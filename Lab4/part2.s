/* Program that counts consecutive 1s */

          .text                   // executable code follows
          .global _start                  
_start:              
			  MOV	  R5, #0		  // R5 will hold the result
	          MOV     R4, #TEST_NUM   // load the data word ...
MAIN_LOOP:	  LDR     R1, [R4], #4    // go to next word
			  CMP     R1, #0		  // check if the list is done
			  BEQ     END             // end the program if the list is done
			  BL      ONES            // find the largest string of 1s in current word
			  CMP     R5, R0          // compare current word's result to previous word's result
			  MOVLT   R5, R0		  // keep higher result in R5
			  B       MAIN_LOOP		  // loop to read next word
			  
END:	      B       END 

ONES:	      MOV     R0, #0          // R0 will hold the result
ONES_LOOP:	  CMP     R1, #0          // check if there are any more 1s
	          BEQ     ONES_END        // if R1 is 0 then leave loop     
	          LSR     R2, R1, #1      // perform SHIFT, followed by AND
	          AND     R1, R1, R2      
	          ADD     R0, #1          // count the string length so far
	          B       ONES_LOOP       // loop to find more 1s  
ONES_END:     MOV     PC, LR          // return to main   

TEST_NUM: 	  .word   0x103fe00f  
			  .word   0x103fe00f 
			  .word   0x103fe00f 
			  .word   0x103fe00f 
			  .word   0x103fe00f 
			  .word   0xffffffff 
			  .word   0x103fe00f 
			  .word   0x103fe00f 
			  .word   0x103fe00f 
			  .word   0x103fe00f 
			  .word   0x00000000
              .end                            

	