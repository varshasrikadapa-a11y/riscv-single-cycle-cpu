// 32-bit RISC-V Immediate Generator
// Combinational logic for the selected educational RV32I subset.
// Supported immediate formats: I, S, B, J.

module immediate_generator (
    input  wire [31:0] instruction,
    output reg  [31:0] immediate
);

    localparam [6:0] OPCODE_I_ARITH = 7'b0010011;
    localparam [6:0] OPCODE_LW       = 7'b0000011;
    localparam [6:0] OPCODE_SW       = 7'b0100011;
    localparam [6:0] OPCODE_BRANCH   = 7'b1100011;
    localparam [6:0] OPCODE_JAL      = 7'b1101111;

    always @(*) begin
        // Default for instructions without a supported immediate.
        immediate = 32'b0;

        case (instruction[6:0])
            // I-Type: ADDI, ANDI, ORI, XORI, SLTI, LW
            OPCODE_I_ARITH,
            OPCODE_LW: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end

            // S-Type: SW
            OPCODE_SW: begin
                immediate = {{20{instruction[31]}},
                             instruction[31:25], instruction[11:7]};
            end

            // B-Type: BEQ, BNE
            // imm[0] is implicit zero.
            OPCODE_BRANCH: begin
                immediate = {{19{instruction[31]}},
                             instruction[31],
                             instruction[7],
                             instruction[30:25],
                             instruction[11:8],
                             1'b0};
            end

            // J-Type: JAL
            // imm[0] is implicit zero.
            OPCODE_JAL: begin
                immediate = {{11{instruction[31]}},
                             instruction[31],
                             instruction[19:12],
                             instruction[20],
                             instruction[30:21],
                             1'b0};
            end

            default: begin
                immediate = 32'b0;
            end
        endcase
    end

endmodule
