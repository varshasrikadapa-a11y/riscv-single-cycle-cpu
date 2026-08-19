# Main Control Measured vs Predicted Analysis

## Result

Prediction and measured XSim behavior agree for all eight test cases.

| Case | Opcode | Expected class | Measured result |
|---|---|---|---|
| 1 | `33` | R-Type | PASS |
| 2 | `13` | I-Type arithmetic | PASS |
| 3 | `03` | LW | PASS |
| 4 | `23` | SW | PASS |
| 5 | `63` + funct3 `0` | BEQ | PASS |
| 6 | `63` + funct3 `1` | BNE | PASS |
| 7 | `6f` | JAL | PASS |
| 8 | `7f` | Unsupported | PASS |

The XSim waveform shows `errors=0`, so no expected-control comparison failed.

No timing/resource measurements were performed; this verification is functional simulation only.
