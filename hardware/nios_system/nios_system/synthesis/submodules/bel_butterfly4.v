////////////////////////////////////////////////////////////////////
//
// bel_butterfly4.v
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



module bel_butterfly4 (
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
        inv,
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

    input start;
    input [`BEL_FFT_CTRL_NUM_WIDTH-1:0] m;
    input [`BEL_FFT_CTRL_NUM_WIDTH-1:0] fstride;
    input [`BEL_FFT_AWIDTH-1:0] foutadr;
    input inv;
   

    reg [`BEL_FFT_AWIDTH-1:0] foutadr0;
    reg [`BEL_FFT_AWIDTH-1:0] foutadr1;
    reg [`BEL_FFT_AWIDTH-1:0] foutadr2;
    reg [`BEL_FFT_AWIDTH-1:0] foutadr3;

    reg rd_o;
    reg wr_o;
    reg [`BEL_FFT_AWIDTH-1:0] adr_o;
                  
    wire signed [word_width - 1:0] tw_re;
    wire signed [word_width - 1:0] tw_im;

    reg [3:0] next_state;
    reg [3:0] state;

    reg signed [word_width - 1:0] fout_re;
    reg signed [word_width - 1:0] fout_im;
    reg signed [word_width - 1:0] fout1_re;
    reg signed [word_width - 1:0] fout1_im;
    reg signed [word_width - 1:0] fout2_re;
    reg signed [word_width - 1:0] fout2_im;
    reg signed [word_width - 1:0] fout3_re;
    reg signed [word_width - 1:0] fout3_im;

    reg signed [word_width - 1:0] div4_dat_re;
    reg signed [word_width - 1:0] div4_dat_im;
    wire signed [word_width - 1:0] div4_out_re;
    wire signed [word_width - 1:0] div4_out_im;

    reg signed [word_width - 1:0] mul_a_re;
    reg signed [word_width - 1:0] mul_a_im;
    wire signed [word_width - 1:0] mul_x_re;
    wire signed [word_width - 1:0] mul_x_im;
    reg signed [word_width - 1:0] add_a_re;
    reg signed [word_width - 1:0] add_a_im;
    reg signed [word_width - 1:0] add_b_re;
    reg signed [word_width - 1:0] add_b_im;
    wire signed [word_width - 1:0] add_x_re;
    wire signed [word_width - 1:0] add_x_im;
    reg signed [word_width - 1:0] sub_a_re;
    reg signed [word_width - 1:0] sub_a_im;
    reg signed [word_width - 1:0] sub_b_re;
    reg signed [word_width - 1:0] sub_b_im;
    wire signed [word_width - 1:0] sub_x_re;
    wire signed [word_width - 1:0] sub_x_im;
    wire signed [word_width - 1:0] addsub_x_re;
    wire signed [word_width - 1:0] addsub_x_im;

    reg [twiddle_rom_awidth - 1:0] tw_adr_o;
    reg [twiddle_rom_awidth - 1:0] tw1adr;
    reg [twiddle_rom_awidth - 1:0] tw2adr;
    reg [twiddle_rom_awidth - 1:0] tw3adr;

    reg signed [word_width - 1:0] scratch0_re;
    reg signed [word_width - 1:0] scratch0_im;
    reg signed [word_width - 1:0] scratch1_re;
    reg signed [word_width - 1:0] scratch1_im;
    reg signed [word_width - 1:0] scratch2_re;
    reg signed [word_width - 1:0] scratch2_im;
    reg signed [word_width - 1:0] scratch3_re;
    reg signed [word_width - 1:0] scratch3_im;
    reg signed [word_width - 1:0] scratch4_re;
    reg signed [word_width - 1:0] scratch4_im;
    reg signed [word_width - 1:0] scratch5_re;
    reg signed [word_width - 1:0] scratch5_im;

    reg [`BEL_FFT_CTRL_NUM_WIDTH-1:0] mcount;
    reg tw_rd_o;

    reg [word_width - 1:0] dat_re_o;
    reg [word_width - 1:0] dat_im_o;

    reg addsub_inv;

    reg mult_pipe_halt;

   
    assign tw_re = tw_re_i;
    assign tw_im = tw_im_i;


    always @ (state or ack_i) begin
        case (state)
            `BEL_BFLY4_LOAD3_STATE: begin
                if (ack_i) begin
                    tw_rd_o <= 1'b1;
                end else begin
                    tw_rd_o <= 1'b0;
                end
            end
            `BEL_BFLY4_LOAD1_STATE: begin
                if (ack_i) begin
                    tw_rd_o <= 1'b1;
                end else begin
                    tw_rd_o <= 1'b0;
                end
            end
            `BEL_BFLY4_LOAD0_STATE: begin
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


    always @ (state or tw1adr or tw2adr or tw3adr) begin
        case (state)
            `BEL_BFLY4_LOAD3_STATE: begin
                tw_adr_o = tw2adr;
            end
            `BEL_BFLY4_LOAD1_STATE: begin
                tw_adr_o = tw3adr;
            end
            `BEL_BFLY4_LOAD0_STATE: begin
                tw_adr_o = tw1adr;
            end
            default: begin
                tw_adr_o = 0;
            end
        endcase
    end
    

    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            tw1adr <= 0;
            tw2adr <= 0;
            tw3adr <= 0;
        end else begin
            case (state)
                `BEL_BFLY4_INIT_STATE: begin
                    tw1adr <= 0;
                    tw2adr <= 0;
                    tw3adr <= 0;
                end
                `BEL_BFLY4_SAVE1_STATE: begin
                    if (ack_i) begin
                        tw3adr <= tw3adr + fstride[twiddle_rom_awidth - 1:0];
                    end
                end
                `BEL_BFLY4_SAVE0_STATE: begin
                    if (ack_i) begin
                        tw2adr <= tw2adr + fstride[twiddle_rom_awidth - 1:0];
                        tw3adr <= tw3adr + fstride[twiddle_rom_awidth - 1:0];
                    end
                end
                `BEL_BFLY4_SAVE3_STATE: begin
                    if (ack_i) begin
                        tw1adr <= tw1adr + fstride[twiddle_rom_awidth - 1:0];
                        tw2adr <= tw2adr + fstride[twiddle_rom_awidth - 1:0];
                        tw3adr <= tw3adr + fstride[twiddle_rom_awidth - 1:0];
                    end
                end
                default: begin
                end
            endcase
        end
    end


    always @ (state or ack_i) begin
        case (state)
            `BEL_BFLY4_LOAD1_STATE: begin
                if (ack_i) begin
                    mult_pipe_halt = 1'b0;
                end else begin
                    mult_pipe_halt = 1'b1;
                end
            end
            `BEL_BFLY4_LOAD0_STATE: begin
                if (ack_i) begin
                    mult_pipe_halt = 1'b0;
                end else begin
                    mult_pipe_halt = 1'b1;
                end
            end
            default: begin
                mult_pipe_halt = 1'b0;
           end
        endcase        
    end


    bel_cmul #(word_width) cmul (
            .clk_i (clk_i),
            .pipe_halt (mult_pipe_halt),
            .a_re_i (mul_a_re),
            .a_im_i (mul_a_im),
            .b_re_i (tw_re),
            .b_im_i (tw_im),
            .x_re_o (mul_x_re),
            .x_im_o (mul_x_im));


    always @ (state or fout1_re or fout1_im or fout2_re or fout2_im or fout3_re or fout3_im) begin
        case (state)
            `BEL_BFLY4_LOAD1_STATE: begin
                mul_a_re = fout2_re;
                mul_a_im = fout2_im;
            end
            `BEL_BFLY4_LOAD0_STATE: begin
                mul_a_re = fout3_re;
                mul_a_im = fout3_im;
            end
            default: begin
                mul_a_re = fout1_re;
                mul_a_im = fout1_im;
            end
        endcase
    end
    
                   
    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            mcount <= 0;
        end else begin
            case (state)
                `BEL_BFLY4_INIT_STATE: begin
                    mcount <= m;
                end
                `BEL_BFLY4_LOAD2_STATE: begin
                    if (ack_i) begin
                        mcount <= mcount - 1'b1;
                    end
                end
                default: begin
                end
            endcase
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            foutadr0 <= 32'h0000_0000;
        end else begin
            if (state == `BEL_BFLY4_INIT_STATE) begin
                foutadr0 <= foutadr;
            end else begin
                if (state == `BEL_BFLY4_SAVE0_STATE) begin
                    if (ack_i) begin
                        foutadr0 <= foutadr0 + (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT);
                    end
                end
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            foutadr1 <= 0;
        end else begin
            if (state == `BEL_BFLY4_INIT_STATE) begin
                foutadr1 <= foutadr + m * (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT);
            end else begin
                if (state == `BEL_BFLY4_SAVE1_STATE) begin
                    if (ack_i) begin
                        foutadr1 <= foutadr1 + (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT);
                    end
                end
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            foutadr2 <= 0;
        end else begin
            if (state == `BEL_BFLY4_INIT_STATE) begin
                foutadr2 <= foutadr + 2 * m * (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT);
            end else begin
                if (state == `BEL_BFLY4_SAVE2_STATE) begin
                    if (ack_i) begin
                        foutadr2 <= foutadr2 + (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT);
                    end
                end
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            foutadr3 <= 0;
        end else begin
            if (state == `BEL_BFLY4_INIT_STATE) begin
                foutadr3 <= foutadr + 3 * m * (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT);
            end else begin
                if (state == `BEL_BFLY4_SAVE3_STATE) begin
                    if (ack_i) begin
                        foutadr3 <= foutadr3 + (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT);
                    end
                end
            end
        end
    end


    always @ (state or foutadr0 or foutadr1 or foutadr2 or foutadr1 or foutadr3) begin
        case (state)
            `BEL_BFLY4_LOAD0_STATE: begin
                rd_o <= 1'b1;
                wr_o <= 1'b0;
                adr_o <= foutadr0;
            end
            `BEL_BFLY4_LOAD1_STATE: begin
                rd_o <= 1'b1;
                wr_o <= 1'b0;
                adr_o <= foutadr1;
            end
            `BEL_BFLY4_LOAD2_STATE: begin
                rd_o <= 1'b1;
                wr_o <= 1'b0;
                adr_o <= foutadr2;
            end
            `BEL_BFLY4_LOAD3_STATE: begin
                rd_o <= 1'b1;
                wr_o <= 1'b0;
                adr_o <= foutadr3;
            end
            `BEL_BFLY4_SAVE0_STATE: begin
                rd_o <= 1'b0;
                wr_o <= 1'b1;
                adr_o <= foutadr0;
            end
            `BEL_BFLY4_SAVE1_STATE: begin
                rd_o <= 1'b0;
                wr_o <= 1'b1;
                adr_o <= foutadr1;
            end
            `BEL_BFLY4_SAVE2_STATE: begin
                rd_o <= 1'b0;
                wr_o <= 1'b1;
                adr_o <= foutadr2;
            end
            `BEL_BFLY4_SAVE3_STATE: begin
                rd_o <= 1'b0;
                wr_o <= 1'b1;
                adr_o <= foutadr3;
            end
            default: begin
                rd_o <= 1'b0;
                wr_o <= 1'b0;
                adr_o <= 0;
            end
        endcase
    end     


    bel_cdiv4 #(word_width) u_cdiv4 (
            .a_re_i (dat_re_i),
            .a_im_i (dat_im_i),
            .x_re_o (div4_out_re),
            .x_im_o (div4_out_im));


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            div4_dat_re <= 0;
            div4_dat_im <= 0;
        end else begin
            div4_dat_re <= div4_out_re;
            div4_dat_im <= div4_out_im;
        end
    end

    
    bel_caddsub #(word_width) u_caddsub (
            .a_re_i (scratch5_re),
            .a_im_i (scratch5_im),
            .b_re_i (scratch4_re),
            .b_im_i (scratch4_im),
            .x_re_o (addsub_x_re),
            .x_im_o (addsub_x_im),
            .inv_i (addsub_inv));


    always @ (state or inv) begin
        if (inv == 1'b0) begin
            case (state)
                `BEL_BFLY4_SAVE2_STATE: begin
                   addsub_inv <= 1'b1;
                end
                default: begin
                   addsub_inv <= 1'b0;
                end
            endcase
        end else begin
            case (state)
                `BEL_BFLY4_SAVE2_STATE: begin
                   addsub_inv <= 1'b0;
                end
                default: begin
                   addsub_inv <= 1'b1;
                end
            endcase
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            fout_re <= 0;
            fout_im <= 0;
        end else begin
            case (state)
                `BEL_BFLY4_EXEC0_STATE: begin
                    fout_re <= div4_dat_re;
                    fout_im <= div4_dat_im;
                end
                `BEL_BFLY4_EXEC4_STATE: begin
                    fout_re <= add_x_re;
                    fout_im <= add_x_im;
                end
                `BEL_BFLY4_EXEC1_STATE: begin
                    fout_re <= add_x_re;
                    fout_im <= add_x_im;
                end
                default: begin
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            fout1_re <= 0;
            fout1_im <= 0;
        end else begin
            case (state)
                `BEL_BFLY4_LOAD0_STATE: begin
                    if (ack_i) begin
                        fout1_re <= div4_dat_re;
                        fout1_im <= div4_dat_im;
                    end
                end
                `BEL_BFLY4_EXEC4_STATE: begin
                    fout1_re <= addsub_x_re;
                    fout1_im <= addsub_x_im;
                end
                default: begin
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            fout2_re <= 0;
            fout2_im <= 0;
        end else begin
            case (state)
                `BEL_BFLY4_LOAD3_STATE: begin
                    if (ack_i) begin
                        fout2_re <= div4_dat_re;
                        fout2_im <= div4_dat_im;
                    end
                end
                `BEL_BFLY4_EXEC4_STATE: begin
                    fout2_re <= sub_x_re;
                    fout2_im <= sub_x_im;
                end
                default: begin
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            fout3_re <= 0;
            fout3_im <= 0;
        end else begin
            case (state)
                `BEL_BFLY4_LOAD1_STATE: begin
                    if (ack_i) begin
                        fout3_re <= div4_dat_re;
                        fout3_im <= div4_dat_im;
                    end
                end
                `BEL_BFLY4_SAVE2_STATE: begin
                    if (ack_i) begin
                        fout3_re <= addsub_x_re;
                        fout3_im <= addsub_x_im;
                    end
                end
                default: begin
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            scratch0_re <= 0;
            scratch0_im <= 0;
        end else begin
            case (state)
                `BEL_BFLY4_EXEC2_STATE: begin
                    scratch0_re <= mul_x_re;
                    scratch0_im <= mul_x_im;
                end
                default: begin
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            scratch1_re <= 0;
            scratch1_im <= 0;
        end else begin
            case (state)
                `BEL_BFLY4_EXEC0_STATE: begin
                    scratch1_re <= mul_x_re;
                    scratch1_im <= mul_x_im;
                end
                default: begin
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            scratch2_re <= 0;
            scratch2_im <= 0;
        end else begin
            case (state)
                `BEL_BFLY4_EXEC1_STATE: begin
                    scratch2_re <= mul_x_re;
                    scratch2_im <= mul_x_im;
                end
                default: begin
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            scratch3_re <= 0;
            scratch3_im <= 0;
        end else begin
            case (state)
                `BEL_BFLY4_EXEC3_STATE: begin
                    scratch3_re <= add_x_re;
                    scratch3_im <= add_x_im;
                end
                default: begin
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            scratch4_re <= 0;
            scratch4_im <= 0;
        end else begin
            case (state)
                `BEL_BFLY4_EXEC3_STATE: begin
                    scratch4_re <= sub_x_re;
                    scratch4_im <= sub_x_im;
                end
                default: begin
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            scratch5_re <= 0;
            scratch5_im <= 0;
        end else begin
            case (state)
                `BEL_BFLY4_EXEC1_STATE: begin
                    scratch5_re <= sub_x_re;
                    scratch5_im <= sub_x_im;
                end
                default: begin
                end
            endcase
        end
    end        


    bel_cadd #(word_width) cadd (
            .a_re_i (add_a_re),
            .a_im_i (add_a_im),
            .b_re_i (add_b_re),
            .b_im_i (add_b_im),
            .x_re_o (add_x_re),
            .x_im_o (add_x_im));


    always @ (state or scratch0_re or scratch0_im or fout_re or fout_im) begin
        case (state)
            `BEL_BFLY4_EXEC3_STATE: begin
                add_a_re = scratch0_re;
                add_a_im = scratch0_im;
            end
            default: begin
                add_a_re = fout_re;
                add_a_im = fout_im;
            end
        endcase
    end
    
    
    always @ (state or scratch1_re or scratch1_im or scratch2_re or scratch2_im or scratch3_re or scratch3_im) begin
        case (state)
            `BEL_BFLY4_EXEC1_STATE: begin
                add_b_re = scratch1_re;
                add_b_im = scratch1_im;
            end
            `BEL_BFLY4_EXEC3_STATE: begin
                add_b_re = scratch2_re;
                add_b_im = scratch2_im;
            end
            default: begin
                add_b_re = scratch3_re;
                add_b_im = scratch3_im;
            end
        endcase
    end
    
    
    bel_csub #(word_width) csub (
            .a_re_i (sub_a_re),
            .a_im_i (sub_a_im),
            .b_re_i (sub_b_re),
            .b_im_i (sub_b_im),
            .x_re_o (sub_x_re),
            .x_im_o (sub_x_im));


    always @ (state or scratch0_re or scratch0_im or fout_re or fout_im) begin
        case (state)
            `BEL_BFLY4_EXEC3_STATE: begin
                sub_a_re = scratch0_re;
                sub_a_im = scratch0_im;
            end
            default: begin
                sub_a_re = fout_re;
                sub_a_im = fout_im;
            end
        endcase
    end
    
    
    always @ (state or scratch1_re or scratch1_im or scratch2_re or scratch2_im or scratch3_re or scratch3_im) begin
        case (state)
            `BEL_BFLY4_EXEC3_STATE: begin
                sub_b_re = scratch2_re;
                sub_b_im = scratch2_im;
            end
            `BEL_BFLY4_EXEC4_STATE: begin
                sub_b_re = scratch3_re;
                sub_b_im = scratch3_im;
            end
            default: begin
                sub_b_re = scratch1_re;
                sub_b_im = scratch1_im;
            end
        endcase
    end
    

    // State machine, sequential part
    
    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            state <= `BEL_BFLY4_IDLE_STATE;
        end else begin
            state <= next_state;
        end
    end        


    always @ (state or ack_i or start or mcount) begin
        case (state)
            `BEL_BFLY4_IDLE_STATE:
                if (start) begin
                    next_state = `BEL_BFLY4_INIT_STATE;
                end else begin
                    next_state = `BEL_BFLY4_IDLE_STATE;
                end
            `BEL_BFLY4_INIT_STATE: begin
                next_state = `BEL_BFLY4_LOAD2_STATE;
                end
            `BEL_BFLY4_LOAD2_STATE:
                if (ack_i) begin
                    next_state = `BEL_BFLY4_LOAD3_STATE;
                end else begin
                    next_state = `BEL_BFLY4_LOAD2_STATE;
                end
            `BEL_BFLY4_LOAD3_STATE:
                if (ack_i) begin
                    next_state = `BEL_BFLY4_LOAD1_STATE;
                end else begin
                    next_state = `BEL_BFLY4_LOAD3_STATE;
                end
            `BEL_BFLY4_LOAD1_STATE:
                if (ack_i) begin
                    next_state = `BEL_BFLY4_LOAD0_STATE;
                end else begin
                    next_state = `BEL_BFLY4_LOAD1_STATE;
                end
            `BEL_BFLY4_LOAD0_STATE:
                if (ack_i) begin
                    next_state = `BEL_BFLY4_EXEC0_STATE;
                end else begin
                    next_state = `BEL_BFLY4_LOAD0_STATE;
                end
            `BEL_BFLY4_EXEC0_STATE: begin
                next_state = `BEL_BFLY4_EXEC1_STATE;
            end
            `BEL_BFLY4_EXEC1_STATE: begin
                next_state = `BEL_BFLY4_EXEC2_STATE;
            end
            `BEL_BFLY4_EXEC2_STATE: begin
                next_state = `BEL_BFLY4_EXEC3_STATE;
            end
            `BEL_BFLY4_EXEC3_STATE: begin
                next_state = `BEL_BFLY4_EXEC4_STATE;
            end
            `BEL_BFLY4_EXEC4_STATE: begin
                next_state = `BEL_BFLY4_SAVE2_STATE;
            end
            `BEL_BFLY4_SAVE2_STATE: begin
                if (ack_i) begin
                    next_state = `BEL_BFLY4_SAVE0_STATE;
                end else begin
                    next_state = `BEL_BFLY4_SAVE2_STATE;
                end
            end
            `BEL_BFLY4_SAVE0_STATE: begin
                if (ack_i) begin
                    next_state = `BEL_BFLY4_SAVE3_STATE;
                end else begin
                    next_state = `BEL_BFLY4_SAVE0_STATE;
                end
            end
            `BEL_BFLY4_SAVE3_STATE: begin
                if (ack_i) begin
                    next_state = `BEL_BFLY4_SAVE1_STATE;
                end else begin
                    next_state = `BEL_BFLY4_SAVE3_STATE;
                end
            end
            `BEL_BFLY4_SAVE1_STATE: begin
                if (ack_i) begin
                    if (mcount == 0)
                        next_state = `BEL_BFLY4_IDLE_STATE;
                    else
                        next_state = `BEL_BFLY4_LOAD2_STATE;
                end else begin
                    next_state = `BEL_BFLY4_SAVE1_STATE;
                end
            end
            default: begin
                next_state = `BEL_BFLY4_IDLE_STATE;
            end
        endcase
    end


    always @ (state or fout_re or fout_im or fout1_re or fout1_im or fout2_re or fout2_im or fout3_re or fout3_im) begin
        case (state)
            `BEL_BFLY4_SAVE0_STATE: begin
                dat_re_o = fout_re;
                dat_im_o = fout_im;
            end
            `BEL_BFLY4_SAVE1_STATE: begin
                dat_re_o = fout1_re;
                dat_im_o = fout1_im;
            end
            `BEL_BFLY4_SAVE2_STATE: begin
                dat_re_o = fout2_re;
                dat_im_o = fout2_im;
            end
            `BEL_BFLY4_SAVE3_STATE: begin
                dat_re_o = fout3_re;
                dat_im_o = fout3_im;
            end
            default: begin
                dat_re_o = 0;
                dat_im_o = 0;
            end
        endcase
    end

    
    assign finish = ((state == `BEL_BFLY4_SAVE1_STATE) && 
            (next_state == `BEL_BFLY4_IDLE_STATE));


endmodule // bel_butterfly4


