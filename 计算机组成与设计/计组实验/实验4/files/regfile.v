`timescale 1ns / 1ps
// regfile.v —— 寄存器堆（写优先：write-before-read）
// 同一拍 WB 写、ID 读同一寄存器时，组合读直接返回写入值，
// 避免流水线中 N 和 N+3 条指令访问同一寄存器时读到 X。
module regfile(
    input  wire        clk,
    input  wire        we3,
    input  wire [4:0]  ra1, ra2, wa3,
    input  wire [31:0] wd3,
    output wire [31:0] rd1, rd2
);
    reg [31:0] rf [31:0];

    // 同步写
    always @(posedge clk) begin
        if (we3) rf[wa3] <= wd3;
    end

    // 组合读 + 写优先转发（write-before-read）
    // 当 WB 写地址 == 读地址 且 we3=1 时，直接输出 wd3，
    // 避免读到非阻塞赋值尚未生效的旧值
    assign rd1 = (ra1 == 5'b0)              ? 32'b0 :
                 (we3 && wa3 == ra1)         ? wd3   :
                                               rf[ra1];

    assign rd2 = (ra2 == 5'b0)              ? 32'b0 :
                 (we3 && wa3 == ra2)         ? wd3   :
                                               rf[ra2];
endmodule
