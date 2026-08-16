# Phase 1 — Foundations Design Review

## Role
Design Reviewer artifact.

## Review Scope
Review the documented architectural foundations before RTL implementation.

## Findings

### ISA Scope — APPROVED
The selected instruction subset is explicit and intentionally limited to R-Type arithmetic, I-Type arithmetic, LW/SW, BEQ/BNE, and JAL.

### Datapath — APPROVED
The documented datapath separates fetch, decode/register read, immediate generation, execute, memory access, write-back, and next-PC selection conceptually while preserving the single-cycle completion model.

### Register File — APPROVED
The 32 x 32 register file has two combinational read ports and one clocked write port. x0 behavior is explicitly specified.

### PC — APPROVED
Normal, branch, and JAL PC_next behaviors are defined. The distinction between current PC state and PC_next is established.

### ALU — APPROVED
The ALU operation set is sufficient for the selected instruction subset. ALUSrc is correctly defined as the selector for ALU input B source.

### Encoding / Decoding — APPROVED FOR CONTINUATION
R-Type encoding and decoding have been manually derived and checked, including ADD, SUB, and XOR examples. Immediate-format derivation remains open.

### Memory Timing — OPEN / HIGH-RISK ASSUMPTION
Same-cycle instruction and data-memory reads are required for the strict single-cycle model. FPGA BRAM synchronous read behavior must not be conflated with this assumption.

## Decision

**APPROVED TO CONTINUE LEARNING — NOT APPROVED FOR RTL YET.**

The Immediate Generator, Main Control, ALU Control, and complete datapath derivations must be completed and understood before implementation begins.