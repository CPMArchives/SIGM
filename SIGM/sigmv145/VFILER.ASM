;  PROGRAM:  VFILER
;  VERSION:  1.7
;  DATE:  9 Sep 83
;  AUTHOR:  Richard Conn
;  PREVIOUS VERSIONS:  1.6 (18 Aug 83), 1.5 (20 July 83)
;  PREVIOUS VERSIONS:  1.4 (19 July 83), 1.3 (18 July 83)
;  PREVIOUS VERSIONS:  1.2 (18 July 83), 1.1 (17 July 83), 1.0 (16 July 83)
;  DERIVATION:  From FILER (Version 1.6) by Richard Conn
;
VERS	EQU	17		;version number

; VFILER from DISK7, Version 7.6C
; DISK7, Version 7.6C, copyright (c) 1983 by Frank Gaude'.  All rights reserved
; released to the public domain for non-commercial use.
; Monetary gain in not permitted under
; any circumstance by individual, partnership, or corporation.

; DISK7 is based on common ideas presented in CLEANUP, WASH, and SWEEP,
; written by Ward Christensen, Michael Karas, and Robert Fisher, respectively.
; Existence of these programs generated impetus for writing DISK7.

; VFILER is a screen-oriented, ZCPR2-specific file utility.  It can be
; installed to run under conventional CP/M by turning all of the ZCPR2-specific
; options off, but it is highly recommended to obtain ZCPR2 (or the 8080
; version called ZC8080) and use VFILER in conjunction with it.  VFILER
; extensively employs cursor addressing to position a pointer on the
; screen, allow the user to manipulate the pointer (up, down, right, left,
; next screen, previous screen, GOTO file).  The pointer points to files
; in the current user directory and displays the user's position dynamically
; on the screen.  Once pointing to a file, user commands can be used to
; manipulate the file (delete, copy, view on console, print on printer, tag
; for later copy or delete, and untag).  In the way of being ZCPR2-specific,
; VFILER can chain to external programs via the MCL and then return (ala
; MENU), and it recognizes Named Directories (so the user can log into B:, B4:,
; and MYDIR:, for example).

; VFILER is installed by GENINS.

; VFILER works with CP/M 2.2 only, with 24k or more of RAM.  File copy
; functions are faster with large amounts of RAM.  It is slightly larger
; than DISK7, occupying 5-6K bytes of memory.  VFILER includes some Z80-
; specific code, while DISK7 is totally 8080.

; starting definitions

TRUE	 EQU	0FFH		;define true and..
FALSE	 EQU	0       	;..false.
Z80	 EQU	TRUE 		;TRUE to use Z80 Instructions
WARMBOOT EQU	FALSE		;set true to warmboot on exit
CPM$BASE EQU	000H		;cp/m system base..
TPA	 EQU	100H		;..'transient program area' start..
CCP	 EQU	800H		;..and 'ccp' length in bytes.
GET	 EQU	0FFH		;get user area e-reg value
EPS	 EQU	16*4		;16 lines x 4 cols per screen
				;  EPS = Entries Per Screen

; cursor positioning as per the user's particular terminal
;   this is set for the TVI 950 function keys

USER$UP		EQU	0BH	;^K
USER$DOWN	EQU	16H	;^V
USER$RIGHT	EQU	0CH	;^L
USER$LEFT	EQU	08H	;^H
SCR$FOR		EQU	06H	;^F
SCR$BACK	EQU	01H	;^A

; cursor positioning addresses

EPSLINE	EQU	(EPS/4)+5	;position of last line of EPS
BANADR	EQU	1*256+24	;banner address
SDMADR	EQU	3*256+30	;screen directory message
CURHOME	EQU	4*256+1		;home address of cursor
BOTADR	EQU	23*256+1	;bottom of screen
CPMADR	EQU	EPSLINE*256+1	;command prompt message
CPADR	EQU	EPSLINE*256+30	;command prompt
ERADR	EQU	(EPSLINE+1)*256+30	;error message
FSADR	EQU	ERADR		;file size message
FNADR	EQU	(EPSLINE+1)*256+15	;address of file name

; ASCII definitions

CTRLC	EQU	'C'-'@'		;..control-C..
CTRLD	EQU	'D'-'@'
CTRLE	EQU	'E'-'@'
CTRLR	EQU	'R'-'@'
CTRLS	EQU	'S'-'@'		;..XOFF..
CTRLX	EQU	'X'-'@'
BS	EQU	08H		;..backspace..
TAB	EQU	09H		;..tab..
LF	EQU	0AH		;..linefeed..
CR	EQU	0DH		;..carriage return..
CAN	EQU	18H		;..cancel..
EOFCHAR	EQU	1AH		;..end-of-file..
CTRLZ	EQU	1AH		;..clear screen..
ESC	EQU	1BH		;..and escape character.

;
; MACROS TO PROVIDE Z80 EXTENSIONS
;   MACROS INCLUDE:
;
$-MACRO 		;FIRST TURN OFF THE EXPANSIONS
;
;	JR	- JUMP RELATIVE
;	JRC	- JUMP RELATIVE IF CARRY
;	JRNC	- JUMP RELATIVE IF NO CARRY
;	JRZ	- JUMP RELATIVE IF ZERO
;	JRNZ	- JUMP RELATIVE IF NO ZERO
;	DJNZ	- DECREMENT B AND JUMP RELATIVE IF NO ZERO
;
;
;
;	@GENDD MACRO USED FOR CHECKING AND GENERATING
;	8-BIT JUMP RELATIVE DISPLACEMENTS
;
@GENDD	MACRO	?DD	;;USED FOR CHECKING RANGE OF 8-BIT DISPLACEMENTS
	IF (?DD GT 7FH) AND (?DD LT 0FF80H)
	DB	100H	;Displacement Range Error on Jump Relative
	ELSE
	DB	?DD
	ENDIF
	ENDM
;
;
; Z80 MACRO EXTENSIONS
;
JR	MACRO	?N	;;JUMP RELATIVE
	 IF	Z80
	DB	18H
	@GENDD	?N-$-1
	 ELSE
	JMP	?N
	 ENDIF
	ENDM
;
JRC	MACRO	?N	;;JUMP RELATIVE ON CARRY
	 IF	Z80
	DB	38H
	@GENDD	?N-$-1
	 ELSE
	JC	?N
	 ENDIF
	ENDM
;
JRNC	MACRO	?N	;;JUMP RELATIVE ON NO CARRY
	 IF	Z80
	DB	30H
	@GENDD	?N-$-1
	 ELSE
	JNC	?N
	 ENDIF
	ENDM
;
JRZ	MACRO	?N	;;JUMP RELATIVE ON ZERO
	 IF	Z80
	DB	28H
	@GENDD	?N-$-1
	 ELSE
	JZ	?N
	 ENDIF
	ENDM
;
JRNZ	MACRO	?N	;;JUMP RELATIVE ON NO ZERO
	 IF	Z80
	DB	20H
	@GENDD	?N-$-1
	 ELSE
	JNZ	?N
	 ENDIF
	ENDM
;
DJNZ	MACRO	?N	;;DECREMENT B AND JUMP RELATIVE ON NO ZERO
	 IF	Z80
	DB	10H
	@GENDD	?N-$-1
	 ELSE
	DCR	B
	JNZ	?N
	 ENDIF
	ENDM
;
; END OF Z80 MACRO EXTENSIONS
;

; assembly origin (load address) and program beginning

	ORG	CPM$BASE+TPA
SOURCE:
	JMP	FILER


;
;	ZCPR2 and its utilities, including this one, are released
; to the public domain.  Anyone who wishes to USE them may do so with
; no strings attached.  The author assumes no responsibility or
; liability for the use of ZCPR2 and its utilities.
;

;
;******************************************************************
;
;  SINSFORM -- ZCPR2 Utility Standard General Purpose Initialization Format
;
;	This data block precisely defines the data format for
; initial features of a ZCPR2 system which are required for proper
; initialization of the ZCPR2-Specific Routines in SYSLIB.
;

;
;  EXTERNAL PATH DATA
;
EPAVAIL:
	DB	0FFH	; IS EXTERNAL PATH AVAILABLE? (0=NO, 0FFH=YES)
EPADR:
	DW	40H	; ADDRESS OF EXTERNAL PATH IF AVAILABLE

;
;  INTERNAL PATH DATA
;
INTPATH:
	DB	0,0	; DISK, USER FOR FIRST PATH ELEMENT
			; DISK = 1 FOR A, '$' FOR CURRENT
			; USER = NUMBER, '$' FOR CURRENT
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0
	DB	0,0	; DISK, USER FOR 8TH PATH ELEMENT
	DB	0	; END OF PATH

;
;  MULTIPLE COMMAND LINE BUFFER DATA
;
MCAVAIL:
	DB	0FFH	; IS MULTIPLE COMMAND LINE BUFFER AVAILABLE?
MCADR:
	DW	0FF00H	; ADDRESS OF MULTIPLE COMMAND LINE BUFFER IF AVAILABLE

;
;  DISK/USER LIMITS
;
MDISK:
	DB	4	; MAXIMUM NUMBER OF DISKS
MUSER:
	DB	31	; MAXIMUM USER NUMBER

;
;  FLAGS TO PERMIT LOG IN FOR DIFFERENT USER AREA OR DISK
;
DOK:
	DB	0FFH	; ALLOW DISK CHANGE? (0=NO, 0FFH=YES)
UOK:
	DB	0FFH	; ALLOW USER CHANGE? (0=NO, 0FFH=YES)

;
;  PRIVILEGED USER DATA
;
PUSER:
	DB	10	; BEGINNING OF PRIVILEGED USER AREAS
PPASS:
	DB	'chdir',0	; PASSWORD FOR MOVING INTO PRIV USER AREAS
	DS	41-($-PPASS)	; 40 CHARS MAX IN BUFFER + 1 for ending NULL

;
;  CURRENT USER/DISK INDICATOR
;
CINDIC:
	DB	'$'	; USUAL VALUE (FOR PATH EXPRESSIONS)

;
;  DMA ADDRESS FOR DISK TRANSFERS
;
DMADR:
	DW	80H	; TBUFF AREA

;
;  NAMED DIRECTORY INFORMATION
;
NDRADR:
	DW	00000H	; ADDRESS OF MEMORY-RESIDENT NAMED DIRECTORY
NDNAMES:
	DB	64	; MAX NUMBER OF DIRECTORY NAMES
DNFILE:
	DB	'NAMES   '	; NAME OF DISK NAME FILE
	DB	'DIR'		; TYPE OF DISK NAME FILE

;
;  REQUIREMENTS FLAGS
;
EPREQD:
	DB	0FFH	; EXTERNAL PATH?
MCREQD:
	DB	0FFH	; MULTIPLE COMMAND LINE?
MXREQD:
	DB	0FFH	; MAX USER/DISK?
UDREQD:
	DB	0FFH	; ALLOW USER/DISK CHANGE?
PUREQD:
	DB	000H	; PRIVILEGED USER?
CDREQD:
	DB	0FFH	; CURRENT INDIC AND DMA?
NDREQD:
	DB	0FFH	; NAMED DIRECTORIES?
Z2CLASS:
	DB	11	; CLASS 11
	DB	'ZCPR2'
	DS	10	; RESERVED

;
;  END OF SINSFORM -- STANDARD DEFAULT PARAMETER DATA
;
;******************************************************************
;

;
;  **** Special Initial Value Area for GENINS
;
LWIDTH:
	DB	132	; WIDTH OF LINE
LTPP:
	DB	44	; LINES OF TEXT PER PAGE
LSPP:
	DB	5	; LINES TO SKIP PER PAGE
CWIDTH:
	DB	80	; WIDTH OF SCREEN
CTPP:
	DB	22	; LINES OF TEXT PER SCREEN
CSPP:
	DB	1	; LINES TO SKIP PER SCREEN

; concealed copyright notice

;	DB	' DISK7 Copyright (c) 1983 by Frank Gaude'''
;	DB	' All Rights Reserved'

;
;  Screen Routines
;
	org	200h		; base page for screen routines
CLS:
	JMP	CLS950
GOTOXY:
	JMP	GOTO950
EREOL:
	JMP	EREOL950

CURTABLE:
	DB	USER$UP,USER$DOWN,USER$RIGHT,USER$LEFT	; up, down, right, left
	DB	SCR$FOR,SCR$BACK			; screen forward, back

; screen routines (for TVI 950)

;  clear screen
CLS950:
	MVI	A,CTRLZ		;clear screen
	JMP	TYPE

;  position cursor (H=row, L=col) where 1,1=upper left
GOTO950:
	MVI	A,ESC		;ESCape
	CALL	TYPE
	MVI	A,'='
	CALL	TYPE
	MOV	A,H		;row
	ADI	' '
	CALL	TYPE
	MOV	A,L		;column
	ADI	' '
	JMP	TYPE

;  erase to end of line
EREOL950:
	MVI	A,ESC		;ESCape
	CALL	TYPE
	MVI	A,'T'
	JMP	TYPE

; start of program

	org	300h		;page address
	JMP	TYPE		;I/O support for package

FILER:
	 IF	NOT WARMBOOT
	LXI	H,0		;clear hl-pair then..
	DAD	SP		;..add cp/m's stack address.
	SHLD	STACK
	 ENDIF			;not warmboot

	LXI	SP,STACK	;start local stack
	LXI	H,CURTABLE	;init cursor commands
	LXI	D,CTABLE	;pt to area
	MVI	B,6		;6 commands
CURINIT:
	MOV	A,M		;get command
	STAX	D		;put it
	INX	H		;pt to next
	INX	D
	INX	D
	INX	D
	DJNZ	CURINIT
	CALL	IDU		;set initial disk/user
	LDA	NDNAMES		;size of disk-based named directory
	LXI	H,0
	MOV	E,A		;... in DE
	MVI	D,0
	DAD	D		;*1
	DAD	H		;*2
	DAD	H		;*4
	DAD	D		;*5
	DAD	H		;*10
	INR	H		;next page
	MVI	L,0
	LXI	D,BUFENTRY	;base address
	DAD	D
	SHLD	RING		;beginning of ring
	XCHG			;HL pts to BUFENTRY
	CALL	ZDNAME		;scan for and load NAMES.DIR
	JRZ	FILERPASS
	MOV	A,C		;set count
	STA	BUFENTRY-1
FILERPASS:
	LDA	MDISK		;get max disk number
	ADI	'A'-1
	STA	MAXDR		;set letter
	LDA	FCB+1		;check for initial help
	CPI	'/'
	JRZ	FILERH
	LDA	FCB2+1		;check for wait
	CPI	'W'
	JRNZ	FILER0
FILERSAK:
	CALL	ILPRT
	DB	CR,LF,'Strike Any Key to Enter VFILER -- ',0
	CALL	DKEYIN
	JR	FILER0
FILERH:
	CALL	HELPMSG		;print help message
	JR	FILERSAK
FILER0:
	CALL	HELPCHK		;check for availability of HELP Files
	JMP	EMBARK

;  set initial disk/user
IDU:
	LXI	H,FCB+1		;check for DU specification
	MOV	A,M
	CPI	' '		;<SP>=none
	JRZ	IDU1
	CALL	DEF$DU0		;extrace drive/user
	MOV	A,C		;get current user
	CALL	IDU$USET	;set it
	MOV	A,B		;get current disk
	CALL	IDU$DSET	;set it
	JMP	LOG1Z		;log it in
IDU1:
	MVI	E,GET		;determine..
	CALL	GET$USR		;..user area then..
	CALL	IDU$USET	;set current user
	MVI	C,INQDISK	;determine current disk
	CALL	BDOS
	CALL	IDU$DSET	;set current disk
	JMP	LOG1Z		;set current user and disk
IDU$USET:
	STA	C$U$A		;..store as current and..
	STA	O$USR		;..as original for exit.
	STA	R$U$A		;..requested user area
	RET
