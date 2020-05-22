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
        clk,
        gameClk,
        gameState,
        salt,
        hitEnemy,
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
    parameter SIZE_SQ = 64;

    // reg [9:0] x = minX, y = minY;
    input wire clk;
    input wire gameClk;
    input wire [3:0] gameState;
    input wire [15:0] salt;
    input wire hitEnemy;
    input wire [9:0] px, py;
    reg [2:0] vx, vy; // control axis
    output wire [COLOR_WIDTH-1:0] rgb; 

    reg [9:0] x, y;
    wire [15:0] numberX, numberY, numberVX, numberVY;

    // seed for randomize
    parameter seed = 255;

    rng #(.seed(seed + 2178)) rngX(gameClk, salt, numberX);
    rng #(.seed(seed + 9801)) rngY(gameClk, salt, numberY);
    rng #(.seed(seed + 3890)) rngVX(gameClk, salt, numberVX);
    rng #(.seed(seed + 1942)) rngVY(gameClk, salt, numberVY);

    reg right = 1, down = 1;
    reg hasHit = 0; // if hit don't show
    reg pGameClk, pHit, pState;


    always @(posedge clk) begin

        if (!pGameClk && gameClk) begin
            if (x == minX) right = 1;
            else if (x == maxX) right = 0;

            if (y == minY) down = 1;
            else if (y == maxY) down = 0;

            x = right ? x+vx : x-vx;
            y = down ? y+vy : y-vy;
            
            if (x < minX) x = minX;
            if (x > maxX) x = maxX;
            if (y < minY) y = minY;
            if (y > maxY) y = maxY;
        end

        if (!pHit && hitEnemy)
            hasHit = 1;
        
        // do something when enter that state
        if (pState != 0 && gameState == 0) begin
            // re-random position and speed;
            x = minX + numberX%(maxX-minX+1);
            y = minY + numberY%(maxY-minY+1);
            vx = numberVX%4;
            vy = numberVY%4;
            
            if (vx == 0 && vy == 0) begin
                vx = 1;
                vy = 1;
            end
            
            // resetHit
            hasHit = 0;
        end

        pGameClk = gameClk;
        pHit = hitEnemy;
        pState = gameState;
    end 

    wire [19:0] dist;
    assign dist = {10'b0, px>x ? px-x : x-px}**2 + {10'b0, py>y ? py-y : y-py}**2;
    assign rgb = (!hasHit && dist <= SIZE_SQ) ? 5'h2 : 5'd0; // red

endmodule
