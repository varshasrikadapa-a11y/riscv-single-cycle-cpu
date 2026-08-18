# PC / Next-PC Design Review

## Review result: PASS

### Architectural correctness

- 32-bit PC stores the byte address of the current instruction.
- Sequential next address is `PC + 4` for the 32-bit instruction width.
- Branch target is `PC + B_imm` when the branch condition is taken.
- JAL target is `PC + J_imm`.
- JAL return address `PC + 4` belongs to the separate register write-back path.

### Control behavior

- BEQ uses `Zero == 1` for branch taken.
- BNE uses `Zero == 0` for branch taken.
- Defensive next-PC priority is Jump > taken Branch > sequential.

### Verification evidence

XSim behavioral simulation completed with `errors = 0`. The supplied waveform confirms reset, sequential +4 progression, taken and not-taken branches, JAL, simultaneous branch/jump priority, and a negative branch offset.

### Timing/resource scope

Functional review passes. FPGA timing and resource utilization are intentionally deferred to the Vivado implementation phase.

## Final disposition

**APPROVED for progression to the next architectural block.**
