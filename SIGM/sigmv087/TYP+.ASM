;********************************************************
;*							*
;*	Disassembly of T.COM from CBBS disks		*
;*							*
;********************************************************
;
;	Originally written by
;	Ward Christensen
;	and supplied with the CBBS package
;
;	Disassembly
;	By Bill Bolton
;	   "Software Tools" RCPM
;	   SYSOP
;
;VERSION LIST - most recent version first
;
;11/Aug/82 Fixed Control S "pause" to release on any char
;	   following, including another Control S. Bill Bolton
;
;02/Aug/82 Entering TYPE *.* would eventually yield a list of
;	   all the files on the disk, including tagged and SYS
;	   files. File type testing was rearranged to prevent
;	   this and COM and OBJ messages were deleted. Fixed bug
;	   due to error in disassembly concerning buffer size.
;	   Changed console input check to direct console I/O
;	   (BDOS 6) and added CP/M version trap. Added messages
;	   explaning how to look at some files that can't be 
;	   "type"d. Bill Bolton
;
;15/Jul/82 Diassembled and file type testing routines from
;	   MLIST50 merged in. Bill Bolton
;
;
BDOS	EQU	00005H		;CP/M BDOS entry point
FCB	EQU	0005CH		;CP/M file control block
SECTOR	EQU	80H		;Length of a CP/M sector
BUF$SIZE EQU	30H		;Size of buffer in pages
;
CNTRLC	EQU	3
TAB	EQU	9
ALF	EQU	0AH
ACR	EQU	0DH
CNTRLS	EQU	13H
CNTRLX	EQU	18H
CNTRLZ	EQU	1AH
;
CONOUT	EQU	2
DIRECT	EQU	6
STRING	EQU	9
VERSION EQU	12
OPEN	EQU	15
SEARCH$1ST EQU	17
SEARCH$NXT EQU	18
READ	EQU	20
SET$DMA	EQU	26
;
	ORG	100H
;
START:
	CALL	BEGIN
;
	DB	'TYPE Ver 5.3 - Multiple file lister',ACR,ALF,'$'
;
BEGIN:
	POP	D
	LXI	H,0
	DAD	SP
	SHLD	OLD$STACK	;Save entry stack
	LXI	SP,STACK$TOP	;Set up local stack
	MVI	C,STRING
	CALL	BDOS
	MVI	C,VERSION
	CALL	BDOS
	CPI	20H
	JNC	VERSION$OK
	CALL	PRN$EXIT
;
	DB	'Sorry, you need CP/M Version 2.0 or later to run TYP'
	DB	ACR,ALF,ACR,ALF,'$'
;	
VERSION$OK:
	LDA	FCB+1
	CPI	' '		;File name specified?
	JNZ	HEADER		;Yes
	CALL	PRN$EXIT	;No, show usage
;
	DB	'TYPE command usage:',ACR,ALF,ACR,ALF
	DB	'	TYPE name',ACR,ALF
	DB	'	TYPE name nn',ACR,ALF
	DB	'	TYPE name #',ACR,ALF
	DB	'	TYPE name label',ACR,ALF,ACR,ALF
	DB	'Where:',ACR,ALF,ACR,ALF
	DB	'	name	Any file name.  * and ? allowed',ACR,ALF
	DB	'	nn	A starting line # (1 = first)',ACR,ALF
	DB	'	#	Means to count # of lines',ACR,ALF
	DB	'	label	Skip to label before printing',ACR,ALF
	DB	'		Must match exactly and completely',ACR,ALF
	DB	'		To match leading chars, end the string with *:'
	DB	ACR,ALF
	DB	'			TYPE b:foo.asm tr*',ACR,ALF,'$'
;
HEADER:
	CALL	PRN$MSG
;
	DB	ACR,ALF
	DB	'CTL-S pauses, CTL-X skips to next file, CTL-C aborts'
	DB	ACR,ALF,ACR,ALF,0
;
	LDA	FCB+17
	CPI	' '	;More command line?
	JZ	NEXT	;No
	CPI	'0'	;Yes,line number?
	JC	A02AE	;No
	CPI	':'
	JC	A02BD	;Yes
A02AE:
	LXI	H,FCB+17	;Point to secondary FCB
	LXI	D,D0707		;Internal buffer
	LXI	B,11		;Length to move
	CALL	MOVER		;Do it
	JMP	NEXT
