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
    integer i;
    integer j;

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

    // ============================================================
    // Instruction Memory
    // ============================================================
    // Asynchronous read.
    // Word aligned address:
    // 0x00 -> imem[0]
    // 0x04 -> imem[1]
    // etc.
    always @(*) begin
        imem_rdata = imem[imem_addr[7:2]];
    end

    // ============================================================
    // Data Memory
    // ============================================================
    // Combinational read.
    always @(*) begin
        if (dmem_read)
            dmem_rdata = dmem[dmem_addr[9:2]];
        else
            dmem_rdata = 32'b0;
    end

    // Synchronous write.
    always @(posedge clk) begin
        if (dmem_write)
            dmem[dmem_addr[9:2]] <= dmem_wdata;
    end

    // ============================================================
    // Data-memory bus verification
    // ============================================================
    always @(posedge clk) begin

        if (!reset && dmem_write) begin

            dmem_write_count = dmem_write_count + 1;

            if (dmem_byte_en !== 4'b1111) begin
                $display("FAIL: SW byte enable = %b",
                         dmem_byte_en);
                errors = errors + 1;
            end

            if (dmem_addr !== 32'd0 &&
                dmem_addr !== 32'd4 &&
                dmem_addr !== 32'd8) begin

                $display("FAIL: Unexpected SW address = %h",
                         dmem_addr);
                errors = errors + 1;
            end

        end

        if (!reset && dmem_read) begin

            dmem_read_count = dmem_read_count + 1;

            if (dmem_byte_en !== 4'b1111) begin
                $display("FAIL: LW byte enable = %b",
                         dmem_byte_en);
                errors = errors + 1;
            end

            if (dmem_addr !== 32'd0 &&
                dmem_addr !== 32'd4 &&
                dmem_addr !== 32'd8) begin

                $display("FAIL: Unexpected LW address = %h",
                         dmem_addr);
                errors = errors + 1;
            end

        end
    end

    // ============================================================
    // Main verification
    // ============================================================
    initial begin

        clk = 1'b0;
        reset = 1'b1;

        dmem_rdata = 32'b0;

        errors = 0;
        dmem_read_count = 0;
        dmem_write_count = 0;

        // Clear memories
        for (i = 0; i < 64; i = i + 1)
            imem[i] = 32'b0;

        for (j = 0; j < 256; j = j + 1)
            dmem[j] = 32'b0;


        // ========================================================
        // PROGRAM 1
        // Basic integration + memory + branch + JAL
        // ========================================================

        // PC 0
        // ADDI x1, x0, 10
        imem[0] = 32'h00A00093;

        // PC 4
        // ADDI x2, x0, 20
        imem[1] = 32'h01400113;

        // PC 8
        // ADD x3, x1, x2
        imem[2] = 32'h002081B3;

        // PC 12
        // SW x3, 0(x0)
        imem[3] = 32'h00302023;

        // PC 16
        // LW x4, 0(x0)
        imem[4] = 32'h00002203;

        // PC 20
        // BEQ x4, x3, +8
        // Taken -> PC 28
        imem[5] = 32'h00320463;

        // PC 24
        // Should be skipped
        // ADDI x5, x0, 1
        imem[6] = 32'h00100293;

        // PC 28
        // BNE x4, x0, +8
        // Taken -> PC 36
        imem[7] = 32'h00021463;

        // PC 32
        // Should be skipped
        // ADDI x6, x0, 1
        imem[8] = 32'h00100313;

        // PC 36
        // BNE x4, x3, +8
        // Not taken
        imem[9] = 32'h00321463;

        // PC 40
        // ADDI x7, x0, 7
        imem[10] = 32'h00700393;

        // PC 44
        // JAL x8, +8
        // x8 = PC + 4 = 48
        // PC -> 52
        imem[11] = 32'h0080046F;

        // PC 48
        // Should be skipped
        // ADDI x9, x0, 1
        imem[12] = 32'h00100493;

        // PC 52
        // ADDI x10, x0, 42
        imem[13] = 32'h02A00513;


        // ========================================================
        // PROGRAM 2
        // R-type operations
        // ========================================================

        // PC 56
        // ADDI x11, x0, 20
        imem[14] = 32'h01400593;

        // PC 60
        // ADDI x12, x0, 5
        imem[15] = 32'h00500613;

        // PC 64
        // SUB x13, x11, x12
        // 20 - 5 = 15
        imem[16] = 32'h40C586B3;

        // PC 68
        // AND x14, x11, x12
        // 20 & 5 = 4
        imem[17] = 32'h00C5F733;

        // PC 72
        // OR x15, x11, x12
        // 20 | 5 = 21
        imem[18] = 32'h00C5E7B3;

        // PC 76
        // XOR x16, x11, x12
        // 20 ^ 5 = 17
        imem[19] = 32'h00C5C833;

        // PC 80
        // SLT x17, x11, x12
        // 20 < 5 = 0
        imem[20] = 32'h00C5A8B3;


        // ========================================================
        // PROGRAM 3
        // I-type operations
        // ========================================================

        // PC 84
        // ADDI x18, x0, -1
        imem[21] = 32'hFFF00913;

        // PC 88
        // ANDI x19, x11, 15
        // 20 & 15 = 4
        imem[22] = 32'h00F5F993;

        // PC 92
        // ORI x20, x11, 15
        // 20 | 15 = 31
        imem[23] = 32'h00F5EA13;

        // PC 96
        // XORI x21, x11, 15
        // 20 ^ 15 = 27
        imem[24] = 32'h00F5CA93;

        // PC 100
        // SLTI x22, x18, 0
        // -1 < 0 = 1
        imem[25] = 32'h000A2B13;


        // ========================================================
        // PROGRAM 4
        // x0 protection
        // ========================================================

        // PC 104
        // ADDI x0, x0, 99
        // x0 MUST remain 0
        imem[26] = 32'h06300013;


        // ========================================================
        // PROGRAM 5
        // Negative signed SLT
        // ========================================================

        // PC 108
        // ADDI x23, x0, -1
        imem[27] = 32'hFFF00B93;

        // PC 112
        // ADDI x24, x0, 0
        imem[28] = 32'h00000C13;

        // PC 116
        // SLT x25, x23, x24
        // -1 < 0 -> 1
        imem[29] = 32'h018BACB3;

        // PC 120
        // SLT x26, x24, x23
        // 0 < -1 -> 0
        imem[30] = 32'h01762D33;


        // ========================================================
        // PROGRAM 6
        // Memory addresses 0, 4, 8
        // ========================================================

        // PC 124
        // ADDI x27, x0, 100
        imem[31] = 32'h06400D93;

        // PC 128
        // SW x27, 4(x0)
        imem[32] = 32'h01B02223;

        // PC 132
        // ADDI x28, x0, 200
        imem[33] = 32'h0C800E13;

        // PC 136
        // SW x28, 8(x0)
        imem[34] = 32'h01C02423;

        // PC 140
        // LW x29, 4(x0)
        imem[35] = 32'h00402E83;

        // PC 144
        // LW x30, 8(x0)
        imem[36] = 32'h00802F03;


        // ========================================================
        // Reset release
        // ========================================================

        #12;
        reset = 1'b0;


        // Run enough cycles for the complete program.
        repeat (40) @(posedge clk);

        #1;


        // ========================================================
        // CHECK PROGRAM 1
        // ========================================================

        if (dut.registers.registers[1] !== 32'd10) begin
            $display("FAIL ADDI x1: expected 10, got %h",
                     dut.registers.registers[1]);
            errors = errors + 1;
        end

        if (dut.registers.registers[2] !== 32'd20) begin
            $display("FAIL ADDI x2: expected 20, got %h",
                     dut.registers.registers[2]);
            errors = errors + 1;
        end

        if (dut.registers.registers[3] !== 32'd30) begin
            $display("FAIL ADD x3: expected 30, got %h",
                     dut.registers.registers[3]);
            errors = errors + 1;
        end

        if (dmem[0] !== 32'd30) begin
            $display("FAIL SW/LW memory[0]: expected 30, got %h",
                     dmem[0]);
            errors = errors + 1;
        end

        if (dut.registers.registers[4] !== 32'd30) begin
            $display("FAIL LW x4: expected 30, got %h",
                     dut.registers.registers[4]);
            errors = errors + 1;
        end

        // x5 and x6 must remain zero because branches skipped them.
        if (dut.registers.registers[5] !== 32'd0) begin
            $display("FAIL BEQ: x5 should remain 0, got %h",
                     dut.registers.registers[5]);
            errors = errors + 1;
        end

        if (dut.registers.registers[6] !== 32'd0) begin
            $display("FAIL BNE: x6 should remain 0, got %h",
                     dut.registers.registers[6]);
            errors = errors + 1;
        end

        if (dut.registers.registers[7] !== 32'd7) begin
            $display("FAIL branch not-taken path: x7 expected 7, got %h",
                     dut.registers.registers[7]);
            errors = errors + 1;
        end

        // JAL return address.
        if (dut.registers.registers[8] !== 32'd48) begin
            $display("FAIL JAL: x8 expected 48, got %h",
                     dut.registers.registers[8]);
            errors = errors + 1;
        end

        // Instruction at PC 48 must be skipped.
        if (dut.registers.registers[9] !== 32'd0) begin
            $display("FAIL JAL skip: x9 expected 0, got %h",
                     dut.registers.registers[9]);
            errors = errors + 1;
        end

        if (dut.registers.registers[10] !== 32'd42) begin
            $display("FAIL JAL target: x10 expected 42, got %h",
                     dut.registers.registers[10]);
            errors = errors + 1;
        end


        // ========================================================
        // CHECK R-TYPE
        // ========================================================

        // SUB: 20 - 5 = 15
        if (dut.registers.registers[13] !== 32'd15) begin
            $display("FAIL SUB: x13 expected 15, got %h",
                     dut.registers.registers[13]);
            errors = errors + 1;
        end

        // AND: 20 & 5 = 4
        if (dut.registers.registers[14] !== 32'd4) begin
            $display("FAIL AND: x14 expected 4, got %h",
                     dut.registers.registers[14]);
            errors = errors + 1;
        end

        // OR: 20 | 5 = 21
        if (dut.registers.registers[15] !== 32'd21) begin
            $display("FAIL OR: x15 expected 21, got %h",
                     dut.registers.registers[15]);
            errors = errors + 1;
        end

        // XOR: 20 ^ 5 = 17
        if (dut.registers.registers[16] !== 32'd17) begin
            $display("FAIL XOR: x16 expected 17, got %h",
                     dut.registers.registers[16]);
            errors = errors + 1;
        end

        // SLT: 20 < 5 = 0
        if (dut.registers.registers[17] !== 32'd0) begin
            $display("FAIL SLT positive: x17 expected 0, got %h",
                     dut.registers.registers[17]);
            errors = errors + 1;
        end


        // ========================================================
        // CHECK I-TYPE
        // ========================================================

        // ADDI -1
        if (dut.registers.registers[18] !== 32'hFFFFFFFF) begin
            $display("FAIL negative ADDI: x18 expected FFFFFFFF, got %h",
                     dut.registers.registers[18]);
            errors = errors + 1;
        end

        // ANDI
        if (dut.registers.registers[19] !== 32'd4) begin
            $display("FAIL ANDI: x19 expected 4, got %h",
                     dut.registers.registers[19]);
            errors = errors + 1;
        end

        // ORI
        if (dut.registers.registers[20] !== 32'd31) begin
            $display("FAIL ORI: x20 expected 31, got %h",
                     dut.registers.registers[20]);
            errors = errors + 1;
        end

        // XORI
        if (dut.registers.registers[21] !== 32'd27) begin
            $display("FAIL XORI: x21 expected 27, got %h",
                     dut.registers.registers[21]);
            errors = errors + 1;
        end

        // SLTI: -1 < 0
        if (dut.registers.registers[22] !== 32'd1) begin
            $display("FAIL SLTI signed: x22 expected 1, got %h",
                     dut.registers.registers[22]);
            errors = errors + 1;
        end


        // ========================================================
        // CHECK x0
        // ========================================================

        if (dut.registers.registers[0] !== 32'd0) begin
            $display("FAIL x0 protection: x0 changed to %h",
                     dut.registers.registers[0]);
            errors = errors + 1;
        end


        // ========================================================
        // CHECK SIGNED SLT
        // ========================================================

        if (dut.registers.registers[25] !== 32'd1) begin
            $display("FAIL SLT -1 < 0: x25 expected 1, got %h",
                     dut.registers.registers[25]);
            errors = errors + 1;
        end

        if (dut.registers.registers[26] !== 32'd0) begin
            $display("FAIL SLT 0 < -1: x26 expected 0, got %h",
                     dut.registers.registers[26]);
            errors = errors + 1;
        end


        // ========================================================
        // CHECK MEMORY
        // ========================================================

        if (dmem[1] !== 32'd100) begin
            $display("FAIL memory[4]: expected 100, got %h",
                     dmem[1]);
            errors = errors + 1;
        end

        if (dmem[2] !== 32'd200) begin
            $display("FAIL memory[8]: expected 200, got %h",
                     dmem[2]);
            errors = errors + 1;
        end

        if (dut.registers.registers[29] !== 32'd100) begin
            $display("FAIL LW address 4: x29 expected 100, got %h",
                     dut.registers.registers[29]);
            errors = errors + 1;
        end

        if (dut.registers.registers[30] !== 32'd200) begin
            $display("FAIL LW address 8: x30 expected 200, got %h",
                     dut.registers.registers[30]);
            errors = errors + 1;
        end


        // ========================================================
        // MEMORY TRANSACTION COUNT
        // ========================================================

        // Expected:
        // SW x3 -> address 0
        // LW x4 <- address 0
        // SW x27 -> address 4
        // SW x28 -> address 8
        // LW x29 <- address 4
        // LW x30 <- address 8
        //
        // Total = 3 writes, 3 reads.

        if (dmem_write_count !== 3) begin
            $display("FAIL memory writes: expected 3, got %0d",
                     dmem_write_count);
            errors = errors + 1;
        end

        if (dmem_read_count !== 3) begin
            $display("FAIL memory reads: expected 3, got %0d",
                     dmem_read_count);
            errors = errors + 1;
        end


        // ========================================================
        // FINAL RESULT
        // ========================================================

        if (errors == 0) begin

            $display("");
            $display("====================================================");
            $display(" CPU PHASE 4 INTEGRATION VERIFICATION PASSED");
            $display("====================================================");
            $display(" All R-type instructions verified");
            $display(" All I-type instructions verified");
            $display(" LW / SW verified");
            $display(" BEQ / BNE taken and not-taken verified");
            $display(" JAL target and PC+4 verified");
            $display(" x0 protection verified");
            $display(" Signed SLT / SLTI verified");
            $display(" Multiple memory addresses verified");
            $display(" Final mixed integration verified");
            $display("====================================================");

        end
        else begin

            $display("");
            $display("====================================================");
            $display(" CPU PHASE 4 INTEGRATION VERIFICATION FAILED");
            $display(" Errors = %0d", errors);
            $display("====================================================");

        end

        #10;

        if (errors == 0)
            $finish;
        else
            $fatal(1, "CPU integration verification failed");

    end


    // ============================================================
    // Waveform / Console Monitor
    // ============================================================

    initial begin

        $monitor(
            "t=%0t PC=%h INSTR=%h ALU=%h ZERO=%b BRANCH=%b TAKEN=%b JUMP=%b WB=%h DMEM_A=%h DMEM_W=%b DMEM_R=%b",
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
            dmem_read
        );

    end

endmodule
