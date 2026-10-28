;		LMODEM.ASM  by S. Kluger, N5NX
;
;	Developed from XMODEM56.ASM by Keith Petersen, W8SDZ
;	The basic idea on how to access the LBR file was taken from
;	LRUN.ASM by G. Novosielski, but no code was copied therefrom.
;	Error checking is not done as extensively as in LRUN.
;	Note that this is an EXPERIMENTAL version and could most
;	definitely be improved by a more experienced programmer.
;	(This doesn't mean I'm incompetent. I made it work, didn't I???)
;
;-----------------------------------------------------------------
; Modifications/updates: (in reverse order to minimize reading time)
; 1.6  12/26/82 Finally fixed send bug. Changed end-of-member detect
;		routine and placement of RCNT. (SFK)
; 1.5  12/25/82 Fixed bug which kept LMODEM from sending files larger
;		than 255 sectors (bug made file size modulo 255) (SFK)
; 1.4  12/22/82 Incorporated directory check to make sure LBR directory
;		is not corrupt. Changed program to accept either a file name
;		defaulting to .LBR or any full file name, in case the library
;		file has a different type. (SFK)
; 1.3  12/03/82 Added EQU to version no.,and changed sign-on message.
;		(Tim Hancock  Walled Lake, Mich)
; 1.2  11/29/82 Fixed RECU and DEFDRV labels (for LOGCAL only) (SFK)
; 1.1  11/27/82 Fixed bug where sometimes the end-of-member would not
;               be detected; LMODEM kept going until EOF on the LBR (SFK)
; 1.0  11/27/82 Original distribution version
;
;
;		REMOTE LBR - CP/M FILE TRANSFER PROGRAM
;
; Based on MODEM.ASM V2.0, by Ward Christensen.  This program is in-
; tended for use on remote CP/M systems where it is important that the
; initialization of the modem not be changed, such as when using the
; BYE program.  The baud rate and number of bits remains the same as
; whatever was set previously.  There is no disconnect, terminal or echo
; option.
;
;       NOTE:  REQUIRES SEQIO22.LIB if "LOGCAL" is set TRUE
;
;*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *
;
;
;	NOTE:  If you add improvements or otherwise update
;		  this program, please modem a copy of the
;		  new file to "El Paso RCPM" in El Paso, TX
;		  (915)-598-1668.
;
;
;*   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *   *
;
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
;
;
;-----------------------------------------------------------------------
;
;		--- Conditional Assembly Options ---
;
;-----------------------------------------------------------------------
;
;
VERSION	EQU	1
MODLEV	EQU	6
;
STDCPM	EQU	TRUE	;TRUE, IS STANDARD CP/M
ALTCPM	EQU	FALSE	;TRUE, IS TRS-80 OR H8 W/O 0-ORG
;
DCH	EQU	FALSE	;TRUE, IS D.C. HAYES
PMMI	EQU	TRUE	;TRUE, IS PMMI
H8	EQU	FALSE	;TRUE, IS H8/H89 W/INS8250 MODEM CHIP
EXTMOD	EQU	FALSE	;TRUE, IS NONE OF THE ABOVE!
;
FASTCLK EQU	TRUE	;PUT TRUE HERE FOR 4 MHZ CLOCK
;
FRNTPNL	EQU	FALSE	;TO DISPLAY STATUS ON FRONT PANEL
PANEL	EQU	0FFH	;DEFAULT ADDRESS OF FRONT PANEL
;
;
;	FILE TRANSFER LOGGING OPTIONS
;
LOGCAL	EQU	false	;IF USING LOGGING OF LMODEM TRANSFERS
LASTUSR	EQU	14	;USER AREA OF 'LASTCALR' FILE(IF 'LOGCAL' ONLY)
RECU	EQU	0	;user area for .LOG file
DEFDRV	EQU	'A'	;LOG file drive
;
LSPEED	EQU	true	;TRUE IF USING BYE WITH SPEED SELECTION
MSPEED	EQU	3DH	;LOCATION OF BAUD RATE FACTOR  (SET BY BYE)
CONOUT	EQU	0000H	;ADDRESS OF BIOS 'C' REGISTER OUTPUT.  THIS WILL
;			;BE THE 5TH ENTRY IN THE CP/M JUMP TABLE.  ENTER
;			;YOUR OWN BIOS ADDRESS HERE IF YOU WISH TO HAVE
;			;THE RECORD COUNT ON YOUR LOCAL CRT CONSOLE.
;
;-----------------------------------------------------------------------
;
; 		--- Modem Port Equates ---
;
;-----------------------------------------------------------------------
;
	IF	PMMI
MODCTLP	EQU	0E0H		;PMMI VALUES (BASE PORT ADDRESS)
MODSNDB	EQU	1		;BIT TO TEST FOR SEND
MODSNDR	EQU	1		;VALUE WHEN READY
MODRCVB	EQU	2		;BIT TO TEST FOR RECEIVE
MODRCVR	EQU	2		;VALUE WHEN READY
MODDCDB	EQU	4		;CARRIER DETECT BIT
MODDCDA	EQU	0		;VALUE WHEN ACTIVE
MODPARE	EQU	08H		;VALUE FOR PARITY ERROR
MODOVRE	EQU	10H		;VALUE FOR OVERRUN ERROR
MODFRME	EQU	20H		;VALUE FOR FRAMING ERROR
MODDATP	EQU	MODCTLP+1	;DATA PORT, RECEIVE
MODDATO	EQU	MODCTLP+1	;DATA PORT, SEND
BAUDRP	EQU	MODCTLP+2	;BAUD RATE OUTPUT/MODEM STATUS
MODCTL2	EQU	MODCTLP+3	;SECOND CTL PORT
	ENDIF
;
	IF	H8
MODCTLP	EQU	0E5H	;H8/H89 VALUES (LSR-LINE STATUS REG.)
MODSNDB	EQU	20H	;TEST FOR SEND (LSR-THRE)
MODSNDR	EQU	20H	;VALUE WHEN READY
MODRCVB	EQU	01H	;TEST FOR RECIEVE (LSR-DR)
MODRCVR	EQU	01H	;VALUE WHEN READY
MODDCDB	EQU	80H	;CARRIER DETECT BIT (MSR-CTS)
MODDCDA	EQU	80H	;VALUE WHEN ACTIVE
MODPARE	EQU	04H	;VALUE FOR PARITY ERROR (LSR-PE)
MODOVRE	EQU	02H	;VALUE FOR OVERRUN ERROR (LSR-OR)
MODFRME	EQU	08H	;VALUE FOR FRAMING ERROE (LSR-FE)
MODDATP	EQU	0E0H	;DATA PORT, RECIEVE
MODDATO	EQU	0E0H	;DATA PORT, SEND
BAUDRP	EQU	0E6H	;BAUD RATE PORT (DALB IN LCR MUST=1)
MODCTL2	EQU	0E6H	;MODEM STATUS REGISTER (MSR)
MODCTL1	EQU	0E3H	;LINE CONTROL REGISTER (LCR)
	ENDIF
;
	IF	DCH
MODCTLP	EQU	92H	;D. C. HAYES VALUES
MODSNDB	EQU	2	;BIT TO TEST FOR SEND
MODSNDR	EQU	2	;VALUE WHEN READY
MODRCVB	EQU	1	;BIT TO TEST FOR RECEIVE
MODRCVR	EQU	1	;VALUE WHEN READY
MODDCDB	EQU	40H	;CARRIER DETECT BIT
MODDCDA	EQU	40H	;VALUE WHEN ACTIVE
MODPARE	EQU	04H	;VALUE FOR PARITY ERROR
MODOVRE	EQU	10H	;VALUE FOR OVERRUN ERROR
MODFRME	EQU	08H	;VALUE FOR FRAMING ERROR
MODDATP	EQU	90H	;DATA PORT IN PORT
MODDATO	EQU	90H	;DATA OUT PORT
MODCTL2	EQU	91H	;SECOND CTL PORT
	ENDIF
;
; If you are using an external modem (not S-100 plug-in) change these
; equates for your modem port requirements
;
	IF	EXTMOD
MODCTLP	EQU	0C3H	;PUT YOUR MODEM STATUS PORT HERE
MODSNDB	EQU	10H	;YOUR BIT TO TEST FOR SEND
MODSNDR	EQU	10H	;YOUR VALUE WHEN READY
MODRCVB	EQU	01H	;YOUR BIT TO TEST FOR RECEIVE
MODRCVR	EQU	01H	;YOUR VALUE WHEN READY
MODDCDB	EQU	02H	;CARRIER DETECT BIT
MODDCDA	EQU	02H	;VALUE WHEN ACTIVE
MODDATP	EQU	0C0H	;YOUR MODEM DATA IN PORT
MODDATO	EQU	0C2H	;YOUR MODEM DATA OUT PORT
MODCTL2	EQU	0C1H	;SECOND CONTROL/STATUS PORT.
	ENDIF		;END OF EXTERNAL MODEM EQUATES
;
;
;-----------------------------------------------------------------------
;
;			--- End of Options ---
;
;-----------------------------------------------------------------------
;
;
ERRLIM	EQU	10	;MAX ALLOWABLE ERRORS (10 STANDARD)
;
;
; Define ASCII characters used
;
SOH	EQU	1	;START OF HEADER
EOT	EQU	4	;END OF TRANSMISSION
ACK	EQU	6	;ACKNOWLEDGE
NAK	EQU	15H	;NEG ACKNOWLEDGE
CRC	EQU	'C'	;CRC REQUEST CHARACTER
CAN	EQU	18H	;CONTROL-X FOR CANCEL
LF	EQU	10	;LINEFEED
CR	EQU	13	;CARRIAGE RETURN
; 
	IF	STDCPM
BASE	EQU	0	;CP/M BASE ADDRESS
	ENDIF
;
	IF	ALTCPM
BASE	EQU	4200H	;ALTERNATE CP/M BASE ADDRESS
	ENDIF
;
	ORG	BASE+100H
;
;
	JMP	BEGIN

SPEED	DB	1	;SPEED FOR FILE TIME TRANSFER WITHOUT AUTO-SET
;			;0=110, 1=300, 2=450, 3=600, 4=710, 5=1200
;
; INIT PRIVATE STACK
;

BEGIN:
	LXI	H,0		;HL=0
	DAD	SP		;HL=STACK FROM CP/M
	SHLD	STACK		;   SAVE IT
	LXI	SP,STACK 	;SP=MY STACK
	CALL	ILPRT	;PRINT:
	DB	CR,LF
	DB	'LMODEM V'
	DB	VERSION+'0'	;VERSION #
	DB	'.',MODLEV+'0'	;MODIFICATION LEVEL
	DB	'[CRC capable]',CR,LF,0
	MVI	A,'S'
	PUSH	PSW		;SAVE OPTION
;
;
; MOVE THE FILENAME FROM FCB2 TO MEMFCB
;
	CALL	MOVEFCB
;
;
; GOBBLE UP GARBAGE CHARACTERS FROM THE LINE PRIOR TO RECEIVER OR SEND
;
	IN	MODDATP
	IN	MODDATP
;
	POP	PSW		;GET OPTION
	IF	LOGCAL
	PUSH	PSW		;BUT SAVE IT
	ENDIF
;
	STA	OPTSAV		;SAVE OPTION IN CASE WE LOSE CARRIER
	JMP	SENDFIL
;
	IF	LOGCAL
;
	MACLIB SEQIO22
;
BSIZE	EQU	80H
FILERR	SET	EXIT
BUFFERS	SET	DBUF
;
;
; THE FOLLOWING ALLOCATIONS ARE USED BY THE 'FILE' MACROS
;
DEFAULT$USER:
	DB	LASTUSR
CUR$USER:
	DB	0FFH
DEFAULT$DISK:
	DB	DEFDRV-'A'
CUR$DISK:
	DB	0FFH
PGSIZE:
	DW	0
LOGCALL:
	FILE	INFILE,CALLER,,LASTCALR,,BSIZE,,PUBLIC,TRUE
;
	MVI	A,RECU
	STA	DEFAULT$USER
;
	FILE	APPEND,LOG,,LOG,SYS,BSIZE,,PUBLIC,TRUE
;
	POP	PSW		;GET OPTION
	PUT	LOG		;PUT IT OUT TO LOG
	LDA	MSPEED		;GET SPEED FACTOR
	ADI	30H
	PUT	LOG		;PUT OUT A SINGLE LETTER CODE
	LDA	PGSIZE		;NOW THE PRGM SIZE IN MINS TRANSFER TIME
	CALL	PNDEC
	MVI	A,' '		;BLANK
	PUT	LOG
;
;
; LOG THE DRIVE AND USER AREA AS A PROMPT
;
	LDA	FCB
	ORA	A
	JNZ	WDRV
	MVI	C,25
	CALL	@BDOS
	INR	A
WDRV:
	ADI	'A'-1
	PUT	LOG
	MVI	C,32		;NOW THE USER AREA (AS DECIMAL NUMBER)
	MVI	E,0FFH
	CALL	@BDOS
	CALL	PNDEC
	MVI	A,'>'		;MAKE IT LOOK LIKE A PROMPT
	PUT	LOG
	LXI	H,FCB+1		;NOW THE NAME OF THE FILE
	MVI	B,11
	CALL	PUTSTR
	MVI	A,' '		;BLANK
	PUT	LOG
CLOOP:
	GET	CALLER		;AND THE CALLER
	CPI	EOF
	JZ	QUIT
	PUT	LOG
	JMP	CLOOP
;.....
;
;
PNDEC:
	CPI	10		;TWO COLUMN DECIMAL FORMAT ROUTINE
	JC	ONE		;ONE OR TWO DIGITS TO AREA #?
	JMP	TWO
;...
;
;
ONE:
	PUSH	PSW
	MVI	A,'0'
	PUT	LOG
	POP	PSW
TWO:
	MVI	H,0
	MOV	L,A
	CALL	DECOT
	RET
;.....
;
;
DECOT:
	PUSH	B
	PUSH	D
	PUSH	H
	LXI	B,-10
	LXI	D,-1
;
DECOT2:	DAD	B
	INX	D
	JC	DECOT2
	LXI	B,10
	DAD	B
	XCHG
	MOV	A,H
	ORA	L
	CNZ	DECOT
	MOV	A,E
	ADI	'0'
	PUT	LOG
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
PUTSTR:
	MOV	A,M
	PUSH	H
	PUSH	B
	PUT	LOG
	POP	B
	POP	H
	INX	H
	DCR	B
	JNZ	PUTSTR
	RET
;.....
;
;
QUIT:	FINIS	LOG
	JMP	EXIT
;.....
;
	ENDIF			;LOGCAL
;
;
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
;		SENDFIL: SENDS A MEMBER OF A LBR FILE
;
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
; The LBR member specified in the LMODEM command is transferred over the
; phone to another computer running MODEM with the "R" (receive) option.
; The data is sent one record at a time with headers and checksums, and
; re transmission on errors.  
;
SENDFIL:
	CALL	TRAP		;CHECK FOR NO NAME OR AMBIG. NAME
	CALL	OPENFIL 	;OPEN THE FILE
	MVI	E,80		;WAIT 80 SEC FOR INITIAL NAK
	CALL	WAITNAK
;
SENDLP:
	CALL	RDSECT		;READ A SECTOR	
	JC	SENDEOF		;SEND 'EOF' IF DONE
	CALL	INCRSNO 	;BUMP SECTOR #
	XRA	A		;ZERO ERROR COUNT
	STA	ERRCT
;
SENDRPT:
	CALL	SENDHDR 	;SEND A HEADER
	CALL	SENDSEC 	;SEND DATA SECTOR
	LDA	CRCFLG		;GET CRC FLAG
	ORA	A		;CRC IN EFFECT?
	CZ	SENDCRC		;YES, SEND CRC
	CNZ	SENDCKS 	;NO, SEND CKSUM
	CALL	GETACK		;GET THE ACK
	JC	SENDRPT 	;REPEAT IF NO ACK
	lhld	rcnt
	mov	a,h
	ora	l
	jz	sendeof
	dcx	h
	shld	rcnt
	JMP	SENDLP		;LOOP UNTIL EOF
;.....
;
;
; FILE SENT, SEND EOT's
;
SENDEOF:
	MVI	A,EOT		;SEND AN 'EOT'
	CALL	SEND
	CALL	GETACK		;GET THE ACK
	JC	SENDEOF 	;LOOP IF NO ACK
	JMP	EXITLG		;ALL DONE
;.....
;
;
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
;			SUBROUTINES
;
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
;
; ---> TRAP:  Check for no file name or ambiguous name
;
TRAP	LXI	H,FCB+1 	;POINT TO FILE NAME
	MOV	A,M		;GET FIRST CHAR OF FILE NAME
	CPI	' '		;ANY THERE?
	JNZ	ATRAP		;YES, CHECK FOR AMBIGOUS FILE NAME
	CALL	ERXIT		;PRINT MSG, EXIT
	DB	CR,LF,'++No File Name Specified++',CR,LF
	DB	'SYNTAX:',CR,LF
	DB	'LMODEM <library> <member>',CR,LF
	DB	'Where <library> is the file name for a '
	DB	'.LBR file, i.e. "TEST.LBR" or "TEST"',CR,LF
	DB	'and <member> is the FULL file name for a '
	DB	'member of that LBR file.',CR,LF
	DB	'(Find <member> with LDIR <library>).',CR,LF,'$'
;
ATRAP:
	MVI	B,11		;11 CHARS TO CHECK
TRLOOP:
	MOV	A,M		;GET CHAR FROM FCB
	CPI	'?'		;AMBIGUOUS?
	JZ	TRERR		;YES, EXIT WITH ERROR MSG
	INX	H		;POINT TO NEXT CHAR
	DCR	B		;ONE LESS TO GO
	JNZ	TRLOOP		;NOT DONE, CHECK SOME MORE
;
; Now see if he specified a LBR file.
; If not and if the type is empty, make it LBR.
;
	LXI	H,FCB+9
	MOV	A,M
	CPI	' '
	JZ	NOXT		;no extension in file name, make one.
	RET			;NO AMBIGUOUS NAME, RETURN
;
; NOXT: The file he specified didn't have an extension. Make it LBR.
;
NOXT:	LXI	D,LBRTYP
	MVI	B,3
NXLP:	LDAX	D
	MOV	M,A
	INX	D
	INX	H
	DCR	B
	JNZ	NXLP
	RET
;
LBRTYP:	DB	'LBR'
;
TRERR:
	CALL	ERXIT		;PRINT MSG, EXIT
	DB	CR,LF,'++Wild Card Options not allowed++',CR,LF,'$'
;
;
; ---> SENDHDR:  Send the sector header
;
; SEND: (SOH) (block #) (complemented block #)
;
SENDHDR:
	MVI	A,SOH		;SEND
	CALL	SEND		;   SOH,
	LDA	SECTNO		;THEN SEND
	CALL	SEND		;   SECTOR #
	LDA	SECTNO		;THEN SECTOR #
	CMA			;   COMPLEMENTED
	JMP	SEND		;   SECTOR #
;.....
;
;
; ---> SENDSEC:  Send the data sector
;
SENDSEC:
	MVI	C,0		;INIT CKSUM
	CALL	CLRCRC		;CLEAR THE CRC COUNTER
	LXI	H,BASE+80H	;POINT TO BUFFER
SENDC:
	MOV	A,M		;GET A CHAR
	CALL	SEND		;SEND IT
	INR	L		;POINT TO NEXT CHAR
	JNZ	SENDC		;LOOP IF <100H
	RET			;FROM SENDSEC
;.....
;
;
; ---> SENDCKS:  Send the checksum
;
SENDCKS:
	MOV	A,C		;SEND THE
	JMP	SEND		;   CHECKSUM
;.....
;
;
; ---> SENDCRC:  Send the two Cyclic Redundancy Check characters.  Call
;		 FINCRC to calculate the CRC which will be in 'DE' upon
;		 return.
;
SENDCRC:
	CALL	FINCRC		;CALC THE CRC FOR THIS SECTOR
	MOV	A,D		;PUT FIRST CRC BYTE IN ACCUM
	CALL	SEND		;SEND IT
	MOV	A,E		;PUT SECOND CRC BYTE IN ACCUM
	CALL	SEND		;SEND IT
	XRA	A		;SET ZERO RETURN CODE
	RET
;.....
;
;
; ---> GETACK:  Get the ACK on the sector
;
; Returns with carry clear if ACK received.  If an ACK is not received,
; the error count is incremented, and if less than "ERRLIM", carry is
; set and control returns.  If the error count is at "ERRLIM", the pro-
; gram aborts.
;
GETACK:
	MVI	B,10		;WAIT 10 SECONDS MAX
	CALL	RECVDG		;RECV W/GARBAGE COLLECT
	JC	GETATOT 	;TIMED OUT
	CPI	ACK		;OK? (CARRY OFF IF =)
	RZ			;YES, RET FROM GETACK
;
;
; Timeout or error on ACK - bump error count
;
ACKERR:
	LDA	ERRCT		;GET COUNT
	INR	A		;BUMP IT
	STA	ERRCT		;SAVE BACK
	CPI	ERRLIM		;AT LIMIT?
	RC			;NOT AT LIMIT
	CALL	ERXIT
	DB	CR,LF,'++Can''t send sector - Aborting++',CR,LF,'$'
;
; 
; Timeout getting ACK
;
GETATOT:
	JMP	ACKERR	;NO MSG
ABORT:
	LXI	SP,STACK
ABORTL:
	MVI	B,1		;1 SECOND WITHOUT CHARACTERS
	CALL	RECV
	JNC	ABORTL		;LOOP UNTIL SENDER DONE
	MVI	A,CAN		;CTL- X
	CALL	SEND		;STOP SENDING END
ABORTW:
	MVI	B,1		;1 SECOND WITHOUT CHRACTERS
	CALL	RECV
	JNC	ABORTW		;LOOP UNTIL SENDER DONE
	MVI	A,' '		;GET A SPACE...
	CALL	SEND		;TO CLEAR OUT CONTROL X
	CALL	ERXIT		;EXIT WITH ABORT MSG
	DB	CR,LF,'++LMODEM Program Cancelled++',CR,LF,'$'
;
;
; ---> INCRSNO:  Increment sector #
;
INCRSNO:
	PUSH	H		;INCREMENT RECORD NUMBER
	LHLD	SECTNO
	INX	H
	SHLD	SECTNO
	LXI	H,CONOUT	;CHECK FOR OPTIONAL COUNT TO CONSOLE
	MOV	A,H
	ORA	L		;IF 0, THEN NOPE, SO
	POP	H
	RZ			;RETURN
;...
;
;
DSPLY:
	MVI	A,1
	STA	CONONL		;SET LOCAL ONLY
	CALL	ILPRT
	DB	CR,'Record #',0
	LHLD	SECTNO
	CALL	DECOUT
	CALL	ILPRT
	DB	'  (',0
	CALL	DHXOUT
	CALL	ILPRT
	DB	'H)',0
	ORA	A
	STA	CONONL		;RESET LOCAL ONLY
	RET
;.....
;
; ---> OPENFIL:  Opens the file to be sent
;
OPENFIL:
	XRA	A		;SET EXT & REC # TO 0 FOR PROPER OPEN
	STA	FCBEXT
	STA	FCBSNO
	LXI	D,FCB		;POINT TO FILE
	MVI	C,OPEN		;GET FUNCTION
	CALL	BDOS		;OPEN IT
	INR	A		;OPEN OK?
	JNZ	OPENOK		;   YES
	CALL	ERXIT		;   NO, ABORT
	DB	CR,LF,'++Unable to open the file++',CR,LF,'$'
;
;
; Check for distribution-protected file
;
OPENOK:
	LDA	FCB+1		;FIRST CHAR OF FILE NAME
	ANI	80H		;CHECK BIT 7
	JNZ	OPENOT		;IF ON, FILE CAN'T BE SENT
	LDA	FCB+2		;ALSO CHECK "F2" FOR TAB
	ANI	80H		;IS IS SET?
	JZ	OPENOK2		;IF NOT, OK TO SEND FILE
OPENOT:
	CALL	ERXIT	;EXIT W/MESSAGE
	DB	CR,LF,'++File is Not for Distribution, Sorry++'
	DB	CR,LF,'$'
OPENOK2:
	LXI	D,80H
	MVI	C,STDMA
	CALL	BDOS
	MVI	C,READ
	LXI	D,FCB
	CALL	BDOS
	LHLD	8EH
	SHLD	DIRSZ
	LXI	D,MEMFCB
	LDAX	D
	CPI	' '
	JNZ	MOK
	CALL	ERXIT
	DB	'++No member name specified!++',CR,LF,'$'
;
MOK:	LXI	H,80H
	MOV	A,M
	ORA	A
	JZ	CKDIR		;check directory present?
BADLBR:	CALL	ERXIT
	DB	'++The file specified is not recognized '
	DB	'as LBR file!++',CR,LF,'$'
;
; CKDIR - check to see if there indeed is a LBR file
;	  directory and barf if not!
;
CKDIR:	MVI	B,11		;len of file name
	MVI	A,' '		;space
	INX	H
CKDLP:	CMP	M
	JNZ	BADLBR
	DCR	B
	INX	H
	JNZ	CKDLP
;
; The first entry in the LBR directory is indeed blank.
; Now see if the directory size is >0
;
	MOV	D,M
	INX	H
	MOV	A,M
	ORA	D
	JNZ	BADLBR
	INX	H
	MOV	A,M
	INX	H
	ORA	M
	JZ	BADLBR
	LXI	H,80H
;
; The next routine checks the LBR directory for the
; specified member name 1 sector at a time.
;
CMLP:	MOV	A,M
	ORA	A
	MVI	B,11
	INX	H
	JNZ	NOMTCH
CKLP:	LDAX	D
	CMP	M
	JNZ	NOMTCH
	INX	H
	INX	D
	DCR	B
	JNZ	CKLP
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
	SHLD	INDEX
	XCHG
	INX	H
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
	DCX	H
	SHLD	RCNT
	LHLD	INDEX
	DAD	H
	MOV	A,H
	STA	FCBEXT
	MOV	A,L
	RRC
	STA	FCBSNO
	LXI	D,FCB
	MVI	C,OPEN
	CALL	BDOS
	CPI	0FFH
	JZ	WHAT
	JMP	OPENOK3
;
WHAT:	CALL	ERXIT
	DB	'++Impossible error - notify SYSOP++',CR,LF,'$'
;
NOMTCH:	INX	H
	DCR	B
	JNZ	NOMTCH
	LXI	B,20
	DAD	B
	LXI	D,MEMFCB
	MOV	A,H
	ORA	A
	JZ	CMLP
	LHLD	DIRSZ
	MOV	A,H
	ORA	L
	JZ	NFOUND
	DCX	H
	SHLD	DIRSZ
	MVI	C,READ
	LXI	D,FCB
	CALL	BDOS
	LXI	H,80H
	LXI	D,MEMFCB
	JMP	CMLP
;
NFOUND:	CALL	ERXIT
	DB	'++Member file not in library++',CR,LF
	DB	'Run LDIR on the file and try again.',CR,LF,'$'
;
OPENOK3:
	CALL	ILPRT	;PRINT:
	DB	'File Open:  ',0
	LHLD	RCNT		;GET RECORD COUNT
	INX	H
	CALL	DECOUT		;PRINT DECIMAL NUMBER OF RECORDS
	CALL	ILPRT
	DB	' (',0
	CALL	DHXOUT		;NOW PRINT SIZE IN HEX
	CALL	ILPRT
	DB	' Hex) Records',CR,LF
	DB	'Send Time:  ',0

	IF	LSPEED
	LDA	MSPEED		;GET THE SPEED INDICATOR
	ENDIF
;
	IF	NOT LSPEED
	LDA	SPEED		;DEFAULT TO PRESET SPEED AT 0103H
	ENDIF
;	
	LXI	D,0
	MOV	E,A		;SET UP FOR TABLE ACCESS
	LXI	H,BTABLE	;POINT TO BAUD FACTOR TABLE
	DAD	D		;INDEX TO PROPER FACTOR
	MOV	A,M		;FACTOR IN 'A'
;	
	LHLD	RCNT		;GET NUMBER OF RECORDS
	INX	H
	CALL	DIVHLA		;DIVIDE HL BY VALUE IN A (RECORDS/MIN)	
	PUSH	H
;
	IF	LOGCAL
	SHLD	PGSIZE
	ENDIF
;
	MVI	H,0
	CALL	DECOUT		;PRINT DECIMAL NUMBER OF MINUTES
	CALL	ILPRT
	DB	' mins, ',0
	LXI	H,SECTBL	;POINT TO DIVISORS FOR SECONDS CALC.
	LXI	D,0
;
	IF	LSPEED
	LDA	MSPEED		;GET INDEX FOR BAUD RATE
	ENDIF
;
	IF	NOT LSPEED
	LDA	SPEED
	ENDIF
;
	MOV	E,A
	DAD	D		;INDEX INTO TABLE
	MOV	A,M		;GET MULTIPLIER
	POP	H		;GET REMAINDER
	CALL	MULHA		;MULTIPLY 'H' BY 'A'
	CALL	SHFTHL
	CALL	SHFTHL
	CALL	SHFTHL
	CALL	SHFTHL	
;
	MVI	H,0
	CALL	DECOUT
;
	IF	LSPEED
	LDA	MSPEED		;GET BAUD RATE CODE
	ENDIF
;
	IF	NOT LSPEED
	LDA	SPEED		;DEFAULT TO PRESET SPEED AT 0103H
	ENDIF
;
	CPI	0		;110 BAUD?
	JNZ	MS300		;NO-CHECK 300
MS110:
	CALL	ILPRT
	DB	' secs at 110 Baud',CR,LF,0
	JMP	MSCTLX
;...
;
;
MS300:
	CPI	1		;300 BAUD?
	JNZ	MS450		;NO-CHECK 450
	CALL	ILPRT
	DB	' secs at 300 Baud',CR,LF,0
	JMP	MSCTLX
;...
;
;
MS450
	CPI	2		;450 BAUD?
	JNZ	MS600		;NO-CHECK 600
	CALL	ILPRT
	DB	' secs at 450 Baud',CR,LF,0
	JMP	MSCTLX
;.....
;
;
MS600:
	CPI	3		;600 BAUD?
	JNZ	MS710		;NO-CHECK 710
	CALL	ILPRT
	DB	' secs at 600 Baud',CR,LF,0
	JMP	MSCTLX
;...
;
;
MS710:
	CPI	4		;710 BAUD?
	JNZ	MS1200		;NO-MUST BE 1200
	CALL	ILPRT
	DB	' secs at 710 Baud',CR,LF,0
	JMP	MSCTLX
;...
;
;
MS1200:
	CALL	ILPRT		;MUST BE 1200 - NO OTHERS SUPPORTED
	DB	' secs at 1200 Baud',CR,LF,0
;...
;
;
MSCTLX	CALL	ILPRT
	DB	'Use CTL-X to Cancel',CR,LF,0
	RET
;...
;
;
BTABLE:	DB	5,13,19,25,29,49,0
SECTBL:	DB	192,74,51,38,33,20,0
;...
;
;
; ---> DIVHL-A:  Divides 'HL' by value in 'A',
;	 UPON EXIT: L=QUOTIENT,H=REMAINDER
;
DIVHLA:
	PUSH	B
	MVI	B,8		;SHIFT FACTOR TO 'B'
	MOV	C,A		;DIVISOR TO 'C'
DIV2:
	XRA	A		;CLEAR CARRY FLAG AND ACCUMULATOR
	DAD	H
	MOV	A,H
	SUB	C
	JM	DIV3		;DONT BORROW ON NEG RESULTS
	MOV	H,A
	MOV	A,L
	ORI	1		;BORROW 1
	MOV	L,A
DIV3:
	DCR	B
	JNZ	DIV2
	POP	B
	RET
;...
;
;
; ---> MULHA:  Multiply the value in 'H' by the value in 'A'
;	 Return with answer in 'HL'.
;
MULHA:
	MOV	B,A		;PUT LOOP COUNT IN 'B'
	MVI	D,0
	MOV	E,H
	MOV	L,H
	MVI	H,0
MULLP:
	DCR	B
	RZ
	DAD	D
	JMP	MULLP
	RET
;
;
; Shift the 'HL' pair one bit to the right
;
SHFTHL:
	MOV	A,L
	RAR
	MOV	L,A
	ORA	A		;CLEAR THE CARRY BIT
	MOV	A,H
	RAR
	MOV	H,A
	RNC
	MVI	A,80h
	ORA	L
	MOV	L,A
	RET
;.....
;
; ---> DECOUT:  Decimal output routine
;
DECOUT:
	PUSH	B
	PUSH	D
	PUSH	H
	LXI	B,-10
	LXI	D,-1
DECOU2:
	DAD	B
	INX	D
	JC	DECOU2
	LXI	B,10
	DAD	B
	XCHG
	MOV	A,H
	ORA	L
	CNZ	DECOUT
	MOV	A,E
	ADI	'0'
	CALL	CTYPE
	POP	H
	POP	D
	POP	B
	RET
;.....
;
;
; ---> DHXOUT: Double precision hex output routine.
;	 Call with hex value in 'HL'.
;
DHXOUT:
	PUSH	H		;SAVE H,L
	PUSH	PSW		;SAVE A
	MOV	A,H		;GET MS BYTE
	CALL	HEXO		;OUTPUT HIGH ORDER BYTE
	MOV	A,L		;GET LS BYTE
	CALL	HEXO		;OUTPUT LOW ORDER BYTE
	POP	PSW		;RESTORE A
	POP	H		;RESTORE H,L
	RET			;RETURN TO CALLER
;
;
; ---> RDSECT:  Reads a sector
;
; For speed, this routine buffers up 16 sectors at a time.
;
RDSECT:	LDA	SECNBF		;GET # SECT IN BUFF
	DCR	A		;DECREMENT
	STA	SECNBF		;   IT
	JM	RDBLOCK 	;EXHAUSTED?  NEED MORE
	LHLD	SECPTR		;GET POINTER
	LXI	D,BASE+80H	;TO DATA
	CALL	MOVE128 	;MOVE TO BUFFER
	SHLD	SECPTR		;SAVE BUFFER POINTER
	RET			;FROM "READSEC"
;.....
;
;
; Buffer is empty - read in another block of 16
;
RDBLOCK:
	LDA	EOFLG		;GET 'EOF' FLAG
	CPI	1		;IS IT SET?
	STC			;TO SHOW 'EOF'
	RZ			;GOT 'EOF'
	MVI	C,0		;SECTORS IN BLOCK
	LXI	D,DBUF		;TO DISK BUFFER
;
RDSECLP:
	PUSH	B
	PUSH	D
	MVI	C,STDMA 	;SET DMA ADDRESS
	CALL	BDOS
	LXI	D,FCB
	MVI	C,READ
	CALL	BDOS
	POP	D
	POP	B
	ORA	A		;READ OK?
	JZ	RDSECOK 	;YES
	DCR	A		;'EOF'?
	JZ	REOF		;GOT 'EOF'
;
;
; Read error
;
	CALL	ERXIT
	DB	CR,LF,'++File Read Error++',CR,LF,'$'
;
RDSECOK:
	INR	C
	LXI	H,80H		;ADD LENGTH OF ONE SECTOR
	DAD	D		;   TO NEXT BUFF
	XCHG			;BUFF TO DE
	MOV	A,C		;GET COUNT
	CPI	16		;DONE?
	JZ	RDBFULL 	;   YES, BUFF IS FULL
	JMP	RDSECLP 	;READ MORE
;...
;
;
REOF:
	MVI	A,1
	STA	EOFLG		;SET EOF FLAG
	MOV	A,C
;
;
; Buffer is full, or got EOF
;
RDBFULL:
	STA	SECNBF		;STORE SECTOR COUNT
	LXI	H,DBUF		;INIT BUFFER POINTEAR
	SHLD	SECPTR
	LXI	D,BASE+80H	;RESET DMA ADDRESS 
	MVI	C,STDMA
	CALL	BDOS
	JMP	RDSECT		;PASS SECT TO CALLER
;
;---->	RECV:  Receive a character
;
; Timeout time is in B, in seconds.  Entry via "RECVDG" deletes garbage
; characters on the line.  For example, having just sent a sector, 
; calling RECVDG will delete any line-noise-induced characters "long"
; before the ACK/NAK would be received.
;
RECVDG:
	IN	MODDATP 	;GET A CHAR
	IN	MODDATP 	;   TOTALLY PURGE UART
RECV:
	PUSH	D		;SAVE
;
	IF	FASTCLK 	;4MHZ?
	MOV	A,B		;GET TIME REQUEST
	ADD	A		;DOUBLE IT
	MOV	B,A		;NEW TIME IN B
	ENDIF
MSEC:
	LXI	D,50000 	;1 SECOND DCR COUNT
;
	IF	NOT DCH
MWTI:
	IN	MODCTLP 	;CHECK STATUS
	ENDIF
;
	IF	DCH
MWTI:
	IN	MODCTL2 	;CHECK STATUS
	ENDIF
;
	IF	PMMI AND FRNTPNL
	OUT	PANEL		;DISPLAY STATUS ON PANEL LIGHTS
	ENDIF
;
	ANI	MODRCVB 	;ISOLATE BIT
	CPI	MODRCVR 	;READY?
	JZ	MCHAR		;GOT CHAR
	DCR	E		;COUNT
	JNZ	MWTI		;   DOWN
	DCR	D		;   FOR
	JNZ	MWTI		;   TIMEOUT
	DCR	B		;MORE SECONDS?
	JNZ	MSEC		;YES, WAIT
;
;
; Test for the presence of carrier - if none, go to CARCK and continue
; testing for 15 seconds. If carrier returns, continue. If is doesn't
; return, exit.
;
	IF	EXTMOD OR H8 OR DCH
	IN	MODCTL2		;READ MODEM STATUS
	ENDIF
;
	IF	PMMI
	IN	BAUDRP		;READ MODEM STATUS
	ENDIF
;
	IF	PMMI AND FRNTPNL
	OUT	PANEL		;DISPLAY STATUS ON PANEL LIGHTS
	ENDIF
;
	ANI	MODDCDB		;CARRIER DETECT MASK
	CPI	MODDCDA		;IS IT STILL ON?
	CNZ	CARCK		;IF NOT, TEST FOR 15 SECONDS
;
; Modem timed out receiving - but carrier still on.
;
	POP	D		;RESTORE D,E
	STC			;CARRY SHOWS TIMEOUT
	RET
;.....
;
;
; Got character from modem.  Check to see if there was a framing error,
; overrun, or parity error.
;
MCHAR:
	IF	PMMI OR H8
	IN	MODCTLP		;GET MODEM STATUS
	ENDIF
;
	IF	DCH
	IN	MODCTL2		;GET MODEM STATUS
	ENDIF
;
	IF	PMMI OR H8 OR DCH
	MOV	D,A		;SAVE STATUS
	ANI	MODFRME		;FRAMING ERROR?
	CPI	MODFRME
	JNZ	MCHAR2		;NO, CHECK FOR OVERRUN
	LDA	ERRCDE		;GET RECV ERR CODE
	ORI	MODFRME		;TURN ON RECV ERR CODE
	STA	ERRCDE		;PUT IT BACK
MCHAR2:
	MOV	A,D		;RESTORE MODEM STATUS
	ANI	MODOVRE		;OVERRUN?
	CPI	MODOVRE
	JNZ	MCHAR3		;NO, CHECK FOR PARITY ERROR
	LDA	ERRCDE
	ORI	MODOVRE		;TURN ON RECV ERR CODE
	STA	ERRCDE
MCHAR3:
	MOV	A,D		;RESTORE MODEM STATUS
	ANI	MODPARE		;PARITY ERROR?
	CPI	MODPARE
	JNZ	MCHAR4		;NO, GET DATA CHAR
	LDA	ERRCDE
	ORI	MODPARE
	STA	ERRCDE
MCHAR4:
	ENDIF			;PMMI OR H8 OR DCH
;
;
; Get data char
;
	IN	MODDATP 	;READ THE CHAR
	POP	D		;RESTORE 'DE'
;
;
; Calculate checksum and CRC
;
	PUSH	PSW		;SAVE THE CHAR
	CALL	UPDCRC		;CALC CRC
	ADD	C		;ADD TO CHECKSUM
	MOV	C,A		;SAVE CHECKSUM
	POP	PSW		;RESTORE CHAR
	ORA	A		;CARRY OFF: NO ERROR
	RET			;FROM "RECV"
;.....
;
;
; CARCK - common 15 second carrier test for RECV and SEND.  If carrier
; returns within 15 seconds, normal program execution continues.  Else,
; it will abort to CP/M via EXIT.
;
CARCK:
	MVI	E,150		;VALUE FOR 15 SECOND DELAY
CARCK1:
	CALL	DELAY		;KILL .1 SECONDS
;
	IF	EXTMOD OR H8 OR DCH
	IN	MODCTL2		;READ MODEM STATUS
	ENDIF
;
	IF	PMMI
	IN	BAUDRP		;READ MODEM STATUS
	ENDIF
;
	IF	PMMI AND FRNTPNL
	OUT	PANEL		;DISPLAY STATUS
	ENDIF
;
	ANI	MODDCDB		;CARRIER DETECT MASK
	CPI	MODDCDA		;IS IT STILL ON?
	RZ			;RETURN IF CARRIER ON
	DCR	E		;HAS 15 SECONDS EXPIRED?
	JNZ	CARCK1		;IF NOT, CONTINUE TESTING
	JMP	EXIT		;ELSE, ABORT TO CP/M.
;
;
; DELAY - 100 millisecond delay.
;
DELAY:
	PUSH	B		;SAVE B,C
;
	IF	FASTCLK		;IF 4MHZ CLOCK
	LXI	B,16667		;VALUE FOR 100MS DELAY
	ENDIF
;
	IF	NOT FASTCLK
	LXI	B,8334		;VALUE FOR 100MS DELAY
	ENDIF
DELAY2:
	DCX	B		;UPDATE COUNT
	MOV	A,B		;GET MS BYTE
	ORA	C		;COUNT = ZERO?
	JNZ	DELAY2		;IF NOT, CONTINUE
	POP	B		;RESTORE B,C
	RET			;RETURN TO CARCK1.
;.....
;
;
; ---> SEND:  Send a character to the modem
;
SEND:
	PUSH	PSW		;SAVE THE CHARACTER
	CALL	UPDCRC		;CALC THE CRC
	ADD	C		;CALC CKSUM
	MOV	C,A		;SAVE CKSUM
;
	IF	NOT DCH
SENDW:
	IN	MODCTLP 	;GET STATUS
	ENDIF
;
	IF	DCH
SENDW:
	IN	MODCTL2 	;GET STATUS
	ENDIF
;
	IF	PMMI AND FRNTPNL
	OUT	PANEL		;DISPLAY STATUS
	ENDIF
;
	ANI	MODSNDB 	;ISOLATE READY BIT
	CPI	MODSNDR 	;READY?
	JZ	SENDR		;   YES, GO SEND
;
;
; Xmit status not ready, so test for carrier before looping - if lost,
; go to CARCK and give it up to 15 seconds to return.  If it doesn't,
; return abort via EXIT.
;
	PUSH	D		;SAVE 'DE'
;
	IF	EXTMOD OR H8 OR DCH
	IN	MODCTL2		;READ MODEM STATUS
	ENDIF
;
	IF	PMMI
	IN	BAUDRP		;READ MODEM STATUS
	ENDIF
;
	IF	PMMI AND FRNTPNL
	OUT	PANEL		;DISPLAY STATUS
	ENDIF
;
	ANI	MODDCDB		;CARRIER DETECT MASK
	CPI	MODDCDA		;IS IT STILL ON?
	CNZ	CARCK		;IF NOT, CONTINUE TESTING IT
	POP	D		;RESTORE D,E
	JMP	SENDW		;ELSE, WAIT FOR XMIT READY.
;.....
;
;
; Xmit status ready, carrier still on - send the data.
;
SENDR:
	POP	PSW		;GET CHAR
	OUT	MODDATP 	;OUTPUT IT
	RET			;FROM "SEND"
;
; ---> WAITNAK:  Waits for initial NAK
;
; To ensure no data is sent until the receiving program is ready, this
; routine waits for the first timeout-NAK or the letter 'C' for CRC
; from the receiver.  If CRC is in effect, then Cyclic Redundancy Checks
; are used instead of checksums.  'E' contains the number of seconds to
; wait.
;
; If the first character received is a CAN (CTL-X) then the send will be
; aborted as though it had timed out.
;
WAITNAK:
	MVI	B,1		;TIMEOUT DELAY
	CALL	RECV		;DID WE GET
	CPI	NAK		;   A NAK?
	RZ			;YES, SEND BLOCK
	CPI	CRC		;CRC INDICATED?
	JZ	WAITCRC		;YES, GO PUT CRC IN EFFECT
	CPI	CAN		;WAS IT A CANCEL (CTL-X)?
	JZ	ABORT		;YES, ABORT
	DCR	E		;80 TRIES?
	JZ	ABORT		;YES, ABORT
	JMP	WAITNAK 	;NO, LOOP
;.....
;
;
; ---> WAITCRC:  Turn on CRC Flag
;
WAITCRC:
	XRA	A		;ZERO ACCUM
	STA	CRCFLG		;TURN ON CRC OPT
	RET
;.....
;
;
; ---> MOVEFCB:  Moves FCB(2) to MEMFCB
;
; Saves the member file name into MEMFCB
;
MOVEFCB:
	LXI	H,FCB+16	;FROM
	LXI	D,MEMFCB-1	;TO
	MVI	B,16		;LEN
	CALL	MOVE		;DO THE MOVE
	XRA	A		;GET 0
	STA	FCBSNO		;ZERO SECTOR #
	STA	FCBEXT		;   AND EXTENT
	RET
;.....
;
;
CTYPE:
	PUSH	B		;SAVE ALL REGISTERS
	PUSH	D
	PUSH	H
	PUSH	PSW		;SAVE THE CHARACTER TEMPORARILY
	LDA	CONONL		;LOCAL ONLY?
	ORA	A
	JNZ	CLTYP		;YES, TO TO BIOS OUT
	POP	PSW		;ELSE GET THE CHARACTER BACK
	MOV	E,A		;CHARACTER TO 'E'
	MVI	C,WRCON 	;WRITE TO CONSOLE
	CALL	BDOS		;PRINT THE CHARACTER
	POP	H		;RESTORE
	POP	D		;   ALL
	POP	B		;   REGS
	RET			;FROM "CTYPE"
;...
;
;
CLTYP:
	POP	PSW		;GET THE CHARACTER BACK
	MOV	C,A		;BIOS NEEDS IT IN 'C'
	CALL	CONOUT		;DO BIOS CALL
	POP	H		;ALL THIS
	POP	D		;   IS FROM
	POP	B		;   CTYPE ROUTINE
	RET
;.....
;
;
HEXO:
	PUSH	PSW		;SAVE FOR RIGHT DIGIT
	RAR			;RIGHT
	RAR			;   JUSTIFY
	RAR			;   LEFT
	RAR			;   DIGIT
	CALL	NIBBL		;PRINT LEFT DIGIT
	POP	PSW		;RESTORE RIGHT
NIBBL:
	ANI	0FH		;ISOLATE DIGIT
	CPI	10		;IS IT <10?
	JC	ISNUM		;YES, NOT ALPHA
	ADI	7		;ADD ALPHA BIAS
ISNUM:
	ADI	'0'		;MAKE PRINTABLE
	JMP	CTYPE		;   THEN TYPE IT
;.....
;
;
; ---> ILPRT:  Inline print of message
;
; The call to ILPRT is followed by a message, binary 0 for its end.
;
ILPRT:
	XTHL			;SAVE HL, GET HL=MSG
;
ILPLP:
	MOV	A,M		;GET CHAR
	ORA	A		;END OF MSG?
	JZ	ILPRET		;   YES, RETURN
	CALL	CTYPE		;TYPE THE MSG
	INX	H		;TO NEXT CHAR
	JMP	ILPLP		;LOOP
;...
;
ILPRET:
	XTHL			;RESTORE HL
	RET			;PAST MSG
;.....
;
;
EXITLG:				; SPECIAL LOG CALLER EXIT
	IF	LOGCAL
	JMP	LOGCALL
	ENDIF
;
	JMP	EXIT
;.....
;
;
; ---> ERXIT:  Exit printing message following call
;
ERXIT:
	POP	D		;GET MESSAGE
	MVI	C,PRINT 	;GET BDOS FNC
	CALL	BDOS		;PRINT MESSAGE
EXIT:
	LHLD	STACK		;GET ORIGINAL STACK
	SPHL			;RESTORE IT
;
	RET			;--EXIT-- TO CP/M
;
;
; Move 128 characters from 'HL' to 'DE' length in 'B'
;
MOVE128:
	MVI	B,128		;SET MOVE COUNT
MOVE:
	MOV	A,M		;GET A CHAR
	STAX	D		;STORE IT
	INX	H		;TO NEXT "FROM"
	INX	D		;TO NEXT "TO"
	DCR	B		;MORE?
	JNZ	MOVE		;   YES, LOOP
	RET			;   NO, RETURN
;.....
;
;
;***********************************************************************
;
; CRCSUBS (Cyclic Redundancy Code Subroutines) version 1.20
; 8080 Mnemonics
;
; These subroutines will compute and check a true 16-bit Cyclic Redun-
; dancy Code for a message of arbitrary length.
;
; (Theory and appliction are discussed extensively in the LMODEMxx.HIS
; file.  See that for additional information.)
;
;***********************************************************************
;
;
; ENTRY	CLRCRC,UPDCRC,FINCRC,CHKCRC
;
CLRCRC:
	PUSH	H		;RESET CRC ACCUMULATOR FOR A NEW MSG.
	LXI	H,0
	SHLD	CRCVAL
	POP	H
	RET
;
UPDCRC:
	PUSH	PSW		;UPDATE CRC ACCUMULATOR WITH BYTE IN 'A'
	PUSH	B
	PUSH	H
	MVI	B,8
	MOV	C,A
	LHLD	CRCVAL
UPDLOOP:
	MOV	A,C
	RLC
	MOV	C,A
	MOV	A,L
	RAL
	MOV	L,A
	MOV	A,H
	RAL
	MOV	H,A
	JNC	SKIPIT
;
	MOV	A,H		;The generator is X^16 + X^12 + X^5 + 1
	XRI	10H		;as recommended by CCITT.  An alternate
	MOV	H,A		;generator which is often used in
	MOV	A,L		;synchronous transmission protocols is
	XRI	21H		;X^16 + X^15 + X^2 + 1. This may be used
	MOV	L,A		;by substituting XOR 80H for XOR 10H and
SKIPIT:
	DCR	B		;XOR 05H for XOR 21H in the adj. code.
	JNZ	UPDLOOP
	SHLD	CRCVAL
	POP	H
	POP	B
	POP	PSW
	RET
;
FINCRC:
	PUSH	PSW		;FINISH CRC CALC FOR OUTBOUND MSG.
	XRA	A
	CALL	UPDCRC
	CALL	UPDCRC
	PUSH	H
	LHLD	CRCVAL
	MOV	D,H
	MOV	E,L
	POP	H
	POP	PSW
	RET
;.....
;
CRCVAL:	DW	0
;
;
;
; Temporary storage area
;
	DB	0
MEMFCB:	DS	16
;
DIRSZ:	DW	0
MAXEXT:	DB	0		;HIGHEST EXT. # SEEN IN FILE SIZE CALC.
SECTNO:	DW	0		;CURRENT SECTOR NUMBER 
ERRCT:	DB	0		;ERROR COUNT
OPTSAV:	DB	0		;SAVE OPTION HERE FOR CARRIER LOSS
CONONL:	DB	0		;CTYPE CONSOLE-ONLY FLAG		
INDEX:	DW	0
;
	IF	PMMI OR H8 OR DCH
ERRCDE:	DB	0		;RECEIVE ERROR CODE
	ENDIF
;
CRCFLG:	DB	'C'		;SET TO NULL IF CRC USED
RCNT:	DW	0		;RECORD COUNT
;
;
; Following 3 used by disk buffering routines
;
EOFLG:	DB	0		;'EOF' FLAG (1=TRUE)
SECPTR:	DW	DBUF
SECNBF:	DB	0		;# OF SECTORS IN BUFFER
	DS	60		;STACK AREA
;
STACK:	DS	2		;STACK POINTER
;
;
; 16 sector disk buffer
;
DBUF:	DS	0		;16 SECTOR DISK BUFFER
;
; BDOS equates
;
RDCON	EQU	1
WRCON	EQU	2
PRINT	EQU	9
CONST	EQU	11		;CONSOLE STAT
SELDRV	EQU	14		;SELECT DRIVE
OPEN	EQU	15		;0FFH = NOT FOUND
CLOSE	EQU	16		;	"       "
SRCHF	EQU	17		;	"       "
SRCHN	EQU	18		;	"       "
ERASEF	EQU	19		;NO RET CODE
READ	EQU	20		;0=OK, 1=EOF
WRITE	EQU	21		;0=OK, 1=ERR, 2=?, 0FFH=NO DIR SPC
MAKE	EQU	22		;0FFH=BAD
REN	EQU	23		;0FFH=BAD
CURDRV	EQU	25		;GET CURRENT DRIVE
STDMA	EQU	26		;SET DMA
USER	EQU	32		;SET USER AREA TO RECEIVE FILE
BDOS	EQU	BASE+5
FCB	EQU	BASE+5CH	;SYSTEM FCB
FCBEXT	EQU	FCB+12		;FILE EXTENT
FCBSNO	EQU	FCB+32		;SECTOR #
;.....
;
;
	END
	EQU	BASE+5
FCB	EQU	BASE+5CH	;S