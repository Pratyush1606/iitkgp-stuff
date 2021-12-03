;
; led_blink.asm
;
; Created: 10-01-2021 18:43:36
; Author : Pratyush Jaiswal
;


; Replace with your application code
.INCLUDE "M32DEF.INC"			;adding board support package
.ORG 0x00						;directive to set pc at 0x00 start	

	LDI R16, HIGH(RAMEND)		;load R16 SFR with address of last SRAM location
	OUT SPH, R16				;set upper byte of stack pointer to SRAM end
	LDI R16, LOW(RAMEND)		;load R16 SFR with address of penultimate SRAM location
	OUT SPL, R16				;set lower byte of stack pointer to SRAM end
	LDI R16, 0X01				;load R16 with value 1
	OUT DDRB, R16				;set PORTB as OUTPUT

LOOP:							;Main Loop
	LDI R16, 0x01				;load SFR R16 with value 1
	OUT PORTB, R16				;set PB0 as output HIGH
	RCALL DELAY1				;transfer control to DELAY1
	LDI R16, 0x00				;load SFR R16 with value 0
	OUT PORTB, R16				;set PORTB as output LOW
	RCALL DELAY1				;transfer control to DELAY1
	RJMP LOOP					;repeat main loop

DELAY1:							;delay1 subroutine
	LDI R16, 0xFF				;set outer loop register counter as 0xFF to define number of LOOP1 executions
	LOOP1:
		LDI R17, 0xFF			;set inner LOOP2 counter register as 0xFF for 255 inner loop runs
		LOOP2:
			DEC R17				;decrease inner loop counter
			BRNE LOOP2			;branch if inner loop counter is zero
		DEC R16					;decrease outer loop counter
		BRNE LOOP1				;branch if outer loop counter is zero
	RET							;return to main loop

