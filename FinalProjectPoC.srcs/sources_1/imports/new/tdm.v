module tdm(num, an, num1, num2, num3, num4, clk);
output reg[3:0] num;
output reg[3:0] an;
// hex inputs
input [3:0] num1;
input [3:0] num2;
input [3:0] num3;
input [3:0] num4;
input clk;

reg [1:0] counter;
reg cout;

initial begin 
    counter = 3'b000;
end

always @(posedge clk) begin
    counter = counter + 1;
end

always @(counter) begin
    case (counter)
        2'b00: an = 4'b0001;
        2'b01: an = 4'b0010;
        2'b10: an = 4'b0100;
        2'b11: an = 4'b1000;
    endcase
end
always @(counter or num4 or num3 or num2 or num1) begin
    case (counter)
        2'b00: num = num1;
        2'b01: num = num2;
        2'b10: num = num3;
        2'b11: num = num4;
    endcase
end
endmodule