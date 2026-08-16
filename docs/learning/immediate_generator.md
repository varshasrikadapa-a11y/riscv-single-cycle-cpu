# Immediate Generator — Learning

## Role
Teaching Assistant artifact.

## Phase
Phase 1 — RISC-V Foundations and Single-Cycle Architecture.

## Purpose
The Immediate Generator (ImmGen) extracts the immediate encoded inside a 32-bit RISC-V instruction, reconstructs split immediate fields where required, and produces a 32-bit signed immediate for the datapath.

## Supported Formats
- I-Type: `ADDI`, `ANDI`, `ORI`, `XORI`, `SLTI`, `LW`
- S-Type: `SW`
- B-Type: `BEQ`, `BNE`
- J-Type: `JAL`

R-Type instructions do not require an immediate.

## Sign Extension
Smaller signed immediates must become 32-bit values without changing their numerical meaning. If the immediate sign bit is 0, upper bits are filled with 0. If it is 1, upper bits are filled with 1.

Example:

`111111111100` (-4 in 12-bit two's complement) becomes `11111111111111111111111111111100`.

## Immediate Construction

### I-Type
`instruction[31:20]` is the 12-bit immediate.

`I_imm = sign_extend(instruction[31:20])`

### S-Type
The immediate is split to preserve fixed positions for register and opcode fields.

`imm[11:5] = instruction[31:25]`

`imm[4:0] = instruction[11:7]`

`S_imm = sign_extend({instruction[31:25], instruction[11:7]})`

### B-Type
The branch immediate is reconstructed as:

`imm[12] = instruction[31]`

`imm[11] = instruction[7]`

`imm[10:5] = instruction[30:25]`

`imm[4:1] = instruction[11:8]`

`imm[0] = 0`

Therefore:

`B_imm = sign_extend({instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0})`

The low bit is implicit because the encoded branch offset is in 2-byte units. It is not correct to describe this as memory being aligned to '2 bits'; it is a byte-address alignment/offset property.

### J-Type
The jump immediate is reconstructed as:

`imm[20] = instruction[31]`

`imm[19:12] = instruction[19:12]`

`imm[11] = instruction[20]`

`imm[10:1] = instruction[30:21]`

`imm[0] = 0`

Therefore:

`J_imm = sign_extend({instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0})`

## Architectural Interface

Input:
- `instruction[31:0]`

Output:
- `immediate[31:0]`

ImmGen is combinational and does not require a clock. The opcode identifies the instruction family/format used to select the appropriate reconstruction rule.

## Datapath Uses
- I-Type arithmetic: immediate becomes ALU input B.
- LW/SW: immediate becomes the address offset used by the ALU.
- BEQ/BNE: immediate contributes to the branch target `PC + branch_immediate`.
- JAL: immediate contributes to the jump target `PC + jump_immediate`.

## Understanding Status
The format-specific immediate reconstruction has been derived conceptually. RTL is still blocked until the design interface and exact control/format selection are finalized.
