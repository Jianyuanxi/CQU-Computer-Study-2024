// controller: 流水线控制器
// 译码阶段产生所有控制信号，通过流水线寄存器传递到各阶段
// D→E: floprc（flushE时清零，插入气泡）
// E→M: flopr（正常传递）
// M→W: flopr（正常传递）
module controller(
    input  wire       clk, rst,
    input  wire [5:0] opD, functD,   // 译码阶段指令字段
    input  wire       flushE,        // 来自hazard，冲刷EX级
    // 译码阶段输出（给datapath的分支/跳转判断，给hazard的branchD）
    output wire       branchD, jumpD,
    // EX阶段控制信号
    output wire       memtoregE, memwriteE,
    output wire       alusrcE, regdstE, regwriteE,
    output wire [2:0] alucontrolE,
    // MEM阶段控制信号
    output wire       memtoregM, memwriteM, regwriteM,
    // WB阶段控制信号
    output wire       memtoregW, regwriteW
);

    // ---- 译码阶段：maindec + aludec ----
    wire       memtoregD, memwriteD, alusrcD, regdstD, regwriteD;
    wire [1:0] aluopD;
    wire [2:0] alucontrolD;

    maindec md (
        .op(opD),
        .memtoreg(memtoregD), .memwrite(memwriteD),
        .branch(branchD),     .alusrc(alusrcD),
        .regdst(regdstD),     .regwrite(regwriteD),
        .jump(jumpD),         .aluop(aluopD)
    );

    aludec ad (
        .funct(functD), .aluop(aluopD),
        .alucontrol(alucontrolD)
    );

    // ---- D→E 流水线寄存器（floprc，flushE时全部清零）----
    // 打包8个控制信号，减少寄存器数量
    // {regwriteD, memtoregD, memwriteD, alusrcD, regdstD, alucontrolD[2:0]}
    wire [7:0] ctrlD = {regwriteD, memtoregD, memwriteD,
                        alusrcD,   regdstD,   alucontrolD};
    wire [7:0] ctrlE;
    floprc #(8) u_DE_ctrl (
        .clk(clk), .rst(rst), .clear(flushE),
        .d(ctrlD), .q(ctrlE)
    );
    assign {regwriteE, memtoregE, memwriteE,
            alusrcE,   regdstE,   alucontrolE} = ctrlE;

    // ---- E→M 流水线寄存器（flopr）----
    wire [2:0] ctrlM;
    flopr #(3) u_EM_ctrl (
        .clk(clk), .rst(rst),
        .d({regwriteE, memtoregE, memwriteE}),
        .q(ctrlM)
    );
    assign {regwriteM, memtoregM, memwriteM} = ctrlM;

    // ---- M→W 流水线寄存器（flopr）----
    wire [1:0] ctrlW;
    flopr #(2) u_MW_ctrl (
        .clk(clk), .rst(rst),
        .d({regwriteM, memtoregM}),
        .q(ctrlW)
    );
    assign {regwriteW, memtoregW} = ctrlW;

endmodule
