`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/20/2020 05:18:01 PM
// Design Name: 
// Module Name: colorLUT
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


module colorLUT(
    input [4:0] colorID,
    output [11:0] color
    );

    reg [11:0] COLOR_MAP [0:31];
    initial begin
        COLOR_MAP[0] = 12'h000; // black
        COLOR_MAP[1] = 12'hff0; // player dot - yellow
        COLOR_MAP[2] = 12'hf00; // enemy dot - red
        COLOR_MAP[3] = 12'hddd; // border - grey
        COLOR_MAP[4] = 12'h0f2; // player HP - filled, green
        COLOR_MAP[5] = 12'h050; // player HP - empty, dark-green
        COLOR_MAP[6] = 12'hf50; // player HP - filled, orange
        COLOR_MAP[7] = 12'h510; // player HP - empty, dark-brown
        COLOR_MAP[31] = 12'h222; // bg
     end    

    assign color = COLOR_MAP[colorID];
endmodule
