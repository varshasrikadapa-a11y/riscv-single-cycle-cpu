# CPU Integration Design

This document derives the top-level signal connections for integrating the existing verified modules.

## Branch decision
The ALU performs subtraction for BEQ/BNE. `Zero=1` means the subtraction result is zero, hence the operands are equal.

BEQ: `BranchTaken = Branch & Zero`.

BNE: `BranchTaken = Branch & ~Zero`.

Using the control unit's `BranchType`: `BranchTaken = Branch & ((BranchType == BEQ) ? Zero : ~Zero)`. The actual BranchType encoding must match `main_control.v`; it must not be invented at integration time.

If `Branch=0`, `BranchTaken=0` regardless of Zero. This prevents an ordinary ALU operation that produces zero from changing the PC.

## Write-back
Three architectural write-back sources are required:

- `00` = ALU Result
- `01` = Data Memory read data
- `10` = PC + 4

Derivation:

- `Jump=1` -> `WBSelect=10`
- otherwise `MemToReg=1` -> `WBSelect=01`
- otherwise -> `WBSelect=00`

R-type and I-type arithmetic therefore write ALU Result; LW writes memory data; JAL writes PC+4. SW and BEQ/BNE have RegWrite=0.

`pc_plus_4 = pc + 32'd4` must use the current PC. For JAL, the PC module simultaneously selects `pc + jump_imm` as the next PC while the register file receives `pc+4` as WriteData.

## Core connections
- `pc -> imem_addr`; `imem_rdata -> instruction`.
- Decoder outputs: `opcode -> main_control`; `funct3 -> main_control + alu_control`; `funct7 -> alu_control`; `rs1/rs2/rd -> register_file`.
- Register file `ReadData1 -> ALU A`; `ReadData2 -> ALU B` when `ALUSrc=0`.
- Immediate generator output -> ALU B when `ALUSrc=1`.
- `ALUOp + funct3 + funct7 -> alu_control -> ALU_Control`.
- `ALU Result -> dmem_addr`.
- `ReadData2 -> dmem_wdata`.
- `MemRead/MemWrite -> dmem_read/dmem_write`.
- `4'b1111 -> dmem_byte_en` for full-word LW/SW.
- Write-back mux output -> register file `WriteData`.
- Main-control `RegWrite -> register_file.RegWrite`.
- B-type immediate -> `pc_next.branch_imm`; J-type immediate -> `pc_next.jump_imm`.
- `Branch`, derived `BranchTaken`, `Jump`, `clk`, and `reset` -> `pc_next`.
- `pc_next.pc -> pc/imem address`.

## PC behavior
Existing `pc_next` computes `pc+4`, `pc+branch_imm`, and `pc+jump_imm` and gives priority JAL > taken branch > sequential.

## Timing assumptions
Instruction read and data read are combinational; data write and PC update occur on the active clock edge. This is the strict educational single-cycle model and is not a claim about synchronous Xilinx BRAM behavior.

## Next implementation step
Confirm the existing `BranchType` encoding, then instantiate the verified modules in a top-level CPU. The top-level testbench must exercise R-type, I-type, LW, SW, BEQ taken/not-taken, BNE taken/not-taken, and JAL with signal-level checks.
