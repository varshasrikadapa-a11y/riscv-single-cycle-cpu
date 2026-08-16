# ALU — Analysis and Predictions

## Scope

This document records pre-RTL predictions for the 32-bit combinational ALU in the educational RV32I single-cycle processor.

## Assumptions

- 32-bit operands and result.
- Combinational ALU; no clock and no reset.
- Supported operations are ADD, SUB, AND, OR, XOR, and signed SLT.
- ALU_Control is a 3-bit internal control code.
- Zero is asserted when the final ALU result is zero.
- Invalid control codes 110 and 111 are defined to produce Result=0 and Zero=1.
- Branch control is outside the ALU. The ALU only supplies comparison information through Zero.

## Functional Predictions

| Control | Operation | Expected result |
|---|---|---|
| 000 | ADD | A + B |
| 001 | SUB | A - B |
| 010 | AND | A & B |
| 011 | OR | A \| B |
| 100 | XOR | A ^ B |
| 101 | SLT | 1 if signed A < signed B, otherwise 0 |
| 110 | Invalid | 0 |
| 111 | Invalid | 0 |

## Zero Prediction

Zero = 1 exactly when Result == 0.

For BEQ, the surrounding branch logic can use Zero=1 to indicate equality after subtraction. For BNE, Zero=0 indicates inequality. The ALU does not itself select the branch target.

## Instruction-Level Predictions

### ADD
A and B come from the register file. Result is A+B and can be written to rd.

### SUB
Result is A-B. The same operation supplies equality information for BEQ/BNE when the operands are compared.

### Logical operations
AND, OR, and XOR operate independently on the 32 bit positions.

### SLT
The comparison is signed and the result is exactly 32'd1 or 32'd0.

### LW/SW
The ALU performs ADD to calculate the effective address: base register + sign-extended immediate. Memory access is outside the ALU.

## Timing Prediction

The ALU contributes combinational propagation delay to every instruction that uses it. In the single-cycle CPU, the complete critical path is expected to be determined by the slowest instruction path, likely a memory instruction such as LW under the assumed asynchronous data-memory model. Exact FPGA delay must be measured after synthesis/implementation and must not be invented from this analysis.

## Resource Prediction

A synthesizer is expected to infer ordinary FPGA arithmetic and logic resources from the RTL. ADD/SUB may map to FPGA carry-chain resources; bitwise operations map to LUT logic; SLT and Zero require comparison logic. Exact LUT/FF/carry resource counts are implementation-dependent and will be measured after synthesis.

## Verification Prediction

Minimum functional coverage should include:

- ADD positive and negative two's-complement operands.
- SUB positive, zero, and negative results.
- AND, OR, XOR bit patterns.
- SLT true/false cases including signed negative-vs-positive comparisons.
- Zero asserted for an actual zero result and deasserted otherwise.
- All valid ALU control codes.
- Both invalid control codes.
- Boundary values such as 0x00000000, 0xFFFFFFFF, 0x80000000, and 0x7FFFFFFF.

## Prediction vs Measurement

At this stage no RTL, simulation, synthesis, timing, or resource measurements exist. Those values will be added only after implementation and verification.
