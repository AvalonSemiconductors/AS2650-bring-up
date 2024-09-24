; Mandelbrot set renderer!

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
M32_RB6          equ mem_start+26
M32_RB7          equ mem_start+27
M32_RB8          equ mem_start+28
M32_CTR          equ mem_start+29
M32_CTR2         equ mem_start+30
R0_BACK          equ mem_start+31
R1_BACK          equ mem_start+32
R2_BACK          equ mem_start+33
R3_BACK          equ mem_start+34
M32_TMP          equ mem_start+35

R0_BACK_U          equ mem_start+40
R1_BACK_U          equ mem_start+41
R2_BACK_U          equ mem_start+42
R3_BACK_U          equ mem_start+43
PSL_BACK_U         equ mem_start+44

sel_rom equ 6
sel_lcd equ 5
sel_gpio equ 3
spi_idle equ 7

; Mandel renderer vars
C1               equ mem_start+50
C2               equ mem_start+54
C3               equ mem_start+58
C4               equ mem_start+62
CURR_ROW         equ mem_start+66
CURR_COL         equ mem_start+67
C_IM             equ mem_start+68
C_RE             equ mem_start+72
MAN_X            equ mem_start+76
MAN_Y            equ mem_start+80
MAN_XX           equ mem_start+84
MAN_YY           equ mem_start+88
ITERATION        equ mem_start+92

; Pre-computed constants for w=238, h=48
M_WIDTH          equ 238
M_HEIGHT         equ 48
C1_PRE           equ 1101
C4_PRE           equ 2730
W_D2             equ 119
H_D2             equ 24

; Settings
;ZOOM             equ 436208
;RE               equ 2684355
;IMAG             equ 17456693
;MAX_ITER         equ 512
ZOOM equ 16000000
RE equ 0
IMAG equ 0
MAX_ITER equ 128

	org 0
programentry:
	eorz,r0
	lpsl
	lodi,r0 %00100000
	lpsu
	
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
	lodi,r0 245
	wrte,r0 PW1
	
	lodi,r0 177
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

	eorz r0
	stra,r0 M32_UNSIGNED

	; c1 = C1_PRE * ZOOM
	; c2 = W_D2 * c1
	eorz r0
	stra,r0 M32_A1
	stra,r0 M32_A4
	lodi,r0 C1_PRE&255
	stra,r0 M32_A2
	lodi,r0 C1_PRE>>8
	stra,r0 M32_A3
	lodi,r0 ZOOM&255
	stra,r0 M32_B1
	lodi,r0 (ZOOM>>8)&255
	stra,r0 M32_B2
	lodi,r0 (ZOOM>>16)&255
	stra,r0 M32_B3
	lodi,r0 (ZOOM>>24)&255
	stra,r0 M32_B4
	bsta,un fixed_mul
	loda,r0 M32_R1
	stra,r0 C1+0
	stra,r0 M32_A1
	loda,r0 M32_R2
	stra,r0 C1+1
	stra,r0 M32_A2
	loda,r0 M32_R3
	stra,r0 C1+2
	stra,r0 M32_A3
	loda,r0 M32_R4
	stra,r0 C1+3
	stra,r0 M32_A4
	lodi,r0 W_D2
	stra,r0 M32_B4
	eorz r0
	stra,r0 M32_B1
	stra,r0 M32_B2
	stra,r0 M32_B3
	bsta,un fixed_mul
	loda,r0 M32_R1
	stra,r0 C2+0
	loda,r0 M32_R2
	stra,r0 C2+1
	loda,r0 M32_R3
	stra,r0 C2+2
	loda,r0 M32_R4
	stra,r0 C2+3

	; c4 = C4_PRE * ZOOM
	; c3 = H_D2 * c4
	eorz r0
	stra,r0 M32_A1
	stra,r0 M32_A4
	lodi,r0 C4_PRE&255
	stra,r0 M32_A2
	lodi,r0 C4_PRE>>8
	stra,r0 M32_A3
	lodi,r0 ZOOM&255
	stra,r0 M32_B1
	lodi,r0 (ZOOM>>8)&255
	stra,r0 M32_B2
	lodi,r0 (ZOOM>>16)&255
	stra,r0 M32_B3
	lodi,r0 (ZOOM>>24)&255
	stra,r0 M32_B4
	bsta,un fixed_mul
	loda,r0 M32_R1
	stra,r0 C4+0
	stra,r0 M32_A1
	loda,r0 M32_R2
	stra,r0 C4+1
	stra,r0 M32_A2
	loda,r0 M32_R3
	stra,r0 C4+2
	stra,r0 M32_A3
	loda,r0 M32_R4
	stra,r0 C4+3
	stra,r0 M32_A4
	lodi,r0 H_D2
	stra,r0 M32_B4
	eorz r0
	stra,r0 M32_B1
	stra,r0 M32_B2
	stra,r0 M32_B3
	bsta,un fixed_mul
	loda,r0 M32_R1
	stra,r0 C3+0
	loda,r0 M32_R2
	stra,r0 C3+1
	loda,r0 M32_R3
	stra,r0 C3+2
	loda,r0 M32_R4
	stra,r0 C3+3

	ppsl PSL_WITH_CARRY
	lodi,r0 M_HEIGHT-1
