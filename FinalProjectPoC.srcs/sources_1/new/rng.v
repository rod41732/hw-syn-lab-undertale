`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Rodchananat Khunakornophat
// 
// Create Date: 05/22/2020 10:04:51 AM
// Design Name: Pseudo Random number generator 
// Module Name: rng
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: generate random 32 bit number on each clock
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rng(
        clk,
        number
    );
    
   input wire clk;
   output reg [31:0] number;
    
    parameter seed = 10;
    
    parameter a = 2390234;
    parameter b = 124960;
    parameter c = 870411;
    parameter d = 7239492;
    parameter e = 6041234;
    
    initial begin
        number = seed;
    end
    
    always @(posedge clk) begin
        number = ((a*number - b)^d)%c + (e*number + a)%d;
    end
endmodule
