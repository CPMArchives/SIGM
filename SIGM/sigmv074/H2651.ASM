;------------------------------------------------------------------------------
;
;	"HITE" Hardware Dependant Code Module for "2651" Family UARTS
;
;		Version 1.0 , March 10, 1982 - By Software Tools
;
;------------------------------------------------------------------------------
;
;	By	Bill Bolton
;		Software Tools,
;		P.O. Box 80,
;		Newport Beach,
;		NSW, 2106
;		AUSTRALIA
;
	TITLE	'2651 UART Interface for HITE, Software Tools'
; 
;DESCRIPTION:
;
;	This code is generally applicable to any 2561 based port. Conditional
;	assembly options are available for bank selected type ports such as
;	found on the Godbout Interfacer 3 IEEE-696 card. The code has been
;	extensively tested on both Godbout System Support and Interfacer 3
;	Cards. The code as presented here is set up for assembly with the
;	MAC or MACRO-80 assemblers. If you wish to assemble it with ASM the
;	'TITLE' line must be removed and the 'hexnum' macro must be eliminated
;	and the port numbers in the signon message must be expanded by hand
;	(i.e. you'll have to plug the ASCII values for the port addresses
;	into the message yourself).
;
;	See the additional notes near the INIT, EXIT and HEXNUM routines.
;
;************************************************
;*						*
;*	     Miscellaneous Equates		*
;*						*
;************************************************
;
TRUE	EQU	0FFFFH
FALSE	EQU	NOT TRUE

BDOS	EQU	0005			;CP/M BDOS entry point
ALF	EQU	0AH			;ASCII line feed
ACR	EQU	0DH			;ASCII carriage return
;
;************************************************
;*						*
;*	     2651 Baud Rate Table		*
;*						*
;************************************************
;
B50	EQU	0000B			;50 bps
B75	EQU	0001B			;75 bps
B110	EQU	0010B			;110 bps
B134	EQU	0011B			;134.5 bps
B150	EQU	0100B			;150 bps
B300	EQU	0101B			;300 bps
B600	EQU	0110B			;600 bps
B1200	EQU	0111B			;1200 bps
B1800	EQU	1000B			;1800 bps
B2000	EQU	1001B			;2000 bps
B2400	EQU	1010B			;2400 bps
B3600	EQU	1011B			;3600 bps
B4800	EQU	1100B			;4800 bps
B7200	EQU	1101B			;7200 bps
B9600	EQU	1110B			;9600 bps
B19200	EQU	1111B			;19200 bps
;
;************************************************
;*						*
;*		2651 Equates			*
;*						*
;************************************************
;
BASE	EQU	5CH			;UART base register
DATA	EQU	BASE+0			;Data port
STATUS	EQU	BASE+1			;Status port
MODE	EQU	BASE+2			;Mode register
CMMD	EQU	BASE+3			;Command register
USER	EQU	BASE+7			;User select port
UNUM	EQU	6			;Modem user number
MODE1	EQU	01101110B		;Asynch,16x,8 data bits,
					; no parity, even, 1 stop bit
MODE2	EQU	01110000B + B300	;Baud rate
CMMDB	EQU	00100111B		;Tx enabled, RX enabled, no break
					; DTR high, RTS high
ERESET	EQU	CMMDB+8			;Error reset
;
SYSSPT	EQU	TRUE			;True for Godbout system support
INTER3	EQU	NOT SYSSPT		;True for Godbout Interfacer 3
;
;
;------------------------------------------------------------------------------
;
		ORG	108H
SDRIVE:
	DB	0		;SET NON-ZERO FOR SINGLE DRIVE SITE.
BEEP:
	DB	0		;SET NON-ZERO TO BEEP WHEN DONE.
TIMEOUT:
	DB	6		;COUNT-DOWN VALUE FOR TIMEOUT (ABOUT 30 SECS.)
				;WITH A 4MHZ Z80, 1 = 5 SEC. (SORT OF).
				;	HENCE ZERO = 21.25 MINUTES.
				;THE SELECTED VALUE IS A TRADE-OFF, SINCE A LOW
				;VALUE MAY TIME-OUT WHILE THE RECEIVER IS
				;WRITING TO DISC (WHICH DOES NO HARM BUT CLOGGS
				;UP THE SCREEN WITH DISPLAYS) AND A HIGH VALUE
				;CAUSES THE KEYBOARD TH BE CHECKED LESS OFTEN.
				;
