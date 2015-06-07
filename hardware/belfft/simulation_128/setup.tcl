#
# setup.tcl
#
#
# This file is part of the "bel_fft" project
#
# Author(s):
#     - Frank Storm (Frank.Storm@gmx.net)
#
#
# Copyright (C) 2010 - 2013 Authors
#
# This source file may be used and distributed without
# restriction provided that this copyright statement is not
# removed from the file and that any derivative work contains
# the original copyright notice and the associated disclaimer.
#
# This source file is free software; you can redistribute it
# and/or modify it under the terms of the GNU Lesser General
# Public License as published by the Free Software Foundation;
# either version 2.1 of the License, or (at your option) any
# later version.
#
# This source is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General
# Public License along with this source; if not, download it
# from http://www.gnu.org/licenses/lgpl.html
#
#
# CVS Revision History
#
# $Log$
#


set BEL_FFT_SRC_DIR ..
set BEL_FFT_IP_DIR ..


radix define ctrl_states {
  5'b00000 "IDLE",
  5'b00001 "INIT",
  5'b00010 "SAVE",
  5'b00011 "CALL",
  5'b00100 "RESTORE",
  5'b00101 "RETURN",
  5'b00110 "COPY",
  5'b00111 "START",
  5'b01000 "WAIT",
  5'b01001 "FINISH",
  5'b01010 "LOOP",
  5'b01011 "WAIT_FOR_COPY_END",
  5'b01100 "LOOP_INIT",
 -default hex
}

radix define butterfly4_state {
 4'b0000 "IDLE",
 4'b0001 "INIT",
 4'b0010 "LOAD2",
 4'b0011 "LOAD0",
 4'b0100 "LOAD3",
 4'b0101 "LOAD1",
 4'b0110 "EXEC0",
 4'b0111 "EXEC1",
 4'b1000 "EXEC2",
 4'b1001 "EXEC3",
 4'b1010 "EXEC4",
 4'b1011 "SAVE2",
 4'b1100 "SAVE1",
 4'b1101 "SAVE3",
 4'b1110 "SAVE0",
 -default hex
}

radix define butterfly2_state {
 4'b0000 "IDLE",
 4'b0001 "INIT",
 4'b0010 "LOAD2",
 4'b0011 "LOAD1",
 4'b0100 "EXEC0",
 4'b0101 "EXEC1",
 4'b0110 "EXEC2",
 4'b0111 "EXEC3",
 4'b1000 "SAVE2",
 4'b1001 "SAVE1",
 -default hex
}

radix define copy_state {
 2'b00 "IDLE",
 2'b01 "LOAD",
 2'b10 "STORE",
 -default hex
}

radix define mif_state {
 2'b00 "RE",
 2'b01 "IM",
 2'b10 "IDLE",
 -default hex
}


proc sext {str} {

    global tcl_platform

    switch [string index $str 0] {
        8 -
        9 -
        A -
        B -
        C -
        D -
        E -
        F {
            return "0x[string repeat F [expr $tcl_platform(wordSize) * 2 - [string length $str]]]$str"
        }
        default {
            return "0x[string repeat 0 [expr $tcl_platform(wordSize) * 2 - [string length $str]]]$str"
        }
    }
}


proc writeDataFile {fileName size wordSize busWidth part} {

    global memData

    if {[catch {set f [open $fileName w]} result]} {
        puts "Error: $result"
        return 1
    }

    for {set i 0} {$i < $size} {incr i} {
        if {$wordSize == 16} {
            if {[string length $memData($i)] == 8} {
                if {[string equal $part re]} {
                    set data [sext [string toupper [string range $memData($i) 0 3]]]
                } else {
                    set data [sext [string toupper [string range $memData($i) 4 end]]]
                }
                puts $f [expr int($data)]
            } else {
                puts "xxx"
            }
        } else {
            if {$busWidth == 32} {
                if {[string equal $part re]} {
                    set data [sext [string toupper $memData([expr $i * 2])]]
                } else {
                    set data [sext [string toupper $memData([expr $i * 2 + 1])]]
                }
                puts $f [expr int($data)]
            } else {
                if {[string length $memData($i)] == 16} {
                    if {[string equal $part re]} {
                        set data [sext [string toupper [string range $memData($i) 0 7]]]
                    } else {
                        set data [sext [string toupper [string range $memData($i) 8 end]]]
                    }
                    puts $f [expr int($data)]
                } else {
                    puts "xxx"
                }
            }
        }
    }
    close $f
    return 0
}


