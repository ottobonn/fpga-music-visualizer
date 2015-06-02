#include "string.h"
#include <altera_avalon_sgdma.h>
#include <altera_avalon_sgdma_descriptor.h>
#include <altera_avalon_sgdma_regs.h>
#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include "system.h"
#include "ethernet.h"

#include "stdio.h"

/******************
 ****  MACROS  ****
 ******************/
 
/* SGDMA control register bits masks. */
#define IE_DESCRIPTOR_COMPLETED  0x04
#define IE_GLOBAL                0x10



/********************************
 ****  GLOBALS DECLARATIONS  ****
 ********************************/
 
/* Allocate transmit and receive frame buffers in packet_memory (on-chip). */
static uint8_t rx_buff[ENET_FRAME_BUFF_SIZE]  __attribute__ ((section (".packet_memory")));
static uint8_t tx_buff[ENET_FRAME_BUFF_SIZE]  __attribute__ ((section (".packet_memory")));

/* For structuring the rx and tx buffers as ethernet frames. */
static struct ethernet_frame *rx_frame;
static struct ethernet_frame *tx_frame;

/* Allocate SGDMA descriptors in the descriptor_memory (on-chip). */
static alt_sgdma_descriptor rx_descriptor      __attribute__ ((section (".descriptor_memory")));
static alt_sgdma_descriptor rx_descriptor_end  __attribute__ ((section (".descriptor_memory")));
static alt_sgdma_descriptor tx_descriptor      __attribute__ ((section (".descriptor_memory")));
static alt_sgdma_descriptor tx_descriptor_end  __attribute__ ((section (".descriptor_memory")));

/* SGDMA transmit and receive devices. */
static alt_sgdma_dev * sgdma_rx_dev;
static alt_sgdma_dev * sgdma_tx_dev;

/* User-provided interrupt service routine for processing received frames. */
static void (*rx_isr)(void*, unsigned int);



/***************************************
 ****  PRIVATE FUNCTION PROTOTYPES  ****
 ***************************************/
 
static void init_sgdma (void);
static void init_device (uint8_t *src_mac);
static void ethernet_rx (void *context);



/***************************************
 ****  PUBLIC FUNCTION DEFINITIONS  ****
 ***************************************/
 
/**
 * This function initializes data transfer over ethernet by doing
 * the following: 
 *
 *  1. Initializing the ethernet device and scatter-gather DMA for 
 *     transferring frame data between the network and the rx/tx 
 *     buffers. 
 *
 *  2. Registering the user provided receive ISR so that it will be 
 *     called each time a new frame arrives in the rx buffer. 
 *
 *  3. Mapping ethernet_frame structures onto the the rx/tx buffers.
 */
void ethernet_init (void *src_mac, void *receive_isr)
{
  init_sgdma ();
  init_device (src_mac); 
  rx_isr = receive_isr;
  rx_frame = rx_buff + ENET_HEADER_WORD_ALIGNMENT_SIZE;
  tx_frame = tx_buff + ENET_HEADER_WORD_ALIGNMENT_SIZE;
}

/**
 * Gets the ethernet transmit frame structure. The user must ensure 
 * the frame's fields are all properly set before calling ethernet_tx(). 
 */
struct ethernet_frame *ethernet_get_tx_frame (void)
{
  return tx_frame;
}

/**
 * Gets the ethernet receive frame structure. The frames's fields will
 * be updated each time a new frame is received.
 */
struct ethernet_frame *ethernet_get_rx_frame (void)
{
  return rx_frame;
}

/**
 * Transmits the contents of the tx buffer as an ethernet frame. It is
 * assumed that the user has properly set all of the tx frame's fields 
 * prior to calling this function.
 */
void ethernet_tx (void)
{
  /* Get the frame data length in host byte order. */
  uint16_t length = ntohs (tx_frame->length);
  
  /* Create transmit SGDMA descriptor. */
  uint32_t total_size = ENET_FRAME_HEADER_SIZE + length;
  alt_avalon_sgdma_construct_mem_to_stream_desc(&tx_descriptor, &tx_descriptor_end, tx_buff, total_size, 0, 1, 1, 0);
  
  /* Set up non-blocking transfer of SGDMA transmit descriptor. */
  alt_avalon_sgdma_do_async_transfer (sgdma_tx_dev, &tx_descriptor);
  
  /* Wait until transmit descriptor transfer is complete. */
  while (alt_avalon_sgdma_check_descriptor_status(&tx_descriptor) != 0);
}

/**
 * Takes a uint16_t in host byte order and converts it to network 
 * byte order.
 */
