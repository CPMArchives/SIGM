;
;			  MCQXS798.ASM
;
;	Patches for overlaying distribution version of MODEM798
;to work with EPSON QX-10 computer and DC Hayes Smartmodem 1200.
;
;You will want to look this file over carefully, there are a number
;of options that you can use to configure MODEM798 to suit your taste.
;
;After you have finished editing this file use DDT to overlay the HEX
;file onto MODEM798 and SAVE 64 MODEM798.COM.
;
;All users should set CLOCK to the right value for their system.
;
;PMMI users should set PUSERATE and CLDBOOT to their proper values.
;
;Non-PMMI, non-QX-10 users who want to get MODEM798 working quickly
;and who do not need to set their modem parameters using this program
;should change VERMSG, INIT, SETUP, CLEAR and PMMI to FALSE and
;change the equates for MODDATP, MODCTLP, MODSNDB, MODSNDR, MODRCVB
;and MODRCVR before assembly.
;
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original MODEM798.COM file:
;
;		A>DDT MODEM798.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4080 0100
;		-IMCQXS798.HEX		(note the "I" command)
;		-R			(loads in the .HEX file)
;		NEXT  PC
;		4080 0000
;		-G0			(return to CP/M)
;		A>SAVE 64 MODEM798.COM  (now have modified .COM file)
;
;12/31/82 - Fixed "illegal FCB" bug when batch mode and smart-
;	    modem commands are used together.			;BRR
;
;12/27/82 - Added additional command-line baud rates.		;BRR
;
;12/26/82 - Modified to allow baud rate on SET command line	;BRR
;	    Also added smartmodem command logic.
;
;12/24/82 - Modified to work with version 7.97 of MODEM7	;BRR
;
;12/20/82 - Modified to work with version 7.96 of MODEM7	;B. RATOFF
;
;12/08/82 - Modified to work with version 7.95 of MODEM7	;G. KANTOR
;
;11/26/82 - Modified to work with version 7.94 of MODEM7	;PLK
;
;11/19/82 - Modified to work with version 7.92 of MODEM7	;PLK
;
;11/02/82 - Modified to work with version 7.90 of MODEM7.
;	    Included "how to use" instructions at start of file. ;IMH
;
;10/20/82 - Modified to work with version 7.89 of MODEM7.	;IMH
;
;10/16/82 - Modified to work with version 7.71 of MODEM7.	;PLK
;
;10/15/82 - Fixed lack of ENDIF after IF VERMSG AND (NOT PMMI)	;PLK
;
;10/12/82 - Modified to give version message.			;PLK
;
;10/09/82 - Modified to work with version 7.70 of MODEM7.	;PLK
;
;10/04/82 - Fixed so can also be easily used for making optional
;	    changes with PMMI modem.				;PLK
;
;10/03/82 - First version of this file.				;PLK
;
TRUE	EQU	0FFH
FALSE	EQU	0
;
BELL	EQU	07H	;bell
CR	EQU	0DH	;carriage return
LF	EQU	0AH	;linefeed
ESC	EQU	1BH	;escape
;
VERMSG	EQU	true 		;change to TRUE if you have given at
				;location SYSVERMSG the name of the
				;system for which MODEM7 has been
				;configured.
;
INIT	EQU	TRUE 		;change to TRUE if you have written a
				;routine at location INITMOD in this
				;file to initialize your modem port
				;on MODEM7 execution. PMMI users should
				;use FALSE here.
;
SETUP	EQU	TRUE 		;change to TRUE if you have written a
				;routine at location SETUPR to change
				;baud rate, etc and MSPEED. PMMI users
				;should use FALSE here.
;
EOSCLR	EQU	TRUE 		;change to TRUE if you have defined the
				;clear to end of screen sequence for
				;your terminal. Clear to end of screen is
				;used on returning from terminal mode to
				;keep the screen from becoming jumbled if
				;the remote can position your cursor.
;
SCRNCLR	EQU	true 		;change to TRUE if you have defined the
				;home cursor and clear screen sequence
				;for you terminal.

