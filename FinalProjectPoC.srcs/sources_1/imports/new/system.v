module hexDisplay(seg, dp, an, num1, num2, num3, num4 , clk);
//parameter DIVIDE = 18;
output [6:0] seg;
output reg dp;
output [3:0] an;

input [3:0] num4;
input [3:0] num3;
input [3:0] num2;
input [3:0] num1;
input clk;

// temp vars
wire [18:0] div; 
wire [3:0] selectedNum;
wire dividedClk;
wire [3:0] temp_an;
assign an = ~temp_an;



//assign div[0] = clk;
//generate 
//for(c=0; c<DIVIDE; c=c+1) begin 
//    clockDiv cd(div[c+1], div[c]);
//end
//endgenerate
//assign dividedClk = div[DIVIDE];

clockDiv cd(dividedClk, clk);

tdm tdm1(selectedNum, temp_an, num1, num2, num3, num4, dividedClk);
hexTo7seg h2seg(seg, selectedNum);

initial begin 
    dp = 1;
end

endmodule