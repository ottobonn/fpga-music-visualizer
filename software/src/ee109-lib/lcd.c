#include "lcd.h"
#include "system.h"

#define DMA_STATUS_ENABLE_MASK 0x00000004

/* DMA controller registers. */
static volatile int *front_buff_reg = (int*)  LCD_DMA_CONTROLLER_BASE;
static volatile int *back_buff_reg  = (int*) (LCD_DMA_CONTROLLER_BASE +  4);
static volatile int *resolution_reg = (int*) (LCD_DMA_CONTROLLER_BASE +  8);
static volatile int *status_reg     = (int*) (LCD_DMA_CONTROLLER_BASE + 12);

/* Character buffer registers. */
static volatile int *char_buff_ctrl = (int*) LCD_CHAR_BUFFER_AVALON_CHAR_CONTROL_SLAVE_BASE;
static volatile char *char_buff_base = (char*) LCD_CHAR_BUFFER_AVALON_CHAR_BUFFER_SLAVE_BASE;


/*****************************************************************************
 * Enables DMA transfer of video data from memory to LCD.                    *
******************************************************************************/
void lcd_enable_dma (bool enable)
{
  if (enable)
    *status_reg |= DMA_STATUS_ENABLE_MASK;
  else
    *status_reg &= ~DMA_STATUS_ENABLE_MASK;
}

/*****************************************************************************
 * Sets the front buffer base address.                                       *
******************************************************************************/
void lcd_set_front_buffer (int *buff)
{
  *back_buff_reg = buff;
  *front_buff_reg = 1;
}

/*****************************************************************************
 * Sets the back buffer base address.                                        *
******************************************************************************/
void lcd_set_back_buffer (int *buff)
{
  *back_buff_reg = buff;
}

/*****************************************************************************
 * Swaps the front and back buffer base addresses.                           *
******************************************************************************/
void lcd_swap_buffers(void)
{
	/* Request a buffer swap */
	*front_buff_reg = 1;

	/* Wait for vertical synchronization */
	while ((*status_reg & 0x01) != 0);
}

/*****************************************************************************
 * Send a string of text to the LCD using the character buffer.              *
******************************************************************************/
void lcd_write(int x, int y, char * text)
{
  int offset;

  int char_x = x * 8;
  int char_y = y * 8;

  /* assume that the text string fits on one line */
  offset = (y << 6) + x;
  while ( *(text) )
  {
    *(char_buff_base + offset) = *(text);  // write to the character buffer
    text++;
    offset++;
    char_x += 8;
  }
}

/*****************************************************************************
 * Draws a filled rectangle on the LCD.                                      *
******************************************************************************/
void lcd_draw_rectangle(int x, int y, int width, int height, short color)
{
  int i, j, offset;
  volatile short *pixel_buffer = (short *) (*front_buff_reg);

  for(i = x; i <= (x + width - 1); i++)
  {
    for(j = y; j <= (y + height -1); j++)
    {
      offset = (j << 9) + i;
      *(pixel_buffer + offset) = color;
    }
  }
}

void lcd_draw_rectangle_back(int x, int y, int width, int height, short color)
{
  int i, j, offset;
  volatile short *pixel_buffer = (short *) (*back_buff_reg);

  for(i = x; i <= (x + width - 1); i++)
  {
    for(j = y; j <= (y + height -1); j++)
    {
      offset = (j << 9) + i;
      *(pixel_buffer + offset) = color;
    }
  }
}

void lcd_char_buffer_clear (void)
{
  int char_x = 0;
  int char_y = 0;

  int i, j, offset;
  for (i = 0; i < LCD_CHAR_BUFF_RES_X; i++)
    for (j = 0; j < LCD_CHAR_BUFF_RES_Y; j++)
      {
        offset = (j << 6) + i;
        *(char_buff_base + offset) = ' ';  // write to the character buffer
      }
}

void *lcd_get_backbuffer_addr (void)
{
  return *back_buff_reg;
}
