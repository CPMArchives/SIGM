;
;	Minimal Forth-like  interpreter as presented
;	in Kilobaud Magazine, February, 1981
;	issue, page 76	by Richard Fritzson
;
;	Note: this is part 1 of a promised 3-part
;	system, to include a compiler, and, hopefully,
;	an editor.
;
;
;			       02/04/81:
;		typed in by Ron Fowler, Westland, Mich
;		(modified slightly: the original version
;		had I/O routines to BIOS hard-coded, and
;		memory fixed at time of assembly.   Mod-
;		ified for any size CPM, and dynamic  fix
;		of memory size at run time)
;
;
;	if you're not using MAC to assemble this program,
;	delete the next statement:

	TITLE	'Threaded Code Interpreter for 8080'
;
; Richard Fritzson
; 29 January 1980      Version 1.0
;
; This version contains only the basic internal
; interpreter and a simple interactive console
; interpreter.
;
	ORG	100H	;START UP ADDRESS
;
BASE:	LXI	SP,STACK ;INITIALIZE PARAMETER STACK
	CALL	DICMOVE ;MOVE DICTIONARY TO HIGH MEMORY
	LXI	H,TOP-1 ;SET PC TO TOP LEVEL LOOP
	SHLD	PC
	JMP	NEXT	;AND START INTERPRETER
;
; TOP - Top Level System Loop
; DESCRIPTION: TOP in an infinite
; loop which picks up the contents of the
; EXEC variable and executes it.
;
TOP:	DW	EXEC,PEEKW	;GET TOP LEVEL PROGRAM
	DW	EXECUTE 	;RUN IT
	DW	JUMP,TOP-1	;AND LOOP
;
; EXEC - address of top level routine
;
EXEC:	DW	VARIABLE	;THREADED CODE VARIABLE
	DW	INTERACT	;ADDRESS OF USER INTERPRETER
;
; Reserved Stack Space
;
	DS	128		;PARAMETER STACK
STACK	EQU	$
	PAGE
;
; The interpreter's architecture: a program counter and a stack
;
PC	DW	0	;A 16 BIT POINTER INTO THE MIDDLE OF
			;THE CURRENT INSTRUCTION (NOT THE
			;FIRST BYTE, BUT THE SECOND)
;
RSTACK	DW	$+2	;THE STACK POINTER POINTS TO THE NEXT
			;AVAILABLE STACK POSITION (NOT THE
			;TOPMOST OCCUPIED POSITION)
;
	DS	80H	;RESERVED STACK SPACE
;
; RPUSH - push DE on stack
; ENTRY: DE - number to be pushed on stack
; EXIT:  DE - is unchanged
; DESCRIPTION: this code is illustrative of how the
; stack works.	However it is not used in the system and
; can be left out.
;
RPUSH:	LHLD	RSTACK	;GET STACK POINTER
	MOV	M,E	;STORE LOW BYTE
	INX	H	;BUMP POINTER TO NEXT BYTE
	MOV	M,D	;STORE HIGH BYTE
	INX	H	;BUMP POINTER TO NEXT EMPTY SLOT
	SHLD	RSTACK	;RESTORE POINTER
	RET
;
; RPOP - pop DE from stack
; ENTRY: No Register Values Expected
; EXIT:  DE - top element of RSTACK
; DESCRIPTION: this code is illustrative of how the
; stack works.	However it is not used in the system and
; can be left out.
;
RPOP:	LHLD	RSTACK	;GET STACK POINTER
	DCX	H	;DROP TO FIRST STACK POSITION
	MOV	D,M	;GET HIGH BYTE
	DCX	H
	MOV	E,M	;GET LOW BYTE
	SHLD	RSTACK	;RESTORE STACK POINTER
	RET
;
; NEXT - main internal interpreter loop
; ENTRY: PC - points into the instruction just completed
; EXIT:  PC - incremented by 2, points to next
;	      instruction
;	 DE - points to middle of first word of
;	      next routine (i.e. (PC)+1)
; DESCRIPTION: increments the PC; picks up the code
; word of the next routine and jumps to it.
;
NEXT:	LHLD	PC	;INCREMENT PROGRAM COUNTER
	INX	H	;  WHILE LOADING DE WITH
	MOV	E,M	;  NEXT INSTRUCTION
	INX	H
	MOV	D,M
	SHLD	PC
	XCHG		;PICK UP WORD ADDRESSED
	MOV	E,M	;BY NEXT INSTRUCTION (WHICH
	INX	H	;  IS CODE, TCALL OR SOME OTHER
	MOV	D,M	;  EXECUTABLE ADDRESS)
	XCHG		;  AND
	PCHL		;  JUMP TO IT
