;MEMR		SEP 3, 1979
	Page 0
VERS	EQU	19	;X.X
;
;
;Diss-assembly of Delta Products memory test program
;Written by D. Rasmussen January 1, 1979
;
;Extensively re-written and new tests added by Larry Alkoff
;
;Additional changes by Bill Bolton
;
;********************************************
;	FIX LIST BY WFB
;********************************************
;15/JULY/81	V19-OPTIONAL CONOUT VIA BDOS/BIOS
;		    AND NEW COMMAND LINE ARGUMENT
;		    TEST, COMMENT TEXT UPDATED
;14/JULY/81	V18-CONOUT VIA BDOS
;14/JULY/81	V17-MESSAGES CORRECTED
;
;********************************************
;	FIX LIST by LBA
;********************************************
;9/3	V16-MISC CLEANUP
;6/11	V15-BUGF ANI 7FH IN HEATH CRTIN
;5/25	V14-MSGS, RANGE LIMITS, FIX S.B. TEST
;5/19	V13-CONDX FOR MONITOR I/O
;5/18	V12-IMPROVE WALKING BIT AND CHECKERBOARD TEST
;5/15	V11-BUGF CONO PRESERVE REGS
;	AND DEFAULT END ADDR (DEFEND) NOW JUST BELOW BIOS
;5/13/79 V0-OBJECT CODE AND SOURCE LISTING
;	GIVEN TO LA BY HEAD OF DELTA PRODUCTS
;	AT SAN FRANCISCO COMPUTER FAIR.
;
;********************************************
;	INFORMATION ABOUT THIS TEST
;********************************************
;
;	This memory test will use default address
;if starting and ending address questions
;are answered with a "CR".
;Memory test can be terminated by a "SP".
;
;Command line arguments are accepted as follows -
;	'-' start of argument string
;	'B' console output via BDOS (for spooling or printing)
;	'R' random number test only
;
;The arguments may be given separately or together,
;i.e. -B, -R, -BR, -RB, or even -B -R
;The default upper test boundary address is modifed
;to the bottom of the BDOS if the B option is given.
;
;	This test is designed to display the most common
;problems first and most uncommon ones last.
;The test never finishes by itself.
;The operator may terminate by pressing the
;space bar at any time.
;Generally memory chip failures will be found within 5 seconds.
;The test takes about 3 minutes to run all
;phases in a 32k board.
;	To completely test for all address open and short
;combinations, the test should be run over a 4K boundry.
;Then run the test over the full range. There are some
;subtle things that get missed if you only run the
;test over the full range and not 4K at a time.
;	The test falls into a random numbers test at the end
;of the first phase and will stay there until
;a space bar is pressed.
;If the memory board passes these tests and will
;run for an hour on the random numbers test
;without a problem, look elsewhere for your troubles.
;
;
;The following tests are performed:
;
;FAST COMPLEMENT:
;This is a test of ALL MEMORY starting at 0
;and testing to memtop (except its own loop).
;Pick up each byte, complement and try to store.
;Quickly test if properly complemented
;and restore original byte.
;
;STUCK BIT:
;1. Fills test area with 0FFH and checks for 0FFH.
;2. Then fills test area with 0's and tests for 0's.
;3. Then re-fills with 0FFH and tests
;   just in case the bit was originally high in (1.).
;
;ADJACENT BIT SHORTED:
;Sets a single bit in all bytes high.
;This checks if a bit is shorted to the
;ones on each side.
;The test repeats 8 times, rotating
;the test bit from LSB to MSB.
;
;CHECKERBOARD:
;Fill memory with 0AAH, 55H pattern and check.
;This forms an alternating "checkerboard".
;Then reverse the pattern and re-check.
;
;WALKING BIT TEST:
;Fill memory with one bit set for each byte.
;The bit rotates at memory increases.
;For example, byte 1 has bit 1 set, byte 2 bit 2 etc.
;Then memory is checked for the proper pattern.
;This is repeated 8 times, rotating the bit each time.
;Then, the whole procedure is repeated rotating
;the opposite way.
;
;ADDRESS SHORTED:
;Fills all memory with 55H then writes an 0AAH
;at 0 (or the lowest memory tested).
;It then tests the rest of memory for 55H's.
;Then it clears location of the 0AAH and
;writes it into location 1.
;Then does same with location 2,4,8,etc setting
;a new address bit high each time and testing all of memory.
;If any address bit is shorted to another,
;the test will find an 0AAH in another location
;than the place it wrote one.
;This test takes the most time and is run last.
;
;RANDOM NUMBERS:
;A random number routine generates an 8 bit number
;pattern and writes it through all test memory.
;It then re-inserts the same seed to the routine
;and test reads the memory. A new seed is generated
;and the exercise is repeated with a new pattern.
;This goes on and on reporting each loop through
;until terminated with the space bar.
;
;
;********************************************
;	SWITCHES
;********************************************
;
TRUE	EQU	0FFFFH
FALSE 	EQU	NOT TRUE
;
NOCHEK	EQU	FALSE		;NO RANGE CHECKING
HEATH	EQU	FALSE
CRAM	EQU	4200H AND HEATH	;CP/M RAM BASE (0=STANDARD)
;
;	PICK ONE I/O ROUTINE
;
CPMIO	EQU	TRUE		;I/O VIA CP/M, WARM BOOT EXIT
LAPIO	EQU	FALSE		;I/O VIA LAPPLE
H84CRT	EQU	FALSE		;HEATH ROUTINE
;
;********************************************
;	EQUATES
;********************************************
;
DEFST	EQU	500H		;DEFAULT STARTING ADDR (INCLUSIVE)
DEFEND	EQU	0F5FFH		;DEFAULT ENDING ADDR (INCLUSIVE)
TPA	EQU	CRAM+100H
STACK	EQU	CRAM+100H	;STACK
RETRYS	EQU	18		;# OF RETRYS
ENDADD	EQU	STACK-2		;ENDING ADDRESS
MEM	EQU	STACK-4		;STARTING ADDRESS
MEMTOPL	EQU	STACK-6		;STORE TOP OF MEMORY
COUNT	EQU	STACK-7		;STORAGE FOR RETRY COUNT
TESTBYTE EQU	STACK-8		;STORAGE
TBUF	EQU	CRAM+82H	;OR STACK-9 IF NOT CP/M TBUFF
SEED	EQU	STACK-11
SEEDST	EQU	STACK-13
TEMP	EQU	STACK-15
WBOOT	EQU	CRAM+0		;WARM BOOT ENTRY
BDOS	EQU	CRAM+5		;BDOS ENTRY
CR	EQU	0DH
LF	EQU	0AH
BD$OFF	EQU	-7		;OFFSET TO BELOW BDOS
BI$OFF	EQU	-4		;OFFSET TO BELOW BIOS
;
;********************************************
;	START OF PROGRAM
;********************************************
;
	ORG	TPA
