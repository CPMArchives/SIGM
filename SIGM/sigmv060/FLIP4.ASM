;	title	'FLIP - flip originate/answer mode under "bye"'
;	Originally written by Bruce Ratoff.
;
;	updated 6/2/80 to uppercase message and require exactly
;		control-c or return, ignoring all else. (BR)
;	updated 6/6/80 to work with PMMI modem and to re-ask for
;		input if invalid answer. Keith Petersen, W8SDZ.
;	updated 8/8/80 to add conditional assembly for either
;		PMMI or D C Hayes modem cards (BR)
;	updated 8/20/81 to add conditional assembly for either
;		BYE or non-BYE remote systems. Howard Booker, W8IU
;
;
;It should be understood that when using FLIP with the
;DC Hayes modem which combines the baud rate select and
;modem control port, you will automatically select the
;highest rate (either 300 or 450 baud). Hence, if you
;are not equipped to communicate at these rates then
;FLIP should not be used. If you still desire to use
;this program with the DC Hayes but would like to avoid
;this problem, then all functions sent to the modem control
;port on your system should passed to a ram location.
;Hence to change to originate, this locataion can be
;ored with 04 and written to the control port. (HB)
;
;

FALSE	EQU	0	;BASIC LOGIC DEFINITIONS
TRUE	EQU	NOT FALSE
;
FASTCLK	EQU	 TRUE	;SET TRUE IF 4MHZ SYSTEM CLOCK
;
BYE	EQU	TRUE	;SET TRUE IF RUNNING UNDER BYE
;
PMMI	EQU	FALSE	;SET TRUE IF PMMI MODEM
DCH	EQU	 TRUE	;SET TRUE IF D C HAYES MODEM
;
	IF	DCH
MODCTL	EQU	82H	;D C HAYES MODEM CONTROL PORT ADDRESS
	ENDIF
;
	IF	PMMI
MODCTL	EQU	0C0H	;PMMI MODEM CONTROL PORT ADDRESS
	ENDIF
;
BDOS	EQU	5
DBUFF	EQU	80H
;
PMESSG	EQU	9
CHRINP	EQU	1
;
	ORG	100H
;
FLIP:	IF	BYE
	LXI	H,0
	DAD	SP
	SHLD	SAVRET
	LXI	SP,SAVRET+100
	ENDIF
;
	MVI	C,PMESSG
	LXI	D,MESSG
	CALL	BDOS
;
FLIP1:	MVI	C,PMESSG
	LXI	D,MESSG2
	CALL	BDOS
	MVI	C,CHRINP
	CALL	BDOS
	CPI	3	;CTL-C?
;
	IF	BYE
	JZ	CPMRET
	ENDIF
	JZ	0	;YES, EXIT TO CP/M WARM BOOT
	CPI	13	;CARRIAGE RETURN?
	JNZ	FLIP1	;NO, ASK FOR ANOTHER INPUT
;
;SET MODEM FOR OFF-HOOK ORIGINATE
	IF	PMMI
	MVI	A,1DH
	ENDIF
	IF	DCH
	MVI	A,87H	;ALSO HIGH BAUD
	ENDIF
	OUT	MODCTL
	IF	FASTCLK
	MVI	C,20	;10 SECONDS AT 4MHZ
	ENDIF
	IF	NOT FASTCLK
	MVI	C,10	;10 SECOND COUNT
	ENDIF
;
;DELAY LOOP - NUMBER OF SECONDS IN C REGISTER
CTLP:	LXI	H,0	;ONE SECOND DELAY LOOP
	LXI	D,1
;
SLO:	DAD	D	;DONE WITH ONE SECOND LOOP?
	JNC	SLO	;NO, DO ANOTHER LOOP
	DCR	C	;ONE LESS SECOND
	JNZ	CTLP	;NOT DONE WITH COUNT
;
	IF	PMMI
;SET PMMI MODEM CHIP SO IT CAN HANG UP ON LOSS OF CARRIER
	MVI	A,1CH	;SET PMMI MODEM FOR ORIGINATE
	OUT	MODCTL
	ENDIF
;
	IF	NOT BYE
	JMP	0	;EXIT TO CP/M WARM BOOT
	ENDIF
;
CPMRET:	LHLD	SAVRET
	SPHL
	RET
;
;
MESSG:
	DB	'IF YOU HIT RETURN, YOU HAVE 15 SECONDS TO SWITCH',13,10
	DB	'TO ANSWER MODE OR YOU WILL LOSE THE CONNECTION.',13,10
	DB	'IF YOUR MODEM INTERRUPTS THE PHONE LINE WHILE',13,10
	DB	'REVERSING, YOU WILL LOSE THE CALL UNLESS YOU',13,10
	DB	'PICK UP THE PHONE FIRST.',13,10,'$'
;
MESSG2:	DB	13,10,'TYPE RETURN TO SWITCH, CONTROL-C TO ABORT: $'
;
SAVRET: DW	1
;
	END
