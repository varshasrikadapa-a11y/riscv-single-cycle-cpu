// 32 x 32-bit RISC-V register file.
// Two combinational read ports and one synchronous write port.
// x0 is hard-wired to zero: reads return zero and writes are ignored.

module register_file (
    input  wire        clk,
    input  wire        reset,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] WriteData,
    input  wire        RegWrite,
    output wire [31:0] ReadData1,
    output wire [31:0] ReadData2
);

    reg [31:0] registers [0:31];
    integer i;

    // Synchronous reset and synchronous architectural writes.
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end
        else if (RegWrite && (rd != 5'd0)) begin
            registers[rd] <= WriteData;
        end
    end

    // Combinational reads. x0 always reads as zero.
    assign ReadData1 = (rs1 == 5'd0) ? 32'b0 : registers[rs1];
    assign ReadData2 = (rs2 == 5'd0) ? 32'b0 : registers[rs2];

endmodule
