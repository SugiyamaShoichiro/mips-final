`timescale 1ns/1ns
`include "register.v"

module regm_test;

   reg clk;
   reg reset;
   reg [4:0] addr_1;
   reg [4:0] addr_2;
   reg [4:0] wb_addr;
   reg [31:0] wb_data;
   reg 		  write;

   wire [31:0] data_1;
   wire [31:0] data_2;

   parameter RATE = 100;

   register register(
					 .clk(clk),
					 .reset(reset),
					 .addr_1(addr_1),
					 .addr_2(addr_2),
					 .wb_addr(wb_addr),
					 .wb_data(wb_data)
					 .write(write),

					 .data_1(data_1),
					 .data_2(data_2)
					 );

   always #(RATE/2) clk = ~clk;

   initial begin
	  #(0)
	  clk = 0;
	  reset = 0;
	  
