`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Chulalonkorn University
// Engineer: Rodchananat Khunakornophat
// 
// Create Date: 04/11/2020 05:39:51 PM
// Design Name: 
// Module Name: uart_transmitter
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

module road_uart_tx(
        // input
        RX_BYTE, TRANSMIT, CLK,
        // output
        TX
    );
    
    input wire [7:0] RX_BYTE;
    input wire TRANSMIT;
    input wire CLK;
    
    output reg TX;
    
    
    reg [1:0] state;
    reg [2:0] counter;
    // 0 = idle
    // 1 = start bit
    // 2 = tx
    // 3 = stop bit
    
    // state machine 
    always @(posedge CLK) begin
        if (state == 0) begin
            state = TRANSMIT;
            counter = 0;
        end else if (state == 1) state = 2;
        else if (state == 2) begin
            if (counter == 7) state = 3;
            else counter = counter + 1;
        end else state = 0;
    end
    
    // logic
    always @(posedge CLK) begin
        if (state == 0) TX = 1;
        else if (state == 1) TX = 0;
        else if (state == 2) begin
            TX = RX_BYTE[counter];
        end else TX = 1; // idle
    end
    
endmodule
