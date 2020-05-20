`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2020 05:02:05 PM
// Design Name: 
// Module Name: test_controller
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


module test_controller();
    reg clk;
    wire [9:0] playerX, playerY;
    wire [18:0] readAddr, writeAddr;
    wire [11:0] playerRGB, din;
    
    vga_controller vga_ctrl(
        clk, 0,
        playerX, playerY, playerRGB,
        
        writeAddr, din, we, ra, dout
    );
    
    player player1(10'd10, 10'd0, 10'd10, 10'd0, playerRGB);
    
    initial begin 
        clk = 0;

        $monitor("T: %3d X: %3d  Y:%3d  RGB:%3d Write:%d Enable:%d WAddr:%d\n", $time, playerX, playerY, playerRGB, din, we, writeAddr);
        
        #10000 $finish;
    end
    
    always #1 clk = ~clk;
    
    
     
    
    
    
endmodule
