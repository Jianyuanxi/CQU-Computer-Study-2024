`timescale 1ns / 1ps
// MIPS single-cycle CPU core: connects Controller and Datapath
// memwrite is 1-bit; WEA expansion for Block RAM is done in top-level wrappers
module mips(
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] instr,
    input  wire [31:0] readdata,
    output wire        memwrite,    // 1-bit write enable
    output wire [31:0] pc,
    output wire [31:0] aluout,
    output wire [31:0] writedata,
    output wire [31:0] display_data // reg[16] ($s0) for board display
);
    wire memtoreg, alusrc, regdst, regwrite, jump, branch;
    wire [2:0] alucontrol;

    controller u_controller(
        .inst       (instr),
        .jump       (jump),
        .branch     (branch),
        .alusrc     (alusrc),
        .memwrite   (memwrite),
        .memtoreg   (memtoreg),
        .regwrite   (regwrite),
        .regdst     (regdst),
        .alucontrol (alucontrol)
    );

    datapath u_datapath(
        .clka        (clk),
        .rst         (rst),
        .jump        (jump),
        .branch      (branch),
        .alusrc      (alusrc),
        .memtoreg    (memtoreg),
        .regwrite    (regwrite),
        .regdst      (regdst),
        .alucontrol  (alucontrol),
        .pc          (pc),
        .instr       (instr),
        .aluout      (aluout),
        .writedata   (writedata),
        .readdata    (readdata),
        .display_data(display_data)
    );
endmodule
