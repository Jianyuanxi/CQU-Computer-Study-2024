// controller: 流水线控制器
// 在译码阶段产生控制信号，通过流水线寄存器传递到各阶段
module controller(
    input  wire       clk, rst,
    // 译码阶段输入
    input  wire [5:0] opD, functD,
    input  wire       flushE,          // 冒险：冲刷EX级（插入气泡）
    // 译码阶段输出（给数据通路和冒险模块用）
    output wire       branchD, jumpD,
    // EX阶段控制信号
    output wire       memtoregE, memwriteE,
    output wire       alusrcE,  regdstE, regwriteE,
    output wire [2:0] alucontrolE,
    // MEM阶段控制信号
    output wire       memtoregM, memwriteM, regwriteM,
    // WB阶段控制信号
    output wire       memtoregW, regwriteW
);
    // -------- 译码阶段信号 --------
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

    // -------- D→E 流水线寄存器（floprc：有清除，FlushE时插入气泡）--------
    // 打包：{regwrite, memtoreg, memwrite, alusrc, regdst, alucontrol[2:0]} = 8位
    wire [7:0] ctrlD = {regwriteD, memtoregD, memwriteD, alusrcD, regdstD, alucontrolD};
    wire [7:0] ctrlE_out;
    floprc #(8) DE_ctrl_reg (
        .clk(clk), .rst(rst), .clear(flushE),
        .d(ctrlD), .q(ctrlE_out)
    );
    assign {regwriteE, memtoregE, memwriteE, alusrcE, regdstE, alucontrolE} = ctrlE_out;

    // -------- E→M 流水线寄存器（flopr）--------
    wire [2:0] ctrlM_out;
    flopr #(3) EM_ctrl_reg (
        .clk(clk), .rst(rst),
        .d({regwriteE, memtoregE, memwriteE}),
        .q(ctrlM_out)
    );
    assign {regwriteM, memtoregM, memwriteM} = ctrlM_out;

    // -------- M→W 流水线寄存器（flopr）--------
    wire [1:0] ctrlW_out;
    flopr #(2) MW_ctrl_reg (
        .clk(clk), .rst(rst),
        .d({regwriteM, memtoregM}),
        .q(ctrlW_out)
    );
    assign {regwriteW, memtoregW} = ctrlW_out;

endmodule