IDU$DSET:
	STA	C$DR
	STA	R$DR		;requested disk
	RET

; check for availability of HELP Files (HELP.COM and FILER.HLP)

HELPCHK:
	XRA	A		;assume NO
	STA	HELPFLG		;set flag
	LXI	D,HELPFCB
	CALL	FILECHK		;check for file
	ORA	A		;0=no
	RZ
	MVI	A,0FFH		;set flag
	STA	HELPFLG
	RET

; check for existance of file whose first 12 FCB bytes are pted to by DE
;   return with A=0 if not found, A=0FFH if found

FILECHK:
	LXI	H,S$FCB		;copy into FCB
	XCHG
	MVI	B,12		;12 bytes
	CALL	MOVE		;copied into S$FCB
	XCHG			;HL pts to FCB
	CALL	INITFCB		;init FCB
	LXI	D,S$FCB		;pt to FCB
	JMP	FFIND

; determine if specific file(s) requested -- show remaining storage

EMBARK:
	CALL	FRESTOR		;get bytes remaining on drive (decode default)
	LXI	H,JOKER		;..treat as '*.*' with 'joker'..
	LXI	D,FCB+1		;..loaded here.
	MVI	B,11		; # of characters to move
	CALL	MOVE		;set field to *.*

; build 'ring' with filename positioned in default 'fcb' area

PLUNGE:
	MVI	C,SETDMA	;initialize dma address..
	LXI	D,TBUF		;..to default buffer.
	CALL	BDOS
	XRA	A		;clear search 'fcb'..
	STA	FCBEXT		;extent byte..
	STA	FCBRNO		;..and record number.
	CMA
	STA	CANFLG		;make cancel flag true
	LXI	D,FCB		;default 'fcb' for search..
	MVI	C,SRCHF		;..of first occurrence.
	CALL	BDOS
	INR	A		; 0ffh --> 00h if no file found
	JNZ	SETRING		;if found, branch and build ring.
	STA	CANFLG		;make log-cancel toggle false
	CALL	ERMSG		;else say none found, fall thru to log.
	DB	'No File Found',0

; l o g

; select drive and user area (system reset for disk change on-the-fly)

LOG:
	CALL	CPRMPT		;prompt to get drive/user selection
	DB	'Login DIR: ',0
	CALL	DEF$D$U
LOG1:
	CALL	LOG1Z		;set current and log in
	CALL	CRLF		;new line
	JMP	EMBARK		;..restart

;  set current user and disk

LOG1X:
	LXI	H,LOG$DU$MSG
	LDA	R$DR		;set prompt message
	ADI	'A'		;adjust to letter
	MOV	M,A
	INX	H
	MVI	M,' '		;prep for user < 10
	LDA	R$U$A		;get user
	CPI	10		;less than 10?
	JRC	LOG2
	MVI	B,'1'		;set digits
LOG1A:
	SUI	10		;adjust user
	CPI	10		;less?
	JRC	LOG1B
	INR	B		;incr 10's
	JR	LOG1A
LOG1B:
	MOV	M,B		;set 10's
LOG2:
	INX	H		;pt to 1's
	ADI	'0'		;to ASCII
	MOV	M,A
	RET

;  actually log into DU requested

LOG1Y:
	LDA	R$U$A		;establish requested area..
	STA	C$U$A		;..as current area.
	CALL	SET$USR
	CALL	RESET		;reset disk system, make requested current.
	LXI	H,0		;initialize tagged..
	SHLD	TAG$TOT		;..file size accumulator.
	RET

;  set current DU and log into it

LOG1Z:
	CALL	LOG1X		;set current
	CALL	LOG1Y		;actually log in
	RET

; routine to define current drive and user area with full error trapping.
; (check validity of user area entry first, then drive validity, then proceed
; with implementation.)

DEF$D$U:
	LXI	H,CMDBUF+2
	MVI	B,20		; # of blanks to..
	CALL	FILL		;..clear 'cmdbuf'.
	LXI	D,CMDBUF	;get DU selection from..
	MVI	C,RDBUF		;..console buffer read.
	CALL	BDOS
	CALL	CONVERT		;make sure alpha is upper case
	LXI	H,CMDBUF+2	;pt to possible drive
DEF$DU0:
	CALL	ZDNFIND		;look for DU or DIR form and return DU
	JRZ	ERRET		;error
	MOV	A,B		;return disk and user
	STA	R$DR
	INR	A		;set FCB
	STA	FCB
	MOV	A,C
	STA	R$U$A
	RET

; error return and recovery from command cancellation

ERRET:
	CALL	ERMSG
	DB	'DIR Entry Error',0
	JMP	NEUTRAL
COMCAN:
	LXI	SP,STACK	;reset stack..
	LDA	CANFLG
	ORA	A		;..from..
	JZ	PLUNGE
	CALL	REFRESH		;refresh screen
	JMP	LOOPFN		;..error/command abort.

; find file along path (file FCB pted to by DE)
;   on return, A=0FFH if found, A=0 if not found, and flags set

FFIND:
	PUSH	D		;save ptr to FCB
	MVI	E,GET		;get and save current DU
	CALL	GET$USR
	STA	C$U$A
	STA	Z$U$A
	MVI	C,INQDISK
	CALL	BDOS
	STA	C$DR
	STA	Z$DR
	POP	D		;get ptr to FCB
	CALL	GETPATH		;HL pts to current path
FFINDL:
	CALL	SEARF		;look for file
	JRNZ	FFOUND		;found file
	LDA	CINDIC		;get current indictor
	MOV	C,A		;... in C
	MOV	A,M		;get drive
	ORA	A		;0=done=not found
	JRZ	FNFOUND
	CMP	C		;current disk?
	JRNZ	FF1
	LDA	C$DR		;get current disk
	INR	A		;increment for following DCR
FF1:
	DCR	A		;adjust to 0 for A
	MOV	B,A		;disk in B
	STA	Z$DR		;note disk
	INX	H		;pt to user
	MOV	A,M		;user in A
	CMP	C		;current?
	JRNZ	FF2
	LDA	C$U$A		;get current user
FF2:
	MOV	C,A		;user in C
	STA	Z$U$A		;note user
	INX	H		;pt to next entry
	CALL	SLOGIN		;log in DU
	JR	FFINDL
FFOUND:
	CALL	DLOGIN		;log in default
	MVI	A,0FFH		;set flag
	ORA	A
	RET
FNFOUND:
	CALL	DLOGIN		;log in default
	XRA	A		;set flag
	RET
; get starting address of path in HL
GETPATH:
	LDA	EPAVAIL		;external path available?
	ORA	A
	JRZ	GPINT
	LHLD	EPADR		;get address of external path
	RET
GPINT:
	LXI	H,INTPATH	;internal path
	RET
; search for file pted to by DE; don't affect DE or HL; ret code in A
SEARF:
	PUSH	H		;save regs
	PUSH	D
	MVI	C,SRCHF		;search for file
	CALL	BDOS
	INR	A		;set flags
	POP	D		;get regs
	POP	H
	RET
; log in default directory
DLOGIN:
	LDA	C$DR		;disk in B
	MOV	B,A
	LDA	C$U$A		;user in C
	MOV	C,A		;fall thru to SLOGIN
; log in DU in BC
SLOGIN:
	PUSH	H		;save regs
	PUSH	D
	PUSH	B
	MOV	A,C		;set user
	CALL	SET$USR
	POP	B
	MOV	A,B		;set disk
	CALL	SET$DR
	POP	D		;restore regs
	POP	H
	RET

; e x i t

; return to cp/m ccp

CPM$CCP:
	LDA	O$USR		;get and set original..
	CALL	SET$USR		;..user area and..
	LXI	D,TBUF		;..tidy up..
	MVI	C,SETDMA	;..before going home.
	CALL	BDOS
	CALL	CLS

	 IF WARMBOOT
	JMP	CPM$BASE
	 ENDIF			;warmboot

	 IF	NOT WARMBOOT
	LHLD	STACK		;put cp/m's pointer..
	SPHL			;..back to 'sp'.
	RET			;return to cp/m ccp
	 ENDIF			;not warmboot

; establish ring (circular list) of filenames

SETRING:
	LHLD	RING		;initialize ring pointer
	SHLD	RINGPOS		;start --> current position of ring

; put each found name in ring.  a-reg --> offset into 'tbuf' name storage

TO$RING:
	DCR	A		;un-do 'inr' from above and below
	ADD	A		;times 32 --> position index
 	ADD	A
	ADD	A
	ADD	A
	ADD	A
	ADI	TBUF		;add page offset and..
	MOV	L,A		;..put address into..
	MVI	H,0		;..hl-pair.
	LDA	FCB		;get drive/user designator and..
	MOV	M,A		;..put into 'fcb' buffer.
	XCHG
	LHLD	RINGPOS		;pointer to current load point in ring
	XCHG
	MVI	B,12		;move drive designator and name to ring
	CALL	MOVE
	XCHG			;de-pair contains next load point address
	MVI	M,' '		;space for potential..
	INX	H		;..tagging of files for mass copy.
	SHLD	RINGPOS		;store and search..
	MVI	C,SRCHN		;..for next occurrence.
	LXI	D,FCB		;filename address field
	CALL	BDOS
	INR	A		;if all done, 0ffh --> 00h.
	JRNZ	TO$RING		;if not, put next name into ring.

; all filenames in ring -- setup ring size and copy-buffer start point

	LHLD	RINGPOS		;next load point of ring is start of buffer
	SHLD	RINGEND		;set ring end..
	SHLD	BUFSTART	;..and copy-buffer start.
	PUSH	H
	LHLD	RING
	LXI	D,13		;compare 'ringend' (tab base+13)
	DAD	D
	XCHG
	POP	H
	CALL	CMPDEHL
	JZ	CMDLOOP		;go to command loop, if no sort.

; sort ring of filenames

SORT:
	LHLD	RING		;initialize 'i' sort variable and..
	SHLD	RINGI
	LXI	D,13		;..also 'j' variable.
	DAD	D
	SHLD	RINGJ
SORTLP:
	LHLD	RINGJ		;compare names 'i & j'
	XCHG
	LHLD	RINGI
	PUSH	H		;save position pointers..
	PUSH	D		;..for potential swap.
	MVI	B,13		; # of characters to compare

; left to right compare of two strings (de-pair points to 'a' string;
; hl-pair, to 'b'; b-reg contains string length.)

CMPSTR:
	LDAX	D		;get an 'a' string character and..
	CMP	M		;..check against 'b' string character.
	JRNZ	NOCMP		;if not equal, set flag.
	INX	H		;bump compare..
	INX	D		;..pointers and..
	DCR	B		; (if compare, set as equal.)
	JRNZ	CMPSTR		;..do next character.
NOCMP:
	POP	D
	POP	H
	MVI	B,13
	JRNC	NOSWAP

; swap if 'j' string larger than 'i'

SWAP:
	MOV	C,M		;get character from one string..
	LDAX	D		;..and one from other string.
	MOV	M,A		;second into first
	MOV	A,C		;first into second
	STAX	D
	INX	H		;bump swap pointers
	INX	D
	DJNZ	SWAP
NOSWAP:
	LHLD	RINGJ		;increment 'j' pointer
	LXI	D,13
	DAD	D
	SHLD	RINGJ
	XCHG			;see if end of 'j' loop
	LHLD	RINGEND
	CALL	CMPDEHL
	JNZ	SORTLP		;no, so more 'j' looping.
	LHLD	RINGI		;bump 'i' pointer
	LXI	D,13
	DAD	D
	SHLD	RINGI
	DAD	D		;set start over 'j' pointer
	SHLD	RINGJ
	XCHG			;see if end of 'i' loop
	LHLD	RINGEND
	CALL	CMPDEHL
	JNZ	SORTLP		;must be more 'i' loop to do

; sort done -- initialize tables for fast crc calculations

	CALL	INITCRC

; calculate buffer maximum available record capacity

B$SIZE:
	LXI	B,0		;count records
	LHLD	BDOS+1		;get 'bdos' entry (fbase)

	 IF	NOT WARMBOOT
	LXI	D,-(CCP)
	DAD	D
	 ENDIF			;not warmboot

	DCX	H
	XCHG			;de-pair --> highest address of buffer
	LHLD	BUFSTART	;start address of buffer (end of ring list)
B$SIZE2:
	INX	B		;increase record count by one
	PUSH	D
	LXI	D,128		; 128-byte record
	DAD	D		;buffer address + record size
	POP	D
	CALL	CMPDEHL		;compare for all done
	JRNC	B$SIZE2		;more will fit?
	DCX	B		;set maximum record count less one
	MOV	A,B		;memory available for copy?
	ORA	C
	JRNZ	B$SIZE3		;yes, buffer memory space available.
	CALL	ERMSG
	DB	'No Memory for Copy Buffer',0
	JMP	NEUTRAL

B$SIZE3:
	MOV	L,C		;store..
	MOV	H,B		;..maximum..
	SHLD	REC$MAX		;..record count.
	JMP	CMDLOOP

; buffer size suitable -- process file/display loop

LOOPFN:
	LXI	H,FNADR		;position cursor for file name print
	CALL	GOTOXY
	LHLD	RINGPOS		;pt to current file name
	INX	H		;pt to first char
	CALL	PRFN		;print file name
LOOP:
	CALL	ATCMD		;position at command prompt
	CALL	DKEYIN		;wait for character from keyboard
	PUSH	PSW		;save command
	LDA	ERMFLG		;error message?
	ORA	A		;0=no
	JRZ	CPROC
	CALL	ERCLR		;erase old error message
CPROC:
	POP	PSW		;get command
	CALL	CTPROC		;process command or return if not found
	CALL	ERMSG
	DB	'Invalid Command: ',0
	MOV	A,B		;get char
	CPI	' '		;expand if less than space
	JRNC	CPROC1
	MVI	A,'^'		;control
	CALL	TYPE
	MOV	A,B		;get byte
	ADI	'@'		;convert to letter
CPROC1:
	CALL	TYPE
NEUTRAL:
	JMP	LOOP		;..position.

; process command from table

CTPROC:
	LXI	H,CTABLE	;pt to table
	MOV	B,A		;command in B
CTPR1:
	MOV	A,M		;get table command char
	ORA	A		;end of table?
	RZ			;done if so
	CMP	B		;match?
	JRZ	CTPR2
	INX	H		;skip to next entry
	INX	H
	INX	H
	JR	CTPR1
CTPR2:
	INX	H		;pt to address
	MOV	A,M		;get low
	INX	H
	MOV	H,M		;get high
	MOV	L,A
	XTHL			;address on stack
	RET			;"jump" to routine

; Command Table
CTABLE:
	DB	0		;user cursor positioning
	DW	UP
	DB	0
	DW	DOWN
	DB	0
	DW	FORWARD
	DB	0
	DW	REVERSE
	DB	0		;user screen jumps
	DW	JUMPF
	DB	0
	DW	JUMPB
	DB	CTRLE		;system cursor positioning
	DW	UP
	DB	CTRLX
	DW	DOWN
	DB	CTRLD
	DW	FORWARD
	DB	CTRLS
	DW	REVERSE
	DB	'+'		;jump forward
	DW	JUMPF
	DB	'-'		;jump backward
	DW	JUMPB
	DB	' '		;go forward
	DW	FORWARD
	DB	BS		;back up?
	DW	REVERSE
	DB	'B'		;back up?
	DW	REVERSE
	DB	'C'		;copy a file?
	DW	COPY
	DB	'D'		;delete a file?
	DW	DELETE
	DB	'F'		;show file size?
	DW	FIL$SIZ
	DB	'G'		;goto a file?
	DW	GOTO
	DB	'H'		;external help?
	DW	EXTHELP
	DB	'L'		;log-in another drive?
	DW	LOG
	DB	'M'		;tagged multiple file copy?
	DW	MASS$COPY
	DB	'N'		;go forward
	DW	FORWARD
	DB	'P'		;output file to 'list' device?
	DW	LSTFILE
	DB	'Q'
	DW	SCREFRESH
	DB	'R'		;if rename, get to work.
	DW	RENAME
	DB	'S'		;free bytes on..
	DW	R$DR$ST		;..requested drive?
	DB	'T'		;if tag, put '*' in..
	DW	TAG$EM		;..front of cursor.
	DB	'U'		;remove '*' from..
	DW	UNTAG		;..in front of cursor?
	DB	'W'		;mass tag/untag?
	DW	MASS$TU
	DB	'V'		; 'view' file at console?
	DW	VIEW
	DB	'X'		;if exit, then to cp/m ccp.
	DW	CPM$CCP
	DB	'Y'		;mass delete?
	DW	MASS$DEL
	DB	'Z'		;run ZCPR2 command
	DW	RUNZCPR2
	DB	ESC		; 'esc' exits to cp/m ccp also.
	DW	CPM$CCP
	DB	'?'		;help
	DW	HELP
	DB	'/'		;help also
	DW	HELP
	DB	0		;end of table

