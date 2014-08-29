/*
 * SnakeAssembly.asm
 *
 *  Created: 2014-04-25 15:33:11
 *   Author: BQ & TF
 */
 //Definera register
 .DEF snakeLength = r22
 .DEF rTemp2 = r24
 .DEF rTemp = r16
 .DEF bufferportb = r17
 .DEF bufferportc = r18
 .DEF bufferportd = r19
 .DEF rowNumber = r21
 .DEF direction = r20
 .DEF delay = r23
 .DEF moreDelay = r25
 .DEF random = r14
 .DEF rTemp3 = r26
 .Def rTemp4 = r27

 //Definera konstanter
 .EQU SNAKE_MAX_SIZE = 25

 //Definera datasegment
 .DSEG
foodX:	.BYTE 1
foodY:	.BYTE 1
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
	//Initiera allt, används även för att starta om spelet
	ldi delay, 0
	ldi moreDelay, 0
	//set up stack pointer
	ldi rTemp, HIGH(RAMEND)
	out SPH, rTemp
	ldi rTemp, LOW(RAMEND)
	out SPL, rTemp

	//Initiera orm
	ldi snakeLength, 1
	ldi direction, 0

	//Initiera ormens X
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
		ldi rowNumber, -1
		st Z, rowNumber
		cpi rTemp, SNAKE_MAX_SIZE
		subi rTemp, -1
		brne initSnakeX

	//Initiera ormens Y
	ldi ZH, HIGH(snakeY)
	ldi ZL, LOW(snakeY)

	ldi rTemp, 4
	st Z, rTemp

	ldi rTemp, 1
	initSnakeY:
		adiw Z, 1
		ldi rowNumber, -1
		st Z, rowNumber
		cpi rTemp, SNAKE_MAX_SIZE
		subi rTemp, -1
		brne initSnakeY

	//Initiera I/O portar
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
	rcall spawnFood
	
	//make sure it's off
	ldi rTemp, 0
	out PORTB, rTemp
	out PORTC, rTemp
	out PORTD, rTemp
	jmp framebuffer

//Loopa buffermatrisens kolumner till rätt pin & port
framebuffer_column_loop:
	//Skifta matrisrad för att matcha output pin för port d
	mov rTemp, rTemp2
	lsl rTemp
	lsl rTemp
	lsl rTemp
	lsl rTemp
	lsl rTemp
	lsl rTemp
	or bufferportd, rTemp
	//Skifta matrisrad för att matcha output pin för port b
	mov rTemp, rTemp2
	lsr rTemp
	lsr rTemp
	or bufferportb, rTemp

	ret
//Loopa buffermatrisens rader till rätt pin & port
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
spawnFood:
	//Hämta random värde för matens y-position & lagra
	ldi YH, HIGH(foodY)
	ldi YL, LOW(foodY)
	rcall getJoyY
	rcall AD

	st Y, rTemp2

	ldi YH, HIGH(foodX)
	ldi YL, LOW(foodX)

	//Hämta random värde för matens x-position & lagra
	rcall getJoyX
	rcall AD
	ldi rTemp, 1
	
	st Y, rTemp

	cpi rTemp2, 0
	brne offsetFoodX
	ret

	offsetFoodX:
		subi rTemp2, 1
		lsl rTemp
		st Y, rTemp
		cpi rTemp2, 0
		brne offsetFoodX

	//Se till att maten inte spawnar på ormen
	ldi YH, HIGH(foodY)
	ldi YL, LOW(foodY)
	ldi ZH, HIGH(foodX)
	ldi ZL, LOW(foodX)
			
	ld rTemp, Y
	ld rTemp3, Z

	ldi YH, HIGH(snakeY)
	ldi YL, LOW(snakeY)
	ldi ZH, HIGH(snakeX)
	ldi ZL, LOW(snakeX)

	ldi rowNumber, 1
	checkFoodLoopY:
		ld rTemp2, Y
		cp rTemp, rTemp2
		breq checkFoodBodyX
		adiw Y, 1
		adiw Z, 1
		cp rowNumber, snakeLength
		subi rowNumber, -1
		brne checkFoodLoopY
		ret

	checkFoodBodyX:
		ld rTemp2, Z
		cp rTemp3, rTemp2
		breq spawnFood
		jmp checkBodyLoopY
//Genväg till init
goToInit:
	jmp init

//Kollisionsdetektera ormens huvud med ormens kropp
checkBody:
	ldi YH, HIGH(snakeY)
	ldi YL, LOW(snakeY)
	ldi ZH, HIGH(snakeX)
	ldi ZL, LOW(snakeX)
			
	ld rTemp, Y
	ld rTemp3, Z

	ldi rowNumber, 1
	checkBodyLoopY:
		adiw Y, 1
		adiw Z, 1
		ld rTemp2, Y
		cp rTemp, rTemp2
		breq checkBodyX
		cp rowNumber, snakeLength
		subi rowNumber, -1
		brne checkBodyLoopY
		ret

	checkBodyX:
		ld rTemp2, Z
		cp rTemp3, rTemp2
		breq goToInit
		jmp checkBodyLoopY

