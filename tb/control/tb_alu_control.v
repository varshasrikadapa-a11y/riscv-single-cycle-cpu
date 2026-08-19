`timescale 1ns/1ps

module tb_alu_control;
    reg [1:0] ALUOp;
    reg [2:0] funct3;
    reg [6:0] funct7;
    wire [2:0] ALUControl;

    integer errors;

    alu_control dut (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );

    task check;
        input [2:0] expected;
        begin
            #1;
            if (ALUControl !== expected) begin
                $display("FAIL ALUOp=%b funct3=%b funct7=%b got=%b expected=%b",
                         ALUOp, funct3, funct7, ALUControl, expected);
                errors = errors + 1;
            end else begin
                $display("PASS ALUOp=%b funct3=%b funct7=%b -> %b",
                         ALUOp, funct3, funct7, ALUControl);
            end
        end
    endtask

    initial begin
        errors = 0;
        funct3 = 3'b000;
        funct7 = 7'b0000000;

        // Effective address and branch comparison classes.
        ALUOp = 2'b00; check(3'b000); // ADD
        ALUOp = 2'b01; check(3'b001); // SUB

        // R-Type: ADD, SUB, AND, OR, XOR, SLT.
        ALUOp = 2'b10; funct3 = 3'b000; funct7 = 7'b0000000; check(3'b000);
        ALUOp = 2'b10; funct3 = 3'b000; funct7 = 7'b0100000; check(3'b001);
        ALUOp = 2'b10; funct3 = 3'b111; funct7 = 7'b0000000; check(3'b010);
        ALUOp = 2'b10; funct3 = 3'b110; funct7 = 7'b0000000; check(3'b011);
        ALUOp = 2'b10; funct3 = 3'b100; funct7 = 7'b0000000; check(3'b100);
        ALUOp = 2'b10; funct3 = 3'b010; funct7 = 7'b0000000; check(3'b101);

        // I-Type: ADDI, ANDI, ORI, XORI, SLTI.
        ALUOp = 2'b11; funct3 = 3'b000; funct7 = 7'b0000000; check(3'b000);
        ALUOp = 2'b11; funct3 = 3'b111; funct7 = 7'b0000000; check(3'b010);
        ALUOp = 2'b11; funct3 = 3'b110; funct7 = 7'b0000000; check(3'b011);
        ALUOp = 2'b11; funct3 = 3'b100; funct7 = 7'b0000000; check(3'b100);
        ALUOp = 2'b11; funct3 = 3'b010; funct7 = 7'b0000000; check(3'b101);

        // Invalid R-Type funct7/funct3 combinations must be deterministic.
        ALUOp = 2'b10; funct3 = 3'b000; funct7 = 7'b1111111; check(3'b000);
        ALUOp = 2'b10; funct3 = 3'b001; funct7 = 7'b0000000; check(3'b000);

        // Invalid I-Type funct3 must be deterministic.
        ALUOp = 2'b11; funct3 = 3'b001; funct7 = 7'b0000000; check(3'b000);

        if (errors == 0)
            $display("ALU CONTROL VERIFICATION PASSED: all tests passed.");
        else
            $display("ALU CONTROL VERIFICATION FAILED: %0d test(s) failed.", errors);

        $finish;
    end
endmodule
