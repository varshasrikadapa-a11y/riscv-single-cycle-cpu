# Phase 1 — Verification Plan

## Scope

Conceptual verification only. RTL and simulation are intentionally deferred until the architectural derivation is complete.

## Required Checks

- Confirm RV32I terminology and selected ISA subset.
- Confirm 32-bit register width and 32-bit instruction width.
- Confirm x0 always reads as zero and ignores writes.
- Confirm normal PC_next = PC + 4 bytes.
- Confirm taken BEQ/BNE targets use PC plus the reconstructed branch immediate.
- Confirm JAL writes PC + 4 to rd and selects PC plus the jump immediate as PC_next.
- Confirm R-Type field order: funct7 | rs2 | rs1 | funct3 | rd | opcode.
- Confirm I-, S-, B-, and J-Type immediate reconstruction will produce signed 32-bit values.
- Confirm ADD/SUB/AND/OR/XOR/SLT ALU operation mapping.
- Confirm ALUSrc selects register ReadData2 versus Immediate for ALU input B.
- Confirm LW uses ALU address generation and writes memory data to rd.
- Confirm SW uses ALU address generation, writes rs2 data to memory, and does not write a register.

## Evidence Standard

Simulation passing alone will not be treated as proof. Later verification documents must explain expected behavior signal-by-signal and cycle-by-cycle and include actual simulator evidence.