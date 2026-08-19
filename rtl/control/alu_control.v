// ALU Control for the selected RV32I subset.
// Combinational decode: ALUOp classifies the work; funct3/funct7
// select the exact operation where required.

module alu_control (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [2:0] ALUControl
);

    localparam [1:0] ALUOP_ADD_ADDR    = 2'b00;
    localparam [1:0] ALUOP_SUB_COMPARE = 2'b01;
    localparam [1:0] ALUOP_R_TYPE      = 2'b10;
    localparam [1:0] ALUOP_I_TYPE      = 2'b11;

    localparam [2:0] ALU_ADD = 3'b000;
    localparam [2:0] ALU_SUB = 3'b001;
    localparam [2:0] ALU_AND = 3'b010;
    localparam [2:0] ALU_OR  = 3'b011;
    localparam [2:0] ALU_XOR = 3'b100;
    localparam [2:0] ALU_SLT = 3'b101;

    always @(*) begin
        // Safe deterministic default for unsupported combinations.
        ALUControl = ALU_ADD;

        case (ALUOp)
            ALUOP_ADD_ADDR: begin
                ALUControl = ALU_ADD;
            end

            ALUOP_SUB_COMPARE: begin
                ALUControl = ALU_SUB;
            end

            ALUOP_R_TYPE: begin
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0100000)
                            ALUControl = ALU_SUB;
                        else if (funct7 == 7'b0000000)
                            ALUControl = ALU_ADD;
                        else
                            ALUControl = ALU_ADD;
                    end
                    3'b111: ALUControl = ALU_AND;
                    3'b110: ALUControl = ALU_OR;
                    3'b100: ALUControl = ALU_XOR;
                    3'b010: ALUControl = ALU_SLT;
                    default: ALUControl = ALU_ADD;
                endcase
            end

            ALUOP_I_TYPE: begin
                case (funct3)
                    3'b000: ALUControl = ALU_ADD; // ADDI
                    3'b111: ALUControl = ALU_AND; // ANDI
                    3'b110: ALUControl = ALU_OR;  // ORI
                    3'b100: ALUControl = ALU_XOR; // XORI
                    3'b010: ALUControl = ALU_SLT; // SLTI
                    default: ALUControl = ALU_ADD;
                endcase
            end

            default: ALUControl = ALU_ADD;
        endcase
    end

endmodule
