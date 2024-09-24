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

lcd_buff_start equ 8192

	org 0
start:
	nop
	bcta,un start_actual
jump_table:
	bcta,un putchar
	bcta,un run_pgm
	bcta,un lcd_delay
	bcta,un lcd_clr
	bcta,un lcd_set_pixel
	bcta,un lcd_clr_pixel
	bcta,un lcd_inv_pixel
	bcta,un lcd_putchar
	bcta,un lcd_push_buff
	bcta,un puthex
	bcta,un newl
	bcta,un lcd_get_pixel
	bcta,un lcd_puthex
start_actual:
	lodi,r0 0
	lpsl
	lodi,r0 32
	lpsu
	
	lodi,r0 %01000011
	wrte,r0 DDRA
	eorz,r0
	wrte,r0 PORTA
	lodi,r0 %00001001
	wrte,r0 DDRB
	lodi,r0 %00001001
	wrte,r0 PORTB
	lodi,r0 %01000110
	wrte,r0 SPA
	lodi,r0 %11110100
	wrte,r0 SPB
	lodi,r0 240
	wrte,r0 PW1
	
	lodi,r0 3
	wrte,r0 UDIV_LO
	lodi,r0 1
	wrte,r0 UDIV_HI
	lodi,r0 1
	wrte,r0 SDIV
	
	lodi,r0 255
	wrte,r0 T0TOP_LO
	wrte,r0 T0TOP_HI
	eorz,r0
	wrte,r0 T0PRE_LO
	wrte,r0 T0PRE_HI
	lodi,r0 %01000000
	wrte,r0 TS
	clr r0
	wrte,r0 T0CD_LO
	wrte,r0 T0CD_HI
	
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
	bsta,un lcd_push_buff
	bsta,un lcd_clr
	lodi,r3 16
longer_delay_loop:
	bsta,un lcd_delay
	bdrr,r3 longer_delay_loop
	bsta,un lcd_push_buff
	
	lodi,r1 8
chirp_loop:
	chrp
	bsta,un putchar
	bdrr,r1 chirp_loop
	
	eorz,r0
	stra,r0 lcd_push_buff_vars
	lodi,r3 6
chirp_loop2:
	chrp
	strz r2
	loda,r0 lcd_push_buff_vars
	addi,r0 7
	stra,r0 lcd_push_buff_vars
	clr r1
	bstf,un lcd_putchar
	bdrr,r3 chirp_loop2
	lodi,r3 6
longer_delay_loop2:
	bsta,un lcd_delay
	bdrr,r3 longer_delay_loop2
	
	bsta,un lcd_push_buff
	
	tpsu 128
	bcfr,0 BADAPPLEBADAPPLEBADAPPLE
	lodi,r0 0
	bctr,un run_pgm

BADAPPLEBADAPPLEBADAPPLE:
	lodi,r0 1
	bctr,un run_pgm

rom_tx:
	wrte,r1 STX
rom_tx_spi_wait:
	rede,r1 STAT
	andi,r1 3
	bcfr,0 rom_tx_spi_wait
	rede,r1 SRX
	retc,un

run_pgm_vars:
	db 0,0
run_pgm:
	ppsl 8
	rede,r1 PORTB
	andi,r1 $FE
	wrte,r1 PORTB
	lodi,r1 $03
	bstr,un rom_tx
	lodi,r1 $60
	strr,r1 run_pgm_vars
	clr r1
	strr,r1 run_pgm_vars+1
	cpsl 1
	addi,r0 1
	lodi,r1 $20
	mul
	bstr,un rom_tx
	strz r1
	bstr,un rom_tx
	lodi,r1 0
	bstr,un rom_tx
	lodi,r3 32
load_pgm_loop:
	lodi,r2 0
