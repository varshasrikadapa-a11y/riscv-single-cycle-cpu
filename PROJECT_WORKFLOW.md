# Project Workflow Rules

These rules govern the RISC-V single-cycle CPU project and are followed throughout development.

## GitHub Commit Rule

**Every completed project phase must be committed to the GitHub repository.**

For each phase, commit the relevant learning notes, design documents, analysis/predictions, verification results, RTL, testbenches, measurements, or review documents produced during that phase.

Commit messages should clearly identify the phase/module, for example:

- `Phase 1: RISC-V foundations and architecture`
- `Phase 1: instruction encoding and decoding`
- `Design: immediate generator`
- `RTL: ALU`
- `Verify: register file`
- `Review: complete datapath`

## Development Discipline

1. Concept and architecture come before RTL.
2. Derive instruction encoding, immediates, datapath connections, control signals, timing, and memory behavior before implementation.
3. Every instruction must have an exact hardware path and control behavior.
4. Every RTL module must correspond to a previously explained architectural block.
5. Verification must explain behavior signal-by-signal and cycle-by-cycle; passing tests alone are not considered sufficient.
6. Do not silently expand the supported ISA or add advanced processor features.
7. Record assumptions about clocking, reset, memory latency, memory implementation, FPGA behavior, and tool behavior.
8. Keep the repository synchronized with the learning/design/verification progress made in ChatGPT.

## Current Project

32-bit single-cycle RISC-V processor using Verilog HDL, Xilinx Vivado/XSim, and FPGA-oriented verification.

Supported subset: ADD, SUB, AND, OR, XOR, SLT, ADDI, ANDI, ORI, XORI, SLTI, LW, SW, BEQ, BNE, JAL.
