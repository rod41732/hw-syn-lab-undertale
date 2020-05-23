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
    gameClk,
    transmit,
    tx_buf,
    gameState,

    px,
    py,
    rgb
    );
    
    parameter size = 19'd64; // circle size
    parameter BUS_WIDTH = 12; // set equal to size of color
    
    input wire gameClk;
    input wire clk;
    input wire transmit;
    input wire [7:0] tx_buf;
    input wire [3:0] gameState;

    input wire [9:0] px;
    input wire [9:0] py;
    output wire [BUS_WIDTH-1: 0] rgb;
    reg [BUS_WIDTH-1:0] rgb_reg;
    
    // position
    reg [9:0] cx = 320;
    reg [9:0] cy = 240;


    localparam GRAVITY = 10'd2;
    localparam JUMP_STRENGTH = 10'd20;
    reg [9:0] vy = 128; //  

    // heartMode; // 0 = red, 1 = blue 
    wire [15:0] randMode;
    wire [15:0] salt = 16'd6174;
    rng #(.seed(4173)) randomMode(clk, salt, randMode);
    

    reg gameMode;
    reg pGameClk;

    // reg for polling
    reg pTransmit;
    reg [3:0] pGameState;

    always @(posedge clk) begin

        // move player only in dodge mode
        if (!pTransmit && transmit && gameState == 0) begin
            
            if (tx_buf == 8'h57) begin //w
                if (gameMode == 0)
                    cy <= cy >= 10'd250 ? cy - 10'd10 : 10'd240; // w 
                else if (cy == 10'd420) // bottom 
                    vy <= JUMP_STRENGTH + 128;
            end
            // else if (tx_buf == 8'h53) cy <= cy <= 410 ? cy + 10 : 420 ; // s
            else if (tx_buf == 8'h53) begin //s
                if (gameMode == 0)
                    cy <= cy <= 10'd410 ? cy + 10'd10 : 10'd420 ; // s
            end
            else if (tx_buf ==  8'h41) cx <= cx >= 10'd250 ? cx - 10'd10 : 10'd240; // a
            else if (tx_buf ==  8'h44) cx <= cx <= 10'd390 ? cx + 10'd10 : 10'd400; // d
        end

        if (pGameState != 0 && gameState == 0) begin
            gameMode <= randMode[0:0];
        end

        if (gameClk && !pGameClk) begin
            if (gameMode == 1) begin
                if (cy == 10'd420)
                    vy <= 128;
                else
                    vy <= vy + GRAVITY > 192 ? 192 : vy + GRAVITY;
                if (cy+vy-128 <= 240) cy <= 10'd240;
                else if (cy+vy-128 >= 420) cy <= 10'd420;
                else cy <= cy+vy-128;
            end
        end

        pGameState <= gameState;
        pTransmit <= transmit;
        pGameClk <= gameClk;
    end
    
    wire [19:0] dist;

    assign dist = {10'b0, (cx>px ? cx-px: px-cx)}**2 + {10'b0, (cy>py ? cy-py: py-cy)}**2;
    
    assign rgb = dist <= size ? (gameMode ? 5'd12 : 5'd1) : 5'd0;  // blue or red depend on mode;;
    // always @(posedge clk)
    //     rgb_reg = dist <= size ? (heartmode? 5'd12 : 5'd1): 5'd0;  // blue or red depend on mode;
    // assign rgb = rgb_reg;
    
endmodule