;
A02BD:
	LXI	D,FCB+17
	LXI	H,0
A02C3:
	LDAX	D
	INX	D
	CPI	' '
	JZ	A0302
	CPI	'0'
	JC	A02E5
	CPI	':'
	JNC	A02E5
	SUI	'0'
	MOV	B,H
	MOV	C,L
	DAD	H
	DAD	H
	DAD	B
	DAD	H
	ADD	L
	MOV	L,A
	JNC	A02C3
	INR	H
	JMP	A02C3
;
A02E5:
	CALL	PRN$EXIT
;
	DB	'++INVALID STARTING LINE #$'
;
A0302:
	MOV	A,H
	ORA	L
	JZ	A0308
	DCX	H
A0308:
	SHLD	D0705
NEXT:
	LXI	SP,STACK$TOP	;Reset stack
	CALL	A062D
	JC	EXIT
	CALL	A031C
;
	DB	'     '
;
A031C:
	POP	H
	LXI	B,5		;Length to move
	LXI	D,T043D
	CALL	MOVER
	CALL	A032F
;
	DB	'      '
;
A032F:
	POP	H
	LXI	B,6		;Length to move
	LXI	D,T044B
	CALL	MOVER
	LXI	H,0
	SHLD	D0700
	MVI	C,OPEN		;Open file
	LXI	D,FCB
	CALL	BDOS
	INR	A		;Good open?
	JZ	EXIT		;No
;
;Check for file protected by CP/M 2.x f2' attribute
;
CKFIL:	LDA	FCB+10		;POINT TO SYS FILE ATTR
	ANI	80H		;IS IT SYS?
	JNZ	NEXT		;SYS file, can't print it
;
;Check for .COM file, which can't be printed
;
	LDA	FCB+11
	CPI	'M'		;WAS LAST CHAR AN 'M'?
	JNZ	OBJCHK		;IF NOT, CHK FOR '.OBJ' TYPE
	LDA	FCB+10
	ANI	7FH		;STRIP CP/M 2.x ATTR
	CPI	'O'		;AN 'O'?
	JNZ	OBJCHK		;IF NOT IT'S OK TO PRINT
	LDA	FCB+9
	ANI	7FH		;STRIP CP/M 2.x ATTR
	CPI	'C'		;'C' AS IN '.COM'?
	JNZ	OBJCHK		;IF NOT, IT'S OK TO PRINT
	JMP	NEXT		;MORE TO PRINT?
;
;Check for .OBJ file, which can't be printed
;
OBJCHK:
	CPI	'J'		;WAS LAST CHAR AN 'J' ?
	JNZ	SHOW$NAME	;IF NOT, OK TO LIST
	LDA	FCB+10		;MIGHT BE '.OBJ', CHK NEXT CHR
	ANI	7FH		;STRIP CP/M 2.x ATTR
	CPI	'B'		;IS IT A 'B'?
	JNZ	SHOW$NAME	;IF NOT, LIST
	LDA	FCB+9		;WAS, CHK FIRST CHAR
	ANI	7FH		;STRIP CP/M 2.x ATTR
	CPI	'O'		;'O' AS IN '.OBJ'?
	JNZ	SHOW$NAME	;IF NOT, PRINT THE FILE, IF SO
	JMP	NEXT		;MORE TO PRINT?
;
SHOW$NAME:
	LXI	H,FCB+1		;Point to primary file name
	LXI	D,PRIMARY
	LXI	B,8		;Length
	CALL	MOVER
	LXI	H,FCB+9		;Point to secondary file name
	LXI	D,SECNDRY
	LXI	B,3		;Length
	CALL	MOVER
	CALL	PRN$MSG
;
	DB	ACR,ALF,ACR,ALF
	DB	'===> LISTING FILE: '
PRIMARY:
	DB	'XXXXXXXX.'
SECNDRY:
	DB	'XXX',ACR,ALF,ACR,ALF
	DB	0
;
	LDA	FCB+2		;POINT TO TAG FILE ATTR
	ANI	80H		;IS IT TAGGED?
	JZ	SQCHK		;NO, CHECK IF SQUEEZED
	CALL	PRN$MSG		;PRINT:
;
	DB	'++FILE NOT FOR DISTRIBUTION, SORRY++',ACR,ALF,0
