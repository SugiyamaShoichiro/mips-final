`timescale 1ns/1ns
`include "ex_stage.v"

module ex_test;
   
   parameter RATE = 1000;

   reg 		  clk;
   reg 		  reset;
   reg [5:0]  opcode;
   reg [4:0]  format;
   reg [5:0]  funct;
   reg [4:0]  rs;
   reg [4:0]  rt;
   reg [4:0]  rd;
   reg [15:0] imm;
   reg [25:0] offset;
   reg [4:0]  base;
   reg [4:0]  sa;
   reg [4:0]  bltz;
   reg [31:0] pc;
   reg [1:0]  i_type;
   reg [31:0] rs_id;
   reg [31:0] rt_id;
   reg [31:0] rs_forward;
   reg [31:0] rt_forward;
   reg 		  is_forward_rs;
   reg 		  is_forward_rt;
   reg 		  halt_in;
   reg 		  halt_from_control;
   wire [31:0] jump_address;
   wire 	   is_int_wb;
   wire 	   is_jump;
   wire 	   is_mem;
   wire [31:0] value_to_be_store;
   wire [5:0]  int_wb_address;
   wire [31:0] int_wb_value;
   wire [31:0] effective_address; 
   wire [1:0]  data_width;
   wire 	   halt;
   
   
   ex_stage ex_stage(
					 .clk(clk),
					 .reset(reset),
					 .opcode(opecode),
					 .format(format),
					 .funct(funct),
					 .rs(rs),
					 .rt(rt),
					 .rd(rd),
					 .imm(imm),
					 .offset(offset),
					 .base(base),
					 .sa(sa),
					 .bltz(bltz),
					 .pc(pc),
					 .i_type(i_type),
					 .rs_id(rs_id),
					 .rt_id(rt_id),
					 .rs_forward(rs_forward),
					 .rt_forward(rt_forward),
					 .is_forward_rs(is_forward_rs),
					 .is_forward_rt(is_forward_rt),
					 .halt_in(halt_in),
					 .halt_from_control(halt_from_control),
					 
					 .jump_address(jump_address),
					 .is_int_wb(is_int_wb),
					 .(),
					 .(),
					 .(),
					 .()
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
   
