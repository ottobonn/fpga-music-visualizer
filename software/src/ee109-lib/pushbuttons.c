#include <stddef.h>
#include "system.h"
#include "pushbuttons.h"
#include "sys/alt_irq.h"

#define DEFAULT_INTERRUPT_MASK 0xE

static volatile int *data_reg           = (int*)  PUSHBUTTONS_BASE;
static volatile int *interrupt_mask_reg = (int*) (PUSHBUTTONS_BASE +  8);
static volatile int *edge_capture_reg   = (int*) (PUSHBUTTONS_BASE + 12);


void pushbuttons_enable_interrupts (void *isr)
{
  pushbuttons_set_interrupt_mask (DEFAULT_INTERRUPT_MASK);
  alt_irq_register (PUSHBUTTONS_IRQ, NULL, isr);
}

uint32_t pushbuttons_get_data (void)
{
  return *data_reg;
}

void pushbuttons_set_interrupt_mask (uint32_t mask)
{
  *interrupt_mask_reg = mask;
}

uint32_t pushbuttons_get_interrupt_mask (void)
{
  return *interrupt_mask_reg;
}

uint32_t pushbuttons_get_edge_capture (void)
{
  return *edge_capture_reg;
}

void pushbuttons_clear_edge_capture (void)
{
  *edge_capture_reg = 1;
}
