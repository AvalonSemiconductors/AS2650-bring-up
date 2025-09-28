; Needs to be clocked via a 40MHz crystal, or you can adjust the timer values below

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

mem_start equ 2048

line_counter equ mem_start+0
vsync equ mem_start+2
line_start equ mem_start+3
pixelValid equ mem_start+4

	org 0
programentry:
	clr r0
	lpsl
	lodi,r0 %01100000
	lpsu
	
	clr r0
	stra,r0 line_counter
	stra,r0 line_counter+1
	stra,r0 line_start
	stra,r0 mem_start+4
	iori,r0 1
	stra,r0 vsync
	lodi,r0 255
	stra,r0 pixelValid
	
	lodi,r0 $FC
	wrte,r0 DDRA
	clr r0
	wrte,r0 DDRB
	wrte,r0 PORTB
	wrte,r0 SPA
	wrte,r0 SPB
	wrte,r0 TS
	lodi,r0 2
	wrte,r0 PORTA
	
	; Adjust timing here!
	; fHSYNC = fCLK / (pre+1) / (top+1)
	lodi,r0 3
	wrte,r0 T0PRE_LO
	lodi,r0 0
	wrte,r0 T0PRE_HI
	lodi,r0 74
	wrte,r0 T0TOP_LO
	lodi,r0 3
	wrte,r0 T0TOP_HI
	
	lodi,r1 itable>>8
	lodi,r0 itable&255
	svb
	lodi,r0 1
	wrte,r0 TS
	cpsu 32
	
	ppsl PSL_WITH_CARRY+PSL_LOGICAL_COMP
loop:
	clr r0
	coma,r0 line_start
	bctr,eq loop
	stra,r0 line_start
	cpsl PSL_CARRY_FLAG
	lodi,r0 1
	adda,r0 line_counter
	stra,r0 line_counter
	clr r0
	adda,r0 line_counter+1
	stra,r0 line_counter+1
	
	loda,r0 pixelValid
	comi,r0 20
	bcfr,lt no_pixels
	lodi,r0 44
short_del_1:
	bdrr,r0 short_del_1
	; Pixel on
	rede,r0 DDRA
	iori,r0 2
	wrte,r0 DDRA
	lodi,r1 55
short_del_2:
	bdrr,r1 short_del_2
	; Pixel off
	eori,r0 2
	wrte,r0 DDRA
	; pixelValid++
	loda,r0 pixelValid
	cpsl PSL_CARRY_FLAG
	addi,r0 1
	stra,r0 pixelValid
no_pixels:
	
	loda,r3 line_counter+1
	bctr,eq not_over_256
	loda,r3 line_counter
	bctr,eq is_line_256
	lodi,r0 6
	comz,r3
	bctr,eq is_line_262
	
	bcta,un loop
not_over_256:
	loda,r3 line_counter
	lodi,r0 250
	comz,r3
	bctr,eq is_line_250
	lodi,r0 244
	comz,r3
	bctr,eq is_line_244
	lodi,r0 200
	comz,r3
	bctr,eq is_line_200

	bcta,un loop

is_line_262:
	clr r0
	stra,r0 line_counter
	stra,r0 line_counter+1
	bcta,un loop

is_line_256:
	clr r0
	stra,r0 vsync
	rede,r0 PORTA
	andi,r0 $F7
	wrte,r0 PORTA
	bcta,un loop

is_line_250:
	lodi,r0 1
	stra,r0 vsync
	rede,r0 PORTA
	iori,r0 8
	wrte,r0 PORTA
	bcta,un loop

is_line_244:
	bcta,un loop

is_line_200:
	eorz,r0
	stra,r0 pixelValid
	bcta,un loop

	align 256
trupt_backs:
	db 0,0,0,0
trupt:
	pshs
	strr,r0 trupt_backs
	;strr,r1 trupt_backs+1
	;strr,r2 trupt_backs+2
	;strr,r3 trupt_backs+3
	lodi,r0 8+16+32
	wrte,r0 TS
	;ppsl PSL_WITH_CARRY
	
	clr r0
	coma,r0 vsync
	bctr,eq vsync_no
vsync_yes:
	rede,r0 DDRA
	andi,r0 $FE
	wrte,r0 DDRA
	bsta,un hsync_del
	iori,r0 1
	wrte,r0 DDRA
	bctr,un vsync_cont
vsync_no:
	rede,r0 DDRA
	iori,r0 1
	wrte,r0 DDRA
	bsta,un hsync_del
	eori,r0 1
	wrte,r0 DDRA
vsync_cont:
	;bsta,un hsync_del
	lodi,r0 1
	stra,r0 line_start
	
	loda,r0 trupt_backs
	;loda,r1 trupt_backs+1
	;loda,r2 trupt_backs+2
	;loda,r3 trupt_backs+3
	pops
	;clrt
	rete,un

hsync_del:
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
	nop
	nop
	nop
	nop
	nop
	nop
	retc,un

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