; h e l p  (menu)

HELPMSG:
	CALL	CLS
	CALL	ILPRT
	DB	'-- VFILER '
	DB	VERS/10+'0','.',VERS MOD 10+'0'
	DB	':  ZCPR2 File Manipulation Program -- '
	DB	CR,LF,CR,LF
	DB	'-- Tagging Commands --    -- File Operations --',CR,LF
	DB	'    T - Tag File              C - Copy File',CR,LF
	DB	'    U - Untag File            D - Delete File',CR,LF
	DB	'    W - Mass Tag/Untag        F - File Size',CR,LF
	DB	'                              M - Mass Copy',CR,LF
	DB	'-- File Print & View --       R - Rename File',CR,LF
	DB	'P - Print      V - View       Y - Mass Delete',CR,LF
	DB	CR,LF
	DB	'-- Movement Commands --   -- Miscellaneous --',CR,LF
	DB	'    <SP> - File Forward       H - Detailed Help',CR,LF
	DB	'     N   - File Forward       L - Login DIR',CR,LF
	DB	'    <BS> - File Backward      Q - Refresh Screen',CR,LF
	DB	'     B   - File Backward      S - Status of Disk',CR,LF
	DB	'     G   - Go To a File       X - Exit',CR,LF
	DB	'     +   - Screen Forward     Z - Run ZCPR2 Command',CR,LF
	DB	'     -   - Screen Backward    / - This Summary',CR,LF
	DB	CR,LF
	DB	'                -- Screen Movement --',CR,LF
	DB	'File:    ^S - LEFT   ^D - RIGHT   ^E - UP   ^X - DOWN',CR,LF
	DB	'Screen:  ^A - LEFT   ^F - RIGHT',CR,LF
	DB	0
	CALL	BOTTOM
	RET
HELP:
	CALL	HELPMSG		;print message
	CALL	REFRESH		;refresh screen
	JMP	LOOPFN
EXTHELP:
	LDA	HELPFLG		;check for further help
	ORA	A		;0=no
	JRZ	EHLP1
	CALL	CLS
	CALL	ILPRT
	DB	'Chaining to External HELP ...',0
	LXI	H,MOREHELP	;run HELP Command
	CALL	CHAIN		;chain to it
	JMP	LOOPFN
EHLP1:
	CALL	ERMSG
	DB	'External HELP Facility Not Available',0
	JMP	LOOPFN

; refresh screen

SCREFRESH:
	CALL	REFRESH		;do it
	JMP	LOOPFN		;reprint name

; execute ZCPR2 command line

RUNZCPR2:
	CALL	ERMSG
	DB	'ZCPR2 Command Line? ',0
	LXI	H,CRCTBL+256	;use last half of CRC Table
	MVI	M,126		;store length of line
	INX	H
	MVI	M,0		;store count
	LXI	D,CRCTBL+256
	PUSH	D
	MVI	C,RDBUF		;Read Line from User
	CALL	BDOS
	POP	H
	INX	H		;pt to char count
	MOV	E,M
	INX	H		;pt to first char
	MVI	D,0		;set no high-order offset
	PUSH	H		;save current ptr for later
	DAD	D
	MVI	M,0		;store ending zero
	POP	H		;pt to first char of command line
	MOV	A,M		;abort if no first char
	ORA	A
	JZ	NEUTRAL
	CALL	CHAIN		;chain to it
	JMP	LOOPFN		;continue

; chain to command pted to by HL ending in zero

CHAIN:
	LDA	MCAVAIL		;multiple commands available?
	ORA	A		;Z=NO
	JRNZ	CHAIN1
	CALL	ERMSG
	DB	'Chaining Error -- No MCL',0
	RET
CHAIN1:
	PUSH	H
	LHLD	MCADR		;pt to MCL
	XCHG
	LXI	H,4
	DAD	D
	XCHG
	MOV	C,M		;save ptr to next command
	MOV	M,E		;store address of first character
	INX	H
	MOV	B,M
	MOV	M,D
	PUSH	B		;ptr to next command saved
	INX	H		;get buffer size
	MOV	B,M		;...in B
	XCHG			;HL pts to first character
	POP	D		;get ptr to rest of current command
	PUSH	H		;save HL
	LXI	H,CRCTBL	;save command in CRCTBL
CHAIN2:
	LDAX	D		;copy rest of command line for later
	MOV	M,A
	INX	H
	INX	D
	ORA	A
	JRNZ	CHAIN2
	POP	H		;get ptr to beginning of buffer
	POP	D		;DE pts to new command
;
;  Copy Desired Command into MCL
;
	CALL	CHAINC		;copy into command line
;
;  Copy Command to Return to FILER into MCL
;
	PUSH	H		;save ptr to MCL
	PUSH	B		;save B counter
	LDA	C$DR		;get current disk
	ADI	'A'		;convert disk to letter
	STA	FILE$D		;store in proper place
	LDA	C$U$A		;get current user
	LXI	H,FILE$U	;store user number
	MVI	C,'0'		;set char
CHAIN3:
	SUI	10		;convert to ASCII
	JRC	CHAIN4
	INR	C		;increment 10's char
	JR	CHAIN3
CHAIN4:
	MOV	M,C		;store 10's digit char
	INX	H		;pt to 1's digit
	ADI	10+'0'		;add back for 1's digit
	MOV	M,A		;store 1's digit char
	POP	B		;restore B counter
	POP	H		;restore ptr and continue
	LXI	D,FILERCMD	;return to FILER
	CALL	CHAINC		;copy rest
;
;  Copy Rest of Original Command Line into MCL
;
	LXI	D,CRCTBL	;pt to rest of original command line
	CALL	CHAINC		;copy it in
;
;  Close MCL and Run New Command Line
;
	MVI	M,0		;store ending zero
	JMP	CPM$CCP
CHAINC:
	LDAX	D		;copy into MCL
	ORA	A		;done?
	RZ
	DCR	B		;check for buffer overflow
	JRZ	CHAINERR
	MOV	M,A
	INX	D
	INX	H
	JR	CHAINC
CHAINERR:
	POP	D		;clear stack
	CALL	ERMSG
	DB	'Chaining Error -- MCL Overflow',0
	LHLD	MCADR		;clear command line
	LXI	D,4
	DAD	D
	MVI	M,0		;no command left
	RET

; mass tag or untag
MASS$TU:
	MVI	A,TRUE		;update file totals
	STA	FS$FLG		;of tagged/untagged files
	CALL	CPRMPT
	DB	'Mass Tag or Untag (T/U)? ',0
	CALL	KEYIN		;get response
	CPI	'T'
	JRZ	MASS$TAG
	CPI	'U'
	JNZ	NEUTRAL		;fall thru to MASS$UNTAG

; mass   u n t a g

MASS$UNTAG:
	XRA	A		;set tag/untag..
	STA	T$UN$FG		;..flag to untag
	STA	FSDFLG		;no file size display
	CALL	WORKMSG
MUTLOOP:
	LHLD	RINGPOS		;move to tag
	LXI	D,12
	DAD	D
	MOV	A,M		;get tag
	CPI	'*'		;check for tag
	MVI	M,' '		;clear tag
	CZ	FSIZ		;adjust sizes
	LHLD	RINGPOS		;advance to next
	LXI	D,13
	DAD	D
	SHLD	RINGPOS
	XCHG			;done?
	LHLD	LOCEND
	CALL	CMPDEHL
	JRNZ	MUTLOOP
	LXI	H,CURHOME	;reset cursor
	SHLD	CURAT
	LHLD	LOCBEG		;set ring position
	JMP	JFW0

; mass   t a g

MASS$TAG:
	XRA	A
	STA	FSDFLG		;no file size display
	MVI	A,TRUE		;set tag/untag..
	STA	T$UN$FG		;..flag to untag
	CALL	WORKMSG
MTLOOP:
	LHLD	RINGPOS		;move to tag
	LXI	D,12
	DAD	D
	MOV	A,M		;get tag
	CPI	'*'		;check for tag
	MVI	M,'*'		;clear tag
	CNZ	FSIZ		;adjust sizes
	LHLD	RINGPOS		;advance to next
	LXI	D,13
	DAD	D
	SHLD	RINGPOS
	XCHG			;done?
	LHLD	LOCEND
	CALL	CMPDEHL
	JRNZ	MTLOOP
	LXI	H,CURHOME	;reset cursor
	SHLD	CURAT
	LHLD	LOCBEG		;set ring position
	JMP	JFW0

; u n t a g

UNTAG:
	XRA	A		;set tag/untag..
	STA	T$UN$FG		;..flag to untag.
	CMA
	STA	FS$FLG		;set flag to compute file size
	LHLD	RINGPOS		;move back one..
	LXI	D,12		;..character position..
	DAD	D		;..and check tagging status.
	MOV	A,M		;if file previously tagged, remove..
	CPI	'*'		;..size from..
	PUSH	PSW		;save flag
	MVI	M,' '		; (untag character, to next ring position.)
	CALL	REFFN		;refresh file name
	POP	PSW		;get flag
	JRZ	FS2		;..summation.
	JMP	FORWARD
 
; t a g

TAG$EM:
	MVI	A,TRUE		;set..
	STA	T$UN$FG		;..tag/untag and..
	STA	FS$FLG		;..file size flags to tag.
	LHLD	RINGPOS
	LXI	D,12		;move back one..
	DAD	D		;..position..
	MOV	A,M		; (if file
	CPI	'*'		; already tagged, skip
	JZ	FORWARD		; to next file.)
	MVI	M,'*'		;..and store a '*' tag character.
	CALL	REFFN		;refresh file name
	JR	FS2		;get file size

; refresh file name with new tag
REFFN:
	CALL	CLRCUR		;clear cursor
	MVI	A,' '		;one more space
	CALL	TYPE
	LHLD	RINGPOS		;reprint file name
	INX	H
	CALL	PRFN
	MOV	A,M		;print tag
	JMP	TYPE

; f i l e   s i z e

; determine and display file size in kilobytes -- round up to next disk
; allocation block -- accumulate tagged file summation

FIL$SIZ:
	XRA	A		;set file size/tagged..
	STA	FS$FLG		;..file flag to file size.
	CMA
	STA	FSDFLG		;display file size
	CALL	FSIZ		;compute and print file size
	JMP	LOOPFN
FS2:
	MVI	A,TRUE
	STA	FSDFLG		;display file size
	CALL	FSIZ		;compute and print file size
	JMP	FORWARD

;  print file size
FSIZ:
	LDA	FSDFLG		;display file size?
	ORA	A		;0=no
	CNZ	FSNOTE
	CALL	RINGFCB		;move name to 's$fcb'

; determine file record count and save in 'rcnt'

	MVI	C,COMPSZ
	LXI	D,S$FCB
	CALL	BDOS
	LHLD	S$FCB+33
	SHLD	RCNT		;save record count and..
	LXI	H,0
	SHLD	S$FCB+33	;..reset cp/m.

; round up to next disk allocation block

	LDA	B$MASK		;sectors/block - 1
	PUSH	PSW		;save 'blm'
	MOV	L,A
	XCHG
	LHLD	RCNT		;..use here.
	DAD	D		;round up to next block
	MVI	B,3+1		;convert from..
	CALL	SHIFTLP		;..records to kilobytes.
	POP	PSW		;retrieve 'blm'
	RRC			;convert..
	RRC			;..to..
	RRC			;..kilobytes/block.
	ANI	1FH
	CMA			;finish rounding
	ANA	L
	MOV	L,A		;hl-pair contains # of kilobytes
	LDA	FS$FLG
	ORA	A
	JRZ	D$F$SIZ		;branch if 'f' function

; tagged file size summation

	XCHG			;file size to de-pair
	LDA	T$UN$FG
	ORA	A
	JRZ	TAKE		;if untag, take size from total.
	LHLD	TAG$TOT		;accumulate..
	DAD	D		;..sum of..
	SHLD	TAG$TOT		;..tagged file sizes.
	XCHG			;file size to hl-pair
	JR	D$F$SIZ		;branch to display sizes

TAKE:
	LHLD	TAG$TOT		;subtract..
	MOV	A,L		;..file..
	SUB	E		;..size..
	MOV	L,A		;..from..
	MOV	A,H		;..summation..
	SBB	D		;..total.
	MOV	H,A		;then put..
	SHLD	TAG$TOT		; (save total)
	XCHG			;..file size in hl-pair.

; display file size in kilobytes -- right justify tagged file total

D$F$SIZ:
	LDA	FSDFLG		;display file size?
	ORA	A		;0=no
	RZ
	PUSH	H		;save value
	CALL	ATFS		;position for file size print
	LHLD	RINGPOS		;print file name of current file
	INX	H
	CALL	PRFN
	MVI	A,':'
	CALL	TYPE
	POP	H		;get value
	CALL	DECOUT          ;print individual file size
	MVI	A,'K'
	CALL	TYPE

; determine # of digits in tagged summation

	LHLD	TAG$TOT		;get present summation
	CALL	ILPRT
	DB	' Tagged:',0
	CALL	DECOUT          ;print tagged file summation
	MVI	A,'K'
	JMP	TYPE

; j u m p

; backward
JUMPB:
	LXI	H,CURHOME	;set cursor home
	SHLD	CURAT
	LHLD	RING		;at front?
	XCHG
	LHLD	LOCBEG
	CALL	CMPDEHL
	JRZ	JUMPBW		;back up and wrap around
	SHLD	LOCEND		;set new end
	LXI	D,-EPS*13	;back up
	DAD	D
	SHLD	LOCBEG		;new beginning
	SHLD	RINGPOS		;new position
	CALL	REFRESH		;refresh screen
	JMP	LOOPFN
JUMPBW:
	LHLD	LOCBEG		;at first screen?
	XCHG
	LHLD	RING		;pt to first element of ring
	CALL	CMPDEHL
	JRZ	JBW0		;advance to end
	LXI	H,-EPS*13	;back up
	DAD	D
	JR	JFW0
JBW0:
	LXI	D,EPS*13	;pt to next screen
	DAD	D
	XCHG
	LHLD	RINGEND
	CALL	CMPDEHL
	XCHG
	JRZ	JBW1
	JRC	JBW0
JBW1:
	LXI	D,-EPS*13
	DAD	D		;pt to first element of local ring
	JR	JFW0
JUMPF:
	LXI	H,CURHOME	;set cursor to home
	SHLD	CURAT
	LHLD	LOCEND		;see if Local End <= Ring End
	XCHG
	LHLD	RINGEND
	CALL	CMPDEHL
	JRZ	CMDLOOP
	LHLD	LOCEND		;new screen
	JR	JFW0
CMDLOOP:
	LXI	H,CURHOME	;set cursor home
	SHLD	CURAT
	LHLD	RING		;set ring position
JFW0:
	SHLD	RINGPOS
JFW0A:
	SHLD	LOCBEG		;front of ring
	LXI	D,EPS*13	;new end?
	DAD	D
	XCHG
	LHLD	RINGEND		;end of ring
	XCHG
	CALL	CMPDEHL
	JRC	JFW1
	XCHG
