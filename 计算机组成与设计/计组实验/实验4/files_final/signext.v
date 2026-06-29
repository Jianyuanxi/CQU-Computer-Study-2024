`timescale 1ns / 1ps
// signext.v -- 16位符号扩展到32位
module signext(
    input  wire [15:0] a,
    output wire [31:0] y
);
    assign y = {{16{a[15]}}, a};
endmodule
