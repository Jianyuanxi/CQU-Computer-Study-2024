`timescale 1ns / 1ps
// display —— 8位七段数码管动态扫描显示模块
// 输入16位数字（显示4位十六进制），扫描频率约1kHz
// ans[7:0]：数码管位选（低电平有效），seg[6:0]：段选
module display(
    input         clk,   // 100MHz板载时钟
    input         rst,
    input  [15:0] num,   // 要显示的16位数（显示低4个十六进制位）
    output reg [7:0] ans, // 位选，低电平有效
    output [6:0]  seg    // 段选
);
    // 分频计数器：100MHz / 100000 = 1kHz 刷新
    reg [16:0] cnt;
    reg [1:0]  sel;   // 当前扫描到第几位（0~3）
    reg [3:0]  digit; // 当前显示的十六进制数字

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
            sel <= 0;
        end else if (cnt == 17'd99_999) begin
            cnt <= 0;
            sel <= sel + 1;
        end else begin
            cnt <= cnt + 1;
        end
    end

    // 选择当前要显示的数字
    always @(*) begin
        case (sel)
            2'd0: digit = num[3:0];
            2'd1: digit = num[7:4];
            2'd2: digit = num[11:8];
            2'd3: digit = num[15:12];
            default: digit = 4'h0;
        endcase
    end

    // 位选信号（低电平有效，每次只亮一个数码管）
    always @(*) begin
        case (sel)
            2'd0: ans = 8'b11111110;
            2'd1: ans = 8'b11111101;
            2'd2: ans = 8'b11111011;
            2'd3: ans = 8'b11110111;
            default: ans = 8'b11111111;
        endcase
    end

    // 例化seg7译码
    seg7 u_seg7(
        .data (digit),
        .seg  (seg)
    );
endmodule
