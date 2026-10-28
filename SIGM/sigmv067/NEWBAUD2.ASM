;		NEWBAUD.ASM ver 2.0
;		(revised 12/27/80)
;	by Keith Petersen and Dave Hardy
;
;REMOTE BAUD RATE CHANGE UTILITY FOR PMMI MODEMS
;
;Allows a remote user to chAnge baud rate without
;HaviNg to call back.
;
;This program is compatiBle with CP/M 1.4, 2.x., and MP/M
;
;12/27/80 Added code to set new stack because some systems
;	  require more stack space than available in CP/M's
;	  default stack.  (KBP)
;
;PMMI modem port equates
;
;Set TPORT to the base address of your PMMI modem
;(all other modem equates are based on this value).
;
TPORT	EQU	0C0H	;UART CONTROL/STATUS PORT
DPORT	EQU	TPORT+1 ;MODEM DATA PORT
RPORT	EQU	TPORT+2 ;RATE GEN/MODEM STATUS
CPORT	EQU	TPORT+3 ;MODEM CONTROL
;
;The following equates are used to set up the PMMI modem
;
P08BIT	EQU	0CH	;8 DATA BITS
P0NOPY	EQU	10H	;NO PARITY
P0TSB	EQU	40H	;2 STOP BITS
P0NORM	EQU	P08BIT+P0NOPY	    ;USE 8 BITS, NO PARITY
P0110	EQU	P08BIT+P0NOPY+P0TSB ;SAME W/2 STOP BITS
;
;Baud rate divisors
;
B110	EQU	142	;110 BAUD
B300	EQU	52	;300 BAUD
B450	EQU	35	;450 BAUD
B600	EQU	26	;600 BAUD
B710	EQU	22	;710 BAUD
;
BDOS	EQU	5	;BDOS ENTRY ADDRESS
CR	EQU	0DH	;CARRIAGE RETURN
LF	EQU	0AH	;LINEFEED
PRINT	EQU	9	;PRINT STRING FUNCTION
;
	ORG	100H
;
;Save old stack pointer and set new one
;
START:	LXI	H,0
	DAD	SP	 ;GET OLD STACK
	SHLD	STACK	 ;SAVE IT
	LXI	SP,STACK ;SET NEW STACK
;
;Print sign-on message
	LXI	D,MSG	 ;SEND MESSAGE TO CONSOLE
	MVI	C,PRINT	 ;VIA BDOS "PRINT STRING" FUNCTION
	CALL	BDOS
;
;Now wait until last character of message
;is finished before changing baud rate
	LXI	H,0
	LXI	D,1	;DELAY VALUE
;
SLO:	DAD	D	;ADD ONE
	JNC	SLO	;NO CARRY YET, COUNT MORE
;
;Get new baud rate, then return to CP/M
	CALL	CHANGE	;CHANGE TO NEW BAUD RATE
	LHLD	STACK	;GET OLD STACK POINTER
	SPHL		;RESTORE IT
	RET		;RETURN TO CP/M
;
;Read the modem at different baud rates until a CR is found
;
CHANGE:	IN	DPORT	 ;CLEAR ANY GARBAGE FROM MODEM PORT
	IN	DPORT	 ;CLEAR IT TWICE JUST TO BE SURE
;
	MVI	A,B110	 ;SELECT 110 BAUD INITIALLY
	OUT	RPORT	 ;SET BAUD RATE IN MODEM
	MVI	A,P0110  ;SELECT 8 DATA, NO PARITY, 2 STOP BITS FOR 110 BAUD
	OUT	TPORT
	MVI	A,7FH	 ;SET MODEM FILTER FOR <300
	OUT	CPORT
	CALL	TSBAUD	 ;SEE IF BAUD = 110
	RZ		 ;YES, EXIT
;
	MVI	A,P0NORM ;SET FOR 1 STOP BIT, ETC., FOR >110 BAUD
	OUT	TPORT
	MVI	A,B300	 ;SET MODEM TO 300 BAUD
	OUT	RPORT
	CALL	TSBAUD	 ;SEE IF BAUD = 300
	RZ		 ;YES, EXIT
;
	MVI	A,B450	 ;SET MODEM TO 450 BAUD
	OUT	RPORT
	MVI	A,5FH	 ;SET MODEM FILTER FOR >300
	OUT	CPORT
	CALL	TSBAUD	 ;SEE IF BAUD = 450
	RZ		 ;YES, EXIT
;
	MVI	A,B600	 ;SET MODEM TO 600 BAUD
	OUT	RPORT
	CALL	TSBAUD	 ;SEE IF BAUD = 600
	RZ		 ;YES, EXIT
;
	MVI	A,B710	 ;SET MODEM TO 710 BAUD
	OUT	RPORT
	CALL	TSBAUD	 ;SEE IF BAUD = 710
	RZ		 ;YES, EXIT
;
	JMP	CHANGE	 ;KEEP TRYING UNTIL CR IS FOUND
;
;TSBAUD reads one character from console input and returns
;with the zero flag set if the character is a CR.
;
TSBAUD:	CALL	CONIN	;GET CHARACTER DIRECT FROM CONSOLE
	CPI	CR	;SET ZERO FLAG IF CHARACTER IS CR
	RET		;THEN RETURN
;
;This routine does a direct console input without echo
;
CONIN:	LHLD	1	;GET CBIOS VECTOR
	LXI	D,6	;ADD OFFSET TO CONIN VECTOR
	DAD	D	;HL NOW = CONIN VECTOR
	PCHL		;GO THERE
;
MSG:	DB	CR,LF,'NEWBAUD ver 2.0 - '
	DB	'Change to new Baud rate,',CR,LF
	DB	'THEN type RETURNs until the system responds.'
	DB	CR,LF,CR,LF,'$'
;
;Temporary storage
;
	DS	60	;ROOM FOR STACK
STACK:	DS	2	;OLD STACK SAVED HERE
;
	END	START
