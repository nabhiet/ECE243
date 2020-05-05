/* Program that displays decimal digit on HEX0 based on KEY presses */

          .text                     // executable code follows
          .global _start

_start:     LDR     R4, =0xFF200020 // base address of HEX3-HEX0
		    LDR     R5, =0xFF200050 // base address of KEYS
			MOV     R8, #0          // counter for hex (initial value is 0)
			
READ:       LDR     R6, [R5]        // read KEYS
			MOV     R7, R6          // save the key value
			CMP     R6, #0
			BEQ     CHECK_KEY       // display nothing if no key is pressed

WAIT:       LDR     R6, [R5]
			CMP     R6, #0
			BNE     WAIT

CHECK_KEY:  CMP     R7, #0	        // when no key is pressed		
			MOVEQ   R8, R8
			
			CMP     R7, #1	        // when key0 is pressed		
			MOVEQ   R8, #0
			
			CMP     R7, #2          // when key1 is pressed
        	ADDEQ   R8, #1
			CMP     R8, #9          // check if >9
			MOVGT   R8, #0          // start back from 0
			
			CMP     R7, #4          // when key2 is pressed
			SUBEQ   R8, #1
			CMP     R8, #0          // check if <0
			MOVLT   R8, #9          // start back from 9
			
			CMP     R7, #8          // when key3 is pressed
			BEQ     BLANK           // blank the display
			
DISPLAY:	MOV     R0, R8
			BL      SEG7_CODE
			STR     R0, [R4]
			B       READ

BLANK:      MOV     R0, #0          // set hex value to blank
			STR     R0, [R4]
			MOV     R7, #1          // force hex to show 0
			
WAIT_BLANK: LDR     R6, [R5]        // wait for next key to be pressed 
			CMP     R6, #0          
			BEQ     WAIT_BLANK
			B       WAIT            // display zero after next key is released
			 
SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0          // index into the BIT_CODES "array"
            LDRB    R0, [R1]        // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment
			.end

