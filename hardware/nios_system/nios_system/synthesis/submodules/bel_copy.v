////////////////////////////////////////////////////////////////////
//
// bel_copy.v
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


/*
        do{
            *Fout = *f;
            f += fstride*in_stride;
        }while(++Fout != Fout_end );
*/

`include "bel_fft_def.v"

`define BEL_COPY_IDLE_STATE 2'b00
`define BEL_COPY_LOAD_STATE 2'b01
`define BEL_COPY_STORE_STATE 2'b10

module bel_copy (
    clk_i,
    rst_i,
    adr_o,
    dat_re_o,
    dat_re_i,                  
    dat_im_o,
    dat_im_i,                  
    wr_o,
    rd_o,
    ack_i,
    err_i,
    start,
    finished,
    finadr,
    foutadr,
    fstride,
    n);

    parameter word_width = 16;

    input clk_i;
    input rst_i;
    output [`BEL_FFT_AWIDTH-1:0] adr_o;
    output [word_width-1:0] dat_re_o;
    input [word_width-1:0] dat_re_i;
    output [word_width-1:0] dat_im_o;
    input [word_width-1:0] dat_im_i;
    output wr_o;    
    output rd_o;    
    input ack_i;
    input err_i;

    input  start;
    output finished;
   
    input [`BEL_FFT_AWIDTH-1:0] finadr;
    input [`BEL_FFT_AWIDTH-1:0] foutadr;
    input [`BEL_FFT_CTRL_NUM_WIDTH-1:0] fstride;
    input [`BEL_FFT_CTRL_NUM_WIDTH-1:0] n;

    reg [`BEL_FFT_AWIDTH-1:0] adr_o;
    reg wr_o;    
    reg rd_o;    
   
    reg [`BEL_FFT_CTRL_NUM_WIDTH-1:0] i;
    reg [1:0] next_state;
    reg [1:0] state;

    reg [`BEL_FFT_AWIDTH-1:0] finadr_loop;
    reg [`BEL_FFT_AWIDTH-1:0] fadr;
    reg [word_width-1:0] dat_re;
    reg [word_width-1:0] dat_im;

   
    always @ (state or finadr_loop or fadr) begin
        case (state)
            `BEL_COPY_LOAD_STATE: begin
                adr_o = finadr_loop;
                rd_o = 1'b1;
                wr_o = 1'b0;
            end
            `BEL_COPY_STORE_STATE: begin
                adr_o = fadr;
                rd_o = 1'b0;
                wr_o = 1'b1;
            end
            default: begin
                adr_o = 32'h00000000;
                rd_o = 1'b0;
                wr_o = 1'b0;
            end
        endcase
    end

   
    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            finadr_loop <= 32'h00000000;
        end else begin
            case (state)
                `BEL_COPY_IDLE_STATE:
                    if (start) begin
                       finadr_loop <= finadr;
                    end
                `BEL_COPY_LOAD_STATE:
                    if (ack_i) begin
                       finadr_loop <= finadr_loop +
                               fstride * (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT);
                    end
                default: begin
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            fadr <= 0;
        end else begin
            case (state)
                `BEL_COPY_IDLE_STATE:
                    if (start) begin
                       fadr <= foutadr;
                    end
                `BEL_COPY_STORE_STATE:
                    if (ack_i) begin
                       fadr <= fadr + word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT;
                    end
            endcase
        end
    end        


    always @ (posedge clk_i) begin
        case (state)
            `BEL_COPY_IDLE_STATE:
                i <= n;
            `BEL_COPY_LOAD_STATE:
                if (ack_i) begin
                    i <= i - 1'b1;
                end
        endcase
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            dat_re <= 16'h0000;
            dat_im <= 16'h0000;
        end else begin
            case (state)
                `BEL_COPY_IDLE_STATE: begin
                    dat_re <= 16'h0000;
                    dat_im <= 16'h0000;
                 end
                `BEL_COPY_LOAD_STATE:
                    if (ack_i == 1'b1) begin
                        dat_re <= dat_re_i;
                        dat_im <= dat_im_i;
                    end
            endcase
        end
    end        


    assign dat_re_o = dat_re;
    assign dat_im_o = dat_im;
   

    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            state <= `BEL_COPY_IDLE_STATE;
        end else begin
            state <= next_state;
        end
    end        


    always @ (state or ack_i or i or start) begin
        case (state)
            `BEL_COPY_IDLE_STATE:
                if (start) begin
                    next_state = `BEL_COPY_LOAD_STATE;
                end else begin
                    next_state = `BEL_COPY_IDLE_STATE;
                end
            `BEL_COPY_LOAD_STATE: begin
                if (ack_i == 1'b1) begin
                    next_state = `BEL_COPY_STORE_STATE;
                end else begin
                    next_state = `BEL_COPY_LOAD_STATE;
                end
            end
            `BEL_COPY_STORE_STATE: begin
                if (ack_i == 1'b1) begin
                    if (i == 0) begin
                        next_state = `BEL_COPY_IDLE_STATE;
                    end else begin
                        next_state = `BEL_COPY_LOAD_STATE;
                    end
                end else begin
                    next_state = `BEL_COPY_STORE_STATE;
                end
            end
            default: begin
                next_state = `BEL_COPY_IDLE_STATE;
            end
        endcase
    end

    assign finished = (state == `BEL_COPY_STORE_STATE) & 
            (next_state == `BEL_COPY_IDLE_STATE) ? 1'b1 : 1'b0;
   
   
endmodule // bel_copy
