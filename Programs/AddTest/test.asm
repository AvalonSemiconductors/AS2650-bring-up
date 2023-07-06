mem_start equ 6144

delay_len0 equ mem_start+0
delay_len1 equ mem_start+1
delay_len2 equ mem_start+2

R0_BACK equ mem_start+3
R1_BACK equ mem_start+4
R2_BACK equ mem_start+5
R3_BACK equ mem_start+6
portb_state equ mem_start+7

counter0 equ mem_start+33
counter1 equ mem_start+34

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
	
	eorz,r0
	stra,r0 counter0
	stra,r0 counter1
	ppsl 8
test_loop:
	lodi,r0 '0'
	bsta,un write_8251
	lodi,r0 ' '
	bsta,un write_8251
	
	loda,r0 counter0
	bsta,un print_hex
	lodi,r0 ' '
	bsta,un write_8251
	loda,r0 counter1
	bsta,un print_hex
	lodi,r0 ' '
	bsta,un write_8251
	
	cpsl 1
	
	tpsl 1
	bcfr,eq nofix1
	loda,r0 counter1
	comi,r0 255
	bcfr,eq nofix1
	loda,r0 counter0
	bsta,un print_hex
	bctr,un fixed1
nofix1:
	loda,r0 counter0
	adda,r0 counter1
	bsta,un print_hex
fixed1:
	lodi,r0 ' '
	bsta,un write_8251
	cpsl 1

	tpsl 1
	bcfr,eq nofix2
	loda,r0 counter1
	comi,r0 255
	bcfr,eq nofix2
	loda,r0 counter0
	bctr,un fixed2
nofix2:
	loda,r0 counter0
	adda,r0 counter1
fixed2:
	
	spsl
	andi,r0 1
	bsta,un print_hex
	lodi,r0 13
	bsta,un write_8251
	lodi,r0 10
	bsta,un write_8251
	
	cpsl 1
	loda,r0 counter0
	addi,r0 1
	stra,r0 counter0
	loda,r0 counter1
	addi,r0 0
	stra,r0 counter1
	
	loda,r0 counter0
	iora,r0 counter1
	bcfa,eq test_loop
	
	eorz,r0
	stra,r0 counter0
	stra,r0 counter1
	ppsl 8
test_loop2:
	lodi,r0 '1'
	bsta,un write_8251
	lodi,r0 ' '
	bsta,un write_8251
	
	loda,r0 counter0
	bsta,un print_hex
	lodi,r0 ' '
	bsta,un write_8251
	loda,r0 counter1
	bsta,un print_hex
	lodi,r0 ' '
	bsta,un write_8251
	
	ppsl 1
	
	tpsl 1
	bcfr,eq nofix3
	loda,r0 counter1
	comi,r0 255
	bcfr,eq nofix3
	loda,r0 counter0
	bsta,un print_hex
	bctr,un fixed3
nofix3:
	loda,r0 counter0
	adda,r0 counter1
	bsta,un print_hex
fixed3:

	lodi,r0 ' '
	bsta,un write_8251
	ppsl 1

	tpsl 1
	bcfr,eq nofix4
	loda,r0 counter1
	comi,r0 255
	bcfr,eq nofix4
	loda,r0 counter0
	bctr,un fixed4
nofix4:
	loda,r0 counter0
	adda,r0 counter1
fixed4:
	
	spsl
	andi,r0 1
	bsta,un print_hex
	lodi,r0 13
	bsta,un write_8251
	lodi,r0 10
	bsta,un write_8251
	
	cpsl 1
	loda,r0 counter0
	addi,r0 1
	stra,r0 counter0
	loda,r0 counter1
	addi,r0 0
	stra,r0 counter1
	
	loda,r0 counter0
	iora,r0 counter1
	bcfa,eq test_loop2
	
loop:
	loda,r0 portb_state
	eori,r0 4
	stra,r0 portb_state
	bsta,un portb_write

	ppsu 64
	lodi,r0 2
	stra,r0 delay_len0
	stra,r0 delay_len1
	stra,r0 delay_len2
	bsta,un delay

	loda,r0 portb_state
	eori,r0 4
	stra,r0 portb_state
	bsta,un portb_write

	cpsu 64
	lodi,r0 4
	stra,r0 delay_len0
	stra,r0 delay_len1
	stra,r0 delay_len2
	bsta,un delay
	
	bcta,un loop
	
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
