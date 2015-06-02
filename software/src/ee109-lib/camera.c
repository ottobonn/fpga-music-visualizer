#include "camera.h"
#include "system.h"

#define DMA_STATUS_ENABLE_MASK 0x00000004

// Pixel front buffer control register
static volatile int *front_buff_reg = (int*) CAMERA_DMA_CONTROLLER_BASE;
static volatile int *back_buff_reg = (int*) (CAMERA_DMA_CONTROLLER_BASE + 4);
static volatile int *resolution_reg = (int*) (CAMERA_DMA_CONTROLLER_BASE +  8);
static volatile int *status_reg = (int*) (CAMERA_DMA_CONTROLLER_BASE + 12);

// Camera configuration register
static volatile int *config = (int*) CAMERA_CONFIG_BASE;


void camera_set_front_buffer (int *buff)
{
  *back_buff_reg = buff;
  *front_buff_reg = 1;
}

void camera_set_back_buffer (int *buff)
{
  *back_buff_reg = buff;
}

void camera_enable_dma (bool enable)
{
  if (enable)
    *status_reg |= DMA_STATUS_ENABLE_MASK; 
  else
    *status_reg &= ~DMA_STATUS_ENABLE_MASK; 
}

void camera_swap_buffers(void)
{
	// Request a buffer swap
	*front_buff_reg = 1;
	
	// Wait for vertical synchronization.
	while ((*status_reg & 0x01) != 0);
}