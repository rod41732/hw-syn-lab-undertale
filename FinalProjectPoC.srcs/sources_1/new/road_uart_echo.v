`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Chulalonkorn University
// Engineer: Rodchananat Khunakornophat
// 
// Create Date: 04/11/2020 06:04:36 PM
// Design Name: 
// Module Name: road_uart_echo
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


module road_uart_echo(
        RX, TX, CLK,
        TX_BYTE, TRANSMIT // expose byte data  
    );
    
    input RX;
    input CLK;
    output TX;
    output wire [7:0] TX_BYTE;
    output wire TRANSMIT;
    
    
    // intermediates
   
    wire [7:0] tx_byte;
    wire [7:0] tx_upper;
    wire out;
    
    assign TX_BYTE = tx_upper;
    assign TRANSMIT = out;
    
    // modules
    
    road_uart_rx receiver(
        .CLK(CLK),
        .RX(RX),
        .TX_BYTE(tx_byte),
        .OUT(out)
    );
    
    to_upper upper_module(
        tx_upper,
        tx_byte
    );


    // ------------ extra logics
    
    // transmit only 'WASDCMY '
    wire shouldTransmit = out & (
        tx_upper == 8'h43 ||
        tx_upper == 8'h4d ||
        tx_upper == 8'h59 ||
        tx_upper == 8'h20 ||
        tx_upper == 8'h57 ||
        tx_upper == 8'h53 ||
        tx_upper ==  8'h41 ||
        tx_upper ==  8'h44
    );

    // transmit Z instead of space
    wire [7:0] tx_actual = tx_upper == 8'h20 ? 8'h20 : tx_upper;
    
    road_uart_tx transmitter(
        .CLK(CLK),
        .TRANSMIT(shouldTransmit),
        .RX_BYTE(tx_actual),
        .TX(TX)
    );
    
endmodule
