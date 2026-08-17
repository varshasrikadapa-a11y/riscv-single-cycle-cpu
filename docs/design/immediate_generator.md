# Immediate Generator — Design Specification

## 1. Purpose

The Immediate Generator (ImmGen) converts the immediate encoded inside a 32-bit instruction into one 32-bit signed value for use by the ALU or PC/branch target logic.

It is a combinational architectural block. It has no clock, reset, or internal state.

## 2. Interface

### Input
- `instruction[31:0]` — current 32-bit instruction.

### Output
- `immediate[31:0]` — reconstructed and sign-extended immediate.

## 3. Format Selection

The opcode identifies the immediate format for the supported subset:

| Opcode | Format | Instructions |
|---|---|---|
| `0010011` | I-Type | ADDI, ANDI, ORI, XORI, SLTI |
| `0000011` | I-Type | LW |
| `0100011` | S-Type | SW |
| `1100011` | B-Type | BEQ, BNE |
| `1101111` | J-Type | JAL |

R-Type instructions do not require an immediate from ImmGen.

## 4. Immediate Reconstruction

### I-Type

The 12-bit immediate occupies instruction bits `[31:20]`.

`I_imm = sign_extend(instruction[31:20])`

The 12-bit value is sign-extended to 32 bits using bit `[31]` of the instruction as the sign bit.

### S-Type

The 12-bit immediate is split to preserve fixed register/opcode field positions:

- `imm[11:5] = instruction[31:25]`
- `imm[4:0] = instruction[11:7]`

`S_imm = sign_extend({instruction[31:25], instruction[11:7]})`

### B-Type

The branch offset is reconstructed as:

- `imm[12] = instruction[31]`
- `imm[11] = instruction[7]`
- `imm[10:5] = instruction[30:25]`
- `imm[4:1] = instruction[11:8]`
- `imm[0] = 0`

`B_imm = sign_extend({instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0})`

The least significant offset bit is implicit zero because B-Type offsets are encoded in 2-byte units.

### J-Type

The jump offset is reconstructed as:

- `imm[20] = instruction[31]`
- `imm[19:12] = instruction[19:12]`
- `imm[11] = instruction[20]`
- `imm[10:1] = instruction[30:21]`
- `imm[0] = 0`

`J_imm = sign_extend({instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0})`

## 5. Sign Extension

All supported immediates become 32-bit signed values.

- Positive immediate: upper bits are filled with `0`.
- Negative immediate: upper bits are filled with `1`.

This preserves the two's-complement numerical value when the smaller encoded immediate is used by the 32-bit ALU or PC calculation.

## 6. Datapath Consumers

ImmGen output is not itself an instruction operation. It supplies a 32-bit value to the appropriate consumer:

- I-Type arithmetic → ALU input B when `ALUSrc=1`
- LW/SW → ALU input B for effective-address calculation
- BEQ/BNE → branch-target adder/PC selection logic
- JAL → jump-target calculation

The Immediate Generator does not decide whether a branch is taken, perform ALU operations, access memory, or update the PC.

## 7. Timing and Implementation Assumptions

- Combinational logic only.
- No clock.
- No reset.
- Output responds to changes in the instruction/opcode.
- Format selection is based primarily on opcode.
- The CPU treats the generated value as a 32-bit signed immediate/offset.

## 8. Invalid/Unsupported Opcode Behavior

The educational CPU supports only the defined subset. For an opcode that does not select I/S/B/J immediate generation, the RTL must define a deterministic output. The implementation should use `32'b0` for unsupported formats rather than allowing an inferred latch or undefined value.

## 9. Design Constraints

This block must not silently add U-Type, shift-immediate, CSR, or other instructions outside the project subset.

## 10. Verification Requirements

Before RTL is considered verified, test at minimum:

- positive I-Type immediate
- negative I-Type immediate
- positive and negative S-Type immediate
- B-Type immediate reconstruction and implicit bit 0
- negative B-Type sign extension
- J-Type immediate reconstruction and implicit bit 0
- negative J-Type sign extension
- supported opcode selection
- unsupported opcode deterministic output

## 11. Architectural Summary

`instruction[31:0] -> opcode/format selection -> immediate reconstruction -> sign extension -> immediate[31:0]`.

The block is purely combinational and is independent of the internal implementation of instruction or data memory.
