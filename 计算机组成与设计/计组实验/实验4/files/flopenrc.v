// flopenrc: 带同步复位+使能+清除的D触发器（指导书原版）
module flopenrc #(parameter WIDTH = 8)(
    input  wire             clk, rst, en, clear,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (rst)        q <= {WIDTH{1'b0}};
        else if (clear) q <= {WIDTH{1'b0}};
        else if (en)    q <= d;
    end
endmodule
