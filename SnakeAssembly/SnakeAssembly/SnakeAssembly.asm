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
	ldi rTemp, HIGH(RAMEND)
	out SPH, rTemp
	ldi rTemp, LOW(RAMEND)
	out SPL, rTemp

	ldi rTemp, 0b1111_1000
	out DDRB, rTemp
	ldi rTemp, 0b1111_0000
	out DDRC, rTemp
	ldi rTemp, 0b0011_1111
	out DDRD, rTemp
	
	ldi rTemp, 0b0000_1000
	//ser rTemp
	out PORTD, rTemp
	ldi rTemp, 0b0000_1000
	out PORTB, rTemp
	
	/*
	clr rTemp
	//ldi rTemp, 01
	ldi rTemp, 0b0100_0000
	out PORTD, rTemp
	ldi rTemp, 0b0100_0000
	out PORTB, rTemp
	*/
	//sbi PORTD2, 1
	//sbi PORTB2, 1
	
	//sbi PORTD, PORTD2
	//sbi PORTB, PORTB2
	/*
	cbi PORTD2, 0
	cbi PORTD3, 0
	cbi PORTD4, 0
	cbi PORTD5, 0
	cbi PORTD6, 0
	cbi PORTD7, 0
	cbi PORTB0, 0
	cbi PORTB1, 0
	cbi PORTB2, 0
	cbi PORTB3, 0
	cbi PORTB4, 0
	cbi PORTB5, 0

	
	*/
	//ser rTemp
	//sbi PORTD2, 1
	//sbi PORTB2, 1