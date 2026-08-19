# Main Control Verification

## DUT

`rtl/control/main_control.v`

## Testbench

`tb/control/tb_main_control.v`

## Stimulus sequence

1. R-Type opcode `0110011`
2. I-Type arithmetic opcode `0010011`
3. LW opcode `0000011`
4. SW opcode `0100011`
5. BEQ opcode `1100011`, funct3 `000`
6. BNE opcode `1100011`, funct3 `001`
7. JAL opcode `1101111`
8. Unsupported opcode `1111111`

## Waveform result

Vivado XSim waveform supplied by the user shows `errors = 0x00000000`, indicating that every testbench expected-control comparison passed.

Observed behavior matches the derived table:

- R-Type (`33`): `RegWrite=1`, `ALUSrc=0`, `ALUOp=2`, memory/branch/jump inactive.
- I-Type (`13`): `RegWrite=1`, `ALUSrc=1`, `ALUOp=3`, memory/branch/jump inactive.
- LW (`03`): `RegWrite=1`, `MemRead=1`, `ALUSrc=1`, `ALUOp=0`, `MemToReg=1`.
- SW (`23`): `MemWrite=1`, `ALUSrc=1`, `ALUOp=0`, `RegWrite=0`.
- BEQ (`63`, funct3=`0`): `Branch=1`, `BranchType=0`, `ALUSrc=0`, `ALUOp=1`.
- BNE (`63`, funct3=`1`): `Branch=1`, `BranchType=1`, `ALUSrc=0`, `ALUOp=1`.
- JAL (`6f`): `RegWrite=1`, `Jump=1`; deterministic defaults leave memory/branch inactive.
- Unsupported (`7f`): safe defaults; no register or memory write.

## Conclusion

Main Control verification PASSED for all supplied test cases. The waveform agrees with the architectural derivation and RTL prediction.
