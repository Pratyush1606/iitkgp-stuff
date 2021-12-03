;
; Transmit_code.asm
;
; Created: 14-03-2021 01:55:06
; Author : Pratyush Jaiswal
;

; Replace with your application code
.ORG 0x0
	JMP INIT
.ORG UDREaddr
	JMP ISR_Transmit


INIT:
	LDI R16,HIGH(RAMEND)									; initialize high
	OUT SPH,R16												; byte of SP
	LDI R16,LOW(RAMEND)										; initialize low
	OUT SPL,R16												; byte of SP

.EQU F_CPU=1000000										; frequency is 1MHz
.EQU USART_BAUDRATE=4800								; set baud rate to for serial comm
.EQU BAUD_PRESCALE = (((F_CPU/(USART_BAUDRATE*16)))-1)  ; calculate the scaling factor obtained from formula in dataset

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
	LDI R16, 'I'
	RCALL USART_TRANSMIT
	LDI R16, ' '
	RCALL USART_TRANSMIT
	LDI R16, 'I'
	RCALL USART_TRANSMIT
	LDI R16, ' '
	RCALL USART_TRANSMIT
	LDI R16, 'T'
	RCALL USART_TRANSMIT
	LDI R16, ' '
	RCALL USART_TRANSMIT
	LDI R16, ' '
	RCALL USART_TRANSMIT
	LDI R16, 'K'
	RCALL USART_TRANSMIT
	LDI R16, 'h'
	RCALL USART_TRANSMIT
	LDI R16, 'a'
	RCALL USART_TRANSMIT
	LDI R16, 'r'
	RCALL USART_TRANSMIT
	LDI R16, 'a'
	RCALL USART_TRANSMIT
	LDI R16, 'g'
	RCALL USART_TRANSMIT
	LDI R16, 'p'
	RCALL USART_TRANSMIT
	LDI R16, 'u'
	RCALL USART_TRANSMIT
	LDI R16, 'r'
	RCALL USART_TRANSMIT
	LDI R16, ' '
	RCALL USART_TRANSMIT
	LDI R16, 13
	RCALL USART_TRANSMIT
	LDI R16, 10
	RCALL USART_TRANSMIT
	RJMP MAIN
	RJMP EXIT

USART_TRANSMIT:
		; Wait for empty transmit buffer
		LDS R20, UCSR0A
		SBRS R20, UDRE0
		RJMP USART_Transmit
		; Put data (r16) into buffer, sends the data
		sts UDR0, R16			
		RET

ISR_transmit:
	STS UDR0,R16
	RETI
exit:
	RJMP exit