;
	LDA	FCB+11
	CPI	'L'		;WAS LAST CHAR AN 'L' ?
	JNZ	HLPCHK		;IF NOT, OK TO LIST
	LDA	FCB+10		;MIGHT BE '.ALL', CHK NEXT CHR
	ANI	7FH		;STRIP CP/M 2.x ATTR
	CPI	'L'		;IS IT A 'L'?
	JNZ	HLPCHK		;IF NOT, LIST
	LDA	FCB+9		;WAS, CHK FIRST CHAR
	ANI	7FH		;STRIP CP/M 2.x ATTR
	CPI	'A'		;'A' AS IN '.ALL'?
	JNZ	HLPCHK		;NO, NEXT CHECK
	CALL	PRN$MSG
;
	DB	ACR,ALF
	DB	'++Use DISPLAY to look at this Catalogue++'
	DB	ACR,ALF,0
	JMP	NEXT		;MORE TO PRINT?
;
HLPCHK:
	LDA	FCB+11		;POINT TO LAST CHAR OF FTYPE
	CPI	'P'
	JNZ	NXTCHK		;IF NOT, OK TO LIST
	LDA	FCB+10		;MIGHT BE '.HLP', CHK NEXT CHR
	ANI	7FH		;STRIP CP/M 2.x ATTR
	CPI	'L'		;IS IT A 'L'?
	JNZ	NXTCHK		;IF NOT, LIST
	LDA	FCB+9		;WAS, CHK FIRST CHAR
	ANI	7FH		;STRIP CP/M 2.x ATTR
	CPI	'H'		;'H' AS IN '.HLP'?
	JNZ	NXTCHK		;NO, NEXT CHECK
	CALL	PRN$MSG
;
	DB	ACR,ALF
	DB	'++Use HELP to look this "HLP" file++'
	DB	ACR,ALF,0
	JMP	NEXT		;MORE TO PRINT?
;
NXTCHK:
	JMP	NEXT
;
;Check for possible 'squeezed' file, which will not print
;
SQCHK:
	LDA	FCB+10		;GET SECOND CHAR OF FILETYPE
	ANI	7FH		;STRIP ATTRIBUTE
	CPI	'Q'		;THIS MAY BE SQUEEZED FILE
	JNZ	A038A		;NOT SQUEEZED
	CALL	PRN$MSG		;PRINT:
;
	DB	'NOTE: If this file doesn''t '
	DB	'print correctly, try TYPE in XYAM.',ACR,ALF
	DB	'Most files with "Q" as 2nd char. '
	DB	'of filetype are squeezed.',ACR,ALF,ACR,ALF,0
;
A038A:
	LXI	H,BUF$END
	MVI	B,1
A038F:
	PUSH	B
	PUSH	D
	PUSH	H
	LXI	H,T06FE
	CALL	A057C
	POP	H
	POP	D
	POP	B
	CPI	CNTRLZ		;End of file?
	JZ	A03ED
	ANI	07FH		;Strip of MSB (WordStar?)
	CPI	ACR
	JZ	A03C0
	CPI	TAB
	JNZ	A03BA
TABER:
	MVI	M,' '
	INX	H
	INR	B
	MOV	A,B
	DCR	A
	ANI	007H		;Reached next TAB stop?
	JNZ	TABER		;No
	JMP	A038F		;Yes
;
A03BA:
	MOV	M,A
	INX	H
	INR	B
	JMP	A038F
;
A03C0:
	MVI	M,' '
	INX	H
	MOV	M,A
	PUSH	B
	PUSH	D
	PUSH	H
	LXI	H,T06FE
	CALL	A057C
	POP	H
	POP	D
	POP	B
	CALL	CONSOLE$CHK
	JC	NEXT
	LDA	D0707
	CPI	'#'
	JZ	A038A
	LHLD	D0705
	MOV	A,H
	ORA	L
	JZ	A045E
	DCX	H
	SHLD	D0705
	JMP	A038A
;
A03ED:
	LHLD	D0705
	MOV	A,H
	ORA	L
	JZ	A0415
	CALL	PRN$EXIT
;
	DB	'++STARTING LINE # TOO HIGH++$'
;
A0415:
	LDA	D0707
	CPI	' '
	JZ	NEXT
	CPI	'#'
	JZ	A043A
	CALL	PRN$EXIT
;
	DB	'++STRING NOT FOUND++$'
;
A043A:
	CALL	PRN$MSG
;
T043D:
	DB	'     '
T0442:
	DB	'  LINES, '
T044B:
	DB	'      '
