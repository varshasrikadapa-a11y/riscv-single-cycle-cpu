# CPU Datapath Integration — Design

## Scope
Integrate the already-verified Instruction Decoder, Immediate Generator, Main Control, ALU Control, ALU, Register File, and PC/Next-PC blocks into the 32-bit single-cycle CPU datapath. This document defines connections before CPU RTL is written.

## Assumptions
- RV32I educational subset only: ADD, SUB, AND, OR, XOR, SLT, ADDI, ANDI, ORI, XORI, SLTI, LW, SW, BEQ, BNE, JAL.
- 32-bit instructions and datapath.
- Separate instruction/data memory interfaces.
- Instruction memory read is combinational.
- Data memory read is combinational; data memory write is synchronous.
- PC reset is synchronous and initializes PC to 0.
- No pipeline, cache, forwarding, CSR, interrupts, or privilege modes.

## Top-Level Data Flow
PC -> instruction memory -> instruction decoder/control/register file/immediate generator -> ALU -> data memory/write-back -> register file.
PC+4, branch target, and JAL target feed next-PC selection.

## Decoder Connections
- opcode = instruction[6:0]
- rd = instruction[11:7]
- funct3 = instruction[14:12]
- rs1 = instruction[19:15]
- rs2 = instruction[24:20]
- funct7 = instruction[31:25]

Raw fields are extracted uniformly; their semantic meaning depends on opcode/format.

## Register File
- rs1 and rs2 come from decoder.
- ReadData1 is ALU operand A for all ALU-address/compare operations.
- ReadData2 is ALU operand B when ALUSrc=0 and is store write data for SW.
- rd is the write destination.
- WriteData comes from the write-back mux.
- RegWrite comes from Main Control.

## Immediate Generator
Produces one 32-bit signed immediate:
- I/LW: sign-extend instruction[31:20]
- S/SW: sign-extend {instruction[31:25], instruction[11:7]}
- B: sign-extend {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}
- J: sign-extend {instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0}

## Main Control
Main Control receives opcode and funct3 and generates RegWrite, MemRead, MemWrite, ALUSrc, ALUOp, Branch, BranchType, Jump, and MemToReg.

## ALU Input Selection
- ALU A = ReadData1.
- ALU B = ALUSrc ? immediate : ReadData2.
- ALUControl is generated from ALUOp/funct3/funct7.
- ALU result is arithmetic/logical result for ALU instructions or effective address for LW/SW.
- For BEQ/BNE, ALU subtracts ReadData1 - ReadData2 and Zero is used by branch logic.

## Branch Decision
- BEQ: Branch=1, BranchType=0, BranchTaken=Zero.
- BNE: Branch=1, BranchType=1, BranchTaken=~Zero.
- Branch target = PC + branch immediate.
- Sequential target = PC + 4.
- JAL has priority over a taken branch in the existing PC/Next-PC block.

## Data Memory Interface
- dmem_addr = ALU result.
- dmem_wdata = ReadData2.
- LW: dmem_read=1, dmem_write=0, byte_en=4'b1111.
- SW: dmem_read=0, dmem_write=1, byte_en=4'b1111.
- Other instructions: both memory controls 0.

## Write-Back
Three architectural write-back sources are required:
1. ALU result for R/I arithmetic and address-independent ALU operations.
2. dmem_rdata for LW.
3. PC+4 for JAL.

The existing MemToReg signal distinguishes ALU versus memory data, but JAL additionally requires a PC+4 write-back path. Therefore CPU integration needs a JAL-aware write-back selection; this must not be hidden by incorrectly writing ALU result into rd for JAL.

## JAL Path
For JAL:
- rd receives PC+4.
- PC_next = PC + jump immediate.
- No register-file source operand is required.
- No data-memory access occurs.

## PC/Next-PC
The existing PC block computes:
- pc_plus_4 = PC + 4
- branch_target = PC + branch_imm
- jump_target = PC + jump_imm
- pc_next = Jump ? jump_target : (Branch && BranchTaken ? branch_target : pc_plus_4)

## Integration Priority
JAL > taken branch > sequential PC+4, matching the existing PC block.

## Architectural Timing
All combinational datapath work occurs during one clock period. At the active edge, PC and register-file state update. This requires instruction/data reads to meet the same-cycle assumption; true synchronous BRAM read latency would violate the strict single-cycle LW assumption and must be addressed separately.

## Integration Verification Strategy
Verify at least one complete path for each instruction class:
- ADD: register -> ALU -> register
- ADDI: register + immediate -> ALU -> register
- LW: register + immediate -> address -> memory -> register
- SW: register + immediate -> address; second register -> memory
- BEQ/BNE: register compare -> branch decision -> PC target/sequential
- JAL: PC+4 -> rd and PC+immediate -> PC
