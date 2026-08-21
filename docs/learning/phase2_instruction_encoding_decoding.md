# Phase 2 — Instruction Encoding & Decoding

## Goal
Move from understanding the single-cycle datapath to understanding exactly how each supported instruction is represented by 32 bits and how hardware extracts those fields.

## Supported subset
R-Type: ADD, SUB, AND, OR, XOR, SLT
I-Type arithmetic: ADDI, ANDI, ORI, XORI, SLTI
Memory: LW, SW
Branch: BEQ, BNE
Jump: JAL

## Core instruction fields
For a 32-bit instruction, identify as applicable:
- opcode[6:0]
- rd[4:0]
- funct3[2:0]
- rs1[4:0]
- rs2[4:0]
- funct7[6:0]
- immediate fields

The opcode identifies the broad instruction class. funct3 and, where applicable, funct7 distinguish the exact operation.

## Formats
R-Type: funct7 | rs2 | rs1 | funct3 | rd | opcode
I-Type: imm[11:0] | rs1 | funct3 | rd | opcode
S-Type: imm[11:5] | rs2 | rs1 | funct3 | imm[4:0] | opcode
B-Type: imm[12] | imm[10:5] | rs2 | rs1 | funct3 | imm[4:1] | imm[11] | opcode
J-Type: imm[20] | imm[10:1] | imm[11] | imm[19:12] | rd | opcode

All selected instructions use 32-bit instruction words.

## Immediate reconstruction
I: sign_extend(instruction[31:20])
S: sign_extend({instruction[31:25], instruction[11:7]})
B: sign_extend({instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0})
J: sign_extend({instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0})

The low bit of B- and J-type PC-relative offsets is encoded as zero because supported instruction targets are at least 2-byte aligned. For the current 32-bit instruction subset, normal sequential PC increments by 4.

## Learning method
For every instruction, derive in order:
1. Assembly instruction
2. Instruction type
3. Opcode
4. Register fields
5. funct3/funct7 if applicable
6. Immediate encoding/reconstruction
7. Complete 32-bit binary word
8. Decode the same word back into fields
9. Connect decoded fields to control signals and datapath

## First worked example target
ADD x5, x1, x2 is R-Type:
funct7=0000000, rs2=00010, rs1=00001, funct3=000, rd=00101, opcode=0110011.
The resulting 32-bit word must be derived by concatenating those fields, then decoded back to the same fields.

## Assumptions
- Fixed 32-bit instruction width.
- 32-bit PC and memory-address interfaces in this project.
- Byte-addressed PC; normal instruction sequencing is PC+4.
- No compressed (C) extension.
- No U-Type instruction is included in the selected implementation subset.
- Encoding/decoding is studied before new RTL is written.
