`timescale 1ns / 1ps
// alu: 支持 and/or/add/sub/slt 五种运算
// alucontrol编码: 000=AND, 001=OR, 010=ADD, 110=SUB, 111=SLT
module alu(
    input  wire [31:0] a, b,
    input  wire [2:0]  alucontrol,
    output reg  [31:0] result,
    output wire        zero
);
    assign zero = (result == 32'b0);

    always @(*) begin
        case (alucontrol)
            3'b000:  result = a & b;
            3'b001:  result = a | b;
            3'b010:  result = a + b;
            3'b110:  result = a - b;
            3'b111:  result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            default: result = 32'b0;
        endcase
    end
endmodule