mandel_loop_rows:
	stra,r0 CURR_ROW
	; res = row * c4
	stra,r0 M32_B4
	loda,r0 C4+0
	stra,r0 M32_A1
	loda,r0 C4+1
	stra,r0 M32_A2
	loda,r0 C4+2
	stra,r0 M32_A3
	loda,r0 C4+3
	stra,r0 M32_A4
	eorz r0
	stra,r0 M32_B1
	stra,r0 M32_B2
	stra,r0 M32_B3
	bsta,un fixed_mul
	; c_im = res + IMAG
	cpsl PSL_CARRY_FLAG
	lodi,r0 IMAG&255
	adda,r0 M32_R1
	stra,r0 C_IM+0
	lodi,r0 (IMAG>>8)&255
	adda,r0 M32_R2
	stra,r0 C_IM+1
	lodi,r0 (IMAG>>16)&255
	adda,r0 M32_R3
	stra,r0 C_IM+2
	lodi,r0 (IMAG>>24)&255
	adda,r0 M32_R4
	stra,r0 C_IM+3
	; c_im = c_im - c3
	ppsl 1
	loda,r0 C_IM+0
	suba,r0 C3+0
	stra,r0 C_IM+0
	loda,r0 C_IM+1
	suba,r0 C3+1
	stra,r0 C_IM+1
	loda,r0 C_IM+2
	suba,r0 C3+2
	stra,r0 C_IM+2
	loda,r0 C_IM+3
	suba,r0 C3+3
	stra,r0 C_IM+3
	
	eorz r0
	; Toggle LED
	tpsu %01000000
	cpsu %01000000
	bctr,0 mandel_loop_cols
	ppsu %01000000
mandel_loop_cols:
	stra,r0 CURR_COL
	; res = col * C1
	stra,r0 M32_B4
	loda,r0 C1+0
	stra,r0 M32_A1
	loda,r0 C1+1
	stra,r0 M32_A2
	loda,r0 C1+2
	stra,r0 M32_A3
	loda,r0 C1+3
	stra,r0 M32_A4
	eorz r0
	stra,r0 M32_B1
	stra,r0 M32_B2
	stra,r0 M32_B3
	lodi,r0 1
	stra,r0 M32_UNSIGNED
	bsta,un fixed_mul
	eorz r0
	stra,r0 M32_UNSIGNED
	; c_re = res + RE
	cpsl PSL_CARRY_FLAG
	lodi,r0 RE&255
	eori,r0 255
	adda,r0 M32_R1
	stra,r0 C_RE+0
	lodi,r1 (RE>>8)&255
	eori,r1 255
	adda,r1 M32_R2
	stra,r1 C_RE+1
	lodi,r2 (RE>>16)&255
	eori,r2 255
	adda,r2 M32_R3
	stra,r2 C_RE+2
	lodi,r3 (RE>>24)&255
	eori,r3 255
	adda,r3 M32_R4
	stra,r3 C_RE+3
	; c_re = x = c_re - c2
	ppsl 1
	loda,r1 C_RE+0
	suba,r1 C2+0
	stra,r1 C_RE+0
	stra,r1 MAN_X+0
	loda,r1 C_RE+1
	suba,r1 C2+1
	stra,r1 C_RE+1
	stra,r1 MAN_X+1
	loda,r1 C_RE+2
	suba,r1 C2+2
	stra,r1 C_RE+2
	stra,r1 MAN_X+2
	loda,r1 C_RE+3
	suba,r1 C2+3
	stra,r1 C_RE+3
	stra,r1 MAN_X+3

	; y = c_im
	loda,r0 C_IM+0
	stra,r0 MAN_Y+0
	loda,r0 C_IM+1
	stra,r0 MAN_Y+1
	loda,r0 C_IM+2
	stra,r0 MAN_Y+2
	loda,r0 C_IM+3
	stra,r0 MAN_Y+3

	; iteration = 0
	eorz r0
	stra,r0 ITERATION+0
	stra,r0 ITERATION+1
