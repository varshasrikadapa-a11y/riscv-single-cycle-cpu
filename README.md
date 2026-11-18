# 32-bit Single-Cycle RISC-V Processor

Educational implementation of a 32-bit single-cycle RISC-V processor using Verilog HDL, Xilinx Vivado/XSim, and FPGA-oriented verification.

## Project Goal
Architectural mastery: understand instruction encodings, control signals, datapath, memory interfaces, and RTL.

## Architecture
- ISA: RV32I educational subset
- Supported: ADD, SUB, AND, OR, XOR, SLT, ADDI, ANDI, ORI, XORI, SLTI, LW, SW, BEQ, BNE, JAL
- 32-bit single-cycle Harvard-style datapath
- 32 x 32-bit register file; x0 is fixed at zero
- Separate instruction and data memory interfaces
- No pipeline, cache, forwarding, interrupts, CSR, privilege modes, or branch prediction

## Datapath
PC -> Instruction Memory -> Decode/Control + Register File + Immediate Generator -> ALU -> Data Memory / Branch Logic -> Write Back -> Register File

Normal execution: PC+4. Taken branches: PC+branch immediate. JAL: PC+jump immediate and rd receives PC+4.

## Memory assumptions
- Instruction memory read: combinational
- Data memory read: combinational
- Data memory write: synchronous
- LW/SW are full-word transfers (`dmem_byte_en = 4'b1111`)

This behavioral memory model permits same-cycle LW in this educational single-cycle architecture. Typical FPGA BRAM synchronous-read behavior would require reconsidering the architecture.

## Basys-3 implementation
- Top module: `basys3_top`
- Target: Digilent Basys-3, Artix-7 `xc7a35tcpg236-1`
- Clock: 100 MHz (10 ns constraint)
- SW0=0: LEDs show PC[7:0]
- SW0=1: LEDs show live ALU result[7:0]
- btnC: synchronous CPU reset
- Instruction/data memories are initialized in RTL with a test program.
- Program tests arithmetic, logical, immediate, LW/SW, BEQ/BNE, JAL, SLT, and x0 behavior. It ends in a self-loop at byte address 148 (0x94).

See [FPGA demo guide](docs/FPGA_DEMO.md) for programming steps and expected LED behavior.

## Current status
- CPU RTL and Basys-3 wrapper are committed.
- Behavioral waveform captured.
- Bitstream generated and board programmed; user reports board observation.
- Final user-reported timing summary: setup WNS +0.011 ns, TNS 0, 0 failing setup endpoints; hold WHS +0.027 ns, 0 failing hold endpoints. Constraints reported met; margin is very tight.
- See [project progress](docs/PROJECT_PROGRESS.md) and [timing closure report](docs/analysis/timing_closure.md).

## Next phase
Synchronize every source file from the active Vivado project to GitHub, capture demonstration evidence, and complete the design review/viva preparation. Do not make timing-sensitive RTL or XDC changes without rerunning implementation timing.

## Structure
```
docs/       learning, design, analysis, verification, reviews, progress
rtl/        processor and board wrapper RTL
tb/         Verilog testbenches
constraints/ Basys-3 XDC
```
