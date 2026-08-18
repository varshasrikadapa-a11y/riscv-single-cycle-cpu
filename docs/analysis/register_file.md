# Register File Analysis

## Predicted Behavior

The register file is a 32 × 32-bit storage structure with two combinational read ports and one synchronous write port.

## Timing Predictions

- Read address changes should propagate to the corresponding read data without waiting for a clock edge.
- A valid write occurs only at the active clock edge when `RegWrite=1` and `rd!=0`.
- A write to x0 must have no architectural effect.
- Reset is synchronous in the initial implementation; all registers are predicted to become zero on the active edge while reset is asserted.

## Functional Predictions

- Reading x0 always returns zero.
- Reading any x1-x31 returns the most recently committed value.
- Two different source registers can be read simultaneously.
- Both read ports may independently select x0.
- Writing one register must not alter unrelated registers.

## Resource Expectations

The logical storage requirement is 32 × 32 = 1024 bits, excluding implementation overhead. Actual LUT/FF/BRAM mapping is FPGA/tool dependent and must be measured in Vivado rather than assumed.

## Verification Priorities

1. Reset clears all registers.
2. Read x0 returns zero.
3. Write x0 is ignored.
4. Normal write/readback works.
5. Two read ports return correct values simultaneously.
6. RegWrite=0 prevents writes.
7. Unrelated registers remain unchanged.

## Timing Assumption

This design intentionally uses combinational register reads to support the strict single-cycle datapath. No hidden pipeline stage or extra cycle is introduced.
