`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/15 16:51:39
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input clk,reset,
    input [7:0] num1,
    input [2:0] op,
    output [6:0] seg,
    output [7:0] ans
    );

    wire [31:0] s;

    alu alu(
    .num1(num1),
    .op(op),
    .result(s) 
    );

    display display(
    .clk(clk),
    .reset(reset),
    .s(s),
    .seg(seg),
    .ans(ans)
    );
endmodule