PMMI	EQU	FALSE		;change to TRUE for PMMI.
;
	IF	NOT PMMI
;THE FOLLOWING MUST BE CHANGED FOR YOUR MICRO IF YOU DON'T HAVE AN EPSON
;QX-10 OR A PMMI MODEM BOARD.
MODDATP	EQU	011H		;data port for QX-10
MODCTLP	EQU	MODDATP+2	;modem status port for QX-10
MODSNDB	EQU	04H		;bit to test for ready to send
MODSNDR	EQU	MODSNDB		;change to 0 if bit is 0 when
				;ready to send
MODRCVB	EQU	1		;bit to test for received data
MODRCVR	EQU	MODRCVB		;change to 0 if bit is 0 when
				;data received
	ENDIF	;NOT PMMI
;
;CHANGE CLR1, CLR2, CLR3, AND CLR4 TO THE APPROPRIATE VALUES FOR
;YOUR TERMINAL IF YOU DO NOT HAVE AN EPSON QX-10 AND EOSCLR IS TRUE.
	IF	EOSCLR
CLR1	EQU	1BH		;QX-10 Zapple clear to end
CLR2	EQU	'Y'		;of screen sequence
CLR3	EQU	0		;the unused bytes MUST be 0
CLR4	EQU	0
	ENDIF	;EOSCLR
;
;CHANGE SCLR1, SCLR2, SCLR3, AND SCLR4 TO THE APPROPRIATE VALUES FOR
;YOUR TERMINAL IF YOU DO NOT HAVE AN EPSON QX-10 AND SCRNCLR IS TRUE.
	IF	SCRNCLR
SCLR1	EQU	1ah		;EPSON QX-10 home cursor
SCLR2	EQU	0		;and clear screen sequence
SCLR3	EQU	0		;the unused bytes MUST be 0
SCLR4	EQU	0
	ENDIF	;SCRNCLR
;
;IF YOU HAVE A PMMI YOU MAY NEED TO CHANGE THE BASE ADDRESS.
;ALSO, CHANGE PORT NUMBER IN THE PMMI MESSAGE BELOW SYSVERMSG.
	 IF	PMMI
PORT	 EQU	0C0H	;PMMI BASE ADDRESS
MODCTLP	 EQU	PORT	;MODEM CONTROL PORT
MODDATP	 EQU	PORT+1	;MODEM DATA PORT
BAUDRP	 EQU	PORT+2	;BAUD RATE PORT
MODCTL2	 EQU	PORT+3	;2ND MODEM CONTROL PORT
	 ENDIF	;PMMI
;
;
;CLOCK SHOULD BE CHANGED TO SUIT YOUR SYSTEM.
;PMMI USERS SHOULD ALSO CHANGE PULSERATE AND CLDBOOT AS NECESSARY.
;
;You can change locations 107H to 120H, and 123H to 125H
;to suit your taste.
;
;*** WARNING - DO NOT INSERT OR DELETE LINES BEFORE SYSVERMSG: ***
;      THE DEFINED LOCATIONS ARE GIVEN ON THE RIGHT MARGIN.
;
;
	ORG 100H
;
		DS	3	;(for  JMP  START)
PMMIBYTE:	DB	PMMI	;don't change this line			103H
SETUPTST:	DB	SETUP	;don't change this line			104H
SCRNTEST:	DB	SCRNCLR	;test for home cursor and clear screen	105H
				;routine at CLRSCRN, don't change this
CLOCK:		DB	4	;clock rate in MHz, 8 MHz maximum	106H
BAKUPBYTE:	DB	TRUE 	;true=make .BAK file			107H
CKSUMDFLT:	DB	TRUE 	;true=default to Checksum checking	108H
				;false=default to CRC checking
