`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/22/2020 03:11:23 PM
// Design Name: 
// Module Name: gameover
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


module gameover(
        x, y, rgb
    );
    
    parameter BUS_WIDTH = 12;
    
    reg [0:0] ROM [25599:0]; // 320*80
    input wire [9:0] x, y;
    output wire [BUS_WIDTH-1: 0] rgb; 
    
    
    initial begin
        $readmemh("gameover.mem", ROM);
    end
    
    assign rgb = (160 <= x && x < 480 && 200 <= y && y < 280) ? (ROM[(y-200)*320+x-160] ? 3 : 1) : 0;
    
endmodule
