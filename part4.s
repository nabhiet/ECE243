     /* Progam that converts a binary number to decimal */
           .text               // executable code follows
           .global _start
_start:     
			
            MOV    R4, #N       // R4 points to the number to be converted
            MOV    R5, #Digits  // R5 points to the decimal digits storage location
            LDR    R4, [R4]     // R4 holds N
            MOV    R0, R4       // parameter for DIVIDE goes in R0
			
			MOV    R1, #1000	
			
			BL     DIVIDE
			STRB   R3,[R5, #3] 	//stores the thousands value into the address at R5+3
			MOV    R1, #100      // place hundreds number into R0 before branching again
			
			BL     DIVIDE  
			STRB   R3, [R5,#2] // stores the hundreds value from R1 into the address at R5+2
			MOV    R1, #10       // place tens number into R0 before branching again
			 
			BL     DIVIDE
            STRB   R3, [R5, #1]  //stores the tens value into the address at R5+1
			
    		STRB   R0, [R5]     //store the remainder which is the value of the ones
			
END:        B      END

/* Subroutine to perform the integer division R0 / 10.
 * Returns: quotient in R1, and remainder in R0
*/
// Uses conditional statements

		
DIVIDE:     MOV    R2, #0      //initializes R2 to have a value of 0
CONT:       CMP    R0, R1       
            BLT    DIV_END     // If is R0 < 10, branch to the end and exit the loop
            SUB    R0, R1      // subtracts 10 from R0. R0= R0 - 10
            ADD    R2, #1      // Increments the counter for the number of times 10 is subtracted
            B      CONT        // Continues the loop 
			
			
DIV_END:    MOV    R3, R2     // quotient in R1 (remainder in R0)
            MOV    PC, LR
			
N:          .word 6032         // the decimal number to be converted
Digits:     .space 4         // storage space for the decimal digits
            .end


