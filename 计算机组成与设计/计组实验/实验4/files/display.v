`timescale 1ns / 1ps
// display —— 8位七段数码管动态扫描（基于实验三，升级为32位输入/8位显示）
// 输入32位值，以8位十六进制形式显示
module display(
    input         clk,
    input         rst,
    input  [31:0] num,      // 32位待显示值
    output reg [7:0] ans,   // 位选（低有效，AN7-AN0）
    output [6:0]  seg
);
    reg [16:0] cnt;
    reg [2:0]  sel;         // 3位选择器，扫描8个数字
    reg [3:0]  digit;

    // 扫描分频（100MHz → ~763Hz扫描切换，每个数字约1.3ms）
    always @(posedge clk) begin
        if (rst) begin cnt <= 0; sel <= 0;
        end else if (cnt == 17'd99_999) begin cnt <= 0; sel <= sel + 1;
        end else cnt <= cnt + 1;
    end

    // 选择当前显示的4位十六进制
    always @(*) begin
        case (sel)
            3'd0: digit = num[3:0];
            3'd1: digit = num[7:4];
            3'd2: digit = num[11:8];
            3'd3: digit = num[15:12];
            3'd4: digit = num[19:16];
            3'd5: digit = num[23:20];
            3'd6: digit = num[27:24];
            3'd7: digit = num[31:28];
            default: digit = 4'h0;
        endcase
    end

    // 位选译码
    always @(*) begin
        case (sel)
            3'd0: ans = 8'b11111110;
            3'd1: ans = 8'b11111101;
            3'd2: ans = 8'b11111011;
            3'd3: ans = 8'b11110111;
            3'd4: ans = 8'b11101111;
            3'd5: ans = 8'b11011111;
            3'd6: ans = 8'b10111111;
            3'd7: ans = 8'b01111111;
            default: ans = 8'b11111111;
        endcase
    end

    seg7 u_seg7(.data(digit), .seg(seg));
endmodule
