# ALU Control Design

## Purpose

Convert the high-level `ALUOp` classification from Main Control plus instruction function fields into the exact ALU operation required by the selected RV32I subset.

## Inputs

- `ALUOp[1:0]`
- `funct3[2:0]`
- `funct7[6:0]`

## Output

- `ALUControl[2:0]`

## ALU operation encoding

| ALUControl | Operation |
|---|---|
| `000` | ADD |
| `001` | SUB |
| `010` | AND |
| `011` | OR |
| `100` | XOR |
| `101` | SLT |

## ALUOp interpretation

| ALUOp | Meaning | Exact operation source |
|---|---|---|
| `00` | ADD_ADDR | ADD directly |
| `01` | SUB_COMPARE | SUB directly |
| `10` | R_TYPE | funct3/funct7 |
| `11` | I_TYPE | funct3 |

## R-Type decoding

- `funct3=000`, `funct7=0000000` → ADD
- `funct3=000`, `funct7=0100000` → SUB
- `funct3=111` → AND
- `funct3=110` → OR
- `funct3=100` → XOR
- `funct3=010` → SLT

## I-Type decoding

- `funct3=000` → ADDI → ADD
- `funct3=111` → ANDI → AND
- `funct3=110` → ORI → OR
- `funct3=100` → XORI → XOR
- `funct3=010` → SLTI → SLT

## Memory and branch decoding

- `LW/SW`: `ALUOp=00` → ADD for effective address.
- `BEQ/BNE`: `ALUOp=01` → SUB for comparison.

## Unsupported combinations

Unsupported `funct3/funct7` combinations produce a deterministic safe ALU control value. The ALU Control does not independently enable register or memory writes; those functions remain controlled by Main Control.

## Architectural separation

Main Control classifies the instruction's required datapath behavior. ALU Control selects the exact arithmetic/logic operation. This avoids duplicating complete instruction decoding in the Main Control and makes the ALU operation derivation explicit.

## Assumptions

Combinational logic; no clock or internal state. Exact ALU operation is one of ADD, SUB, AND, OR, XOR, SLT for the supported subset.