load_pgm_loop_inner:
	lodi,r1 $FF
	lodz r1
	bstr,un rom_tx
	strr,r1 *run_pgm_vars
	cpsl 1
	lodr,r1 run_pgm_vars+1
	addi,r1 1
	strr,r1 run_pgm_vars+1
	lodr,r1 run_pgm_vars
	addi,r1 0
	strr,r1 run_pgm_vars
	bdrr,r2 load_pgm_loop_inner
	bdrr,r3 load_pgm_loop
	
	rede,r1 PORTB
	iori,r1 1
	wrte,r1 PORTB
	
	bctf,un $6000

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

lcd_delay:
	stra,r0 lcd_putchar_vars
	stra,r1 lcd_putchar_vars+1
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
	loda,r0 lcd_putchar_vars
	loda,r1 lcd_putchar_vars+1
	retc,un

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

lcd_clr:
	stra,r0 lcd_push_buff_vars
	stra,r1 lcd_push_buff_vars+1
	stra,r2 lcd_push_buff_vars+2
	stra,r3 lcd_push_buff_vars+3
	spsl
	stra,r0 lcd_push_buff_vars+6
	lodi,r0 lcd_buff_start&255
	stra,r0 lcd_push_buff_vars+5
	lodi,r0 lcd_buff_start>>8
	stra,r0 lcd_push_buff_vars+4
	
	ppsl 8
	lodi,r1 4
lcd_clr_loop_outer:
	lodi,r3 0
	lodi,r2 0
lcd_clr_loop:
	strr,r2 *lcd_push_buff_vars+4
	cpsl 1
	loda,r0 lcd_push_buff_vars+5
	addi,r0 1
	stra,r0 lcd_push_buff_vars+5
	loda,r0 lcd_push_buff_vars+4
	addi,r0 0
	stra,r0 lcd_push_buff_vars+4
	bdrr,r3 lcd_clr_loop
	bdrr,r1 lcd_clr_loop_outer
	loda,r0 lcd_push_buff_vars+6
	lpsl
	loda,r0 lcd_push_buff_vars
	loda,r1 lcd_push_buff_vars+1
	loda,r2 lcd_push_buff_vars+2
	loda,r3 lcd_push_buff_vars+3
	retc,un

lcd_push_buff_vars:
	db 0,0,0,0,0,0,0
lcd_push_buff:
	strr,r0 lcd_push_buff_vars
	strr,r1 lcd_push_buff_vars+1
	strr,r2 lcd_push_buff_vars+2
	strr,r3 lcd_push_buff_vars+3
	spsl
	strr,r0 lcd_push_buff_vars+6
	ppsl 8
lcd_push_buff_skip:
	clr r1
	lodi,r0 lcd_buff_start&255
	strr,r0 lcd_push_buff_vars+5
	lodi,r0 lcd_buff_start>>8
	strr,r0 lcd_push_buff_vars+4
lcd_push_loop_outer:
	; Into command mode
	rede,r3 PORTA
	andi,r3 $FE
	wrte,r3 PORTA
	; Set page
	ppsl 1
	lodi,r0 7
	subz r1
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
	lodi,r2 128
lcd_push_loop_inner:
	lodr,r0 *lcd_push_buff_vars+4
	bsta,un lcd_tx
	
	cpsl 1
	loda,r0 lcd_push_buff_vars+5
	addi,r0 1
	stra,r0 lcd_push_buff_vars+5
	loda,r0 lcd_push_buff_vars+4
	addi,r0 0
	stra,r0 lcd_push_buff_vars+4
	
	bdrr,r2 lcd_push_loop_inner
	addi,r1 1
	comi,r1 8
	bcfr,eq lcd_push_loop_outer
	loda,r0 lcd_push_buff_vars+6
	lpsl
	loda,r0 lcd_push_buff_vars
	loda,r1 lcd_push_buff_vars+1
	loda,r2 lcd_push_buff_vars+2
	loda,r3 lcd_push_buff_vars+3
	retc,un

last_px:
	db 255,255,0,0
lcd_buff_pos:
	db 0,0

lcd_compute_pos:
	comr,r0 last_px
	bcfr,eq lcd_compute_continue
	comr,r1 last_px+1
	bctr,eq lcd_compute_pos_skip
