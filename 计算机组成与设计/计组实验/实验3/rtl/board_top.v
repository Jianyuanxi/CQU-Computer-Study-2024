`timescale 1ns / 1ps
// board_top.v -- synthesis top for Nexys4 DDR
// CPU runs at 25 MHz (divided from 100 MHz) to meet timing.
// Block RAMs clocked at 25 MHz negedge via BUFG-routed inverted clock.
module board_top(
    input  wire        clk,    // 100 MHz
    input  wire        rst,
    output wire [7:0]  an,
    output wire [6:0]  seg
);
    // ---- Divide 100 MHz -> 25 MHz ----
    reg [1:0] clk_div_cnt;
    reg       clk25;
    always @(posedge clk) begin
        if (rst) begin
            clk_div_cnt <= 0;
            clk25 <= 0;
        end else begin
            clk_div_cnt <= clk_div_cnt + 1;
            if (clk_div_cnt == 2'd1) clk25 <= ~clk25;
        end
    end

    // Route 25 MHz through global clock buffer
    wire clk_cpu;
    BUFG u_bufg_cpu (.I(clk25), .O(clk_cpu));

    // Inverted 25 MHz for Block RAMs
    wire clk_cpu_inv;
    BUFG u_bufg_inv (.I(~clk_cpu), .O(clk_cpu_inv));

    wire [31:0] pc, instr, readdata, aluout, writedata, display_data;
    wire        memwrite;

    mips u_mips(
        .clk         (clk_cpu),
        .rst         (rst),
        .instr       (instr),
        .readdata    (readdata),
        .memwrite    (memwrite),
        .pc          (pc),
        .aluout      (aluout),
        .writedata   (writedata),
        .display_data(display_data)
    );

    instr_ram instr_ram (
        .clka  (clk_cpu_inv),
        .ena   (1'b1),
        .addra (pc[9:2]),
        .douta (instr)
    );

    data_ram data_ram (
        .clka  (clk_cpu_inv),
        .wea   (memwrite),
        .addra (aluout[9:2]),
        .dina  (writedata),
        .douta (readdata)
    );

    // Display $s0 directly -- stable at 5050=0x13BA after halt
    display u_display(
        .clk (clk),      // display still uses 100 MHz for smooth scanning
        .rst (rst),
        .num (display_data[15:0]),
        .ans (an),
        .seg (seg)
    );

endmodule
