/* Standard. */
#include <unistd.h>
#include <stdbool.h>
#include <stdio.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>

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
volatile kiss_fft_cpx fout[FFT_LEN];
static void fft_isr (void *context, unsigned int id);
volatile bool audio_ready = false;

// FFT averaging and power spectrum
#define AVERAGING_LENGTH 2
size_t current_power_history_index = 0;
float power_history[FFT_LEN/2][AVERAGING_LENGTH];
float average_power_spectrum[FFT_LEN/2];


int values[FFT_LEN] = {98,
              195,
              290,
              382,
              471,
              555,
              634,
              707,
              773,
              831,
              881,
              923,
              956,
              980,
              995,
              1000,
              995,
              980,
              956,
              923,
              881,
              831,
              773,
              707,
              634,
              555,
              471,
              382,
              290,
              195,
              98,
              0,
              -99,
              -196,
              -291,
              -383,
              -472,
              -556,
              -635,
              -708,
              -774,
              -832,
              -882,
              -924,
              -957,
              -981,
              -996,
              -1000,
              -996,
              -981,
              -957,
              -924,
              -882,
              -832,
              -774,
              -708,
              -635,
              -556,
              -472,
              -383,
              -291,
              -196,
              -99,
              -1};

/*******************************
 ****  FUNCTION PROTOTYPES  ****
 *******************************/
/* General. */
static int initialize (void);
static void run (void);

int test_fft();
void draw_fft ();
static void fft_isr (void *context, unsigned int id);
int fft ();
void signal_audio_ready ();

/* Configuration Functions */
static void configure_lcd ();
static void configure_interrupts ();
static int configure_fft ();

float map (float value, float d0, float d1, float r0, float r1);

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
  lcd_set_front_buffer (LCD_DEFAULT_FRONT_BUFF_BASE);
  lcd_set_back_buffer (LCD_DEFAULT_BACK_BUFF_BASE);
  lcd_enable_dma (true);
  lcd_draw_rectangle (0, 0, LCD_RES_X, LCD_RES_Y, BLACK);
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
  kiss_fft (fft_cfg, samples_for_fft, fout);
  for (i = 0; i < FFT_LEN / 2; i++)
    {
      float power = sqrt(fout[i].r*fout[i].r + fout[i].i*fout[i].i);

      float scaled_power = map(power, 0, 100000, 0, LCD_RES_Y);
      power_history[i][current_power_history_index] = scaled_power;
      // Blend in historical data for smoothing
      average_power_spectrum[i] = 0;
      for (j = 0; j < AVERAGING_LENGTH; j++)
        average_power_spectrum[i] += power_history[i][j] / (float) AVERAGING_LENGTH;
    }

  current_power_history_index = (current_power_history_index + 1) % AVERAGING_LENGTH;
  return 0;
}

void draw_fft ()
{
  lcd_draw_rectangle (0, 0, LCD_RES_X, LCD_RES_Y, BLACK);
  const size_t bar_width = 4;

  int i;
  for (i = 0; i < FFT_LEN / 2; i++)
    {
      int value = (int) average_power_spectrum[i];
      lcd_draw_rectangle (bar_width * i, LCD_RES_Y - value, bar_width, value, WHITE);
    }

  lcd_swap_buffers ();
}

float map (float value, float d0, float d1, float r0, float r1)
{
  if (value > d1) return r1;
  if (value < d0) return r0;
  return value * (r1 - r0) / (d1 - d0);
}

void signal_audio_ready ()
{
  audio_ready = true;
}

int test_fft()
{


    kiss_fft_cpx fin[FFT_LEN];

    volatile kiss_fft_cpx fout[FFT_LEN];
    int i;

    /*
     * Initialize the destination memory area to see that the FFT has actually calculated something.
     */
    for (i = 0; i < FFT_LEN; i++) {
    	fin[i].r = values[i];
      fin[i].i = 0;
    }

    kiss_fft (fft_cfg, fin, fout);

    /*
     *  Print out the FFT result.
     */
    for (i = 0; i < FFT_LEN / 2; i++) {
      average_power_spectrum[i] = sqrt(fout[i].r*fout[i].r + fout[i].i*fout[i].i);
    }


    return 0;
}

static void fft_isr (void *context, unsigned int id)
{
  green_leds_set (current_power_history_index);
}