lcd_compute_continue:
	strr,r0 last_px
	strr,r1 last_px+1
	lodi,r0 127
	ppsl 1
	subr,r0 last_px
	strr,r0 last_px+2
	lodi,r1 63
	subr,r1 last_px+1
	strr,r1 last_px+3
	
	spsl
	stra,r0 lcd_push_buff_vars+6
	ppsl 8
	; y / 8 * 128 + x
	; (y & $F8) * 16 + x
	lodz r1
	andi,r0 $F8
	lodi,r1 16
	mul
	cpsl 1
	addr,r0 last_px+2
	addi,r1 0
	cpsl 1
	addi,r0 lcd_buff_start&255
	addi,r1 lcd_buff_start>>8
	strr,r0 lcd_buff_pos+1
	strr,r1 lcd_buff_pos
	loda,r0 lcd_push_buff_vars+6
	lpsl
	loda,r0 last_px
	loda,r1 last_px+3
lcd_compute_pos_skip:
	retc,un

lcd_bit_pos_comp:
	lodi,r0 7
	ppsl 1
	subz r1
	andi,r0 7
	loda,r0 lsh_lut,r0
	loda,r1 *lcd_buff_pos
	retc,un

lcd_set_pixel:
	bsta,un lcd_compute_pos
	bstr,un lcd_bit_pos_comp
	iorz r1
	stra,r0 *lcd_buff_pos
	loda,r0 last_px
	loda,r1 last_px+1
	retc,un

lcd_clr_pixel:
	bsta,un lcd_compute_pos
	bstr,un lcd_bit_pos_comp
	cpl r0
	andz r1
	stra,r0 *lcd_buff_pos
	loda,r0 last_px
	loda,r1 last_px+1
	retc,un

lcd_inv_pixel:
	bsta,un lcd_compute_pos
	bstr,un lcd_bit_pos_comp
	eorz r1
	stra,r0 *lcd_buff_pos
	loda,r0 last_px
	loda,r1 last_px+1
	retc,un

lcd_get_pixel:
	bsta,un lcd_compute_pos
	bsta,un lcd_bit_pos_comp
	andz r1
	loda,r1 last_px+1
	retc,un

lcd_putchar_vars:
	db 0,0,0,0,0,0,0,0
lcd_putchar:
	strr,r0 lcd_putchar_vars
	strr,r1 lcd_putchar_vars+1
	strr,r2 lcd_putchar_vars+2
	strr,r3 lcd_putchar_vars+3
	spsl
	strr,r0 lcd_putchar_vars+4
	ppsl 9
	subi,r2 ' '
	clr r3
	strr,r3 lcd_putchar_vars+5
	
	cpsl 1
	rrl,r2
	rrl,r3
	rrl,r2
	rrl,r3
	rrl,r2
	rrl,r3
	addi,r2 font&255
	addi,r3 font>>8
	bctr,un lcd_putchar_loop_begin
lcd_putchar_outer:
	lodr,r2 lcd_putchar_vars+7
	lodr,r3 lcd_putchar_vars+6
lcd_putchar_loop_begin:
	lir
	cpsl 1
	addi,r2 1
	addi,r3 0
	strr,r2 lcd_putchar_vars+7
	strr,r3 lcd_putchar_vars+6
	strz r2
	lodr,r0 lcd_putchar_vars+1
	lodr,r3 lcd_putchar_vars+5
	addz,r3
	cpsl 1
	addi,r3 1
	stra,r3 lcd_putchar_vars+5
	loda,r1 lcd_putchar_vars
	xchg
	lodi,r3 7
lcd_putchar_inner:
	rrr,r2
	tpsl 1
	bcfr,0 lcd_putchar_clear
	bsta,un lcd_set_pixel
	bctr,un lcd_putchar_set
lcd_putchar_clear:
	bsta,un lcd_clr_pixel
lcd_putchar_set:
	
	cpsl 1
	addi,r0 1
	bdrr,r3 lcd_putchar_inner
	loda,r3 lcd_putchar_vars+5
	comi,r3 8
	bcfa,eq lcd_putchar_outer
	
	loda,r0 lcd_putchar_vars+4
	lpsl
	loda,r3 lcd_putchar_vars+3
	loda,r2 lcd_putchar_vars+2
	loda,r1 lcd_putchar_vars+1
	loda,r0 lcd_putchar_vars+0
	retc,un

