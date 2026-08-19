# ALU Control Measured vs Predicted

## Predicted

The analysis predicted the exact mapping ADD=000, SUB=001, AND=010, OR=011, XOR=100, SLT=101, with ALUOp selecting address/compare/R-Type/I-Type classes.

## Measured

The provided Vivado XSim waveform shows:

- `ALUOp=00` → `ALUControl=0`
- `ALUOp=01` → `ALUControl=1`
- R-Type sequence → `0,1,2,3,4,5`
- I-Type sequence → `0,2,3,4,5`
- Invalid R-Type/I-Type cases → deterministic `0`
- `errors=00000000`

## Conclusion

Measured behavior matches the predicted ALU Control mapping for all displayed test cases. No mismatch is visible in the supplied simulation.

## Next measurement

The next ALU verification must test the actual 32-bit arithmetic/logic result and Zero output, including signed SLT behavior and equality/inequality cases.
