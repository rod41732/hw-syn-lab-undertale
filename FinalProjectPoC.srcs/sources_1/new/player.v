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
    clk,
    transmit,
    tx_buf,
    gameState,

    px,
    py,
    rgb
    );
    
    parameter size = 10; // circle size
    parameter BUS_WIDTH = 12; // set equal to size of color
    
    input wire clk;
    input wire transmit;
    input wire [7:0] tx_buf;
    input wire [3:0] gameState;

    input wire [9:0] px;
    input wire [9:0] py;
    output wire [BUS_WIDTH-1:0] rgb;
    
    // position
    reg [9:0] cx = 320;
    reg [9:0] cy = 240;

    // reg for polling
    reg pTransmit;
    reg [3:0] pGameState;

    always @(posedge clk) begin

        // move player only in dodge mode
        if (!pTransmit && transmit && gameState == 0)
            if (tx_buf == 8'h57) cy <= cy >= 10 ? cy - 10 : 0; // w 
            else if (tx_buf == 8'h53) cy <= cy <= 410 ? cy + 10 : 420 ; // s
            else if (tx_buf ==  8'h41) cx <= cx >= 10 ? cx - 10 : 0; // a
            else if (tx_buf ==  8'h44) cx <= cx <= 390 ? cx + 10 : 400; // d

        pGameState = gameState;
        pTransmit <= transmit;
    end


    

    wire [19:0] dist;

    assign dist = {10'b0, (cx>px ? cx-px: px-cx)}**2 + {10'b0, (cy>py ? cy-py: py-cy)}**2;
    assign rgb = dist <= 20'd100 ? 5'd1: 5'd0; 
    
endmodule
