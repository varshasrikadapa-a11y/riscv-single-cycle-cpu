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
    integer errors;
    integer dmem_read_count;
    integer dmem_write_count;

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

    // Check the external data-memory transaction at the clock edge where
    // the CPU commits the corresponding instruction.
    always @(posedge clk) begin
        if (!reset && dmem_write) begin
            dmem_write_count = dmem_write_count + 1;
            if (dmem_addr !== 32'd0 || dmem_wdata !== 32'd30 ||
                dmem_byte_en !== 4'b1111) begin
                $display("FAIL SW bus: addr=%h wdata=%h byte_en=%b",
                         dmem_addr, dmem_wdata, dmem_byte_en);
                errors = errors + 1;
            end
        end

        if (!reset && dmem_read) begin
            dmem_read_count = dmem_read_count + 1;
            if (dmem_addr !== 32'd0 || dmem_byte_en !== 4'b1111) begin
                $display("FAIL LW bus: addr=%h byte_en=%b",
                         dmem_addr, dmem_byte_en);
                errors = errors + 1;
            end
        end
    end

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        dmem_rdata = 32'b0;
        errors = 0;
        dmem_read_count = 0;
        dmem_write_count = 0;

        for (integer i = 0; i < 64; i = i + 1)
            imem[i] = 32'b0;
        for (integer j = 0; j < 256; j = j + 1)
            dmem[j] = 32'b0;

        // Combined RV32I single-cycle integration program.  All branch and
        // JAL offsets are byte offsets relative to the instruction PC.
        //
        // PC  Instruction              Derived encoding
        //  0  ADDI x1, x0, 10          00A00093
        //  4  ADDI x2, x0, 20          01400113
        //  8  ADD  x3, x1, x2          002081B3
        // 12  SW   x3, 0(x0)           00302023
        // 16  LW   x4, 0(x0)           00002203
        // 20  BEQ  x4, x3, +8          00320463  (taken; skips PC 24)
        // 24  ADDI x5, x0, 1           00100293  (must be skipped)
        // 28  BNE  x4, x0, +8          00021463  (taken; skips PC 32)
        // 32  ADDI x6, x0, 1           00100313  (must be skipped)
        // 36  BNE  x4, x3, +8          00321463  (not taken)
        // 40  ADDI x7, x0, 7           00700393
        // 44  JAL  x8, +8              0080046F  (x8 = 48; skips PC 48)
        // 48  ADDI x9, x0, 1           00100493  (must be skipped)
        // 52  ADDI x10, x0, 42         02A00513
        imem[0] = 32'h00A00093;
        imem[1] = 32'h01400113;
        imem[2] = 32'h002081B3;
        imem[3] = 32'h00302023;
        imem[4] = 32'h00002203;
        imem[5] = 32'h00320463;
        imem[6] = 32'h00100293;
        imem[7] = 32'h00021463;
        imem[8] = 32'h00100313;
        imem[9] = 32'h00321463;
        imem[10] = 32'h00700393;
        imem[11] = 32'h0080046F;
        imem[12] = 32'h00100493;
        imem[13] = 32'h02A00513;

        #12;
        reset = 1'b0;

        // Eleven non-NOP instructions execute after reset release.  Wait for
        // a further edge so every write-back and the synchronous SW completes.
        repeat (12) @(posedge clk);
        #1;

        if (dut.registers.registers[1] !== 32'd10) begin
            $display("FAIL ADDI: x1 expected 10, got %0d", dut.registers.registers[1]);
            errors = errors + 1;
        end
        if (dut.registers.registers[2] !== 32'd20) begin
            $display("FAIL ADDI: x2 expected 20, got %0d", dut.registers.registers[2]);
            errors = errors + 1;
        end
        if (dut.registers.registers[3] !== 32'd30) begin
            $display("FAIL ADD: x3 expected 30, got %0d", dut.registers.registers[3]);
            errors = errors + 1;
        end
        if (dmem[0] !== 32'd30) begin
            $display("FAIL SW: memory[0] expected 30, got %0d", dmem[0]);
            errors = errors + 1;
        end
        if (dut.registers.registers[4] !== 32'd30) begin
            $display("FAIL LW: x4 expected 30, got %0d", dut.registers.registers[4]);
            errors = errors + 1;
        end
        if (dut.registers.registers[5] !== 32'd0 || dut.registers.registers[6] !== 32'd0) begin
            $display("FAIL taken branch: x5=%0d x6=%0d; both skipped writes must remain zero",
                     dut.registers.registers[5], dut.registers.registers[6]);
            errors = errors + 1;
        end
        if (dut.registers.registers[7] !== 32'd7) begin
            $display("FAIL not-taken BNE: x7 expected 7, got %0d", dut.registers.registers[7]);
            errors = errors + 1;
        end
        if (dut.registers.registers[8] !== 32'd48 || dut.registers.registers[9] !== 32'd0) begin
            $display("FAIL JAL: x8 return address=%0d (expected 48), x9=%0d (expected skipped zero)",
                     dut.registers.registers[8], dut.registers.registers[9]);
            errors = errors + 1;
        end
        if (dut.registers.registers[10] !== 32'd42) begin
            $display("FAIL JAL target: x10 expected 42, got %0d", dut.registers.registers[10]);
            errors = errors + 1;
        end
        if (dmem_write_count !== 1 || dmem_read_count !== 1) begin
            $display("FAIL memory controls: writes=%0d reads=%0d, expected one each",
                     dmem_write_count, dmem_read_count);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("CPU INTEGRATION VERIFICATION PASSED: ADDI/ADD, SW, LW, BEQ, BNE, and JAL.");
        else
            $display("CPU INTEGRATION VERIFICATION FAILED: %0d error(s).", errors);

        #10;
        if (errors == 0)
            $finish;
        else
            $fatal(1, "CPU integration test failed");
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