JFW1:
	XCHG
	SHLD	LOCEND
	CALL	REFRESH
	JMP	LOOPFN

; f o r w a r d

FORWARD:
	CALL	CLRCUR		;clear cursor
	CALL	FOR0		;position on screen and in ring
	CALL	SETCUR		;set cursor
	JMP	LOOPFN
;  advance routine
FOR0:
	LHLD	RINGPOS		;at end of loop yet?
	LXI	D,13		;i.e., will we be at end of loop?
	DAD	D
	XCHG
	LHLD	LOCEND
	CALL	CMPDEHL		;compare 'present' to 'end'
	JRNZ	FORW		;to next print position
	CALL	CUR$FIRST	;position cursor
	LHLD	LOCBEG		;set position pointer to beginning and..
	SHLD	RINGPOS
	RET
FORW:
	LHLD	RINGPOS		;advance in ring
	LXI	D,13
	DAD	D
	SHLD	RINGPOS		;new position
	CALL	CUR$NEXT	;position cursor
	RET

; r e v e r s e

REVERSE:
	CALL	CLRCUR		;clear cursor
	CALL	REV0		;position on screen and in ring
	CALL	SETCUR		;set cursor
	JMP	LOOPFN
;  Back Up Routine
REV0:
	LHLD	LOCBEG
	XCHG
	LHLD	RINGPOS		;see if at beginning of ring
	CALL	CMPDEHL
	JRNZ	REV1		;skip position pointer reset if not..
	CALL	CUR$LAST	;end of local ring
	LHLD	LOCEND		;set to end +1 to backup to end
	LXI	D,-13
	DAD	D
	SHLD	RINGPOS
	RET
REV1:
	CALL	CUR$BACK	;back up 1
REV2:
	LHLD	RINGPOS
	LXI	D,-13		;one ring position..
	DAD	D		;..backwards.
	SHLD	RINGPOS
	RET

; u p

UP:
	CALL	CLRCUR		;clear cursor
	LHLD	RINGPOS		;see if wrap around
	LXI	D,-13*4		;4 entries
	DAD	D
	XCHG
	LHLD	LOCBEG		;beginning of local screen
	CALL	CMPDEHL
	JRC	UP2		;wrap around
	MVI	B,4		;back up 4 entries
UP1:
	PUSH	B		;save count
	CALL	REV0		;back up in ring and on screen (no print)
	POP	B		;get count
	DJNZ	UP1
	JR	DOWN1A
UP2:
	LHLD	RINGPOS		;advance to beyond end
	LXI	D,13*4
	DAD	D
	XCHG
	LHLD	LOCEND		;compare to local end
	XCHG
	CALL	CMPDEHL
	JRZ	DOWN1A		;at end, so too far
	JRC	DOWN1A		;beyond end, so back up
	SHLD	RINGPOS		;new ring position
	LHLD	CURAT		;advance cursor
	INR	H		;next line
	SHLD	CURAT
	JR	UP2

; d o w n

DOWN:
	CALL	CLRCUR		;clear cursor
	LHLD	RINGPOS		;see if wrap around
	LXI	D,13*4		;4 entries
	DAD	D
	XCHG
	LHLD	LOCEND		;end of local screen
	XCHG
	CALL	CMPDEHL
	JRZ	DOWN2		;wrap around
	JRC	DOWN2		;wrap around
	MVI	B,4		;forward 4 entries
DOWN1:
	PUSH	B		;save count
	CALL	FOR0		;advance in ring and on screen (no print)
	POP	B		;get count
	DJNZ	DOWN1
DOWN1A:
	CALL	SETCUR		;set cursor
	JMP	LOOPFN
DOWN2:
	LHLD	CURAT		;preserve column
	MOV	B,L		;column number in B
	LXI	H,CURHOME	;home position
	SHLD	CURAT		;set new position
	LHLD	LOCBEG		;beginning of local ring
	SHLD	RINGPOS		;new ring position
DOWN3:
	LHLD	CURAT		;check for at top of column
	MOV	A,L		;get col
	CMP	B		;there?
	JRZ	DOWN1A
	LHLD	RINGPOS		;advance in ring
	LXI	D,13		;13 bytes/entry
	DAD	D
	SHLD	RINGPOS
	LHLD	CURAT		;get cursor position
	LXI	D,19		;advance 19 bytes/screen entry
	DAD	D
	SHLD	CURAT
	JR	DOWN3

; s t a t

; determine remaining storage on requested disk

R$DR$ST:
	CALL	CPRMPT
	DB	'Status of Disk: ',0
	CALL	KEYIN		;get char
	PUSH	PSW
	CALL	CRLF
	POP	PSW
	SUI	'A'		;convert to number
	JC	NEUTRAL
	MOV	B,A		;... in B
	LDA	MAXDR		;compare to max
	SUI	'A'
	CMP	B
	JC	LOOPFN
	MOV	A,B		;get disk
	STA	R$DR		;requested drive
	CALL	RESET		;..login as current.
	CALL	FRESTOR		;determine free space remaining
	CALL	PRINT$FRE	;print value
	LDA	C$DR		;login original as..
	CALL	SET$DR		;..current drive.
; compute file count
	LXI	H,0		;set count
	SHLD	LOCPOS		;dummy area
	LHLD	RING		;pt to ring
R$DR1:
	XCHG			;position in DE
	LHLD	RINGEND
	CALL	CMPDEHL		;at end of ring?
	JRZ	R$DR2
	LHLD	LOCPOS		;increment count
	INX	H
	SHLD	LOCPOS
	LXI	H,13		;advance to next ring element
	DAD	D		;HL pts to next
	JR	R$DR1
R$DR2:
	LHLD	LOCPOS		;get count
	CALL	DECOUT		;print count
	CALL	ILPRT
	DB	' Files in DIR',0
	JMP	LOOPFN

; d e l e t e

; mass delete

MASS$DEL:
	CALL	CPRMPT
	DB	'Mass Delete (Y/N/V=Verify Each)? ',0
	CALL	KEYIN		;get response
	CPI	'Y'
	JRZ	MD1
	CPI	'V'
	JNZ	NEUTRAL		;return to position
MD1:
	STA	MDFLG		;set flag
	XRA	A		;set for mass delete
	STA	MFLAG
	LHLD	RING
	SHLD	RINGPOS		;set ring position
MD$LP:
	LHLD	RINGPOS		;get current position
	LXI	D,12		;pt to tag
	DAD	D
	MOV	A,M		;get tag
	CPI	'*'
	JRNZ	MD$LOOP
	CALL	RINGFCB		;set up file name
	LDA	MDFLG		;verify?
	CPI	'V'
	JRZ	MDEL1		;delete with verify
	JR	DEL1		;delete without verify
MD$LOOP:
	LHLD	RINGPOS		;re-entry point for next file mass-copy
	LXI	D,13		;advance to next
	DAD	D
	SHLD	RINGPOS
MD1$LOOP:
	XCHG			;at ring..
	LHLD	RINGEND		;..end yet?
	CALL	CMPDEHL		; (compare present position with end)
	JRNZ	MD$LP		;no, loop 'till thru ring list.

MD$EXIT:
	MVI	A,TRUE		;set no
	STA	MFLAG		;..mass-delete request.
	JMP	CMDLOOP		;jump to 'ring' beginning


; set up to delete filename at cursor position

DELETE:
	MVI	A,TRUE		;set for no mass delete
	STA	MFLAG
	STA	MDFLG
MDELETE:
	CALL	RINGFCB		;move file name
MDEL1:
	CALL	CPRMPT
	DB	'Delete ',0
	CALL	PRFNS		;print file name in S$FCB
	CALL	ILPRT
	DB	' (Y/N)? ',0
	CALL	KEYIN
	CPI	'Y'
	JRZ	DEL1
	LDA	MFLAG		;mass delete?
	ORA	A
	JRZ	MD$LOOP
MDEL2:
	LHLD	LOCEND		;move in end
	LXI	D,-13
	DAD	D
	SHLD	LOCEND
	XCHG
	LHLD	RINGPOS		;position beyond end of ring?
	CALL	CMPDEHL
	JRNZ	MDEL3
	CALL	CUR$BACK	;back up cursor
	LHLD	LOCEND		;reset position
	LXI	D,-13
	DAD	D
	SHLD	RINGPOS
	LHLD	LOCEND		;get end
	XCHG
MDEL3:
	LHLD	LOCBEG		;erased all local files?
	CALL	CMPDEHL
	JZ	CMDLOOP		;reset
	JMP	JFW0A		;rescreen

; delete file

DEL1:
	LDA	MDFLG		;Y option on Mass Delete?
	CPI	'Y'
	JRNZ	DEL1A
	CALL	ERMSG
	DB	'Deleting File ',0
	CALL	PRFNS
DEL1A:
	LXI	H,S$FCB		;set file to R/W
	CALL	ATTRIB
	LXI	D,S$FCB		;point at delete 'fcb'
	MVI	C,ERASE		;erase function
	CALL	BDOS
	INR	A
	JRZ	FNF$MSG		;print error message
	CALL	DEL2		;close up erased position
	LDA	MFLAG		;check for mass delete
	ORA	A
	JRNZ	MDEL2
	LHLD	RINGPOS		;no advance because of close up
	JMP	MD1$LOOP
FNF$MSG:
	CALL	ERMSG		;show error message
	DB	'No File Found',0
	JMP	LOOPFN

; reverse ring to close up erased position

DEL2:
	LHLD	RINGPOS		;prepare move up pointers
	PUSH	H
	LXI	D,13		;13 bytes/entry
	DAD	D		;de-pair = 'to' location
	POP	D		;hl-pair = 'from' location
MOVUP:
	XCHG
	PUSH	H		;check if at end
	LHLD	RINGEND		;get old end pointer
	CALL	CMPDEHL		;check against current end location
	POP	H
	XCHG
	JRZ	MOVDONE		;must be at end of ring
	MVI	B,13		;one name size
	CALL	MOVE		;move one name up
	JR	MOVUP		;go check end parameters

MOVDONE:
	LHLD	RING		;see if ring is empty
	XCHG
	SHLD	RINGEND		;set new ring end if all moved
	CALL	CMPDEHL		;..(listend --> listpos --> ring)
	RNZ
	LHLD	RINGPOS
	CALL	CMPDEHL
	RNZ			;neither equal so not empty
	LXI	SP,STACK	;reset stack
	CALL	ERMSG
	DB	'List Empty',0
	JMP	LOG		;go to drive/user area with files

; r e n a m e

; set-up to rename file at cursor position -- scan keyboard buffer and
; move filename to 'rename' destination 'fcb' (dfcb)

RENAME:
	LHLD	RINGPOS		;move name from ring to rename 'fcb'
	LXI	D,D$FCB		;place to move name
	MVI	B,12		;amount to move
	CALL	MOVE
	CALL	CPRMPT		;new name prompt
	DB	'Rename File to: ',0
	LXI	D,D$FCB+16	;pt to FCB to fill
	CALL	FILENAME	;get file name
	LXI	H,D$FCB+1	;check for any wild cards -- none permitted
	MVI	B,11		;11 bytes
WILDCHK:
	MOV	A,M		;get char
	INX	H		;pt to next
	CPI	'?'		;wild?
	JRZ	WILDFND
	DJNZ	WILDCHK

; copy old file status bit ($r/o or $sys) to new filename

CPYBITS:
	LXI	D,D$FCB+1	;first character of old name..
	LXI	H,D$FCB+17	;..and of new name.
	MVI	B,11		; # of bytes with tag bits
CBITS1:
	LDAX	D		;fetch bit of old name character
	ANI	128		;strip upper bit and..
	MOV	C,A		;..save in b-reg.
	MVI	A,7FH		;mask for character only
	ANA	M		;put masked character into a-reg
	ORA	C		;add old bit
	MOV	M,A		;copy new byte back
	INX	H		;bump copy pointers
	INX	D
	DJNZ	CBITS1

; check if new filename already exists.  if so, say so.  then go
; to command loop without moving ring position

	LDA	D$FCB		;copy new name to source 'fcb'
	STA	S$FCB
	MVI	B,11
	LXI	H,D$FCB+17	;copy new name to..
	LXI	D,S$FCB+1	;..source 'fcb' for existence check.
	CALL	MOVE
	LXI	H,S$FCB+12	;clear cp/m 'fcb' system..
	CALL	INITFCB		;..fields.
	LXI	D,S$FCB		;search to see if this file exists
	MVI	C,SRCHF		;search first function
	CALL	BDOS
	INR	A		; 0ffh --> 00h if file not found
	JRZ	RENFILE		;to rename, if duplicate doesn't exists.
	CALL	ERMSG		;announce the situation
	DB	'File Already Exists',0
	JMP	COMCAN		;try again?

; wild char found in file name -- error

WILDFND:
	CALL	ERMSG
	DB	'Ambiguous File Name NOT Allowed',0
	JMP	COMCAN

; copy new name into ring position

RENFILE:
	LHLD	RINGPOS		;get ring position pointer
	INX	H		;pt to name
	PUSH	H		;save ptr
	XCHG
	LXI	H,D$FCB+17	;point at new name and..
	MVI	B,11
	CALL	MOVE		;..move.
	LHLD	CURAT		;get current position on screen
	LXI	D,4		;advance 4 chars
	DAD	D
	CALL	GOTOXY
	POP	H		;get ptr
	CALL	PRFN		;print file name
	MOV	A,M		;print tag
	CALL	TYPE
	LXI	D,D$FCB		;rename 'fcb' location
	MVI	C,REN		;rename function
	CALL	BDOS
	INR	A		; 0ffh --> 00h if rename error
	JNZ	NEUTRAL		;if okay, proceed, else..
	JMP	FNF$MSG		;..show no-file msg.

; get file name from user and process into FCB pted to by DE
FILENAME:
	PUSH	D		;save ptr
	LXI	D,CMDBUF	;command line location
	MVI	C,RDBUF		;console read-buffer function
	CALL	BDOS
	CALL	CONVERT		;capitalize alpha
	POP	H		;set to null drive
	MVI	M,0		;..required by 'bdos'.
	INX	H

; initialize new filename field with spaces

	PUSH	H		;save start pointer
	MVI	B,11		; # of spaces to 'blank'
	CALL	FILL
	POP	H
	XCHG
	LXI	H,CMDBUF+1	;put length..
	MOV	C,M		;..in c-reg.
	INX	H
	XCHG			;de-pair --> buffer pointer and hl-pair..
	CALL	UNSPACE		;..--> 'fcb' pointer.  remove leading spaces.

; extend buffer to spaces beyond command length

EXTEND:
	PUSH	H
	MOV	L,C		;double-byte remaining length
	MVI	H,0
	DAD	D		;to buffer end +1
	MVI	M,' '		;force illegal character end
	POP	H

; start filename scan

SCAN:
	MVI	B,8		; 8 characters in filename
SCAN1:
	CALL	CKLEGAL		;get and see if legal character
	JC	COMCAN		;all of command line?
	CPI	' '		;see if end of parameter field
	RZ			;rename file
	CPI	'.'		;at end of filename
	JRZ	SCAN2		;process filetype field
	CPI	'*'		;rest wild?
	JRZ	SCAN1B
	MOV	M,A		;put character into destination 'fcb'
	INX	H
	DJNZ	SCAN1

; entry if eight characters without a 'period'

SCAN1A:
	CALL	CKLEGAL		;scan buffer up to period or end
	RC			;no extent if not legal
	CPI	' '		;end of parameter field?
	RZ
	CPI	'.'
	JRNZ	SCAN1A		;do till end or period
	JR	SCAN2A		;continue at correct place

; make rest of entry wild

SCAN1B:
	MVI	M,'?'		;fill with ?'s
	INX	H
	DJNZ	SCAN1B
	LDAX	D		;get next char
	INX	D		;pt to after dot
	CPI	'.'		;must be dot
	JNZ	COMCAN		;cancel if not
	JR	SCAN2A