;
START:	JMP	START2
;
JEXIT:	JMP	MONIT
JCONI:	JMP	CONIN		;JUMPS MAY BE PATCHED
JCONS:	JMP	CONST
JCONO:	JMP	CONOUT
;
;********************************************
;	MAIN LOOP
;********************************************
;
START2:
	LXI	SP,STACK-16
	CALL	INIT
	MVI	A,RETRYS	;SET RETRY COUNT
	STA	COUNT
	LXI	D,SIG	;SIGN ON
	CALL	PMSG	;PRINT IT
	CALL	CRLF
	CALL	CRLF
	LDA	BDOS$FLAG
	ORA	A		;BIOS OUTPUT
	JNZ	BDOS$1		;NO
	LXI	D,BIOSMSG
	CALL	PMSG
	LXI	D,LOCMSG
	CALL	PMSG
	LHLD	WBOOT+1	;GET LOCATION OF BIOS ENTRY
	LXI	D,BI$OFF+1 ;OFFSET TO START OF BIOS
	DAD	D
	MVI	L,0
	JMP	GO$ON$1
;
BDOS$1:
	LXI	D,BDOSMSG
	CALL	PMSG
	LXI	D,LOCMSG
	CALL	PMSG
	LHLD	BDOS+1	;GET LOCATION OF BDOS ENTRY
	LXI	D,BD$OFF+1 ;OFFSET TO START OF BDOS
	DAD	D
	MVI	L,0
GO$ON$1:
	CALL	PHL	;PRINT LOCATION OF BIOS
	LXI	D,MEMSG
	CALL	PMSG
	CALL	MEMTOP	;FIND TOP OF MEMORY
	SHLD	MEMTOPL	;AND SAVE
	CALL	PHL	;AND PRINT IT
	LXI	D,SPMSG
	CALL	PMSG
	LXI	D,XPMSG	;EXPLAIN
	CALL	PMSG
	LDA	BDOS$FLAG
	ORA	A	;BIOS OUTPUT?
	JNZ	BDOS$4	;NO
	LXI	D,BIOSMSG
	JMP	GO$ON$4
