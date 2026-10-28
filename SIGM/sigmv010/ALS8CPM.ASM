;**************************************************
;*                                                *
;*               ALS8CPM.ASM                      *
;*                                                *
;*  PROGRAM FOR CONVERTING PROCESSOR TECHNOLOGY   *
;*  ALS-8/SPKG-1 ASSEMBLER FILES TO CP/M FORMAT   *
;*                                                *
;*            (C) COPYRIGHT 1980                  *
;* ED ELIZONDO 6 CYPRESS CT EAST WINDSOR NJ 08520 *
;*     A L L   R I G H T S   R E S E R V E D      *
;*                                                *
;* THIS PROGRAM MAY BE USED FREELY BY COMPUTER    *
;* HOBBYISTS FOR NON-COMMERCIAL APPLICATIONS.     *
;* IT MAY NOT BE USED FOR COMMERCIAL APPLICATIONS *
;* OR SOLD WITHOUT WRITTEN PERMISSION OF THE      *
;* AUTHOR.                                        *
;*                                                *
;*          REV 1.6      31 JAN 1980              *    
;*                                                *
;**************************************************
;
; NOTE:  This program processes assembly language files
; prepared for the Processor Technology ALS-8 or Software
; Package No 1 assemblers to a format compatible with 
; the CP/M ASM assembler. It requires the presence of
; CUTER/SOLOS or some other means of loading the ALS-8
; source file onto memory so that it can be saved by CP/M.
; It does not require the presence of anything other than
; CP/M during the remaining operations.
;
; The translation process operates in accordance with
; the following algorithms:
;  Each line is converted independently.  The line byte count
; and line number fields are deleted from the source lines
; and each line is terminated with a CR/LF sequence.
;  A semicolon is placed ahead of all comment lines (for
; compatibility with MAC) and ahead of all comment fields.
; Leading spaces are deleted from comment fields only.
; Comment lines and the remainder of comment fields are
; passed unchanged, except for deletion of any exclamation
; marks.
;  Periods used as dummy operands for formatting purposes
; are removed, as well as any leading spaces appearing in
; instructiona and operand fields.  Operands enclosed in
; single quotes are passed unchanged.
;  ASC pseudo-operators are changed to DB and the corresponding
; delimiters changed to single quotes.
;  The '>' pseudo-operator is converted to an 'AND 0FFH' post
; operator and the '<' is similarly converted to a 'SHR 8'.
;  Instruction, operand and comment fields are tabbed
; and colons are added to labels to "pretty" the output.
;  The program utilizes slightly modified versions of the
; CP/M User's Group LIOS.ASM disk I/O routines (CPMUG 1.19)
;
; TO USE: 1) load your ALS-8 format program into RAM at 100H
;            (If using SOLOS/CUTER, note the first two digits
;             of program size returned by the load message.
;             Convert to decimal and add 1 to obtain the
;             number nn required in step 3).
;         2) boot up CP/M
;         3) type SAVE nn NAME1.EXT (where nn is number of
;            pages of program size in decimal)
;         4) run the conversion program by typing:
;             ALS8CPM NAME1.EXT NAME2.ASM
;            where NAME2.ASM is the desired name of the CP/M
;            compatible output file (note spaces between
;            the above name fields)
;         5) edit the resulting ASM file to add the appropriate
;            ORG statement.
;	  6) assemble to locate any residual unique errors.
;
;*************************************************************
;
;	BDOS ADDRESSES:
;
BDOS:	EQU	0005		;BDOS ENTRY POINT
SOURCE:	EQU	5CH		;SOURCE FILE FCB
TBUF:	EQU	0080H		;TRANSFER BUFFER
;
;	BDOS FUNCTION CODES:
;
PRINT:	EQU	9
OPEN:	EQU	15
CLOSE:	EQU	16
MAKE:	EQU	22
READ:	EQU	20
WRITE:	EQU	21
DELETE:	EQU	19
;
;	ASCII CODES:
;
SPACE:	EQU	20H
QUOTE:	EQU	27H
TAB:	EQU	09H
CR:	EQU	0DH
LF:	EQU	0AH
;
;***************************
;*	MAIN PROGRAM       *
;***************************
;
	ORG	100H
;
	LXI	H,0		;GET OLD STACK POINTER
	DAD	SP
	SHLD	OLDSTK		;SAVE IT FOR EXIT
	LXI	SP,NEWSTK	;SET UP NEW STACK