; build filetype field

SCAN2:
	INX	H		;advance ptr to file type field
	DJNZ	SCAN2
SCAN2A:
	MVI	B,3		;length of filetype field
SCAN3:
	CALL	CKLEGAL		;get and check character
	JRC	SCAN4		;name done if illegal
	CPI	' '		;end of parameter field?
	JRZ	SCAN4
	CPI	'.'		;check if another period
	JRZ	SCAN4
	CPI	'*'		;rest wild?
	JRZ	SCAN4B
	MOV	M,A
	INX	H
	DJNZ	SCAN3		;get next character
	JR	SCAN4A
SCAN4:
	INX	H		;advance to end of type field
	DJNZ	SCAN4
SCAN4A:
	CALL	INITFCB		;..and zero counter fields.
	RET
SCAN4B:
	MVI	M,'?'		;make wild
	INX	H
	DJNZ	SCAN4B
	JR	SCAN4A		;complete rest

; goto file

GOTO:
	CALL	CPRMPT
	DB	'Goto Filename: ',0
	LXI	D,D$FCB		;pt to FCB
	CALL	FILENAME	;get file name
	LHLD	RING		;pt to first element of ring
	SHLD	RINGPOS		;set position
	SHLD	LOCBEG		;set local beginning
	XRA	A		;set local counter
	STA	CRCTBL		;use this buffer
GOTOL:
	CALL	GOTOCOMP	;compare
	JRZ	GOTOF		;we are there
	LDA	CRCTBL		;increment count
	INR	A
	STA	CRCTBL
	CPI	EPS
	JRNZ	GOTOL1
	XRA	A		;reset count
	STA	CRCTBL
	LHLD	LOCBEG		;reset local beginning
	LXI	D,EPS*13
	DAD	D
	SHLD	LOCBEG
GOTOL1:
	LHLD	RINGPOS		;advance to next entry
	LXI	D,13
	DAD	D
	SHLD	RINGPOS		;new position
	XCHG			;position in DE
	LHLD	RINGEND		;check for completion
	CALL	CMPDEHL		;compare current position with end of ring
	JRNZ	GOTOL
	LHLD	RING		;pt to first element
	SHLD	RINGPOS		;set position
	CALL	ERMSG
	DB	'File NOT Found',0
	JMP	CMDLOOP
GOTOF:
	LHLD	LOCBEG		;we have local beginning
	PUSH	H
	XCHG			;ring location in DE
	LXI	H,CURHOME	;set cursor ptr
	SHLD	CURAT
GOTOF0:
	LHLD	RINGPOS		;at position?
	CALL	CMPDEHL
	JRZ	GOTOF1
	LXI	H,13		;advance location
	DAD	D
	PUSH	H
	CALL	CUR$NEXT	;advance cursor
	POP	D		;pt to next ring position
	JR	GOTOF0
GOTOF1:
	POP	H		;pt to local ring
	JMP	JFW0A		;process
GOTOCOMP:
	LHLD	RINGPOS		;pt to current entry
	INX	H		;pt to first char of file name
	LXI	D,D$FCB+1	;pt to first char of new file
	MVI	B,11		;11 bytes
GOTOC1:
	LDAX	D		;get char
	CPI	'?'		;match?
	JRZ	GOTOC2
	CMP	M		;match?
	RNZ			;no match
GOTOC2:
	INX	D		;pt to next
	INX	H
	DJNZ	GOTOC1
	RET

; v i e w

; type file to console with pagination set to 'lps' -- single-line scroll
; using <space> bar , <ctrl-x> to cancel, any other key to page screen.

VIEW:
	CALL	CLS
	CALL	ILPRT
	DB	CR,LF,'<CTRL-C> Cancels, <SP> Turns Up One Line, '
	DB	'Other Keys Page Screen',CR,LF,LF,0
	MVI	A,1		;initialize..
	STA	LPSCNT		;..lines-per-screen counter.
	STA	VIEWFLG		; 'view' paginate if not zero
	MVI	A,WRCON		;write console out function
	JR	CURRENT		;to common i/o processing

; p r i n t e r

; send file to logical list device -- any keypress cancels

LSTFILE:
	CALL	CPRMPT
	DB	'Print on LST Device (Y/N)? ',0
	CALL	KEYIN		;get response
	CPI	'Y'
	JNZ	NEUTRAL
	CALL	ERMSG
	DB	'Printing ',0
	LHLD	RINGPOS		;pt to file name
	INX	H
	CALL	PRFN		;print it
	MVI	A,1		;one for..
	STA	VIEWFLG		;..output to printer.
	DCR	A		;zero for..
	STA	LPSCNT		;..lines-per-page counter
	MVI	A,LIST		;out to 'list' device function and fall thru

; output character for console/list/punch processing

CURRENT:
	STA	CON$LST		;save bdos function

; output file to console/printer/punch

	CALL	RINGFCB		;position name to 'fcb'
	XCHG			;HL pts to S$FCB
	CALL	INITFCB		;set 'fcb' for use
	LXI	D,TBUF		;set to use default cp/m dma buffer
	MVI	C,SETDMA	;address set function
	CALL	BDOS
	LXI	D,S$FCB		;open file for reading
	MVI	C,OPEN		;file open function code
	CALL	BDOS
	INR	A		; 0ffh --> 00h if open not okay
	JRNZ	ZEROCR		;if not okay, show error message.
	CALL	ERMSG
	DB	'Unable to Open File',0
	JMP	NEUTRAL

ZEROCR:
	XRA	A
	STA	S$FCB+32	;zero file 'current record' field
	STA	CHARCNT		;zero char count for tabbing
	CALL	PHEAD		;print heading if output to LST device
READMR:
	LXI	D,S$FCB		;point at file 'fcb' for reading
	MVI	C,READ		;record read function
	CALL	BDOS
	ORA	A		;check if read okay
	JRNZ	CURDONE		;eof?
	LXI	H,TBUF		;point at record just read
	MVI	B,128		;set record character counter to output
READLP:
	MOV	A,M		;get a character
	ANI	7FH		;force to 'ascii'
	CPI	EOFCHAR		;see if end-of-file
	JRZ	CURDONE		;back to ring loop if 'eof'
	MOV	E,A		;put character for 'bdos' call
	PUSH	B
	PUSH	H
	PUSH	D		; (character in e-reg)
	LDA	CON$LST		;get function for punch/list/console output
	MOV	C,A
	MOV	A,E		;check char
	CPI	TAB		;tabulate?
	JRNZ	NOTAB
	MVI	E,' '		;space over
TABL:
	PUSH	B		;save key regs
	PUSH	D
	CALL	BDOS
	POP	D		;get key regs
	POP	B
	CALL	INCCCNT		;increment char count
	ANI	7		;check for done at every 8
	JRNZ	TABL
	JR	TABDN
NOTAB:
	CALL	BDOS		;send character
	CALL	INCCCNT		;increment char count
TABDN:
	LDA	VIEWFLG		;if 'view'..
	ORA	A
	POP	D		;get char in E in case PAGER is called
	CNZ	PAGER		;..check for 'lf'.
	MVI	E,GET		;get status or char
	MVI	C,DIRCON	;console status function
	CALL	BDOS		;status?
	POP	H
	POP	B
	ANI	7FH		;if character there, then abort..
	CNZ	CANVIEW		;already got char
	INX	H		;if not, bump buffer pointer.
	DJNZ	READLP		;no, more in present record.
	JR	READMR		;yes, get next record.
CURDONE:
	LDA	CON$LST		;console?
	CPI	WRCON
	CZ	BOTTOM		;prompt for user
	CALL	REFRESH		;refresh screen
	JMP	LOOPFN
PAGER:
	MOV	A,E		; (character in e-reg)
	CPI	LF
	RNZ
	XRA	A		;zero char count
	STA	CHARCNT
	LDA	CON$LST		;printer or console?
	CPI	LIST		;check for printer
	JRZ	PAGEP
	LDA	CTPP		;get number of lines of text per screen
	MOV	B,A		;... in B
	LDA	LPSCNT		;is counter..
	INR	A		;..at..
	STA	LPSCNT		;..limit..
	CMP	B		;..of lines-per-screen?
	RC			;no, return.
	XRA	A		;yes, initialize..
	STA	LPSCNT		;..for next screen full.
	CALL	ILPRT
	DB	'  [View More...]',CR,0	;show msg line
	CALL	DKEYIN		;wait for keyboard input
	CPI	' '		;see if <space> bar..
	PUSH	PSW
	CALL	ILPRT
	DB	'                ',CR,0	;clear above msg line
	POP	PSW
	JRNZ	CANVIEW		;..if not, see if cancel.
	LDA	CTPP		;set for single line
	DCR	A
	STA	LPSCNT		;..scroll and..
	RET			;..return for one more line.

PAGEP:
	LDA	LTPP		;get number of lines of text per page
	MOV	B,A		;... in B
	LDA	LPSCNT		;is counter..
	INR	A		;..at..
	STA	LPSCNT		;..limit..
	CMP	B		;..of lines-per-screen?
	RC			;no, return.
	XRA	A		;zero for..
	STA	LPSCNT		;..lines-per-page counter
	LDA	LSPP		;number of lines to skip
	MOV	B,A		;number of lines to skip
	MVI	C,LIST		;LST output
PAGELST:
	CALL	LCRLF		;new line on LST
	DJNZ	PAGELST
	CALL	PHEAD		;print heading
	RET			;done!

CANVIEW:
	CPI	CTRLC		;^C?
	JZ	COMCAN
	RET			;return for another page

INCCCNT:
	LDA	CHARCNT		;increment char count
	INR	A
	STA	CHARCNT
	RET

PHEAD:
	LDA	CON$LST		;printing to printer?
	CPI	LIST
	RNZ
	LXI	H,HEADMSG	;print heading
PHEAD1:
	MOV	A,M		;get char
	ORA	A		;done?
	JRZ	PHEAD2
	CALL	LOUT		;send to printer
	INX	H		;pt to next
	JR	PHEAD1
PHEAD2:
	LXI	H,S$FCB+1	;pt to file name
	MVI	B,8		;8 chars
	CALL	PHEAD3
	MVI	A,'.'		;dot
	CALL	LOUT
	MVI	B,3		;3 more chars
	CALL	PHEAD3
	CALL	LCRLF		;new line
	CALL	LCRLF		;blank line
	RET
PHEAD3:
	MOV	A,M		;get char
	CALL	LOUT		;LST it
	INX	H		;pt to next
	DJNZ	PHEAD3
	RET

; m a s s   c o p y

; copy files tagged using the 't' command.  auto-erase if file exists
; on requested destination drive or in user area.

MASS$COPY:
	CALL	ERMSG
	DB	'Mass Copy',0
	LHLD	RINGPOS		;save position
	SHLD	SRINGPOS
	LHLD	RING
	SHLD	RINGPOS		;set position
MASS$LP:
	LHLD	RINGPOS		;get position
	LXI	D,12		;get 1st possible tag location
	DAD	D
	MOV	A,M		;get tag
	CPI	'*'
	JRZ	MCOPY		;copy filename with tag character (*)
M$LP:
	LHLD	RINGPOS		;re-entry point for next file mass-copy
	LXI	D,13		;advance to next
	DAD	D
	SHLD	RINGPOS
	XCHG			;at ring..
	LHLD	RINGEND		;..end yet?
	CALL	CMPDEHL		; (compare present position with end)
	JRNZ	MASS$LP		;loop 'till thru ring list.

MF$EXIT:
	XRA	A		;reset flags..
	STA	FIRST$M		;..for..
	CMA			;..next..
	STA	MFLAG		;..mass-copy request.
	LHLD	SRINGPOS	;reset ring position
	SHLD	RINGPOS
	LHLD	LOCBEG		;local ring
	JMP	JFW0A		;rescreen

; c o p y

; copy source file at current 'ring' position to another drive.  set-up
; fcb's and buffer area and check for correct keyboard inputs.  contains
; auto-crc file copy verification.

MCOPY:
	XRA	A		;zero flag to..
	STA	MFLAG		;..mass copy.
COPY:
	LXI	H,0		;initialize storage for..
	SHLD	CRCVAL		;..'crc' working value.
	CALL	RINGFCB		;move from 'ring' to 'sfcb'
	LXI	H,S$FCB+12	;set pointer to source extent field
	CALL	INITFCB
	XRA	A		;zero fcb 'cr' field
	STA	S$FCB+32
	MVI	B,32		;copy source 'fcb' to destination 'fcb'
	LXI	H,S$FCB+1	;from point..
	LXI	D,D$FCB+1	;..to point..
	CALL	MOVE		;..move across.
	LXI	D,S$FCB		;open file for reading
	MVI	C,OPEN		;open function
	CALL	BDOS
	INR	A		; 0ffh --> 00h if bad open
	JRNZ	COPY2		;if okay, skip error message.
	CALL	ERMSG
	DB	'Unable to Open Source',0
	JMP	NEUTRAL

COPY2:
	LDA	FIRST$M		;by-pass prompt, drive/user compatibility..
	ORA	A		;..test, and disk reset after..
	JRNZ	COPY3M		;..1st time thru in mass-copy mode.
	CALL	CPRMPT		;prompt for drive selection
	DB	'Copy to DIR: ',0
	CALL	DEF$D$U

; either drives or user areas must be different

	LDA	DOK		;OK to change drive?
	ORA	A
	JRNZ	CDOK
	LDA	S$FCB		;make source and destination the same
	STA	FCB
CDOK:
	LDA	UOK		;OK to change user?
	ORA	A
	JRNZ	CUOK
	LDA	C$U$A		;make current user and requested the same
	STA	R$U$A
CUOK:
	LDA	FCB		;get requested drive from 'fcb' and..
	MOV	B,A		;..put into b-reg for..
	LDA	S$FCB		;..comparison.
	CMP	B
	JRNZ	COPY3		;branch if different
	LDA	R$U$A		;requested user area --> rua
	MOV	B,A
	LDA	C$U$A		;current user area --> cua
	CMP	B
	JRNZ	COPY3
	CALL	ERMSG		;if not, show error condition:
	DB	'Drives or User Areas must be different',0
	JMP	NEUTRAL		;try again?

COPY3:
	CALL	RESET		;make sure disk is read/write
COPY3M:
	LDA	FCB		;put requested drive into..
	STA	D$FCB		;..place in destination fcb.
	LDA	R$U$A		;toggle to..
	CALL	SET$USR		;..requested user area.
	LXI	D,D$FCB		;search for duplicate
	MVI	C,SRCHF		; 'search first' function
	CALL	BDOS
	INR	A		;if not found, 0ffh --> 00h.  then..
	JRZ	COPY5		;go to 'make' function for new file.
	LDA	MFLAG		;auto-erase..
	ORA	A		;..if..
	JRZ	COPY4M		;..in mass-copy mode.
	CALL	ERMSG		;CPR2 - if found, ask to replace:
	DB	'Copy Exists -- Erase (Y/N)? ',0
	CALL	KEYIN		;get answer
	CPI	'Y'		;if yes, then..
	JRZ	COPY4M		;..delete and overlay.
	LDA	C$U$A		;reset to..
	CALL	SET$USR		;..current user area.
	JMP	FORWARD		;if re-copy not wanted, to next position.

COPY4M:
	LXI	H,D$FCB		;pt to FCB
	CALL	ATTRIB		;clear bytes in FCB and set attr of file
	LXI	D,D$FCB		;delete file already existing
	MVI	C,ERASE		;erase function
	CALL	BDOS
COPY5:
	LXI	D,D$FCB		;create new file and open for writing
	MVI	C,MAKE		;make function
	CALL	BDOS
	INR	A		;if directory full, 0ffh --> 00h.
	JRNZ	COPY6		;if not, branch.
	CALL	ERMSG
	DB	'Destination Directory Full',0
	JMP	LOOPFN		;if error, back to ring processor.

