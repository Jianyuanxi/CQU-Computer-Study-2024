`timescale 1ns / 1ps
// adder.v -- 32位组合加法器（用于PC+4、分支目标计算）
module adder(
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] y
);
    assign y = a + b;
endmodule