;
BDOS$4:
	LXI	D,BDOSMSG
GO$ON$4:
	CALL	PMSG
	CALL	CRLF
	LXI	D,SMSG	;STARTING ADDR MSG
	CALL	PMSG	;PRINT IT
LOWER0:			;GET STARTING ADDRESS
	CALL	GETADD	;INPUT ADDR FROM CONIN
	JNC	LOWER2	;NC MEANS ADDR ENTERED
	LXI	H,LASTB	;CY=CR GIVES DEFAULT
	PUSH	H
	CALL	PHL	;PRINT DEFAULT ADDR
	POP	H
LOWER2:
	IF HEATH OR NOCHEK
	SHLD MEM ! JMP UPPER0	;NO CHECKING
	ENDIF
	XCHG		;ST ADDR TO DE
	LXI	H,LASTB	;TOP OF THIS PROGRAM
	CALL	HILO	;MUST BE BELOW
	XCHG		;STARTING ADDR
	SHLD	MEM	;SAVE STARTING ADDR
	JNC	UPPER0	;LOWER ADDR IS OK, GET UPPER
	LXI	D,LOWMSG
	CALL	PMSG	;SAY TOO LOW
	LXI	H,LASTB
	CALL	PHL	;SAY LOWEST OK ADDR
	JMP	LOWER0
UPPER0:			;GET ENDING ADDR
	LXI	D,EMSG	;ENDING ADDR MSG
	CALL	PMSG
	CALL	GETADD	;GET ENDING ADDR FROM KEYBOARD
	JNC	UPPER2	;NC MEANS ADDR ENTERED
	LDA	BDOS$FLAG
	ORA	A	;BIOS OUTPUT ?
	JNZ	BDOS$2	;NO
	LHLD	WBOOT+1	
	LXI	D,BI$OFF ;ESTABLISH DEFAULT ADDRESS
	JMP	GO$ON$2
;
BDOS$2:
	LHLD	BDOS+1	;CY=CR MEANS DEFAULT
	LXI	D,BD$OFF ;ESTABLISH DEFAULT END ADDR
GO$ON$2:
	DAD	D	;JUST BELOW BIOS OR BDOS
	PUSH	H
	CALL	PHL	;PRINT DEFAULT ADDR
	POP	H
UPPER2:
	XCHG		;END ADDR TO DE
	IF HEATH OR NOCHEK
	JMP	UPPERX	;NO CHECKING
	ENDIF
	LHLD	MEM	;GET START ADDR
	INX	H
	CALL	HILO	;ERROR,END ADDR MUST
	JNC	UPPERX	;BE ABOVE START ADDR
	LXI	D,UPPMSG
	CALL	PMSG
	JMP	UPPER0	;TRY AGAIN
;
UPPERX:
	XCHG		;END ADDR
	SHLD	ENDADD	;SAVE ENDING ADDR
	SHLD	SEED	;USE AS SEED ALSO
	LXI	D,CTUMSG	;CONTINUE?
	CALL	PMSG
WAIT:
	CALL	CSTAT	;WAIT FOR RESPONSE
	ORA	A
	JZ	WAIT
RESTART:
	CALL	CSTAT	;SEE IF ABORT
	CALL	CRLF
	LDA	RAND$FLAG
	ORA	A	;DO RANDOM TEST ONLY ?
	JNZ	RTEST	;YES, GO DO RANDOM NUMBERS
;
;********************************************
;	DO FAST COMPLEMENT TEST - ALL MEMORY
;********************************************
;
	LXI	D,FCTST
	CALL	PMSG	;PRINT FAST COMP TEST
	IF NOT HEATH
	LXI	H,0	;START AT 0
	ENDIF
	IF HEATH
	LXI	H,2000H
	ENDIF
	LXI D,FCTEST-1	;AND STOP AT LOOP
	CALL	FCTEST	;DO TEST
	LHLD	MEMTOPL	;NOW TEST
	XCHG		;TO MEMTOP
	LXI	H,FCLPX	;STARTING HERE
	CALL	FCTEST
