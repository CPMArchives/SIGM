;
;			  MCNFG797.ASM
;
;	Patches for overlaying distribution version of MODEM797.
;
;You will want to look this file over carefully, there are a number
;of options that you can use to configure MODEM797 to suit your taste.
;
;After you have finished editing this file use DDT to overlay the HEX
;file onto MODEM797 and SAVE 64 MODEM797.COM.
;
;All users should set CLOCK to the right value for their system.
;
;PMMI users should set PUSERATE and CLDBOOT to their proper values.
;
;Non-PMMI, non-H89 users who want to get MODM797 working quickly
;and who do not need to set their modem parameters using this program
;should change VERMSG, INIT, SETUP, CLEAR and PMMI to FALSE and
;change the equates for MODDATP, MODCTLP, MODSNDB, MODSNDR, MODRCVB
;and MODRCVR before assembly.
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
;		-IMCNFG797.HEX		(note the "I" command)
;		-R			(loads in the .HEX file)
;		NEXT  PC
;		4080 0000
;		-G0			(return to CP/M)
;		A>SAVE 64 MODEM797.COM  (now have modified .COM file)
;
;12/15/82 - Modified to work with version 7.96 of MODEM7	;PLK
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
VERMSG	EQU	FALSE		;change to TRUE if you have given at
				;location SYSVERMSG the name of the
				;system for which MODEM7 has been
				;configured.
;
INIT	EQU	FALSE		;change to TRUE if you have written a
				;routine at location INITMOD in this
				;file to initialize your modem port
				;on MODEM7 execution. PMMI users should
				;use FALSE here.
;
SETUP	EQU	FALSE		;change to TRUE if you have written a
				;routine at location SETUPR to change
				;baud rate, etc and MSPEED. PMMI users
				;should use FALSE here.
;
EOSCLR	EQU	true 		;change to TRUE if you have defined the
				;clear to end of screen sequence for
				;your terminal. Clear to end of screen is
				;used on returning from terminal mode to
				;keep the screen from becoming jumbled if
				;the remote can positon your cursor.
;
SCRNCLR	EQU	true 		;change to TRUE if you have defined the
				;home cursor and clear screen sequence
				;for you terminal.

PMMI	EQU	true 		;change to TRUE for PMMI.
;
	IF	NOT PMMI
;THE FOLLOWING MUST BE CHANGED FOR YOUR MICRO IF YOU DON'T HAVE AN H89
;OR A PMMI MODEM BOARD.
MODDATP	EQU	0D8H		;data port for H89
MODCTLP	EQU	MODDATP+5	;modem status port for H89
MODSNDB	EQU	20H		;bit to test for ready to send
MODSNDR	EQU	MODSNDB		;change to 0 if bit is 0 when
				;ready to send
MODRCVB	EQU	1		;bit to test for received data
MODRCVR	EQU	MODRCVB		;change to 0 if bit is 0 when
				;data received
	ENDIF	;NOT PMMI
;
;CHANGE CLR1, CLR2, CLR3, AND CLR4 TO THE APPROPRIATE VALUES FOR
;YOUR TERMINAL IF YOU DO NOT HAVE AN H19 OR H89 AND EOSCLR IS TRUE
	IF	EOSCLR
CLR1	EQU	7eh		;tilde ctl-X is the Visual 200 clear
CLR2	EQU	'X'-40h		;to end of screen sequence
CLR3	EQU	0		;the unused bytes MUST be 0
CLR4	EQU	0
	ENDIF	;EOSCLR
;
;CHANGE SCLR1, SCLR2, SCLR3, AND SCLR4 TO THE APPROPRIATE VALUES FOR
;YOUR TERMINAL IF YOU DO NOT HAVE AN H19 OR H89 AND SCRNCLR IS TRUE
	IF	SCRNCLR
SCLR1	EQU	7eh		;tilde ctl-\ is the Visual 200 home
SCLR2	EQU	'\'-40h		;cursor and clear screen sequence
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
;*** WARNING - DO NOT INSERT OR DELETE LINES BEFORE SYSVERMSG ***
;      THE DEFINED LOCATIONS ARE GIVEN ON THE RIGHT MARGIN.
;
;
		ORG	100H
;
		DS	3	;(for  JMP  START)
PMMIBYTE:	DB	PMMI	;don't change this line			103H
SETUPTST:	DB	SETUP	;don't change this line			104H
SCRNTEST:	DB	SCRNCLR	;test for home cursor and clear screen	105H
				;routine at CLRSCRN, don't change this
CLOCK:		DB	4	;clock speed in MHz, 8 MHz maximum	106H
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
MSPEED:		DB	1	;0=110 1=300 2=450 3=600 4=710 5=1200   116H
				;default modem speed, PMMI and H89 routines
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
		JMP	SYSVERMSG					16EH
		ENDIF
JMP$DIALPL:	DS	3	;					171H
JMP$DISCONNT:	DS	3	;					174H
;
SYSVERMSG:
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
	CALL	JMP$ILPRT
	DB	'Version for: HEATH H89',CR,LF,0
	RET
	ENDIF	;VERMSG AND NOT PMMI
