////////////////////////////////////////////////////////////////////
//
// belfft_twiddle_rom0.v.v
//
//
// This file is part of the "bel_fft" project
//
// Author(s):
//     - Frank Storm (Frank.Storm@gmx.net)
//
////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2012-2013 Authors
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


module belfft_twiddle_rom0 (
        clock,
        clken,
        address,
        q);

    input clock;
    input clken;
    input [6 - 1:0] address;
    output [32 - 1: 0] q;

    reg [32 - 1:0] rom [64 - 1:0];
    reg [32 - 1:0] q;

    always @(posedge clock) begin
        if (clken) begin
            case (address)
                6'h0000: q <= 32'h7FFF0000;
                6'h0001: q <= 32'h7F61F374;
                6'h0002: q <= 32'h7D89E707;
                6'h0003: q <= 32'h7A7CDAD8;
                6'h0004: q <= 32'h7641CF05;
                6'h0005: q <= 32'h70E2C3AA;
                6'h0006: q <= 32'h6A6DB8E4;
                6'h0007: q <= 32'h62F1AECD;
                6'h0008: q <= 32'h5A82A57E;
                6'h0009: q <= 32'h51339D0F;
                6'h000A: q <= 32'h471C9593;
                6'h000B: q <= 32'h3C568F1E;
                6'h000C: q <= 32'h30FB89BF;
                6'h000D: q <= 32'h25288584;
                6'h000E: q <= 32'h18F98277;
                6'h000F: q <= 32'h0C8C809F;
                6'h0010: q <= 32'h00008001;
                6'h0011: q <= 32'hF374809F;
                6'h0012: q <= 32'hE7078277;
                6'h0013: q <= 32'hDAD88584;
                6'h0014: q <= 32'hCF0589BF;
                6'h0015: q <= 32'hC3AA8F1E;
                6'h0016: q <= 32'hB8E49593;
                6'h0017: q <= 32'hAECD9D0F;
                6'h0018: q <= 32'hA57EA57E;
                6'h0019: q <= 32'h9D0FAECD;
                6'h001A: q <= 32'h9593B8E4;
                6'h001B: q <= 32'h8F1EC3AA;
                6'h001C: q <= 32'h89BFCF05;
                6'h001D: q <= 32'h8584DAD8;
                6'h001E: q <= 32'h8277E707;
                6'h001F: q <= 32'h809FF374;
                6'h0020: q <= 32'h80010000;
                6'h0021: q <= 32'h809F0C8C;
                6'h0022: q <= 32'h827718F9;
                6'h0023: q <= 32'h85842528;
                6'h0024: q <= 32'h89BF30FB;
                6'h0025: q <= 32'h8F1E3C56;
                6'h0026: q <= 32'h9593471C;
                6'h0027: q <= 32'h9D0F5133;
                6'h0028: q <= 32'hA57E5A82;
                6'h0029: q <= 32'hAECD62F1;
                6'h002A: q <= 32'hB8E46A6D;
                6'h002B: q <= 32'hC3AA70E2;
                6'h002C: q <= 32'hCF057641;
                6'h002D: q <= 32'hDAD87A7C;
                6'h002E: q <= 32'hE7077D89;
                6'h002F: q <= 32'hF3747F61;
                6'h0030: q <= 32'h00007FFF;
                6'h0031: q <= 32'h0C8C7F61;
                6'h0032: q <= 32'h18F97D89;
                6'h0033: q <= 32'h25287A7C;
                6'h0034: q <= 32'h30FB7641;
                6'h0035: q <= 32'h3C5670E2;
                6'h0036: q <= 32'h471C6A6D;
                6'h0037: q <= 32'h513362F1;
                6'h0038: q <= 32'h5A825A82;
                6'h0039: q <= 32'h62F15133;
                6'h003A: q <= 32'h6A6D471C;
                6'h003B: q <= 32'h70E23C56;
                6'h003C: q <= 32'h764130FB;
                6'h003D: q <= 32'h7A7C2528;
                6'h003E: q <= 32'h7D8918F9;
                6'h003F: q <= 32'h7F610C8C;
            endcase
        end
    end

endmodule
