`timescale 1ns / 1ps
// ============================================================
// board_top.v -- 上板顶层
// 使用 Block Memory IP（inst_ram / data_ram）
// sum1to100 程序最终执行 sw $1, 0($0) 将 5050 写入地址0
// 我们锁存这个值，显示在数码管上 -> "13bA"
//
// IP 配置：
//   inst_ram: Single Port ROM, 32-bit×256, Use ENA Pin enabled
//             不勾 32-bit address; addra=pc[9:2]（8位）
//             COE 路径: C:/coe/sum1to100.coe
//   data_ram: Single Port RAM, 32-bit×256, write_first
//             addra=aluout[9:2]
//             wea=memwrite
// ============================================================
module board_top(
    input  wire        clk,       // 100MHz板载时钟（E3）
    input  wire        rst,       // BTNC复位（按高有效，N17）
    output wire [7:0]  an,        // 数码管位选
    output wire [6:0]  seg        // 数码管段选
);

    // ---- 25MHz CPU时钟 ----
    wire clk_cpu;
    clk_div u_clkdiv(
        .clk(clk), .rst(rst),
        .clk_cpu(clk_cpu)
    );

    // ---- MIPS核 ----
    wire [31:0] pc, instr, readdata, aluout, writedata;
    wire        memwrite;

    mips u_mips(
        .clk(clk_cpu), .rst(rst),
        .instr(instr),
        .pc(pc),
        .readdata(readdata),
        .memwrite(memwrite),
        .aluout(aluout),
        .writedata(writedata)
    );

    // ---- 指令ROM（Block Memory IP）----
    // 反相时钟读：让CPU在上升沿看到稳定的数据
    inst_ram u_imem(
        .clka(~clk_cpu),
        .ena(1'b1),
        .addra(pc[9:2]),
        .douta(instr)
    );

    // ---- 数据RAM（Block Memory IP）----
    data_ram u_dmem(
        .clka(~clk_cpu),
        .wea(memwrite),
        .addra(aluout[9:2]),
        .dina(writedata),
        .douta(readdata)
    );

    // ---- 结果锁存：sw写入地址0时锁存数据 ----
    reg [15:0] result_latch;
    always @(posedge clk_cpu, posedge rst) begin
        if (rst)
            result_latch <= 16'h0000;
        else if (memwrite && (aluout == 32'd0))
            result_latch <= writedata[15:0];
    end

    // ---- 数码管显示 ----
    display u_disp(
        .clk(clk), .rst(rst),
        .num(result_latch),
        .an(an), .seg(seg)
    );

endmodule
