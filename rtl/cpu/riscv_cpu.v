`timescale 1ns/1ps

// Top-level 32-bit single-cycle RISC-V CPU.
// Integrates the existing verified datapath/control modules.
// Memory is external through separate instruction/data interfaces.

module riscv_cpu (
    input  wire        clk,
    input  wire        reset,

    // Instruction memory interface
    output wire [31:0] imem_addr,
    input  wire [31:0] imem_rdata,

    // Data memory interface
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wdata,
    input  wire [31:0] dmem_rdata,
    output wire        dmem_read,
    output wire        dmem_write,
    output wire [3:0]  dmem_byte_en
);

    // ----------------------------------------------------------------
    // Instruction and PC signals
    // ----------------------------------------------------------------
    wire [31:0] pc;
    wire [31:0] pc_next_addr;
    wire [31:0] instruction;

    assign imem_addr = pc;
    assign instruction = imem_rdata;

    // ----------------------------------------------------------------
    // Instruction decoder outputs
    // ----------------------------------------------------------------
    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] funct7;

    instruction_decoder decoder (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7)
    );

    // ----------------------------------------------------------------
    // Immediate generation
    // ----------------------------------------------------------------
    wire [31:0] immediate;

    immediate_generator imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );

    // ----------------------------------------------------------------
    // Main control
    // ----------------------------------------------------------------
    wire       RegWrite;
    wire       MemRead;
    wire       MemWrite;
    wire       ALUSrc;
    wire [1:0] ALUOp;
    wire       Branch;
    wire       BranchType;
    wire       Jump;
    wire       MemToReg;

    main_control control_unit (
        .opcode(opcode),
        .funct3(funct3),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp),
        .Branch(Branch),
        .BranchType(BranchType),
        .Jump(Jump),
        .MemToReg(MemToReg)
    );

    // ----------------------------------------------------------------
    // Register file
    // ----------------------------------------------------------------
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;
    wire [31:0] writeback_data;

    register_file registers (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WriteData(writeback_data),
        .RegWrite(RegWrite),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    // ----------------------------------------------------------------
    // ALU control
    // ----------------------------------------------------------------
    wire [2:0] ALUControl;

    alu_control alu_ctrl (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );

    // ----------------------------------------------------------------
    // ALU input selection
    // ----------------------------------------------------------------
    wire [31:0] alu_a;
    wire [31:0] alu_b;
    wire [31:0] alu_result;
    wire        alu_zero;

    assign alu_a = ReadData1;
    assign alu_b = ALUSrc ? immediate : ReadData2;

    alu alu_unit (
        .A(alu_a),
        .B(alu_b),
        .ALU_Control(ALUControl),
        .Result(alu_result),
        .Zero(alu_zero)
    );

    // ----------------------------------------------------------------
    // Branch decision
    // BranchType: 0 = BEQ, 1 = BNE.
    // ----------------------------------------------------------------
    wire BranchTaken;

    assign BranchTaken = Branch &&
                         ((BranchType == 1'b0 && alu_zero) ||
                          (BranchType == 1'b1 && !alu_zero));

    // ----------------------------------------------------------------
    // Data memory interface
    // ----------------------------------------------------------------
    assign dmem_addr    = alu_result;
    assign dmem_wdata   = ReadData2;
    assign dmem_read    = MemRead;
    assign dmem_write   = MemWrite;
    assign dmem_byte_en = 4'b1111;

    // ----------------------------------------------------------------
    // Three-way write-back selection
    // 00 = ALU result
    // 01 = memory data
    // 10 = PC + 4
    // 11 = unused
    // ----------------------------------------------------------------
    wire [1:0] WBSelect;
    wire [31:0] pc_plus_4;

    assign pc_plus_4 = pc + 32'd4;

    assign WBSelect = Jump ? 2'b10 :
                      (MemToReg ? 2'b01 : 2'b00);

    assign writeback_data = (WBSelect == 2'b00) ? alu_result :
                            (WBSelect == 2'b01) ? dmem_rdata :
                            (WBSelect == 2'b10) ? pc_plus_4 :
                            32'b0;

    // ----------------------------------------------------------------
    // Program counter and next-PC selection
    // Existing pc_next gives priority: JAL > taken branch > PC + 4.
    // ----------------------------------------------------------------
    pc_next pc_unit (
        .clk(clk),
        .reset(reset),
        .Branch(Branch),
        .BranchTaken(BranchTaken),
        .Jump(Jump),
        .branch_imm(immediate),
        .jump_imm(immediate),
        .pc(pc),
        .pc_next_addr(pc_next_addr)
    );

endmodule
