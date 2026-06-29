`timescale 1ns / 1ps
// signext —— 16位符号扩展到32位
module signext(
    input  [15:0] a,
    output [31:0] y
);
    assign y = {{16{a[15]}}, a};
endmodule