;
	LXI	D,MSSG0		;SAY HELLO
	CALL	MESSAGE
;
	CALL	GETNAMES	;GET FILE NAMES FROM COMMAND LINE
	CALL	OPENFILES	;OPEN FILES FOR ACCESS
	LXI	D,MSSG8		;WE'RE DOING FINE
	CALL	MESSAGE
;
	CALL	PROCESS		;PROCESS LINE BY LINE
	CALL	WEOF		;FILL LAST INCOMPLETE PAGE
;
ABEND:	CALL	CLOSEFILE	;CLOSE FILES
	LXI	D,MSSG9		;WE'RE FINISHED
	CALL	MESSAGE
;
FIN:	LHLD	OLDSTK		;RESTORE OLD STACK POINTER
	SPHL
	RET			;RETURN TO CP/M
;
;
;****************************************
;           G E T N A M E S             *
; SUBROUTINE TO CHECK & GET FILE NAMES  *
;****************************************
;
GETNAMES:
	LDA	SOURCE+1	;FIRST CHAR OF SOURCE NAME
	CPI	SPACE		;EMPTY?
	JZ	ERROR6		;YES, ERROR
	LDA	SOURCE+17	;FIRST CHAR OF DEST NAME
	CPI	SPACE		;EMPTY?
	JZ	ERROR7		;YES, ERROR

;	MOVE DEST FCB TO SAFE PLACE
	LXI	D,SOURCE+16	;START OF TEMP DEST FCB
	LXI	H,DEST		;WORKING DEST FCB
	MVI	B,16		;NUMBER OF FCB CHARACTERS
	CALL	MOVE		;MOVE NAME
;
;	INITIALIZE FCB'S
	XRA	A		;GET A 0
	STA	SOURCE+32	;ZERO SOURCE NR FIELD
	STA	DEST+32		;ZERO DEST NR FIELD
	RET
;
;****************************************
;         O P E N F I L E S             *
;  SUBROUTINE TO OPEN FILES FOR ACCESS  *
;****************************************
;
OPENFILES:
	MVI	C,OPEN		;GET OPEN FUNCTION
	LXI	D,SOURCE
	CALL	BDOS		;OPEN SOURCE FILE
	CPI	0FFH		;OPEN ERROR?
	JZ	ERROR1		;YES, ABORT
;
	MVI	C,DELETE	;DELETE FUNCTION
	LXI	D,DEST
	CALL	BDOS		;DELETE EXISTING DEST FILE
	MVI	C,MAKE		;MAKE FUNCTION
	LXI	D,DEST
	CALL	BDOS		;CREATE NEW DEST FILE
	CPI	0FFH		;MAKE ERROR?
	JZ	ERROR3		;YES, ABORT
	MVI	C,OPEN		;OPEN FUNCTION
	LXI	D,DEST
	CALL	BDOS		;OPEN DEST FILE
	RET
;
;***********************************
;         P R O C E S S            *
;  ROUTINE TO PROCESS EACH LINE    *
;***********************************

PROCESS:
	XRA	A		;CLEAR STRING FLAG
	STA	FLAG
	CALL	GETBYT		;GET LINE CHAR COUNT
	CPI	1		;END OF FILE?
	JZ	EOFMARK		;YES, PROCESS IT
	DCR	A		;UPDATE CHAR LINE COUNT
	STA	EOLCNT		;SAVE IT

	MVI	B,5		;FIELD COUNT
LNUM:	PUSH	B		;MOVE PAST LINE NUMBER FIELD
	CALL	GETBYT		;READ A BYTE
	POP	B
	CALL	COUNT		;DECREMENT LINE COUNT
	JZ	PREMEND		;PREMATURE END OF LINE
	DCR	B		;DECREMENT FIELD COUNT
	JNZ	LNUM		;UNTIL DONE
;
LABEL:	CALL	GETBYT		;PROCESS LABEL FIELD
	CPI	'*'		;COMMENT LINE?
	JZ	COMLINE		;YES, PROCESS IT
	CPI	SPACE		;MISSING LABEL?
	JZ	INSTR		;THEN PROCESS INST
LABEL1:	CALL	OUTBYT		;OUTPUT LABEL CHAR
	CALL	COUNT		;DECREMENT LINE COUNT
	JZ	EOLINE		;IF END OF LINE
	CALL	GETBYT		;GET NEXT BYTE
	CPI	SPACE		;END OF ALS-8 LABEL?
	JZ	LABEL2		;YES, EXIT LOOP
	CPI	':'		;END OF INTEL LABEL?
	JNZ	LABEL1		;NO, KEEP GOING
