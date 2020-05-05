/* Program that displays a two-digit decimal counter on HEX1-0 
that starts/stops based on KEY presses using a hardware timer*/

          .text                     // executable code follows
          .global _start

_start:     LDR     R4, =0xFF200020 // base address of HEX3-HEX0
		    LDR     R5, =0xFF200050 // base address of KEYS
			MOV     R8, #0          // counter for hex (initial value is 0)
			LDR     R10, =0xFFFEC600 // address of A9 Private Timer
			LDR     R3, =50000000    
			STR     R3, [R10]
			MOV     R3, #0b011
			STR     R3, [R10, #8]   // write to control register
			
READ:       LDR     R6, [R5]        // read KEYS
			MOV     R7, R6          // save the key value
			CMP     R6, #0
			BEQ     READ            // Wait for key to be pressed

WAIT:       LDR     R6, [R5]
			CMP     R6, #0
			BNE     WAIT
			STR     R7, [R5, #0xC]
	        					
DISPLAY:	ADD     R8, #1			// add one to counter if KEY is pressed
			CMP     R8, #99
			MOVGT   R8, #0			// reset to 0 when counter reaches 99
			MOV     R0, R8          
            BL      DIVIDE          // ones digit will be in R0; tens digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R2, R0          // save bit code
            MOV     R0, R9          // retrieve the tens digit, get bit code
            BL      SEG7_CODE       
            LSL     R0, #8
            ORR     R2, R0
            STR     R2, [R4]        // display the number of the counter

DO_DELAY:   LDR     R3, [R10, #0xC] // wait for status register
			CMP     R3, #0           
			BEQ     DO_DELAY        // wait for F bit
			STR     R3, [R10, #0xC] // reset F bit
			
PAUSE:      LDR     R6, [R5]        // read KEYS
			MOV     R7, R6          // save the key value
			CMP     R6, #0
			BEQ     DISPLAY         // Wait for key to be pressed

WAIT_AGAIN: LDR     R6, [R5]
			CMP     R6, #0
			BNE     WAIT_AGAIN
			STR     R7, [R5, #0xC]
			B       READ

DIVIDE:     MOV    R2, #0      //initializes R2 to have a value of 0
CONT:       CMP    R0, #10       
            BLT    DIV_END     // If is R0 < 10, branch to the end and exit the loop
            SUB    R0, #10     // subtracts 10 from R0. R0= R0 - 10
            ADD    R2, #1      // Increments the counter for the number of times 10 is subtracted
            B      CONT        // Continues the loop 
						
DIV_END:    MOV    R1, R2     // quotient in R1 (remainder in R0)
            MOV    PC, LR
			 
SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0          // index into the BIT_CODES "array"
            LDRB    R0, [R1]        // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment
			.end