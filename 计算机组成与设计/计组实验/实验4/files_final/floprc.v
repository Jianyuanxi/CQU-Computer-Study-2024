`timescale 1ns / 1ps
// floprc.v -- 带异步复位+同步清零的D触发器
// 用途：ID/EX流水线寄存器（flushE=1时插入气泡）
// 优先级：rst > clear
module floprc #(parameter WIDTH = 8)(
    input  wire             clk, rst, clear,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk, posedge rst) begin
        if      (rst)   q <= {WIDTH{1'b0}};
        else if (clear) q <= {WIDTH{1'b0}};
        else            q <= d;
    end
endmodule
