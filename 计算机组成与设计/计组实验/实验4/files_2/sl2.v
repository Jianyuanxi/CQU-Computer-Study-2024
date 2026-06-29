// sl2: 左移2位（用于branch跳转地址计算）
module sl2(
    input  wire [31:0] a,
    output wire [31:0] y
);
    assign y = {a[29:0], 2'b00};
endmodule
