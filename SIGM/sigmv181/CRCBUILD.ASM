;
;		CRCBUILD.ASM	version 1.0
;        by John L. Raff WB2MDG/KAPP8107
;	     (built 830408FR)
;
;---> NOTE: MUST BE ASSEMBLED BY MAC <----
;
;CRCBUILD is a program to build a CP/M file in SIG/M 
;-CATALOG format and print
;a CYCLIC-REDUNDANCY-CHECK number based on the
;CCITT standard polynominal:
;   X^16 + X^15 + X^13 + X^7 + X^4 + X^2 + X + 1
;  
;Define true and false
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
;
;Conditional assembly switches
;
STDCPM	EQU	TRUE	;TRUE IS STANDARD CP/M
ALTCPM	EQU	FALSE	;TRUE IS H8 OR TRS-80
NOSYS	EQU	FALSE	;TRUE IF SYS FILES NOT WANTED
;
;System equates
;
BASE	SET	0
	IF	ALTCPM
BASE	SET	4200H
	ENDIF		;ALTCPM
;
;Define write buffer size (presently set for 8k)
;
BSIZE	EQU	8*1024	;DISK WRITE BUFFER SIZE
;
;BDOS equates
;
RDCON	EQU	1
WRCON	EQU	2
PRINT	EQU	9
READCONSOLE	EQU	10	;Read console buffer
CSTAT	EQU	11
OPEN	EQU	15
SRCHF	EQU	17
SRCHN	EQU	18
READ	EQU	20
STDMA	EQU	26
BDOS	EQU	BASE+5
FCB	EQU	BASE+5CH 
FCBEXT	EQU	FCB+12
FCBRNO	EQU	FCB+32
FCB2	EQU	BASE+6CH
STRLMT	EQU	80	;STRING LENGTH LIMIT
;
;Program starts here
;
	ORG	BASE+100H
;
	MACLIB	SEQIO	;DEFINE MACRO LIBRARY USED
 
CRCBUILD:
	JMP	BEGIN	;Jump around identification & alternate file name
	DB	'CRCBUILD.COM 1.0 830408fr',0
;
BEGIN:
	XRA	A
	STA	NAMQUAN	;Zero the quantity of files read
	LXI	H,0	;GET STACK...
	DAD	SP	;POINTER SO WE CAN..
	SHLD	STACK	;SAVE IT
	LXI	SP,STACK ;INITIALIZE LOCAL STACK
BGN2:
	CALL	CRLF	;TURN UP A NEW LINE
	CALL	ILPRT	;Print the heading
	DB	'CRCBUILD Ver 1.0 830224TH',CR,LF
	DB	'CTL-S pauses, CTL-C aborts',CR,LF,0
	LDA	FCB+1
	CPI	' '	;SEE IF NAME THERE
	JNZ	BEGIN2	;YES, CONTINUE
	LXI	D,FCB+2	;Put total directory pattern
	LXI	H,FCB+1	;in FCB
	MVI	M,'?'	;All "?"
	LXI	B,10	;4 characters
	CALL	MOVER	;MOVE IT
	JMP	BEGIN2	;Go get um
;
THRNUM?:	;Check for three ascii numbers
	CALL	TWONUM?
	RNZ		;Return if not numbers
	CALL	NUM?
	RZ		;Return if a number
	CPI	'.'	;Check for a period
	RNZ		;Return if not a period
	DCX	H	;Otherwise back up one character
	DCR	B	;And one count
	CMP	A	;Set zero flag
	RET
;
TWONUM?:
	CALL	NUM?
	RNZ
NUM?:
	MOV	A,M	;Get the character
	INX	H	;For next character
	INR	B	;Increment for next count
	CPI	'0'	;Is it less than 0
	JC	NUMNOT	;Branch if it is
	CPI	'9'+1	;Is it greater than 9?
	JNC	NUMNOT
	CMP	A	;Set zero flag
	RET
