`timescale 1ns / 1ps
// ALU —— 支持 and/or/add/sub/slt 运算
// alucontrol: 000=AND, 001=OR, 010=ADD, 110=SUB, 111=SLT
module alu(
    input  [31:0] a,
    input  [31:0] b,
    input  [2:0]  alucontrol,
    output reg [31:0] result,
    output        zero
);
    assign zero = (result == 32'b0);

    always @(*) begin
        case (alucontrol)
            3'b000: result = a & b;
            3'b001: result = a | b;
            3'b010: result = a + b;
            3'b110: result = a - b;
            3'b111: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            default: result = 32'b0;
        endcase
    end
endmodule