TOGGLECRC:	DB	TRUE	;true=allow toggling of Checksum to CRC	109H
CONVBKSP:	DB	FALSE	;true=convert backspace to rub		10AH
TOGGLEBK:	DB	TRUE	;true=allow toggling of bksp to rub	10BH
ADDLF:		DB	FALSE	;true=add LF after CR			10CH
TOGGLELF:	DB	TRUE	;true=allow toggling of LF after CR	10DH
TRANLOGON:	DB	TRUE 	;true=allow transmission of logon	10EH
				;write logon sequence at location LOGON
SAVCCP:		DB	TRUE	;true=do not overwrite CCP		10FH
LOCONEXTCHR:	DB	FALSE	;true=local command if EXTCHR precedes	110H
				;false=not local command if EXTCHR precedes
TOGGLELOC:	DB	TRUE	;true=allow toggling of LOCONEXTCHR	111H
LSTTST:		DB	TRUE	;true=allow toggling of printer on/off	112H
				;in terminal mode, set to false if your
				;printer can't keep up with the modem
XOFFTST:	DB	true 	;true=allow testing of XOFF from remote 113H
				;while transmitting a file in terminal mode
XONWAIT:	DB	FALSE	;true=wait for XON after sending CR	114H
				;while transmitting a file in terminal mode
TOGXOFF:	DB	TRUE	;true=allow toggling of XOFF testing	115H
MSPEED:		DB	5	;0=110 1=300 2=450 3=600 4=710 5=1200   116H
				;6=2400 7=4800 8=9600
				;default modem speed, PMMI routines
				;reset this value and so should your own
				;modem routines
BYTDLY:		DB	0	;0=0 delay, 1=0.02 sec, -- ,9=0.18 sec	117H
				;default time to send character in	
				;terminal mode file transfer
CRDLY:		DB	0	;0=0 delay, 1=0.08 sec, -- ,9=0.72 sec	118H
				;default time for extra wait after CR
				;in terminal mode file transfer
BELRPT:		DB	30	;bell repeat time = value*0.03 sec	119H
EXITCHR:	DB	'E'-40H	; ^E = Exit without disconnect		11AH
LOGCHR:		DB	'O'-40H	; ^O = Send logon			11BH
LSTCHR:		DB	'P'-40H	; ^P = Toggle printer			11CH
UNSAVE:		DB	'W'-40H	; ^W = Close input text buffer		11DH
TRANCHR:	DB	'T'-40H ; ^T = Transmit file to remote		11EH
SAVECHR:	DB	'Y'-40H	; ^Y = Open input text buffer		11FH
EXTCHR:		DB	'^'-40H	; ^^ = Send next character		120H
;
;Equates used only by PMMI routines grouped together here.
PULSERATE:	DB	125	;125 for 20pps, 250 for 10pps on PMMI	121H
				;not used if PMMI FALSE
CLDBOOT:	DW	00000H	;currently set to warm boot with	122H
				;BYE routine for PMMI, put your cold
				;boot entry here if you have one and
				;desire to do on BYE
BRKCHR:		DB	'@'-40H ; ^@ = Transmit "BREAK" with PMMI	124H
CHGBAUD:	DB	'B'-40H	; ^B = Used with PMMI in terminal	125H
				;  mode to change baud rate on fly
DISCCHR:	DB	'D'-40H	; ^D = PMMI Disconnect			126H
;
IN$MODCTLP:	IN	MODCTLP ! RET	;in modem control port	     	127H
OUT$MODDATP:	OUT	MODDATP ! RET	;out modem data port		12AH
IN$MODDATP:	IN	MODDATP ! RET	;in modem data port		12DH
;
	IF	NOT PMMI
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready	130H
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready	133H
ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready	136H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of rcv. bit when ready	139H
		DS	15		;PMMI only calls		13CH
LOGONPTR:	DW	LOGON		;				14BH
JMP$INITMOD:	JMP	INITMOD		;go to user written routine	14DH
	ENDIF	;NOT PMMI
;
	IF	PMMI
		DS	12		;not changed			130H
