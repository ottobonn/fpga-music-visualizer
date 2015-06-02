////////////////////////////////////////////////////////////////////
//
// bel_fft_avl_sif.v
//
//
// This file is part of the "bel_fft" project
//
// Author(s):
//     - Frank Storm (Frank.Storm@gmx.net)
//
////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2010-2011 Authors
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

module bel_fft_avl_sif (
        clk_i,
        rst_i,

        address,
        readdata,
        writedata,
        read,
        write,
        byteenable,
        waitrequest,
        readdatavalid,

        adr_o,
        dat_i,
        dat_o,                  
        bsel_o,
        wr_o,
        rd_o,
        ack_i,
        err_i);

    input clk_i;
    input rst_i;

    input [`BEL_FFT_SIF_AWIDTH - 1:0] address;
    output [`BEL_FFT_DWIDTH - 1:0] readdata;
    input [`BEL_FFT_DWIDTH - 1:0] writedata;
    input read;
    input write;
    input [`BEL_FFT_BCNT - 1:0] byteenable;
    output waitrequest;
    output readdatavalid;

    output [`BEL_FFT_SIF_AWIDTH-1:0] adr_o;
    input [`BEL_FFT_DWIDTH-1:0] dat_i;
    output [`BEL_FFT_DWIDTH-1:0] dat_o;
    output [`BEL_FFT_BCNT - 1:0] bsel_o;
    output wr_o;    
    output rd_o;    
    input ack_i;
    input err_i;

    reg last_read;

    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i) begin
            last_read <= 1'b0;
        end else begin
            last_read <= read;
        end
    end


    assign adr_o = address;
    assign readdata = dat_i;
    assign dat_o = writedata;
    assign wr_o = write;
    assign rd_o = read;
    assign readdatavalid = (last_read) ? ack_i : 1'b0;
    assign waitrequest = 1'b0;
    assign bsel_o = byteenable;

endmodule

