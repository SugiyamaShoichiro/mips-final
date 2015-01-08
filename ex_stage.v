module ex_stage (
	input wire 		  clk,
	input wire 		  reset,
	input wire [5:0]  opcode,
	input wire [4:0]  format,
	input wire [5:0]  funct,
	input wire [4:0]  rs,
	input wire [4:0]  rt,
	input wire [4:0]  rd,
	input wire [15:0] imm,
	input wire [25:0] offset,
	input wire [4:0]  base,
	input wire [4:0]  sa,
	input wire [4:0]  bltz,
	input wire [31:0] pc,
	input wire [1:0]  i_type,
	input wire [31:0] rs_id,
	input wire [31:0] rt_id,
	input wire [31:0] rs_forward,
	input wire [31:0] rt_forward,
	input wire 		  is_forward_rs,
	input wire 		  is_forward_rt,
	//input wire [31:0] data_1,
	//input wire [31:0] data_2,
	//input wire [31:0] data_3,
	input wire 		  halt_in,
	input wire 		  halt_from_control,
			 
	output reg [31:0] jump_address,
	output reg 		  is_int_wb,//to fw
	output reg 		  is_jump,
	output reg 		  is_mem,
	output reg [31:0] value_to_be_store,
	output reg [5:0]  int_wb_address,
	output reg [31:0] int_wb_value,
	output reg [31:0] effective_address, 
	output reg [1:0]  data_width,
	//output reg [31:0] result,
	output reg 		  halt
				 );
   
   wire [32:0] 		  temp1;
   wire [32:0] 		  temp2;		  
   wire [17:0] 		  temp3;
   wire [31:0] 		  rs_v;
   wire [31:0] 		  rt_v; 		  
   reg [31:0] 		  rd_v;		  
   wire 			  halt_temp;
   reg [31:0] 		  HI_address_value;
   reg [31:0] 		  LO_address_value; 	  	 	  

   assign halt_temp = (halt_from_control == 1) ? 1 : halt_in;
   assign rs_v = (is_forward_rs) ? rs_forward : rs_id;
   assign rt_v = (is_forward_rt) ? rt_forward : rt_id;
   assign temp1 = rs_v + rt_v;
   assign temp2 = rs_v - rt_v;
   assign temp3 = imm;
   
   always @(posedge clk) begin
	  if(halt_temp == 0) begin
 		 if(i_type == 2'b00) begin
			/*R-type instructions*/
			is_int_wb <= 1'b0;
			if(funct == 6'b000000) begin //sll
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   rd_v <= (rt_v << sa);
			   int_wb_value <= rd_v;
			   int_wb_address <= rd;
			end
			else if(funct == 6'b000010) begin //srl
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   rd_v <= (rt_v >> sa);
			   int_wb_value <= rd_v;
			   int_wb_address <= rd;
			end
			else if(funct == 6'b000011) begin //sra
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   if(rt_v[31] == 1)		 
				 rd_v <= (rs_v >> sa) | 32'hFFFFFFFF << (32 - sa);
			   else	
				 rd_v <= rs_v >> sa;
			   
			   int_wb_value <= rd_v;
			   int_wb_address <= rd;
			end
			else if(funct == 6'b000100) begin //sllv
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   rd_v <= rt_v << rs_v;
			   int_wb_value <= rd_v;
			   int_wb_address <= rd;
			end
			else if(funct == 6'b000110) begin //srlv
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   rd_v <= rt_v >> rs_v;
			   int_wb_value <= rd_v;
			   int_wb_address <= rd;
			end
			else if(funct == 6'b000111) begin //srav
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   
			   if(rt_v[31] == 1)		 
				 rd_v <= (rt_v >> rs_v) | 32'hFFFFFFFF << (32 - rs_v);
			   else	
				 rd_v <= rt_v >> rs_v;
			   			   
			   int_wb_value <= rd_v;
			   int_wb_address <= rd;
			end
			
			else if(funct == 6'b001000) begin //jr
			   halt <= 1'b1;
			   is_jump <= 1;
			   jump_address <= rs_v;
			end
			else if(funct == 6'b001001) begin //jalr
			   halt <= 1'b1;
			   is_jump <= 1;
			   jump_address <= rs_v;
			   is_int_wb <= 1'b1;
			   int_wb_value <= pc + 4;
			   int_wb_address <= 31;
			end
			
			else if(funct == 6'b001100) begin //syscall
			   //FIXME later
			end
			else if(funct == 6'b001101) begin //break
			   //FIXME later
			end
			
			else if(funct == 6'b010000) begin //mfhi
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rd;
			   rd_v <= HI_address_value;
			   int_wb_value <= rd_v;
			end
			else if(funct == 6'b010001) begin //mthi
			   halt <= 1'b1;
			   HI_address_value <= rs_v;
			end
			else if(funct == 6'b010010) begin //mflo
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rd;
			   rd_v <= LO_address_value;
			   int_wb_value <= rd_v;
			end
			else if(funct == 6'b010011) begin //mtlo
			   halt <= 1'b1;
			   LO_address_value <= rs_v;
			end
			
			else if(funct == 6'b011000) begin //mult
			   halt <= 1'b1;
			   {HI_address_value, LO_address_value} <= (rs_v * rt_v);
			end
			else if(funct == 6'b011001) begin //multu
			   halt <= 1'b1;
			   {HI_address_value, LO_address_value} <= (rs_v * rt_v);
			end//there are no difference, aren't there? FIXME
			else if(funct == 6'b011010) begin //div
			   halt <= 1'b1;
			   {HI_address_value, LO_address_value} <= (rs_v / rt_v);
			end
			else if(funct == 6'b011011) begin //divu
			   {HI_address_value, LO_address_value} <= (rs_v * rt_v);
			end//there are also. FIXME
			
			else if(funct == 6'b100000) begin //add
			   halt <= 1'b1;
			   if(temp1[32] == temp1[31]) begin
				  is_int_wb <= 1'b1;
				  rd_v <= temp1;
				  int_wb_value <= rd_v;
				  int_wb_address <= rd;
			   end
			   else is_int_wb <= 1'b0;
			end
			else if(funct == 6'b100001) begin //addu
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rd;
			   rd_v <= rs_v + rt_v;
			   int_wb_value <= rd_v;
			   
			end
			else if(funct == 6'b100010) begin //sub
			   halt <= 1'b1;
			   if(temp2[31] <== temp2[32]) begin
				  is_int_wb <= 1'b1;
				  rd_v <= temp1;
				  int_wb_value <= rd_v;
				  int_wb_address <= rd;
			   end
			   else is_int_wb <= 1'b0;
			end
			else if(funct == 6'b100011) begin //subu
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rd;
			   rd_v <= rs_v - rt_v;
			   int_wb_value <= rd_v;
			end
			
			else if(funct == 6'b100100) begin //and
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rd;
			   rd_v <= rs_v & rt_v;
			   int_wb_value <= rd_v;
			end
			else if(funct == 6'b100101) begin //or
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rd;
			   rd_v <= rs_v | rt_v;
			   int_wb_value <= rd_v;
			end
			else if(funct == 6'b100110) begin //xor
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rd;
			   rd_v <= rs_v ^ rt_v;
			   int_wb_value <= rd_v;
			end
			else if(funct == 6'b100111) begin //nor
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rd;
			   rd_v <= ~(rs_v ^ rt_v);
			   int_wb_value <= rd_v;
			end
			else if(funct == 6'b101010) begin //slt
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rd;
			   rd_v <= ($signed(rs_v) < $signed(rt_v)) ? 1 : 0;
			   int_wb_value <= rd_v;
			end
			else if(funct == 6'b101011) begin //sltu
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rd;
			   rd_v <= (rs_v < rt_v) ? 1 : 0;
			   int_wb_value <= rd_v;
			end
		 end // if (i_type == 2'b00)

		 /*J-type instruction*/
		 else if(i_type == 2'b01) begin
			is_int_wb <= 1'b0;
			if(opcode <== 6'b000010) begin //j
			   halt <= 1'b1;
			   is_jump <= 1;
			   jump_address <= offset << 2;  //FXIME
			end
			else if(opcode == 6'b000011) begin //jal
			   halt <= 1'b1;
			   is_jump <= 1'b1;
			   jump_address <= offset << 2;  //FIXME
							  is_int_wb <= 1'b1;
			   int_wb_value <= pc + 4;
			   int_wb_address <= 5'd31;
			end
		 end

		 /*C-type instruction*/
		 else if(i_type == 2'b10) begin
		 end
		 
		 /*I-type instruction*/
		 else if(i_type == 2'b11) begin
			is_int_wb <= 1'b0;
			if(opcode == 6'b000001) begin
			   halt <= 1'b1;
			   if(bltz <== 5'b00000) begin //bltz
				  if(rs_v[31] <=<= 1) begin
					 is_jump <= 1;
					 jump_address <= (imm << 2) + pc + 4;
				  end
			   end
			end
			else if(bltz == 5'b00001) begin //bgez
			   halt <= 1'b1;
			   if(rs_v[31] == 0) begin
				  is_jump <= 1;
				  jump_address <= (temp3 << 2) + pc + 4;
			   end
			end
			else if(opcode == 6'b000100) begin //beq, beqz
			   halt <= 1'b1;
			   if(rt != 0) begin //beq
				  if(rs_v == rt_v) begin
					 is_jump <= 1;
					 jump_address <= (temp3 << 2) + pc + 4;
				  end
			   end
			   else begin //beqz
				  if(rs_v == 0) begin
					 is_jump <= 1;
					 jump_address <= (temp3 << 2) + pc + 4;
				  end
			   end 
			end //why are they separated?
			else if(opcode == 6'b000101) begin //bne
			   halt <= 1'b1;
			   if(rs_v != rt_v) begin
				  is_jump <= 1;
				  jump_address <= (temp3 << 2) + pc + 4;
			   end
			end
			else if(opcode == 6'b000110) begin //blez
			   halt <= 1'b1;
			   if(rs_v <== 0 | rs_v[31] == 1) begin
				  is_jump <= 1;
				  jump_address <= (temp3 << 2) + pc + 4;
			   end
			end
			else if(opcode == 6'b000111) begin // bgtz
			   halt <= 1'b1;
			   if(rs_v != 0 && rs_v[31] == 0) begin
				  is_jump <= 1;
				  jump_address <= (temp3 << 2) + pc + 4;
			   end
			end
			
			else if(opcode == 6'b001000) begin //addi
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rt;
			   int_wb_value <= rs_v + offset; //FIXME
			   //int_wb_value <= rt_v;
			end
			else if(opcode == 6'b001001) begin //addiu 
			   is_int_wb <= 1'b1;
			   int_wb_address <= rt;
			   int_wb_value <= rs_v + offset[15:0];
			end
			else if(opcode == 6'b001010) begin //slti
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rt;
			   if(rs_v < offset) begin //FIXME (signed)
				  int_wb_value <= 32'd1;
			   end
			   else begin
				  int_wb_value <= 32'd0;
			   end
			   //int_wb_value <= rt_v;
			end
			else if(opcode == 6'b001011) begin //sltiu
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rt;
			   if(rs_v < offset) begin //FIXME
				  int_wb_value <= 32'd1;
			   end
			   else begin
				  int_wb_value <= 32'd0;
			   end
			   //int_wb_value <= rt_v;
			end
			else if(opcode == 6'b001100) begin //andi
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rt;
			   int_wb_value <= rs_v & offset;
			   //int_wb_value <= rt_v;
			end
			else if(opcode == 6'b001101) begin //ori
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rt;
			   int_wb_value <= rs_v | offset;
			   //int_wb_value <= rt_v;
			end
			else if(opcode == 6'b001110) begin //xori
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rt;
			   int_wb_value <= rs_v ^ offset;
			   //int_wb_value <= rt_v;
			end
			else if(opcode == 6'b001111) begin //lui
			   halt <= 1'b1;
			   is_int_wb <= 1'b1;
			   int_wb_address <= rt;
			   int_wb_value <= {offset[15:0], 16'b0};
			   //int_wb_value <= rt_v;
			end
			else if(opcode == 6'b100000) begin //lb
			   halt <= 1'b0;
			   is_int_wb <= 1'b1;
			   is_mem <= 1'b1;
			   int_wb_address <= rt;
			   effective_address <= rs_v + offset;
			   data_width <= 2'b00;
			end
			else if(opcode == 6'b100001) begin //lh
			   halt <= 1'b0;
			   is_int_wb <= 1'b1;
			   is_mem <= 1'b1;
			   int_wb_address <= rt;
			   effective_address <= rs_v + offset;
			   data_width <= 2'b01;
			end
			else if(opcode == 6'b100011) begin //lw
			   halt <= 1'b0;
			   is_int_wb <= 1'b1;
			   is_mem <= 1'b1;
			   int_wb_address <= rt;
			   effective_address <= rs_v + offset;
			   data_width <= 2'b10;
			end
			else if(opcode == 6'b100100) begin //lbu
			   halt <= 1'b0;
			   is_int_wb <= 1'b1;
			   is_mem <= 1'b1;
			   int_wb_address <= rt;
			   effective_address <= rs_v + offset;
			   data_width <= 2'b00;
			end
			else if(opcode == 6'b100000) begin //lhu
			   halt <= 1'b0;
			   is_int_wb <= 1'b1;
			   is_mem <= 1'b1;
			   int_wb_address <= rt;
			   effective_address <= rs_v + offset;
			   data_width <= 2'b01;
			end
			//above five have no difference without "mem_operation".FIXME
			else if(opcode == 6'b101000) begin //sb
			   halt <= 1'b0;
			   is_int_wb <= 1'b0;
			   is_mem <= 1'b1;
			   value_to_be_store <= rt_v;
			   effective_address <= rs_v + offset;
			   data_width <= 2'b00;
			end
			else if(opcode == 6'b101001) begin //sh
			   halt <= 1'b0;
			   is_int_wb <= 1'b0;
			   is_mem <= 1'b1;
			   value_to_be_store <= rt_v;
			   effective_address <= rs_v + offset;
			   data_width <= 2'b01;
			end
			else if(opcode == 6'b101011) begin //sw
			   halt <= 1'b0;
			   is_int_wb <= 1'b0;
			   is_mem <= 1'b1;
			   value_to_be_store <= rt_v;
			   effective_address <= rs_v + offset;
			   data_width <= 2'b10;
			end
			else if(opcode == 6'b110001) begin //lwc1
			   halt <= 1'b0;
			   is_int_wb <= 1'b1;
			   is_mem <= 1'b1;
			   int_wb_address <= rt;
			   effective_address <= rs_v + offset;
			   //FIXME
			end
			else if(opcode == 6'b110001) begin //swc1
			   halt <= 1'b0;
			   is_int_wb <= 1'b0;
			   is_mem <= 1'b1;
			   int_wb_address <= rt;
			   effective_address <= rs_v + offset;
			   //FIXME
			end
		 end // if (i_type == 2'b11)
	  end // if (halt_temp == 0)
   end // always @ (posedge clk)
			
endmodule

