# ALU Design

## Role
The 32-bit ALU is a purely combinational execution unit. It receives two 32-bit operands and a 3-bit internal ALU control code, and produces a 32-bit result plus a Zero flag used by branch logic.

## Assumptions
- Width: 32 bits
- Combinational; no clock or reset
- Signed two's-complement interpretation for SLT
- Supported operations only: ADD, SUB, AND, OR, XOR, SLT
- Zero = 1 when Result == 0
- Unused ALU control codes are deterministic: Result = 0, Zero = 1

## Interface
- A[31:0]
- B[31:0]
- ALU_Control[2:0]
- Result[31:0]
- Zero

## Internal ALU Control Encoding
| ALU_Control | Operation |
|---|---|
| 000 | ADD |
| 001 | SUB |
| 010 | AND |
| 011 | OR |
| 100 | XOR |
| 101 | SLT |
| 110 | unused |
| 111 | unused |

## Operation Definitions
- ADD: Result = A + B
- SUB: Result = A - B
- AND: Result = A & B
- OR: Result = A | B
- XOR: Result = A ^ B
- SLT: Result = 32'd1 when signed(A) < signed(B), otherwise 32'd0
- Zero: Result == 0

## Datapath Connections
R-Type uses ReadData1 and ReadData2 as A and B. I-Type and memory instructions use ReadData1 as A and the immediate as B through the ALUSrc multiplexer. LW/SW use ADD to calculate the effective address. SW separately sends ReadData2 to dmem_wdata.

## Branch Use
For BEQ/BNE, the ALU can subtract A-B. Zero=1 indicates equality; Zero=0 indicates inequality. Branch control, not the ALU itself, determines whether the result selects the branch target or PC+4.

## Timing
The ALU contributes combinational delay to the single-cycle critical path. LW is expected to include ALU delay between register read and data-memory access.

## Status
Design derivation complete. RTL is intentionally deferred until the analysis/prediction stage is completed.