NUMNOT:
	CPI	'0'	;Should not be equal, reset zero flag
	RET
;
BEG2NG:
	CALL	ILPRT
	DB	CR,LF,'Incorrect characters',CR,LF,0
;
BEGIN2:
	CALL	ILPRT
	DB	'Enter -CATALOG.xxx number (three digits) -',0
	LXI	D,STR4	;Point to string 4
	MVI	A,5	;Indicate size of buffer 
	STAX	D
	MVI	C,READCONSOLE	;Read console buffer
	CALL	BDOS	;Go get the string
	LXI	H,STR4+1	;Point to quantity characters entered
	MOV	C,M	;Get the count
	MVI	A,3	;Check for three characters
	CMP	C	;In buffer
	JNZ	BEG2NG	;Branch if not 3 characters
	MVI	B,0	;Zero counter
	INX	H	;Point to first character
BEG2A:
	CALL	NUM?	;Is it a decimal number?
	JNZ	BEG2NG	;Branch if not a decimal number
	MOV	A,B	;Check quantity of characters
	CPI	3
	JNZ	BEG2A	;Branch if not end of characters yet
	MVI	M,0	;Ensure termination of string
	LXI	H,STR4+2	;Copy number into file string
	LXI	D,FNAME1
	LXI	B,3		;Count
	CALL	MOVER
	MVI	A,'F'	;Indicate write file open
	STA	FFLAG
;
;'Declare' FCB for output file
;(temporarily named -CATALOG.$$$)
;
	FILE	OUTFILE,CATALOG,,-CATALOG,$$$,BSIZE
;
AGAIN:	LXI	SP,STACK ;RE-INIT STACK POINTER
	MVI	A,0	;Indicate in building phase
	STA	WHICH	;Save flag
	CALL	MFNAME	;SEARCH FOR NAMES
	JNC	NAMTST	;ANOTHER FOUND, PRINT NAME
AGN2:	
	LDA	MFFLG2	;NOTHING FOUND, CHECK...
	ORA	A	;... NAME FOUND FLAG
	JZ	DONE	;AT LEAST ONE WAS FOUND
	CALL	ABEXIT	;PRINT MSG, THEN EXIT
	DB	'++FILE NOT FOUND++$'
;
DONE:			;Close -CATALOG.$$$
	LXI	H,FNAME1
	LXI	D,DONEX
	LXI	B,3
	CALL	MOVER
	CALL	ILPRT
	DB	CR,LF,'SIG-M Library -CATALOG Volume Number-'
DONEX:
	DB	'NNN, ',0
DONEY:
	LDA	NAMQUAN
	CALL	SHWDC
	CALL	ILPRT
	DB	' Files cataloged.',CR,LF,0
;
	FINIS	CATALOG
;
	LXI	H,STR4+2	;Point to beginning of string
	LXI	D,FCBFINAL+9	;Location of Name TYPE
	LXI	B,3	;Quantity to move
	CALL	MOVER
;
;Build FCB for final name of -CATALOG.nnn
;
	FILE	SETFILE, FINAL,,-CATALOG,NNN
;
;	Erase any existing old file
;
	ERASE FINAL
;
;	Rename -CATALOG.$$$ to -CATALOG.NNN
	RENAME	FINAL,CATALOG
;
;Now exit to CP/M
DONE2:	
	CALL	MSGEXIT	;PRINT DONE, THEN EXIT
	DB	CR,LF,'DONE$'
;
;Test for names to ignore
;
NAMTST:	IF	NOSYS
	LDA	FCB+10	;GET SYS ATTRIBUTE
	ANI	80H	;IS IT SYS?
	JNZ	AGAIN	;YES, IGNORE THIS FILE
	ENDIF		;NOSYS
