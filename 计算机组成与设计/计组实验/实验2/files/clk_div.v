`timescale 1ns / 1ps
// 时钟分频器
// SIM_MODE=1时极速分频（仿真用），SIM_MODE=0时1Hz（上板用）
module clk_div #(parameter SIM_MODE = 0)(
    input      hclk,
    input      rst,
    output reg lclk
);
    reg [26:0] cnt;
    wire [26:0] MAX = SIM_MODE ? 27'd4 : 27'd49_999_999;

    always @(posedge hclk) begin
        if (rst) begin
            cnt  <= 27'd0;
            lclk <= 1'b0;
        end else if (cnt == MAX) begin
            cnt  <= 27'd0;
            lclk <= ~lclk;
        end else begin
            cnt  <= cnt + 1'b1;
        end
    end
endmodule
