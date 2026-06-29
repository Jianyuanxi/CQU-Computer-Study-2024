`timescale 1ns / 1ps
// ============================================================
// datapath.v -- 五级流水线数据通路（干净版）
//
// 设计要点：
//   1) beq判断在EX阶段：pcsrcE = branchE & zeroE
//   2) flushD 由 datapath 内部根据 (pcsrcE | jumpD) 生成，向上输出
//      mips.v 合成 flushE_total = flushE_hazard | flushD 后回传给本模块的 flushE
//   3) 寄存器堆下降沿写：天然解决WB-ID读后写一致性
//   4) sw写入data_ram的数据 = srcb2E（前推后的rt值）
//
// 流水线寄存器分配：
//   PC      : flopenr  (en=~stallF)
//   IF/ID   : flopenrc (en=~stallD, clear=flushD)
//   ID/EX   : floprc   (clear=flushE_total)
//   EX/MEM  : flopr
//   MEM/WB  : flopr
// ============================================================
module datapath(
    input  wire        clk, rst,
    input  wire [31:0] instrF,
    input  wire [31:0] readdataM,
    // 控制信号
    input  wire        jumpD,
    input  wire        branchE,
    input  wire        regdstE, alusrcE,
    input  wire [2:0]  alucontrolE,
    input  wire        memtoregW, regwriteW,
    // 来自hazard（注意 flushE 是顶层合成的总版本）
    input  wire [1:0]  forwardAE, forwardBE,
    input  wire        stallF, stallD, flushE,
    // 输出给controller（指令字段）
    output wire [5:0]  opD, functD,
    // 输出给hazard
    output wire [4:0]  rsD, rtD,
    output wire [4:0]  rsE, rtE,
    output wire [4:0]  writeregE,
    output wire [4:0]  writeregM,
    output wire [4:0]  writeregW,
    // 输出给顶层
    output wire [31:0] pcF,
    output wire [31:0] aluoutM,
    output wire [31:0] writedataM,
    // 输出 flushD 给 mips 顶层合成 flushE_total
    output wire        flushD_out
);

    // -------- 内部连线 --------
    wire [31:0] pcnextF, pcplus4F, pc_seq_or_branch;
    wire [31:0] pcbranchE, pcjumpD;
    wire        pcsrcE, flushD;

    wire [31:0] instrD, pcplus4D;
    wire [4:0]  rdD;
    wire [31:0] rd1D, rd2D, signimmD;
    wire [31:0] resultW;

    wire [31:0] rd1E, rd2E, signimmE, pcplus4E;
    wire [4:0]  rdE;
    wire [31:0] srcaE, srcb2E, srcbE;
    wire [31:0] aluoutE;
    wire        zeroE;
    wire [31:0] signimmE_sl2;

    wire [31:0] aluoutW, readdataW;

    // ============================================================
    // IF 阶段
    // ============================================================
    flopenr #(32) u_pcreg(
        .clk(clk), .rst(rst), .en(~stallF),
        .d(pcnextF), .q(pcF)
    );

    adder u_pcplus4(.a(pcF), .b(32'd4), .y(pcplus4F));

    mux2 #(32) u_branch_mux(
        .d0(pcplus4F), .d1(pcbranchE),
        .sel(pcsrcE), .y(pc_seq_or_branch)
    );

    mux2 #(32) u_jump_mux(
        .d0(pc_seq_or_branch), .d1(pcjumpD),
        .sel(jumpD), .y(pcnextF)
    );

    // ============================================================
    // IF/ID 寄存器（flopenrc, en=~stallD, clear=flushD）
    // ============================================================
    assign flushD = pcsrcE | jumpD;
    assign flushD_out = flushD;

    flopenrc #(32) u_ifid_instr(
        .clk(clk), .rst(rst),
        .en(~stallD), .clear(flushD),
        .d(instrF), .q(instrD)
    );

    flopenrc #(32) u_ifid_pcp4(
        .clk(clk), .rst(rst),
        .en(~stallD), .clear(flushD),
        .d(pcplus4F), .q(pcplus4D)
    );

    // ============================================================
    // ID 阶段
    // ============================================================
    assign opD    = instrD[31:26];
    assign rsD    = instrD[25:21];
    assign rtD    = instrD[20:16];
    assign rdD    = instrD[15:11];
    assign functD = instrD[5:0];

    regfile u_rf(
        .clk(clk),
        .we3(regwriteW),
        .ra1(rsD), .ra2(rtD),
        .wa3(writeregW),
        .wd3(resultW),
        .rd1(rd1D), .rd2(rd2D)
    );

    signext u_se(.a(instrD[15:0]), .y(signimmD));

    // j指令目标：{pcplus4D高4位, instr[25:0], 2'b00}
    assign pcjumpD = {pcplus4D[31:28], instrD[25:0], 2'b00};

    // ============================================================
    // ID/EX 寄存器（floprc）
    // clear = flushE（顶层合成的flushE_total）
    // ============================================================
    floprc #(32) u_idex_rd1  (.clk(clk), .rst(rst), .clear(flushE), .d(rd1D),     .q(rd1E));
    floprc #(32) u_idex_rd2  (.clk(clk), .rst(rst), .clear(flushE), .d(rd2D),     .q(rd2E));
    floprc #(32) u_idex_simm (.clk(clk), .rst(rst), .clear(flushE), .d(signimmD), .q(signimmE));
    floprc #(32) u_idex_pcp4 (.clk(clk), .rst(rst), .clear(flushE), .d(pcplus4D), .q(pcplus4E));
    floprc #(5)  u_idex_rs   (.clk(clk), .rst(rst), .clear(flushE), .d(rsD),      .q(rsE));
    floprc #(5)  u_idex_rt   (.clk(clk), .rst(rst), .clear(flushE), .d(rtD),      .q(rtE));
    floprc #(5)  u_idex_rd   (.clk(clk), .rst(rst), .clear(flushE), .d(rdD),      .q(rdE));

    // ============================================================
    // EX 阶段
    // ============================================================
    // 三路前推MUX
    mux3 #(32) u_fwdA(
        .d0(rd1E), .d1(resultW), .d2(aluoutM),
        .sel(forwardAE), .y(srcaE)
    );

    mux3 #(32) u_fwdB(
        .d0(rd2E), .d1(resultW), .d2(aluoutM),
        .sel(forwardBE), .y(srcb2E)
    );

    // ALU源B（立即数 or 寄存器值）
    mux2 #(32) u_alusrc(
        .d0(srcb2E), .d1(signimmE),
        .sel(alusrcE), .y(srcbE)
    );

    alu u_alu(
        .a(srcaE), .b(srcbE),
        .alucontrol(alucontrolE),
        .result(aluoutE), .zero(zeroE)
    );

    // 分支判断（用ALU输出的zero信号）
    assign pcsrcE = branchE & zeroE;

    // 写目标寄存器
    mux2 #(5) u_wreg(
        .d0(rtE), .d1(rdE),
        .sel(regdstE), .y(writeregE)
    );

    // 分支目标地址
    sl2 u_sl2(.a(signimmE), .y(signimmE_sl2));
    adder u_brnch(
        .a(pcplus4E), .b(signimmE_sl2),
        .y(pcbranchE)
    );

    // ============================================================
    // EX/MEM 寄存器
    // ============================================================
    flopr #(32) u_exmem_alu(.clk(clk), .rst(rst), .d(aluoutE),   .q(aluoutM));
    flopr #(32) u_exmem_wd (.clk(clk), .rst(rst), .d(srcb2E),    .q(writedataM));
    flopr #(5)  u_exmem_wr (.clk(clk), .rst(rst), .d(writeregE), .q(writeregM));

    // ============================================================
    // MEM/WB 寄存器
    // ============================================================
    flopr #(32) u_memwb_alu(.clk(clk), .rst(rst), .d(aluoutM),    .q(aluoutW));
    flopr #(32) u_memwb_rd (.clk(clk), .rst(rst), .d(readdataM),  .q(readdataW));
    flopr #(5)  u_memwb_wr (.clk(clk), .rst(rst), .d(writeregM),  .q(writeregW));

    // ============================================================
    // WB 阶段
    // ============================================================
    mux2 #(32) u_result(
        .d0(aluoutW), .d1(readdataW),
        .sel(memtoregW), .y(resultW)
    );

endmodule
