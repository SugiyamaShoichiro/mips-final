module id_stage(
				input wire 		  clk, // global clock
				input wire 		  reset, // global reset
				input wire [31:0] instruction, // from memory
				input wire [31:0] pc_in, //from if stage
				input wire 		  halt_fetch, // from if stage
				input wire 		  halt_control, // from control unit

				output reg [5:0]  opcode, // to the ex stage
				output reg [4:0]  format, // to the ex stage
				output reg [5:0]  funct, // to the ex stage
				output reg [4:0]  rs, // to the ex stage
				output reg [4:0]  rt, // to the ex stage
				output reg [4:0]  rd, // to the ex stage
				output reg [15:0] imm, // to the ex stage
				output reg [25:0] offset, // to the ex stage
				output reg [4:0]  base, //to the ex stage
				output reg [4:0]  sa, // to the ex stage
				output reg [4:0]  bltz, //to the ex stage
				output reg [31:0] pc_out, //to the ex stage
				output reg 		  halt_out, //to the ex stage
				output reg [1:0]  i_type, //to the ex stage

				output [4:0] 	  rs_reg,//to the register file
				output [4:0] 	  rt_reg//to the register file
				//  output rs_enable,
				//  output rt_enable
				);
   
   wire [5:0] 					  opcode_temp;
   reg [4:0] 					  format_temp;
   wire [5:0] 					  funct_temp;
   reg [1:0] 					  i_type_temp;
   reg [4:0] 					  rs_temp;
   reg [4:0] 					  rt_temp;
   reg [4:0] 					  rd_temp;
   wire [15:0] 					  imm_temp;
   reg [25:0] 					  offset_temp;					  
   wire [4:0] 					  base_temp;
   wire [4:0] 					  sa_temp;
   wire [4:0] 					  bltz_temp;
   wire 						  halt_temp;

   assign halt_temp = (halt_control == 1'b1)? 1'b1 : halt_fetch;

   assign opcode_temp = instruction[31:26];
   assign base_temp = instruction[25:21];
   assign sa_temp = instruction[10:6];
   assign bltz_temp = instruction[20:16];
   assign funct_temp = instruction[5:0];
   assign imm_temp = instruction[15:0];
   
   always @(instruction) begin
      if(opcode_temp == 6'b0) begin//R-type instructionruction
		 i_type_temp <= 2'd0;
		 rs_temp <= instruction[25:21];
		 rt_temp <= instruction[20:16];
		 rd_temp <= instruction[15:11];
		 offset_temp <= 26'b0;
      end else if(opcode_temp == 6'b000010 | opcode_temp == 6'b000011) begin//J-type instructionruction
		 i_type_temp <= 2'd1;
		 rs_temp <= 5'b0;
		 rt_temp <= 5'b0;
		 rd_temp <= 5'b0;
		 offset_temp <= instruction[25:0];
	  end else if(opcode_temp == 6'b001011) begin//C-type instructionruction
		 i_type_temp <= 2'd2;
		 rs_temp <= instruction[15:11];
		 rt_temp <= instruction[20:16];
		 rd_temp <= instruction[10:6];
		 offset_temp <= instruction[25:0];
		 format_temp <= instruction[25:21];
      end else begin//I-type instructionruction
		 i_type_temp <= 2'd3;
		 rs_temp <= instruction[25:21];
		 rt_temp <= instruction[20:16];
		 rd_temp <= 5'b0;
		 offset_temp <= {10'b0, instruction[15:0]}; //Is it OK??? FIXME
      end
   end

   /*these signals are connected with register file*/
   assign rs_reg = rs_temp;
   assign rt_reg = rt_temp;
   assign rd_reg = rd_temp;

   always @(posedge clk) begin
      if(reset == 1'b1) begin
		 opcode <= 6'b0;
		 format <= 5'b0;
		 funct <= 6'b0;
		 rs <= 5'b0;
		 rt <= 5'b0;
		 rd <= 5'b0;
		 imm <= 16'b0;
		 offset <= 26'b0;
		 base <= 5'b0;
		 sa <= 5'b0;
		 bltz <= 5'b0;
		 halt_out <= 1'b1;
		 pc_out <= 32'b0;
		 i_type <= 2'b0;
      end // if (reset == 1'b1)
      else begin
		 opcode <= opcode_temp;
		 format <= format_temp;
		 funct <= funct_temp;
		 rs <= rs_temp;
		 rt <= rt_temp;
		 rd <= rd_temp;
		 imm <= imm_temp;
		 offset <= offset_temp;
		 base <= base_temp;
		 sa <= sa_temp;
		 bltz <= bltz_temp;
		 halt_out <= halt_temp;
		 pc_out <= pc_in;
		 i_type <= i_type_temp;
      end // else: !if(reset == 1'b1)
   end	  
endmodule
