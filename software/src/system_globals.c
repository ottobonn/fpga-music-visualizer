#include "system_globals.h"
#include "ee109-lib/audio.h"

volatile int left_buffer[AUDIO_BUF_SIZE] = {
  10000, 100000, 1000000, 1000, 10000, 10000, 1000000, 100000,
  10000, 10000, 1, 10000000, 10, 11000000, 10000, 100000
};
volatile int right_buffer[AUDIO_BUF_SIZE];
