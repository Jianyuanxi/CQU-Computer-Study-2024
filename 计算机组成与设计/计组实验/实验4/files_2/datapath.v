`timescale 1ns / 1ps
// datapath.v: 五级流水线数据通路
// beq在ID阶段提前判断（指导书方案）
// 严格按指导书Listing 5/6/7/8实现
module datapath(
    input  wire        clk, rst,
    input  wire [31:0] instrF,
    input  wire [31:0] readdata,
    input  wire        branchD, jumpD,
    input  wire        memtoregE, alusrcE, regdstE,
    input  wire [2:0]  alucontrolE,
    input  wire        regwriteW, memtoregW,
    input  wire [1:0]  forwardAE, forwardBE,
    input  wire        forwardAD, forwardBD,
    input  wire        stallF, stallD, flushE,
    output wire [5:0]  opD, functD,
    output wire [4:0]  rsD, rtD,
    output wire [4:0]  rsE, rtE,
    output wire [4:0]  writeregE, writeregM, writeregW,
    output wire        equalD,
    output wire [31:0] pcF,
    output wire [31:0] aluoutM,
    output wire [31:0] writedataM,
    output wire [31:0] resultW
);

    // ============================================================
    // IF 阶段
    // ============================================================
    wire [31:0] pcplus4F, pcnextF, pc_nobranch;
    wire [31:0] pcbranchD, pcjumpD;
    wire        pcsrcD;

    adder u_pcadd     (.a(pcF),        .b(32'd4),    .y(pcplus4F));
    mux2  u_branch_mx (.d0(pcplus4F),  .d1(pcbranchD), .sel(pcsrcD), .y(pc_nobranch));
    mux2  u_jump_mx   (.d0(pc_nobranch),.d1(pcjumpD), .sel(jumpD),   .y(pcnextF));
    flopenr #(32) u_pc(.clk(clk), .rst(rst), .en(~stallF), .d(pcnextF), .q(pcF));

    // ============================================================
    // IF/ID 寄存器
    // flushD：branch成立或jump时冲刷，但stall期间不冲刷
    // ============================================================
    wire [31:0] instrD, pcplus4D;
    wire        flushD = (pcsrcD | jumpD) & ~stallD;

    flopenrc #(32) u_instrD  (.clk(clk),.rst(rst),.en(~stallD),.clear(flushD),.d(instrF),  .q(instrD));
    flopenrc #(32) u_pcplus4D(.clk(clk),.rst(rst),.en(~stallD),.clear(flushD),.d(pcplus4F),.q(pcplus4D));

    // ============================================================
    // ID 阶段
    // ============================================================
    assign opD    = instrD[31:26];
    assign functD = instrD[5:0];
    assign rsD    = instrD[25:21];
    assign rtD    = instrD[20:16];
    wire [4:0]  rdD     = instrD[15:11];
    wire [31:0] signimmD;
    signext u_se (.a(instrD[15:0]), .y(signimmD));

    // 寄存器堆（写优先）
    wire [31:0] rd1D, rd2D;
    regfile u_rf (.clk(clk), .we3(regwriteW), .wa3(writeregW), .wd3(resultW),
                  .ra1(rsD), .ra2(rtD), .rd1(rd1D), .rd2(rd2D));

    // beq在ID提前判断（Listing 7前推）
    wire [31:0] equalA = forwardAD ? aluoutM : rd1D;
    wire [31:0] equalB = forwardBD ? aluoutM : rd2D;
    assign equalD = (equalA == equalB);
    assign pcsrcD = branchD & equalD;

    // 分支目标：pcplus4D + signimm<<2
    wire [31:0] branchoff;
    sl2   u_sl2 (.a(signimmD),  .y(branchoff));
    adder u_ba  (.a(pcplus4D),  .b(branchoff), .y(pcbranchD));

    // 跳转目标
    assign pcjumpD = {pcplus4D[31:28], instrD[25:0], 2'b00};

    // ============================================================
    // ID/EX 寄存器（floprc，flushE时清零）
    // ============================================================
    wire [31:0] rd1E, rd2E, signimmE;
    wire [4:0]  rdE;

    floprc #(32) u_rd1E (.clk(clk),.rst(rst),.clear(flushE),.d(rd1D),   .q(rd1E));
    floprc #(32) u_rd2E (.clk(clk),.rst(rst),.clear(flushE),.d(rd2D),   .q(rd2E));
    floprc #(32) u_simE (.clk(clk),.rst(rst),.clear(flushE),.d(signimmD),.q(signimmE));
    floprc #(5)  u_rsE  (.clk(clk),.rst(rst),.clear(flushE),.d(rsD),    .q(rsE));
    floprc #(5)  u_rtE  (.clk(clk),.rst(rst),.clear(flushE),.d(rtD),    .q(rtE));
    floprc #(5)  u_rdE  (.clk(clk),.rst(rst),.clear(flushE),.d(rdD),    .q(rdE));

    // ============================================================
    // EX 阶段
    // ============================================================
    mux2 #(5) u_regdst (.d0(rtE),.d1(rdE),.sel(regdstE),.y(writeregE));

    wire [31:0] srcaE, srcb2E, srcbE;
    mux3 u_fwdA  (.d0(rd1E),.d1(resultW),.d2(aluoutM),.sel(forwardAE),.y(srcaE));
    mux3 u_fwdB  (.d0(rd2E),.d1(resultW),.d2(aluoutM),.sel(forwardBE),.y(srcb2E));
    mux2 u_alusrc(.d0(srcb2E),.d1(signimmE),.sel(alusrcE),.y(srcbE));

    wire [31:0] aluoutE;
    wire        zeroE;
    alu u_alu (.a(srcaE),.b(srcbE),.alucontrol(alucontrolE),.result(aluoutE),.zero(zeroE));

    // ============================================================
    // EX/MEM 寄存器
    // ============================================================
    wire [31:0] aluoutM_w, writedataM_w;
    wire [4:0]  writeregM_w;

    flopr #(32) u_aluM (.clk(clk),.rst(rst),.d(aluoutE),  .q(aluoutM_w));
    flopr #(32) u_wdM  (.clk(clk),.rst(rst),.d(srcb2E),   .q(writedataM_w));
    flopr #(5)  u_wregM(.clk(clk),.rst(rst),.d(writeregE),.q(writeregM_w));

    assign aluoutM    = aluoutM_w;
    assign writedataM = writedataM_w;
    assign writeregM  = writeregM_w;

    // ============================================================
    // MEM/WB 寄存器
    // ============================================================
    wire [31:0] aluoutW, readdataW;
    wire [4:0]  writeregW_w;

    flopr #(32) u_aluW (.clk(clk),.rst(rst),.d(aluoutM_w), .q(aluoutW));
    flopr #(32) u_rdW  (.clk(clk),.rst(rst),.d(readdata),   .q(readdataW));
    flopr #(5)  u_wregW(.clk(clk),.rst(rst),.d(writeregM_w),.q(writeregW_w));

    assign writeregW = writeregW_w;

    // ============================================================
    // WB 阶段
    // ============================================================
    mux2 u_result(.d0(aluoutW),.d1(readdataW),.sel(memtoregW),.y(resultW));

endmodule
