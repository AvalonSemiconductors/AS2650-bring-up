; Mandelbrot set renderer!

PSL_CC1          equ 0b10000000
PSL_CC0          equ 0b01000000
PSL_IDC          equ 0b00100000
PSL_BANK         equ 0b00010000
PSL_WITH_CARRY   equ 0b00001000
PSL_OVERFLOW     equ 0b00000100
PSL_LOGICAL_COMP equ 0b00000010
PSL_CARRY_FLAG   equ 0b00000001

mem_start equ 6144

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

portb_state equ mem_start+100
R0_BACK_U          equ mem_start+101
R1_BACK_U          equ mem_start+102
R2_BACK_U          equ mem_start+103
R3_BACK_U          equ mem_start+104
PSL_BACK_U         equ mem_start+105

sel_rom equ 6
sel_lcd equ 5
sel_gpio equ 3
spi_idle equ 7

; Mandel renderer vars
C1               equ mem_start+132
C2               equ mem_start+136
C3               equ mem_start+140
C4               equ mem_start+144
CURR_ROW         equ mem_start+148
CURR_COL         equ mem_start+149
C_IM             equ mem_start+150
C_RE             equ mem_start+154
MAN_X            equ mem_start+158
MAN_Y            equ mem_start+162
MAN_XX           equ mem_start+166
MAN_YY           equ mem_start+180
ITERATION        equ mem_start+184

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
	lodi,r0 0b00100000
	lpsu
	; De-select ALL 8-bit peripherals
	lodi,r0 0b11111001
	stra,r0 portb_state
	bsta,un portb_write
	loda,r0 portb_state
	bsta,un portb_write

	eorz r0
	stra,r0 M32_UNSIGNED

	; c1 = C1_PRE * ZOOM
	; c2 = W_D2 * c1
	eorz r0
	stra,r0 M32_A1
	stra,r0 M32_A4
	lodi,r0 C1_PRE%256
	stra,r0 M32_A2
	lodi,r0 C1_PRE>>8
	stra,r0 M32_A3
	lodi,r0 ZOOM%256
	stra,r0 M32_B1
	lodi,r0 ZOOM>>8%256
	stra,r0 M32_B2
	lodi,r0 ZOOM>>16%256
	stra,r0 M32_B3
	lodi,r0 ZOOM>>24%256
	stra,r0 M32_B4
	bsta,3 fixed_mul
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
	bsta,3 fixed_mul
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
	lodi,r0 C4_PRE%256
	stra,r0 M32_A2
	lodi,r0 C4_PRE>>8
	stra,r0 M32_A3
	lodi,r0 ZOOM%256
	stra,r0 M32_B1
	lodi,r0 ZOOM>>8%256
	stra,r0 M32_B2
	lodi,r0 ZOOM>>16%256
	stra,r0 M32_B3
	lodi,r0 ZOOM>>24%256
	stra,r0 M32_B4
	bsta,3 fixed_mul
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
	bsta,3 fixed_mul
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
	bsta,3 fixed_mul
	; c_im = res + IMAG
	cpsl PSL_CARRY_FLAG
	lodi,r0 IMAG%256
	adda,r0 M32_R1
	stra,r0 C_IM+0
	lodi,r0 IMAG>>8%256
	adda,r0 M32_R2
	stra,r0 C_IM+1
	lodi,r0 IMAG>>16%256
	adda,r0 M32_R3
	stra,r0 C_IM+2
	lodi,r0 IMAG>>24%256
	adda,r0 M32_R4
	stra,r0 C_IM+3
	; c_im = c_im - c3
	lodi,r1 C_IM-mem_start
	lodi,r2 C_IM-mem_start
	lodi,r3 C3-mem_start
	
	;lodi,r0 13
	;bsta,un write_8251
	;lodi,r0 10
	;bsta,un write_8251
	;loda,r0 C_IM+3
	;bsta,un print_hex
	;loda,r0 C_IM+2
	;bsta,un print_hex
	;loda,r0 C_IM+1
	;bsta,un print_hex
	;loda,r0 C_IM+0
	;bsta,un print_hex
	;lodi,r0 '-'
	;bsta,un write_8251
	;loda,r0 C3+3
	;bsta,un print_hex
	;loda,r0 C3+2
	;bsta,un print_hex
	;loda,r0 C3+1
	;bsta,un print_hex
	;loda,r0 C3+0
	;bsta,un print_hex
	;lodi,r0 '='
	;bsta,un write_8251
	
	bsta,un safe_sub
	
	;loda,r0 C_IM+3
	;bsta,un print_hex
	;loda,r0 C_IM+2
	;bsta,un print_hex
	;loda,r0 C_IM+1
	;bsta,un print_hex
	;loda,r0 C_IM+0
	;bsta,un print_hex
	;lodi,r0 13
	;bsta,un write_8251
	;lodi,r0 10
	;bsta,un write_8251
	
	eorz r0
	; Toggle LED
	tpsu 0b01000000
	cpsu 0b01000000
	bctr,0 mandel_loop_cols
	ppsu 0b01000000
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
	bsta,3 fixed_mul
	eorz r0
	stra,r0 M32_UNSIGNED
	; c_re = res + RE
	cpsl PSL_CARRY_FLAG
	lodi,r0 RE%256
	eori,r0 255
	adda,r0 M32_R1
	stra,r0 C_RE+0
	lodi,r1 RE>>8%256
	eori,r1 255
	adda,r1 M32_R2
	stra,r1 C_RE+1
	lodi,r2 RE>>16%256
	eori,r2 255
	adda,r2 M32_R3
	stra,r2 C_RE+2
	lodi,r3 RE>>24%256
	eori,r3 255
	adda,r3 M32_R4
	stra,r3 C_RE+3
	; c_re = x = c_re - c2
	lodi,r1 C_RE-mem_start
	lodi,r2 C_RE-mem_start
	lodi,r3 C2-mem_start
	bsta,un safe_sub
	loda,r0 C_RE+0
	stra,r0 MAN_X+0
	loda,r0 C_RE+1
	stra,r0 MAN_X+1
	loda,r0 C_RE+2
	stra,r0 MAN_X+2
	loda,r0 C_RE+3
	stra,r0 MAN_X+3

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
	loda,r0 C_IM+1
	tpsl 1
	bcfr,eq nofix407
	comi,r1 255
	bctr,eq fixed412
