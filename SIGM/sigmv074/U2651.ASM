;****************************************************************
;*								*
;*	   BSTAM/BSTMS Interface routines for 2651 UART.	*
;*		on Godbout System Support 1 Board		*
;*		 or Godbout Interfacer 3/4 Board		*
;*								*
;****************************************************************
;
;	By	Bill Bolton
;		Software Tools,
;		P.O. Box 80,
;		Newport Beach,
;		NSW, 2106
;		AUSTRALIA
;
	TITLE	'2651 UART Interface for BSTAM, Software Tools'
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
	ORG	103H
;
BEGIN:
INITIL:
	JMP	INITIU		;UART/USART INITIALATION ENTRY POINT
INSPORT:
	JMP	INSPRU		;STATUS PORT READ ENTRY POINT
ERRSET:
	JMP	ERRSTU		;UART/USART ERROR RESET ENTRY POINT
INPORT:
	JMP	INPRTU		;READ DATA PORT ENTRY POINT
OUTPORT:
	JMP	OUTPRU		;WRITE DATA PORT ENTRY POINT
;
;
;			THIS IS THE UART/USART INITIALATION ROUTINE.
;			TO BE COMPATIBLE WITH MOST BSTAM USERS USE FOLLOWING
;			INITIALISATION GUIDE LINES:
;			1. USE 1 STOP BIT	(OPTIONAL - 2)
;			2. USE 8 DATA BITS	(MUST)
;			3. USE 1 START BIT	(MUST)
;			4. USE 16X FOR CLOCK RATE 	(MUST)
;			5. USE ASYNCHRONOUS MODE ONLY	(MUST)
;
INITIU:
	CALL	SIGNON		;Announce version

	if	inter3
	MVI	A,UNUM
	OUT	USER		;Select UART
	endif	;inter3

	MVI	A,MODE1		;Get first mode word
	OUT	MODE
	MVI	A,MODE2		;Get second mode word
	OUT	MODE
	MVI	A,CMMDB		;Get command byte
	OUT	CMMD
	RET		;RETURN TO BSTAM
;
;
;			THIS IS THE STATUS READ PORT ROUTINE.
;			WHEN EXITING THIS ROUTINE BSTAM EXPECTS IN REGISTER A
;			THE FOLLOWING BITS TO BE SET IF NEEDED:
;			1. 20 BIT SET IF FRAMING ERROR
;			2. 10 BIT SET IF OVERRUN ERROR
;			3. 08 BIT SET IF PARITY  ERROR
;			4. 04 BIT SET IF TRANSMITTER EMPTY
;				IF YOUR UART/USART DOES NOT HAVE TRANSMITTER
;				EMPTY FEATURE, THEN ALWAYS SET THIS BIT ON.
;			5. 02 BIT SET IF RECEIVER READY
;			6. 01 BIT SET IF TRANSMITTER READY
;			7. DO NOT SET THE 80 BIT OR 40 BIT
;
;
;
INSPRU:
	if	inter3
	MVI	A,UNUM
	OUT	USER		;Select UART
	endif	;inter3

	IN	STATUS		;Get status
	ORI	4		;Force Tx empty high
	RET
;
;
;			YOUR UART/USART MAY NOT NEED TO BE RESET IF FRAMING,
;			OVERRUN, OR PARITY ERROR IS FOUND. IF THIS IS YOUR
;			CASE, JUST DO A RETURN.
;
;
;
;
ERRSTU:
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
;			THIS IS THE READ DATA PORT ROUTINE.
;			BEFORE THIS ROUTINE IS ENTERED THE 02 BIT OF
;			STATUS READ ROUTINE MUST HAVE BEEN SET.
;			DO NOT CLEAR THE 80 BIT FROM THE DATA INPUT PORT.
;			RETURN WITH REGISTER A LOADED WITH INPUT DATA.
;
;
INPRTU:
	if	inter3
	MVI	A,UNUM
	OUT	USER		;Select UART
	endif	;inter3

	IN	DATA		;Get data
	RET
;
;			THIS IS THE WRITE DATA PORT ROUTINE.
;			BEFORE THIS ROUTINE IS ENTERED THE 04 BIT AND 01 BIT
;			OF STATUS READ MUST BE SET.
;			DO NOT CLEAR THE 80 BIT FROM THE DATA OUTPUT PORT.
;			REGISTER A CONTAINS THE OUTPUT DATA.
;
OUTPRU:
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
SIGNON:	PUSH	B		;Save  the environment
	PUSH	D
	PUSH	H
	LXI	D,MESSGE
	MVI	C,9		;BDOS display string command
	CALL	BDOS		;Announce version to user
	POP	H		;Restore the enviroment
	POP	D
	POP	B
	RET
;
hexnum	macro	num
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
	DB	'Version 4.5, March 29, 1982 by Software Tools',ACR,ALF
	DB	'2651 UART on '

	if	sysspt
	DB	'Godbout System Support 1 Board'
	endif	;sysspt

	if	inter3
	DB	'Godbout Interfacer 3 Board'
	endif	;sysspt

	DB	ACR,ALF
	DB	'UART Addressed at ' 
	hexnum	%BASE
	DB	'H, 300 bps, no parity.',ACR,ALF

	if	inter3
	DB	'UART Relative User '
	hexnum	%UNUM
	DB	',',ACR,ALF
	endif	;inter3

	DB	'$'
;
	END	BEGIN
