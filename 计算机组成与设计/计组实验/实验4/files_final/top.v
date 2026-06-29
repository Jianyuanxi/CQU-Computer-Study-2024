`timescale 1ns / 1ps
// ============================================================
// top.v -- 仿真顶层
// 使用行为级RAM（异步读，由$readmemh初始化）
// 默认读取 C:/coe/inst_ram.mem（sum1to100程序）
//
// 输出 display_data：实时显示数据存储器[0]的值（即sum的最终结果）
// 便于在波形中观察累加过程
// ============================================================
module top(
    input  wire        clk, rst,
    output wire [31:0] writedata,
    output wire [31:0] dataadr,
    output wire        memwrite,
    output wire [31:0] display_data
);

    wire [31:0] pc, instr, readdata;

    // ---- MIPS核 ----
    mips u_mips(
        .clk(clk), .rst(rst),
        .instr(instr),
        .pc(pc),
        .readdata(readdata),
        .memwrite(memwrite),
        .aluout(dataadr),
        .writedata(writedata)
    );

    // ---- 行为级指令存储器（异步读）----
    imem u_imem(
        .addr(pc[9:2]),
        .dout(instr)
    );

    // ---- 行为级数据存储器（同步写，异步读）----
    dmem u_dmem(
        .clk(clk),
        .we(memwrite),
        .addr(dataadr[9:2]),
        .din(writedata),
        .dout(readdata)
    );

    // ---- 累加观察信号：实时显示mem[0]（sw最终写入位置）----
    assign display_data = u_dmem.mem[0];

endmodule


// ============================================================
// 行为级指令存储器
// ============================================================
module imem(
    input  wire [7:0]  addr,
    output wire [31:0] dout
);
    reg [31:0] mem [0:255];
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) mem[i] = 32'b0;
        $readmemh("C:/coe/inst_ram.mem", mem);
    end
    assign dout = mem[addr];
endmodule


// ============================================================
// 行为级数据存储器（同步写，异步读）
// ============================================================
module dmem(
    input  wire        clk,
    input  wire        we,
    input  wire [7:0]  addr,
    input  wire [31:0] din,
    output wire [31:0] dout
);
    reg [31:0] mem [0:255];
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1) mem[i] = 32'b0;
    end
    always @(posedge clk) begin
        if (we) mem[addr] <= din;
    end
    assign dout = mem[addr];
endmodule
