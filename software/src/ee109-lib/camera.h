#ifndef __CAMERA_H__
#define __CAMERA_H__

#include <stdbool.h>

#define CAMERA_RES_X 400
#define CAMERA_RES_Y 240

void camera_enable_dma (bool enable);
void camera_set_front_buffer (int *buff);
void camera_set_back_buffer (int *buff);
void camera_swap_buffers(void);

#endif /* __CAMERA_H__ */
