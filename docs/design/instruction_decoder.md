# Instruction Decoder Design — Phase 2

## Purpose

Extract the architecturally defined fields from the 32-bit instruction and provide them to the control, register-file, and immediate-generation logic. Instruction format is identified primarily from the opcode.

## Inputs

`instruction[31:0]`

## Common fields

- `opcode = instruction[6:0]`
- `rd = instruction[11:7]`
- `funct3 = instruction[14:12]`
- `rs1 = instruction[19:15]`
- `rs2 = instruction[24:20]`
- `funct7 = instruction[31:25]`

These fields are exposed combinationally; unused fields for a particular instruction are ignored by the downstream logic.

## Opcode-to-format classification for the selected subset

| Opcode | Format/class | Instructions |
|---|---|---|
| `0110011` | R-Type | ADD, SUB, AND, OR, XOR, SLT |
| `0010011` | I-Type arithmetic | ADDI, ANDI, ORI, XORI, SLTI |
| `0000011` | I-Type load | LW |
| `0100011` | S-Type | SW |
| `1100011` | B-Type | BEQ, BNE |
| `1101111` | J-Type | JAL |

## Immediate field mapping

- I-Type: `instruction[31:20]`
- S-Type: `{instruction[31:25], instruction[11:7]}`
- B-Type: `{instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}`
- J-Type: `{instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0}`

The Immediate Generator sign-extends these reconstructed values to 32 bits.

## Datapath interface

```text
instruction[31:0]
       |
       v
Instruction Decoder
 | opcode, rd, rs1, rs2, funct3, funct7
 | immediate field information
 +----> Main Control
 +----> Register File
 +----> ALU Control
 +----> Immediate Generator
```

## Design assumptions

- Combinational decode; no clock or internal state.
- Exactly the selected 16-instruction subset is architecturally supported.
- Unsupported opcodes are handled by downstream control as unsupported/safe instructions.
- The decoder extracts fields; it does not independently perform register writes, memory operations, ALU operations, or PC updates.
