`timescale 1ns/1ns
`include "memory.v"

module mem_test;

   reg clk;
   reg reset;
   reg [31:0] i_addr;
   reg [31:0] d_addr;
   reg 		  i_enable;
   reg 		  d_enable;
   reg 		  i_write;
   reg 		  d_write;
   reg [1:0]  data_width;

   wire [31:0] instruction;
   wire [31:0] data;

   parameter RATE = 100;

   memory memory(
			.clk(clk),
			.reset(reset),
			.i_addr(i_addr),
			.d_addr(d_addr),
			.i_enable(i_enable),
			.d_enable(d_enable),
			.i_write(i_write),
			.d_write(d_write),
			.data_width(data_width),

			.instruction(instruction),
			.data(data)
			);

   always #(RATE/2) clk = ~clk;

   initial begin
	  #(0)
	  clk = 0;
	  reset = 0;
	  i_enable = 1;
	  i_write = 0;
	  d_enable = 0;
	  i_addr = 32'h10000;

	  #(RATE)
	  i_addr = i_addr + 4;
	   
	  #(RATE)
	  i_addr = i_addr + 4;

	  #(RATE)
	  $finish;

   end // initial begin

   initial
	 $monitor($stime, "clk = %b reset = %b i_addr = %5d instruction = %8h", clk, reset, i_addr, instruction);
   
	  
	  
endmodule
