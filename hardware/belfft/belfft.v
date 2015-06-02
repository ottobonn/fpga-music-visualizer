////////////////////////////////////////////////////////////////////
//
// belfft.v
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


module belfft (
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

        int_o);

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

    output int_o;

    wire [7 - 1:0] tw_adr;
    wire tw_rd;
    wire [32 - 1:0] tw_re;
    wire [32 - 1:0] tw_im;
    wire [1 - 1:0] tw_cfg_sel;

    bel_fft_avl  #(
            .word_width (32),
            .config_num (1),
            .stage_num (4),
            .twiddle_rom_max_awidth (7),
            .fft_size (128),
            .fft_size1 (0),
            .fft_size2 (0),
            .fft_size3 (0),
            .has_butterfly2 (1))
            u_core (
            .clk_i (clk_i),
            .rst_i (rst_i),

            .m_address (m_address),
            .m_readdata (m_readdata),
            .m_writedata (m_writedata),
            .m_read (m_read),
            .m_write (m_write),
            .m_waitrequest (m_waitrequest),
            .m_readdatavalid (m_readdatavalid),

            .s_address (s_address),
            .s_readdata (s_readdata),
            .s_writedata (s_writedata),
            .s_read (s_read),
            .s_write (s_write),
            .s_byteenable (s_byteenable),
            .s_waitrequest (s_waitrequest),
            .s_readdatavalid (s_readdatavalid),

            .tw_adr (tw_adr),
            .tw_rd (tw_rd),
            .tw_re (tw_re),
            .tw_im (tw_im),
            .tw_cfg_sel (tw_cfg_sel),

            .int_o (int_o));


    belfft_twiddle_roms #(.word_width (32),
            .config_num (1),
            .max_awidth (7),
            .size (128),
            .awidth (7),
            .file_name ("belfft_twiddle_rom0.dat"),
            .size2 (0),
            .awidth2 (0),
            .file_name2 (""),
            .size3 (0),
            .awidth3 (0),
            .file_name3 (""),
            .size4 (0),
            .awidth4 (0),
            .file_name4 ("")
            ) u_twiddles (
            .clk_i (clk_i),
            .rst_i (rst_i),
            .adr_i (tw_adr),
            .rd_i (tw_rd),
            .dat_o ({tw_re, tw_im}),
            .cfg_sel_i (tw_cfg_sel));

endmodule

