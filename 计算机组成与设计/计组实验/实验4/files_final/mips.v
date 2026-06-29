`timescale 1ns / 1ps
// ============================================================
// mips.v -- MIPS流水线CPU核
// 连接 controller、datapath、hazard 三大模块
//
// 关键设计：flushE_total = flushE_hazard | flushD
//   flushE_hazard 来自hazard（lwstall时插气泡）
//   flushD        来自datapath（pcsrcE | jumpD，分支/跳转成立）
// 必须同时清掉ID/EX，否则beq后的"延迟槽"指令会错执行
// ============================================================
module mips(
    input  wire        clk, rst,
    // 与inst_ram接口
    input  wire [31:0] instr,
    output wire [31:0] pc,
    // 与data_ram接口
    input  wire [31:0] readdata,
    output wire        memwrite,
    output wire [31:0] aluout,
    output wire [31:0] writedata
);

    // -------- 模块间互连信号 --------
    wire [5:0]  opD, functD;
    wire        jumpD;
    wire        branchE;
    wire        regdstE, alusrcE;
    wire [2:0]  alucontrolE;
    wire        memwriteM, memtoregM, regwriteM;
    wire        memtoregW, regwriteW;
    wire        memtoregE;

    wire [4:0]  rsD, rtD;
    wire [4:0]  rsE, rtE;
    wire [4:0]  writeregE, writeregM, writeregW;

    wire [1:0]  forwardAE, forwardBE;
    wire        stallF, stallD;
    wire        flushE_hazard;    // 来自hazard，只含lwstall部分
    wire        flushD;           // 来自datapath，分支/跳转成立
    wire        flushE_total;     // 合成：lwstall | 分支冲刷

    // 关键合成：beq/j 成立时，ID/EX 也必须清零
    assign flushE_total = flushE_hazard | flushD;

    // ============================================================
    // Controller —— 使用 flushE_total
    // ============================================================
    controller u_ctrl(
        .clk(clk), .rst(rst),
        .opD(opD), .functD(functD),
        .flushE(flushE_total),
        .jumpD(jumpD),
        .branchE(branchE),
        .regdstE(regdstE), .alusrcE(alusrcE),
        .alucontrolE(alucontrolE),
        .memtoregE(memtoregE),
        .memwriteM(memwriteM), .memtoregM(memtoregM), .regwriteM(regwriteM),
        .memtoregW(memtoregW), .regwriteW(regwriteW)
    );

    // ============================================================
    // Datapath —— 使用 flushE_total，并输出 flushD
    // ============================================================
    datapath u_dp(
        .clk(clk), .rst(rst),
        .instrF(instr),
        .readdataM(readdata),
        .jumpD(jumpD),
        .branchE(branchE),
        .regdstE(regdstE), .alusrcE(alusrcE),
        .alucontrolE(alucontrolE),
        .memtoregW(memtoregW), .regwriteW(regwriteW),
        .forwardAE(forwardAE), .forwardBE(forwardBE),
        .stallF(stallF), .stallD(stallD), .flushE(flushE_total),
        .opD(opD), .functD(functD),
        .rsD(rsD), .rtD(rtD),
        .rsE(rsE), .rtE(rtE),
        .writeregE(writeregE),
        .writeregM(writeregM),
        .writeregW(writeregW),
        .pcF(pc),
        .aluoutM(aluout),
        .writedataM(writedata),
        .flushD_out(flushD)
    );

    // ============================================================
    // Hazard —— 输出 flushE_hazard（只含lwstall部分）
    // ============================================================
    hazard u_hz(
        .rsD(rsD), .rtD(rtD),
        .rsE(rsE), .rtE(rtE),
        .writeregE(writeregE),
        .memtoregE(memtoregE),
        .writeregM(writeregM),
        .regwriteM(regwriteM),
        .writeregW(writeregW),
        .regwriteW(regwriteW),
        .forwardAE(forwardAE),
        .forwardBE(forwardBE),
        .stallF(stallF),
        .stallD(stallD),
        .flushE(flushE_hazard)
    );

    assign memwrite = memwriteM;

endmodule
