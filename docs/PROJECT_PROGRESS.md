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
- [x] Timing optimizations in the committed CPU RTL: direct register-operand branch comparison and dedicated effective-address calculation for LW/SW.
- [x] Write-back selection: JAL selects PC+4, LW selects data-memory result, otherwise ALU result.
- [x] Bitstream generated and FPGA programmed; user reports observing the design on the Basys-3 board.

## Final timing closure — user-reported implementation

The final Vivado Design Timing Summary screenshot reported:

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

This meets the specified 10 ns setup constraint, but the positive setup margin is only 11 ps. Treat this as a narrowly passing implementation. These are screenshot-reported results, not an independent run performed here.

## FPGA demonstration

- btnC: synchronous active-high reset; press to restart the PC at 0.
- SW0=0: LEDs LD7–LD0 display `debug_pc[7:0]`, so the program address progression is visible.
- SW0=1: LEDs display `debug_alu_result[7:0]`, the current instruction's ALU result—not a saved final result.
- Instructions are preloaded into instruction memory in RTL; switches do not enter instruction data.
- Program exercises arithmetic/logical/immediate operations, SW/LW, BEQ/BNE, JAL, SLT, and x0 protection.
- At the end, `JAL x0,0` parks the PC at byte address 148 (0x94). In PC display mode, the low byte therefore remains 0x94 (LD7–LD0 = 10010100) after the program reaches the loop.
- In ALU display mode, the terminal self-loop may show zero because the live ALU result of the parking instruction can be zero. This is not a stored-result display.

See [Basys-3 demonstration guide](FPGA_DEMO.md) for the test sequence and LED interpretation.

## Git synchronization note

The GitHub `main` branch contains the timing-optimized CPU RTL, Basys-3 wrapper, XDC, testbench, and this documentation. Because the Vivado project is local, the final source synchronization still needs a file-by-file comparison against the laptop's active Vivado sources. Do not overwrite the current optimized CPU RTL with an older bundle.

## Remaining work

1. Compare the complete Vivado source set against the GitHub `main` snapshot.
2. Save final FPGA photos/video and the timing summary as project evidence.
3. If a persistent non-zero ALU result is desired for the demo, make a separate display/test-program enhancement without changing CPU architecture, then re-verify timing.
4. Complete design review and prepare instruction-by-instruction viva explanation.
