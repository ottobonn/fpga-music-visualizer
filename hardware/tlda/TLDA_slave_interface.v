/*****************************************************************************
 *                                     ASI Module                            *
 *****************************************************************************/
module TLDA_slave_interface (
	// clock and reset
	input					clk,
	input					resetn,

	// avalon slave signals
	input 				slave_chipselect,
	input 	  [2:0]	slave_address,
	input					slave_read,
	input					slave_write,
	input 	  [31:0]	slave_writedata,
	output reg [31:0]	slave_readdata,

	// signals for LDA circuit
	input					Done_from_LDA,
	output				Go_to_LDA,
	output 	  [8:0]	X0_to_LDA,
	output 	  [8:0]	X1_to_LDA,
	output 	  [7:0]	Y0_to_LDA,
	output 	  [7:0]	Y1_to_LDA,
	output	  [8:0] Thickness,
	output 	  [15:0]	Color_to_LDA,
	output    [31:0] Base_Addr_to_LDA
);

// ENABLE THE THICKNESS COMPONENT

/*****************************************************************************
 *                     Please write your code below                          *
 *****************************************************************************/

// Slave addresses
`define STATUS_REGISTER 0
`define GO_REGISTER	1
`define LINE_START 2
`define LINE_END	3
`define LINE_COLOR 4
`define LINE_THICKNESS 5
`define BASE_ADDR 6


reg [8:0] next_X0, next_X1;
reg [7:0] next_Y0, next_Y1;

// Determine what readdata to provide to master
always @(*) begin
	if (slave_chipselect) begin
		if (slave_write) begin
			slave_readdata = 0;
		end else if (slave_read) begin
			case (slave_address)
				`STATUS_REGISTER: begin
					slave_readdata = Done_from_LDA;
				end
				`LINE_START: begin
					slave_readdata = {Y0_to_LDA, X0_to_LDA};
				end
				`LINE_END: begin
					slave_readdata = {Y1_to_LDA, X1_to_LDA};
				end
				`LINE_COLOR: begin
					slave_readdata = Color_to_LDA;
				end
				`LINE_THICKNESS: begin
					slave_readdata = Thickness;
				end
				`BASE_ADDR: begin
					slave_readdata = Base_Addr_to_LDA;
				end
				default: begin
					slave_readdata = 0;
				end
			endcase
		end else begin
			slave_readdata = 0;
		end
	end else begin // if not slave_chipselect
		slave_readdata = 0;
	end
end


wire write_line_start, write_line_end, write_color, write_go, write_thickness, write_base_addr;

assign write_line_start = slave_write & slave_chipselect
													& (slave_address == `LINE_START);

assign write_line_end	 	= slave_write & slave_chipselect
													& (slave_address == `LINE_END);

assign write_color 			= slave_write & slave_chipselect
													& (slave_address == `LINE_COLOR);

assign write_go					= slave_write & slave_chipselect
													& (slave_address == `GO_REGISTER);

assign write_thickness = slave_write & slave_chipselect
													& (slave_address == `LINE_THICKNESS);

assign write_base_addr = slave_write & slave_chipselect
													& (slave_address == `BASE_ADDR);

assign Go_to_LDA = write_go & slave_writedata[0];

dffre #(32) base_addr_ff (
  .clk    (clk),
  .reset  (~resetn),
  .en     (write_base_addr),
  .d      (slave_writedata),
  .q      (Base_Addr_to_LDA)
);

falling_dffre #(9) x0_ff (
	.clk		(clk),
	.reset 	(~resetn),
	.en			(write_line_start),
	.d			(slave_writedata[8:0]),
	.q			(X0_to_LDA)
);

falling_dffre #(8) y0_ff (
	.clk		(clk),
	.reset 	(~resetn),
	.en			(write_line_start),
	.d			(slave_writedata[16:9]),
	.q			(Y0_to_LDA)
);

falling_dffre #(9) x1_ff (
	.clk		(clk),
	.reset 	(~resetn),
	.en			(write_line_end),
	.d			(slave_writedata[8:0]),
	.q			(X1_to_LDA)
);

falling_dffre #(9) y1_ff (
	.clk		(clk),
	.reset 	(~resetn),
	.en			(write_line_end),
	.d			(slave_writedata[16:9]),
	.q			(Y1_to_LDA)
);

falling_dffre #(16) color_ff (
	.clk		(clk),
	.reset 	(~resetn),
	.en			(write_color),
	.d			(slave_writedata[15:0]),
	.q			(Color_to_LDA)
);

falling_dffre #(9) thickness_ff (
	.clk		(clk),
	.reset 	(~resetn),
	.en			(write_thickness),
	.d			(slave_writedata[8:0]),
	.q			(Thickness)
);

endmodule
