`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/19/2020 08:24:09 PM
// Design Name: 
// Module Name: enemy
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


module enemy(
        gameClk,
        vx,
        vy,
        px,
        py,
        rgb
    );

    parameter minX = 10'd240;
    parameter minY = 10'd240;
    parameter maxX = 10'd400;
    parameter maxY = 10'd420;

    parameter initX = minX;
    parameter initY = minY;

    parameter COLOR_WIDTH = 12;
    parameter SIZE_SQ = 100;

    reg [9:0] x = initX, y = initY;
    // reg [9:0] x = minX, y = minY;
    input wire gameClk;
    input wire [9:0] px, py;
    input wire vx, vy; // control axis
    output wire [COLOR_WIDTH-1:0] rgb; 


    reg right = 1, down = 1;

    always @(posedge gameClk) begin
        if (x == minX) right = 1;
        else if (x == maxX) right = 0;

        if (y == minY) down = 1;
        else if (y == maxY) down = 0;

        if (vx)
            x = right ? x+1 : x-1;
        if (vy)
            y = down ? y+1 : y-1;
    end 

    wire [19:0] dist;
    assign dist = {10'b0, px>x ? px-x : x-px}**2 + {10'b0, py>y ? py-y : y-py}**2;
    assign rgb = dist <= SIZE_SQ ? 5'h2 : 5'd0; // red

endmodule
