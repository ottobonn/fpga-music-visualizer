#ifndef __HEX_H__
#define __HEX_H__

#include <stddef.h>
#include <stdint.h>
#include "numbers.h"

void hex_write (uint32_t value, enum number_base base);
void hex_write_3to0 (uint32_t value, enum number_base base);
void hex_write_7to4 (uint32_t value, enum number_base base);
void hex_clear (void);
void hex_clear_3to0 (void);
void hex_clear_7to4 (void);


#endif /* __HEX_H__ */
