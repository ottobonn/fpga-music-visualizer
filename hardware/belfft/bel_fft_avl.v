////////////////////////////////////////////////////////////////////
//
// bel_fft_avl.v
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


module bel_fft_avl (
        clk_i,
        rst_i,

        m_address,
        m_readdata,
        m_writedata,
        m_read,
        m_write,
        m_waitrequest,
        m_readdatavalid,

        s_address,
        s_readdata,
        s_writedata,
        s_read,
        s_write,
        s_byteenable,
        s_waitrequest,
        s_readdatavalid,

        tw_adr,
        tw_rd,
        tw_re,
        tw_im,
        tw_cfg_sel,

        int_o);

    parameter word_width = 16;
    parameter config_num = 1;
    parameter stage_num = 4;
    parameter twiddle_rom_max_awidth = 8;
    parameter fft_size = 256;
    parameter fft_size1 = 256;
    parameter fft_size2 = 256;
    parameter fft_size3 = 256;
    parameter has_butterfly2 = 1;

    input clk_i;
    input rst_i;

    output [`BEL_FFT_MIF_AWIDTH - 1:0] m_address;
    input [`BEL_FFT_DWIDTH - 1:0] m_readdata;
    output [`BEL_FFT_DWIDTH - 1:0] m_writedata;
    output m_read;
    output m_write;
    input m_waitrequest;
    input m_readdatavalid;

    input [`BEL_FFT_SIF_AWIDTH - 1:0] s_address;
    output [`BEL_FFT_DWIDTH - 1:0] s_readdata;
    input [`BEL_FFT_DWIDTH - 1:0] s_writedata;
    input s_read;
    input s_write;
    input [`BEL_FFT_BCNT - 1:0] s_byteenable;
    output s_waitrequest;
    output s_readdatavalid;

    output [twiddle_rom_max_awidth - 1:0] tw_adr;
    output tw_rd;
    input [word_width - 1:0] tw_re;
    input [word_width - 1:0] tw_im;
    output [config_num - 1:0] tw_cfg_sel;

    output int_o;

    wire event_o;
    wire [`BEL_FFT_AWIDTH-1:0] butterfly_generic_adr;
    wire [word_width-1:0] butterfly_generic_dat_re_i;
    wire [word_width-1:0] butterfly_generic_dat_re_o;
    wire [word_width-1:0] butterfly_generic_dat_im_i;
    wire [word_width-1:0] butterfly_generic_dat_im_o;
    wire butterfly_generic_wr;
    wire butterfly_generic_rd;    
    wire butterfly_generic_ack;
    wire butterfly_generic_err;

    wire [`BEL_FFT_AWIDTH-1:0] butterfly2_adr;
    wire [word_width-1:0] butterfly2_dat_re_i;
    wire [word_width-1:0] butterfly2_dat_re_o;
    wire [word_width-1:0] butterfly2_dat_im_i;
    wire [word_width-1:0] butterfly2_dat_im_o;
    wire butterfly2_wr;
    wire butterfly2_rd;    
    wire butterfly2_ack;
    wire butterfly2_err;

    wire [`BEL_FFT_AWIDTH-1:0] butterfly4_adr;
    wire [word_width-1:0] butterfly4_dat_re_i;
    wire [word_width-1:0] butterfly4_dat_re_o;
    wire [word_width-1:0] butterfly4_dat_im_i;
    wire [word_width-1:0] butterfly4_dat_im_o;
    wire butterfly4_wr;    
    wire butterfly4_rd;    
    wire butterfly4_ack;
    wire butterfly4_err;

    wire [`BEL_FFT_AWIDTH-1:0] copy_adr;
    wire [word_width-1:0] copy_dat_re_i;
    wire [word_width-1:0] copy_dat_re_o;
    wire [word_width-1:0] copy_dat_im_i;
    wire [word_width-1:0] copy_dat_im_o;
    wire copy_wr;    
    wire copy_rd;    
    wire copy_ack;
    wire copy_err;

    wire [`BEL_FFT_SIF_AWIDTH-1:0] ctrl_adr;
    wire [`BEL_FFT_DWIDTH-1:0] ctrl_dat_i;
    wire [`BEL_FFT_DWIDTH-1:0] ctrl_dat_o;
    wire ctrl_wr;    
    wire ctrl_rd;    
    wire ctrl_ack;
    wire ctrl_err;
    wire [`BEL_FFT_BCNT-1:0] ctrl_bsel;
    wire [`BEL_FFT_DWIDTH-1:0] user;


    generate
        if (word_width == 16) begin

            bel_fft_avl_mif_16 #(
                    .word_width (word_width))
                    u_mif (
                    .clk_i (clk_i),
                    .rst_i (rst_i),

                    .address (m_address),
                    .readdata (m_readdata),
                    .writedata (m_writedata),
                    .read (m_read),
                    .write (m_write),
                    .waitrequest (m_waitrequest),
                    .readdatavalid (m_readdatavalid),

                    .adr0_i (butterfly4_adr),
                    .dat_re0_i (butterfly4_dat_re_o),
                    .dat_re0_o (butterfly4_dat_re_i),
                    .dat_im0_i (butterfly4_dat_im_o),
                    .dat_im0_o (butterfly4_dat_im_i),                  
                    .wr0_i (butterfly4_wr),
                    .rd0_i (butterfly4_rd),
                    .ack0_o (butterfly4_ack),
                    .err0_o (butterfly4_err),
 
                    .adr1_i (copy_adr),
                    .dat_re1_i (copy_dat_re_o),
                    .dat_re1_o (copy_dat_re_i),                  
                    .dat_im1_i (copy_dat_im_o),
                    .dat_im1_o (copy_dat_im_i),                  
                    .wr1_i (copy_wr),
                    .rd1_i (copy_rd),
                    .ack1_o (copy_ack),
                    .err1_o (copy_err),

                    .adr2_i (butterfly2_adr),
                    .dat_re2_i (butterfly2_dat_re_o),
                    .dat_re2_o (butterfly2_dat_re_i),
                    .dat_im2_i (butterfly2_dat_im_o),
                    .dat_im2_o (butterfly2_dat_im_i),                  
                    .wr2_i (butterfly2_wr),
                    .rd2_i (butterfly2_rd),
                    .ack2_o (butterfly2_ack),
                    .err2_o (butterfly2_err),
 
                    .adr3_i (butterfly_generic_adr),
                    .dat_re3_i (butterfly_generic_dat_re_o),
                    .dat_re3_o (butterfly_generic_dat_re_i),
                    .dat_im3_i (butterfly_generic_dat_im_o),
                    .dat_im3_o (butterfly_generic_dat_im_i),                  
                    .wr3_i (butterfly_generic_wr),
                    .rd3_i (butterfly_generic_rd),
                    .ack3_o (butterfly_generic_ack),
                    .err3_o (butterfly_generic_err),

                    .user_i (user));


        end

        if (word_width == 32) begin
            bel_fft_avl_mif_32 #(
                    .word_width (word_width))
                    u_mif (
                    .clk_i (clk_i),
                    .rst_i (rst_i),

                    .address (m_address),
                    .readdata (m_readdata),
                    .writedata (m_writedata),
                    .read (m_read),
                    .write (m_write),
                    .waitrequest (m_waitrequest),
                    .readdatavalid (m_readdatavalid),

                    .adr0_i (butterfly4_adr),
                    .dat_re0_i (butterfly4_dat_re_o),
                    .dat_re0_o (butterfly4_dat_re_i),
                    .dat_im0_i (butterfly4_dat_im_o),
                    .dat_im0_o (butterfly4_dat_im_i),                  
                    .wr0_i (butterfly4_wr),
                    .rd0_i (butterfly4_rd),
                    .ack0_o (butterfly4_ack),
                    .err0_o (butterfly4_err),
 
                    .adr1_i (copy_adr),
                    .dat_re1_i (copy_dat_re_o),
                    .dat_re1_o (copy_dat_re_i),                  
                    .dat_im1_i (copy_dat_im_o),
                    .dat_im1_o (copy_dat_im_i),                  
                    .wr1_i (copy_wr),
                    .rd1_i (copy_rd),
                    .ack1_o (copy_ack),
                    .err1_o (copy_err),

                    .adr2_i (butterfly2_adr),
                    .dat_re2_i (butterfly2_dat_re_o),
                    .dat_re2_o (butterfly2_dat_re_i),
                    .dat_im2_i (butterfly2_dat_im_o),
                    .dat_im2_o (butterfly2_dat_im_i),                  
                    .wr2_i (butterfly2_wr),
                    .rd2_i (butterfly2_rd),
                    .ack2_o (butterfly2_ack),
                    .err2_o (butterfly2_err),

                    .adr3_i (butterfly_generic_adr),
                    .dat_re3_i (butterfly_generic_dat_re_o),
                    .dat_re3_o (butterfly_generic_dat_re_i),
                    .dat_im3_i (butterfly_generic_dat_im_o),
                    .dat_im3_o (butterfly_generic_dat_im_i),                  
                    .wr3_i (butterfly_generic_wr),
                    .rd3_i (butterfly_generic_rd),
                    .ack3_o (butterfly_generic_ack),
                    .err3_o (butterfly_generic_err),

                    .user_i (user));
        end
    endgenerate


    bel_fft_avl_sif u_sif (
            .clk_i (clk_i),
            .rst_i (rst_i),

            .address (s_address),
            .readdata (s_readdata),
            .writedata (s_writedata),
            .read (s_read),
            .write (s_write),
            .byteenable (s_byteenable),
            .waitrequest (s_waitrequest),
            .readdatavalid (s_readdatavalid),

            .adr_o (ctrl_adr),
            .dat_i (ctrl_dat_o),
            .dat_o (ctrl_dat_i),
            .bsel_o (ctrl_bsel),
            .wr_o (ctrl_wr),
            .rd_o (ctrl_rd),
            .ack_i (ctrl_ack),
            .err_i (ctrl_err));


    bel_fft_core #(
            .word_width (word_width),
            .config_num (config_num),
            .stage_num (stage_num),
            .twiddle_rom_max_awidth (twiddle_rom_max_awidth),
            .fft_size (fft_size),
            .fft_size1 (fft_size1),
            .fft_size2 (fft_size2),
            .fft_size3 (fft_size3),
            .has_butterfly2 (has_butterfly2))
            u_core (
            .clk_i (clk_i),
            .rst_i (rst_i),

            .butterfly_generic_adr_o (butterfly_generic_adr),
            .butterfly_generic_dat_re_i (butterfly_generic_dat_re_i),
            .butterfly_generic_dat_re_o (butterfly_generic_dat_re_o),
            .butterfly_generic_dat_im_i (butterfly_generic_dat_im_i),
            .butterfly_generic_dat_im_o (butterfly_generic_dat_im_o),
            .butterfly_generic_wr_o (butterfly_generic_wr),
            .butterfly_generic_rd_o (butterfly_generic_rd),
            .butterfly_generic_ack_i (butterfly_generic_ack),
            .butterfly_generic_err_i (butterfly_generic_err),

            .butterfly2_adr_o (butterfly2_adr),
            .butterfly2_dat_re_i (butterfly2_dat_re_i),
            .butterfly2_dat_re_o (butterfly2_dat_re_o),
            .butterfly2_dat_im_i (butterfly2_dat_im_i),
            .butterfly2_dat_im_o (butterfly2_dat_im_o),
            .butterfly2_wr_o (butterfly2_wr),
            .butterfly2_rd_o (butterfly2_rd),
            .butterfly2_ack_i (butterfly2_ack),
            .butterfly2_err_i (butterfly2_err),

            .butterfly4_adr_o (butterfly4_adr),
            .butterfly4_dat_re_i (butterfly4_dat_re_i),
            .butterfly4_dat_re_o (butterfly4_dat_re_o),
            .butterfly4_dat_im_i (butterfly4_dat_im_i),
            .butterfly4_dat_im_o (butterfly4_dat_im_o),
            .butterfly4_wr_o (butterfly4_wr),
            .butterfly4_rd_o (butterfly4_rd),
            .butterfly4_ack_i (butterfly4_ack),
            .butterfly4_err_i (butterfly4_err),

            .copy_adr_o (copy_adr),
            .copy_dat_re_i (copy_dat_re_i),
            .copy_dat_re_o (copy_dat_re_o),
            .copy_dat_im_i (copy_dat_im_i),
            .copy_dat_im_o (copy_dat_im_o),
            .copy_wr_o (copy_wr),
            .copy_rd_o (copy_rd),
            .copy_ack_i (copy_ack),
            .copy_err_i (copy_err),

            .ctrl_adr_i (ctrl_adr),
            .ctrl_dat_i (ctrl_dat_i),
            .ctrl_dat_o (ctrl_dat_o),
            .ctrl_bsel_i (ctrl_bsel),
            .ctrl_wr_i (ctrl_wr),
            .ctrl_rd_i (ctrl_rd),
            .ctrl_ack_o (ctrl_ack),
            .ctrl_err_o (ctrl_err),

            .tw_adr (tw_adr),
            .tw_rd (tw_rd),
            .tw_re (tw_re),
            .tw_im (tw_im),
            .tw_cfg_sel (tw_cfg_sel),

            .event_o (event_o),
            .int_o (int_o),

            .user_o (user));


endmodule
