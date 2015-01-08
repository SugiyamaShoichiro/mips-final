module wb_stage(
				input wire 		   is_mem,
				input wire [31:0]  rdata,
				input wire [31:0]  alurslt,
				output wire [31:0] wrdata);

   
	assign wrdata = (is_mem) ? rdata : alurslt;

endmodule