uint16_t htons(uint16_t n)
{
  return ((n & 0xff) << 8) | ((n & 0xff00) >> 8);
}

/**
 * Takes a uint16_t in network byte order and converts it to host 
 * byte order.
 */
uint16_t ntohs(uint16_t n)
{
  return htons(n);
}

/**
 * Takes a uint32_t in host byte order and converts it to network 
 * byte order.
 */
uint32_t htonl (uint32_t n)
{
  return ((n & 0xff        ) << 24) |
         ((n & 0xff00      ) <<  8) |
         ((n & 0xff0000UL  ) >>  8) |
         ((n & 0xff000000UL) >> 24);
}

/**
 * Takes a uint32_t in network byte order and converts it to host 
 * byte order.
 */
uint32_t ntohl (uint32_t n)
{
  return htonl(n);
}

/**
 *
 *
 */
static void ethernet_rx (void *context)
{
  /* Wait until receive descriptor transfer is complete. */
  while (alt_avalon_sgdma_check_descriptor_status(&rx_descriptor) != 0);
  
  /* Process frame with user-specified interrupt service routine. */
  rx_isr (NULL, SGDMA_RX_IRQ);
  
  /* Create SGDMA receive descriptor */
  alt_avalon_sgdma_construct_stream_to_mem_desc(&rx_descriptor, &rx_descriptor_end, rx_buff, 0, 0);
  
  /* Set up non-blocking transfer of SGDMA receive descriptor */
  alt_avalon_sgdma_do_async_transfer(sgdma_rx_dev, &rx_descriptor);
}

/**
 *
 *
 */
static void init_sgdma (void)
{
  /* Open the SGDMA transmit device. */
  sgdma_tx_dev = alt_avalon_sgdma_open(SGDMA_TX_NAME);
  if (sgdma_tx_dev == NULL) {
    alt_printf ("Error: could not open scatter-gather DMA transmit device\n");
    return;
  } 
  else alt_printf("Opened scatter-gather DMA transmit device\n");
  
  /* Open the SGDMA receive device. */
  sgdma_rx_dev = alt_avalon_sgdma_open (SGDMA_RX_NAME);
  if (sgdma_rx_dev == NULL) {
    alt_printf ("Error: could not open scatter-gather DMA receive device\n");
    return;
  } 
  else alt_printf("Opened scatter-gather DMA receive device\n");
  
  /* Configure interrupts for the SGDMA receive device. */
  uint16_t chain_control = IE_DESCRIPTOR_COMPLETED | IE_GLOBAL;
  alt_avalon_sgdma_register_callback (sgdma_rx_dev, (alt_avalon_sgdma_callback) ethernet_rx, chain_control, NULL);
 
  /* Create SGDMA receive descriptor. */
  alt_avalon_sgdma_construct_stream_to_mem_desc(&rx_descriptor, &rx_descriptor_end, rx_buff, 0, 0);
  
  /* Set up non-blocking transfer of first SGDMA receive descriptor. */
  alt_avalon_sgdma_do_async_transfer(sgdma_rx_dev, &rx_descriptor);
}

/**
 *
 *
 */
static void init_device (uint8_t *src_mac)
{
  /* Triple-speed ethernet device base address. */
  volatile int *enet = (int *) ENET_BASE;  
  
  /* Write the source MAC address. */ 
  *(enet + 3) = *(int *)  src_mac; 
  *(enet + 4) = *(int *) (src_mac + 4); 

  /* Specify the addresses of the PHY devices to be accessed through MDIO interface. */
  *(enet + 0x10) = 0x11;  // MDIO Address 1
  
  /* Write to register 16 of the PHY chip for ethernet port 1 to enable automatic crossover for all modes. */
  *(enet + 0xB0) = *(enet + 0xB0) | 0x0060;
  
  /* Write to register 20 of the PHY chip for ethernet port 1 to set up delay for input/output clk. */
  *(enet + 0xB4) = *(enet + 0xB4) | 0x0082;
  
  /* Enable line loopback with ethernet port 0. */
  *(enet + 0x0F) = 0x10; // MDIO Address 0
  *(enet + 0x94) = 0x4000; 
  
  /* Software reset the ethernet 1 PHY chip and wait. */
  *(enet + 0xA0) = *(enet + 0xA0) | 0x8000;
  while (*(enet + 0xA0) & 0x8000);   
   
  /* Set the command_config register fields. */
  // bit  0: tx enable
  // bit  1: rx enable
  // bit  3: gigabit ethernet enable
  // bit  4: promiscuous mode enable
  // bit  6: CRC forwarding on receive
  // bit 15: local loopback enable
  *(enet + 2) = *(enet + 2) | 0x0000004B;
}
