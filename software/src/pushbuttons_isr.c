#include "system_globals.h"
#include "ee109-lib/pushbuttons.h"

/**
 * Function: pushbuttons_isr
 * ------------------------------------------
 */
void pushbuttons_isr (void *context, unsigned int id)
{
  uint32_t edges = pushbuttons_get_edge_capture ();
  if (edges & BUTTON1)
    {
      toggle_hardware_rendering ();
    }
  pushbuttons_clear_edge_capture ();
}
