#include <stdint.h>
#include <stdio.h>

#include "sys/alt_irq.h"
#include "audio.h"


// Using the audio system is easiest with an ISR. Here's a sample ISR that
// simply copies the incoming audio data to the output:
//
// int left_buffer[AUDIO_BUF_SIZE];
// int right_buffer[AUDIO_BUF_SIZE];
//
// void audio_isr (void *context, unsigned int id)
// {
//  int count = audio_read (left_buffer, right_buffer, AUDIO_BUF_SIZE);
//  audio_write (left_buffer, right_buffer, AUDIO_BUF_SIZE);
// }


/******************
 ****  MACROS  ****
 ******************/

#define AUDIO_RE_MASK 0x1
#define AUDIO_WE_MASK 0x2
#define AUDIO_CR_MASK 0x4
#define AUDIO_CW_MASK 0x8
#define AUDIO_RI_MASK 0x100
#define AUDIO_WI_MASK 0x200

#define AUDIO_RARC_MASK 0xFF
#define AUDIO_RALC_MASK 0xFF00
#define AUDIO_WSRC_MASK 0xFF0000
#define AUDIO_WSLC_MASK 0xFF000000

/********************************
 ****  GLOBALS DECLARATIONS  ****
 ********************************/

static volatile int *audio_ptr      = (int *) AUDIO_BASE;
static volatile int *fifospace_ptr  = (int *) (AUDIO_BASE + 4);
static volatile int *leftdata_ptr   = (int *) (AUDIO_BASE + 8);
static volatile int *rightdata_ptr  = (int *) (AUDIO_BASE + 12);

/* User-supplied audio ISR */
static void (*audio_isr)(void *context, unsigned int id);


/***************************************
 ****  PRIVATE FUNCTION PROTOTYPES  ****
 ***************************************/


/***************************************
 ****  PUBLIC FUNCTION DEFINITIONS  ****
 ***************************************/

void audio_init (void *isr)
{
  audio_isr = isr;

  // Register internal interrupt handler
  alt_irq_register (AUDIO_IRQ, NULL, (alt_isr_func) audio_isr);

  // Enable interrupts from audio module
  *audio_ptr |= AUDIO_RE_MASK;
}

void audio_clear_read_fifo ()
{
  *audio_ptr |= AUDIO_CR_MASK;
  *audio_ptr &= ~AUDIO_CR_MASK;
}

void audio_clear_write_fifo ()
{
  *audio_ptr |= AUDIO_CW_MASK;
  *audio_ptr &= ~AUDIO_CW_MASK;
}

uint8_t audio_read (int *left_buffer, int *right_buffer, uint8_t count)
{
  size_t read_buffer_index = 0;
  while ((*fifospace_ptr & AUDIO_RARC_MASK) && (read_buffer_index < count))
    {
      left_buffer[read_buffer_index]  = *leftdata_ptr;
      right_buffer[read_buffer_index] = *rightdata_ptr;
      read_buffer_index++;
    }
  return read_buffer_index;
}

uint8_t audio_write (int *left_buffer, int *right_buffer, uint8_t count)
{
  size_t write_buffer_index = 0;
  while ((*fifospace_ptr & AUDIO_WSRC_MASK) && (write_buffer_index < count))
    {
      *leftdata_ptr = left_buffer[write_buffer_index];
      *rightdata_ptr = right_buffer[write_buffer_index];
      write_buffer_index++;
    }
  return write_buffer_index;
}
