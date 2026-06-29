`timescale 1ns / 1ps
// board_top.v —— 上板综合顶层（含时钟分频 + 七段显示）
// 综合时在 Vivado 中将 Top Module 改为 board_top
// 约束文件用 nexys4ddr.xdc（修改端口名为 board_top 的 an/seg）
module board_top(
    input  wire       clk,      // 100 MHz 板载时钟
    input  wire       rst,      // 复位 BTNC（高有效）
    output wire [7:0] an,       // 七段位选
    output wire [6:0] seg       // 七段段选
);
    // ---- 时钟分频：100MHz → 25MHz（4分频，同实验三 board_top）----
    reg [1:0] div_cnt;
    reg       clk25;
    always @(posedge clk or posedge rst) begin
        if (rst) begin div_cnt <= 0; clk25 <= 0; end
        else begin
            div_cnt <= div_cnt + 1;
            if (div_cnt == 2'd1) clk25 <= ~clk25;
        end
    end
    wire clk_cpu;
    BUFG u_cpu_bufg (.I(clk25),   .O(clk_cpu));

    // Block Memory 使用反相时钟（同实验三 board_top）
    wire clk_mem;
    BUFG u_mem_bufg (.I(~clk_cpu), .O(clk_mem));

    // ---- MIPS 软核 ----
    wire [31:0] pc, instr, readdata, dataadr, writedata;
    wire        memwrite, stallD;

    mips u_mips (
        .clk      (clk_cpu),
        .rst      (rst),
        .instr    (instr),
        .readdata (readdata),
        .pc       (pc),
        .memwrite (memwrite),
        .aluout   (dataadr),
        .writedata(writedata),
        .stallD   (stallD)
    );

    // ---- 指令存储器 ----
    instr_ram instr_ram (
        .clka  (clk_mem),
        .ena   (~stallD),
        .addra (pc[9:2]),
        .douta (instr)
    );

    // ---- 数据存储器 ----
    data_ram data_ram (
        .clka  (clk_mem),
        .wea   (memwrite),
        .addra (dataadr[9:2]),
        .dina  (writedata),
        .douta (readdata),
        .ena   (1'b1)
    );

    // ---- 结果锁存（捕获最后一次 SW 写入的数据用于显示）----
    reg [31:0] result_latch;
    always @(posedge clk_cpu or posedge rst) begin
        if (rst)           result_latch <= 32'b0;
        else if (memwrite) result_latch <= writedata;
    end

    // ---- 七段显示（用 100MHz 扫描，保证平滑；显示 result_latch 的 32 位十六进制）----
    display u_display (
        .clk(clk),
        .rst(rst),
        .num(result_latch),
        .ans(an),
        .seg(seg)
    );

endmodule
