////////////////////////////////////////////////////////////////////
//
// bel_fft_core.v
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


module bel_fft_core (
        clk_i,
        rst_i,

        butterfly_generic_adr_o,
        butterfly_generic_dat_re_i,
        butterfly_generic_dat_re_o,
        butterfly_generic_dat_im_i,
        butterfly_generic_dat_im_o,
        butterfly_generic_wr_o,
        butterfly_generic_rd_o,
        butterfly_generic_ack_i,
        butterfly_generic_err_i,

        butterfly2_adr_o,
        butterfly2_dat_re_i,
        butterfly2_dat_re_o,
        butterfly2_dat_im_i,
        butterfly2_dat_im_o,
        butterfly2_wr_o,
        butterfly2_rd_o,
        butterfly2_ack_i,
        butterfly2_err_i,

        butterfly4_adr_o,
        butterfly4_dat_re_i,
        butterfly4_dat_re_o,
        butterfly4_dat_im_i,
        butterfly4_dat_im_o,
        butterfly4_wr_o,
        butterfly4_rd_o,
        butterfly4_ack_i,
        butterfly4_err_i,

        copy_adr_o,
        copy_dat_re_i,
        copy_dat_re_o,
        copy_dat_im_i,
        copy_dat_im_o,
        copy_wr_o,
        copy_rd_o,
        copy_ack_i,
        copy_err_i,

        ctrl_adr_i,
        ctrl_dat_i,
        ctrl_dat_o,
        ctrl_bsel_i,
        ctrl_wr_i,
        ctrl_rd_i,
        ctrl_ack_o,
        ctrl_err_o,

        tw_adr,
        tw_rd,
        tw_re,
        tw_im,
        tw_cfg_sel,

        event_o,
        int_o,

        user_o);
   
    parameter word_width = 16;
    parameter config_num = 1;
    parameter stage_num = 4;
    parameter twiddle_rom_max_awidth = 8;
    parameter fft_size = 256;
    parameter fft_size1 = 0;
    parameter fft_size2 = 0;
    parameter fft_size3 = 0;
    parameter has_butterfly2 = 1;

    input clk_i;
    input rst_i;

    output [`BEL_FFT_AWIDTH-1:0] butterfly_generic_adr_o;
    input [word_width-1:0] butterfly_generic_dat_re_i;
    output [word_width-1:0] butterfly_generic_dat_re_o;
    input [word_width-1:0] butterfly_generic_dat_im_i;
    output [word_width-1:0] butterfly_generic_dat_im_o;
    output butterfly_generic_wr_o;
    output butterfly_generic_rd_o;
    input butterfly_generic_ack_i;
    input butterfly_generic_err_i;

    output [`BEL_FFT_AWIDTH-1:0] butterfly2_adr_o;
    input [word_width-1:0] butterfly2_dat_re_i;
    output [word_width-1:0] butterfly2_dat_re_o;
    input [word_width-1:0] butterfly2_dat_im_i;
    output [word_width-1:0] butterfly2_dat_im_o;
    output butterfly2_wr_o;
    output butterfly2_rd_o;
    input butterfly2_ack_i;
    input butterfly2_err_i;

    output [`BEL_FFT_AWIDTH-1:0] butterfly4_adr_o;
    input [word_width-1:0] butterfly4_dat_re_i;
    output [word_width-1:0] butterfly4_dat_re_o;
    input [word_width-1:0] butterfly4_dat_im_i;
    output [word_width-1:0] butterfly4_dat_im_o;
    output butterfly4_wr_o;    
    output butterfly4_rd_o; 
    input butterfly4_ack_i;
    input butterfly4_err_i;

    output [`BEL_FFT_AWIDTH-1:0] copy_adr_o;
    input [word_width-1:0] copy_dat_re_i;
    output [word_width-1:0] copy_dat_re_o;
    input [word_width-1:0] copy_dat_im_i;
    output [word_width-1:0] copy_dat_im_o;
    output copy_wr_o;
    output copy_rd_o;
    input copy_ack_i;
    input copy_err_i;

    input [`BEL_FFT_SIF_AWIDTH-1:0] ctrl_adr_i;
    input [`BEL_FFT_DWIDTH-1:0] ctrl_dat_i;
    output [`BEL_FFT_DWIDTH-1:0] ctrl_dat_o;
    input [`BEL_FFT_BCNT-1:0] ctrl_bsel_i;
    input ctrl_wr_i;
    input ctrl_rd_i;
    output ctrl_ack_o;
    output ctrl_err_o;

    output [twiddle_rom_max_awidth - 1:0] tw_adr;
    output tw_rd;
    input [word_width - 1:0] tw_re;
    input [word_width - 1:0] tw_im;
    output [config_num - 1:0] tw_cfg_sel;

    output event_o;
    output int_o;

    output [`BEL_FFT_DWIDTH-1:0] user_o;


    reg [4:0] next_state;
    reg [4:0] state;

    reg start;
    reg inv;
    reg inten;

    reg [`BEL_FFT_CTRL_NUM_WIDTH - 1:0] i;
    reg [`BEL_FFT_CTRL_NUM_WIDTH - 1:0] k;
    reg [`BEL_FFT_CTRL_NUM_WIDTH - 1:0] stage [stage_num-1:0];

    reg running;
    wire ov;
    reg finish;
    wire err;
    reg [`BEL_FFT_CTRL_NUM_WIDTH-1:0] n;
    reg [`BEL_FFT_AWIDTH - 1:0] srcadr;
    reg [`BEL_FFT_AWIDTH - 1:0] dstadr;

    reg [`BEL_FFT_AWIDTH - 1:0] finadr [stage_num-1:0];
    reg [`BEL_FFT_AWIDTH - 1:0] foutadr [stage_num-1:0];
    reg [`BEL_FFT_AWIDTH - 1:0] foutloopadr;
    reg [`BEL_FFT_AWIDTH - 1:0] finloopadr;
    reg [`BEL_FFT_AWIDTH - 1:0] foutbegadr [stage_num-1:0];
   

    reg [`BEL_FFT_CTRL_NUM_WIDTH - 1:0] m [stage_num-1:0];
    reg [`BEL_FFT_CTRL_NUM_WIDTH - 1:0] p [stage_num-1:0];
    reg [`BEL_FFT_CTRL_NUM_WIDTH - 1:0] fstride [stage_num-1:0];
    reg [`BEL_FFT_CTRL_NUM_WIDTH - 1:0] next_fstride;

    reg [`BEL_FFT_DWIDTH - 1:0] user;


    wire butterfly4_start;
    wire butterfly2_start;
    wire butterfly_finished;
    wire butterfly4_finished;
    wire butterfly2_finished;

    wire copy_start;
    wire copy_finished;

    reg ctrl_ack_rd;
    reg ctrl_err;
    reg [`BEL_FFT_DWIDTH-1:0] ctrl_dat;
    reg [`BEL_FFT_DWIDTH-1:0] ctrl_dat_factors [stage_num-1:0];
   
    integer rst_stage_count;

    reg [config_num - 1:0] tw_cfg_sel;
    wire [twiddle_rom_max_awidth - 1:0] tw_adr_bfly4;
    wire [twiddle_rom_max_awidth - 1:0] tw_adr_bfly2;
    wire tw_rd_bfly4;
    wire tw_rd_bfly2;


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
           fstride[0] <= 1;
        end else begin
            case (state)
                `BEL_CTRL_CALL_STATE: begin
                   fstride[i] <= next_fstride;
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
           next_fstride <= 0;
        end else begin
            case (state)
                `BEL_CTRL_SAVE_STATE: begin
                   next_fstride <= fstride[i] * p[i];
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
           finadr[0] <= 0;
        end else begin
            case (state)
                `BEL_CTRL_INIT_STATE: begin
                   finadr[i] <= srcadr;
                end
                `BEL_CTRL_SAVE_STATE: begin
                   finadr[i] <= finloopadr;
                end
                `BEL_CTRL_CALL_STATE: begin
                   finadr[i] <= finloopadr;
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
           finloopadr <= 0;
        end else begin
            case (state)
                `BEL_CTRL_LOOP_INIT_STATE: begin
                   finloopadr <= finadr[i];
                end
                `BEL_CTRL_RESTORE_STATE: begin
                   finloopadr <= finadr[i] + 
                           fstride[i] * (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT);
                end
            endcase
        end
    end        


    always @ (posedge clk_i) begin
        case (state)
            `BEL_CTRL_INIT_STATE: begin
               foutadr[0] <= dstadr;
            end
            `BEL_CTRL_SAVE_STATE: begin
               foutadr[i] <= foutloopadr;
            end
        endcase
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
           foutloopadr <= 0;
        end else begin
            case (state)
                `BEL_CTRL_INIT_STATE: begin
                   foutloopadr <= dstadr;
                end
                `BEL_CTRL_RESTORE_STATE: begin
                   foutloopadr <= foutadr[i] + m[i] * (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT);
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
           foutbegadr[0] <= 0;
        end else begin
            case (state)
                `BEL_CTRL_INIT_STATE: begin
                   foutbegadr[0] <= dstadr;
                end
                `BEL_CTRL_CALL_STATE: begin
                   foutbegadr[i] <= foutloopadr;
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
           i <= 0;
        end else begin
            case (state)
                `BEL_CTRL_SAVE_STATE: begin
                   i <= i + 1'b1;
                end
                `BEL_CTRL_RETURN_STATE: begin
                   i <= i - 1'b1;
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            k <= 0;
        end else begin
            case (state)
                `BEL_CTRL_INIT_STATE: begin
                     k <= p[0];
                end
                `BEL_CTRL_CALL_STATE: begin
                     k <= p[i];
                end
                `BEL_CTRL_RESTORE_STATE: begin
                     k <= stage[i] - 1'b1;
                end
            endcase
        end
    end        


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            // for (rst_stage_count = 0; rst_stage_count < stage_num; rst_stage_count = rst_stage_count + 1)
            //      stage[rst_stage_count] <= 0;
        end else begin
            case (state)
                `BEL_CTRL_SAVE_STATE: begin
                   stage[i] <= k;
                end
            endcase
        end
    end        

   
    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            state <= `BEL_CTRL_IDLE_STATE;
        end else begin
            state <= next_state;
        end
    end        


    always @ (state or start or m[i] or k or butterfly_finished or copy_finished or i) begin
        case (state)
            `BEL_CTRL_IDLE_STATE:
                if (start) begin
                    next_state = `BEL_CTRL_INIT_STATE;
                end else begin
                    next_state = `BEL_CTRL_IDLE_STATE;
                end
            `BEL_CTRL_INIT_STATE: begin
                next_state = `BEL_CTRL_LOOP_INIT_STATE;
            end
            `BEL_CTRL_SAVE_STATE: begin
                if (start) begin
                    // Restart again
                    next_state = `BEL_CTRL_INIT_STATE;
                end else begin
                    next_state = `BEL_CTRL_CALL_STATE;
                end
            end
            `BEL_CTRL_CALL_STATE: begin
                if (start) begin
                    // Restart again
                    next_state = `BEL_CTRL_INIT_STATE;
                end else begin
                    next_state = `BEL_CTRL_LOOP_INIT_STATE;
                end
            end
            `BEL_CTRL_LOOP_INIT_STATE: begin
                if (start) begin
                    // Restart again
                    next_state = `BEL_CTRL_INIT_STATE;
                end else begin
                    next_state = `BEL_CTRL_LOOP_STATE;
                end
            end
            `BEL_CTRL_LOOP_STATE: begin
                if (start) begin
                    // Restart again
                    next_state = `BEL_CTRL_INIT_STATE;
                end else begin
                    if (m[i] == 1) begin
                        next_state = `BEL_CTRL_COPY_STATE;
                    end else begin
                        if (k == 0) begin
                            next_state = `BEL_CTRL_START_STATE;
                        end else begin
                            next_state = `BEL_CTRL_SAVE_STATE;
                        end
                    end
                end
            end
            `BEL_CTRL_COPY_STATE: begin
                if (start) begin
                    // Restart again
                    next_state = `BEL_CTRL_INIT_STATE;
                end else begin
                    next_state = `BEL_CTRL_WAIT_FOR_COPY_END_STATE;
                end
            end
            `BEL_CTRL_WAIT_FOR_COPY_END_STATE: begin
                if (start) begin
                    // Restart again
                    next_state = `BEL_CTRL_INIT_STATE;
                end else begin
                    if (copy_finished) begin
                        next_state = `BEL_CTRL_START_STATE;
                    end else begin
                        next_state = `BEL_CTRL_WAIT_FOR_COPY_END_STATE;
                    end
                end
            end
            `BEL_CTRL_RETURN_STATE: begin
                if (start) begin
                    // Restart again
                    next_state = `BEL_CTRL_INIT_STATE;
                end else begin
                    next_state = `BEL_CTRL_RESTORE_STATE;
                end
            end
            `BEL_CTRL_RESTORE_STATE: begin
                if (start) begin
                    // Restart again
                    next_state = `BEL_CTRL_INIT_STATE;
                end else begin
                    next_state = `BEL_CTRL_LOOP_STATE;
                end
            end
            `BEL_CTRL_START_STATE: begin
                if (start) begin
                    // Restart again
                    next_state = `BEL_CTRL_INIT_STATE;
                end else begin
                    next_state = `BEL_CTRL_WAIT_STATE;
                end
            end
            `BEL_CTRL_WAIT_STATE: begin
                if (start) begin
                    // Restart again
                    next_state = `BEL_CTRL_INIT_STATE;
                end else begin
                    if (butterfly_finished) begin
                        if (i == 0) begin
                            next_state = `BEL_CTRL_FINISH_STATE;
                        end else begin
                            next_state = `BEL_CTRL_RETURN_STATE;
                        end
                    end else begin
                        next_state = `BEL_CTRL_WAIT_STATE;
                    end
                end
            end
            `BEL_CTRL_FINISH_STATE: begin
                if (start) begin
                    // Restart again
                    next_state = `BEL_CTRL_INIT_STATE;
                end else begin
                    next_state = `BEL_CTRL_IDLE_STATE;
                end
            end
            default: begin
                next_state = `BEL_CTRL_IDLE_STATE;
            end
        endcase
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            finish <= 1'b0;
        end else begin
            if (state == `BEL_CTRL_FINISH_STATE) begin
                finish <= 1'b1;
            end else begin
                if (ctrl_rd_i && (ctrl_adr_i == `BEL_FFT_STATUS_REG_ADDR)) begin
                    finish <= 1'b0;
                end
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i == 1'b1) begin
            running <= 1'b0;
        end else begin
            if (next_state != `BEL_CTRL_IDLE_STATE) begin
                running <= 1'b1;
            end else begin
                running <= 1'b0;
            end
        end
    end


    assign butterfly4_start = (state == `BEL_CTRL_START_STATE) && (p[i] == 4);
    assign butterfly2_start = (state == `BEL_CTRL_START_STATE) && (p[i] == 2);

    assign butterfly_finished = butterfly2_finished | butterfly4_finished;

    assign copy_start = (state == `BEL_CTRL_COPY_STATE);
   
   
    bel_butterfly4 #(
            .word_width (word_width),
            .twiddle_rom_awidth (twiddle_rom_max_awidth))
            u_butterfly4 (
            .clk_i (clk_i),
            .rst_i (rst_i),
            .adr_o (butterfly4_adr_o),
            .dat_re_i (butterfly4_dat_re_i),
            .dat_im_i (butterfly4_dat_im_i),
            .dat_re_o (butterfly4_dat_re_o),
            .dat_im_o (butterfly4_dat_im_o),
            .rd_o (butterfly4_rd_o),
            .wr_o (butterfly4_wr_o),
            .ack_i (butterfly4_ack_i),
            .err_i (butterfly4_err_i),
            .start (butterfly4_start),
            .finish (butterfly4_finished),
            .m (m[i]),
            .fstride (fstride[i]),
            .foutadr (foutbegadr[i]),
            .inv (inv),
            .tw_adr_o (tw_adr_bfly4),
            .tw_rd_o (tw_rd_bfly4),
            .tw_re_i (tw_re),
            .tw_im_i (tw_im));

    generate
        if (has_butterfly2 == 1) begin
   
            bel_butterfly2 #(
                    .word_width (word_width),
                    .twiddle_rom_awidth (twiddle_rom_max_awidth))
                u_butterfly2 (
                    .clk_i (clk_i),
                    .rst_i (rst_i),
                    .adr_o (butterfly2_adr_o),
                    .dat_re_i (butterfly2_dat_re_i),
                    .dat_im_i (butterfly2_dat_im_i),
                    .dat_re_o (butterfly2_dat_re_o),
                    .dat_im_o (butterfly2_dat_im_o),
                    .rd_o (butterfly2_rd_o),
                    .wr_o (butterfly2_wr_o),
                    .ack_i (butterfly2_ack_i),
                    .err_i (butterfly2_err_i),
                    .start (butterfly2_start),
                    .finish (butterfly2_finished),
                    .m (m[i]),
                    .fstride (fstride[i]),
                    .foutadr (foutbegadr[i]),
                    .tw_adr_o (tw_adr_bfly2),
                    .tw_rd_o (tw_rd_bfly2),
                    .tw_re_i (tw_re),
                    .tw_im_i (tw_im));
        end else begin

            assign butterfly2_adr_o = 0;
            assign butterfly2_rd_o = 0;
            assign butterfly2_wr_o = 0;
            assign butterfly2_dat_re_o = 0;
            assign butterfly2_dat_im_o = 0;
            assign tw_adr_bfly2 = 0;
            assign tw_rd_bfly2 = 0;
            assign butterfly2_finished = 0;

        end
    endgenerate

    assign tw_adr = tw_adr_bfly4 | tw_adr_bfly2;
    assign tw_rd = tw_rd_bfly4 | tw_rd_bfly2;

   
    bel_copy #(word_width) u_copy (
            .clk_i (clk_i),
            .rst_i (rst_i),
            .adr_o (copy_adr_o),
            .dat_re_o (copy_dat_re_o),
            .dat_re_i (copy_dat_re_i),
            .dat_im_o (copy_dat_im_o),
            .dat_im_i (copy_dat_im_i),
            .wr_o (copy_wr_o),
            .rd_o (copy_rd_o),
            .ack_i (copy_ack_i),
            .err_i (copy_err_i),
            .start (copy_start),
            .finished (copy_finished),
            .finadr (finloopadr),
            .foutadr (foutloopadr),
            .fstride (fstride[i]),
            .n (p[i]));
           

    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i) begin
            start <= 1'b0;
            inten <= 1'b0;
            inv <= 1'b0;
        end else begin
            if (state == `BEL_CTRL_INIT_STATE) begin
                // Reset start flag
                        
                start <= 1'b0;
            end else begin
                if (ctrl_wr_i && (ctrl_adr_i == `BEL_FFT_CONTROL_REG_ADDR)) begin
                    if (ctrl_bsel_i[2]) begin
                        inv <= ctrl_dat_i[16];
                    end
                    if (ctrl_bsel_i[1]) begin
                        inten <= ctrl_dat_i[8];
                    end
                    if (ctrl_bsel_i[0]) begin
                        start <= ctrl_dat_i[0];
                    end
                end
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i) begin
            n[`BEL_FFT_CTRL_NUM_WIDTH - 1:0] <= 0;
        end else begin
            if (ctrl_wr_i && (ctrl_adr_i == `BEL_FFT_SIZE_REG_ADDR)) begin
                if (ctrl_bsel_i[1]) begin
                    n[`BEL_FFT_CTRL_NUM_WIDTH - 1:8] <= ctrl_dat_i[`BEL_FFT_CTRL_NUM_WIDTH - 1:8];
                end
                if (ctrl_bsel_i[0]) begin
                    n[7:0] <= ctrl_dat_i[7:0];
                end
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i) begin
            srcadr[31:0] <= 0;
        end else begin
            if (ctrl_wr_i && (ctrl_adr_i == `BEL_FFT_SOURCE_REG_ADDR)) begin
                if (ctrl_bsel_i[3]) begin
                    srcadr[31:24] <= ctrl_dat_i[31:24];
                end
                if (ctrl_bsel_i[2]) begin
                    srcadr[23:16] <= ctrl_dat_i[23:16];
                end
                if (ctrl_bsel_i[1]) begin
                    srcadr[15:8] <= ctrl_dat_i[15:8];
                end
                if (ctrl_bsel_i[0]) begin
                    srcadr[7:0] <= ctrl_dat_i[7:0];
                end
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i) begin
            dstadr[31:0] <= 0;
        end else begin
            if (ctrl_wr_i && (ctrl_adr_i == `BEL_FFT_DEST_REG_ADDR)) begin
                if (ctrl_bsel_i[3]) begin
                    dstadr[31:24] <= ctrl_dat_i[31:24];
                end
                if (ctrl_bsel_i[2]) begin
                    dstadr[23:16] <= ctrl_dat_i[23:16];
                end
                if (ctrl_bsel_i[1]) begin
                    dstadr[15:8] <= ctrl_dat_i[15:8];
                end
                if (ctrl_bsel_i[0]) begin
                    dstadr[7:0] <= ctrl_dat_i[7:0];
                end
            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i) begin
            user[31:0] <= 0;
        end else begin
            if (ctrl_wr_i && (ctrl_adr_i == `BEL_FFT_USER_REG_ADDR)) begin
                if (ctrl_bsel_i[3]) begin
                    user[31:24] <= ctrl_dat_i[31:24];
                end
                if (ctrl_bsel_i[2]) begin
                    user[23:16] <= ctrl_dat_i[23:16];
                end
                if (ctrl_bsel_i[1]) begin
                    user[15:8] <= ctrl_dat_i[15:8];
                end
                if (ctrl_bsel_i[0]) begin
                    user[7:0] <= ctrl_dat_i[7:0];
                end
            end
        end
    end


generate

    genvar cfg_count;

    for (cfg_count = 0; cfg_count < config_num; cfg_count = cfg_count + 1) begin: cfg_count_loop

        always @ (posedge rst_i or posedge clk_i) begin
            if (rst_i) begin
                tw_cfg_sel[cfg_count] <= 1'b0;
            end else begin
                if (cfg_count == 0) begin
                    tw_cfg_sel[cfg_count] <= (n == fft_size);
                end else if (cfg_count == 1) begin
                    tw_cfg_sel[cfg_count] <= (n == fft_size1);
                end else if (cfg_count == 2) begin
                    tw_cfg_sel[cfg_count] <= (n == fft_size2);
                end else if (cfg_count == 3) begin
                    tw_cfg_sel[cfg_count] <= (n == fft_size3);
                end
            end
        end

    end

endgenerate


genvar stage_count;

generate

    for (stage_count = 0; stage_count < stage_num; stage_count = stage_count + 1) begin: stage_count_loop

        always @ (posedge rst_i or posedge clk_i) begin
            if (rst_i) begin
                m[stage_count] <= 0;
                p[stage_count] <= 0;
            end else begin
                if (ctrl_wr_i && (ctrl_adr_i == `BEL_FFT_FACTORS_REG_ADDR + stage_count)) begin
                    if (ctrl_bsel_i[3]) begin
                        p[stage_count][`BEL_FFT_CTRL_NUM_WIDTH - 1:8] <= ctrl_dat_i[`BEL_FFT_CTRL_NUM_WIDTH + 15:24];
                    end
                    if (ctrl_bsel_i[2]) begin
                        p[stage_count][7:0] <= ctrl_dat_i[23:16];
                    end
                    if (ctrl_bsel_i[1]) begin
                        m[stage_count][`BEL_FFT_CTRL_NUM_WIDTH - 1:8] <= ctrl_dat_i[`BEL_FFT_CTRL_NUM_WIDTH - 1:8];
                    end
                    if (ctrl_bsel_i[0]) begin
                        m[stage_count][7:0] <= ctrl_dat_i[7:0];
                    end
                end
            end
        end


    end

endgenerate


    always @ (ctrl_adr_i or m[0] or p[0]) begin
        if (ctrl_adr_i == `BEL_FFT_FACTORS_REG_ADDR) begin
            ctrl_dat_factors[0] = 0;
            ctrl_dat_factors[0][`BEL_FFT_CTRL_NUM_WIDTH - 1:0] = m[0];
            ctrl_dat_factors[0][`BEL_FFT_CTRL_NUM_WIDTH + 15:16] = p[0];
        end else begin
            ctrl_dat_factors[0] = 0;
        end
    end

generate

    for (stage_count = 1; stage_count < stage_num; stage_count = stage_count + 1) begin: ctrl_dat_loop

        always @ (ctrl_adr_i or m[stage_count] or p[stage_count] or ctrl_dat_factors[stage_count - 1]) begin
            if (ctrl_adr_i == `BEL_FFT_FACTORS_REG_ADDR + stage_count) begin
                ctrl_dat_factors[stage_count] = 0;
                ctrl_dat_factors[stage_count][`BEL_FFT_CTRL_NUM_WIDTH - 1:0] = m[stage_count];
                ctrl_dat_factors[stage_count][`BEL_FFT_CTRL_NUM_WIDTH + 15:16] = p[stage_count];
            end else begin
                ctrl_dat_factors[stage_count] = ctrl_dat_factors[stage_count - 1];
            end
        end

    end

endgenerate


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i) begin
            ctrl_err <= 1'b0;
            ctrl_dat <= 0;
        end else begin
            if (ctrl_rd_i) begin

                // Set all unused bits to 0. Used bits are overwritten in the case statement.
                ctrl_dat <= 0;
                ctrl_err <= 1'b0;
                case (ctrl_adr_i)
                    `BEL_FFT_CONTROL_REG_ADDR: begin
                        ctrl_dat[8] <= inten;
                        ctrl_dat[16] <= inv;
                    end
                    `BEL_FFT_STATUS_REG_ADDR: begin
                        ctrl_dat[0] <= running;
                        ctrl_dat[1] <= ov;
                        ctrl_dat[2] <= finish;
                        ctrl_dat[3] <= err;
                    end
                    `BEL_FFT_SIZE_REG_ADDR: begin
                        ctrl_dat[`BEL_FFT_CTRL_NUM_WIDTH - 1:0] <= n;
                    end
                    `BEL_FFT_SOURCE_REG_ADDR: begin
                        ctrl_dat <= srcadr;
                    end
                    `BEL_FFT_DEST_REG_ADDR: begin
                        ctrl_dat <= dstadr;
                    end
                    `BEL_FFT_USER_REG_ADDR: begin
                        ctrl_dat <= user;
                    end
                    default: begin
                        ctrl_dat <= ctrl_dat_factors[stage_num - 1];
                    end
                endcase

            end
        end
    end


    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i) begin
            ctrl_ack_rd <= 1'b0;
        end else begin
            ctrl_ack_rd <= ctrl_rd_i;
        end
    end


    assign ctrl_ack_o = ctrl_ack_rd | ctrl_wr_i;
    assign ctrl_err_o = ctrl_err;
    assign ctrl_dat_o = ctrl_dat;

    assign err = 1'b0;
    assign ov = 1'b0;

    assign int_o = (inten) ? finish : 1'b0;

    assign event_o = finish;

    assign user_o = user;

    // For generic butterfly, not yet implemented
    assign butterfly_generic_adr_o = 0;
    assign butterfly_generic_dat_re_o = 0;
    assign butterfly_generic_dat_im_o = 0;
    assign butterfly_generic_wr_o = 0;
    assign butterfly_generic_rd_o = 0;

   
endmodule


