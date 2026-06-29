// mux2: 二选一多路选择器
module mux2 #(parameter WIDTH = 32)(
    input  wire [WIDTH-1:0] d0, d1,
    input  wire             sel,
    output wire [WIDTH-1:0] y
);
    assign y = sel ? d1 : d0;
endmodule
