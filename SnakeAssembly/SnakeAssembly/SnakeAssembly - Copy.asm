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
 .DEF fIterator = r20
 
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
	
	//initiate buffers
	ldi bufferportb, 0b0011_1111
	ldi bufferportc, 0
	ldi bufferportd, 0b1100_0000

	ldi fIterator, 0

	jmp framebuffer

framebuffer:
	inc fIterator
	//see if iterator is done for the frame, go to game logic
	


	cpi fIterator, 1
	breq row0
	cpi fIterator, 2
	breq row1
	cpi fIterator, 3
	breq row2
	cpi fIterator, 4
	breq row3
	cpi fIterator, 5
	breq row4
	cpi fIterator, 6
	breq row5
	cpi fIterator, 7
	breq row6
	/*
	cpi fIterator, 8
	breq row7
	*/
	cpi fIterator, 9
	breq gamelogic
	//sbi PORTC, fIterator

	
	//movw bufferportc, fIterator

	//execute buffers
	out PORTB, bufferportb
	//out PORTC, bufferportc
	out PORTD, bufferportd

	//increase iterator and loop
	jmp framebuffer
row0:
	sbi PORTC, 0
	//cbi PORTD, 5
	jmp framebuffer
row1:
	sbi PORTC, 1
	//cbi PORTC, 0
	jmp framebuffer
row2:
	sbi PORTC, 2
	//cbi PORTC, 1
	jmp framebuffer
row3:
	sbi PORTC, 3
	//cbi PORTC, 2
	jmp framebuffer
row4:
	sbi PORTD, 2
	//cbi PORTC, 3
	jmp framebuffer
row5:
	sbi PORTD, 3
	//cbi PORTD, 2
	jmp framebuffer
row6:
	sbi PORTD, 4
	//cbi PORTD, 3
	jmp framebuffer
row7:
	sbi PORTD, 5
	//cbi PORTD, 4
	jmp framebuffer

gamelogic:
	//reset iterator
	ldi fIterator, 0

	//back to framebuffer
	jmp framebuffer