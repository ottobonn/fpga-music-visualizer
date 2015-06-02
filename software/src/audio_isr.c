#include "ee109-lib/audio.h"
#include "ee109-lib/green_leds.h"

// From system_globals.c
extern volatile int left_buffer[AUDIO_BUF_SIZE];
extern volatile int right_buffer[AUDIO_BUF_SIZE];

void audio_isr (void *context, unsigned int id)
{
  int count = audio_read (left_buffer, right_buffer, AUDIO_BUF_SIZE);
  green_leds_set(0x1);
  audio_write (left_buffer, right_buffer, AUDIO_BUF_SIZE);
  green_leds_clear_all ();
}