;
;********************************************
;	DO BIT STUCK TEST
;********************************************
	LXI	D,BSTST
	CALL	PMSG	;PRINT TEST
	MVI	B,0FFH	;FF TEST START
	CALL	TESTW	;WRITE TEST BYTE
	CALL	TESTR	;CHECK TEST BYTE
	MVI	B,0	;ZEROS TEST
	CALL	TESTW	;WRITE TEST BYTE 0
	CALL	TESTR	;TEST
	MVI	B,0FFH	;BACK HI TEST
	CALL	TESTW	;WRITE TEST BYTE 0FFH
	CALL	TESTR	;TEST
;
;********************************************
;	DO SHORTED BIT TEST
;********************************************
	LXI	D,SBTST
	CALL	PMSG	;PRINT BIT SHORT TEST
	MVI	A,1	;ROTATE BIT TEST
LOOP2:	MOV	B,A	;MAKE TEST BYTE
	CALL	ROTTST	;DO TEST
	JNC	LOOP2	;DONE WITH 8 BITS?
;
;********************************************
;	DO CHECKERBOARD TEST
;********************************************
	LXI	D,CBTST
	CALL	PMSG	;PRINT CHECKBOARD TEST
	MVI	B,55H
	CALL	CBTEST
	MVI	B,0AAH
	CALL	CBTEST
;
;********************************************
;	DO WALKING BIT TEST
;********************************************
	LXI	D,WBLTST
	CALL	PMSG	;PRINT WALKING BIT LEFT
	MVI	B,80H
WALL:	CALL	WALKL	;DO TEST, SAVES B
	MOV	A,B
	RLC		;NEXT SEED BIT
	MOV	B,A
	CPI	80H	;DONE IF
	JNZ	WALL
	LXI	D,WBRTST
	CALL	PMSG	;PRINT WALKING BIT RIGHT
	MVI	B,1
WALR:	CALL	WALKR	;DO TEST, SAVES B
	MOV	A,B
	RRC		;NEXT SEED BIT
	MOV	B,A
	CPI	1	;DONE IF
	JNZ	WALR
;
;********************************************
;	DO ADDRESS LINE TEST
;********************************************
	LXI	D,ALTST
	CALL	PMSG	;PRINT ADDR LINE TEST
	MVI	B,055H	;TEST BYTE
	CALL	ADTEST	;TEST
	MVI	B,0AAH	;TEST BYTE
	CALL	ADTEST	;TEST
;
;********************************************
;	DO RANDOM NUMBER TEST
;********************************************
RTEST:	LXI	D,RNTST
	CALL	PMSG
	MVI	C,'1'
RANDLP:	PUSH	B
	CALL	RNDW	;DO RANDOM # TEST
	CALL	SPACE
	POP	B
	CALL	CONO
	INR	C
	MVI	A,'9'
	CMP	C
	JNZ	RANDLP	;CONTINUE RANDOM NR TEST
;
	LXI	D,MSGOK	;POINT AT TEST COMPLETE MSG
	CALL	PMSG
	JMP	RESTART	;START TEST AGAIN WITH OLD PARAMETERS
;
;********************************************
;	FINISHED WITH MAIN LOOP
;********************************************
;
ERROR:			;PRINT ERROR LOCATIONS
	PUSH	B
	PUSH	D
	PUSH	H
	PUSH	PSW	;SAVE ALL REGS
	CALL	CRLF
	LXI	D,MSG1
	LDA	COUNT
	CPI	RETRYS
	CZ	PMSG	;PRINT LABELS
	CALL	PHL	;PRINT HL REG
	MOV	D,B	;GET SHOULD BE DATA
	CALL	CNVT	;PRINT HEX
	MOV	A,B
	CALL	CNVTB
	POP	PSW
	PUSH	PSW
	MOV	D,A	;GET WAS DATA
	CALL	CNVT	;PRINT HEX
	POP	PSW
	CALL	CNVTB
	LDA	COUNT	;GET ERROR COUNT
	DCR	A	;ONE LESS
	STA	COUNT	;PUT BACK COUNT
	JNZ	MORET
	LXI	D,CTUMSG
	CALL	PMSG
	CALL	GETADD	;SEE IF STOP OR CONTINUE
	MVI	A,RETRYS
	STA	COUNT	;RESET COUNT
MORET:	POP	H	;GET ALL REGS BACK
	POP	D	;AND CONTINUE TEST
	POP	B
	RET
;
PHL:			;PRINT HL REGISTER
	MOV	D,H
	CALL	CNVT	;MAKE ADDR OF ERROR ASCII
	MOV	D,L
	CALL	CNVT
	CALL	TAB
	RET
