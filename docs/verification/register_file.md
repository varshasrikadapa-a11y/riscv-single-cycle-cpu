# Register File Verification

## Simulation Evidence

Functional verification was performed in Vivado XSim using `tb/register_file/tb_register_file.v`.

## Results

- Synchronous reset: PASS
- Write x5 = 100: PASS
- Write x10 = 200: PASS
- Simultaneous two-port read: PASS
- `RegWrite = 0` prevents write: PASS
- Attempted write to x0 is ignored: PASS
- x0 reads as zero: PASS
- Combinational read behavior: PASS
- Testbench `errors = 0`: PASS

## Conclusion

The observed waveform and testbench result establish functional correctness for the tested architectural behaviors. This verification does not yet establish FPGA timing or resource utilization.
