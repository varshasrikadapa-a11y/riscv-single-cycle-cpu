# 32-bit Single-Cycle RISC-V Processor

Educational implementation of a 32-bit single-cycle RISC-V processor using Verilog HDL, Xilinx Vivado/XSim, and FPGA-oriented verification.

## Project Goal

The goal is architectural mastery rather than feature completion. Every instruction, encoding field, control signal, datapath connection, memory interface, and RTL module is derived and understood before implementation.

## Architecture

- ISA philosophy: RV32I
- Supported subset: ADD, SUB, AND, OR, XOR, SLT, ADDI, ANDI, ORI, XORI, SLTI, LW, SW, BEQ, BNE, JAL
- Datapath: 32-bit single-cycle Harvard-style
- Instruction width: 32 bits
- Registers: 32 x 32-bit, x0 hard-wired to zero
- Separate instruction and data memory interfaces
- No pipeline, cache, forwarding, interrupts, CSR, privilege modes, or branch prediction

## Datapath

PC -> Instruction Memory -> Decode/Control + Register File + Immediate Generator -> ALU -> Data Memory / Branch Logic -> Write Back -> Register File

Normal execution uses PC_next = PC + 4. Taken branches use PC + branch immediate. JAL uses PC + jump immediate and writes PC + 4 to rd.

## Memory Timing Assumption

Initial strict single-cycle model:

- Instruction memory read: combinational
- Data memory read: combinational
- Data memory write: synchronous
- LW/SW use full-word transfers with dmem_byte_en = 4'b1111

Xilinx BRAM commonly uses synchronous reads, which conflicts with a strict single-cycle LW. Initial implementation therefore uses a memory model compatible with same-cycle reads. BRAM will be reconsidered separately if required.

## Development Workflow

1. Foundations and encoding/decoding
2. ALU
3. Register File
4. Immediate Generator
5. PC / Next-PC
6. Main Control
7. ALU Control
8. Instruction/Data Memory interfaces
9. Individual instruction datapaths
10. Complete datapath and CPU integration
11. Verification and cycle-by-cycle analysis
12. Vivado FPGA implementation
13. Timing/resource measurement and design review

## Repository Structure

```text
riscv-single-cycle-cpu/
├── docs/
│   ├── learning/
│   ├── design/
│   ├── analysis/
│   ├── verification/
│   └── design_review/
├── rtl/
├── tb/
├── constraints/
├── programs/
├── scripts/
└── sim/
```

RTL is intentionally not added until the corresponding architecture and derivation have been completed.
