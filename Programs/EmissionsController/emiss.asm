; Program that smoothsteps between random values and sends the result out over UART. Can be fed into OSC and VRC to control avatar emissions by a small program on the PC.

PSL_CC1          equ 0b10000000
PSL_CC0          equ 0b01000000
PSL_IDC          equ 0b00100000
PSL_BANK         equ 0b00010000
PSL_WITH_CARRY   equ 0b00001000
PSL_OVERFLOW     equ 0b00000100
PSL_LOGICAL_COMP equ 0b00000010
PSL_CARRY_FLAG   equ 0b00000001

mem_start equ 4096

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
SEED_1           equ mem_start+35
SEED_2           equ mem_start+36
SEED_3           equ mem_start+37
SEED_4           equ mem_start+38
M32_TMP          equ mem_start+39

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

; Emissions Controller vars & constants
ADVANCE          equ 0x1A005
ADVANCE_SLOW     equ 0x0E104
A_1              equ mem_start+512
A_2              equ mem_start+513
A_3              equ mem_start+514
B_1              equ mem_start+515
B_2              equ mem_start+516
B_3              equ mem_start+517
DIFF_1           equ mem_start+518
DIFF_2           equ mem_start+519
DIFF_3           equ mem_start+520
DIFF_4           equ mem_start+521
X_1              equ mem_start+522
X_2              equ mem_start+523
X_3              equ mem_start+524
XX_1             equ mem_start+525
XX_2             equ mem_start+526
XX_3             equ mem_start+527
BTN_STATE        equ mem_start+528
SLOW_EMISS       equ mem_start+529

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
	
	ppsl PSL_WITH_CARRY

	;lodi,r0 67
	;stra,r0 SEED_1
	;lodi,r0 207
	;stra,r0 SEED_2
	;lodi,r0 3
	;stra,r0 SEED_3
	;lodi,r0 69
	;stra,r0 SEED_4

	lodi,r0 1
	bsta,un set_rx_state_8251
	lodi,r3 255
seed_read_loop:
	ppsl PSL_BANK
	bsta,un read_8251
	cpsl PSL_BANK
	iori,r0 0
	bctr,eq seed_read_loop
	stra,r0 SEED_1,r3+
	
	lodz,r3
	eori,r0 3
	bcfr,eq seed_read_loop
	eorz,r0
	bsta,un set_rx_state_8251

	bsta,un xorshift
	bsta,un xorshift
	bsta,un xorshift
	bsta,un xorshift

	bsta,un rng_B
	bsta,un rng_B

	eorz r0
	stra,r0 M32_UNSIGNED
	stra,r0 X_1
	stra,r0 X_2
	stra,r0 X_3
	stra,r0 BTN_STATE
	stra,r0 SLOW_EMISS

emissions_loop:
	nop
	tpsu 128
	bctr,eq btn_not_pressed
	loda,r0 BTN_STATE
	bcfr,eq btn_held
	iori,r0 69
	stra,r0 BTN_STATE
	loda,r0 SLOW_EMISS
	eori,r0 1
	stra,r0 SLOW_EMISS
	bctr,3 btn_held
btn_not_pressed:
	eorz r0
	stra,r0 BTN_STATE
btn_held:

	bsta,un calc_weight
	loda,r0 DIFF_1
	stra,r0 M32_B1
	loda,r0 DIFF_2
	stra,r0 M32_B2
	loda,r0 DIFF_3
	stra,r0 M32_B3
	loda,r0 DIFF_4
	stra,r0 M32_B4
	bsta,un fixed_mul
	cpsl PSL_CARRY_FLAG
	loda,r0 M32_R1
	adda,r0 A_1
	
	tpsl 1
	bcfr,eq nofix173
	loda,r1 A_2
	comi,r1 255
	bcfr,eq nofix173
	loda,r1 M32_R2
	bctr,un fixed178
nofix173:
	loda,r1 M32_R2
	adda,r1 A_2
fixed178:
	
	loda,r2 M32_R3
	adda,r2 A_3
	bsta,un print_formatted_value

	lodz r1
	bsta,un print_formatted_value
	lodz r2
	bsta,un print_formatted_value
	lodi,r0 '#'
	bsta,un write_8251

	loda,r2 portb_state
	andi,r2 0b11111011
	loda,r3 SLOW_EMISS
	rrl,r3
	rrl,r3
	andi,r3 4
	lodz,r2
	iorz,r3
	stra,r0 portb_state
	bsta,un portb_write

	loda,r0 SLOW_EMISS
	bctr,eq inc_x_fast
inc_x_slow:
	lodi,r1 ADVANCE_SLOW%256
	lodi,r2 ADVANCE_SLOW>>8%256
	lodi,r3 ADVANCE_SLOW>>16%256
	bctr,un inc_x