;
; TCALL - the threaded call routine
; ENTRY: DE - middle of first word of routine being called
; EXIT:  No Register Values Returned
; DESCRIPTION: pushes the current congtents of the PC
; onto the return stack; makes DE the new PC
;
TCALL:	LHLD	PC	;GET OLD PROGRAM COUNTER
	XCHG		;REPLACE WITH DE
	SHLD	PC
	LHLD	RSTACK	;PUSH OLD PC ON RSTACK
	MOV	M,E
	INX	H
	MOV	M,D
	INX	H
	SHLD	RSTACK
	JMP	NEXT	;BACK TO INTERPRETER
;
; TRET - the threaded code return
; DESCRIPTION: pops the top element of the
;	       return stack and puts it into the PC.
;
TRET:	DW	$+2	;CODE
	LHLD	RSTACK	;GET STACK POINTER
	DCX	H	;HIGH BYTE OF TOP ELEMENT
	MOV	D,M
	DCX	H	;LOW BYTE OF TOP ELEMENT
	MOV	E,M
	SHLD	RSTACK	;RESTORE STACK POINTER
	XCHG		;STORE TOP OF STACK IN PC
	SHLD	PC
	JMP	NEXT	;BACK TO INTERPRETER
;
; Simple arithmetic routines
;
; INC - increment the top of the stack
;
INC:	DW	$+2	;CODE
	POP	H	;GET TOP
	INX	H	;INCREMENT
	PUSH	H	;RESTORE
	JMP	NEXT
;
; DEC - decrement the top of the stack
;
DEC:	DW	$+2	;CODE
	POP	H	;GET TOP
	DCX	H	;DECREMENT
	PUSH	H	;RESTORE
	JMP	NEXT
;
; TADD - add the top two elements of the stack
;
TADD:	DW	$+2	;CODE
	POP	H	;FIRST ELEMENT
	POP	D	;SECOND ELEMENT
	DAD	D	;ADD 'EM
	PUSH	H	;PUSH RESULT
	JMP	NEXT
;
; MINUS - negate top of stack
;
MINUS:	DW	$+2	;CODE
	POP	H	;GET TOP
	CALL	MINUSH	;NEGATE IT
	PUSH	H	;PUSH IT
	JMP	NEXT
;
MINUSH: DCX	H	;GOOD OLE 2S COMPLEMENT
	MOV	A,H
	CMA
	MOV	H,A
	MOV	A,L
	CMA
	MOV	L,A
	RET
;
; TSUB - subtract TOP from TOP-1
;
TSUB:	DW	TCALL	;THREADED CODE
	DW	MINUS	;NEGATE TOP
	DW	TADD	;AND ADD
	DW	TRET
;
; PEEKB - retrieve a byte from memory
; ENTRY: TOP - address
; EXIT:  TOP - byte at address
;
PEEKB:	DW	$+2	;CODE
	POP	H	;GET ADDRESS
	MOV	E,M	;GET BYTE
	MVI	D,0
	PUSH	D	;SAVE
	JMP	NEXT
;
; PEEKW - retrieve a word from memory
; ENTRY: TOP - address
; EXIT:  TOP - word at address
;
PEEKW:	DW	$+2	;CODE
	POP	H	;GET ADDRESS
	MOV	E,M	;GET WORD
	INX	H
	MOV	D,M
	PUSH	D	;SAVE
	JMP	NEXT
;
; POKEB - store byte in memory
; ENTRY: TOP - address
;	 TOP-1 - byte to store
; EXIT:  No Values Returned
;
POKEB:	DW	$+2	;CODE
	POP	H	;GET ADDRESS
	POP	D	;GET BYTE
	MOV	M,E	;STORE
	JMP	NEXT
;
; POKEW - store word in memory
; ENTRY: TOP - address
;	 TOP-1 - word to store
; EXIT: No Values returned
;
POKEW:	DW	$+2	;CODE
	POP	H	;GET ADDRESS
	POP	D	;GET WORD
	MOV	M,E	;STORE WORD
	INX	H
	MOV	M,D
	JMP	NEXT
