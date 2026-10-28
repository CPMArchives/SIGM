	TITLE		'CHAT.ASM ver 1.9'
;			(revised 10/Jun/82)
;
;    An interactive program to allow a remote user to "chat"
;      with the local Remote CP/M system operator.
;
;               Originally by Roderick W. Hart
;
;This program is to be used by a local RCPM operator to conduct two-way
;communications with a remote caller.  Operator acknowledges "chat"
;request by pressing the special code key designated at "ACK" below.
;
;When in the chat mode, lines are automatically limited to 63
;characters. A  CR and LF is inserted automatically on the first
;space typed after the 57th character.
;
;10/Jun/82 Added three bells for operator, for those of us who
;	  use bells as normal prompts for remote users (Bill Bolton)
;
;13/Apr/82 Added conditional assembly for MINIRBBS and replaced
;	  FASTCLK switch with SPEED equate. (Bill Bolton)
; 
;26/May/81 Added conditional assembly for RBBS based message
;	  systems.  Separated MINICBBS and CBBS conditional
;	  assemblies.  (Howard Booker)
;
;19/Apr/81 Added DACBELL option for systems having a D-to-A type music
;	  board (such as Newtech).  This allows summoning the operator
;	  when the system console is turned off.  (Bruce Ratoff)
;
;2/Jan/81 Fixed TRUE/FALSE equates (FALSE was never used), changed
;	  signon message, fixed conditional on ORG statement,
;	  cleaned up file. (KBP)
;
;20/Dec/80 Modified so no warm boot on exit, TRUE/FALSE equates
;	  for ALTCPM, FASTCLK, MPMPRL, MINICBBS (or CBBS) message.
;	  Also inform user to use CTL-C to exit.  By Kelly Smith.
;
;14/Dec/80 Modified to use direct calls to CBIOS I/O to make
;	  compatible with CP/M 1.4, 2.x, and MP/M.  (KBP)
;
;09/Dec/80 Rewritten to optimize code, correct stack problems,
;	  add backspace routine, reduce number of bells,
;	  add user selectable operator acknowledge code, 
;	  eliminate unnecessary subroutines, add additional
;	  comments and add base equate for ALTCPM.
;	    By Keith Petersen W8SDZ, and Dave Hardy
;
FALSE	EQU	0	  ;DEFINE FALSE
TRUE	EQU	NOT FALSE ;DEFINE TRUE
;
;Conditional assembly switches
;
STDCPM	EQU	TRUE 	;TRUE IF STANDARD CP/M
ALTCPM	EQU	FALSE	;TRUE IF ALTERNATE CP/M (HEATH H8 & TRS-80 MODEL I)
MPMPRL	EQU	FALSE	;TRUE IF MP/M PROGRAM RELOCATABLE FORMAT
CBBS	EQU	FALSE	;TRUE IF CBBS MESSAGE 
RBBS	EQU	FALSE	;TRUE IF RBBS MESSAGE
MINCBBS EQU	FALSE	;TRUE IF MINICBBS MESSAGE
MINRBBS	EQU	TRUE	;TRUE IF MINIRBBS MESSAGE
DACBELL	EQU	FALSE	;TRUE IF MUSIC BOARD INSTEAD OF CONTROL-G FOR BELL
DACPORT	EQU	24H	;I/O PORT CONTAINING D-TO-A
SPEED	EQU	4	;Speed of CPU in Mhz
;
;Define base address of system
;
	IF	STDCPM
BASE	EQU	0
	ENDIF
;
	IF	ALTCPM
BASE	EQU	4200H
	ENDIF
;
;Define operator acknowledge code
;
ACK	EQU	1BH	;ESCAPE KEY
;
;Define number of alert attempts
;
ALERT	EQU	6	;SIX SEEMS ENOUGH
RINGS	EQU	3	;Number of bells each alert
;
;Define ASCII characters used
;
BEL	EQU	07H	;BELL
CR	EQU	0DH	;CARRIAGE RETURN
LF	EQU	0AH	;LINE FEED
CONTC	EQU	03H	;CONTROL-C, CHAT-MODE EXIT CHARACTER
BAKSP	EQU	08H	;BACKSPACE
;
;BDOS equates
;
BDOS	EQU	BASE+5	;BDOS CALL ADDRESS
PRINT	EQU	9	;PRINT STRING FUNCTION
;
	IF	MPMPRL
	ORG	BASE
	ENDIF
