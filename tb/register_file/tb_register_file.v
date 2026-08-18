`timescale 1ns/1ps

module tb_register_file;

    reg        clk;
    reg        reset;
    reg [4:0]  rs1;
    reg [4:0]  rs2;
    reg [4:0]  rd;
    reg [31:0] WriteData;
    reg        RegWrite;

    wire [31:0] ReadData1;
    wire [31:0] ReadData2;

    integer errors;

    register_file dut (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WriteData(WriteData),
        .RegWrite(RegWrite),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    always #5 clk = ~clk;

    task check_read;
        input [31:0] expected1;
        input [31:0] expected2;
        begin
            #1;
            if (ReadData1 !== expected1 || ReadData2 !== expected2) begin
                $display("FAIL READ: rs1=%0d rs2=%0d ReadData1=%h ReadData2=%h Expected1=%h Expected2=%h",
                         rs1, rs2, ReadData1, ReadData2, expected1, expected2);
                errors = errors + 1;
            end
            else begin
                $display("PASS READ: rs1=%0d rs2=%0d ReadData1=%h ReadData2=%h",
                         rs1, rs2, ReadData1, ReadData2);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b0;
        rs1 = 5'd0;
        rs2 = 5'd0;
        rd = 5'd0;
        WriteData = 32'b0;
        RegWrite = 1'b0;
        errors = 0;

        // 1. Synchronous reset: all registers must become zero.
        reset = 1'b1;
        @(posedge clk);
        #1;
        reset = 1'b0;
        rs1 = 5'd0;
        rs2 = 5'd31;
        check_read(32'd0, 32'd0);

        // 2. Write x5 = 100.
        rd = 5'd5;
        WriteData = 32'd100;
        RegWrite = 1'b1;
        @(posedge clk);
        #1;
        RegWrite = 1'b0;
        rs1 = 5'd5;
        rs2 = 5'd0;
        check_read(32'd100, 32'd0);

        // 3. Write x10 = 200.
        rd = 5'd10;
        WriteData = 32'd200;
        RegWrite = 1'b1;
        @(posedge clk);
        #1;
        RegWrite = 1'b0;

        // 4. Two simultaneous combinational reads.
        rs1 = 5'd5;
        rs2 = 5'd10;
        check_read(32'd100, 32'd200);

        // 5. RegWrite=0 must prevent a write to x6.
        rd = 5'd6;
        WriteData = 32'd999;
        RegWrite = 1'b0;
        @(posedge clk);
        rs1 = 5'd6;
        rs2 = 5'd0;
        check_read(32'd0, 32'd0);

        // 6. Attempt to write x0; x0 must remain zero.
        rd = 5'd0;
        WriteData = 32'd999;
        RegWrite = 1'b1;
        @(posedge clk);
        #1;
        RegWrite = 1'b0;
        rs1 = 5'd0;
        rs2 = 5'd0;
        check_read(32'd0, 32'd0);

        // 7. Verify combinational read changes without a clock edge.
        rs1 = 5'd10;
        rs2 = 5'd5;
        check_read(32'd200, 32'd100);

        if (errors == 0)
            $display("REGISTER FILE VERIFICATION PASSED: all tests passed.");
        else
            $display("REGISTER FILE VERIFICATION FAILED: %0d test(s) failed.", errors);

        $finish;
    end

endmodule
