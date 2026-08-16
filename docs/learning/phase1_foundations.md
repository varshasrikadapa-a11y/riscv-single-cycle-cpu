# Phase 1 — RISC-V Foundations

## Role
Teaching Assistant artifact.

## Objective
Establish the architectural concepts required before RTL implementation.

## ISA and RV32I

RISC-V is an Instruction Set Architecture (ISA): a software-visible contract describing instructions, registers, and architectural behavior. The implementation is separate from the ISA.

RV32I means the RISC-V 32-bit integer base ISA. In this project, a deliberately selected educational subset is implemented rather than the complete base ISA.

## Single-Cycle Architecture

One instruction completes all required operations within one clock cycle. The cycle must be long enough for the longest instruction path. No pipeline, cache, forwarding, interrupts, CSR, privilege modes, or branch prediction are included.

## Datapath

PC -> Instruction Memory -> Decode / Control + Register File + Immediate Generator -> ALU -> Data Memory / Branch Logic -> Write Back -> Register File.

The datapath moves data. Control logic selects the required paths and operations.

## Register File

32 registers x0-x31, each 32 bits wide. Two combinational read ports and one synchronous write port are used. x0 always reads as zero and writes to x0 are ignored.

## Program Counter

The PC is a 32-bit state register holding the current instruction address. Normally PC_next = PC + 4 bytes. Taken branches use PC + branch immediate. JAL uses PC + jump immediate and writes PC + 4 to rd.

## ALU

The 32-bit ALU supports ADD, SUB, AND, OR, XOR, and signed SLT, plus comparison information required by BEQ/BNE. ALU input B is selected by ALUSrc between register ReadData2 and the generated immediate.

## Instruction Formats

The supported instruction layouts are R-Type, I-Type, S-Type, B-Type, and J-Type. Format describes bit layout; it does not by itself describe instruction function. LW is I-Type despite being a memory instruction.

Important R-Type field order:

funct7 | rs2 | rs1 | funct3 | rd | opcode

Important examples derived during learning:

ADD x5, x1, x2 = 00000000001000001000001010110011 = 0x002082B3

SUB x7, x3, x4 = 01000000010000011000001110110011 = 0x404183B3

XOR x12, x4, x10 = 00000000101000100100011000110011

## Memory Instruction Intuition

LW x5, 8(x1): ALU calculates x1 + 8 as the address, memory data is written to x5.

SW x5, 8(x1): ALU calculates x1 + 8 as the address, x5 is the data written to memory, and there is no register write-back.

## Current Boundary

The next teaching topic is Immediate Generation. No RTL is produced until the relevant concept and derivation are understood and documented.