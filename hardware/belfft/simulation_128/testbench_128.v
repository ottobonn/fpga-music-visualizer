////////////////////////////////////////////////////////////////////
//
// testbench_128.v
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


module testbench_128;

    parameter input_file_name = "input_data_128.dat";
    parameter fft_size = 128;
    parameter inverse = 0;
    parameter word_width = 32;
    parameter ram_awidth = 8;


    reg clk;
    reg rst;

    wire [`BEL_FFT_MIF_AWIDTH - 1:0] m_address;
    wire [`BEL_FFT_DWIDTH - 1:0] m_readdata;
    wire [`BEL_FFT_DWIDTH - 1:0] src_m_readdata;
    wire [`BEL_FFT_DWIDTH - 1:0] dst_m_readdata;
    wire [`BEL_FFT_DWIDTH - 1:0] m_writedata;
    wire m_read;
    wire src_m_read;
    wire dst_m_read;
    wire m_write;
    wire src_m_write;
    wire dst_m_write;
    wire m_waitrequest;
    wire m_readdatavalid;
    wire src_m_readdatavalid;
    wire dst_m_readdatavalid;

    reg [`BEL_FFT_SIF_AWIDTH - 1:0] s_address;
    wire [`BEL_FFT_DWIDTH - 1:0] s_readdata;
    reg [`BEL_FFT_DWIDTH - 1:0] s_writedata;
    reg s_read;
    reg s_write;
    reg [`BEL_FFT_BCNT - 1:0] s_byteenable;
    wire s_waitrequest;
    wire s_readdatavalid;

    wire int;

    reg dat_sel;
   
   
    task idleCycle;
        input [31:0] cycle_count;
        begin
            #1
            s_address = 0;
            s_writedata = 0;
            s_byteenable = 4'b0000;
            s_write = 1'b0;
            s_read = 1'b0;
            repeat (cycle_count)
                @(posedge clk);
        end
    endtask

    
    task writeRegister;
        input [`BEL_FFT_SIF_AWIDTH - 1:0] address;
        input [`BEL_FFT_DWIDTH - 1:0] data;
        begin
            #1 
            s_address = address;
            s_writedata = data;
            s_byteenable = 4'b1111;
            s_write = 1'b1;
            @(posedge clk);
            while (s_waitrequest == 1'b1)
                @(posedge clk);
            #1
            s_address = 0;
            s_writedata = 0;
            s_byteenable = 4'b0000;
            s_write = 1'b0;
            @(posedge clk);
        end
    endtask // input


    task readRegister;
        input [`BEL_FFT_SIF_AWIDTH - 1:0] address;
        begin
            #1 
            s_address = address;
            s_byteenable = 4'b1111;
            s_read = 1'b1;
            @(posedge clk);
            while (s_waitrequest == 1'b1)
                @(posedge clk);
            #1
            s_address = 0;
            s_byteenable = 4'b0000;
            s_read = 1'b0;
            while (s_readdatavalid == 1'b0)
                @(posedge clk);
            @(posedge clk);
        end
    endtask // input


    task waitForInterrupt;
        begin
            @(posedge int);
        end
    endtask
    
    
    initial begin
        rst = 1'b1;
        #20 rst = 1'b0;
    end
    

    initial begin
        clk = 1'b0;
    end
    

    always begin
        #10 clk = 1'b1;
        #10 clk = 1'b0;
    end


    initial begin
        idleCycle (4);
        // u_OutputRam.open_logfile;

        writeRegister (`BEL_FFT_SIZE_REG_ADDR, fft_size);

        // The input data is located t address 0.
        // finadr = 0
        writeRegister (`BEL_FFT_SOURCE_REG_ADDR, fft_size * (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT));

        // Write the resulting data above the input data (FFT size * number of bytes per complex value)
        // foutadr = FFT size * number of 32 bit word for a complex number
        writeRegister (`BEL_FFT_DEST_REG_ADDR, 2 * fft_size * (word_width * 2 / `BEL_FFT_DWIDTH * `BEL_FFT_BCNT));

        // p[0] = 0004, m[0] = 0020
        writeRegister (`BEL_FFT_FACTORS_REG_ADDR + 0, 32'h0004_0020);

        readRegister (`BEL_FFT_FACTORS_REG_ADDR + 0);

        // p[1] = 0004, m[1] = 0008
        writeRegister (`BEL_FFT_FACTORS_REG_ADDR + 1, 32'h0004_0008);

        readRegister (`BEL_FFT_FACTORS_REG_ADDR + 1);

        // p[2] = 0004, m[2] = 0002
        writeRegister (`BEL_FFT_FACTORS_REG_ADDR + 2, 32'h0004_0002);

        readRegister (`BEL_FFT_FACTORS_REG_ADDR + 2);

        // p[3] = 0002, m[3] = 0001
        writeRegister (`BEL_FFT_FACTORS_REG_ADDR + 3, 32'h0002_0001);

        readRegister (`BEL_FFT_FACTORS_REG_ADDR + 3);

        // start + enable interrupt
        writeRegister (`BEL_FFT_CONTROL_REG_ADDR, inverse * 65536 + 257);

        waitForInterrupt;
        
        idleCycle (1);

        // Read the status register
        readRegister (`BEL_FFT_STATUS_REG_ADDR);

        idleCycle (1);

        // u_OutputRam.close_logfile;
        u_OutputRam.dump;
        $finish;
    end


    initial begin
        // Timeout in case of errors
        
        #100000000 $finish;
    end


    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
           dat_sel <= 1'b0;
        end else begin
            if (m_read | m_write) begin
                if (m_address[ram_awidth + 3:ram_awidth + 2] == 2'b10) begin
                    dat_sel <= 1'b1;
                end else begin
                    dat_sel <= 1'b0;
                end
            end
        end
    end

    assign src_m_read = (m_address[ram_awidth + 3:ram_awidth + 2] == 2'b01) ? m_read : 1'b0;
    assign dst_m_read = (m_address[ram_awidth + 3:ram_awidth + 2] == 2'b10) ? m_read : 1'b0;
    assign src_m_write = (m_address[ram_awidth + 3:ram_awidth + 2] == 2'b01) ? m_write : 1'b0;
    assign dst_m_write = (m_address[ram_awidth + 3:ram_awidth + 2] == 2'b10) ? m_write : 1'b0;
    assign m_readdata = dat_sel ? dst_m_readdata : src_m_readdata;
    assign m_readdatavalid = dat_sel ? dst_m_readdatavalid : src_m_readdatavalid;
    assign m_waitrequest = 1'b0;


    bel_avl_ram #(fft_size * word_width * 2 / `BEL_FFT_DWIDTH, ram_awidth,
            input_file_name, "/dev/null", "input_ram.log") u_InputRam (
            .clk_i (clk),
            .rst_i (rst),
            .address (m_address[ram_awidth + 1:2]),
            .readdata (src_m_readdata),
            .writedata (m_writedata),
            .read (src_m_read),
            .write (src_m_write),
            .readdatavalid (src_m_readdatavalid));


    bel_avl_ram #(fft_size * (word_width * 2 / `BEL_FFT_DWIDTH), ram_awidth,
            "", "output_data.dat", "output_ram.log") u_OutputRam (
            .clk_i (clk),
            .rst_i (rst),
            .address (m_address[ram_awidth + 1:2]),
            .readdata (dst_m_readdata),
            .writedata (m_writedata),
            .read (dst_m_read),
            .write (dst_m_write),
            .readdatavalid (dst_m_readdatavalid));

    
    belfft u_fft (
            .clk_i (clk),
            .rst_i (rst),
            .m_address (m_address),
            .m_readdata (m_readdata),
            .m_writedata (m_writedata),
            .m_read (m_read),
            .m_write (m_write),
            .m_waitrequest (m_waitrequest),
            .m_readdatavalid (m_readdatavalid),
            .s_address (s_address),
            .s_readdata (s_readdata),
            .s_writedata (s_writedata),
            .s_read (s_read),
            .s_write (s_write),
            .s_byteenable (s_byteenable),
            .s_waitrequest (s_waitrequest),
            .s_readdatavalid (s_readdatavalid),
            .int_o (int));

 
endmodule

