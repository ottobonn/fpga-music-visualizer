////////////////////////////////////////////////////////////////////
//
// bel_fft_avl_mif_32.v
//
//
// This file is part of the "bel_fft" project
//
// Author(s):
//     - Frank Storm (Frank.Storm@gmx.net)
//
////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2010-2013 Authors
//
// This source file may be used and distributed without
// restriction provided that this copyright statement is not
// removed from the file and that any derivative work contains
// the original copyright notice and the associated disclaimer.
//
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General
// Public License along with this source; if not, download it
// from http://www.gnu.org/licenses/lgpl.html
//
////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log$
//
////////////////////////////////////////////////////////////////////


`include "bel_fft_def.v"


module bel_fft_avl_mif_32 (
        clk_i,
        rst_i,

        address,
        readdata,
        writedata,
        read,
        write,
        waitrequest,
        readdatavalid,

        adr0_i,
        dat_re0_i,
        dat_re0_o,                  
        dat_im0_i,
        dat_im0_o,                  
        wr0_i,
        rd0_i,
        ack0_o,
        err0_o,
 
        adr1_i,
        dat_re1_i,
        dat_re1_o,                  
        dat_im1_i,
        dat_im1_o,                  
        wr1_i,
        rd1_i,
        ack1_o,
        err1_o,

        adr2_i,
        dat_re2_i,
        dat_re2_o,                  
        dat_im2_i,
        dat_im2_o,                  
        wr2_i,
        rd2_i,
        ack2_o,
        err2_o,

        adr3_i,
        dat_re3_i,
        dat_re3_o,                  
        dat_im3_i,
        dat_im3_o,                  
        wr3_i,
        rd3_i,
        ack3_o,
        err3_o,

        user_i);

    parameter word_width = 32;

    input clk_i;
    input rst_i;

    output [`BEL_FFT_MIF_AWIDTH - 1:0] address;
    input [`BEL_FFT_DWIDTH - 1:0] readdata;
    output [`BEL_FFT_DWIDTH - 1:0] writedata;
    output read;
    output write;
    input waitrequest;
    input readdatavalid;

    input [`BEL_FFT_AWIDTH-1:0] adr0_i;
    input [word_width-1:0] dat_re0_i;
    output [word_width-1:0] dat_re0_o;
    input [word_width-1:0] dat_im0_i;
    output [word_width-1:0] dat_im0_o;
    input wr0_i;    
    input rd0_i;    
    output ack0_o;
    output err0_o;

    input [`BEL_FFT_AWIDTH-1:0] adr1_i;
    input [word_width-1:0] dat_re1_i;
    output [word_width-1:0] dat_re1_o;
    input [word_width-1:0] dat_im1_i;
    output [word_width-1:0] dat_im1_o;
    input wr1_i;    
    input rd1_i;    
    output ack1_o;
    output err1_o;

    input [`BEL_FFT_AWIDTH-1:0] adr2_i;
    input [word_width-1:0] dat_re2_i;
    output [word_width-1:0] dat_re2_o;
    input [word_width-1:0] dat_im2_i;
    output [word_width-1:0] dat_im2_o;
    input wr2_i;
    input rd2_i;    
    output ack2_o;
    output err2_o;

    input [`BEL_FFT_AWIDTH-1:0] adr3_i;
    input [word_width-1:0] dat_re3_i;
    output [word_width-1:0] dat_re3_o;
    input [word_width-1:0] dat_im3_i;
    output [word_width-1:0] dat_im3_o;
    input wr3_i;
    input rd3_i;    
    output ack3_o;
    output err3_o;

    input [`BEL_FFT_DWIDTH-1:0] user_i;

    wire rd;
    wire wr;

    reg [word_width-1:0] dat_re_o;
    reg [word_width-1:0] dat_im_o;
    wire [word_width-1:0] dat_re_i;
    wire [word_width-1:0] dat_im_i;


    reg [`BEL_FFT_DWIDTH - 1:0] writedata;
    reg [`BEL_FFT_MIF_AWIDTH - 1:0] address;
    reg read;
    reg write;
    reg ack_rd;
    reg [word_width-1:0] tmp_dat_re;

    reg [`BEL_FFT_AWIDTH-1:0] next_adr;
    reg [1:0] addr_state;
    reg [1:0] next_addr_state;
    reg [1:0] data_state;
    reg [1:0] next_data_state;
    reg ack0_o;
    reg ack1_o;
    reg ack2_o;
    reg ack3_o;
    wire [`BEL_FFT_AWIDTH-1:0] adr;


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            addr_state <= `BEL_MIF_RE_STATE;
        end else begin
            addr_state <= next_addr_state;
        end
    end


    always @ (addr_state or waitrequest or rd or wr or ack_rd) begin
        case (addr_state) 
            `BEL_MIF_RE_STATE: begin
                if ((rd || wr) && ~waitrequest) begin
                    next_addr_state = `BEL_MIF_IM_STATE;
                end else begin
                    next_addr_state = `BEL_MIF_RE_STATE;
                end
            end
            `BEL_MIF_IM_STATE: begin
                if (rd) begin
                    if (waitrequest) begin
                        next_addr_state = `BEL_MIF_IM_STATE;
                    end else begin
                        next_addr_state = `BEL_MIF_IDLE_STATE;
                    end
                end else begin
                    if (wr) begin
                        if (waitrequest) begin
                            next_addr_state = `BEL_MIF_IM_STATE;
                        end else begin
                            next_addr_state = `BEL_MIF_RE_STATE;
                        end
                    end else begin
                        // We should not get here
                        next_addr_state = `BEL_MIF_RE_STATE;
                    end
                end
            end
            `BEL_MIF_IDLE_STATE: begin
                if (rd) begin
                    if (ack_rd) begin
                        next_addr_state = `BEL_MIF_RE_STATE;
                    end else begin
                        next_addr_state = `BEL_MIF_IDLE_STATE;
                    end
                end else begin
                    // We should not get here
                    next_addr_state = `BEL_MIF_RE_STATE;
                end
            end
            default: begin
                next_addr_state = `BEL_MIF_RE_STATE;
            end
        endcase
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            data_state <= `BEL_MIF_IDLE_STATE;
        end else begin
            data_state <= next_data_state;
        end
    end


    always @ (data_state or readdatavalid or rd or wr) begin
        case (data_state) 
            `BEL_MIF_RE_STATE: begin
                if (rd && readdatavalid) begin
                    next_data_state = `BEL_MIF_IM_STATE;
                end else begin
                    next_data_state = `BEL_MIF_RE_STATE;
                end
            end
            `BEL_MIF_IM_STATE: begin
                if (rd && readdatavalid) begin
                    next_data_state = `BEL_MIF_IDLE_STATE;
                end else begin
                    next_data_state = `BEL_MIF_IM_STATE;
                end
            end
            `BEL_MIF_IDLE_STATE: begin
                if (rd) begin
                    next_data_state = `BEL_MIF_RE_STATE;
                end else begin
                    next_data_state = `BEL_MIF_IDLE_STATE;
                end
            end
            default: begin
                next_data_state = `BEL_MIF_IDLE_STATE;
            end
        endcase
    end


    always @ (addr_state or wr or rd or adr or next_adr or dat_re_i or dat_im_i) begin
        case (addr_state) 
            `BEL_MIF_RE_STATE: begin
                write = wr;
                read = rd;
                address = adr;
                writedata = dat_re_i;
            end
            `BEL_MIF_IM_STATE: begin
                write = wr;
                read = rd;
                address = next_adr;
                writedata = dat_im_i;
            end
            default: begin
                write = 1'b0;
                read = 1'b0;
                // We con't care about the address value here
                writedata = dat_re_i;
                address = adr;
            end
        endcase
    end


    always @ (addr_state or wr0_i or rd0_i or waitrequest or ack_rd) begin
        if (wr0_i) begin
            if (addr_state == `BEL_MIF_IM_STATE) begin
                ack0_o = ~waitrequest;
            end else begin
                ack0_o = 1'b0;
            end
        end else begin
            if (rd0_i) begin
                ack0_o = ack_rd;
            end else begin
                ack0_o = 1'b0;
            end
        end
    end


    always @ (addr_state or wr1_i or rd1_i or waitrequest or ack_rd) begin
        if (wr1_i) begin
            if (addr_state == `BEL_MIF_IM_STATE) begin
                ack1_o = ~waitrequest;
            end else begin
                ack1_o = 1'b0;
            end
        end else begin
            if (rd1_i) begin
                ack1_o = ack_rd;
            end else begin
                ack1_o = 1'b0;
            end
        end
    end


    always @ (addr_state or wr2_i or rd2_i or waitrequest or ack_rd) begin
        if (wr2_i) begin
            if (addr_state == `BEL_MIF_IM_STATE) begin
                ack2_o = ~waitrequest;
            end else begin
                ack2_o = 1'b0;
            end
        end else begin
            if (rd2_i) begin
                ack2_o = ack_rd;
            end else begin
                ack2_o = 1'b0;
            end
        end
    end


    always @ (addr_state or wr3_i or rd3_i or waitrequest or ack_rd) begin
        if (wr3_i) begin
            if (addr_state == `BEL_MIF_IM_STATE) begin
                ack3_o = ~waitrequest;
            end else begin
                ack3_o = 1'b0;
            end
        end else begin
            if (rd3_i) begin
                ack3_o = ack_rd;
            end else begin
                ack3_o = 1'b0;
            end
        end
    end


    always @ (posedge clk_i) begin
        next_adr <= adr + `BEL_FFT_BCNT;
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            ack_rd <= 1'b0;
        end else begin
            if (rd && (data_state == `BEL_MIF_IM_STATE)) begin
                ack_rd <= readdatavalid;
            end else begin
                ack_rd <= 1'b0;
            end
        end
    end


    always @ (posedge clk_i) begin
        case (data_state) 
            `BEL_MIF_RE_STATE: begin
                if (rd & readdatavalid) begin
                    tmp_dat_re <= readdata;
                end
            end
            `BEL_MIF_IM_STATE: begin
                if (rd & readdatavalid) begin
                    dat_im_o <= readdata;
                    dat_re_o <= tmp_dat_re;
                end
            end
        endcase
    end


    assign rd = rd0_i | rd1_i | rd2_i | rd3_i;
    assign wr = wr0_i | wr1_i | wr2_i | wr3_i;
    assign adr = adr0_i | adr1_i | adr2_i | adr3_i;

    assign dat_im_i = dat_im0_i | dat_im1_i | dat_im2_i | dat_im3_i;
    assign dat_re_i = dat_re0_i | dat_re1_i | dat_re2_i | dat_re3_i;

    assign dat_im0_o = dat_im_o;
    assign dat_im1_o = dat_im_o;
    assign dat_im2_o = dat_im_o;
    assign dat_im3_o = dat_im_o;

    assign dat_re0_o = dat_re_o;
    assign dat_re1_o = dat_re_o;
    assign dat_re2_o = dat_re_o;
    assign dat_re3_o = dat_re_o;

    assign err0_o = 1'b0;
    assign err1_o = 1'b0;
    assign err2_o = 1'b0;
    assign err3_o = 1'b0;

endmodule

