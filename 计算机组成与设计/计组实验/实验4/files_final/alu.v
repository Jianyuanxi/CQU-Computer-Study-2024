`timescale 1ns / 1ps
// ============================================================
// alu.v -- 32位ALU
// 控制码编码（alucontrol[2:0]）：
//   3'b010 = ADD
//   3'b110 = SUB
//   3'b000 = AND
//   3'b001 = OR
//   3'b111 = SLT（小于则置1，有符号比较）
// 输出：result（32位结果），zero（结果是否为0）
// ============================================================
module alu(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  alucontrol,
    output reg  [31:0] result,
    output wire        zero
);

    wire [31:0] b_inv;
    wire [31:0] sum;
    wire        slt;

    // SUB实现：a + (~b) + 1
    assign b_inv = alucontrol[2] ? ~b : b;
    assign sum   = a + b_inv + alucontrol[2];

    // SLT：用减法结果的符号位判断
    // 注意溢出处理：当a和b异号时，符号位即结果
    // 当同号时，sum的符号位即结果（不会溢出）
    assign slt = (a[31] ^ b[31]) ? a[31] : sum[31];

    always @(*) begin
        case (alucontrol)
            3'b010: result = sum;            // ADD
            3'b110: result = sum;            // SUB
            3'b000: result = a & b;          // AND
            3'b001: result = a | b;          // OR
            3'b111: result = {31'b0, slt};   // SLT
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule
