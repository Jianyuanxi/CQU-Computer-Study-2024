`timescale 1ns / 1ps
// display.v -- 8位数码管动态扫描（实际只用低4位显示16位数据）
// Nexys4 DDR: 共阳极, an[7:0]低电平选中
module display(
    input  wire        clk,        // 100MHz板载时钟
    input  wire        rst,
    input  wire [15:0] num,        // 16位待显示数据（4个16进制位）
    output reg  [7:0]  an,         // 数码管位选
    output wire [6:0]  seg         // 段选
);
    // 17位分频计数器：100MHz / 2^17 ≈ 763Hz 扫描速度
    reg  [16:0] cnt;
    always @(posedge clk, posedge rst) begin
        if (rst) cnt <= 17'b0;
        else     cnt <= cnt + 1'b1;
    end

    // 扫描状态由cnt高2位驱动（4位16进制 → 选其中一位）
    wire [1:0] sel = cnt[16:15];
    reg  [3:0] digit;

    always @(*) begin
        case (sel)
            2'b00: begin an = 8'b1111_1110; digit = num[3:0];   end
            2'b01: begin an = 8'b1111_1101; digit = num[7:4];   end
            2'b10: begin an = 8'b1111_1011; digit = num[11:8];  end
            2'b11: begin an = 8'b1111_0111; digit = num[15:12]; end
        endcase
    end

    seg7 u_seg7(.num(digit), .seg(seg));
endmodule
