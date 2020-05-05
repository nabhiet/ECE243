/* Program that counts consecutive 1s */

          .text                   // executable code follows
          .global _start                  
_start:              
			      MOV	  R5, #0		   // R5 will hold the result of the longest string of 1s
				  MOV     R6, #0		   // R6 will hold the result of the longest string of 0s
				  MOV     R7, #0           // R7 will hold the result of the longest string of alternating 1s and 0s
	              MOV     R4, #TEST_NUM    // load the data word ...
				  LDR     R10, =0xffffffff // used for inverting a string of bits 
				  LDR     R11, =0x55555555 // used for finding alternating 1s and 0s
				  LDR     R12, =0xaaaaaaaa // used for finding alternating 0s and 1s
				  
MAIN_LOOP:	      LDR     R1, [R4]        // load into R1
			      CMP     R1, #0		  // check if the list is done
			      BEQ     DISPLAY         // end the program if the list is done
			      BL      ONES            // find the largest string of 1s in current word
			      CMP     R5, R0          // compare and keep higher result in R5
			      MOVLT   R5, R0		   
				  LDR     R1, [R4]		  // load into R1 again
				  BL      ZEROS           // find the largest string of 0s in current word
				  CMP     R6, R0          // compare and keep higher result in R6
				  MOVLT   R6, R0          
				  LDR     R1, [R4]        // load into R1 again
				  LDR     R3, [R4]        // load into R3 as well 
				  BL      ALTERNATE       // find the largest string of alternating 1s & 0s or 0s & 1s in current word
				  CMP     R7, R0          // compare and keep higher result in R7
				  MOVLT   R7, R0          
				  ADD	  R4, #4          // go to next word
			      B       MAIN_LOOP		  // loop to read next word
			  
END:	          B       END

// find longest string of 1s
ONES:	          MOV     R0, #0          // R0 will hold the result
ONES_LOOP:	      CMP     R1, #0          // check if there are any more 1's
	              BEQ     ONES_END        // if R1 is 0 then leave loop     
	              LSR     R2, R1, #1      // perform SHIFT, followed by AND
	              AND     R1, R1, R2      
	              ADD     R0, #1          // count the string length so far
	              B       ONES_LOOP       // loop to find more 1s  
ONES_END:         MOV     PC, LR          // return to main   

// find longest string of 0s
ZEROS:	          MOV     R0, #0          // R0 will hold the result
				  EOR     R1, R10         // XOR R1 and R19 to invert R1
ZEROS_LOOP:	      CMP     R1, #0          // check if there are any more 1's
	              BEQ     ZEROS_END       // if R1 is 0 then leave loop     
	              LSR     R2, R1, #1      // perform SHIFT, followed by AND
	              AND     R1, R1, R2      
	              ADD     R0, #1          // count the string length so far
	              B       ZEROS_LOOP      // loop to find more 1s  
ZEROS_END:        MOV     PC, LR          // return to main 

// find longest string of alternating 1s and 0s
ALTERNATE:	  	  PUSH    {R8, LR}
				  MOV     R0, #0          // R0 will hold the 1s&0s and final result
				  MOV     R8, #0          // R8 will hold the 0s&1s result
				  EOR     R1, R11         // used for checking alternating 1s and 0s
				  EOR	  R3, R12 	      // used for checking alternating 0s and 1s
ALTERNATE_LOOP_10:CMP     R1, #0          // check if there are any more 1's
	          	  BEQ     ALTERNATE_LOOP_01   // if R1 is 0 then leave loop     
	              LSR     R2, R1, #1      // perform SHIFT, followed by AND
	              AND     R1, R1, R2      
	              ADD     R0, #1          // count the string length so far
	              B       ALTERNATE_LOOP_10  // loop to find more 1s  
ALTERNATE_LOOP_01:CMP     R3, #0          // check if there are any more 1's
	          	  BEQ     ALTERNATE_END   // if R3 is 0 then leave loop     
	              LSR     R2, R3, #1      // perform SHIFT, followed by AND
	              AND     R3, R3, R2      
	              ADD     R8, #1          // count the string length so far
	              B       ALTERNATE_LOOP_01  // loop to find more 1s
ALTERNATE_END:    CMP	  R0, R8		  // compare the 1s&0s and 0s&1s counters and store highest in R0
				  MOVLT   R0, R8
				  POP    {R8, LR}
				  MOV     PC, LR          // return to main


/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R0 = the decimal value of the digit to be displayed
 *    Returns: R0 = bit patterm to be written to the HEX display
 */
SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110 // 0, 1, 2, 3, 4
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111 // 5, 6, 7, 8, 9
            .skip   2      // pad with 2 bytes to maintain word alignment
			

/* Display R5 on HEX1-0, R6 on HEX3-2 and R7 on HEX5-4 */
DISPLAY:    LDR     R8, =0xFF200020 // base address of HEX3-HEX0
            MOV     R0, R5          // display R5 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R4, R0          // save bit code
            MOV     R0, R9          // retrieve the tens digit, get bit code
            BL      SEG7_CODE       
            LSL     R0, #8
            ORR     R4, R0
						
            MOV     R0, R6          // display R6 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE  
			LSL     R0, #16
            ORR     R4, R0
            MOV     R0, R9          // retrieve the tens digit, get bitcode
            BL      SEG7_CODE       
            LSL     R0, #24
            ORR     R4, R0
            STR     R4, [R8]        // display the numbers from R6 and R5
			
            LDR     R8, =0xFF200030 // base address of HEX5-HEX4
            MOV     R0, R7          // display R7 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R4, R0          // save bit code
            MOV     R0, R9          // retrieve the tens digit, get bitcode
            BL      SEG7_CODE       
            LSL     R0, #8
            ORR     R4, R0
            STR     R4, [R8]        // display the number from R7
			B		END

DIVIDE:     MOV    R2, #0      //initializes R2 to have a value of 0
CONT:       CMP    R0, #10       
            BLT    DIV_END     // If is R0 < 10, branch to the end and exit the loop
            SUB    R0, #10     // subtracts 10 from R0. R0= R0 - 10
            ADD    R2, #1      // Increments the counter for the number of times 10 is subtracted
            B      CONT        // Continues the loop 
						
DIV_END:    MOV    R1, R2     // quotient in R1 (remainder in R0)
            MOV    PC, LR
			
TEST_NUM: 	      .word   0x103fe00f  
			      .word   0x103fe00f 
			      .word   0x103fe00f 
			      .word   0x103f0000	// longest string of 0s should be here (16, hex:10)
			      .word   0x103fe00f 
			      .word   0xffffffff 	// longest string of 1s should be here (32, hex:20)
		    	  .word   0x103fe00f 
		    	  .word   0x103fe00f 
		    	  .word   0xaaafe00f    // longest string of alternating should be here (13, hex:d)	
		    	  .word   0x103fe00f 
		    	  .word   0x00000000
                  .end
