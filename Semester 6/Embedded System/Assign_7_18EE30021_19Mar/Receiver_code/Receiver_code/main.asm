;
; Receiver_code.asm
;
; Created: 16-03-2021 01:57:29
; Author : Pratyush Jaiswal
;
; Replace with your application code

.EQU F_CPU=1000000										; frequency is 1MHz
.EQU USART_BAUDRATE=4800								; set baud rate to for serial comm
.EQU BAUD_PRESCALE = (((F_CPU/(USART_BAUDRATE*16)))-1)  ; calculate the scaling factor obtained from formula in dataset

LDI R16,HIGH(RAMEND)									; initialize high
OUT SPH,R16												; byte of SP
LDI R16,LOW(RAMEND)										; initialize low
OUT SPL,R16												; byte of SP


USART_Init:
	LDI R16, 0
	LDI R16, HIGH(BAUD_PRESCALE)						;storing the HIGHER 8 bits of prescaler
	STS UBRR0H, R16
	LDI R16, LOW(BAUD_PRESCALE)							;storing the LOWER 8 bits of prescaler
	STS UBRR0L, R16

	; Enable receiver and transmitter
	LDI r16, (1<<RXEN0) | (1<<TXEN0)						
	STS UCSR0B, R16					
		
	; Set frame format: 8data
	LDI r16, (1<<UCSZ01)|(1<<UCSZ00)					;enabling 8 bit frame of data
	STS UCSR0C, R16											
	

MAIN:
	RCALL USART_RECEIVE									; receiving from the transmitter 
	RCALL USART_TRANSMIT								; after receiving, transmit the received data to the screen
	RJMP MAIN

USART_RECEIVE:
		; Wait for data to be received
		LDS R20, UCSR0A
		SBRS R20, RXC0
		RJMP USART_RECEIVE
		; Get and return received data from buffer
		LDS R16, UDR0
		RET

USART_TRANSMIT:
		; Wait for empty transmit buffer
		LDS R20, UCSR0A
		SBRS R20, UDRE0
		RJMP USART_Transmit
		; Put data (r16) into buffer, sends the data
		sts UDR0, R16			
		RET

exit:
		RJMP exit