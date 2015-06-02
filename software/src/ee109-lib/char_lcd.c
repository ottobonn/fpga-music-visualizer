#include "system.h"
#include "char_lcd.h"

// 16x2 character display

// Instructions              
#define LCD_SET_CURSOR     0x80
#define LCD_SHIFT_LEFT     0x18
#define LCD_SHIFT_RIGHT    0x1C
#define LCD_CURSOR_OFF     0x0C
#define LCD_BLINK_ON       0x0F
#define LCD_CLEAR_DISPLAY  0x01

// Position
#define LCD_TOP_ROW        0x00
#define LCD_BOTTOM_ROW     0x40
#define LCD_X_MAX          0x27
#define LCD_Y_MAX          0x01


volatile char *instruction_ptr = (char *)  CHAR_LCD_16X2_BASE;	
volatile char *data_ptr        = (char *) (CHAR_LCD_16X2_BASE + 1);

/******************************************************************************
 * Moves the LCD cursor to the position specified by X and Y.
******************************************************************************/
void char_lcd_move_cursor (int x, int y)
{
  char address = 0;
  
  address |= (x < LCD_X_MAX) ? x : LCD_X_MAX;
  address |= (y == 0) ? LCD_TOP_ROW : LCD_BOTTOM_ROW;  
  
  // write to the LCD instruction register
  *(instruction_ptr) = LCD_SET_CURSOR | address;		
}

/******************************************************************************
 * Subroutine to send a string of text to the LCD 
******************************************************************************/
void char_lcd_write (char *text)
{
	while (*(text))
	{
		*(data_ptr) = *(text);	// write to the LCD data register
	  text++;
	}
}

/******************************************************************************
 * Subroutine to turn off the LCD cursor
******************************************************************************/
void char_lcd_cursor_off (void)
{
	*(instruction_ptr) = LCD_CURSOR_OFF;	 // turn off the LCD cursor
}

/******************************************************************************
 * Subroutine to shift the LCD cursor one pixel to the left.
******************************************************************************/
void char_lcd_shift_left (void)
{
	*(instruction_ptr) = LCD_SHIFT_LEFT;	 // shift display to the left
}

/******************************************************************************
 * Subroutine to shift the LCD cursor one pixel to the right.
******************************************************************************/
void char_lcd_shift_right (void)
{
	*(instruction_ptr) = LCD_SHIFT_RIGHT;	 // shift display to the right
}

