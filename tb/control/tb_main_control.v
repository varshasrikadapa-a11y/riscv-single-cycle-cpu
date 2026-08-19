`timescale 1ns/1ps

module tb_main_control;
    reg [6:0] opcode;
    reg [2:0] funct3;

    wire RegWrite, MemRead, MemWrite, ALUSrc;
    wire [1:0] ALUOp;
    wire Branch, BranchType, Jump, MemToReg;

    integer errors;

    main_control dut (
        .opcode(opcode), .funct3(funct3),
        .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite),
        .ALUSrc(ALUSrc), .ALUOp(ALUOp), .Branch(Branch),
        .BranchType(BranchType), .Jump(Jump), .MemToReg(MemToReg)
    );

    task check;
        input e_rw, e_mr, e_mw, e_src;
        input [1:0] e_op;
        input e_br, e_bt, e_j, e_mtr;
        begin
            #1;
            if ({RegWrite,MemRead,MemWrite,ALUSrc,ALUOp,Branch,BranchType,Jump,MemToReg} !==
                {e_rw,e_mr,e_mw,e_src,e_op,e_br,e_bt,e_j,e_mtr}) begin
                $display("FAIL opcode=%b funct3=%b outputs=%b", opcode, funct3,
                         {RegWrite,MemRead,MemWrite,ALUSrc,ALUOp,Branch,BranchType,Jump,MemToReg});
                errors = errors + 1;
            end else begin
                $display("PASS opcode=%b funct3=%b", opcode, funct3);
            end
        end
    endtask

    initial begin
        errors = 0;
        opcode = 7'b0110011; funct3 = 3'b000; // R-Type
        check(1,0,0,0,2'b10,0,0,0,0);

        opcode = 7'b0010011; funct3 = 3'b000; // I-Type arithmetic
        check(1,0,0,1,2'b11,0,0,0,0);

        opcode = 7'b0000011; funct3 = 3'b010; // LW
        check(1,1,0,1,2'b00,0,0,0,1);

        opcode = 7'b0100011; funct3 = 3'b010; // SW
        check(0,0,1,1,2'b00,0,0,0,0);

        opcode = 7'b1100011; funct3 = 3'b000; // BEQ
        check(0,0,0,0,2'b01,1,0,0,0);

        opcode = 7'b1100011; funct3 = 3'b001; // BNE
        check(0,0,0,0,2'b01,1,1,0,0);

        opcode = 7'b1101111; funct3 = 3'b000; // JAL
        check(1,0,0,0,2'b00,0,0,1,0);

        opcode = 7'b1111111; funct3 = 3'b111; // Unsupported opcode
        check(0,0,0,0,2'b00,0,0,0,0);

        if (errors == 0)
            $display("MAIN CONTROL VERIFICATION PASSED: all tests passed.");
        else
            $display("MAIN CONTROL VERIFICATION FAILED: %0d test(s) failed.", errors);
        $finish;
    end
endmodule
