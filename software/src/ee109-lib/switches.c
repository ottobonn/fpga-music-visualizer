#include <stddef.h>
#include "system.h"
#include "switches.h"
#include "sys/alt_irq.h"

#define DEFAULT_INTERRUPT_MASK 0x3FFFF

static volatile int *data_reg           = (int*)  SLIDER_SWITCHES_BASE;
static volatile int *interrupt_mask_reg = (int*) (SLIDER_SWITCHES_BASE +  8);
static volatile int *edge_capture_reg   = (int*) (SLIDER_SWITCHES_BASE + 12);


void switches_enable_interrupts (void *isr)
{
  switches_set_interrupt_mask (DEFAULT_INTERRUPT_MASK);
  alt_irq_register (SLIDER_SWITCHES_IRQ, NULL, isr);
}

uint32_t switches_get_positions (void)
{
  return *data_reg;
}

void switches_set_interrupt_mask (uint32_t mask)
{
  *interrupt_mask_reg = mask;
}

uint32_t switches_get_interrupt_mask (void)
{
  return *interrupt_mask_reg;
}

uint32_t switches_get_edge_capture (void)
{
  return *edge_capture_reg;
}

void switches_clear_edge_capture (void)
{
  *edge_capture_reg = 1;
}
