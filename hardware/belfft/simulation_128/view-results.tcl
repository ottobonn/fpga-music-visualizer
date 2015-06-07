#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

#
# view-results.tcl
#
#
# This file is part of the "bel_fft" project
#
# Author(s):
#     - Frank Storm (Frank.Storm@gmx.net)
#
#
# Copyright (C) 2012-2013 Authors
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
                        set data [sext [string toupper [string range $memData($i) 8 end]]]
                    } else {
                        set data [sext [string toupper [string range $memData($i) 0 7]]]
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


bel_fft_run_gnuplot

