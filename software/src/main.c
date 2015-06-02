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

// Hardware FFT macros
#define FIXED_POINT 16
#define FFT_LEN 64

/********************************
 ****  GLOBALS DECLARATIONS  ****
 ********************************/

// From system_globals.c
extern volatile int left_buffer[AUDIO_BUF_SIZE];
extern volatile int right_buffer[AUDIO_BUF_SIZE];

// For hardware FFT
kiss_fft_cfg fft_cfg;
kiss_fft_cpx fin[FFT_LEN];
volatile kiss_fft_cpx fout[FFT_LEN];

#define AVERAGING_LENGTH 4
size_t current_power_history_index = 0;
float power_history[AVERAGING_LENGTH][FFT_LEN/2];
float power_spectrum[FFT_LEN/2];

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
static void initialize (void);
static void run (void);

int test_fft();
void draw_fft ();
static void fft_isr (void *context, unsigned int id);
int fft ();

/* Configuration Functions */
static void configure_lcd();
static void configure_interrupts();

int map (int value, int d0, int d1, int r0, int r1);

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
  initialize ();

  /* Repeatedly checks state and makes updates. */
  run ();

  return 0;
}

/**
 * Function: initialize
 * --------------------
 * Prepare all interrupts and interfaces.
 */
static void initialize (void)
{
  configure_lcd ();

  configure_interrupts ();

  fft_cfg = kiss_fft_alloc (FFT_LEN, 0, NULL, 0);
  if (! fft_cfg) {
    printf ("Error: Cannot allocate memory for FFT control structure.\n");
    return 1;
  }
  size_t i;
  for (i = 0; i < FFT_LEN; i++)
    fin[i].i = 0;
}


static void configure_interrupts ()
{
  audio_init (audio_isr);

  pushbuttons_enable_interrupts (pushbuttons_isr);
  pushbuttons_set_interrupt_mask (BUTTON1 | BUTTON2 | BUTTON3);

  // alt_irq_register (BELFFT_0_IRQ, NULL, (alt_isr_func) fft_isr);
}

static void configure_lcd ()
{
  lcd_enable_dma (true);
  lcd_draw_rectangle (0, 0, LCD_RES_X, LCD_RES_Y, BLACK);
}

/**
 * Function: run
 * -------------
 */
void run (void)
{
  while(1)
    {
      fft ();
      draw_fft ();
    }
}

int fft ()
{
  int i, j;

  for (i = 0; i < FFT_LEN; i++)
    fin[i].r = left_buffer[i] / 10;

  kiss_fft (fft_cfg, fin, fout);

  for (i = 0; i < FFT_LEN / 2; i++)
    {
      power_spectrum[i] = sqrt(fout[i].r*fout[i].r + fout[i].i*fout[i].i);
      power_history[current_power_history_index][i] = power_spectrum[i];

      // Blend in historical data for smoothing
      for (j = 0; j < AVERAGING_LENGTH; j++)
        power_spectrum[i] += power_history[j][i];

      power_spectrum[i] = power_spectrum[i] / AVERAGING_LENGTH;
    }

  current_power_history_index = (current_power_history_index + 1) % AVERAGING_LENGTH;

  return 0;
}

void draw_fft ()
{
  lcd_draw_rectangle (0, 0, LCD_RES_X, LCD_RES_Y, BLACK);
  const size_t bar_width = 10;

  int i;
  for (i = 0; i < FFT_LEN / 2; i++)
    {
      int value = (int) (power_spectrum[i] / 0x100);
      lcd_draw_rectangle (bar_width * i, 0, bar_width, value, WHITE);
    }
}

int map (int value, int d0, int d1, int r0, int r1){
  return value * (r1 - r0) / (d1 - d0);
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
        power_spectrum[i] = sqrt(fout[i].r*fout[i].r + fout[i].i*fout[i].i);
    }


    return 0;
}

void fft_isr (void *context, unsigned int id)
{
  printf ("FFT complete!\n");
}
