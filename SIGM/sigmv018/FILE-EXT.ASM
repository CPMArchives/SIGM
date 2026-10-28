; 
;                       FILE-EXT.ASM
;  
;  Originally  named  FILES.ASM,  and  from a  disassembly  by 
; "J.A.P"  of January 23,1980...FILE-EXT.ASM will display  the 
; selected disk's directory entries in the form:
; 
;          Filename.Typ   exs1s2rc <-----Group----->
;          =========================================
; 
;  The "hack-job" I did on this one was less than  ideal,  but 
; none the less, it get's the job done...the display format is 
; now  alot  cleaner,  and  it  does'nt  "warm  boot"  as  the 
; FILES.ASM version did...
; 
;  The  program will display the disk directory of the  logged 
; on  disk,  including all the Hexadecimal information on  the 
; groups.  If an illegal character is found in the filename or 
; filetype,  it  will  prompt  the operator as to  whether  to 
; delete the file (or not).  If the operator answers Y  (yes), 
; the  program will go on displaying more file information and 
; stopping  when  a bad filename or filetype  is  encountered. 
; When the display is all done,  the files that were  selected 
; for deletion will be removed from the directory.
; 
;  On  the  subject  of  "hack-job's"  of  software,  read  an 
; interesting  article  in  Psychology  Today  magazine,  "The 
; Hacker  Papers;  Computer  Addiction:  Reflection on  a  New 
; Obsession"...August 1980 issue, pages 62-69.
; 
;                               Best regards,
; 
;                               Kelly Smith, CP/M-NET (tm)
;                               805-527-9321 (Modem, 300 Baud)
;                               805-527-0518 (Verbal)
; 

	ORG	0100H

BDOS	EQU	05H
TBUFF	EQU	80H
;
CR	EQU	0DH	;ASCII CARRIAGE RETURN
LF	EQU	0AH	;ASCII LINE FEED
;
;
FILES:			; 
	LXI	H,0	;
	DAD	SP	;
	SHLD	OLDSTK	;
	LXI	SP,NEWSTK	;
	JMP	BEGIN	;
;
;
;	SYSTEM SUBROUTINES
;
;	PRINT STRING FROM D&E REGS.
;
PRINT:	MVI	C,9
	CALL	BDOS
	RET
;
;	TYPE A CHAR FROM (A)
;
TYPE:		; 
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,2
	MOV	E,A
	CALL	BDOS	;
	POP	H
	POP	D
	POP	B
	RET
;
;	SEARCH FOR A FILE
;
SEARCH:		; 
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,11H
	LXI	D,AFN	;
	CALL	BDOS	;
	STA	RESULT	;
	POP	H
	POP	D
	POP	B
	RET
;
;	AMBIGUOUS FILENAME.TYP
;
AFN:		; 
	DB	'?????????????'
RESULT:		; 
	DB	0	;STORAGE FOR RESULT OF BDOS CALL
;
;	FIND NEXT OCCURRENCE OF FILE
;
NEXTFILE:		; 
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,12H
	LXI	D,AFN	;
	CALL	BDOS	;
	STA	RESULT	;
	POP	H
	POP	D
	POP	B
	RET
;
;	DELETE A FILE
;
DELETE:		; 
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,13H
	CALL	BDOS	;
	POP	H
	POP	D
	POP	B
	RET
;
;	GET INPUT FROM CONSOLE
;
CONIN:		; 
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,1
	CALL	BDOS	;
	POP	H
	POP	D
	POP	B
	RET
;
;	CONVERT A BYTE IN (A) TO TWO PRINTED CHARACTERS
;
HEXASC:		; 
	CPI	0AH
	JC	HEXA2	;
	ADI	'7'	;
	CALL	TYPE	;
	RET
HEXA2:		; 
	ADI	'0'	;
	CALL	TYPE	;
	RET
HEXCON:		; 
	PUSH	PSW
	RAR
	RAR
	RAR
	RAR
	ANI	0FH
	CALL	HEXASC	;
	POP	PSW
	ANI	0FH
	CALL	HEXASC	;
	RET
