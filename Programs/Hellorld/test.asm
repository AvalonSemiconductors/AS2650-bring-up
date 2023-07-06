mem_start equ 6144

PSL_CC1          equ 0b10000000
PSL_CC0          equ 0b01000000
PSL_IDC          equ 0b00100000
PSL_BANK         equ 0b00010000
PSL_WITH_CARRY   equ 0b00001000
PSL_OVERFLOW     equ 0b00000100
PSL_LOGICAL_COMP equ 0b00000010
PSL_CARRY_FLAG   equ 0b00000001

delay_len0 equ mem_start+40
delay_len1 equ mem_start+41
delay_len2 equ mem_start+42

M32_A1           equ mem_start+1
M32_A2           equ mem_start+2
M32_A3           equ mem_start+3
M32_A4           equ mem_start+4
M32_B1           equ mem_start+5
M32_B2           equ mem_start+6
M32_B3           equ mem_start+7
M32_B4           equ mem_start+8
M32_R1           equ mem_start+9
M32_R2           equ mem_start+10
M32_R3           equ mem_start+11
M32_R4           equ mem_start+12
M32_SIGN         equ mem_start+13
M32_UNSIGNED     equ mem_start+14
PSL_BACK1        equ mem_start+17
PSU_BACK1        equ mem_start+18
PSL_BACK2        equ mem_start+19
PSU_BACK2        equ mem_start+20
M32_RB1          equ mem_start+21
M32_RB2          equ mem_start+22
M32_RB3          equ mem_start+23
M32_RB4          equ mem_start+24
M32_RB5          equ mem_start+25
M32_CTR          equ mem_start+26
M32_CTR2         equ mem_start+27
R0_BACK          equ mem_start+28
R1_BACK          equ mem_start+29
R2_BACK          equ mem_start+30
R3_BACK          equ mem_start+31
portb_state equ mem_start+100

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
	; De-select ALL 8-bit peripherals
	lodi,r0 0b11111001
	stra,r0 portb_state
	bsta,un portb_write
	
	lodi,r0 0x7A
	bsta,un print_hex
	lodi,r0 0x33
	bsta,un print_hex
	cpsl 1
	lodi,r0 0x33
	addi,r0 0x7A
	bsta,un print_hex
	lodi,r0 13
	bsta,un write_8251
	lodi,r0 10
	bsta,un write_8251
	
	bctr,un print_hellorld
hellorld_text:
	db "Hellorld!"
	db 13
	db 10
	db 0
print_hellorld:
	lodi,r2 255
print_hellorld_loop:
	loda,r0 hellorld_text,r2+
	bctr,eq print_hellorld_done
	bsta,un write_8251
	bctr,un print_hellorld_loop
print_hellorld_done:
	
loop:
	loda,r0 portb_state
	eori,r0 4
	stra,r0 portb_state
	bsta,un portb_write

	ppsu 64
	lodi,r0 210
	stra,r0 delay_len0
	stra,r0 delay_len1
	stra,r0 delay_len2
	bsta,un delay

	loda,r0 portb_state
	eori,r0 4
	stra,r0 portb_state
	bsta,un portb_write

	cpsu 64
	lodi,r0 250
	stra,r0 delay_len0
	stra,r0 delay_len1
	stra,r0 delay_len2
	bsta,un delay
	
	bcta,un loop
	
delay:
	loda,r1 delay_len0
delay_loop1:
	loda,r2 delay_len1
delay_loop2:
	loda,r3 delay_len2
delay_loop3:
	bdrr,r3 delay_loop3
	bdrr,r2 delay_loop2
	bdrr,r1 delay_loop1
	
	retc,un
	
hex_chars:
	db "0123456789ABCDEF"
hex_a_back:
	db 0
print_hex:
	stra,r0 hex_a_back
	rrr,r0
	rrr,r0
	rrr,r0
	rrr,r0
	andi,r0 15
	loda,r0 hex_chars,r0
	bsta,un write_8251
	loda,r0 hex_a_back
	andi,r0 15
	loda,r0 hex_chars,r0
	bsta,un write_8251
	loda,r0 hex_a_back
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

delay_8251:
	loda,r0 5
delay_8251_loop:
	bdrr,r0 delay_8251_loop
	retc,un

uart_delay_loop_readval:
	db 0
write_8251_backs:
	db 0
	db 0
	db 0
write_8251:
	stra,r1 write_8251_backs
	stra,r2 write_8251_backs+1
	stra,r3 write_8251_backs+2
	xchg
	
	; Wait for TX complete
	; Put in command mode and prepare for reads
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
	loda,r1 write_8251_backs
	loda,r2 write_8251_backs+1
	loda,r3 write_8251_backs+2
	retc,un
