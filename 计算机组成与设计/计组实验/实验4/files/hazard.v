// hazard: 冒险处理单元
// 处理数据冒险（前推+暂停）和控制冒险（分支提前到ID级）
module hazard(
    // 寄存器地址
    input  wire [4:0] rsD, rtD,         // ID阶段源寄存器
    input  wire [4:0] rsE, rtE,         // EX阶段源寄存器
    input  wire [4:0] writeregE,        // EX阶段写目标寄存器
    input  wire [4:0] writeregM,        // MEM阶段写目标寄存器
    input  wire [4:0] writeregW,        // WB阶段写目标寄存器
    // 控制信号
    input  wire       regwriteE, regwriteM, regwriteW,
    input  wire       memtoregE, memtoregM,
    input  wire       branchD,
    // EX阶段前推选择（mux3）
    // 00=寄存器堆, 01=WB结果, 10=MEM的ALU输出
    output reg  [1:0] forwardAE, forwardBE,
    // ID阶段前推选择（用于分支比较，1位：0=寄存器堆, 1=MEM的ALU输出）
    output reg        forwardAD, forwardBD,
    // 暂停/冲刷信号
    output wire       stallF,            // 暂停取指
    output wire       stallD,            // 暂停译码
    output wire       flushE             // 冲刷EX级（插入气泡）
);

    // ======== EX阶段数据前推 ========
    always @(*) begin
        // forwardAE：srcaE来源选择
        if      (rsE != 5'b0 && rsE == writeregM && regwriteM) forwardAE = 2'b10;
        else if (rsE != 5'b0 && rsE == writeregW && regwriteW) forwardAE = 2'b01;
        else                                                    forwardAE = 2'b00;

        // forwardBE：srcb2E来源选择
        if      (rtE != 5'b0 && rtE == writeregM && regwriteM) forwardBE = 2'b10;
        else if (rtE != 5'b0 && rtE == writeregW && regwriteW) forwardBE = 2'b01;
        else                                                    forwardBE = 2'b00;
    end

    // ======== ID阶段分支前推（只能从MEM前推ALU结果）========
    always @(*) begin
        forwardAD = (rsD != 5'b0) && (rsD == writeregM) && regwriteM && !memtoregM;
        forwardBD = (rtD != 5'b0) && (rtD == writeregM) && regwriteM && !memtoregM;
    end

    // ======== 暂停逻辑 ========
    // load-use冒险：lw在EX级，下一条指令在ID级依赖该结果
    wire lwstall = ((rsD == rtE) || (rtD == rtE)) && memtoregE;

    // 控制冒险暂停：分支在ID级，但依赖的寄存器值尚未就绪
    wire branchstall =
        (branchD && regwriteE  && (writeregE == rsD || writeregE == rtD))  ||
        (branchD && memtoregM  && (writeregM == rsD || writeregM == rtD));

    assign stallF = lwstall || branchstall;
    assign stallD = lwstall || branchstall;
    assign flushE = lwstall || branchstall;

endmodule
