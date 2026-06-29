`timescale 1ns / 1ps
// flopr.v -- 带异步复位的D触发器
module flopr #(parameter WIDTH = 8)(
    input  wire             clk, rst,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk, posedge rst) begin
        if (rst) q <= {WIDTH{1'b0}};
        else     q <= d;
    end
endmodule
