****************************************************************************

*         Read the Calendar/clock on the TimEPROMmer Board                 *  
*       from Optronics Technology, POB 81, Pittsford, NY 14534             *
*       by D. Mc Lanahan, POB 17, Marlow, NH 03456, 1 Feb 1983	   	   *
*                Numeric date group (as DD/MM/YY)			   *   

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
	SLASH	EQU	2FH
	DLYL	EQU	14

	ORG	CPM$BASE+100H

	MVI     A,10H
	OUT	CLK	;OUTPUT HOLD BIT
	MVI	A,00			
	CALL	COUT
	MVI	A,00H			
	CALL	COUT
        LXI     B,DLYL
        CALL    DELAY
        MVI     A,48
	OUT	CLK		;OUTPUT HOLD AND READ BITS
	NOP
	NOP
        

MON10:  MVI     A,58            ;ASK FOR DECADE MONTH
	LXI	B,01H		;NOT OVER 1
	CALL 	READ


MON1:   MVI     A,57		;ASK FOR UNIT MONTH
	CALL 	READ

	MVI	A,SLASH
	CALL 	COUT

DA10:   MVI     A,56            ;ASK FOR DECADE DATE
	LXI	B,03H		;NOT OVER 3
	CALL 	READ

DA1:    MVI     A,55            ;ASK FOR UNIT DATE
	LXI	B,0FH
	CALL	READŠ
	MVI 	A,SLASH
	CALL	COUT

YR10:	MVI     A,60            ;ASK FOR DECADE YEAR
	CALL	READ

YR1:	MVI     A,59		;ASK FOR UNIT YEAR
	CALL	READ
	
        CALL    PRCSP

        MVI     A,SPACE
        CALL    COUT

HR10:   MVI     A,53            ;ASK FOR DECADE HOUR
	LXI	B,03H		;NOT OVER 2
	CALL 	READ

HR1:    MVI     A,52            ;ASK FOR UNIT HOUR
	CALL	READ

	MVI	A,COLON
	CALL 	COUT

MIN10:	MVI     A,51            ;ASK FOR DECADE MINUTES
	LXI	B,07H
	CALL	READ

MIN1:	MVI     A,50		;ASK FOR UNIT MINUTES
	CALL 	READ

	MVI	A,COLON
	CALL    COUT

SEC10:	MVI     A,49            ;ASK FOR DECADE SECONDS
	LXI	B,07H
	CALL    READ


SEC1:	MVI     A,48		;ASK FOR UNIT SECONDS
	CALL	READ

	MVI	A,00		;RELEASE CLOCK HOLD
	OUT	CLKŠ	RET

READ:   OUT     CLK
        NOP
        NOP
        IN      CLK+1           
	ANA	C	;LEGAL NUMBER?
	ADI	'0'	;CONVERT TO ASCII
	CALL 	COUT
	LXI	B,0FH
	RET
    
PRCSP:	MVI	A,COMMA 	;PRINT COMMA
	CALL	COUT
	MVI	A,SPACE		;PRINT SPACE
        CALL    COUT
	RET


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


	END
