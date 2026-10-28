;
;			  MCOSB797.ASM
;
;	Patches for overlaying distribution version of MODEM797,
;		for use with the Osborne O-1.
;
;You will want to look this file over carefully, there are a number
;of options that you can use to configure MODEM797 to suit your taste.
;
;
;	TO USE: First edit this file filling in answers for your own
;		equipment.  Then assemble with ASM.COM or equivalent
;		assembler.  Then use DDT to overlay the the results
;		of this program to the original MODEM797.COM file:
;
;		A>DDT MODEM797.COM
;		DDT VERS 2.2
;		NEXT  PC
;		4080 0100
;		-IMCOSB797.HEX		(note the "I" command)
;		-R			(loads in the .HEX file)
;		NEXT  PC
;		4080 0000
;		-G0			(return to CP/M)
;		A>SAVE 64 MODEM797.COM  (now have modified .COM file)
;
;
;12/17/82 - Revised for MODEM796				PLK
;
;12/01/82 - The file is left in the 11/29/82 form as an example of
;	    memory mapped I/O. Osborne owners may want to use the
;	    approach Frank Wancho describes.			PLK
;
;11/30/82 - This file stills uses an old-style and now obsolete form of
;	    accessing the RS232 port directly thru the bank-switching
;	    technique with code in memory above 4000H, all OSBORNEs
;	    should have now been upgraded to at least ROM 1.2, if not
;           1.3 - the latest version. Combined with that upgrade is a
;           new BIOS that supports the IOBYTE. All that has to be done
;	    is toggle the first of the two CON: bits in the IOBYTE
;	    as follows:
;
;	        0 - keyboard + crt (TTY:)
;	        1 - serial port (CRT:)
;								F. J. Wancho
;
;11/29/82 - Version of MODEM797 overlay file for Osborne-1. The
;	    Osborne routines come from an earlier version.	P. L. Kelley
;
TRUE	EQU	0FFH
FALSE	EQU	0
;
BELL	EQU	07H	;bell
CR	EQU	0DH	;carriage return
LF	EQU	0AH	;linefeed
;
MODCTLP	EQU	2A00H		;status register for RS232
MODSNDB	EQU	2		;bit to test for ready to send
MODSNDR	EQU	MODSNDB		;change to 0 if bit is 0 when
				;ready to send
MODRCVB	EQU	1		;bit to test for received data
MODRCVR	EQU	MODRCVB		;change to 0 if bit is 0 when
				;data received
MODDATP	EQU	MODCTLP+1	;data resister for RS232
;
CLR1	EQU	0		;there is no O-1 clear to end
CLR2	EQU	0		;of screen sequence
CLR3	EQU	0		;so all bytes MUST be 0
CLR4	EQU	0
;
SCLR1	EQU	'Z'-40H		;ctrl-Z for O-1 clear screen
SCLR2	EQU	0		;and home cursor
SCLR3	EQU	0		;the unused bytes MUST be 0
SCLR4	EQU	0
;
;
;You can change locations 107H to 120H to suit your taste.
;
;*** WARNING - DO NOT INSERT OR DELETE LINES BEFORE SYSVERMSG: ***
;      THE DEFINED LOCATIONS ARE GIVEN ON THE RIGHT MARGIN.
;
;
		ORG	100H
;
		DS	3	;(for  JMP  START)
PMMIBYTE:	DB	FALSE	;don't change this line			103H
SETUPTST:	DB	TRUE	;don't change this line			104H
SCRNTEST:	DB	TRUE	;don't change this line			105H
CLOCK:		DB	2	;don't change this line			106H
BAKUPBYTE:	DB	FALSE	;true=make .BAK file			107H
CKSUMDFLT:	DB	FALSE	;true=default to Checksum checking	108H
				;false=default to CRC checking
