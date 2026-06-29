`timescale 1ns / 1ps
// display —— 8位七段数码管动态扫描显示模块
// 输入16位数字（显示4位十六进制），扫描频率约1kHz
module display(
    input         clk,
    input         rst,
    input  [15:0] num,
    output reg [7:0] ans,
    output [6:0]  seg
);
    reg [16:0] cnt;
    reg [1:0]  sel;
    reg [3:0]  digit;

    always @(posedge clk) begin
        if (rst) begin cnt <= 0; sel <= 0;
        end else if (cnt == 17'd99_999) begin cnt <= 0; sel <= sel + 1;
        end else cnt <= cnt + 1;
    end

    always @(*) begin
        case (sel)
            2'd0: digit = num[3:0];
            2'd1: digit = num[7:4];
            2'd2: digit = num[11:8];
            2'd3: digit = num[15:12];
            default: digit = 4'h0;
        endcase
    end

    always @(*) begin
        case (sel)
            2'd0: ans = 8'b11111110;
            2'd1: ans = 8'b11111101;
            2'd2: ans = 8'b11111011;
            2'd3: ans = 8'b11110111;
            default: ans = 8'b11111111;
        endcase
    end

    seg7 u_seg7(.data(digit), .seg(seg));
endmodule
