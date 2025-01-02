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

PSL_CC1          equ %10000000
PSL_CC0          equ %01000000
PSL_IDC          equ %00100000
PSL_BANK         equ %00010000
PSL_WITH_CARRY   equ %00001000
PSL_OVERFLOW     equ %00000100
PSL_LOGICAL_COMP equ %00000010
PSL_CARRY_FLAG   equ %00000001

DISP_WE equ 128
DISP_A0 equ 64

mem_start equ 2048

	org 0
programentry:
	clr r0
	lpsl
	lodi,r0 %01100000
	lpsu
	
	lodi,r0 $FF
	wrte,r0 DDRA
	lodi,r0 %11000001
	wrte,r0 DDRB
	lodi,r0 1
	wrte,r0 PORTB
	clr r0
	wrte,r0 SPA
	wrte,r0 SPB
	wrte,r0 TS
	
	lodi,r0 $FF
	wrte,r0 T2TOP_LO
	wrte,r0 T2TOP_HI
	lodi,r0 101
	wrte,r0 T2PRE_LO
	clr r0
	wrte,r0 T2PRE_HI
	lodi,r0 8
	wrte,r0 T0PRE_LO
	clr r0
	wrte,r0 T0PRE_HI
	lodi,r0 220
	wrte,r0 T0TOP_LO
	lodi,r0 5
	wrte,r0 T0TOP_HI
	bsta,un timer_del

	lodi,r0 $FF
	wrte,r0 PORTA
	rede,r0 PORTB
	andi,r0 $3F
	iori,r0 DISP_WE
	wrte,r0 PORTB
	bsta,un short_del
	eori,r0 DISP_WE
	wrte,r0 PORTB
	bsta,un short_del
	iori,r0 DISP_A0
	bsta,un short_del
	wrte,r0 PORTB
	iori,r0 DISP_WE
	wrte,r0 PORTB
	bsta,un short_del
	eori,r0 DISP_WE
	wrte,r0 PORTB
	bsta,un short_del
	bsta,un timer_del
	
	lodi,r1 itable>>8
	lodi,r0 itable&255
	svb
	lodi,r0 1
	wrte,r0 TS
	cpsu 32

	ppsl PSL_WITH_CARRY
loop:
	bsta,un timer_del
	bstr,un up_count
	bsta,un timer_del
	bstr,un up_count
	ppsu 64
	cpsl PSL_CARRY_FLAG
	lodi,r0 32
	adda,r0 LEDS
	stra,r0 LEDS
	bsta,un timer_del
	bstr,un up_count
	bsta,un timer_del
	bstr,un up_count
	cpsu 64
	bctr,un loop
count:
	db 0,0

up_count:
	cpsl PSL_CARRY_FLAG
	lodr,r2 count+1
	addi,r2 1
	strr,r2 count+1
	lodr,r2 count
	addi,r2 0
	strr,r2 count
	
	rrr,r2
	rrr,r2
	rrr,r2
	rrr,r2
	andi,r2 $0F
	loda,r0 BIN_TO_SEG,r2
	stra,r0 DIGITS
	lodr,r2 count
	andi,r2 $0F
	loda,r0 BIN_TO_SEG,r2
	stra,r0 DIGITS+1
	lodr,r2 count+1
	rrr,r2
	rrr,r2
	rrr,r2
	rrr,r2
	andi,r2 $0F
	loda,r0 BIN_TO_SEG,r2
	stra,r0 DIGITS+3
	lodi,r2 $0F
	andr,r2 count+1
	loda,r0 BIN_TO_SEG,r2
	stra,r0 DIGITS+2
	
	retc,un

timer_del:
	loda,r0 DIGITS+4
	eori,r0 1
	stra,r0 DIGITS+4
	clr r0
	wrte,r0 T2CD_LO
	wrte,r0 T2CD_HI
timer_del_loop:
	wrte,r0 TCR
	rede,r0 T2CD_HI
	comi,r0 31
	retc,gt
	bctr,un timer_del_loop

short_del:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	retc,un

trupt_backs:
	db 0,0,0,0
trupt:
	pshs
	strr,r0 trupt_backs
	strr,r1 trupt_backs+1
	strr,r2 trupt_backs+2
	strr,r3 trupt_backs+3
	lodi,r0 8+16+32
	wrte,r0 TS
	cpsl PSL_WITH_CARRY
	
	lodi,r0 255
	wrte,r0 PORTA
	rede,r0 PORTB
	andi,r0 $3F
	iori,r0 DISP_WE
	bsta,un short_del
	wrte,r0 PORTB
	bsta,un short_del
	eori,r0 DISP_WE
	wrte,r0 PORTB
	bsta,un short_del
	iori,r0 DISP_A0
	wrte,r0 PORTB
	loda,r1 LEDS
	andi,r1 $E0
	stra,r1 LEDS
	loda,r1 CURR_GRID
	eori,r1 $1F
	iora,r1 LEDS
	wrte,r1 PORTA
	iori,r0 DISP_WE
	bsta,un short_del
	wrte,r0 PORTB
	bsta,un short_del
	eori,r0 DISP_WE+DISP_A0
	wrte,r0 PORTB
	bsta,un short_del
	loda,r1 CURR_DIGIT
	loda,r0 DIGITS,r1
	eori,r0 255
	wrte,r0 PORTA
	rede,r0 PORTB
	iori,r0 DISP_WE
	bsta,un short_del
	wrte,r0 PORTB
	bsta,un short_del
	eori,r0 DISP_WE
	wrte,r0 PORTB
	
	loda,r0 CURR_GRID
	addz r0
	stra,r0 CURR_GRID
	addi,r1 1
	comi,r1 5
	bcfr,eq disp_not_repeat
	clr r1
	lodi,r0 1
	stra,r0 CURR_GRID
disp_not_repeat:
	stra,r1 CURR_DIGIT

	loda,r0 trupt_backs
	loda,r1 trupt_backs+1
	loda,r2 trupt_backs+2
	loda,r3 trupt_backs+3
	pops
	clrt
	rete,un

	align 16
itable:
	db 0,0
	db trupt>>8,trupt&255
	db 0,0
	db 0,0
	db trupt>>8,trupt&255
	db 0,0
	db 0,0
	db 0,0

variables:
	db 0
DIGITS:
	db 0,0,0,0,0
LEDS:
	db 128
CURR_GRID:
	db 1
CURR_DIGIT:
	db 0
BIN_TO_SEG:
	db %0111111
	db %0001010
	db %1010111
	db %1001111
	db %1101010
	db %1101101
	db %1111101
	db %0001011
	db %1111111
	db %1101111
	db %1111011
	db %1111100
	db %0110101
	db %1011110
	db %1110101
	db %1110001
