`timescale 1ns / 1ps
// clk_div.v -- 100MHz → 25MHz 时钟分频
// 用于上板：单周期CPU组合路径过长，必须降速；流水线短路径短，
// 但为了和实验3保持一致，依然降到25MHz
module clk_div(
    input  wire clk,    // 100MHz板载时钟
    input  wire rst,
    output reg  clk_cpu // 25MHz
);
    reg [1:0] cnt;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cnt     <= 2'b00;
            clk_cpu <= 1'b0;
        end
        else begin
            cnt <= cnt + 1'b1;
            if (cnt == 2'b01) clk_cpu <= ~clk_cpu;
        end
    end
endmodule