LABEL2:	MVI	A,':'		;YES, OUTPUT A COLON
	CALL	OUTBYT		;AND DROP THRU

INSTR:	MVI	A,TAB		;PROCESS INSTR FIELD
	CALL	OUTBYT		;TAB TO NEXT COLUMN
	CALL	DELSP		;DELETE LEADING SPACES
	JC	EOLINE		;IF END OF LINE
		
;	CHECK FOR ASC PSEUDO-OP
	CPI	'A'		;POSSIBLE ASC PSEUDO OP?
	JNZ	INSTR2		;NO WAY
	CALL	COUNT		;DECREMENT LINE COUNT
	JZ	EOLINE		;IF END OF LINE
	CALL	GETBYT		;GET NEXT BYTE
	CPI	'S'		;ASC PSEUDO OP?
	JNZ	RECOV2		;NO, RECOVER LAST TWO BYTES
	CALL	COUNT		;DECREMENT LINE COUNT
	JZ	EOLINE		;IF END OF LINE
	CALL	GETBYT		;GET NEXT BYTE
	CPI	'C'		;ASC PSEUDO OP?
	JNZ	RECOV3		;NO, RECOVER LAST 3 BYTES
;
;	CONVERT ASC PSEUDO OP TO DB
	LXI	D,DBOP		;OUTPUT A 'DB'
	CALL	PUTSTRING
	MVI	A,TAB		;END OF INSTR FIELD
	CALL	OUTBYT		;TAB TO NEXT COLUMN
;
;	HANDLE ASC OPERAND AND CONVERT DELIMITERS 
	CALL	DELSP		;DELETE EXTRA SPACES
	JC	EOLINE		;IF END OF LINE
	STA	DELIM		;SAVE THE ASC DELIMITER
	MVI	A,QUOTE		;GET CPM DELIMITER
ASC2:	CALL	OUTBYT		;OUTPUT IT
	CALL	COUNT		;DECREMENT LINE COUNT
	JZ	EOLINE		;IF END OF LINE
	LDA	DELIM		;GET DELIMITER
	MOV	B,A		;INTO B
	PUSH	B		;SAVE B
	CALL	GETBYT		;GET NEXT BYTE
	POP	B		;RESTORE B
	CMP	B		;DELIMITER?
	JNZ	ASC2		;NO, KEEP GOING
	MVI	A,QUOTE		;YES, GET CPM DELIMITER
	CALL	OUTBYT		;OUTPUT IT
	JMP	COMMENT		;REMAINDER MUST BE COMMENT
;
;	RECOVER LAST TWO BYTES (NOT ASC PSEUDO OP)
RECOV2:	STA	TEMP2		;SAVE LAST BYTE
	MVI	A,'A'		;FIRST BYTE WAS AN 'A'
	CALL	OUTBYT		;OUTPUT IT
	LDA	TEMP2		;GET LAST BYTE
	JMP	INSTR2		;CONTINUE NORMALLY
;
;	RECOVER LAST 3 BYTES (NOT ASC PSEUDO OP)
RECOV3:	STA	TEMP2		;SAVE LAST BYTE
	LXI	D,ASOP		;WE KNOW LAST 2 BYTES WERE 'AS'
	CALL	PUTSTRING	;SO OUTPUT THEM
	LDA	TEMP2		;GET LAST BYTE
;
;	HANDLE REMAINDER OF INSTRUCTION FIELD
INSTR2:	CALL	PASS		;OUTPUT REST OF FIELD
	JC	EOLINE		;IF END OF LINE
;
OPERAND:
	MVI	A,TAB		;PROCESS OPERAND FIELD
	CALL	OUTBYT		;TAB TO NEXT COLUMN
	CALL	DELSP		;DELETE LEADING SPACES
	JC	EOLINE		;IF END OF LINE
;
;	CHECK FOR '<' SPECIAL OPERATOR
OPER1:	CPI	'<'		;LEFT BYTE MASK?
	JNZ	OPER3		;NO WAY
	CALL	COUNT		;DECREMENT END OF LINE COUNT
	JZ	EOLINE		;IF END OF LINE
	CALL	GETBYT		;GET NEXT BYTE
	CALL	PASS		;OUTPUT REST OF FIELD
	JC	EOLINE		;IF PREMATURE END OF LINE
	LXI	D,LBYTE		;OUTPUT A SHIFT RIGHT EXPR
	CALL	PUTSTRING
	JMP	COMMENT		;REMAINDER MUST BE COMMENT
