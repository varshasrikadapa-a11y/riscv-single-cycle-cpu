# ALU Control Verification

## Verification target

Verify that `alu_control` maps every supported ALUOp/funct3/funct7 combination to the exact ALU operation derived during design.

## Test cases

- ADD_ADDR → ADD
- SUB_COMPARE → SUB
- R-Type ADD
- R-Type SUB
- R-Type AND
- R-Type OR
- R-Type XOR
- R-Type SLT
- I-Type ADDI
- I-Type ANDI
- I-Type ORI
- I-Type XORI
- I-Type SLTI
- Invalid R-Type funct7/funct3 combinations
- Invalid I-Type funct3

## Observed simulation

The user-provided Vivado XSim waveform shows `errors[31:0] = 00000000` throughout the test sequence. The visible `ALUControl[2:0]` sequence matches the expected operation encodings for the exercised valid cases: ADD=0, SUB=1, AND=2, OR=3, XOR=4, SLT=5. The final invalid cases return the deterministic safe default ADD=0.

## Result

**PASS** — all testbench checks report zero accumulated errors.

## Signal-level interpretation

- `ALUOp=00` produces `ALUControl=000` for address calculation.
- `ALUOp=01` produces `ALUControl=001` for branch comparison.
- `ALUOp=10` uses R-Type function fields to select the exact operation.
- `ALUOp=11` uses `funct3` to select the I-Type operation.
- Invalid combinations remain deterministic and do not create an unknown output.

## Verification limitation

This verification establishes the decoder mapping. It does not yet verify the arithmetic behavior of the ALU itself; that belongs to ALU module verification.
