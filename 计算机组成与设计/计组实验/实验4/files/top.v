`timescale 1ns / 1ps
// top.v -- simulation top
// Uses behavioral RAM (async read) to avoid Block Memory timing issues
// For board use board_top.v (with Block Memory IP)
module top(
    input  wire        clk,
    input  wire        rst,
    output wire [31:0] writedata,
    output wire [31:0] dataadr,
    output wire        memwrite
);
    wire [31:0] pc, instr, readdata;
    wire        stallD;

    mips u_mips (
        .clk      (clk),
        .rst      (rst),
        .instr    (instr),
        .readdata (readdata),
        .pc       (pc),
        .memwrite (memwrite),
        .aluout   (dataadr),
        .writedata(writedata),
        .stallD   (stallD)
    );

    imem u_imem (
        .addr (pc[9:2]),
        .dout (instr)
    );

    dmem u_dmem (
        .clk  (clk),
        .we   (memwrite),
        .addr (dataadr[9:2]),
        .din  (writedata),
        .dout (readdata)
    );

endmodule

// Behavioral instruction ROM (async read)
module imem(
    input  wire [7:0]  addr,
    output wire [31:0] dout
);
    reg [31:0] mem [0:255];
    initial $readmemh("C:/coe/inst_ram.mem", mem);
    assign dout = mem[addr];
endmodule

// Behavioral data RAM (async read, sync write)
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
