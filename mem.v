module memory (
			   input wire 		 clk, // Clock Input
			   input wire 		 reset,
			   input wire [31:0] i_addr, // Instruction Address
			   input wire [31:0] d_addr, // Data Address
			   input wire 		 i_enable, //instruction enable
			   input wire 		 d_enable, //data enable
			   input wire 		 i_write,
			   input wire 		 d_write, //when it is 0 -> write(confusing)
			   input wire [1:0]  data_width, //output data width		

			   inout [31:0] 	 instruction,
			   inout [31:0] 	 data
			   ); 


   reg [31:0] 					 instruction_temp;
   reg [31:0] 					 data_temp;
   //parameter	DATA_WIDTH = 8 ;
   //parameter	ADDR_WIDTH = 8 ;
   //parameter	RAM_DEPTH = 1 << ADDR_WIDTH;
   parameter	MEMSIZE = 32'he000000;
   //parameter	MEMSIZE = 1000;

   reg [7:0] 					 mem [0:MEMSIZE-1];


   assign instruction = instruction_temp;
   assign data = data_temp;

   initial
	 $readmemh("mem_new", mem, 32'h10000);


   //accessing .text section
   always @ (posedge clk) begin
      if (reset == 1'b1) begin
		 instruction_temp <= 32'b0;
      end else begin
		 if (i_enable == 1'b1) begin
			if (i_write == 1'b1) begin
			   mem[i_addr] = instruction;
			end else begin
			   instruction_temp = {mem[i_addr+2'd0],mem[i_addr+2'd1],mem[i_addr+2'd2],mem[i_addr+2'd3]};
			end
		 end
      end
   end

   //accessing .data .bss section
   always @ (posedge clk) begin
      if (reset == 1'b1) begin
		 data_temp <= 32'b0;
      end else begin
		 if (d_enable == 1'b1) begin
			if (data_width == 2'd0) begin //byte
			   if (d_write == 1'b0)begin//write
				  mem[d_addr] <= data[7:0];
			   end else begin//read
				  data_temp <= {24'b0, mem[d_addr]};
			   end
			end else if (data_width == 2'd1) begin //half
			   if (d_write == 1'b0)begin//write
				  mem[d_addr] <= data[15:8];
				  mem[d_addr+1'd1] <= data[7:0];
			   end else begin//read
				  data_temp <= {16'b0, mem[d_addr],mem[d_addr+1'd1]};
			   end
			end else if (data_width == 2'd2) begin //word
			   if (d_write == 1'b0)begin//write
				  mem[d_addr] <= data[31:24];
				  mem[d_addr+1'd1] <= data[23:16];
				  mem[d_addr+1'd2] <= data[15:8];
				  mem[d_addr+1'd3] <= data[7:0];
			   end else begin//read
				  data_temp <= {mem[d_addr],mem[d_addr+1'd1],mem[d_addr+1'd2],mem[d_addr+1'd3]};
			   end
			end
		 end
      end
   end



endmodule 






/*



 */
