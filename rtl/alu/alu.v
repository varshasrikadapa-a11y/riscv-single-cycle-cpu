`timescale 1ns/1ps

// 32-bit combinational ALU for the educational RV32I subset.
// ALU_Control encoding:
// 000 ADD
// 001 SUB
// 010 AND
// 011 OR
// 100 XOR
// 101 SLT (signed)
// 110,111 unused -> Result = 0
module alu (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [2:0]  ALU_Control,
    output reg  [31:0] Result,
    output wire        Zero
);

    always @(*) begin
        case (ALU_Control)
            3'b000: Result = A + B;
            3'b001: Result = A - B;
            3'b010: Result = A & B;
            3'b011: Result = A | B;
            3'b100: Result = A ^ B;
            3'b101: Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            default: Result = 32'd0;
        endcase
    end

    assign Zero = (Result == 32'd0);

endmodule
