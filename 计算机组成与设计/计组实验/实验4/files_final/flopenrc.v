`timescale 1ns / 1ps
// flopenrc.v -- 带异步复位+使能+同步清零的D触发器
// 用途：IF/ID流水线寄存器（stallD保持，flushD清零）
// 优先级：rst > clear > en
//   clear优先于en：分支/跳转成立时立即冲刷，stall保持只在无flush时生效
module flopenrc #(parameter WIDTH = 8)(
    input  wire             clk, rst, en, clear,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk, posedge rst) begin
        if      (rst)   q <= {WIDTH{1'b0}};
        else if (clear) q <= {WIDTH{1'b0}};
        else if (en)    q <= d;
        // en=0且无clear：保持
    end
endmodule