nofix407:
	addz,r1
fixed412:
	stra,r0 MAN_Y+1
	
	; 3
	loda,r0 C_IM+2
	tpsl 1
	bcfr,eq nofix419
	comi,r2 255
	bctr,eq fixed421
nofix419:
	addz,r2
fixed421:
	stra,r0 MAN_Y+2
	
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
	
	;lodi,r1 MAN_X-mem_start
	;lodi,r2 M32_R1-mem_start
	;lodi,r3 MAN_YY-mem_start
	;bsta,un safe_sub
	
	ppsl PSL_CARRY_FLAG
	loda,r1 MAN_YY+0
	eori,r1 0xFF
	comi,r0 255
	bcfr,eq nofix462
	loda,r0 M32_R1
	bctr,un fixed465
nofix462:
	loda,r0 M32_R1
	addz,r1
fixed465:
	stra,r0 MAN_X+0
	
	loda,r1 M32_R2
	tpsl 1
	bcfr,eq nofix474
	comi,r1 255
	bcfr,eq nofix474
	loda,r0 MAN_YY+1
	eori,r0 0xFF
	bctr,un fixed479
nofix474:
	loda,r0 MAN_YY+1
	eori,r0 0xFF
	addz,r1
fixed479:
	stra,r0 MAN_X+1
	
	loda,r1 M32_R3
	tpsl 1
	bcfr,eq nofix489
	comi,r1 255
	bcfr,eq nofix489
	loda,r0 MAN_YY+2
	eori,r0 0xFF
	bctr,un fixed494
nofix489:
	loda,r0 MAN_YY+2
	eori,r0 0xFF
	addz,r1
fixed494:
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
	tpsl 1
	bcfr,eq nofix496
	loda,r0 C_RE+1
	comi,r0 255
	bctr,eq fixed472
