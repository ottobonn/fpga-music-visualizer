////////////////////////////////////////////////////////////////////
//
// bel_fft_defs.v
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



`define BEL_FFT_DWIDTH 32

`define BEL_FFT_AWIDTH 32

`define BEL_FFT_MIF_AWIDTH `BEL_FFT_AWIDTH

`define BEL_FFT_SIF_AWIDTH 10

`define BEL_FFT_BCNT 4



`define BEL_FFT_STAGE_NUM 4

`define BEL_FFT_CTRL_NUM_WIDTH 12




`define BEL_FFT_CONTROL_REG_ADDR 0

`define BEL_FFT_STATUS_REG_ADDR 1

`define BEL_FFT_SIZE_REG_ADDR 2

`define BEL_FFT_SOURCE_REG_ADDR 3

`define BEL_FFT_DEST_REG_ADDR 4

`define BEL_FFT_FACTORS_REG_ADDR 5

`define BEL_FFT_USER_REG_ADDR 1022


`define BEL_CTRL_IDLE_STATE 5'b00000
`define BEL_CTRL_INIT_STATE 5'b00001
`define BEL_CTRL_SAVE_STATE 5'b00010
`define BEL_CTRL_CALL_STATE 5'b00011
`define BEL_CTRL_RESTORE_STATE 5'b00100
`define BEL_CTRL_RETURN_STATE 5'b00101
`define BEL_CTRL_COPY_STATE 5'b00110
`define BEL_CTRL_START_STATE 5'b00111
`define BEL_CTRL_WAIT_STATE 5'b01000
`define BEL_CTRL_FINISH_STATE 5'b01001
`define BEL_CTRL_LOOP_STATE 5'b01010
`define BEL_CTRL_WAIT_FOR_COPY_END_STATE 5'b01011
`define BEL_CTRL_LOOP_INIT_STATE 5'b01100


`define BEL_BFLY4_IDLE_STATE 4'b0000
`define BEL_BFLY4_INIT_STATE 4'b0001
`define BEL_BFLY4_LOAD2_STATE 4'b0010
`define BEL_BFLY4_LOAD0_STATE 4'b0011
`define BEL_BFLY4_LOAD3_STATE 4'b0100
`define BEL_BFLY4_LOAD1_STATE 4'b0101
`define BEL_BFLY4_EXEC0_STATE 4'b0110
`define BEL_BFLY4_EXEC1_STATE 4'b0111
`define BEL_BFLY4_EXEC2_STATE 4'b1000
`define BEL_BFLY4_EXEC3_STATE 4'b1001
`define BEL_BFLY4_EXEC4_STATE 4'b1010
`define BEL_BFLY4_SAVE2_STATE 4'b1011
`define BEL_BFLY4_SAVE1_STATE 4'b1100
`define BEL_BFLY4_SAVE3_STATE 4'b1101
`define BEL_BFLY4_SAVE0_STATE 4'b1110

`define BEL_BFLY2_IDLE_STATE 4'b0000
`define BEL_BFLY2_INIT_STATE 4'b0001
`define BEL_BFLY2_LOAD2_STATE 4'b0010
`define BEL_BFLY2_LOAD1_STATE 4'b0011
`define BEL_BFLY2_EXEC0_STATE 4'b0100
`define BEL_BFLY2_EXEC1_STATE 4'b0101
`define BEL_BFLY2_EXEC2_STATE 4'b0110
`define BEL_BFLY2_EXEC3_STATE 4'b0111
`define BEL_BFLY2_SAVE2_STATE 4'b1000
`define BEL_BFLY2_SAVE1_STATE 4'b1001


`define BEL_MIF_RE_STATE 2'b00
`define BEL_MIF_IM_STATE 2'b01
`define BEL_MIF_IDLE_STATE 2'b10


