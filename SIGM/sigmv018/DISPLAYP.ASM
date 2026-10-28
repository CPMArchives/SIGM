;
;			DISPLAYP.ASM
;		 by Keith Petersen, W8SDZ
;		     (revised 11/22/80)
;
;This patch fixes DISPLAY.COM so it will not accept wild-cards,
;distribution-tagged files, SYS files, and files with '#' as the
;last character of the file type.  Compatible with CP/M 1.4 or 2.x.
;
BDOS	EQU	05H
FCB	EQU	5CH
OPEN	EQU	15
CR	EQU	0DH
LF	EQU     0AH
ENTRY	EQU	121H	;DISPLAY.COM ENTRY ADDRESS
;        
	ORG     100H
;
	JMP	PATCH
;
	ORG	821H
;
;Check for ambiguous file names
;
PATCH	LXI	H,FCB	;POINT TO FCB
	MVI	B,11	;NR OF CHARS TO CHECK
;
LOOP	INX	H	;POINT TO NEXT CHAR
	MOV	A,M	;GET CHAR
	CPI	'?'	;WAS IT A '?'
	JZ	WERROR	;YES, EXIT WITH ERROR MSG
	DCR	B	;ONE LESS TO CHECK
	JNZ	LOOP	;NOT DONE, GO GET MORE
;
;Check for private file type
;
	CPI	'#'	;WAS LAST CHARACTER A '#' ?
	JZ	OPENOT	;YES, PRINT ERROR AND EXIT
;
;Check for .COM file, which can't be printed
;
	CPI	'M'	;WAS LAST CHAR AN 'M'?
	JNZ	OBJCHK	;IF NOT, CHK FOR '.OBJ' TYPE
	DCX	H
	MOV	A,M	;CHK NEXT
	CPI	'O'	;AN 'O'?
	JNZ	OPENFIL	;IF NOT, GO OPEN FILE
	DCX	H
	MOV	A,M	;WAS 'O', CHK NEXT CHAR
	CPI	'C'	; 'C' AS IN '.COM'?
	JNZ	OPENFIL	;IF NOT, GO OPEN FILE
	CALL	ERXIT	;EXIT W/MESSAGE
	DB	'++CAN''T DISPLAY .COM FILES$'
;
;Check for .OBJ file, which can't be printed
;
OBJCHK	CPI	'J'	;WAS LAST CHAR AN 'J' THEN?
	JNZ	OPENFIL	;IF NOT, GO OPEN FILE
	DCX	H
	MOV	A,M	;MIGHT BE '.OBJ', CHK NEXT CHR
	CPI	'B'	;IS IT A 'B'?
	JNZ	OPENFIL	;IF NOT, GO OPEN FILE
	DCX	H
	MOV	A,M	;WAS, CHK FIRST CHAR
	CPI	'O'	; 'O' AS IN '.OBJ'?
	JNZ	OPENFIL	;IF NOT, GO OPEN FILE
	CALL	ERXIT	;EXIT W/MESSAGE
	DB	'++CAN''T DISPLAY .OBJ FILES$'
;
;Open the file to get attributes into FCB
;
OPENFIL	LXI	D,FCB	;POINT TO FILE
	MVI	C,OPEN	;GET FUNCTION
	CALL	BDOS	;OPEN IT
	INR	A	;OPEN OK?
	JZ	ENTRY	;..NO, LET DISPLAY GIVE ERROR MSG
;
;Check for SYS file
;
	LDA	FCB+10	;GET SYS ATTRIBUTE
	ANI	80H	;ISOLATE ATTR BIT
	JNZ	OPENOT	;IT'S SYS, EXIT
;
;Check for distribution-protected (tagged) file
;
	LDA	FCB+1	;FIRST CHAR OF FILE NAME
	ANI	80H	;CHECK BIT 7
	JZ	ENTRY	;IT WAS OFF, EXIT TO DISPLAY
;
OPENOT	CALL	ERXIT	;EXIT W/MESSAGE
	DB	'++FILE IS NOT FOR DISTRIBUTION, SORRY$'
;
WERROR	CALL	ERXIT
	DB	'++CAN''T USE WILD CARDS$'
;
;Exit with error message
;
ERXIT	POP	D	;GET MSG ADRS
	MVI	C,9 
	JMP	BDOS	;PRINT IT THEN RETURN TO CCP
;
	END
