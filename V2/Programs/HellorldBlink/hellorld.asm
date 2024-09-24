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
	
	org 0
start:
	nop
	lodi,r0 0
	lpsl
	lodi,r0 32
	lpsu
	ppsu 64
	cpsu 64
	
	;bcta,un flag_blink
	
	lodi,r0 %01000011
	wrte,r0 DDRA
	eorz,r0
	wrte,r0 PORTA
	lodi,r0 %00001001
	wrte,r0 DDRB
	lodi,r0 %00001001
	wrte,r0 PORTB
	lodi,r0 %00000110 ;%01000110
	wrte,r0 SPA
	lodi,r0 %11110100
	wrte,r0 SPB
	eorz,r0
	wrte,r0 PW1
	
	lodi,r0 3
	wrte,r0 UDIV_LO
	lodi,r0 1
	wrte,r0 UDIV_HI
	lodi,r0 1
	wrte,r0 SDIV
	
	lodi,r0 255
	wrte,r0 T0TOP_LO
	wrte,r0 T1TOP_HI
	eorz,r0
	wrte,r0 T0PRE_HI
	wrte,r0 T0PRE_LO
	lodi,r0 %01000000
	wrte,r0 TS
	
	rede,r0 PORTA
	andi,r0 $FE
	wrte,r0 PORTA
	lodi,r3 255
lcd_init_loop:
	loda,r0 lcd_rst_seq,r3+
	bctr,0 lcd_init_done
	comi,r0 255
	bcfr,eq lcd_init_not_delay
	bsta,un lcd_delay
	bctr,un lcd_init_loop
lcd_init_not_delay:
	rede,r2 PORTB
	andi,r2 $F7
	wrte,r2 PORTB
	nop
	nop
	wrte,r0 STX
lcd_init_spi_wait:
	rede,r0 STAT
	andi,r0 3
	bcfr,0 lcd_init_spi_wait
	iori,r2 8
	wrte,r2 PORTB
	bctr,un lcd_init_loop
lcd_init_done:

	lodi,r0 255
	wrte,r0 T1TOP_LO
	wrte,r0 T1TOP_HI
	lodi,r0 16
	wrte,r0 T1PRE_HI
	eorz,r0
	wrte,r0 T1PRE_LO
loop:
	wrte,r0 TCR
	rede,r0 T1CD_HI
	wrte,r0 PORTA
	nop
	andi,r0 %00111111
	bstr,0 print_the_hellorld
	nop
	bctr,un loop

putchar_vars:
	db 0
putchar:
	strr,r0 putchar_vars
uart_wait_loop:
	rede,r0 STAT
	andi r0,3
	bcfr,0 uart_wait_loop
	lodr,r0 putchar_vars
	wrte,r0 UTX
	retc,un

hellorld:
	db "Hellorld!",13,10,0
print_the_hellorld:
	lodi,r1 255
hellorld_loop:
	loda,r0 hellorld,r1+
	bctr,0 hellorld_loop_over
	bstr,un putchar
	bctr,un hellorld_loop
hellorld_loop_over:
	retc,un

lcd_delay:
	nop
	lodi,r0 255
lcd_delay_loop_1:
	lodi,r1 255
lcd_delay_loop_2:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	bdrr,r1 lcd_delay_loop_2
	nop
	bdrr,r0 lcd_delay_loop_1
	nop
	retc,un

halt:
flag_blink:
	ppsu 64
	bstr,un long_del
	cpsu 64
	bstr,un long_del
	bstr,un long_del
	bstr,un long_del
	bstr,un long_del
	bstr,un long_del
	bstr,un long_del
	bctr,un flag_blink

long_del:
	lodi,r0 2
long_del_loop_1:
	nop
	lodi,r1 255
long_del_loop_2:
	nop
	lodi,r2 255
long_del_loop_3:
	nop
	nop
	nop
	nop
	nop
	bdrr,r2 long_del_loop_3
	nop
	bdrr,r1 long_del_loop_2
	nop
	bdrr,r0 long_del_loop_1
	nop
	retc,un

lcd_rst_seq: ;FF indicates delay required, 00 is end of sequence
	db $A2, $A0, $C0, $40, $2C, $FF, $2E, $FF, $2F, $FF, $26, $AF, $A4, $81, 19, $00