;
;Ignore files with .$$$ filetype (they are usually
;zero-length and clutter up our display.  We also
;want to ignore our own CRCKLIST.$$$ temporary file).
;
	LXI	H,FCB+9	;POINT TO FILETYPE IN FCB
	PUSH	H	;May need pointer for BAD check
	CALL	TSTBAD	;CHECK FOR .$$$ FILES
	JZ	AGAIN	;IF ZERO FLAG, IGNORE THEM
	POP	H	;Restore pointer
	CALL	BADTYP	;Check for .BAD files
	JZ	AGAIN	;Branch if it is
;
NAMTS2:
	CALL	ILPRT	;PRINT:
	DB	CR,LF
FNAME1:
	DB	'NNN.',0
;
	LDA	NAMQUAN	;Get quantity of name
	INR	A	;Increment count
	STA	NAMQUAN
	CALL	SHWDC	;Show the count
;
;Move 8 characters from FCB+1 to FNAME
;
	LXI	H,FCB+1
	LXI	D,FNAME
	LXI	B,8
	CALL	MOVER
;Move 3 characters from FCB+9 to FNAME+9
	LXI	H,FCB+9
	LXI	D,FNAME+9
	LXI	B,3
	CALL	MOVER
;Now print filename.type
	CALL	ILPRT
	DB	'	'
FNAME:
	DB	'XXXXXXXX.XXX  ',0
FNAME2:
	CALL	OPN	;Open file and build CRC
	JZ	AGAIN	;Branch if bad open or read
	JMP	ABEXT2	;Otherwise get out
;
;Open the file
;
OPN:
	LXI	D,FCB
	MVI	C,OPEN
	CALL	BDOS
	INR	A
	JNZ	RDINIT
	CALL	ILPRT
	DB	'++Open Failed++',0
	JMP	BADRET	;Indicate Bad open
;
;Initialize CRC to zero and set Bufad to cause initial read
;
RDINIT:
	LXI	H,0
	SHLD	REM	;Init remainder to zero
	SHLD	QUANEK	;Quantity of eighth k
	LXI	H,BASE+100H
	SHLD	BUFAD	;Init buffer address
;
;This is the read loop
;
READIT:
	LHLD	BUFAD
	MOV	A,H	;Time to read?
	CPI	BASE SHR 8	;End of buffer?
	JZ	NORD
	MVI	C,CSTAT
	CALL	BDOS	;Chck for operator abort
	ORA	A
	JZ	READ2	;Branch if nothing from operator
	MVI	C,RDCON
	CALL	BDOS	;Get character from operator
	CPI	'C'-40h	;Control C?
	JZ	ABEXT2	;Branch if yes, exit
;
READ2:
	LXI	D,FCB
	MVI	C,READ	;Read another sector of file
	CALL	BDOS
	ORA	A	;Check return code
	JNZ	FINISH	;Error or EOF
	LHLD	QUANEK	;Get quantity of eighth K
	INX	H	;Add 1
	SHLD	QUANEK	;Put back
	LXI	H,BASE+80H	;Bufer location
;
NORD:
	MOV	A,M	;Get file character
	STA	MESS	;Save for DIVP
	INX	H
	SHLD	BUFAD	;Update buffer address
	CALL	DIVP	;Calculate new CRC
	JMP	READIT	;GO READ MORE CHARACTERS
;
FINISH:	CPI	1	;NORMAL END-OF-FILE?
	JNZ	FILERR	;NO, IT WAS A READ ERROR
	LHLD	QUANEK	;Get quantity of eighth K
	LXI	B,7
	DAD	B	;Round up to next K
	DAD	H	;Turn into full K
	DAD	H	;In "H" register
	DAD	H
	DAD	H
	DAD	H
	MOV	A,H
	CALL	SHWDEC	;Show Number of K
	CALL	ILPRT
	DB	'K   ',0 
	LDA	REM+1	;GET MSP OF CRC
	CALL	HEXO	;PRINT IT
	MVI	A,' '
	CALL	TYPE	;TYPE A SPACE
	LDA	REM	;GET LSP OF CRC
	CALL	HEXO	;PRINT IT
