`timescale 1ns/1ns
`include "id_stage.v"

module id_test;
   
   reg clk;
   reg reset;
   reg [31:0] instruction;
   reg [31:0] pc_in;
   reg 		  halt_fetch;
   reg 		  halt_control;
   
   wire [5:0] opcode;
   wire [4:0] format;
   wire [5:0] funct;
   wire [4:0] rs;
   wire [4:0] rt;
   wire [4:0] rd;
   wire [15:0] imm;
   wire [25:0] offset;
   wire [4:0]  base;
   wire [4:0]  sa;
   wire [4:0]  bltz;
   wire [31:0] pc_out;
   wire 	   halt_out;
   wire [1:0]  i_type;
   
   wire [4:0]  rs_reg;
   wire [4:0]  rt_reg;
   
   parameter RATE = 100;
   
   id_stage id_stage(
					 .clk(clk),
					 .reset(reset),
					 .instruction(instruction),
					 .pc_in(pc_in),
					 .halt_fetch(halt_fetch),
					 .halt_control(halt_control),
					 .opcode(opcode),
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
					 .pc_out(pc_out),
					 .halt_out(halt_out),
					 .i_type(i_type),
	  
					 .rs_reg(rs_reg),
					 .rt_reg(rt_reg)
					 );

   always #(RATE/2) clk = ~clk;

   initial begin
	  #(0) 
	  clk = 0;
	  reset = 0;

	  #(RATE/2)
	  instruction = 32'h0;
	  pc_in = 32'd10000;
	  halt_fetch = 0;
	  halt_control = 0;
	  
	  #(RATE)
	  instruction = 32'h3c1c0000;
	  pc_in = 32'd10004;
	  
	  #(RATE)
	  instruction = 32'h279c0000;
	  pc_in = 32'd10008;
	  
	  #(RATE)
	  instruction = 32'h0;
	  pc_in = 32'd10000;
	  
	  #(RATE)
	  reset = 1;	
	  
	  #(RATE)
	  $finish;
   end

   initial 
	 $monitor ($stime, 
			   "clk = %b reset = %b instruction = %8h pc_in = %5d halt_fetch = %b halt_control = %b opcode = %6b format = %5b funct = %6b rs = %5b rt = %5b rd = %5b imm = %16b offset = %26b base = %5b sa = %5b bltz = %5b pc_out = %5d i_type = %2b rs_reg = %5b rt_reg = %5b", clk, reset, instruction, pc_in, halt_fetch, halt_control, opcode, format, funct, rs, rt, rd, imm, offset, base, sa, bltz, pc_out, i_type, rs_reg, rt_reg);
	  
endmodule
   
