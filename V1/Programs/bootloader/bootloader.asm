mem_start equ 6144

delay_len0 equ mem_start+0
delay_len1 equ mem_start+1
delay_len2 equ mem_start+2

R0_BACK equ mem_start+3
R1_BACK equ mem_start+4
R2_BACK equ mem_start+5
R3_BACK equ mem_start+6
portb_state equ mem_start+7
str_ptr_hi equ mem_start+8
str_ptr_lo equ mem_start+9

sel_rom equ 6
sel_lcd equ 5
sel_gpio equ 3
spi_idle equ 7

org 0
programentry:
	nop
	lodi,r0 0
	lpsl
	lodi,r0 32
	lpsu
	
	bsta,un spi_init
	bsta,un gpio_init
	; De-select ALL 8-bit peripherals
	lodi,r0 0b11111001
	stra,r0 portb_state
	bsta,un portb_write
	loda,r0 portb_state
	bsta,un portb_write
	
	; UART Init
	bsta,un init_8251
	
	lodi,r0 init_text>>8
	stra,r0 str_ptr_hi
	lodi,r0 init_text%256
	stra,r0 str_ptr_lo
	bsta,un puts
	
	loda,r0 portb_state
	iori,r0 2
	stra,r0 portb_state
	bsta,un portb_write

	lodi,r0 sel_rom
	wrtc,r0
	nop
	nop
	lodi,r0 0x90
	bsta,un spi_send
	eorz,r0
	bsta,un spi_send
	eorz,r0
	bsta,un spi_send
	eorz,r0
	bsta,un spi_send
	bsta,un spi_receive
	comi,r0 0xEF
	bctr,eq valid_rom
	comi,r0 0xC2
	bcfr,eq invalid_rom
	bsta,un spi_receive
	eori,r0 0x10
	bcfr,eq invalid_rom
	bctr,un valid_rom
invalid_rom:
	lodi,r0 spi_idle
	wrtc,r0
	nop
	nop
	lodi,r3 255
error_print_loop:
	loda,r0 invalid_rom_text,r3+
	bcta,eq error_loop
	bsta,un write_8251
	bctr,un error_print_loop
valid_rom:
	lodi,r0 spi_idle
	wrtc,r0
	nop
	lodi,r0 rom_title_text>>8
	stra,r0 str_ptr_hi
	lodi,r0 rom_title_text%256
	stra,r0 str_ptr_lo
	bsta,un puts
	
	lodi,r0 255
	stra,r0 delay_len0
rom_title_print_loop:
	lodi,r0 sel_rom
	wrtc,r0
	nop
	lodi,r0 0x03
	bsta,un spi_send
	eorz,r0
	bsta,un spi_send
	eorz,r0
	bsta,un spi_send
	loda,r0 delay_len0
	cpsl 1
	addi,r0 1
	stra,r0 delay_len0
	bsta,un spi_send
	bsta,un spi_receive
	lodi,r1 spi_idle
	wrtc,r1
	nop
	iorz,r0
	bctr,eq rom_title_print_loop_end
	bsta,un write_8251
	bctr,un rom_title_print_loop
rom_title_print_loop_end:
	lodi,r0 13
	bsta,un write_8251
	lodi,r0 10
	bsta,un write_8251
	
	lodi,r3 255
;	bctr,un copy_the_copy_loop
;hex_digits:
;	db "0123456789ABCDEF"
copy_the_copy_loop:
	loda,r0 copy_loop_start,r3+
	stra,r0 7936,r3
	
;	stra,r0 delay_len1
;	rrr,r0
;	rrr,r0
;	rrr,r0
;	rrr,r0
;	andi,r0 15
;	loda,r0 hex_digits,r0
;	bsta,un write_8251
;	loda,r0 delay_len1
;	andi,r0 15
;	loda,r0 hex_digits,r0
;	bsta,un write_8251
;	lodi,r0 ' '
;	bsta,un write_8251
	
	lodz,r3
	eori,r0 copy_loop_end-copy_loop_start
	bcfr,eq copy_the_copy_loop
	
	lodi,r0 booting_text>>8
	stra,r0 str_ptr_hi
	lodi,r0 booting_text%256
	stra,r0 str_ptr_lo
	bsta,un puts
	
	lodi,r0 sel_rom
	wrtc,r0
	nop
	lodi,r0 0x03
	bsta,un spi_send
	eorz,r0
	bsta,un spi_send
	eorz,r0
	bsta,un spi_send
	loda,r0 delay_len0
	cpsl 1
	addi,r0 1
	bsta,un spi_send
	
	bcta,un 7937
	
error_loop:
	cpsu 64
	lodi,r0 2
	stra,r0 delay_len0
	stra,r0 delay_len1
	stra,r0 delay_len2
	bsta,un delay
	loda,r0 portb_state
	eori,r0 4
	stra,r0 portb_state
	bsta,un portb_write
	bctr,un error_loop

delay:
	stra,r0 R0_BACK
	ppsl 8