IN$BAUDRP:	IN	BAUDRP	! RET	;in baudrate port		13CH
OUT$BAUDRP:	OUT	BAUDRP	! RET	;out baudrate port		13FH
OUT$MODCTL2:	OUT	MODCTL2	! RET	;out modem control port #2	142H
OUT$MODCTLP:	OUT	MODCTLP		;out modem control port		145H
		DS	9		;not changed			147H
		ENDIF	;PMMI
;
JMP$SETUPR:			;					150H
;
	IF 	SETUP	
		JMP	SETUPR
	ENDIF	;SETUP
;
	IF	NOT SETUP
		RET
		NOP
		NOP
	ENDIF	;NOT SETUP
;
CLREOS:		CALL	JMP$ILPRT	;				153H
;
	IF	EOSCLR
		DB	CLR1,CLR2,CLR3,CLR4,0
	ENDIF	;EOSCLR
;
	IF	NOT EOSCLR
		DB	0,0,0,0,0
	ENDIF	;NOT EOSCLR
;
		RET
;
CLRSCRN:	CALL	JMP$ILPRT	;				15CH
;
	IF	SCRNCLR
		DB	SCLR1,SCLR2,SCLR3,SCLR4,0
	ENDIF	;SCRNCLR
;
	IF	NOT	SCRNCLR
		DB	0,0,0,0,0
	ENDIF	;NOT SCRNCLR
;
		RET
;
JMP$ILPRT:	DS	3	;					165H
JMP$ILCOMP:	DS	3	;					168H
JMP$INBUFF:	DS	3	;					16BH
JMP$SYSVERMSG:
		IF	PMMI
		DS	3	;					16EH
		ELSE
		JMP	SYSVERMSG	;				16EH
		ENDIF
JMP$DIALPL:	DS	3	;					171H
JMP$DISCONNT:	DS	3	;					174H
;
SYSVERMSG:			;					16EH
;
	IF	(NOT VERMSG) AND (NOT PMMI)
	CALL	JMP$ILPRT
	DB	'Version for: UNSPECIFIED SYSTEM',CR,LF,0
			;NOTE: 0 MUST BE AT END OF ALL ILPRT MESSAGES
	RET
	ENDIF	;NOT VERMSG AND NOT PMMI
;
;This is where the message goes giving the system for
;which MODEM7 has been customized.
	IF	VERMSG AND (NOT PMMI)
	LXI	D,0CCCCH	;Take opportunity to force
	MVI	C,12		;TPM into CP/M 2.2 compatibility mode
	CALL	5
	CALL	SETMSPEED	;Adjust MSPEED for QX-10 CMOS value
	CALL	JMP$ILPRT
	DB	'Version for: EPSON QX-10 and Hayes Smartmodem 1200',CR,LF,0
	RET
	ENDIF	;VERMSG AND NOT PMMI
;
;
	IF	NOT PMMI
		;INSERT YOUR LOGON HERE, MUST END IN 0.
		;FOR A LOGON, PMMI USERS MUST MODIFY MODEM798.ASM
LOGON:
	DB	'+++'	; ATTENTION STRING FOR SMARTMODEM
	DB	0
	ENDIF	;NOT PMMI
;
	IF	(NOT INIT) AND (NOT PMMI)
INITMOD:
	RET
	ENDIF	;NOT INIT AND NOT PMMI
;
;*** WARNING - IF YOU MAKE INITMOD AND SETUPR TOO LONG YOU MAY	  ***
;*** GO BEYOND THE LENGTH OF THE PMMI INITMOD ROUTINE.		  ***
;*** YOU CAN MODIFY UP TO THE BYTE BEFORE NUMBLIB:		  ***
;*** NUMBLIB CURRENTLY IS AT 617H.				  ***
;*** IF YOU NEED MORE SPACE USE AN APPROPRIATE DS BEFORE NUMBLIB: ***
;
TPORTS	EQU	7		; TIMER SETUP PORT
TPORTC	EQU	6		; TIMER COUNTER PORT
;
CRAM	EQU	35		; CMOS RAM BAUD RATE STORAGE
MOSADR	EQU	3DH		; CMOS RAM ADDRESS PORT
MOSDAT	EQU	3CH		; CMOS RAM DATA PORT
;
DSBCD	MACRO
	DB	0EDH,52H
	ENDM
