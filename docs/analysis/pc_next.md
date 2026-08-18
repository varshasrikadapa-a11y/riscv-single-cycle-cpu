# PC / Next-PC Analysis

## Predicted behavior

The PC is a 32-bit state register. It stores the byte address of the current 32-bit instruction. Normal sequential execution advances by 4 bytes.

## Candidate next addresses

- Sequential: `PC + 32'd4`
- Branch target: `PC + B_imm`
- JAL target: `PC + J_imm`

## Selection prediction

For the supported ISA, decoded JAL and branch controls are mutually exclusive. The defined defensive priority is:

1. `Jump` → JAL target
2. `Branch && BranchTaken` → branch target
3. Otherwise → sequential `PC + 4`

`BranchTaken` is derived from ALU `Zero`:
- BEQ: `Zero == 1`
- BNE: `Zero == 0`

## Timing prediction

PC is clocked state. Candidate addresses and the MUX are combinational; the selected `PC_next` is captured at the active clock edge. The PC path therefore contributes an adder and next-PC selection logic to the single-cycle timing path.

## Reset assumption

Initial implementation uses synchronous reset and initializes PC to `0x00000000`.

## Resource prediction

Expected logic consists primarily of 32-bit adders and a next-PC multiplexer. Actual LUT, FF, and timing results are FPGA/tool dependent and must be measured in Vivado.

## Verification priorities

1. Reset establishes PC=0.
2. Normal instruction gives PC+4.
3. Taken BEQ selects PC+B_imm.
4. Not-taken BEQ selects PC+4.
5. Taken BNE selects PC+B_imm.
6. Not-taken BNE selects PC+4.
7. JAL selects PC+J_imm.
8. JAL return address is PC+4 in the separate write-back path.
9. Defensive priority is deterministic if controls are accidentally asserted together.