inc_x_fast:
	lodi,r1 ADVANCE%256
	lodi,r2 ADVANCE>>8%256
	lodi,r3 ADVANCE>>16%256
inc_x:
	; Should be safe to use add without safeguards, as long as ADVANCE and ADVANCE_SLOW contain no 0xFF bytes
	cpsl PSL_CARRY_FLAG
	loda,r0 X_1
	addz r1
	stra,r0 X_1
	loda,r0 X_2
	addz r2
	stra,r0 X_2
	loda,r0 X_3
	addz r3
	stra,r0 X_3
	eorz r0
	addi,r0 0
	bcta,eq emissions_loop
	bsta,un rng_B
	eorz r0
	stra,r0 M32_B1
	stra,r0 M32_B2
	stra,r0 M32_B3
	db 182
	db 0b01000000
	cpsu 0b01000000
	bcta,eq emissions_loop
	ppsu 0b01000000
	bcta,un emissions_loop

formatted_backup:
	db 0
print_formatted_value:
	cpsl PSL_WITH_CARRY
	stra,r0 formatted_backup
	andi,r0 15
	addi,r0 ' '
	bsta,un write_8251
	loda,r0 formatted_backup
	rrr,r0
	rrr,r0
	rrr,r0
	rrr,r0
	andi,r0 15
	addi,r0 ' '
	bsta,un write_8251
	ppsl PSL_WITH_CARRY
	retc,un

calc_weight:
	loda,r0 X_1
	stra,r0 M32_A1
	stra,r0 M32_B1
	loda,r0 X_2
	stra,r0 M32_A2
	stra,r0 M32_B2
	loda,r0 X_3
	stra,r0 M32_A3
	stra,r0 M32_B3
	eorz,r0
	stra,r0 M32_A4
	stra,r0 M32_B4
	bsta,un fixed_mul
	loda,r0 M32_R1
	stra,r0 M32_A1
	loda,r0 M32_R2
	stra,r0 M32_A2
	loda,r0 M32_R3
	stra,r0 M32_A3
	loda,r0 M32_R4
	stra,r0 M32_A4
	bsta,un fixed_mul
	cpsl PSL_CARRY_FLAG
	loda,r0 M32_A1
	rrl,r0
	strz r1
	loda,r0 M32_A2
	rrl,r0
	strz r2
	loda,r0 M32_A3
	rrl,r0
	strz r3
	loda,r0 M32_A4
	rrl,r0
	stra,r0 M32_B4
	cpsl PSL_CARRY_FLAG
	adda,r1 M32_A1
	stra,r1 M32_A1
	
	tpsl 1
	bcfr,eq nofix305
	loda,r0 M32_A2
	comi,r0 255
	bcfr,eq nofix305
	bctr,un fixed309
nofix305:
	adda,r2 M32_A2
fixed309:
	stra,r2 M32_A2
	
	tpsl 1
	bcfr,eq nofix313
	loda,r0 M32_A3
	comi,r0 255
	bcfr,eq nofix313
	bctr,un fixed317
nofix313:
	adda,r3 M32_A3
fixed317:
	stra,r3 M32_A3
	
	loda,r0 M32_B4
	adda,r0 M32_A4
	stra,r0 M32_A4

	cpsl PSL_CARRY_FLAG
	loda,r0 M32_R1
	rrl,r0
	strz r1
	loda,r0 M32_R2
	rrl,r0
	strz r2
	loda,r0 M32_R3
	rrl,r0
	strz r3
	loda,r0 M32_R4
	rrl,r0
	stra,r0 M32_B1

	; 1
	ppsl PSL_CARRY_FLAG
	eori,r1 0xFF
	comi,r1 255
	bctr,eq fixed346
nofix344:
	loda,r0 M32_A1
	addz,r1
	stra,r0 M32_A1
fixed346:
	
	; 2
	eori,r2 0xFF
	comi,r2 255
	bcfr,eq nofix355
	tpsl 1
	bctr,eq fixed357
nofix355:
	loda,r0 M32_A2
	addz,r2
	stra,r0 M32_A2
fixed357:
	
	; 3
	eori,r3 0xFF
	comi,r3 255
	bcfr,eq nofix366
	tpsl 1
	bctr,eq fixed368
nofix366:
	loda,r0 M32_A3
	addz,r3
	stra,r0 M32_A3
fixed368:
	
	; 4
	loda,r0 M32_B1
	eori,r0 0xFF
	adda,r0 M32_A4
	stra,r0 M32_A4
	retc,un

