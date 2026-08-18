# PC / Next-PC Analysis — Measured vs Predicted

## Prediction

The PC is a 32-bit synchronous state register. The next-PC logic is combinational and selects `PC+4`, `PC+B_imm`, or `PC+J_imm`.

## Measurement

XSim waveform confirms the predicted sequence:

`0 → 4 → 8 → 0x1C → 0x20 → 0x2C → 0x54 → 0x5C → 0x50`

The waveform also shows `errors = 0`.

## Comparison

- Reset to zero: predicted and measured — PASS
- Sequential +4: predicted and measured — PASS
- Taken branch: predicted and measured — PASS
- Not-taken branch: predicted and measured — PASS
- JAL target: predicted and measured — PASS
- Jump priority: predicted and measured — PASS
- Negative branch offset: predicted and measured — PASS

## Timing interpretation

The candidate next addresses and MUX are combinational. The selected address is captured into the PC at the active clock edge. This matches the single-cycle architectural model.

## FPGA measurement status

No post-synthesis/post-implementation timing or resource claim is made here. Those measurements remain for the Vivado FPGA phase.
