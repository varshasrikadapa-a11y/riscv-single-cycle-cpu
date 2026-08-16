# RISC-V Single-Cycle CPU Project Plan

## Goal

Build a 32-bit single-cycle RISC-V processor on a Xilinx FPGA using Verilog HDL and Vivado/XSim, with architectural mastery as the primary objective.

## ISA Subset

R-Type: ADD, SUB, AND, OR, XOR, SLT
I-Type arithmetic: ADDI, ANDI, ORI, XORI, SLTI
Memory: LW, SW
Branches: BEQ, BNE
Jump: JAL

## Architecture

PC -> Instruction Memory -> Decode / Control + Register File + Immediate Generator -> ALU -> Data Memory / Branch Logic -> Write Back -> Register File

## Mandatory Learning and Implementation Flow

1. Foundations and encoding/decoding
2. ALU
3. Register File
4. Immediate Generator
5. PC / Next-PC
6. Main Control
7. ALU Control
8. Instruction Memory
9. Data Memory / Bus
10. Individual instruction datapaths
11. Complete datapath
12. CPU integration
13. Verification
14. Vivado FPGA implementation
15. Timing/resources
16. Design review
17. Knowledge test

## Artifact Flow Per Module

Teach -> design -> analysis prediction -> user understanding confirmation -> RTL -> verification -> testbench -> simulation/measurement -> analysis update -> design review -> knowledge test.

## Repository Rule

Every completed milestone must be committed to GitHub automatically. Each module milestone should use the appropriate learning, design, analysis, verification, and design-review documents, plus RTL and testbench artifacts when implementation has reached that stage.

## Design Discipline

- No RTL before concept, architecture, and derivation.
- Every instruction must have an exact datapath and control-signal explanation.
- Verification must explain behavior signal-by-signal and cycle-by-cycle; passing alone is insufficient.
- State assumptions explicitly.
- Do not silently add ISA features or advanced microarchitectural features.
- Resource, timing, and power claims must be measured or explicitly labeled as predictions.

## Reference Pattern

This project adopts the useful artifact organization and milestone-review discipline observed in the supplied low-power NPU reference repository, but all architecture, content, RTL, and verification are specific to this RISC-V project.
