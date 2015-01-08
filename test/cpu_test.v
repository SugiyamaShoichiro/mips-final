`timescale 1ns/1ns
`include "cpu.v"

module cpu_test;

   reg clk;
   reg reset;
   reg start;
   reg program_load;
   reg 	   halt;
   reg [31:0] instruction;
   wire 	   i_write;
   wire 	   i_enable;

   parameter RATE = 100;
   
   if_stage if_stage(
					 .clk(clk),
					 .reset(reset),
					 .npc(npc),
					 .pc(pc),
					 .pc_mem(pc_mem),
					 .halt(halt),
					 .i_write(i_write),
					 .i_enable(i_enable)
					 );

   always #(RATE/2) clk = ~clk;

   initial begin
	  #(0) 
	  clk = 0;
	  reset = 0;
	  npc = 32'd10000;
	  
	  #(RATE)
	  npc = pc;
	  
	  #(RATE)
	  npc = pc;
	  
	  #(RATE)
	  npc = 32'd10100;

	  #(RATE)
	  npc = pc;
	  reset = 1;	
	  
	  #(RATE)
	  $finish;
   end

   initial
	 $monitor ($stime, 
			   "clk = %b reset = %b npc = %5d pc = %5d pc_mem = %5d halt = %b i_write =  %b i_enable = %b", clk, reset, npc, pc, pc_mem, halt, i_write, i_enable);

endmodule
   