;
;
; MAKE MODEM'S SPEED FLAG MATCH QX-10'S
SETMSPEED:
	MVI	A,CRAM
	OUT	MOSADR
	IN	MOSDAT
	ANI	0FH
	LXI	H,MSPDTBL
	ADD	L
	MOV	L,A
	JNC	SETMSPD2
	INR	H
SETMSPD2:
	MOV	A,M
	STA	MSPEED
	RET
;
;
; THIS TABLE GIVES MSPEED VALUES FOR QX-10 CMOS BAUD RATE VALUES
; NOTE THAT LOWER RATES DO NOT MATCH AND APPROXIMATIONS ARE USED
MSPDTBL:
	DB	0,0,0,1,3,5,6,7,8
;
; THIS TABLE GIVES THE TIMER CHIP DIVISORS FOR EACH BAUD RATE
CSPDTBL:
	DW	110,1135 ; 0
	DW	135,924	 ; 1
	DW	150,832	 ; 2
	DW	300,416	 ; 3
	DW	600,208	 ; 4
	DW	1200,104 ; 5
	DW	2400,52	 ; 6
	DW	4800,26	 ; 7
	DW	9600,13	 ; 8
;
;
;
;The following routine changes the baud rate for the QX-10 from
;the MENU. Write your own routine here to change your modem
;parameters from the menu.
;
;
	IF	SETUP OR INIT
;
SETUPR:
	LDAX	D		;Look at passed-in byte count
	CPI	5		;Enuf for possible baud rate?
	JC	AGAIN		;No, prompt for one
	MOV	B,A		;Save byte count
	INX	D		;Point to first byte
	CALL	NXTARG		;Skip to next argument
	MOV	A,B
	JNC	SETUP1
AGAIN:	CALL	JMP$ILPRT
	DB	'Input Baud Rate: ',0
	LXI	D,KEYBUF
	CALL	JMP$INBUFF	;read baud rate from console
	LXI	D,KEYBUF+1
	LDAX	D
	INX	D
SETUP1:
	MOV	L,A		;Force null at end of buffer
	MVI	H,0
	DAD	D
	MVI	M,0
	LXI	H,0
GDLUP:
	LDAX	D
	ORA	A
	JZ	GDONE
	SUI	'0'
	JC	BADRATE
	CPI	10
	JNC	BADRATE
	MOV	B,H
	MOV	C,L
	DAD	H
	DAD	H
	DAD	B
	DAD	H
	MVI	B,0
	MOV	C,A
	DAD	B
	INX	D
	JMP	GDLUP
BADRATE:
	CALL	JMP$ILPRT
	DB	CR,LF,'++ Invalid baud rate -- try again ++',CR,LF,0
	JMP	AGAIN
GDONE:
	MOV	A,H
	ORA	L
	JZ	QUIT
;
; ENTER HERE WITH BAUD RATE IN HL TO SET BAUD RATE FROM INITMOD
;
FINDRATE:
	PUSH	H
	LXI	H,CSPDTBL
	SHLD	TBLADR
	POP	H
	LXI	B,900H
CLP:
	PUSH	H
	LHLD	TBLADR
	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	XTHL
	XCHG
	ORA	A
	DSBCD
	XCHG
	XTHL
	JZ	DOIT
	INX	H
	INX	H
	SHLD	TBLADR
	POP	H
	INR	C
	DCR	B
	JNZ	CLP
	JMP	BADRATE
;
DOIT:
	POP	D
	MVI	A,0B6H
	OUT	TPORTS
	MOV	A,M
	INX	H
	OUT	TPORTC
	MOV	A,M
	OUT	TPORTC
	CALL	IN$MODDATP
	CALL	IN$MODDATP
	MVI	A,CRAM
	OUT	MOSADR
	MOV	A,C
	OUT	MOSDAT
