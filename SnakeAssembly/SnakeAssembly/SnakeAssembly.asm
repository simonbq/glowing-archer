/*
 * SnakeAssembly.asm
 *
 *  Created: 2014-04-25 15:33:11
 *   Author: BQ & TF
 */
 .DEF rTemp = r16
 //setup buffers
 .DEF bufferportb = r17
 .DEF bufferportc = r18
 .DEF bufferportd = r19
 .DEF rowNumber = r21
 .DEF matrixData = r24

 .DSEG
matrix: .BYTE 8

.CSEG // Code segment
.ORG 0x0000
	jmp init // Reset vector
	nop
.ORG 0x0020
	//jmp isr_timer0F // Timer 0 overflow vector 
	nop
 
.ORG INT_VECTORS_SIZE
init:

	//set up stack pointer
	ldi rTemp, HIGH(RAMEND)
	out SPH, rTemp
	ldi rTemp, LOW(RAMEND)
	out SPL, rTemp

	ldi rTemp, 0b0011_1111
	out DDRB, rTemp
	ldi rTemp, 0b0000_1111
	out DDRC, rTemp
	ldi rTemp, 0b1111_1100
	out DDRD, rTemp
	
	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)
	ldi rTemp, 0
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0b00100100
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0b01111110
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0b01000010
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0b00100100
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0b00011000
	st Y, rTemp
	adiw Y, 1
	ldi rTemp, 0
	st Y, rTemp

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
gamelogic:

	//back to framebuffer
	jmp framebuffer