;
;	NEWLINE
;
CRLF:		; 
	MVI	A,CR
	CALL	TYPE	;
	MVI	A,LF
	CALL	TYPE	;
	RET
;
;	PRINT A SPACE
;
SPACE:		; 
	MVI	A,' '	;
	CALL	TYPE	;
	RET
;
;	MAIN WORK LOOP
;
;	THIS ROUTINE FINDS THE POSITION OF THE FILE
;	INFORMATION IN THE DIRECTORY DMA, PRINTS THE
;	DATA IF IT IS A CURRENT FILE, AND PROMPTS THE
;	OPERATOR FOR INSTRUCTIONS IF THE FILENAME HAS
;	ILLEGAL (NON-ASCII) DATA IN IT.
;
WORKLOOP:		; 
	LDA	RESULT	;RESULT HOLDS POSITION OF-
	MOV	B,A	; -THE DIRECTORY ENTRY IN THE DIR. DMA
	ANI	3
	RAL
	RAL
	RAL
	RAL
	RAL
	ANI	0E0H
	MOV	E,A
	MVI	D,0
	LXI	H,TBUFF	;
	DAD	D	;HL NOW POINTS AT THE FILE INFO
	MOV	A,M
	CPI	0E5H	;KILLED FILE?
	RZ		;YES
	MOV	A,M
	STA	ENTBYT	;
	PUSH	H
	PUSH	H
	MVI	B,8
	INX	H
WORK02:	MOV	A,M	;PRINT FILE NAME
	CALL	ILLCHK	;
	CALL	TYPE	;
	DCR	B
	INX	H
	JNZ	WORK02	;
	MVI	B,3
	MVI	A,'.'
	CALL	TYPE	;PRINT NEXT THREE CHARACTERS AS ASCII
WORK03:	MOV	A,M
	CALL	ILLCHK	;
	CALL	TYPE	;
	DCR	B
	INX	H
	JNZ	WORK03	;
	CALL	TYPE
	CALL	SPACE
	MVI	B,3
	POP	H	;NOW DISPLAY ATTRIBUTES
	LXI	D,9
	DAD	D
WORK03A:CALL	SPACE
	MOV	A,M
	RLC		;TEST $SYS AND $R/O, AND RESERVED
	MVI	A,'1'
	JC	WORK03B
	MVI	A,'0'
WORK03B:CALL	TYPE
	CALL	SPACE
	DCR	B
	INX	H
	JNZ	WORK03A
	MVI	B,20
WORK04:	MOV	A,B
	ANI	3
	CZ	SPACE	;
	MOV	A,M
	CALL	HEXCON	;
	INX	H
	DCR	B
	JNZ	WORK04	;
	CALL	CRLF	;
	POP	H
	LDA	ENTBYT	;
	ORA	A
	RZ
	PUSH	H
	LXI	H,DELMSG	;
WORK06:		; 
	MOV	A,M
	ORA	A
	JZ	WORK08	;
	CALL	TYPE	;
	INX	H
	JMP	WORK06	;
DELMSG:		; 
	DB	'Delete this file ? ',0
WORK08:		; 
	CALL	CONIN	;
	POP	H
	ANI	5FH
	CPI	'Y'	;
	PUSH	PSW
	CALL	CRLF	;KEEP IT NEAT
	POP	PSW
	RNZ
	XCHG
	LHLD	DELPTR	;
	MVI	B,10H
WORK10:		; 
	LDAX	D
	MOV	M,A
	INX	H
	INX	D
	DCR	B
	JNZ	WORK10	;
	SHLD	DELPTR	;
	RET
;
;	CHECK FOR NONASCII CHARACTER  <20H  OR  >60H
;
ILLCHK:	PUSH	PSW
	ANI	07FH	;MASK FOR PROPRIETARY", "$SYS", "$R/W"
	CPI	' '	;
	JC	ILLEGL	;
	CPI	61H
	JNC	ILLEGL	;
	POP	PSW
	RET
