`timescale 1ns / 1ps
// ============================================================
// aludec.v -- ALU译码器
// 输入：aluop（来自maindec）+ funct（指令低6位）
// 输出：alucontrol[2:0]
//   ADD = 3'b010, SUB = 3'b110, AND = 3'b000
//   OR  = 3'b001, SLT = 3'b111
// ============================================================
module aludec(
    input  wire [5:0] funct,
    input  wire [1:0] aluop,
    output reg  [2:0] alucontrol
);
    always @(*) begin
        case (aluop)
            2'b00: alucontrol = 3'b010; // lw/sw/addi -> ADD
            2'b01: alucontrol = 3'b110; // beq -> SUB
            default: begin              // R-type，看funct
                case (funct)
                    6'b100000: alucontrol = 3'b010; // add
                    6'b100010: alucontrol = 3'b110; // sub
                    6'b100100: alucontrol = 3'b000; // and
                    6'b100101: alucontrol = 3'b001; // or
                    6'b101010: alucontrol = 3'b111; // slt
                    default:   alucontrol = 3'b010; // 默认ADD
                endcase
            end
        endcase
    end
endmodule
