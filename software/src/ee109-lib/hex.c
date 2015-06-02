#include "hex.h"
#include "system.h"

static volatile int *hex_3to0 = (int *) HEX3_HEX0_BASE;
static volatile int *hex_7to4 = (int *) HEX7_HEX4_BASE;

/* Lookup table for active high segment encodings. */
static unsigned char table[16] = {0x3F, // 0
                                  0x06, // 1
                                  0x5B, // 2
                                  0x4F, // 3
                                  0x66, // 4
                                  0x6D, // 5
                                  0x7D, // 6
                                  0x07, // 7
                                  0x7F, // 8
                                  0x6F, // 9
                                  0x77, // A
                                  0x7C, // B
                                  0x39, // C
                                  0x5E, // D
                                  0x79, // E
                                  0x71};// F

/* Private function prototypes. */
static uint32_t lookup_10 (uint32_t value);
static uint32_t lookup_16 (uint32_t value);


void hex_write (uint32_t value, enum number_base base)
{
  /* Lookup hex segments for bits 15-0 of value. */
  switch (base)
  {
    case NUM_BASE_10: 
      *hex_3to0 = lookup_10 (value % 10000);
      *hex_7to4 = lookup_10 (value / 10000);
      break;
    case NUM_BASE_16:
      *hex_3to0 = lookup_16 (value & 0x0000FFFF);
      *hex_7to4 = lookup_16 (value >> 16);
      break;
  }
}

void hex_write_3to0 (uint32_t value, enum number_base base)
{
  /* Lookup hex segments for bits 15-0 of value. */
  switch (base)
  {
    case NUM_BASE_10: 
      *hex_3to0 = lookup_10 (value);
      break;
    case NUM_BASE_16:
      *hex_3to0 = lookup_16 (value);
      break;
  }
}

void hex_write_7to4 (uint32_t value, enum number_base base)
{
  /* Lookup hex segments for bits 15-0 of value. */
  switch (base)
  {
    case NUM_BASE_10: 
      *hex_7to4 = lookup_10 (value);
      break;
    case NUM_BASE_16:
      *hex_7to4 = lookup_16 (value);
      break;
  }
}


void hex_clear (void)
{
  *hex_3to0 = 0;
  *hex_7to4 = 0;
}

void hex_clear_3to0 (void)
{
  *hex_3to0 = 0;
}

void hex_clear_7to4 (void)
{
  *hex_7to4 = 0;
}



static uint32_t lookup_16 (uint32_t value)
{
  if (value > 0xFFFF) 
    value %= 0x10000;
    
  return (table[(value >>12) & 0xF] << 24 |  // lookup segments for nibble 3
          table[(value >> 8) & 0xF] << 16 |  // lookup segments for nibble 2 
          table[(value >> 4) & 0xF] <<  8 |  // lookup segments for nibble 1
          table[ value & 0xF      ]);        // lookup segments for nibble 0
}

static uint32_t lookup_10 (uint32_t value)
{
  if (value > 9999) 
    value %= 10000;
    
  return (table[ value / 1000       ] << 24 |  // lookup segments for thousands digit
          table[(value % 1000) / 100] << 16 |  // lookup segments for hundreds digit
          table[(value % 100)  /  10] <<  8 |  // lookup segments for tens digit
          table[ value % 10         ]);        // lookup segments for ones digit 
}