GOODRET:
	XRA	A
	RET		;Return to caller with zero flag set
;
FILERR:
	CALL	ILPRT	;Print the message and return
	DB	TAB,TAB,'++FILE READ ERROR++',CR,LF,0
BADRET:			;General bad return location
	XRA	A	;Set zero flag
	INR	A	;reset zero flag
	RET		;Return to caller
;
;---------------------------------------------
;An 8080 routine for generating a CYCLIC-
;REDUNDANCY-CHECK.  Character leaves that
;character in location REM.  By Fred Gutman.
;From 'EDN' magazine, June 5, 1979 issue, page 84.
;
DIVP:
	LHLD	REM	;GET REMAINDER
	MOV	A,H
	ANI	128	;Q-BIT MASK
	PUSH	PSW	;SAVE STATUS
	DAD	H	;2 X R(X)
	LDA	MESS	;MESSAGE BIT IN LSB
	ADD	L
	MOV	L,A
	POP	PSW
	JZ	QB2	;IF Q-BIT IS ZERO
;
QB:
	MOV	A,H
	XRI	0A0H	;MS HALF OF GEN. POLY
	MOV	H,A
	MOV	A,L
	XRI	97H	;LS HALF OF GEN. POLY
	MOV	L,A
;
QB2:
	SHLD	REM
	RET
;--------------------------------------------
;
;Hex output
;
HEXO:
	PUSH	PSW	;SAVE FOR RIGHT DIGIT
	RAR		;RIGHT..
	RAR		;..JUSTIFY..
	RAR		;..LEFT..
	RAR		;..DIGIT..
	CALL	NIBBL	;PRINT LEFT DIGIT
	POP	PSW	;RESTORE RIGHT
;
NIBBL:	ANI	0FH	;ISOLATE DIGIT
	CPI	10	;IS IS <10?
	JC	ISNUM	;YES, NOT ALPHA
	ADI	7	;ADD ALPHA BIAS
;
ISNUM:	ADI	'0'	;MAKE PRINTABLE
	JMP	TYPE	;PRINT IT, THEN RETURN
;
;Inline print routine
;
ILPRT:	XTHL		;SAVE HL, GET MSG
;
ILPLP:	MOV	A,M	;GET CHAR
	CALL	TYPE	;OUTPUT IT
	INX	H	;POINT TO NEXT
	MOV	A,M	;TEST
	ORA	A	;..FOR END
	JNZ	ILPLP
	XTHL		;RESTORE HL, RET ADDR
	RET		;RET PAST MSG
;
;Send carriage return, line feed to output
;
CRLF:	MVI	A,CR	;CARRIAGE RETURN
	CALL	TYPE
	MVI	A,LF	;LINE FEED, FALL INTO 'TYPE'
;
;Send character in A register to output
;
TYPE:	PUSH	B
	PUSH	D
	PUSH	H
	ANI	7FH	;STRIP PARITY BIT
	MOV	E,A
	PUSH	D
	CALL	WRFILE	;WRITE TO FILE IF REQUESTED
	POP	d
	mvi	c,WRCON	;send chracter to console
	call	bdos
	pop	h
	pop	d
	pop	b
	ret
;
;	Write character in E register to output file
;
WRFILE:
	LDA	FFLAG	;Get file trigger
	CPI	'F'	;Is it set?
	RNZ		;No?, return
	MOV	A,E	;Get character back
	PUT	CATALOG	;Send it to the file
	RET		;to caller
;
;Multi-file access subroutine. Allows processing
;of multiple files <i.e. *.ASM> from disk.  This
;routine builds the proper name in the FCB each
;time it is called.  carry is set if no more names
;can be found.  The routine is commented in pseudo
;code, each pseudo code statement is in <<...>>
;
MFNAME:
	MVI	C,STDMA
	LXI	D,BASE+80H
	CALL	BDOS
	XRA	A
	STA	FCBEXT
	STA	FCBRNO
