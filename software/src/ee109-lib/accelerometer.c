#include <stddef.h>
#include <stdint.h>
#include "accelerometer.h"

/* ADXl345 register addresses. */
#define DATAX0 0x32  // Low-order  byte of x-axis acceleration
#define DATAX1 0x33  // High-order byte of x-axis acceleration
#define DATAY0 0x34  // Low-order  byte of y-axis acceleration
#define DATAY1 0x35  // High-order byte of y-axis acceleration
#define DATAZ0 0x36  // Low-order  byte of z-axis acceleration
#define DATAZ1 0x37  // High-order byte of z-axis acceleration

/* Accelerometer controller registers. */
static volatile uint8_t *address_reg = (uint8_t*)  ACCELEROMETER_BASE;
static volatile uint8_t *data_reg    = (uint8_t*) (ACCELEROMETER_BASE + 1);


/**
 * Returns the current x-axis acceleration value.
 */
int accelerometer_get_x (void)
{
  int16_t x;
  
  *address_reg = DATAX0;
  x = *data_reg;
  
  *address_reg = DATAX1;
  x |= *data_reg << 8;
  
  return x;
}

/**
 * Returns the current y-axis acceleration value.
 */
int accelerometer_get_y (void)
{
  int16_t y;
  
  *address_reg = DATAY0;
  y = *data_reg;
  
  *address_reg = DATAY1;
  y |= *data_reg << 8;
  
  return y;
}

/**
 * Returns the current z-axis acceleration value.
 */
int accelerometer_get_z (void)
{
  int16_t z;
  
  *address_reg = DATAZ0;
  z = *data_reg;
  
  *address_reg = DATAZ1;
  z |= *data_reg << 8;
  
  return z;
}
