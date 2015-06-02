#ifndef __VGA_H__
#define __VGA_H__

#include <stdbool.h>
#include "system.h"


/******************
 ****  MACROS  ****
 ******************/

/* Default pixel buffer addresses. */
#define VGA_DEFAULT_FRONT_BUFF_BASE   SRAM_BASE
#define VGA_DEFAULT_BACK_BUFF_BASE   (SRAM_BASE + 0x80000)

/* VGA display resolution. */
#define VGA_RES_X  320
#define VGA_RES_Y  240

/* VGA character buffer resolution. */
#define VGA_CHAR_BUFF_RES_X  80
#define VGA_CHAR_BUFF_RES_Y  60


/**************************************
 ****  PUBLIC FUNCTION PROTOTYPES  ****
 **************************************/

/* VGA DMA Control */
void vga_enable_dma (bool enable);
void vga_set_front_buffer (int *buff);
void vga_set_back_buffer (int *buff);
void vga_swap_buffers (void);

/* VGA drawing functions */
// void vga_draw_rectangle (int x1, int y1, int x2, int y2, short color);
void vga_draw_rectangle(int x, int y, int width, int height, short color);

/* VGA character buffer */
void vga_write (int x, int y, char *text);
void vga_char_buffer_clear (void);

#endif /* __VGA_H__ */
