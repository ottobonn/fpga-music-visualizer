////////////////////////////////////////////////////////////////////
//
// bel_cmul.v
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


module bel_cmul (
        clk_i,
        pipe_halt,
        a_re_i,
        a_im_i,
        b_re_i,
        b_im_i,
        x_re_o,
        x_im_o);

    parameter word_width = 16;

    input clk_i;
    input pipe_halt;
    input signed [word_width - 1:0] a_re_i;
    input signed [word_width - 1:0] a_im_i;
    input signed [word_width - 1:0] b_re_i;
    input signed [word_width - 1:0] b_im_i;
    output signed [word_width - 1:0] x_re_o;
    output signed [word_width - 1:0] x_im_o;

    reg signed [word_width * 2 - 1:0] scratch0;
    reg signed [word_width * 2 - 1:0] scratch1;
    reg signed [word_width * 2 - 1:0] scratch2;
    reg signed [word_width * 2 - 1:0] scratch3;
    wire signed [word_width * 2 - 1:0] scratch4;
    reg signed [word_width * 2 - 1:0] scratch5;
    reg signed [word_width * 2 - 1:0] scratch6;

    wire signed [word_width * 2 - 1:0] x_re;
    wire signed [word_width * 2 - 1:0] x_im;


    always @ (posedge clk_i) begin
        if (~pipe_halt) begin
            scratch0 <= a_re_i * b_re_i;
            scratch1 <= a_re_i * b_im_i;
            scratch2 <= a_im_i * b_re_i;
            scratch3 <= a_im_i * b_im_i;
            scratch5 <= scratch0 - scratch3;
            scratch6 <= scratch1 + scratch2;
        end
    end


    assign scratch4 = 1 << (word_width - 2);

    assign x_re = (scratch5 + scratch4) >>> (word_width - 1);
    assign x_im = (scratch6 + scratch4) >>> (word_width - 1);
   
    assign x_re_o = x_re[word_width - 1:0];
    assign x_im_o = x_im[word_width - 1:0];
    
endmodule // bel_cmul

