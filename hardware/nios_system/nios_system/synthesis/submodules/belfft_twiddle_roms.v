////////////////////////////////////////////////////////////////////
//
// belfft_twiddle_roms.v
//
//
// This file is part of the "bel_fft" project
//
// Author(s):
//     - Frank Storm (Frank.Storm@gmx.net)
//
////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2010-2012 Authors
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


module belfft_twiddle_roms (clk_i, rst_i, adr_i, rd_i, dat_o, cfg_sel_i);

    parameter word_width = 16;
    parameter config_num = 1;
    parameter max_awidth = 6;

    parameter size = 256;
    parameter awidth = 6;
    parameter file_name = "bel_rom_twiddles.dat";

    parameter size2 = 256;
    parameter awidth2 = 6;
    parameter file_name2 = "bel_rom_twiddles2.dat";

    parameter size3 = 256;
    parameter awidth3 = 6;
    parameter file_name3 = "bel_rom_twiddles3.dat";

    parameter size4 = 256;
    parameter awidth4 = 6;
    parameter file_name4 = "bel_rom_twiddles4.dat";

    input clk_i;
    input rst_i;
    input [max_awidth - 1:0] adr_i;
    input rd_i;
    output [word_width * 2 - 1:0] dat_o;
    input [config_num - 1:0] cfg_sel_i;

    reg [word_width * 2 - 1:0] dat_o;
    wire [word_width * 2 - 1:0] dat;
    wire [word_width * 2 - 1:0] dat2;
    wire [word_width * 2 - 1:0] dat3;
    wire [word_width * 2 - 1:0] dat4;

    belfft_twiddle_rom0 rom (
        .address (adr_i[awidth - 1:0]),
        .clken (rd_i & cfg_sel_i[0]),
        .clock (clk_i),
        .q (dat));

generate

    if (config_num > 1) begin
    
        belfft_twiddle_rom1 rom2 (
            .address (adr_i[awidth2 - 1:0]),
            .clken (rd_i & cfg_sel_i[1]),
            .clock (clk_i),
            .q (dat2));

        if (config_num > 2) begin

            belfft_twiddle_rom2 rom3 (
                .address (adr_i[awidth3 - 1:0]),
                .clken (rd_i & cfg_sel_i[2]),
                .clock (clk_i),
                .q (dat3));

            if (config_num > 3) begin

                belfft_twiddle_rom3 rom4 (
                    .address (adr_i[awidth4 - 1:0]),
                    .clken (rd_i & cfg_sel_i[3]),
                    .clock (clk_i),
                    .q (dat4));

                always @ (cfg_sel_i or dat or dat2 or dat3 or dat4) begin
                    case (cfg_sel_i)
                        4'b1000: begin
                            dat_o = dat4;
                        end
                        4'b0100: begin
                            dat_o = dat3;
                        end
                        4'b0010: begin
                            dat_o = dat2;
                        end
                        default: begin
                            dat_o = dat;
                        end
                    endcase
                end

            end else begin

                always @ (cfg_sel_i or dat or dat2 or dat3) begin
                    case (cfg_sel_i)
                        3'b100: begin
                            dat_o = dat3;
                        end
                        3'b010: begin
                            dat_o = dat2;
                        end
                        default: begin
                            dat_o = dat;
                        end
                    endcase
                end

            end

        end else begin

            always @ (cfg_sel_i or dat or dat2) begin
                case (cfg_sel_i)
                    2'b10: begin
                        dat_o = dat2;
                    end
                    default: begin
                        dat_o = dat;
                    end
                endcase
            end

        end

    end else begin

        always @ (dat)
          dat_o = dat;

    end

endgenerate

    
endmodule // belfft_twiddle_roms

