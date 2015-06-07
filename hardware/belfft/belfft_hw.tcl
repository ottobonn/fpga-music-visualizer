#
# belfft_hw.tcl
#
#
# This file is part of the "bel_fft" project
#
# Author(s):
#     - Frank Storm (Frank.Storm@gmx.net)
#
#
# Copyright (C) 2010 - 2011 Authors
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
# from http:#www.gnu.org/licenses/lgpl.html
#
#
# CVS Revision History
#
# $Log$
#

# If no version is specified, version 9.0 is taken.

package require -exact sopc 11.0

set_module_property NAME belfft
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP DSP
set_module_property AUTHOR "Frank Storm"
set_module_property DISPLAY_NAME belfft
set_module_property TOP_LEVEL_HDL_FILE belfft.v
set_module_property TOP_LEVEL_HDL_MODULE belfft
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property FIX_110_VIP_PATH false

add_file bel_butterfly4.v {SYNTHESIS SIMULATION}
add_file bel_butterfly2.v {SYNTHESIS SIMULATION}
add_file bel_cadd.v {SYNTHESIS SIMULATION}
add_file bel_caddsub.v {SYNTHESIS SIMULATION}
add_file bel_cdiv4.v {SYNTHESIS SIMULATION}
add_file bel_cdiv2.v {SYNTHESIS SIMULATION}
add_file bel_cmac.v {SYNTHESIS SIMULATION}
add_file bel_cmul.v {SYNTHESIS SIMULATION}
add_file bel_copy.v {SYNTHESIS SIMULATION}
add_file bel_csub.v {SYNTHESIS SIMULATION}
add_file bel_fft_core.v {SYNTHESIS SIMULATION}
add_file bel_fft_avl.v {SYNTHESIS SIMULATION}
add_file bel_fft_avl_sif.v {SYNTHESIS SIMULATION}
add_file bel_fft_avl_mif_32.v {SYNTHESIS SIMULATION}
add_file belfft_twiddle_rom0.v {SYNTHESIS SIMULATION}
add_file belfft_twiddle_roms.v {SYNTHESIS SIMULATION}
add_file belfft.v {SYNTHESIS SIMULATION}
add_file bel_fft_def.v {SYNTHESIS SIMULATION}
add_file belfft_twiddle_rom0.mif {SYNTHESIS SIMULATION}

add_interface control_slave avalon end
set_interface_property control_slave addressAlignment DYNAMIC
set_interface_property control_slave addressUnits WORDS
set_interface_property control_slave associatedClock clock_sink
set_interface_property control_slave associatedReset reset_sink
set_interface_property control_slave burstOnBurstBoundariesOnly false
set_interface_property control_slave explicitAddressSpan 0
set_interface_property control_slave holdTime 0
set_interface_property control_slave isMemoryDevice false
set_interface_property control_slave isNonVolatileStorage false
set_interface_property control_slave linewrapBursts false
set_interface_property control_slave maximumPendingReadTransactions 1
set_interface_property control_slave printableDevice false
set_interface_property control_slave readLatency 0
set_interface_property control_slave readWaitTime 1
set_interface_property control_slave setupTime 0
set_interface_property control_slave timingUnits Cycles
set_interface_property control_slave writeWaitTime 0

set_interface_property control_slave ENABLED true

add_interface_port control_slave s_address address Input 10
add_interface_port control_slave s_readdata readdata Output 32
add_interface_port control_slave s_writedata writedata Input 32
add_interface_port control_slave s_read read Input 1
add_interface_port control_slave s_write write Input 1
add_interface_port control_slave s_byteenable byteenable Input 4
add_interface_port control_slave s_waitrequest waitrequest Output 1
add_interface_port control_slave s_readdatavalid readdatavalid Output 1


# connection point clock_sink

add_interface clock_sink clock end
set_interface_property clock_sink clockRate 0

set_interface_property clock_sink ENABLED true

add_interface_port clock_sink clk_i clk Input 1


# connection point reset_sink

add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock_sink
set_interface_property reset_sink synchronousEdges DEASSERT

set_interface_property reset_sink ENABLED true

add_interface_port reset_sink rst_i reset Input 1

# connection point avalon_master

add_interface avalon_master avalon start
set_interface_property avalon_master addressUnits SYMBOLS
set_interface_property avalon_master associatedClock clock_sink
set_interface_property avalon_master associatedReset reset_sink
set_interface_property avalon_master burstOnBurstBoundariesOnly false
set_interface_property avalon_master doStreamReads false
set_interface_property avalon_master doStreamWrites false
set_interface_property avalon_master linewrapBursts false
set_interface_property avalon_master readLatency 0

set_interface_property avalon_master ENABLED true

add_interface_port avalon_master m_address address Output 32
add_interface_port avalon_master m_readdata readdata Input 32
add_interface_port avalon_master m_read read Output 1
add_interface_port avalon_master m_write write Output 1
add_interface_port avalon_master m_waitrequest waitrequest Input 1
add_interface_port avalon_master m_readdatavalid readdatavalid Input 1
add_interface_port avalon_master m_writedata writedata Output 32


# connection point interrupt_sender

add_interface interrupt_sender interrupt end
set_interface_property interrupt_sender associatedAddressablePoint control_slave
set_interface_property interrupt_sender associatedClock clock_sink
set_interface_property interrupt_sender associatedReset reset_sink

set_interface_property interrupt_sender ENABLED true

add_interface_port interrupt_sender int_o irq Output 1