;
PMSG:		;PRINT STRING POINTED BY DE
	CALL	CSTAT	;POSS ABORT AT EVERY PMSG
PMSGLP:	LDAX	D	;GET BYTE TO PRINT
	ORA	A	;END OF TEXT?
	RZ
	MOV	C,A	;CONVENTION
	CALL	CONO	;GOTO OUTPUT
	INX	D
	JMP	PMSGLP
;
FCTEST:			;COMPLEMENT BYTE AND RESTORE
	MOV A,M ! CMA
	MOV	M,A	;VERY FAST CHANGE
	MOV	B,A	;SAVE COMPLEMENTED BYTE
	MOV	C,M	;SEE WHAT GOT STORED
	MOV A,B ! CMA	;ORIG BYTE
	MOV	M,A	;ALWAYS RESTORED
FCLPX:	MOV A,C ! CMP B	;DID IT COMPLEMENT?
	CNZ	ERROR
	INX H ! CALL HILO
	JNC	FCTEST	;DO MORE
	RET		;DONE
;
LOAD:			;GET ADDRESSES TO TEST
	CALL	CSTAT	;POSS ABORT AT EVERY LOAD
	LHLD	ENDADD	;GET ENDING ADDR
	XCHG		;INTO DE
	LHLD	MEM	;GET STARTING ADDR
	RET
;
TESTW:			;FILL MEMORY WITH TEST BYTE
	CALL	LOAD
WLOOP:	MOV	M,B	;PUT TEST BYTE IN MEMORY
	INX H ! CALL HILO
	JNC	WLOOP
	RET
;
TESTR:		;READ AND COMPARE MEMORY TO TEST BYTE
	LHLD	MEM
TESTADR:
	XCHG
	LHLD	ENDADD	;GET STARTING ADDR
	XCHG
RLOOP:	MOV A,M ! CMP B	;CHECK BYTE
	CNZ	ERROR
	INX H ! CALL HILO
	JNC	RLOOP
	RET
;
CBTEST:			;CHECKERBOARD TEST
	CALL	LOAD
CBWLP:	MOV	M,B	;B HAS TEST BYTE
	INX H ! CALL HILO
	JC	CBR	;TIME TO READ
	MOV A,B ! CMA	;55H BECOMES 0AAH
	MOV	M,A	;STORE COMPLEMENT
	INX H ! CALL HILO
	JNC	CBWLP
CBR:			;READ AND TEST CHECKERBOARD
	CALL	LOAD
CBRLP:	MOV A,M ! CMP B	;CHECK BYTE
	CNZ	ERROR
	INX H ! CALL HILO
	RC		;DONE
	MOV A,B ! CMA ! MOV B,A
	MOV A,M ! CMP B	;CHECK BYTE
	CNZ	ERROR
	MOV A,B ! CMA ! MOV B,A
	INX H ! CALL HILO
	JNC	CBRLP
	RET
;
CSTAT:		;CONSOLE ABORT (SAVES ALL REGS)
	PUSH H ! PUSH D ! PUSH B
	CALL	JCONS	;SEE IF KEY STRUCK
	ORA	A	;SET FLAGS
	JZ	NOKEY
	CALL	JCONI	;GET KEY
	CPI	' '	;EXIT IF SPACE
	JZ	RETURN
	CPI	3	;OR ^C
	JZ	RETURN
	CPI	18H	;^X
	JZ	START	;RE-START TEST
NOKEY:	POP B ! POP D ! POP H
	RET
;
CNVT:			;CONVERT REG D TO HEX ASCII
	MOV	A,D
	RRC		;GET HIGH NIBBLE
	RRC
	RRC
	RRC
	ANI	00FH
	CALL	CNV	;MAKE NIBBLE ASCII
	MVI	A,00FH
	ANA	D	;GET LOW NIBBLE
	CALL	CNV	;MAKE NIBBLE ASCII
	RET
;
CNV:	ADI	030H
	CPI	03AH
	JM	DONE
	ADI	007H
DONE:	MOV	C,A
	CALL	CONO
	RET
;
ROTTST:			;ROTATE TEST
	PUSH	PSW
	CALL	TESTW
	POP	PSW
	PUSH	PSW
	CALL	TESTR
	POP	PSW
	RLC
	RET
