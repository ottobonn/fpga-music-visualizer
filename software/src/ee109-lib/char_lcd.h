#ifndef __CHAR_LCD_H__
#define __CHAR_LCD_H__

//TODO: add #defines for dimensions of display and buffer

void char_lcd_move_cursor (int x, int y);
void char_lcd_write (char *text);
void char_lcd_cursor_off (void);
void char_lcd_shift_left (void);
void char_lcd_shift_right (void);

#endif /* __CHAR_LCD_H__ */