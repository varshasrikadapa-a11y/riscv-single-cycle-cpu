# Instruction Decoder Analysis — Phase 2

## Scope

Prediction only; no RTL or measured results yet.

## Predicted behavior

The decoder is purely combinational. For every input `instruction[31:0]`, field extraction is stable without a clock.

| Instruction class | opcode | Expected fields used |
|---|---|---|
| R-Type | `0110011` | rd, rs1, rs2, funct3, funct7 |
| I-Type arithmetic | `0010011` | rd, rs1, funct3, imm[11:0] |
| LW | `0000011` | rd, rs1, funct3, imm[11:0] |
| SW | `0100011` | rs1, rs2, funct3, split S immediate |
| BEQ/BNE | `1100011` | rs1, rs2, funct3, split B immediate |
| JAL | `1101111` | rd, split J immediate |

## Representative predictions

### ADD x5,x1,x2
- opcode `0110011`
- rd `00101` (x5)
- rs1 `00001` (x1)
- rs2 `00010` (x2)
- funct3 `000`
- funct7 `0000000`

### ADDI x5,x1,10
- opcode `0010011`
- rd `00101`
- rs1 `00001`
- funct3 `000`
- immediate field `000000001010`

### SW x5,8(x1)
- opcode `0100011`
- rs2 `00101`
- rs1 `00001`
- funct3 `010`
- S immediate reconstructs to `8`

### BEQ x1,x2,20
- opcode `1100011`
- rs2 `00010`
- rs1 `00001`
- funct3 `000`
- reconstructed B immediate `20`

### JAL x5,20
- opcode `1101111`
- rd `00101`
- reconstructed J immediate `20`

## Invalid opcode prediction

Unsupported opcodes are still field-extractable because the bit slices physically exist, but downstream control must not interpret them as supported instructions. No memory write or register write should be enabled for an unsupported instruction by default.

## Resource/timing prediction

The decoder consists only of wires/slices and, if format classification is implemented explicitly, small combinational decode logic. No registers or memory are required. Expected latency/resource usage is therefore very small relative to instruction/data memory and the ALU datapath.

## Verification plan later

Verify representative encodings for all five formats, positive and negative immediates, and at least one unsupported opcode. Compare each output field against the manually derived bit positions.
