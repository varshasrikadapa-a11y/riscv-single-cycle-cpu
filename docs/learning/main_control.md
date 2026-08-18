# Main Control Unit — Learning

## Purpose

The Main Control Unit translates the decoded instruction's opcode (and, where needed, instruction type information) into high-level datapath control signals. It does not perform the ALU operation itself. It tells the datapath what kind of path the instruction needs.

## Why control logic exists

The same hardware is reused by many instructions. For example, the ALU performs ADD for R-type ADD, ADDI, LW address calculation, SW address calculation, and branch target/address-related work. The control unit selects the required datapath configuration so that the same hardware can serve different instructions.

## Main control signals

- `RegWrite`: permits register-file write-back.
- `MemRead`: requests a data-memory read.
- `MemWrite`: requests a data-memory write.
- `ALUSrc`: selects ALU input B: register data when 0, immediate when 1.
- `ALUOp`: high-level category passed to ALU Control; separates instruction class from exact ALU operation.
- `Branch`: identifies conditional branch behavior.
- `BranchType`: distinguishes BEQ from BNE.
- `Jump`: identifies JAL.
- `MemToReg`: selects write-back data: ALU result when 0, memory data when 1.

## Datapath intuition

R-type `ADD`: read two registers → ALU → register write-back. Therefore `RegWrite=1`, `ALUSrc=0`, `MemRead=0`, `MemWrite=0`, `Branch=0`, `Jump=0`, `MemToReg=0`.

I-type arithmetic `ADDI`: read rs1 and immediate → ALU → register write-back. Therefore `RegWrite=1`, `ALUSrc=1`, `MemToReg=0`.

LW: read rs1 and immediate → ALU effective address → data-memory read → register write-back. Therefore `RegWrite=1`, `MemRead=1`, `ALUSrc=1`, `MemToReg=1`.

SW: read rs1 and rs2 → ALU computes address from rs1 + immediate; rs2 goes to memory write data. Therefore `MemWrite=1`, `ALUSrc=1`, `RegWrite=0`.

BEQ/BNE: read two registers → ALU subtracts to produce Zero → branch decision → PC selection. Therefore `Branch=1`, `RegWrite=0`, `MemRead=0`, `MemWrite=0`, `ALUSrc=0`. `BranchType` distinguishes equality from inequality.

JAL: calculate jump target using the J immediate and write `PC+4` to rd. Therefore `Jump=1`, `RegWrite=1`; it does not access data memory.

## Why ALUOp exists

The Main Control should not need to encode every exact ALU operation directly. It identifies a high-level instruction class, and ALU Control combines that category with `funct3/funct7` when needed to select ADD, SUB, AND, OR, XOR, or SLT. This keeps the control hierarchy understandable.

## Critical principle

Every control signal must have a datapath reason. We should be able to ask: "What hardware connection changes if this signal changes?" If no architectural datapath behavior justifies a signal value, the control table is not yet derived.
