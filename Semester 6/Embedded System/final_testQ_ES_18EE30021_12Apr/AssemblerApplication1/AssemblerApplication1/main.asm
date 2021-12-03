;
; AssemblerApplication1.asm
;
; Created: 12-04-2021 09:53:01
; Author : Pratyush Jaiswal
;


; Replace with your application code
#define F_CPU (1000000) ; for the simulation - for actual use 16000000 as most arduino come with 16MHz crystal

#define TEMP 	R16        ; temporary variable for loading / initialising operations etc.

#define DD_MOSI	PB3		   ; making Pin3 as MOSI(Master Out Slave In)
#define DD_SCK	PB5        ; making Pin5 as SCK(Serial CLock)
#define DD_SS	PB2		   ; making Pin2 as SS(chip select)
#define DDR_SPI	DDRB

.org 0x0000

ldi TEMP, low(RAMEND)
OUT SPL, TEMP
ldi TEMP, high(RAMEND)
OUT SPH, TEMP           ; stack pointer initialisation complete 

SETUP:
RCALL SPI_MasterInit
CBI PORTB , DD_SS
;LDI DATA, 0X05
;RCALL SPI_MasterTransmit


MAINLOOP:
	RCALL SPI_RECIEVE
	COM R16
	RCALL SPI_MasterTransmit
RJMP MAINLOOP

SPI_MasterInit:
   ; initialising MOSI, SCK and SS pins as output
   ldi TEMP , (1<<DD_MOSI) | (1<<DD_SCK) | (1<<PB4)
   out DDR_SPI, TEMP
   ; making the microcontroller as master and setting the clock freq
   ldi TEMP , (1<<SPE)|(1<<MSTR)|(1<<SPR0)
   out SPCR, TEMP
   ret

SPI_MasterTransmit:
   ; master transmit from microcontroller to the sd card
   out SPDR, R16
   Wait_Transmit:
      in TEMP, SPSR
      sbrs TEMP, SPIF
      rjmp Wait_Transmit
   ret

SPI_RECIEVE:
   ; Wait for reception complete
   in r16, SPSR
   sbrs r16, SPIF
   rjmp SPI_RECIEVE
   ; Read received data and return
   in r16, SPDR
   ret