framebuffer:
	//Ladda in buffermatris och kör framebuffer loops för att matcha portar & pins
	ldi rowNumber, 0b0000_0001
	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)
	
	framebuffer_loop:
		ldi bufferportb, 0
		ldi bufferportc, 0
		ldi bufferportd, 0

		ld rTemp2, Y

		rcall framebuffer_row_loop
		rcall framebuffer_column_loop
		adiw Y, 1

		//Outputa buffrar
		out PORTB, bufferportb
		out PORTC, bufferportc
		out PORTD, bufferportd
		

		//Öka iterator, loopa
		lsl rowNumber

		cpi rowNumber, 0
		breq gamelogic
		nop

		jmp framebuffer_loop

//Lägg in orm och mat på buffermatrisen
draw:
	rcall resetMatrix
	ldi rowNumber, 1
	rcall drawFoodY
	sendToFramebuffer:
		rcall drawSnakeY
		cp rowNumber, snakeLength
		breq framebuffer
		subi rowNumber, -1
		jmp sendToFramebuffer
//Kollisionsdetektering mellan huvud och mat
checkFood:
	ldi YH, HIGH(foodY)
	ldi YL, LOW(foodY)
	ld rTemp, Y
	ldi ZH, HIGH(snakeY)
	ldi ZL, LOW(snakeY)
	ld rTemp2, Z

	cp rTemp, rTemp2
	breq checkFoodX
	nop

	ret
checkFoodX:
	ldi YH, HIGH(foodX)
	ldi YL, LOW(foodX)
	ld rTemp, Y
	ldi ZH, HIGH(snakeX)
	ldi ZL, LOW(snakeX)
	ld rTemp2, Z

	cp rTemp, rTemp2
	breq makeLonger
	nop

	ret
//Väx ormen & spawna ny mat
makeLonger:
	subi snakeLength, -1
	rcall spawnFood
	ret
//Samlingsplats för spellogik
gamelogic:
	//Sakta ner spelet till en spelbar hastighet
	ldi rTemp, 25
	sub rTemp, snakeLength
	lsl rTemp

	subi delay, -1
	cp delay, rTemp
	brlo draw
	ldi delay, 0
	lsl rTemp

	subi moreDelay, -1
	cp moreDelay, rTemp
	brlo draw
	ldi moreDelay, 0

	//Utför kollisionsdetektering
	rcall checkBody
	rcall checkFood
	
	//Uppdatera svansen
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

	//Kontroller
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

	//Fortsätt i den senaste riktningen
	cpi direction, 0
	breq goRight
	cpi direction, 2
	breq goLeft
	cpi direction, 3
	breq goUp
	cpi direction, 1
	brsh goDown
	jmp drawShortcut
//Genväg till draw
drawShortcut:
	jmp draw
//Kontrollfunktion		
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
//Kontrollfunktion	
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
//Kontrollfunktion	
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
//Kontrollfunktion	
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
//Uppdaterar svans
tailLoop:
	ld rTemp2, Z
	adiw Z, 1
	st Z, rTemp2
	sbiw Z, 2

	subi rTemp, -1
	cp rTemp, snakeLength
	brlo tailLoop
	ret
//Går till sista elementet i svansen
tailGotoBack:
	adiw Z, 1
	subi rTemp, -1
	cp rTemp, snakeLength
	brlo tailGotoBack
	ldi rTemp, 0
	ret

//Hjälpfunktion för inläggning av orm i buffermatris
step:
	adiw Z, 1
	subi rTemp, -1
	cp rTemp, rowNumber
	brne step
	nop
	sbiw Z, 1
	ret

//Inläggning av orm i buffermatris
drawSnakeY:
	ldi ZH, HIGH(snakeY)
	ldi ZL, LOW(snakeY)
	ldi rTemp, 0
	rcall step

	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)
	ld rTemp, Z
	drawSnakeMoveY:
		cpi rTemp, 0
		breq drawSnakeX
		nop

		subi rTemp, 1
		adiw Y, 1
		jmp drawSnakeMoveY

drawSnakeX:
	ldi ZH, HIGH(snakeX)
	ldi ZL, LOW(snakeX)
	ldi rTemp, 0
	rcall step

	ld rTemp2, Y
	ld rTemp, Z
	or rTemp, rTemp2
	st Y, rTemp

	ret
//Inläggning av mat i buffermatris
drawFoodY:
	ldi ZH, HIGH(foodY)
	ldi ZL, LOW(foodY)
	ld rTemp, Z

	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)

	drawFoodMoveY:
		cpi rTemp, 0
		breq drawFoodX
		nop

		subi rTemp, 1
		adiw Y, 1
		jmp drawFoodMoveY
	ret

drawFoodX:
	ldi ZH, HIGH(foodX)
	ldi ZL, LOW(foodX)

	ld rTemp2, Y
	ld rTemp, Z
	or rTemp, rTemp2
	st Y, rTemp

	ret
//Töm buffermatris
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
//Hjälpfunktion för A/D konverterare
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
//Hjälpfunktion för A/D konverterare
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
//A/D konverterare & psuedo slumptalsgenerator
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
	
	add random, rTemp

	lds rTemp2, ADCH
	add rTemp2, random
	lsr rTemp2
	lsr rTemp2
	lsr rTemp2
	lsr rTemp2
	lsr rTemp2


	ret