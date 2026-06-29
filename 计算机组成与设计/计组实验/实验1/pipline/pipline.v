`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/16 09:47:28
// Design Name: 
// Module Name: pipline
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pipline(
input [31:0]  cin_a,
input [31:0]  cin_b,
input        c_in,
input        clk,
input [3:0]       stop,
input [3:0]       reset,
output       c_out,
output [31:0] sum_out
);
reg c_out ;
reg c_out_t1 , c_out_t2 , c_out_t3 ;

reg [31:0] sum_out ;
reg [7:0] sum_out_t1 ;
reg [15:0] sum_out_t2 ;
reg [23:0] sum_out_t3 ;

always @( posedge clk ) begin
    if(reset[0])
        sum_out_t1 <= 0;
    else if(stop[0])
        sum_out_t1 <= sum_out_t1;
    else { c_out_t1 , sum_out_t1 } <= {1'b0 , cin_a [7:0]} + {1'b0 , cin_b
[7:0]} + c_in ;
end

always @( posedge clk ) begin
    if(reset[1])
        sum_out_t2 <= 0;
    else if(stop[1])
        sum_out_t2 <= sum_out_t2;
    else { c_out_t2 , sum_out_t2 } <= {{1'b0 , cin_a [15:8]} + {1'b0 ,
cin_b [15:8]} + c_out_t1 , sum_out_t1 };
end

always @( posedge clk ) begin
    if(reset[2])
        sum_out_t3 <= 0;
    else if(stop[2])
        sum_out_t3 <= sum_out_t3;
    else { c_out_t3 , sum_out_t3 } <= {{1'b0 , cin_a [23:16]} + {1'b0 ,
cin_b [23:16]} + c_out_t2 , sum_out_t2 };
end

always @( posedge clk ) begin
    if(reset[3])
        sum_out <= 0;
    else if(stop[3])
        sum_out <= sum_out;
    else { c_out , sum_out } <= {{1'b0 , cin_a [31:24]} + {1'b0 , cin_b
[31:24]} + c_out_t3 , sum_out_t3 };
end

endmodule
