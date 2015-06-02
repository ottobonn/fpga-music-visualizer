#ifndef __PUSHBUTTONS_H__
#define __PUSHBUTTONS_H__

#include <stddef.h>
#include <stdint.h>

/* Bit masks. */
#define BUTTON0  0x1
#define BUTTON1  0x2
#define BUTTON2  0x4
#define BUTTON3  0x8


/* Public function prototypes. */
void pushbuttons_enable_interrupts (void *isr);
uint32_t pushbuttons_get_data (void);
void pushbuttons_set_interrupt_mask (uint32_t mask);
uint32_t pushbuttons_get_interrupt_mask (void);
uint32_t pushbuttons_get_edge_capture (void);
void pushbuttons_clear_edge_capture (void);

#endif /* __PUSHBUTTONS_H__ */
