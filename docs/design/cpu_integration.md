# CPU Integration Design — Top-Level Signal Connections

## Scope
This document derives the top-level connections for integrating the already-verified educational RV32I subset modules. No RTL integration is defined here beyond signal-level architecture.

## Assumptions
- 32-bit single-cycle datapath.
- Harvard-style instruction/data interfaces.
- Instruction memory read is combinational.
- Data memory read is combinational; data memory write is synchronous.
- PC is synchronous state and resets synchronously to 0.
- Existing PC module is `pc_next` with inputs `Branch`, `BranchTaken`, `Jump`, `branch_imm`, `jump_imm`, and outputs `pc`, `pc_next_addr`.
- Existing ALU provides `Result` and `Zero`.
- Existing control provides `BranchType` and `MemToReg`.

## Top-Level Data Flow

`pc -> instruction memory -> instruction_decoder -> register file/control/immediate generator -> ALU -> data memory/write-back -> register file`.

The PC module receives branch/jump decisions and immediates and selects the next PC.

## Signal-by-Signal Connections

### Instruction fetch
- `imem_addr = pc`.
- `instruction = imem_rdata`.
- The decoder receives `instruction`.

### Decoder outputs
- `opcode -> main_control.opcode`.
- `funct3 -> main_control.funct3` and `alu_control.funct3`.
- `funct7 -> alu_control.funct7`.
- `rs1 -> register_file.rs1`.
- `rs2 -> register_file.rs2`.
- `rd -> register_file.rd`.

### Register file
- `ReadData1 -> ALU A`.
- `ReadData2 -> ALU B` when `ALUSrc=0`.
- `WriteData <- write-back mux output`.
- `RegWrite <- main control RegWrite`.

### Immediate generator
- `instruction -> immediate_generator.instruction`.
- `immediate -> ALU B` when `ALUSrc=1`.
- For branches, the same generated B-type immediate goes to `pc_next.branch_imm`.
- For JAL, the generated J-type immediate goes to `pc_next.jump_imm`.

### ALU input selection
`ALU_B = ALUSrc ? immediate : ReadData2`.

Thus:
- R-type: register + register.
- I-type arithmetic: register + immediate.
- LW: base register + offset.
- SW: base register + offset.
- Branch comparison: register + register, with subtraction selected by ALU control.

### ALU control
- `ALUOp`, `funct3`, and `funct7` feed `alu_control`.
- `ALUControl -> ALU.AL​​U_Control`.
- `ReadData1 -> ALU.A`.
- selected ALU-B value -> `ALU.B`.

## BranchTaken Derivation

The ALU's `Zero` signal means `ALU Result == 0`.
For branch instructions the ALU performs subtraction, so:

`Zero = 1` means the two register operands are equal.

For BEQ:

`BranchTaken = Branch & (BranchType == BEQ) & Zero`.

For BNE:

`BranchTaken = Branch & (BranchType == BNE) & ~Zero`.

If `Branch=0`, `BranchTaken` must be 0 regardless of ALU Zero. This prevents an ordinary arithmetic instruction producing zero from changing the PC.

A compact form is:

`BranchTaken = Branch & ((BranchType == BEQ) ? Zero : ~Zero)`.

The exact encoding used for `BranchType` must match the existing main-control implementation; the integration must not invent a new encoding.

## PC Connections

- `pc_next.clk <- clk`.
- `pc_next.reset <- reset`.
- `pc_next.Branch <- MainControl.Branch`.
- `pc_next.BranchTaken <- derived BranchTaken`.
- `pc_next.Jump <- MainControl.Jump`.
- `pc_next.branch_imm <- B-type immediate`.
- `pc_next.jump_imm <- J-type immediate`.
- `pc_next.pc -> imem_addr`.

The existing PC logic implements:

1. JAL target when `Jump=1`.
2. Taken branch target when `Branch=1` and `BranchTaken=1`.
3. Otherwise `PC+4`.

## Data Memory Connections

For LW/SW:
- `dmem_addr = ALU Result`.
- `dmem_wdata = ReadData2`.
- `dmem_read = MemRead`.
- `dmem_write = MemWrite`.
- `dmem_byte_en = 4'b1111` for the initial full-word subset.

For arithmetic/branch/JAL instructions, the memory controls remain inactive.

## Three-Way Write-Back

The register-file write data must select among three architectural sources:

- `00`: ALU Result.
- `01`: Data Memory read data.
- `10`: PC + 4.

This is required because JAL writes the return address `PC+4`, while ALU instructions write the ALU result and LW writes memory data.

### Instruction mapping

| Instruction class | Write-back source | RegWrite |
|---|---|---:|
| R-type | ALU Result | 1 |
| I-type arithmetic | ALU Result | 1 |
| LW | Data Memory | 1 |
| SW | none | 0 |
| BEQ/BNE | none | 0 |
| JAL | PC + 4 | 1 |

The existing `MemToReg` signal can distinguish ALU result from memory data for the non-JAL cases, but it is not sufficient by itself to represent the third JAL source. Therefore the integration must derive a three-way write-back selection, with JAL taking priority over the normal ALU/memory distinction.

One clean integration-level derivation is:

- if `Jump=1`: `WBSelect=10`.
- else if `MemToReg=1`: `WBSelect=01`.
- else: `WBSelect=00`.

`WriteData` is then selected by `WBSelect` and connected to the register file's `WriteData` input.

## PC+4 for JAL

`PC+4` must be calculated from the current PC, not from `pc_next_addr`.

`pc_plus_4 = pc + 32'd4`.

This value is written to `rd` when JAL executes. Simultaneously, the PC module selects `pc + jump_imm` as the next PC.

## Architectural Trace Examples

### ADD x5,x1,x2
- `ALUSrc=0`.
- ALU A=`x1`.
- ALU B=`x2`.
- ALU operation=ADD.
- WB source=ALU Result.
- `RegWrite=1`.
- `PC_next=PC+4`.

### LW x5,8(x1)
- `ALUSrc=1`.
- ALU A=`x1`.
- ALU B=8.
- ALU operation=ADD.
- `dmem_addr=ALU Result`.
- `MemRead=1`.
- WB source=memory data.
- `RegWrite=1`.
- `PC_next=PC+4`.

### BEQ x1,x2,offset
- `ALUSrc=0`.
- ALU A=`x1`.
- ALU B=`x2`.
- ALU operation=SUB.
- `Zero=1` iff `x1==x2`.
- `BranchTaken=Branch & BEQ & Zero`.
- If taken: `PC_next=PC+branch_imm`.
- If not taken: `PC_next=PC+4`.
- `RegWrite=0`.

### BNE x1,x2,offset
Same datapath, but:
- `BranchTaken=Branch & BNE & ~Zero`.

### JAL x5,offset
- `Jump=1`.
- `pc_next` selects `PC+jump_imm`.
- `pc_plus_4=PC+4`.
- `WBSelect=10`.
- `WriteData=PC+4`.
- `RegWrite=1`.
- `rd=x5` receives the return address.

## Integration Boundary

No existing verified module needs to be rewritten merely to connect the CPU. The top-level integration module is responsible for wiring these interfaces and for the two integration-level decisions derived here: `BranchTaken` and the three-way write-back selection.

## Next Step

Before generating the CPU RTL, verify the exact `BranchType` values in `main_control` and the exact register-file path/name in the repository. Then instantiate the modules using their verified port declarations and create a top-level integration testbench covering R-type, I-type, LW, SW, BEQ, BNE, and JAL.
