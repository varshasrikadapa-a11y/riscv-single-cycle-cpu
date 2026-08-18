`timescale 1ns/1ps

module tb_pc_next;

    reg clk;
    reg reset;
    reg Branch;
    reg BranchTaken;
    reg Jump;
    reg [31:0] branch_imm;
    reg [31:0] jump_imm;

    wire [31:0] pc;
    wire [31:0] pc_next_addr;

    integer errors;

    pc_next dut (
        .clk(clk),
        .reset(reset),
        .Branch(Branch),
        .BranchTaken(BranchTaken),
        .Jump(Jump),
        .branch_imm(branch_imm),
        .jump_imm(jump_imm),
        .pc(pc),
        .pc_next_addr(pc_next_addr)
    );

    always #5 clk = ~clk;

    task check_next;
        input [31:0] expected;
        begin
            #1;
            if (pc_next_addr !== expected) begin
                $display("FAIL NEXT-PC: pc=%h Branch=%b BranchTaken=%b Jump=%b next=%h expected=%h",
                         pc, Branch, BranchTaken, Jump, pc_next_addr, expected);
                errors = errors + 1;
            end
            else begin
                $display("PASS NEXT-PC: pc=%h next=%h", pc, pc_next_addr);
            end
        end
    endtask

    task advance_clock;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        Branch = 1'b0;
        BranchTaken = 1'b0;
        Jump = 1'b0;
        branch_imm = 32'd0;
        jump_imm = 32'd0;
        errors = 0;

        // 1. Synchronous reset: PC becomes zero.
        advance_clock();
        reset = 1'b0;
        if (pc !== 32'd0) begin
            $display("FAIL RESET: pc=%h expected=00000000", pc);
            errors = errors + 1;
        end
        else
            $display("PASS RESET: pc=00000000");

        // 2. Normal sequential execution: PC + 4.
        check_next(32'd4);
        advance_clock();
        if (pc !== 32'd4) begin
            $display("FAIL SEQUENTIAL: pc=%h expected=00000004", pc);
            errors = errors + 1;
        end

        // 3. Another sequential step: 4 + 4 = 8.
        check_next(32'd8);
        advance_clock();

        // 4. Taken BEQ-style branch: 8 + 20 = 28.
        Branch = 1'b1;
        BranchTaken = 1'b1;
        branch_imm = 32'd20;
        check_next(32'd28);
        advance_clock();
        Branch = 1'b0;
        BranchTaken = 1'b0;
        if (pc !== 32'd28) begin
            $display("FAIL TAKEN BRANCH: pc=%h expected=0000001c", pc);
            errors = errors + 1;
        end

        // 5. Not-taken branch: 28 + 4 = 32.
        Branch = 1'b1;
        BranchTaken = 1'b0;
        branch_imm = 32'd20;
        check_next(32'd32);
        advance_clock();
        Branch = 1'b0;

        // 6. Taken BNE-style branch: 32 + 12 = 44.
        Branch = 1'b1;
        BranchTaken = 1'b1;
        branch_imm = 32'd12;
        check_next(32'd44);
        advance_clock();
        Branch = 1'b0;
        BranchTaken = 1'b0;

        // 7. JAL: 44 + 40 = 84.
        Jump = 1'b1;
        jump_imm = 32'd40;
        check_next(32'd84);
        advance_clock();
        Jump = 1'b0;
        if (pc !== 32'd84) begin
            $display("FAIL JAL: pc=%h expected=00000054", pc);
            errors = errors + 1;
        end

        // 8. Defensive priority: Jump overrides a simultaneously asserted branch.
        Branch = 1'b1;
        BranchTaken = 1'b1;
        branch_imm = 32'd100;
        Jump = 1'b1;
        jump_imm = 32'd8;
        check_next(32'd92);
        advance_clock();
        Branch = 1'b0;
        BranchTaken = 1'b0;
        Jump = 1'b0;

        // 9. Negative branch offset: 92 - 12 = 80.
        Branch = 1'b1;
        BranchTaken = 1'b1;
        branch_imm = -32'sd12;
        check_next(32'd80);
        advance_clock();
        Branch = 1'b0;
        BranchTaken = 1'b0;

        if (errors == 0)
            $display("PC / NEXT-PC VERIFICATION PASSED: all tests passed.");
        else
            $display("PC / NEXT-PC VERIFICATION FAILED: %0d test(s) failed.", errors);

        $finish;
    end

endmodule
