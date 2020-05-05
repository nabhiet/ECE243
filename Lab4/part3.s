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
			      BEQ     END             // end the program if the list is done
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

TEST_NUM: 	      .word   0x103fe00f  
			      .word   0x103fe00f 
			      .word   0x103fe00f 
			      .word   0x103f0000	// longest string of 0s should be here (16, hex:10)
			      .word   0x103fe00f 
			      .word   0xffffffff 	// longest string of 1s should be here (32, hex:20)
		    	  .word   0x103fe00f 
		    	  .word   0x103fe00f 
		    	  .word   0x05555555    // longest string of alternating should be here (13, hex:d)	
		    	  .word   0x103fe00f 
		    	  .word   0x00000000
                  .end                            

	
	
	
	
	