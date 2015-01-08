
/*
 * regm - register memory
 *
 * A 32-bit register memory.  Two registers can be read at once. The
 * variables `read1` and `read2` specifiy which registers to read.  The
 * output is placed in `data1` and `data2`.
 *
 * If `regwrite` is high, the value in `wrdata` will be written to the
 * register in `wrreg`.
 *
 * The register at address $zero is treated special, it ignores
 * assignment and the value read is always zero.
 *
 * If the register being read is the same as that being written, the
 * value being written will be available immediately without a one
 * cycle delay.
 *
 */

/*
module regm(
		input wire		clk,
		input wire  [4:0]	read1, read2,
		input wire		regwrite,
		input wire	[4:0]	wrreg,
		input wire	[31:0]	wrdata,
		output wire [31:0]	data1, data2);


	reg [31:0] mem [0:31];  // 32-bit memory with 32 entries

	reg [31:0] _data1, _data2;

	always @(*) begin
		if (read1 == 5'd0)
			_data1 = 32'd0;
		else if ((read1 == wrreg) && regwrite)
			_data1 = wrdata;
		else
			_data1 = mem[read1][31:0];
	end

	always @(*) begin
		if (read2 == 5'd0)
			_data2 = 32'd0;
		else if ((read2 == wrreg) && regwrite)
			_data2 = wrdata;
		else
			_data2 = mem[read2][31:0];
	end

	assign data1 = _data1;
	assign data2 = _data2;

	always @(posedge clk) begin
		if (regwrite && wrreg != 5'd0) begin
			// write a non $zero register
			mem[wrreg] <= wrdata;
		end
	end
endmodule

*/

module register(
  input wire clk,//global clock
  input wire reset, //global reset
  input wire [4:0] addr_1, //rs, rt from id stage
  input wire [4:0] addr_2, //rs, rt from id stage
  input wire [4:0] wb_addr, //wb_addr from wb stage
  input wire [31:0] wb_data, //wb_data from wb_stage
  input wire write, //from wb_stage
  
  output [31:0] data_1,// will connect with ex_stage
  output [31:0] data_2 //will connect with ex_stage
);

  reg [31:0] register [0:31];

  reg [31:0] data_1_temp;
  reg [31:0] data_2_temp;


  //reading from the register file
  always @ (posedge clk) begin
    if (reset == 1'b1) begin
      data_1_temp <= 32'b0;
      data_2_temp <= 32'b0;
    end else begin
      data_1_temp <= register[addr_1];
      data_2_temp <= register[addr_2];
    end
  end

  assign data_1 = data_1_temp;
  assign data_2 = data_2_temp;
  // write back to the register file
  always @ (negedge clk) begin
    if (reset == 1'b1) begin
      register[0] <= 32'b0;
    end else begin
      if (write == 1'b1) begin
        register[wb_addr] <= wb_data;
      end
    end
  end
endmodule




