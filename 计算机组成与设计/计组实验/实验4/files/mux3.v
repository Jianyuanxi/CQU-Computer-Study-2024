`timescale 1ns / 1ps
// mux3 —— 三选一选择器（lab4新增，用于数据前推）
// sel=2'b00: d0(寄存器堆), 2'b01: d1(WB结果), 2'b10: d2(MEM的ALU输出)
module mux3 #(parameter WIDTH = 32)(
    input  [WIDTH-1:0] d0, d1, d2,
    input  [1:0]       sel,
    output [WIDTH-1:0] y
);
    assign y = sel[1] ? d2 : (sel[0] ? d1 : d0);
endmodule
