`timescale 1ns / 1ps
// ALU 仿真文件
// B 端口固定为 32'h00000001，A 端口按报告表格输入
// 时钟周期 10ns，每个时钟周期换一次 op，验证全部 6 种运算

module alu_sim();

    reg  [31:0] num1;
    reg  [31:0] num2;
    reg  [2:0]  op;
    wire [31:0] result;
    wire        zero;

    // 实例化 ALU（组合逻辑，无时钟）
    alu uut(
        .num1(num1),
        .num2(num2),
        .op(op),
        .result(result),
        .zero(zero)
    );

    initial begin
        // B 端口固定为 32'h00000001
        num2 = 32'h00000001;

        // --- 000: A + B (Unsigned)  期望: 2+1=3 ---
        num1 = 32'h00000002;
        op   = 3'b000;
        #10;
        $display("A+B:    num1=%h, num2=%h, result=%h (expect 00000003)", num1, num2, result);

        // --- 001: A - B  期望: 0xFF - 1 = 0xFE ---
        num1 = 32'h000000FF;
        op   = 3'b001;
        #10;
        $display("A-B:    num1=%h, num2=%h, result=%h (expect 000000fe)", num1, num2, result);

        // --- 010: A AND B  期望: 0xFE & 0x01 = 0x00 ---
        num1 = 32'h000000FE;
        op   = 3'b010;
        #10;
        $display("A AND B: num1=%h, num2=%h, result=%h (expect 00000000)", num1, num2, result);

        // --- 011: A OR B  期望: 0xAA | 0x01 = 0xAB ---
        num1 = 32'h000000AA;
        op   = 3'b011;
        #10;
        $display("A OR B: num1=%h, num2=%h, result=%h (expect 000000ab)", num1, num2, result);

        // --- 100: NOT A  期望: ~0x000000F0 = 0xFFFFFF0F ---
        num1 = 32'h000000F0;
        op   = 3'b100;
        #10;
        $display("NOT A:  num1=%h, result=%h (expect ffffff0f)", num1, result);

        // --- 101: SLT  num1=0 < num2=1，期望 result=1 ---
        num1 = 32'h00000000;
        op   = 3'b101;
        #10;
        $display("SLT:    num1=%h, num2=%h, result=%h (expect 00000001)", num1, num2, result);

        #10;
        $finish;
    end

endmodule
