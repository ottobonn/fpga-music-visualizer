#include <stdint.h>

#define AUDIO_BUF_SIZE 128

void audio_init (void *isr);

uint8_t audio_read (int *left_buffer, int *right_buffer, uint8_t count);

uint8_t audio_write (int *left_buffer, int *right_buffer, uint8_t count);

void audio_clear_read_fifo ();

void audio_clear_write_fifo ();
