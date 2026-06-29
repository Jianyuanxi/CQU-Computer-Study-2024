`timescale 1ns / 1ps
// mux3.v -- 参数化三选一MUX
// sel编码：2'b00 → d0（来自寄存器堆，无前推）
//          2'b01 → d1（来自WB阶段前推）
//          2'b10 → d2（来自MEM阶段前推）
module mux3 #(parameter WIDTH = 32)(
    input  wire [WIDTH-1:0] d0,
    input  wire [WIDTH-1:0] d1,
    input  wire [WIDTH-1:0] d2,
    input  wire [1:0]       sel,
    output reg  [WIDTH-1:0] y
);
    always @(*) begin
        case (sel)
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            default: y = d0;
        endcase
    end
endmodule
