`timescale 1ns / 1ps
// Controller —— 顶层控制器，例化maindec和aludec
// 输入：op[5:0], funct[5:0]
// 输出：全部控制信号 + alucontrol[2:0]
module controller(
    input      [5:0] op,
    input      [5:0] funct,
    output           memtoreg,
    output           memwrite,
    output           branch,
    output           alusrc,
    output           regdst,
    output           regwrite,
    output           jump,
    output     [2:0] alucontrol
);
    wire [1:0] aluop;

    maindec u_maindec(
        .op       (op),
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
        .funct      (funct),
        .aluop      (aluop),
        .alucontrol (alucontrol)
    );
endmodule
