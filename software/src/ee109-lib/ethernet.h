#ifndef __ENET_H__
#define __ENET_H__

#include <stddef.h>
#include <stdint.h>


/******************
 ****  MACROS  ****
 ******************/
#define ENET_FRAME_BUFF_SIZE             2048
#define ENET_FRAME_HEADER_SIZE           16
#define ENET_FRAME_DATA_OFFSET           ENET_FRAME_HEADER_SIZE
#define ENET_FRAME_DATA_SIZE             (ENET_FRAME_BUFF_SIZE - ENET_FRAME_HEADER_SIZE)
#define ENET_MAC_ADDR_SIZE               6
#define ENET_HEADER_WORD_ALIGNMENT_SIZE  2
#define ENET_HEADER_DEST_MAC_OFFSET      2
#define ENET_HEADER_SRC_MAC_OFFSET       8
#define ENET_HEADER_LENGTH_SIZE          2
#define ENET_HEADER_LENGTH_OFFSET        14


/***************************
 ****  DATA STRUCTURES  ****
 ***************************/
/* An Ethernet frame organized into its constituent fields. 
   Note that the NiosII uses Little Endian byte order while 
   network byte order is Big Endian. And so the user must be 
   careful to read/write the length field with the appropriate 
   byte order. */ 
struct ethernet_frame
{
  uint8_t dest[ENET_MAC_ADDR_SIZE];
  uint8_t src[ENET_MAC_ADDR_SIZE];
  uint16_t length;
  uint8_t data[ENET_FRAME_DATA_SIZE];
};


/**************************************
 ****  PUBLIC FUNCTION PROTOTYPES  ****
 **************************************/
void ethernet_init (void *src_mac, void *receive_isr);
struct ethernet_frame *ethernet_get_tx_frame (void);
struct ethernet_frame *ethernet_get_rx_frame (void);
void ethernet_tx (void);

/* Converting between byte orderings. */
uint16_t htons(uint16_t n);
uint16_t ntohs(uint16_t n);
uint32_t htonl(uint32_t n);
uint32_t ntohl(uint32_t n);

#endif /* __ENET_H__ */
