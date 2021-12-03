/*Date: 21/02/2021				
								Variable Frequency Sine Wave Generator

Submitted BY:
	Pratyush Jaiswal (18EE30021)
	Nuruddin Jiruwala (18EE30029)



Logic Used:
		Base Frequency(Highest Frequency): F_CPU/(256*resolution)
		Prescaler: 1	(Since, no prescaling)
		From the base frequency and frequency Factor we can get the required frequency using the below formula:
			Frequency: (Base Frequency/Freqfactor)
		Frequency Factor and number of ramps will get the get the same value from the sine lookup table so the 
		wave gets stretched and the frequency gets decreased to the required value.
		
		The number of cycles, a particular wave can be outputted can be precalculated form the product of 
		Time for which the wave is being generated and the frequency of that wave(from the definition of Frequency).*/


#define duty R17						; value of sineLookUp at the current index of resolution count
#define resolutionCount R19				; Temporary resolution count for being compared with resolution (0 to resolution-1)
#define tempCycleCount R20				; Temporary cycle count for being compared with currCycle (0 to currCycle-1)

#define currFreqFactor R21				; Frequency of the wave at index
#define currCycle R22					; Total number of cycles for which the current wave with current index
#define index R23						; For storing the current wave index
#define count R18						; Compare with currFreqFactor


.ORG 0x0
    JMP MAIN
.ORG 0x20
    JMP overflow_isr

MAIN:

    ; Initializing the stack
    LDI R16,HIGH(RAMEND)
    OUT SPH,R16
    LDI R16,LOW(RAMEND)
    OUT SPL,R16

    ; Initializing stack is done
	clr tempCycleCount
	CALL loadLookUp								; loading the Sine LookUp Table for the first time

    SBI DDRD,6                                  ; Setting PD6 as output

    LDI duty, 63                                 ; just for initialisation sake
    OUT OCR0A,duty									; Loading Timer0 with 127
	
	; clearing all the temporary counters
	clr count	
	clr resolutionCount
	clr tempCycleCount	

	; Loading first wave by calling loadwave
	call loadWave

    LDI R16,(1<<WGM01)  | (1<<WGM00) | (1<<COM0A1)                        ;Setting timer mode to fast PWM
    OUT TCCR0A, R16

    LDI R16, (1<<CS00)                          ;Start Timer0 - prescaler = (no prescaling)
    OUT TCCR0B, R16                             

    LDI R16, (1<<TOIE0)							;Setting the ISR vector
    STS TIMSK0, R16                             ;Enable Timer0 compare match interrupt

    SEI                                         ;Enable global interrupts

Again:
	CP tempCycleCount, currCycle			; comparing the tempCycleCount with the number of cycles assigned for the current wave(index) 
	brne Repeat
	call loadWave							; loading the next wave(incrementing the index)
			
	Repeat:
		cp count, currFreqFactor			; checking the number of number of ramps required for current angle value in the Sine LookUpTable
		brne Repeat2						; if not equal, then don't change the current PWM value
		LPM duty, Z+						; if equalt, then load with the next value in sine LookUp Table
		clr count							; Reset number of ramps
		inc resolutionCount					; increase index in sineLookUp Table
		Repeat2:	
			out OCR0A, duty					; Give output PWM
			cpi resolutionCount, resolution	; checking if the one cycle of current wave is completed
			brne Again						; if not equal then complete the current cycle
			call loadLookUp					; if equal then load the new cycle by calling LookUp Table again,
											; and resetting resolutionCount and incrementing tempCycleCount
	JMP Again								; Repeat the phenomena infintite times

; For getting a new wave form the Freqfactor
/*Here we used only one dataframe as we could access memory through Z only, two functions could be 
implemented and Z be pushed onto the stack multiple times to achieve this using 2 dataframes, 
but this method felt simpler and the values are taken pairwise i.e. freqfactor and number of cycles*/
loadWave:
	; clear the parameters for a new wave
	clr tempCycleCount		
	clr count		
	
	; Pushing Z indirect register onto Stack (it is used for loading SineLookUp that is why I have to push it)	
	PUSH ZL
	PUSH ZH

	; Loading with the Freqfactor data
	LDI ZL, LOW(2*freqFactor)
	LDI ZH, HIGH(2*freqFactor)


	CPI index, freqCount		; comapring and checking if the total waves have been outputted
	brne updateWave				; if not equal then go for the remaining waves
	CLR index					; if equal then start from the beginning of the data

	; Loading parameters for the wave at current index
	updateWave:		
		add ZL, index
		LDI R16, 0
		adc ZH, R16
		LPM currFreqFactor, Z+
		LPM currCycle, Z+
		
		; incrementing index twice because the two parameters(currFreqFactor and currCycle) for a wave are stored sequentially
		inc index
		inc index

		; Popping out the Z register from the Stack for lookUpTable
		POP ZH
		POP ZL
		ret

; for loading SineLookUp Table
loadLookUp:
	clr resolutionCount			; since a new cycle is starting, reset the resolutionCount(index of lookUpTable)
	ldi ZL, LOW(2*sineLookUp)
	ldi ZH, HIGH(2*sineLookUp)
	inc tempCycleCount	; incrementing the current number of cycles
	ret

overflow_isr:
	inc count			; incrementing the number of ramps
    reti

; for storing the LookUpTable of a Sine Wave with 64 resolution
sineLookUp:
		.DB 128, 140, 153, 165, 177, 188, 199, 209, 219, 227, 235, 241, 246, 250, 253, 255, 255, 254, 252, 248, 244, 238, 231, 223, 214, 204, 194, 183, 171, 159, 147, 134, 121, 108, 96, 84, 72, 61, 51, 41, 32, 24, 17, 11, 7, 3, 1, 0, 0, 2, 5, 9, 14, 20, 28, 36, 46, 56, 67, 78, 90, 102, 115, 127
		.EQU resolution = 63

; for storing the frequencies(Frequency Factor) and Number of Cycles
freqFactor:
		.DB 15, 2, 16, 2, 17, 2, 18, 2, 19, 2, 20, 2, 21, 2, 22, 2, 23, 2, 24, 2, 23, 2, 22, 2, 21, 2, 20, 2, 19, 2, 18, 2, 17, 2, 16, 2
		.EQU freqCount = 36


/*For the Proteus Simulation:
	We are taking the output of the PWM from PD6 clipping the output with 1V(For getting it into the range of -1 to 1 as it 
	was being generated from 0 to 2 inside the microcontoller) and after that passing through a Active Low Pass Filter for getting the Sine Wave from generated PWM.
	
	Due to timing errors in proteus the cutoff frequency of the low pass filter could not be set to the required value, hence there is seen some amplitude change as 
	the frequency changes because the cutoff frequency is too low, and hence for some higher frequencies the gain goes low so amplitude changes.

	A speaker is also attached for getting the audio version of the signal being generated after being amplified through an inverting Amplifier
	because of the threshold voltage of the speaker*/