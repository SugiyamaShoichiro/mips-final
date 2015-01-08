module ma_stage(
				input wire 		  clk,
				input wire 		  reset, 
				input wire 		  halt,
				input wire 		  is_mem_in,
				input wire 		  is_int_wb_in,
				input wire [4:0]  int_wb_address_in,
				input wire [31:0] int_wb_value_in,

				output reg 		  is_mem_out, 
				output reg 		  is_int_wb_out,
				output reg [4:0]  int_wb_address_out,
				output reg [31:0] int_wb_value_out
				);
   
   
   always @(posedge clk) begin
	  if(reset == 1'b1) begin
		 is_mem_out <= 1'b0;
		 is_int_wb_out <= 1'b0;
		 int_wb_address_out <= 5'b0;
		 int_wb_value_out = 32'b0;
	  end
	  else begin
		 if(halt == 1'b0) begin
			is_mem_out <= is_mem_in;
			is_int_wb_out <= is_int_wb_in;
			int_wb_address_out <= int_wb_address_in;
			int_wb_value_out <= int_wb_value_in;
		 end
	  end
   end
			
   


endmodule
