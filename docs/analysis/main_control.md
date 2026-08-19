# Main Control Unit Analysis

## Scope

Predict the output controls produced by opcode/funct3 decoding for the supported subset before RTL implementation.

## Prediction by instruction class

- R-Type (`0110011`): register write enabled, register operands selected for ALU, no memory, no branch/jump, ALUOp=`R_TYPE`, ALU result selected for write-back.
- I-Type arithmetic (`0010011`): register write enabled, immediate selected for ALU B, no memory/branch/jump, ALUOp=`I_TYPE`, ALU result selected for write-back.
- LW (`0000011`): register write and memory read enabled, immediate selected for effective-address calculation, memory data selected for write-back, ALUOp=`ADD_ADDR`.
- SW (`0100011`): memory write enabled, immediate selected for effective-address calculation, no register write, ALUOp=`ADD_ADDR`.
- BEQ/BNE (`1100011`): branch enabled, register operands selected, no memory or register write, ALUOp=`SUB_COMPARE`; funct3 determines BranchType.
- JAL (`1101111`): jump and register write enabled; PC target uses J immediate and return-address write-back uses PC+4. Normal ALU/memory controls are functionally irrelevant and will be assigned deterministic values.

## Expected decoding properties

Only one supported instruction class should be active for a valid supported opcode. Unsupported opcodes must not accidentally enable register or memory writes.

## Timing prediction

Main Control is combinational decode logic. Its outputs change as the instruction fields change and are consumed during the same single-cycle datapath evaluation. No clock is required inside the Control Unit.

## Verification priorities

1. Verify every supported opcode maps to its expected controls.
2. Verify BEQ and BNE differ in BranchType while sharing the other branch controls.
3. Verify LW/SW differ in direction: LW reads memory and writes a register; SW writes memory and does not write a register.
4. Verify R-Type versus I-Type differs in ALUSrc and ALUOp classification.
5. Verify JAL asserts Jump and RegWrite.
6. Verify unsupported opcode produces safe inactive controls.
