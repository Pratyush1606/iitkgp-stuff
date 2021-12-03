;
; AssemblerApplication1.asm
;
; Created: 18-03-2021 23:02:11
; Author : Pratyush Jaiswal
;

; Replace with your application code
.org 0X00
	RJMP MAIN

.EQU CS = 0  ; chip select
.EQU CLK = 1 ; clock
.EQU D0 = 2  ; data output
MAIN:
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16
	LDI R16, LOW(RAMEND)			; initialize ram stack as functions are to be called and adresses will be pushed
	OUT SPL, R16
	LDI R16, 0XFF
	OUT DDRB, R16					; Port B taken as output and given to DAC 8 bit
	LDI R16, 0b00000111				; Port D taken as input from ADC
	OUT DDRD, R16
	SBI PORTD, CS
LOOP:
	CALL READ_ADC
	OUT PORTB, R20
	RJMP LOOP
READ_ADC:
	CBI PORTD, CS
	NOP
	LDI R16, 0X09 ; as it takes 10 bits for input so loop 0 to 9
LOOP1:
	SBI PORTD, CLK		; set clock bit in portd
	NOP
	CBI PORTD, CLK		; clear clock bit in portd
	SBIC PIND, D0		; set carry if D0 is set (1)
	SEC
	SBIS PIND, D0		; set carry if D0 is clear(0)
	CLC
	ROL R20				; Rotate left i.e. get the carry in it
	DEC R16				; decrease count 
	BRNE LOOP1			; repeat until all bits of a single conversion doesnt happen
	NOP
	SBI PORTD, CS		; select chip
	NOP
	RET

exit: 
	RJMP exit ; the output is inverted as iout has inrush of current instead of outgoing(so wrt to reference it is inverted)