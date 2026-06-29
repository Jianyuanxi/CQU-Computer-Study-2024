`timescale 1ns / 1ps
// regfile.v -- 32个32位寄存器
// 写端：下降沿写（同步），we3使能
// 读端：组合读（异步），$0永远为0
// 下降沿写解决"WB-ID读后写一致性"：下一条指令ID阶段（上升沿）可读到新值
module regfile(
    input  wire        clk,
    input  wire        we3,
    input  wire [4:0]  ra1, ra2, wa3,
    input  wire [31:0] wd3,
    output wire [31:0] rd1, rd2
);
    reg [31:0] rf [0:31];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) rf[i] = 32'b0;
    end

    // 下降沿写
    always @(negedge clk) begin
        if (we3 && (wa3 != 5'b0))
            rf[wa3] <= wd3;
    end

    assign rd1 = (ra1 == 5'b0) ? 32'b0 : rf[ra1];
    assign rd2 = (ra2 == 5'b0) ? 32'b0 : rf[ra2];
endmodule
