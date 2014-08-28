/*
 * SnakeAssembly.asm
 *
 *  Created: 2014-04-25 15:33:11
 *   Author: BQ & TF
 */
 .DEF snakeLength = r22
 .DEF rTemp2 = r14
 .DEF rTemp = r16
 //setup buffers
 .DEF bufferportb = r17
 .DEF bufferportc = r18
 .DEF bufferportd = r19
 .DEF rowNumber = r21
 .DEF matrixData = r24
 .DEF direction = r20
 .DEF delay = r23
 .DEF moreDelay = r25

 .EQU SNAKE_MAX_SIZE = 25

 .DSEG
matrix: .BYTE 8
snakeX: .BYTE SNAKE_MAX_SIZE + 1
snakeY: .BYTE SNAKE_MAX_SIZE + 1

.CSEG // Code segment
.ORG 0x0000
	jmp init // Reset vector
	nop
.ORG 0x0020
	//jmp isr_timer0F // Timer 0 overflow vector 
	nop
 
.ORG INT_VECTORS_SIZE
init:
	ldi delay, 0
	ldi moreDelay, 0
	//set up stack pointer
	ldi rTemp, HIGH(RAMEND)
	out SPH, rTemp
	ldi rTemp, LOW(RAMEND)
	out SPL, rTemp

	//init snake
	ldi snakeLength, 6

	ldi ZH, HIGH(snakeX)
	ldi ZL, LOW(snakeX)
	ldi rTemp, 1
	lsl rTemp
	lsl rTemp
	lsl rTemp
	lsl rTemp
	st Z, rTemp

	ldi rTemp, 1
	initSnakeX:
		adiw Z, 1
		ldi rowNumber, 0
		st Z, rowNumber
		cpi rTemp, SNAKE_MAX_SIZE
		subi rTemp, -1
		brne initSnakeX

	ldi ZH, HIGH(snakeY)
	ldi ZL, LOW(snakeY)

	ldi rTemp, 4
	st Z, rTemp

	ldi rTemp, 1
	initSnakeY:
		adiw Z, 1
		ldi rowNumber, 0
		st Z, rowNumber
		cpi rTemp, SNAKE_MAX_SIZE
		subi rTemp, -1
		brne initSnakeY

	//set up i/o
	//port b
	ldi rTemp, 0b0011_1111
	out DDRB, rTemp
	//port c
	ldi rTemp, 0b0000_1111
	out DDRC, rTemp
	//port d
	ldi rTemp, 0b1111_1100
	out DDRD, rTemp

	//initialize A/D converter
	lds rTemp, ADMUX
	ori rTemp, 0b01000000
	sts ADMUX, rTemp

	lds rTemp, ADCSRA
	ori rTemp, 0b10000111
	sts ADCSRA, rTemp

	rcall resetMatrix
	
	
	//make sure it's off
	ldi rTemp, 0
	out PORTB, rTemp
	out PORTC, rTemp
	out PORTD, rTemp
	jmp framebuffer

framebuffer_column_loop:
	mov rTemp, matrixData
	lsl rTemp
	lsl rTemp
	lsl rTemp
	lsl rTemp
	lsl rTemp
	lsl rTemp
	or bufferportd, rTemp

	mov rTemp, matrixData
	lsr rTemp
	lsr rTemp
	or bufferportb, rTemp

	ret
	
framebuffer_row_loop:
	ldi rTemp, 0
	out PORTC, rTemp

	mov rTemp, rowNumber
	andi rTemp, 0b0000_1111
	or bufferportc, rTemp

	ldi rTemp, 0
	out PORTD, rTemp

	mov rTemp, rowNumber
	lsr rTemp
	lsr rTemp
	lsr rTemp
	lsr rTemp

	lsl rTemp
	lsl rTemp
	or bufferportd, rTemp

	ret
framebuffer:
	//see if iterator is done for the frame, go to game logic

	ldi rowNumber, 0b0000_0001
	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)
	
	framebuffer_loop:
		ldi bufferportb, 0
		ldi bufferportc, 0
		ldi bufferportd, 0

		ld matrixData, Y

		rcall framebuffer_row_loop
		rcall framebuffer_column_loop
		adiw Y, 1

		//execute buffers
		out PORTB, bufferportb
		out PORTC, bufferportc
		out PORTD, bufferportd
		

		//increase iterator and loop
		lsl rowNumber

		cpi rowNumber, 0
		breq gamelogic
		nop

		jmp framebuffer_loop

draw:
	rcall resetMatrix
	ldi rowNumber, 1
	sendToFramebuffer:
		rcall drawPixelsY
		cp rowNumber, snakeLength
		breq framebuffer
		subi rowNumber, -1
		jmp sendToFramebuffer