;
	IF	NOT PMMI
		;INSERT YOUR LOGON HERE, MUST END IN 0.
		;FOR A LOGON, PMMI USERS MUST MODIFY MODM797.ASM
LOGON:	DB	0
	ENDIF	;NOT PMMI
;
	IF	(NOT INIT) AND (NOT PMMI)
INITMOD:
	RET
	ENDIF	;NOT INIT AND NOT PMMI
;
;*** WARNING - IF YOU MAKE INITMOD AND SETUPR TOO LONG YOU MAY	  ***
;*** GO BEYOND THE LENGTH OF THE PMMI INITMOD ROUTINE.		  ***
;*** YOU CAN MODIFY UP TO THE BYTE BEFORE NUMBLIB		  ***
;*** NUMBLIB CURRENTLY IS AT 0617H.				  ***
;*** IF YOU NEED MORE SPACE USE AN APPROPRIATE DS BEFORE NUMBLIB  ***
;
	IF	INIT
;
;The following are used in setting up the 8250 ACE on the H89.
;No need to change for another micro if INIT and SETUP are FALSE.
;
;control and status ports
MODIER	EQU	MODDATP+1	;interrupt enable
MODIIR	EQU	MODDATP+2	;interrupt ident.
MODLCR	EQU	MODDATP+3	;line control
MODMCR	EQU	MODDATP+4	;modem control
MODLSR	EQU	MODDATP+5	;line status, same as MODCTLP above
MODMSR	EQU	MODDATP+6	;modem status
;
;baud rate latches
MODDLL	EQU	MODDATP		;divisor latch low
MODDLH	EQU	MODDATP+1	;divisor latch high
;
;control bytes
DISABL		EQU	0		;disable interrupts
LOOP$NODTR	EQU	10H		;set loop back, turn off DTR
ACCBAUD		EQU	80H		;access baud rate divisor latches
LSD1200		EQU	60H		;LSD for 1200 baud
MSD1200		EQU	0		;MSD for 1200 baud
WORDLEN		EQU	3		;8 bit word, no parity, no break
					;deaccess baud rate divisor latches
DTR		EQU	1		;turn on DTR
;End of H89 specific equates for initialization.
;
;
;The following is used to initialize the H89 on execution
;of MODEM7. Change it to initialize the modem port on
;your micro if you wish.
;
;
INITMOD:
	MVI	A,5		;MSPEED 1200 baud value
	STA	MSPEED
INITMOD2:
	MVI	A,DISABL
	OUT	MODIER
	MVI	A,LOOP$NODTR
	OUT	MODMCR
	MVI	A,ACCBAUD
	OUT	MODLCR
LSBD:	MVI	A,LSD1200
	OUT	MODDLL
MSBD:	MVI	A,MSD1200
	OUT	MODDLH
	MVI	A,WORDLEN
	OUT	MODLCR
	MVI	A,DTR
	OUT	MODMCR
	RET
;
	ENDIF	;INIT
;
;
;The following routine changes the baud rate for the H89 from
;the command level. Write your own routine here to change your
;modem parameters.
;
;
	IF	SETUP
;
SETUPR:
	PUSH	H
AGAIN:	LXI	D,BAUDBUF	;point to input buffer for ILCOMP
	CALL	JMP$ILPRT
	DB	'Input Baud Rate (300, 450, 600, 1200): ',0
	CALL	JMP$INBUFF
	LXI	D,BAUDBUF+2
	CALL	JMP$ILCOMP	;compare BAUDBUF+2 with characters below
	DB	'300',0
	JNC	OK300		;go if got match
	CALL	JMP$ILCOMP
	DB	'450',0
	JNC	OK450
	CALL	JMP$ILCOMP
	DB	'600',0
	JNC	OK600
	CALL	JMP$ILCOMP
	DB	'1200',0
	JNC	OK1200
	CALL	JMP$ILPRT	;all matches failed - tell operator
	DB	'++ Incorrect entry ++',CR,LF,BELL,0
	JMP	AGAIN		;try again
;
OK300:	MVI	A,1		;MSPEED 300 baud value
	LHLD	BD300		;get 300 baud parameters in HL
	JMP	LOADBD		;go load them
;
OK450:	MVI	A,2
	LHLD	BD450
	JMP	LOADBD

OK600:	MVI	A,3
	LHLD	BD600
	JMP	LOADBD
;
OK1200:	MVI	A,5
	LHLD	BD1200
	JMP	LOADBD
;
LOADBD:	STA	MSPEED
	MOV	A,L		;get least significant baud rate byte
	STA	LSBD+1		;store in INITMOD
	MOV	A,H		;get most signifcant baud rate byte
	STA	MSBD+1		;store in INITMOD
	POP	H
	JMP	INITMOD2	;reset H89 8250
;
;Table of baud rate parameters
BD300:	DW	0180H
BD450:	DW	0100H
BD600:	DW	00C0H
BD1200:	DW	0060H
;
BAUDBUF:
	DB	10,0
	DS	10
;
	ENDIF	;SETUP
;
;
	END
;
