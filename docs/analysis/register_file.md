# Register File Analysis — Measured vs Predicted

## Predicted Behavior

The register file is a 32 × 32-bit storage structure with two combinational read ports and one synchronous write port.

## Timing Predictions

- Read address changes should propagate to the corresponding read data without waiting for a clock edge.
- A valid write occurs only at the active clock edge when `RegWrite=1` and `rd!=0`.
- A write to x0 must have no architectural effect.
- Reset is synchronous in the initial implementation; all registers are predicted to become zero on the active edge while reset is asserted.

## Measured Functional Behavior

Vivado XSim confirmed the planned functional behavior with `errors = 0`.

Observed results matched predictions for reset, normal writes, simultaneous two-port reads, `RegWrite=0`, x0 write protection, x0 reads, and combinational read selection.

## Resource Expectations

The logical storage requirement is 32 × 32 = 1024 bits, excluding implementation overhead. Actual LUT/FF/BRAM mapping is FPGA/tool dependent and must be measured in Vivado rather than assumed.

## Timing Status

No FPGA synthesis or implementation timing measurements have been performed yet. Those measurements remain for the FPGA implementation phase.
