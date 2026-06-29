// mips: MIPS软核顶层，连接控制器、数据通路和冒险单元
module mips(
    input  wire        clk, rst,
    input  wire [31:0] instr,     // 来自inst_ram（instrF，IF级组合输出）
    input  wire [31:0] readdata,  // 来自data_ram（WB级）
    output wire [31:0] pc,        // inst_ram地址
    output wire        memwrite,  // data_ram写使能
    output wire [31:0] aluout,    // data_ram地址（dataadr）
    output wire [31:0] writedata, // data_ram写数据
    output wire        stallD     // 传给inst_ram的ENA控制（top层用）
);

    // ---- 控制信号 ----
    wire       branchD, jumpD;
    wire       memtoregE, memwriteE, alusrcE, regdstE, regwriteE;
    wire [2:0] alucontrolE;
    wire       memtoregM, memwriteM, regwriteM;
    wire       memtoregW, regwriteW;

    // ---- 冒险信号 ----
    wire [1:0] forwardAE, forwardBE;
    wire       forwardAD, forwardBD;
    wire       stallF, flushE;

    // ---- 数据通路信号 ----
    wire [5:0] opD, functD;
    wire [4:0] rsD, rtD, rsE, rtE;
    wire [4:0] writeregE, writeregM, writeregW;
    wire       equalD;
    wire [31:0] aluoutM, writedataM, resultW;

    assign memwrite  = memwriteM;
    assign aluout    = aluoutM;
    assign writedata = writedataM;

    // ---- 控制器 ----
    controller ctrl (
        .clk(clk), .rst(rst),
        .opD(opD), .functD(functD),
        .flushE(flushE),
        .branchD(branchD), .jumpD(jumpD),
        .memtoregE(memtoregE), .memwriteE(memwriteE),
        .alusrcE(alusrcE),  .regdstE(regdstE), .regwriteE(regwriteE),
        .alucontrolE(alucontrolE),
        .memtoregM(memtoregM), .memwriteM(memwriteM), .regwriteM(regwriteM),
        .memtoregW(memtoregW), .regwriteW(regwriteW)
    );

    // ---- 冒险单元 ----
    hazard hzd (
        .rsD(rsD), .rtD(rtD),
        .rsE(rsE), .rtE(rtE),
        .writeregE(writeregE), .writeregM(writeregM), .writeregW(writeregW),
        .regwriteE(regwriteE), .regwriteM(regwriteM), .regwriteW(regwriteW),
        .memtoregE(memtoregE), .memtoregM(memtoregM),
        .branchD(branchD),
        .forwardAE(forwardAE), .forwardBE(forwardBE),
        .forwardAD(forwardAD), .forwardBD(forwardBD),
        .stallF(stallF), .stallD(stallD), .flushE(flushE)
    );

    // ---- 数据通路 ----
    datapath dp (
        .clk(clk), .rst(rst),
        .instrF(instr),
        .readdata(readdata),
        .branchD(branchD), .jumpD(jumpD),
        .memtoregE(memtoregE), .alusrcE(alusrcE), .regdstE(regdstE),
        .alucontrolE(alucontrolE),
        .regwriteW(regwriteW), .memtoregW(memtoregW),
        .forwardAE(forwardAE), .forwardBE(forwardBE),
        .forwardAD(forwardAD), .forwardBD(forwardBD),
        .stallF(stallF), .stallD(stallD), .flushE(flushE),
        .opD(opD), .functD(functD),
        .rsD(rsD), .rtD(rtD),
        .rsE(rsE), .rtE(rtE),
        .writeregE(writeregE), .writeregM(writeregM), .writeregW(writeregW),
        .equalD(equalD),
        .pcF(pc),
        .aluoutM(aluoutM),
        .writedataM(writedataM),
        .resultW(resultW)
    );

endmodule
