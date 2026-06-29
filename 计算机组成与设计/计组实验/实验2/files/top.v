`timescale 1ns / 1ps
// SIM_MODE=1仿真用，上板前改为SIM_MODE=0
module top(
    input        hclk,
    input        rst,
    output [6:0] seg,
    output [7:0] ans,
    output [9:0] led
);
    wire lclk;
    clk_div #(.SIM_MODE(1)) u_clk_div(   // 上板前改为SIM_MODE(0)
        .hclk (hclk),
        .rst  (rst),
        .lclk (lclk)
    );

    wire [31:0] pc, pc_plus4, instr;
    wire        inst_ce;

    pc u_pc(
        .clk     (lclk),
        .rst     (rst),
        .pc_next (pc_plus4),
        .pc      (pc),
        .inst_ce (inst_ce)
    );

    assign pc_plus4 = pc + 32'h4;

    blk_mem_gen_0 u_inst_rom(
        .clka  (lclk),
        .ena   (inst_ce),
        .addra (pc[9:2]),
        .douta (instr)
    );

    wire       memtoreg, memwrite, branch, alusrc, regdst, regwrite, jump;
    wire [2:0] alucontrol;

    controller u_ctrl(
        .op         (instr[31:26]),
        .funct      (instr[5:0]),
        .memtoreg   (memtoreg),
        .memwrite   (memwrite),
        .branch     (branch),
        .alusrc     (alusrc),
        .regdst     (regdst),
        .regwrite   (regwrite),
        .jump       (jump),
        .alucontrol (alucontrol)
    );

    wire pcsrc = 1'b0;

    assign led[0]   = memtoreg;
    assign led[1]   = memwrite;
    assign led[2]   = pcsrc;
    assign led[3]   = alusrc;
    assign led[4]   = regdst;
    assign led[5]   = regwrite;
    assign led[6]   = jump;
    assign led[7]   = branch;
    assign led[9:8] = alucontrol[1:0];

    display u_display(
        .clk  (hclk),
        .rst  (rst),
        .num  (pc[15:0]),
        .seg  (seg),
        .ans  (ans)
    );
endmodule
