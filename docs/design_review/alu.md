# ALU Design Review

## Review status

**PASS — functional simulation evidence provided.**

## Reviewed architecture

- 32-bit combinational ALU
- Inputs: A[31:0], B[31:0], ALU_Control[2:0]
- Outputs: Result[31:0], Zero
- Operations: ADD, SUB, AND, OR, XOR, signed SLT
- Invalid controls 110 and 111 produce Result=0
- Zero is derived from Result==0

## Verification evidence

The supplied Vivado/XSim waveform exercises all eight 3-bit control codes. The observed result values match the expected test vectors, including equality detection through SUB, signed SLT, and invalid controls. The testbench `errors` signal remains zero throughout the observed run.

## Architectural review

The ALU has no clock or reset because it is purely combinational. Branch target selection remains outside the ALU; Zero is only comparison information for later branch logic. LW and SW use ALU ADD for effective-address calculation.

## Open items

- Run the same testbench through the repository's reproducible simulation flow.
- Add boundary/overflow-oriented vectors.
- Measure synthesized FPGA resources and timing after CPU integration.
- Review ALU behavior again as part of complete datapath integration.

## Verdict

The ALU RTL and current functional verification evidence are consistent with the approved design specification. Proceed to the next architectural block while retaining the open measurement items above.
