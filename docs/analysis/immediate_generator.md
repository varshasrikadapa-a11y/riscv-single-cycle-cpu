# Immediate Generator — Analysis & Predictions

## Purpose
Predict the behavior and implementation characteristics of the combinational Immediate Generator before RTL.

## Architectural Inputs and Output

- Input: `instruction[31:0]`
- Output: `immediate[31:0]`
- Clock: none
- Reset: none
- Logic: purely combinational

## Format Selection Predictions

For the supported subset, opcode identifies the immediate format:

| Opcode | Format | Immediate use |
|---|---|---|
| `0010011` | I-Type | arithmetic immediate |
| `0000011` | I-Type | LW effective address |
| `0100011` | S-Type | SW effective address |
| `1100011` | B-Type | BEQ/BNE branch target |
| `1101111` | J-Type | JAL target |

R-Type does not require an immediate.

## Immediate Reconstruction

I-Type:
`sign_extend(instruction[31:20])`

S-Type:
`sign_extend({instruction[31:25], instruction[11:7]})`

B-Type:
`sign_extend({instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0})`

J-Type:
`sign_extend({instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0})`

## Sign Extension Prediction

The source immediate is signed. Its most significant bit is replicated into all newly added upper bits. Positive values therefore receive zeros; negative two's-complement values receive ones.

## Timing Prediction

The block is combinational. No state is stored and no clock edge is required. Its propagation delay contributes to the single-cycle datapath whenever an immediate is consumed by the ALU or PC target calculation.

## Critical-Path Prediction

The Immediate Generator itself should be a relatively small combinational block consisting primarily of bit wiring, concatenation, sign extension, and opcode-based selection. It should generally contribute less delay than instruction memory, register-file read, ALU, or data-memory access in the relevant paths, although the actual FPGA delay must be measured after synthesis and implementation.

## Verification Predictions

Verification should cover:

1. Positive I-Type immediate.
2. Negative I-Type immediate and sign extension.
3. Positive S-Type immediate reconstruction.
4. Negative S-Type immediate reconstruction.
5. Positive and negative B-Type offsets.
6. Correct B-Type implicit `imm[0] = 0`.
7. Positive and negative J-Type offsets.
8. Correct J-Type implicit `imm[0] = 0`.
9. Opcode-based format selection.
10. No unintended dependence on clock or reset.

## Expected Edge Cases

- Maximum positive representable immediate for each format.
- Most negative representable immediate for each format.
- Zero immediate.
- Sign bit set.
- Branch and jump offsets with the low bit implicitly zero.

## Resource Prediction

Because the design is mostly wiring and simple combinational selection, expected FPGA resource usage is small. Exact LUT count and timing are implementation-dependent and must be measured in Vivado rather than assumed.

## Stop Condition

RTL is permitted only after the predictions above are understood and confirmed. Actual FPGA timing/resource numbers remain unmeasured until synthesis/implementation.