;
; Some standart threaded code functions
; TPUSH - push the next word onto the stack
;
TPUSH:	DW	$+2	;CODE
	LHLD	PC	;GET PROGRAM COUNTER
	INX	H	;ADVANCE TO NEXT WORD
	MOV	E,M	;AND PICK UP CONTENTS
	INX	H
	MOV	D,M
	SHLD	PC	;STORE NEW PROGRAM COUNTER
	PUSH	D	;PUSH WORD ONTO PARAM STACK
	JMP	NEXT	;CONTINUE
;
; TPOP - drop the top of the parameter stack
;
TPOP:	DW	$+2	;CODE
	POP	H	;POP ONE ELEMENT
	JMP	NEXT	;  AND CONTINUE
;
; SWAP - exchange top two elements of the stack
;
SWAP:	DW	$+2	;CODE
	POP	H	;GET ONE ELEMENT
	XTHL		;XCHG
	PUSH	H	;PUT BACK
	JMP	NEXT	;AND CONTINUE
;
; DUP - duplicate the top of the stack
; DESCRIPTION: often used before functions which
; consume the top of the stack (e.g. conditional jumps)
;
DUP:	DW	$+2	;CODE
	POP	H	;GET TOP
	PUSH	H	;SAVE IT TWICE
	PUSH	H
	JMP	NEXT
;
; CLEAR - clear the stack
;
CLEAR:	DW	$+2	;CODE
	LXI	SP,STACK ;RESET STACK POINTER;
	JMP	NEXT
;
; Threaded Code Jumps
;
; All Jumps are to absolute locations
; All Conditional jumps consume the
; elements of the stack that they test
;
; JUMP - unconditional jump
;
JUMP:	DW	$+2	;CODE
JUMP1:	LHLD	PC	;GET PROGRAM COUNTER
	INX	H	;GET NEXT WORD
	MOV	E,M
	INX	H
	MOV	D,M
	XCHG		;MAKE IT THE PC
	SHLD	PC
	JMP	NEXT
;
; IFZ - jump if top is zero
;
IFZ:	DW	$+2	;CODE
	POP	H	;GET TOP
	MOV	A,H	;TEST FOR ZERO
	ORA	L
	JZ	JUMP1	;IF YES, JUMP
SKIP:	LHLD	PC	;ELSE SIMPLY SKIP NEXT WORD
	INX	H
	INX	H
	SHLD	PC
	JMP	NEXT
;
; IFNZ - jump if top not zero
;
IFNZ:	DW	$+2	;CODE
	POP	H	;GET TOP
	MOV	A,H	;TEST FOR ZERO
	ORA	L
	JNZ	JUMP1	;IF NOT, JUMP
	JMP	SKIP	;ELSE DON'T
;
; IFEQ - jump if TOP = TOP-1
;
IFEQ:	DW	$+2	;CODE
	POP	H	;GET TOP
	CALL	MINUSH	;NEGATE IT
	POP	D	;GET TOP-1
	DAD	D	;ADD 'EM
	MOV	A,H	;TEST FOR ZERO
	ORA	L
	JZ	JUMP1	;IF EQUAL, JUMP
	JMP	SKIP	;IF NOT, DON'T
;
; Implementation of Constants and Variables in a
; threaded code system
;
 ;CONSTANT - code address for constants
; ENTRY: DE - points to middle of code word for
;	      constant
; DESCRIPTION: picks up the contents of the word
; following the code word and pushes it onto the stack.
;
CONSTANT:
	XCHG		;HL <- ADDRESS OF CODE WORD
	INX	H	;GET CONSTANT
	MOV	E,M
	INX	H
	MOV	D,M
	PUSH	D	;PUSH IT ON THE PARAMETER STACK
	JMP	NEXT	;RETURN TO INTERPRETER
;
; Some common constants
;
ZERO:	DW	CONSTANT	;THREADED CODE CONSTANT
	DW	0
;
ONE:	DW	CONSTANT	;THREADED CODE CONSTANT
	DW	1
;
NEGONE: DW	CONSTANT	;THREADED CODE CONSTANT
	DW	-1
;
MEMORY: DW	CONSTANT	;LAST AVAILABLE BYTE
	DW	8*1024-1	;8K SYSTEM