;
WALKL:		;LEFT WALKING BIT TEST
	PUSH	B	;SAVE SEED
	CALL	LOAD
WLSTOR:	MOV	A,B	;GET BYTE
	RLC		;ROTATE LEFT
	MOV	B,A	;AND RESAVE IN B
	MOV	M,A	;TO MEMORY
	INX H ! CALL HILO
	JNC	WLSTOR
	CALL	LOAD
	POP B ! PUSH B	;GET SEED BIT
WLTST:	MOV	A,B	;NOW CHECK
	RLC
	MOV	B,A
	MOV A,M ! CMP B	;CHECK BYTE
	CNZ	ERROR
	INX H ! CALL HILO
	JNC	WLTST
	POP	B	;ORIG SEED
	RET		;DONE
;
WALKR:		;RIGHT WALKING BIT TEST
	PUSH	B	;SAVE SEED
	CALL	LOAD
WRSTOR:	MOV	A,B	;GET BYTE
	RRC		;ROTATE RIGHT
	MOV	B,A	;AND RESAVE IN B
	MOV	M,A	;TO MEMORY
	INX H ! CALL HILO
	JNC	WRSTOR
	CALL	LOAD
	POP B ! PUSH B	;GET SEED BIT
WRTST:	MOV	A,B	;NOW CHECK
	RRC
	MOV	B,A
	MOV	A,M	;CHECK BYTE
	CMP	B
	CNZ	ERROR
	INX H ! CALL HILO
	JNC	WRTST
	POP	B	;ORIG SEED
	RET		;DONE
;
ADTEST:			;ADDRESS SHORTED TEST
	CALL	TESTW	;FILL MEMORY WITH TEST BYTE
	MOV	A,B
	STA	TESTBYTE	;SAVE TEST BYTE
	CALL	LOAD
	CMA
	MOV	M,A
	INX	H
	CALL	TESTADR
	LXI	B,1	;START ADDR LSB ON
LOOP4:	LHLD	MEM
	DAD	B
	RC		;ROLLED OVER 65K
	MOV	A,D	;GET TEST ADDR
	SUB	H	;PAST END?
	RC		;KEEP GOING IF NO CARRY
	JNZ	INXHA
	MOV	A,E
	SUB	L
	RC
INXHA:	LDA	TESTBYTE
	PUSH	B
	MOV	B,A
	CMA		;INVERT BITS
	MOV	M,A	;WRITE TO TEST MEMORY
	INX H ! CALL HILO
	JC	OVERFL
	CALL	TESTADR	;TEST
	POP	H
	DAD	H
	RC
	MOV	B,H
	MOV	C,L
	JMP	LOOP4
;
OVERFL:	POP	B
	RET
;
GETBYT:	CALL	CHAR
	RZ
	CPI	' '	;EXIT IF SPACE
	JZ	RETURN
	CPI	3	;^C
	JZ	RETURN
	CPI	18H	;^X
	JZ	START
	CALL	ATOH
	JP	REENTER
	RRC
	RRC
	RRC
	RRC
	MOV	E,A
	PUSH	D
	CALL	CHAR
	POP	D
	JZ	REENTER
	CALL	ATOH
	JP	REENTER
	ORA	E
	RET
;
CHAR:	CALL	JCONI
	CPI	CR
	STC		;SET CY FLAG (MAYBE CR)
	RZ
	PUSH	PSW
	MOV	C,A
	CALL	CONO
	POP	PSW
	RET
;
ATOH:	SUI	030H
	JM	BAD
	CPI	00AH
	RM
	SUI	007H
	CPI	00AH
	JM	BAD
	CPI	010H
	RM
BAD:	XRA	A	;SET ZERO FLAG
	RET
;
REENTER:
	POP	H	;FIX STACK
	LXI	D,IEMSG
	CALL	PMSG
GETADD:			;INPUT 4 HEX VALUES FROM CONSOLE
	CALL	GETBYT
	RC
	MOV	H,A
	SHLD	TEMP
	CALL	GETBYT
	LHLD	TEMP
	MOV	L,A
	RET
;
CNVTB:			;PRINT REG A IN BINAR
	MOV	E,A	;SAVE A
	MVI	D,2	;TWO SPACES
	CALL	TLOP
	MVI	B,2	;NIBBLE COUNT
PNIBB:	MVI	D,4
ALLBIT:	MOV	A,E	;RESTORE A
	RAL
	MOV	E,A
	MVI	C,030H	;0
	JNC	ZERO
	MVI	C,031H	;1
