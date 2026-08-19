# Main Control Design Review

## Verdict

**APPROVED** for the current selected ISA subset.

## Evidence

- Control logic is combinational and has no clock/state.
- Supported opcodes are decoded into the intended high-level datapath controls.
- BEQ and BNE share branch controls and are distinguished by `funct3` through `BranchType`.
- LW enables memory read and memory-to-register write-back.
- SW enables memory write and disables register write-back.
- R-Type and I-Type arithmetic use separate `ALUOp` classifications for downstream ALU Control.
- JAL enables jump and register write for the `PC+4` return-address path.
- Unsupported opcode defaults are safe and do not enable architectural writes.
- User-provided Vivado XSim waveform reports `errors=0`.

## Scope limitations

This review covers only the selected educational RV32I subset. No unsupported ISA instructions, exceptions, CSR/privilege behavior, interrupts, caches, or pipeline behavior are included.

## Follow-up

Proceed to ALU Control design and verification. Main Control must remain stable while exact ALU operation decoding is developed separately.