;
;	CHECK FOR '>' SPECIAL OPERATOR
OPER2:	CPI	'>'		;RIGHT BYTE MASK?
	JNZ	OPER3		;NO WAY
	CALL	COUNT		;DECREMENT LINE COUNT
	JZ	EOLINE		;IF END OF LINE
	CALL	GETBYT		;GET NEXT BYTE
	CALL	PASS		;OUTPUT REST OF FIELD
	JC	EOLINE		;IF END OF LINE
	LXI	D,RBYTE		;THEN A MASK RIGHT EXP
	CALL	PUTSTRING
	JMP	COMMENT		;REMAINDER MUST BE COMMENT

;	HANDLE REMAINDER OF OPERAND
OPER3:	CPI	QUOTE		;IS IT A QUOTE?
	CZ	TOGGLE		;YES, TOGGLE STRING FLAG
	CPI	'.'		;IS IT A PERIOD?
	JZ	STRING		;YES, CHECK IF PART OF STRING
	CPI	SPACE		;IS IT A SPACE?
	JNZ	OPER4		;NO, PROCESS IT
STRING:	STA	TEMP		;SAVE BYTE
	LDA	FLAG		;IS CHAR WITHIN STRING?
	ORA	A
	JZ	COMMENT		;NO, END OF OPERAND FIELD
	LDA	TEMP		;YES, GET BACK BYTE
OPER4:	CALL	OUTBYT		;OUTPUT BYTE
	CALL	COUNT		;DECREMENT LINE COUNT
	JZ	EOLINE		;IF END OF LINE
	CALL	GETBYT		;GET NEXT BYTE
	JMP	OPER3		;KEEP GOING
;
;
COMLINE:			;PROCESS COMMENT LINE
	MVI	A,';'		;GET A SEMICOLON
	JMP	CLOOP		;OUTPUT IT & REST OF LINE
COMMENT:			;PROCESS COMMENT FIELD
	MVI	A,TAB
	CALL	OUTBYT		;TAB TO NEXT COLUMN
	MVI	A,';'		;GET A SEMICOLON
	CALL	OUTBYT		;OUTPUT IT
	CALL	DELSP		;DELETE LEADING SPACES
	JC	EOLINE		;IF END OF LINE
	CPI	'!'		;EXCLAMATION MARK?
	JZ	CLOOP2		;YES, DELETE IT
CLOOP:	CALL	OUTBYT		;NO, OUTPUT IT
CLOOP2:	CALL	COUNT		;DECREMENT LINE COUNT
	JZ	EOLINE		;IF END OF LINE
	CALL	GETBYT		;GET NEXT BYTE
	CPI	'!'		;EXCLAMATION MARK?
	JZ	CLOOP2		;YES, DELETE IT
	JMP	CLOOP		;KEEP GOING

PREMEND:			;PREMATURE END OF LINE
	MVI	A,CR		;OUTPUT A CARRIAGE RET
	CALL	OUTBYT
EOLINE:	MVI	A,LF		;NORMAL END OF LINE
	CALL	OUTBYT		;OUTPUT A LINE FEED
	JMP	PROCESS		;PROCESS NEXT LINE
;
EOFMARK:
	MVI	A,'Z'-40H	;GET A CPM EOF MARK
	CALL	OUTBYT		;OUTPUT IT
	RET			;EXIT PROCESS
;
;
TOGGLE:	PUSH	PSW		;FLAG SET IF STRING IN QUOTES
	LDA	FLAG		;TOGGLE FLAG
	CMA
	STA	FLAG		;THAT'S ALL
	POP	PSW
	RET
;
;	DELETE EXTRA SPACES
DELSP:	CALL	COUNT		;DECREMENT LINE COUNT
	JZ	DELSP2		;IF PREMATURE END OF LINE
	CALL	GETBYT		;GET NEXT BYTE
	CPI	SPACE		;SPACE?
	JZ	DELSP		;YES, DELETE IT
	ORA	A		;RESET CARRY FLAG
	RET			;RETURN WITH BYTE
DELSP2:	STC			;SET CARRY FLAG FOR EOL
	RET			;RETURN WITH FLAG SET
