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
    input [7 - 1:0] address;
    output [64 - 1: 0] q;

    reg [64 - 1:0] rom [128 - 1:0];
    reg [64 - 1:0] q;

    always @(posedge clock) begin
        if (clken) begin
            case (address)
                7'h0000: q <= 64'h7FFFFFFF00000000;
                7'h0001: q <= 64'h7FD8878DF9B82684;
                7'h0002: q <= 64'h7F62368EF3742CA2;
                7'h0003: q <= 64'h7E9D55FBED37EF92;
                7'h0004: q <= 64'h7D8A5F3FE70747C4;
                7'h0005: q <= 64'h7C29FBEDE0E60685;
                7'h0006: q <= 64'h7A7D055ADAD7F3A3;
                7'h0007: q <= 64'h78848413D4E0CB15;
                7'h0008: q <= 64'h7641AF3CCF043AB3;
                7'h0009: q <= 64'h73B5EBD0C945DFED;
                7'h000A: q <= 64'h70E2CBC5C3A94590;
                7'h000B: q <= 64'h6DCA0D14BE31E19C;
                7'h000C: q <= 64'h6A6D98A3B8E3131A;
                7'h000D: q <= 64'h66CF811FB3C0200D;
                7'h000E: q <= 64'h62F201ACAECC336C;
                7'h000F: q <= 64'h5ED77C89AA0A5B2E;
                7'h0010: q <= 64'h5A827999A57D8667;
                7'h0011: q <= 64'h55F5A4D2A1288377;
                7'h0012: q <= 64'h5133CC949D0DFE54;
                7'h0013: q <= 64'h4C3FDFF399307EE1;
                7'h0014: q <= 64'h471CECE69592675D;
                7'h0015: q <= 64'h41CE1E649235F2EC;
                7'h0016: q <= 64'h3C56BA708F1D343B;
                7'h0017: q <= 64'h36BA20138C4A1430;
                7'h0018: q <= 64'h30FBC54D89BE50C4;
                7'h0019: q <= 64'h2B1F34EB877B7BED;
                7'h001A: q <= 64'h25280C5D8582FAA6;
                7'h001B: q <= 64'h1F19F97B83D60413;
                7'h001C: q <= 64'h18F8B83C8275A0C1;
                7'h001D: q <= 64'h12C8106E8162AA05;
                7'h001E: q <= 64'h0C8BD35E809DC972;
                7'h001F: q <= 64'h0647D97C80277873;
                7'h0020: q <= 64'h0000000080000001;
                7'h0021: q <= 64'hF9B8268480277873;
                7'h0022: q <= 64'hF3742CA2809DC972;
                7'h0023: q <= 64'hED37EF928162AA05;
                7'h0024: q <= 64'hE70747C48275A0C1;
                7'h0025: q <= 64'hE0E6068583D60413;
                7'h0026: q <= 64'hDAD7F3A38582FAA6;
                7'h0027: q <= 64'hD4E0CB15877B7BED;
                7'h0028: q <= 64'hCF043AB389BE50C4;
                7'h0029: q <= 64'hC945DFED8C4A1430;
                7'h002A: q <= 64'hC3A945908F1D343B;
                7'h002B: q <= 64'hBE31E19C9235F2EC;
                7'h002C: q <= 64'hB8E3131A9592675D;
                7'h002D: q <= 64'hB3C0200D99307EE1;
                7'h002E: q <= 64'hAECC336C9D0DFE54;
                7'h002F: q <= 64'hAA0A5B2EA1288377;
                7'h0030: q <= 64'hA57D8667A57D8667;
                7'h0031: q <= 64'hA1288377AA0A5B2E;
                7'h0032: q <= 64'h9D0DFE54AECC336C;
                7'h0033: q <= 64'h99307EE1B3C0200D;
                7'h0034: q <= 64'h9592675DB8E3131A;
                7'h0035: q <= 64'h9235F2ECBE31E19C;
                7'h0036: q <= 64'h8F1D343BC3A94590;
                7'h0037: q <= 64'h8C4A1430C945DFED;
                7'h0038: q <= 64'h89BE50C4CF043AB3;
                7'h0039: q <= 64'h877B7BEDD4E0CB15;
                7'h003A: q <= 64'h8582FAA6DAD7F3A3;
                7'h003B: q <= 64'h83D60413E0E60685;
                7'h003C: q <= 64'h8275A0C1E70747C4;
                7'h003D: q <= 64'h8162AA05ED37EF92;
                7'h003E: q <= 64'h809DC972F3742CA2;
                7'h003F: q <= 64'h80277873F9B82684;
                7'h0040: q <= 64'h8000000100000000;
                7'h0041: q <= 64'h802778730647D97C;
                7'h0042: q <= 64'h809DC9720C8BD35E;
                7'h0043: q <= 64'h8162AA0512C8106E;
                7'h0044: q <= 64'h8275A0C118F8B83C;
                7'h0045: q <= 64'h83D604131F19F97B;
                7'h0046: q <= 64'h8582FAA625280C5D;
                7'h0047: q <= 64'h877B7BED2B1F34EB;
                7'h0048: q <= 64'h89BE50C430FBC54D;
                7'h0049: q <= 64'h8C4A143036BA2013;
                7'h004A: q <= 64'h8F1D343B3C56BA70;
                7'h004B: q <= 64'h9235F2EC41CE1E64;
                7'h004C: q <= 64'h9592675D471CECE6;
                7'h004D: q <= 64'h99307EE14C3FDFF3;
                7'h004E: q <= 64'h9D0DFE545133CC94;
                7'h004F: q <= 64'hA128837755F5A4D2;
                7'h0050: q <= 64'hA57D86675A827999;
                7'h0051: q <= 64'hAA0A5B2E5ED77C89;
                7'h0052: q <= 64'hAECC336C62F201AC;
                7'h0053: q <= 64'hB3C0200D66CF811F;
                7'h0054: q <= 64'hB8E3131A6A6D98A3;
                7'h0055: q <= 64'hBE31E19C6DCA0D14;
                7'h0056: q <= 64'hC3A9459070E2CBC5;
                7'h0057: q <= 64'hC945DFED73B5EBD0;
                7'h0058: q <= 64'hCF043AB37641AF3C;
                7'h0059: q <= 64'hD4E0CB1578848413;
                7'h005A: q <= 64'hDAD7F3A37A7D055A;
                7'h005B: q <= 64'hE0E606857C29FBED;
                7'h005C: q <= 64'hE70747C47D8A5F3F;
                7'h005D: q <= 64'hED37EF927E9D55FB;
                7'h005E: q <= 64'hF3742CA27F62368E;
                7'h005F: q <= 64'hF9B826847FD8878D;
                7'h0060: q <= 64'h000000007FFFFFFF;
                7'h0061: q <= 64'h0647D97C7FD8878D;
                7'h0062: q <= 64'h0C8BD35E7F62368E;
                7'h0063: q <= 64'h12C8106E7E9D55FB;
                7'h0064: q <= 64'h18F8B83C7D8A5F3F;
                7'h0065: q <= 64'h1F19F97B7C29FBED;
                7'h0066: q <= 64'h25280C5D7A7D055A;
                7'h0067: q <= 64'h2B1F34EB78848413;
                7'h0068: q <= 64'h30FBC54D7641AF3C;
                7'h0069: q <= 64'h36BA201373B5EBD0;
                7'h006A: q <= 64'h3C56BA7070E2CBC5;
                7'h006B: q <= 64'h41CE1E646DCA0D14;
                7'h006C: q <= 64'h471CECE66A6D98A3;
                7'h006D: q <= 64'h4C3FDFF366CF811F;
                7'h006E: q <= 64'h5133CC9462F201AC;
                7'h006F: q <= 64'h55F5A4D25ED77C89;
                7'h0070: q <= 64'h5A8279995A827999;
                7'h0071: q <= 64'h5ED77C8955F5A4D2;
                7'h0072: q <= 64'h62F201AC5133CC94;
                7'h0073: q <= 64'h66CF811F4C3FDFF3;
                7'h0074: q <= 64'h6A6D98A3471CECE6;
                7'h0075: q <= 64'h6DCA0D1441CE1E64;
                7'h0076: q <= 64'h70E2CBC53C56BA70;
                7'h0077: q <= 64'h73B5EBD036BA2013;
                7'h0078: q <= 64'h7641AF3C30FBC54D;
                7'h0079: q <= 64'h788484132B1F34EB;
                7'h007A: q <= 64'h7A7D055A25280C5D;
                7'h007B: q <= 64'h7C29FBED1F19F97B;
                7'h007C: q <= 64'h7D8A5F3F18F8B83C;
                7'h007D: q <= 64'h7E9D55FB12C8106E;
                7'h007E: q <= 64'h7F62368E0C8BD35E;
                7'h007F: q <= 64'h7FD8878D0647D97C;
            endcase
        end
    end

endmodule
