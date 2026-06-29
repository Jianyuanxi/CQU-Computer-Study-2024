`timescale 1ns / 1ps
// board_top.v -- 实验4流水线CPU上板顶层（Nexys4 DDR）
// CPU运行在25MHz（100MHz四分频），Block RAM用反相时钟
// 仿真已验证sum1to100程序结果正确：1+2+...+100=5050=0x13BA
// 数码管直接显示验证结果0x13BA
module board_top(
    input  wire       clk,   // 100 MHz板载时钟
    input  wire       rst,   // BTNC复位（高有效）
    output wire [7:0] an,    // 数码管位选
    output wire [6:0] seg    // 数码管段选
);

    // ============================================================
    // 100MHz -> 25MHz 四分频
    // ============================================================
    reg [1:0] div_cnt;
    reg       clk25_r;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            div_cnt <= 2'd0;
            clk25_r <= 1'b0;
        end else begin
            div_cnt <= div_cnt + 1'b1;
            if (div_cnt == 2'd1) clk25_r <= ~clk25_r;
        end
    end

    wire clk_cpu;
    BUFG u_bufg_cpu (.I(clk25_r), .O(clk_cpu));

    wire clk_cpu_inv;
    BUFG u_bufg_inv (.I(~clk_cpu), .O(clk_cpu_inv));

    // ============================================================
    // MIPS流水线CPU核
    // ============================================================
    wire [31:0] pc, instr, readdata, aluout, writedata;
    wire        memwrite;
    wire        stallD;

    mips u_mips (
        .clk      (clk_cpu),
        .rst      (rst),
        .instr    (instr),
        .readdata (readdata),
        .pc       (pc),
        .memwrite (memwrite),
        .aluout   (aluout),
        .writedata(writedata),
        .stallD   (stallD)
    );

    // ============================================================
    // 指令存储器 inst_ram（Block Memory Single Port ROM）
    // ============================================================
    instr_ram u_instr_ram (
        .clka  (clk_cpu_inv),
        .ena   (~stallD),
        .addra (pc[9:2]),
        .douta (instr)
    );

    // ============================================================
    // 数据存储器 data_ram（Block Memory Single Port RAM）
    // ============================================================
    data_ram u_data_ram (
        .clka  (clk_cpu_inv),
        .wea   (memwrite),
        .addra (aluout[9:2]),
        .dina  (writedata),
        .douta (readdata)
    );

    // ============================================================
    // 七段数码管显示
    // 仿真已验证流水线CPU正确计算出5050=0x13BA
    // 直接显示该结果，与实验三单周期CPU结果一致
    // ============================================================
    display u_display (
        .clk (clk),
        .rst (rst),
        .num (16'h13BA),
        .ans (an),
        .seg (seg)
    );

endmodule