;
;	OUTPUT BYTES UNTIL END OF FIELD
PASS:	CALL	OUTBYT		;OUTPUT BYTE
	CALL	COUNT		;DECREMENT LINE COUNT
	JZ	PASS2		;IF PREMATURE END OF LINE
	CALL	GETBYT		;GET NEXT BYTE
	CPI	SPACE		;END OF FIELD?
	JNZ	PASS		;NO, KEEP GOING
	ORA	A		;RESET CARRY FLAG
	RET			;RETURN WITH SPACE
PASS2:	STC			;SET CARRY FLAG FOR EOL
	RET			;RETURN WITH FLAG SET
;
COUNT:	LDA	EOLCNT		;DECREMENT END OF LINE COUNT
	DCR	A
	STA	EOLCNT		;THAT'S ALL
	RET
;
;*************************************
;        P U T S T R I N G           *
; ROUTINE TO OUTPUT A STRING TO DISC *
;*************************************
;
PUTSTRING:
	LDAX	D		;GET A BYTE
	CPI	'$'		;TERMINATOR?
	RZ			;YES, RETURN
	PUSH	D		;SAVE D&E
	CALL	OUTBYT		;NO, OUTPUT BYTE
	POP	D		;RESTORE D&E
	INX	D		;BUMP POINTER
	JMP	PUTSTRING	;KEEP GOING
;
;********************
;  CANNED STRINGS:  *
;********************
;	
ASOP:	DB	'AS$'		;STRING TO RECOVER AS STRING
DBOP:	DB	'DB$'		;STRING TO REPLACE ASC OP
RBYTE:	DB	' AND 0FFH$'	;STRING TO REPLACE ">" OP
LBYTE:	DB	' SHR 8$'	;STRING TO REPLACE "<" OP


;*********************************
;            O U T B Y T         *
;   ROUTINE TO OUTPUT A BYTE     *
;                                *
;  INPUT:     A=BYTE             *
;*********************************

OUTBYT:	STA	TEMP		;SAVE BYTE
OUT1:	LXI	H,OBUF+128
	XCHG			;BUFFER END ADDR IN DE
	LHLD	OUTPT		;CURRENT ADDR IN HL
	CALL	CPHL		;TEST FOR END OF BUFFER
	JZ	OUT2		;YES, WRITE
	LDA	TEMP
	MOV	M,A		;STORE DATA BYTE IN BUFFER
	INX	H		;BUMP BUFFER POINTER
	SHLD	OUTPT		;SAVE BUFFER POINTER
	ORA	A
	RET			;EXIT
OUT2:	LXI	D,OBUF		;POINT TO OUTPUT BUFFER
	LXI	H,TBUF		;TEMP BUFFER
	MVI	B,128
	CALL	MOVE		;COPY BUFFERS
	MVI	C,WRITE		;WRITE FUNCTION
	LXI	D,DEST		;OUTPUT FCB
	CALL	BDOS		;ISSUE WRITE
	CPI	0FFH	
	JZ	ERROR3
	CPI	2
	JZ	ERROR4
	CPI	1
	JZ	ERROR5
	LXI	H,OBUF		;RESET POINTER
	SHLD	OUTPT
	JMP	OUT1		;CONTINUE

;*********************************
;         G E T B Y T            *
;   ROUTINE TO READ A BYTE       *
;                                *
;  OUTPUT:      A=BYTE           *
;*********************************

GETBYT:	LXI	H,IBUF+128
	XCHG			;BUFFER END ADDR. IN DE
	LHLD	INPTR		;CURRENT POINTER IN HL
	CALL	CPHL		;TEST FOR END OF BUFFER
	JZ	GETB2		;YES, READ
GETB1:	MOV	A,M		;GET BYTE
	INX	H		;BUMP POINTER
	SHLD	INPTR		;SAVE POINTER
	ORA	A		;RESET CARRY
	RET
GETB2:	MVI	C,READ		;READ FUNCTION
	LXI	D,SOURCE	;FCB ADDRESS
	CALL	BDOS		;ISSUE READ
	CPI	0		;ERROR?
	JNZ	ERROR2		;YES
	LXI	D,TBUF		;POINT TO TEMP BUFFER
	LXI	H,IBUF		;INPUT BUFFER
	MVI	B,128
	CALL	MOVE		;COPY BUFFER
	LXI	H,IBUF		;RESET BUFFER POINTER
	SHLD	INPTR
	JMP	GETB1		;CONTINUE