mandel_calc_loop:
	; yy = y * y
	loda,r0 MAN_Y+0
	stra,r0 M32_A1
	stra,r0 M32_B1
	loda,r0 MAN_Y+1
	stra,r0 M32_A2
	stra,r0 M32_B2
	loda,r0 MAN_Y+2
	stra,r0 M32_A3
	stra,r0 M32_B3
	loda,r0 MAN_Y+3
	stra,r0 M32_A4
	stra,r0 M32_B4
	bsta,un fixed_mul
	loda,r0 M32_R1
	stra,r0 MAN_YY+0
	loda,r0 M32_R2
	stra,r0 MAN_YY+1
	loda,r0 M32_R3
	stra,r0 MAN_YY+2
	loda,r0 M32_R4
	stra,r0 MAN_YY+3
	; res = x * y
	loda,r0 MAN_X+0
	stra,r0 M32_A1
	loda,r0 MAN_Y+0
	stra,r0 M32_B1
	loda,r0 MAN_X+1
	stra,r0 M32_A2
	loda,r0 MAN_Y+1
	stra,r0 M32_B2
	loda,r0 MAN_X+2
	stra,r0 M32_A3
	loda,r0 MAN_Y+2
	stra,r0 M32_B3
	loda,r0 MAN_X+3
	stra,r0 M32_A4
	loda,r0 MAN_Y+3
	stra,r0 M32_B4
	bsta,un fixed_mul
	; regs = res << 1
	cpsl PSL_CARRY_FLAG
	loda,r0 M32_R1
	loda,r1 M32_R2
	loda,r2 M32_R3
	loda,r3 M32_R4
	rrl,r0
	rrl,r1
	rrl,r2
	rrl,r3
	; y = regs + c_im
	cpsl PSL_CARRY_FLAG
	; 1
	adda,r0 C_IM+0
	stra,r0 MAN_Y+0
	; 2
	adda,r1 C_IM+1
	stra,r1 MAN_Y+1
	; 3
	adda,r2 C_IM+2
	stra,r2 MAN_Y+2
	; 4
	adda,r3 C_IM+3
	stra,r3 MAN_Y+3
	; res = xx = x * x
	loda,r0 MAN_X+0
	stra,r0 M32_A1
	stra,r0 M32_B1
	loda,r0 MAN_X+1
	stra,r0 M32_A2
	stra,r0 M32_B2
	loda,r0 MAN_X+2
	stra,r0 M32_A3
	stra,r0 M32_B3
	loda,r0 MAN_X+3
	stra,r0 M32_A4
	stra,r0 M32_B4
	bsta,un fixed_mul
	loda,r0 M32_R1
	loda,r1 M32_R2
	loda,r2 M32_R3
	loda,r3 M32_R4
	stra,r0 MAN_XX+0
	stra,r1 MAN_XX+1
	stra,r2 MAN_XX+2
	stra,r3 MAN_XX+3
	; x = res - yy
	
	ppsl PSL_CARRY_FLAG
	loda,r0 M32_R1
	suba,r0 MAN_YY+0
	stra,r0 MAN_X+0
	loda,r0 M32_R2
	suba,r0 MAN_YY+1
	stra,r0 MAN_X+1
	loda,r0 M32_R3
	suba,r0 MAN_YY+2
	stra,r0 MAN_X+2
	loda,r0 M32_R4
	suba,r0 MAN_YY+3
	stra,r0 MAN_X+3
	
	; x = x + c_re
	cpsl PSL_CARRY_FLAG
	; 1
	loda,r0 MAN_X+0
	adda,r0 C_RE+0
	stra,r0 MAN_X+0
	; 2
	loda,r0 MAN_X+1
	adda,r0 C_RE+1
	stra,r0 MAN_X+1
	; 3
	loda,r0 MAN_X+2
	adda,r0 C_RE+2
	stra,r0 MAN_X+2
	; 4
	loda,r0 MAN_X+3
	adda,r0 C_RE+3
	stra,r0 MAN_X+3

	; check if xx + yy <= 4
	cpsl PSL_CARRY_FLAG
	loda,r0 MAN_XX+0
	adda,r0 MAN_YY+0
	loda,r0 MAN_XX+1
	adda,r0 MAN_YY+1
	loda,r0 MAN_XX+2
	adda,r0 MAN_YY+2
	loda,r0 MAN_XX+3
	adda,r0 MAN_YY+3
	andi,r0 %01111100
	bcfr,eq mandel_calc_loop_overflow

	; iteration++
	cpsl PSL_CARRY_FLAG
	loda,r0 ITERATION+0
	addi,r0 1
	stra,r0 ITERATION+0
	loda,r1 ITERATION+1
	addi,r1 0
	stra,r1 ITERATION+1
	comi,r1 MAX_ITER>>8
	bcfa,eq mandel_calc_loop
	comi,r0 MAX_ITER&255
	bcfa,eq mandel_calc_loop
	; Max iters exit
	lodi,r0 ' '
	bsta,un putchar
	bcta,un mandel_calc_loop_exit
