////////////////////////////////////////////////////////////////////
//
// bel_avl_ram.v
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


module bel_avl_ram (
        clk_i,
        rst_i,
        address,
        readdata,
        writedata,
        read,
        write,
        readdatavalid);

    parameter size = 64;
    parameter adr_width = 6;
    parameter input_file_name = "bel_avl_ram_in.dat";
    parameter output_file_name = "bel_avl_ram_out.dat";
    parameter log_file_name = "bel_wb_ram.log";

    input clk_i;
    input rst_i;

    input [adr_width - 1:0] address;
    output [`BEL_FFT_DWIDTH - 1:0] readdata;
    input [`BEL_FFT_DWIDTH - 1:0] writedata;
    input read;
    input write;
    output readdatavalid;

    reg [`BEL_FFT_DWIDTH-1:0] ram [0:size-1];

    reg [adr_width-1:0] adr;
    reg readdatavalid;

    integer log_f;


    task init_memory;
        integer i;

        for (i = 0; i < size; i = i + 1) begin
            ram[i] = {`BEL_FFT_DWIDTH{16'hDEAD}};
        end
    endtask


    initial begin
        init_memory;         
        log_f = 0;
        $readmemh (input_file_name, ram);
    end


    task open_logfile;
        begin
            log_f = $fopen (log_file_name); 
        end
    endtask


    task close_logfile;
        begin
            $fclose (log_f); 
        end
    endtask


    task dump;
        integer f;
        integer i;

        begin
            f = $fopen (output_file_name); 
            for (i = 0; i < size; i = i + 1) begin
                $fwrite (f, "@%X %X\n", i, ram[i]);
            end
            $fclose (f);
        end
    endtask 
 
    
    always @ (posedge rst_i or posedge clk_i) begin
        if (rst_i) begin
            adr <= 0;
            readdatavalid <= 1'b0;
        end else begin
            if (read | write) begin
                adr <= address;
            end
            if (write) begin
                if (log_f != 0) begin
                    $fwrite (log_f, "%d: Write %8X - %8X\n", $time, address, writedata);
                end

                ram[address] <= writedata;
            end
            if (read) begin
                if (log_f != 0) begin
                    $fwrite (log_f, "%d: Read  %8X - %8X\n", $time, address, ram[address]);
                end
                readdatavalid <= 1'b1;
            end else begin
                readdatavalid <= 1'b0;
            end
        end
    end

            
    assign readdata = ram[adr];


endmodule // bel_avl_ram

