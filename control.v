module control(
			   input wire 		 is_jump,//from ex
			   input wire [31:0] jump_address,//from ex
			   input wire [31:0] pc,//from if
			   
			   output reg [31:0] npc,
			   output reg 		 halt
			   );


   assign npc = (is_jump) ? jump_address : pc;
   assign halt = (is_jump) ? 1 : 0;
   
   
endmodule