nofix496:
	loda,r0 MAN_X+1
	adda,r0 C_RE+1
	stra,r0 MAN_X+1
fixed472:

	; 3
	tpsl 1
	bcfr,eq nofix481
	loda,r0 C_RE+2
	comi,r0 255
	bctr,eq fixed484
nofix481:
	loda,r0 MAN_X+2
	adda,r0 C_RE+2
	stra,r0 MAN_X+2
fixed484:

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
	andi,r0 0b01111100
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
	comi,r0 MAX_ITER%256
	bcfa,eq mandel_calc_loop
	; Max iters exit
	lodi,r0 ' '
	bsta,un write_8251
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
	bsta,un write_8251
	bctr,un print_loop1

print_loop1_exit:
	lodi,r0 '#'
	bsta,un write_8251

mandel_calc_loop_exit:
	; End col loop
	loda,r0 CURR_COL
	cpsl PSL_CARRY_FLAG
	addi,r0 1
	comi,r0 M_WIDTH
	bcfa,0 mandel_loop_cols

	; End row loop
	loda,r0 newline+0
	bsta,un write_8251
	loda,r0 newline+1
	bsta,un write_8251
	loda,r0 CURR_ROW
	bdra,r0 mandel_loop_rows

	lodi,r3 255
print_loop2:
	loda,r0 mandel_color_reset,r3+
	comi,r0 0
	bctr,eq print_loop2_exit
	bsta,un write_8251
	bctr,un print_loop2

print_loop2_exit:
	ppsu 0b01000000
end_loop:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	tpsu 0b10000000
	bctr,eq end_loop
	cpsu 0b01000000
	bcta,un programentry
	
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

safe_sub_temp:
	db 0
safe_sub:
	ppsl PSL_CARRY_FLAG
	loda,r0 mem_start,r2
	comi,r0 255
	bcfr,eq nofix507
	loda,r0 mem_start,r3
	eori,r0 0xFF
	bctr,un fixed513
nofix507:
	loda,r0 mem_start,r3
	eori,r0 0xFF
	stra,r1 safe_sub_temp
	strz,r1
	loda,r0 mem_start,r2
	xchg
	addz,r1
	loda,r1 safe_sub_temp
fixed513:
	stra,r0 mem_start,r1

	loda,r0 mem_start,r2+
	comi,r0 255
	bcfr,eq nofix523
	tpsl 1
	bcfr,eq nofix523
	loda,r0 mem_start,r3+
	eori,r0 0xFF
	bctr,un fixed527
nofix523:
	loda,r0 mem_start,r3+
	eori,r0 0xFF
	stra,r1 safe_sub_temp
	strz,r1
	loda,r0 mem_start,r2
	xchg
	addz,r1
	loda,r1 safe_sub_temp
fixed527:
	stra,r0 mem_start,r1+
	
	loda,r0 mem_start,r2+
	comi,r0 255
	bcfr,eq nofix537
	tpsl 1
	bcfr,eq nofix537
	loda,r0 mem_start,r3+
	eori,r0 0xFF
	bctr,un fixed543
nofix537:
	loda,r0 mem_start,r3+
	eori,r0 0xFF
	stra,r1 safe_sub_temp
	strz,r1
	loda,r0 mem_start,r2
	xchg
	addz,r1
	loda,r1 safe_sub_temp
fixed543:
	stra,r0 mem_start,r1+
	
	loda,r0 mem_start,r3+
	eori,r0 0xFF
	stra,r1 safe_sub_temp
	strz,r1
	loda,r0 mem_start,r2+
	xchg
	addz,r1
	loda,r1 safe_sub_temp
	stra,r0 mem_start,r1+
	
	retc,un

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
	adda,r2 M32_RB4
	stra,r2 M32_RB4
	tpsl PSL_CARRY_FLAG
	bcfr,eq nofix469
	comi,r3 255
	bctr,eq fixed471
nofix469:
	loda,r0 M32_RB5
	addz,r3
	stra,r0 M32_RB5
fixed471:
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
	adda,r2 M32_RB5
	stra,r2 M32_RB5
	tpsl PSL_CARRY_FLAG
	bcfr,eq nofix488
	comi,r3 255
	bctr,eq fixed490
