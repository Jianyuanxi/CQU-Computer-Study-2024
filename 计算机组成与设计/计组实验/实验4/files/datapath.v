`timescale 1ns / 1ps
// datapath.v -- 五级流水线数据通路
// IF/ID 寄存器：flopenrc（enable=~stallD，clear=flushD）
// flushD = pcsrcD | jumpD，保证跳转后冲刷 ID 级错误指令
module datapath(
    input  wire        clk, rst,
    input  wire [31:0] instrF,        // 来自 imem 的组合输出（IF 级）
    input  wire [31:0] readdata,      // 来自 dmem 的组合输出（MEM 级）
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

    // ================================================================
    //  IF
    // ================================================================
    wire [31:0] pcplus4F, pcnextF, pc_nobranch;
    wire [31:0] pcbranchD, pcjumpD;
    wire        pcsrcD;

    adder u_pc_add    (.a(pcF),         .b(32'd4),      .y(pcplus4F));
    mux2  u_branch_mx (.d0(pcplus4F),   .d1(pcbranchD), .sel(pcsrcD), .y(pc_nobranch));
    mux2  u_jump_mx   (.d0(pc_nobranch),.d1(pcjumpD),   .sel(jumpD),  .y(pcnextF));
    flopenr #(32) u_pc (.clk(clk),.rst(rst),.en(~stallF),.d(pcnextF),.q(pcF));

    // ================================================================
    //  IF/ID 寄存器
    //  flushD = pcsrcD | jumpD：跳转成立时冲刷 ID 级误取指令
    //  stallD：stall 时保持 instrD 不变
    // ================================================================
    wire        flushD = pcsrcD | jumpD;
    wire [31:0] instrD;
    wire [31:0] pcplus4D;
    flopenrc #(32) u_instrD (.clk(clk),.rst(rst),.en(~stallD),.clear(flushD),.d(instrF),   .q(instrD));
    flopenrc #(32) u_pc4D   (.clk(clk),.rst(rst),.en(~stallD),.clear(flushD),.d(pcplus4F),.q(pcplus4D));

    // ================================================================
    //  ID
    // ================================================================
    assign opD    = instrD[31:26];
    assign functD = instrD[5:0];
    assign rsD    = instrD[25:21];
    assign rtD    = instrD[20:16];
    wire [4:0] rdD = instrD[15:11];

    wire [31:0] signimmD;
    signext u_se (.a(instrD[15:0]), .y(signimmD));

    wire [31:0] rd1D, rd2D;
    regfile u_rf (
        .clk(clk), .we3(regwriteW), .wa3(writeregW), .wd3(resultW),
        .ra1(rsD), .ra2(rtD), .rd1(rd1D), .rd2(rd2D)
    );

    wire [31:0] equalaD = forwardAD ? aluoutM : rd1D;
    wire [31:0] equalbD = forwardBD ? aluoutM : rd2D;
    assign equalD = (equalaD == equalbD);
    assign pcsrcD = branchD & equalD;

    wire [31:0] branchoffD;
    sl2   u_sl2 (.a(signimmD),  .y(branchoffD));
    adder u_ba  (.a(pcplus4D),  .b(branchoffD), .y(pcbranchD));
    assign pcjumpD = {pcplus4D[31:28], instrD[25:0], 2'b00};

    // ================================================================
    //  ID/EX 寄存器（floprc：clear=flushE）
    // ================================================================
    wire [31:0] rd1E, rd2E, signimmE;
    wire [4:0]  rdE;
    floprc #(32) u_r1E (.clk(clk),.rst(rst),.clear(flushE),.d(rd1D),    .q(rd1E));
    floprc #(32) u_r2E (.clk(clk),.rst(rst),.clear(flushE),.d(rd2D),    .q(rd2E));
    floprc #(32) u_siE (.clk(clk),.rst(rst),.clear(flushE),.d(signimmD),.q(signimmE));
    floprc #(5)  u_rsE (.clk(clk),.rst(rst),.clear(flushE),.d(rsD),     .q(rsE));
    floprc #(5)  u_rtE (.clk(clk),.rst(rst),.clear(flushE),.d(rtD),     .q(rtE));
    floprc #(5)  u_rdE (.clk(clk),.rst(rst),.clear(flushE),.d(rdD),     .q(rdE));

    // ================================================================
    //  EX
    // ================================================================
    mux2 #(5) u_regdst (.d0(rtE),.d1(rdE),.sel(regdstE),.y(writeregE));

    wire [31:0] srcaE, srcb2E, srcbE;
    mux3 u_fwdA   (.d0(rd1E), .d1(resultW),.d2(aluoutM),.sel(forwardAE),.y(srcaE));
    mux3 u_fwdB   (.d0(rd2E), .d1(resultW),.d2(aluoutM),.sel(forwardBE),.y(srcb2E));
    mux2 u_alusrc (.d0(srcb2E),.d1(signimmE),.sel(alusrcE),.y(srcbE));

    wire [31:0] aluoutE;
    wire        zeroE;
    alu u_alu (.a(srcaE),.b(srcbE),.alucontrol(alucontrolE),.result(aluoutE),.zero(zeroE));

    // ================================================================
    //  EX/MEM 寄存器（flopr：无 clear，确保 sw/lw 不被意外清除）
    // ================================================================
    wire [31:0] writedataM_int;
    wire [4:0]  writeregM_int;
    flopr #(32) u_aluM  (.clk(clk),.rst(rst),.d(aluoutE),  .q(aluoutM));
    flopr #(32) u_wdM   (.clk(clk),.rst(rst),.d(srcb2E),   .q(writedataM_int));
    flopr #(5)  u_wregM (.clk(clk),.rst(rst),.d(writeregE),.q(writeregM_int));
    assign writedataM = writedataM_int;
    assign writeregM  = writeregM_int;

    // ================================================================
    //  MEM/WB 寄存器
    // ================================================================
    wire [31:0] aluoutW_int;
    wire [4:0]  writeregW_int;
    flopr #(32) u_aluW  (.clk(clk),.rst(rst),.d(aluoutM),        .q(aluoutW_int));
    flopr #(5)  u_wregW (.clk(clk),.rst(rst),.d(writeregM_int),  .q(writeregW_int));
    assign writeregW = writeregW_int;

    // ================================================================
    //  WB
    //  dmem 异步读：readdata 在 MEM 级地址稳定后立即有效，
    //  直接送 WB 级 mux，无需额外锁存。
    // ================================================================
    mux2 u_result (.d0(aluoutW_int),.d1(readdata),.sel(memtoregW),.y(resultW));

endmodule
