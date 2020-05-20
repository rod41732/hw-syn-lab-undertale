`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2020 09:41:01 PM
// Design Name: 
// Module Name: test-math
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


module test_math();
    reg [9:0] a = 10'd240;
    reg [7:0] hp = 70, maxHp = 254; 
    parameter x = 240, y = 420;
    
    
    wire [9:0] playerThres = hp*(y-x)/maxHp+x;
    initial begin
        #10;
        $display("Thres = %d\n", playerThres);
    
        $monitor("T:%d: a = %d --> %d < %d --> %d?", $time, a, hp*(y-x), (a-x)*maxHp, hp*(y-x) < (a-x)*maxHp);
        #180
        $finish;
    end
    
    always #1 a = a+1;
endmodule
