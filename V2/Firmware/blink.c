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

//Multi-project
#define reg_mprj_counter_mp (*(volatile uint32_t*)0x30040000)
#define reg_mprj_proj_sel (*(volatile uint32_t*)0x30080000)
#define reg_mprj_settings (*(volatile uint32_t*)0x30020000)
#define reg_mprj_sram (*(volatile uint32_t*)0x30010000)

//AS2650v2
#define reg_mprj_counter_as (*(volatile uint32_t*)0x30400000)
#define reg_mprj_debug_opts (*(volatile uint32_t*)0x30200000)
#define reg_mprj_rom_opts_1 (*(volatile uint32_t*)0x30100000)
#define reg_mprj_rom_opts_2 (*(volatile uint32_t*)0x30180000)

#define SEL_SID 0
#define SEL_SN 1
#define SEL_AY 2
#define SEL_TBB 3

/*
int putchar(int c) {
	reg_uart_data = c;
	return c;
}

void puts(const char *s) {
	while(*s) {
		putchar(*s);
		s++;
	}
}

void puthex_nibble(unsigned char c) {
	if(c >= 10) putchar('A' + (c - 10));
	else putchar('0' + c);
}

void puthex(unsigned char c) {
	puthex_nibble(c >> 4);
	puthex_nibble(c & 15);
}

void puthex32(uint32_t a) {
	puthex(a >> 24);
	puthex(a >> 16);
	puthex(a >> 8);
	puthex(a);
}

void newl() {
	putchar('\r');
	putchar('\n');
}*/

void blank_io() {
	reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_PULLDOWN;
    reg_mprj_io_1 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_2 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
    reg_mprj_io_3 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
    reg_mprj_io_4 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
    reg_mprj_io_5 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_6 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_7 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_8 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_9 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_10 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_11 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_12 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_13 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_14 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_15 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_16 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_17 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_18 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_19 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_20 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_21 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_22 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_23 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_24 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_25 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_26 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_27 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_28 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_29 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_30 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_31 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_32 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_33 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_34 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_35 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_36 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_37 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);
    reg_mprj_datah = 0;
    reg_mprj_datal = 0;
}

