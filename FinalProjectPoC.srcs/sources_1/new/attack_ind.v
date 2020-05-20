`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2020 10:51:00 PM
// Design Name: 
// Module Name: attack_ind
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


module attack_ind(
    gameClk, // auto driven by gameclk
    x,
    y,
    rgb,
    damage
);
    parameter BUS_WIDTH = 12;
    parameter TOP = 330;
    parameter LEFT = 240;
    parameter RIGHT = 400;
    parameter THICCNESS = 3;
    parameter HEIGHT = 30;

    input wire gameClk; // auto driven by gameclk
    input wire [9:0] x;
    input wire [9:0] y;
    output reg [BUS_WIDTH-1:0] rgb;
    output reg [7:0] damage;


    wire [9:0] middle = (LEFT+RIGHT)/2; // to lzay to declare param

    reg [9:0] markerPos = LEFT;
    reg right = 0;

    always @(posedge gameClk) begin
        if (markerPos == LEFT) right = 1;
        else if (markerPos == RIGHT) right = 0;

        markerPos = right ? markerPos + 1 : markerPos - 1;
    end


    always @(*) begin
        if (markerPos-THICCNESS <= x && x <= markerPos+THICCNESS &&
            TOP-HEIGHT <= y && y <= TOP+HEIGHT
        ) rgb = 5'd3;
        else 
            if (TOP-THICCNESS <= y && y <= TOP+THICCNESS)
                if ((middle > x ? middle - x : x - middle) <= 30)
                    rgb = 5'd4;
                else if ((middle > x ? middle - x : x - middle) <= 45)
                    rgb = 5'd1;
                else if ((middle > x ? middle - x : x - middle) <= 65)
                    rgb = 5'd6;
                else 
                    rgb = 5'd0;
        if ((middle > x ? middle - x : x - middle) <= 30)
            damage = 8'd40;
        else if ((middle > x ? middle - x : x - middle) <= 45)
            damage = 8'd30;
        else if ((middle > x ? middle - x : x - middle) <= 65)
            damage = 8'd15;
    end

endmodule