;
; VARIABLE - code address for variables
; ENTRY: DE - points to middle of code word for
;	      variable
; DESCRIPTION: pushes address of word following code
;	       word onto the stack
;
VARIABLE:
	INX	D	;INCREMENT TO VARIABLE ADDRESS
	PUSH	D	;STORE ON PARAMETER STACK
	JMP	NEXT	;RETURN TO INTERPRETER
;
; Top Level External Interpreter Version 1.0
;
; This routine reads one line of reverse
; polish notation from the console and executes it.
;
INTERACT:
	DW	TCALL		;THREADED CODE
;
	DW	PROMPT		;PROMPT THE USER AND
	DW	READLINE	;READ A CONSOLE LINE
;
SLOOP:	DW	SCAN		;SCAN FOR NEXT WORD
	DW	IFZ,EXIT-1	;IF END OF LINE, QUIT
	DW	LOOKUP		;ELSE LOOKUP WORD IN DICTIONARY
	DW	IFZ,NUMBER-1	;IF NOT FOUND, TRY NUMBER
	DW	EXECUTE 	;ELSE EXECUTE IT
	DW	JUMP,SLOOP-1	;AND CONTINUE SCANNING
;
NUMBER: DW	CONAXB		;TRY CONVERTING TO NUMBER
	DW	IFNZ,SLOOP-1	;IF SUCCESSFUL, LEAVE ON STACK
				;AND CONTINUE SCANNING
	DW	TPUSH,ERRMSG	;ELSE PUSH ERROR MESSAGE
	DW	PRINTS		;AND PRINT IT
	DW	PRINTS		;THEN PRINT STRING
	DW	TRET		;AND RETURN
;
EXIT:	DW	DUP,CONBXA	;COPY AND CONVERT TOP OF STACK
	DW	PRINTS		;PRINT IT
	DW	TRET		;RETURN
;
ERRMSG: DB	13,'Not Defined: '
;
; LOOKUP - the dictionary lookup routine
; ENTRY: TOP  -  pointer to string to be looked up
; EXIT:  TOP  -  -1 if string found in dictionary
;		  0 if string not found
;	 TOP-1 - pointer to code of found subroutine
;			or
;		 string pointer if not found
; DESCRIPTION: performs a linear search of the
; dictionary. Returns the code address if the string
; is found, or else the string pointer if not found
;
LOOKUP: DW	TCALL		;THREADED CODE
	DW	NAMES,PEEKW	;GET TOP OF DICTIONARY
;
SEARCH: DW	DUP,PEEKB	;GET CHAR COUNT OF NEXT ENTRY
	DW	IFZ,FAIL-1	;IF END OF DICTIONARY
;
	DW	MATCH		;ELSE ATTEMPT A MATCH
	DW	IFNZ,SUCCEED-1	;IF SUCCESSFUL MATCH
;
	DW	FIRST,TADD	;ELSE SKIP STRING
	DW	TPUSH,2,TADD	;AND POINTER
	DW	JUMP,SEARCH-1	;AND TRY NEXT ENTRY
;
FAIL:	DW	TPOP		;DROP DICTIONARY POINTER
	DW	ZERO		;LEAVE A ZERO ON THE STACK
	DW	TRET		;AND QUIT
;
SUCCEED:
	DW	SWAP,TPOP	;DROP STRING POINTER
	DW	FIRST,TADD,PEEKW ;GET CODE POINTER
	DW	NEGONE		;PUSH A MINUS ONE
	DW	TRET		;AND RETURN
;
; Names - address of dictionary names
;
NAMES:	DW	VARIABLE	;THREADED CODE VARIABLE
	DW	NAMEBEG 	;BEGINNING OF NAMES
;
; MATCH - match strings
; ENTRY: TOP   - ptr to string
;	 TOP-1 - ptr to another string
; EXIT:  TOP   - -1 if strings are the same
;		  0 if strings do not match
;	 TOP-1 - ptr to first string
;	 TOP-2 - ptr to second string
; DESCRIPTION: written in assembly to speed things up
;
MATCH:	DW	$+2		;CODE
	POP	H		;FIRST STRING
	POP	D		;SECOND STRING
	PUSH	D		;LEAVE ON STACK
	PUSH	H
	LDAX	D		;GET 2ND COUNT
	CMP	M		;COMPARE WITH FIRST
	JNZ	MATCHF		;IF NO MATCH
				;ELSE TRY STRING MATCHING
	MOV	B,A
