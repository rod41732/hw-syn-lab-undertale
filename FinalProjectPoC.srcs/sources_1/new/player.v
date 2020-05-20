`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2020 09:36:38 PM
// Design Name: 
// Module Name: player
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


module player(
    cx,
    cy,
    px,
    py,
    rgb
    );
    
    parameter size = 10; // circle size
    parameter BUS_WIDTH = 12; // set equal to size of color
    
    input wire [9:0] cx;
    input wire [9:0] cy;
    input wire [9:0] px;
    input wire [9:0] py;
    output wire [BUS_WIDTH-1:0] rgb;

    wire [19:0] dist;

    assign dist = {10'b0, (cx>px ? cx-px: px-cx)}**2 + {10'b0, (cy>py ? cy-py: py-cy)}**2;
    assign rgb = dist <= 20'd100 ? 5'd1: 5'd0; 
    
endmodule
