
module ee109_media_computer (
  // Inputs
  CLOCK_50,
//  TD_CLK27,
  KEY,
  SW,

  //  Communication
  UART_RXD,
  
  // Audio
  AUD_ADCDAT,
  
  //  D5M on HSMC
  HSMC_D5M_PIXEL_CLK,
  HSMC_D5M_CCD_DATA,
  HSMC_D5M_LVAL,
  HSMC_D5M_FVAL,
  HSMC_D5M_STROBE,
  
  // Accelerometer
  HSMC_G_SENSOR_INT1,
  
  // USB
  OTG_INT,

/*****************************************************************************/
  // Bidirectionals
  GPIO,

  // Memory (SRAM)
  SRAM_DQ,
  
  // Memory (SDRAM)
  DRAM_DQ,

  // PS2 Port
  PS2_KBCLK,
  PS2_KBDAT,
  PS2_MSCLK,
  PS2_MSDAT,
  
  // Audio
  AUD_BCLK,
  AUD_ADCLRCK,
  AUD_DACLRCK,
  
  // Char LCD 16x2
  LCD_DATA,

  // AV Config
  I2C_SDAT,
  
  //  D5M on HSMC
  HSMC_D5M_SDAT,
  
  //Accelerometer
  HSMC_G_SENSOR_SDAT,
  
  //USB
  OTG_DATA,
  
/*****************************************************************************/
  // Outputs
//  TD_RESET_N,
  
  //   Simple
  LEDG,
  LEDR,

  HEX0,
  HEX1,
  HEX2,
  HEX3,
  HEX4,
  HEX5,
  HEX6,
  HEX7,
  
  //   Memory (SRAM)
  SRAM_ADDR,

  SRAM_CE_N,
  SRAM_WE_N,
  SRAM_OE_N,
  SRAM_UB_N,
  SRAM_LB_N,
  
  //  Communication
  UART_TXD,
  
  // Memory (SDRAM)
  DRAM_ADDR,
  
  DRAM_BA,
  DRAM_CAS_N,
  DRAM_RAS_N,
  DRAM_CLK,
  DRAM_CKE,
  DRAM_CS_N,
  DRAM_WE_N,
  DRAM_DQM,
  
  // Audio
  AUD_XCK,
  AUD_DACDAT,
  
  // VGA
  VGA_CLK,
  VGA_HS,
  VGA_VS,
  VGA_BLANK_N,
  VGA_SYNC_N,
  VGA_R,
  VGA_G,
  VGA_B,

  // Char LCD 16x2
  LCD_ON,
  LCD_BLON,
  LCD_EN,
  LCD_RS,
  LCD_RW,
  
  // AV Config
  I2C_SCLK,

  // LCD
  HSMC_LCD_CLK,
  HSMC_LCD_DEN,
  HSMC_LCD_HS,
  HSMC_LCD_VS,
  HSMC_LCD_MODE,
  HSMC_LCD_SHLR,
  HSMC_LCD_UPDN,
  HSMC_LCD_DITH,
  HSMC_LCD_RSTB,
  HSMC_LCD_POWER_CTL,
  HSMC_LCD_DIM,
  HSMC_LCD_R,
  HSMC_LCD_G,
  HSMC_LCD_B,
  
  //  D5M on HSMC
  HSMC_D5M_XCLK,
  HSMC_D5M_RESET_N,
  HSMC_D5M_TRIGGER,
  HSMC_D5M_SCLK,
      
  // Accelerometer
  HSMC_G_SENSOR_SCLK,
  HSMC_G_SENSOR_ALT_ADDR_SEL,
  HSMC_G_SENSOR_CS_N,
  
  
  //IRDA
  IRDA_RXD,
  
  //SD Card
  SD_CMD,
  SD_DAT,
  SD_CLK,
    
  //Flash
  FL_ADDR,
  FL_CE_N,
  FL_OE_N,
  FL_WE_N,
  FL_RESET_N,
  FL_DQ,   
    
  //Video In
  TD_CLK27,  
  TD_DATA,   
  TD_HS,     
  TD_VS,     
  TD_RESET_N,
  
  // USB
  OTG_ADDR,
  OTG_CS_N,
  OTG_OE_N,
  OTG_RST_N,
  OTG_WE_N,
/*****************************************************************************/

  // Ethernet 0
  ENET0_MDC,
  ENET0_MDIO,
  ENET0_RESET_N,
  
  // Ethernet 1
  ENET1_GTX_CLK,
  ENET1_MDC,
  ENET1_MDIO,
  ENET1_RESET_N,
  ENET1_RX_CLK,
  ENET1_RX_DATA,
  ENET1_RX_DV,
  ENET1_TX_DATA,
  ENET1_TX_EN
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input        CLOCK_50;
input    [ 3: 0]  KEY;
input    [17: 0]  SW;


//  Communication
input        UART_RXD;

//  Audio
input        AUD_ADCDAT;

//  D5M on HSMC
input           HSMC_D5M_PIXEL_CLK;
input  [11:  0] HSMC_D5M_CCD_DATA;
input           HSMC_D5M_LVAL;
input           HSMC_D5M_FVAL;
input           HSMC_D5M_STROBE;

//  Accelerometer
input           HSMC_G_SENSOR_INT1;

// IrDA
input           IRDA_RXD;

//  Video In
input           TD_CLK27;
input  [ 7: 0]  TD_DATA;   
input           TD_HS;  
input           TD_VS; 

// USB
input  [ 1: 0]  OTG_INT;

// Bidirectionals
inout  [35: 0]  GPIO;

//   Memory (SRAM)
inout  [15: 0]  SRAM_DQ;

//  Memory (SDRAM)
inout  [31: 0]  DRAM_DQ;

/* PS2 Port. */
inout           PS2_KBCLK;
inout           PS2_KBDAT;
inout           PS2_MSCLK;
inout           PS2_MSDAT;

/* Audio. */
inout           AUD_BCLK;
inout           AUD_ADCLRCK;
inout           AUD_DACLRCK;

/* AV Config. */
inout           I2C_SDAT;
  
/* Flash. */
inout  [ 7: 0]  FL_DQ;

//  Char LCD 16x2
inout  [ 7: 0]  LCD_DATA;

//  D5M on HSMC
inout           HSMC_D5M_SDAT;

// Accelerometer
inout           HSMC_G_SENSOR_SDAT;

//  SD Card
inout           SD_CMD;
inout  [ 3: 0]  SD_DAT;

// USB
inout  [15: 0]  OTG_DATA;

//   Simple
output  [ 8: 0]  LEDG;
output  [17: 0]  LEDR;

output  [ 6: 0]  HEX0;
output  [ 6: 0]  HEX1;
output  [ 6: 0]  HEX2;
output  [ 6: 0]  HEX3;
output  [ 6: 0]  HEX4;
output  [ 6: 0]  HEX5;
output  [ 6: 0]  HEX6;
output  [ 6: 0]  HEX7;

//   Memory (SRAM)
output    [19: 0]  SRAM_ADDR;

output        SRAM_CE_N;
output        SRAM_WE_N;
output        SRAM_OE_N;
output        SRAM_UB_N;
output        SRAM_LB_N;

//  Communication
output        UART_TXD;

//  Memory (SDRAM)
output    [12: 0]  DRAM_ADDR;

output    [ 1: 0]  DRAM_BA;
output        DRAM_CAS_N;
output        DRAM_RAS_N;
output        DRAM_CLK;
output        DRAM_CKE;
output        DRAM_CS_N;
output        DRAM_WE_N;
output    [ 3: 0]  DRAM_DQM;

//  Audio
output        AUD_XCK;
output        AUD_DACDAT;

//  VGA
output        VGA_CLK;
output        VGA_HS;
output        VGA_VS;
output        VGA_BLANK_N;
output        VGA_SYNC_N;
output    [ 7: 0]  VGA_R;
output    [ 7: 0]  VGA_G;
output    [ 7: 0]  VGA_B;

//  Char LCD 16x2
output        LCD_ON;
output        LCD_BLON;
output        LCD_EN;
output        LCD_RS;
output        LCD_RW;

//  AV Config
output        I2C_SCLK;

//  Accelerometer
output        HSMC_G_SENSOR_SCLK;
output        HSMC_G_SENSOR_ALT_ADDR_SEL;
output        HSMC_G_SENSOR_CS_N;
  
//  SD Card
output SD_CLK;

//  Flash
output [22:0] FL_ADDR;
output FL_CE_N;
output FL_OE_N;
output FL_WE_N;
output FL_RESET_N;
  
//  Video In  
output TD_RESET_N;

//  D5M on HSMC
output        HSMC_LCD_CLK;
output        HSMC_LCD_DEN;
output        HSMC_LCD_HS;
output        HSMC_LCD_VS;
output        HSMC_LCD_MODE;
output        HSMC_LCD_SHLR;
output        HSMC_LCD_UPDN;
output        HSMC_LCD_DITH;
output        HSMC_LCD_RSTB;
output        HSMC_LCD_POWER_CTL;
output        HSMC_LCD_DIM;
output    [ 7: 0]  HSMC_LCD_R;
output    [ 7: 0]  HSMC_LCD_G;
output    [ 7: 0]  HSMC_LCD_B;

//  D5M on HSMC
output        HSMC_D5M_XCLK;
output        HSMC_D5M_RESET_N;
output        HSMC_D5M_TRIGGER;
output        HSMC_D5M_SCLK;

//USB
output      [ 1: 0]  OTG_ADDR;
output        OTG_CS_N;
output        OTG_OE_N;
output        OTG_RST_N;
output        OTG_WE_N;

//Ethernet 0
output        ENET0_MDC;
inout         ENET0_MDIO;
output        ENET0_RESET_N;

// Ethernet 1
output        ENET1_GTX_CLK;
output        ENET1_MDC;
inout         ENET1_MDIO;
output        ENET1_RESET_N;
input         ENET1_RX_CLK;
input  [3: 0] ENET1_RX_DATA;
input         ENET1_RX_DV;
output [3: 0] ENET1_TX_DATA;
output        ENET1_TX_EN;


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire clk_50, clk_125, clk_25, clk_2p5, tx_clk;
wire enet_reset_n;
wire mdc, mdio_in, mdio_oen, mdio_out;
wire eth_mode, ena_10;

// Internal Registers

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/


/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

// Ethernet Assignments
assign mdio_in    = ENET1_MDIO;
assign ENET0_MDC  = mdc;
assign ENET1_MDC  = mdc;
assign ENET0_MDIO = mdio_oen ? 1'bz : mdio_out;
assign ENET1_MDIO = mdio_oen ? 1'bz : mdio_out;
assign ENET0_RESET_N = enet_reset_n;
assign ENET1_RESET_N = enet_reset_n;

// Output Assignments
//assign TD_RESET_N  = 1'b0;
assign GPIO[ 0]    = 1'bZ;
assign GPIO[ 2]    = 1'bZ;
assign GPIO[16]    = 1'bZ;
assign GPIO[18]    = 1'bZ;

assign HSMC_LCD_MODE    = 1'b0;
assign HSMC_LCD_SHLR    = 1'b1;
assign HSMC_LCD_UPDN    = 1'b0;
assign HSMC_LCD_DITH    = 1'b0;
assign HSMC_LCD_RSTB    = 1'b1;
assign HSMC_LCD_POWER_CTL  = 1'b1;
assign HSMC_LCD_DIM      = 1'b1;

assign HSMC_D5M_RESET_N    = 1'b1;
assign HSMC_D5M_TRIGGER    = 1'b1;

assign HSMC_G_SENSOR_ALT_ADDR_SEL = 1'b1;


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

// Ethernet Subsystem
enet_pll pll_inst (
  .areset  (~KEY[0]),
  .inclk0  (CLOCK_50),
  .c0    (clk_50),
  .c1    (clk_125),
  .c2    (clk_25),
  .c3    (clk_2p5),
  .locked  (enet_reset_n)
); 

assign tx_clk = eth_mode ? clk_125 :       // GbE Mode   = 125MHz clock
                ena_10   ? clk_2p5 :       // 10Mb Mode  = 2.5MHz clock
                           clk_25;         // 100Mb Mode = 25 MHz clock

enet_ddio_out ddio_out_inst(
  .datain_h(1'b1),
  .datain_l(1'b0),
  .outclock(tx_clk),
  .dataout(ENET1_GTX_CLK)
);

 

// NiosII System
nios_system NiosII (
  // 1) global signals:
  .clk                      (CLOCK_50),
  .clk_27                   (TD_CLK27),
  .reset_n                  (KEY[0]),
  .sys_clk                  (),
  .vga_clk                  (),
  .sdram_clk                (DRAM_CLK),
  .audio_clk                (AUD_XCK),

  // the_AV_Config
  .I2C_SDAT_to_and_from_the_AV_Config    (I2C_SDAT),
  .I2C_SCLK_from_the_AV_Config           (I2C_SCLK),
  
  // the_Audio
  .AUD_ADCDAT_to_the_Audio          (AUD_ADCDAT),
  .AUD_BCLK_to_the_Audio            (AUD_BCLK),
  .AUD_ADCLRCK_to_the_Audio         (AUD_ADCLRCK),
  .AUD_DACLRCK_to_the_Audio         (AUD_DACLRCK),
  .AUD_DACDAT_from_the_Audio        (AUD_DACDAT),

  // the_Char_LCD_16x2
  .LCD_DATA_to_and_from_the_Char_LCD_16x2  (LCD_DATA),
  .LCD_ON_from_the_Char_LCD_16x2           (LCD_ON),
  .LCD_BLON_from_the_Char_LCD_16x2         (LCD_BLON),
  .LCD_EN_from_the_Char_LCD_16x2           (LCD_EN),
  .LCD_RS_from_the_Char_LCD_16x2           (LCD_RS),
  .LCD_RW_from_the_Char_LCD_16x2           (LCD_RW),

  // the_Expansion_JP5
  .GPIO_to_and_from_the_Expansion_JP5    ({GPIO[35:19], GPIO[17], GPIO[15:3], GPIO[1]}),

  // the_Green_LEDs
  .LEDG_from_the_Green_LEDs        (LEDG),

  // the_HEX3_HEX0
  .HEX0_from_the_HEX3_HEX0        (HEX0),
  .HEX1_from_the_HEX3_HEX0        (HEX1),
  .HEX2_from_the_HEX3_HEX0        (HEX2),
  .HEX3_from_the_HEX3_HEX0        (HEX3),
  
  // the_HEX7_HEX4
  .HEX4_from_the_HEX7_HEX4        (HEX4),
  .HEX5_from_the_HEX7_HEX4        (HEX5),
  .HEX6_from_the_HEX7_HEX4        (HEX6),
  .HEX7_from_the_HEX7_HEX4        (HEX7),

  // the_PS2_Port
  .PS2_CLK_to_and_from_the_PS2_Port    (PS2_KBCLK),
  .PS2_DAT_to_and_from_the_PS2_Port    (PS2_KBDAT),
  
  // the_PS2_Port_Dual
  .PS2_CLK_to_and_from_the_PS2_Port_Dual  (PS2_MSCLK),
  .PS2_DAT_to_and_from_the_PS2_Port_Dual  (PS2_MSDAT),
  
  // the_Pushbuttons
  .KEY_to_the_Pushbuttons          ({KEY[3:1], 1'b1}),

  // the_Red_LEDs
  .LEDR_from_the_Red_LEDs          (LEDR),
  
  // the_SDRAM
  .zs_addr_from_the_SDRAM          (DRAM_ADDR),
  .zs_ba_from_the_SDRAM          (DRAM_BA),
  .zs_cas_n_from_the_SDRAM        (DRAM_CAS_N),
  .zs_cke_from_the_SDRAM          (DRAM_CKE),
  .zs_cs_n_from_the_SDRAM          (DRAM_CS_N),
  .zs_dq_to_and_from_the_SDRAM      (DRAM_DQ),
  .zs_dqm_from_the_SDRAM          (DRAM_DQM),
  .zs_ras_n_from_the_SDRAM        (DRAM_RAS_N),
  .zs_we_n_from_the_SDRAM          (DRAM_WE_N),
  
  // the_SRAM
  .SRAM_DQ_to_and_from_the_SRAM      (SRAM_DQ),
  .SRAM_ADDR_from_the_SRAM           (SRAM_ADDR),
  .SRAM_LB_N_from_the_SRAM           (SRAM_LB_N),
  .SRAM_UB_N_from_the_SRAM           (SRAM_UB_N),
  .SRAM_CE_N_from_the_SRAM           (SRAM_CE_N),
  .SRAM_OE_N_from_the_SRAM           (SRAM_OE_N),
  .SRAM_WE_N_from_the_SRAM           (SRAM_WE_N),

  // the_Serial_port
  .UART_RXD_to_the_Serial_Port        (UART_RXD),
  .UART_TXD_from_the_Serial_Port      (UART_TXD),
  
  // the_Slider_switches
  .Slider_Switches_external_interface_export        (SW),

  // the_VGA_Controller
  .vga_controller_external_interface_CLK    (VGA_CLK),
  .vga_controller_external_interface_HS     (VGA_HS),
  .vga_controller_external_interface_VS     (VGA_VS),
  .vga_controller_external_interface_BLANK  (VGA_BLANK_N),
  .vga_controller_external_interface_SYNC   (VGA_SYNC_N),
  .vga_controller_external_interface_R      (VGA_R),
  .vga_controller_external_interface_G      (VGA_G),
  .vga_controller_external_interface_B      (VGA_B),
  
  // IRDA
// .irda_TXD                                  (IRDA_TXD),
   .irda_RXD                                  (IRDA_RXD),
  
  //SD Card
   .sdcard_b_SD_cmd                           (SD_CMD),
   .sdcard_b_SD_dat                           (SD_DAT[0]),
   .sdcard_b_SD_dat3                          (SD_DAT[3]),
   .sdcard_o_SD_clock                         (SD_CLK),
  
  //Flash
   .flash_ADDR                                (FL_ADDR),
   .flash_CE_N                                (FL_CE_N),
   .flash_OE_N                                (FL_OE_N),
   .flash_WE_N                                (FL_WE_N),
   .flash_RST_N                               (FL_RESET_N),
   .flash_DQ                                  (FL_DQ),   
  
  //Video In
   .video_in_TD_CLK27                         (TD_CLK27),  
   .video_in_TD_DATA                          (TD_DATA),   
   .video_in_TD_HS                            (TD_HS),     
   .video_in_TD_VS                            (TD_VS),     
   .video_in_TD_RESET                         (TD_RESET_N),  
   .video_in_clk27_reset            (!KEY[0]),
// .video_in_overflow_flag                    (<connected-to-video_in_overflow_flag>),
  
   //Ethernet 1
   .enet_pcs_mac_tx_clk            (tx_clk),       
   .enet_pcs_mac_rx_clk            (ENET1_RX_CLK),     
   .enet_mac_mdio_mdc                 (mdc),               
   .enet_mac_mdio_mdio_in               (mdio_in),           
   .enet_mac_mdio_mdio_out              (mdio_out),          
   .enet_mac_mdio_mdio_oen              (mdio_oen),          
   .enet_mac_rgmii_rgmii_in             (ENET1_RX_DATA),     
   .enet_mac_rgmii_rgmii_out            (ENET1_TX_DATA),     
   .enet_mac_rgmii_rx_control           (ENET1_RX_DV),      
   .enet_mac_rgmii_tx_control           (ENET1_TX_EN),      
   .enet_mac_status_eth_mode            (eth_mode),          
   .enet_mac_status_ena_10              (ena_10),   
  
/*  //Ethernet 0
   .ethernet_0_rgmii_in                       (<connected-to-ethernet_0_rgmii_in>),       
   .ethernet_0_rgmii_out                      (<connected-to-ethernet_0_rgmii_out>),       
   .ethernet_0_rx_control                     (<connected-to-ethernet_0_rx_control>),      
   .ethernet_0_tx_control                     (<connected-to-ethernet_0_tx_control>),      
   .ethernet_0_tx_clk                         (<connected-to-ethernet_0_tx_clk>),          
   .ethernet_0_rx_clk                         (<connected-to-ethernet_0_rx_clk>),         
   .ethernet_0_set_10                         (<connected-to-ethernet_0_set_10>),          
   .ethernet_0_set_1000                       (<connected-to-ethernet_0_set_1000>),          
   .ethernet_0_ena_10                         (<connected-to-ethernet_0_ena_10>),             
   .ethernet_0_eth_mode                       (<connected-to-ethernet_0_eth_mode>),            
   .ethernet_0_mdio_out                       (<connected-to-ethernet_0_mdio_out>),            
   .ethernet_0_mdio_oen                       (<connected-to-ethernet_0_mdio_oen>),                   
   .ethernet_0_mdio_in                        (<connected-to-ethernet_0_mdio_in>),                    
   .ethernet_0_mdc                            (<connected-to-ethernet_0_mdc>),
*/
   //5MP Camera Config  
   .camera_config_I2C_SDAT                    (HSMC_D5M_SDAT),            
   .camera_config_I2C_SCLK                    (HSMC_D5M_SCLK),             
   .camera_config_exposure                    (16'h0300),
  
  //5MP Camera Ports
   .camera_in_PIXEL_CLK                       (HSMC_D5M_PIXEL_CLK),
   .camera_in_LINE_VALID                      (HSMC_D5M_LVAL),
   .camera_in_FRAME_VALID                     (HSMC_D5M_FVAL),
   .camera_in_PIXEL_DATA                      (HSMC_D5M_CCD_DATA),
   .camera_in_pixel_clk_reset                 (!KEY[0]),
  
  //LCD Touchscreen
   .lcd_controller_external_interface_CLK     (HSMC_LCD_CLK),
   .lcd_controller_external_interface_HS      (HSMC_LCD_HS),
   .lcd_controller_external_interface_VS      (HSMC_LCD_VS),
// .lcd_controller_external_interface_DATA_EN (<connected-to-lcd_controller_external_interface_DATA_EN>),
   .lcd_controller_external_interface_R       (HSMC_LCD_R[7:0]),
   .lcd_controller_external_interface_G       (HSMC_LCD_G[7:0]),
   .lcd_controller_external_interface_B       (HSMC_LCD_B[7:0]),
  
  .vga_clk_out_clk_clk                        (HSMC_D5M_XCLK),
  
  .accelerometer_I2C_SDAT                     (HSMC_G_SENSOR_SDAT),
   .accelerometer_I2C_SCLK                    (HSMC_G_SENSOR_SCLK),
   .accelerometer_G_SENSOR_CS_N               (HSMC_G_SENSOR_CS_N),
   .accelerometer_G_SENSOR_INT                (HSMC_G_SENSOR_INT1),
  
  // the USB             
   .usb_INT1                               (OTG_INT[1]),
   .usb_DATA                               (OTG_DATA),
   .usb_RST_N                              (OTG_RST_N),
   .usb_ADDR                               (OTG_ADDR),
   .usb_CS_N                               (OTG_CS_N),
   .usb_RD_N                               (OTG_OE_N),
   .usb_WR_N                               (OTG_WE_N),
   .usb_INT0                               (OTG_INT[0]),
);

endmodule

