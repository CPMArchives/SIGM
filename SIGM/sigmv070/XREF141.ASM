	TITLE	'XREF.ASM  Ver 1.41	03/15/82'
	PAGE	0

;********************************************************
;							*
; This program generates a cross reference list for all	*
; Symbols in a CPM assembler program.  Its input is	*
; either an assembler source file (FN.ASM) or an assem-	*
; bler listing file (FN.PRN).  It will number the lines	*
; and generate a cross reference listing at the end of	*
; the program.  The output defaults to the CPM list	*
; device, but it can be directed to the console or to a *
; disk file instead.  If the output is directed to a	*
; disk file, that file will be named FN.XRF.  The	*
; filename will be the filename of the input file.	*
; It is invoked by entering:				*
;		XREF FN.ASM	(OUTPUT TO LIST DEVICE)	*
;		XREF FN.PRN CON	(OUTPUT TO CONSOLE)	*
;		XREF FN.ASM D	(OUTPUT TO DISK-DEFAULT	*
;						DRIVE)	*
;		XREF FN.PRN B:D	(OUTPUT TO DISK-DRIVE	*
;				NUMBER SPECIFIED)	*
;							*
; To invoke help function enter:			*
;		XREF ?					*
;							*
;********************************************************

;03/15/82 This program would lock up if there was a
;comment line that started with an asterisk('*') instead
;of a semicolon.  The program then processed the whole
;line as a valid line of assemble code.  This usually
;resulted in the cross reference program locking up if
;there were a lot lines that started with an asterisk.
;The program now treats an asterisk the same as a
;semicolon.  This was done by changing the table CTAB1
;so that the program branches to LSEMI when it finds an
;asterisk. Also fixed bug that occurred when the last
;record of a file was completely filled with data and
;thus had no control Z's(EOF characters) in it.  This
;was done by always placing two control Z's after the
;last record was read.  Finally fixed a bug that showed
;up only when a program had no symbols or labels in it.
;Added a check for an empty symbol table before attempting
;to print the symbol table.  (JRM)

;03/06/82 Changed the code so that the size of output
;disk buffer can be specified at assembly time.  The
;size is set by OUTSECT which equals the number of disk
;sectors to be written when the buffer is full.
;Implemented the same feature for disk input.  INSECT sets
;the number of disk records to be read into the input
;buffer.  On file type PRN the was a bug.  Whenever the
;first symbol on a line was preceded by a character, the
;line was not listed in the cross reference listing.  This
;was caused by skipping over the first 16 characters in the
;line on a CR(carriage return) instead of on a LF(line feed).
;This bug has been fixed.  Added help function.  This is
;invoked by entering  XFER ?.  (JRM)


;03/03/82 Added a 2k buffer for disk output writes.  This
;was done to speed up the execution of program when disk
;output was specified.  Fixed bug when page size was
;specified.  CPM assembler was not doing the conditional
;IF assembly correctly.  Changed the code to test if page
;size is in effect by testing LPAGE to see if it is zero.
;Changed test to question to erase existing disk cross
;reference file to handle lower case as well as upper
;case.  (JRM)

;02/20/82 Changed code so that the size of the symbol
;that is referenced in the cross reference listing can
;be set at assembly time.  The original program only
;allowed for 5 char per symbol.  This did not allow for
;separate unique symbols where the uniqueness occurred
;after the first 5 characters.  I tested this function
;for a length of 5, 8, and 10 characters labels.  It
; should work for any length of symbol.  I also
;allowed the '$' character to be a valid character in a
;symbol.  The equ SYMSIZ was added and all other values
;and variables that are dependent on the size of the
;symbol are expressed using SYMSIZ.
;		Example: SSIZ EQU SYMSIZ+3
;Added a disk file output option.  The output disk file
;will the filename of the input file and always a file
;type of 'XRF'.  This option is enabled by specifying
;a 'D' as the second parameter when executing the program.
;The user can optionally specify a different drive than
;the default drive for the cross reference disk output.
;		Example: XREF FN.ASM D
;			 XREF FN.PRN B:D
;						(JRM)

;11/01/81 Changed the code so that the hex addresses and
;the hex translation of the instructions are not included
;in the cross reference listing for PRN files from CPM
;assembler.  The listing can now be directed at execution
;time to the console or the list (LST:) device.  If the
;listing is to be displayed on the console enter
;	XREF FN.FT C
;If the listing is to go to the list device enter
;	XREF FN.FT
;In other words, the output goes to the list device by
;default. (JRM)

;Modifications 4/5/79, 4/26/79, 5/3/79, 8/28/79 by SAN:
;Suppress initial page eject, add page eject at completion
;Automatically convert lower case in source file to UPPER
;Abort execution if ^C typed, but ignore other typed chars
;Add ELSE, PAGE to reserved word table

;********************************************************

;Number of lines per output page set by LPAGE EQUate

;Number of symbol refs per table entry set by NREFS EQUate
;	This value should be set to the average number of
;	references that a symbol will have in program.  It
;	is used to build the symbol reference table entries.
;	Each entry will be equal to (NREFS * 2)+2.  If it is
;	made unnecessarily large, then the symbol reference
;	table will be very large with a lot of unused slots.
;	Example: a program with 300 symbols will require a
;	reference table that is at least 12600 bytes if
;	NREFS=20, whereas the same program will require a
;	reference table that is at least 3600 bytes if
;	NREFS=5.  Each symbol that exceeds NREFS references
;	will require ((Total references/NREFS)rounded up)
;	reference table entries.  Recommended values: 3-5.

;Number of symbol references to be printed per output line
;	This is set by LREFS EQUate.  It should be a multiple
;	of NREFS.  If it is not, then the first number that is
;	less than LREFS and is a multiple of NREFS will be
;	printed on the line.  Example: if NREFS is 5 and
;	LREFS is 13, then only 10 entries will be printed per
;	line.  The total number of references that will fit on
;	one line without overflow is equal to the size of the
;	line minus (SYMSIZ+2) divided by 5.  Example: if the
;	line size is 132 characters and SYMSIZ equals 8,
;	then Total num of ref/line can be INT((132-(8+2))/5)
;	or INT(122/5) or 20.

