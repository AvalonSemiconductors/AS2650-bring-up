/*
 *  Combined firmware for GFMPW multi-project and AS2650-2 on efabless dev board
 *  Auto-detects project ID
 *  If multi-project, reads mprj_io[37:36] and activates one of the four PSG designs
 *  0 = SID
 *  1 = SN76489
 *  2 = AY
 *  3 = TBB
 *  If AS2650-2, enables built-in RAM and bootstrap ROM before reset
 */

#include <defs.h>


// --------------------------------------------------------
// Firmware routines
// --------------------------------------------------------

//AS2650v2
#define reg_mprj_counter_as (*(volatile uint32_t*)0x30400000)
#define reg_mprj_debug_opts (*(volatile uint32_t*)0x30200000)
#define reg_mprj_rom_opts_1 (*(volatile uint32_t*)0x30100000)
#define reg_mprj_rom_opts_2 (*(volatile uint32_t*)0x30180000)

void configure_io_as2650() {
	reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_PULLUP;
    reg_mprj_io_1 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_2 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_3 = GPIO_MODE_MGMT_STD_INPUT_PULLUP;
    reg_mprj_io_4 = GPIO_MODE_USER_STD_INPUT_NOPULL;
	reg_mprj_io_5 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_6 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_7 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_8 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_9 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_10 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_11 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_12 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;
	reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_17 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_18 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_19 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_20 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_21 = GPIO_MODE_USER_STD_INPUT_PULLUP;
	reg_mprj_io_22 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_23 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_24 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_25 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_26 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_27 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_28 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_29 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_30 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_31 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_32 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_33 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_34 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_35 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_36 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_37 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
    // Initiate the serial transfer to configure IO
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);
	reg_mprj_datah = 0;
    reg_mprj_datal = 0;
}

void delay(const uint32_t d) {
	//reg_mprj_counter = 0;
	//uint32_t read = 0;
	//while(read < d) read = reg_mprj_counter;
    /* Configure timer for a single-shot countdown */
	reg_timer0_config = 0;
	reg_timer0_data = d;
    reg_timer0_config = 1;

    // Loop, waiting for value to reach zero
   reg_timer0_update = 1;  // latch current value
   while (reg_timer0_value > 0) {
           reg_timer0_update = 1;
   }
}

#define INTERNAL_RAM
#define debug_reg_base 0b000010000 //Normal IOD/IOC pins
//#define debug_reg_base 0b000010010 //Debug Carries
//#define debug_reg_base 0b000010001 //Debug Condition Code

#ifdef INTERNAL_RAM
#define debug_reg_base_actual (debug_reg_base | (1 << 8))
#else
#define debug_reg_base_actual (debug_reg_base)
#endif

void main() {
	int i, j, k;

    reg_gpio_mode1 = 1;
    reg_gpio_mode0 = 0;
    reg_gpio_ien = 1;
    reg_gpio_oeb = 0;

	reg_spictrl = (1 << 31) | (2 << 16); //Less wait states
    reg_uart_enable = 0;
    reg_wb_enable = 1;
    
    // Configure All LA probes as inputs to the cpu
	reg_la0_oenb = reg_la0_iena = 0x00000000;    // [31:0]
	reg_la1_oenb = reg_la1_iena = 0x00000000;    // [63:32]
	reg_la2_oenb = reg_la2_iena = 0x00000000;    // [95:64]
	reg_la3_oenb = reg_la3_iena = 0x00000000;    // [127:96]
	
	reg_gpio_out = 1;
	//AS2650v2
	reg_spi_enable = 0;
	reg_mprj_debug_opts = debug_reg_base_actual | (1 << 5); //Force design reset
	configure_io_as2650();
	reg_mprj_rom_opts_1 = 8184 << 16;
	reg_mprj_rom_opts_2 = (1 << 31); //Enable bootstrap ROM with PB0 used for spiflash CS
	reg_mprj_debug_opts = debug_reg_base_actual; //Release reset
	while(1) {
		reg_gpio_out = 1; // ON
		delay(2000000);
		//reg_gpio_out = 0;  // OFF
		//delay(28000000);
	}
}