;------------------------------------------------------------------------------
;
;
HINIT:		JMP	INIT		;UART/USART INITIALATION ENTRY POINT
HEXIT:		JMP	EXIT		;SPECIAL USER EXIT ROUTINE
HSTAT:		JMP	STAT		;STATUS PORT READ ENTRY POINT
HRES:		JMP	RES		;UART/USART ERROR RESET ENTRY POINT
HRX:		JMP	RX		;READ DATA PORT ENTRY POINT
HTX:		JMP	TX		;WRITE DATA PORT ENTRY POINT
;
;
;------------------------------------------------------------------------------
;			THIS IS THE UART/USART INITIALISATION ROUTINE.
;			TO ENSURE COMPATIBILITY WITH OTHER USERS, THE
;			FOLLOWING STANDARD IS RECCOMENDED :
;			1. USE 1 STOP BIT	(OPTIONAL - 2)
;			2. USE 8 DATA BITS	(MANDATORY)
;			3. USE 1 START BIT	(MANDATORY)
;			4. USE ASYNC MODE ONLY	(MANDATORY)
;
;			For the 2651, the UART operating parameters
;			(which are under software control) are read and stored.
;			On exit from HITE these	entry paramters will be
;			restored to the UART. This allows HITE to
;			transparently use different UART parameters from
;			other programs that may utilise the port.
;
INIT:

	if	inter3
	MVI	A,UNUM
	OUT	USER		;Select UART
	endif	;inter3

	IN	MODE		;Get first mode byte from entry format
	STA	SMODE1		;Save for exit
	IN	MODE		;Get second mode byte
	STA	SMODE2		;Save for exit
	IN	CMMD		;Get command byte
	STA	SCMMDB		;Save for exit
INIT1:
	MVI	A,MODE1		;Put first mode word for HITE format
	OUT	MODE
	MVI	A,MODE2		;Put second mode word
	OUT	MODE
	MVI	A,CMMDB		;Put command byte
	OUT	CMMD
SIGNON:
	LXI	D,MESSGE	;Message is at the end of this module
	MVI	C,9		;BDOS display string command
	JMP	BDOS		;Announce version to user and return
				;to HITE via BDOS RET instruction
;
SMODE1	DB	0		;Storage for first entry mode byte
SMODE2	DB	0		;Storage for second entry mode word
SCMMDB	DB	0		;Storage for entry command byte
;
;------------------------------------------------------------------------------
;			THIS SECTION IS INCLUDED FOR ANY "SPECIAL" USER
;			EXIT CODE. (EG. RESTORING INTERRUPT VECTORS).
;			IF UNUSED, A <RETURN> IS THE ONLY CODE NEEDED.
;			AS THIS IS THE LAST ROUTINE OBEYED BEFORE THE TEST
;			FOR "SINGLE DRIVE SITES" IS MADE, NO REGISTERS NEED
;			TO BE PRESERVED.
;
;
;			For the 2651, the UART operating parameters
;			(entry parameters) will be restored to the UART.
;			This allows HITE to transparently use different
;			UART parameters from other programs that may utilise
;			the port. This is particularly 	handy if the same
;			port has to double for another function such as a
;			printer port etc. It is also useful if a dedicated
;			communications port must use different parameters
;			(i.e number of stop bits) when communicating with
;			a variety of other computers in text or binary
;			modes. 
;
EXIT:
	LDA	SMODE1		;Get first mode byte of entry format
	OUT	MODE
	LDA	SMODE2		;Get second mode byte of entry format
	OUT	MODE
	LDA	SCMMDB		;Get command byte of entry format
	JMP	RES		;Do an error reset