;Symbol size is set by SYMSIZ.  This is the symbol size that the
;	program will use in the cross reference listing.  It
;	should be large enough to make each symbol unique in
;	cross reference listing.  If a symbol is larger than the
;	value for SYMSIZ, then the symbol will be truncated in the
;	output(eg: LARGE$SYMBOL would be LARGE$SYM if SYMSIZ was
;	set to 9.  Recommended value is 8.

;OUTSECT sets the number of disk records that will be written to
;	disk when the output disk buffer is full.  This value is
;	used by the program to calculate the size of the output
;	disk buffer.  Output buffer size = OUTSECT * 128.
;	Recommended value is from 8 to 32.  16 works well.

;INSECT is the number of disk records that will be read when the
;	disk input buffer is empty.  It is used to calculate the
;	size of the input buffer.  Input buffer size = INSECT * 128.
;	Recommend value is from 8 to 32.  16 works well.

;NOTE:	If OUTSECT and INSECT are made too large, there will not be
;	be enough memory left to build the cross reference table
;	for a large program.  Largest tested values so far(3/6/82)
;	is 64 for OUTSECT and 64 for INSECT on a 64K system.  The
;	file successfully cross referenced was MODEM74.PRN. (JRM)

;Graceful exit after error message if file not found

LPAGE	EQU	00		;NUM LINES PER PAGE IF PEJECT IS TRUE
NREFS	EQU	03		;NUMBER OF REFERENCES PER REF TBL ENTRY
LREFS	EQU	21		;REFERENCES PER OUTPUT LINE
SYMSIZ	EQU	08		;NUMBER OF SYMBOL CHAR
OUTSECT	EQU	32		;NUMBER OF DISK SECTORS WRITTEN FROM BUFFER
INSECT	EQU	32		;NUMBER OF DISK SECTORS READ INTO BUFFER

;********************************;
;
;	   INTEL ASSEMBLER
;	CROSS REFERENCE PROGRAM  
;
;	    VERSION 1.41
;
;	   JEFF KRAVITZ 
;
;	MODIFIED BY JOHN MAHR
;
;********************************;

;********************************;
;
;          MAIN LOOP
;
;********************************;
	ORG	100H		;ORIGIN ADDRESS
XREF:	LXI	SP,STACK	;SET STACK POINTER
	CALL	SETUP		;INITIALIZE
MAIN:	CALL	GETBT		;GET A BYTE FROM SOURCE FILE
	CALL	SAVBT		;SAVE BYTE IN PRINT BUFFER
MAIN2:	CALL	CKNUM		;TEST FOR NUMERIC
	JNC	LNUM		;YES, FOUND A NUMBER, PROCESS
	CALL	CKALP		;TEST FOR ALPHABETIC
	JNC	LALPH		;YES, PROCESS
	LXI	H,CTAB1		;POINT TO CHARACTER TABLE
	CALL	LOOK		;LOOK UP CHAR IN CHAR TABLE
	JC	LIGN		;NOT FOUND, IGNORE
	PCHL			;EXECUTE ROUTINE

;*******************************************************
;
;		DONE
;
;      FINAL SYMBOL TABLE PRINT
;
; DONE gets control when a control Z(1AH) is found
; in the input data stream.  This routine:
;
;	1. issues a page eject
;	2. prints the cross reference table
;	3. issues a page eject
;	4. if disk output, writes out the remaining
;		sectors in the disk output buffer and
;		then closes the disk output file.
;	5. close the disk input file.
;	6. displays end of program message.
;
;*******************************************************

DONE:	CALL	EJECT		;ISSUE PAGE EJECT
	LHLD	SYMBT		;GET SYMBOL TABLE BOTTOM
	MVI	A,0FFH		;check to see if there were...
	CMP	M		;...any symbols in the program
	JZ	DLP4		;no, don't print symbol table
	SHLD	SYM		;SET SYMBOL POINTER
	LHLD	SYMTP		;GET SYMBOL TABLE TOP
	MVI	M,0FFH		;END OFF SYMBOL TABLE
DLP1:	LHLD	SYM		;GET SYMBOL TABLE POINTER
	CALL	PSYM		;PRINT SYMBOL
	LHLD	SYM
	LXI	D,SYMSIZ+1	;OFFSET TO REF LINK
	DAD	D
	MOV	E,M
	INX	H
	MOV	D,M		;GET REF BLOCK ADDR
	XCHG			;INTO HL
	SHLD	REF
	CALL	PREFS		;PRINT REFERENCES
	LHLD	SYM		;GET SYMBOL TABLE POINTER
	LXI	D,SSIZ		;SIZE OF SYM TABLE ENTRY
	DAD	D
	SHLD	SYM
	MOV	A,M		;GET BYTE
	CPI	0FFH		;END OF TABLE?
	JNZ	DLP1		;LOOP

DLP2:	CALL	EJECT		;PAGE EJECT
	LDA	DISKOUT		;GET DISK OUTPUT SWITCH
	ORA	A		;DISK OUTPUT BEING USED?
	JZ	DLP3		;NO, ISSUE END MSG & RETURN TO CPM
	LXI	H,DISKBUF	;GET OUTPUT DISK BUFFER
	LXI	D,OFCB		;AND OUT FCB
	CALL	DCLOSE		;AND CLOSE OUTPUT DISK FILE

DLP3:	LXI	D,TFCB		;CLOSE THE...
	MVI	C,CLOSE		;...INPUT...
	CALL	CPM		;...FILE.
	LXI	D,DONEMSG	;TELL OPERATOR...
	MVI	C,PSTRING	;...THAT PGM IS...
	CALL	CPM		;...DONE
	JMP	BOOT		;AND RETURN TO CP/M

DLP4:	LXI	H,NOSYMS	;get no symbol message
	MVI	B,28		;NUMBER OF CHAR IN MSG
DLP5:	MOV	E,M		;print the...
	CALL	PBYT		;...message
	INX	H
	DCR	B
	JNZ	DLP5
	JMP	DLP2		;go close files



;********************************;
;
;     SYMBOL PRINT ROUTINE
;
;********************************;
PSYM:	MVI	B,SYMSIZ	;SYMBOL SIZE
PSYM2:	MOV	E,M		;GET BYTE
	CALL	PBYT		;PRINT BYTE
	INX	H
	DCR	B
	JNZ	PSYM2
	MVI	E,' '
	CALL	PBYT		;PRINT 2 SPACES
	CALL	PBYT
	RET

;********************************;
;
;     REFERENCE PRINT ROUTINE
;
;********************************;
PREFS:	MVI	A,LREFS/NREFS	;NUMBER OF BLOCKS TO PRINT ON ONE LINE
	STA	NLINS		;TO NLINS
PREF0:	LHLD	REF		;GET REF BLOCK ADDR
	INX	H
	INX	H		;BUMP TO FIRST REF NUMBER
	SHLD	TEMP		;SAVE REF NUM ADDR
	MVI	A,(REFSZ-2)/2	;NUMBER OF REF SLOTS
	STA	SYMCT		;SAVE IN SYMCT
PREF:	LHLD	TEMP		;GET REF SLOT ADDR
	MOV	E,M
	INX	H
	MOV	D,M		;GET REF
	LXI	H,0000		;ZERO?
	CALL	CPHL
	JZ	CRLF		;YES, DONE
	XCHG			;GET NUM IN HL
	CALL	DECOT		;CONVERT
	LXI	H,DEC		;POINT TO DEC STRING
	MVI	M,' '		;BLANK LEADING ZERO
	MVI	B,5		;NUMBER OF DIGITS + 1 IN REF NUM
PREF2:	MOV	E,M
	CALL	PBYT		;PRINT BYTE
	INX	H
	DCR	B
	JNZ	PREF2		;PRINT REFERENCE NUMBER
	LHLD	TEMP		;GET REF SLOT ADDR
	INX	H
	INX	H		;BUMP TO NEXT SLOT
	SHLD	TEMP
	LDA	SYMCT		;GET COUNT
	DCR	A		;DECREMENT
	STA	SYMCT
	JNZ	PREF
	LHLD	REF		;GET REF BLOCK ADDRESS
	MOV	E,M
	INX	H
	MOV	D,M		;GET LINK TO NEXT BLOCK
	LXI	H,0000
	CALL	CPHL		;ANY MORE BLOCKS?
	JZ	CRLF		;NO, EXIT
	XCHG			;YES, SET NEXT BLOCK POINTER IN REF
	SHLD	REF
	LDA	NLINS
	DCR	A		;DECREMENT LINES COUNT
	STA	NLINS
	JNZ	PREF0		;AND PRINT MORE ON SAME LINE
	CALL	CRLF		;PRINT CR,LF
	MVI	B,SYMSIZ+2	;INDENT CONTINUATION LINE...
PREF3:	MVI	E,' '		;...WITH SPACES
	CALL	PBYT		;PRINT SPACES
	DCR	B
	JNZ	PREF3		;PRINT 6 SPACES
	JMP	PREFS

;********************************;
;
;   CHARACTER PARSING ROUTINES
;
;********************************;
LALPH:	LXI	H,SBUF		;POINT TO SYMBOL BUFFER
	MVI	C,SYMSIZ
	MVI	A,' '		;FILL SYMBOL...
LALX:	MOV	M,A		;...WITH...
	INX	H		;...BLANKS
	DCR	C
	JNZ	LALX		;CLEAR SYMBOL BUFFER
	LXI	H,SBUF
	SHLD	SYMPT
	MVI	A,00
	STA	SYMCT		;RESET SYMBOL POINTER+COUNT
	LDA	CHAR		;GET CHARACTER AGAIN
	CALL	GTSYM		;COLLECT IDENTIFIER
LALC:	CALL	GETBT		;GET A BYTE FROM SOURCE FILE
	CALL	SAVBT		;SAVE BYTE IN PRINT BUFFER
	CALL	CKNUM		;TEST FOR NUMBER
	JNC	LAL3		;YES, CONTINUE
	CALL	CKALP		;TEST FOR ALPHABETIC
	JNC	LAL3		;YES, CONTINUE
	CALL	CRES		;TEST FOR RESERVED WORD
	JC	LAL1		;NO, CONTINUE
LAL0:	LDA	CHAR		;GET CHARACTER THAT ENDED ID
	JMP	MAIN2		;CONTINUE SCAN
LAL1:	CALL	FIND		;SEE IF DEFINED
	JC	LAL2		;NO, CONTINUE
	CALL	ADDRF		;YES, ADD REFERENCE
	JMP	LAL0		;DONE
LAL2:	CALL	ENSYM		;ENTER SYMBOL DEFINITION
	CALL	ADDRF		;ADD REFERENCE
	JMP	LAL0		;CONTINUE
LAL3:	CALL	GTSYM		;COLLECT IDENTIFIER
	JMP	LALC		;CONTINUE

LNUM:	CALL	GETBT		;GET BYTE
	CALL	SAVBT		;SAVE BYTE IN PRINTER BUFFER
	CALL	CKNUM		;TEST FOR NUMERIC
	JNC	LNUM		;YES, CONTINUE
	CALL	CKALP		;TEST FOR ALPHABETIC
	JNC	LNUM		;YES, CONTINUE
	JMP	MAIN2		;CONTINUE WITH MAIN SCAN

LQUOT:	CALL	GETBT		;GET A BYTE
	CALL	SAVBT		;SAVE BYTE IN PRINTER BUFFER
	CPI	''''		;SEE IF STRING QUOTE
	JNZ	LQUOT		;NO, KEEP LOOPING
	CALL	GETBT		;GET NEXT BYTE
	CALL	SAVBT		;SAVE BYTE
	CPI	''''		;TEST FOR DOUBLES
	JZ	LQUOT		;YES, START SCAN AGAIN
	JMP	MAIN2		;NO, CONTINUE IN MAIN SCAN

LSEMI:	CALL	GETBT		;GET A BYTE
	CALL	SAVBT		;SAVE BYTE
	CPI	0DH		;WAIT FOR CR
	JNZ	LSEMI		;CONTINUE
	JMP	MAIN2		;ENTER MAIN LOOP

LCR:	CALL	PLINE		;PRINT LINE
	LHLD	LCNT		;GET LINE NUMBER
	INX	H		;BUMP LINE NUMBER
	SHLD	LCNT		;STORE
	JMP	MAIN

LLF:	PUSH	PSW		;save char
	LDA	FTPRN		;is it file...
	ORA	A		;...type PRN?
	JZ	LLF2		;yes, skip 1rst 16 char
	POP	PSW		;restore char
	JMP	MAIN

LLF2:	POP	PSW		;RESTORE CHARACTER
	MVI	B,16		;# OF CHAR TO SKIP OVER

LLF3:	CALL	GETBT		;get next byte
	CALL	SAVBT		;put in print buf
	CPI	0DH		;carriage return?
	JZ	LCR		;yes, get next line
	DCR	B		;skipped all char?
	JNZ	LLF3		;no, continue skipping
	JMP	MAIN		;CONTINUE

LIGN:	JMP	MAIN		;RE-ENTER MAIN LOOP

LSPC	EQU	LIGN
LTAB	EQU	LIGN
LDOL	EQU	LIGN
LDEL	EQU	LIGN

;********************************;
;
;          SUBROUTINES
;
;********************************;

;******************************************************************
;
;		SETUP
;
;         INITIALIZATION
;
; 1. displays program logo and version
; 2. checks for input file type PRN.
;	-if file type PRN, sets PRN switch.
; 3. if oper specified FN.FT CON, then sets console
;	output switch on.  Goes to step 5.
; 4. else check for disk output option.
;	-if not disk output, default to printer output.
;		-go to step 5.
;	-else check to see if cross reference file exists.
;		-if it exists, ask operater if it is to
;		 be erased.
;			-if no erase, terminate program
;			-else erase cross reference file.
;	-then create new cross reference disk file.
;	-initialize output character pointer to disk buffer.
; 5. open input disk file.
; 6. initialize printer buffer, address pointers for symbol table
;    and reference table, set line counter to 1.
; 7. return to caller
;
;******************************************************************

SETUP:	LXI	D,LOGO		;get program logo msg
	MVI	C,PSTRING	;BDOS PRINT STRING
	CALL	CPM		;PRINT LOGO
	LDA	TFCB+1		;get first char of file name
	CPI	'?'		;help function?
	JNZ	SETUP1		;no, go check input file type
	LXI	D,HELP		;display help message
	JMP	FERR1

SETUP1:	LDA	TFCB+9		;get first char of file type
	CPI	'P'		;is it type PRN?
	JNZ	SETUP2		;no, don't set switch
	LDA	TFCB+10		;get 2nd char of file type
	CPI	'R'
	JNZ	SETUP2
	LDA	TFCB+11		;get 3rd char of file type
	CPI	'N'
	JNZ	SETUP2
	XRA	A
	STA	FTPRN		;turn on prn file type

SETUP2:	LDA	TFCB+17		;get 1rst char of 2nd fcb
	CPI	'C'		;output to console?
	JNZ	SETUP3		;no, don't turn on switch
	LDA	TFCB+18		;get 2nd char of 2nd fcb
	CPI	'O'		;output to console?
	JNZ	SETUP3		;no, don't turn on switch
	MVI	A,0FFH		;turn on...
	STA	CONSOLE		;...console output
	JMP	SETUP6		;go open input file
SETUP3:	LDA	TFCB+17		;get 1rst char of 2nd fcb
	CPI	'D'		;output to be written to disk?
	JNZ	SETUP6		;no, go open input file.
	STA	DISKOUT		;turn on disk output switch
	LDA	TFCB+16		;get output file drive number
	STA	OFCB		;move to output fcb
	LXI	D,TFCB		;point to fcb
	CALL	FOPEN		;open disk input file
	LXI	D,TFCB+1	;point to input file name
	MVI	B,8		;length of file name
	LXI	H,OFCB+1	;point to output fcb file name
	CALL	MOVE		;move input file name to output fcb
	LXI	D,OFCB		;does output file...
	MVI	C,OPEN		;...already...
	CALL	CPM		;...exist?
	CPI	0FFH		;open succeed?
	JZ	SETUP4		;no, file does not exist
	LXI	D,OFCB		;close...
	MVI	C,CLOSE		;...the open...
	CALL	CPM		;...file.
	LXI	D,MSG1		;ask operator...
	MVI	C,PSTRING	;...if old file...
	CALL	CPM		;...is to be...
	MVI	C,CONIN		;...deleted
	CALL	CPM
	ANI	05FH		;make upper case
	CPI	'Y'		;operator say yes?
	JNZ	BOOT		;no, terminate
	LXI	D,CONCRLF	;write carriage return...
	MVI	C,PSTRING	;...line feed to console
	CALL	CPM
	LXI	D,OFCB		;point to fcb to delete file
	MVI	C,DELETE	;delete the...
	CALL	CPM		;...file
	CPI	0FFH		;delete succeed?
	LXI	D,EMSG2		;get err msg in case of failure
	JZ	FERR1		;failure, print msg & quit

SETUP4:	LXI	D,OFCB		;point to output fcb
	MVI	C,MAKE		;create new...
	CALL	CPM		;...cross reference file.
	CPI	0FFH		;create succeed?
	LXI	D,EMSG3		;get err msg in case of failure
	JZ	FERR1		;create failed, print msg & quit
	LXI	H,DISKBUF	;get addr of disk buffer
	SHLD	DCHAR		;init disk char pointer

SETUP6:	LXI	D,TFCB		;POINT TO FCB
	CALL	FOPEN		;OPEN FCB
	LXI	H,PBUF
	SHLD	LPNT		;SET PRINT POINTER
	LXI	H,00001		;SET LINE COUNTER...
	SHLD	LCNT		;...TO ONE.
	LXI	H,SYMT		;GET ADDRESS OF SYMBOL TABLE
	SHLD	SYM
	SHLD	SYMBT
	SHLD	SYMTP		;SET SYMBOL TABLE POINTERS
	LHLD	MEMSZ		;GET AVAILABLE MEMORY ADDRESS
	DCX	H
	SHLD	REF
	SHLD	REFBT
	SHLD	REFTP		;SET REFERENCE TABLE POINTERS
	RET

;********************************;
;
;    CHECK FOR RESERVED WORD
;
;********************************;
CRES:	LXI	H,RTAB		;POINT TO RESERVED WORD TABLE
	SHLD	TEMP		;SAVE IN TEMP WORD
CRES1:	LHLD	TEMP		;GET TABLE POINTER
	LXI	D,SBUF		;POINT TO SYMBOL
	MVI	B,5		;SYMBOL SIZE
CRES2:	LDAX	D		;GET SYMBOL BYTE
	CMP	M		;COMPARE AGAINST TABLE ENTRY
	RC			;LESS, NOT IN TABLE
	JNZ	CRES3		;GREATER, GET NEXT TABLE ENTRY
	INX	D		;BUMP POINTERS
	INX	H
	DCR	B		;DECREMENT BYTE COUNT
	JNZ	CRES2		;KEEP TESTING
	JMP	CRES4		;FOUND
CRES3:	LHLD	TEMP		;GET TABLE POINTER
	LXI	D,RSIZ		;SIZE OF ENTRY
	DAD	D		;BUMP POINTER
	SHLD	TEMP		;STORE NEW POINTER
	MOV	A,M		;GET TABLE BYTE
	CPI	0FFH		;END OF TABLE?
	JNZ	CRES1		;NO, LOOP
	STC			;SET CARRY (NOT IN TABLE)
	RET
CRES4:	ORA	A		;RESET CARRY
	RET

;********************************;
;
;     FIND SYMBOL IN TABLE
;
;********************************;
FIND:	LHLD	SYMBT		;GET BEGIN OF SYM TABLE
	SHLD	SYM		;SET TEMP POINTER
FIND1:	LHLD	SYM		;GET TEMP POINTER
	LXI	D,SBUF		;POINT TO CURRENT SYMBOL
	MVI	B,SYMSIZ	;SYMBOL SIZE
FIND2:	LDAX	D		;GET BYTE FROM SBUF
	CMP	M		;COMPARE TO SYM TABLE BYTE
	RC			;GREATER, NOT IN TABLE
	JNZ	FIND3		;LESS, GET NEXT TABLE ENTRY
	INX	D		;BUMP POINTER
	INX	H		;BUMP POINTER
	DCR	B		;DECREMENT BYTE COUNT
	JNZ	FIND2		;LOOP
	RET			;TRUE ZERO, FOUND
FIND3:	LHLD	SYM		;GET CURRENT POINTER
	LXI	D,SSIZ		;SYMBOL TABLE ENTRY SIZE
	DAD	D		;BUMP POINTER
	XCHG			;INTO DE
	LHLD	SYMTP		;GET TOP OF SYMBOL TABLE
	CALL	CPHL		;TEST FOR END OF TABLE
	JZ	FIND4		;YES, DONE
	JC	FERR		;TABLE OVERFLOW, ERROR
	XCHG			;CURRENT POINTER INTO HL
	SHLD	SYM		;SET CURRENT POINTER
	JMP	FIND1		;LOOP
FIND4:	STC			;SET CARRY FOR NOT FOUND
	LHLD	SYMTP		;GET CURRENT TOP
	SHLD	SYM		;SET CURRENT POINTER
	RET

FERR:	LXI	D,EMSG1		;SYMBOL TABLE ERR MSG

FERR1:	MVI	C,PSTRING	;WRITE CONSOLE
	CALL	CPM		;ISSUE ERROR MESSAGE
	JMP	BOOT		;EXIT

FERR2:	LXI	D,EMSG6		;no room for symbol table
	JMP	FERR1

;********************************;
;
;   ADD REFERENCE TO REF TABLE
;
;********************************;
ADDRF:	LHLD	SYM		;GET SYMBOL POINTER
	LXI	D,SYMSIZ+1	;OFFSET PAST SYMBOL&FLAGS
	DAD	D
	MOV	E,M
	INX	H
	MOV	D,M		;GET REFERENCE POINTER
	LXI	H,0000
	CALL	CPHL		;TEST FOR ZERO REF PTR
	JZ	BLDRF		;YES, BUILD REFERENCE ENTRY
LINK1:	XCHG			;REF PTR IN HL
	MOV	E,M		;GET REF LINK
	INX	H
	MOV	D,M		;INTO DE
	DCX	H		;REPOSITION HL
	PUSH	H		;SAVE REF PTR
	LXI	H,0000
	CALL	CPHL		;IF LINK IS ZERO
	POP	H
	JNZ	LINK1		;NON ZERO, GET NEXT LINK
	SHLD	REF		;SAVE REF POINTER
	INX	H
	INX	H		;SKIP TO FIRST REF NUMBER
	MVI	B,(REFSZ-2)/2	;NUMBER OF REF NUMBERS/ENTRY
LINK3:	MOV	E,M		;GET REF NUMBER
	INX	H
	MOV	D,M
	DCX	H		;REPOSITION
	PUSH	H		;SAVE REF NUM ADDR
	LXI	H,0000
	CALL	CPHL		;SEE IF REF NUM IS ZERO
	POP	H
	JZ	ENREF		;YES, ENTER REFERENCE
	INX	H
	INX	H		;SKIP TO NEXT REF NUM
	DCR	B		;DECREMENT COUNT
	JNZ	LINK3		;TRY AGAIN AT NEXT SLOT
	CALL	ADBLK		;ADD NEW REF BLOCK
	LHLD	REF		;GET REF POINTER
	INX	H
	INX	H		;SKIP TO FIRST REF SLOT
ENREF:	PUSH	H		;SAVE REF SLOT ADDR
	LHLD	LCNT		;GET LINE NUMBER
	XCHG			;INTO DE
	POP	H		;GET REF SLOT ADDR
	MOV	M,E
	INX	H
	MOV	M,D		;STORE LINE REF
	RET			;DONE
;********************************;
;
;     BUILD REF TABLE BLOCK
;
;********************************;
BLDRF:	LHLD	SYM		;GET SYMBOL POINTER
	LXI	D,SYMSIZ+1	;OFFSET TO REF POINTER
	DAD	D
	SHLD	REF		;SET TEMP REF POINTER TO HERE
	CALL	ADBLK		;ADD BLOCK
	LHLD	REF		;GET REAL REF POINTER
	INX	H
	INX	H		;POSITION TO FIRST REF SLOT
	JMP	ENREF		;ADD REFERENCE
ADBLK:	LHLD	REFBT		;GET REF BOTTOM
	LXI	D,REFSZ		;SUBTRACT REF SIZE
	MOV	A,L
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A
	SHLD	TEMP		;SAVE NEW REF BOTTOM
	XCHG			;INTO DE ALSO
	LHLD	SYMTP		;GET SYMBOL TOP
	CALL	CPHL		;CHECK FOR BUMP
	JZ	FERR2		;YES, NO ROOM
	JNC	FERR2		;NO ROOM
	LHLD	TEMP		;GET REF BOTTOM
	XCHG			;INTO DE
	LHLD	REF		;GET REF POINTER
	MOV	M,E		;SET LINK
	INX	H
	MOV	M,D		;TO NEW REF BLOCK
	LHLD	TEMP		;GET NEW REF BLOCK ADDR
	SHLD	REF		;STORE IN REF
	MVI	B,REFSZ		;SIZE OF REF BLOCK
	MVI	A,00
ADB2:	MOV	M,A		;ZERO THE REF BLOCK
	INX	H
	DCR	B
	JNZ	ADB2
	LHLD	TEMP		;GET NEW REF BOTTOM
	SHLD	REFBT		;SET REFBT
	RET

;********************************;
;
;     ENTER SYMBOL IN SYM TABLE
;
;********************************;
ENSYM:	LHLD	SYM		;GET SYMBOL POINTER
	XCHG			;INTO DE
	LHLD	SYMTP		;GET SYMBOL TABLE TOP
	CALL	CPHL		;CHECK FOR END OF TABLE
	JZ	NWSYM		;YES, ADD SYMBOL AT END
	LXI	D,SSIZ		;SYMBOL TABLE ENTRY SIZE
	DAD	D		;CALCULATE NEW END OF TABLE
	XCHG			;INTO DE
	LHLD	REFBT		;REFERENCE TABLE BOTTOM
	CALL	CPHL		;TEST FOR TABLE OVERFLOW
	LXI	D,EMSG7		;ADDR OF ERR MSG IN OF OVERFLOW
	JZ	FERR1		;FULL, ERROR
	JC	FERR1		;YES, ERROR
	LHLD	SYMTP		;GET TABLE TOP
	LXI	D,SSIZ-1	;BUMP TO END OF ENTRY
	DAD	D
	SHLD	TO		;STORE IN TO ADDRESS
	LXI	D,SSIZ
	MOV	A,L
	SUB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A		;SUBTRACT SIZE OF ONE ENTRY
	SHLD	FROM		;STORE AS FROM ADDRESS
	LHLD	SYM		;GET CURRENT POINTER
	SHLD	LIMIT		;STORE AS LIMIT ADDRESS
	CALL	MVUP		;MOVE TABLE UP IN MEMORY
NWSYM:	LHLD	SYM		;GET CURRENT POINTER
	LXI	D,SBUF		;POINT TO SYMBOL
	MVI	B,SYMSIZ	;SIZE OF SYMBOL
	CALL	MOVE		;COPY SYMBOL TO TABLE
	MVI	A,0
	MOV	M,A
	INX	H
	MOV	M,A
	INX	H
	MOV	M,A		;SET POINTERS TO 0000
	LHLD	SYMTP		;GET SYMBOL TABLE TOP
	LXI	D,SSIZ		;GET SYMBOL ENTRY SIZE
	DAD	D		;BUMP
	SHLD	SYMTP		;STORE EW TOP
	RET

;********************************;
;
;    MOVE SYMBOL TABLE UP
;
;********************************;
MVUP:	LHLD	TO		;GET TO POINTER
	MOV	B,H
	MOV	C,L		;INTO BC
	LHLD	FROM		;GET FROM POINTER
	XCHG			;INTO DE
	LHLD	LIMIT		;GET LIMIT ADDRESS
MVUP2:	LDAX	D		;GET FROM BYTE
	STAX	B		;STORE AT TO ADDRESS
	CALL	CPHL		;COMPARE FROM TO LIMIT
	RZ			;EXIT IF DONE
	DCX	B		;DECREMENT TO
	DCX	D		;DECRMENT FROM
	JMP	MVUP2		;LOOP

;********************************;
;
;  GENERAL PURPOSE MOVE ROUTINE
;
;********************************;
MOVE:	LDAX	D		;GET BYTE
	MOV	M,A		;STORE BYTE
	INX	D
	INX	H		;BUMP POINTERS
	DCR	B		;DECREMENT COUNT
	JNZ	MOVE		;LOOP
	RET

;********************************;
;
;    BINARY TO DECIMAL CONVERSION
;
;********************************;
DECOT:	LXI	D,DEC
	XCHG
	LXI	B,10000
	CALL	DIG
	LXI	B,1000
	CALL	DIG
	LXI	B,100
	CALL	DIG
	LXI	B,10
	CALL	DIG
	LXI	B,1
	CALL	DIG
	RET

DIG:	MVI	M,'0'
DI0:	MOV	A,E
	SUB	C
	MOV	E,A
	MOV	A,D
	SBB	B
	MOV	D,A
	JM	DI2
	INR	M
	JMP	DI0
DI2:	MOV	A,E
	ADD	C
	MOV	E,A
	MOV	A,D
	ADC	B
	MOV	D,A
	INX	H
	RET

;********************************;
;
;    TEST FOR ALPHABETIC CHAR.
;
;********************************;
CKALP:	cpi	'$'		;treat '$' like a char
	rz

	CPI	'A'		;ASCII 'A'
	RC			;NO, EXIT
	CPI	'Z'+1
	CMC
	RET

;********************************;
;
;       TEST FOR NUMERIC CHAR
;
;********************************;
CKNUM:	CPI	'0'
	RC
	CPI	'9'+1
	CMC
	RET

;********************************;
;
;  LOOK UP CHAR IN PARSE TABLE
;
;********************************;
LOOK:	LXI	D,0003		;TABLE ENTRY SIZE
	MOV	B,A		;ARGUMENT BYTE IN B
LOOK2:	MOV	A,M		;GET TABLE BYTE
	CPI	0FFH		;END OF TABLE?
	JZ	LOOKN		;YES, NOT FOUND
	CMP	B		;COMPARE
	JZ	LOOKY		;FOUND
	DAD	D		;BUMP POINTER
	JMP	LOOK2		;LOOP
LOOKN:	STC			;CARRY = NOT FOUND
	RET

LOOKY:	INX	H		;SKIP TO TABLE BYTE
	MOV	E,M
	INX	H
	MOV	D,M		;TABLE ENTRY IN DE
	XCHG			;INTO HL
	RET

;********************************;
;
;    SAVE BYTE IN LINE BUFFER
;
;********************************;
SAVBT:	LHLD	LPNT		;GET LINE POINTER
	MOV	M,A		;SAVE BYTE
	INX	H		;BUMP POINTER
	SHLD	LPNT		;SAVE POINTER
	call	lwrupr		;convert lower to upper case
	sta	char		;save char in char
	RET

;********************************;
;
;  PRINT SOURCE LINE WITH NUMBER
;
;********************************;
PLINE:	LHLD	LCNT		;GET LINE NUMBER
	CALL	DECOT		;CONVERT TO DECIMAL
	LXI	H,DEC		;POINT TO DEC STRING
PL2:	MOV	E,M		;GET STRING BYTE
	MOV	A,E
	CPI	0DH		;DONE?
	JZ	PL3		;YES
	CALL	PBYT		;PRINT BYTE
	INX	H		;BUMP POINTER
	JMP	PL2
PL3:	MVI	E,':'
	CALL	PBYT		;PRINT ':'
	MVI	E,' '
	CALL	PBYT		;PRINT ' '
	CALL	PBYT		;PRINT SPACE
	LXI	H,PBUF		;POINT TO PRINT BUFFER
	MVI	A,00
	STA	COL		;SET COLUMN COUNT
PL41:	MOV	E,M		;GET BYTE
	MOV	A,E
	CPI	0DH		;DONE?
	JZ	PL5
	CPI	0AH		;LF?
	JZ	PL4A		;YES, IGNORE
	CPI	09H		;TAB?
	JNZ	PL42		;NO, CONTINUE
	PUSH	H		;SAVE HL
PL43:	MVI	E,' '
	CALL	PBYT		;PRINT SPACE
	LXI	H,COL
	INR	M
	MOV	A,M
	ANI	07H		;MODULO 8
	JNZ	PL43
	POP	H
	JMP	PL4A
PL42:	LDA	COL
	INR	A
	STA	COL
	CALL	PBYT		;PRINT BYTE
PL4A:	INX	H
	JMP	PL41
PL5:	CALL	CRLF		;PRINT CR,LF
	LXI	H,PBUF
	SHLD	LPNT		;RESET LINE POINTER
	RET

;********************************;
;
;      COLLECT SYMBOL IN SYM BUF
;
;********************************;
GTSYM:	MOV	B,A		;SAVE CHAR
	LDA	SYMCT		;GET SYMBOL COUNT
	CPI	SYMSIZ		;MAX?
	RNC			;YES, DONE 
	INR	A
	STA	SYMCT
	LHLD	SYMPT
	MOV	M,B
	INX	H		;BUMP SYMBOL POINTER
	SHLD	SYMPT
	RET

;********************************;
;
;       PRINTER INTERFACES
;
;********************************;

;********************************;
;
;       PRINT A SINGLE BYTE
;
;********************************;
PBYT:	PUSH	B
	PUSH	D
	PUSH	H
	PUSH	PSW
	LDA	DISKOUT		;disk output...
	ORA	A		;...in effect?
	JNZ	DBYT		;yes, go write to disk
	MVI	C,05
	LDA	CONSOLE		;get console out switch
	ORA	A		;console output?
	JZ	PBYT2		;no, print output
	MVI	C,2		;console output

PBYT2:	CALL	CPM

PBYT3:	MVI	C,11		;CHECK CONSOLE STATUS
	CALL	CPM
	ORA	A		;IF ZERO, OK
	JZ	PBYTX		;EXIT
	MVI	C,1
	CALL	CPM		;READ CONSOLE CHAR
	CPI	3
	JZ	BOOT		;ABORT IF ^C, OTHERWISE IGNORE
PBYTX:	POP	PSW
	POP	H
	POP	D
	POP	B
	RET

;**************************************;
;
;		DBYT
;
;	PUT OUTPUT CHARACTER
;	INTO DISK BUFFER.
;		INPUT=E(OUTPUT CHAR)
;
; 1. move character to buffer.
; 2. if at end of buffer, go
;	write out disk buffer.
; 3. else add 1 to disk buffer
;	pointer.
; 4. subtract 1 from number of
;	positions left in buffer.
; 5. go check if operator pressed
;	control C.
;
;***************************************;

DBYT:	MOV	A,E		;save char to be put in buffer
	LHLD	DSKCNT		;get num of char left in buf
	XCHG			;put num in D,E
	LHLD	DCHAR		;point to next char in buf
	MOV	M,A		;put char in disk buf
	DCR	E		;at end of buf?
	JNZ	DBYT1		;no, don't write buffer
	DCR	D		;at end of buf?
	JZ	PUTREC		;yes, go write buffer

DBYT1:	INX	H		;point to next char in buf
	SHLD	DCHAR		;save next pos
	XCHG			;put num of char left in H,L
	SHLD	DSKCNT		;save num of remaining char
	JMP	PBYT3		;go check console status

;****************************************************************
;		PUTREC
;	WRITE OUT DISK BUFFER TO DISK
;
;	1. initialize start of disk buffer address and number
;		of sectors to write out.
;	2. get current disk sector buffer address
;	3. add 128 to it and save for DMA of sector after
;		current sector.
;	4. do DMA for current sector buffer address
;	5. write current disk sector
;	6. if not last sector repeat steps 2 thru 5.
;	7. set number of characters positions left in buffer
;		to size of buffer.
;	8. set disk output buffer pointer to front of buffer.
;	9. go check to see if operator pressed control C.
;
;***************************************************************
PUTREC:	LXI	H,DISKBUF	;address of disk buffer
	SHLD	BUFADR		;save it for later DMA's
	MVI	B,OUTSECT	;number of disk sectors to write

PUTRC2:	PUSH	B		;save sector count
	LHLD	BUFADR		;get disk buffer address
	XCHG			;put it in D,E for DMA
	LXI	H,80H		;put 128 H,L
	DAD	D		;add 128 to disk buf adr for next DMA
	SHLD	BUFADR		;save it for next DMA
	MVI	C,SETDMA	;point DMA to...
	CALL	CPM		;...correct buffer
	LXI	D,OFCB		;get output disk fcb
	MVI	C,WRITE		;write sector...
	CALL	CPM		;...to disk
	ORA	A		;was write successfull?
	POP	B		;restore num of sectors left
	LXI	D,EMSG4		;get err msg in case write failed
	JNZ	FERR1		;disk write failed, display err msg, quit
	DCR	B		;written 16 sectors yet?
	JNZ	PUTRC2		;no, continue writing disk sectors
	LXI	H,OUTSECT*128	;put disk buffer size into H,L
	SHLD	DSKCNT		;set num of char left in buf to buffer size
	LXI	H,DISKBUF	;point to front...
	SHLD	DCHAR		;...of disk buffer
	JMP	PBYT3		;go check console status for ^C

;*********************************;
;
;      ISSUE PAGE EJECT
;
;*********************************;
EJECT:	MVI	E,0CH		;printer eject command
	CALL	PBYT
	MVI	E,00H
	MVI	B,10
EJECT2:	CALL	PBYT		;PRINT 10 NULLS
	DCR	B
	JNZ	EJECT2
	MVI	A,00
	STA	LINES		;SET LINE COUNT
	RET

;********************************;
;
;      ISSUE CR, LF & TEST PAGE
;
;********************************;
CRLF:	MVI	E,0DH
	CALL	PBYT
	MVI	E,0AH
	CALL	PBYT
	LDA	LINES
	INR	A
	STA	LINES		;INCREMENT LINE COUNT
	MVI	A,LPAGE		;get number of lines
	ORA	A		;is it zero?
	LDA	LINES
	RZ			;YES, RETURN
	CPI	LPAGE		;TEST LINE COUNT
	CZ	EJECT		;IF EQ TO LPAGE THEN NEW PAGE
	RET


;********************************;
;
;       CHARACTER PARSING TABLE
;
;********************************;
CTAB1:	DB	0DH
	DW	LCR
	DB	0AH
	DW	LLF
	DB	''''
	DW	LQUOT
	DB	';'
	DW	LSEMI
	DB	' '
	DW	LSPC
	DB	09H
	DW	LTAB
	DB	'$'
	DW	LDOL
	DB	'('
	DW	LDEL
	DB	')'
	DW	LDEL
	DB	'+'
	DW	LDEL
	DB	'-'
	DW	LDEL
	DB	'*'
	DW	LSEMI
	DB	'/'
	DW	LDEL
	DB	','
	DW	LDEL
	DB	':'
	DW	LDEL
	DB	EOF
	DW	DONE
	DB	0FFH
	DW	0000H
EOF	EQU	1AH		;EOF CODE

;********************************;
;
;     RESERVED WORD TABLE
;
;********************************;
RTAB:	DB	'A    '
	DB	'ACI  '
	DB	'ADC  '
	DB	'ADD  '
	DB	'ADI  '
	DB	'ANA  '
	DB	'AND  '
	DB	'ANI  '
	DB	'B    '
	DB	'C    '
	DB	'CALL '
	DB	'CC   '
	DB	'CM   '
	DB	'CMA  '
	DB	'CMC  '
	DB	'CMP  '
	DB	'CNC  '
	DB	'CNZ  '
	DB	'CP   '
	DB	'CPE  '
	DB	'CPI  '
	DB	'CPO  '
	DB	'CZ   '
	DB	'D    '
	DB	'DAA  '
	DB	'DAD  '
	DB	'DB   '
	DB	'DCR  '
	DB	'DCX  '
	DB	'DI   '
	DB	'DS   '
	DB	'DW   '
	DB	'E    '
	DB	'EI   '
	DB	'ELSE '
	DB	'END  '
	DB	'ENDIF'
	DB	'ENDM '
	DB	'EQU  '
	DB	'H    '
	DB	'HLT  '
	DB	'IF   '
	DB	'IN   '
	DB	'INR  '
	DB	'INX  '
	DB	'JC   '
	DB	'JM   '
	DB	'JMP  '
	DB	'JNC  '
	DB	'JNZ  '
	DB	'JP   '
	DB	'JPE  '
	DB	'JPO  '
	DB	'JZ   '
	DB	'L    '
	DB	'LDA  '
	DB	'LDAX '
	DB	'LHLD '
	DB	'LXI  '
	DB	'M    '
	DB	'MACRO'
	DB	'MOD  '
	DB	'MOV  '
	DB	'MVI  '
	DB	'NOP  '
	DB	'NOT  '
	DB	'OR   '
	DB	'ORA  '
	DB	'ORG  '
	DB	'ORI  '
	DB	'OUT  '
	DB	'PAGE '
	DB	'PCHL '
	DB	'POP  '
	DB	'PSW  '
	DB	'PUSH '
	DB	'RAL  '
	DB	'RAR  '
	DB	'RC   '
	DB	'RET  '
	DB	'RLC  '
	DB	'RM   '
	DB	'RNC  '
	DB	'RNZ  '
	DB	'RP   '
	DB	'RPE  '
	DB	'RPO  '
	DB	'RRC  '
	DB	'RST  '
	DB	'RZ   '
	DB	'SBB  '
	DB	'SBI  '
	DB	'SET  '
	DB	'SHL  '
	DB	'SHLD '
	DB	'SHR  '
	DB	'SP   '
	DB	'SPHL '
	DB	'STA  '
	DB	'STAX '
	DB	'STC  '
	DB	'SUB  '
	DB	'SUI  '
	DB	'TITLE'
	DB	'XCHG '
	DB	'XOR  '
	DB	'XRA  '
	DB	'XRI  '
	DB	'XTHL '
	DB	0FFH		;END OF RESERVED WORD TABLE
RSIZ	EQU	05		;SIZE OF TABLE ENTRY

;********************************;
;
;       MISCELLANEOUS DATA
;
;********************************;

MSG1:	DB	'DISK CROSS REFERENCE FILE EXISTS - ERASE IT(Y/N)?','$'
EMSG0:	DB	'++ERROR++ INPUT FILE DOES NOT EXIST', 0DH, 0AH, '$'
EMSG1:	DB	'SYMBOL TABLE ERROR',0DH,0AH,'$'
EMSG2:	DB	'FAILED TO DELETE EXISTING CROSS REFERENCE FILE',0DH,0AH,'$'
EMSG3:	DB	'FAILED TO CREATE CROSS REFERENCE FILE',0DH,0AH,'$'
EMSG4:	DB	'DISK WRITE FAILED - OUT OF SPACE?',0DH,0AH,'$'
EMSG5:	DB	'CLOSE FAILED ON DISK CROSS REFERENCE FILE',0DH,0AH,'$'
EMSG6:	DB	'++ERROR++ NOT ENOUGH MEMORY FOR SYMBOL TABLE',0DH,0AH,'$'
EMSG7:	DB	'++ERROR++ SYMBOL TABLE OVERFLOW',0DH,0AH,'$'
LOGO:	DB	0Dh,0Ah,'CPM ASSEMBLER CROSS REFERENCE LIST Ver 1.41',0Dh,0Ah,'$'
DONEMSG: DB	'CROSS REFERENCE LIST IS DONE',0DH,0AH,'$'
NOSYMS:	DB	'NO SYMBOLS IN THIS PROGRAM'
CONCRLF	DB	0DH,0AH,'$'
SSIZ	EQU	SYMSIZ+3	;SYMBOL TABLE ENTRY SIZE
SYMBT:	DS	2		;SYMBOL TABLE BOTTOM ADDRESS
SYMTP:	DS	2		;SYMBOL TABLE TOP ADDRESS
REFBT:	DS	2		;REFERENCE TABLE BOTTOM ADDRESS
REFTP:	DS	2		;REFERENCE TABLE TOP ADDRESS
SYM:	DS	2		;CURRENT SYMBOL TABLE ADDRESS
REFSZ	EQU	2+(NREFS*2)	;NUMBER OF BYTES IN REF BLOCK
REF:	DS	2		;CURRENT REFERENCE TABLE ADDRESS
FROM:	DS	2		;MOVE POINTER
TO:	DS	2		;TO POINTER
LIMIT:	DS	2		;LIMIT POINTER
COL:	DS	1
CHAR:	DS	1
LCNT:	DS	2		;LINE COUNTER
LPNT:	DS	2
DEC:	DS	5
	DB	0DH
PBUF:	DS	132
SYMCT:	DS	1
SYMPT:	DS	2
SBUF:	DS	SYMSIZ		;SYMBOL BUFFER
NLINS:	DB	0		;BUFFERS TO PRINT ON LINE
LINES:	DB	0		;PRINT LINE COUNT
 
;********************************;
;
;       OPERATING SYSTEM EQUATES
;
;********************************;
 
BOOT	EQU	0000H	;REBOOT ENTRY POINT
CPM	EQU	0005H	;CPM ENTRY POINT

MEMSZ	EQU	0006H	;END OF MEMORY POINTER
TFCB	EQU	005CH	;TRANS. FCB

CONIN	EQU	01	;CONSOLE INPUT FUNCTION CODE
PSTRING	EQU	09	;PRINT STRING FUNCTION CODE
OPEN	EQU	15	;OPEN FUNCTION CODE
CLOSE	EQU	16	;CLOSE FILE FUNCTION CODE
DELETE	EQU	19	;DELETE FILE FUNCTION CODE
READ	EQU	20	;READ DISK FUNCTION CODE
WRITE	EQU	21	;WRITE DISK FUNCTION CODE
MAKE	EQU	22	;MAKE FILE FUNCTION CODE
SETDMA	EQU	26	;SET DMA FUNCTION CODE



;********************************;
;           F O P E N            ;
;  ROUTINE TO OPEN A DISK FILE   ;
;				 ;
;  INPUT:     DE=A(FCB)		 ;
;********************************;

FOPEN:	MVI	C,OPEN	;OPEN CODE
	CALL	CPM	;ISSUE OPEN
	CPI	0FFH	;ERROR?
	RNZ		;NO ERROR
	LXI	D,EMSG0
	JMP	FERR1

;********************************;
;				 ;
; ROUTINE TO CLOSE OUTPUT DISK	 ;
;	CROSS REFERENCE FILE	 ;
;  INPUT:	DE=ADDR(FCB)	 ;
;		HL=ADDR(BUFFER)	 ;
;********************************;

DCLOSE:	PUSH	D		;save fcb address
	PUSH	H		;save buffer address
	LHLD	DSKCNT		;put number of char left...
	XCHG			;...in buffer into D,E
	LHLD	DCHAR		;point to next char in output buf
	MVI	A,1AH		;put a control Z in accum

DCLSE2:	MOV	M,A		;fill...
	INX	H		;...rest of...
	DCR	E		;...buffer...
	JNZ	DCLSE2		;...with...
	DCR	D		;...control Z's.
	JNZ	DCLSE2
	POP	H		;point to...

DCLSE4:	XCHG			;...output buffer
	LXI	H,128		;put 128 into H,L
	DAD	D		;add 128 to disk buf addr for next DMA
	SHLD	BUFADR		;save it for next DMA after this one
	MVI	C,SETDMA	;...disk buffer for...
	CALL	CPM		;...last disk write
	POP	D		;do last...
	PUSH	D		;....(D,E contains OFCB)...
	MVI	C,WRITE		;...disk...
	CALL	CPM		;...write
;Check to see if last record has been written.  Do this by comparing
;address of next available char to address of buffer for next disk write.
;If address of next available char is equal or greater, close file.
	LHLD	DCHAR		;put high order address
	XCHG			;...of last char+1...
	MOV	A,D		;...into ACCUM
	LHLD	BUFADR		;get addr of next disk buffer
	CMP	H		;compare to last char+1 in buffer
	JC	DCLSE5		;if next addr is greater, close file
	JNZ	DCLSE4		;if not equal, continue
	MOV	A,E		;put low order address of last char+1
	CMP	L		;into accum and test
	JNC	DCLSE4		;if not less, do another write

DCLSE5:	POP	D		;close the...(D,E contains OFCB)
	MVI	C,CLOSE		;...output disk
	CALL	CPM		;...cross ref file
	CPI	0FFH		;close successfull?
	RNZ			;yes, return
	LXI	D,EMSG5		;no, display error msg...
	JMP	FERR1		;... and quit

;********************************;
;            G E T B T           ;
;   ROUTINE TO READ A BYTE       ;
;                                ;
;  OUTPUTS:     A=BYTE           ;
;				 ;
; 1. is current byte pointer at  ;
;	end of buffer?		 ;
;	-yes, Read disk records	 ;
;	 into buffer.		 ;
; 2. move character from buffer	 ;
;	to ACCUM.		 ;
; 3. add 1 to character pointer	 ;
;	and save pointer.	 ;
; 4. return to caller		 ;
;				 ;
;********************************;

GETBT:	LXI	H,TBUF+(INSECT*128);end of input buf addr
	XCHG		;BUFFER END ADDR. IN DE
	LHLD	INPTR	;CURRENT POINTER IN HL
	CALL	CPHL	;TEST FOR END OF BUFFER
	CZ	GETREC	;YES, READ DISK RECORDS
	MOV	A,M	;GET BYTE
	INX	H	;BUMP POINTER
	SHLD	INPTR	;SAVE POINTER
	ORA	A	;CLEAR CARRY
	RET		;RETURN CARRY RESET

;***********************************************************
;			GETREC
;Read the number of input records specified by INSECT.  The
;buffer starts at TBUF.  Before each DMA, the buffer address
;is incremented by 128 and saved in IDADDR.  This address
;will be used for the DMA after the current sector is read.
;The logic is:
;		1. get current buffer address
;		2. add 128 to it and save it
;		3. issue DMA for current buffer address
;		4. read the disk record,
;			-if end of file goto step 7.
;		5. decrement number of sectors to read
;		6. if not number of sectors not zero
;			-repeat above
;		7. reset character pointer to first buffer
;		8. return to caller.
;***********************************************************

GETREC:	MVI	B,INSECT;number of sectors to read
	LXI	H,TBUF	;get address of disk input buffer
	SHLD	IDADDR	;initialize current buffer address

GETRC2:	LHLD	IDADDR	;get addr of input buffer
	XCHG		;put it in D,E
	LXI	H,128	;add 128 to input buf
	DAD	D	;...addr for read after next
	SHLD	IDADDR	;save it read after next
	PUSH	B	;save sector count
	PUSH	D	;save current buf ptr in case EOF occurrs
	MVI	C,SETDMA;POINT TO INPUT BUFFER...
	CALL	CPM
	MVI	C,READ	;READ CODE
	LXI	D,TFCB	;FCB ADDRESS
	CALL	CPM	;ISSUE READ
	POP	D	;restore current buf pointer
	POP	B	;restore sector count
	CPI	00	;ERROR?
	JNZ	GETRC4	;YES
	DCR	B	;read all of the sectors?
	JNZ	GETRC2	;no, continue reading

GETRC3:	LXI	H,TBUF	;RESET BUFFER POINTER
	SHLD	INPTR
	RET		;RETURN TO CALLER

GETRC4:	XCHG		;POINT TO FIRST CHAR PAST BUF
	MVI	M,26H	;PUT TWO...
	INX	H	;...CONTROL Z's
	MVI	M,26H	;...AFTER LAST REC IN FILE
	JMP	GETRC3	;GO RESET BUFFER POINTER

;********************************;
;   CONVERTS LOWER TO UPPER CASE ;
;	INPUT: A=BYTE(upper/lower;
;	OUTPUTS: A=BYTE UPPER	 ;
;********************************;

lwrupr:	cpi	'A'+20h	;is it upper case?
	cmc		;complement carry
	rnc		;yes, return with carry reset
	Cpi	'Z'+21h	;over lower case 'Z'?
	rnc		;no, return no carry
	sui	20h	;convert to upper case
	ret

;********************************;
;   MISCELLANEOUS SUBROUTINES    ;
;********************************;


;********************************;
;             C P H L            ;
;  ROUTINE TO COMPARE HL VS DE   ;
;	OUTPUT: HL=DE, ZERO=ON	 ;
;		HL<>DE, ZERO=OFF ;
;********************************;

CPHL:	MOV	A,H
	CMP	D
	RNZ
	MOV	A,L
	CMP	E
	RET

;********************************;
;             D A T A            ;
;********************************;

OFCB:	DB	0	;disk output fcb, default drive
	DS	8	;file name
	DB	'XRF'	;file type
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

DCHAR:	DW	DISKBUF	;pointer for disk buffer

BUFADR:	DS	2	;pointer to disk output buffer for DMA

IDADDR:	DS	2	;POINTER TO DISK INPUT BUFFER FOR DMA

DSKCNT:	DW	OUTSECT*128	;number of char left in disk buffer

INPTR:	DW	TBUF+(INSECT*128);POINTER TO CHAR IN INPUT BUFFER

DISKBUF	DS	OUTSECT*128	;output disk buffer

TBUF:	DS	INSECT*128	;DISK INPUT BUFFER

EOFCHR:	DB	26H,26H	;control Z's in case last block is
			;filled with data

CONSOLE	DB	0	;console output switch

DISKOUT	DB	0	;disk output switch

FTPRN:	DB	1	;prn file type

TEMP:	DS	2	;TEMP SAVE WORD

	DS	64	;stack contains 32 words
STACK	EQU	$

;***********************************************
;
;		SYMBOL TABLE AREA
;
;	THE SYMBOL TABLE MUST BE THE
;	LAST BYTE BEFORE THE HELP MESSAGE
;
;***********************************************

	ORG	($ AND 0FFF0H) + 10H	;FORCE 16 BYTE BOUNDARY
SYMT:	DB	0FFH

HELP:	DB	0DH,0AH,'This program can be used to' 
	DB	' create a cross reference listing',0DH,0AH
	DB	'of CPM assembler programs.'
	DB	'  The input can be either the assembler',0DH,0AH
	DB	'language source code(FN.ASM) or the assembly listing(FN.PRN).',0DH,0AH
	DB	'The output can be printed on the CPM list device, displayed on',0DH,0AH
	DB	'the console, or written to disk(file type will be XRF).  It is',0DH,0AH
	DB	'invoked by keying:',0DH,0AH,0AH
	DB	09H,'XREF FN.ASM      (OUTPUT ON LIST DEVICE)',0DH,0AH
	DB	09H,'XREF FN.PRN CON  (OUTPUT ON THE CONSOLE)',0DH,0AH
	DB	09H,'XREF FN.ASM D    (OUTPUT ON DISK-DEFAULT DRIVE)',0DH,0AH
	DB	09H,'XREF FN.PRN B:D  (OUTPUT ON DISK-DRIVE SPECIFIED)',0DH,0AH,'$'

	END
