`timescale 1ns / 1ps
// maindec: 主译码器，根据opcode生成各路控制信号
module maindec(
    input  wire [5:0] op,
    output reg        memtoreg,  // 1=从内存写回寄存器
    output reg        memwrite,  // 1=写数据存储器
    output reg        branch,    // 1=beq指令
    output reg        alusrc,    // 1=ALU第二操作数用立即数
    output reg        regdst,    // 1=写目标寄存器用rd(R型)，0=用rt
    output reg        regwrite,  // 1=写寄存器堆
    output reg        jump,      // 1=j指令
    output reg [1:0]  aluop      // ALU操作类型，送aludec
);
    always @(*) begin
        case (op)
            6'b000000: begin // R型
                regwrite=1; regdst=1; alusrc=0;
                branch=0; memwrite=0; memtoreg=0;
                jump=0; aluop=2'b10;
            end
            6'b100011: begin // lw
                regwrite=1; regdst=0; alusrc=1;
                branch=0; memwrite=0; memtoreg=1;
                jump=0; aluop=2'b00;
            end
            6'b101011: begin // sw
                regwrite=0; regdst=0; alusrc=1;
                branch=0; memwrite=1; memtoreg=0;
                jump=0; aluop=2'b00;
            end
            6'b000100: begin // beq
                regwrite=0; regdst=0; alusrc=0;
                branch=1; memwrite=0; memtoreg=0;
                jump=0; aluop=2'b01;
            end
            6'b000101: begin // bne
                regwrite=0; regdst=0; alusrc=0;
                branch=1; memwrite=0; memtoreg=0;
                jump=0; aluop=2'b01;
            end
            6'b001000: begin // addi
                regwrite=1; regdst=0; alusrc=1;
                branch=0; memwrite=0; memtoreg=0;
                jump=0; aluop=2'b00;
            end
            6'b000010: begin // j
                regwrite=0; regdst=0; alusrc=0;
                branch=0; memwrite=0; memtoreg=0;
                jump=1; aluop=2'b00;
            end
            default: begin
                regwrite=0; regdst=0; alusrc=0;
                branch=0; memwrite=0; memtoreg=0;
                jump=0; aluop=2'b00;
            end
        endcase
    end
endmodule
