# Phase 1 — Foundation Analysis / Predictions

## Role
Performance Analyst artifact.

## Status
Predictions only. No FPGA implementation measurements are claimed at this stage.

## Architectural Predictions

1. The single-cycle clock period will be constrained by the longest combinational instruction path.
2. LW is expected to be among the longest paths because it includes instruction fetch, decode/register read, immediate generation, ALU address generation, data-memory read, and write-back selection.
3. R-Type arithmetic should have a shorter path than LW because it does not require data-memory access.
4. Branches require ALU comparison plus target calculation and next-PC selection.
5. JAL requires jump-immediate reconstruction, target addition, next-PC selection, and PC+4 write-back to rd.

## Memory Timing Prediction

Strict single-cycle LW requires same-cycle data-memory read availability. Synchronous FPGA BRAM reads would introduce an incompatible timing dependency for the textbook single-cycle model. Therefore the initial behavioral/distributed memory assumption is retained.

## Resource Prediction

The final resource use will depend on the Vivado inference and implementation of registers, memories, multiplexers, control logic, and arithmetic. Exact LUT/FF/BRAM/DSP utilization must be measured after synthesis and implementation rather than guessed.

## Verification Prediction

The most valuable early verification targets are: instruction-field decoding, immediate reconstruction, ALU operation selection, x0 behavior, PC_next selection, memory read/write control, and write-back source selection.

## Open Measurements

When RTL exists and is synthesized, measure at minimum: clock period / critical path, slack, LUT count, FF count, memory resource usage, and any inferred DSP/BRAM resources.