////////////////////////////////////////////////////////////////////
//
// bel_fft_avl_mif_16.v
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


module bel_fft_avl_mif_16 (
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

    parameter word_width = 16;

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

    reg [word_width-1:0] dat_re;
    reg [word_width-1:0] dat_im;

    reg ack_rd0;
    reg ack_rd1;
    reg ack_rd2;
    reg ack_rd3;
    wire ack_rd;
    wire ack_wr0;
    wire ack_wr1;
    wire ack_wr2;
    wire ack_wr3;
    reg wait_for_data0;
    reg wait_for_data1;
    reg wait_for_data2;
    reg wait_for_data3;
    wire wait_for_data;


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            wait_for_data0 <= 1'b0;
        end else begin
            if (wait_for_data0) begin
                if (readdatavalid) begin
                    wait_for_data0 <= 1'b0;
                end
            end else begin
                if (~waitrequest && rd0_i && ~ack_rd0) begin
                    wait_for_data0 <= 1'b1;
                end
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            wait_for_data1 <= 1'b0;
        end else begin
            if (wait_for_data1) begin
                if (readdatavalid) begin
                    wait_for_data1 <= 1'b0;
                end
            end else begin
                if (~waitrequest && rd1_i && ~ack_rd1) begin
                    wait_for_data1 <= 1'b1;
                end
            end
        end
    end

    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            wait_for_data2 <= 1'b0;
        end else begin
            if (wait_for_data2) begin
                if (readdatavalid) begin
                    wait_for_data2 <= 1'b0;
                end
            end else begin
                if (~waitrequest && rd2_i && ~ack_rd2) begin
                    wait_for_data2 <= 1'b1;
                end
            end
        end
    end

    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            wait_for_data3 <= 1'b0;
        end else begin
            if (wait_for_data3) begin
                if (readdatavalid) begin
                    wait_for_data3 <= 1'b0;
                end
            end else begin
                if (~waitrequest && rd3_i && ~ack_rd3) begin
                    wait_for_data3 <= 1'b1;
                end
            end
        end
    end

    assign wait_for_data = wait_for_data0 | wait_for_data1 | wait_for_data2 | wait_for_data3;

    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            ack_rd0 <= 1'b0;
        end else begin
            if (wait_for_data0) begin
                if (readdatavalid) begin
                    ack_rd0 <= 1'b1;
                end else begin
                    ack_rd0 <= 1'b0;
                end
            end else begin
                ack_rd0 <= 1'b0;
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            ack_rd1 <= 1'b0;
        end else begin
            if (wait_for_data1) begin
                if (readdatavalid) begin
                    ack_rd1 <= 1'b1;
                end else begin
                    ack_rd1 <= 1'b0;
                end
            end else begin
                ack_rd1 <= 1'b0;
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            ack_rd2 <= 1'b0;
        end else begin
            if (wait_for_data2) begin
                if (readdatavalid) begin
                    ack_rd2 <= 1'b1;
                end else begin
                    ack_rd2 <= 1'b0;
                end
            end else begin
                ack_rd2 <= 1'b0;
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            ack_rd3 <= 1'b0;
        end else begin
            if (wait_for_data3) begin
                if (readdatavalid) begin
                    ack_rd3 <= 1'b1;
                end else begin
                    ack_rd3 <= 1'b0;
                end
            end else begin
                ack_rd3 <= 1'b0;
            end
        end
    end


    always @ (posedge clk_i) begin
        if ((wait_for_data0 || wait_for_data1 || wait_for_data2 || wait_for_data3) && readdatavalid) begin
            dat_re <= readdata[`BEL_FFT_DWIDTH - 1:word_width];
            dat_im <= readdata[word_width - 1:0];
        end
    end

    assign writedata = {dat_re0_i, dat_im0_i} | {dat_re1_i, dat_im1_i} |
            {dat_re2_i, dat_im2_i} | {dat_re3_i, dat_im3_i};
    assign address = adr0_i | adr1_i | adr2_i | adr3_i;

    assign rd = rd0_i | rd1_i | rd2_i | rd3_i;
    assign wr = wr0_i | wr1_i | wr2_i | wr3_i;

    assign write = wr;
    assign read = rd & ~wait_for_data & ~ack_rd;

    assign ack_wr0 = wr0_i & ~waitrequest;
    assign ack_wr1 = wr1_i & ~waitrequest;
    assign ack_wr2 = wr2_i & ~waitrequest;
    assign ack_wr3 = wr3_i & ~waitrequest;

    assign ack0_o = ack_rd0 | ack_wr0;
    assign ack1_o = ack_rd1 | ack_wr1;
    assign ack2_o = ack_rd2 | ack_wr2;
    assign ack3_o = ack_rd3 | ack_wr3;
    assign ack_rd = ack_rd0 | ack_rd1 | ack_rd2 | ack_rd3;


    assign dat_im0_o = dat_im;
    assign dat_im1_o = dat_im;
    assign dat_im2_o = dat_im;
    assign dat_im3_o = dat_im;

    assign dat_re0_o = dat_re;
    assign dat_re1_o = dat_re;
    assign dat_re2_o = dat_re;
    assign dat_re3_o = dat_re;

    assign err0_o = 1'b0;
    assign err1_o = 1'b0;
    assign err2_o = 1'b0;
    assign err3_o = 1'b0;

endmodule