TOGGLECRC:	DB	TRUE	;true=allow toggling of Checksum to CRC	109H
CONVBKSP:	DB	FALSE	;true=convert backspace to rub		10AH
TOGGLEBK:	DB	TRUE	;true=allow toggling of bksp to rub	10BH
ADDLF:		DB	FALSE	;true=add LF after CR			10CH
TOGGLELF:	DB	TRUE	;true=allow toggling of LF after CR	10DH
TRANLOGON:	DB	FALSE	;true=allow transmission of logon	10EH
				;write logon sequence at location LOGON
SAVCCP:		DB	FALSE	;true=do not overwrite CCP		10FH
LOCONEXTCHR:	DB	FALSE	;true=local command if EXTCHR precedes	110H
				;false=not local command if EXTCHR precedes
TOGGLELOC:	DB	TRUE	;true=allow toggling of LOCONEXTCHR	111H
LSTTST:		DB	TRUE	;true=allow toggling of printer on/off	112H
				;in terminal mode, set to false if your
				;printer can't keep up with the modem
XOFFTST:	DB	FALSE	;true=allow testing of XOFF from remote 113H
				;while transmitting a file in terminal mode
XONWAIT:	DB	FALSE	;true=wait for XON after sending CR	114H
				;while transmitting a file in terminal mode
TOGXOFF:	DB	TRUE	;true=allow toggling of XOFF testing	115H
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200   116H
				;default modem speed, PMMI routines
				;reset this value and so should your own
				;modem routines
BYTDLY:		DB	0	;0=0 delay, 1=0.02 sec, -- ,9=0.18 sec  117H
				;default time to send character in
				;terminal mode file transfer
CRDLY:		DB	0	;0=0 delay, 1=0.08 sec, -- ,9=0.72 sec	118H
				;default time for extra wait after CR
				;in terminal mode file transfer
BELRPT:		DB	30	;bell repeat time = value*0.03 sec	119H
EXITCHR:	DB	'E'-40H	; ^E = Exit without disconnect		11AH
LOGCHR:		DB	'O'-40H	; ^O = Send logon			11BH
LSTCHR:		DB	'P'-40H	; ^P = Toggle printer			11CH
UNSAVE:		DB	'R'-40H	; ^R = Close input text buffer		11DH
TRANCHR:	DB	'T'-40H ; ^T = Transmit file to remote		11EH
SAVECHR:	DB	'Y'-40H	; ^Y = Open input text buffer		11FH
EXTCHR:		DB	'W'-40H	; ^W = Send next character		120H
		DS	6	;don't change, used only by PMMI	121H
IN$MODCTLP:	JMP	MXSTAT		;test for status		127H
OUT$MODDATP:	JMP	MXOUT		;output data to modem		12AH
IN$MODDATP:	JMP	MXIN		;get data from modem		12DH
ANI$MODSNDB:	ANI	MODSNDB ! RET	;bit to test for send ready	130H
CPI$MODSNDR:	CPI	MODSNDR ! RET	;value of send bit when ready	133H
ANI$MODRCVB:	ANI	MODRCVB ! RET	;bit to test for receive ready	136H
CPI$MODRCVR:	CPI	MODRCVR ! RET	;value of rcv. bit when ready	139H
		DS	15		;PMMI only calls		13CH
LOGONPTR:	DW	LOGON		;				14BH
JMP$INITMOD:	JMP	MXINIT		;go to user written routine	14DH
JMP$SETUPR:	JMP	MXSETBAUD	;				150H
;
CLREOS:		CALL	JMP$ILPRT	;				153H
		DB	CLR1,CLR2,CLR3,CLR4,0
		RET
;
CLRSCRN:	CALL	JMP$ILPRT	;				15CH
		DB	SCLR1,SCLR2,SCLR3,SCLR4,0
		RET
;
JMP$ILPRT:	DS	3	;					165H
JMP$ILCOMP:	DS	3	;					168H
JMP$INBUFF:	DS	3	;					16BH
JMP$SYSVER:	JMP	SYSVERMSG;					16EH
JMP$DIALPL:	DS	3	;					171H
JMP$DISCONNT:	DS	3	;					174H
;
SYSVERMSG:			;					16EH
	CALL	JMP$ILPRT
	DB	'Version for: OSBORNE O-1',CR,LF,0
	RET