mandel_calc_loop_overflow:
	; Overflow exit
	loda,r0 ITERATION+0
	andi,r0 7
	cpsl PSL_WITH_CARRY
	addz r0
	addz r0
	addz r0
	ppsl PSL_WITH_CARRY
	strz r3
print_loop1:
	loda,r0 mandel_colors,r3+
	comi,r0 33
	bctr,eq print_loop1_exit
	bsta,un putchar
	bctr,un print_loop1

print_loop1_exit:
	lodi,r0 '#'
	bsta,un putchar

mandel_calc_loop_exit:
	; End col loop
	loda,r0 CURR_COL
	cpsl PSL_CARRY_FLAG
	addi,r0 1
	comi,r0 M_WIDTH
	bcfa,0 mandel_loop_cols

	; End row loop
	loda,r0 newline+0
	bsta,un putchar
	loda,r0 newline+1
	bsta,un putchar
	loda,r0 CURR_ROW
	bdra,r0 mandel_loop_rows

	lodi,r3 255
print_loop2:
	loda,r0 mandel_color_reset,r3+
	comi,r0 0
	bctr,eq print_loop2_exit
	bsta,un putchar
	bctr,un print_loop2

print_loop2_exit:
	ppsu %01000000
end_loop:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	tpsu %10000000
	bctr,eq end_loop
	cpsu %01000000
	bcta,un programentry
	
;hex_chars:
;	db "0123456789ABCDEF"
;hex_a_back:
;	db 0
;print_hex:
;	stra,r0 hex_a_back
;	rrr,r0
;	rrr,r0
;	rrr,r0
;	rrr,r0
;	andi,r0 15
;	loda,r0 hex_chars,r0
;	bsta,un putchar
;	loda,r0 hex_a_back
;	andi,r0 15
;	loda,r0 hex_chars,r0
;	bsta,un putchar
;	loda,r0 hex_a_back
;	retc,un

fixed_mul:
	stra,r0 R0_BACK
	stra,r1 R1_BACK
	stra,r2 R2_BACK
	spsl
	stra,r0 PSL_BACK1
	cpsl PSL_BANK
	ppsl PSL_WITH_CARRY+PSL_LOGICAL_COMP
	eorz,r0
	stra,r0 M32_RB1
	stra,r0 M32_RB2
	stra,r0 M32_RB3
	stra,r0 M32_RB4
	stra,r0 M32_RB5
	stra,r0 M32_RB6
	stra,r0 M32_RB7
	stra,r0 M32_RB8
	
	eorz,r0
	stra,r0 M32_SIGN
	coma,r0 M32_UNSIGNED
	bcfa,eq mul_32x32_unsigned
	
	loda,r1 M32_A4
	andi,r1 128
	bctr,eq fixed_mul_not_neg_a
	cpsl PSL_CARRY_FLAG
	lodi,r1 255
	lodi,r2 0
	loda,r0 M32_A1
	eorz r1
	addi,r0 1
	stra,r0 M32_A1
	loda,r0 M32_A2
	eorz r1
	addz r2
	stra,r0 M32_A2
	loda,r0 M32_A3
	eorz r1
	addz r2
	stra,r0 M32_A3
	loda,r0 M32_A4
	eorz r1
	addz r2
	stra,r0 M32_A4
	lodi,r2 1
	stra,r2 M32_SIGN
fixed_mul_not_neg_a:
	loda,r1 M32_B4
	andi,r1 128
	bctr,eq fixed_mul_not_neg_b
	cpsl PSL_CARRY_FLAG
	lodi,r1 255
	lodi,r2 0
	loda,r0 M32_B1
	eorz r1
	addi,r0 1
	stra,r0 M32_B1
	loda,r0 M32_B2
	eorz r1
	addz r2
	stra,r0 M32_B2
	loda,r0 M32_B3
	eorz r1
	addz r2
	stra,r0 M32_B3
	loda,r0 M32_B4
	eorz r1
	addz r2
	stra,r0 M32_B4
	loda,r2 M32_SIGN
	eori,r2 1
	stra,r2 M32_SIGN