COPY6:
	CALL	ERMSG
	DB	'Copying File ',0
	LXI	H,D$FCB+1	;print file name
	CALL	PRFNSX
	XRA	A		;clear 'eof'..
	STA	EOFLAG		;..flag.
COPY6A:
	LDA	C$U$A		;reset user area..
	CALL	SET$USR		;..to current.
	LXI	H,0		;clear current-record..
	SHLD	REC$CNT		;..counter.
	LHLD	BUFSTART	;set buffer start pointer..
	SHLD	BUF$PT		;..to begin pointer.

; read source file -- fill buffer memory or stop on 'eof' -- update 'crc'
; on-the-fly

COPY7:
	LHLD	BUF$PT		;set dma address to buffer pointer
	XCHG			; de-pair --> dma address
	MVI	C,SETDMA
	CALL	BDOS
	LXI	D,S$FCB		;source 'fcb' for reading
	MVI	C,READ		;record read function
	CALL	BDOS
	ORA	A		; 00h --> read okay
	JRZ	S$RD$OK
	DCR	A		;eof?
	JRZ	COPY8		;yes, end-of-file, set 'eof' flag.
	CALL	ERMSG
	DB	'Source Read Error',0
	JMP	LOOPFN

S$RD$OK:
	LHLD	BUF$PT
	MVI	B,128
COPY7A:
	MOV	A,M		;get character and..
	CALL	UPDCRC		;..add to 'crc' value.
	INX	H
	DCR	B
	JRNZ	COPY7A		;loop 'till record read finished
	LHLD	BUF$PT		;bump buffer pointer..
	LXI	D,128		;..by..
	DAD	D		;..one..
	SHLD	BUF$PT		;..record.
	LHLD	REC$CNT		;bump buffer..
	INX	H		;..record count and..
	SHLD	REC$CNT		;..store.
	XCHG			;ready to compare to..
	LHLD	REC$MAX		;..maximum record count (full-buffer).
	CALL	CMPDEHL		;compare
	JRNZ	COPY7    	;if not full, get next record.
	JR	COPY9		;full, start first write session.

; indicate end-of-file read

COPY8:
	MVI	A,TRUE		;set 'eof' flag
	STA	EOFLAG

; write 'read-file' from memory buffer to destination 'written-file'

COPY9:
	LDA	R$U$A		;set user to requested..
	CALL	SET$USR		;..area.
	LHLD	BUFSTART	;adjust buffer pointer..
	SHLD	BUF$PT		;..to start address.
COPY10:
	LHLD	REC$CNT		;buffer empty?
	MOV	A,H
	ORA	L
	JRZ	COPY11		;buffer empty, check 'eof' flag.
	DCX	H		;dec buffer record count for each write
	SHLD	REC$CNT
	LHLD	BUF$PT		;set up dma address
	PUSH	H		;save for size bump
	XCHG			;pointer in de-pair
	MVI	C,SETDMA
	CALL	BDOS
	POP	H
	LXI	D,128		;bump pointer one record length
	DAD	D
	SHLD	BUF$PT
	LXI	D,D$FCB		;destination file 'fcb'
	MVI	C,WRITE		;write record function
	CALL	BDOS
	ORA	A   		; 00h --> write okay
	JRZ	COPY10		;okay, do next record.  else..
	CALL	ERMSG		;..say disk write error.
	DB	'Copy Disk Full',0
C$ERA:
	LXI	D,D$FCB		;delete..
	MVI	C,ERASE		;..partial..
	CALL	BDOS		;..from directory.
	XRA	A      		;reset 1st-time-thru tag flag..
	STA	FIRST$M		;..for continuation of mass copying.
	JMP	LOOPFN		;back to ring

COPY11:
	LDA	EOFLAG		;buffer all written, check for 'eof'.
	ORA	A
	JZ	COPY6A		;branch to read next buffer full
	LXI	D,D$FCB		;point at 'fcb' for file closure
	MVI	C,CLOSE
	CALL	BDOS
	INR	A		;if no-close-error then..
	JRNZ	CRC$CMP		;..compare file crc's.
	CALL	ERMSG
	DB	'Copy Close Error',0
	JMP	C$ERA

; read destination 'written-file' and compare crc's

CRC$CMP:
	LHLD	CRCVAL		;transfer 'crc' value to..
	SHLD	CRCVAL2		;..new storage area.
	LXI	H,0		;clear working storage..
	SHLD	CRCVAL		;..to continue.
	LXI	D,TBUF
	MVI	C,SETDMA
	CALL	BDOS
	LXI	H,D$FCB+12
	CALL	INITFCB
	LXI	D,D$FCB
	MVI	C,OPEN
	CALL	BDOS
	INR	A		; 0ffh --> 00h if bad open
	JZ	BADCRC		;if bad open, just say 'bad-crc'.
	XRA	A		;zero 'fcb'..
	STA	D$FCB+32	;..'cr' field.
CRCWF1:
	LXI	D,D$FCB
	MVI	C,READ
	CALL	BDOS
	ORA	A		;read okay?
	JRZ	D$RD$OK		;yes, read more.
	DCR	A		;eof?
	JZ	FINCRC		;yes, finish up and make 'crc' comparison.
	CALL	ERMSG
	DB	'Copy Read Error',0
	JMP	NEUTRAL

D$RD$OK:
	LXI	H,TBUF
	MVI	B,128
CRCWF2:
	MOV	A,M		;get character to..
	CALL	UPDCRC		;..add to 'crc' value. 
	INX	H
	DJNZ	CRCWF2
	JR	CRCWF1

; clear attributes of file (HL) and set attributes on disk
ATTRIB:
	PUSH	H		;save ptr
	INX	H		;pt to first char
	MVI	B,11		;11 Bytes
ATTRIB1:
	MOV	A,M		;get byte
	ANI	7FH		;mask it
	MOV	M,A		;put byte
	INX	H		;pt to next
	DCR	B		;count down
	JNZ	ATTRIB1
	POP	D		;pt to FCB
	MVI	C,ATTR
	JMP	BDOS

; crc subroutines

; initialize tables for fast crc calculations

INITCRC:
	LXI	H,CRCTBL
	MVI	C,0		;table index
GLOOP:
	XCHG
	LXI	H,0		;initialize crc register pair
	MOV	A,C
	PUSH	B		;save index in c-reg
	MVI	B,8
	XRA	H
	MOV	H,A
LLOOP:
	DAD	H
	JRNC	LSKIP
	MVI	A,10H		;generator is x^16 + x^12 + x^5 + x^0 as..
	XRA	H		;..recommended by ccitt for asynchronous..
	MOV	H,A		;..communications.  produces the same..
	MVI	A,21H		;..results as public domain programs..
	XRA	L		;..chek, comm7, mdm7, and modem7.
	MOV	L,A
LSKIP:
	DJNZ	LLOOP
	POP	B
	XCHG			;de-pair now has crc, hl pointing into table.
	MOV	M,D		;store high byte of crc..
	INR	H
	MOV	M,E		;..and store low byte.
	DCR	H
	INX	H		;move to next table entry
	INR	C		;next index
	JRNZ	GLOOP
	RET

UPDCRC:
	PUSH	B		;update 'crc'..
	PUSH	H		;..accumulator..
	LHLD	CRCVAL		;pick up partial remainder
	XCHG			;de-pair now has partial
	MVI	B,0
	XRA	D
	MOV	C,A
	LXI	H,CRCTBL
	DAD	B
	MOV	A,M
	XRA	E
	MOV	D,A
	INR	H
	MOV	E,M
	XCHG
	SHLD	CRCVAL
	POP	H
	POP	B
	RET

FINCRC:
	LDA	C$U$A		;reset user from 'requested'..
	CALL	SET$USR		;..to 'current' area.
	LHLD	CRCVAL		;put written-file 'crc' into..
	XCHG			;..de-pair.
	LHLD	CRCVAL2		;put read-file 'crc' and..
	CALL	CMPDEHL		;..compare 'de/hl' for equality.
	JRNZ	BADCRC		;if not zero, show copy-error message.
	CALL	ILPRT		;if zero, show 'verified' message.
	DB	' -- CRC Verified',0
	LDA	MFLAG		;if not mass-copy mode, return..
	ORA	A		;..to next 'ring' position.
	JNZ	FORWARD		;else..
	CMA			;..set 1st-time-thru flag..
	STA	FIRST$M		;..and..
	JMP	M$LP		;..get next file to copy, if one.
 
BADCRC:
	CALL	ERMSG
	DB	'Error on CRC compare',0
	JMP	FORWARD		;move to next 'ring' position

; w o r k h o r s e   r o u t i n e s

; inline print of message

ILPRT:
	XTHL			;save hl, get msg pointer.
ILPLP:
	MOV	A,M		;get character
	INX	H		;pt to next
	ANI	7FH		;strip type bits
	JRZ	ILPLP1
	CALL	TYPE		;show on console
	JR	ILPLP
ILPLP1:
	XTHL			;set hl-pair and..
	RET			;..return past message.

; output 'crlf' to console

CRLF:
	MVI	A,CR
	CALL	TYPE
	MVI	A,LF

; conout routine

TYPE:
	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H
	PUSH	PSW	; check for flow control
	CALL	CST	; BIOS console status
	ORA	A	; 0 means nothing
	JRZ	TYPE1
	CALL	CIN	; BIOS console input
	CPI	CTRLS	; pause?
	JRNZ	TYPE1
	CALL	CIN	; BIOS console input
TYPE1:
	POP	PSW	; get char
	MOV	E,A
	MVI	C,WRCON
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	POP	PSW
	RET

; direct BIOS I/O
CST:
	LHLD	CPM$BASE+1	; get BIOS Base Address
	MVI	L,6		; console status routine
	PCHL			; jump to it
CIN:
	LHLD	CPM$BASE+1	; get BIOS Base Address
	MVI	L,9		; console input routine
	PCHL

; output 'crlf' to printer

LCRLF:
	MVI	A,CR
	CALL	LOUT
	MVI	A,LF

; printer routine

LOUT:
	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H
	MOV	E,A
	MVI	C,LIST
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	POP	PSW
	RET

; crt clear-line function

CLR$L:
	MVI	A,CR
	CALL	TYPE
	MVI	B,30		;blank # of characters on line
	MVI	A,' '
CL$LP:
	CALL	TYPE
	DJNZ	CL$LP
	RET

; conin routine (waits for response)

KEYIN:
	MVI	C,RDCON
	CALL	BDOS

; convert character in a-reg to upper case

UCASE:
	CPI	61H		;less than small 'a'?
	RC			;if so, no convert needed.
	CPI	7AH+1		; >small 'z'?
	RNC			;if so, ignore.
	ANI	5FH		;otherwise convert
	RET

; direct console input w/o echo (waits for input)

DKEYIN:
	CALL	CIN		;get char from BIOS
	ANI	7FH		;mask MSB
	JR	UCASE		;capitalize

; convert keyboard input to upper case

CONVERT:
	LXI	H,CMDBUF+1	; 'current keyboard buffer length'..
	MOV	B,M		;..to b-reg.
	MOV	A,B
	ORA	A		;if zero length, skip conversion.
	JZ	COMCAN
CONVLP:
	INX	H		;point at character to capitalize
	MOV	A,M
	CALL	UCASE
	MOV	M,A		;put back into buffer
	DJNZ	CONVLP
	RET

; fill buffer with 'spaces' with count in b-reg

FILL:
	MVI	M,' '		;put in space character
	INX	H
	DJNZ	FILL		;no, branch.
	RET

; ignore leading spaces (ls) in buffer, length in c-reg.

UNSPACE:
	LDAX	D		;get character
	CPI	' '
	RNZ			;not blank, a file is entered.
	INX	D		;to next character
	DCR	C
	JZ	COMCAN		;all spaces --> command recovery error
	JR	UNSPACE

; check for legal cp/m filename character -- return with carry set if illegal

CKLEGAL:
	LDAX	D		;get character from de-pair
	INX	D		;point at next character
	CPI	' '		;less than space?
	RC			;return carry if unpermitted character
	PUSH	H
        PUSH	B
	CPI	'['		;if greater than 'z', exit with..
	JRNC	CKERR		;..carry set.
	MVI	B,CHR$TEND-CHR$TBL
	LXI	H,CHR$TBL
CHR$LP:
	CMP	M  
	JRZ	CKERR
	INX	H
	DJNZ	CHR$LP
	ORA	A		;clear carry for good character
	POP	B
	POP	H
	RET

CKERR:
	POP	B
	POP	H
	STC	     		;error exit with carry set
	RET

CHR$TBL:
	DB	',',':',';','<','=','>'	;invalid character table
CHR$TEND:
	DS	0

; print file name in S$FCB

PRFNSX:
	PUSH	H		;save regs
	PUSH	B
	JR	PRFNS0
PRFNS:
	PUSH	H		;affect only PSW
	PUSH	B
	LXI	H,S$FCB+1
PRFNS0:
	CALL	PRFN		;print file name
	POP	B		;restore
	POP	H
	RET

; print file name pted to by HL

PRFN:
	MVI	B,8		;8 chars
	CALL	PRFNS1
	MVI	A,'.'
	CALL	TYPE
	MVI	B,3		;file type and fall thru
PRFNS1:
	MOV	A,M		;get char
	CALL	TYPE
	INX	H		;pt to next
	DJNZ	PRFNS1
	RET

; filename from 'ring' to 'sfcb'

RINGFCB:
	LHLD	RINGPOS		;move name from ring to source 'fcb'
	LXI	D,S$FCB		;place to move filename and..
	MVI	B,12		;..amount to move.

; move subroutine -- move b-reg # of bytes from hl-pair to de-pair

MOVE:
	MOV	A,M		;get hl-pair referenced source byte
	ANI	7FH		;strip cp/m 2.x attributes
	STAX	D		;put to de-pair referenced destination
	INX	H		;fix pointers for next search
	INX	D
	DJNZ	MOVE
	RET

; initialize 'fcb' cp/m system fields (entry with hl-pair pointing to 'fcb')

INITFCB:
	MVI	B,4		;fill ex, s1, s2, rc counters with zeros.
INITLP:
	MVI	M,0		;put zero (null) in memory
	INX	H
	DJNZ	INITLP
	RET

; disk system reset -- login requested drive

RESET:
	MVI	C,INQDISK	;determine and..
	CALL	BDOS		;..save..
	STA	C$DR		;..current drive.
	MVI	C,RESETDK	;reset system
	CALL	BDOS
	LDA	R$DR		;make requested drive..
SET$DR:
	MOV	E,A		;..current.
	MVI	C,LOGIN
	JMP	BDOS		;return to caller

; set/reset (or get) user area (call with binary user area in a-reg)

SET$USR:
	MOV	E,A		; 0 --> 0, 1 --> 1, etc.
GET$USR:
	MVI	C,SGUSER
	JMP	BDOS		;return to caller

; compare de-pair to hl-pair and set flags accordingly

CMPDEHL:
	MOV	A,D		;see if high bytes set flags
	CMP	H
	RNZ			;return if not equal
	MOV	A,E
	CMP	L		;low bytes set flags instead
	RET

; shift hl-pair b-reg bits (-1) to right (divider routine)

SHIFTLP:
	DCR	B
	RZ
	MOV	A,H
	ORA	A
	RAR
	MOV	H,A
	MOV	A,L
	RAR
	MOV	L,A
	JR	SHIFTLP

; decimal pretty print (h-reg contains msb; l-reg, the lsb.)

DECOUT:
	MVI	A,5		;set leading space count
	STA	LDSP
DECOU1:
	PUSH	PSW
	PUSH	B
	PUSH	D
	PUSH	H
	LDA	LDSP		;count down
	DCR	A
	STA	LDSP
	LXI	B,-10		;radix
	LXI	D,-1