ZERO:	CALL	CONO
	DCR	D
	JNZ	ALLBIT
	CALL	SPACE	;PRINT SPACE
	DCR	B
	JNZ	PNIBB
TAB:	MVI	D,004H
TLOP:	CALL	SPACE
	DCR	D
	JNZ	TLOP
	RET
;
CRLF:	MVI C,CR ! CALL CONO
	MVI C,LF ! JMP CONO
;
SPACE:	MVI	C,020H
CONO:	PUSH B ! PUSH D ! PUSH H
	LDA	BDOS$FLAG
	ORA	A	;BIOS OUTPUT ?
	JNZ	BDOS$3	;NO
	CALL	JCONO	;YES
	JMP	GO$ON$3
;
BDOS$3:	
	MOV	E,C
	MVI	C,2
	CALL	BDOS
GO$ON$3:
	POP H ! POP D ! POP B
	RET
;
;RANGE TESTING ROUTINE - CY SET IF RANGE EXCEEDED
;  IF	HL=DE	THEN NC AND Z SET
;  IF	HL<=DE	THEN NC
;  IF	HL>DE	THEN CY AND NZ
;  IF	HL=0	THEN CY AND Z SET
HILOX:	INX	H	;INCREMENT PNTR, CHECK RANGE
HILO:
	MOV A,H ! ORA L
	STC ! RZ	;TEST HL=0
	MOV A,E ! SUB L	;DE-HL
	MOV A,D ! SBB H
	RET
;
RNDW:			;WRITE RANDOM NUMBERS
	LHLD	SEED	;GET SEED
	SHLD	SEEDST	;SAVE IT FOR LATER
	CALL	LOAD
RNDWL:	CALL	RND
	MOV	M,B
	INX H ! CALL HILO
	JNC	RNDWL
;
RNDR:			;CHECK AND READ RANDOM NUMBERS
	LHLD	SEEDST	;START WITH SAME SEED
	SHLD	SEED	;PASS SEED TO GENERATOR
	CALL	LOAD	;GET TEST ADDR
RNDRL:	CALL	RND
	MOV	A,M
	CMP	B
	CNZ	ERROR
	INX H ! CALL HILO
	JNC	RNDRL
	RET		;TEST DONE
;
RND:			;GENERATE RANDOM NR FROM SEED
	PUSH	H
	LHLD	SEED
	MOV	A,L
	XRA	H
	MOV	B,A
	RLC
	MOV	L,A
	ADD	H
	MOV	H,A
	SHLD	SEED
	POP	H
	RET
;
RETURN:
	LXI	SP,STACK-16	;FIX STACK
	JMP	JEXIT
;
MEMTOP:			;FIND TOP OF MEMORY
	IF NOT HEATH
	LXI	H,100H-1
	ENDIF
	IF HEATH
	LXI	H,2000H-1
	ENDIF
MEMLOOP:
	INR	H
	JZ	FOUND	;ABOVE 64K BOUNDRY
	MOV	B,M	;GET MEMORY BYTE
	MOV	A,M	;AND IN A
	CMA
	MOV	M,A	;STORE COMP
	MOV	C,M	;GET BACK COMP BYTE
	CMP	C	;DID IT STORE OK?
	MOV	M,B	;PUT BACK ORIG
	JZ	MEMLOOP
FOUND:	DCR	H	;FOUND IT
	RET		;HL=MEMTOP
;
;********************************************
;	MESSAGE AREA
;********************************************
SIG:	DB	CR,LF
	DB	'MEMRS Memory Test - Version '
	DB	VERS/10+30H, '.', VERS MOD 10+30H
	DB	0
BIOSMSG:DB	'BIOS',0
BDOSMSG:DB	'BDOS',0
LOCMSG:	DB	' located at ',0
MEMSG:	DB	' Top of memory at ',0
SPMSG:	DB	CR,LF
	DB	'Press "SP" or "^C" to warm boot at any time'
	DB	CR,LF
	DB	'or "^X" to restart test from beginning. ',0
XPMSG:	DB	CR,LF
	DB	'Response of "CR" gives default test range'
	DB	CR,LF
	DB	'which starts above this program and ends at ',0
MSG1:	DB	'LOCATION  SHOULD BE           WAS'
	DB	CR,LF,0
CTUMSG:	DB	CR,LF
	DB	'"CR" to continue test - "SP", "^C" to quit,'
	DB	' "^X" to restart.',0
