*******************************************************
*						      *
*	    CITOH GRAPHICS PRINTER DRIVER	      *
*						      *
*	   USING ONLY THE TOP 4 PRINT PINS	      *
*						      *
*	    (Configured for the Sorcerer)	      *
*						      *
*      Written by William King (November,1982)	      *
*						      *
*******************************************************


;  History
;  -------
;     The original driver program was written using 8-
;  bit data with a suitable cable to the printer.  This
;  seemingly obvious exploit lead to a friend's printer
;  and my own printer breaking down beyond repair (I
;  don't know why, nor did the printer repair people,
;  very expensive).  This prompted me to write a driver
;  that used 7 bit data or less.  This driver uses only
;  the top 4 print pins (but still sending 7 bit data).
;  Thus there are NO hardware mods required (i.e. the
;  original print cable and settings may be used.
;
;  Use
;  ---
;     The main driver routine may be called as a sub.
;  by calling BASEAD+0 (i.e. 5000h in this case).
;     The video output may be set to BASEAD+0 so all
;  graphics data + text is printed 4 dot lines at a
;  time (i.e. for Sorcerer SE O=5000 from monitor)
;     The screen may be dumped to the printer as is by
;  calling the routine at BASEAD+100h (i.e. 5100h in
;  this case - note that it should be called via a
;  program rather than direct running from moitor so as
;  to preserve the entire screen display)
;
;  Cable
;  -----
;     Use the cable normally used for printing ASCII
;  data (NO need for a special cable)
;
;  Changes
;  -------
;     The program may be reconfigured for other
;  printers and other computers taking special note of
;  the following points :
;    (1) Alter line feed pitch code sequence at LFDATA
;    (2) Alter here comes 8 data bytes for graphics
;	 code at GDATA
;    (3) Alter screen width at SWIDTH
;    (4) Alter # of lines on screen at LINES
;    (5) Alter start address of screen at SCRTOP
;    (6) Alter monitor equates as required


*  MONITOR EQUATES  *


VIDEO:	EQU	0E01BH	      ;VIDEO OUTPUT
KEYIN:	EQU	0E009H	      ;GET A KEY ROUTINE
MONWRM: EQU	0E003H	      ;MONITOR WARM START


*  HARDWARE EQUATES  *


PWIDTH: EQU	80	      ;PRINTER WIDTH (SO IF NO
			      ; <CR> HAS COME, BUFFER
			      ; WILL NOT OVERFLOW !)
SWIDTH: EQU	64	      ;SCREEN WIDTH (FOR SCREEN
			      ; DUMP)
LINES:	EQU	30	      ;# OF LINES ON SCREEN
SCRTOP: EQU	0F080H	      ;ADDR OF TOP OF SCREEN
ASCLOW: EQU	0F800H	      ;LOWEST ASCII CHARACTER
			      ; ADDRESS


BASEAD: EQU	05000H	      ;BASE ADDRESS OF DRIVER


	ORG	BASEAD	      ;SET BASE ADDR OF DRIVER


START:	JR	POUT1-$	      ;PAST SUBROUTINES


*  PRINTER DRIVER ROUTINE  *


DRIVE:	PUSH	AF
	PUSH	AF

DR1:	IN	A,(0FFH)
	BIT	7,A
	JR	NZ,DR1-$

	POP	AF

	OR	080H
	OUT	(0FFH),A
	AND	07FH
	OUT	(0FFH),A
	OR	080H
	OUT	(0FFH),A

	POP	AF
	RET


*  SENDS DATA FOLLOWING THE CALL,TO PRINTER  *


DATA:	POP	HL	      ;FIRST BYTE OF DATA

DAT1:	LD	A,(HL)	      ;GET DATA
	OR	A	      ;LAST BYTE?
	JR	Z,DAT2-$      ;YES,THEN BACK
	CALL	DRIVE	      ;NO,THEN SEND BYTE TO PRT
	INC	HL	      ;NEXT BYTE
	JR	DAT1-$	      ;KEEP GOING

DAT2:	INC	HL	      ;NEXT BYTE
	JP	(HL)	      ;JUMP THERE


*  MAIN PROGRAM	 *


POUT1:	CALL	VIDEO	      ;CHAR TO SCREEN

POUT2:	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF

	CP	' '	      ;CHAR >= SPACE?
	JR	NC,COUNT-$    ;YES,THEN COUNT HOW MANY
	CP	00DH	      ;<CR>?
	JR	Z,COUNT-$     ;YES,THEN DO THAT TOO!
	CP	00AH	      ;LF?
	JR	Z,END-$	      ;YES,THEN DO NOTHING
	CP	00CH	      ;CLEAR SCREEN?
	JR	Z,END-$	      ;YES,THEN DO NOTHING

	CALL	DRIVE	      ;SEND CONTROL CHAR

END:	POP	AF
	POP	BC
	POP	DE
	POP	HL

	RET


COUNT:	CP	00DH	      ;IS IT A <CR>?
	JR	Z,PRINT-$     ;YES,THEN DO THE LINE

	LD	B,A	      ;SAVE THE CHAR
	LD	A,(BUFCNT)    ;GET NUMB. CHARS IN BUFF.
	LD	E,A	      ;GET TO E
	LD	D,00
	LD	HL,BUFFER     ;START OF BUFFER
	ADD	HL,DE	      ;WHERE CHAR MUST GO
	LD	(HL),B	      ;PUT CHAR IN BUFFER
	INC	A	      ;COUNT = COUNT + 1
	LD	(BUFCNT),A    ;SAVE IT BACK
	CP	PWIDTH	      ;COUNT >= PRINTER WIDTH?
	JR	C,END-$	      ;NO,THEN BACK TO CALLER

PRINT:	CALL	DATA	      ;SEND FOLLOWING DATA

LFDATA: DB	01BH,054H,'08';LF PITCH = 8/144"
	DB	01BH,051H     ;COMPRESSED PRINT !!
	DB	000H	      ;END CODE

	XOR	A	      ;CLEAR:
	LD	(FLAG),A      ;	     FIRST PASS FLAG

PASS1:	LD	A,(BUFCNT)    ;GET BUFFER COUNTER
	OR	A	      ;NO CHARS TO DO?
	JR	Z,CR1-$	      ;YES,THEN JUST SEND <CR>

	LD	B,A	      ;GET COUNT TO B
	LD	HL,BUFFER     ;POINTER TO START OF BUFF

PASS2:	LD	A,(HL)	      ;GET A CHAR

	CALL	BITS	      ;DO TOP OR BOT. BITS

	INC	HL

	DJNZ	PASS2-$	      ;SEND THEM OUT TILL DONE

	LD	A,(FLAG)      ;GET FLAG
	OR	A	      ;FINISHED?
	JR	NZ,CR2-$      ;YES,THEN DO A <CR>

	CPL		      ;SET FLAG TO A NZ VALUE
	LD	(FLAG),A      ;SAVE FLAG BACK

	LD	A,0DH	      ;SEND A CR TO END LINE
	CALL	DRIVE

	JR	PASS1-$	      ;DO SECOND PASS

CR1:	LD	A,00DH	      ;SEND A <CR>
	CALL	DRIVE

CR2:	LD	A,00DH	      ;SEND A <CR>
	CALL	DRIVE

	XOR	A	      ;CLEAR:
	LD	(BUFCNT),A    ;	     BUFFER COUNT
	LD	(FLAG),A      ;	     PASS FLAG

	JP	END	      ;BACK TO CALLER


*  ROUTINE TO ROTATE CHARACTER IN REGISTER A	 *
*  THEN SEND OUT HIGH OR LOW 4 BITS (TOP 4 PINS	 *
*  ON PRINTER),THUS ONLY USING THE TOP 4 PINS	 *


BITS:	PUSH	HL
	PUSH	BC
	PUSH	AF

	PUSH	AF

	CALL	DATA	      ;SEND OUT FOLLOWING DATA

GDATA:	DB	01BH,053H,'0008'  ;"HERE COMES 8 GRAPH.
	DB	000H		  ; DATA BYTES"

	POP	AF

BIT1:	LD	L,A	      ;GET CHAR TO L
	LD	H,00	      ;CLEAR H
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL	      ;* 8
	LD	DE,ASCLOW     ;LOWEST ASCII CHAR ADDR.
	ADD	HL,DE	      ;GET ADDRESS OF CHAR

	PUSH	HL	      ;SAVE ADDRESS
	LD	C,080H	      ;BIT 7 SET
	PUSH	BC	      ;SAVE MASK

BIT2:	LD	E,00	      ;CLEAR E (RESULT IN HERE)
	LD	B,001H	      ;SET BIT 1

BIT3:	LD	A,(HL)	      ;GET CHARACTER DATA
	AND	C	      ;MASK OUT ALL OTHER BITS
	JR	Z,BIT4-$      ;NO BIT SET,THEN PAST

	LD	A,E	      ;GET ANSWER
	OR	B	      ;SET THE CORRECT BIT
	LD	E,A	      ;SAVE RESULT

BIT4:	RL	B	      ;SET NEXT BIT ON LEFT
	INC	HL	      ;POINT TO NEXT DATA BYTE
	LD	A,B
	OR	A	      ;FINISHED THIS VERT. LINE
	JR	NZ,BIT3-$     ;NO,THEN DO 8 BITS TOTAL

	LD	A,(FLAG)      ;FLAG ZERO=LOWER 4 BITS
	OR	A	      ;ZERO?
	LD	A,E	      ;GET DATA TO A
	JR	NZ,BIT5-$     ;NO, MUST BE UPPER 4 BITS

	AND	00FH	      ;ZERO,THEN KEEP LOW BITS
	JR	BIT6-$	      ;JUMP

BIT5:	AND	0F0H	      ;NONZERO,THEN KEEP HIGH 4
	SRL	A
	SRL	A
	SRL	A
	SRL	A	      ;MOVE HIGH 4 -> LOW 4

BIT6:	CALL	DRIVE	      ;SEND OUT DATA

	POP	BC	      ;GET MASK BACK
	RR	C	      ;SHIFT BITS TO RIGHT
	POP	HL	      ;GET ADDRESS BACK
	PUSH	HL
	PUSH	BC
	LD	A,C	      ;GET MASK
	OR	A	      ;DONE 8 TIMES?
	JR	NZ,BIT2-$     ;NO,THEN KEEP GOING

	POP	BC	      ;RESTORE PUSHES/POPS
	POP	HL

	POP	AF
	POP	BC
	POP	HL

	RET		      ;RETURN TO CALLER


*  SCREEN DUMP ROUTINE	*


	ORG	BASEAD+100H   ;NEED EVEN ADDRESS


BEGIN:	LD	B,01	      ;NO. OF COPIES

BEG1:	CALL	SCREEN	      ;DO ONE COPY

BEG2:	CALL	KEYIN	      ;KEYSCAN
	CP	'P'	      ;"P"?
	JR	NZ,BEG2-$     ;NO,THEN WAIT

	DJNZ	BEG1-$	      ;DO TILL COPIES=0

	JP	MONWRM	      ;BACK TO MONITOR


SCREEN: PUSH	HL
	PUSH	BC
	PUSH	AF

	LD	HL,SCRTOP     ;TOP OF SCREEN

	LD	C,LINES	      ;# OF LINES ON SCREEN

	XOR	A	      ;CLEAR:
	LD	(BUFCNT),A    ;	     PRINT BUF COUNT

SCRN1:	LD	B,SWIDTH      ;WIDTH OF SCREEN

SCRN2:	LD	A,(HL)	      ;GET CHAR
	CALL	POUT2	      ;SEND CHAR TO PRINTER
	INC	HL
	DJNZ	SCRN2-$

	LD	A,00DH	      ;<CR>
	CALL	POUT2	      ;SEND <CR> TO PRINTER

	DEC	C	      ;DEC # OF LINES
	LD	A,C	      ;GET # OF LINES TO A
	OR	A	      ;END YET?
	JR	NZ,SCRN1-$    ;NO,THEN DO ANOTHER LINE

	POP	AF
	POP	BC
	POP	HL

	RET		      ;BACK TO COUNTING ROUT.


*  DATA AREA  *


BUFCNT: DEFS	1	      ;BYTE COUNTER (IN BUFF)
FLAG:	DEFS	1	      ;PASS FLAG


BUFFER: DB	00	      ;SPACE FOR BUFFER


	END