DECOU2:
	DAD	B		;sets..
	INX	D
	JRC	DECOU2		;..carry.	
	LXI	B,10
	DAD	B
	XCHG
	MOV	A,H
	ORA	L
	CNZ	DECOU1		; (recursive)
	LDA	LDSP		; any spaces?
	ORA	A		; 0=none
	JRZ	DECOU4
	MOV	B,A		; count in B
	MVI	A,' '
DECOU3:
	CALL	TYPE
	DJNZ	DECOU3
	XRA	A		;A=0
	STA	LDSP		;set flag
DECOU4:
	MOV	A,E
	ADI	'0'		;make ascii
	CALL	TYPE
	POP	H
	POP	D
	POP	B
	POP	PSW
	RET

; determine free storage remaining on selected drive

FRESTOR:
	MVI	C,INQDISK	;determine current drive
	CALL	BDOS		;returns 0 as a:, 1 as b:, etc.
	INR	A		;make 1 --> a:, 2 --> b:, etc.
	STA	FCB
	MVI	C,GETPARM	;current disk parameter block
	CALL	BDOS
	INX	H		;bump to..
	INX	H
	MOV	A,M		;..block shift factor.
	STA	BSHIFTF		; 'bsh'
	INX	H		;bump to..
	MOV	A,M		;..block mask.
	STA	B$MASK		; 'blm'
	INX	H		;bump to..
	INX	H		;..get..
	MOV	E,M		;..maximum block number..
	INX	H		;..double..
	MOV	D,M		;..byte.
	XCHG
	SHLD	B$MAX		; 'dsm'
	MVI	C,INQALC	;address of cp/m allocation vector
	CALL	BDOS
	XCHG			;get its length
	LHLD	B$MAX
	INX	H
	LXI	B,0		;initialize block count to zero
GSPBYT:
	PUSH	D		;save allocation address
	LDAX	D
	MVI	E,8		;set to process 8 bits (blocks)
GSPLUP:
	RAL			;test bit
	JRC	NOT$FRE
	INX	B
NOT$FRE:
	MOV	D,A		;save bits
	DCX	H
	MOV	A,L
	ORA	H    
	JRZ	END$ALC		;quit if out of blocks
	MOV	A,D		;restore bits
	DCR	E		;count down 8 bits
	JRNZ	GSPLUP		;branch to do another bit
	POP	D		;bump to next count..
	INX	D		;..of allocation vector.
	JR	GSPBYT		;process it

END$ALC:
	POP	D		;clear alloc vector pointer from stack
	MOV	L,C		;copy # blocks to hl-pair
	MOV	H,B
	LDA	BSHIFTF		;get block shift factor
	SUI	3		;convert from sectors to thousands (k)
	JRZ	PRT$FRE		;skip shifts if 1k blocks
FREK$LP:
	DAD	H		;multiply blocks by k-bytes per block
	DCR	A		;multiply by 2, 4, 8, or 16.
	JRNZ	FREK$LP
PRT$FRE:
	SHLD	DISKSP		;save disk space
	RET
;
;  Print free space on disk
;
PRINT$FRE:
	CALL	ERMSG		;position and set flags
	DB	0
	LHLD	DISKSP
	CALL 	DECOUT		; # of free k-bytes in hl-pair
	CALL	ILPRT
	DB	'K Bytes on Disk',0
	RET

;*
;*  ZDNAME -- LOAD THE CONTENTS OF THE NAMES.DIR FILE INTO THE MEMORY
;*	BUFFER PTED TO BY HL
;*	ON ENTRY, HL PTS TO THE MEMORY BUFFER EXTENDING TO THE BASE OF
;*		THE BDOS
;*	ON EXIT, BC IS THE NUMBER OF VALID ENTRIES, A IS THE ERROR FLAG (A=0FFH
;*		AND NZ IF NO ERROR, A=0 AND Z IF ERROR)
;*			ERRORS MAY BE EITHER MEMORY OVERFLOW OR NAMES.DIR
;*			NOT FOUND
;*	EACH NAMES.DIR ENTRY IS 10 BYTES LONG, STRUCTURED AS FOLLOWS:
;*		BYTE 0: DISK NUMBER (A=0)
;*		BYTE 1: USER NUMBER
;*		BYTES 2-9: DIRECTORY NAME, 8 CHARS MAX, <SP> FILL AT END
;*
ZDNAME:
	PUSH	D	; SAVE UNCHANGED REG
	SHLD	DIRNAME	; SAVE PTR TO BUFFER
	LXI	H,DNFILE	; PT TO NAMES.DIR FILE NAME
	LXI	D,S$FCB+1	; PT TO FCB
	MVI	B,11	; 11 BYTES
	CALL	MOVE
	XCHG		; HL PTS TO S$FCB+12
	CALL	INITFCB	; INIT FCB
	LXI	H,S$FCB	; PT TO FCB
	MVI	M,0	; ZERO DRIVE
	XCHG		; DE PTS TO FCB
	CALL	FFIND	; LOOK FOR NAMES.DIR FILE
	JZ	DIRNERR	; FILE NOT FOUND ERROR
;
;  FOUND NAMES.DIR, SO LOAD IT
;
	LDA	Z$U$A	; GET USER
	MOV	C,A
	LDA	Z$DR	; GET DISK
	MOV	B,A
	CALL	SLOGIN	; LOG INTO IT
	LXI	H,S$FCB+12
	CALL	INITFCB
	LXI	D,S$FCB	; PT TO FCB
	XRA	A
	STAX	D	; ZERO FCB DISK
	STA	S$FCB+32	; ZERO CURRENT RECORD
	CALL	FIOPEN	; OPEN FOR INPUT
	ORA	A	; ERROR?
	JRNZ	ZDNA3
;
;  LOAD NAMES.DIR FILE
;
	MVI	C,0	; SET ENTRY COUNT
	LDA	NDNAMES	; GET MAX NUMBER OF NAMES
	MOV	B,A	; ... IN B
ZDNA1:
	LXI	H,ENTRY	; PT TO ENTRY BUFFER
	CALL	GETNAME	; GET NAME FROM DISK
	JRNZ	ZDNA3	; DONE?
	LDA	ENTRY+2	; LOOK AT FIRST LETTER OF DIR NAME
	ORA	A	; NO ENTRY?
	JZ	ZDNA2
	LHLD	DIRNAME	; PT TO BUFFER ENTRY
	LXI	D,ENTRY	; PT TO NEW ENTRY
	INR	C	; INCREMENT ENTRY COUNTER
	PUSH	B	; SAVE COUNTERS
	XCHG		; HL PTS TO NEW ENTRY, DE PTS TO DEST
	MOV	A,M	; GET DISK NUMBER
	STAX	D	; STORE DISK NUMBER
	INX	H	; PT TO USER NUMBER
	INX	D
	MOV	A,M	; GET USER
	STAX	D	; PUT USER
	MVI	B,8	; AT MOST 8 MORE BYTES
ZDNA1A:
	INX	H	; PT TO NEXT BYTE
	INX	D
	MOV	A,M	; GET NEXT BYTE
	ORA	A	; END OF NAME?
	JRZ	ZDNA1B	; <SP> FILL
	STAX	D	; PUT BYTE
	DJNZ	ZDNA1A
	INX	D	; PT TO FIRST BYTE OF NEXT ENTRY
	JR	ZDNA1C
ZDNA1B:
	MVI	A,' '	; <SP> FILL
	STAX	D	; PLACE <SP>
	INX	D	; PT TO NEXT
	DJNZ	ZDNA1B
ZDNA1C:
	POP	B	; RESTORE COUNTERS
	XCHG		; HL PTS TO NEXT BUFFER POSITION
	SHLD	DIRNAME	; SAVE PTR
;
;  CONTINUE LOOPING
;
ZDNA2:
	DJNZ	ZDNA1
;
;  COMPLETION EXIT
;
ZDNA3:
	PUSH	B	; SAVE COUNTER
	CALL	DLOGIN	; RESTORE USER/DISK
	POP	B	; RESTORE COUNTER IN C
	MVI	A,0FFH	; SET NO ERROR
	ORA	A	; SET FLAGS
	STA	DNLOAD	; SET LOAD FLAG
	POP	D	; RESTORE DE
	RET

;*
;*  ZDNFIND -- SCAN FOR POSSIBLE DISK DIRECTORY NAME
;*	THIS ROUTINE EXAMINES THE DIR: PREFIX FOR EITHER A DIRECTORY NAME
;*		OR THE DU FORM
;*	ON ENTRY, HL PTS TO DIRECTORY NAME ENDING IN ANY VALID DELIMITER
;*	RETURN DISK IN B, USER IN C, NZ IF OK, HL PTS TO COLON
;*	DE IS NOT AFFECTED
;*
ZDNFIND:
	PUSH	D	; SAVE DE
	SHLD	DIRNAME	; SAVE DIRECTORY NAME AWAY
	MVI	C,INQDISK	; SAVE CURRENT POSITION
	CALL	BDOS
	STA	DISK
	STA	T$DR
	MVI	E,GET
	CALL	GET$USR
	STA	USER
	LHLD	DIRNAME	; PT TO NAME
	JMP	SVDISK	; CHECK DU FORM FIRST
;
;  LOOK FOR DIR: FORM
;
DIRNXX:
;
;  SCAN MEMORY-RESIDENT BUFFER IF ONE IS AVAILABLE
;
	LDA	T$DR	; SET DISK
	STA	DISK
	LHLD	NDRADR	; GET ADDRESS
	MOV	A,L	; CHECK FOR ZERO
	ORA	H
	CNZ	NBSCAN	; SCAN BUFFER
	JRNZ	NAMEF	; FOUND
	LXI	H,BUFENTRY-2	; PT TO BYTE BEFORE ENTRY COUNT OF DIR BUFFER
	LDA	DNLOAD	; LOADED?
	ORA	A	; 0=NO
	CNZ	NBSCAN	; SCAN BUFFER
	JRNZ	NAMEF
	POP	D	; RESTORE DE
	XRA	A	; NOT FOUND
	RET
NAMEF:
	POP	D	; RESTORE DE
	MVI	A,0FFH	; FOUND
	ORA	A	; DISK/USER IN B/C
	RET

;
;  SCAN MEMORY-RESIDENT BUFFER PTED TO BY HL
;    ON EXIT, A=0 AND ZERO FLAG IF NOT FOUND
;		IF FOUND, B=DISK AND C=USER
;
NBSCAN:
	INX	H	; PT TO ENTRY COUNT
	MOV	A,M	; GET ENTRY COUNT
	ORA	A	; CHECK FOR NO ENTRIES
	RZ		; ABORT IF NO ENTRIES
	MOV	B,A	; ENTRY COUNT IN B
	INX	H	; PT TO FIRST ENTRY
	XCHG		; DE PTS TO FIRST ENTRY IN MEMORY
;
;  MAIN SCANNING LOOP FOR MEMORY-RESIDENT BUFFER
;
NBS0:
	LHLD	DIRNAME	; HL PTS TO DIR NAME
	PUSH	D	; SAVE PTR TO CURRENT MEMORY ENTRY
	MVI	C,8	; SCAN UP TO 8 BYTES
	INX	D	; SKIP DISK
	INX	D	; SKIP USER
	XCHG		; SWITCH PTRS
NBS1:
	LDAX	D	; GET CHAR IN BUFFER
	CPI	':'	; COLON?
	JRNZ	NBS1A
	MVI	A,' '	; SUBSTITUTE SPACE FOR IT
NBS1A:
	CMP	M	; COMPARE AGAINST TARGET NAME
	JRNZ	NBS2
	INX	H	; PT TO NEXT
	INX	D
	DCR	C	; COUNT DOWN
	JRNZ	NBS1
	JR	NBS3	; FOUND
NBS2:
	POP	H	; GET PTR TO CURRENT BUFFER ENTRY
	LXI	D,10	; SKIP TO NEXT ENTRY
	DAD	D	; HL PTS TO NEXT ENTRY
	XCHG		; DE PTS TO NEXT ENTRY
	DJNZ	NBS0
;
;  ENTRY NOT FOUND
;
	XRA	A	; A=0 AND ZERO FLAG SET
	RET
;
;  ENTRY FOUND
;
NBS3:
	POP	H	; GET PTR TO ENTRY
	MOV	B,M	; DISK IN B
	INX	H	; PT TO USER
	MOV	C,M	; USER IN C
	MVI	A,0FFH	; SET FOUND FLAG
	ORA	A
	RET

;
;  LOOK AT START OF DU: FORM
;	ON ENTRY, HL PTS TO FIRST CHAR OF DIRECTORY NAME
;
SVDISK:
	LDA	MDISK	; GET MAX DISK
	INR	A	; +1 FOR LATER COMPARE
	MOV	B,A	; ... IN B
	MOV	A,M	; GET DISK LETTER
	CPI	'A'	; DIGIT?
	JRC	USERCK	; IF NO DIGIT, MUST BE USER OR COLON
	SUI	'A'	; CONVERT TO NUMBER
	CMP	B	; LIMIT?
	JNC	DIRNXX	; NAME IF OUT OF LIMIT
	STA	DISK	; SAVE DISK
	INX	H	; PT TO NEXT CHAR
;
;  CHECK FOR USER
;
USERCK:
	MOV	A,M	; GET POSSIBLE USER NUMBER
	CPI	':'	; NO USER NUMBER
	JRZ	DIRNX	; EXIT IF SO
	CPI	' '	; NO USER NUMBER
	JRZ	DIRNX
	ORA	A
	JRZ	DIRNX
	XRA	A	; ZERO USER NUMBER
	MOV	B,A	; B=ACCUMULATOR FOR USER NUMBER
USRLOOP:
	MOV	A,M	; GET DIGIT
	INX	H	; PT TO NEXT
	CPI	':'	; DONE?
	JRZ	USRDN
	CPI	' '	; DONE?
	JRZ	USRDN
	SUI	'0'	; CONVERT TO BINARY
	JC	DIRNXX	; NAME IF USER NUMBER ERROR
	CPI	10
	JNC	DIRNXX
	MOV	C,A	; NEXT DIGIT IN C
	MOV	A,B	; OLD NUMBER IN A
	ADD	A	; *2
	ADD	A	; *4
	ADD	B	; *5
	ADD	A	; *10
	ADD	C	; *10+NEW DIGIT
	MOV	B,A	; RESULT IN B
	JR	USRLOOP
USRDN:
	MOV	A,B	; GET NEW USER NUMBER
	CPI	32	; WITHIN RANGE?
	JNC	DIRNXX	; NAME IF OUT OF RANGE
	STA	USER	; SAVE IN FLAG
;
;  VALID EXIT -- FOUND IT, SO LOAD BC AND EXIT FLAG; ON ENTRY, HL PTS TO :
;
DIRNX:
	LDA	USER	; RETURN USER IN C, DISK IN B
	MOV	C,A
	LDA	DISK
	MOV	B,A
	MVI	A,0FFH	; SET NO ERROR
	ORA	A	; SET FLAGS
	POP	D	; RESTORE DE
	RET
;
;  INVALID EXIT -- NOT FOUND OR ERROR
;	NO VALID RETURN PARAMETERS (BC, HL)
;
DIRNERR:
	XRA	A	; ERROR CODE
	STA	DNLOAD	; SET LOAD FLAG TO NO LOAD
	POP	D	; RESTORE DE
	RET

;
;  GET NAME FROM NAMES.DIR INTO BUFFER PTED TO BY HL
;	DO NOT AFFECT BC OR HL; RET W/NZ IF ERROR
;
GETNAME:
	PUSH	B	; SAVE BC
	PUSH	H	; SAVE HL
	CALL	FGET	; GET DISK LETTER
	JRNZ	GNERR	; ERROR?
	SUI	'A'	; CONVERT TO NUMBER
	MOV	M,A	; STORE IT
	INX	H	; PT TO NEXT
	MVI	B,10	; GET USER AND DIRECTORY NAME
GETN1:
	CALL	FGET	; GET BYTE
	JRNZ	GNERR	; ERROR?
	MOV	M,A	; STORE IT
	INX	H	; PT TO NEXT
	DJNZ	GETN1
	XRA	A	; OK