MATCH1: INX	H		;NEXT BYTE
	INX	D
	LDAX	D
	CMP	M
	JNZ	MATCHF		;IF NO MATCH
	DCR	B		;ELSE DEC COUNT
	JNZ	MATCH1		;IF MORE TO COMPARE
	LXI	H,-1		;ELSE PUSH SUCCESS
	PUSH	H
	JMP	NEXT
;
MATCHF: LXI	H,0		;FAILURE
	PUSH	H
	JMP	NEXT
;
; EXECUTE - execute routine at top of stack
; ENTRY: TOP  - address of routine to be executed
; EXIT:  DE   - middle of word addressed by top
; DESCRIPTION: The address is of a threaded code
; interpreter routine, so the contents of the
; first word is an executable address. EXECUTE
; gets that address and jumps to it, leaving DE
; in the same state that the main interpreter
; loop (NEXT) would have.
;
EXECUTE:
	DW	$+2		;CODE
	POP	H		;GET ADDRESS
	MOV	E,M		;GET FIRST WORD
	INX	H
	MOV	D,M
	XCHG			;AND JUMP TO IT
	PCHL
;
; READLINE - fill console buffer
; DESCRIPTION: reads characters from the console, echoing them
; to the screen and storing them in the console buffer,
; beginning in the third character of the buffer.
; Stops on encountering a carriage return and stores a
; final zero after the other characters.
; Takes appropriate action for a backspace character.
;
READLINE:
	DW	TCALL		;THREADED CALL
	DW	ZERO		;MARK BUFFER AS UNSCANNED
	DW	CONBUF,POKEB
;
	DW	CONBUF,INC,INC	;PUSH FIRST BYTE OF BUFFER
;
RLOOP:	DW	DUP		;DUPLICATE BUFFER POINTER
	DW	CIN		;GET CHARACTER
	DW	DUP,COUT	;ECHO TO SCREEN
;
	DW	DUP,TPUSH,08H	;COMPARE WITH BACKSPACE
	DW	IFEQ,BKSP-1
;
	DW	DUP,TPUSH,0DH	;COMPARE WITH CARRIAGE RETURN
	DW	IFEQ,EOL-1
;
	DW	SWAP,POKEB	;IF NEITHER, STORE IN BUFFER
	DW	INC		;INCREMENT BUFFER POINTER
	DW	JUMP,RLOOP-1	;AND KEEP READING
;
BKSP:	DW	TPOP,TPOP	;DROP BS AND BUFFER PTR COPY
	DW	DEC		;BACKUP POINTER
	DW	TPUSH,20H,COUT	;PRINT A SPACE
	DW	TPUSH,08H,COUT	;AND ANOTHER BACKSPACE
	DW	JUMP,RLOOP-1
;
EOL:	DW	TPOP,TPOP	;DROP CR AND BUFFER PTR COPY
	DW	ZERO,SWAP,POKEB ;STORE FINAL ZERO
	DW	TPUSH,0AH,COUT	;PRINT A LINE FEED
	DW	TRET		;AND RETURN
;
; Console Buffer
; DESCRIPTION: First byte contains the scan pointer which
; points to the next byte to be scanned. The remaining bytes
; contain characters read from the console.
;
CONBUF: DW	VARIABLE	;THREADED CODE VARIABLE
	DS	101D		;LONG ENOUGH FOR MOST SCREENS
;
; PROMPT - prompt the user
; DESCRIPTION: clears to a new line and prints a hyphen
;
PROMPT: DW	TCALL		;THREADED CODE
	DW	TPUSH,PRMSG	;PUSH PROMPT MESSAGE
	DW	PRINTS		;AND PRINT IT
	DW	TRET
;
PRMSG:	DB	3,0DH,0AH,'-'
;
; PRINTS - prints string
; ENTRY: TOP  - points to string
; DESCRIPTION: Uses first byte of string as a character count
;
PRINTS: DW	TCALL		;THREADED CODE
	DW	FIRST		;GET COUNT
