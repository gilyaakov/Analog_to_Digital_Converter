#include<ADUC841.H>
;********************************************************************
; Gil Ya'akov
; Date : 24/12/2020
; File: ADC_P2.asm
; Hardware : Any 8052 based MicroConverter (ADuC8xx)
; Description : This program read the value of ADC, from channel 0 
;               and output it to DAC0 without using Timer 2 interrupt,
;               but Timer 2 still sets the conversion rate.
;               Timer 2 over flow rate = 245,760Hz.
;********************************************************************
CSEG AT 0000H ;When "wake up" jump to START.
     JMP START	 
CSEG AT 0033H ;ADCI ISR
     JMP ADCI_ISR
CSEG AT 0200H
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
CSEG AT 0300H
    START:
        MOV SP, #30H ;Set SP to 30H address.
		;Timer 2 config
        CLR CNT2
        CLR CAP2
        MOV RCAP2H, #0FFH ;Cause Timer 2 to interrupt every 45*(1/11059200) = 4.069us.
		                  ;Timer 2 over flow rate = 245,760Hz.
        MOV RCAP2L, #0D3H
        MOV TH2, #0FFH
        MOV TL2, #0D3H
		;DAC0 Configuration
		MOV DACCON,#00001101b ;Power on DAC0, set it to 12 bit mode,
                     		  ;set it to VDD top level and set the output
                              ;to whatever it should be, set the sync bit
							  ;to 1 - send as soon DAC0L get update by value.
		;ADC Configuration
	    ;ADCCON1 Configuration
		MOV ADCCON1,#10111010b ;Power on ADC, set it to use the internal 
		                       ;reference voltage (Vref = 2.5V), set the
							   ;divide factor to 2 (11.0592MHz/2 = 5.5296MHz - ADC clock),
							   ;set 3 ADC clock cycle to acquire the signal, set Timer 2
                               ;conversion bit to 1, set 
                               ;external trigger bit to 0.
        ;ADCCON2 Configuration - none		
		;ADCCON3 Configuration - none
		SETB EADC ;Enable ADC interrupt.
		SETB TR2 ;Let Timer 2 start to run.
        SETB EA ;Enable interrupts globally.
        JMP $        
END