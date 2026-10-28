*********************************************************
*							*
*	  User Number Display in CP/M Prompt		*
*		A Patch for CP/M 2.2			*
*							*
*********************************************************
;
;	Bill Bolton
;	Software Tools
;	P.O. Box 80,
;	Newport Beach,
;	NSW, 2106
;	AUSTRALIA
;
;	Source Address TCY 396
;
;	August 25, 1981
;
PATCH$AREA	EQU	0F700H		;Somewhere above bios
CCP		EQU	0CF00H		;Insert your CCP address here
PATCH1		EQU	CCP+388H
BDOS$CURRENT$DISK	EQU	CCP+1D0H
GET$USER	EQU	CCP+113H
BDOS$CON$OUT	EQU	CCP+08CH
;
;
	ORG	PATCH1			;PATCH THE CCP
;
	JMP	PATCH$AREA		;OVERLAYS CALL TO
					;BDOS$CURRENT$DISK
;
	ORG	PATCH$AREA
;
	CALL	GET$USER
	CPI	10			;USER NO. > 9?
	JC	FILL1			;NO
	SUI	10			;YES, MODULO 10
	PUSH	PSW			;SAVE REMAINDER FOR LATER
	MVI	A,'1'			;>10 SO PRINT TENS DIGIT
	CALL	BDOS$CON$OUT
	POP	PSW			;RECOVER REMAINDER
FILL1:
	ADI	'0'			;ASCII ADJUST
	CALL	BDOS$CON$OUT		;DISPLAY IT
	JMP	BDOS$CURRENT$DISK	;THIS IS WHAT THE JMP TO
					;PATCH OVERLAID, BDOS
					;PROVIDES THE RETURN
	END