;
;
;------------------------------------------------------------------------------
;			THIS IS THE STATUS READ PORT ROUTINE.
;			IT MUST EMULATE THE STATUS BITS FOR
;			AN 8251 USART. I.E.
;
;			BIT 00 SET IF TRANSMITTER READY
;			BIT 01 SET IF RECEIVER READY
;			BIT 02 SET IF TRANSMITTER EMPTY
;			BIT 03 SET IF PARITY  ERROR
;			BIT 04 SET IF OVERRUN ERROR
;			BIT 05 SET IF FRAMING ERROR
;			BITS 06 AND 07 RESET (I.E. 0)
;
;	*** NOTE: ONLY THE "A" REGISTER SHOULD BE ALTERED. ***
;
;
STAT:
	if	inter3
	MVI	A,UNUM
	OUT	USER		;Select UART
	endif	;inter3

	IN	STATUS		;Get status
	ORI	4		;Force Tx empty high
	RET
;
;
;------------------------------------------------------------------------------
;			THIS IS THE ERROR RESET FOR UART/USART ROUTINE.
;			IF YOUR UART/USART DOES NOT NEED TO BE RESET ON
;			ERROR, WE RECCOMEND THAT YOU DO AN "IN DATA" TO
;			CLEAR THE AIR AND RETURN.
;
RES:
	if	inter3
	MVI	A,UNUM
	OUT	USER		;Select UART
	endif	;inter3

	MVI	A,ERESET	;Reset error flags in 2651
	OUT	CMMD
	MVI	A,CMMDB		;Restore normal operation
	OUT	CMMD
	RET
;
;
;------------------------------------------------------------------------------
;			THIS IS THE RECEIVE DATA ROUTINE.
;			BEFORE THIS ROUTINE IS ENTERED BIT 02 OF THE
;			STATUS READ ROUTINE MUST HAVE BEEN SET.
;			DO NOT CLEAR THE TOP (MOST SIGNIFICANT) BIT.
;			RETURN WITH REGISTER A LOADED WITH INPUT DATA.
;
;
;
RX:
	if	inter3
	MVI	A,UNUM
	OUT	USER		;Select UART
	endif	;inter3

	IN	DATA		;Get data
	RET
;
;
;
;------------------------------------------------------------------------------
;			THIS IS THE TRANSMIT DATA ROUTINE.
;			BEFORE THIS ROUTINE IS ENTERED BIT 00
;			AND  BIT 3 OF STATUS READ MUST BE SET.
;			DO NOT CLEAR THE TOP BIT BEFORE OUUDATUT.
;			REGISTER A CONTAINS THE DATA.
;
TX:
	if	inter3
	PUSH	PSW
	MVI	A,UNUM
	OUT	USER		;Select UART
	POP	PSW
	endif	;inter3

	OUT	DATA		;Send data
	RET
;
;
;
;------------------------------------------------------------------------------
;
;			THE PURPOSE OF THIS MEASSGE IS TO SHOW
;			(OR REMIND) YOU OF THE ACTUAL HARDWARE
;			THAT THIS VERSION OF HITE IS SET UP FOR.
;
;			Note that only one level of the stack
;			is used on entry to the initialisation routine.
;			The rest of the "reserved" stack space
;			may be used for the signon message as this is only
;			needed once near the start of HITE. Once the message
;			has been displayed it can be safely overwritten by
;			the stack.
;
;
HEXNUM	macro	num
	if	(num/16) > 9 	
	db	(num/16 and 0fh) + 'A' - 10
	else
	db	(num/16 and 0fh) + '0'
	endif
	if	(num and 0fh) > 9
	db	(num and 0fh) + 'A' - 10
	else
	db	(num and 0fh) + '0'
	endif
	endm

MESSGE:	DB	ACR,ALF,ALF
	DB	'For 2651 UART'

	if	sysspt
	DB	' on System Support 1 Board'
	endif	;sysspt

	if	inter3
	DB	' on Interfacer 3 Board'
	endif	;sysspt

	DB	',',ACR,ALF
	DB	'at port ' 
	hexnum	%BASE
	DB	'H, 300 bps, 1 stop, no parity.',ACR,ALF

	if	inter3
	DB	'UART Offset '
	hexnum	%UNUM
	DB	', '
	endif	;inter3

	DB	'Version 1.0, 10/May/82',ACR,ALF
	DB	'$'
;
;
;
;
;------------------------------------------------------------------------------
;
;
	END
