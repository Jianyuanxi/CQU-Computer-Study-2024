`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/15 21:00:21
// Design Name: 
// Module Name: sim
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


module sim();
  reg [7:0]num1;
  reg [2:0]op;
  wire [31:0]result; 

  alu test(.num1(num1),.op(op),.result(result));
  initial begin
      #0 num1 = 0;
         op = 3'b001;
      #100 $finish;
  end


endmodule
