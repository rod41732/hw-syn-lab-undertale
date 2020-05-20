module clockDiv(out, clk);
input clk;
output reg out;

reg[32:0] counter;
// number of clock to divide
parameter maxCount = 2;

initial begin
   counter = 0;
   out = 0;
end

always @(posedge clk) begin
    if (counter == maxCount - 1)
       counter <= 0;
    else 
       counter <= counter + 1;
end


always @(posedge clk) begin 
    if (counter == maxCount - 1)
        out <= ~out;
end


endmodule