gamelogic:
	ldi rTemp, 25
	sub rTemp, snakeLength
	lsl rTemp

	subi delay, -1
	cp delay, rTemp
	brlo draw
	ldi delay, 0

	subi moreDelay, -1
	cp moreDelay, rTemp
	brlo draw
	ldi moreDelay, 0

	ldi rTemp, 1
	ldi ZH, HIGH(snakeX)
	ldi ZL, LOW(snakeX)
	rcall tailGotoBack
	rcall tailLoop
	ldi rTemp, 1
	ldi ZH, HIGH(snakeY)
	ldi ZL, LOW(snakeY)
	rcall tailGotoBack
	rcall tailLoop

	rcall getJoyX
	rcall AD
	cpi rTemp, 100
	brlo goRight
	cpi rTemp, 150
	brsh goLeft 
	rcall getJoyY
	rcall AD
	cpi rTemp, 150
	brsh goUp
	cpi rTemp, 100
	brlo goDown

	cpi direction, 0
	breq goRight
	cpi direction, 2
	breq goLeft
	cpi direction, 3
	breq goUp
	cpi direction, 1
	brsh goDown
	jmp drawShortcut

drawShortcut:
	jmp draw
			
goLeft:
	cpi direction, 0
	breq goRight
	ldi direction, 2
	ldi ZH, HIGH(snakeX)
	ldi ZL, LOW(snakeX)
	ld rTemp, Z
	lsr rTemp
	cpi rTemp, 0
	breq resetLeft
	st Z, rTemp
	brne drawShortcut
	resetLeft:
		ldi rTemp, 0b10000000
		st Z, rTemp
		jmp draw
	
goRight:
	cpi direction, 2
	breq goLeft
	ldi direction, 0
	ldi ZH, HIGH(snakeX)
	ldi ZL, LOW(snakeX)
	ld rTemp, Z
	lsl rTemp
	cpi rTemp, 1
	brlo resetRight
	st Z, rTemp
	brne drawShortcut
	resetRight:
		ldi rTemp, 0b00000001
		st Z, rTemp
		jmp drawShortcut

goUp:
	cpi direction, 1
	breq goDown
	ldi direction, 3
	ldi ZH, HIGH(snakeY)
	ldi ZL, LOW(snakeY)
	ld rTemp, Z
	subi rTemp, 1
	cpi rTemp, -1
	breq resetUp
	st Z, rTemp
	brne drawShortcut
	resetUp:
		ldi rTemp, 7
		st Z, rTemp
		jmp drawShortcut
	st Z, rTemp
	jmp drawShortcut

goDown:
	cpi direction, 3
	breq goUp
	ldi direction, 1
	ldi ZH, HIGH(snakeY)
	ldi ZL, LOW(snakeY)
	ld rTemp, Z
	subi rTemp, -1
	cpi rTemp, 8
	brsh resetDown
	st Z, rTemp
	brne drawShortcut
	resetDown:
		ldi rTemp, 0
		st Z, rTemp
		jmp draw
	st Z, rTemp
	jmp drawShortcut

tailLoop:
		ld rTemp2, Z
		adiw Z, 1
		st Z, rTemp2
		sbiw Z, 2

		subi rTemp, -1
		cp rTemp, snakeLength
		brlo tailLoop
		ret

tailGotoBack:
		adiw Z, 1
		subi rTemp, -1
		cp rTemp, snakeLength
		brlo tailGotoBack
		ldi rTemp, 0
		ret

step:
	adiw Z, 1
	subi rTemp, -1
	cp rTemp, rowNumber
	brne step
	nop
	sbiw Z, 1
	ret
drawPixelsY:
	ldi ZH, HIGH(snakeY)
	ldi ZL, LOW(snakeY)
	ldi rTemp, 0
	rcall step

	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)
	ld rTemp, Z
	drawPixelsMoveY:
		cpi rTemp, 0
		breq drawPixelsX
		nop

		subi rTemp, 1
		adiw Y, 1
		jmp drawPixelsMoveY

drawPixelsX:
	ldi ZH, HIGH(snakeX)
	ldi ZL, LOW(snakeX)
	ldi rTemp, 0
	rcall step

	ld rTemp2, Y
	ld rTemp, Z
	or rTemp, rTemp2
	st Y, rTemp

	ret

resetMatrix:
	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)
	ldi rTemp, 0
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0
	st Y, rTemp

	ret

getJoyX:
	lds rTemp2, ADMUX
	lsr rTemp2
	lsr rTemp2
	lsr rTemp2
	lsr rTemp2
	lsl rTemp2
	lsl rTemp2
	lsl rTemp2
	lsl rTemp2
	ldi rTemp, 0b0000_0101
	or rTemp2, rTemp
	sts ADMUX, rTemp2
	ret
getJoyY:
	lds rTemp2, ADMUX
	lsr rTemp2
	lsr rTemp2
	lsr rTemp2
	lsr rTemp2
	lsl rTemp2
	lsl rTemp2
	lsl rTemp2
	lsl rTemp2
	ldi rTemp, 0b0000_0100
	or rTemp2, rTemp
	sts ADMUX, rTemp2
	ret
AD:
	lds rTemp, ADMUX
	ori rTemp, 0b0010_0000
	sts ADMUX, rTemp

	lds rTemp, ADCSRA
	ori rTemp, 0b0100_0000
	sts ADCSRA, rTemp

	ADLoop:
		lds rTemp, ADCSRA
		sbrc rTemp, 6
		rjmp ADLoop
	lds rTemp, ADCH
		//get random functionality from statical BRUS?
	ret