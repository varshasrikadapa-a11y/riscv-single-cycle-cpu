`timescale 1ns/1ps

module tb_immediate_generator;
    reg  [31:0] instruction;
    wire [31:0] immediate;
    integer errors;

    immediate_generator dut (
        .instruction(instruction),
        .immediate(immediate)
    );

    task check;
        input [31:0] expected;
        begin
            #1;
            if (immediate !== expected) begin
                $display("FAIL: instruction=%h immediate=%h expected=%h", instruction, immediate, expected);
                errors = errors + 1;
            end else begin
                $display("PASS: instruction=%h immediate=%h", instruction, immediate);
            end
        end
    endtask

    // Helper encodings contain only the fields needed by ImmGen.
    initial begin
        errors = 0;

        // I-Type +10: imm[11:0]=000000001010, opcode=0010011
        instruction = {12'b000000001010, 20'b0};
        instruction[6:0] = 7'b0010011;
        check(32'd10);

        // I-Type -4: imm[11:0]=111111111100
        instruction = {12'b111111111100, 20'b0};
        instruction[6:0] = 7'b0010011;
        check(32'hFFFF_FFFC);

        // S-Type +12: imm[11:5]=0000000, imm[4:0]=01100
        instruction = 32'b0;
        instruction[31:25] = 7'b0000000;
        instruction[11:7]  = 5'b01100;
        instruction[6:0]   = 7'b0100011;
        check(32'd12);

        // S-Type -4: 12-bit immediate = 111111111100
        instruction = 32'b0;
        instruction[31:25] = 7'b1111111;
        instruction[11:7]  = 5'b11100;
        instruction[6:0]   = 7'b0100011;
        check(32'hFFFF_FFFC);

        // B-Type +4: immediate[12:1]=000000000010, imm[0]=0
        instruction = 32'b0;
        instruction[31]    = 1'b0;
        instruction[30:25] = 6'b000000;
        instruction[11:8]  = 4'b0010;
        instruction[7]     = 1'b0;
        instruction[6:0]   = 7'b1100011;
        check(32'd4);

        // B-Type -4: immediate[12:1] all ones, imm[0]=0
        instruction = 32'b0;
        instruction[31]    = 1'b1;
        instruction[30:25] = 6'b111111;
        instruction[11:8]  = 4'b1110;
        instruction[7]     = 1'b1;
        instruction[6:0]   = 7'b1100011;
        check(32'hFFFF_FFFC);

        // J-Type +4: imm[20:1]=00000000000000000010, imm[0]=0
        instruction = 32'b0;
        instruction[31]    = 1'b0;
        instruction[30:21] = 10'b0000000010;
        instruction[20]    = 1'b0;
        instruction[19:12] = 8'b0;
        instruction[6:0]   = 7'b1101111;
        check(32'd4);

        // J-Type -4: negative 21-bit immediate, imm[0]=0
        instruction = 32'b0;
        instruction[31]    = 1'b1;
        instruction[30:21] = 10'b1111111110;
        instruction[20]    = 1'b1;
        instruction[19:12] = 8'b11111111;
        instruction[6:0]   = 7'b1101111;
        check(32'hFFFF_FFFC);

        // Unsupported opcode -> defined default zero
        instruction = 32'b0;
        instruction[6:0] = 7'b0110011;
        check(32'd0);

        if (errors == 0)
            $display("IMMEDIATE GENERATOR VERIFICATION PASSED: all tests passed.");
        else
            $display("IMMEDIATE GENERATOR VERIFICATION FAILED: %0d test(s) failed.", errors);

        $finish;
    end
endmodule
