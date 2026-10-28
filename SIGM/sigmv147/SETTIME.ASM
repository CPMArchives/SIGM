; DATE 10/07/83  10:48      last revision
;

	TITLE	'Sets Compupro Clock'
;
; SETTIME.ASM
; DATE 08/29/83  19:47
; by: H.M. Van Tassell, 120 Hill Hollow Rd, Watchung NJ  07060 (201)755-5372
;
; This is the standard Compupro program to set the system support clock and
; it has been modified to include the day of the week byte. This byte is used
; by some programs ie COMM7 to show the day of the week.
;
; 

		BASE 	EQU 	50H
		CLKCMD 	EQU     BASE+10
		CLKDATA	EQU	BASE+11
		BDOS	EQU	0005H
		READ 	EQU     10H
		WRITE	EQU 	20H
		HOLD	EQU 	40H
		
		ORG	100H	



		LXI	SP,STACK
START		LXI	D,SIGNON 
		CALL	PMSG
		CALL	GETCHAR
		CPI	'X' 
		JZ	0000H
		CPI	'S'
		JZ	SETTIME
		CPI	'P'
		JZ	PTIME
		CPI	'C'
		JZ	FOREVER
		LXI	D,ERROR
		CALL	PMSG
		JMP	START

SETTIME		CALL	GETTIME
		LXI	H,DTABLE
		LXI	D,ATABLE
		MVI	B,14
		MVI	A,HOLD
		OUT	CLKCMD 
SET1		DCR	B
		JNZ	HERE
		MVI	A,0
		OUT	CLKCMD
		LXI	D,TIMEIS
		CALL	PMSG
		CALL	RDDAY
		CALL	CLKPRNT
		JMP	START
HERE		MOV	A,M
		MOV	C,A
		LDAX	D
		CALL	WRTDGT
		INX	H
		INX	D
		JMP 	SET1
		
GETTIME		LXI	D,ASKDAY
		CALL	PMSG
		LXI	H,DTABLE
GET3		CALL	GETCHAR
		CPI	'0'
		JC	GET3
		CPI	'6'+1
		JNC	GET3
		ANI	0FH
		MOV	M,A
		INX	H
TIME	 	LXI	D,ASKTIME
		CALL	PMSG
GET1		CALL	GETNUMB
		CPI	0DH
		JZ	GETDATE
		ANI	0FH
		MOV	M,A
		INX	H
		JMP	GET1
GETDATE		LXI	D,ASKDATE
		CALL	PMSG
GET2		CALL	GETNUMB
		CPI	0DH
		RZ
		ANI	0FH
		MOV	M,A
		INX	H
		JMP	GET2

GETNUMB		CALL	GETCHAR
		CPI	0DH 
		RZ
		CPI	'0'
		JC	GETNUMB
		CPI	'9'+1
		JNC	GETNUMB
		RET

WRTDGT		PUSH	PSW
		ADI	HOLD
		OUT	CLKCMD
		CPI 	5+HOLD
		JNZ	WRT1
		MOV	A,C
		ADI	08H
		JMP     WRT3
WRT1		CPI	8+HOLD
		JNZ	WRT2
		MOV	A,C
		ANI	03H
		JMP	WRT3
WRT2		MOV	A,C
WRT3		OUT	CLKDATA
		POP	PSW
		ADI	WRITE+HOLD
		OUT	CLKCMD
		SUI	WRITE
		OUT	CLKCMD
		RET

RDDGT		ADI	READ
		OUT	CLKCMD
		CPI	05H+READ
		IN	CLKDATA
		RNZ
		SUI	08H
		RET

CLKPRNT		LXI	H,RTABLE
		CALL	PRINTWO 
		MVI	A,'/'
		CALL 	PCHAR
		CALL	PRINTWO
		MVI	A,'/'
		CALL	PCHAR
		CALL	PRINTWO
		MVI	A,' '
		CALL	PCHAR
		MVI	A,' '
		CALL	PCHAR
		CALL	PRINTWO
		MVI	A,':'
		CALL    PCHAR
		CALL	PRINTWO
		MVI	A,':'
		CALL	PCHAR
		CALL	PRINTWO
		RET

PRINTWO		MOV	A,M
		CALL	RDDGT
		ADI	30H
		CALL	PCHAR
		INX	H
		MOV	A,M
		CALL	RDDGT
		ADI	30H
		CALL 	PCHAR
		INX	H
		RET

PTIME		LXI	D,TIMEIS
		CALL	PMSG
		CALL	RDDAY
		CALL	CLKPRNT 
		JMP	START

FOREVER		MVI	A,0AH
		CALL	PCHAR
FOR1		MVI	A,0DH
		CALL 	PCHAR
		CALL	CLKPRNT 
		MVI	A,0
		CALL	RDDGT
		MOV	B,A
FOR2		MVI	A,0
		CALL	RDDGT
		CMP	B
		JZ	FOR2
		JMP	FOR1

GETCHAR		PUSH	H
		MVI	C,01
		CALL	BDOS
		POP	H
		CPI	'a'
		JC	SKIP
		CPI	'z'+1
		JNC	SKIP
		ANI	5FH
SKIP		ANI	7FH
		CPI	03H
		JZ	0000H
		RET

PCHAR		PUSH	D
		MOV	E,A
		MVI	C,02H
		PUSH	H
		CALL	BDOS
		MVI	C,0BH
		CALL	BDOS
		POP 	H
		POP	D
		ORA	A
		CNZ	GETCHAR
		RET

RDDAY	MVI	A,6		;day of week
	CALL	RDDGT
	RLC			; *2 for tbl offset
	LXI	H,DTBL		;point to day table

TBLO	MOV	E,A		;shift factor..
	MVI	D,0		;..into de-pair.
	DAD	D		;add offset to hl-pair
	MOV	E,M		;put address into..
	INX	H
	MOV	D,M		;..de-pair.  then..
	CALL	PMSG		;PRINT IT
	RET

PMSG		PUSH	H
		MVI	C,09H
		CALL	BDOS
		POP	H
		RET


SIGNON		DB	0DH,0AH,0DH,0AH,'Time and date test routines for '
		DB	'System Support 1',0DH,0AH,0DH,0AH
		DB	'Please type one of the following commands:',0DH,0AH
		DB	'S - Set the time and date',0DH,0AH
		DB	'P - Print the time and date once',0DH,0AH
		DB	'C - Continuously print the time and date',0DH,0AH
		DB	'X - Exit to operating system',0DH,0AH
		DB	0DH,0AH,'Command: $'
    	
ERROR		DB	0DH,0AH,'That was not one of the commands.'  
		DB	0DH,0AH,'Please try again $'

ASKTIME		DB	0DH,0AH,'What is the time ? (HH:MM:SS) $'

ASKDATE		DB	0DH,0AH,'What is the date ?  (MM/DD/YY) $'

ASKDAY		DB	0DH,0AH,'Day of the week ? (Sun=0,Sat=6) $'

TIMEIS		DB	0DH,0AH,'The time and date are: $'


DTBL	DW	SUN		;daytable
	DW	MON
	DW	TUE
	DW	WED
	DW	THU
	DW	FRI
	DW	SAT

SUN	DB	'Sunday $'
MON	DB	'Monday $'
TUE	DB	'Tuesday $'
WED	DB	'Wednesday $'
THU	DB	'Thursday $'
FRI	DB	'Friday $'
SAT	DB	'Saturday $'


ATABLE		DB	6,5,4,3,2,1,0,10,9,8,7,12,11

RTABLE		DB	10,9,8,7,12,11,5,4,3,2,1,0

DTABLE		DS	13

		DS	32
STACK
