#include "tlda.h"
#include "system.h"

/* LDA Circuit registers */
static volatile unsigned int *dl_status = 	    (unsigned int *) TLDA_PERIPHERAL_0_BASE; // line status: 1 = complete, 0 = in progress
static volatile unsigned int *dl_go =     	    (unsigned int *) (TLDA_PERIPHERAL_0_BASE + 4);	// line start trigger
static volatile unsigned int *dl_xy0 =    	    (unsigned int *) (TLDA_PERIPHERAL_0_BASE + 8);	// starting point
static volatile unsigned int *dl_xy1 =    	    (unsigned int *) (TLDA_PERIPHERAL_0_BASE + 12);	// end pointvolatile unsigned int *dl_xy1 =    	    (unsigned int *) (TLDA_PERIPHERAL_0_BASE + 12);	// end point
static volatile unsigned int *dl_color =  	    (unsigned int *) (TLDA_PERIPHERAL_0_BASE + 16);	// color
static volatile unsigned int *dl_thickness = 	(unsigned int *) (TLDA_PERIPHERAL_0_BASE + 20); // thickness
static volatile unsigned int *dl_base_addr = 	(unsigned int *) (TLDA_PERIPHERAL_0_BASE + 24); // base memory address
static void *drawing_buffer = 0x08000000;

/* Hardware drawline */
void tlda_draw (unsigned int x0,
                unsigned int y0,
                unsigned int x1,
                unsigned int y1,
                unsigned int color,
                unsigned int thickness)
{
	*dl_xy0 = (y0 << 9) + x0;
	*dl_xy1 = (y1 << 9) + x1;
	*dl_color = color;
	*dl_thickness = thickness;
  *dl_base_addr = drawing_buffer;
	*dl_go = 1;
	while(*dl_status != 1);
}

void tlda_set_drawing_buffer (void *buffer)
{
  drawing_buffer = buffer;
}