delay_loop:
	cpsl 1
	loda,r0 delay_len0
	addi,r0 255
	stra,r0 delay_len0
	loda,r0 delay_len1
	addi,r0 255
	stra,r0 delay_len1
	loda,r0 delay_len2
	addi,r0 255
	stra,r0 delay_len2
	
	loda,r0 delay_len0
	iora,r0 delay_len1
	iora,r0 delay_len2
	bcfr,eq delay_loop
	
	loda,r0 R0_BACK
	retc,un

	; Send contents of r0 over SPI, ignoring serial in
spi_send:
	stra,r1 R1_BACK
	stra,r2 R2_BACK
	ppsl 8
	lodi,r1 0
	wrtd,r1
	nop
	lodi,r2 8
spi_send_loop:
	rrl,r0
	lodi,r1 0
	rrl,r1
	wrtd,r1
	nop
	iori,r1 2
	wrtd,r1
	nop
	eori,r1 2
	wrtd,r1
	nop
	bdrr,r2 spi_send_loop
	lodi,r1 0
	wrtd,r1
	nop
	loda,r1 R1_BACK
	loda,r2 R2_BACK
	retc,un
	
spi_init:
	; Init SPI bus
	lodi,r0 spi_idle
	wrtc,r0
	nop
	lodi,r0 sel_gpio
	wrtc,r0
	nop
	lodi,r0 spi_idle
	wrtc,r0
	nop
	
	lodi,r0 255
spi_init_delay_loop:
	nop
	bdrr,r0 spi_init_delay_loop
	
	retc,un
	
spi_receive:
	stra,r1 R1_BACK
	stra,r2 R2_BACK
	stra,r3 R3_BACK
	ppsl 8
	lodi,r0 0
	lodi,r1 0
	wrtd,r1
	nop
	lodi,r2 8
spi_receive_loop:
	iori,r1 2
	wrtd,r1
	nop
	
	redd,r3
	nop
	rrr,r3
	rrl,r0
	
	eori,r1 2
	wrtd,r1
	nop
	bdrr,r2 spi_receive_loop
	lodi,r1 0
	wrtd,r1
	nop
	loda,r1 R1_BACK
	loda,r2 R2_BACK
	loda,r3 R3_BACK
	retc,un
	
gpio_init:
	; Configure PORTB all outputs, PORTA all inputs for now
	lodi,r0 sel_gpio
	wrtc,r0
	nop
	nop
	lodi,r0 64
	bsta,un spi_send
	lodi,r0 0
	bsta,un spi_send
	lodi,r0 0xFF
	bsta,un spi_send
	lodi,r0 0
	bsta,un spi_send
	lodi,r0 spi_idle
	wrtc,r0
	nop
	nop
	retc,un
	
porta_inp:
	lodi,r0 sel_gpio
	wrtc,r0
	nop
	nop
	lodi,r0 64
	bsta,un spi_send
	lodi,r0 0
	bsta,un spi_send
	lodi,r0 0xFF
	bsta,un spi_send
	lodi,r0 spi_idle
	wrtc,r0
	nop
	nop
	retc,un
	
porta_outp:
	lodi,r0 sel_gpio
	wrtc,r0
	nop
	nop
	lodi,r0 64
	bsta,un spi_send
	lodi,r0 0
	bsta,un spi_send
	lodi,r0 0x00
	bsta,un spi_send
	lodi,r0 spi_idle
	wrtc,r0
	nop
	nop
	retc,un
	
porta_write:
	stra,r0 R0_BACK
	lodi,r0 sel_gpio
	wrtc,r0
	nop
	nop
	lodi,r0 64
	bsta,un spi_send
	lodi,r0 0x12
	bsta,un spi_send
	loda,r0 R0_BACK
	bsta,un spi_send
	lodi,r0 spi_idle
	wrtc,r0
	nop
	nop
	retc,un

porta_read:
	lodi,r0 sel_gpio
	wrtc,r0
	nop
	nop
	lodi,r0 65
	bsta,un spi_send
	lodi,r0 0x12
	bsta,un spi_send
	bsta,un spi_receive
	stra,r0 R0_BACK
	lodi,r0 spi_idle
	wrtc,r0
	nop
	nop
	loda,r0 R0_BACK
	retc,un
	
portb_write:
	stra,r0 R0_BACK
	lodi,r0 sel_gpio
	wrtc,r0
	nop
	nop
	lodi,r0 64
	bsta,un spi_send
	lodi,r0 0x13
	bsta,un spi_send
	loda,r0 R0_BACK
	bsta,un spi_send
	lodi,r0 spi_idle
	wrtc,r0
	nop
	nop
	retc,un
	
; UART stuffs
puts:
	ppsl 8
	loda,r0 *str_ptr_hi
	retc,eq
	bsta,un write_8251
	cpsl 1
	loda,r0 str_ptr_lo
	addi,r0 1
	stra,r0 str_ptr_lo
	loda,r0 str_ptr_hi
	addi,r0 0
	stra,r0 str_ptr_hi
	bctr,un puts+2
	
delay_8251:
	loda,r0 3
delay_8251_loop:
	bdrr,r0 delay_8251_loop
	retc,un

