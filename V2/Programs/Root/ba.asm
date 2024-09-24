DDRA equ 0
DDRB equ 1
PORTA equ 2
PORTB equ 3
SPA equ 4
PINA equ 5
PINB equ 6
IRQC equ 7
SPB equ 8

TS equ 64
TCR equ 65
T0PRE_LO equ 66
T0PRE_HI equ 67
T1PRE_LO equ 68
T1PRE_HI equ 69
T2PRE_LO equ 70
T2PRE_HI equ 71
T0TOP_LO equ 72
T0TOP_HI equ 73
T1TOP_LO equ 74
T1TOP_HI equ 75
T2TOP_LO equ 76
T2TOP_HI equ 77
T0CD_LO equ 78
T0CD_HI equ 79
T1CD_LO equ 80
T1CD_HI equ 81
T2CD_LO equ 82
T2CD_HI equ 83

PW0 equ 84
PW1 equ 85
PW2 equ 86

UIE equ 128
UDIV_LO equ 129
UDIV_HI equ 130
STAT equ 131
SDIV equ 132
UTX equ STAT
STX equ 133
URX equ 134
SRX equ 135

jump_table equ 4
putchar equ jump_table+0
run_pgm equ jump_table+4
delay equ jump_table+8
lcd_clr equ jump_table+12
lcd_set_pixel equ jump_table+16
lcd_clr_pixel equ jump_table+20
lcd_inv_pixel equ jump_table+24
lcd_putchar equ jump_table+28
lcd_push_buff equ jump_table+32
puthex equ jump_table+36
newl equ jump_table+40

ba_data_start equ 3*8192
timer_trigger equ 33333
total_frames equ 6572

	org $6000
start:
	lodi,r0 8
	lpsl
	lodi,r0 32
	lpsu
	lodi,r0 0
	wrte,r0 SDIV
	ppsl 16
	lodi,r1 ba_data_start&255
	lodi,r2 (ba_data_start>>8)&255
	lodi,r3 ba_data_start>>16
	cpsl 16
	lodi,r0 9
	wrte,r0 T1PRE_LO
	clr r0
	wrte,r0 T1PRE_HI
	lodi,r0 255
	wrte,r0 T1TOP_LO
	wrte,r0 T1TOP_HI
	clr r0
	wrte,r0 T1CD_LO
	wrte,r0 T1CD_HI
	
ba_loop:
	wrte,r0 TCR
	rede,r1 T1CD_LO
	rede,r2 T1CD_HI
	ppsl 1
	subi,r1 timer_trigger&255
	subi,r2 timer_trigger>>8
	tpsl 1
	bcfr,0 ba_loop
	clr r0
	wrte,r0 T1CD_LO
	wrte,r0 T1CD_HI
	bstr,un next_frame
	cpsl 1
	lodi,r1 1
	clr r2
	addr,r1 frame_counter
	addr,r2 frame_counter+1
	strr,r1 frame_counter
	strr,r2 frame_counter+1
	ppsl 1
	subi,r1 total_frames&255
	subi,r2 total_frames>>8
	tpsl 1
	bcfr,0 ba_loop
	
halt:
	cpsu 64
	bctr,un halt

frame_counter:
	db 0,0

lcd_tx:
	rede,r3 PORTB
	andi,r3 $F7
	wrte,r3 PORTB
	wrte,r0 STX
lcd_tx_spi_wait:
	rede,r0 STAT
	andi,r0 3
	bcfr,0 lcd_tx_spi_wait
	iori,r3 8
	wrte,r3 PORTB
	retc,un

generic_spi_wait:
	rede,r0 STAT
	andi,r0 3
	retc,0
	bctr,un generic_spi_wait

next_frame:
	; Begin spiflash read
	rede,r1 PORTB
	andi,r1 $FE
	wrte,r1 PORTB
	lodi,r0 3
	wrte,r0 STX
	; ROM pos from r3',r2',r1'
	ppsl 16
	lodz r3
	nop
	nop
	nop
	wrte,r0 STX
	lodz r2
	nop
	nop
	nop
	nop
	nop
	wrte,r0 STX
	lodz r1
	nop
	nop
	nop
	nop
	nop
	wrte,r0 STX
	cpsl 16
	nop
	nop
	nop
	nop
	nop
	wrte,r3 STX
	nop
	nop
	nop
	nop
	nop
	
	clr r3
sid_loop:
	cpsl 1
	addi,r3 1
	rede,r0 SRX
	bctr,2 sid_loop_over
	wrte,r0 STX
	ppsl 1
	subi,r0 32
	cpsl 1
	addi,r0 192
	rede,r1 SRX
	cpsl 1
	addi,r3 1
	wrte,r0 STX
	; Address now in r0, value in r1
	strr,r0 self_mod+1
self_mod:
	wrte,r1 0
	bcta,un sid_loop
sid_loop_over:
	lodz r3
	ppsl 16
	cpsl 1
	addz r1
	addi,r2 0
	addi,r3 0
	strz r1
	cpsl 16
	
	clr r2
frame_loop_outer:
	rede,r1 PORTB
	iori,r1 $09
	wrte,r1 PORTB
	; Into command mode
	rede,r3 PORTA
	andi,r3 $FE
	wrte,r3 PORTA
	; Set page
	ppsl 1
	lodi,r0 7
	subz r2
	iori,r0 $B0
	bsta,un lcd_tx
	; Set column upper
	lodi,r0 $10
	bsta,un lcd_tx
	; Set column lower
	eorz,r0
	bsta,un lcd_tx
	; Into data mode
	rede,r3 PORTA
	iori,r3 1
	wrte,r3 PORTA
	; Begin spiflash read
	rede,r1 PORTB
	andi,r1 $FE
	wrte,r1 PORTB
	lodi,r0 3
	wrte,r0 STX
	; ROM pos from r3',r2',r1'
	ppsl 16
	lodz r3
	nop
	nop
	nop
	wrte,r0 STX
	lodz r2
	nop
	nop
	nop
	nop
	nop
	wrte,r0 STX
	lodz r1
	nop
	nop
	nop
	nop
	nop
	wrte,r0 STX
	cpsl 16
	nop
	nop
	nop
	nop
	nop
	wrte,r3 STX
	nop
	nop
	nop
	nop
	nop
	; Update screen rows, using funni trick where both the ROM and display are selected at the same time
	; Every SPI transfer receives the next byte from the ROM and sends the previous byte to the display
	rede,r3 PORTB
	andi,r3 $F7
	wrte,r3 PORTB
	lodi,r3 128
frame_loop_inner:
	rede,r1 SRX
	wrte,r1 STX
	bdrr,r3 frame_loop_inner
	; Add 128 to rom pos
	ppsl 16
	cpsl 1
	addi,r1 $80
	addi,r2 $00
	addi,r3 $00
	cpsl 16
	cpsl 1
	addi,r2 1
	comi,r2 8
	bcfa,eq frame_loop_outer
	; Deselect all
	rede,r1 PORTB
	iori,r1 $09
	wrte,r1 PORTB
	
	tpsu 64
	cpsu 64
	retc,eq
	ppsu 64
	retc,un
