// mux3: 三选一多路选择器
// sel编码（与hazard模块forwardAE/forwardBE保持一致）：
//   2'b00 -> d0  寄存器堆原始值（无前推）
//   2'b01 -> d1  WB阶段 resultW（写回阶段前推）
//   2'b10 -> d2  MEM阶段 aluoutM（访存阶段前推，优先级更高）
module mux3 #(parameter WIDTH = 32)(
    input  wire [WIDTH-1:0] d0, d1, d2,
    input  wire [1:0]       sel,
    output reg  [WIDTH-1:0] y
);
    always @(*) begin
        case (sel)
            2'b00:   y = d0;
            2'b01:   y = d1;
            2'b10:   y = d2;
            default: y = d0;
        endcase
    end
endmodule
