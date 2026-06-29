`timescale 1ns / 1ps
// top.v -- simulation wrapper
// Port order MUST match testbench.v positional connection:
//   top dut(clk, rst, writedata, dataadr, memwrite)
module top(
    input  wire        clk,
    input  wire        rst,
    output wire [31:0] writedata,
    output wire [31:0] dataadr,
    output wire        memwrite
);
    wire clk_inv;
    BUFG u_clk_inv_bufg (.I(~clk), .O(clk_inv));

    wire [31:0] pc, instr, readdata, display_data;

    mips u_mips(
        .clk         (clk),
        .rst         (rst),
        .instr       (instr),
        .readdata    (readdata),
        .memwrite    (memwrite),
        .pc          (pc),
        .aluout      (dataadr),
        .writedata   (writedata),
        .display_data(display_data)
    );

    instr_ram instr_ram (
        .clka  (clk_inv),
        .ena   (1'b1),
        .addra (pc[9:2]),
        .douta (instr)
    );

    data_ram data_ram (
        .clka  (clk_inv),
        .wea   (memwrite),
        .addra (dataadr[9:2]),
        .dina  (writedata),
        .douta (readdata)
    );
endmodule
