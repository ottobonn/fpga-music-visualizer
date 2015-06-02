#ifndef  __ACCELEROMETER_H__
#define  __ACCELEROMETER_H__

#include "system.h"


/******************
 ****  MACROS  ****
 ******************/
 
#define ACCEL_MIN   127
#define ACCEL_MIN  -128


/**************************************
 ****  PUBLIC FUNCTION PROTOTYPES  ****
 **************************************/

int accelerometer_get_x (void);
int accelerometer_get_y (void);
int accelerometer_get_z (void);

#endif /*  __ACCELEROMETER_H__ */
