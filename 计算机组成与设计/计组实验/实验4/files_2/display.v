`timescale 1ns / 1ps
// display: 8位七段数码管动态扫描显示
// 输入16位数值，显示4位十六进制，扫描频率约1kHz（100MHz时钟）
module display(
    input  wire        clk,   // 100 MHz（板载，不降频）
    input  wire        rst,
    input  wire [15:0] num,
    output reg  [7:0]  ans,   // 位选（低有效，共8位，只用低4位）
    output wire [6:0]  seg
);
    reg [16:0] cnt;
    reg [1:0]  sel;
    reg [3:0]  digit;

    // 扫描计数：100MHz / 100_000 = 1kHz刷新
    always @(posedge clk or posedge rst) begin
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

    // 选择当前显示的十六进制位
    always @(*) begin
        case (sel)
            2'd0: digit = num[3:0];
            2'd1: digit = num[7:4];
            2'd2: digit = num[11:8];
            2'd3: digit = num[15:12];
            default: digit = 4'h0;
        endcase
    end

    // 位选信号（低有效，依次点亮最低4个数码管）
    always @(*) begin
        case (sel)
            2'd0: ans = 8'b11111110;
            2'd1: ans = 8'b11111101;
            2'd2: ans = 8'b11111011;
            2'd3: ans = 8'b11110111;
            default: ans = 8'b11111111;
        endcase
    end

    seg7 u_seg7 (.data(digit), .seg(seg));
endmodule