QUIT:
	JMP	SETMSPEED
;
NXTARG:
	CALL	SCNTOB
	RC
SCNNB:
	LDAX	D
	CPI	' '
	RNZ
	INX	D
	DCR	B
	JNZ	SCNNB
	STC
	RET
;
SCNTOB:
	LDAX	D
	CPI	' '
	RZ
	RC
	INX	D
	DCR	B
	JNZ	SCNTOB
	STC
	RET
;
;
TBLADR:	DW	0
;
KEYBUF	DB	5,0,0,0,0,0,0,0
;
	ENDIF	;SETUP OR INIT
;
;
	IF	INIT
INITMOD:
	LDAX	D		; GET COMMAND BYTE COUNT
	MOV	B,A
	INX	D
	MOV	L,A
	MVI	H,0		; FORCE CR AT END OF BUFFER
	DAD	D
	MVI	M,0DH
;
	PUSH	D
	PUSH	B
	LXI	D,5CH+9		; LOOK AT FIRST FILETYPE
	CALL	JMP$ILCOMP	; CHECK FOR VALID BAUD RATE
	DB	'110',0
	LXI	H,110
	JNC	GOTRATE
	CALL	JMP$ILCOMP
	DB	'300',0
	LXI	H,300
	JNC	GOTRATE
	CALL	JMP$ILCOMP
	DB	'600',0
	LXI	H,600
	JNC	GOTRATE
	CALL	JMP$ILCOMP
	DB	'120',0
	LXI	H,1200
	JNC	GOTRATE
	CALL	JMP$ILCOMP
	DB	'240',0
	LXI	H,2400
	JNC	GOTRATE
	CALL	JMP$ILCOMP
	DB	'480',0
	LXI	H,4800
	JNC	GOTRATE
	CALL	JMP$ILCOMP
	DB	'960',0
	LXI	H,9600
	JC	NORATE
GOTRATE:
	CALL	FINDRATE
NORATE:
	POP	B		; RESTORE COMMAND LINE BYTE COUNT
	POP	D		; RESTORE COMMAND LINE TEXT POINTER
SCNBSL:
	LDAX	D		; LOOK AT FIRST CHAR OF ARG
	CPI	'\'		; BACKSLASH?
	JZ	GOTBSL
	CALL	NXTARG
	JNC	SCNBSL
	RET
GOTBSL:
	MVI	A,0DH		; MAKE STUFF AFTER \ DISAPPEAR
	STAX	D		; SO MFACCESS ISN'T CONFUSED
	INX	D
	LXI	H,6CH+1		; POINT TO 2ND FCB
	MOV	A,M
	CPI	'\'		; DID WE WIND IN 2ND FILENAME?
	JNZ	BSLOK		; NO, SKIP AHEAD
	DCX	H
	MVI	M,0		; ZAP DRIVE OF 2ND FCB
	MVI	B,11
ZFL1:
	INX	H
	MVI	M,' '
	DCR	B
	JNZ	ZFL1
	MVI	B,4
ZFL2:
	INX	H
	MVI	M,0
	DCR	B
	JNZ	ZFL2
BSLOK:
	CALL	MIN		; EMPTY GARBAGE CHARS FROM MODEM
	JNC	BSLOK		; LOOP TILL TIMEOUT
	LXI	H,ATS		; SEND INITIAL STRING TO MODEM
	CALL	SEND
	CALL	GET		; LOOK FOR REPLY
