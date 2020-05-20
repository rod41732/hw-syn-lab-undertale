`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2020 08:27:37 PM
// Design Name: 
// Module Name: test_vga_timer
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


module test_vga_timer();
    reg clk, reset;
    wire hsync, vsync;
    wire [9:0] pixelX, pixelY;
    
    vga_timer vga_timer_module(
		.clk(clk),
//		.reset(0),
		.hsync(hsync),
		.vsync(vsync),
		.x(pixelX),
		.y(pixelY)
	);
	
	initial begin
	   clk = 0;
//	   reset = 1;
	   #10
//	   reset = 0;
	   $monitor("T:%d\t%d,%d", $time, pixelX, pixelY);
	   
	   #1000
	   $finish;
	end
	
	always #1 clk = ~clk;
endmodule
