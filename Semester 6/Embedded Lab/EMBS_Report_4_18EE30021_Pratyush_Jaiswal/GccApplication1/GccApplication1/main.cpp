/*
 * GccApplication1.cpp
 *
 * Created: 19-03-2021 00:19:01
 * Author : Pratyush Jaiswal
 */

#include <avr/io.h>
#include <util/atomic.h>
#include <math.h>
#define res 20
#define F_cpu 1000000UL
#define tot_freq_count 7
int frequencies[] = {240, 270, 300, 320, 360, 400, 450};	//array containing all the frequencies for generating sa re ga ma tune
int tot_time = 0.5;											//time for which the each freq will run(here all freq are given same time, 
															//can be changed with array for modification
int table[tot_freq_count][res];								//2-D array containing all the look table values for every freq with resolution res
int timep[tot_freq_count];									//1-D array for containing pre-calculated timep values

int curr_freq = 0;											//counter for maintaining the current frequency index 

unsigned char idx=0;										//counter for current index in lookup table
int curr_cycles=0;											//counter for number of cycles of the current freq

void init(){
	for(int j=0;j<tot_freq_count;j++){
		int f_arr = frequencies[j];
		timep[j]=F_cpu/(res*f_arr);
		for(int i=0;i<res;i++){
			table[j][i]=(0.5+0.5*sin((2*M_PI*i)/res))*timep[j];
		}
	}
	
	TCCR1A = 0b10000010;
	TCCR1B = 0b00011001;
	TIMSK1=1;
	ICR1=timep[0];
	DDRB = 0b00000010;
}
int main(void)
{
    /* Replace with your application code */
	init();
	sei();
	
    while (1){
		if(curr_cycles>=0.5*frequencies[curr_freq]){
			curr_freq+=1;
			curr_cycles=0;
			idx = 0;
			if(curr_freq==tot_freq_count){
				curr_freq=0;
			}
			ICR1 = timep[curr_freq];
		}
	}
}

ISR(TIMER1_OVF_vect){
	if(idx==res){
		idx=0;
		curr_cycles+=1;
	}
	
	OCR1A=table[curr_freq][idx];
	idx++;
}