nofix488:
	loda,r0 M32_RB6
	addz,r3
	stra,r0 M32_RB6
fixed490:
	loda,r3 M32_RB7
	addi,r3 0
	stra,r3 M32_RB7
	loda,r3 M32_RB8
	addi,r3 0
	stra,r3 M32_RB8
	
	; 3
	loda,r0 M32_TMP
	loda,r1 M32_B3
	mul
	cpsl PSL_CARRY_FLAG
	adda,r2 M32_RB6
	stra,r2 M32_RB6
	tpsl PSL_CARRY_FLAG
	bcfr,eq nofix518
	comi,r3 255
	bctr,eq fixed520
nofix518:
	loda,r0 M32_RB7
	addz,r3
	stra,r0 M32_RB7
fixed520:
	loda,r3 M32_RB8
	addi,r3 0
	stra,r3 M32_RB8
	
	; 4
	loda,r0 M32_TMP
	loda,r1 M32_B4
	mul
	cpsl PSL_CARRY_FLAG
	adda,r2 M32_RB7
	stra,r2 M32_RB7
	adda,r3 M32_RB8
	stra,r3 M32_RB8
	
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
    ;loda,r0 M32_RB1
    ;eorz r2
    ;addi,r0 1
    ;stra,r0 M32_RB1
    ;loda,r0 M32_RB2
    ;eorz r2
    ;addz r3
    ;stra,r0 M32_RB2
    ;loda,r0 M32_RB3
    ;eorz r2
    ;addz r3
    ;stra,r0 M32_RB3
    ;loda,r0 M32_RB4
    ;eorz r2
    ;addz r3
    ;stra,r0 M32_RB4
    ;loda,r0 M32_RB5
    ;eorz r2
    ;addz r3
    ;stra,r0 M32_RB5
    ;loda,r0 M32_RB6
    ;eorz r2
    ;addz r3
    ;stra,r0 M32_RB6
    ;loda,r0 M32_RB7
    ;eorz r2
    ;addz r3
    ;stra,r0 M32_RB7
    ;loda,r0 M32_RB8
    ;eorz r2
    ;addz r3
    ;stra,r0 M32_RB8
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

	; Send contents of r0 over SPI, ignoring serial in
spi_send:
	stra,r1 R1_BACK_U
	stra,r2 R2_BACK_U
	xchg
	spsl
	stra,r0 PSL_BACK_U
	xchg
	ppsl PSL_WITH_CARRY
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
	loda,r1 R1_BACK_U
	loda,r2 R2_BACK_U
	loda,r0 PSL_BACK_U
	lpsl
	retc,un
	
spi_receive:
	spsl
	stra,r0 PSL_BACK_U
	stra,r1 R1_BACK_U
	stra,r2 R2_BACK_U
	stra,r3 R3_BACK_U
	ppsl PSL_WITH_CARRY
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
	xchg
	loda,r0 PSL_BACK_U
	lpsl
	xchg
	loda,r1 R1_BACK_U
	loda,r2 R2_BACK_U
	loda,r3 R3_BACK_U
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
	stra,r0 R0_BACK_U
	lodi,r0 sel_gpio
	wrtc,r0
	nop
	nop
	lodi,r0 64
	bsta,un spi_send
	lodi,r0 0x12
	bsta,un spi_send
	loda,r0 R0_BACK_U
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
	stra,r0 R0_BACK_U
	lodi,r0 spi_idle
	wrtc,r0
	nop
	nop
	loda,r0 R0_BACK_U
	retc,un
	
portb_write:
	stra,r0 R0_BACK_U
	lodi,r0 sel_gpio
	wrtc,r0
	nop
	nop
	lodi,r0 64
	bsta,un spi_send
	lodi,r0 0x13
	bsta,un spi_send
	loda,r0 R0_BACK_U
	bsta,un spi_send
	lodi,r0 spi_idle
	wrtc,r0
	nop
	loda,r0 R0_BACK_U
	retc,un

delay_8251:
	loda,r0 3
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
	
newline:
	db 0x0D
	db 0x0A
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
	db 0x0D
	db 0x0A
	db 0
end
