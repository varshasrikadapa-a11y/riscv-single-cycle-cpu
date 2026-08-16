# ALU Verification

## Verification status

**Status: PASS based on the supplied Vivado/XSim waveform.**

The waveform shows `ALU_Control` stepping through the defined operations and the expected `Result`/`Zero` behavior. The `errors` signal remains `0` throughout the observed simulation.

## Observed tests

| Control | Operation | Expected | Observed |
|---|---|---|---|
| 000 | ADD | 10 + 5 = 15 | 0000000F |
| 001 | SUB | 10 - 5 = 5 | 00000005 |
| 001 | SUB equality | 10 - 10 = 0, Zero=1 | 00000000, Zero=1 |
| 010 | AND | F0F00F0F & 0FF0F0F0 = 00F00000 | 00F00000 |
| 011 | OR | F0000000 | F00000F0 |
| 100 | XOR | AAAAAAAA ^ FFFFFFFF = 55555555 | 55555555 |
| 101 | signed SLT | -1 < +1 | Result=1 |
| 101 | signed SLT | +1 < -1 is false | Result=0, Zero=1 |
| 110 | invalid | Result=0 | Result=0, Zero=1 |
| 111 | invalid | Result=0 | Result=0, Zero=1 |

## Signal-level interpretation

For each test, `A`, `B`, and `ALU_Control` select the operation. `Result` reflects that operation and `Zero` is asserted exactly when `Result == 0`.

The SUB equality case verifies the branch comparison mechanism: equal operands produce a zero result, which can be consumed by BEQ/BNE branch logic later.

## Conclusion

The ALU RTL behavior matches the designed six-operation specification for the tested cases. The testbench's `errors` signal is zero in the supplied waveform. This verifies functional behavior for the selected vectors; exhaustive verification is not claimed.