T0451:
	DB	'  BYTES',ACR,ALF,0
;
	JMP	NEXT
;
A045E:
	LDA	D0707
	CPI	' '
	JZ	A048F
	LXI	H,D0707
	LXI	D,BUF$END
A046C:
	LDAX	D
	CPI	' '
	JZ	A0489
	CPI	':'
	JZ	A0489
	CMP	M
	JNZ	A0480
	INX	D
	INX	H
	JMP	A046C
;
A0480:
	MOV	A,M
	CPI	'?'
	JZ	A048F
	JMP	A038A
;
A0489:
	MOV	A,M
	CPI	' '
	JNZ	A038A
A048F:
	MVI	A,' '
	STA	D0707
	MVI	C,0
	LXI	H,BUF$END
A0499:
	MOV	A,M
	CPI	' '
	JNZ	A04A9
	CPI	ACR
	JZ	A04A9
	INX	H
	INR	C
	JMP	A0499
;
A04A9:
	LXI	H,BUF$END
	MVI	B,1
A04AE:
	PUSH	B
	PUSH	H
A04B0:
	MOV	A,M
	INX	H
	INR	B
	CPI	ACR
	JZ	A04E6
	CPI	' '
	JNZ	A04B0
	MOV	A,B
	POP	H
	POP	B
	CPI	'P'
	JC	A04EA
	JZ	A04EA
	CALL	PRN$MSG
	DCR	C
	LDAX	B
	NOP
	PUSH	B
A04CF:
	XRA	A
	ORA	C
	JZ	A04E7
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,DIRECT	;Console out
	LXI	D,' '
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	DCR	C
	JMP	A04CF
;
A04E6:
	POP	H
A04E7:
	POP	B
	MVI	B,1
A04EA:
	MOV	E,M
	INR	B
	MOV	A,M
	CPI	' '
	JNZ	A04F8
	MOV	A,B
	CPI	'P'
	JZ	A0503
A04F8:
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,DIRECT	;Console out
	CALL	BDOS
	POP	H
	POP	D
	POP	B
A0503:
	CALL	CONSOLE$CHK
	JC	NEXT
	MOV	A,M
	INX	H
	CPI	ACR
	JZ	SEND$LF
	CPI	' '
	JNZ	A04EA
	JMP	A04AE
;
DIR$CON:
	PUSH	B
	PUSH	D
	PUSH	H
	LXI	D,0FFH
	MVI	C,DIRECT	;Direct Console input
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	ORA	A
	RET
;
CONSOLE$CHK:
	CALL	DIR$CON
	RZ
CONTROL$CHK:
	CPI	CNTRLC		;Abort ?
	JZ	ABORT		;Yes
	CPI	CNTRLX		;Skip to next file?
	JZ	SKIP		;Yes
	CPI	CNTRLS		;Pause for a while?
	JNZ	NO$ACTION	;No
PAUSE$LOOP:
	CALL	DIR$CON		;Another key pressed
	JZ	PAUSE$LOOP	;No
	CPI	CNTRLS		;Yes, go again?
	JZ	NO$ACTION	;Yes
	JMP	CONTROL$CHK	;No, check it
;
NO$ACTION:
	ORA	A		;Reset flags
	RET
;
SKIP:
	CALL	PRN$MSG
;
	DB	ACR,ALF,ACR,ALF,'++SKIPPING TO NEXT FILE++',0
;
	STC
	RET
;
SEND$LF:
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,DIRECT	;Console out
	LXI	D,ALF
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	JMP	A038A
;
PRN$MSG:
	XTHL
MSG$LOOP:
	MOV	E,M
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,DIRECT		;Console out
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	INX	H
	MOV	A,M
	ORA	A
	JNZ	MSG$LOOP
	XTHL
	RET
;
MOVER:
	MOV	A,M		;Get a byte from source
	STAX	D		;Put into destination
	INX	H		;Adjust pointers
	INX	D
	DCX	B		;Adjust counter
	MOV	A,B
	ORA	C		;Done?
	JNZ	MOVER		;No
	RET
;
A057C:
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	MOV	C,M
	INX	H
	MOV	B,M
	MOV	A,B
	ORA	C
	JNZ	A05D1
	INX	H
	MOV	A,M
	ADD	A
	MOV	B,A
	INX	H
	PUSH	H
	MOV	A,M
	INX	H
	MOV	H,M
	MOV	L,A
