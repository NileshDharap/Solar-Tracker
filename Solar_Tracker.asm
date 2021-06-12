EN 			EQU 	P3.0
RS 			EQU 	P3.1
RESULT_L	EQU 	30H
RESULT_H	EQU 	34H
H 			EQU 	31H
T 			EQU 	32H
U 			EQU 	33H
LDR			EQU 	35H
C1			EQU 	P3.7
C2			EQU 	P3.6
C3			EQU 	P3.5
C4			EQU 	P3.4

org 0000H

		JMP START

ORG 0003H

		MOV 		A,P1		//Take input from ADC 0-255
		CALL 		OPERATION
		CALL	    DISPLAY_RESULT
		CALL	 	SET_MOTOR
RETI


ORG 0100H

		START:
		MOV 	R2,#00H
		MOV 	P2,#00H  	;Config ssd
		MOV 	P1,#0FFH 	;Config adc
		MOV 	P0,#00H
		
		CLR 	C2
		CLR 	C3
		CLR		C1
		CLR 	C4		
		
//Initialize LCD 
		MOV A,#38H      
		CALL LCD_CMD
		MOV A,#0CH
		CALL LCD_CMD
		MOV A,#01H     //Display on ,cursor off, blink off
		CALL LCD_CMD
	
//Enable Interrupt for ADC

		SETB 	IT0		;-ve edge triggered interrupt
		SETB 	EA
		SETB 	EX0

		JMP 	$

ORG 0150H
DELAY_15MS:
		MOV 	R6,#30
delay:	MOV 	R7,#255
		DJNZ 	R7,$
		DJNZ 	R6,delay
		RET
	
ORG 	0200H
		MSG_disp: 
		MOV 	A,R2
		MOV 	DPTR ,#0300H
		MOVC 	A,@A+DPTR
		CALL 	LCD_DATA
		INC 	R2
		CJNE 	A,#00H,MSG_disp

		RET

ORG 0300H
		MSG: 	DB  "LIGHT INTENSITY:",00h
		
ORG 0350H
		LCD_CMD:
		MOV 	P2,A
		CLR 	RS
		SETB 	EN
		CALL 	DELAY_15ms
		CLR 	EN
		RET

ORG 0400H
		LCD_DATA:
		MOV 	P2,A
		SETB 	RS
		SETB 	EN
		CALL 	DELAY_15ms
		CLR 	EN
		RET

ORG 0450H	
DISPLAY_RESULT:

	MOV 	R2,#00h
	CALL 	MSG_disp


	MOV 	A,#0C7H
	CALL 	LCD_CMD


	MOV 	A,H
	CJNE 	A,#00,Notequal

	MOV 	A,#' '
	CALL	LCD_DATA

	Notequal:
	ADD 	A,#30H
	CALL	LCD_DATA

	MOV 	A,#0C8H
	CALL 	LCD_CMD

	MOV 	A,T
	ADD 	A,#30H
	CALL	LCD_DATA

	MOV 	A,#0C9H
	CALL 	LCD_CMD

	MOV 	A,U
	ADD 	A,#30H
	CALL	LCD_DATA

	MOV 	A,#0CAH
	CALL 	LCD_CMD
	MOV 	A,#'%'
	CALL 	LCD_DATA

	MOV 	A,#80H
	CALL 	LCD_CMD

RET

ORG 0500H
	OPERATION:
	CALL 	MULTIPLY_100

	CALL 	DIVIDE_255	;o/p 	Q-R1,R0		R-R3,R2
	
	MOV 	LDR,R2		;Store Quotient (Intensity in %)
	
	MOV 	A,LDR	
	
	//Get Individual Digits 
	MOV 	B,#10
	DIV 	AB
	MOV 	U,B
	
	MOV 	B,#10
	DIV 	AB
	
	MOV 	H,A
	MOV 	T,B
	
	RET
	
ORG 0550H
	DIVIDE_255:
	//This function takes following parameters
	//16-bit Dividend in R1(High) R0(Low)
	MOV 	R0,RESULT_L
	MOV 	R1,RESULT_H
	//16-bit Divisor  in R3(High) R2(Low)
	MOV		R3,#00H
	MOV 	R2,#255
	//This Function returns following parameters
	//16-bit Remainder in R1(High) R0(Low)
	//16-bit Quotient in  R3(High) R2(Low)	
div16_16:
	CLR C       ;Clear carry initially
	MOV R4,#00h ;Clear R4 working variable initially
	MOV R5,#00h ;CLear R5 working variable initially
	MOV B,#00h  ;Clear B since B will count the number of left-shifted bits
div1:
	INC B      ;Increment counter for each left shift
	MOV A,R2   ;Move the current divisor low byte into the accumulator
	RLC A      ;Shift low-byte left, rotate through carry to apply highest bit to high-byte
	MOV R2,A   ;Save the updated divisor low-byte
	MOV A,R3   ;Move the current divisor high byte into the accumulator
	RLC A      ;Shift high-byte left high, rotating in carry from low-byte
	MOV R3,A   ;Save the updated divisor high-byte
	JNC div1   ;Repeat until carry flag is set from high-byte
div2:        ;Shift right the divisor
	MOV A,R3   ;Move high-byte of divisor into accumulator
	RRC A      ;Rotate high-byte of divisor right and into carry
	MOV R3,A   ;Save updated value of high-byte of divisor
	MOV A,R2   ;Move low-byte of divisor into accumulator
	RRC A      ;Rotate low-byte of divisor right, with carry from high-byte
	MOV R2,A   ;Save updated value of low-byte of divisor
	CLR C      ;Clear carry, we don't need it anymore
	MOV 07h,R1 ;Make a safe copy of the dividend high-byte
	MOV 06h,R0 ;Make a safe copy of the dividend low-byte
	MOV A,R0   ;Move low-byte of dividend into accumulator
	SUBB A,R2  ;Dividend - shifted divisor = result bit (no factor, only 0 or 1)
	MOV R0,A   ;Save updated dividend 
	MOV A,R1   ;Move high-byte of dividend into accumulator
	SUBB A,R3  ;Subtract high-byte of divisor (all together 16-bit substraction)
	MOV R1,A   ;Save updated high-byte back in high-byte of divisor
	JNC div3   ;If carry flag is NOT set, result is 1
	MOV R1,07h ;Otherwise result is 0, save copy of divisor to undo subtraction
	MOV R0,06h
div3:
	CPL C      ;Invert carry, so it can be directly copied into result
	MOV A,R4 
	RLC A      ;Shift carry flag into temporary result
	MOV R4,A   
	MOV A,R5
	RLC A
	MOV R5,A		
	DJNZ B,div2 ;Now count backwards and repeat until "B" is zero
	MOV R3,05h  ;Move result to R3/R2
	MOV R2,04h  ;Move result to R3/R2
RET

org 0600h
	MULTIPLY_100:
	MOV 	B,#100
	MUL 	AB
	MOV 	RESULT_L,A
	MOV 	RESULT_H,B	
	RET
	
org 0650h
	SET_MOTOR:
	MOV 	A,LDR
	
	CJNE 	A,#66,label1	
	label1: JNC cond1			;if A>90 	Coil 2 set and Coil3 cleared
	
	CJNE 	A,#33,label2
	label2: JNC cond2			;if 90>A>50 Coil 2 and Coil3 set
	
	SETB 	C3					;if A<50 	Coil 3 set and Coil 2 cleared
	CLR 	C2
	RET
	
	cond1:
	SETB 	C2
	CLR 	C3
	RET
	
	cond2:
	SETB 	C2
	SETB	C3
	RET
end