#ifndef __SWITCHES_H__
#define __SWITCHES_H__

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

/* Bit masks. */
#define SWITCH0   0x00001  
#define SWITCH1   0x00002
#define SWITCH2   0x00004
#define SWITCH3   0x00008
#define SWITCH4   0x00010
#define SWITCH5   0x00020
#define SWITCH6   0x00040
#define SWITCH7   0x00080
#define SWITCH8   0x00100
#define SWITCH9   0x00200
#define SWITCH10  0x00400
#define SWITCH11  0x00800
#define SWITCH12  0x01000
#define SWITCH13  0x02000
#define SWITCH14  0x04000
#define SWITCH15  0x08000
#define SWITCH16  0x10000
#define SWITCH17  0x20000

/* Public function prototypes. */
void switches_enable_interrupts (void *isr);
uint32_t switches_get_positions (void);
void switches_set_interrupt_mask (uint32_t mask);
uint32_t switches_get_interrupt_mask (void);
uint32_t switches_get_edge_capture (void);
void switches_clear_edge_capture (void);

#endif /* __SWITCHES_H__ */
