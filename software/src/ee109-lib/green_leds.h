#ifndef __GREEN_LEDS_H__
#define __GREEN_LEDS_H__

#include <stddef.h>
#include <stdint.h>

/* Bit masks. */ 
#define LEDG0  0x001
#define LEDG1  0x002
#define LEDG2  0x004
#define LEDG3  0x008
#define LEDG4  0x010
#define LEDG5  0x020
#define LEDG6  0x040
#define LEDG7  0x080
#define LEDG8  0x100
 
/* Public Function Prototypes. */
void green_leds_set (uint32_t mask);
void green_leds_update (uint32_t mask);
void green_leds_clear (uint32_t mask);
void green_leds_clear_all (void);

#endif /* __GREEN_LEDS_H__ */
