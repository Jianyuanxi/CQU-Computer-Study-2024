`timescale 1ns / 1ps
// regfile: 32个32位通用寄存器
// $0 硬连线为0，写$0无效
// 写优先（write-through）：同一周期写和读同一寄存器，读出新值
// 这样可以减少一类WB→ID的前推需求（但hazard仍保留WB前推做兜底）
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

    // 组合读 + $0 = 0 + 写优先转发
    assign rd1 = (ra1 == 5'b0)        ? 32'b0 :
                 (we3 && wa3 == ra1)   ? wd3   :
                                         rf[ra1];
    assign rd2 = (ra2 == 5'b0)        ? 32'b0 :
                 (we3 && wa3 == ra2)   ? wd3   :
                                         rf[ra2];
endmodule
