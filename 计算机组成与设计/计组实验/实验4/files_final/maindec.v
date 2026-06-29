`timescale 1ns / 1ps
// ============================================================
// maindec.v -- 主译码器
// 支持指令：R型(000000)、lw(100011)、sw(101011)、beq(000100)、
//          addi(001000)、j(000010)
// 输出9位控制信号：regwrite, regdst, alusrc, branch, memwrite,
//                memtoreg, jump, aluop[1:0]
// ============================================================
module maindec(
    input  wire [5:0] op,
    output wire       regwrite,
    output wire       regdst,
    output wire       alusrc,
    output wire       branch,
    output wire       memwrite,
    output wire       memtoreg,
    output wire       jump,
    output wire [1:0] aluop
);
    reg [8:0] controls;

    assign {regwrite, regdst, alusrc, branch, memwrite,
            memtoreg, jump, aluop} = controls;

    always @(*) begin
        case (op)
            6'b000000: controls = 9'b110000010; // R-type
            6'b100011: controls = 9'b101001000; // lw
            6'b101011: controls = 9'b001010000; // sw
            6'b000100: controls = 9'b000100001; // beq
            6'b001000: controls = 9'b101000000; // addi
            6'b000010: controls = 9'b000000100; // j
            default:   controls = 9'b000000000; // illegal -> nop
        endcase
    end
endmodule
