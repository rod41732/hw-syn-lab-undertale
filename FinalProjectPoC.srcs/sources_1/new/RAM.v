`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2020 05:06:34 PM
// Design Name: 
// Module Name: RAM
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


module RAM(
    writeAddr,
    readAddr,
    din,
    writeClk,
    readClk,
    we,
    // input en,
    // input rstb,
    // input outEnb,
    dout
);    
  //  Xilinx Simple Dual Port 2 Clock RAM
  //  This code implements a parameterizable SDP dual clock memory.
  //  If a reset or enable is not necessary, it may be tied off or removed from the code.

  parameter RAM_WIDTH = 8;                  // Specify RAM data width
  parameter RAM_DEPTH = 307200;                  // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "LOW_LATENCY"; // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  parameter INIT_FILE = "";                       // Specify name/location of RAM initialization file if using one (leave blank if not)
    
  // dont know why it error and i need to HARD CODE ram width
  input wire [18:0] writeAddr; // Write address bus, width determined from RAM_DEPTH
  input wire [18:0] readAddr; // Read address buses, width determined from RAM_DEPTH
  input wire [RAM_WIDTH-1:0] din;          // RAM input data
  input wire writeClk;                          // Write clock
  input wire readClk;                          // Read clock
  input wire  we;                           // Write enable
  wire  en;                           // Read Enable, for additional power savings, disable when not in use
  wire  rstb;                          // Output reset (does not affect memory contents)
  wire  outEnb;                        // Output register enable
  output wire [RAM_WIDTH-1:0] dout;                 // RAM output data

  reg [RAM_WIDTH-1:0] RAM_BLOCK [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] RAM_DATA = {RAM_WIDTH{1'b0}};
  // ROAD: always enable RAM
  assign en = 1;
  assign rstb = 0;
  assign outEnb = 1;

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, RAM_BLOCK, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          RAM_BLOCK[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge writeClk)
    if (we)
      RAM_BLOCK[writeAddr] <= din;

  always @(posedge readClk)
    if (en) begin
      RAM_DATA <= RAM_BLOCK[readAddr];
    end
  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign dout = RAM_DATA;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};

      always @(posedge readClk)
        if (rstb)
          doutb_reg <= {RAM_WIDTH{1'b0}};

        else if (outEnb)
          doutb_reg <= RAM_DATA;

      assign dout = doutb_reg;

    end
  endgenerate

		
						
endmodule