rng_B:
	loda,r0 B_1
	stra,r0 A_1
	loda,r0 B_2
	stra,r0 A_2
	loda,r0 B_3
	stra,r0 A_3

	bsta,un xorshift
	loda,r0 SEED_2
	stra,r0 B_1
	loda,r1 SEED_3
	stra,r1 B_2
	loda,r2 SEED_4
	stra,r2 B_3

	ppsl PSL_CARRY_FLAG+PSL_WITH_CARRY
	; 1
	stra,r0 workaround_temp
	comi,r0 255
	bcfr,eq nofix401
	loda,r0 A_1
	eori,r0 0xFF
	stra,r0 DIFF_1
	bctr,un fixed405
nofix401:
	loda,r0 A_1
	eori,r0 0xFF
	adda,r0 workaround_temp
	stra,r0 DIFF_1
fixed405:

	; 2
	comi,r1 255
	bcfr,eq nofix413
	tpsl 1
	bcfr,eq nofix413
	loda,r0 A_2
	eori,r0 0xFF
	stra,r0 DIFF_2
nofix413:
	loda,r0 A_2
	eori,r0 0xFF
	addz,r1
	stra,r0 DIFF_2
fixed415:
	
	; 3
	lodz,r2
	loda,r1 A_3
	bcfr,eq nofix425
	tpsl 1
	bctr,eq fixed427
nofix425:
	eori,r1 0xFF
	addz,r1
fixed427:
	stra,r0 DIFF_3
	
	; 4
	lodi,r0 0xFF
	lodi,r3 0
	addz,r3
	stra,r0 DIFF_4
	retc,un
workaround_temp:
	db 0
	
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

xorshift:
	spsl
	stra,r0 PSL_BACK1
	ppsl PSL_WITH_CARRY
	cpsl PSL_BANK
	lodi,r0 5
	loda,r1 SEED_1
	loda,r2 SEED_2
	loda,r3 SEED_3
xorshift_loop_1:
	cpsl PSL_CARRY_FLAG
	rrl,r1
	rrl,r2
	rrl,r3
	bdrr,r0 xorshift_loop_1

	eora,r0 SEED_1
	eora,r1 SEED_2
	eora,r2 SEED_3
	eora,r3 SEED_4
	lodz r3
	strz r1
	lodz r2
	lodi,r2 0
	lodi,r3 0
	cpsl PSL_CARRY_FLAG
	rrr,r1
	rrr,r0
	eora,r0 SEED_1
	eora,r1 SEED_2
	eora,r2 SEED_3
	eora,r3 SEED_4

	ppsl PSL_BANK
	lodi,r1 5
xorshift_loop_2:
	cpsl PSL_CARRY_FLAG+PSL_BANK
	rrl,r0
	rrl,r1
	rrl,r2
	rrl,r3
	ppsl PSL_BANK
	bdrr,r1 xorshift_loop_2
	cpsl PSL_BANK

	eora,r0 SEED_1
	eora,r1 SEED_2
	eora,r2 SEED_3
	eora,r3 SEED_4
	stra,r0 SEED_1
	stra,r1 SEED_2
	stra,r2 SEED_3
	stra,r3 SEED_4
	loda,r0 PSL_BACK1
	lpsl
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
	
read_8251:
	stra,r3 R3_BACK_U
	; Put in command mode and prepare for reads
	bsta,un porta_inp
	loda,r0 portb_state
	iori,r0 0b00011001
	andi,r0 0b11011111
	stra,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
	
	; Read status, then put in data mode
	loda,r0 portb_state
	andi,r0 0b11110111
	bsta,un portb_write
	bsta,un delay_8251
	bsta,un porta_read
	strz,r3
	loda,r0 portb_state
	andi,r0 254
	stra,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
	
	lodz,r3
	andi,r0 2
	strz,r3
	bctr,eq read_8251_return
	; Read data
	loda,r0 portb_state
	andi,r0 0b11110111
	bsta,un portb_write
	bsta,un delay_8251
	bsta,un porta_read
	strz,r3
	loda,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
read_8251_return:
	; Put in data mode & deselect
	loda,r0 portb_state
	andi,r0 254
	iori,r0 32
	stra,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
	bsta,un porta_inp
	lodz,r3
	loda,r3 R3_BACK_U
	retc,un

set_rx_state_8251:
	stra,r1 R1_BACK_U
	xchg
	; Select in command mode
	loda,r0 portb_state
	iori,r0 0b00011001
	andi,r0 0b11011111
	stra,r0 portb_state
	bsta,un portb_write
	bsta,un delay_8251
	
	; Send command
	bsta,un porta_outp
	xchg
	iorz,r0
	bctr,eq disable_rx
	lodi,r0 0b00010111
	bctr,un enable_rx
disable_rx:
	lodi,r0 0b00010011
enable_rx:
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
	loda,r1 R1_BACK_U
	retc,un

end
