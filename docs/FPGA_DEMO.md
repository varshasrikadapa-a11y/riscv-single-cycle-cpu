# Basys-3 FPGA Demonstration

## Hardware and programming
- Board: Digilent Basys-3, Artix-7 `xc7a35tcpg236-1`
- Clock: board 100 MHz clock
- Bitstream: generated from the `basys3_top` wrapper and `constraints/basys3_top.xdc`
- Program instruction words are initialized in RTL instruction memory; no external instruction input is needed.

## Run the demo
1. Connect the Basys-3 board to the computer using its USB programming cable and turn the board on.
2. In Vivado Hardware Manager, connect to the target and program the FPGA with the generated bitstream.
3. Press the center button (btnC) to assert synchronous reset. Release it to start the program from PC=0.
4. Set SW0 to 0. The eight LEDs display PC[7:0]. Watch the addresses advance through the test program.
5. Set SW0 to 1. The eight LEDs display ALU-result[7:0] for the instruction currently executing. This is a live debug signal, not a register holding the final computed value.
6. Press btnC again to restart the demonstration.

## What the program tests
The program in `rtl/basys3_top.v` initializes instruction memory with:
- ADDI x1,x0,10 and ADDI x2,x0,20
- ADD x3,x1,x2, producing 30
- SW x3,0(x0), then LW x4,0(x0)
- BEQ and BNE tests (some instructions are deliberately skipped)
- JAL and its PC+4 return-address write-back
- SUB, AND, OR, XOR, SLT
- Immediate arithmetic/logical operations, including a negative immediate
- An attempted write to x0 (x0 must remain zero)
- Additional SW/LW accesses at byte addresses 4 and 8
- A terminal `JAL x0,0` loop

## Expected visible behavior
- In PC mode (SW0=0), the LED byte changes as the PC advances. When the program reaches its terminal self-loop, PC holds at `0x00000094`; the LEDs show the low byte `0x94` (binary `10010100`).
- In ALU mode (SW0=1), the LEDs show the low eight bits of the live ALU result. Values depend on the instruction currently at the PC. The terminal JAL self-loop can display zero, so do not interpret a zero display at the end as the program having failed.
- The board's switches do not select the instruction or provide data to the CPU. The test program is preloaded in RTL.

## Demonstration to an instructor
Show reset, PC progression in SW0=0, switch to ALU mode in SW0=1, reset and repeat if needed, then explain that the test program is stored in instruction memory and executes one instruction per clock cycle. Use the XSim waveform to show instruction, PC, ALU, memory, and write-back behavior more precisely.

## Timing evidence
The final user-provided implementation timing screenshot reported setup WNS +0.011 ns, TNS 0, 0 failing setup endpoints, hold WHS +0.027 ns, and 0 hold failures. This meets the report's timing constraints, but the setup margin is very small. Any source, constraint, or implementation-setting change requires another implementation timing check.