ILLEGL:	POP	PSW
	PUSH	PSW
	MVI	A,0FFH
	STA	ENTBYT	;
	POP	PSW
	RET
;
;
;
MSG:	DB	'Filename.Typ R/OSysRes exs1s2rc'
	DB	' <--------------Group-------------->'
	DB	CR,LF
	DB	'==============================='
	DB	'===================================='
	DB	CR,LF,'$'
;
;
;
; ERROR MESSAGES
;
ERROR1:	LXI	D,ERMSG1;SAY NO GO, AND BAIL OUT
	CALL	PRINT
	JMP	QUIT

;
ERMSG1:	DB	CR,LF,'Disk select should be " N:"$'

;
ERROR2:	LXI	D,ERMSG2;SAY NO GO, AND BAIL OUT
	CALL	PRINT
	JMP	QUIT

ERMSG2:	DB	CR,LF,'Bad delimeter, should be ":"$'

;
ERROR3:	LXI	D,ERMSG3;SAY NO GO, AND BAIL OUT
	CALL	PRINT
	JMP	QUIT

ERMSG3:	DB	CR,LF,'No drive specified$'

;
ERROR4:	LXI	D,ERMSG4;SAY NO GO, AND BAIL OUT
	CALL	PRINT
	JMP	QUIT

ERMSG4:	DB	CR,LF,'Only drives A to D allowed$'

;

;	PROGRAM BEGINS HERE
;
BEGIN:
;
; CHECK FOR DRIVE SPECIFICATION
;
	LDA	TBUFF	;GET LENGTH OF COMMAND PARAMETERS
	CPI	2	; IF <2, NO PARAMETERS
	JC	MAIN01	; MUST BE PRESENT LOGGED-IN DRIVE
	JZ	ERROR1	;EXACTLY 2, IS ERROR
	LHLD	TBUFF+2	;AT LEAST 3 THEN...
	MOV	A,H	;NEXT CHARACTER SHOULD BE ":"
	CPI	':'
	JNZ	ERROR2	;ONLY ALLOW DRIVE SET
	MOV	A,L	;NEXT CHARACTER SHOULD BE DRIVE
	CPI	'A'	;AT A MINIMUM, "A"
	JC	ERROR3
	CPI	'E'	;AT A MAXIMUM "D"
	JNC	ERROR4
	ANI	7	;STRIP BITS, FOR 0 TO 3
	DCR	A	;BACK OFF FOR 0 TO 3
	MOV	E,A	;MAKE DISK NUMBER
	MVI	D,0
	MVI	C,14	;BDOS SELECT DISK FUNCTION
	CALL	BDOS

MAIN01:	LXI	D,MSG
	CALL	PRINT
		; 
	LXI	H,DELFIL	;
	SHLD	DELPTR	;
	CALL	SEARCH	;
MAIN02:		; 
	LDA	RESULT	;
	CPI	0FFH
	JZ	MAIN04	;
	CALL	WORKLOOP	;
	CALL	NEXTFILE	;
	JMP	MAIN02	;
MAIN04:		; 
	LHLD	DELPTR	;
	LXI	D,DELFIL
	MOV	A,L
	CMP	E
	JNZ	MAIN06	;
	MOV	A,H
	CMP	D
	JZ	QUIT	;
MAIN06:		; 
	LXI	D,-10H
	DAD	D
	SHLD	DELPTR	;
	XCHG
	CALL	DELETE	;
	JMP	MAIN04	;
QUIT:		; 
	LHLD	OLDSTK	;
	SPHL
	RET		;
;
;	SOME STORAGE LOCATIONS
;
OLDSTK:	DS	2	;STORAGE FOR "OLD" STACK POINTER
	DS	32
NEWSTK	EQU	$	;STORAGE FOR "NEW" STACK
ENTBYT:	DS	1	;
DELPTR:	DS	16	;
DELFIL	EQU	$	;FILE OF DELETEABLE FILE BUILDS HERE
;
;
	END
