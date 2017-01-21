SHIFT	EQU 1
NULL	EQU 0

;//////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////
;	(Kyle Hewitt CS2400 HW4 Problem A)	
;
;This main routine marks the beggining and end of 
;	each group of Byte hex values then building them 
;	into a single word by calling the subroutine.
;	The main routine then negates the first value and
;	adds them together (-a+b).
;//////////////////////////////////////////////////////////////////////////////////////////////
;R0	Marker for the MSD	R1	Marker for the LSD
;R5	Holds A's word		R2	Holds the contents of the word when built/being built
;R6	Holds B's word		R8 	Contains the address in memory where RESULT points to
;//////////////////////////////////////////////////////////////////////////////////////////////
;//////////////////////////////////////////////////////////////////////////////////////////////
	AREA	HW4AddHex, CODE
	ENTRY

Main
	LDR R0, =A_MSD		;Load the pointer of the first address of number A into R0
	LDR R1,=A_LSD		;Load the pointer of the last address of number A into R1
	BL BuildNum		;Start subroutine
	TST R2, #2, 2		;test the contents of R2 against #2 LSL left which would be the smallest 2s comp negitive value
	BNE DONE		;if the masks match it means that number A is out of range
	MVN R5, R2		;takes the bitwise invert of R2
	ADD R5, R5, #SHIFT	;adds one to get the negitive 2s comp
	

	LDR R0,=B_MSD		;Load the pointer of the first address of number B into R0
	LDR R1,=B_LSD		;Load the pointer of the last address of number B into R1
	BL BuildNum		;Start subroutine
	TST R2,#2,2		;test the contents of R2 against #2 LSL left which would be the smallest 2s comp negitive value
	BNE DONE		;if the masks match it means that number A is out of range
	MOV R6, R2		;moves the contents of the result of number B into R6
	
	ADD R7,R5,R6		;Add the negitive 2s comp of A to B into R7
	LDR R8, =RESULT		;Loads the address to R8
	STR R7,[R8]		;Stores the result into the memory address at RESULT


DONE	SWI 0x11		;terminate program

;//////////////////////////////////////////////////////////////////////////////////////////////
;	This subroutine loads hex Bytes from memory and builds them into a single word
;//////////////////////////////////////////////////////////////////////////////////////////////
;R2	Holds the value of the built word	R3 Holds the Byte value pointed to by [R0]
;R4 	Holds the value of the word as each value is being shifted
;//////////////////////////////////////////////////////////////////////////////////////////////

BuildNum
	MOV R2,#0		;zeros the contents of R2

;////////////////////////////////////////////////////

Loop
	MOV R3, #0		;zeros the contents of R3
	LDRB R3, [R0],#SHIFT	;adds the first bite contained at the address in R0 then incriment the counter
	CMP R3, #0X0		;compares the contents loaded to R3 to the constant 0x0
	BLO INVALID		;if it is below zero it is out of the range of the possible hex symbols 
	CMP R3, #0XF		;compares the contents loaded to R3 to the constant 0xF
	BHI INVALID		;if it is above 0xF(15) it is out of the range of the possible hex symbols
	

	MOV R4,R2,LSL #SHIFT	;____________________________________________________________________________________
	TST R4, #2, 2		;____________________________________________________________________________________
	BNE INVALID		;____________________________________________________________________________________
				;____________________________________________________________________________________
	MOV R4,R4,LSL #SHIFT	;____________________________________________________________________________________
	TST R4, #2, 2		;____________________________________________________________________________________
	BNE INVALID		;	All the steps in this block shifts each bit left 1 at a time then checks_____ 
				;	if that rotation pushed a bit into the MSB causing it to go negitive and_____
	MOV R4,R4,LSL #SHIFT	;	pushing it out of 2s comp range.                                        _____
 	TST R4, #2, 2		;____________________________________________________________________________________
	BNE INVALID		;____________________________________________________________________________________
				;____________________________________________________________________________________
	MOV R4,R4,LSL #SHIFT	;____________________________________________________________________________________
	TST R4, #2, 2		;____________________________________________________________________________________
	BNE INVALID		;____________________________________________________________________________________

	ADD R2,R4,R3		;Add the most recent number to the LSD in the new number
	TST R4, #2, 2		;Test to see if the resulting number is positive
	BNE INVALID		;If not skip to the invalid case

	CMP R0,R1		;compare the address in R0(MSD) to R1(LSD)
	BHI DONE_BLDNUM		;If the LSD address is higher than the MSD address it means that the number is complete
	B Loop			;Otherwise loop back and do it again

;////////////////////////////////////////////////////

INVALID
	LDR R2, =0XFFFFFFFF	;If at any point an invalid digit is found R2 is defaulted to 0xFFFFFFFF

;////////////////////////////////////////////////////

DONE_BLDNUM
	
	MOV PC, LR		;Return from subroutine

;////////////////////////////////////////////////////

	AREA	Data, DATA

A_MSD	DCB	0X3	;A's Most Significant Digit
	DCB	0XA
	DCB	0X4
A_LSD	DCB	0X5	;A's Least Significant Digit
	ALIGN
 
B_MSD	DCB	0X2	;B's Most Significant Digit
	DCB	0X4
	DCB	0X6
	DCB	0X8
	DCB	0XC
B_LSD	DCB	0XF	;B's Least Significant Digit
	ALIGN

RESULT
	DCD	0	;The address for where the result will be saved
	
;////////////////////////////////////////////////////

	END