*********************************************************
*							*
*	RETURN CP/M COMMAND LINE TO MBASIC		*
*							*
*	A LINKABLE MODULE IN THE MICROSOFT		*
*	RELOCATION FORMAT				*
*							*
*	(C) 1981, Software Tools			*
*		  P.O. Box 80				*
*		  Newport Beach				*
*		  NSW, 2106				*
*		  AUSTRALIA				*
*							*
*	Written by:	Bill Bolton			*
*							*
*	Date:		26/Jan/1981			*
*							*
*	Version:	1.1	(Initial Release)	*
*							*
*	Date:		16/Feb/1981			*
*							*
*	Version:	1.2	Eliminated redundant	*
*				code, added length	*
*				checks and absolute	*
*				exit on terminator.	*	
*							*
*	-------------------------------------------	*
*							*
*	************ CAUTION *****************		*
*							*
*	This module will only work with the		*
*	Microsoft BASIC compiler			*
*							*
*	-------------------------------------------	*
*							*
*	INPUT PARAMETERS:				*
*							*
*	1st. passed in HL = Address of length of	*
*			    string (1 byte), followed	*
*			    pointer to string (2 bytes)	*
*							*
*	RETURNED VALUE:					*
*							*
*	1st. passed by writing command line buffer	*
*		    into string passed as 1st. input	*
*		    parameter. First leading blank	*
*		    is stripped if present.		*
*							*
*	Note 1	    If running under a debugger		*
*		    with command lines forced by	*
*		    using "I", the leading blank is	*
*		    not inserted in the command		*
*		    buffer by the debugger unless	*
*		    explicitly typed.			*
*							*
*	Note 2	    The CP/M CCP converts any		*
*		    lower case characters in the	*
*		    command line to UPPER CASE.		*
*							*		
*	------------------------------------------	*
*							*
*	Assembler:	RMAC.ASM (Digital Research)	*
*							*
*	Support:	MACRO3.LIB (Software Tools)	*
*							*
*********************************************************	    

	PUBLIC	CMD

	MACLIB	MACRO3

	CSEG

CMD:
	MOV	A,M		;GET LENGTH OF STRING
	STA	LENGTH		;SAVE IT FOR LATER
	INX	H		;HL <---- POINTER TO STRING LOC
	CONTENTS		;HL <---- POINTER TO BASIC STRING
	XCHG	      		;DE <---- POINTER TO BASIC STRING
	LXI	H,80H		;POINT TO COMMAND BUFFER
	MOV	A,M		;GET LENGTH OF COMMAND LINE
	ORA	A		;IS IT ZERO?
	RZ			;YES, DO NOTHING
	PUSH	H		;SAVE COMMAND LINE POINTER
	LXI	H,LENGTH	;POINT TO LENGTH OF BASIC STRING
	CMP	M		;WILL COMMAND LINE FIT?
	JC	FITS		;YES
	MOV	A,M		;NO, ONLY MOVE LENGTH THAT WILL FIT
FITS:
	POP	H		;RESTORE COMMAND LINE POINTER	
	MVI	B,0
	MOV	C,A		;BC <--- LENGTH TO MOVE
	DCX	D		;PREPARE FOR LOOP ENTRY
	INX	H		;POINT TO FIRST BYTE OF COMMAND
	MOV	A,M		;GET FIRST BYTE
	CPI	' '		;IS IT A SPACE?
	JZ	LOOP		;YES, IGNORE IT
	INX	D		;NO
	STAX	D		;SAVE IT
LOOP:
	INX	H		;POINT TO NEXT COMMAND BYTE
	INX	D		;POINT TO NEXT STRING BYTE
	MOV	A,M		;GET BYTE FROM COMMAND
	CPI	0		;IS IT TERMINATOR?
	RZ			;YES
	STAX	D		;PUT BYTE TO STRING
	DCR	C		;ADJUST COUNT
	JNZ	LOOP
	RET
;
;	DATA STORAGE
;
	DSEG
;
	DB	'Portions (C) 1981, Software Tools'
;
LENGTH:	DB	0		;POINTER TO BASIC LENGTH BYTE
;
	END
