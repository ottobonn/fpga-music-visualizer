#include <stddef.h>
#include <stdint.h>
#include "string.h"
#include "system_globals.h"
#include "ee109-lib/ethernet.h"
#include <stdio.h>

/* Defined in system_globals.c */
extern volatile struct ethernet_frame *rx_frame;


/**
 * Ethernet Receive Frame - Interrupt Service Routine
 *
 */
void ethernet_rx_isr (void *context, unsigned int id)
{
  /* Process data in ethernet receive frame. */
}
