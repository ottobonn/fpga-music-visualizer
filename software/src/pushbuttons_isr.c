#include "system_globals.h"
#include "ee109-lib/pushbuttons.h"

/**
 * Function: pushbuttons_isr
 * ------------------------------------------
 */
void pushbuttons_isr (void *context, unsigned int id)
{
  pushbuttons_clear_edge_capture ();
}
