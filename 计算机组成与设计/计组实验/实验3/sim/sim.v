`timescale 1ns / 1ps
// =============================================================
// sim.v -- Single-Cycle MIPS CPU Self-Contained Simulation
// Program: compute 1+2+...+100 = 5050 (0x13BA)
//
// Assembly (word address):
//  [0] addi $t0, $zero,   1   # $t0 = 1  (loop counter i)
//  [1] addi $s0, $zero,   0   # $s0 = 0  (accumulator sum)
//  [2] addi $t1, $zero, 101   # $t1 = 101 (termination bound)
//  [3] add  $s0, $s0, $t0     # sum += i        <- LOOP
//  [4] addi $t0, $t0,   1     # i++
//  [5] beq  $t0, $t1, +1      # if(i==101) skip j, fall to [7]
//  [6] j    3                 # goto LOOP
//  [7] sw   $s0, 84($zero)    # store result to addr 84
//  [8] lw   $t2, 84($zero)    # reload from addr 84 (verify lw)
//  [9] j    9                 # HALT: jump to self
//
// Uses inline memory models (no Block RAM IP needed for sim).
// =============================================================
module sim;

    // ---- clock & reset ----
    reg clk, rst;

    // ---- buses ----
    wire [31:0] pc, instr, aluout, writedata, readdata;
    wire        memwrite;       // 1-bit, matching mips.v output
    wire [31:0] display_data;  // $s0, connected to silence port warning

    // ---- instruction memory (ROM, 256x32) ----
    reg [31:0] inst_mem [0:255];
    assign instr = inst_mem[pc[9:2]];

    // ---- data memory (RAM, 256x32) ----
    reg [31:0] data_mem [0:255];
    assign readdata = data_mem[aluout[9:2]];
    always @(posedge clk) begin
        if (memwrite)
            data_mem[aluout[9:2]] <= writedata;
    end

    // ---- instantiate MIPS CPU ----
    mips u_mips(
        .clk         (clk),
        .rst         (rst),
        .instr       (instr),
        .readdata    (readdata),
        .memwrite    (memwrite),
        .pc          (pc),
        .aluout      (aluout),
        .writedata   (writedata),
        .display_data(display_data)  // connected; avoids unconnected-port warning
    );

    // ---- load instruction memory ----
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            inst_mem[i] = 32'h00000000;

        inst_mem[0] = 32'h20080001; // addi $t0,$zero,1
        inst_mem[1] = 32'h20100000; // addi $s0,$zero,0
        inst_mem[2] = 32'h20090065; // addi $t1,$zero,101
        inst_mem[3] = 32'h02088020; // add  $s0,$s0,$t0   <- LOOP (word 3)
        inst_mem[4] = 32'h21080001; // addi $t0,$t0,1
        inst_mem[5] = 32'h11090001; // beq  $t0,$t1,+1   (offset=1 -> skip j)
        inst_mem[6] = 32'h08000003; // j    3             (goto LOOP)
        inst_mem[7] = 32'hac100054; // sw   $s0,84($zero) (store at byte addr 84)
        inst_mem[8] = 32'h8c0a0054; // lw   $t2,84($zero) (reload, verify lw)
        inst_mem[9] = 32'h08000009; // j    9             (HALT: jump to self)
    end

    // ---- clear data memory ----
    initial begin
        for (i = 0; i < 256; i = i + 1)
            data_mem[i] = 32'h00000000;
    end

    // ---- clock: 10ns period (100 MHz) ----
    initial clk = 0;
    always  #5 clk = ~clk;

    // ---- reset: active-high for first 12 ns ----
    initial begin
        rst = 1;
        #12;
        rst = 0;
    end

    // ---- waveform monitor (ASCII only - avoids TCL console garble) ----
    // Signals required by lab report: pc, instr, rs, rt, rd, result
    initial begin
        $display("============================================");
        $display(" MIPS Single-Cycle CPU Simulation");
        $display(" Program: 1+2+...+100 = 5050 (0x13BA)");
        $display("============================================");
        $display("  time(ns) | PC       | instr    | rs(rd1)  | rt(rd2)  | rd(wreg) | result");
        $monitor("%8t ns | %08h | %08h | %08h | %08h | %05b    | %08h",
            $time,
            pc,
            instr,
            u_mips.u_datapath.rd1,
            u_mips.u_datapath.rd2,
            u_mips.u_datapath.writereg,
            u_mips.u_datapath.result);
    end

    // ---- result check at t=6000ns (600 cycles, enough for ~405 loop cycles) ----
    initial begin
        #6000;
        $display("--------------------------------------------");
        $display("Registers after halt:");
        $display("  $s0 (reg[16]) = %0d  (expected: 5050)", u_mips.u_datapath.u_regfile.rf[16]);
        $display("  $t0 (reg[ 8]) = %0d  (expected: 101)",  u_mips.u_datapath.u_regfile.rf[8]);
        $display("  $t2 (reg[10]) = %0d  (lw verify, expected: 5050)", u_mips.u_datapath.u_regfile.rf[10]);
        $display("  data_mem[21]  = %0d  (sw verify, addr 84, expected: 5050)", data_mem[21]);
        $display("--------------------------------------------");
        if (u_mips.u_datapath.u_regfile.rf[16] == 32'd5050)
            $display("Simulation succeeded: sum(1..100) = 5050");
        else
            $display("Simulation failed: got %0d, expected 5050",
                     u_mips.u_datapath.u_regfile.rf[16]);
        $display("============================================");
        $finish;
    end

endmodule
