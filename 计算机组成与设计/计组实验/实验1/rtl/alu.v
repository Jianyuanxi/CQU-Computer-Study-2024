`timescale 1ns / 1ps
// ALU 模块
// 支持操作：000=A+B, 001=A-B, 010=A AND B, 011=A OR B, 100=NOT A, 101=SLT

module alu(
    input  wire [31:0] num1,
    input  wire [31:0] num2,
    input  wire [2:0]  op,
    output wire        zero,
    output wire [31:0] result
);
    assign result = (op == 3'b000) ? num1 + num2 :
                    (op == 3'b001) ? num1 - num2 :
                    (op == 3'b010) ? num1 & num2 :
                    (op == 3'b011) ? num1 | num2 :
                    (op == 3'b100) ? ~num1 :
                    (op == 3'b101) ? ($signed(num1) < $signed(num2) ? 32'd1 : 32'd0) :
                    32'h00000000;

    assign zero = (result == 32'h0) ? 1'b1 : 1'b0;

endmodule
