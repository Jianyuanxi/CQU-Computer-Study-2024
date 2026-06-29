`timescale 1ns / 1ps
// ============================================================
// controller.v -- 流水线控制器
// 译码（ID）阶段生成所有控制信号，逐级流水到所需阶段
//
// 信号传递路径：
//   ID阶段产生：jumpD, branchD（branch在EX用，但提前进ID/EX）
//              regdstD, alusrcD, alucontrolD（EX阶段用）
//              memwriteD, memtoregD（MEM阶段用）
//              regwriteD（WB阶段用）
//
//   ID→EX (floprc, flushE清零)：
//       regwriteE, memtoregE, memwriteE, branchE,
//       alucontrolE, alusrcE, regdstE
//
//   EX→MEM (flopr)：regwriteM, memtoregM, memwriteM
//   MEM→WB (flopr)：regwriteW, memtoregW
//
// ⚠ 设计要点：beq判断在EX阶段（用ALU的zero信号），
//   因此branchE需要传到EX。pcsrcE = branchE & zeroE。
//   flushE 由 mips.v 合成 = flushE_hazard | flushD
// ============================================================
module controller(
    input  wire        clk, rst,
    input  wire [5:0]  opD, functD,
    input  wire        flushE,
    // ID阶段输出（直接用，不经流水线寄存器）
    output wire        jumpD,
    // EX阶段控制信号（已通过ID/EX寄存器）
    output wire        branchE,
    output wire        regdstE, alusrcE,
    output wire [2:0]  alucontrolE,
    output wire        memtoregE,    // 给hazard用（检测load-use）
    // MEM阶段控制信号
    output wire        memwriteM, memtoregM, regwriteM,
    // WB阶段控制信号
    output wire        memtoregW, regwriteW
);
    // ============= ID阶段：译码 =============
    wire       regwriteD, regdstD, alusrcD;
    wire       branchD, memwriteD, memtoregD;
    wire [1:0] aluopD;
    wire [2:0] alucontrolD;

    maindec u_md(
        .op(opD),
        .regwrite(regwriteD), .regdst(regdstD), .alusrc(alusrcD),
        .branch(branchD), .memwrite(memwriteD),
        .memtoreg(memtoregD), .jump(jumpD),
        .aluop(aluopD)
    );

    aludec u_ad(
        .funct(functD), .aluop(aluopD),
        .alucontrol(alucontrolD)
    );

    // ============= ID→EX 寄存器（floprc）=============
    // 打包9位：{regwrite, memtoreg, memwrite, branch, alusrc, regdst, alucontrol[2:0]}
    // memtoregE 已是 output 端口，不要再 wire 声明
    wire regwriteE, memwriteE;
    floprc #(9) u_ctrlE(
        .clk(clk), .rst(rst), .clear(flushE),
        .d({regwriteD, memtoregD, memwriteD, branchD,
            alusrcD, regdstD, alucontrolD}),
        .q({regwriteE, memtoregE, memwriteE, branchE,
            alusrcE, regdstE, alucontrolE})
    );

    // ============= EX→MEM 寄存器（flopr）=============
    flopr #(3) u_ctrlM(
        .clk(clk), .rst(rst),
        .d({regwriteE, memtoregE, memwriteE}),
        .q({regwriteM, memtoregM, memwriteM})
    );

    // ============= MEM→WB 寄存器（flopr）=============
    flopr #(2) u_ctrlW(
        .clk(clk), .rst(rst),
        .d({regwriteM, memtoregM}),
        .q({regwriteW, memtoregW})
    );

endmodule
