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

SID equ 192

jump_table equ 4
putchar equ jump_table+0
run_pgm equ jump_table+3
delay equ jump_table+6
lcd_clr equ jump_table+9
lcd_set_pixel equ jump_table+12
lcd_clr_pixel equ jump_table+15
lcd_inv_pixel equ jump_table+18
lcd_putchar equ jump_table+21
lcd_push_buff equ jump_table+24
puthex equ jump_table+27
newl equ jump_table+30
lcd_get_pixel equ jump_table+33
lcd_puthex equ jump_table+36

PSL_CC1          equ %10000000
PSL_CC0          equ %01000000
PSL_IDC          equ %00100000
PSL_BANK         equ %00010000
PSL_WITH_CARRY   equ %00001000
PSL_OVERFLOW     equ %00000100
PSL_LOGICAL_COMP equ %00000010
PSL_CARRY_FLAG   equ %00000001

snek_max_length equ 200
snek_initial_length equ 15
snek_start_x equ 32
snek_start_y equ 32
field_y_offset equ 11
field_height equ 64-field_y_offset
field_width equ 128
; X and Y snek coords stored in separate lists, so indexed addressing works

	org $6000
start:
	lodi,r0 PSL_LOGICAL_COMP
	lpsl
	lodi,r0 32
	lpsu
	
	lodi,r0 254
	wrte,r0 PW1
	clr r0
	wrte,r0 SID+7
	wrte,r0 SID+8
	clr r0
	wrte,r0 SID+2
	lodi,r0 $08
	wrte,r0 SID+3
	lodi,r0 $30
	wrte,r0 SID+5
	lodi,r0 $F2
	wrte,r0 SID+6
	
	lodi,r3 255
clear_loop:
	lodi,r0 255
	stra,r0 snek_buff,r3+
	stra,r0 snek_buff+snek_max_length,r3
	comi,r3 snek_max_length-1
	bcfr,eq clear_loop
	
	lodi,r3 255
	lodi,r2 snek_start_x
initial_snek_loop:
	lodz r2
	stra,r0 snek_buff,r3+
	lodi,r0 snek_start_y
	stra,r0 snek_buff+snek_max_length,r3
	addi,r2 1
	comi,r3 snek_initial_length-1
	bcfr,eq initial_snek_loop
	
	clr r0
	stra,r0 score
	stra,r0 snek_dir
	stra,r0 debug_on
	stra,r0 sid_step
	lodi,r0 5
	stra,r0 timeout
	lodi,r0 snek_initial_length
	stra,r0 snek_curr_length
	
	bsta,un place_snack

	lodi,r0 255
	wrte,r0 T2TOP_LO
	wrte,r0 T2TOP_HI
	wrte,r0 T2PRE_LO
	wrte,r0 T2PRE_HI
	clr r0
	wrte,r0 T2CD_LO
	wrte,r0 T2CD_HI
game_loop:
	wrte,r0 TCR
	rede,r0 T2CD_LO
	comi,r0 28
	bctr,lt game_loop
	clr r0
	wrte,r0 T2CD_LO
	wrte,r0 T2CD_HI
	bsta,un xorshift
	
	loda,r0 sid_step
	comi,r0 1
	bctr,eq sid_step_1
	comi,r0 2
	bctr,eq sid_step_2
	
	bctr,un sid_done
sid_step_1:
	lodi,r0 2
	stra,r0 sid_step
	lodi,r0 8858&255
	wrte,r0 SID+0
	lodi,r0 8858>>8
	wrte,r0 SID+1
	bctr,un sid_done
sid_step_2:
	clr r0
	stra,r0 sid_step
	lodi,r0 %01000000
	wrte,r0 SID+4
	bctr,un sid_done
sid_done:
	
	loda,r0 score
	addz r0
	strz r3
	lodi,r0 254
	subz r3
	wrte,r0 PW1
	
	ppsl PSL_BANK
	rede,r3 PINA
	rrr,r3
	rrr,r3
	rrr,r3
	andi,r3 %00010111
	loda,r0 snek_dir
	andi,r0 2
	bcfr,0 snek_can_go_left_or_right
snek_can_go_up_or_down:
	lodz r3
	andi,r3 1
	bctr,0 snek_going_up
	andi,r0 4
	bctr,0 snek_going_down
	bctr,un snek_inputs_done
snek_can_go_left_or_right:
	lodz r3
	andi,r3 16
	bctr,0 snek_going_left
	andi,r0 2
	bctr,0 snek_going_right
	bctr,un snek_inputs_done
snek_going_up:
	lodi,r0 2
	stra,r0 snek_dir
	bctr,un snek_inputs_done
