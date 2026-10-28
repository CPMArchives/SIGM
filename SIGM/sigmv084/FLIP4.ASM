	TITLE	'FLIP - Toggle originate/answer mode under "bye"'
;
;	Originally written by Bruce Ratoff.
;
;	VERSION LIST: Most recent version first
;
;17/Jun/82 Added  short  signon  message  with  version  number
;	   equate inserted into message.  Changed prompts to be
;	   consistent with my "FLIP" option in BYE72D.
;	   (Bill Bolton)
;
;12/Jun/82 Added timeout before flip OK  message, to allow time
;	   remote modem  to  detect  new carrier, seems to take
;	   about 5 seconds for  CCITT  V21 when going to ANSWER
;	   mode. (Bill Bolton)
;
;11/Jun/82 Added code to toggle mode rather than just change to
;          answer  as CCITT systems have less marked difference
;          in performance than BELL 103A systems and  switching
;          to answer mode isn't always a good solution. Now the
;          remote  user  can  go  back  to  originate.  Removed
;          PMMI/Hayes stuff (because CCITT users can't use them
;          and  it isn't really clear what some of the hardware
;          specific  stuff  does  when  you've  never seen  one
;          [and  are never likely to]) and set up  for  Telecom
;          Australia modem. Message rewritten to lower case and
;          63 char line. (Bill Bolton)
;
;08/Aug/80 Added  conditional  assembly for either PMMI or D  C
;          Hayes modem cards (BR)
;
;06/Jun/80 PMMI  modem conditionals and to re-ask for input  if
;          invalid answer. Keith Petersen, W8SDZ.
;
;02/Jun/80 Uppercase  message and require exactly control-c  or
;          return, ignoring all else. (BR)
;
FALSE	EQU	0	;BASIC LOGIC DEFINITIONS
TRUE	EQU	NOT FALSE
;
VERS	EQU	41	;Version number
;
MODCTL	EQU	5FH	;2651 UART command port
RTS	EQU	20H	;RTS bit in comand byte
SPEED	EQU	4	;CPU speed in Mhz
RETIME	EQU	6	;Time for remote modem to
			; detect new carrier 
;
WBOOT	EQU	0	;CP/M warm boot entry point
BDOS	EQU	5	;CP/M BDOS entry point
DBUFF	EQU	80H
;
PMESSG	EQU	9
CHRINP	EQU	1
ALF	EQU	0AH	;Ascii line feed
ACR	EQU	0DH	;Ascii carriage return
;
	ORG	100H
;
FLIP:
	MVI	C,PMESSG
	LXI	D,SIGNONMSG	;Annouce ourself quitely
	CALL	BDOS
	IN	MODCTL
	ANI	RTS		;In answer mode?
	CZ	ORIGINATE	;Yes
	MVI	C,PMESSG
	LXI	D,SWITCHMSG
	CALL	BDOS
;
FLIP1:
	MVI	C,PMESSG
	LXI	D,SELECTMSG
	CALL	BDOS
	MVI	C,CHRINP
	CALL	BDOS
	ANI	05FH		;Make upper case
	CPI	'N'		;NO?
	JZ	ABORT	 	;OK, NO CHANGE
	CPI	'Y'
	JNZ	FLIP1		;WASN'T Y OR N...ASK HIM AGAIN
;
;SET MODEM FOR DTR ON & ORIGINATE
;
	IN	MODCTL		;Get the current mode
	XRI	RTS		;Toggle the bit
	OUT	MODCTL		;Flip the mode
	MVI	B,RETIME*10	
TLOOP:
	CALL	DELAY		;Wait for remote to carrier detect
	DCR	B
	JNZ	TLOOP
	MVI	C,PMESSG	;If we get carrier again we can
	LXI	D,DONEMSG	; tell them we made it OK
	CALL	BDOS		; else BYE takes care of things
	JMP	WBOOT		;EXIT TO CP/M WARM BOOT

ABORT:
	MVI	C,PMESSG
	LXI	D,ABORTMSG
	CALL	BDOS
	JMP	WBOOT
;
ORIGINATE:
	PUSH	PSW
	LXI	H,OMSG		;Point to new message
	LXI	D,MODE		;Point to message to overwrite
	MVI	B,MLEN-MODE	;Length of message
OLOOP:
	MOV	A,M		;Get a byte
	STAX	D		;Put a byte
	INX	H		;Adjust pointers
	INX	D
	DCR	B		;Done?
	JNZ	OLOOP		;No
	POP	PSW
	RET			;Yes
;
;	.1 SEC DELAY ROUTINE
;
DELAY:
	PUSH	B
	LXI	B,SPEED*4167 	;TIMING CONSTANT
DELAY1:
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	DELAY1
	POP	B
	RET
;
SIGNONMSG:
	DB	'FLIP Version '
	DB	VERS/10 + '0','.',(VERS MOD 10) + '0'
	DB	ACR,ALF,'$'
;
SWITCHMSG:
	DB	ACR,ALF
	DB	'If  you answer "Y" to the next question you have 20 seconds  to',ACR,ALF
	DB	'switch your modem or acoustic coupler to the "'
MODE:
	DB	'ANSWER" mode.   '
MLEN:
	DB	ACR,ALF,'$'
;
SELECTMSG:
	DB	ACR,ALF,'Do you want to FLIP the modem mode ? ','$'
;
DONEMSG:
	DB	ACR,ALF,ACR,ALF
	DB	'If you see this, the mode change was successful.',ACR,ALF,'$'
;
ABORTMSG:
	DB	ACR,ALF,ACR,ALF
	DB	'OK, no change in mode then.',ACR,ALF,'$'
;
OMSG:
	DB	'ORIGINATE" mode.'

	END
