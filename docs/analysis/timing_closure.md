# Final Timing Closure — Basys-3 RV32 Single-Cycle CPU

**Tool:** Vivado 2018.2  
**Device:** xc7a35tcpg236-1 (Basys-3 Artix-7)  
**Clock:** W5, 10.000 ns period (100 MHz)  
**Evidence:** User-provided final post-implementation Design Timing Summary.

## Final reported metrics

| Metric | Result |
|---|---:|
| Setup WNS | +0.011 ns |
| Setup TNS | 0.000 ns |
| Setup failing endpoints | 0 |
| Setup endpoints | 3232 |
| Hold WHS | +0.027 ns |
| Hold THS | 0.000 ns |
| Hold failing endpoints | 0 |
| Timing constraints | Met |

The implementation report says all specified timing constraints are met. The setup margin is 11 ps and therefore very small. These are values from the user's screenshot, not an independently rerun implementation in this environment.

## RTL optimizations in the current CPU source

1. **Branch comparison:** direct comparison of the register operands is used for BEQ/BNE instead of making the branch decision depend on the ALU zero output.
2. **Effective address:** load/store address is calculated using `ReadData1 + immediate` in a dedicated combinational expression.
3. **Write-back:** priority mux selects PC+4 for JAL, data-memory read data for LW, and ALU result for other register-writing operations.
4. **Debug visibility:** PC and ALU result are exposed for board LED observation.

The CPU remains single-cycle. No pipeline, extra clock, or architectural memory-latency change was introduced.

## Functional and implementation context

- Behavioral instruction memory and data memory use asynchronous reads; data writes are synchronous.
- Full-word LW/SW only.
- The initialized test program exercises the implemented subset and parks at byte address 148 (0x94) using JAL x0,0.
- User reports simulation, bitstream generation, FPGA programming, and board observation completed.

## Caution

Timing closure is specific to the source snapshot, constraints, device, tool version, and implementation settings. Preserve those artifacts. Any RTL/XDC/settings changes require a new implementation timing check before claiming 100 MHz closure.