snek_going_down:
	lodi,r0 3
	stra,r0 snek_dir
	bctr,un snek_inputs_done
snek_going_left:
	clr r0
	stra,r0 snek_dir
	bctr,un snek_inputs_done
snek_going_right:
	lodi,r0 1
	stra,r0 snek_dir
	bctr,un snek_inputs_done
snek_inputs_done:
	rede,r0 PINB
	andi,r0 2
	bcfr,0 no_debug_enable
	lodi,r0 1
	stra,r0 debug_on
no_debug_enable:
	cpsl PSL_BANK
	
	bsta,un snek_step
	
	nop
	loda,r0 timeout
	bctr,0 snack_check
	subi,r0 1
	stra,r0 timeout
	bcta,un no_collision

snack_check:
	ppsl PSL_BANK
	loda,r0 snek_buff ; Head pos x
	coma,r0 snack_location
	bcfr,eq collision_check
	loda,r1 snek_buff+snek_max_length ; Head pos y
	coma,r1 snack_location+1
	bctr,eq eat_snack
collision_check:
	loda,r0 snek_buff ; Head pos x
	loda,r1 snek_buff+snek_max_length ; Head pos y
	addi,r1 field_y_offset
	bstf,un lcd_get_pixel
	comi,r0 0
	bctr,eq no_collision
	bsta,un game_over
eat_snack:
	loda,r0 score
	comi,r0 $99
	bcfr,lt max_score_reached
	addi,r0 $66
	addi,r0 1
	dar r0
	stra,r0 score
max_score_reached:
	bsta,un place_snack
	bsta,un snek_extend
	; Beep
	lodi,r0 5096&255
	wrte,r0 SID+0
	lodi,r0 5096>>8
	wrte,r0 SID+1
	lodi,r0 $8F
	wrte,r0 SID+24
	lodi,r0 %01000001
	wrte,r0 SID+4
	lodi,r0 1
	stra,r0 sid_step
	
no_collision:
	cpsl PSL_BANK
	
	bsta,un render
	
	bctf,un game_loop

game_over_str:
	db "You are ded!",0
game_over:
	cpsl PSL_BANK
	bsta,un render
	lodi,r3 15
	stra,r3 snek_temp
	lodi,r3 255
game_over_str_loop:
	loda,r0 game_over_str,r3+
	strz r2
	bctr,0 game_over_str_loop_end
	loda,r0 snek_temp
	addi,r0 7
	stra,r0 snek_temp
	lodi,r1 28
	bstf,un lcd_putchar
	bctr,un game_over_str_loop
game_over_str_loop_end:
	bstf,un lcd_push_buff

	lodi,r0 4004&255
	wrte,r0 SID+0
	lodi,r0 4004>>8
	wrte,r0 SID+1
	lodi,r0 %01000001
	wrte,r0 SID+4
	clr r0
tone_delay_1:
	lodi,r1 150
tone_delay_2:
	lodi,r3 205
tone_delay_3:
	nop
	nop
	nop
	bira,r3 tone_delay_3
	nop
	bdrr,r1 tone_delay_2
	nop
	bdrf,r0 tone_delay_1
	lodi,r0 %01000000
	wrte,r0 SID+4

wait_for_flag:
	tpsu 128
	bctr,0 wait_for_flag
	bctf,un start

timeout:
	db 0
snek_temp:
	db 0
snek_curr_length:
	db 0
snek_dir:
	db 0
snek_step:
	lodr,r3 snek_curr_length
	subi,r3 1
snek_step_loop:
	loda,r0 snek_buff,r3-
	stra,r0 snek_buff,r3+
	loda,r0 snek_buff+snek_max_length,r3-
	stra,r0 snek_buff+snek_max_length,r3+
	subi,r3 1
	comi,r3 0
	bcfr,eq snek_step_loop
	lodi,r0 1
	comr,r0 snek_dir
	bctr,eq snek_go_right
	lodi,r0 2
	comr,r0 snek_dir
	bctr,eq snek_go_up
	addi,r0 1
	comr,r0 snek_dir
	bctr,eq snek_go_down
snek_go_left:
	loda,r0 snek_buff
	subi,r0 1
	andi,r0 127
	stra,r0 snek_buff
	retc,un
snek_go_right:
	loda,r0 snek_buff
	addi,r0 1
	andi,r0 127
	stra,r0 snek_buff
	retc,un
snek_go_up:
	loda,r0 snek_buff+snek_max_length
	subi,r0 1
	comi,r0 255
	bcfr,eq snek_go_up_no_clip
	lodi,r0 field_height-1
snek_go_up_no_clip:
	stra,r0 snek_buff+snek_max_length
	retc,un
