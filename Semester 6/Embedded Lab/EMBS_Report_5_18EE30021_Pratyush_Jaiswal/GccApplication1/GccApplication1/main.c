/*
 * GccApplication1.c
 *
 * Created: 04-04-2021 11:46:18
 * Author : Pratyush Jaiswal
 */ 

#include "avr/interrupt.h"
#include "avr/io.h"
#define F_CPU 1000000UL						// 1MHz for simulation
#include "util/delay.h"
#include <stdbool.h>
#define BAUD 4800							// baud rate
#define MYUBRR F_CPU/16/BAUD-1				// baud register for timer
#define SAMPLE_RATE 100						// number of samples taken in one second

#define TIMER_PRESCALER 64					// timer prescaler
#define COMPARE ((F_CPU/(TIMER_PRESCALER))/SAMPLE_RATE)-1	// top value for timer


unsigned char lower;						// for storing the lower 8bits of ADC input
unsigned char upper;						// for storing the higher 2bits of ADC input

bool done = false;							// for taking care of the conversion state

void UART_Init(unsigned int ubrr)
{
	UBRR0H = (unsigned char)(ubrr>>8);		//setting baud rate low
	UBRR0L = (unsigned char)ubrr;			// set baud rate upper
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);			// set transmission and receiver bits
	UCSR0C = (1<<USBS0)|(3<<UCSZ00);		// 2 stop bits and 9 bit character size
}

void UART_Transmit(unsigned char data)
{
	while (!(UCSR0A & (1<<UDRE0)));			// wait for empty buffer and transmit
	UDR0 = data;
}
ISR(ADC_vect){								// one data point conversion done
	lower = ADCL;							// variable where lower 8 bits are stored
	upper = ADCH;							// variable where upper 8 bits are stored
	upper &= 0x03;							// making sure that the other 6 bits are maintained zero
	done = true;							// conversion is completed and it is ready to be transmitted
}
EMPTY_INTERRUPT (TIMER1_COMPB_vect);		// timer interrupt when the counter overflows, just pass

int main(void)
{
	UART_Init(MYUBRR);						// initialization of uart
	DDRC &= 0xFE;
	DDRB = 0xFF;
	TCCR1A = 0;
	TCCR1B = 0;
	TCNT1 = 0;
	TCCR1B = (1<<CS11)| (1<<CS10) | (1<<WGM12);		// CTC, prescaler of 8
	TIMSK1 = (1<<OCIE1B);							// interrupt enable
	OCR1A = COMPARE;								// top values for timer
	OCR1B = COMPARE;

	ADCSRA =  (1<<ADEN) |(1<<ADIE) | (1<<ADIF);		// turn ADC on, want interrupt on completion
	ADCSRA |= (1 << ADPS1) | (1 << ADPS0);			// 8 prescaler
	ADMUX = (1<<REFS0) | (0 & 7);					// select ADC0 for conversion (total 6 ADCs are present)
	ADCSRB = (1<<ADTS0) | (1<<ADTS2);				// Timer/Counter1 Compare Match B
	ADCSRA |= (1<<ADATE);							// turn on automatic triggering
	DIDR0 |= 0X01;									// Disabling Digital Input Buffer corresponding to ADC0 to save power 
													// referred to documentation
	sei();											// switching interrupt on
	while(1)
	{
		//temp=(upper<<6) + (lower>>2);
		PORTB = (upper<<6) + (lower>>2);
		if(done)
		{
			cli();									// clear global interrupt flag to prevent 
													// any interrupt calling as transmission being done
			UART_Transmit((upper<<6) + (lower>>2)); // transmit the top 8 bits from 10 bits output
			done = false;							// transmission over, ready for next value conversion
			sei();									// again switching interrupt on
		}
	}
	return 0;
}