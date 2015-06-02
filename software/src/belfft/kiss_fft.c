/*
 * Copyright (c) 2003-2010, Mark Borgerding
 * Adaption to bel_fft hardware FFT
 * Copyright (c) 2011-2012, Frank Storm
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this
 *   list of conditions and the following disclaimer in the documentation and/or
 *   other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#include "bel_fft.h"
#include "kiss_fft.h"
#include "system.h"

#include <sys/alt_cache.h>


typedef struct kiss_fft_state{
    int nfft;
    int nstage;
    short int factors[2*MAXFACTORS];
    volatile struct bel_fft *belFftPtr;
} kiss_fft_state;


/*
 *  facbuf is populated by p1,m1,p2,m2, ...
 *  where
 *  p[i] * m[i] = m[i-1]
 *  m0 = n
 */

static
int kf_factor (int n, short int *facbuf)
{
    int p = 4;

    /* factor out powers of 4, powers of 2, then any remaining primes */
    do {
        while (n % p) {
            switch (p) {
                case 4: p = 2; break;
                case 2: p = 3; break;
                default: p += 2; break;
            }
            if (p > 32000 || (int) p *(int) p > n) {
                p = n;          /* no more factors, skip to end */
            }
        }
        n /= p;
        if (p>5) {
            return 0;
        }
        *facbuf++ = (short int) p;
        *facbuf++ = (short int) n;
    } while (n > 1);
    return 1;
}

/*
 * User-callable function to allocate all necessary storage space for the fft.
 *
 * The return value is a contiguous block of memory, allocated with malloc.  As such,
 * It can be freed with free(), rather than a kiss_fft-specific function.
 *
 * The parameters inverse_fft, mem, and lenmem are not used.
 */

kiss_fft_cfg kiss_fft_alloc_twiddles (int nfft, int inverse_fft, void *mem, size_t *lenmem)
{
    kiss_fft_cfg cfg;

    cfg = (kiss_fft_cfg) malloc (sizeof (struct kiss_fft_state));
    if (cfg) {
        cfg->nfft = nfft;

        cfg->belFftPtr = (struct bel_fft *) FFT_BASE;
        if (! kf_factor (nfft, cfg->factors)) {
            free (cfg);
            return NULL;
        }
    }
    return cfg;
}


kiss_fft_cfg kiss_fft_alloc (int nfft, int inverse_fft, void * mem, size_t * lenmem)
{
    return kiss_fft_alloc_twiddles (nfft, inverse_fft, mem, lenmem);
}


void kiss_fft_stride (const kiss_fft_cfg cfg, kiss_fft_cpx *fin, kiss_fft_cpx *fout, int in_stride)
{
  short int *facbuf;
  int i;

  /*
   *  Set bit 31 to bypass the cache on the NIOSII.
   */

  volatile struct bel_fft * belFftPtr = (struct bel_fft *) (FFT_BASE + 0x80000000);

  /*
   * Set the size, source and destination address
   */

  belFftPtr->N.N = cfg->nfft;
  belFftPtr->Finadr = fin;
  belFftPtr->Foutadr = fout;

  /*
   * Copy the precalculated factors.
   */

  facbuf = cfg->factors;
  i = 0;
  while (1) {
      belFftPtr->Factors[i].P = *facbuf++;
      belFftPtr->Factors[i].M = *facbuf;
      if (*facbuf++ == 1) {
          break;
      }
      i++;
  }

  /*
   * Flush the data cache for the source and destination region
   */

  alt_dcache_flush (fin, cfg->nfft * sizeof (kiss_fft_cpx));
  alt_dcache_flush (fout, cfg->nfft * sizeof (kiss_fft_cpx));

  /*
   * Since we poll the status register we do not enable the interrupt
   */

  // cfg->belFftPtr->Control.Inten = 1;

  /*
   * Start the FFT
   */

  belFftPtr->Control.Start = 1;

  /*
   * We poll the status register until the FFT is ready. Other implementations
   * like generation an interrupt are possible.
   */

  while (! belFftPtr->Status.Int);
}


void kiss_fft (kiss_fft_cfg cfg, kiss_fft_cpx *fin, kiss_fft_cpx *fout)
{
    kiss_fft_stride (cfg, fin, fout, 1);
}


/*
 * Empty function, nothing to clean up
 */
void kiss_fft_cleanup (void)
{
}
