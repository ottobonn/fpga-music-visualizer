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
static void fft_isr (void *context, unsigned int id);
volatile bool audio_ready = false;

// FFT averaging and power spectrum
#define AVERAGING_LENGTH 1
size_t current_power_history_index = 0;
double power_history[FFT_LEN/2][AVERAGING_LENGTH];
double average_power_spectrum[FFT_LEN/2];

/*******************************
 ****  FUNCTION PROTOTYPES  ****
 *******************************/
/* General. */
static int initialize (void);
static void run (void);

/* Hardware FFT functions */
static void fft_isr (void *context, unsigned int id);
int fft ();
void signal_audio_ready ();

/* Drawing functions */
void draw_fft ();
void swap_buffers ();

/* Configuration functions */
static void configure_lcd ();
static void configure_interrupts ();
static int configure_fft ();


float mapf (float value, float d0, float d1, float r0, float r1);
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

static void configure_interrupts ()
{
  audio_init (audio_isr);
}

static void configure_lcd ()
{
  lcd_set_front_buffer (LCD_FRONT_BUFFER);
  lcd_set_back_buffer (LCD_BACK_BUFFER);
  lcd_enable_dma (true);
  lcd_draw_rectangle_back (0, 0, LCD_RES_X, LCD_RES_Y, BLACK);
  swap_buffers ();
}

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
      //lcd_draw_rectangle_back (0, 0, LCD_RES_X, LCD_RES_Y, BLACK);
      //tlda_draw (1,LCD_RES_Y-100,1,LCD_RES_Y,RED,10);
      //swap_buffers ();
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

  for (i = 0; i < FFT_LEN / 2; i++)
    {
      double power = sqrt((double)fft_output[i].r*(double)fft_output[i].r + (double)fft_output[i].i*(double)fft_output[i].i);

      float scaled_power = mapd(power, 0, 100000000, 0, LCD_RES_Y-1);
      power_history[i][current_power_history_index] = scaled_power;
      // Blend in historical data for smoothing
      average_power_spectrum[i] = 0;
      for (j = 0; j < AVERAGING_LENGTH; j++)
        average_power_spectrum[i] += power_history[i][j] / (double) AVERAGING_LENGTH;
    }

  current_power_history_index = (current_power_history_index + 1) % AVERAGING_LENGTH;
  return 0;
}

void swap_buffers ()
{
  lcd_swap_buffers ();
  tlda_set_drawing_buffer (lcd_get_backbuffer_addr ());
}

void draw_fft ()
{
  lcd_draw_rectangle_back (0, 0, LCD_RES_X, LCD_RES_Y, BLACK);
  const size_t bar_width = 12;

  int i;
  for (i = 0; i < FFT_LEN / 4; i++)
    {
      int value = (int) average_power_spectrum[i];
      // lcd_draw_rectangle (bar_width * i, LCD_RES_Y - value, bar_width, value, rand () % 0x10000);
      tlda_draw (bar_width * i + bar_width / 2,
                LCD_RES_Y - value,
                bar_width * i + bar_width / 2,
                LCD_RES_Y,
                (value + 1000) % 0x10000,
                bar_width / 2
                );
    }
  swap_buffers ();
}

float mapf (float value, float d0, float d1, float r0, float r1)
{
  if (value > d1) return r1;
  if (value < d0) return r0;
  float new = value * (r1 - r0) / (d1 - d0);
  return new;
}

double mapd (double value, double d0, double d1, double r0, double r1)
{
  if (value > d1) return r1;
  if (value < d0) return r0;
  double new = value * (r1 - r0) / (d1 - d0);
  return new;
}

void signal_audio_ready ()
{
  audio_ready = true;
}

static void fft_isr (void *context, unsigned int id)
{
  green_leds_set (current_power_history_index);
}

/* Cool strobe feature that brought some much needed joy during long nights in the lab */
void clear_strobe_flash (void)
{
	int coin;
	int x, y;
	int i;
	for (i = 0; i < 5000; i++)
	{
		coin = rand() % 2;
		if (coin)
			{
				x = rand() % 2 ? 0 : LCD_RES_X;
				y = rand() % (LCD_RES_Y + 1);
			}
		else
			{
				x = rand() % (LCD_RES_X + 1);
				y = rand() % 2 ? 0 : LCD_RES_Y;
			}
		tlda_draw (LCD_RES_X / 2, LCD_RES_Y / 2, x, y, 0, 1);
	}
}
