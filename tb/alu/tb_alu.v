`timescale 1ns/1ps

// Verification testbench for the 32-bit combinational ALU.
// Tests every defined operation, branch-equality behavior, signed SLT,
// and the two unused control codes.
module tb_alu;

    reg  [31:0] A;
    reg  [31:0] B;
    reg  [2:0]  ALU_Control;
    wire [31:0] Result;
    wire        Zero;

    integer errors;

    alu dut (
        .A(A),
        .B(B),
        .ALU_Control(ALU_Control),
        .Result(Result),
        .Zero(Zero)
    );

    task check;
        input [31:0] expected_result;
        input        expected_zero;
        begin
            #1;
            if (Result !== expected_result || Zero !== expected_zero) begin
                $display("FAIL: A=%h B=%h Control=%b Result=%h Zero=%b Expected Result=%h Zero=%b",
                         A, B, ALU_Control, Result, Zero,
                         expected_result, expected_zero);
                errors = errors + 1;
            end else begin
                $display("PASS: A=%h B=%h Control=%b Result=%h Zero=%b",
                         A, B, ALU_Control, Result, Zero);
            end
        end
    endtask

    initial begin
        errors = 0;

        // ADD
        A = 32'd10; B = 32'd5; ALU_Control = 3'b000;
        check(32'd15, 1'b0);

        // SUB
        A = 32'd10; B = 32'd5; ALU_Control = 3'b001;
        check(32'd5, 1'b0);

        // SUB equality: required for BEQ comparison
        A = 32'd10; B = 32'd10; ALU_Control = 3'b001;
        check(32'd0, 1'b1);

        // AND
        A = 32'hF0F0_0F0F; B = 32'h0FF0_F0F0; ALU_Control = 3'b010;
        check(32'h00F0_0000, 1'b0);

        // OR
        A = 32'hF000_0000; B = 32'h0000_00F0; ALU_Control = 3'b011;
        check(32'hF000_00F0, 1'b0);

        // XOR
        A = 32'hAAAA_AAAA; B = 32'hFFFF_FFFF; ALU_Control = 3'b100;
        check(32'h5555_5555, 1'b0);

        // SLT signed: -1 < +1
        A = 32'hFFFF_FFFF; B = 32'd1; ALU_Control = 3'b101;
        check(32'd1, 1'b0);

        // SLT signed: +1 < -1 is false
        A = 32'd1; B = 32'hFFFF_FFFF; ALU_Control = 3'b101;
        check(32'd0, 1'b1);

        // Invalid controls
        A = 32'd123; B = 32'd456; ALU_Control = 3'b110;
        check(32'd0, 1'b1);

        A = 32'd123; B = 32'd456; ALU_Control = 3'b111;
        check(32'd0, 1'b1);

        if (errors == 0)
            $display("ALU VERIFICATION PASSED: all tests passed.");
        else
            $display("ALU VERIFICATION FAILED: %0d test(s) failed.", errors);

        $finish;
    end

endmodule