;
	IF	NOT MPMPRL
	ORG	BASE+100H
	ENDIF
;
START:	LXI	H,0
	DAD	SP	 ;GET OLD STACK POINTER
	SHLD	STACK	 ;SAVE IT
	LXI	SP,STACK ;SET NEW STACK POINTER
;
;Initialize jumps to CBIOS for direct I/O
;
	LHLD	BASE+1	 ;GET POINTER TO CBIOS
	LXI	D,3	 ;READY FOR ADD
	DAD	D	 ;HL = CONSTAT VECTOR
	SHLD	CSTAT+1	 ;MODIFY JUMP
	DAD	D	 ;HL = CONIN VECTOR
	SHLD	CONIN+1	 ;MODIFY JUMP
	DAD	D	 ;HL = CONOUT VECTOR
	SHLD	CONOUT+1 ;MODIFY JUMP
;
;Print signon message
;
	CALL	ILPRT	;PRINT:
	DB	CR,LF,'CHAT ver 1.9 - Remote conversation utility.'
	DB	CR,LF,'Program returns to system in 30 seconds'
	DB	CR,LF,'if operator is unavailable.'
	DB	CR,LF,CR,LF,'Alerting operator . ',0
;
;Attempt to alert operator
;
START1:
	IF	DACBELL
	CALL	DING
	CALL	ILPRT
	DB	'. ',0
	ENDIF
;
	IF	NOT DACBELL
	CALL	RING
	CALL	ILPRT	;PRINT BELL, PERIOD, SPACE
	DB	'. ',0
	ENDIF
;
	CALL	DELAY	;WAIT 5 SECONDS
	LDA	CNT	;GET ATTEMPT COUNTER
	DCR	A	;DONE WITH ALERT ATTEMPTS?
	STA	CNT	;SAVE NEW COUNT
	JNZ	START1	;NOT DONE WITH ATTEMPTS, DO MORE
	CALL	ILPRT	;PRINT:
	DB	CR,LF,CR,LF,'Sorry, no operator available - ',CR,LF
	DB	'Please leave your request on '
;
	IF	CBBS
	DB	'CBBS'
	ENDIF
;
	IF	MINCBBS
	DB	'MINICBBS'
	ENDIF
;
	IF	RBBS
	DB	'RBBS'
	ENDIF
;
	IF	MINRBBS
	DB	'MINIRBBS'
	ENDIF
;
	DB	'.',CR,LF,0
	JMP	EXIT	;EXIT TO CP/M
;
	IF	DACBELL
DING:
	MVI	B,0FCH		; INITIAL DAC VALUE
DING1:
	MVI	C,32*SPEED	; DURATION COUNTER
DING2:	SUB	A		; DAC TO 0
	OUT	DACPORT
	CALL	DINGDLY		; WAIT 1/2 CYCLE
	MOV	A,B
	OUT	DACPORT		; MAKE SOME SOUND
	CALL	DINGDLY
	DCR	C
	JNZ	DING2
	ANI	0FCH		; IGNORE LOW BITS
	RZ			; QUIT IF DONE RINGING
	RAR			; DECAY THE TONE SOME
	MOV	B,A		; SAVE IT
	JMP	DING2		; LOOP FOR DURATION
;
DINGDLY:
	MVI	E,20H*SPEED	; COUNTER FOR 1/2 CYCLE DELAY
DINGDLY1:
	DCR	E
	JNZ	DINGDLY1
	RET
	ENDIF
;
RING:
	MVI	B,RINGS
RING1:
	CALL	ILPRT	;Ring my chimes, maybe I'll come
	DB	BEL,0	; as Chuck Foresburg says...
	MVI	A,1	;Delay a while
	CALL	DELAY1	
	DCR	B	;Done ringing
	JNZ	RING1	;No
	RET
;
DELAY:	MVI	A,((40*SPEED)/10)-2	;VALUE for 5 sec between bells
;
DELAY1:	LXI	H,0
	LXI	D,1	;LOOP DELAY VALUES
;
WAIT:	DAD	D	;WAIT BETWEEN BELL RINGS
	JNC	WAIT
	DCR	A	;DONE?
	JNZ	DELAY1	;NO, LOOP