snek_go_down:
	loda,r0 snek_buff+snek_max_length
	addi,r0 1
	comi,r0 field_height
	bctr,lt snek_go_down_no_clip
	clr r0
snek_go_down_no_clip:
	stra,r0 snek_buff+snek_max_length
	retc,un

snek_extend:
	loda,r0 snek_curr_length
	comi,r0 snek_max_length
	bcfr,lt snek_max_length_reached
	addi,r0 1
	stra,r0 snek_curr_length
	strz r3
	subi,r3 1
	lodi,r0 255 ; Careful! Must skip rendering this!
	stra,r0 snek_buff,r3
	stra,r0 snek_buff+snek_max_length,r3
snek_max_length_reached:
	retc,un

render:
	bstf,un lcd_clr
	clr r0
line_loop:
	lodi,r1 field_y_offset-1
	bstf,un lcd_set_pixel
	addi,r0 1
	comi,r0 128
	bcfr,eq line_loop
	
	loda,r2 snek_curr_length
snek_render_loop:
	loda,r0 snek_buff+snek_max_length,r2-
	comi,r0 255
	bctr,eq snek_render_loop_skip
	strz r1
	loda,r0 snek_buff,r2
	addi,r1 field_y_offset
	bstf,un lcd_set_pixel
snek_render_loop_skip:
	comi,r2 0
	bcfr,eq snek_render_loop
	
	loda,r2 score
	rrr,r2
	rrr,r2
	rrr,r2
	rrr,r2
	andi,r2 15
	addi,r2 '0'
	clr r0
	clr r1
	bstf,un lcd_putchar
	loda,r2 score
	andi,r2 15
	addi,r2 '0'
	lodi,r0 7
	clr r1
	bstf,un lcd_putchar
	
	clr r0
	coma,r0 debug_on
	bctr,eq snek_render_no_debug
	lodi,r0 21
	clr r1
	loda,r2 snack_location
	bstf,un lcd_puthex
	lodi,r0 35
	clr r1
	loda,r2 snack_location+1
	bstf,un lcd_puthex
	lodi,r0 56
	clr r1
	loda,r2 snek_buff
	bstf,un lcd_puthex
	lodi,r0 70
	clr r1
	loda,r2 snek_buff+snek_max_length
	bstf,un lcd_puthex
snek_render_no_debug:
	
	loda,r0 snack_location
	loda,r1 snack_location+1
	addi,r1 field_y_offset
	bstf,un lcd_set_pixel

	bstf,un lcd_push_buff
	retc,un

place_snack:
	bsta,un xorshift
	bsta,un xorshift
	loda,r1 xorshift_state+2
	andi,r1 63
	comi,r1 field_height
	bcfr,lt place_snack
	loda,r2 xorshift_state
	andi,r2 127
	
	loda,r3 snek_curr_length
place_check_loop:
	loda,r0 snek_buff,r3-
	comz r2
	bcfr,eq place_check_continue
	loda,r0 snek_buff+snek_max_length,r3
	comz r1
	bctr,eq place_snack
place_check_continue:
	comi,r3 0
	bcfr,eq place_check_loop
	
	stra,r2 snack_location
	stra,r1 snack_location+1
	
	retc,un

xorshift_backs:
	db 0
xorshift_state:
	db 69,193,102,2
xorshift:
	spsl
	stra,r0 xorshift_backs
	ppsl PSL_WITH_CARRY
	cpsl PSL_BANK
	lodi,r0 5
	loda,r1 xorshift_state
	loda,r2 xorshift_state+1
	loda,r3 xorshift_state+2
xorshift_loop_1:
	cpsl PSL_CARRY_FLAG
	rrl,r1
	rrl,r2
	rrl,r3
	bdrr,r0 xorshift_loop_1

	eora,r0 xorshift_state
	eora,r1 xorshift_state+1
	eora,r2 xorshift_state+2
	eora,r3 xorshift_state+3
	lodz r3
	strz r1
	lodz r2
	lodi,r2 0
	lodi,r3 0
	cpsl PSL_CARRY_FLAG
	rrr,r1
	rrr,r0
	eora,r0 xorshift_state
	eora,r1 xorshift_state+1
	eora,r2 xorshift_state+2
	eora,r3 xorshift_state+3

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

	eora,r0 xorshift_state
	eora,r1 xorshift_state+1
	eora,r2 xorshift_state+2
	eora,r3 xorshift_state+3
	stra,r0 xorshift_state
	stra,r1 xorshift_state+1
	stra,r2 xorshift_state+2
	stra,r3 xorshift_state+3
	loda,r0 xorshift_backs
	lpsl
	retc,un

sid_step:
	db 0
snack_location:
	db 0,0
score:
	db 0
debug_on:
	db 0
snek_buff:
	db 0
