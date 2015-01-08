module forward(
			   input wire [4:0]  rs, //rs_reg from id
			   input wire [4:0]  rt, //rt_reg from id
			   input wire 		 wb_true_ex,
			   input wire 		 wb_true_ma,
			   input wire [4:0]  wb_address_ex,
			   input wire [31:0] wb_value_ex,
			   input wire [4:0]  wb_address_ma,
			   input wire [31:0] wb_value_ma,

			   output reg [31:0] rs_v_out,
			   output reg [31:0] rt_v_out,
			   output reg 		 is_forward_rs,
			   output reg 		 is_forward_rt);
   
   wire [37:0] 					 f_reg [0:1];
   
   assign f_reg [0] = {wb_true_ex, wb_address_ex, wb_value_ex};
   assign f_reg [1] = {wb_true_ma, wb_address_ma, wb_value_ma};
   
   
   
   
   always @(*) begin
	  //for rs
	  if (f_reg [0][37] == 1'b1) begin 
		 if(f_reg [0][36:32] == rs) begin
			rs_v_out <= f_reg [0][31:0];
			is_forward_rs <= 1'b1;
		 end
	  end
	  else if(f_reg [1][37] == 1'b1) begin
		 if(f_reg [1][37:32] == rs) begin
			rs_v_out <= f_reg [1][31:0];
			is_forward_rs <= 1;
		 end
	  end
	  else begin
		 is_forward_rs <= 0;
	  end
   end
   
   
   always @(*) begin
	  if (f_reg [0][37] == 1'b1) begin 
		 if(f_reg [0][36:32] == rt) begin
			rt_v_out <= f_reg [0][31:0];
			is_forward_rt <= 1'b1;
		 end
	  end
	  else if(f_reg [1][37] == 1'b1) begin
		 if(f_reg [1][36:32] == rt) begin
			rt_v_out <= f_reg [1][31:0];
			is_forward_rt <= 1;
		 end
	  end
	  else begin
		 is_forward_rt <= 0;
	  end
   end
	  

   
   
endmodule
