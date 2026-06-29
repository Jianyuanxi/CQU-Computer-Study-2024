`timescale 1ns / 1ps
// ALU Decoder —— 根据aluop和funct生成alucontrol[2:0]
// 译码表参照指导书表3
module aludec(
    input      [5:0] funct,
    input      [1:0] aluop,
    output reg [2:0] alucontrol
);
    always @(*) begin
        case (aluop)
            2'b00: alucontrol = 3'b010; // lw/sw/addi: Add
            2'b01: alucontrol = 3'b110; // beq: Subtract
            2'b10: begin                // R-type: 由funct决定
                case (funct)
                    6'b100000: alucontrol = 3'b010; // add
                    6'b100010: alucontrol = 3'b110; // subtract
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
