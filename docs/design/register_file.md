# Register File Design

## Purpose

Implement the architectural 32 × 32-bit RISC-V register file for the selected RV32I subset.

## Interface

Inputs:
- `clk`: active clock
- `reset`: reset control; synchronous reset will be used initially
- `rs1[4:0]`: first read register address
- `rs2[4:0]`: second read register address
- `rd[4:0]`: write register address
- `WriteData[31:0]`: data to write
- `RegWrite`: register write enable

Outputs:
- `ReadData1[31:0]`
- `ReadData2[31:0]`

## Storage

32 registers × 32 bits. Register addresses are 5 bits because 2^5 = 32.

## Read behavior

Reads are combinational:
`ReadData1 = (rs1 == 0) ? 32'b0 : registers[rs1]`
`ReadData2 = (rs2 == 0) ? 32'b0 : registers[rs2]`

## Write behavior

Writing occurs only on the active clock edge when `RegWrite = 1` and `rd != 0`.
Writes to x0 are ignored.

## x0 invariant

x0 must always read as zero and must never be modified by a write operation.

## Reset assumption

Initial educational implementation uses synchronous reset. On the active clock edge with reset asserted, all registers are initialized to zero. This gives deterministic simulation and a known starting architectural state.

## Timing

Read path is combinational. Write path is synchronous. There is no hidden pipeline or additional cycle in the register file.

## Datapath relationships

R-Type: ReadData1 and ReadData2 feed the two ALU inputs.
I-Type/LW: ReadData1 provides the base/source operand; the immediate provides the second ALU operand.
SW: ReadData1 provides the base address operand; ReadData2 provides the memory write data.

## Design constraint

The module exposes architectural register-file behavior only and does not depend on a particular FPGA memory primitive.
