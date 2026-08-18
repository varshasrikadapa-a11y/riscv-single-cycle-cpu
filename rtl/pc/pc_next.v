// 32-bit Program Counter and next-PC selection logic.
// PC is synchronous state. Candidate next addresses are combinational.
// Reset is synchronous and initializes PC to zero.

module pc_next (
    input  wire        clk,
    input  wire        reset,
    input  wire        Branch,
    input  wire        BranchTaken,
    input  wire        Jump,
    input  wire [31:0] branch_imm,
    input  wire [31:0] jump_imm,
    output reg  [31:0] pc,
    output wire [31:0] pc_next_addr
);

    wire [31:0] pc_plus_4      = pc + 32'd4;
    wire [31:0] branch_target  = pc + branch_imm;
    wire [31:0] jump_target    = pc + jump_imm;

    // Defensive priority: JAL > taken branch > sequential execution.
    assign pc_next_addr = Jump ? jump_target :
                          ((Branch && BranchTaken) ? branch_target : pc_plus_4);

    always @(posedge clk) begin
        if (reset)
            pc <= 32'b0;
        else
            pc <= pc_next_addr;
    end

endmodule
