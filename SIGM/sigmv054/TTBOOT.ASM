ER.LOG  although  it  may  be 
                ; physically appended to it)...Note: You must type I/O-CAP<cr> 
                size to fit ok for cp/m 2.2
;	by: Jack Burge
;	    518A Fifth Street
;	    East Northport, LI NY   11731
;
;           (516) 261-7219
;
;	Patching to automatically determine `START` equate value
;       inserted by:
;			Henry B. Rothberg
;			1 Laticrete Park North
;			Bethany,  CT 06525
;
;			From excellent coding done by:
;
;			TKI (The Kendall Institute)
;				
;				Bruce Kendall
;				334-A  Camille Court
;				Mountain View,  CA  94040
;
;
;	To use this and ttcbios.asm see TTSDDJ.HLP
;
;	To use, change ONLY the values at MSIZE & DELTA for
;	your system size
;
;*************************************************************
;                                                          ***
MSIZE	EQU	20	; Insert system size in KB here    ***
;                                                          ***
;*************************************************************
;
DELTA	EQU	0000H	; Offset from standard CP/M
;
;*************************************************************
;
BIAS	EQU	(MSIZE-20)*1024-DELTA	; Offset from 20K CP/M system
;
CCP	EQU	3400H+BIAS		; Base of CP/M
;
START	EQU	CCP       ; All worked out for ANY system
;
ORIGIN	EQU	0E000H			; Location of BOOT Prom on SD DJ Board
STACK	EQU	ORIGIN+26EH
DMAADR	EQU	ORIGIN+274H
SECTOR	EQU	ORIGIN+0FH
READ	EQU	ORIGIN+15H
WRITE	EQU	ORIGIN+18H
SEEK	EQU	ORIGIN+0CH
HOME	EQU	ORIGIN+9H
BOOTS	EQU	ORIGIN
;
	ORG	80H
;
LOAD	CALL	SETUP
RLOOP	NOP
	PUSH	B
	CALL	SECTOR
	CALL	READ
	ANA	A
	JNZ	BOOTS
	POP	B
	DCR	B
	JZ	START+1600H
	CALL	NSDMA
	JMP	RLOOP
;
SAVE	LXI	SP,STACK
	CALL	HOME
	CALL	SETUP
WLOOP	NOP
	PUSH	B
	CALL	SECTOR
	CALL	WRITE
	ANA	A
	JNZ	STALL
	POP	B
	DCR	B
STALL	JZ	STALL
	CALL	NSDMA
	JMP	WLOOP
;
INTLZ	LXI	SP,STACK
	CALL	HOME
	LXI	H,80H
	SHLD	DMAADR
	CALL	WRITE
	NOP
DONE	JMP	DONE
;
SETUP	LXI	B,3206H
	LXI	H,START+200H
	SHLD	DMAADR
	RET
;
NSDMA	MVI	A,5
	ADD	C
	MOV	C,A
	SBI	27
	JM	OK
	INR	A
	MOV	C,A
	LXI	D,0F580H
	CPI	1
	JNZ	OK+3
	PUSH	B
	CALL	SEEK
	POP	B
OK	LXI	D,280H
	LHLD	DMAADR
	DAD	D
	SHLD	DMAADR
	MVI	A,(START+1800H)/100H
	SUB	H
	JM	NSDMA
	RET
