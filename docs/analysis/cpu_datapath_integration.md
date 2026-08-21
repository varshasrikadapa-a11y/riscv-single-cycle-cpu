# CPU Datapath Integration — Analysis Predictions

## Objective
Predict the behavior of the integrated single-cycle datapath before CPU RTL and integration simulation.

## Timing Prediction
For each instruction, all combinational stages occur within one clock period. The active edge updates PC and register-file state. Critical path is expected to be dominated by instruction memory + decode/control + register read + ALU + (for LW) data-memory read + write-back selection.

## Instruction-Class Predictions

### ADD
PC_next = PC + 4. ALU A=rs1 value, B=rs2 value, operation ADD. No memory access. rd receives ALU result.

### ADDI
PC_next = PC + 4. ALU A=rs1 value, B=sign-extended immediate, operation ADD. No memory access. rd receives ALU result.

### LW
ALU A=rs1 value, B=sign-extended immediate, operation ADD. ALU result is effective byte address. Data memory read is asserted. Returned data is selected for write-back to rd. PC_next = PC + 4.

### SW
ALU A=rs1 value, B=sign-extended S immediate, operation ADD. ALU result is effective byte address. ReadData2 is written to data memory. RegWrite=0. PC_next = PC + 4.

### BEQ
ALU A=rs1 value, B=rs2 value, operation SUB. Zero=1 predicts equality and BranchTaken=1. If taken, PC_next=PC+B immediate; otherwise PC+4.

### BNE
ALU A=rs1 value, B=rs2 value, operation SUB. Zero=0 predicts inequality and BranchTaken=1. If not taken, Zero=1 and PC_next=PC+4.

### JAL
Jump=1. PC_next=PC+J immediate. rd must receive PC+4. No data-memory access. This instruction requires a dedicated/explicit PC+4 write-back selection in the integrated datapath.

## Key Integration Risk
The current control interface has MemToReg for ALU-vs-memory selection, but JAL requires a third write-back source (PC+4). Integration must therefore add a JAL-aware write-back selection without changing the already-verified individual modules unless necessary.

## Resource Prediction
Integration adds mostly muxes, wires, branch comparison logic, and top-level interconnect. Existing blocks remain reusable. Memory implementation determines whether the strict single-cycle timing assumption is realizable on the target FPGA.

## Verification Prediction
Expected first integration tests should use small hand-encoded programs and check, cycle by cycle: PC, instruction, decoded fields, control signals, register operands, immediate, ALU inputs/control/result, memory signals, write-back data, and PC_next.
