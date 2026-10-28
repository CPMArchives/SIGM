;********************************;
;   LOGICAL I/O SYSTEM FOR CP/M  ;
;********************************;
 
;********************************;
;   MISCELLANEOUS EQUATES        ;
;********************************;
 
BOOT	EQU	0000H	;REBOOT ENTRY POINT
CPM	EQU	0005H	;CPM ENTRY POINT

TBUF	EQU	0080H	;TRANS. BUFFER
TFCB	EQU	005CH	;TRANS. FCB

SDISK	EQU	14	;SET DISK FUNCT. CODE
OPEN	EQU	15	;OPEN FUNCTION CODE
CLOSE	EQU	16	;CLOSE FUNCTION CODE
DELET	EQU	19	;DELETE FUNCTION CODE
READ	EQU	20	;READ FUNCTION CODE
WRITE	EQU	21	;WRITE FUNCTION CODE
CREAT	EQU	22	;CREATE FUNCTION CODE
RENAM	EQU	23	;RENAME FUNCTION CODE

;********************************;
;          JUMP VECTORS          ;
;********************************;

	ORG	1000H
	JMP	FFCB	;FILL FCB
	JMP	FMAKE	;FILE CREATE
	JMP	FOPEN	;FILE OPEN
	JMP	FCLOS	;FILE CLOSE
	JMP	FDELE	;DELETE FILE
	JMP	OUTBT	;BYTE OUTPUT
	JMP	GETBT	;BYTE INPUT

;********************************;
;           F F C B              ;
; ROUTINE TO FILL IN ID FIELDS   ;
;            OF FCB              ;
;                                ;
; INPUTS:    HL = A(FCB)         ;
;            DE = A(ID STRING)   ;
; OUTPUTS:   CARRY = ERROR       ;
;********************************;

FFCB:	MVI	M,00	;CLEAR FIRST BYTE OF FCB
	INX	H	;SKIP BYTE
	PUSH	H	;SAVE FCB NAME ADDRESS
	MVI	C,8+3	;SIZE OF ID FIELD
	MVI	A,' '	;SPACE
FFCB0:	MOV	M,A	;CLEAR ID FIELD TO SPACES
	INX	H
	DCR	C
	JNZ	FFCB0
	POP	H	;GET ID FIELD ADDR.
	MVI	C,8	;MAZ SIZE OF NAME
FFCB1:	LDAX	D	;GET ID BYTES
	CPI	' '	;LEADING SPACES?
	JNZ	FFCB2	;NO, CONTINUE
	INX	D	;SKIP LEADING SPACES
	JMP	FFCB1
FFCB2:	LDAX	D	;GET ID BYTE
	CPI	0DH	;CR?
	RZ		;YES, DONE
	CPI	' '	;IMBEDDED SPACE?
	RZ		;YES, DONE
	CPI	'.'	;NAME.TYP SEPARATOR?
	JZ	FFCB3	;YES, PROCESS TYPE
	MOV	M,A	;STORE NAME BYTE
	INX	D
	INX	H	;BUMP POINTERS
	DCR	C	;DECREMENT MAX COUNT
	JNZ	FFCB2	;LOOP
	JMP	FFCBE	;ERROR, NAME TOO BIG

FFCB3:	INX	D	;SKIP OVER '.'
FFCB4:	INX	H	;SKIP TO TYPE FIELD
	DCR	C
	JNZ	FFCB4
	MVI	C,3	;SIZE OF TYPE FIELD
FFCB5:	LDAX	D	;GET ID BYTE
	CPI	0DH	;CR?
	RZ		;YES, DONE
	CPI	' '	;SPACE?
	RZ		;YES, DONE
	MOV	M,A	;STORE TYPE BYTE
	INX	D	;BUMP POINTER
	INX	H
	DCR	C	;DECREMENT MAX COUNT
	JNZ	FFCB5	;LOOP
	RET		;DONE

FFCBE:	STC		;SET CARRY
	RET

;********************************;
;           F M A K E            ;
;  ROUTINE TO CREATE A DISK FILE ;
;                                ;
;  INPUT:    DE=A(FCB)           ;
; OUTPUT:    CARRY=ERROR         ;
;********************************;

FMAKE:	MVI	C,CREAT	;CREATE CODE
	CALL	CPM	;ISSUE CREATE
	CPI	0FFH	;ERROR?
	JZ	FMERR	;YES
	XRA	A	;CLEAR CARRY
	RET
FMERR:	STC		;SET CARRY
	RET		;EXIT

;********************************;
;           F O P E N            ;
;  ROUTINE TO OPEN A DISK FILE   ;
;                                ;
;  INPUT:     DE=A(FCB)          ;
; OUTPUT:     CARRY=ERROR        ;
;********************************;

FOPEN:	MVI	C,OPEN	;OPNE CODE
	CALL	CPM	;ISSUE OPEN
	CPI	0FFH	;ERROR?
	JZ	FOERR	;YES
	XRA	A	;CLEAR CARRY
	RET