;
	CALL	CSTAT	;GET CONSOLE STATUS
	ORA	A	;CHARACTER WAITING?
	RZ		;NO, RETURN
	CALL	CONIN	;GET CHARACTER
	CPI	ACK	;WAS IT THE RIGHT ANSWER?
	RNZ		;NO? THEN TRY AGAIN
;
	POP	PSW	;FIX STACK
	CALL	ILPRT	;PRINT:
	DB	CR,LF,CR,LF
	DB	'Operator is available, enter CTL-C to exit CHAT'
	DB	CR,LF,BEL,'Please go ahead:'
	DB	CR,LF,CR,LF,0
;
;Conversation routine - uses direct CBIOS I/O to
;prevent control characters from being echoed.
;
CONT:	CALL	CONIN	;GET CONSOLE INPUT WITH NO ECHO
	CPI	CONTC	;CONTROL-C ?
	JZ	EXIT	;YES, EXIT TO CP/M
	CPI	CR	;CARRIAGE RETURN?
	JZ	CRLF	;YES, SEND CRLF
	CPI	BAKSP	;BACKSPACE?
	JZ	BACKIT	;YES, DO BACKSPACE SPACE BACKSPACE
	CPI	' '	;SPACE OR ABOVE?
	JC	CONT	;IT'S A CTL CHARACTER, CONTINUE LOOPING
	PUSH	PSW	;SAVE CHARACTER ON STACK
	MOV	C,A	;CHARACTER TO C FOR CBIOS
	CALL	CONOUT	;SEND CHARACTER TO CONSOLE
	POP	B	;GET CHARACTER TO B FROM STACK
	LDA	LCNT	;GET CHARACTER COUNT
	INR	A	;INCREMENT COUNTER
	STA	LCNT	;SAVE NEW COUNT
	CPI	63	;AT END OF LINE LIMIT?
	JZ	CRLF	;YES, GIVE AUTO CRLF
	CPI	58	;NEAR END OF LINE LIMIT?
	JC	CONT	;NO, CONTINUE LOOPING
	MOV	A,B	;GET CHARACTER
	CPI	' '	;SPACE?
	JNZ	CONT	;NO, CONTINUE LOOPING
;
CRLF:	CALL	ILPRT	;PRINT:
	DB	CR,LF,0
	XRA	A	;ZERO CHARACTER COUNTER
	STA	LCNT
	JMP	CONT	;CONTINUE LOOPING
;
BACKIT:	LDA	LCNT	;GET CHARACTER COUNT
	DCR	A	;SUBTRACT ONE BECAUSE OF BACKSPACE
	JM	CONT	;DONT GO PAST ZERO
	STA	LCNT	;SAVE NEW COUNT
	CALL	ILPRT	;PRINT
	DB	BAKSP,' ',BAKSP,0
	JMP	CONT	;CONTINUE LOOPING
;
;Inline print routine
;
ILPRT:	XTHL		;SAVE HL, GET MSG
;
ILPLP:	MOV	C,M	;GET CHAR
	PUSH	H
	CALL	CONOUT	;OUTPUT IT
	POP	H
	INX	H	;POINT TO NEXT
	MOV	A,M	;TEST
	ORA	A	;...FOR END
	JNZ	ILPLP
	XTHL		;RESTORE HL, RETURN ADDRESS
	RET		;RETURN PAST MESSAGE STRING
;
EXIT:	LHLD	STACK	;GET OLD CP/M (OR MP/M) STACK
	SPHL		;RESTORE OLD STACK POINTER
	RET		;RETURN TO CCP
;
CSTAT:	JMP	$-$	;MODIFIED AT INIT
;
CONIN:	JMP	$-$	;MODIFIED AT INIT
;
CONOUT:	JMP	$-$	;MODIFIED AT INIT
;
CNT:	DB	ALERT	;ALERT COUNTER
LCNT:	DB	0	;LINE POSITION COUNTER
;
	DS	64	;ROOM FOR 32 LEVEL STACK
STACK	DS	2	;OLD CP/M (OR MP/M) STACK SAVED HERE
;
	IF	MPMPRL
	DB	0	;FORCE ALLOCATION OF STORAGE SPACE
	ENDIF
;
	END	START
