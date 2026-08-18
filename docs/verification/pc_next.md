# PC / Next-PC Verification

## Simulation evidence

XSim behavioral simulation of `tb_pc_next` completed successfully.

The supplied waveform shows `errors = 0` throughout the simulation.

## Observed cases

- Synchronous reset establishes `PC = 0`.
- Sequential execution advances 0 → 4 → 8.
- Taken branch at PC=8 with offset 20 produces target 28 (`0x1C`).
- Not-taken branch at PC=28 selects 32 (`PC + 4`).
- Taken branch at PC=32 with offset 12 produces 44 (`0x2C`).
- JAL at PC=44 with offset 40 produces 84 (`0x54`).
- Simultaneous branch and jump control demonstrates jump priority: PC=84 with jump offset 8 produces 92 (`0x5C`).
- Negative branch offset at PC=92 with offset -12 produces 80 (`0x50`).

## Result

All testbench checks passed with `errors = 0`. Functional verification PASS.

## Scope

This verifies functional PC/next-PC behavior in behavioral simulation. FPGA timing and resource measurements remain part of the later Vivado implementation phase.
