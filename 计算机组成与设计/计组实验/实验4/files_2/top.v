`timescale 1ns / 1ps
// top.v: 仿真顶层，使用行为级RAM（异步读）
// 跑 sum1to100：$1累加1到100，最终sw写入地址0，值5050(0x13BA)
// display_data 直接暴露 $1 寄存器值，仿真波形可见累加过程
module top(
    input  wire        clk,
    input  wire        rst,
    output wire [31:0] writedata,
    output wire [31:0] dataadr,
    output wire        memwrite,
    output wire [31:0] display_data  // 仿真观察用：实时显示$1的值
);
    wire [31:0] pc, instr, readdata;
    wire        stallD;

    mips u_mips (
        .clk(clk),       .rst(rst),
        .instr(instr),   .readdata(readdata),
        .pc(pc),         .memwrite(memwrite),
        .aluout(dataadr),.writedata(writedata),
        .stallD(stallD)
    );

    imem u_imem (
        .addr(pc[9:2]),
        .dout(instr)
    );

    dmem u_dmem (
        .clk(clk),    .we(memwrite),
        .addr(dataadr[9:2]),
        .din(writedata), .dout(readdata)
    );

    // display_data：从数据RAM读地址0的值（sw写入后即为5050）
    // 仿真中每次写入后可在波形看到值变化
    assign display_data = u_dmem.mem[0];

endmodule

// ---- 行为级指令ROM（异步读）----
module imem(
    input  wire [7:0]  addr,
    output wire [31:0] dout
);
    reg [31:0] mem [0:255];
    initial $readmemh("C:/coe/inst_ram.mem", mem);
    assign dout = mem[addr];
endmodule

// ---- 行为级数据RAM（同步写，异步读）----
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
