****************************************************************************

*         Read the Calendar/clock on the TimEPROMmer Board                 *  
*       from Optronics Technology, POB 81, Pittsford, NY 14534             *
*       by D. Mc Lanahan, POB 17, Marlow, NH 03456, 1 Feb 1983	   	   *
*           3-char month spelled out, week-day spelled out		   *	   

****************************************************************************


CPM$BASE	EQU	0		; BASE ADDRESS OF CP/M SYSTEM
	CLK	EQU	40		; BASE ADDRESS OF TP-100 CLOCK
	BDOS	EQU	CPM$BASE+5	; ADDRESS OF BDOS ENTRY
	CR	EQU	0DH
	LF	EQU	0AH
        SPACE   EQU     20H
        PERIOD  EQU     2EH
        COMMA   EQU     2CH
	COLON	EQU	3AH
	DLYL	EQU	1		;ONLY IF INITIAL SPACES DROPPED
					;-BUT <>0 IF ROUTINE REMAINS
	ORG	CPM$BASE+100H

	MVI     A,10H
	OUT	CLK			;OUTPUT HOLD BIT
	MVI	A,SPACE
	CALL	COUT
	MVI	A,SPACE
	CALL	COUT
	MVI	A,SPACE
	CALL	COUT
	MVI	A,SPACE
	CALL	COUT
	MVI	A,SPACE
	CALL	COUT
        MVI	C,DLYL
        MVI     A,48
	OUT	CLK	;OUTPUT HOLD AND READ BITS
	NOP
	NOP
        

DA10:   MVI     A,56            ;ASK FOR DECADE DATE
	MVI	C,03		;NOT OVER 3
	CALL	READ

DA1:    MVI     A,55            ;ASK FOR UNIT DATE
	CALL	READ

	MVI	A,SPACE
	CALL	COUT

MON1:   MVI     A,58            ;ASK FOR DECADE MONTH
	OUT	CLK
        NOP
        NOP
        LXI     D,00            ;CLEAR REGISTER
        IN      CLK+1           ;GET DECADE MONTH    
        ANI	01H		;KILL LEAP YEAR BIT
	JZ      MON2            ;IF DECADE IS ZERO
        MVI	D,10		;IF NOT LOAD 10
MON2    MVI     A,57		;ASK FOR UNIT MONTH
        OUT     CLK
        NOP
        MVI     H,0		;HOUSEKEEP
        IN      CLK+1		;GET UNIT MONTH
        ANI     0FH		;KILL HIGH NIBBLE
        ADD     D		;COMB. TENS & UNITS
        DCR     A               ;0 to 11 from 1 to 12
        ADD	A		;MULTIPLY BY TWO
        ADD	A		;AND AGAIN (4x-each month
        MOV     L,A		;is 4 bytes in table)
        LXI     D,MONTH		;
        DAD     D		;
        CALL    PRINT		;PRINT MO. FROM TABLE
	MVI	A,SPACE    
	CALL	COUT

YRHD:	MVI	A,31H		;PRINT 1 <--\
	CALL	COUT		;change these in 1999
	MVI     A,39H		;PRINT 9 <--/
	CALL	COUT		; -DON'T FORGET!-

YR10:	MVI     A,60            ;ASK FOR DECADE YEAR
	CALL 	READ

YR1:	MVI     A,59		;ASK FOR UNIT YEAR
	CALL	READ
	
        CALL    PRCSP


WKDAY:  MVI     A,54		;ASK FOR WKDAY NO.
        OUT     CLK
        NOP
        MVI     H,0
        IN      CLK+1		;GET WKDAY NO.
        ANI     07H		;LESS THAN 7
        ADD     A		;MULT. BY 8
        ADD	A		;8 bytes per day
        ADD	A		;in table
        MOV     L,A
        LXI     D,DAY
        DAD     D
        CALL    PRINT
	LXI	H,00
	LXI	H,WKD		;Now print 'day'-
	CALL 	PRINT		;(saves table space)

	CALL	PRCSP

HR10:   MVI     A,53            ;ASK FOR DECADE HOUR
        MVI	C,03		;KILL AM/PM BIT 
        CALL    READ		;PRINT DECADE HOUR

HR1:    MVI     A,52            ;ASK FOR UNIT HOUR
        CALL    READ		;PRINT UNIT HOUR
	
	MVI	A,COLON
	CALL 	COUT

MIN10:	MVI     A,51            ;ASK FOR DECADE MINUTES
	MVI	C,07		;NOT OVER 6
        CALL 	READ

MIN1:	MVI     A,50		;ASK FOR UNIT MINUTES
	CALL	READ

	MVI	A,COLON
	CALL    COUT

SEC10:	MVI     A,49            ;ASK FOR DECADE SECONDS
	MVI	C,07
        CALL 	READ

SEC1:	MVI     A,48		;ASK FOR UNIT SECONDS
	CALL	READ


	MVI	A,00		;RELEASE CLOCK HOLD
	OUT	CLK
	RET

READ:	OUT CLK
	NOP		;a bit of wheelspinning while
	NOP		;the chip gets 'it' together
	IN	CLK+1
	ANA	C	;CLEAN IT UP
	ADI	'0'	;CONVERT 0-9 TO '0'-'9'
	CALL 	COUT
        MVI	C,0FH	;READY FOR NEXT CLEANING
	RET
    
PRCSP:	MVI	A,COMMA 	;PRINT COMMA
	CALL	COUTŠ	MVI	A,SPACE		;PRINT SPACE
        CALL    COUT
	RET

*  PRINT STRING ENDING IN 0 PTED TO BY H & L
PRINT:	MOV	A,M	; GET BYTE
	INX	H	; PT TO NEXT
	ORA	A	; DONE?
        RZ
	CALL	COUT	; PRINT IT
	JMP	PRINT

*  PRINT CHAR IN REG A ON CONSOLE
COUT:
	PUSH	H	; SAVE REGS
	PUSH	D
	PUSH	B
	MOV	E,A
	MVI	C,2	; CONSOLE OUTPUT
	CALL	BDOS
	POP	B	; RESTORE REGS
	POP	D
	POP	H
	RET

DELAY:  DCR	C
	JNZ	DELAY
	RET

WKD:	DB	'day',0

DAY:	DB	'Sun',0,0,0,0,0
	DB	'Mon',0,0,0,0,0
	DB	'Tues',0,0,0,0
	DB	'Wednes',0,0
	DB	'Thurs',0,0,0
	DB	'Fri',0,0,0,0,0
	DB	'Satur',0,0,0

MONTH:	DB	'Jan',0
	DB 	'Feb',0
	DB	'Mar',0
	DB	'Apr',0
	DB	'May',0
	DB	'Jun',0
	DB	'Jul',0
	DB	'Aug',0
	DB	'Sep',0
	DB	'Oct',0
	DB	'Nov',0
	DB	'Dec',0


	END