A0592:
	CALL	CONSOLE$CHK
	JC	NEXT
	MVI	A,CNTRLZ
	STAX	D
	PUSH	D
	PUSH	H
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,SET$DMA	;Set DMA address
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	POP	D
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,READ		;Read sequential
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	ORA	A
	POP	H
	JNZ	A05C6
	MOV	A,L
	ADI	080H
	MOV	L,A
	MOV	A,H
	ACI	0
	MOV	H,A
	XCHG
	DCR	B
	JNZ	A0592
A05C6:
	POP	H
	DCX	H
	MOV	A,M
	DCX	H
	MOV	M,A
	DCX	H
	DCX	H
	DCX	H
	JMP	A057C
;
A05D1:
	INX	H
	MOV	A,M
	XCHG
	ADD	H
	MOV	H,A
	MOV	A,L
	SUB	C
	MOV	L,A
	MOV	A,H
	SBB	B
	MOV	H,A
	MOV	A,M
	XCHG
	CALL	A05EF
	CPI	ALF
	CZ	A05FA
	CPI	CNTRLZ
	RZ
	DCX	B
	DCX	H
	MOV	M,B
	DCX	H
	MOV	M,C
	RET
;
A05EF:
	PUSH	H
	LXI	H,T0451
A05F3:
	PUSH	PSW
	CALL	A0601
	POP	PSW
	POP	H
	RET
;
A05FA:
	PUSH	H
	LXI	H,T0442
	JMP	A05F3
;
A0601:
	MOV	A,M
	ORI	'0'
	INR	A
	MOV	M,A
	CPI	':'
	RNZ
	MVI	M,'0'
	DCX	H
	JMP	A0601
;
; >> NO EXECUTION PATH TO HERE <<
	PUSH	PSW
	RAR
	RAR
	RAR
	RAR
	CALL	A0618
	POP	PSW
A0618:
	ANI	00FH
	ADI	090H
	DAA
	ACI	040H
	DAA
	MOV	E,A
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,DIRECT
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	RET
;
A062D:
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,SET$DMA		;Set DMA address
	LXI	D,00080H
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	XRA	A
	STA	FCB+12
	STA	FCB+32
	LDA	D06DA
	ORA	A
	JNZ	A067D
	MVI	A,1
	STA	D06DA
	LXI	H,FCB
	LXI	D,T06DB
	LXI	B,12
	CALL	MOVER
	LDA	FCB
	STA	CDISK
	LXI	H,T06DB
	LXI	D,FCB
	LXI	B,12
	CALL	MOVER
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,SEARCH$1st	;Search for first
	LXI	D,FCB
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	JMP	A06B1
;
A067D:
	LXI	H,CDISK
	LXI	D,FCB
	LXI	B,12
	CALL	MOVER
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,SEARCH$1st		;Search for first
	LXI	D,FCB
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	LXI	H,T06DB
	LXI	D,FCB
	LXI	B,12
	CALL	MOVER
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,SEARCH$NXT	;Search for next
	LXI	D,FCB
	CALL	BDOS
	POP	H
	POP	D
	POP	B
A06B1:
	INR	A
	STC
	RZ
	DCR	A
	ANI	3
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADI	081H
	MOV	L,A
	MVI	H,0
	PUSH	H
	LXI	D,T06E8
	LXI	B,11
	CALL	MOVER
	POP	H
	LXI	D,FCB+1
	LXI	B,11
	CALL	MOVER
	XRA	A
	STA	FCB+12
	RET
;
D06DA:
	DB	0
T06DB:
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0
CDISK:
	DB	0
T06E8:
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0
;
ABORT:
	CALL	PRN$EXIT
;
	DB	ACR,ALF,ACR,ALF,'++ABORTED++',ACR,ALF,'$'
;
PRN$EXIT:
	POP	D
	MVI	C,STRING	;Print string
	CALL	BDOS
EXIT:
	LHLD	OLD$STACK
	SPHL
	RET
;
T06FE:
	DW	BUFFER
D0700:
	DB	0,0
	DB	BUF$SIZE
	DW	FCB
D0705:
	DW	0
D0707:
	DB	020H
;
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0
STACK$TOP:
;
OLD$STACK:
	DW	0
;
BUFFER	EQU	$
BUF$END	EQU	$ + ((2 * BUF$SIZE) * SECTOR) ;Length of buffer
;
	END

