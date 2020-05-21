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

    reg [7:0] fakeCounter;
    reg pTransmit;
    reg [7:0] offsetX, offsetY;
    reg [7:0] posiX = 10, posiY = 10; // position on map
    
    reg oldPosX, oldPosY;
    reg [BUS_WIDTH-1:0] rgb_reg; 

    // trigger enemy
    always @(posedge clk) begin
        if (!pTransmit && transmit) begin 
            if (tx_buf == 8'h57) posY = posY - 1; // w 
            else if (tx_buf == 8'h53) posY = posY + 1; // s
            else if (tx_buf ==  8'h41) posX = posX - 1; // a
            else if (tx_buf ==  8'h44) posX = posX + 1; // d
        end
        
        // render
        offsetX = posX/40*40;
        offsetY = posY/30*30;
        posiX = offsetX + x/8;
        posiY = offsetY + y/8; 

        // render just map
        if ((posiX == 0 || posiX == 160) && (0 <= posiY && posiY <= 120) ||
                 (posiY == 0 || posiY == 120) && (0 <= posiX && posiX <= 160)) begin
            rgb_reg = 3;
        end
        // fake circles
        else if ({10'd0, posiX > 30 ? posiX-30: 30-posiX}**2 + {10'd0, posiY > 10 ? posiY-10: 10-posiY}**2 <= 66) begin
            rgb_reg = 5;
        end
        else if ({10'd0, posiX > 10 ? posiX-10: 10-posiX}**2 + {10'd0, posiY > 30 ? posiY-30: 30-posiY}**2 <= 49) begin
            rgb_reg = 2;
        end
        else if ({10'd0, posiX > 30 ? posiX-30: 30-posiX}**2 + {10'd0, posiY > 50 ? posiY-50: 50-posiY}**2 <= 30) begin
            rgb_reg = 2;
        end
        else if ({10'd0, posiX > 70 ? posiX-70: 70-posiX}**2 + {10'd0, posiY > 35 ? posiY-35: 35-posiY}**2 <= 100) begin
            rgb_reg = 3;
        end
        else if ({10'd0, posiX > 100 ? posiX-100: 100-posiX}**2 + {10'd0, posiY > 35 ? posiY-35: 35-posiY}**2 <= 26) begin
            rgb_reg = 3;
        end
        else if ({10'd0, posiX > 100 ? posiX-100: 100-posiX}**2 + {10'd0, posiY > 55 ? posiY-55: 55-posiY}**2 <= 43) begin
            rgb_reg = 4;
        end
        // hardcode enemy
        else if (posiX == 15 && posiY == 10 || posiX == 12 && posiY == 54 || posiX == 27 && posiY == 33 ||
            posiX == 70 && posiY == 20 || posiX == 57 && posiY == 57) begin
            rgb_reg = 6;
        end
        else begin
            rgb_reg = 0;
            // encounter = 0;
        end
            
        // player logic
        if (posiX == posX && posiY == posY) begin
            // enemy detection
            if (posiX == 15 && posiY == 10 || posiX == 12 && posiY == 54 || posiX == 27 && posiY == 33 ||
            posiX == 70 && posiY == 20 || posiX == 57 && posiY == 57)
                encounter = 1;

            // roll back logic
            if (rgb_reg != 0) begin
                posX = oldPosX;
                posY = oldPosY;
            end
            else begin
                rgb_reg = 1;
                oldPosX = posX;
                oldPosY = posY;
            end
            
        end
        else 
            encounter = 0;

        rgb = rgb_reg;
        // render player and check collision
        pTransmit = transmit;
    end

    

    



endmodule
