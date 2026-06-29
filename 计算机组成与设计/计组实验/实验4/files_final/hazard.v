`timescale 1ns / 1ps
// ============================================================
// hazard.v -- 冒险处理单元
//
// 本设计将beq判断放在EX阶段，因此hazard只处理：
//   1) EX阶段数据前推（forwardAE/BE）
//      - 优先级：MEM前推（2'b10） > WB前推（2'b01） > 无前推（2'b00）
//   2) load-use 数据冒险暂停（lwstall）
//      - lw在EX阶段，ID阶段下一条指令的rs或rt等于lw的rt
//        → stallF=1, stallD=1, flushE=1（插1个气泡，下拍自动解除）
//
// 不再有branchstall/forwardAD/BD —— 控制冒险由datapath内部
// 用 pcsrcE|jumpD 信号直接冲刷IF/ID寄存器（flushD）来处理。
// mips.v合成的 flushE_total = flushE_hazard | flushD 同时清掉ID/EX。
//
// 前推条件中要求writereg != 0（避免与$0误匹配）和regwrite=1
// （避免与不写寄存器的指令误匹配）。
// ============================================================
module hazard(
    // ID阶段（用于lwstall检测）
    input  wire [4:0] rsD, rtD,
    // EX阶段
    input  wire [4:0] rsE, rtE,
    input  wire [4:0] writeregE,
    input  wire       memtoregE,   // lw标志：=1表示EX阶段是lw
    // MEM阶段
    input  wire [4:0] writeregM,
    input  wire       regwriteM,
    // WB阶段
    input  wire [4:0] writeregW,
    input  wire       regwriteW,
    // 输出
    output wire [1:0] forwardAE,
    output wire [1:0] forwardBE,
    output wire       stallF,
    output wire       stallD,
    output wire       flushE
);

    // ============= EX阶段前推 =============
    // forwardAE
    assign forwardAE =
        ((rsE != 5'b0) && (rsE == writeregM) && regwriteM) ? 2'b10 :
        ((rsE != 5'b0) && (rsE == writeregW) && regwriteW) ? 2'b01 :
                                                              2'b00 ;

    // forwardBE
    assign forwardBE =
        ((rtE != 5'b0) && (rtE == writeregM) && regwriteM) ? 2'b10 :
        ((rtE != 5'b0) && (rtE == writeregW) && regwriteW) ? 2'b01 :
                                                              2'b00 ;

    // ============= Load-use 暂停 =============
    // lw在EX，ID阶段的rs或rt等于EX的rt（lw的目标寄存器）
    wire lwstall;
    assign lwstall = memtoregE && ((rsD == rtE) || (rtD == rtE)) && (rtE != 5'b0);

    assign stallF = lwstall;
    assign stallD = lwstall;
    assign flushE = lwstall;

endmodule
