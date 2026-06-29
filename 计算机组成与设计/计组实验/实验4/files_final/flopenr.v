`timescale 1ns / 1ps
// flopenr.v -- 带异步复位+使能的D触发器
// 用途：PC寄存器（stallF=1时en=0，PC保持不变）
// 优先级：rst > en
module flopenr #(parameter WIDTH = 8)(
    input  wire             clk, rst, en,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk, posedge rst) begin
        if      (rst) q <= {WIDTH{1'b0}};
        else if (en)  q <= d;
        // en=0时保持不变
    end
endmodule
