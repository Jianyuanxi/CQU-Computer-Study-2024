`timescale 1ns / 1ps
// sl2 —— 左移2位（用于branch地址计算）
module sl2(
    input  [31:0] a,
    output [31:0] y
);
    assign y = {a[29:0], 2'b00};
endmodule
