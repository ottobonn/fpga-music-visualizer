#include "system.h"
#include "green_leds.h"


static volatile int *data_reg = (int*) GREEN_LEDS_BASE;


void green_leds_set (uint32_t mask)
{
  *data_reg = mask;
}

void green_leds_update (uint32_t mask)
{
  *data_reg |= mask;
}

void green_leds_clear (uint32_t mask)
{
  *data_reg &= ~mask;
}

void green_leds_clear_all (void)
{
  *data_reg = 0;
}