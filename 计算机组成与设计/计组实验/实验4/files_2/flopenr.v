// flopenr: 带异步复位+使能的D触发器
// 用途：PC寄存器（stallF时保持PC不变）
module flopenr #(parameter WIDTH = 8)(
    input  wire             clk, rst, en,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk, posedge rst) begin
        if (rst)     q <= {WIDTH{1'b0}};
        else if (en) q <= d;
    end
endmodule
