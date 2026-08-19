# Main Control Unit Design

## Purpose

Decode the instruction opcode and generate the high-level datapath control signals for the selected RV32I subset. Exact ALU operation selection is delegated to ALU Control.

## Inputs

- `opcode[6:0]`
- `funct3[2:0]` may be used for branch type classification

## Outputs

- `RegWrite`
- `MemRead`
- `MemWrite`
- `ALUSrc`
- `ALUOp`
- `Branch`
- `BranchType`
- `Jump`
- `MemToReg`

## Control signal meanings

`RegWrite`: enable register-file write-back.
`MemRead`: enable data-memory read for LW.
`MemWrite`: enable data-memory write for SW.
`ALUSrc`: select immediate for ALU input B when 1; select rs2 when 0.
`ALUOp`: classify the ALU work for downstream ALU Control.
`Branch`: identifies a conditional branch.
`BranchType`: distinguishes BEQ from BNE.
`Jump`: identifies JAL and selects the jump PC target.
`MemToReg`: select memory data rather than ALU result for register write-back.

## Derived control table

| Instruction class | RegWrite | MemRead | MemWrite | ALUSrc | ALUOp | Branch | BranchType | Jump | MemToReg |
|---|---:|---:|---:|---:|---|---:|---|---:|---:|
| R-Type | 1 | 0 | 0 | 0 | R_TYPE | 0 | NONE | 0 | 0 |
| I-Type arithmetic | 1 | 0 | 0 | 1 | I_TYPE | 0 | NONE | 0 | 0 |
| LW | 1 | 1 | 0 | 1 | ADD_ADDR | 0 | NONE | 0 | 1 |
| SW | 0 | 0 | 1 | 1 | ADD_ADDR | 0 | NONE | 0 | 0 |
| BEQ | 0 | 0 | 0 | 0 | SUB_COMPARE | 1 | BEQ | 0 | 0 |
| BNE | 0 | 0 | 0 | 0 | SUB_COMPARE | 1 | BNE | 0 | 0 |
| JAL | 1 | 0 | 0 | 0* | JAL | 0 | NONE | 1 | 0* |

`*` For JAL, `ALUSrc` and `MemToReg` are functionally irrelevant because the normal ALU/memory write-back path is not used for the JAL return address. The implementation will assign deterministic values rather than leave controls unknown.

## Datapath derivation

R-Type reads rs1/rs2, performs an ALU operation selected by ALU Control, and writes the ALU result to rd.

I-Type arithmetic reads rs1, selects the sign-extended immediate for ALU input B, performs the operation selected by ALU Control, and writes the ALU result to rd.

LW calculates `rs1 + I_imm`, reads data memory, and writes memory data to rd.

SW calculates `rs1 + S_imm` and writes rs2 data to data memory. No register write occurs.

BEQ/BNE compare rs1 and rs2 using ALU subtraction. Branch Control interprets Zero according to BranchType. No register or data-memory write occurs.

JAL writes `PC + 4` to rd and selects `PC + J_imm` as the next PC.

## Assumptions

The opcode primarily identifies the instruction class. `funct3` distinguishes BEQ/BNE and is available to Main Control. Exact R-Type/I-Type ALU operations are intentionally delegated to ALU Control. No unsupported ISA instruction is assigned an active architectural operation.
