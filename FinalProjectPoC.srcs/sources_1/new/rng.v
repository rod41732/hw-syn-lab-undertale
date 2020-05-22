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
        salt,
        number
    );
    
   input wire clk;
   input wire [15:0] salt;
   output reg [15:0] number;
    
    parameter seed = 10;
    
    parameter a = 16'd30234;
    parameter b = 16'd4960;
    parameter c = 16'd30411;
    parameter d = 16'd19492;
    parameter e = 16'd21234;
    
    initial begin
        number = seed;
    end
    
    always @(posedge clk) begin
        // just random messy formula
        number = (((a-salt)*(number+salt) - b*salt)^d)%c + (e*number*salt + a - salt)%d;
    end
endmodule
