.global _main
.align 2

.set RAND_MAX, 0X7FFFFFFF
.set NULL, 0x0
.set GOAL_MASK, 0xFFFF
.set STATE_PLAYING, 0
.set STATE_ASK_REPLAY, 1
.set STATE_ASK_QUIT, 2
.set BUFFER_LEN, 1024
.set READ_LEN, BUFFER_LEN - 1

init_rand:
    stp x29, x30, [sp, 0]!

	mov x0, NULL
	bl _time
	bl _srand
	bl _rand

    ldp x29, x30, [sp], 0
	ret

get_next_goal:
    stp x29, x30, [sp, 0]!

	bl _rand
	and x0, x0, GOAL_MASK
	adrp x1, goal@PAGE
	add x1, x1, goal@PAGEOFF
	str x0, [x1]

    ldp x29, x30, [sp], 0
	ret

get_yn:
    stp x29, x30, [sp, 0]!
	
	.read_loop:
		bl _getchar

		cmp x0, #'Y'
		beq .end

		cmp x0, #'N'
		beq .end

		cmp x0, #'y'
		beq .end

		cmp x0, #'n'
		beq .end

		cmp x0, #10
		beq .end_err

		cmp x0, #-1
		beq .end_err

		b .read_loop

	.end_err:
	mov x0, #0

	.end:
    ldp x29, x30, [sp], 0
	ret

handle_win:
    stp x29, x30, [sp, 0]!

	.win_loop:
		adr x0, quit_msg
		bl _printf
		bl get_yn
		cmp x0, #0
		beq .win_loop
	cmp x0, #'n'
	beq .win_no
	cmp x0, #'N'
	beq .win_no

	.win_yes:
	bl get_next_goal
	adr x0, win_msg
	b .win_end

	.win_no:
	adrp x1, playing@PAGE
	add x1, x1, playing@PAGEOFF
	str xzr, [x1]

	.win_end:
    ldp x29, x30, [sp], 0
	ret

handle_quit:
    stp x29, x30, [sp, 0]!

	.quit_loop:
		adr x0, quit_msg
		bl _printf
		bl get_yn
		cmp x0, #0
		beq .quit_loop
	cmp x0, #'n'
	beq .quit_no
	cmp x0, #'N'
	beq .quit_no

	.quit_yes:
	adrp x1, playing@PAGE
	add x1, x1, playing@PAGEOFF
	str xzr, [x1]
	b .quit_end

	.quit_no:
	adr x0, quit_no_msg
	bl _printf

	.quit_end:
    ldp x29, x30, [sp], 0
	ret

play_game:
    stp x29, x30, [sp, 0]!

	adrp x1, playing@PAGE
	add x1, x1, playing@PAGEOFF
	mov x0, #1
	str x0, [x1]

	.play_loop:
		adrp x1, playing@PAGE
		add x1, x1, playing@PAGEOFF
		ldr x0, [x1]
		cmp x0, #0
		beq .end_play

		adrp x1, buffer@PAGE
		add x1, x1, buffer@PAGEOFF
		mov x0, #0
		mov x2, READ_LEN
		bl _read

		adrp x1, buffer@PAGE
		add x1, x1, buffer@PAGEOFF
		strb wzr, [x1, x0]

		ldrb w0, [x1]
		cmp x0, #'q'
		beq .call_quit

		mov x0, x1
		adr x1, format
		adrp x2, guess@PAGE
		add x2, x2, guess@PAGEOFF
		bl _sscanf
		cmp x0, #0
		beq .bad_input

		adrp x0, guess@PAGE
		add x0, x0, guess@PAGEOFF

		adrp x1, goal@PAGE
		add x1, x1, goal@PAGEOFF

		cmp x0, x1
		beq .call_win
		bgt .say_lower
		.say_higher:
			adr x0, lower_msg
			bl _printf

		b .play_loop
		.bad_input:
			adr x0, bad_input_msg
			bl _printf
			b .play_loop

		.say_lower:
			adr x0, lower_msg
			bl _printf
			b .play_loop

		.call_quit:
			bl handle_quit
			b .play_loop

		.call_win:
			bl handle_win
			b .play_loop

	.end_play:
    ldp x29, x30, [sp], 0
	ret

_main:
    stp x29, x30, [sp, -0x10]!
    sub sp, sp, 0x10

	bl init_rand
	adr x0, start_msg
	bl _printf

	bl play_game

    mov w0, 0
    add sp, sp, 0x10
    ldp x29, x30, [sp], 0x10

	ret

format: .ascii "%ld\0"

start_msg: .ascii "Higher or Lower !\nGuess the random number between 0 and 65635 (inclusive)\n(press 'q' at any time to quit)\n\n\0"

higher_msg: .ascii "Higher !\n\0"

lower_msg: .ascii "Lower !\n\0"

win_msg: .ascii "You found the random number !!\nDo you want to replay ? (Y/N)\n\0"

quit_msg: .ascii "Are you sure you want to quit ? (Y/N)\n\0"

quit_no_msg: .ascii "Waiting for a guess !\n\0"

bad_input_msg: .ascii "This doesn't look like a number...\n\0"

.data

buffer: .space BUFFER_LEN

goal: .space 8

guess: .space 8

playing: .space 8
