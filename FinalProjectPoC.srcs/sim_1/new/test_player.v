`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2020 05:18:25 PM
// Design Name: 
// Module Name: test_player
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


module test_player();
    
    reg [9:0] cx = 9'd100, cy = 9'd100, px = 9'd90, py = 9'd90; // param
    wire [11:0] rgb;
    
    player player1(cx, cy, px, py, rgb);
    
    initial begin
        
    
        $monitor("T%4d: %4d %4d %4d", $time, px, py, rgb);
        
        #450
        $finish;
    end
    
    always #1
        px = (px == 110) ? 90 : px + 1;
    always #21
        py = py + 1;
       
    
    
endmodule
