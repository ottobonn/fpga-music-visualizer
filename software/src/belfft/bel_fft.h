/*******************************************************************
 *
 * bel_fft.h
 *
 *
 * This file is part of the "bel_fft" project
 *
 * Author(s):
 *     - Frank Storm (Frank.Storm@gmx.net)
 *
 *******************************************************************
 *
 * Copyright (C) 2010-2011 Authors
 *
 * This source file may be used and distributed without
 * restriction provided that this copyright statement is not
 * removed from the file and that any derivative work contains
 * the original copyright notice and the associated disclaimer.
 *
 * This source file is free software; you can redistribute it
 * and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation;
 * either version 2.1 of the License, or (at your option) any
 * later version.
 *
 * This source is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this source; if not, download it
 * from http://www.gnu.org/licenses/lgpl.html
 *
 *******************************************************************
 *
 * CVS Revision History
 *
 * $Log$
 *
 *******************************************************************
 */


#ifndef BEL_FFT_H
#define BEL_FFT_H

/*
 * e.g. an fft of length 128 has 4 factors
 * as far as kissfft is concerned
 * 4*4*4*2
 */
#define MAXFACTORS 32


/* Control register */
struct ControlReg {
    /* Starts the FFT */
    int Start: 1;
    int reserved1: 7;
    /* Enables the interrupt */
    int Inten: 1;
    int reserved2: 7;
    /* Normal or inverse FFT */
    int Inv: 1;
    int reserved3: 15;
};

/* Status register */
struct StatusReg {
    /* Indicates that the FFT is running. */
    int Running: 1;
    /* Overflow flag */
    int Ov: 1;
    /* Interrupt flag. This flag is cleared after reading. */
    int Int: 1;
    /* Error flag. This flag indicates that an error occured while 
     * the FFT was accessing the bus. This flag is cleared after 
     * reading. */
    int Err: 1;
    int reserved1: 28;
};

/* FFT size register */
struct NReg {
    /* Size of the FFT */
    int N: 16;
    int reserved1: 16;
};

/* FFT size register */
struct FactorsReg {
    /* Stage's FFT length/p */
    int M: 16;
    /* The radix */
    int P: 16;
};

/* Register structure, must be mapped to base address */
struct bel_fft  {
    struct ControlReg Control;                    /* Control register */
    struct StatusReg Status;                      /* Status register */
    struct NReg N;                                /* FFT size register */
    void * Finadr;                                /* Source address register */
    void * Foutadr;                               /* Destination address register */
    struct FactorsReg Factors[MAXFACTORS];        /* FFT size registers */
};


#endif