proc readReadmemhFile {fileName} {

    global memData

    if {[catch {set f [open $fileName r]} result]} {
        puts "Error: $result"
        return 1
    }

    while {! [eof $f]} {
        gets $f str
        if {[regexp -nocase {^\ *\@([0-9A-F]+)\ +([0-9A-F]+)} $str match address data]} {
            set memData([expr 0x$address]) $data
        }
    }
    close $f
    return 0
}


proc writeGnuplotRunScript {fileName} {

    if {[catch {set f [open $fileName w]} result]} {
        puts "Error: $result"
        return 1
    }

    puts $f "set style data linespoints"
    puts $f "plot 'output_data_re.dat', 'output_data_im.dat'"
    
    close $f
    return 0
}


proc bel_fft_library_setup {} {

    global BEL_FFT_SRC_DIR

    vlib work
    vmap work work


    if {[file exist [file join $BEL_FFT_SRC_DIR belfft_twiddle_rom0.mif]]} {
        file copy -force [file join $BEL_FFT_SRC_DIR belfft_twiddle_rom0.mif] .
    }
    if {[file exist [file join $BEL_FFT_SRC_DIR belfft_twiddle_rom0.dat]]} {
        file copy -force [file join $BEL_FFT_SRC_DIR belfft_twiddle_rom0.dat] .
    }
    file copy -force [file join $BEL_FFT_SRC_DIR bel_fft_def.v] bel_fft_def.v
    if {[file exist [file join $BEL_FFT_SRC_DIR bel_axi_def.v]]} {
        file copy -force [file join $BEL_FFT_SRC_DIR bel_axi_def.v] bel_axi_def.v
    }

}


proc bel_fft_compile_files {} {

    global BEL_FFT_SRC_DIR

    foreach verilogFileName [list \
            [file join $BEL_FFT_SRC_DIR bel_butterfly4.v] \
            [file join $BEL_FFT_SRC_DIR bel_butterfly2.v] \
            [file join $BEL_FFT_SRC_DIR bel_cadd.v] \
            [file join $BEL_FFT_SRC_DIR bel_caddsub.v] \
            [file join $BEL_FFT_SRC_DIR bel_cdiv4.v] \
            [file join $BEL_FFT_SRC_DIR bel_cdiv2.v] \
            [file join $BEL_FFT_SRC_DIR bel_cmac.v] \
            [file join $BEL_FFT_SRC_DIR bel_cmul.v] \
            [file join $BEL_FFT_SRC_DIR bel_copy.v] \
            [file join $BEL_FFT_SRC_DIR bel_csub.v] \
            [file join $BEL_FFT_SRC_DIR bel_fft_core.v] \
            [file join $BEL_FFT_SRC_DIR bel_fft_avl.v] \
            [file join $BEL_FFT_SRC_DIR bel_fft_avl_sif.v] \
            [file join $BEL_FFT_SRC_DIR bel_fft_avl_mif_32.v] \
            [file join $BEL_FFT_SRC_DIR belfft_twiddle_rom0.v] \
            [file join $BEL_FFT_SRC_DIR belfft_twiddle_roms.v] \
            [file join $BEL_FFT_SRC_DIR belfft.v] \
            bel_avl_ram.v \
            testbench_128.v \
            ] {
        vlog $verilogFileName
    }
}


proc bel_fft_run_simulation {} {

    vsim \
            -t ps \
            -L work \
            -L altera_mf_ver \
            testbench_128

    add wave -noupdate /testbench_128/*
    # add wave -noupdate sim:/testbench_128/u_fft/u_core/u_sif/*
    add wave -noupdate sim:/testbench_128/u_InputRam/*
    add wave -noupdate sim:/testbench_128/u_OutputRam/*
    add wave -noupdate sim:/testbench_128/u_fft/u_core/u_mif/*

}


proc bel_fft_run_gnuplot {} {

    if {[readReadmemhFile output_data.dat]} {
        return 1
    }
    if {[writeDataFile output_data_re.dat 128 32 32 re]} {
        return 1
    }
    if {[writeDataFile output_data_im.dat 128 32 32 im]} {
        return 1
    }
    if {[writeGnuplotRunScript plot_output.scr]} {
        return 1
    }
    exec gnuplot -p plot_output.scr
}


proc bel_fft_show_help {} {

    echo ""
    echo "Available commands:"
    echo ""
    echo "c   Compile all files"
    echo ""
    echo "s   Start the simulation"
    echo ""
    echo "g   Show the results with Gnuplot"
    echo ""
}


alias c bel_fft_compile_files
alias s bel_fft_run_simulation
alias g bel_fft_run_gnuplot

bel_fft_library_setup

bel_fft_show_help

