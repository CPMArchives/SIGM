;********************************************************
;*							*
;*		 KEYBOARD INPUT PATCH			*
;*							*
;*		  SIMULATED FUNCTION			*
;*    KEYS WITH CPM IN GENERAL; THE SORCERER COMPUTER	*
;*    IN PARTICULAR, USING KIP.HEX AND KID.COM &  DDT	*
;*							*
;*    AS PUBLISHED IN DR DOBBS JOURNAL, ISSUE 55  MAY	*
;*    1981, BY JOHN B PALMER.				*
;*	   P.O. BOX 23					*
;*	   BOONSVILLE, CA, 95415			*
;*	   USA						*
;*							*
;*	See the Dr. Dobbs article for commented code	*
;*							*
;********************************************************
;
;	Keyed in By	John Cepak
;		 	Australia
;
FRERAM	EQU	5C00H
TEXT	EQU	FRERAM+256
KIFUN	EQU	01
TAB	EQU	09
LF	EQU	0AH
CR	EQU	0DH
EOF	EQU	01AH
;
ACTIVE	EQU	0FFH
INACTIV	EQU	0
;
	ORG	FRERAM
;
KIP:
OLDST:	JMP	0
OLDIN:	JMP	0
NEWST:	JMP	STAT
NEWIN:	JMP	INP
;
ASWITCH	DB	0
EOSTR:	DB	0
STRPTR:	DW	0
SAVCHR:	DB	0
;
STAT:
	LDA	SWITCH
	ORA	A
	RNZ
	JMP	OLDST
;
INP:
	LDA	SWITCH
	ORA	A
	JNZ	STRING
	CALL	OLDIN
	CPI	KIFUN
	RNZ
	CALL	OLDIN
	STA	SAVCHR
	ORI	20H
	SUI	'`'
	SUI	16
	CC	OLDIN
	LDA	SAVCHR
SEARCH:
	PUSH	B
	PUSH	H
	CPI	KIFUN
	JZ	PEEK
	MOV	B,A
	LXI	H,TEXT
TRY:
	CALL	IGNORE
	JC	EXIT
	JZ	TRY
	CMP	B
	JZ	FOUND
	CALL	SKIP
	JNC	TRY
EXIT:
	MVI	A,'?'
	POP	H
	POP	B
	RET
;
PEEK:
	MVI	A,CR
	CALL	DIO
	MVI	A,LF
	LXI	H,TEXT
PRINT:
	CALL	DIO
	MOV	A,M
	INX	H
	CPI	EOF
	JNZ	PRINT
	POP	H
	POP	B
	MVI	A,CR
	RET
;
DIO:
	PUSH	D
	PUSH	H
	LHLD	01
	LXI	B,9
	DAD	B
	MOV	C,A
	CALL	VIAHL
	POP	H
	POP	D
	RET
;
VIAHL:
	PCHL
FOUND:
	MOV	A,M
	STA	EOSTR
	INX	H
	SHLD	STRPTR
	MVI	A,ACTIVE
FIN:
	STA	SWITCH
	POP	H
	POP	B
	JMP	INP
;
SKIP:
	MOV	A,M
	CALL	EOFCHR
	RC
	MOV	C,A
	INX	H
TSTCHR:
	MOV	A,M
	INX	H
	CALL	EOFCHR
	RC
	CMP	C
	RZ
	JMP	TSTCHR
;
IGNORE:
	MOV	A,M
	INX	H
	CPI	' '
	RZ
	CPI	9
	RZ
	CPI	','
	RZ
	CPI	CR
	RZ
	CPI	LF
	RZ
EOFCHR:
	CPI	EOF
	STC
	CMC
	RNZ
	ORA	A
	STC
	RET
;
STRING:
	CALL	GETCHR
	RM
	CPI	'^'
	RNZ
	CALL	GETCHR
	RM
	CPI	'^'
	RZ
	ANI	01FH
	RET
;
GETCHR:
	PUSH	H
	LHLD	STRPTR
	MVI	A,EOF
	CMP	M
	JZ	WIERD
	LDA	EOSTR
	CMP	M
	JZ	WIERD
	INX	H
	SHLD	STRPTR
	CMP	M
	DCX	H
	MOV	L,M
	JNZ	READY
	SUB	A
	STA	SWITCH
READY:
	MOV	A,L
	POP	H
	ORA	A
	RET
;
WIERD:
	POP	PSW
	SUB	A
	STA	SWITCH
	DCR	A
	MVI	A,'?'
	POP	H
	RET
;
	END
