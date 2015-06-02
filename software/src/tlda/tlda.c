#include "tlda.h"
#include "system.h"

/* LDA Circuit registers */
volatile unsigned int *dl_status = 	    (unsigned int *) TLDA_PERIPHERAL_0_BASE; // line status: 1 = complete, 0 = in progress
volatile unsigned int *dl_go =     	    (unsigned int *) (TLDA_PERIPHERAL_0_BASE + 4);	// line start trigger
volatile unsigned int *dl_xy0 =    	    (unsigned int *) (TLDA_PERIPHERAL_0_BASE + 8);	// starting point
volatile unsigned int *dl_xy1 =    	    (unsigned int *) (TLDA_PERIPHERAL_0_BASE + 12);	// end point
volatile unsigned int *dl_color =  	    (unsigned int *) (TLDA_PERIPHERAL_0_BASE + 16);	// color
volatile unsigned int *dl_thickness = 	(unsigned int *) (TLDA_PERIPHERAL_0_BASE + 20);

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
	*dl_go = 1;
	while(*dl_status != 1);
}
