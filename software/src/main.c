/* Standard. */
#include <unistd.h>
#include <stdbool.h>
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <math.h>

/* Altera. */
#include "system.h"
#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"

/* EE109. */
#include "isr.h"
#include "system_globals.h"
#include "ee109-lib/colors.h"
#include "ee109-lib/switches.h"
#include "ee109-lib/pushbuttons.h"
#include "ee109-lib/vga.h"
#include "ee109-lib/lcd.h"
#include "ee109-lib/char_lcd.h"
#include "ee109-lib/red_leds.h"
#include "ee109-lib/green_leds.h"
#include "ee109-lib/hex.h"
#include "ee109-lib/audio.h"


#include "belfft/bel_fft.h"
#include "belfft/kiss_fft.h"

#include "tlda/tlda.h"

#define LCD_FRONT_BUFFER (SRAM_BASE)
#define LCD_BACK_BUFFER  (SRAM_BASE + 0x80000)

/********************************
 ****  GLOBALS DECLARATIONS  ****
 ********************************/

// From system_globals.c
extern volatile int left_buffer[AUDIO_BUF_SIZE];
extern volatile int right_buffer[AUDIO_BUF_SIZE];
extern volatile kiss_fft_cpx samples_for_fft[FFT_LEN];
extern volatile bool samples_for_fft_requested;

// For hardware FFT
kiss_fft_cfg fft_cfg;
volatile kiss_fft_cpx fft_output[FFT_LEN];
volatile bool audio_ready = false;

// Number of bins to draw (must be <= FFT_LEN)
#define DRAWING_BINS (FFT_LEN / 4 - 1)

// FFT averaging and power spectrum
#define AVERAGING_LENGTH 1
size_t current_power_history_index = 0;
double power_history[DRAWING_BINS][AVERAGING_LENGTH];
double average_power_spectrum[DRAWING_BINS];

// If true, use hardware rendering
volatile bool use_hardware_rendering = true;

/*******************************
 ****  FUNCTION PROTOTYPES  ****
 *******************************/
/* General functions */
static int initialize (void);
static void run (void);

/* Hardware FFT functions */
int fft ();
void signal_audio_ready ();

/* Drawing functions */
void draw_fft ();
void swap_buffers ();
void toggle_hardware_rendering ();

/* Configuration functions */
static void configure_lcd ();
static void configure_interrupts ();
static int configure_fft ();

/* Math functions */
double mapd (double value, double d0, double d1, double r0, double r1);

/********************************
 ****  FUNCTION DEFINITIONS  ****
 ********************************/

/**
 * Function: main
 * --------------
 * main simply calls initialize() then run().
 */
int main(void)
{
  /* Initialize devices and introduce application. */
  if (initialize () != 0)
    return 1;

  /* Repeatedly checks state and makes updates. */
  run ();

  return 0;
}

/**
 * Function: initialize
 * --------------------
 * Prepare all interrupts and interfaces. Returns 0 on success, nonzero otherwise.
 */
static int initialize (void)
{
  configure_lcd ();

  configure_interrupts ();

  if (configure_fft () != 0)
    return 1;

  return 0;
}

/* Set up audio and pushbutton interrupts. */
static void configure_interrupts ()
{
  audio_init (audio_isr);
  pushbuttons_enable_interrupts (pushbuttons_isr);
  pushbuttons_set_interrupt_mask (BUTTON1);
}

/* Enable LCD double buffering and DMA, then clear the screen. */
static void configure_lcd ()
{
  lcd_set_front_buffer (LCD_FRONT_BUFFER);
  lcd_set_back_buffer (LCD_BACK_BUFFER);
  lcd_enable_dma (true);
  lcd_draw_rectangle_back (0, 0, LCD_RES_X, LCD_RES_Y, BLACK);
  swap_buffers ();
}

/* Allocate the FFT configuration stryct and prepare sample array. */
static int configure_fft ()
{
  fft_cfg = kiss_fft_alloc (FFT_LEN, 0, NULL, 0);
  if (! fft_cfg) {
    printf ("Error: Cannot allocate memory for FFT control structure.\n");
    return 1;
  }

  // Set imaginary part of FFT input vector to 0
  size_t i;
  for (i = 0; i < FFT_LEN; i++)
    samples_for_fft[i].i = 0;

  return 0;
}

/**
 * Function: run
 * -------------
 * Request audio, then perform an FFT and draw it. Repeat.
 */
void run (void)
{
  while (true)
    {
      samples_for_fft_requested = true; // Request audio
      while (!audio_ready); // Wait for audio
      green_leds_set (0xFF);
      fft ();
      green_leds_clear (0xFF);
      draw_fft ();
      audio_ready = false;
    }
}

/**
 * Function: fft
 * -------------
 * Perform a hardware FFT on the samples_for_fft array.
 * Also store historical FFT outputs in a ring buffer of length AVERAGING_LENGTH
 * so the animation is smoother.
 */
int fft ()
{
  int i, j;
  kiss_fft (fft_cfg, samples_for_fft, fft_output);

  for (i = 0; i < DRAWING_BINS; i++)
    {
      double power = sqrt((double)fft_output[i].r*(double)fft_output[i].r + (double)fft_output[i].i*(double)fft_output[i].i);

      float scaled_power = mapd(power, 0, 10000000, 0, LCD_RES_Y-1);
      power_history[i][current_power_history_index] = scaled_power;
      // Blend in historical data for smoothing
      average_power_spectrum[i] = 0;
      for (j = 0; j < AVERAGING_LENGTH; j++)
        average_power_spectrum[i] += power_history[i][j] / (double) AVERAGING_LENGTH;
    }

  current_power_history_index = (current_power_history_index + 1) % AVERAGING_LENGTH;
  return 0;
}

/* Swap the LCD buffers and pass the new backbuffer address to the TLDA. */
void swap_buffers ()
{
  lcd_swap_buffers ();
  tlda_set_drawing_buffer (lcd_get_backbuffer_addr ());
}

/* Draw the visualizer pattern using the FFT output. */
void draw_fft ()
{
  lcd_draw_rectangle_back (0, 0, LCD_RES_X, LCD_RES_Y, BLACK);
  const size_t bar_width = 13;

  int i;
  for (i = 0; i < DRAWING_BINS; i++)
    {
      int value = (int) average_power_spectrum[i];
      if (use_hardware_rendering)
        {
          tlda_draw (bar_width * i,
                    LCD_RES_Y - value,
                    bar_width * i,
                    LCD_RES_Y,
                    (value + 1000) % 0x10000,
                    bar_width - 2);
        }
      else
        {
          lcd_draw_rectangle_back (bar_width * i,
                                    LCD_RES_Y - value,
                                    bar_width - 1,
                                    value,
                                    (value + 1000) % 0x10000);
        }
    }
  swap_buffers ();
}

/* Map a double whose domain spans from d0 to d1 onto the range given by
 * r0 to r1. */
double mapd (double value, double d0, double d1, double r0, double r1)
{
  if (value > d1) return r1;
  if (value < d0) return r0;
  double new = (value - d0) * (r1 - r0) / (d1 - d0);
  return new;
}

/* Called by the audio ISR to signal the main loop that samples are ready
 * for the FFT. */
void signal_audio_ready ()
{
  audio_ready = true;
}

/* Turn hardware rendering on or off. */
void toggle_hardware_rendering ()
{
  use_hardware_rendering = !use_hardware_rendering;
}
