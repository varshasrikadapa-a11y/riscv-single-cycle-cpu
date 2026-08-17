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

## Verification Method

The testbench will drive representative encodings and compare the DUT output against independently derived expected 32-bit signed immediates. Positive and negative values are required so that sign extension is explicitly tested. B-Type and J-Type tests must verify the implicit zero least-significant bit and the non-contiguous source fields.

## Status

RTL and testbench preparation complete. Simulation results are intentionally not marked PASS until an actual XSim run is performed and the waveform/output is reviewed.