;<<if first time>>
	LDA	MFFLG1
	ORA	A
	JZ	MFN01
;<<save the requested name>>
;save orig request
	LXI	H,FCB
	LXI	D,MFREQ
	LXI	B,12
	CALL	MOVER
	LDA	FCB
	STA	MFCUR	;Save disk in curr FCB
;<<srchf requested namd>>
	LXI	H,MFREQ
	LXI	D,FCB
	LXI	B,12
	CALL	MOVER
	MVI	C,SRCHF
	LXI	D,FCB
	CALL	BDOS
;<<else>>
	JMP	MFN02
;
MFN01:	;<<srchf current name>>
	LXI	H,MFCUR
	LXI	D,FCB
	LXI	B,12
	CALL	MOVER
	MVI	C,SRCHF
	LXI	D,FCB
	CALL	BDOS
;<<SRCHN requested name>>
	LXI	H,MFREQ
	LXI	D,FCB
	LXI	B,12
	CALL	MOVER
	MVI	C,SRCHN
	LXI	D,FCB
	CALL	BDOS
;<<endif>>
MFN02:	;<<return carry if not found>>
	INR	A
	STC
	RZ
;<<move name found to current name>>
	DCR	A
	ANI	3
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADI	81H
	MOV	L,A
	MVI	H,BASE SHR 8
	PUSH	H	;SAVE NAME POINTER
	LXI	D,MFCUR+1
	LXI	B,11
	CALL	MOVER
;<<move name found to FCB>>
	POP	H
	LXI	D,FCB+1
	LXI	B,11
	CALL	MOVER
;<<setup FCB>>
	XRA	A
	STA	FCBEXT
	STA	FCBRNO
	STA	MFFLG1	;TURN OFF 1ST TIME SW
	STA	MFFLG2	;FLAG INDICATING FOUND AT LEAST ONE
;<<return>>
	RET
;------------------------------------------------
;
;Check for .$$$ files
;
TSTBAD:	CALL	TESTIT	;CHECK FIRST ONE FOR '$'
	RNZ		;NO, RETURN
	CALL	TESTIT	;CHECK SECOND ONE
	RNZ		;NO, RETURN
			;FALL INTO TESTIT TO CHECK THIRD
;
TESTIT:	MOV	A,M
	ANI	7FH	;STRIP ATTRIBUTE
	CPI	'$'	;CHECK FOR $ FILETYPE
	INX	H
	RET
BADTYP:			;Check for BAD file type
	MOV	A,M
	ANI	7FH
	CPI	'B'
	RNZ
	INX	H
	MOV	A,M
	ANI	7FH
	CPI	'A'
	RNZ
	INX	H
	MOV	A,M
	ANI	7FH
	CPI	'D'
	RET		;Return with zero flag set or not
;
;Move (BC) bytes from (HL) to (DE)
;
MOVER:	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	MOVER
	RET
;
;Aborted - print reason.  If making output file,
;close the incomplete file to update CP/M's bit map,
;then erase it.
;
ABEXIT:	POP	D	;GET MSG ADRS
	MVI	C,PRINT
	CALL	BDOS	;PRINT MSG
;
ABEXT2:	LDA	FFLAG	;SEE IF WE ARE MAKING FILE
	CPI	'F'
	JNZ	ABEXT3	;NO FILE, SKIP FILE STUFF
	FINIS	CATALOG	;CLOSE INCOMPLETE FILE
	ERASE	CATALOG	;ERASE INCOMPLETE FILE
;
ABEXT3:	CALL	ERXIT	;PRINT MSG, EXIT
	DB	CR,LF,CR,LF,'++ABORTED++$'
;
;Exit with message
;
MSGEXIT:EQU	$	;EXIT W/"INFORMATIONAL" MSG
ERXIT:	POP	D	;GET MSG
	MVI	C,PRINT
	CALL	BDOS
