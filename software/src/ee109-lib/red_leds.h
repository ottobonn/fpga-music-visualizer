#ifndef __RED_LEDS_H__
#define __RED_LEDS_H__

#include <stddef.h>
#include <stdint.h>


/* Bit masks. */ 
#define LEDR0   0x00001
#define LEDR1   0x00002
#define LEDR2   0x00004
#define LEDR3   0x00008
#define LEDR4   0x00010
#define LEDR5   0x00020
#define LEDR6   0x00040
#define LEDR7   0x00080
#define LEDR8   0x00100
#define LEDR9   0x00200
#define LEDR10  0x00400
#define LEDR11  0x00800
#define LEDR12  0x01000
#define LEDR13  0x02000
#define LEDR14  0x04000
#define LEDR15  0x08000
#define LEDR16  0x10000
#define LEDR17  0x20000
 
 
void red_leds_set (uint32_t state);
void red_leds_update (uint32_t mask);
void red_leds_clear (uint32_t mask);
void red_leds_clear_all (void);

#endif /* __RED_LEDS_H__ */
