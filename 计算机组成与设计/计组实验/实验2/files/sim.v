`timescale 1ns / 1ps
module test_bench();

    reg         clk;
    reg         rst;
    wire [31:0] pc, pc_plus4, instr;
    wire        inst_ce;
    wire        memtoreg, memwrite, branch;
    wire        alusrc, regdst, regwrite, jump;
    wire [2:0]  alucontrol;

    pc u_pc(
        .clk     (clk),
        .rst     (rst),
        .pc_next (pc_plus4),
        .pc      (pc),
        .inst_ce (inst_ce)
    );

    assign pc_plus4 = pc + 32'h4;

    blk_mem_gen_0 u_rom(
        .clka  (clk),
        .ena   (inst_ce),
        .addra (pc[9:2]),
        .douta (instr)
    );

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

    initial clk = 1'b0;
    always #10 clk = ~clk;

    initial begin
        rst = 1'b1;
        #100;
        rst = 1'b0;
    end

    // 打印前10条（包含ROM延迟稳定后的有效指令）
    integer cnt;
    initial cnt = 0;
    always @(posedge clk) begin
        if (!rst) begin
            cnt = cnt + 1;
            #1;
            $display("cnt=%0d PC=%08h  instr=%08h  memtoreg=%b memwrite=%b pcsrc=0 alusrc=%b regdst=%b regwrite=%b jump=%b branch=%b alucontrol=%b",
                cnt, pc, instr, memtoreg, memwrite,
                alusrc, regdst, regwrite,
                jump, branch, alucontrol);
        end else begin
            cnt = 0;
        end
    end

endmodule