void configure_io_as2650() {
	reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_PULLUP;
    reg_mprj_io_1 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_2 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
    reg_mprj_io_3 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
    reg_mprj_io_4 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
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
	reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_17 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_18 = GPIO_MODE_USER_STD_OUTPUT;
	reg_mprj_io_19 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_20 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
	reg_mprj_io_21 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
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

void configure_io(uint8_t sel, uint8_t uart_en) {

//  ======= Useful GPIO mode values =============

//      GPIO_MODE_MGMT_STD_INPUT_NOPULL
//      GPIO_MODE_MGMT_STD_INPUT_PULLDOWN
//      GPIO_MODE_MGMT_STD_INPUT_PULLUP
//      GPIO_MODE_MGMT_STD_OUTPUT
//      GPIO_MODE_MGMT_STD_BIDIRECTIONAL
//      GPIO_MODE_MGMT_STD_ANALOG

//      GPIO_MODE_USER_STD_INPUT_NOPULL
//      GPIO_MODE_USER_STD_INPUT_PULLDOWN
//      GPIO_MODE_USER_STD_INPUT_PULLUP
//      GPIO_MODE_USER_STD_OUTPUT
//      GPIO_MODE_USER_STD_BIDIRECTIONAL
//      GPIO_MODE_USER_STD_ANALOG

    reg_mprj_io_0 = GPIO_MODE_USER_STD_INPUT_PULLUP;

    // Changing configuration for IO[1-4] will interfere with programming flash. if you change them,
    // You may need to hold reset while powering up the board and initiating flash to keep the process
    // configuring these IO from their default values.

    reg_mprj_io_1 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_2 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
    reg_mprj_io_3 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
    reg_mprj_io_4 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;

    // -------------------------------------------

	if(sel == SEL_SID) {
		reg_mprj_io_5 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
		reg_mprj_io_6 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
		reg_mprj_io_7 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
		reg_mprj_io_8 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
		reg_mprj_io_9 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
		reg_mprj_io_10 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
		reg_mprj_io_11 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
		reg_mprj_io_12 = GPIO_MODE_USER_STD_BIDIRECTIONAL;
    }else {
		reg_mprj_io_5 = GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_6 = GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_7 = GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_8 = GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_9 = GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_10 = GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_11 = GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_12 = sel == SEL_TBB ? GPIO_MODE_MGMT_STD_INPUT_NOPULL : GPIO_MODE_USER_STD_INPUT_NOPULL;
		
		reg_mprj_io_13 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
		reg_mprj_io_14 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
		reg_mprj_io_15 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
		reg_mprj_io_16 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
		reg_mprj_io_17 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
		reg_mprj_io_18 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;
	}
	
	if(sel == SEL_SID) {
		reg_mprj_io_13 = GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_14 = GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_15 = GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_16 = GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_17 = GPIO_MODE_USER_STD_INPUT_NOPULL;
		reg_mprj_io_18 = GPIO_MODE_USER_STD_INPUT_NOPULL;
	}else if(sel == SEL_TBB) {
		reg_mprj_io_13 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_14 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_15 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_16 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_17 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_18 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
	}else {
		reg_mprj_io_13 = GPIO_MODE_USER_STD_OUTPUT;
		reg_mprj_io_14 = GPIO_MODE_USER_STD_OUTPUT;
		reg_mprj_io_15 = GPIO_MODE_USER_STD_OUTPUT;
		reg_mprj_io_16 = GPIO_MODE_USER_STD_OUTPUT;
		reg_mprj_io_17 = sel == SEL_SN ? GPIO_MODE_USER_STD_OUTPUT : GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_18 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
	}

    reg_mprj_io_19 = sel == SEL_TBB ? GPIO_MODE_MGMT_STD_INPUT_PULLDOWN : GPIO_MODE_USER_STD_INPUT_NOPULL;
    reg_mprj_io_20 = sel == SEL_SID || sel == SEL_AY ? GPIO_MODE_USER_STD_INPUT_NOPULL : GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_21 = sel == SEL_SID ? GPIO_MODE_USER_STD_INPUT_NOPULL : GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_22 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_26 = sel == SEL_SID ? GPIO_MODE_MGMT_STD_INPUT_PULLDOWN : GPIO_MODE_USER_STD_OUTPUT;
    
    if(sel == SEL_AY || sel == SEL_SN) {
		reg_mprj_io_27 = GPIO_MODE_USER_STD_OUTPUT;
		reg_mprj_io_28 = GPIO_MODE_USER_STD_OUTPUT;
		reg_mprj_io_29 = GPIO_MODE_USER_STD_OUTPUT;
		reg_mprj_io_30 = GPIO_MODE_USER_STD_OUTPUT;
		reg_mprj_io_31 = GPIO_MODE_USER_STD_OUTPUT;
		reg_mprj_io_32 = GPIO_MODE_USER_STD_OUTPUT;
	}else {
		reg_mprj_io_27 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_28 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_29 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_30 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_31 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
		reg_mprj_io_32 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
	}

    reg_mprj_io_33 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_34 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_35 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_36 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_37 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    
    if(uart_en) {
		reg_mprj_io_5 = GPIO_MODE_MGMT_STD_INPUT_NOPULL;     // UART Rx
		reg_mprj_io_6 = GPIO_MODE_MGMT_STD_OUTPUT;           // UART Tx
	}

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

void main()
{
	int i, j, k;

    reg_gpio_mode1 = 1;
    reg_gpio_mode0 = 0;
    reg_gpio_ien = 1;
    reg_gpio_oeb = 0;

	reg_spictrl = (1 << 31) | (2 << 16); //Less wait states
    reg_uart_enable = 0;
    reg_wb_enable = 1;
	
	if(reg_hkspi_user_id == 0x5EEC8018) {
		//AS2650v2
		uint32_t debug_reg_base;
		//debug_reg_base = 0b100101000; //Normal IOD/IOC pins
		//debug_reg_base = 0b100101010; //Debug Carries
		debug_reg_base = 0b100100001; //Debug Condition Code
		
		reg_mprj_debug_opts = debug_reg_base | (1 << 4); //Force design reset
		configure_io_as2650();
		reg_mprj_rom_opts_1 = 4095 << 16;
		reg_mprj_rom_opts_2 = (1 << 31); //Enable bootstrap ROM with PB0 used for spiflash CS
		reg_mprj_debug_opts = debug_reg_base; //Release reset control to mprj_io0
		while(1) {
			reg_gpio_out = 1; // OFF
			delay(10000000);
			reg_gpio_out = 0;  // ON
			delay(20000000);
		}
	}
	
	blank_io();
	uint32_t sel = (reg_mprj_datah >> 4) & 3;
    configure_io(sel, 0);

    // Configure All LA probes as inputs to the cpu
	reg_la0_oenb = reg_la0_iena = 0x00000000;    // [31:0]
	reg_la1_oenb = reg_la1_iena = 0x00000000;    // [63:32]
	reg_la2_oenb = reg_la2_iena = 0x00000000;    // [95:64]
	reg_la3_oenb = reg_la3_iena = 0x00000000;    // [127:96]

	switch(sel) {
		case SEL_SID:
			reg_mprj_proj_sel = 0b0001000;
			break;
		case SEL_SN:
			reg_mprj_proj_sel = 0b0001100;
			break;
		case SEL_AY:
			reg_mprj_proj_sel = 0b0011000;
			break;
		case SEL_TBB:
			reg_mprj_proj_sel = 0b0100000;
			break;
	}
	
	while(1) {
        reg_gpio_out = 1; // OFF
		delay(20000000);
        reg_gpio_out = 0;  // ON
		delay(20000000);
		//puthex32(reg_hkspi_user_id);
		//newl();
    }
}

