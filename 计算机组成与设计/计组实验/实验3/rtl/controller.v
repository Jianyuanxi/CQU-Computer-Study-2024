`timescale 1ns / 1ps
// Controller -- decodes 32-bit instruction, produces all control signals
// memwrite is 1-bit here; the 4-bit WEA expansion for Block RAM lives in top/board_top
module controller(
    input  [31:0] inst,
    output        memtoreg,
    output        memwrite,   // 1-bit: 1=write data memory
    output        branch,
    output        alusrc,
    output        regdst,
    output        regwrite,
    output        jump,
    output [2:0]  alucontrol
);
    wire [1:0] aluop;

    maindec u_maindec(
        .op       (inst[31:26]),
        .memtoreg (memtoreg),
        .memwrite (memwrite),
        .branch   (branch),
        .alusrc   (alusrc),
        .regdst   (regdst),
        .regwrite (regwrite),
        .jump     (jump),
        .aluop    (aluop)
    );

    aludec u_aludec(
        .funct      (inst[5:0]),
        .aluop      (aluop),
        .alucontrol (alucontrol)
    );
endmodule
