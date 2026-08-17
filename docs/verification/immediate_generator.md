# Immediate Generator Verification

## Scope

Verify the combinational Immediate Generator for every supported immediate format in the selected ISA subset.

## Test Categories

1. I-Type positive immediate
2. I-Type negative immediate
3. S-Type positive immediate
4. S-Type negative immediate
5. B-Type positive offset
6. B-Type negative offset
7. J-Type positive offset
8. J-Type negative offset
9. Unsupported opcode behavior

## Expected Reconstruction

I-Type:
`sign_extend(instruction[31:20])`

S-Type:
`sign_extend({instruction[31:25], instruction[11:7]})`

B-Type:
`sign_extend({instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0})`

J-Type:
`sign_extend({instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0})`

## Simulation Evidence

User-provided XSim behavioral simulation waveform was reviewed. The waveform shows the expected immediate sequence:

| Test | Observed immediate | Expected | Status |
|---|---|---|---|
| I-Type +10 | `0000000A` | `0000000A` | PASS |
| I-Type -4 | `FFFFFFFC` | `FFFFFFFC` | PASS |
| S-Type +12 | `0000000C` | `0000000C` | PASS |
| S-Type -4 | `FFFFFFFC` | `FFFFFFFC` | PASS |
| B-Type +4 | `00000004` | `00000004` | PASS |
| B-Type -4 | `FFFFFFFC` | `FFFFFFFC` | PASS |
| J-Type +4 | `00000004` | `00000004` | PASS |
| J-Type -4 | `FFFFFFFC` | `FFFFFFFC` | PASS |
| Unsupported opcode | `00000000` | `00000000` | PASS |

The waveform also shows `errors = 0` throughout the run, indicating no mismatches were reported by the testbench.

## Signal-Level Interpretation

- I-Type values are extracted from `instruction[31:20]` and sign-extended.
- S-Type values are reconstructed from `instruction[31:25]` and `instruction[11:7]`.
- B-Type values correctly reconstruct the non-contiguous fields and implicit `imm[0] = 0`.
- J-Type values correctly reconstruct the non-contiguous fields and implicit `imm[0] = 0`.
- Negative values preserve the sign through 32-bit sign extension.
- Unsupported opcode behavior matches the defined zero default.

## Result

**PASS — functional behavioral verification completed for the planned test set.**

This verification demonstrates functional correctness of the Immediate Generator for the tested representative values. It does not yet establish FPGA timing or resource utilization; those remain synthesis/implementation measurements for later stages.
