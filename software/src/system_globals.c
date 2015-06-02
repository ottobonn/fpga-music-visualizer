#include "system_globals.h"
#include "ee109-lib/audio.h"
#include "belfft/kiss_fft.h"

volatile int left_buffer[AUDIO_BUF_SIZE];
volatile int right_buffer[AUDIO_BUF_SIZE];
volatile kiss_fft_cpx samples_for_fft[FFT_LEN];
volatile bool samples_for_fft_requested;
