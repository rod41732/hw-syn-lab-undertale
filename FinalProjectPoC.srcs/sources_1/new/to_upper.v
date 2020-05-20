`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Chulalonkorn University
// Engineer: Rodchananat Khunakornophat
// 
// Create Date: 04/11/2020 05:58:55 PM
// Design Name: 
// Module Name: to_upper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Convert letter to uppercase 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.041732 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module to_upper(
        OUT,
        IN
    );
    output wire [7:0] OUT;
    input wire [7:0] IN;
    
    
    wire isLower = (8'h61 <= IN && IN <= 8'h7a);
    
    //              if space --> Z
    assign OUT = isLower ? IN - 32 : IN;
    
endmodule
