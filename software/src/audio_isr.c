#include "ee109-lib/audio.h"
#include "ee109-lib/red_leds.h"
#include "belfft/kiss_fft.h"
#include "system_globals.h"
#include <stdbool.h>

// From system_globals.c
extern volatile int left_buffer[AUDIO_BUF_SIZE];
extern volatile int right_buffer[AUDIO_BUF_SIZE];
extern volatile kiss_fft_cpx samples_for_fft[FFT_LEN];
extern volatile bool samples_for_fft_requested;

// from main.c
int fft ();
void draw_fft ();
void signal_audio_ready ();

int clamp (int value, int ceiling)
{
  if (value < ceiling) return 0;
  else return value;
}

void audio_isr (void *context, unsigned int id)
{
  size_t count = audio_read (left_buffer, right_buffer, AUDIO_BUF_SIZE);
  audio_write (left_buffer, right_buffer, count);
  if (samples_for_fft_requested)
    {
      size_t i;
      red_leds_set (0xFF);

      for (i = 0; i < FFT_LEN; i++)
        samples_for_fft[i].r = left_buffer[i] / AUDIO_DIVISOR;

      samples_for_fft_requested = false;
      signal_audio_ready ();
      red_leds_clear (0xFF);
    }
}