hexchars:
	db "0123456789ABCDEF"
puthex_vars:
	db 0,0
puthex:
	strr,r0 puthex_vars
	rrr r0
	rrr r0
	rrr r0
	rrr r0
	andi,r0 15
	loda,r0 hexchars,r0
	bsta,un putchar
	lodr,r0 puthex_vars
	andi,r0 15
	loda,r0 hexchars,r0
	bsta,un putchar
	lodr,r0 puthex_vars
	retc,un

newl:
	strr,r0 puthex_vars
	lodi,r0 13
	bsta,un putchar
	lodi,r0 10
	bsta,un putchar
	lodr,r0 puthex_vars
	retc,un

lcd_puthex:
	stra,r2 puthex_vars
	stra,r3 puthex_vars+1
	rrr r2
	rrr r2
	rrr r2
	rrr r2
	andi,r2 15
	strz r3
	loda,r0 hexchars,r2
	strz r2
	lodz r3
	bsta,un lcd_putchar
	cpsl 1
	addi,r0 7
	loda,r2 puthex_vars
	andi,r2 15
	strz r3
	loda,r0 hexchars,r2
	strz r2
	lodz r3
	bsta,un lcd_putchar
	loda,r2 puthex_vars
	loda,r3 puthex_vars+1
	retc,un

lsh_lut:
	db 1,2,4,8,16,32,64,128,0
lcd_rst_seq: ;FF indicates delay required, 00 is end of sequence
	db $A2, $A0, $C0, $40, $2C, $FF, $2E, $FF, $2F, $FF, $27, $AF, $A4, $81, 19, $00

