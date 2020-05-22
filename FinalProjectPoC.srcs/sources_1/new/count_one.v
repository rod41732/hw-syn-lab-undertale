`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/22/2020 01:35:28 PM
// Design Name: 
// Module Name: count_one
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


module count_one(
    bits, count
);
    parameter IN_BITS = 4;
    parameter OUT_BITS = 3;
    input wire [IN_BITS-1:0] bits;
    output reg [OUT_BITS-1:0] count;
    
    integer idx;
    always @* begin
      count = {OUT_BITS{1'b0}};  
      for( idx = 0; idx<IN_BITS; idx = idx + 1) begin
        count = count + bits[idx];
      end
    end
    
    
endmodule