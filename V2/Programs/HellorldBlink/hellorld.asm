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
UDR equ 133
SDR equ 134
	
	org 0
start:
	nop
	lodi,r0 0
	lpsl
	lodi,r0 32
	lpsu
	ppsu 64
	cpsu 64
	
	lodi,r0 255
	wrte,r0 DDRA
	wrte,r0 T0TOP_LO
	wrte,r0 T0TOP_HI
	lodi,r0 16
	wrte,r0 T0PRE_HI
	eorz,r0
	wrte,r0 T0PRE_LO

loop:
	wrte,r0 TCR
	rede,r0 T0CD_HI
	wrte,r0 PORTA
	nop
	nop
	nop
	nop
	bctr,un loop

halt:
	halt
	bctr,un halt
