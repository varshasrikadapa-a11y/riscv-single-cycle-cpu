module basys3_top (
    input  wire       clk,
    input  wire       btnC,
    input  wire [0:0] sw,
    output wire [7:0] led
);

    wire [31:0] imem_addr, imem_rdata;
    wire [31:0] dmem_addr, dmem_wdata, dmem_rdata;
    wire dmem_read, dmem_write;
    wire [3:0] dmem_byte_en;
    wire [31:0] debug_pc, debug_alu_result, display_value;

    // Behavioral memories: asynchronous reads, synchronous data writes.
    reg [31:0] imem [0:63];
    reg [31:0] dmem [0:255];
    integer i;

    initial begin
        for (i = 0; i < 64; i = i + 1)
            imem[i] = 32'h00000013; // ADDI x0,x0,0 (NOP)

        imem[0]  = 32'h00A00093; // ADDI x1,x0,10
        imem[1]  = 32'h01400113; // ADDI x2,x0,20
        imem[2]  = 32'h002081B3; // ADD x3,x1,x2
        imem[3]  = 32'h00302023; // SW x3,0(x0)
        imem[4]  = 32'h00002203; // LW x4,0(x0)
        imem[5]  = 32'h00320463; // BEQ x4,x3,+8
        imem[6]  = 32'h00100293; // skipped ADDI x5,x0,1
        imem[7]  = 32'h00021463; // BNE x4,x0,+8
        imem[8]  = 32'h00100313; // skipped ADDI x6,x0,1
        imem[9]  = 32'h00321463; // BNE x4,x3,+8 (not taken)
        imem[10] = 32'h00700393; // ADDI x7,x0,7
        imem[11] = 32'h0080046F; // JAL x8,+8
        imem[12] = 32'h00100493; // skipped ADDI x9,x0,1
        imem[13] = 32'h02A00513; // ADDI x10,x0,42
        imem[14] = 32'h01400593; // ADDI x11,x0,20
        imem[15] = 32'h00500613; // ADDI x12,x0,5
        imem[16] = 32'h40C586B3; // SUB x13,x11,x12
        imem[17] = 32'h00C5F733; // AND x14,x11,x12
        imem[18] = 32'h00C5E7B3; // OR x15,x11,x12
        imem[19] = 32'h00C5C833; // XOR x16,x11,x12
        imem[20] = 32'h00C5A8B3; // SLT x17,x11,x12
        imem[21] = 32'hFFF00913; // ADDI x18,x0,-1
        imem[22] = 32'h00F5F993; // ANDI x19,x11,15
        imem[23] = 32'h00F5EA13; // ORI x20,x11,15
        imem[24] = 32'h00F5CA93; // XORI x21,x11,15
        imem[25] = 32'h000A2B13; // SLTI x22,x18,0
        imem[26] = 32'h06300013; // ADDI x0,x0,99 (x0 remains zero)
        imem[27] = 32'hFFF00B93; // ADDI x23,x0,-1
        imem[28] = 32'h00000C13; // ADDI x24,x0,0
        imem[29] = 32'h018BACB3; // SLT x25,x23,x24
        imem[30] = 32'h01762D33; // SLT x26,x24,x23
        imem[31] = 32'h06400D93; // ADDI x27,x0,100
        imem[32] = 32'h01B02223; // SW x27,4(x0)
        imem[33] = 32'h0C800E13; // ADDI x28,x0,200
        imem[34] = 32'h01C02423; // SW x28,8(x0)
        imem[35] = 32'h00402E83; // LW x29,4(x0)
        imem[36] = 32'h00802F03; // LW x30,8(x0)
        imem[37] = 32'h0000006F; // JAL x0,0: park at byte address 148
    end

    initial begin
        for (i = 0; i < 256; i = i + 1)
            dmem[i] = 32'b0;
    end

    assign imem_rdata = imem[imem_addr[7:2]];
    assign dmem_rdata = dmem_read ? dmem[dmem_addr[9:2]] : 32'b0;

    always @(posedge clk) begin
        if (dmem_write && (dmem_byte_en == 4'b1111))
            dmem[dmem_addr[9:2]] <= dmem_wdata;
    end

    riscv_cpu cpu (
        .clk(clk), .reset(btnC),
        .imem_addr(imem_addr), .imem_rdata(imem_rdata),
        .dmem_addr(dmem_addr), .dmem_wdata(dmem_wdata),
        .dmem_rdata(dmem_rdata), .dmem_read(dmem_read),
        .dmem_write(dmem_write), .dmem_byte_en(dmem_byte_en),
        .debug_pc(debug_pc), .debug_alu_result(debug_alu_result)
    );

    // SW0=0 displays PC[7:0]; SW0=1 displays ALU result[7:0].
    assign display_value = sw[0] ? debug_alu_result : debug_pc;
    assign led = display_value[7:0];

endmodule
