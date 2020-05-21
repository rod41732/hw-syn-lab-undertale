`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2020 12:38:02 PM
// Design Name: 
// Module Name: vga_test
// Project Name: VGA testing circuit
// Target Devices: 
// Tool Versions: 
// Description: Display circle on (cx, cy)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// emit X, Y for TOP to read color and send to VGA
module vga_timer
	(
		input clk, 
        input reset,
		output hsync,
        output vsync,
        output video_on,
        // wire used to control RAM read of TOP
        output x,
        output y
	);

    wire clk;
    wire reset;
    wire hsync;
    wire vsync;
    wire video_on;
    wire [9:0] x;
    wire [9:0] y;

	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;
    reg [19:0] dist;
       
        
    // instantiate vga_sync
    vga_sync vga_sync_unit (.clk(clk), .reset(reset), .hsync(hsync), .vsync(vsync),
                            .video_on(video_on), .p_tick(), .x(x), .y(y));
    
endmodule