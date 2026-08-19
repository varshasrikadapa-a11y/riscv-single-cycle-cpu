// Main Control Unit for the selected RV32I subset.
// Purely combinational opcode/funct3 decode.
// Exact ALU operation selection is delegated to ALU Control.

module main_control (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    output reg        RegWrite,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg [1:0]  ALUOp,
    output reg        Branch,
    output reg        BranchType,
    output reg        Jump,
    output reg        MemToReg
);

    // ALUOp encodings:
    // 00 = ADD_ADDR    : LW/SW effective address
    // 01 = SUB_COMPARE : BEQ/BNE comparison
    // 10 = R_TYPE      : exact operation from funct3/funct7
    // 11 = I_TYPE      : exact operation from funct3
    localparam [1:0] ALUOP_ADD_ADDR    = 2'b00;
    localparam [1:0] ALUOP_SUB_COMPARE = 2'b01;
    localparam [1:0] ALUOP_R_TYPE      = 2'b10;
    localparam [1:0] ALUOP_I_TYPE      = 2'b11;

    // BranchType: 0 = BEQ, 1 = BNE.
    localparam BR_BEQ = 1'b0;
    localparam BR_BNE = 1'b1;

    always @(*) begin
        // Safe defaults: unsupported instructions perform no architectural write.
        RegWrite  = 1'b0;
        MemRead   = 1'b0;
        MemWrite  = 1'b0;
        ALUSrc    = 1'b0;
        ALUOp     = ALUOP_ADD_ADDR;
        Branch    = 1'b0;
        BranchType = BR_BEQ;
        Jump      = 1'b0;
        MemToReg  = 1'b0;

        case (opcode)
            7'b0110011: begin // R-Type: ADD/SUB/AND/OR/XOR/SLT
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                ALUOp    = ALUOP_R_TYPE;
            end

            7'b0010011: begin // I-Type arithmetic: ADDI/ANDI/ORI/XORI/SLTI
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = ALUOP_I_TYPE;
            end

            7'b0000011: begin // LW
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = ALUOP_ADD_ADDR;
                MemToReg = 1'b1;
            end

            7'b0100011: begin // SW
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = ALUOP_ADD_ADDR;
            end

            7'b1100011: begin // BEQ/BNE
                Branch = 1'b1;
                ALUSrc = 1'b0;
                ALUOp  = ALUOP_SUB_COMPARE;

                case (funct3)
                    3'b000: BranchType = BR_BEQ;
                    3'b001: BranchType = BR_BNE;
                    default: begin
                        Branch = 1'b0;
                        BranchType = BR_BEQ;
                    end
                endcase
            end

            7'b1101111: begin // JAL
                RegWrite = 1'b1;
                Jump     = 1'b1;
                // ALUSrc/MemToReg remain deterministic defaults.
            end

            default: begin
                // Keep all safe defaults for unsupported opcodes.
            end
        endcase
    end

endmodule
