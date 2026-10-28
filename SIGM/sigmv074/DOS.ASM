;********************************************************
;*							*
;*	     SYSTEM ADDRESS LOCATOR FOR CP/M		*
;*							*
;********************************************************
;
;	By	Bill Bolton,
;		Software Tools,
;		P.O. Box 80,
;		Newport Beach,
;		NSW, 2106
;		Australia
;
;		November 10, 1981
;
;	This program was hacked together out of bits of
;	existing code from BDLOC, TPA and other programs.
;

BIOS	EQU	0		;BIOS WARM BOOT ENTRY
BDOS	EQU	5		;BDOS ENTRY POINT
ALF	EQU	0AH
ACR	EQU	0DH
;
VERS	EQU	10
;
	ORG	100H
;
DOSLOC:
	CALL	PRINT$MESSAGE
;
	DB	ACR,ALF
	DB	'Software Tools System Address Locator'
	DB	ACR,ALF,'Version ',VERS/10 + '0','.', VERS MOD 10 +'0'
	DB	ACR,ALF,ALF,0
;
	CALL	PRINT$MESSAGE
;
	DB	'The Address of the system  BIOS  is ',0
;
	LDA	BIOS+2
	CALL	PRINT$HEX
	CALL	PRINT$MESSAGE
;
	DB	'00',0
;
	CALL	PRINT$MESSAGE
;
	DB	ACR,ALF
	DB	'The Address of the system  BDOS  is ',0
;
	LDA	BDOS+2
	CALL	PRINT$HEX
	CALL	PRINT$MESSAGE
;
	DB	'00',0
;
	CALL	PRINT$MESSAGE
;
	DB	ACR,ALF
	DB	'The Address of the system  CCP   is ',0
;
	LDA	BDOS+2
	SUI	008H
	CALL	PRINT$HEX
	CALL	PRINT$MESSAGE
;
	DB	'00',ACR,ALF,0
;
	CALL	PRINT$MESSAGE
;
	DB	ACR,ALF
	DB	'Total TPA space with CCP overlay is ',0
;
	LDA	BDOS+2
	SUI	1
	CALL	PRINT$HEX
	CALL	PRINT$MESSAGE
;
	DB	'00',0
;
	CALL	PRINT$MESSAGE
;
	DB	ACR,ALF
	DB	'Total TPA space with CCP  intact is ',0
;
	LDA	BDOS+2
	SUI	9
	CALL	PRINT$HEX
	CALL	PRINT$MESSAGE
;
	DB	'00',ACR,ALF,0
;
	RET
;
PRINT$HEX:
	PUSH	PSW
	RLC
	RLC
	RLC
	RLC
	CALL	HEX$1
	POP	PSW
HEX$1:
	ANI	00FH
	CPI	10
	JNC	ALPHA
	ADI	'0'
	JMP	CONOUT
;
ALPHA:
	ADI	'7'
	JMP	CONOUT
;
PRINT$MESSAGE:
	XTHL
LOOP:
	MOV	A,M
	INX	H
	ORA	A
	JZ	EXIT
	CALL	CONOUT
	JMP	LOOP
;
EXIT:
	XTHL
	RET
;
CONOUT:
	PUSH	H
	PUSH	D
	PUSH	B
	MOV	E,A
	MVI	C,2
	CALL	BDOS
	POP	B
	POP	D
	POP	H
	RET
;
	END