init_8251:
	; Select in command mode
	loda,r0 portb_state
	iori,r0 0b00011001
	andi,r0 0b11011111
	stra,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
	
	; Send three 0s followed by software reset ('worst case' initialization procedure according to datasheet)
	bsta,un porta_outp
	eorz,r0
	bsta,un porta_write
	bsta,un delay_8251
	lodi,r3 3
init_8251_zeroes_loop:
		loda,r0 portb_state
		andi,r0 0b11101111
		bsta,un portb_write
		bsta,un delay_8251
		loda,r0 portb_state
		bsta,un portb_write
		bsta,un delay_8251
	bdrr,r3 init_8251_zeroes_loop
	
	lodi,r0 0x40
	bsta,un porta_write
	bsta,un delay_8251
	loda,r0 portb_state
	andi,r0 0b11101111
	bsta,un portb_write
	bsta,un delay_8251
	loda,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
	loda,r0 portb_state
	iori,r0 32
	bsta,un portb_write
	lodi,r3 6
init_8251_reset_wait_loop:
	bsta,un delay_8251
	bdrr,r3 init_8251_reset_wait_loop
	loda,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
	
	; Send mode word
	lodi,r0 0b01001110 ; 1 stop bit, no parity, 8-bit, 16X baud rate divisor
	bsta,un porta_write
	bsta,un delay_8251
	loda,r0 portb_state
	andi,r0 0b11101111
	bsta,un portb_write
	bsta,un delay_8251
	loda,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
	
	; Send command word
	lodi,r0 0b00010011 ; Enable TX, but no RX
	bsta,un porta_write
	bsta,un delay_8251
	loda,r0 portb_state
	andi,r0 0b11101111
	bsta,un portb_write
	bsta,un delay_8251
	loda,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
	; Put in data mode & deselect
	loda,r0 portb_state
	andi,r0 254
	iori,r0 32
	stra,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
	bsta,un porta_inp
	retc,un
	
uart_delay_loop_readval:
	db 0
write_8251:
	stra,r1 R1_BACK
	xchg
	
	; Wait for TX complete
	; Put in data mode and prepare for reads
	bsta,un porta_inp
	loda,r0 portb_state
	iori,r0 0b00011001
	andi,r0 0b11011111
	stra,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
uart_delay_loop:
		loda,r0 portb_state
		andi,r0 0b11110111
		bsta,un portb_write
		bsta,un delay_8251
		bsta,un porta_read
		stra,r0 uart_delay_loop_readval
		loda,r0 portb_state
		bsta,un portb_write
		bsta,un delay_8251
		loda,r0 uart_delay_loop_readval
		andi,r0 4
	bctr,0 uart_delay_loop
	
	; Select in data mode
	loda,r0 portb_state
	iori,r0 0b00011000
	andi,r0 0b11011110
	stra,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
	
	; Send char
	bsta,un porta_outp
	xchg
	bsta,un porta_write
	bsta,un delay_8251
	loda,r0 portb_state
	andi,r0 0b11101111
	bsta,un portb_write
	bsta,un delay_8251
	loda,r0 portb_state
	bsta,un portb_write
	
	; Put in data mode & deselect
	loda,r0 portb_state
	andi,r0 254
	iori,r0 32
	stra,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
	bsta,un porta_inp
	loda,r1 R1_BACK
	retc,un
	
copy_loop_start:
	db 0
	ppsu 64
	ppsl 8
copy_loop:
	lodr,r0 copy_loop_ptr_lo
	andi,r0 128
	bctr,eq clr_a
	cpsu 64
	bctr,un clr_b
clr_a:
	ppsu 64
clr_b:
	
	lodi,r0 0
	lodi,r1 0
	wrtd,r1
	nop
	lodi,r2 8
copy_spi_receive_loop:
		iori,r1 2
		wrtd,r1
		nop
		
		redd,r3
		nop
		rrr,r3
		rrl,r0
		
		eori,r1 2
		wrtd,r1
		nop
	bdrr,r2 copy_spi_receive_loop
	
	strr,r0 *copy_loop_ptr_hi
	cpsl 1
	lodr,r0 copy_loop_ptr_lo
	addi,r0 1
	strr,r0 copy_loop_ptr_lo
	lodr,r0 copy_loop_ptr_hi
	addi,r0 0
	strr,r0 copy_loop_ptr_hi
	eori,r0 16
	bcfr,eq copy_loop
	lodi,r0 spi_idle
	wrtc,r0
	nop
	
	cpsu 64
	bcta,un 0

copy_loop_ptr_hi:
	db 0
copy_loop_ptr_lo:
	db 0
copy_loop_end:
	db 0
	
init_text:
	db 13
	db 10
	db "AS2650 BringUp Board Bootloader ready!"
	db 13
	db 10
	db 0
invalid_rom_text:
	db "FATAL: No supported boot ROM found on SPI bus!"
	db 13
	db 10
	db 0
rom_title_text:
	db "ROM Title: "
	db 0
booting_text:
	db "Loading..."
	db 13
	db 10
	db 0