PRINTS1:
	DW	DUP,IFZ,PRINTX-1 ;IF DONE RETURN
	DW	SWAP,FIRST	;ELSE GET NEXT CHARACTER
	DW	COUT		;PRINT IT
	DW	SWAP,DEC	;DECREMENT COUNT
	DW	JUMP,PRINTS1-1	;AND KEEP LOOPING
;
PRINTX: DW	TPOP,TPOP	;DROP COUNT AND POOINTER
	DW	TRET		;THEN RETURN
;
; FIRST - get next byte of string on stack
; ENTRY: TOP   - ptr to string
; EXIT:  TOP   - first character of string
;	 TOP-1 - ptr to rest of string
; DESCRIPTION: useful for advancing through strings a byte
; at a time.
;
FIRST:	DW	$+2		;CODE
	POP	H		;GET POINTER
	MOV	C,M		;BC <- CHARACTER
	MVI	B,0
	INX	H		;BUMP POINTER
	PUSH	H		;RESTORE POINTER
	PUSH	B		;ADD CHARACTER
	JMP	NEXT		;CONTINUE
;
; COUT - character output routine
; ENTRY: TOP - character to print
; DESCRIPTION: uses operating system to print character
; <<<=== NOTE: MODIFIED FOR VAR. SIZE CPM SYS (RGF) ===>>>
;
COUT:	DW	$+2		;CODE
	POP	B		;C <- CHARACTER
VCOUT:	CALL	7E0CH		;PRINT IT (<<MODIFIED AT INIT>>)
	JMP	NEXT		;RETURN