MSGOK:	DB	CR,LF
	DB	'Test series complete', 0
SMSG:	DB	CR,LF
	DB	'Starting address (Hex or "CR") ',0
EMSG:	DB	CR,LF
	DB	'Ending address   (Hex or "CR") ',0
IEMSG:	DB	CR,LF
	DB	'Input error - Retype 4 hex digits ',0
FCTST:	DB	CR,LF
	DB	'Non-destructive test of ALL MEMORY starting at '
	IF NOT HEATH
	DB	'0 ',0
	ENDIF
	IF HEATH
	DB	'2000H ',0
	ENDIF
BSTST:	DB	CR,LF
	DB	'Bit stuck high or low test ',0
SBTST:	DB	CR,LF
	DB	'Adjacent bits shorted test ',0
CBTST:	DB	CR,LF
	DB	'Checkerboard (55AAH pattern) test ',0
WBLTST:	DB	CR,LF
	DB	'Walking bit left test ',0
WBRTST:	DB	CR,LF
	DB	'Walking bit right test ',0
ALTST:	DB	CR,LF
	DB	'Address line test ',0
RNTST:	DB	CR,LF
	DB	'Random number test - Cycle: ',0
LOWMSG:	DB	CR,LF
	DB	'Re-enter, starting address must be at least ',0
UPPMSG:	DB	CR,LF
	DB	'Re-enter, ending address too low',0
;
;
;********************************************
;	INSERT CUSTOM INITIALIZATION AND I/O ROUTINES HERE
;********************************************
;
	IF CPMIO	;THESE ROUTINES CP/M USERS
MONIT	EQU	WBOOT
CONST	EQU	6	;CONSOLE STATUS TO REG A
CONIN	EQU	9	;CONSOLE CHAR TO REG A
CONOUT	EQU	0CH	;CHAR FROM REG C TO CONSOLE
;
INIT:			;SET HI ORDER ADDR BYTES
	LDA	WBOOT+2
	STA	JCONS+2
	STA	JCONI+2
	STA	JCONO+2
	JMP	INIT1
	ENDIF
;
	IF LAPIO	;USES LAPPLE MONITOR
MONIT	EQU	0D000H
CONST	EQU	0D012H
CONIN	EQU	0D003H
CONOUT	EQU	0D009H
INIT:	JMP	INIT1	;NO INIT NEEDED
	ENDIF
;
	IF H84CRT
MONIT	EQU	WBOOT
INIT:	JMP	INIT1
CONST	EQU	$
CRTST:	IN H84ST ! ANI 1
	MVI A,0 ! RZ ! CMA ! RET
CONIN	EQU	$
CRTIN:	IN H84ST ! RAR ! JNC CRTIN
	IN H84IO ! ANI 7FH ! RET
CONOUT	EQU	$
CRTOUT:	IN H84ST ! ANI 20H ! JZ CRTOUT
	MOV A,C ! OUT H84IO ! RET
H84ST	EQU	0EDH
H84IO	EQU	0E8H
	ENDIF
;
INIT1:
	LXI	H,TBUF	;POINT TO COMMAND LINE
	MOV	A,M	;GET FIRST BYTE
	CPI	'-'	;OPTION CHARACTER ?
	JNZ	DEFAULT ;NO
CLOOP:
	INX	H	;POINT TO NEXT BYTE
	MOV	A,M
	CPI	00	;END OF COMMAND LINE ?
	RZ		;YES
	CPI	'B'	;BDOS OUTPUT ?
	CZ	SET$BDOS ;YES
	CPI	'R'	;RANDOM TEST ONLY ?
	CZ	SET$RAND ;YES
	JMP	CLOOP	;NO
;
DEFAULT:
	XRA	A
	STA	BDOS$FLAG	;BIOS OUTPUT
	STA	RAND$FLAG	;FULL TEST
	RET
;
SET$BDOS:
	MVI	A,TRUE		;BDOS OUTPUT
	STA	BDOS$FLAG
	RET
;
SET$RAND:
	MVI	A,TRUE		;RANDOM NUMBER TEST ONLY
	STA	RAND$FLAG
	RET
;	
;********************************************
;
BDOS$FLAG	DB	0	;BDOS OUTPUT FLAG
RAND$FLAG	DB	0	;RANDOM TEST FLAG
;
LASTB	EQU	$	;END OF PROGRAM
;
	END	START
