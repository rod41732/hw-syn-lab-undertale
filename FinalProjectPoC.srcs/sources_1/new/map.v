`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/21/2020 11:36:52 AM
// Design Name: 
// Module Name: map
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


module map(
        // trigger input from keyboard
        clk, // for triggering only 1 tick
        transmit,
        tx_buf,
        // pixel position
        x,
        y,
        rgb,
        encounter // trigger when encounter enemy
    );

    parameter BLOCK_WIDTH = 8;
    parameter SCREEN_WIDTH = 80;
    parameter SCREEN_HEIGHT = 60;
    parameter BUS_WIDTH = 12;

    input wire clk;
    input wire transmit;
    input wire [7:0] tx_buf;
    input wire [9:0] x;
    input wire [9:0] y;
    output reg [BUS_WIDTH-1:0] rgb;
    output reg encounter;

    // TODO map array;

    reg [7:0] posX = 10, posY = 10;

    reg [4:0] fakeCounter;
    reg pTransmit;
    reg [7:0] offsetX, offsetY;

    // trigger enemy
    always @(posedge clk) begin
        if (!pTransmit && transmit) begin 
            if (tx_buf == 8'h57) posY = posY - 1; // w 
            else if (tx_buf == 8'h53) posY = posY + 1; // s
            else if (tx_buf ==  8'h41) posX = posX - 1; // a
            else if (tx_buf ==  8'h44) posX = posX + 1; // d
            if (fakeCounter == 15) begin
                fakeCounter = 0;
                encounter = 1;
            end
            else
                fakeCounter = fakeCounter + 1;
        end
        else 
            encounter = 0;
        
        // render
        offsetX = posX/80*80;
        offsetY = posY/60*60;

        if (offsetX + x/8 == posX && offsetY + y/8 == posY) begin
            rgb = 5'd1;
        end
        else if (offsetX+x/8 == 0 || offsetX+x/8 == 160 || offsetY+y/8 == 0 || offsetY+y/8 == 120) begin
            rgb = 5'd3;
        end
        else if (((offsetX+x/8) * 27 + 12)*(offsetY+y/8) % 29 == 13) begin
            rgb = 5'd4;
        end
        else rgb = 0;
        



        pTransmit = transmit;
    end

    



endmodule
