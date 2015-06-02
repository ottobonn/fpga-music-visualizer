// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/13.0sp1/ip/merlin/altera_merlin_router/altera_merlin_router.sv.terp#1 $
// $Revision: #1 $
// $Date: 2013/03/07 $
// $Author: swbranch $

// -------------------------------------------------------
// Merlin Router
//
// Asserts the appropriate one-hot encoded channel based on 
// either (a) the address or (b) the dest id. The DECODER_TYPE
// parameter controls this behaviour. 0 means address decoder,
// 1 means dest id decoder.
//
// In the case of (a), it also sets the destination id.
// -------------------------------------------------------

`timescale 1 ns / 1 ns

module nios_system_addr_router_001_default_decode
  #(
     parameter DEFAULT_CHANNEL = 1,
               DEFAULT_WR_CHANNEL = -1,
               DEFAULT_RD_CHANNEL = -1,
               DEFAULT_DESTID = 23 
   )
  (output [100 - 95 : 0] default_destination_id,
   output [39-1 : 0] default_wr_channel,
   output [39-1 : 0] default_rd_channel,
   output [39-1 : 0] default_src_channel
  );

  assign default_destination_id = 
    DEFAULT_DESTID[100 - 95 : 0];

  generate begin : default_decode
    if (DEFAULT_CHANNEL == -1) begin
      assign default_src_channel = '0;
    end
    else begin
      assign default_src_channel = 39'b1 << DEFAULT_CHANNEL;
    end
  end
  endgenerate

  generate begin : default_decode_rw
    if (DEFAULT_RD_CHANNEL == -1) begin
      assign default_wr_channel = '0;
      assign default_rd_channel = '0;
    end
    else begin
      assign default_wr_channel = 39'b1 << DEFAULT_WR_CHANNEL;
      assign default_rd_channel = 39'b1 << DEFAULT_RD_CHANNEL;
    end
  end
  endgenerate

endmodule


module nios_system_addr_router_001
(
    // -------------------
    // Clock & Reset
    // -------------------
    input clk,
    input reset,

    // -------------------
    // Command Sink (Input)
    // -------------------
    input                       sink_valid,
    input  [111-1 : 0]    sink_data,
    input                       sink_startofpacket,
    input                       sink_endofpacket,
    output                      sink_ready,

    // -------------------
    // Command Source (Output)
    // -------------------
    output                          src_valid,
    output reg [111-1    : 0] src_data,
    output reg [39-1 : 0] src_channel,
    output                          src_startofpacket,
    output                          src_endofpacket,
    input                           src_ready
);

    // -------------------------------------------------------
    // Local parameters and variables
    // -------------------------------------------------------
    localparam PKT_ADDR_H = 67;
    localparam PKT_ADDR_L = 36;
    localparam PKT_DEST_ID_H = 100;
    localparam PKT_DEST_ID_L = 95;
    localparam PKT_PROTECTION_H = 104;
    localparam PKT_PROTECTION_L = 102;
    localparam ST_DATA_W = 111;
    localparam ST_CHANNEL_W = 39;
    localparam DECODER_TYPE = 0;

    localparam PKT_TRANS_WRITE = 70;
    localparam PKT_TRANS_READ  = 71;

    localparam PKT_ADDR_W = PKT_ADDR_H-PKT_ADDR_L + 1;
    localparam PKT_DEST_ID_W = PKT_DEST_ID_H-PKT_DEST_ID_L + 1;



    // -------------------------------------------------------
    // Figure out the number of bits to mask off for each slave span
    // during address decoding
    // -------------------------------------------------------
    localparam PAD0 = log2ceil(64'h8000000 - 64'h0); 
    localparam PAD1 = log2ceil(64'h8200000 - 64'h8000000); 
    localparam PAD2 = log2ceil(64'h8201000 - 64'h8200000); 
    localparam PAD3 = log2ceil(64'h8202000 - 64'h8201000); 
    localparam PAD4 = log2ceil(64'h8202400 - 64'h8202000); 
    localparam PAD5 = log2ceil(64'h8202440 - 64'h8202400); 
    localparam PAD6 = log2ceil(64'h8202480 - 64'h8202440); 
    localparam PAD7 = log2ceil(64'h9002000 - 64'h9000000); 
    localparam PAD8 = log2ceil(64'h9002800 - 64'h9002000); 
    localparam PAD9 = log2ceil(64'ha000800 - 64'ha000000); 
    localparam PAD10 = log2ceil(64'hb000400 - 64'hb000000); 
    localparam PAD11 = log2ceil(64'hbff0004 - 64'hbff0000); 
    localparam PAD12 = log2ceil(64'hc800000 - 64'hc000000); 
    localparam PAD13 = log2ceil(64'h10000010 - 64'h10000000); 
    localparam PAD14 = log2ceil(64'h10000020 - 64'h10000010); 
    localparam PAD15 = log2ceil(64'h10000030 - 64'h10000020); 
    localparam PAD16 = log2ceil(64'h10000040 - 64'h10000030); 
    localparam PAD17 = log2ceil(64'h10000050 - 64'h10000040); 
    localparam PAD18 = log2ceil(64'h10000060 - 64'h10000050); 
    localparam PAD19 = log2ceil(64'h10000070 - 64'h10000060); 
    localparam PAD20 = log2ceil(64'h10000108 - 64'h10000100); 
    localparam PAD21 = log2ceil(64'h10000110 - 64'h10000108); 
    localparam PAD22 = log2ceil(64'h10000120 - 64'h10000110); 
    localparam PAD23 = log2ceil(64'h10001008 - 64'h10001000); 
    localparam PAD24 = log2ceil(64'h10001018 - 64'h10001010); 
    localparam PAD25 = log2ceil(64'h10001028 - 64'h10001020); 
    localparam PAD26 = log2ceil(64'h10002020 - 64'h10002000); 
    localparam PAD27 = log2ceil(64'h10002028 - 64'h10002020); 
    localparam PAD28 = log2ceil(64'h10003010 - 64'h10003000); 
    localparam PAD29 = log2ceil(64'h10003030 - 64'h10003020); 
    localparam PAD30 = log2ceil(64'h10003038 - 64'h10003030); 
    localparam PAD31 = log2ceil(64'h10003050 - 64'h10003040); 
    localparam PAD32 = log2ceil(64'h10003052 - 64'h10003050); 
    localparam PAD33 = log2ceil(64'h10003070 - 64'h10003060); 
    localparam PAD34 = log2ceil(64'h10003080 - 64'h10003070); 
    localparam PAD35 = log2ceil(64'h10003090 - 64'h10003080); 
    localparam PAD36 = log2ceil(64'h100030a0 - 64'h10003090); 
    localparam PAD37 = log2ceil(64'h100030a8 - 64'h100030a0); 
    localparam PAD38 = log2ceil(64'h10004022 - 64'h10004020); 
    // -------------------------------------------------------
    // Work out which address bits are significant based on the
    // address range of the slaves. If the required width is too
    // large or too small, we use the address field width instead.
    // -------------------------------------------------------
    localparam ADDR_RANGE = 64'h10004022;
    localparam RANGE_ADDR_WIDTH = log2ceil(ADDR_RANGE);
    localparam OPTIMIZED_ADDR_H = (RANGE_ADDR_WIDTH > PKT_ADDR_W) ||
                                  (RANGE_ADDR_WIDTH == 0) ?
                                        PKT_ADDR_H :
                                        PKT_ADDR_L + RANGE_ADDR_WIDTH - 1;

    localparam RG = RANGE_ADDR_WIDTH-1;

      wire [PKT_ADDR_W-1 : 0] address = sink_data[OPTIMIZED_ADDR_H : PKT_ADDR_L];

    // -------------------------------------------------------
    // Pass almost everything through, untouched
    // -------------------------------------------------------
    assign sink_ready        = src_ready;
    assign src_valid         = sink_valid;
    assign src_startofpacket = sink_startofpacket;
    assign src_endofpacket   = sink_endofpacket;

    wire [PKT_DEST_ID_W-1:0] default_destid;
    wire [39-1 : 0] default_src_channel;





    nios_system_addr_router_001_default_decode the_default_decode(
      .default_destination_id (default_destid),
      .default_wr_channel   (),
      .default_rd_channel   (),
      .default_src_channel  (default_src_channel)
    );

    always @* begin
        src_data    = sink_data;
        src_channel = default_src_channel;
        src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = default_destid;

        // --------------------------------------------------
        // Address Decoder
        // Sets the channel and destination ID based on the address
        // --------------------------------------------------

    // ( 0x0 .. 0x8000000 )
    if ( {address[RG:PAD0],{PAD0{1'b0}}} == 29'h0   ) begin
            src_channel = 39'b000000000000000000000000000000000000010;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 23;
    end

    // ( 0x8000000 .. 0x8200000 )
    if ( {address[RG:PAD1],{PAD1{1'b0}}} == 29'h8000000   ) begin
            src_channel = 39'b000000000000000000000010000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 25;
    end

    // ( 0x8200000 .. 0x8201000 )
    if ( {address[RG:PAD2],{PAD2{1'b0}}} == 29'h8200000   ) begin
            src_channel = 39'b001000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 33;
    end

    // ( 0x8201000 .. 0x8202000 )
    if ( {address[RG:PAD3],{PAD3{1'b0}}} == 29'h8201000   ) begin
            src_channel = 39'b000100000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 35;
    end

    // ( 0x8202000 .. 0x8202400 )
    if ( {address[RG:PAD4],{PAD4{1'b0}}} == 29'h8202000   ) begin
            src_channel = 39'b000000100000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 34;
    end

    // ( 0x8202400 .. 0x8202440 )
    if ( {address[RG:PAD5],{PAD5{1'b0}}} == 29'h8202400   ) begin
            src_channel = 39'b000010000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 37;
    end

    // ( 0x8202440 .. 0x8202480 )
    if ( {address[RG:PAD6],{PAD6{1'b0}}} == 29'h8202440   ) begin
            src_channel = 39'b000001000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 36;
    end

    // ( 0x9000000 .. 0x9002000 )
    if ( {address[RG:PAD7],{PAD7{1'b0}}} == 29'h9000000   ) begin
            src_channel = 39'b000000000000000000001000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 29;
    end

    // ( 0x9002000 .. 0x9002800 )
    if ( {address[RG:PAD8],{PAD8{1'b0}}} == 29'h9002000   ) begin
            src_channel = 39'b000000010000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 15;
    end

    // ( 0xa000000 .. 0xa000800 )
    if ( {address[RG:PAD9],{PAD9{1'b0}}} == 29'ha000000   ) begin
            src_channel = 39'b000000000000000000000000000000000000001;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 2;
    end

    // ( 0xb000000 .. 0xb000400 )
    if ( {address[RG:PAD10],{PAD10{1'b0}}} == 29'hb000000   ) begin
            src_channel = 39'b000000000000000100000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 24;
    end

    // ( 0xbff0000 .. 0xbff0004 )
    if ( {address[RG:PAD11],{PAD11{1'b0}}} == 29'hbff0000   ) begin
            src_channel = 39'b000000000000000010000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 8;
    end

    // ( 0xc000000 .. 0xc800000 )
    if ( {address[RG:PAD12],{PAD12{1'b0}}} == 29'hc000000   ) begin
            src_channel = 39'b000000000000000000000000000000000000100;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 7;
    end

    // ( 0x10000000 .. 0x10000010 )
    if ( {address[RG:PAD13],{PAD13{1'b0}}} == 29'h10000000   ) begin
            src_channel = 39'b000000000000000000000000000000001000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 22;
    end

    // ( 0x10000010 .. 0x10000020 )
    if ( {address[RG:PAD14],{PAD14{1'b0}}} == 29'h10000010   ) begin
            src_channel = 39'b000000000000000000000000000000010000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 9;
    end

    // ( 0x10000020 .. 0x10000030 )
    if ( {address[RG:PAD15],{PAD15{1'b0}}} == 29'h10000020   ) begin
            src_channel = 39'b000000000000000000000000000000100000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 10;
    end

    // ( 0x10000030 .. 0x10000040 )
    if ( {address[RG:PAD16],{PAD16{1'b0}}} == 29'h10000030   ) begin
            src_channel = 39'b000000000000000000000000000001000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 11;
    end

    // ( 0x10000040 .. 0x10000050 )
    if ( {address[RG:PAD17],{PAD17{1'b0}}} == 29'h10000040   ) begin
            src_channel = 39'b000000000000000000000000000010000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 27;
    end

    // ( 0x10000050 .. 0x10000060 )
    if ( {address[RG:PAD18],{PAD18{1'b0}}} == 29'h10000050   ) begin
            src_channel = 39'b000000000000000000000000000100000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 21;
    end

    // ( 0x10000060 .. 0x10000070 )
    if ( {address[RG:PAD19],{PAD19{1'b0}}} == 29'h10000060   ) begin
            src_channel = 39'b000000000000000000000000001000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 6;
    end

    // ( 0x10000100 .. 0x10000108 )
    if ( {address[RG:PAD20],{PAD20{1'b0}}} == 29'h10000100   ) begin
            src_channel = 39'b000000000000000000000001000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 20;
    end

    // ( 0x10000108 .. 0x10000110 )
    if ( {address[RG:PAD21],{PAD21{1'b0}}} == 29'h10000108   ) begin
            src_channel = 39'b000000000000000000100000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 19;
    end

    // ( 0x10000110 .. 0x10000120 )
    if ( {address[RG:PAD22],{PAD22{1'b0}}} == 29'h10000110   ) begin
            src_channel = 39'b000000000100000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 28;
    end

    // ( 0x10001000 .. 0x10001008 )
    if ( {address[RG:PAD23],{PAD23{1'b0}}} == 29'h10001000   ) begin
            src_channel = 39'b000000000000000000000000000000000001000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 14;
    end

    // ( 0x10001010 .. 0x10001018 )
    if ( {address[RG:PAD24],{PAD24{1'b0}}} == 29'h10001010   ) begin
            src_channel = 39'b000000000000000000000000010000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 26;
    end

    // ( 0x10001020 .. 0x10001028 )
    if ( {address[RG:PAD25],{PAD25{1'b0}}} == 29'h10001020   ) begin
            src_channel = 39'b000000000000001000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 13;
    end

    // ( 0x10002000 .. 0x10002020 )
    if ( {address[RG:PAD26],{PAD26{1'b0}}} == 29'h10002000   ) begin
            src_channel = 39'b000000000000000000000000000000000010000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 12;
    end

    // ( 0x10002020 .. 0x10002028 )
    if ( {address[RG:PAD27],{PAD27{1'b0}}} == 29'h10002020   ) begin
            src_channel = 39'b000000000000000000000000000000000100000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 38;
    end

    // ( 0x10003000 .. 0x10003010 )
    if ( {address[RG:PAD28],{PAD28{1'b0}}} == 29'h10003000   ) begin
            src_channel = 39'b000000000000000000010000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 18;
    end

    // ( 0x10003020 .. 0x10003030 )
    if ( {address[RG:PAD29],{PAD29{1'b0}}} == 29'h10003020   ) begin
            src_channel = 39'b100000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 31;
    end

    // ( 0x10003030 .. 0x10003038 )
    if ( {address[RG:PAD30],{PAD30{1'b0}}} == 29'h10003030   ) begin
            src_channel = 39'b000000000000000000000100000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 30;
    end

    // ( 0x10003040 .. 0x10003050 )
    if ( {address[RG:PAD31],{PAD31{1'b0}}} == 29'h10003040   ) begin
            src_channel = 39'b000000000000000001000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 1;
    end

    // ( 0x10003050 .. 0x10003052 )
    if ( {address[RG:PAD32],{PAD32{1'b0}}} == 29'h10003050   ) begin
            src_channel = 39'b000000000000000000000000100000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 5;
    end

    // ( 0x10003060 .. 0x10003070 )
    if ( {address[RG:PAD33],{PAD33{1'b0}}} == 29'h10003060   ) begin
            src_channel = 39'b000000000000010000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 32;
    end

    // ( 0x10003070 .. 0x10003080 )
    if ( {address[RG:PAD34],{PAD34{1'b0}}} == 29'h10003070   ) begin
            src_channel = 39'b000000000001000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 3;
    end

    // ( 0x10003080 .. 0x10003090 )
    if ( {address[RG:PAD35],{PAD35{1'b0}}} == 29'h10003080   ) begin
            src_channel = 39'b000000000000100000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 4;
    end

    // ( 0x10003090 .. 0x100030a0 )
    if ( {address[RG:PAD36],{PAD36{1'b0}}} == 29'h10003090   ) begin
            src_channel = 39'b010000000000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 17;
    end

    // ( 0x100030a0 .. 0x100030a8 )
    if ( {address[RG:PAD37],{PAD37{1'b0}}} == 29'h100030a0   ) begin
            src_channel = 39'b000000001000000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 16;
    end

    // ( 0x10004020 .. 0x10004022 )
    if ( {address[RG:PAD38],{PAD38{1'b0}}} == 29'h10004020   ) begin
            src_channel = 39'b000000000010000000000000000000000000000;
            src_data[PKT_DEST_ID_H:PKT_DEST_ID_L] = 0;
    end

end


    // --------------------------------------------------
    // Ceil(log2()) function
    // --------------------------------------------------
    function integer log2ceil;
        input reg[65:0] val;
        reg [65:0] i;

        begin
            i = 1;
            log2ceil = 0;

            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction

endmodule


