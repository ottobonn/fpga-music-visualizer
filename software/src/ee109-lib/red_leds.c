#include "red_leds.h"
#include "system.h"


static volatile int *data_reg = (int*) RED_LEDS_BASE;


void red_leds_set (uint32_t mask)
{
  *data_reg = mask;
}

void red_leds_update (uint32_t mask)
{
  *data_reg |= mask;
}

void red_leds_clear (uint32_t mask)
{
  *data_reg &= ~mask;
}

void red_leds_clear_all (void)
{
  *data_reg = 0;
}
