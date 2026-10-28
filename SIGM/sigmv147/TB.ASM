****************************************************************************

*         Read the Calendar/clock on the TimEPROMmer Board                 *  
*       from Optronics Technology, POB 81, Pittsford, NY 14534             *
*       by D. Mc Lanahan, POB 17, Marlow, NH 03456, 1 Feb 1983	   	   *
*            3-char month spelled out, week-day omitted			   *	   

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
	DLYL	EQU	1		;DELAY PROBABLY NOT
					;NEC, DEP ON OUTPUT
	ORG	CPM$BASE+100H		;BUAD RATE

	MVI     A,10H
	OUT	CLK			;OUTPUT HOLD BIT
	MVI	A,SPACE
	CALL	COUT
	MVI	A,SPACE
	CALL	COUT
        LXI     B,DLYL
        MVI     A,48
	OUT	CLK	;OUTPUT HOLD AND READ BITS
	NOP
	NOP
        

DA10:   MVI     A,56            ;ASK FOR DECADE DATE
        OUT     CLK
        NOP
        NOP
        IN      CLK+1           ;GET DECADE DATE
	ANI	03H		;NOT OVER 3
        CALL    HEX1            ;CONVERT TO ASCII
        CALL    COUT            ;PRINT DECADE DATE
DA1:    MVI     A,55            ;ASK FOR UNIT DATE
        OUT     CLK
        NOP
        NOP
        IN      CLK+1           ;GET UNIT DATE
        CALL    HEX1
        CALL    COUT            ;PRINT UNIT DATE
	MVI	A,SPACE
	CALL	COUT

MON1:   MVI     A,58            ;ASK FOR DECADE MONTH
        OUT     CLK
        NOP
        NOP
        LXI     D,00            ;CLEAR REGISTER
        IN      CLK+1           ;GET DECADE MONTH    
        ANI	01H		;KILL HIGH NIBBLE
	JZ      MON2            ;IF DECADE IS ZERO
        MVI	D,10
MON2    MVI     A,57
        OUT     CLK
        NOP
        MVI     H,0
        IN      CLK+1
        ANI     0FH
        ADD     D
        DCR     A              ;0 to 11 from 1 to 12
        ADD	A
        ADD	A
        MOV     L,A
        LXI     D,MONTH
        DAD     D
        CALL    PRINT
	MVI	A,SPACE    
	CALL	COUT

YRHD:	MVI	A,31H		;PRINT 1 <--\
	CALL	COUT		;change these in 1999
	MVI     A,39H		;PRINT 9 <--/
	CALL	COUT		;Don't Forget!! 

YR10:	MVI     A,60            ;ASK FOR DECADE YEAR
        OUT     CLK
        NOP
        NOP
        IN      CLK+1           ;GET DECADE YEAR
	CALL 	HEX1
        CALL 	COUT

YR1:	MVI     A,59		;ASK FOR UNIT YEAR
        OUT     CLK
        NOP
        NOP
        IN      CLK+1		;GET UNIT YEAR
	CALL	HEX1
	CALL	COUT
	
        CALL    PRCSP

        MVI     A,SPACE
        CALL    COUT

HR10:   MVI     A,53            ;ASK FOR DECADE HOUR
        OUT     CLK
        NOP
        NOP
        IN      CLK+1           ;GET DECADE HOUR
        ANI     03H		;NOT OVER 2
        CALL    HEX1            ;CONVERT TO ASCII
        CALL    COUT            ;PRINT DECADE HOUR
HR1:    MVI     A,52            ;ASK FOR UNIT HOUR
        OUT     CLK
        NOP
        NOP
        IN      CLK+1           ;GET UNIT HOUR
        CALL    HEX1Š        CALL    COUT            ;PRINT UNIT HOUR
	MVI	A,COLON
	CALL 	COUT

MIN10:	MVI     A,51            ;ASK FOR DECADE MINUTES
        OUT     CLK
        NOP
        NOP
        IN      CLK+1           ;GET DECADE MINUTES
	ANI	07H		;NOT OVER 6
	CALL 	HEX1
        CALL 	COUT

MIN1:	MVI     A,50		;ASK FOR UNIT MINUTES
        OUT     CLK
        NOP
        NOP
        IN      CLK+1		;GET UNIT MINUTES
	CALL	HEX1
	CALL	COUT
	MVI	A,COLON
	CALL    COUT

SEC10:	MVI     A,49            ;ASK FOR DECADE SECONDS
        OUT     CLK
        NOP
        NOP
        IN      CLK+1           ;GET DECADE SECONDS
	ANI	07H
	CALL 	HEX1
        CALL 	COUT

SEC1:	MVI     A,48		;ASK FOR UNIT SECONDS
        OUT     CLK
        NOP
        NOP
        IN      CLK+1
	CALL	HEX1
	CALL	COUT

	MVI	A,00		;RELEASE CLOCK HOLD
	OUT	CLK
	RET

HEX1:	ANI	0FH	; MASK OUT HIGH
	ADI	'0'	; CONVERT 0-9 TO '0'-'9'
        RET
    
PRCSP:	MVI	A,COMMA 	;PRINT COMMA
	CALL	COUTŠ	MVI	A,SPACE		;PRINT SPACE
        CALL    COUT
	RET

*  PRINT STRING ENDING IN 0 PTED TO BY (HL)
PRINT:
	MOV	A,M	; GET BYTE
	INX	H	; PT TO NEXT
	ORA	A	; DONE?
        RZ
	CALL	COUT	; PRINT IT
	JMP	PRINT

*  PRINT CHAR IN REG A ON CONSOLE
COUT:	PUSH	H	; SAVE REGS
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