;INSERT YOUR LOGON HERE, MUST END IN 0.
LOGON:	DB	0
;
MXIN:	CALL	$-$	;patched to call input routine
	RET
;
MXOUT:	CALL	$-$	;patched to call output routine
	RET
;
MXSTAT:
	CALL	$-$	;patched to call status routine
	RET
;
MXINIT:
	LDA	FINITFLG
	ORA	A
	RZ
	CMA
	STA	FINITFLG
	LHLD	6	;find top of user RAM
	LXI	D,-100H	;step down a little
	DAD	D
	PUSH	H	;save it
	LXI	D,BDJ	;point to source of code
	LXI	B,CDLEN+2	;set length of code
	XCHG
	DB	0EDH,0B0H ; Z80 LDIR
;
	LHLD	6	;get BDOS address back
	POP	D
	PUSH	D
	INX	D	;point to address position
	XCHG
	MOV	M,E	;patch in address
	INX	H
	MOV	M,D
;
	POP	H
	SHLD	6	;transfer BDOS jump
;
	LXI	D,OSIN-BDJ
	DAD	D	;compute address of OSIN routine
	SHLD	MXIN+1	;patch call
	LXI	D,OSOUT-OSIN
	DAD	D
	SHLD	MXOUT+1	;patch call
	LXI	D,OSTAT-OSOUT
	DAD	D
	SHLD	MXSTAT+1
;
	MVI	A,1		;MSPEED 300 baud value
	STA	MSPEED
	MVI	C,56H		;for 300 baud
STBAUD:	PUSH	H
	CALL	OSET
	POP	H
	XRA	A	;clear carry
	RET
;
OSET:	LHLD	1	;get BIOS+3 address
	MVI	L,3CH	;special Osborne routine
	PCHL		;branch to it
;
MXSETBAUD:
	PUSH	H
AGAIN:	LXI	D,BAUDBUF	;point to input buffer for ILCOMP
	CALL	JMP$ILPRT
	DB	'Input Baud Rate (300, 1200): ',0
	CALL	JMP$INBUFF
	LXI	D,BAUDBUF+2
	CALL	JMP$ILCOMP	;compare BAUDBUF+2 with characters below
	DB	'300',0
	MVI	A,1		;MSPEED 300 baud
	MVI	C,56H		;O-1 300 baud
	JNC	OK		;go if got match
	CALL	JMP$ILCOMP
	DB	'1200',0
	MVI	A,5
	MVI	C,55H
	JNC	OK
	CALL	JMP$ILPRT	;all matches failed - tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,0
	JMP	AGAIN		;try again
;
OK:	STA	MSPEED		;set MSPEED
	POP	H
	JMP	STBAUD
;
BAUDBUF:	DB	10,0
		DS	10
;
FINITFLG:	DB	TRUE
;
;
; --- ROUTINES THAT GET COPIED UP TO TOP OF MEMORY ---
;		JUST UNDER THE BDOS
;
BDJ:	JMP	$-$	;this gets patched to jump to BDOS entry
;
OSIN:	DI		;disable interrupts
	OUT	0	;switch to alternate page
	LDA	MODDATP	;get data byte
	OUT	1	;switch back pages
	EI		;re-enable interrupts
	RET
;
OSOUT:	DI		;disable interrupts
	OUT	0	;switch to alternate page
	STA	MODDATP	;send data byte
	OUT	1	;switch back pages
	EI		;re-enable interrupts
	RET
;
OSTAT:	DI		;disable interrupts
	OUT	0	;switch to alternate page
	LDA	MODCTLP	;get status byte
	OUT	1	;switch back pages
	EI		;re-enable interrupts
	RET
CDLEN:	EQU	$-BDJ	;length of code to copy
;
;
	END
;
