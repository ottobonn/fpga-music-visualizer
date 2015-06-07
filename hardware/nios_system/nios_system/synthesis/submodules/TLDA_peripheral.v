module TLDA_peripheral (
	// clock and reset signals
	input				csi_clockreset_clk,
	input				csi_clockreset_resetn,

	// avalon slave signals
	input				avs_slave_chipselect,
	input  [2:0] 	avs_slave_address,
	input				avs_slave_read,
	input				avs_slave_write,
	input  [31:0] 	avs_slave_writedata,

	output [31:0] 	avs_slave_readdata,

	// avalon master signals
	input				avm_master_waitrequest,

	output [31:0]	avm_master_address,
	output 			avm_master_write,
	output [15:0]	avm_master_writedata,
	output [1:0]	avm_master_byteenable
);

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
wire		Go, Draw, Done, Write_Finish;
wire 		[8:0] X0,X1,Thickness;
wire		[7:0] Y0,Y1;
wire 		[15:0] Color;
wire		[31:0] Pixel_Address, Base_Addr;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
// memory-mapped avalon slave interface
TLDA_slave_interface ASI(
		// clock and reset
		.clk					(csi_clockreset_clk),
		.resetn				(csi_clockreset_resetn),

		// avalon slave signals
		.slave_chipselect (avs_slave_chipselect),
		.slave_address		(avs_slave_address),
		.slave_read			(avs_slave_read),
		.slave_write		(avs_slave_write),
		.slave_writedata	(avs_slave_writedata),
		.slave_readdata	(avs_slave_readdata),

		// signals for LDA circuit
		.Done_from_LDA		(Done),
		.Thickness			(Thickness),
		.Go_to_LDA			(Go),
		.X0_to_LDA			(X0),
		.Y0_to_LDA			(Y0),
		.X1_to_LDA			(X1),
		.Y1_to_LDA			(Y1),
		.Color_to_LDA		(Color),
		.Base_Addr_to_LDA (Base_Addr)
);

//line_drawing_algorithm circuit
TLDA_circuit TLDA_C(
		// clock and reset signals
		.clk					(csi_clockreset_clk),
		.resetn				(csi_clockreset_resetn),

		// signals communicate with ASC
		.Go					(Go),
		.X0					(X0),
		.Y0					(Y0),
		.X1					(X1),
		.Y1					(Y1),
		.Thickness			(Thickness),
		.Done					(Done),

		// signals communicate with AMC
		.Write_Finish		(Write_Finish),
		.Draw					(Draw),
		.Pixel_Address		(Pixel_Address),

		// inout signal, its value is unchanged in this module
		.Color				(Color),
		.Base_Addr 		(Base_Addr)
);


//avalon master interface
TLDA_master_interface AMI(
		// clock and reset
		.clk							(csi_clockreset_clk),
		.resetn						(csi_clockreset_resetn),

		// avalon master signals
		.master_waitrequest		(avm_master_waitrequest),
		.master_address			(avm_master_address),
		.master_write				(avm_master_write),
		.master_writedata			(avm_master_writedata),
		.master_byteenable		(avm_master_byteenable),

		// signals for LDA circuit
		.Draw_from_LDA				(Draw),
		.Pixel_Address_from_LDA	(Pixel_Address),
		.Color_from_LDA			(Color),
		.Write_Finish_to_LDA 	(Write_Finish)
);

endmodule
