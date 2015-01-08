`include "mem.v"
`include "if_stage.v"
`include "id_stage.v"
`include "control.v"
`include "regm.v"
`include "ex_stage.v"
`include "forward.v"
`include "ma_stage.v"
`include "wb_stage.v"

module cpu(
		   input wire 		 clk,
		   input wire 		 reset,
		   input wire 		 start,
		   input wire 		 program_load,//leading program to memory
		   input wire 		 halt,
		   input wire [31:0] instruction  
		   );

   //---------------------------------------------
   //	IF STAGE
   //---------------------------------------------
   //input signals to if_stage
   wire [31:0] 				 npc;//coming from control unit

   //output signals from if_stage
   wire [31:0] 				 pc_id; //connect to id_stage pc_in
   wire [31:0] 				 pc_mem; //connect to memory i_addr
   wire 					 halt_fetch; //connect to the id_stage halt
   wire 					 i_write; //connect to the mem i_write
   wire 					 i_enable; //connect to the mem i_enable

   //---------------------------------------------
   //	MEMORY
   //---------------------------------------------
   //input signals to memory
   wire [31:0] 				 effective_address;//connect with data_address from the ex stage
   wire 					 i_enable_mem;//connect with the i_enable of memory
   wire 					 is_mem_ex;//connect with the data_enable from the ex stage
   wire 					 i_write_mem;//connect with the i_write of if_stage
   wire 					 is_int_wb_ex;//connect with the d_write of ex_stage and forwarding
   wire [1:0] 				 data_width;//from ex stage				 
   //inout signals of memory
   wire [31:0] 				 instruction_mem;//will to the id_stage input
   wire [31:0] 				 data_mem;//from ex, to wb
   //output signals from memory
   assign i_enable_mem = (program_load == 1'b1)? 1'b1:i_enable;
   assign i_write_mem = (program_load == 1'b1)? 1'b1:i_write;

   //---------------------------------------------
   //	ID STAGE
   //---------------------------------------------
   //input signal to id_stage
   wire 					 halt_control; // from control unit

   //output signal from id_stage
   wire [5:0] 				 opcode; // will connect to the id and ex stage
   wire [4:0] 				 format; // connect with id and ex stage
   wire [5:0] 				 funct; // connect with the id and ex stage
   wire [4:0] 				 rs; // connect with the id and ex stage, forwarding
   wire [4:0] 				 rt; // connect with the id and ex stage, forwarding
   wire [4:0] 				 rd; // connect with the id and ex stage
   wire [15:0] 				 imm; // connect with the id and ex stage
   wire [25:0] 				 offset; // connect with the id and ex stage
   wire [4:0] 				 base; //connect with the id and ex stage
   wire [4:0] 				 sa; // connect witto the ex stage
   wire [4:0] 				 bltz; //to the ex stage
   wire [31:0] 				 pc_ex; //to the ex stage
   wire 					 halt_id; //to the ex stage
   wire [1:0] 				 i_type; //to the ex stage
   wire [4:0] 				 rs_reg;//to the register file
   wire [4:0] 				 rt_reg;//to the register file
   

   //---------------------------------------------
   //	REGISTER FILE
   //---------------------------------------------
   //input signal to register_file
   wire [4:0] 				 int_wb_address_ma; //from ma stage, also forwarding input
   wire [31:0] 				 wrdata; //from wb_stage
   wire 					 is_int_wb_ma; //from ma stage, also forwarding input

   //output signal from register_file
   wire [31:0] 				 data_1;// will connect with ex
   wire [31:0] 				 data_2; //will connect with ex

   //---------------------------------------------
   //   FORWARDING UNIT
   //---------------------------------------------
   //input signal to forward
   wire [4:0] 				 int_wb_address_ex; //from ex stage
   wire [31:0] 				 int_wb_value_ex; //from ex stage
   wire [31:0] 				 int_wb_value_ma; //from ma stage, also wb input 				 

   //output signal from forwarding unit
   wire [31:0] 				 rs_forward;//to ex stage
   wire [31:0] 				 rt_forward;//to ex stage
   wire 					 is_forward_rs;//to ex stage
   wire 					 is_forward_rt;//to ex stage
 					 
   
   //---------------------------------------------
   //   EX STAGE
   //---------------------------------------------
   //input signal to ex_stage

   //output signal from ex_stage
   wire [31:0] 				 jump_address;//to control
   wire 					 is_jump;//???
   wire 					 halt_ex;
   
   //---------------------------------------------
   //   MA STAGE
   //---------------------------------------------
   //input signal to ma_stage

   //output signal from ma_stage
   wire 					 is_mem_ma;//to wb stage
   
   


   


   //instansiation if_stage
   if_stage fetch_stage(.clk(clk),//global
						.reset(reset),//global
						.npc(npc),//from control
						 						
						.pc(pc_id),//to id stage
						.pc_mem(pc_mem),//to memory
						.halt(halt_fetch),//to id stage
						.i_write(i_write),//to assign statement in cpu for using as i_write_mem in memory
						.i_enable(i_enable));//to assign statement in cpu for using as i_enable_mem in memory



   //instansiation mem
   memory mem(.clk(clk),//global
			  .reset(reset),//global
			  .i_addr(pc_mem),//from if stage
			  .d_addr(effective_address),//from ex stage
			  .i_enable(i_enable_mem),//from if_stage passing through assign statement in cpu
			  .d_enable(is_mem_ex),//from ex stage
			  .i_write(i_write_mem),//from if_stage passing through assign statement in cpu
			  .d_write(is_int_wb_ex),//from ex stage
			  .data_width(data_width),//from ex stage
			  
			  .instruction(instruction_mem),//inout, to id stage
			  .data(data_mem));//inout, from ex stage, to wb stage



   //instansiation id_stage
   id_stage decode_stage(
						 .clk(clk), // global clock
						 .reset(reset), // global reset
						 .instruction(instruction_mem), // from memory
						 .pc_in(pc_id), //from if stage
						 .halt_fetch(halt_fetch), // from if stage
						 .halt_control(halt_control), // from control unit
  	  
						 .opcode(opcode), // to the ex stage
						 .format(format), // to the ex stage
						 .funct(funct), // to the ex stage
						 .rs(rs), // to the ex stage
						 .rt(rt), // to the ex stage
						 .rd(rd), // to the ex stage
						 .imm(imm), // to the ex stage
						 .offset(offset), // to the ex stage
						 .base(base), //to the ex stage
						 .sa(sa), // to the ex stage
						 .bltz(bltz), //to the ex stage
						 .pc_out(pc_ex), //to the ex stage
						 .halt_out(halt_id), //to the ex stage
						 .i_type(i_type), //to the ex stage

						 .rs_reg(rs_reg),//to the register file
						 .rt_reg(rt_reg)//to the register file
						 //  output rs_enable,
						 //  output rt_enable
						 );

   control control(
				   .is_jump(is_jump),
				   .jump_address(jump_address),
				   .pc(pc_id),

				   .npc(npc),
				   .halt(halt_control)
				   );
   


   //instansiation register_file
   register regm(
				 .clk(clk),//global clock
				 .reset(reset), //global reset
				 .addr_1(rs_reg), //rs, rt from id stage
				 .addr_2(rt_reg),//rs, rt from id stage
				 .wb_addr(int_wb_address_ma), //wb_addr from wb stage
				 .wb_data(wrdata), //wb_data from wb_stage
				 .write(is_int_wb_ma), //from wb_stage
	  
				 .data_1(data_1),// will connect with fw
				 .data_2(data_2) //will connect with fw
				 );

   //instansiation forward unit
   forward forwarding(
					  .rs(rs),
					  .rt(rt),
					  .wb_true_ex(is_int_wb_ex),
					  .wb_true_ma(is_int_wb_ma),
					  .wb_address_ex(int_wb_address_ex),
					  .wb_value_ex(int_wb_value_ex),
					  .wb_address_ma(int_wb_address_ma),
					  .wb_value_ma(int_wb_value_ma),

					  .rs_v_out(rs_forward),
					  .rt_v_out(rt_forward),
					  .is_forward_rs(is_forward_rs),
					  .is_forward_rt(is_forward_rt));
   
					  
   //instansiation ex_stage
   ex_stage execution_stage(
							.clk(clk), //global clock
							.reset(reset), //global reset
							.opcode(opcode), //from id stage
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
							.pc(pc_ex),
							.i_type(i_type),
							.rs_id(data_1),
							.rt_id(data_2),
							.rs_forward(rs_forward),
							.rt_forward(rt_forward),
							.is_forward_rs(is_forward_rs),
							.is_forward_rt(is_forward_rt),
							.halt_in(halt_id),
							.halt_from_control(halt_from_control),

							.jump_address(jump_address),
							.is_int_wb(is_int_wb_ex),
							.is_jump(is_jump),
							.is_mem(is_mem_ex),
							.value_to_be_store(data_mem),
							.int_wb_address(int_wb_address_ex),
							.int_wb_value(int_wb_value_ex),
							.effective_address(effective_address), //to memory
							.data_width(data_width),
							.halt(halt_ex));
   
   //instansiation ma_stage
   ma_stage memory_access_stage(
								.clk(clk),
								.reset(reset),
								.halt(halt_ex),
								.is_mem_in(is_mem_ex),
								.is_int_wb_in(is_int_wb_ex),
								.int_wb_address_in(int_wb_address_ex),
								.int_wb_value_in(int_wb_value_ex),

								.is_mem_out(is_mem_ma),
								.is_int_wb_out(is_int_wb_ma),
								.int_wb_address_out(int_wb_address_ma),
								.int_wb_value_out(int_wb_value_ma)
								);
   

   
   //instansiation wb_stage
   wb_stage write_back_stage(
							 .is_mem(is_mem_ma),
							 .rdata(data_mem),
							 .alurslt(int_wb_value_ma),

							 .wrdata(wrdata));

   
endmodule