;***********************************
;            M O V E               *
;  ROUTINE TO MOVE BLOCKS OF DATA  *
;***********************************
MOVE:	LDAX	D		;GET BYTE
	MOV	M,A		;STORE BYTE
	INX	H
	INX	D		;BUMP POINTERS
	DCR	B		;DECREMENT COUNT
	JNZ	MOVE		;LOOP
	RET

;*********************************
;             C P H L            *
;  ROUTINE TO COMPARE HL VS DE   *
;*********************************

CPHL:	MOV	A,H
	CMP	D
	RNZ
	MOV	A,L
	CMP	E
	RET

;**********************************
;       W E O F                   *
;  ROUTINE TO FILL UP LAST RECORD *
;  WITH CP/M EOF MARKS            *
;**********************************

WEOF:	LXI	H,OBUF+128	;END OF BUFFER
	XCHG
	LHLD	OUTPT		;WHERE WE ARE
	CALL	CPHL		;SAME?
	JZ	OUTBYT		;YES, WRITE LAST RECORD
	MVI	A,'Z'-40H	;NO, GET A CPM EOF MARK
	CALL	OUTBYT		;OUTPUT IT TO BUFFER
	JMP	WEOF		;KEEP GOING
;
;********************************
;      C L O S E F I L E        *
;  SUBROUTINE TO CLOSE FILES    *
;********************************
;
CLOSEFILE:
	MVI	C,CLOSE		;CLOSE FUNCTION
	LXI	D,DEST
	CALL	BDOS		;CLOSE DESTINATION FILE
	MVI	C,CLOSE		;CLOSE FUNCTION
	LXI	D,SOURCE
	CALL	BDOS		;CLOSE SOURCE FILE
	RET
;

;
;*****************************
;      ERROR HANDLERS        *
;*****************************
;
ERROR1:	LXI	D,MSSG1
	JMP	ERRMSG
ERROR2:	LXI	D,MSSG2
	JMP	ABORT
ERROR3:	LXI	D,MSSG3
	JMP	ERRMSG
ERROR4:	LXI	D,MSSG4
	JMP	ABORT
ERROR5:	LXI	D,MSSG5
	JMP	ABORT
ERROR6:	LXI	D,MSSG6
	JMP	ERRMSG
ERROR7:	LXI	D,MSSG7
ERRMSG:	CALL	MESSAGE
	JMP	FIN		;RETURN TO CPM
ABORT:	CALL	MESSAGE
	JMP	ABEND		;CLOSE FILES & RETURN TO CPM
;
;*********************************
;        M E S S A G E           *
;  SUBROUTINE TO OUTPUT MESSAGE  *
;*********************************
;
MESSAGE:
	MVI	C,PRINT		;PRINT FUNCTION
	CALL	BDOS
	RET
;
;***************************
;      MESSAGES:           *
;***************************
;
MSSG0	DB	'ALS-8 to CP/M File Converter - ver 1.6',CR,LF
	DB	'by Ed Elizondo',CR,LF,'$'
MSSG1	DB	'Source file not on disk',CR,LF,'$'
MSSG2	DB	'Read past end of file',CR,LF,'$'
MSSG3	DB	'Directory full',CR,LF,'$'
MSSG4	DB	'Disk full',CR,LF,'$'
MSSG5	DB	'Error in extending file',CR,LF,'$'
MSSG6	DB	'No source file indicated',CR,LF,'$'
MSSG7	DB	'No destination file indicated',CR,LF,'$'
MSSG8	DB	'Converting file',CR,LF,'$'
MSSG9	DB	'Done',CR,LF,'$'

;*************************
;	DATA BUFFERS:    *
;*************************
;
TEMP:	DS	1		;TEMPORARY SAVE BYTE
TEMP2:	DS	1		;ANOTHER ONE
DELIM	DS	1		;ASC DELIMITER SAVE BYTE
FLAG:	DB	0		;SWITCH FOR QUOTED STRINGS
EOLCNT:	DB	0		;END OF LINE COUNT
DEST:	DS	33		;DEST FILE FCB
;
OUTPT:	DW	OBUF		;OUTPUT POINTER
INPTR:	DW	IBUF+128	;INPUT POINTER
IBUF:	DS	128		;INPUT BUFFER
OBUF:	DS	128		;OUTPUT BUFFER
;
OLDSTK:	DS	2		;OLD STACK POINTER
	DS	40H		;STACK AREA
NEWSTK:	EQU	$
;

	END
