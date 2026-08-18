# PC / Next-PC Design

## Purpose

Define the 32-bit program counter and next-PC selection logic for the educational single-cycle RV32I subset.

## PC Register

The PC is a 32-bit state register holding the byte address of the current instruction.

At the active clock edge:
`PC <= PC_next`

Initial reset assumption: synchronous reset sets `PC = 32'b0`.

## Candidate Next Addresses

Sequential:
`PC_plus_4 = PC + 32'd4`

Branch target:
`branch_target = PC + branch_immediate`

JAL target:
`jump_target = PC + jump_immediate`

## PC Selection

Normal instructions:
`PC_next = PC_plus_4`

Taken BEQ/BNE:
`PC_next = branch_target`

JAL:
`PC_next = jump_target`

A taken JAL has priority over branch selection. In the selected ISA, JAL and Branch controls are decoded from mutually exclusive instruction opcodes, so simultaneous valid assertion should not occur. The RTL should nevertheless define deterministic priority: `Jump` first, then `BranchTaken`, then sequential.

## Branch Condition

The ALU performs subtraction for BEQ/BNE. `Zero=1` means `rs1 == rs2`.

`BEQ_taken = Branch && (BranchType == BEQ) && Zero`
`BNE_taken = Branch && (BranchType == BNE) && !Zero`
`BranchTaken = BEQ_taken || BNE_taken`

## JAL Write-Back Relationship

JAL also writes the return address `PC + 4` to `rd`. This is a datapath/write-back function separate from the PC target selection.

## Timing Assumptions

The PC is edge-triggered. All candidate next addresses and control decisions are combinational during the cycle. The resulting `PC_next` is captured at the active edge. No pipeline stage is introduced.

## Width and Addressing

PC and all candidate addresses are 32 bits. Instructions are 32 bits (4 bytes), so sequential execution advances by 4 byte addresses.
