// flopr: 带异步复位的D触发器（实验4基础触发器）
// 用途：PC寄存器、EX/MEM、MEM/WB流水线寄存器
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
