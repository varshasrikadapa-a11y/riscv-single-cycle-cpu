# Project Progress — Single-Cycle RV32 CPU

**Target:** Basys-3 / Artix-7 `xc7a35tcpg236-1`  
**Tool:** Vivado 2018.2 / XSim  
**Clock constraint:** 100 MHz, 10.000 ns  
**Architecture:** 32-bit single-cycle RV32I educational subset, separate instruction/data interfaces.

## Completed milestones

- [x] Instruction decoder, immediate generator, main control, ALU control, ALU, register file, and PC/next-PC modules.
- [x] Integrated CPU datapath.
- [x] Supported subset: ADD, SUB, AND, OR, XOR, SLT, ADDI, ANDI, ORI, XORI, SLTI, LW, SW, BEQ, BNE, JAL.
- [x] CPU testbench and behavioral simulation waveform.
- [x] Basys-3 top-level wrapper with behavioral instruction/data memories.
- [x] Debug observation ports: PC and ALU result.
- [x] SW0-controlled LED output: PC low byte or ALU-result low byte.
- [x] Timing-related RTL optimizations in the current GitHub CPU RTL: direct operand branch comparison and dedicated effective-address expression.
- [x] Write-back selection prioritizes JAL (PC+4), LW (memory result), then ALU result.
- [x] Bitstream generated and FPGA programmed; user reports board observation.

## Timing closure (final user-reported implementation)

The final Vivado Design Timing Summary screenshot supplied by the user reported:

| Metric | Value |
|---|---:|
| Setup WNS | +0.011 ns |
| Setup TNS | 0.000 ns |
| Setup failing endpoints | 0 |
| Setup endpoints | 3232 |
| Hold WHS | +0.027 ns |
| Hold THS | 0.000 ns |
| Hold failing endpoints | 0 |
| Timing constraints | Met |

The setup margin is only 11 ps, so this implementation passes the reported timing run but has very little margin. This is screenshot evidence, not an independent rerun in this environment.

## FPGA demo

- Press btnC to synchronously reset the CPU and restart PC at 0.
- SW0=0: LEDs show PC[7:0], allowing the program's address progression to be observed.
- SW0=1: LEDs show ALU result[7:0] for the current instruction.
- The test program is preloaded in instruction memory; the switches do not select instructions.
- After the test program, a JAL x0,0 instruction parks the PC at byte address 148 (0x94). PC mode therefore holds the low byte of 0x94 on the LEDs.
- ALU mode may show zero at the terminal self-loop because the parked JAL's ALU result can be zero; the LEDs are a live debug display, not a dedicated result register.

## Source synchronization

The repository has the CPU RTL, Basys-3 wrapper, testbench and supporting docs. The XDC was added under `constraints/basys3_top.xdc`. Before declaring all local source files synchronized, compare the laptop Vivado source files with GitHub: a previously supplied RTL bundle includes an older CPU version and should not replace the current optimization-bearing RTL.

## Remaining work

1. Compare the complete Vivado source set with GitHub and confirm the exact source snapshot used for the passing implementation.
2. Capture final board photos/video and waveform screenshot for project evidence.
3. If a persistent non-zero ALU LED demonstration is needed, use a dedicated test-program/display hold strategy (not an architectural change to the CPU).
4. Complete project review and prepare instruction-by-instruction viva explanation.
