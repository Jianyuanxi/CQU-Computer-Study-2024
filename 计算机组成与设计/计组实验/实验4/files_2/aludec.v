`timescale 1ns / 1ps
// aludec: ALU操作译码，根据aluop和funct生成alucontrol
module aludec(
    input  wire [5:0] funct,
    input  wire [1:0] aluop,
    output reg  [2:0] alucontrol
);
    always @(*) begin
        case (aluop)
            2'b00: alucontrol = 3'b010; // lw/sw/addi: ADD
            2'b01: alucontrol = 3'b110; // beq: SUB（用于比较是否相等）
            2'b10: begin                // R型指令，看funct字段
                case (funct)
                    6'b100000: alucontrol = 3'b010; // add
                    6'b100010: alucontrol = 3'b110; // sub
                    6'b100100: alucontrol = 3'b000; // and
                    6'b100101: alucontrol = 3'b001; // or
                    6'b101010: alucontrol = 3'b111; // slt
                    default:   alucontrol = 3'b010;
                endcase
            end
            default: alucontrol = 3'b010;
        endcase
    end
endmodule
