`timescale 1ns/1ps

module tb_riscv_cpu;

    reg clk;
    reg reset;

    wire [31:0] imem_addr;
    reg  [31:0] imem_rdata;

    wire [31:0] dmem_addr;
    wire [31:0] dmem_wdata;
    reg  [31:0] dmem_rdata;
    wire        dmem_read;
    wire        dmem_write;
    wire [3:0]  dmem_byte_en;

    reg [31:0] imem [0:63];
    reg [31:0] dmem [0:255];

    riscv_cpu dut (
        .clk(clk),
        .reset(reset),
        .imem_addr(imem_addr),
        .imem_rdata(imem_rdata),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_rdata(dmem_rdata),
        .dmem_read(dmem_read),
        .dmem_write(dmem_write),
        .dmem_byte_en(dmem_byte_en)
    );

    always #5 clk = ~clk;

    // Word-addressed behavioral instruction memory.
    always @(*) begin
        imem_rdata = imem[imem_addr[7:2]];
    end

    // Combinational data-memory read.
    always @(*) begin
        if (dmem_read)
            dmem_rdata = dmem[dmem_addr[9:2]];
        else
            dmem_rdata = 32'b0;
    end

    // Synchronous data-memory write.
    always @(posedge clk) begin
        if (dmem_write)
            dmem[dmem_addr[9:2]] <= dmem_wdata;
    end

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        dmem_rdata = 32'b0;

        for (integer i = 0; i < 64; i = i + 1)
            imem[i] = 32'b0;
        for (integer j = 0; j < 256; j = j + 1)
            dmem[j] = 32'b0;

        // Three-instruction CPU integration test:
        // ADDI x1, x0, 10  -> x1 = 10
        // ADDI x2, x0, 20  -> x2 = 20
        // ADD  x3, x1, x2  -> x3 = 30
        imem[0] = 32'h00A00093;
        imem[1] = 32'h01400113;
        imem[2] = 32'h002081B3;

        #12;
        reset = 1'b0;

        #40;
        $display("FINAL: x1=%0d x2=%0d x3=%0d", dut.registers.registers[1], dut.registers.registers[2], dut.registers.registers[3]);

        if (dut.registers.registers[1] !== 32'd10)
            $display("FAIL: x1 expected 10");
        else if (dut.registers.registers[2] !== 32'd20)
            $display("FAIL: x2 expected 20");
        else if (dut.registers.registers[3] !== 32'd30)
            $display("FAIL: x3 expected 30");
        else
            $display("PASS: ADDI/ADDI/ADD integration test");

        #10;
        $finish;
    end

    initial begin
        $monitor("t=%0t PC=%h INSTR=%h ALU=%h ZERO=%b BRANCH=%b TAKEN=%b JUMP=%b WB=%h DMEM_A=%h DMEM_W=%b DMEM_R=%b",
                 $time,
                 dut.pc,
                 imem_rdata,
                 dut.alu_result,
                 dut.alu_zero,
                 dut.Branch,
                 dut.BranchTaken,
                 dut.Jump,
                 dut.writeback_data,
                 dmem_addr,
                 dmem_write,
                 dmem_read);
    end

endmodule