FOERR:	STC
	RET

;********************************;
;           F C L O S            ;
;  ROUTINE TO CLOSE A DISK FILE  ;
;                                ;
;  INPUT:     DE=A(FCB)          ;
; OUTPUT:     CARRY=ERROR        ;
;********************************;

FCLOS:	MVI	C,CLOSE	;CLOSE CODE
	CALL	CPM
	CPI	0FFH	;ERROR?
	JZ	FCERR	;YES
	XRA	A	;CLEAR CARRY
	RET
FCERR:	STC
	RET

;********************************;
;            F D E L E           ;
;  ROUTINE TO DELETE A DISK FILE ;
;                                ;
;  INPUT:     DE=A(FCB)          ;
;********************************;

FDELE:	MVI	C,DELET
	CALL	CPM	;ISSUE DELETE
	XRA	A	;RESET CARRY
	RET

;********************************;
;            O U T B T           ;
;   ROUTINE TO OUTPUT A BYTE     ;
;                                ;
;  INPUT:     A=BYTE)            ;
; OUTPUT:     CARRY=ERROR        ;
;********************************;

OUTBT:	STA	TEMP	;SAVE BYTE
OUT1:	LXI	H,OBUF+128
	XCHG		;BUFFER END ADDR IN DE
	LHLD	OUTPT	;CURRENT ADDR IN HL
	CALL	CPHL	;TEST FOR END OF BUFFER
	JZ	OUT2	;YES, WRITE
	LDA	TEMP
	MOV	M,A	;STORE DATA BYTE IN BUFFER
	INX	H	;BUMP BUFFER POINTER
	SHLD	OUTPT	;SAVE BUFFER POINTER
	ORA	A
	RET		;EXIT
OUT2:	LXI	D,OBUF	;POINT TO OUTPUT BUFFER
	LXI	H,TBUF	;TEMP BUFFER
	MVI	B,128
	CALL	MOVE	;COPY BUFFERS
	MVI	C,WRITE	;WRITE CODE
	LXI	D,OFCB	;OUTPUT FCB
	CALL	CPM	;ISSUE WRITE
	CPI	00	;OK?
	JNZ	OERR	;NO
OUT2A:	LXI	H,OBUF	;RESET POINTER
	SHLD	OUTPT
	JMP	OUT1	;CONTINUE
OERR:	STC
	RET

;********************************;
;            G E T B T           ;
;   ROUTINE TO READ A BYTE       ;
;                                ;
;  OUTPUTS:     A=BYTE           ;
;               CARRY=ERROR      ;
;********************************;

GETBT:	LXI	H,IBUF+128
	XCHG		;BUFFER END ADDR. IN DE
	LHLD	INPTR	;CURRENT POINTER IN HL
	CALL	CPHL	;TEST FOR END OF BUFFER
	JZ	GETB2	;YES, READ
GETB1:	MOV	A,M	;GET BYTE
	INX	H	;BUMP POINTER
	SHLD	INPTR	;SAVE POINTER
	ORA	A	;RESET CARRY
	RET
GETB2:	MVI	C,READ	;READ CODE
	LXI	D,IFCB	;FCB ADDRESS
	CALL	CPM	;ISSUE READ
	CPI	00	;ERROR?
	JNZ	IERR	;YES
	LXI	D,TBUF	;POINT TO TEMP BUFFER
	LXI	H,IBUF	;INPUT BUFFER
	MVI	B,128
	CALL	MOVE	;COPY BUFFER
	LXI	H,IBUF	;RESET BUFFER POINTER
	SHLD	INPTR
	JMP	GETB1	;CONTINUE
IERR:	STC
	RET

;********************************;
;   MISCELLANEOUS SUBROUTINES    ;
;********************************;

;********************************;
;            M O V E             ;
;  ROUTINE TO MOVE BLOCKS OF DATA;
;********************************;
MOVE:	LDAX	D	;GET BYTE
	MOV	M,A	;STORE BYTE
	INX	H
	INX	D	;BUMPP POINTERS
	DCR	B	;DECREMENT COUNT
	JNZ	MOVE	;LOOP
	RET

;********************************;
;             C P H L            ;
;  ROUTINE TO COMPARE HL VS DE   ;
;********************************;

CPHL:	MOV	A,H
	CMP	D
	RNZ
	MOV	A,L
	CMP	E
	RET

;********************************;
;             D A T A            ;
;********************************;

TEMP:	DS	2	;TEMP SAVE WORD

IFCB:	DS	33	;INPUT FCB
OFCB:	DS	33	;OUTPUT FCB

OUTPT:	DW	OBUF	;OUTPUT POINTER
INPTR:	DW	IBUF+128;INPUT POINTER

OBUF:	DS	128	;INPUT BUFFER
IBUF:	DS	128	;OUTPUT BUFFER
	END
