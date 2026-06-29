`timescale 1ns / 1ps
// PC模块 —— D触发器结构，存储当前PC值
// 输入：clk, rst, pc_next（下一条指令地址）
// 输出：pc（当前指令地址），inst_ce（指令存储器使能）
module pc(
    input         clk,
    input         rst,
    input  [31:0] pc_next,
    output reg [31:0] pc,
    output        inst_ce
);
    // inst_ce 恒为高，只要不复位就使能指令存储器
    assign inst_ce = ~rst;

    always @(posedge clk) begin
        if (rst)
            pc <= 32'h00000000;
        else
            pc <= pc_next;
    end
endmodule
