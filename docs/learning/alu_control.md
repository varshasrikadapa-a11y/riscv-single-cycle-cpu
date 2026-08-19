# ALU Control — Learning

## Purpose

ALU Control converts the high-level `ALUOp` from Main Control plus instruction function fields into the exact ALU operation. Main Control classifies the instruction; ALU Control selects the precise operation.

## Inputs

- `ALUOp[1:0]`
- `funct3[2:0]`
- `funct7[6:0]` (needed to distinguish ADD from SUB for R-Type)

## Output

- Exact ALU operation control code.

## Why two levels of control?

Main Control should not have to decode every ALU function detail. For example, ADD and SUB are both R-Type and therefore share the same high-level `ALUOp`. ALU Control then examines `funct3` and `funct7` to choose ADD or SUB.

Similarly, LW and SW both need an address calculation, so Main Control gives `ALUOp=ADD_ADDR`; ALU Control maps this directly to ADD. BEQ/BNE both require comparison by subtraction, so `ALUOp=SUB_COMPARE` maps to SUB.

## Exact operations for this project

The ALU supports:

- ADD
- SUB
- AND
- OR
- XOR
- SLT

### R-Type decoding

Opcode `0110011` is already classified by Main Control as `R_TYPE`. Exact operation comes from `funct3` and, for ADD/SUB, `funct7`.

Expected mapping:

| funct7 | funct3 | Operation |
|---|---|---|
| `0000000` | `000` | ADD |
| `0100000` | `000` | SUB |
| `0000000` | `111` | AND |
| `0000000` | `110` | OR |
| `0000000` | `100` | XOR |
| `0000000` | `010` | SLT |

### I-Type arithmetic decoding

Opcode `0010011` is classified as `I_TYPE`. Exact operation is determined by `funct3` for this selected subset:

| funct3 | Operation |
|---|---|
| `000` | ADD |
| `111` | AND |
| `110` | OR |
| `100` | XOR |
| `010` | SLT |

### Fixed operations

- `ADD_ADDR` → ADD for LW/SW effective addresses.
- `SUB_COMPARE` → SUB for BEQ/BNE comparison.

## Branch relationship

ALU Control does not decide whether a branch is taken. It only makes the ALU perform subtraction. The ALU's `Zero` output then indicates whether `rs1-rs2` is zero. Branch logic combines `Zero` with `BranchType`:

- BEQ: `Zero=1` → taken.
- BNE: `Zero=0` → taken.

## Important distinction

`ALUSrc` selects the source of ALU input B. ALU Control selects the operation performed on the selected A and B values. These are separate decisions.