font:
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $04,$04,$04,$04,$04,$04,$00,$04
	db $0a,$0a,$0a,$00,$00,$00,$00,$00
	db $0a,$0a,$1f,$0a,$0a,$1f,$0a,$0a
	db $04,$1e,$05,$05,$0e,$14,$0f,$04
	db $00,$00,$12,$08,$04,$02,$09,$00
	db $06,$09,$09,$09,$06,$16,$09,$16
	db $02,$02,$00,$00,$00,$00,$00,$00
	db $04,$02,$01,$01,$01,$01,$02,$04
	db $04,$08,$10,$10,$10,$10,$08,$04
	db $00,$04,$15,$0e,$15,$04,$00,$00
	db $00,$04,$04,$1f,$04,$04,$00,$00
	db $00,$00,$00,$00,$00,$04,$04,$04
	db $00,$00,$00,$0e,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$04
	db $00,$00,$10,$08,$04,$02,$01,$00
	db $0e,$11,$19,$15,$15,$13,$11,$0e
	db $18,$14,$10,$10,$10,$10,$10,$10
	db $0e,$11,$10,$08,$04,$02,$01,$1f
	db $0e,$11,$10,$0e,$10,$10,$11,$0e
	db $18,$14,$12,$11,$1f,$10,$10,$10
	db $1f,$01,$01,$0e,$10,$10,$11,$0e
	db $0e,$11,$01,$0f,$11,$11,$11,$0e
	db $1f,$10,$10,$08,$04,$04,$04,$04
	db $0e,$11,$11,$0e,$11,$11,$11,$0e
	db $0e,$11,$11,$1e,$10,$10,$11,$0e
	db $00,$04,$00,$00,$00,$00,$04,$00
	db $00,$04,$00,$00,$00,$00,$04,$04
	db $00,$08,$04,$02,$01,$02,$04,$08
	db $00,$00,$1f,$00,$00,$1f,$00,$00
	db $00,$02,$04,$08,$10,$08,$04,$02
	db $0e,$11,$10,$08,$04,$04,$00,$04
	db $0e,$11,$10,$10,$16,$15,$15,$0e
	db $0e,$11,$11,$11,$1f,$11,$11,$11
	db $0f,$11,$11,$0f,$11,$11,$11,$0f
	db $0e,$01,$01,$01,$01,$01,$01,$0e
	db $0f,$11,$11,$11,$11,$11,$11,$0f
	db $1f,$01,$01,$1f,$01,$01,$01,$1f
	db $1f,$01,$01,$1f,$01,$01,$01,$01
	db $0e,$11,$11,$01,$1d,$11,$11,$0e
	db $11,$11,$11,$1f,$11,$11,$11,$11
	db $04,$04,$04,$04,$04,$04,$04,$04
	db $08,$08,$08,$08,$08,$08,$0a,$04
	db $11,$09,$05,$03,$03,$05,$09,$11
	db $01,$01,$01,$01,$01,$01,$01,$0f
	db $11,$1b,$15,$11,$11,$11,$11,$11
	db $11,$11,$13,$15,$19,$11,$11,$11
	db $0e,$11,$11,$11,$11,$11,$11,$0e
	db $0f,$11,$11,$0f,$01,$01,$01,$01
	db $0e,$11,$11,$11,$11,$15,$19,$1e
	db $0f,$11,$11,$0f,$11,$11,$11,$11
	db $0e,$11,$01,$0e,$10,$10,$11,$0e
	db $1f,$04,$04,$04,$04,$04,$04,$04
	db $11,$11,$11,$11,$11,$11,$11,$0e
	db $11,$11,$11,$11,$11,$11,$0a,$04
	db $11,$11,$11,$11,$11,$15,$1b,$11
	db $11,$11,$11,$0a,$04,$0a,$11,$11
	db $11,$11,$11,$0a,$04,$04,$04,$04
	db $1f,$10,$08,$04,$04,$02,$01,$1f
	db $0e,$02,$02,$02,$02,$02,$02,$0e
	db $00,$00,$01,$02,$04,$08,$10,$00
	db $0e,$08,$08,$08,$08,$08,$08,$0e
	db $04,$0a,$11,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$1f
	db $02,$04,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$0e,$10,$1e,$11,$1e
	db $01,$01,$01,$01,$0d,$13,$11,$0f
	db $00,$00,$00,$0e,$01,$01,$01,$0e
	db $10,$10,$10,$16,$19,$11,$11,$1e
	db $00,$00,$00,$0e,$11,$1f,$01,$0e
	db $0c,$12,$02,$02,$07,$02,$02,$02
	db $00,$00,$00,$1e,$11,$1e,$10,$0e
	db $00,$01,$01,$01,$0d,$13,$11,$11
	db $00,$04,$00,$06,$04,$04,$04,$0e
	db $00,$08,$00,$0c,$08,$08,$0a,$04
	db $00,$01,$01,$09,$05,$03,$05,$09
	db $00,$06,$04,$04,$04,$04,$04,$0e
	db $00,$00,$00,$00,$0b,$15,$15,$11
	db $00,$00,$00,$0d,$13,$11,$11,$11
	db $00,$00,$00,$0e,$11,$11,$11,$0e
	db $00,$00,$00,$0f,$11,$0f,$01,$01
	db $00,$00,$00,$16,$19,$16,$10,$10
	db $00,$00,$00,$0d,$13,$01,$01,$01
	db $00,$00,$00,$0e,$01,$0e,$10,$0f
	db $00,$02,$02,$07,$02,$02,$12,$0c
	db $00,$00,$00,$11,$11,$11,$19,$16
	db $00,$00,$00,$11,$11,$11,$0a,$04
	db $00,$00,$00,$11,$11,$15,$15,$0a
	db $00,$00,$00,$11,$0a,$04,$0a,$11
	db $00,$00,$00,$11,$11,$1e,$10,$0e
	db $00,$00,$00,$1f,$08,$04,$02,$1f
	db $00,$04,$02,$02,$01,$02,$02,$04
	db $04,$04,$04,$04,$04,$04,$04,$04
	db $00,$04,$08,$08,$10,$08,$08,$04
	db $00,$00,$00,$12,$15,$09,$00,$00
