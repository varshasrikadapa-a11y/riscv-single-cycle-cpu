# ALU Control Analysis

## Predictions

ALU Control is combinational. For every supported input combination, the predicted exact ALU operation is:

| ALUOp | funct3 | funct7 | Predicted operation |
|---|---|---|---|
| 00 | X | X | ADD |
| 01 | X | X | SUB |
| 10 | 000 | 0000000 | ADD |
| 10 | 000 | 0100000 | SUB |
| 10 | 111 | 0000000 | AND |
| 10 | 110 | 0000000 | OR |
| 10 | 100 | 0000000 | XOR |
| 10 | 010 | 0000000 | SLT |
| 11 | 000 | X | ADD |
| 11 | 111 | X | AND |
| 11 | 110 | X | OR |
| 11 | 100 | X | XOR |
| 11 | 010 | X | SLT |

## Expected architectural behavior

1. LW and SW must always produce ADD for effective-address calculation.
2. BEQ and BNE must always produce SUB for register comparison.
3. R-Type ADD and SUB require funct7 to distinguish the two instructions because both use funct3=000.
4. R-Type logical/set-less-than operations are selected primarily by funct3 in this subset.
5. I-Type arithmetic operations are selected by funct3.
6. Unsupported function combinations must not accidentally map to an unintended supported operation.

## Resource/timing prediction

The block is a small combinational decode network: comparisons against ALUOp, funct3, and selected funct7 bits. No registers or clock are required. Its delay contributes to the single-cycle critical path when the instruction uses the ALU.

## Verification plan

Test all six R-Type operations, all five I-Type operations, ADD_ADDR, SUB_COMPARE, and invalid function combinations. Compare the exact `ALUControl` output against the derived table.
