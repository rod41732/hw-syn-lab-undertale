`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2020 05:25:34 PM
// Design Name: 
// Module Name: test_block_RAM
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

// test wheter block ram work correctly
module test_block_RAM(

    );
    
    reg [18:0] readAddr, writeAddr;
    reg [7:0] dataIn;
    wire [7:0] dataOut;
    reg readClk, writeClk, din, we, en, rstb, outEnb;
    
    RAM ram(
        writeAddr,
        readAddr,
        dataIn,
        readClk,
        writeClk,
        we,
        en,
        rstb,
        outEnb,
        dataOut
    );
    
     
    initial begin
        readClk = 0;
        writeClk = 0; 
        we = 0;
        en = 1;
        rstb = 1;
        outEnb = 1;
        
        #10
        rstb = 0;
        we = 1;
        writeAddr = 0;
        dataIn = 8'hff;
        
        #20 
        readAddr = 0;
        
        #20
        $display("MEM[%d] = %d\n", readAddr, dataOut);    
    end
    
    
    always #1 begin
        readClk = ~readClk;
        writeClk = ~writeClk; 
    end
    
    
    
endmodule