GNERR:
	POP	H	; RESTORE HL
	POP	B	; RESTORE BC
	RET

;
;  OPEN FILE FOR GET
;
FIOPEN:
	PUSH	D
	MVI	C,OPEN	; OPEN FILE
	CALL	BDOS
	POP	D
FIO1:
	MVI	C,READ	; READ FIRST BLOCK
	CALL	BDOS
	LXI	H,TBUF	; SET PTR
	SHLD	FIPTR
	RET
;
;  GET NEXT BYTE FROM FILE
;
FGET:
	PUSH	H	; SAVE REGS
	PUSH	D
	PUSH	B
	LHLD	FIPTR	; PT TO NEXT CHAR
	MOV	A,M	; GET IT
	STA	FICHAR	; SAVE IT
	INX	H	; PT TO NEXT
	SHLD	FIPTR	; SET PTR
	LXI	D,TBUF+80H	; END OF BUFFER?
	CALL	CMPDEHL	; COMPARE
	JRNZ	FGETD	; DONE IF NOT
	LXI	D,S$FCB	; PT TO FCB
	CALL	FIO1	; READ BLOCK AND SET PTR
	ORA	A	; SET FLAG (NZ = ERROR)
	JR	FGETD1
FGETD:
	XRA	A	; NO ERROR (Z)
FGETD1:
	POP	B	; GET REGS
	POP	D
	POP	H
	LDA	FICHAR	; GET CHAR
	RET

; message routines

; print VFILER banner
BANNER:
	CALL	CLS		;clear screen
	LXI	H,BANADR
	CALL	GOTOXY
	CALL	ILPRT		;print banner
	DB	'VFILER, Version '
	DB	VERS/10+'0','.',(VERS MOD 10)+'0'
	 IF	Z80
	DB	'  [Z80  Code]'
	 ELSE
	DB	'  [8080 Code]'
	 ENDIF
	DB	0
	RET
; home the cursor
CUR$FIRST:
	LXI	H,CURHOME	; HOME ADDRESS
	SHLD	CURAT		; SET CURSOR POSITION
	JMP	GOTOXY
; last file position
CUR$LAST:
	LHLD	RINGPOS		; ADVANCE
	SHLD	LOCPOS		; SET LOCAL POSITION
CL0:
	LXI	D,13
	DAD	D
	XCHG
	LHLD	LOCEND		; END OF LOCAL RING?
	CALL	CMPDEHL
	RZ
	XCHG			; NEW POSITION
	SHLD	LOCPOS
	PUSH	H		; SAVE POSITION
	CALL	CUR$NEXT	; ADVANCE CURSOR
	POP	H		; GET POSITION
	JR	CL0
; advance the cursor
CUR$NEXT:
	LHLD	CURAT		; COMPUTE NEW POSITION
	MOV	A,L		; CHECK FOR NEW LINE
	ADI	19		; SIZE OF EACH ENTRY
	CPI	70
	JRNC	CN1		; ADVANCE TO NEXT LINE
	MOV	L,A		; NEW POSITION
	SHLD	CURAT
	JMP	GOTOXY
CN1:
	MOV	A,H		; GET LINE
	LXI	H,CURHOME	; GET COL
	MOV	H,A		; SET LINE AND FALL GO TO CUR$DOWN
	SHLD	CURAT
	JR	CUR$DOWN
; back up the cursor
CUR$BACK:
	LXI	H,CURHOME	; GET HOME
	XCHG			; ... IN DE
	LHLD	CURAT
	CALL	CMPDEHL		; COMPARE
	JRZ	CUR$LAST	; GOTO END IF LAST
	MOV	A,L		; CHECK FOR FIRST COL
	CMP	E
	JRZ	CB1
	SUI	19		; BACK UP ONE COL
	MOV	L,A
	SHLD	CURAT		; NEW POS
	JMP	GOTOXY
CB1:
	MOV	A,E		; GET HOME COL
	ADI	19*3		; GET LAST COL
	MOV	L,A
	DCR	H		; PREV LINE
	SHLD	CURAT
	JMP	GOTOXY
; move cursor down one line
CUR$DOWN:
	LXI	H,CURHOME	; GET HOME ADDRESS
	MOV	B,H		; LINE IN B
	LHLD	CURAT		; GET CURRENT ADDRESS
	INR	H		; MOVE DOWN
	MOV	A,H		; CHECK FOR TOO FAR
	SUB	B
	CPI	EPS/4
	JRNC	CD1
	SHLD	CURAT		; OK, SO SET POSITION
	JMP	GOTOXY
CD1:
	MOV	A,L		; GET COL
	LXI	H,CURHOME
	MOV	L,A
	SHLD	CURAT
	JMP	GOTOXY
; refresh screen
REFRESH:
	LHLD	CURAT	; SAVE CURSOR AND RING POSITIONS
	SHLD	SCURAT
	LHLD	RINGPOS
	SHLD	SRINGPOS
	CALL	BANNER	; PRINT BANNER
	CALL	NEWPOS	; DISPLAY FILES
	LXI	H,CPMADR	; COMMAND PROMPT MESSAGE
	CALL	GOTOXY
	CALL	ILPRT		; PROMPT WITH DRIVE PREFIX
LOG$DU$MSG:
	DB	'   :  '
	DB	'Command (? for Help)?',0
	LXI	H,SDMADR	; SCREEN DIRECTORY MESSAGE
	CALL	GOTOXY
	CALL	ILPRT
	DB	'-- Screen Directory --',0
	LXI	H,FNADR		; PT TO WHERE FILE NAME IS PRINTED
	MVI	L,1		; COL 1 FOR THIS MESSAGE
	CALL	GOTOXY		; GO THERE
	CALL	ILPRT
	DB	'Current File:',0
	LHLD	SCURAT		; RESTORE CURSOR AND RING POSITIONS
	SHLD	CURAT
	LHLD	SRINGPOS
	SHLD	RINGPOS
	CALL	SETCUR		; RESTORE CURSOR ON SCREEN
	RET
; refresh file display
NEWPOS:
	CALL	CUR$FIRST	; POSITION CURSOR AT FIRST POSITION
	MVI	B,EPS/4		; # LINES
NEWP0:
	PUSH	B
	CALL	EREOL		; ERASE TO EOL
	LHLD	CURAT		; GET ADDRESS OF CURSOR
	INR	H		; NEXT LINE
	SHLD	CURAT
	CALL	GOTOXY
	POP	B
	DJNZ	NEWP0
	CALL	CUR$FIRST	; POSITION CURSOR AT FIRST POSITION
	LHLD	LOCBEG		; PT TO FIRST FILE NAME
	SHLD	LOCPOS		; SAVE LOCAL POSITION
NEWP1:
	LHLD	LOCEND		; AT END?
	XCHG
	LHLD	LOCPOS
	CALL	CMPDEHL
	JZ	CUR$FIRST	; POSITION AT FIRST ENTRY AND RETURN
	MVI	B,4		; 4 SPACE
	MVI	A,' '
T4:
	CALL	TYPE
	DJNZ	T4
	PUSH	H		; SAVE CURRENT LOCAL POSITION IN RING
	INX	H		; PT TO FILE NAME
	CALL	PRFN		; PRINT FILE NAME
	MOV	A,M		; PRINT TAG
	CALL	TYPE
	POP	H		; GET CURRENT LOCAL POSITION
	LXI	D,13
	DAD	D
	SHLD	LOCPOS
	CALL	CUR$NEXT	; ADVANCE CURSOR
	JR	NEWP1
; position cursor at CURAT
SETCUR:
	LHLD	CURAT
	CALL	GOTOXY
	CALL	ILPRT
	DB	'-->',0
	RET
; clear cursor
CLRCUR:
	LHLD	CURAT
	CALL	GOTOXY
	CALL	ILPRT
	DB	'   ',0
	RET
; command prompt
CPRMPT:
	LXI	H,CPADR	; GET ADDRESS
MPRINT:
	PUSH	H	; SAVE ADDRESS
	CALL	GOTOXY
	CALL	EREOL	; ERASE TO EOL
	POP	H	; GET ADDRESS
	CALL	GOTOXY	; POSITION CURSOR
	JMP	ILPRT	; PRINT MESSAGE AND RETURN
; working message
WORKMSG:
	CALL	ERMSG
	DB	'Working ...',0
	RET
; error message
ERMSG:
	MVI	A,0FFH	; SET ERROR MESSAGE FLAG
	STA	ERMFLG
	LXI	H,ERADR	; GET ADDRESS
	JR	MPRINT
; print file size info
FSNOTE:
	CALL	ERMSG	; USE THIS ROUTINE
	DB	'File Size of ',0
	RET
; position for file size print
ATFS:
	LXI	H,FSADR+13	; POSITION FOR PRINT OF FILE SIZE
	JMP	GOTOXY
; clear error message
ERCLR:
	XRA	A	; CLEAR FLAG
	STA	ERMFLG
	LXI	H,ERADR	; POSITION
	CALL	GOTOXY
	JMP	EREOL	; ERASE TO EOL
; position at command prompt and clear it
ATCMD:
	LXI	H,CPADR	; POSITION
	CALL	GOTOXY
	CALL	EREOL	; CLEAR MESSAGE
	LXI	H,CPADR	; REPOSITION
	JMP	GOTOXY
; position at bottom of screen and prompt for continuation
BOTTOM:
	LXI	H,BOTADR	; POSITION
	CALL	GOTOXY
	CALL	ILPRT
	DB	'Strike Any Key to Continue -- ',0
	JMP	KEYIN


; s t o r a g e

; initialized

HEADMSG:
	 DB	'File: ',0
MOREHELP:
	 DB	'HELP VFILER',0	;HELP Command for further info
HELPFCB:
	 DB	0,'HELP    COM'
FILERCMD:
	 DB	';VFILER '
FILE$D:
	 DB	'x'
FILE$U:
	 DB	'xx'
	 DB	' W'	;WAIT option
	 DB	0
JOKER:
	 DB	'???????????'	; *.* equivalent
FIRST$M:
	 DB	FALSE		; 1st time thru in mass-copy mode
MFLAG:
	 DB	TRUE		;multiple file copy flag --> 0 for mass copy
TAG$TOT:
	 DW	0		;summation of tagged file sizes
CMDBUF:
	 DB	32,0		;command buffer maximum length, usage, and..

; uninitialized

	 DS	100		;..storage for buffer and local stack.
STACK:
	 DS	2		;cp/m's stack pointer stored here
B$MAX:
	 DS	2		;highest block number on drive
B$MASK:
	 DS	1		;sec/blk - 1
BSHIFTF:
	 DS	1		; # of shifts to multiply by sec/blk
BUF$PT:
	 DS	2		;copy buffer current pointer..
BUFSTART:
	 DS	2		;..and begin pointer.
CANFLG:
	 DS	1		;no-file-found cancel flag
C$DR:
	 DS	1		; 'current drive'
CHARCNT:
	 DS	1		;character count for tab expansion
CON$LST:
	 DS	1		;bdos function storage
CRCTBL:
	 DS	512		;tables for 'crc' calculations
CRCVAL:
	 DS	2		; 2-byte 'crc' value of working file and..
CRCVAL2:
	 DS	2		;..of finished source read-file.
C$U$A:
	 DS	1		; 'current user area'
CURAT:
	 DS	2		;current cursor position
D$FCB:
	 DS	33		;fcb for destination file/new name if rename
DIRNAME:
	 DS	2		;ptr to DIR prefix
DISK:
	 DS	1		;selected disk for ZDNAME
DISKSP:
	 DS	2		;space remaining on disk
DNLOAD:
	 DS	1		;NAMES.DIR loaded flag
DRLET:
	 DS	1		;scratch for drive letter
ENTRY:
	 DS	11		;scratch for ZDNAME/ZDNFIND
EOFLAG:
	 DS	1		;file copy loop 'eof' flag
ERMFLG:
	 DS	1		;error message present flag
FICHAR:
	 DS	1		;byte-oriented input char
FIPTR:
	 DS	2		;byte-oriented input ptr
FSDFLG:
	 DS	1		;display file size flag (yes/no)
FS$FLG:
	 DS	1		;tag total versus file size flag
HELPFLG:
	 DS	1		;is HELP available externally?  0=No
LDSP:
	 DS	1		;leading space count for DECOUT
LPSCNT:
	 DS	1		;lines-per-screen for 'view'
LOCBEG:
	 DS	2		;local beginning of ring
LOCEND:
	 DS	2		;local end of ring
LOCPOS:
	 DS	2		;local ring position (temp)
MAXDR:
	 DS	1		;max driver letter
MDFLG:
	 DS	1		;mass delete verify flag
O$USR:
	 DS	1		;store initial user area for exit
R$DR:
	 DS	1		; 'requested drive'
RCNT:
	 DS	2		; # of records in file and..
REC$CNT:
	 DS	2		;..currently in ram buffer.
REC$MAX:
	 DS	2		;maximum 128-byte record capacity of buffer
RING:
	 DS	2		;ptr to beginning of ring
RINGI:
	 DS	2		;ring sort pointer
RINGJ:
	 DS	2		;another ring sort pointer
RINGEND:
	 DS	2		;current ring end pointer
RINGPOS:
	 DS	2		;current ring position in scan
R$U$A:
	 DS	1		; 'requested user area'
SCURAT:
	 DS	2		;save cursor position
S$FCB:
	 DS	36		;fcb for source (random record) file
SRINGPOS:
	 DS	2		;save ring position
T$DR:
	 DS	1		;temp disk
TEST$RT:
	 DS	1		;intermediate right-justify data
T$U$A:
	 DS	1		;temp user
T$UN$FG:
	 DS	1		;tag/untag file summation switch
USER:
	 DS	1		;temp user buffer
VIEWFLG:
	 DS	1		; 00h --> to list/punch else to crt 'view'
Z$DR:
	 DS	1		;disk for ZDNAME
Z$U$A:
	 DS	1		;user area for ZDNAME
 
; cp/m system functions

RDCON	EQU	1		;console input function
WRCON	EQU	2		;write character to console..
PUNCH	EQU	4		;..punch and..
LIST	EQU	5		;..to list logical devices.
DIRCON	EQU	6		;direct console i/o
RDBUF	EQU	10		;read input string
CONST	EQU	11		;get console status
RESETDK	EQU	13		;reset disk system
LOGIN	EQU	14		;log-in new drive
OPEN	EQU	15		;open file
CLOSE	EQU	16		;close file
SRCHF	EQU	17		;search directory for first..
SRCHN	EQU	18		;..and next occurrence.
ERASE	EQU	19		;erase file
READ	EQU	20		;read and..
WRITE	EQU	21		;..write 128-record.
MAKE	EQU	22		;make file
REN	EQU	23		;rename file
INQDISK	EQU	25		;get current (default) drive
SETDMA	EQU	26		;set dma address
INQALC	EQU	27		;allocation vector
ATTR	EQU	30		;set file attributes
GETPARM	EQU	31		;current drive parameters address
SGUSER	EQU	32		;set or get user area
COMPSZ	EQU	35		; # of records in file

; system addresses

BDOS	 EQU	CPM$BASE+05H	;bdos function entry address
FCB	 EQU	CPM$BASE+5CH	;default file control block
FCBEXT	 EQU	FCB+12      	;extent byte in 'fcb'
FCBRNO	 EQU	FCB+32		;record number in 'fcb'
FCB2	 EQU	CPM$BASE+6CH	;2nd FCB
TBUF	 EQU	CPM$BASE+80H	;default cp/m buffer

; assembled 'com' and 'ram-loaded' file size (0c00h = 3k)

COMFILE	 EQU	(CMDBUF+2)-256	; 'prn' listing shows 'com'..
LAST:	 DS	1		; 1 for byte before BUFENTRY
; even-page base of filename ring storage

BUFENTRY	EQU	$/100H*100H+100H


	 END			;..and loaded file size.

