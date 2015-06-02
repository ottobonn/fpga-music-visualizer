////////////////////////////////////////////////////////////////////
//
// bel_butterfly2.v
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


module bel_butterfly2 (
        clk_i,
        rst_i,
        adr_o,
        dat_re_i,
        dat_re_o,                  
        dat_im_i,
        dat_im_o,                  
        wr_o,
        rd_o,
        ack_i,
        err_i,

        start,
        finish,
        m,
        fstride,
        foutadr,
        tw_adr_o,
        tw_rd_o,
        tw_re_i,
        tw_im_i);

    parameter word_width = 16;
    parameter twiddle_rom_awidth = 8;

    input clk_i;
    input rst_i;

    output [`BEL_FFT_AWIDTH-1:0] adr_o;
    input [word_width - 1:0] dat_re_i;
    output [word_width - 1:0] dat_re_o;
    input [word_width - 1:0] dat_im_i;
    output [word_width - 1:0] dat_im_o;
    output wr_o;
    output rd_o;
    input ack_i;
    input err_i;

    output finish;
    output [twiddle_rom_awidth-1:0] tw_adr_o;
    output tw_rd_o;
    input [word_width - 1:0] tw_re_i;
    input [word_width - 1:0] tw_im_i;
    reg tw_rd_o;

    input start;
    input [`BEL_FFT_CTRL_NUM_WIDTH-1:0] m;
    input [`BEL_FFT_CTRL_NUM_WIDTH-1:0] fstride;
    input [`BEL_FFT_AWIDTH-1:0] foutadr;

    reg [twiddle_rom_awidth-1:0] tw_adr_o;
    reg [`BEL_FFT_AWIDTH-1:0] foutadr0;
    reg [`BEL_FFT_AWIDTH-1:0] foutadr2;

    reg [word_width - 1:0] dat_re_o;
    reg [word_width - 1:0] dat_im_o;

    reg signed [word_width - 1:0]     t_re;
    reg signed [word_width - 1:0]     t_im;
    wire signed [word_width - 1:0]    mul_x_re;
    wire signed [word_width - 1:0]    mul_x_im;

    reg [3:0] next_state;
    reg [3:0] state;

    reg signed [word_width - 1:0]     fout_re;
    reg signed [word_width - 1:0]     fout_im;
    reg signed [word_width - 1:0]     fout2_re;
    reg signed [word_width - 1:0]     fout2_im;
    wire signed [word_width - 1:0]    div2_fout_re;
    wire signed [word_width - 1:0]    div2_fout_im;

    reg signed [word_width - 1:0]    div2_dat_re;
    reg signed [word_width - 1:0]    div2_dat_im;

    wire signed [word_width - 1:0]    add_x_re;
    wire signed [word_width - 1:0]    add_x_im;
    wire signed [word_width - 1:0]    sub_x_re;
    wire signed [word_width - 1:0]    sub_x_im;

    reg [twiddle_rom_awidth-1:0]    tw_adr;
    reg [`BEL_FFT_CTRL_NUM_WIDTH-1:0]    mcount;
    
    reg [`BEL_FFT_AWIDTH-1:0] adr_o;
    reg wr_o;
    reg rd_o;

    wire mult_pipe_halt;


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            mcount <= 0;
        end else begin
            if (state == `BEL_BFLY2_INIT_STATE) begin
                mcount <= m;
            end else begin
                if (state == `BEL_BFLY2_LOAD1_STATE) begin
                    if (ack_i) begin
                        mcount <= mcount - 1'b1;
                    end
                end
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            foutadr0 <= 0;
        end else begin
            if (state == `BEL_BFLY2_INIT_STATE) begin
                foutadr0 <= foutadr;
            end else begin
                if (state == `BEL_BFLY2_SAVE1_STATE) begin
                    if (ack_i) begin
                        foutadr0 <= foutadr0 + (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT);
                    end
                end
            end
        end
    end

    
    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            foutadr2 <= 0;
        end else begin
            if (state == `BEL_BFLY2_INIT_STATE) begin
                foutadr2 <= foutadr + m * (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT);
            end else begin
                if (state == `BEL_BFLY2_SAVE2_STATE) begin
                    if (ack_i) begin
                        foutadr2 <= foutadr2 + (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT);
                    end
                end
            end
        end
    end

    
    bel_cmul #(word_width) cmul (
            .clk_i (clk_i),
            .pipe_halt (mult_pipe_halt),
            .a_re_i (fout2_re),
            .a_im_i (fout2_im),
            .b_re_i (tw_re_i),
            .b_im_i (tw_im_i),
            .x_re_o (mul_x_re),
            .x_im_o (mul_x_im));

    assign mult_pipe_halt = 1'b0;
           
    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            t_re <= 0;
            t_im <= 0;
        end else begin
            if (state == `BEL_BFLY2_EXEC2_STATE) begin
                t_re <= mul_x_re;
                t_im <= mul_x_im;
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            tw_adr <= 0;
        end else begin
            if (state == `BEL_BFLY2_INIT_STATE) begin
                tw_adr <= 0;
            end else begin
                if (state == `BEL_BFLY2_EXEC2_STATE) begin
                    tw_adr <= tw_adr + fstride[twiddle_rom_awidth - 1:0];
                end
            end
        end
    end


    always @ (state or ack_i) begin
        case (state)
            `BEL_BFLY2_LOAD1_STATE: begin
                if (ack_i) begin
                    tw_rd_o <= 1'b1;
                end else begin
                    tw_rd_o <= 1'b0;
                end
            end
            default: begin
                tw_rd_o <= 1'b0;
            end
        endcase
    end


    always @ (state or tw_adr) begin
        case (state)
            `BEL_BFLY2_LOAD1_STATE: begin
                tw_adr_o = tw_adr;
            end
            default: begin
                tw_adr_o = 0;
            end
        endcase
    end     


    always @ (state or foutadr0 or foutadr2) begin
        case (state)
            `BEL_BFLY2_LOAD1_STATE: begin
                rd_o = 1'b1;
                wr_o = 1'b0;
                adr_o = foutadr0;
            end
            `BEL_BFLY2_LOAD2_STATE: begin
                rd_o = 1'b1;
                wr_o = 1'b0;
                adr_o = foutadr2;
            end
            `BEL_BFLY2_SAVE1_STATE: begin
                rd_o = 1'b0;
                wr_o = 1'b1;
                adr_o = foutadr0;
            end
            `BEL_BFLY2_SAVE2_STATE: begin
                rd_o = 1'b0;
                wr_o = 1'b1;
                adr_o = foutadr2;
            end
            default: begin
                rd_o = 1'b0;
                wr_o = 1'b0;
                adr_o = 0;
            end
        endcase
    end     


    always @ (state or fout_re or fout_im or fout2_re or fout2_im) begin
        case (state)
            `BEL_BFLY2_SAVE1_STATE: begin
                dat_re_o = fout_re;
                dat_im_o = fout_im;
            end
            `BEL_BFLY2_SAVE2_STATE: begin
                dat_re_o = fout2_re;
                dat_im_o = fout2_im;
            end
            default: begin
                dat_re_o = 0;
                dat_im_o = 0;
            end
        endcase
    end


    bel_cadd  #(word_width) cadd (
            .a_re_i (fout_re),
            .a_im_i (fout_im),
            .b_re_i (t_re),
            .b_im_i (t_im),
            .x_re_o (add_x_re),
            .x_im_o (add_x_im));

    
    bel_cdiv2 #(word_width) cdiv2 (
            .a_re_i (dat_re_i),
            .a_im_i (dat_im_i),
            .x_re_o (div2_fout_re),
            .x_im_o (div2_fout_im));


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            div2_dat_re <= 0;
            div2_dat_im <= 0;
        end else begin
            div2_dat_re <= div2_fout_re;
            div2_dat_im <= div2_fout_im;
        end
    end

    
    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            fout_re <= 0;
            fout_im <= 0;
        end else begin
                case (state)
                    `BEL_BFLY2_EXEC0_STATE: begin
                        fout_re <= div2_dat_re;
                        fout_im <= div2_dat_im;
                    end
                    `BEL_BFLY2_EXEC3_STATE: begin
                        fout_re <= add_x_re;
                        fout_im <= add_x_im;
                    end
                endcase
        end
    end        


    bel_csub #(word_width) csub (
            .a_re_i (fout_re),
            .a_im_i (fout_im),
            .b_re_i (t_re),
            .b_im_i (t_im),
            .x_re_o (sub_x_re),
            .x_im_o (sub_x_im));

    
    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            fout2_re <= 0;
            fout2_im <= 0;
        end else begin
            case (state)
                `BEL_BFLY2_LOAD1_STATE: begin
                    if (ack_i) begin
                        fout2_re <= div2_dat_re;
                        fout2_im <= div2_dat_im;
                    end
                end
                `BEL_BFLY2_EXEC3_STATE: begin
                    fout2_re <= sub_x_re;
                    fout2_im <= sub_x_im;
                end
            endcase
        end
    end        


    // State machine, sequential part
    
    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            state <= `BEL_BFLY2_IDLE_STATE;
        end else begin
            state <= next_state;
        end
    end        


    always @ (state or ack_i or start or mcount) begin
        case (state)
            `BEL_BFLY2_IDLE_STATE:
                if (start) begin
                    next_state = `BEL_BFLY2_INIT_STATE;
                end else begin
                    next_state = `BEL_BFLY2_IDLE_STATE;
                end
            `BEL_BFLY2_INIT_STATE: begin
                next_state = `BEL_BFLY2_LOAD2_STATE;
            end
            `BEL_BFLY2_LOAD2_STATE:
                if (ack_i) begin
                    next_state = `BEL_BFLY2_LOAD1_STATE;
                end else begin
                    next_state = `BEL_BFLY2_LOAD2_STATE;
                end
            `BEL_BFLY2_LOAD1_STATE:
                if (ack_i) begin
                    next_state = `BEL_BFLY2_EXEC0_STATE;
                end else begin
                    next_state = `BEL_BFLY2_LOAD1_STATE;
                end
            `BEL_BFLY2_EXEC0_STATE: begin
                next_state = `BEL_BFLY2_EXEC1_STATE;
            end
            `BEL_BFLY2_EXEC1_STATE: begin
                next_state = `BEL_BFLY2_EXEC2_STATE;
            end
            `BEL_BFLY2_EXEC2_STATE: begin
                next_state = `BEL_BFLY2_EXEC3_STATE;
            end
            `BEL_BFLY2_EXEC3_STATE: begin
                next_state = `BEL_BFLY2_SAVE2_STATE;
            end
            `BEL_BFLY2_SAVE2_STATE: begin
                if (ack_i) begin
                    next_state = `BEL_BFLY2_SAVE1_STATE;
                end else begin
                    next_state = `BEL_BFLY2_SAVE2_STATE;
                end
            end
            `BEL_BFLY2_SAVE1_STATE: begin
                if (ack_i) begin
                    next_state = `BEL_BFLY2_IDLE_STATE;
                end else begin
                    next_state = `BEL_BFLY2_SAVE1_STATE;
                end
            end
            default: begin
                next_state = `BEL_BFLY2_IDLE_STATE;
            end
        endcase
    end

    assign finish = ((state == `BEL_BFLY2_SAVE1_STATE) && 
            (next_state == `BEL_BFLY2_IDLE_STATE));

    
endmodule // bel_butterfly2