;
;Exit, restoring stack and return to CCP
;
EXIT:	LHLD	STACK
	SPHL
	RET		;TO CCP
;
SHWDEC:			;3 Digits, up to 255, with leading 0 suppress
	MVI	B,' '	;Set for space
	MVI	C,0
SHWDE:
	CPI	100	;Check if greater than 100
	JC	NOHUNS
	INR	C
	SUI	100
	JMP	SHWDE
NOHUNS:
	PUSH	PSW
	MOV	A,C
	ORA	A
	JZ	NOHN
	MVI	B,'0'	;Set "0" for next 0
NOHN:
	ADD	B	;Add space or "0"
	CALL	TYPE
	POP	PSW
	MVI	C,0
CKTENS:
	CPI	10
	JC	NO10S
	INR	C
	SUI	10
	JMP	CKTENS
NO10S:
	PUSH	PSW
	MOV	A,C
	ORA	A	;Check if any 10s
	JZ	NO10X
	MVI	B,'0'
NO10X:
	ADD	B	;Add space or "0"
	CALL	TYPE
	POP	PSW
	ADI	'0'
	JMP	TYPE		
;
SHWDC:			;2 DIGITS ONLY, 99 only, No 0 supress
	MVI	C,'0'	;Set up for '0' digit
SHWDC1:
	CPI	10	;Check if greater than 10
	JC	NOTENS	;Branch if no tens digits
	INR	C	;Increment tens digit counter
	SUI	10	;Subtract 10 from number
	JMP	SHWDC1	;Branch back to test again
NOTENS:
	PUSH	PSW	;Save the units digit quantity
	MOV	A,C	;Get the tens digit quantity
	CALL	TYPE
	POP	PSW	;Restore the units digit quantity
	ADI	'0'	;Add ascii digits numeral offset
	JMP	TYPE	;Display units and return to caller
;
;Program storage area
;
NAMPTR:	DS	2	;Storage for name start in catalog search
MTCH	DB	0	;CRC Match counter
NOMTCH	DB	0	;CRC Don't match counter
BADPAR	DB	0	;Bad parse counter
MISFIL	DB	0	;Missing files counter
FFLAG:	DB	0	;FILE WRITE REQUEST FLAG
FLAGAX:	DB	0	;All user check flag
REM:	DW	0	;CRC REMAINDER STORAGE
QUANEK:	DW	0	;Quantity of eighth K
MSPREM	DS	1	;Storage for CRC MSP from file
LSPREM	DS	1	;LSP from file
MESS:	DB	0	;CRC MESSAGE CHAR GOES HERE
MFFLG1:	DB	1	;1ST TIME SWITCH
MFFLG2:	DB	1	;FLAG INDICATING ONE NAME FOUND OR NOT
XFRST:	DB	1	;1st time check in read
RDCK:	DB	0	;Open file CRCKLIST or -CATALOG
VERNUM:	DB	0	;VERSION NUMBER OF CP/M IN USE
ENTUSR:	DB	0	;ENTRY USER NUMBER
NOWUSR:	DB	0	;PRESENT USER'S NUMBER
NAMQUAN:	DB	0	;Quantity of files read	
FRSNAM:	DB	1	;FIRST NAME IN USER FLAG
MFREQ:	DS	12	;REQUESTED NAME
MFCUR:	DS	12	;CURRENT NAME
WHICH	DS	1	;Flag storage for phase
BUFAD:	DS	2	;READ BUFFER ADDRESS
STRCNT	DS	2	;STRING COUNT STORAGE
STRING	DS	11	;STRING STORAGE
STR1:	DS	12	;Name storage
STR2:	DS	8	;Characters after name
STR3:	DS	5	;Ascii CRC characters
STR4:	DS	80	;Buffer
	DS	60	;STACK AREA
STACK:	EQU	$
OLDSTK:	DS	2	;OLD STACK POINTER SAVED HERE
;
;Define location of file write buffer
BUFFERS:EQU	$
;
	END	CRCK
