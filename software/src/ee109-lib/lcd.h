#ifndef __LCD_H__
#define __LCD_H__

#include <stdbool.h>
#include "system.h"


/******************
 ****  MACROS  ****
 ******************/

/* Default pixel buffer addresses. */
#define LCD_DEFAULT_FRONT_BUFF_BASE  (SRAM_BASE + 0x100000)
#define LCD_DEFAULT_BACK_BUFF_BASE   (SRAM_BASE + 0x180000)

/* LCD resolution. */
#define LCD_RES_X  400
#define LCD_RES_Y  240

/* LCD character buffer resolution. */
#define LCD_CHAR_BUFF_RES_X  50
#define LCD_CHAR_BUFF_RES_Y  30


/**************************************
 ****  PUBLIC FUNCTION PROTOTYPES  ****
 **************************************/

/* LCD DMA Control */
void lcd_enable_dma (bool enable);
void lcd_set_front_buffer (int *buff);
void lcd_set_back_buffer (int *buff);
void lcd_swap_buffers(void);

/* LCD drawing functions */
void lcd_draw_rectangle(int x, int y, int width, int height, short color);
void lcd_draw_rectangle_back(int x, int y, int width, int height, short color);
void *lcd_get_backbuffer_addr (void);

/* LCD character buffer */
void lcd_write(int x, int y, char *text);
void lcd_char_buffer_clear (void);

#endif /* __LCD_H__ */
