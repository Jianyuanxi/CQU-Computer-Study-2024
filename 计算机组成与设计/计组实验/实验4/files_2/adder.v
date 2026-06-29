// adder: 32位加法器
module adder(
    input  wire [31:0] a, b,
    output wire [31:0] y
);
    assign y = a + b;
endmodule
