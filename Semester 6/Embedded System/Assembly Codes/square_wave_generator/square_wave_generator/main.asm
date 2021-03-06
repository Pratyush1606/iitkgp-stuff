;
; square_wave_generator.asm
;
; Created: 28-01-2021 19:55:46
; Author : Pratyush Jaiswal
;


; Replace with your application code
.INCLUDE "M32DEF.INC"
.ORG 0x00

LDI R16, HIGH(RAMEND)
OUT SPH, R16
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R16, 0x01
OUT DDRB, R16

LOOP1:
	LDI R16, 0xFF
	OUT PORTB, R16
	RCALL DELAY
	LDI R16, 0x00
	OUT PORTB, R16
	RCALL DELAY
	RJMP LOOP1

DELAY:
	LDI R16, 0x0F
	LOOP2:
		LDI R17, 0x0F
		LOOP3:
			DEC R17
			BRNE LOOP3
		DEC R16
		BRNE LOOP2
	RET