TIM:
	JC	TIMOT		; WE MIGHT HAVE TIMED OUT
	JNZ	ERR
	LXI	H,AT		; GET ATTENTION STRING
	CALL	SEND		; SEND IT
	XCHG			; NOW SEND OUR COMMAND
	CALL	SEND
	MVI	C,CR		; END IT WITH RETURN
	CALL	PUT
	CALL	MIN		; READ THE ECHOED CR
	CALL	GETX		; GET RESULT (NO TIMEOUT)
	JNZ	ERR
	CPI	'1'		; ON LINE?
	JZ	ONLIN
	CPI	'5'		; ON LINE 1200?
	JZ	ONLIN
	CPI	'0'		; OTHER NORMAL RESULT?
	RZ			; YUP, QUIT
	PUSH	PSW		; SAVE STATUS
	LXI	H,ATV1
	CALL	SEND		; RESTORE VERBOSE MODE
	POP	PSW
	CPI	'3'
	JZ	CAR		; NO CARRIER ?
	CPI	'4'
	JZ	BAD		; BAD COMMAND?
ERR:
	CALL	JMP$ILPRT
	DB	CR,LF,'Bad response from DC Hayes.',0
	RET
GET:
	CALL	MIN		; READ WITH TIMEOUT
	RC
	MOV	C,A		; SAVE CHAR
	CALL	MIN
	RC
	CPI	CR		; 2ND SHOULD BE CR
	MOV	A,C
	RET
GETX:
	CALL	MINX		; READ W/O TIMEOUT FOR RESULT
	MOV	C,A		; COULD TAKE A WHILE FOR DIALING, ETC.
	CALL	MINX		; GET FOLLOWING CR
	CPI	CR
	MOV	A,C
	RET
MINX:
	CALL	MRCVRDY		; CHECK FOR A CHAR
	JZ	MXGOT		; JUMP IF WE GOT ONE
	PUSH	B
	PUSH	D
	PUSH	H
	MVI	C,11		; DO ABORT CHECK
	CALL	5
	ORA	A
	JZ	NO		; SKIP IF NO KEY STRUCK
	MVI	C,1
	CALL	5		; GOT KEY -- EAT IT
	CALL	PUT		; SEND IT TO MODEM (WILL CAUSE ABORT)
NO:
	POP	H
	POP	D
	POP	B
	JMP	MINX
GOT:
	POP	D
MXGOT:
	CALL	IN$MODDATP
	ANI	7FH
	RET
MIN:
	PUSH	D
	LXI	D,16000		;SET A TIMEOUT
WTST:
	CALL	MRCVRDY		;CHECK FOR READY
	JZ	GOT		;EXIT WITH CHARACTER
	DCX	D
	MOV	A,D		;COUNT DOWN TIMEOUT
	ORA	E
	JNZ	WTST
	STC
	POP	D		;QUIT WITH TIMEOUT
	RET
;
MRCVRDY:			; TEST FOR MODEM RECEIVE READY
	CALL	IN$MODCTLP
	CALL	ANI$MODRCVB
	CALL	CPI$MODRCVR
	RET
;
SEND:
	MOV	A,M		;GET A CHARACTER
	INX	H
	ORA	A		;END OF THE STRING?
	RZ
	CPI	0DH
	RZ
	ANI	7FH
	MOV	C,A		;NO, SEND IT
	CALL	PUT
	CALL	MIN		;EAT ECHO
	JNC	SEND
	POP	H		;DITCH RETURN
	JMP	TIMOT		;GO COMPLAIN
PUT:
	CALL	IN$MODCTLP	;GET MODEM STATUS
	CALL	ANI$MODSNDB	;TEST SEND BITS
	CALL	CPI$MODSNDR
	JNZ	PUT
	MOV	A,C
	JMP	OUT$MODDATP
;
TIMOT:
	CALL	JMP$ILPRT
	DB	CR,LF,'No response from DC Hayes.',0
	RET
ONLIN:
	CALL	JMP$ILPRT
	DB	CR,LF,'On line.',0
	RET
CAR:
	CALL	JMP$ILPRT
	DB	CR,LF,'No carrier detected.',0
	RET
BAD:
	CALL	JMP$ILPRT
	DB	CR,LF,'Bad command.',0
	RET
;
AT:
	DB	'AT ',0
ATV1:
	DB	'AT V1',CR+80H,0
ATS:
	DB	'AT S10=30 V0 X1 ',CR+80H,0
;
	ENDIF	;INIT
;
	END
