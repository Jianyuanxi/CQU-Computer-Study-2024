`timescale 1ns / 1ps
// mux2 —— 直接复用实验三，2选1多路选择器
module mux2 #(parameter WIDTH = 32)(
    input  [WIDTH-1:0] d0,
    input  [WIDTH-1:0] d1,
    input              sel,
    output [WIDTH-1:0] y
);
    assign y = sel ? d1 : d0;
endmodule
