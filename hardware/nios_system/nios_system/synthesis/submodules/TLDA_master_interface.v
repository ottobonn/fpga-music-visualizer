/*****************************************************************************
 *                                     AMI Module                            *
 *****************************************************************************/
module TLDA_master_interface(
	// clock and reset
	input				clk,
	input				resetn,

	// avalon master signals
	input				master_waitrequest,
	output reg [31:0]	master_address,
	output reg			master_write,
	output reg [15:0]	master_writedata,
	output [1:0] 	master_byteenable,

	// signals for LDA circuit
	input 			Draw_from_LDA,
	input [31:0]	Pixel_Address_from_LDA,
	input [15:0]	Color_from_LDA,
	output reg			Write_Finish_to_LDA
);
/*****************************************************************************
 *                     Please write your code below                          *
 *****************************************************************************/

assign master_byteenable = 2'b11;

`define IDLE_STATE 0
`define WRITING_STATE 1
`define WAITING_STATE 2
`define DONE_WRITING_STATE 3

reg [1:0] next_state;
wire [1:0] state;

always @(*) begin
	case (state)
		`IDLE_STATE: begin
			master_write = 0;
			master_address = 0;
			master_writedata = 0;
			Write_Finish_to_LDA = 0;
			next_state = Draw_from_LDA ? `WRITING_STATE : `IDLE_STATE;
		end
		`WRITING_STATE: begin
			master_write = 1;
			master_address = Pixel_Address_from_LDA;
			master_writedata = Color_from_LDA;
			Write_Finish_to_LDA = 0;
			next_state = master_waitrequest ? `WAITING_STATE : `DONE_WRITING_STATE;
		end
		`WAITING_STATE: begin
			master_write = 1;
			master_address = Pixel_Address_from_LDA;
			master_writedata = Color_from_LDA;
			Write_Finish_to_LDA = 0;
			if (master_waitrequest) begin
				next_state = `WAITING_STATE;
			end else begin
				next_state = `DONE_WRITING_STATE;
			end
		end
		`DONE_WRITING_STATE: begin
			master_write = 0;
			master_address = 0;
			master_writedata = 0;
			Write_Finish_to_LDA = 1;
			next_state = Draw_from_LDA ? `WRITING_STATE : `IDLE_STATE;
		end
		default: begin
			master_write = 0;
			master_address = 0;
			master_writedata = 0;
			Write_Finish_to_LDA = 0;
			next_state = `IDLE_STATE;
		end
	endcase
end


dffre #(2) state_ff (
	.clk		(clk),
	.reset 	(~resetn),
	.en			(1),
	.d			(next_state),
	.q			(state)
);


endmodule
