#include<ADUC841.H>
;********************************************************************
; Gil Ya'akov
; Date : 24/12/2020
; File: ADC_P3.asm
; Hardware : Any 8052 based MicroConverter (ADuC8xx)
; Description : This program read the value of ADC, from channel 0 
;               and output it to DAC0 by using the continuous 
;               conversion mode.
;               The DAC0 output has 2V forced limitation.
;********************************************************************
CSEG AT 0000H ;When "wake up" jump to START.
     JMP START	 
CSEG AT 0033H ;ADCI ISR
     JMP ADCI_ISR
CSEG AT 0100H
  ADCI_ISR:
           PUSH ACC
           MOV A, ADCDATAH ;Move A the high 8 bit of the sample.
		   ;Limit the output of the DAC to 2V
		   CJNE A,#0CH,CHECK1
		   MOV DAC0H, A ;Prepare the sample highest 4 bit to send.
		   JMP NEXT1
    CHECK1:JC SMALLER
	       MOV DAC0H,#0CH ;Send the limit (2V).
		   MOV DAC0L,#0CDH ;Send the limit (2V).
		   JMP DONE
	 NEXT1:MOV A, ADCDATAL ;Move A the low 8 bit of the sample.
		   CJNE A,#0CDH,NEXT2
   SMALLER:MOV A, ADCDATAH ;Move A the high 8 bit of the sample.
           MOV DAC0H, A ;Prepare the sample highest 4 bit to send.
           MOV A, ADCDATAL
		   MOV DAC0L, A ;Send the 12 bit sample.
		   JMP DONE
	 NEXT2:JC SMALLER
	       MOV DAC0L,#0CDH ;Send the limit (2V).
      DONE:POP ACC
           RETI
CSEG AT 0200H
    START:
        MOV SP, #30H ;Set SP to 30H address.
		;DAC0 Configuration
		MOV DACCON,#00001101b ;Power on DAC0, set it to 12 bit mode,
                     		  ;set it to Vref = 2.5V top level and set the output
                              ;to whatever it should be, set the sync bit
							  ;to 1 - send as soon DAC0L get update by value.
		;ADC Configuration
	    ;ADCCON1 Configuration
		MOV ADCCON1,#10011000b ;Power on ADC, set it to use the internal 
		                       ;reference voltage (Vref = 2.5V), set the
							   ;divide factor to 2 (11.0592MHz/4 = 2.7648MHz - ADC clock),
							   ;set 3 ADC clock cycle to acquire the signal, set Timer 2
                               ;conversion bit to 0, set 
                               ;external trigger bit to 0.
        ;ADCCON2 Configuration - none		
		;ADCCON3 Configuration - none
		SETB CCONV ;Set ADC to continuous conversion mode.
		SETB EADC ;Enable ADC interrupt.
        SETB EA ;Enable interrupts globally.
        JMP $        
END