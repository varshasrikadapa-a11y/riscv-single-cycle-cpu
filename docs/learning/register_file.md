# Register File — Learning

## 1. Purpose

The register file stores the processor's 32 general-purpose architectural registers, x0 through x31. Each register is 32 bits wide because this is an RV32 processor.

The register file provides operands to the datapath and receives results during write-back.

## 2. Organization

- Number of registers: 32
- Width of each register: 32 bits
- Total storage bits: 32 × 32 = 1024 bits
- Register names: x0–x31
- x0 is hard-wired to zero

The 5-bit register index is sufficient because 2^5 = 32.

## 3. Ports

Our architecture uses:

- Read address 1: `rs1[4:0]`
- Read address 2: `rs2[4:0]`
- Read data 1: 32 bits
- Read data 2: 32 bits
- Write address: `rd[4:0]`
- Write data: 32 bits
- `RegWrite`: write enable
- Clock: write timing
- Reset: documented initialization behavior

Two read ports are required because R-Type instructions can need two source operands simultaneously. For example, `ADD x5, x1, x2` needs both x1 and x2 during the same cycle.

## 4. Combinational Reads

Register reads are combinational. When `rs1` or `rs2` changes, the corresponding read data reflects the selected register without waiting for a clock edge.

Conceptually:

`ReadData1 = Reg[rs1]`

`ReadData2 = Reg[rs2]`

This is necessary for a single-cycle datapath because the register operands must be available to the ALU during the same instruction cycle.

## 5. Synchronous Write

Register writes occur on the active clock edge when `RegWrite = 1`:

`Reg[rd] <= WriteData`

The write port is therefore clocked, unlike the read ports.

For example, after `ADD x5, x1, x2`, the ALU result is presented as write data and x5 is updated at the active clock edge if `RegWrite` is asserted.

## 6. x0 Behavior

RISC-V defines x0 as a constant zero register:

`x0 = 0`

Reads of x0 must always return zero. Writes to x0 must have no architectural effect.

Therefore:

- `rs1 = 0` → ReadData1 = 0
- `rs2 = 0` → ReadData2 = 0
- `rd = 0` → write is ignored

The design must prevent x0 from becoming nonzero even if a write is attempted.

## 7. Examples

### R-Type

`ADD x5, x1, x2`

- rs1 = x1
- rs2 = x2
- ReadData1 = x1 value
- ReadData2 = x2 value
- ALU performs ADD
- rd = x5
- ALU result is written to x5 on the active clock edge

### I-Type

`ADDI x5, x1, 10`

- rs1 = x1
- ReadData1 = x1 value
- immediate provides the second ALU operand
- rs2 is not used by the instruction
- rd = x5
- ALU result is written to x5 on the active clock edge

### SW

`SW x5, 8(x1)`

- rs1 = x1 supplies the base address
- rs2 = x5 supplies store data
- no register write occurs
- `RegWrite = 0`

## 8. Reset Assumption

For the educational implementation, reset behavior must be explicitly defined before RTL. The architectural requirement is only that x0 always reads as zero and cannot be changed. Other register initialization should not be assumed unless the implementation specifically defines reset initialization.

## 9. Key Mental Model

The register file is not the ALU and does not perform arithmetic. It is the storage/operand-delivery block between instruction decode, execution, and write-back:

Instruction fields → register addresses → register reads → ALU/datapath → result → register write-back.

## Stop Condition

Before RTL, the learner must be able to explain why there are two read ports, why reads are combinational, why writes are clocked, why register indices are 5 bits, and how x0 is kept at zero.
