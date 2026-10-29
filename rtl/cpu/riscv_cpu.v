`timescale 1ns/1ps
module riscv_cpu (
    input wire clk, input wire reset,
    output wire [31:0] imem_addr, input wire [31:0] imem_rdata,
    output wire [31:0] dmem_addr, output wire [31:0] dmem_wdata,
    input wire [31:0] dmem_rdata, output wire dmem_read, output wire dmem_write,
    output wire [3:0] dmem_byte_en,
    output wire [31:0] debug_pc,
    output wire [31:0] debug_alu_result
);
    wire [31:0] pc;
    wire [31:0] pc_next_addr;
    wire [31:0] instruction;
    assign imem_addr = pc;
    assign instruction = imem_rdata;
    assign debug_pc = pc;

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [6:0] funct7;

    instruction_decoder decoder (
        .instruction(instruction), .opcode(opcode), .rd(rd),
        .funct3(funct3), .rs1(rs1), .rs2(rs2), .funct7(funct7)
    );

    wire [31:0] immediate;
    immediate_generator imm_gen (.instruction(instruction), .immediate(immediate));

    wire RegWrite, MemRead, MemWrite, ALUSrc;
    wire [1:0] ALUOp;
    wire Branch, BranchType, Jump, MemToReg;

    main_control control_unit (
        .opcode(opcode), .funct3(funct3), .RegWrite(RegWrite),
        .MemRead(MemRead), .MemWrite(MemWrite), .ALUSrc(ALUSrc),
        .ALUOp(ALUOp), .Branch(Branch), .BranchType(BranchType),
        .Jump(Jump), .MemToReg(MemToReg)
    );

    wire [31:0] ReadData1, ReadData2, writeback_data;
    register_file registers (
        .clk(clk), .reset(reset), .rs1(rs1), .rs2(rs2), .rd(rd),
        .WriteData(writeback_data), .RegWrite(RegWrite),
        .ReadData1(ReadData1), .ReadData2(ReadData2)
    );

    wire [2:0] ALUControl;
    alu_control alu_ctrl (
        .ALUOp(ALUOp), .funct3(funct3), .funct7(funct7),
        .ALUControl(ALUControl)
    );

    wire [31:0] alu_a, alu_b, alu_result;
    wire alu_zero;
    assign alu_a = ReadData1;
    assign alu_b = ALUSrc ? immediate : ReadData2;
    assign debug_alu_result = alu_result;

    alu alu_unit (
        .A(alu_a), .B(alu_b), .ALU_Control(ALUControl),
        .Result(alu_result), .Zero(alu_zero)
    );

    // Direct register operand comparison for BEQ/BNE.
    wire Equal;
    assign Equal = (ReadData1 == ReadData2);
    wire BranchTaken;
    assign BranchTaken = BranchType ? !Equal : Equal;

    // Dedicated effective-address adder, bypassing general ALU selection.
    wire [31:0] effective_addr;
    assign effective_addr = ReadData1 + immediate;
    assign dmem_addr = effective_addr;
    assign dmem_wdata = ReadData2;
    assign dmem_read = MemRead;
    assign dmem_write = MemWrite;
    assign dmem_byte_en = 4'b1111;

    wire [31:0] pc_plus_4;
    assign pc_plus_4 = pc + 32'd4;
    assign writeback_data = Jump ? pc_plus_4 :
                            MemToReg ? dmem_rdata :
                                       alu_result;

    pc_next pc_unit (
        .clk(clk), .reset(reset), .Branch(Branch),
        .BranchTaken(BranchTaken), .Jump(Jump),
        .branch_imm(immediate), .jump_imm(immediate),
        .pc(pc), .pc_next_addr(pc_next_addr)
    );
endmodule
