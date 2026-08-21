`timescale 1ns/1ps

module tb_instruction_decoder;

    reg  [31:0] instruction;
    wire [6:0]  opcode;
    wire [4:0]  rd;
    wire [2:0]  funct3;
    wire [4:0]  rs1;
    wire [4:0]  rs2;
    wire [6:0]  funct7;

    instruction_decoder dut (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .funct3(funct3),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7)
    );

    task check_fields;
        input [6:0] exp_opcode;
        input [4:0] exp_rd;
        input [2:0] exp_funct3;
        input [4:0] exp_rs1;
        input [4:0] exp_rs2;
        input [6:0] exp_funct7;
        begin
            #1;
            if ({opcode,rd,funct3,rs1,rs2,funct7} !==
                {exp_opcode,exp_rd,exp_funct3,exp_rs1,exp_rs2,exp_funct7}) begin
                $display("FAIL instruction=%b", instruction);
                $display("  got: opcode=%b rd=%b funct3=%b rs1=%b rs2=%b funct7=%b",
                         opcode,rd,funct3,rs1,rs2,funct7);
                $display("  exp: opcode=%b rd=%b funct3=%b rs1=%b rs2=%b funct7=%b",
                         exp_opcode,exp_rd,exp_funct3,exp_rs1,exp_rs2,exp_funct7);
                $fatal;
            end
        end
    endtask

    initial begin
        // ADD x5,x1,x2 = 00000000001000001000001010110011
        instruction = 32'b00000000001000001000001010110011;
        check_fields(7'b0110011,5'b00101,3'b000,5'b00001,5'b00010,7'b0000000);

        // ADDI x5,x1,10 = 00000000101000001000001010010011
        // [24:20] is imm[4:0], not rs2. The decoder still exposes
        // the raw [24:20] slice on its rs2 output for uniform field extraction.
        instruction = 32'b00000000101000001000001010010011;
        check_fields(7'b0010011,5'b00101,3'b000,5'b00001,5'b01010,7'b0000000);

        // SW x5,8(x1) = 00000000010100001010010000100011
        // [11:7] is imm[4:0], while [24:20] is rs2.
        instruction = 32'b00000000010100001010010000100011;
        check_fields(7'b0100011,5'b01000,3'b010,5'b00001,5'b00101,7'b0000000);

        // BEQ x1,x2,20 = 00000100001000001000101001100011
        // [11:7] and [31:25] are immediate fragments, not rd/funct7.
        instruction = 32'b00000100001000001000101001100011;
        check_fields(7'b1100011,5'b10100,3'b000,5'b00001,5'b00010,7'b0000010);

        // JAL x5,20 = 00000010100000000000001011101111
        // The raw [24:20] slice is part of the J-type immediate, not rs2.
        instruction = 32'b00000010100000000000001011101111;
        check_fields(7'b1101111,5'b00101,3'b000,5'b00000,5'b00101,7'b0000000);

        $display("PASS: instruction decoder field extraction tests");
        $finish;
    end

endmodule
