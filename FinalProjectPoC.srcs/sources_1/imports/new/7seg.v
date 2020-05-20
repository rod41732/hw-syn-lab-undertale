// 7-segment encoding
//      0
//     ---
//  5 |   | 1
//     --- <--6
//  4 |   | 2
//     ---
//      3

module hexTo7seg(seg, hex);
input wire[3:0] hex;
output reg [6:0] seg;

   always @(hex)
      case (hex)
        4'b0001 : seg  = 7'b1111001;   // 1
        4'b0010 : seg = 7'b0100100;   // 2
        4'b0011 : seg = 7'b0110000;   // 3
        4'b0100 : seg = 7'b0011001;   // 4
        4'b0101 : seg = 7'b0010010;   // 5
        4'b0110 : seg = 7'b0000010;   // 6
        4'b0111 : seg = 7'b1111000;   // 7
        4'b1000 : seg = 7'b0000000;   // 8
        4'b1001 : seg = 7'b0010000;   // 9
        4'b1010 : seg = 7'b0001000;   // A
        4'b1011 : seg = 7'b0000011;   // b
        4'b1100 : seg = 7'b1000110;   // C
        4'b1101 : seg = 7'b0100001;   // d
        4'b1110 : seg = 7'b0000110;   // E
        4'b1111 : seg = 7'b0001110;   // F
        default : seg = 7'b1000000;   // 0
      endcase			
endmodule