`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Chulalonkorn University
// Engineer: Rodchananat Khunakornophat
// 
// Create Date: 04/10/2020 04:40:49 PM
// Design Name: 
// Module Name: top module for LAB 6:
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


module top(
        input wire clk,
		input wire rx,
		output wire tx,
		output wire hsync, vsync,
		output wire [11:0] rgb,// display
		output wire [6:0] seg,
		output wire [3:0] an
    );

	localparam BUS_WIDTH = 5; // equal to RAM width = RGB pixel size

	// display logics
	wire [7:0] tx_byte;
	wire transmit;
	
	reg [15:0] display = 0;
	wire [15:0] debugOutput;
	
	reg [7:0] tx_buf;

	always @(posedge transmit) begin
	// 	display[15:8] <= tx_byte;
		tx_buf <= tx_byte;
	// 	display[7:0] <= display[7:0] + 1;
	end	
	
	// 1666666/2 = 60 FPS, more divide = less FPS
	clockDiv #(.maxCount(1666666/2)) gameDiv(gameClk, clk);
	
	clockDiv #(.maxCount(1666666)) _30FPSdiv(thirty, clk);


	wire [9:0] pixelX, pixelY;

	wire [BUS_WIDTH-1:0] dataIn, dataOut;
	wire [18:0] writeAddr, readAddr;
	wire we;

	// display stuff
	assign readAddr = 10'd640*{10'b0, pixelY} + pixelX;
	colorLUT colorMap(dataOut, rgb); 

	// it's now game controller
	vga_controller #(.BUS_WIDTH(BUS_WIDTH)) vga_ctrl(
		clk,
		gameClk,

		// playerWire
		tx_buf,
		transmit,

		writeAddr,
		dataIn,
		we,

		debugOutput
	);

	RAM #(.RAM_WIDTH(BUS_WIDTH)) ram(
		.writeAddr(writeAddr),
		.readAddr(readAddr),
		.din(dataIn),
		.readClk(clk),
		.writeClk(clk),
		.we(we),
		.dout(dataOut)
	);
	
	// circuit that render player model based on supplied px, py

    
    reg reset = 1;
    // let some time for reset to be 1
    always @(negedge clk) begin
        reset = 0;
    end
    
    
    // circuit for generating x, y position for display
	vga_timer vga_timer_module(
		.clk(clk),
		.reset(reset),
		.hsync(hsync),
		.vsync(vsync),
		.x(pixelX),
		.y(pixelY)
	);


	// ----------------------- DEBUG

    // UART module for keyboard input
    clockDiv #(.maxCount(868/2)) uartDiv(uartClk, clk);
    road_uart_echo echo(
        .CLK(uartClk),
        .RX(rx),
        .TX(tx),
        .TX_BYTE(tx_byte),
        .TRANSMIT(transmit)
    );
   

	always @(posedge thirty) begin
		display <= debugOutput;
	end

    // 7-seg display module for debug
	clockDiv #(.maxCount(50000)) display_div(displayClk, clk);
	hexDisplay display_module(
	      seg, __dp, an,
	      display[3:0], display[7:4], display[11:8], display[15:12], displayClk
	);

endmodule
