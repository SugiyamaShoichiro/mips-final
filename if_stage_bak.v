module if_stage #(
	parameter NMEM = 128,
	parameter IM_DATA = 128) 

(
	input wire clk,
	input reg stall_s1_s2,
	input reg pcsrc,
	input wire [31:0] baddr_s2,
	input reg [31:0] pc,
	output wire [31:0] pc4); 



  // {{{ stage 1, IF (fetch)

 /*       wire [31:0]     alurslt_s4;
        wire [31:0]     alurslt;  // ALU result
        reg [1:0] forward_a;
        reg [1:0] forward_b;
        reg [31:0] fw_data2_s3;
        wire [31:0] baddr_s2;
        reg pcsrc;
        reg stall_s1_s2;
        reg  [31:0] pc;
        initial begin
                pc <= 32'd0; // FIXME need modify later 
        end
*/
//  assign if_pc  = pc;
        //reg  [31:0] pc;

	reg [31:0] _pc;

        assign pc4 = _pc + 4;

        always @(posedge clk) begin
                if (stall_s1_s2)
                        _pc <= pc;
                else if (pcsrc == 1'b1)
                        _pc <= baddr_s2;
                else
                        _pc <= pc4;
        end

        // pass PC + 4 to stage 2
        wire [31:0] pc4_s2;
        szreggy #(.N(32)) reggy_pc4_s2(.clk(clk),
                                                .stall(stall_s1_s2), .zero(branch_flush),
                                                .in(pc4), .out(pc4_s2));

        // instruction memory
        wire [31:0] inst;
        wire [31:0] inst_s2;

        assign if_instr = inst;

        im #(.NMEM(NMEM), .IM_DATA(IM_DATA))
                im1(.clk(clk), .addr(pc), .data(inst));
        szreggy #(.N(32)) reggy_im_s2(.clk(clk),
                                                .stall(stall_s1_s2), .zero(branch_flush),
                                                .in(inst), .out(inst_s2));

        // }}}

endmodule