fixed_mul_not_neg_b:
mul_32x32_unsigned:
	lodi,r2 255
mul_32x32_loop:
	loda,r0 M32_A1,r2+
	stra,r0 M32_TMP
	
	; Begin mul_8x32_hw
	ppsl PSL_BANK
	
	; 1
	loda,r0 M32_TMP
	loda,r1 M32_B1
	mul
	cpsl PSL_CARRY_FLAG
	adda,r0 M32_RB4
	stra,r0 M32_RB4
	adda,r1 M32_RB5
	stra,r1 M32_RB5
	loda,r3 M32_RB6
	addi,r3 0
	stra,r3 M32_RB6
	loda,r3 M32_RB7
	addi,r3 0
	stra,r3 M32_RB7
	loda,r3 M32_RB8
	addi,r3 0
	stra,r3 M32_RB8
	
	; 2
	loda,r0 M32_TMP
	loda,r1 M32_B2
	mul
	cpsl PSL_CARRY_FLAG
	adda,r0 M32_RB5
	stra,r0 M32_RB5
	adda,r1 M32_RB6
	stra,r1 M32_RB6
	loda,r2 M32_RB7
	addi,r2 0
	stra,r2 M32_RB7
	loda,r2 M32_RB8
	addi,r2 0
	stra,r2 M32_RB8
	
	; 3
	loda,r0 M32_TMP
	loda,r1 M32_B3
	mul
	cpsl PSL_CARRY_FLAG
	adda,r0 M32_RB6
	stra,r0 M32_RB6
	adda,r1 M32_RB7
	stra,r1 M32_RB7
	loda,r3 M32_RB8
	addi,r3 0
	stra,r3 M32_RB8
	
	; 4
	loda,r0 M32_TMP
	loda,r1 M32_B4
	mul
	cpsl PSL_CARRY_FLAG
	adda,r0 M32_RB7
	stra,r0 M32_RB7
	adda,r1 M32_RB8
	stra,r1 M32_RB8
	
	cpsl PSL_BANK
	; End mul_8x32_hw
	comi,r2 3
	bcta,eq mul_32x32_end
	
	loda,r0 M32_RB2
	stra,r0 M32_RB1
	loda,r0 M32_RB3
	stra,r0 M32_RB2
	loda,r0 M32_RB4
	stra,r0 M32_RB3
	loda,r0 M32_RB5
	stra,r0 M32_RB4
	loda,r0 M32_RB6
	stra,r0 M32_RB5
	loda,r0 M32_RB7
	stra,r0 M32_RB6
	loda,r0 M32_RB8
	stra,r0 M32_RB7
	eorz,r0
	stra,r0 M32_RB8
	bcta,un mul_32x32_loop
mul_32x32_end:
	loda,r0 M32_RB7
	stra,r0 M32_R4
	loda,r0 M32_RB6
	stra,r0 M32_R3
	loda,r0 M32_RB5
	stra,r0 M32_R2
	loda,r0 M32_RB4
	stra,r0 M32_R1
    loda,r0 M32_SIGN
    comi,r0 0
    bcta,eq fixed_mul_no_negate_res
    lodi,r2 255
    lodi,r3 0
    cpsl PSL_CARRY_FLAG
    cpsl PSL_CARRY_FLAG
    loda,r0 M32_R1
    eorz r2
    addi,r0 1
    stra,r0 M32_R1
    loda,r0 M32_R2
    eorz r2
    addz r3
    stra,r0 M32_R2
    loda,r0 M32_R3
    eorz r2
    addz r3
    stra,r0 M32_R3
    loda,r0 M32_R4
    eorz r2
    addz r3
    stra,r0 M32_R4
fixed_mul_no_negate_res:
	loda,r0 PSL_BACK1
	lpsl
	loda,r0 R0_BACK
	loda,r1 R1_BACK
	loda,r2 R2_BACK
	retc,un

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

	
newline:
	db $0D
	db $0A
mandel_colors:
	db 33,27,91,51,49,109,0,33
	db 33,27,91,51,49,109,0,33
	db 33,27,91,51,50,109,0,33
	db 33,27,91,51,51,109,0,33
	db 33,27,91,51,52,109,0,33
	db 33,27,91,51,53,109,0,33
	db 33,27,91,51,54,109,0,33
	db 33,27,91,51,55,109,0,33
mandel_color_reset:
	db 27,91,48,109
	db "Done."
	db $0D
	db $0A
	db 0
end
