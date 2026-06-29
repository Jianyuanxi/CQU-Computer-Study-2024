// flopenrc: 带异步复位+使能+同步清零的D触发器
// 用途：IF/ID流水线寄存器
// 优先级：rst(异步) > clear(同步清零) > en(使能采样)
// clear优先于en：分支/跳转成立时冲刷优先于stall保持
module flopenrc #(parameter WIDTH = 8)(
    input  wire             clk, rst, en, clear,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk, posedge rst) begin
        if      (rst)   q <= {WIDTH{1'b0}};
        else if (clear) q <= {WIDTH{1'b0}};
        else if (en)    q <= d;
        // en=0且无clear：保持不变（隐含else，q<=q）
    end
endmodule
