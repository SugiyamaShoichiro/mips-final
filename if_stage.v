//`include "im.v"
module if_stage(
  input wire 		clk,
  input wire 		reset,
  input wire [31:0] npc, //from control input
  output reg [31:0] pc,//to the decode stage
  output reg [31:0] pc_mem,//to the memory stage
  output reg 		halt,
  output reg 		i_write, //control the read and write
  output reg 		i_enable//to the memory to enable the text section read
);
   wire [31:0] pc_temp;
   assign pc_temp = npc;
always @(pc_temp) pc_mem <= pc_temp;
   
  always @(posedge clk) begin
    if(reset == 1'b1) begin
      pc <= 0;
      halt <= 1'b1;
      i_write <= 1'b0;
      i_enable <= 1'b0;
    end else begin
      pc <= pc_temp + 4;
      halt <= 0;	 
      i_write <= 1'b0;
      i_enable <= 1'b1;
    end
  end
endmodule
