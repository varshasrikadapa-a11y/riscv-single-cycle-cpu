# Phase 1 — Foundation Design Record

## Architectural Scope

The processor is a 32-bit single-cycle Harvard-style RISC-V implementation with separate instruction and data memory interfaces.

## Current Blocks

- Program Counter
- Instruction memory interface
- Instruction decode
- Register file
- Immediate generator
- 32-bit ALU
- Data memory interface
- Branch/jump next-PC logic
- Write-back selection
- Main control and ALU control

## Key Interfaces

Instruction interface: `imem_addr[31:0]`, `imem_rdata[31:0]`.

Data interface: `dmem_addr[31:0]`, `dmem_wdata[31:0]`, `dmem_rdata[31:0]`, `dmem_read`, `dmem_write`, `dmem_byte_en[3:0]`.

For full-word LW/SW, `dmem_byte_en = 4'b1111`.

## Architectural Timing Assumption

Instruction-memory read and data-memory read are combinational for the initial strict single-cycle model. Data-memory writes are synchronous. This assumption is necessary to make same-cycle LW behavior explicit.

## Control Signals

Main control signals are:

- `RegWrite`
- `MemRead`
- `MemWrite`
- `ALUSrc`
- `ALUOp`
- `Branch`
- `BranchType`
- `Jump`
- `MemToReg`

Each signal must be derived from the required datapath behavior rather than copied from an unrelated implementation.

## Next Design Step

Derive the Immediate Generator for I-, S-, B-, and J-Type instructions, including signed 32-bit extension and branch/jump target construction.