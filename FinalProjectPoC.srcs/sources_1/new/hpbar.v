`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2020 05:42:31 PM
// Design Name: 
// Module Name: hpbar
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


module hpbar(
    input [9:0] x,
    input [9:0] y,
    input [7:0] hp,
    input [7:0] maxHp,
    input [7:0] enemyHp,
    input [7:0] maxEnemyHp,
    output [4:0] rgb
    );
    // 20 280 40 280 20
    localparam PXMIN = 20;
    localparam PXMAX = 300;
    localparam EXMIN = 340;
    localparam EXMAX = 620;
    localparam YMIN = 440;
    localparam YMAX = 450;

    assign inBoundY = YMIN <= y && y <= YMAX;
    wire [9:0] playerThres = hp*(PXMAX-PXMIN)/maxHp + PXMIN;
    wire [9:0] enemyThres = enemyHp*(EXMAX-EXMIN)/maxEnemyHp + EXMIN;

    reg [4:0] result;

    always @(*) begin
        if (inBoundY) begin
            if (PXMIN <= x && x <= playerThres) result = 5'd4;
            else if (playerThres < x && x <= PXMAX) result = 5'd5;
            else if (EXMIN <= x && x <= enemyThres) result = 5'd6;
            else if (enemyThres < x && x <= EXMAX) result = 5'd7;
            else result = 0; 
        end
        else 
            result = 0;
    end

    assign rgb = result;



endmodule
