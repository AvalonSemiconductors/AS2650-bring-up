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
	
	; DDRA all outputs, all low
	lodi,r0 $FF
	wrte,r0 DDRA
	clr r0
	wrte,r0 PORTA
	; Only PB0 (spiflash CSb) is output, and high by default
	lodi,r0 %00000001
	wrte,r0 DDRB
	wrte,r0 PORTB
	; Select UART special function on PORTA
	; Select no special functions on PORTB
	lodi,r0 %00000110
	wrte,r0 SPA
	clr r0
	wrte,r0 SPB
	
	; Init PWM generators
	lodi,r0 254
	wrte,r0 PW0
	wrte,r0 PW1
	wrte,r0 PW2
	
	; UART clock div to 115200 @ 50MHz
	lodi,r0 181
	wrte,r0 UDIV_LO
	lodi,r0 1
	wrte,r0 UDIV_HI
	; SPI clock div to 5 clocks
	lodi,r0 4
	wrte,r0 SDIV
	
	; Setup timer0 to overflow about twice a second @ 50MHz
	; Not actually used in this program
	lodi,r0 255
	wrte,r0 T0TOP_LO
	wrte,r0 T0TOP_HI
	lodi,r0 125
	wrte,r0 T0PRE_LO
	lodi,r0 1
	wrte,r0 T0PRE_HI
	clr r0
	wrte,r0 TS
	
loop:
	ppsu 64 ; Set flag high
	; Increment PORTA
	rede,r0 PORTA
	addi,r0 1
	wrte,r0 PORTA
	; Delay
	bsta,un long_del
	bsta,un long_del
	bsta,un long_del
	bsta,un long_del
	cpsu 64 ; Set flag low
	; Increment PORTA
	rede,r0 PORTA
	addi,r0 1
	wrte,r0 PORTA
	; Delay
	bsta,un long_del
	bsta,un long_del
	bsta,un long_del
	bsta,un long_del
	; Print message
	bsta,un print_text
	; Loop
	bctr,un loop

	; Sends a single character out through the UART. Waits for TX buffer to be empty first.
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

	; Subroutine to print a string
hellorld:
	db "Hello, World!",13,10,0
print_text:
	lodi,r1 255
print_loop:
	loda,r0 hellorld,r1+
	retc,0
	bstr,un putchar
	bctr,un print_loop

	; Just a really long time waster
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
