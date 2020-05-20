`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Chulalonkorn University
// Engineer: Rodchananat Khunakornophat
// 
// Create Date: 04/11/2020 05:02:23 PM
// Design Name: 
// Module Name: road_uart_rx
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


module road_uart_rx(
    // input
    RX, CLK,
    // output
    OUT, TX_BYTE
    );
    
    input wire RX;
    input wire CLK;
    
    output reg OUT;
    output reg [7:0] TX_BYTE;
    
    reg [1:0] state = 0;
    // 0 = idle
    // 1 = recv
    // 2 = delay start
    reg [2:0] counter = 0;
    // count bit to recv
    
    // state machine
    always @(posedge CLK) begin
        if (state == 0) begin
            if (RX == 0) begin
                state = 1;
                counter = 0;
            end else state = 0; 
        end else if (state == 1) begin 
            if (counter == 7) begin
                counter = 0;
                state = 2;
            end else begin 
                counter = counter + 1;
            end
        end else if (state == 2) begin
            state = 0;
        end
    end
        
    always @(posedge CLK) begin
        if (state == 0) begin
            OUT = 0;
        end else if (state == 1) begin 
            TX_BYTE[counter] = RX;
            OUT = 0;
        end else if (state == 2) begin
            OUT = 1;
        end
    end
    
endmodule