;
; CIN - character input routine
; EXIT: TOP  - character read from console
; DESCRIPTION: Uses operating system
; <<<=== NOTE: MODIFIED FOR VAR. SIZE CPM SYS (RGF) ===>>>
;
CIN:	DW	$+2		;CODE
VCIN:	CALL	7E09H		;READ CHARACTER ((<<MODIFIED AT INIT>>)
	MOV	L,A		;HL <- CHARACTER
	MVI	H,0
	PUSH	H		;PUSH ON STACK
	JMP	NEXT		;RETURN
;
; SCAN - Scan for next word
; ENTRY: No Values Expected
; EXIT: TOP    -  -1 if word found, 0 if word not found
;	TOP-1  -  ptr to word if found (else nothing)
; DESCRIPTION: first byte of buffer contains a counter of
; characters already scanned. The next word is moved to the
; beginning of the line with a leading byte count.
;
SCAN:	DW	$+2		;CODE
	LXI	H,CONBUF+2	;BC <- CHARACTER COUNT
	MOV	C,M
	MVI	B,0
	INR	M		;TEST FOR END OF LINE ALREADY
	JZ	SCANX		;IF YES
	INX	H		;HL <- SCANNING START POINT
	DAD	B
	MOV	B,C		;B <- CHARACTER COUNT
SCAN1:	INX	H		;INCREMENT POINTER
	INR	B		;INCREMENT COUNT
	MOV	A,M		;GET NEXT CHARACTER
	ORA	A		;TEST FOR END OF LINE
	JZ	SCANX		;IF YES,
	CPI	20H		;ELSE, CHECK FOR BLANK
	JZ	SCAN1		;IF YES, SKIP IT
	LXI	D,CONBUF+3	;ELSE BEGIN MOVING WORD
	MVI	C,0		;C <- SIZE OF STRING
SCAN2:	INX	D
	STAX	D
	INR	C		;INC WORD SIZE
	INR	B		;INC SCANNED CHAR COUNT
	INX	H		;GET NEXT BYTE
	MOV	A,M
	ORA	A		;TEST FOR END OF LINE
	JNZ	SCAN3		;IF NOT,
	MVI	B,-1		;ELSE SET EOL FLAG
	MVI	A,20H		;AND CHANGE EOL TO DELIMETER
SCAN3:	CPI	20H		;CHECK FOR SPACE
	JNZ	SCAN2		;IF NOT YET
	LXI	H,CONBUF+2	;ELSE SAVE SCANNED CHAR COUNT
	MOV	M,B
	INX	H		;AND WORD SIZE
	MOV	M,C
	PUSH	H		;AND RETURN WORD POINTER
	LXI	H,-1
	PUSH	H
	JMP	NEXT
;
SCANX:	MVI	A,-1		;HIT END OF LINE
	STA	CONBUF+2	;MARK BUFFER EMPTY
	LXI	H,0		;RETURN A ZERO
	PUSH	H
	JMP	NEXT
;
; CONBXA - convert binary to ascii
;
; ENTRY: TOP - 16 bit positive integer
; EXIT:  TOP - address of converted ASCII string
; DESCRIPTION: pushes the digits of the number
; on to the stack, least significant digits first.
; Then pops them up and stores them in a local
; buffer.
;
CONBXA: DW	TCALL		;THREADED CODE
	DW	NEGONE,SWAP	;MARK END OF STRING WITH -1
CONB1:	DW	TPUSH,10,DIV	;DIVIDE NUMBER BY 10
	DW	SWAP		;PUT QUOTIENT ON TOP
	DW	DUP
	DW	IFNZ,CONB1-1	;CONTINUE UNTIL Q = 0
;
	DW	TPOP		;THEN DROP QUOTIENT
	DW	ZERO		;STORE BYTE IN FIRST
	DW	NBUFR,POKEB	;BYTE OF BUFFER
;
CONB2:	DW	DUP,NEGONE	;TEST FOR END OF STRING
	DW	IFEQ,CONB3-1	;IF YES
	DW	NBUFR,PEEKB	;ELSE, INCREMENT BYTE COUNT
	DW	INC
	DW	NBUFR,POKEB
	DW	TPUSH,'0',TADD	;CONVERT DIGIT TO ASCII
				;AND STORE IN NEXT LOCATION
	DW	NBUFR
	DW	NBUFR,PEEKB,TADD
	DW	POKEB
	DW	JUMP,CONB2-1	;REPEAT
;
CONB3:	DW	TPOP		;DROP END OF STRING MARKER
	DW	NBUFR		;PUSH RETURN BUFFER ADDRESS
	DW	TRET		;AND RETURN
;
NBUFR:	DW	VARIABLE	;THREADED VARIABLE
	DS	10		;PLENTY LONG ENOUGH
;
; CONAXB - convert ASCII decimal string to binary
; ENTRY: TOP   - pointer to string
; EXIT:  TOP   - -1 if converted to binary
;		  0 if not
;	 TOP-1 - value of number if converted
;		 ptr to string if not
; DESCRIPTION: converts only positive, unsigned
; integers. WRitten in assembly because I had it around
; and didn't want to rewrite it in threaded code.
;
CONAXB: DW	$+2		;CODE
	POP	D		;GET STRING POINTER
	PUSH	D		;BUT LEAVE ON STACK
	LDAX	D		;GET BYTE COUNT
	MOV	B,A
	LXI	H,0		;STARTING VALUE
;
CONA1:	INX	D
	LDAX	D		;GET NEXT CHARACTER
	CPI	'0'		;TEST FOR DIGIT
	JC	CONAX		;IF NOT
	CPI	'9'+1
	JNC	CONAX		;IF NOT
	SUI	'0'		;CONVERT TO BINARY
	PUSH	D		;SAVE POINTER
	DAD	H		;MULTIPLY CURRENT VALUE BY 10
	PUSH	H
	DAD	H
	DAD	H
	POP	D
	DAD	D
	MOV	E,A		;ADD NEW BINARY DIGIT
	MVI	D,0
	DAD	D
	POP	D		;RESTORE POINTER
	DCR	B		;DEC COUNT
	JNZ	CONA1		;CONTINUE TILL DONE
	POP	D		;THEN DROP POINTER
	PUSH	H		;PUSH NUMBER
	LXI	H,-1		;AND -1
	PUSH	H
	JMP	NEXT
;
CONAX:	LXI	H,0		;FAILURE: PUSH A ZERO
	PUSH	H
	JMP	NEXT
;
; DIV - 16 bit divide
; ENTRY: TOP   - divisor
;	 TOP-1 - dividend
; EXIT:  TOP   - remainder
;	 TOP-1 - quotient
; DESCRIPTION: performs a 32 bit by 16 bit division for
; positive integers only.  The quotient must be resolved
; in 16 bits.
;
DIV:	DW	$+2		;CODE
	POP	B		;BC <- DIVISOR
	POP	D		;HLDE <- DIVIDEND
	LXI	H,0
	CALL	DIV1		;DO DIVISION
	PUSH	D		;PUSH QUOTIENT
	PUSH	H		;PUSH REMAINDER
	JMP	NEXT
;
DIV1:	DCX	B		;NEGATE BC
	MOV	A,B
	CMA
	MOV	B,A
	MOV	A,C
	CMA
	MOV	C,A
	MVI	A,16D		;ITERATION COUNT
DIV2:	DAD	H		;SHIFT HLDE
	PUSH	PSW		;SAVE OVERFLOW
	XCHG
	DAD	H
	XCHG
	JNC	DIV3
	INR	L
DIV3:	POP	PSW		;GET OVERFLOW
	JC	DIV5		;IF OVERFLOW, FORCE SUBTRACTION
	PUSH	H		;ELSE, SAVE DIVIDEND
	DAD	B		;ATTEMPT SUBTRACTION
	JC	DIV4		;IF IT GOES
	POP	H		;ELSE RESTORE DIVIDEND
	JMP	DIV6
DIV4:	INR	E		;INCREMENT QUOTIENT
	INX	SP		;DROP OLD DIVIDEND
	INX	SP
	JMP	DIV6
DIV5:	DAD	B		;FORCE SUBTRACTION
	INR	E		;INC QUOTIENT
DIV6:	DCR	A		;DECREMENT COUNT
	JNZ	DIV2		;REPEAT UNTIL DONE
	RET
;
; The Names in the dictionary
; Notice that the actual printed names are chosen for typing
; convenience and do not necessarily match the internal names,
; which must conform to the assembler's rules. Also, not all
; functions have been included here.
;
NAMEBEG EQU	$
;
	DB	1,'+'
	DW	TADD
;
	DB	1,'-'
	DW	TSUB
;
	DB	4,'/MOD'
	DW	DIV
;
	DB	7,'EXECUTE'
	DW	EXECUTE
;
	DB	5,'CLEAR'
	DW	CLEAR
;
	DB	5,'MATCH'
	DW	MATCH
;
	DB	6,'LOOKUP'
	DW	LOOKUP
;
	DB	4,'EXEC'
	DW	EXEC
;
	DB	6,'MEMORY'
	DW	MEMORY
;
	DB	6,'CONBXA'
	DW	CONBXA
;
	DB	3,'INC'
	DW	INC
;
	DB	3,'DEC'
	DW	DEC
;
	DB	5,'MINUS'
	DW	MINUS
;
	DB	5,'PEEKW'
	DW	PEEKW
;
	DB	5,'PEEKB'
	DW	PEEKB
;
	DB	5,'POKEW'
	DW	POKEW
;
	DB	5,'POKEB'
	DW	POKEB
;
	DB	3,'POP'
	DW	TPOP
;
	DB	4,'SWAP'
	DW	SWAP
;
	DB	3,'DUP'
	DW	DUP
;
	DB	5,'FIRST'
	DW	FIRST
;
	DB	0			;END OF DICTIONARY
;
NAMEEND EQU	$-1
;
DICSIZE EQU	NAMEEND-NAMEBEG+1	;DICTIONARY SIZE IN BYTES
;
; Initialition Code
; Executed on start up of system but eventually overwritten by
; the expanding dictionary
;
; DICMOVE - moves the dictionary names
;	    to the top of available memory
;
; <<<===  Modified For CPM initialization (RGF)  ===>>>
;
DICMOVE:
	LHLD	6
	SHLD	MEMORY+2	;INIT TOP OF MEMORY
	XCHG			;DE <- TOP OF MEMORY
	LXI	H,NAMEEND	;HL <- SOURCE (END OF NAMES)
	LXI	B,DICSIZE	;BC <- BYTE COUNT
				;TRANSFER LOOP
DIC1:	MOV	A,M		;GET NEXT BYTE
	STAX	D		;MOVE IT
	DCX	H		;DEC SOURCE POINTER
	DCX	D		;DEC TARGET POINTER
	DCX	B		;DEC COUNT
	MOV	A,B		;TEST FOR ZERO
	ORA	C
	JNZ	DIC1		;NOT YET
;
	XCHG			;SET DICTIONARY VARIABLE
	INX	H
	SHLD	NAMES+2
;
	LDA	2		;MODIFIY I/O ROUTINES
	STA	VCOUT+2 	;  SO THEY WILL WORD
	STA	VCIN+2		; IN ANY SIZE CPM SYSTEM
;
	RET
;
;
;
;
	END	BASE
