/*
 * SnakeAssembly.asm
 *
 *  Created: 2014-04-25 15:33:11
 *   Author: BQ & TF
 */
 .DEF rTemp = r16

 
 .DSEG
	

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
	
	ldi rTemp, 0b0011_1111
	out PORTB, rTemp
	ldi rTemp, 0b0000_1111
	out PORTC, rTemp
	ldi rTemp, 0b1111_1100
	out PORTD, rTemp
