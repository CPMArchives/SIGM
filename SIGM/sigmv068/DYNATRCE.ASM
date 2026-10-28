;*****************************************************
;                                                    *
;                  DYNATRACE                         *
;                    V 2.0                           *
;                                                    *
;     COPYRIGHT (C) 1976, BY RICHARD E. MEADOR       *
;                            SACRAMENTO, CALIFORNIA  *
;                                             95826  *
;                                                    *
;      ALL RIGHTS RESERVED WITH THE EXCEPTION OF     *
; REPRODUCTION BY THOSE INDIVIDUALS FOR THEIR OWN    *
; NONCOMERCIAL USE WHO HAVE PURCHASED DYNATRACE FROM *
; AN AUTHORIZED DISTRIBUTOR.                         *
;                                                    *
;*****************************************************
;
;
;
	ORG	8000H
DYNAT:	DS	400H	;BASE ADDRESS OF PROGRAM
STACK   EQU     DYNAT+0C00H       ;SET UP SYSTEM STACK
CONPRT	EQU	0C8H	;CONTROL PORT ADDRESS
SCREEN  EQU     0BC00H  ;1K OF BUFFER FOR SCREEN
TOS     EQU     (SCREEN+1024)/256    ;LAST BUFFER ADDRESS+1
MIDSCR  EQU     SCREEN+448      ;TOP LINE OF ROLLUP PORTION OF SCREEN
LINE    EQU     64      ;64 CHARACTERS/LINE
LINE1   EQU     SCREEN+LINE
LINE2   EQU     LINE1+64
LINE3   EQU     LINE2+64
LINE4   EQU     LINE3+64
LINE5   EQU     LINE4+64
LINE15  EQU     SCREEN+960
PCH     EQU     LINE1+8 ;PC HEX DISPLAY LOCATION
INSTA   EQU     LINE2+8 ;INSTRUCTION ASCII DISPLAY LOCATION
INSTH   EQU     LINE2+18        ;INSTRUCTION HEX DISPLAY LOCATION
SB      EQU     LINE4+8 ;SIGN FLAG BINARY DISPLAY LOCATION
ZB      EQU     LINE4+9 ;ZERO FLAG BINARY DISPLAY LOCATION
ACB     EQU     LINE4+11        ;AUX CARRY FLAG BINARY DISPLAY LOCATION
PB      EQU     LINE4+13        ;PARITY FLAG BINARY DISPLAY LOCATION
CYB     EQU     LINE4+15        ;CARRY FLAG BINARY DISPLAY LOCATION
ACCH    EQU     LINE1+22        ;ACCUMULATOR HEX DISPLAY LOCATION
ACCB    EQU     LINE1+25        ;ACCUMULATOR BINARY DISPLAY LOCATION
BCH     EQU     LINE1+37        ;B REG HEX DISPLAY LOCATION
BCB     EQU     LINE1+42        ;B REG BINARY DISPLAY LOCATION
DEH     EQU     LINE2+37        ;DE REG PR HEX DISPLAY LOCATION
DEB     EQU     LINE2+42        ;DE REG PR BINARY DISPLAY LOCATION
HLH     EQU     LINE3+37        ;HL REG PR HEX DISPLAY LOCATION
HLB     EQU     LINE3+42        ;HL REG PR BINARY DISPLAY LOCATION
SPH     EQU     LINE4+37        ;SP REG PR HEX DISPLAY LOCATION
KSTAT   EQU     6EH
KEYBRD  EQU     6CH
KBDRDY  EQU     80H
RSTAT	EQU	07H
READER  EQU     06H
RDRRDY  EQU     02H
SWTCHS  EQU     0FFH
CR      EQU     0DH
LF      EQU     0AH
ESC     EQU     1BH
;
;
;STORAGE DEFINITION STATEMENTS
;
        ORG     DYNAT+0B80H   ;SYSTEM WORKING STORAGE AREA
PC1:	DS	2	;USER'S PROGRAM COUNTER STORAGE
STKPTR:	DS	2	;USER'S STACK POINTER STORAGE
BC:     DS      2       ;USER'S BC REG PR STORAGE
DE:     DS      2       ;USER'S DE REG PR STORAGE
HL:     DS      2       ;USER'S HL REG PR STORAGE
STSWRD: DS      1       ;USER'S STATUS FLAG STORAGE
AC:     DS      1       ;USER'S ACCUMULATOR STORAGE
PC:     DS      2       ;USER'S PRIMARY PROGRAM COUNTER STORAGE
BINFLG: DB      0       ;BINARY DISPLAY SWITCH(0=>NO BINARY DISPLAY)
CPOSIT: DS      2       ;CURSER POSITION FOR ROLLUP PORTION OF SCREEN
STKTMP: DS      2       ;TEMPORARY STORAGE FOR SYSTEM STACK
BASE:   DS      2       ;BASE ADDRESS STORAGE FOR VARIOUS ROUTINES
LAST:   DS      2       ;LAST    '       '     '     '       '
FROM:   DB      'FROM-' ;MESSAGES
TO:     DB      'TO-'   ;
ASCII:  DB      '0123456789ABCDEF'      ;ASCII HEX DIGIT TABLE
MOVENM: DB      'MOV  ,  '      ;MOVE MNUMONIC
	DB	'COPYRIGHT (C) 1976, RICHARD E. MEADOR'
;
;CODE BEGINS HERE
;
	ORG	100H
DBYTE	EQU	8000H	;PROGRAM WILL RUN HERE

	LXI	H,0400H	;PROGRAM BASE POINTER
	LXI	D,DBYTE	;NEW BASE POINTER
LOOP	MOV	A,M	;PICK UP 1ST CHAR
	STAX	D	;STORE AT NEW BASE
	INX	H
	INX	D
	MOV	A,H	;MOVE POINTER
	CPI	10H	;
	JNZ	LOOP	;DO UNTIL DONE
	JMP	DBYTE	;GO TO NEW LOCATION
;
;
;
        ORG     DYNAT   ;START ADDRESS
START:  LXI     SP,STACK        ;DEFINE SYSTEM STACK
        CALL    CLRSCR  ;CLEAR VIDEO SCREEN
        CALL    SETSCR  ;SET UP DISPLAY OF USER REGISTERS
        MVI     A,0     ;CLEAR ACCUMULATOR
        MVI     B,14    ;SET CLEAR COUNT
        LXI     H,PC1   ;SET FIRST ADDRESS TO BE CLEARED
VDM010: MOV     M,A     ;CLEAR
        INX     H       ;NEXT ADDRESS
        DCR     B       ;1 LESS TO DO
        JNZ     VDM010  ;DONE?
        LXI     H,PC1        ;YES, DEFINE USER'S STACK POINTER
        SHLD    STKPTR      ;
VDM015: CALL    DSREGS  ;DISPLAY CONTENTS OF USER'S REGISTERS
        CALL    KEYBDI  ;GET COMMAND
        CPI     40H     ;CHECK FOR ALPHA
        JM      VDM020  ;IGNORE IF NOT
        CPI     5BH     ;
        JP      VDM020  ;
        LXI     H,KEYTAB        ;GET COMMAND LOCATOR TABLE BASE ADDRESS
        SBI     40H     ;SUBTRACT ASCII BIAS FROM RECEIVED COMMAND
        RLC             ;DOUBLE FOR WORD INDEXING
        ADD     L       ;ADD INDEX
        MOV     L,A     ;
        MVI     A,0     ;        ADC     H       ;
        MOV     H,A     ;
        MOV     E,M     ;GET COMMAND ADDRESS FROM TABLE
        INX     H       ;
        MOV     D,M     ;
        LXI     H,VDM020        ;SET UP RETURN ADDRESS
        PUSH    H       ;SAVE ON STACK
        XCHG            ;HL=COMMAND ROUTINE ADDRESS
        PCHL            ;(THIS IS REALLY A CALL TO A COMMAND ROUTINE)
VDM020: LXI     H,LINE15        ;RESET CURSOR
        SHLD    CPOSIT  ;
        JMP     VDM015  ;END OF COMMAND PROCESSING LOOP
;
;COMMAND LOCATOR TABLE
;
KEYTAB: DW      UTURN   ;A-NOP
        DW      BINARY  ;B-BINARY DISPLAY TOGGLE
        DW      CALSUB  ;C-CALL USER SUB-PROGRAM
        DW      DUMPME  ;D-DUMP MEMORY TO SCREEN
        DW      UTURN   ;E-NOP
        DW      UTURN   ;F-NOP
        DW      GO      ;G-EXECUTE USER PROGRAM INTERPRETIVELY
        DW      UTURN   ;H-NOP
        DW      ISPEED  ;I-SET EXECUTION SPEED OF INTERPRETER
        DW      UTURN   ;J-NOP
        DW      UTURN   ;K-NOP
        DW      LOADRG  ;L-LOAD REGISTER PAIR
        DW      MEMSTR  ;M-STORE BYTES IN CONSECUTIVE MEMORY LOCATIONS
        DW      UTURN   ;N-NOP
        DW      UTURN   ;O-NOP
        DW      UTURN   ;P-NOP
        DW      UTURN   ;Q-NOP
        DW      READTP  ;R-READ PAPER TAPE
        DW      STEP    ;S-INTERPRET ONE INSTRUCTION
        DW      UTURN   ;T-NOP
        DW      UTURN   ;U-NOP
        DW      UTURN   ;V-NOP
        DW      UTURN   ;W-NOP
        DW      UTURN   ;X-NOP
        DW      UTURN   ;Y-NOP
        DW      ZERMEM  ;Z-ZERO MEMORY
;
;
;
UTURN:  RET             ;DUMMY ROUTINE FOR NOP'S
;
;
;  CLEAR VDM ROUTINE
;
CLRSCR: MVI     A,0     ;CONTROL PORT IINITIALIZATUIION WORD
        OUT     CONPRT  ;SEND
        LXI     B,SCREEN        ;BASE ADDRESS OF VDM BUFFER
CLR010: MVI     A,' '   ;ASCII SPACE
        STAX    B       ;CLEAR 1 BUFFER WORD
        INX     B       ;UPDATE BUFFER POINTER
        MVI     A,TOS AND 0FFH   ;LAST BUFFER ADDRESS +1
        CMP     B       ;CHECK FOR END OF BUFFER AREA
        JNZ     CLR010  ;DO UNTIL DONE
        LXI     H,LINE15        ;INITIAL CURSOR LOCATION
        SHLD    CPOSIT  ;STORE TO CURSOR SAVE
        RET             ;EXIT
;
;  SET DISPLAY OF USER'S REGISTERS
;
SETSCR: LXI     H,'PC'          ;PC
        SHLD    LINE1+5
        MVI     A,'A'           ;A
        STA     LINE1+20
        LXI     H,'BC'          ;BC
        SHLD    LINE1+34
        LXI     H,'IN'          ;IN
        SHLD    LINE2+2
        LXI     H,'ST'          ;ST
        SHLD    LINE2+4
        MVI     A,'R'           ;R
        STA     LINE2+6
        LXI     H,'DE'          ;DE
        SHLD    LINE2+34
        MVI     A,'C'           ;C
        STA     LINE3+15
        MVI     A,'Z'           ;Z
        STA     LINE3+9
        MVI     A,'P'           ;P
        STA     LINE3+13
        MVI     A,'S'           ;S
        STA     LINE3+8
        MVI     A,'A'           ;A
        STA     LINE3+11
        LXI     H,'HL'          ;HL
        SHLD    LINE3+34
        LXI     H,'SP'          ;SP
        SHLD    LINE4+34
        LXI     H,'PS'
        SHLD    LINE4+4
        MVI     A,'W'
        STA     LINE4+6
        MVI     A,'0'
        STA     LINE4+10
        STA     LINE4+12
        INR     A
        STA     LINE4+14
        RET
;
;MOVE THE NUMBER OF BYTES INDICATED IN DE
;FROM THE ADDRESS BEGINNING IN BC
;TO THE ADDRESS BEGINNING IN HL
;
SETLNE: LDAX    B       ;GETBYTE
        MOV     M,A     ;TRANSFER
        INX     H       ;UPDATE DESTINATION POINTER
        INX     B       ;UPDATE SOURCE POINTER
        DCX     D       ;UPDATE COUNT
        MOV     A,E     ;CHECK FOR COMPLETION
        CPI     0       ;
        JNZ     SETLNE  ;
        MOV     A,D     ;
        CPI     0       ;
        JNZ     SETLNE  ;
        RET             ;EXIT
;
; DISPLAY REGISTERS ROUTINE
;
;THIS ROUTINE DECODES THE USER'S REGISTER INFORMATION
;     AND FORMATS IT FOR DISPLAY ON THE CRT SCREEN
;
DSREGS: PUSH    B       ;SAVE ALL REGISTERS
        PUSH    D       ;
        PUSH    H       ;
        PUSH    PSW     ;
        LXI     D,PC1   ;
        LXI     H,PCH+2 ;
        CALL    DSPHEX  ;
        LXI     D,PC1+1 ;
        LXI     H,PCH   ;
        CALL    DSPHEX  ;
        LXI     D,STKPTR    ;
        LXI     H,SPH+2 ;
        CALL    DSPHEX  ;
        LXI     D,STKPTR+1  ;
        LXI     H,SPH   ;
        CALL    DSPHEX  ;
        LXI     D,BC    ;
        LXI     H,BCH+2 ;
        CALL    DSPHEX  ;
        LXI     D,BC+1  ;
        LXI     H,BCH   ;
        CALL    DSPHEX  ;
        LXI     D,DE    ;
        LXI     H,DEH+2 ;
        CALL    DSPHEX  ;
        LXI     D,DE+1  ;
        LXI     H,DEH   ;
        CALL    DSPHEX  ;
        LXI     D,HL    ;
        LXI     H,HLH+2 ;
        CALL    DSPHEX  ;
        LXI     D,HL+1  ;
        LXI     H,HLH   ;
        CALL    DSPHEX  ;
        LXI     D,AC    ;
        LXI     H,ACCH  ;
        CALL    DSPHEX  ;
        LDA     STSWRD  ;
        LXI     H,CYB   ;
        RAR             ;
        MVI     M,'0'   ;
        JNC     DSR010  ;
        MVI     M,'1'   ;
DSR010: RAR             ;
        RAR             ;
        LXI     H,PB    ;
        MVI     M,'0'   ;
        JNC     DSR020  ;
        MVI     M,'1'   ;
DSR020: RAR             ;
        RAR             ;
        LXI     H,ACB   ;
        MVI     M,'0'   ;
        JNC     DSR030  ;
        MVI     M,'1'   ;
DSR030: RAR             ;
        RAR             ;
        LXI     H,ZB    ;
        MVI     M,'0'   ;
        JNC     DSR040  ;
        MVI     M,'1'   ;
DSR040: RAR             ;
        LXI     H,SB    ;
        MVI     M,'0'   ;
        JNC     DSR050  ;
        MVI     M,'1'   ;
DSR050: POP     PSW     ;
        POP     H       ;
        POP     D       ;
        POP     B       ;
        LDA     BINFLG  ;CHECK FOR BINARY DISPLAY FLAG SET
        ANA     A       ;
        RZ              ;DONE IF NOT SET
        PUSH    B       ;
        PUSH    D       ;
        PUSH    H       ;
        PUSH    PSW     ;
        LXI     D,AC    ;
        LXI     H,ACCB  ;
        CALL    DSPBIN  ;
        LXI     D,BC    ;
        LXI     H,BCB+9 ;
        CALL    DSPBIN  ;
        LXI     D,BC+1  ;
        LXI     H,BCB   ;
        CALL    DSPBIN  ;
        LXI     D,DE    ;
        LXI     H,DEB+9 ;
        CALL    DSPBIN  ;
        LXI     D,DE+1  ;
        LXI     H,DEB   ;
        CALL    DSPBIN  ;
        LXI     D,HL    ;
        LXI     H,HLB+9 ;
        CALL    DSPBIN  ;
        LXI     D,HL+1  ;
        LXI     H,HLB   ;
        CALL    DSPBIN  ;
        POP     PSW     ;
        POP     H       ;
        POP     D       ;
        POP     B       ;
        RET             ;
;
; DECODE REGISTERS FOR DISPLAY ROUTINE
;
DSPHEX: LDAX    D       ;GET REGISTER CONTENTS
        RRC             ;SCALE ACCUMULATOR DOWN TO GET UPPER HEX DIGIT
        RRC             ;
        RRC             ;
        RRC             ;
        ANI     0FH     ;MASK OFF UNWANTED BITS
        LXI     B,ASCII ;BASE ADDRESS OF ASCIIDIGIT TABLE
        ADD     C       ;ADD ACCUMULATOR TO BC TO GET ADDRESS OF DIGIT
        MOV     C,A     ;
        MVI     A,0     ;
        ADC     B       ;
        MOV     B,A     ;
        LDAX    B       ;
        MOV     M,A     ;STORE ASCII CODE FOR HEX DIGIT
        INX     H       ;INCREMENT SCREEN POSITION
        LDAX    D       ;GET REGISTER CONTENTS AGAIN
        ANI     0FH     ;DO THE SAME FOR THE LOWER HEX DIGIT
        LXI     B,ASCII ;
        ADD     C       ;
        MOV     C,A     ;
        MVI     A,0     ;
        ADC     B       ;
        MOV     B,A     ;
        LDAX    B       ;
        MOV     M,A     ;
        RET             ;
;
; DECODE REGISTER TO BINARY DISPLAY ROUTINE
;
DSPBIN: LDAX    D       ;GET USER REGISTER CONTENTS
        MVI     C,8     ;# OF BITS
DSP010: RAL             ;SHIFT UPPER BIT TO CARRY FOR CHECKING
        MVI     M,'0'   ;ASSUME ZERO
        JNC     DSP020  ;CHECK FOR ONE
        MVI     M,'1'   ;CHANGE IF ONE
DSP020: INX     H       ;MOVE TO NEXT SCREEN POSITION
        DCR     C       ;COUNT OFF
        JNZ     DSP010  ;DONE?
        RET             ;YES
;
;SIMULATOR CODE BEGINS HERE
;  ONE 8080 INSTRUCTION AS INDICATED BY THE USER'S PC REGISTER
STEP:   LHLD    PC      ;GET USER'S PROGRAM COUNTER VALUE
        SHLD    PC1     ;SAVE FOR LAGGING DISPLAY
        MOV     A,M     ;GET THE CONTENTS OF MEMORY LOCATION INDICATED
        CPI     40H     ;CHECK FOR CODES 0-3F HEX
        JC      STP010  ;LOW ORDER 64 OPCODES?
        CPI     80H     ;NO, CHECK FOR 40-7F HEX
        JNC     STP020  ;IS A REGISTER TO REGISTER MOVE INSTRUCTION?
        CALL    MOVE    ;YES, EXECUTE IT
        RET             ;RETURN TO MONITOR
STP010: CALL    OPLOW   ;LOW ORDER OP CODES
        RET             ;RETURN TO MONITOR
STP020: CPI     0C0H    ;CHECK FOR 80-BF HEX
        JNC     STP030  ;ARTHMETIC INSTRUCTION?
        CALL    ARITH   ;YES, EXECUTE
        RET             ;RETURN TO MONITOR
STP030: CALL    OPHIGH  ;HIGH ORDER OP CODE
        RET             ;RETURN TO MONITOR
;
; EXECUTE INSTRUCTION ROUTINE
;
OPEXEC: LXI     H,0     ;SAVE MONITOR'S STACK POINTER
        DAD     SP
        SHLD    STKTMP
        LHLD    STSWRD  ;LOAD REAL REGISTERS WITH USER'S DATA
        PUSH    H       
        POP     PSW     
        LHLD    STKPTR
        SPHL
        LHLD    BC
        MOV     B,H
        MOV     C,L
        LHLD    DE
        XCHG
        LHLD    HL
INSTR:  DS      3       ;INSTRUCTION TO BE EXECUTED IS STORED HERE
                        ; IF IT WILL NOT CAUSE LOSS OF CONTROL
        SHLD    HL      ;SAVE USER REGISTER VALUES
        PUSH    PSW     ;
        POP     H       ;
        SHLD    STSWRD  ;
        LXI     H,0     ;
        DAD     SP      ;
        SHLD    STKPTR      ;
        XCHG            ;
        SHLD    DE      ;
        LHLD    STKTMP  ;GET MONITOR'S STACK POINTER
        SPHL            ;
        MOV     H,B     ;
        MOV     L,C     ;
        SHLD    BC      ;
        RET             ;
;
; MOV COMMAND EXECUTION ROUTINE
;
MOVE:   MOV     B,A     ;SAVE OP CODE
        ANI     07H     ;DECODE SOURCE REGISTER
        MVI     D,0     ;
        MOV     E,A     ;
        LXI     H,RGSTRS        ;
        DAD     D       ;
        MOV     A,M     ;GET REGISTER NAME
        STA     MOVENM+6   ;SET UP NMEUMONIC
        MOV     A,B     ;RESTORE OP CODE
        RRC             ;
        RRC             ;
        RRC             ;
        ANI     07H     ;DO SAME FOR DESTINATION REGISTER
        MOV     E,A     ;
        LXI     H,RGSTRS        ;
        DAD     D       ;
        MOV     A,M     ;
        STA     MOVENM+4   ;
        MOV     A,B     ;
        MVI     B,1     ;# OF BYTES IN INSTRUCTION
        CALL    MVINST  ;COPY INSTRUCTION INTO EXECUTION AREA
        LXI     H,INSTA ;DISPLAY NMEUMONIC
        LXI     B,MOVENM   ;
        LXI     D,8     ;
        CALL    SETLNE  ;
        CALL    OPEXEC  ;GO EXECUTE INSTRUCTION
        RET             ;DONE,
;
; ARITHMETIC INSTRUCTION EXECUTION ROUTINE
;
ARITH:  MOV     B,A     ;SAVE OP CODE
        LXI     H,ARITHN        ;GET ADDRESS OF ARITH NMEUMONICS
        ANI     38H     ;ISOLATE REGISTER OPERAND
        MVI     D,0     ;
        MOV     E,A     ;
        DAD     D       ;ADD INDEX TO GET APPROPRIATE NMEUMONIC
        PUSH    H       ;SAVE TEMPORARILY
        MOV     A,B     ;RESTORE OPCODE
        ANI     07H     ;ISOLATE REGISTER OPERAND #
        LXI     H,RGSTRS        ;GET REGISTER NAME LIST ADDRESS
        MOV     E,A     ;
        DAD     D       ;ADD INDEX TO GET CORRECT REGISTER NMEUMONIC
        MOV     A,M     ;GET NMEUMONIC
        POP     H       ;RETRIEVE INSTRUCTION NMEUMONIC ADDRESS
	MVI	E,4	;
	DAD	D	;
        MOV     M,A     ;MOVE REGISTER NAME TO MEMORY
        DCX     SP      ;
        DCX     SP      ;
        MOV     A,B     ;RESTORE OP CODE
        MVI     B,1     ;SET # OF BYTES IN OPCODE
        CALL    MVINST  ;MOVE INSTRUCTION TO EXECUTION AREA
        LXI     H,INSTA ;DISPLAY NMEUMONIC
        LXI     D,8     ;
        POP     B       ;
        CALL    SETLNE  ;
        CALL    OPEXEC  ;GO EXECUTE INSTRUCTION
        RET             ;
;
;ARITHMETIC INSTRUCTION NMEUMONICS
;
ARITHN: DB      'ADD     '      ;ADD REGISTER TO ACCUMULATOR
        DB      'ADC     '      ;ADD REGISTER+CARRY TO ACCUMULATOR
        DB      'SUB     '      ;SUB REGISTER FROM ACCUMULATOR
        DB      'SBB     '      ;SUB REGISTER+CARRY FROM ACCUMULATOR
        DB      'ANA     '      ;LOGICAL AND REGISTER WITH ACCUMULATOR
        DB      'XRA     '      ;LOGICAL EXCLUSIVE OR REGISTER WITH ACCU
        DB      'ORA     '      ;LOGICAL OR REGISTER WITH ACCUMULATOR
        DB      'CMP     '      ;COMPARE REGISTER WITH ACCUMULATOR
;
; LOW ORDER INSTRUCTION EXECUTION ROUINE
; OP CODES 0-3F HEX
OPLOW:  MOV     E,A     ;SAVE OP CODE
        ANI     07H     ;DETERMINE CLASS AND BRANCH TO APPRPRIATE ROUTINE
        RLC             ;
        MOV     C,A     ;
        MVI     B,0     ;
        LXI     H,OPTAB ;
        DAD     B       ;
        MOV     A,E     ;
        MOV     E,M     ;
        INX     H       ;
        MOV     D,M     ;
        XCHG            ;
        PCHL            ;
;
;OP CODE SIMULATION ROUTINE LOOKUP TABLE
;
OPTAB:  DW      NPINST     ; NO-OP ROUTINE POINTER
        DW      LXIDAD  ; LXI & DAD ROUTINE POINTER
        DW      LDSTRX  ; LDAX & STAX ROUTIN POINTER
        DW      INXDCX  ;INX & DCX ROUTINE POINTER
        DW      INRDCR  ; INR & DCR ROUTINE POINTER
        DW      INRDCR  ; SAME
        DW      MVIMM     ; MVI ROUTINE POINTER
        DW      ROTATE  ; ROTATE POINTER
;
; A=OP CODE, B= NO. OF BYTES
;
MVINST: STA     INSTR   ;STORE OP CODE TO EXECUTION AREA
        PUSH    B       ;SAVE NUMBER OF BYTES IN OP CODE
        CALL    HEXASC  ;CONVERT OP CODE TO ASCII/HEX EQUIVALANT
        MOV     H,C     ;TRANSFER FOR DOUBLE LENGTH STORE
        MOV     L,B     ;
        SHLD    INSTH   ;STORE ASCII CODES OF OP CODE TO VDM BUFFER
        POP     B       ;RETRIEVE NUMBER OF BYTES IN INSTRUCTION
        LXI     D,INSTR+1       ;GET ADDRESS OF NEXT LOCATION IN EXECUTI
        MVI     A,0     ;ZERO NEXT 2 BYTES IN EXECUTION AREA
        STAX    D       ;    IN CASE INSTRUCTION<3 BYTES
        STA     INSTR+2 ;
        MVI     H,' '   ;CLEAR PREVIOUS EXECUTION FROM SCREEN
        MOV     L,H     ;
        SHLD    INSTH+2 ;
        SHLD    INSTH+4 ;
        LXI     H,INSTH+2       ;SET TO DISPLAY REST OF INSTRUCTION IF A
        SHLD    STKTMP  ;SAVE VDM BUFFER LOCATION OF ASCII/HEX DISPLAY A
        LHLD    PC      ;GET USER'S PROGRAM COUNTER
        INX     H       ;UPDATE IT
MVI010: DCR     B       ;COUNT OFF NUMBER OF BYTES IN INSTRUCTION
        JZ      MVI020  ;EXIT IF DONE
        MOV     A,M     ;GET NEXT BYTE OF INSTRUCTION FROM USER'S PROGRA
        INX     H       ;UPDATE USER'S PROGRAM COUNTER
        STAX    D       ;STORE BYTE TO EXECUTION AREA
        INX     D       ;UPDATE EXECUTION BUFFER POINTER
        PUSH    B       ;SAVE NUMBER OF BYTES IN INSTRUCTION
        PUSH    D       ;SAVE EXECUTION BUFFER POINTER
        PUSH    H       ;SAVE USER'S PROGRAM COUNTER
        CALL    HEXASC  ;CONVERT NEXT BYTE OF INSTRUCTION TO ASCII/HEX C
        LHLD    STKTMP  ;RETRIEVE VDM BUFFER LOCATIN OF ASCII/HEX DISPLA
        MOV     M,B     ;MOVE ASCII/HEX CODES OF CURRENT INSTRUCTION BYT
        INX     H       ;   TO VDM BUFFER AREA
        MOV     M,C     ;
        INX     H       ;
        SHLD    STKTMP  ;SAVE VDM BUFFER LOCATION AGAIN
        POP     H       ;RETRIEVE USER'S PROGRAM COUNTER
        POP     D       ;RETRIEVE EXECUTION BUFFER POINTER
        POP     B       ;RETRIEVE NUMBER OF BYTES LEFT IN INSTRUCTION
        JMP     MVI010  ;CONTINUE UNTIL ALL BYTES MOVED
MVI020: SHLD    PC      ;STORE UPDATED USER'S PROGRAM COUNTER
        RET             ;EXIT
;
;
; MOVE NMUMONIC TO BUFFER
;
MVNMNC: LXI     H,INSTA ;GET VDM BUFFER LOCATION OF MNEUMONIC DISPLAY AR
        PUSH    D       ;SAVE D REGISTER
        LXI     D,4     ;SET NUMBER OF BYTES TO TRANSFER
        CALL    SETLNE  ;DO TRANSFER
        POP     B       ;GET OLD D REGISTER
        MVI     D,' '   ;THE FOLLOWING CODE MOVES THE ASCII CHARACTERS O
        MOV     M,D     ;   THE REGISTERS USED BY THE INSTRUCTION TO THE
        INX     H       ;       THE VDM BUFFER AREA
        MOV     M,C     ;
        INX     H       ;
        MOV     M,B     ;
        INX     H       ;
        MOV     M,D     ;
        RET             ;
;
; GET REGISTER PAIR ROUTINE
;
GETRP:  ANI     30H     ;MASK REGISTER PAIR FIELD
        RRC             ;SCALE FOR INDEXING
        RRC             ;
        RRC             ;
        MOV     E,A     ;BUILD INDEX IN DE
        MVI     D,0     ;
        LXI     H,REGPAR        ;GET BASE ADDRESS OF REG PAIR MNEUMONICS
        DAD     D       ;ADD INDEX
        SHLD    GET010+1        ;SAVE POINTER
GET010: LHLD    0       ;0 IS REPLACED BY POINTER FROM ABOVE
        XCHG            ;POSITION FOR SUB ROUTINE CALL
        CALL    MVNMNC  ;DISPLAY OP CODE
        RET             ;
;
; EXECUTE NO-OP ROUTINE
;
NPINST:    MVI     B,1     ;SET INSTRUCTION LENGTH
        CALL    MVINST  ;MOVE INSTRUCTION TO EXECUTION AREA
        LXI     D,'  '  ;NO REGISTER DATA
        LXI     B,LOWOP ;ADDRESS OF NOP MNEUMONIC
        CALL    MVNMNC  ;DISPLAY OP CODE
        CALL    OPEXEC  ;EXECUTE INSTRUCTION
        RET             ;
;
;  EXECUTE LXI AND DAD INSTRUCTIONS ROUTINE
;
LXIDAD:	MOV	B,A	;SAVE INSTRUCTION
        ANI     08H     ;ISOLATE LXI/DAD BIT
        MOV     A,B     ;RESTORE INSTRUCTION
        MVI     B,1     ;ASSUME DAD INSTRUCTION
        JNZ     LXI010  ;DAD OR LXI?
	MVI	B,3	;LXI, CHANGE INSTRUCTION LENGTH TO 3 BYTES
LXI010: PUSH    PSW     ;SAVE INSTRUCTION DESIGNATOR WHICH IS THE ZERO F
        CALL    MVINST  ;DISPLAY OP CODE
        POP     PSW     ;RETRIEVE FLAG
        LXI     B,LOWOP1+4      ;ASSUME DAD
        JNZ     LXI020  ;DAD/LXI?
	LXI	B,LOWOP1	;LXI, CHANGE POINTER
LXI020: CALL    GETRP   ;ISOLATE REG PAIR
        CALL    OPEXEC  ;EXECUTE INSTRUCTION
        RET             ;
;
; LDA STA LDAX STAX SHLD LHLD  EXECUTION ROUTINE
;
LDSTRX: MOV     C,A     ;SAVE INSTRUCTION
        ANI     20H     ;ISOLATE (LDX,STX)/(LHLD,SHLD,LDA,STA) BIT
        MOV     A,C     ;RESTORE INSTRUCTION
        JNZ     LDS020  ;(LDX,STX)/(LHLD,SHLD,LDA,STA)?
        ANI     08H     ;ISOLATE LDX/STX BIT
        MOV     A,C     ;RESTORE INSTRUCTION
        MVI     B,1     ;INSTRUCTION LENGTH IS 1 FOR BOTH
        PUSH    PSW     ;SAVE DESIGNATOR BIT
        CALL    MVINST  ;MOVE INSTRUCTION TO EXECUTION AREA
        POP     PSW     ;RETRIEVE DESIGNATOR BIT
        LXI     B,LOWOP2        ;ASSUME STAX
        JZ      LDS010  ;STAX/LDAX?
	LXI	B,LOWOP2+4	;LDAX, CHANGE MNEUMONIC POINTER
LDS010: CALL    GETRP   ;DETERMINE REGISTER PAIR
        JMP     LDS030  ;GO EXECUTE
LDS020:	MVI	B,3	;(LHLD,SHLD,LDA,STA), SET LENGTH TO 3 BYTES
        CALL    MVINST  ;MOVE INSTRUCTION TO EXECUTION AREA
        MOV     A,C     ;RESTORE INSTRUCTION
        ANI     18H     ;ISOLATE INSTRUCTION DESIGNATOR
        RRC             ;SCALE FOR INDEXING
        MOV     E,A     ;BUILD INDEX
        MVI     D,0     ;
        LXI     H,LOWOP2+8      ;GET BASE ADDRESS OF INSTRUCTION GROUP
        DAD     D       ;ADD INDEX
        MOV     B,H     ;POSITION FOR CALL
        MOV     C,L     ;
        LXI     D,'  '  ;SET REG TYPE TO NULL
        CALL    MVNMNC  ;DISPLAY CODE
LDS030: CALL    OPEXEC  ;EXECUTE INSTRUCTION
        RET             ;
;
; INX DCX EXECUTION ROUTINE
;
INXDCX: MOV     C,A     ;SAVE INSTRUCTION
        MVI     B,1     ;THESE ARE ALL ONE BYTE
        CALL    MVINST  ;MOVE INSTRUCTION TO EXECUTION AREA
        MOV     A,C     ;RESTORE INSTRUCTION
        PUSH    PSW     ;SAVE IT AGAIN
        ANI     08H     ;ISOLATE DESIGNATOR BIT
        LXI     B,LOWOP3        ;ASSUME INX
        JZ      INX010  ;INX/DCX?
	LXI	B,LOWOP3+4	;DCX, CHAINGE POINTER
INX010: POP     PSW     ;GET INSTRUCTION BACK
        CALL    GETRP   ;DETERMINE REG PAIR
        CALL    OPEXEC  ;EXECUTE INSTRUCTION
        RET             ;
;
; INR DCR EXECUTION ROUTINE
;
INRDCR: MOV     C,A     ;SAVE INSTRUCTION
        MVI     B,1     ;THESE ARE ALL ONE BYTE
        CALL    MVINST  ;MOVE INSTRUCTION TO EXECUTION AREA
        MOV     A,C     ;RESTORE INSTRUCTION
        STA     STKTMP  ;SAVE IT AGAIN
        LXI     B,LOWOP4        ;ASSUME INR
        ANI     01H     ;CHECK DESIGNATOR BIT
        JZ      INR010  ;INR/DCR?
	LXI	B,LOWOP5	;DCR, CHANGE POINTER
INR010: LDA     STKTMP  ;GET INSTRUCTION BACK
        CALL    GETREG  ;DETERMINE REGISTER
        CALL    OPEXEC  ;EXECUTE INSTRUCTION
        RET             ;
;
; MVI EXECUTION ROUTINE
;
MVIMM:    MOV     C,A     ;SAVE INSTRUCTION
        MVI     B,2     ;THESE ARE ALL 2 BYTE INSTRUCTIONS
        CALL    MVINST  ;MOVE INSTRUCTION TO EXECUTION AREA
        MOV     A,C     ;RESTORE INSTRUCTION
        LXI     B,LOWOP6        ;SET POINTER MVI MNEUMONIC
        CALL    GETREG  ;DETERMINE REGISTER
        CALL    OPEXEC  ;EXECUTE INSTRUCTION
        RET             ;
;
; RLC RRC RAL RAR DAA CMA STC CMC
; EXECUTION ROUTINE
;
ROTATE: MOV     C,A     ;SAVE INSTRUCTION
        MVI     B,1     ;THESE ARE ALL ONE BYTE INSTRUCTIONS
        CALL    MVINST  ;MOVE INSTRUCTION TO EXECUTION AREA
        MOV     A,C     ;RESTORE INSTRUCTION
        ANI     38H     ;ISOLATE DESIGNATOR BITS
        RRC             ;SCALE FOR INDEXING
        MOV     E,A     ;CONSTRUCT INDEX
        MVI     D,0     ;
        LXI     H,LOWOP7        ;GET BASE OF ADDRESS OF MNEUMONICS
        DAD     D       ;ADD INDEX
        MOV     C,L     ;POSITION ADDRESS FOR SUBROUTINE CALL
        MOV     B,H     ;
        LXI     D,'  '  ;SET REGISTER TO NULL
        CALL    MVNMNC  ;DISPLAY OP CODE
        CALL    OPEXEC  ;EXECUTE INSTRUCTION
        RET             ;
;
; GET REGISTER ROUTINE
;
GETREG: ANI     38H     ;ISOLATE REGISTER DESIGNATOR BITS
        RRC             ;SCALE FOR INDEXING
        RRC             ;
        RRC             ;
        MOV     E,A     ;CONSTRUCT INDEX WORD
        MVI     D,0     ;
        LXI     H,RGSTRS        ;GET BASE ADDRESS OF REGISTER CODES
        DAD     D       ;ADD INDEX
        MVI     E,' '   ;OTHER REGISTER IS NULL
        MOV     D,M     ;GET THIS REGISTER
        CALL    MVNMNC  ;DISPLAY OP CODE AND REGISTER
        RET             ;
LOWOP:  DB      'NOP '  ;NO-OP
LOWOP1: DB      'LXI '  ;LOAD REGISTER PAIR IMMEDIATE(EXTENDED)
        DB      'DAD '  ;DOUBLE LENGTH ADD
LOWOP2: DB      'STAX'  ;STORE ACCUMULATOR INDIRECT THROUGH REG PAIR
        DB      'LDAX'  ;LOAD ACCUMULATOR INDIRECT THROUGH REG PAIR
        DB      'SHLD'  ;STORE HL DIRECT
        DB      'LHLD'  ;LOAD HL DIRECT
        DB      'STA '  ;STORE ACCUMULATOR DIRECT
        DB      'LDA '  ;LOAD ACCUMULATOR DIRECT
LOWOP3: DB      'INX '  ;INCREMENT REGISTER PAIR
        DB      'DCX '  ;DECREMENT REGISTER PAIR
LOWOP4: DB      'INR '  ;INCREMENT REGISTER
LOWOP5: DB      'DCR '  ;DECREMENT REGISTER
LOWOP6: DB      'MVI '  ;MOVE DATA IMMEDIATE TO REGISTER
LOWOP7: DB      'RLC '  ;ROTATE LEFT THROUGH CARRY
        DB      'RRC '  ;ROTATE RIGHT THROUGH CARRY
        DB      'RAL '  ;ROTATE ARITHMETIC LEFT
        DB      'RAR '  ;ROTATE ARITHMETIC RIGHT
        DB      'DAA '  ;DECIMAL ADJUST ACCUMULATOR
        DB      'CMA '  ;COMPLIMENT ACCUMULATOR
        DB      'STC '  ;SET CARRY
        DB      'CMC '  ;COMPLIMENT CARRY
RGSTRS: DB      'BCDEHLMA'      ;REGISTER CODES
REGPAR: DB      'B D H SP'      ;REGISTER PAIR CODES
FLAGS:  DB      'NZZ NCC POPEP M '      ;STATUS FLAG CODES
;
;
;
KEYBDI: PUSH    H       ;SAVE HL
        LHLD    CPOSIT  ;GET CURSOE POSITION
KEY005: IN      KSTAT  ;CHECK 3P+S STATUS
        ANI     KBDRDY  ;LOOK FOR KEY BOARD READY
        JNZ     KEY005  ;LOOP ON NO DATA AVAILABLE
        IN      KEYBRD  ;GET DATA FROM ASCII KEYBOARD
        ANI     7FH     ;STRIP OFF PARITY BIT
        MOV     B,A     ;SAVE CHARACTER
        CPI     ESC     ;CHECK FOR ESCAPE SEQUENCE
        JNZ     KEY007  ;WAS IT?
	LXI	SP,STACK	;YES, RESET STACK POINTER
        CALL    BMPLNE  ;SCROLL UP ONE LINE
        JMP     VDM015  ;RESUME SCAN LOOP
KEY007: CPI     CR      ;CHECK FOR CARRIAGE RETURN
        JZ      KEY020  ;WAS IT
KEY010:	MOV	M,A	;NO, DISPLAY CHARACTER
        INX     H       ;UPDATE CURSER
        MOV     A,H     ;CHECK FOR VDM BUFFER OVERFLOW
        CPI     TOS AND 0FFH     ;
        JC      KEY030  ;
KEY020: CALL    BMPLNE  ;SCROLL UP ON BUFFER FULL
        LXI     H,LINE15        ;RESET CURSOR TO BEGINNING OF LAST LINE
KEY030: MOV     A,B     ;RESTORE CHARATER RECEIVED FROM KEYBOARD
        SHLD    CPOSIT  ;STORE UPDATED CURSOR
        POP     H       ;RESTORE ORIGINAL CONTENTS OF HL
        RET             ;
;
;
;
BMPLNE: PUSH    H       ;SAVE HL
        PUSH    D       ;SAVE DE
        PUSH    B       ;SAVE BC
        PUSH    PSW     ;SAVE PSW
        LXI     H,MIDSCR        ;BUFFER ADDRESS TO MOVE OLD DATA TO
        LXI     B,MIDSCR+LINE   ;BUFFER ADDRESS TO GET OLD DATA FROM
        MVI     E,8     ;NUMBER OF LINES TO BE SCROLLED
BMP010: PUSH    D       ;SAVE
        LXI     D,64    ;NUMBER OF CHARACTERS PER LINE
        CALL    SETLNE  ;SCROLL ONE LINE AT A TIME FROM THE TOP DOWN
        POP     D       ;GET NUMBER OF LINES LEFT TO GO
        DCR     E       ;COUNT OFF ONE MORE
        JNZ     BMP010  ;DO UNTIL DONE
        MVI     A,' '   ;STE TO SPACE OUT LAST LINE
        MVI     D,64    ;BLANK OUT ALL CHARACTERS ON LAST LINE
        LXI     H,LINE15        ;GET ADDRESS OF FIRST CHARACTER OF LAST 
BMP020: MOV     M,A     ;BLANK IT OUT
        INX     H       ;UPDATE POINTER
        DCR     D       ;COUNT DOWN
        JNZ     BMP020  ;DO WHILE NOT DONE
        LXI     H,LINE15        ;RESET CURSOR
        SHLD    CPOSIT  ;
        POP     PSW     ;RESTORE ORIGINAL REGISTER CONTENTS
        POP     B       ;
        POP     D       ;
        POP     H       ;
        RET             ;
;
;
;
BINARY: LDA     BINFLG  ;GET BINARY DISPLAY FLAG
        CMA             ;TOGGLE IT
        STA     BINFLG  ;PUT IT BACK
        CALL    CLRSCR  ;RESET SCREEN
        CALL    SETSCR  ;
        RET             ;
;
;
;
GTLMTS: CALL    BMPLNE  ;SCROLL UP
        LXI     B,FROM  ;DISPLAY FROM MESSAGE
        LXI     H,LINE15        ;
        LXI     D,5     ;
        CALL    SETLNE  ;
        LXI     H,LINE15+5      ;
        SHLD    CPOSIT  ;
        CALL    GETADR  ;GET ONE HEX NUMBER OF UP TO 4 DIGITS
        SHLD    BASE    ;THAT WAS THE BASE ADDRESS
        CALL    BMPLNE  ;SCROLL UP
        LXI     B,TO    ;DISPLAY TO MESSAGE
        LXI     H,LINE15        ;
        LXI     D,3     ;
        CALL    SETLNE  ;
        LXI     H,LINE15+3      ;
        SHLD    CPOSIT  ;
        CALL    GETADR  ;GET ONE HEX NUMBER
        XCHG            ;MOVE TO DE
        LHLD    BASE    ;GET BASE ADDRESS
        CALL    BMPLNE  ;SCROLL UP
        RET             ;
;
;
;
DUMPME: CALL    GTLMTS  ;GET DUMP LIMITS
DMP010: PUSH    D       ;SAVE LAST ADDRESS
        CALL    DMEM16  ;DISPLAY 16 BYTES
        POP     D       ;GET LAST ADDRESS
        MOV     A,E     ;SEE IF LAST ADDRESS EXCEEDED
        SUB     L       ;
        MOV     A,D     ;
        SBB     H       ;
        JP      DMP010  ;CONTINUE DUMPING IF NOT
        RET             ;
;
;
;
GETBYT: MVI     E,2     ;GET TWO CHARACTERS FROM KEY BOARD
	JMP	GTA005	;GO AROUND NEXT ENTRY POINT
GETADR:	MVI	E,4	;GET 4 CHARACTERSFROM KEYBOARD
GTA005:	LXI	H,0	;START WITH ZERO
GTA010:	CALL	KEYBDI	;GET ACHARACTER FROM THE KEYBOARD
        CPI     CR      ;CHECK FOR TERMINATOR
        JZ      GTA020  ;EXIT ON END OF NUMBER
        CALL    ASCHEX  ;CONVERT CHARACTER TO HEX DIGIT
        MOV     C,A     ;POISITION FOR ADD
        MVI     B,0     ;
        DAD     H       ;MULTIPLY HL BY 16
        DAD     H       ;
        DAD     H       ;
        DAD     H       ;
        DAD     B       ;ADD LAST CHARACTER RECIEVED
        DCR     E       ;COUNT OFF NUMBER OF DIGITS
        JNZ     GTA010  ;DO UNTIL COUNT EXAUSTED OR CARRIAGE RETURN
GTA020: RET             ;
;
;
;
ASCHEX: SBI     '0'     ;SUBTRACT OFF ASCII BIAS
        JM      ASC010  ;CHAR<0?
        CPI     10      ;NO,
        RC              ;DONE IF CHAR<=9
        SBI     07H     ;ADJUST FOR ALPHA BIAS
        CPI     LF      ;
        JC      ASC010  ;
        CPI     10H     ;CHAR>0FH?
        RC              ;NO, RETURN
ASC010: MVI     A,0     ;RETURN ZERO IF ILLEAGLE
        RET             ;
;
;DUMP 16 BYTES TO TTY
;
DMEM16: MOV     A,L     ;DISPLAY ADDRESS
        CALL    HEXASC  ;
        PUSH    B       ;
        MOV     A,H     ;
        CALL    HEXASC  ;
        LXI     D,LINE15        ;
        XCHG            ;
        MOV     M,B     ;
        INX     H       ;
        MOV     M,C     ;
        INX     H       ;
        POP     B       ;
        MOV     M,B     ;
        INX     H       ;
        MOV     M,C     ;
        MVI     B,16    ;NUMBER OF BYTES TO DISPLAY
DME010: PUSH    B       ;SAVE
        INX     H       ;UPDATE ADDRESS
        LDAX    D       ;GET BYTE FROM MEMORY
        INX     D       ;UPDATE POINTER
        CALL    HEXASC  ;CONVERT TO ASCII CHARACTERS AND DISPLAY
        INX     H       ;
        MOV     M,B     ;
        INX     H       ;
        MOV     M,C     ;
        POP     B       ;
        DCR     B       ;
        JNZ     DME010  ;DO UNTIL ALL 16 DISPLAYED
        CALL    BMPLNE  ;SCROLL UP
        XCHG            ;
        RET             ;
;
;CONVERT BYTE IN ACCUMULATOR TO ASCII DIGITS
;
HEXASC: PUSH    D       ;SAVE DE
        PUSH    H       ;SAVE HL
        LXI     H,ASCII ;GET BASE ADDRESS OF ASCII CODE
        MOV     B,A     ;SAVE DATA
        ANI     0FH     ;DO LOWER HEX DIGIT FIRST
        MOV     E,A     ;SET UP FOR INDEXING
        MVI     D,0     ;
        DAD     D       ;ADD INDEX
        MOV     C,M     ;GET CHARACTER
        MOV     A,B     ;RESTORE DATA
        ANI     0F0H    ;DO UPPER HEX DIGIT
        RRC             ;SCALE DOWN FOR INDEXING
        RRC             ;
        RRC             ;
        RRC             ;
        MOV     E,A     ;SET UP FOR INDEXING
        LXI     H,ASCII ;GET BASE ADDRESS OF ASCII CODES AGAIN
        DAD     D       ;ADD INDEX
        MOV     B,M     ;GET CHARACTER
        POP     H       ;RESTORE HL
        POP     D       ;RESTORE DE
        RET             ;
;
;LOAD REGISTERS FROM KEYBOARD ROUTINE
;
LOADRG: CALL    KEYBDI  ;GET REGISTER IDENTIFIER
        LXI     H,LDREGS        ;DETERMINE SELECTED REGISTER
        MVI     D,6     ;6 POSSIBLE REGISTER PAIRS
        MOV     B,A     ;SAVE REGISTER DESIGNATOR
LOA010: MOV     A,M     ;GET ONE FROM MEMORY
        CMP     B       ;CHECK AGAINST SELECTED REGISTER PAIR
        JZ      LOA020  ;MATCH
        INX     H       ;NO, KEEP LOOKING
        DCR     D       ;
        JNZ     LOA010  ;
        RET             ;RETURN IF NOT FOUND
LOA020: MOV     A,D     ;GET INDEX NUMBER
        DCR     A       ;ADJUST
        RLC             ;SCALE
        MOV     E,A     ;SET UP INDEX
        MVI     D,0     ;
        PUSH    D       ;SAVE INDEX
        CALL    GETADR  ;GET A HEX NUMBER FROM KEYBOARD
        XCHG            ;RELOCATE NUMBER TO LESS CONVENIENT REGISTER
        POP     H       ;GET INDEX BACK
        MOV     A,L     ;MOVE TO ACCUMULATOR
        ANA     A       ;SET FLAGS
        JNZ     LOA030  ;IS IT THE PC REGISTER?
        PUSH    H       ;YES,
        LXI     B,PC    ;GET ADDRESS OF USER'S PC REG
        DAD     B       ;THIS IS REDUNDANT
        MOV     M,E     ;STORE DATA TO USER'S PC REGISTER
        INX     H       ;
        MOV     M,D     ;
        POP     H       ;
LOA030: LXI     B,PC1   ;STORE DATE TO USER REGISTER
        DAD     B       ;
        MOV     M,E     ;
        INX     H       ;
        MOV     M,D     ;
        CALL    BMPLNE  ;
        RET             ;
LDREGS: DB      'AHDBSP'        ;POSSIBLE REGISTER DESIGNATIONS
;
;STORE DATA TO MEMORY ROUTINE
;
MEMSTR: CALL    GETADR  ;GET BEGINNING ADDRESS
MEM010: PUSH    H       ;SAVE IT
        LHLD    CPOSIT  ;GET CURSOR POSITION
        MVI     A,'-'   ;DISPLAY PROMPT
        MOV     M,A     ;
        INX     H       ;UPDATE CURSOR
        SHLD    CPOSIT  ;RESTORE UPDATED CURSOR
        CALL    GETBYT  ;GET A DATA BYTE
        MOV     A,E     ;GET NUMBER OF BYTES RECIEVED
        CPI     2       ;CHECK FOR NONE RECIEVED
        JNZ     MEM020  ;ANY DATA RECIEVED?
        POP     H       ;NO, RESTORE HL
        RET             ;GET OUT OF HERE
MEM020: MOV     A,L     ;MOVE DATA BYTE TO ACCUMULATOR
        POP     H       ;GET ADDRESS BACK
        MOV     M,A     ;STORE DATA TO MEMORY
        INX     H       ;UPDATE ADDRESS
        JMP     MEM010  ;CONTINUE
;
;CALL USER SUBROUTINE
;
CALSUB: LHLD    CPOSIT  ;GET CURSOE POSITION
        MVI     A,'-'   ;DISPLAY PROMPT
        MOV     M,A     ;
        INX     H       ;UPDATE CURSOR POSITION
        SHLD    CPOSIT  ;RESTORE CURSOR
        MVI     A,0CDH  ;LOAD ACCUMULATOR WITH A CALL INSTRUCTION
        STA     INSTR   ;MOVE TO EXECUTION AREA
        CALL    GETADR  ;GET ADDRESS OF SUBROUTINE TO BE EXECUTED
        SHLD    INSTR+1 ;STORE ADDRESS TO EXECUTION AREA PLUS ONE
        CALL    BMPLNE  ;SCROLL UP
        CALL    OPEXEC  ;EXECUTE SUBROUTINE
        CALL    CLRSCR  ;CLEAR ANY GARBAGE FROM SCREEN
        CALL    SETSCR  ;SET UPSCREEN AGAIN
        RET             ;
;
;HIGH ORDER INSTRUCTION DECODE ROUTINE
;
OPHIGH: MOV     E,A     ;SAVE INSTRUCTION
        ANI     07H     ;DETERMINE SUB CLASS
        RLC             ;SCALE FOR INDEX
        MOV     C,A     ;POSITION FOR INDEXING
        MVI     B,0     ;
        LXI     H,HOPTAB        ;GET HIGH ORDER INSTRUCTION TABLE BASE A
        DAD     B       ;ADD INDEX
        MOV     A,E     ;RESTORE INSTRUCTION
        MOV     E,M     ;GET ADDRESS OF INSTRUCTION ROUTINE
        INX     H       ;
        MOV     D,M     ;
        XCHG            ;MOVE TO HL
        PCHL            ;PASS CONTROL TO APPROPIATE ROUTINE
;
HOPTAB: DW      RETURN  ;RETURN
        DW      PPINST     ;POP
        DW      JUMP    ;JUMP
        DW      MISC    ;MISC
        DW      CLINST    ;CALL
        DW      PSINST    ;PUSH
        DW      IMMEDT  ;IMMEDIATE
        DW      RESTRT  ;RESTART
;
HIGHOP: DB      'R   '  ;CONDITIONAL RETURN
HIHOP1: DB      'POP '  ;POP
        DB      'RET '  ;UNCONDITIONAL ROUTINE
        DB      '*NOP'  ;UNIMPLEMENTED OP CODES
        DB      'PCHL'  ;INDIRECT JUMP
        DB      'SPHL'  ;LOAD STACK POINTER WITH HL
HIHOP2: DB      'J   '  ;CONDITIONAL JUMP
HIHOP3: DB      'JMP '  ;UNCONDITIONAL JUMP
        DB      '*NOP'  ;UNIMPLEMENTED OP CODE
        DB      'OUT '  ;OUTPUT
        DB      'IN  '  ;INPUT
        DB      'XTHL'  ;EXCHANGE HL AND TOP OF STACK
        DB      'XCHG'  ;EXCHANGE HL AND DE
        DB      'DI  '  ;DISABLE INTERRUPTS
        DB      'EI  '  ;ENABLE INTERRUPTS
HIHOP4: DB      'C   '  ;CONDITIONAL CALL
HIHOP5: DB      'PUSH'  ;PUSH
        DB      'CALL'  ;UNCONDITIONAL CALL
        DB      '*NOP'  ;UNIMPLEMENTED OP CODE
HIHOP6: DB      'ADI '  ;ADD IMMEDIATE
        DB      'ACI '  ;ADD IMMEDIATE WITH CARRY
        DB      'SUI '  ;SUBTRACT IMMEDIATE
        DB      'SBI '  ;SUBTRACT IMMEDIATE WITH BORROW
        DB      'ANI '  ;AND IMMEDIATE
        DB      'XRI '  ;EXCLUSIVE OR IMMEDIATE
        DB      'ORI '  ;OR IMMEDIATE
        DB      'CPI '  ;COMPARE IMMEDIATE
HIHOP7: DB      'RST '  ;RESTART
;
;DETERMINE CONDITIONAL FLAG ROUTINE
;
GTFLAG: ANI     38H     ;ISOLATE CONDITION BITS
        PUSH    H       ;SAVE HL
        RRC             ;SCALE FOR INDEXING
        RRC             ;
        MVI     D,0     ;
        MOV     E,A     ;CONSTRUCT INDEX
        LXI     H,FLAGS ;GET BASE ADDRESS OF FLAG CODES
        DAD     D       ;ADD INDEX
        MOV     A,M     ;GET FLAG CODE
        STAX    B       ;STORE TO VDM BUFFER
        INX     B       ;UPDATE POINTER
        INX     H       ;UPDATE FLAG LOCATOR
        MOV     A,M     ;GET SECOND CHARACTER OF FLAG
        STAX    B       ;DISPLAY IT
        LXI     D,'  '  ;OTHER CHARACTERS ARE BLANK
        POP     B       ;GET OLD HL
        CALL    MVNMNC  ;DISPLAY OP CODE
        RET             ;
;
;TEST FLAG FOR CONDITION
;
TSTFLG: ANI     38H     ;ISOLATE FLAG
        ORI     0C0H    ;ASSEMBLE A RETURN ON CONDITION INSTRUCTION
        STA     TST010  ;STORE FOR LATER EXECUTION
        LHLD    STSWRD  ;GET USER STATUS WORD
        PUSH    H       ;MOVE TO REAL FLAGS
        POP     PSW     ;
        MVI     A,1     ;A=1 MEANS CONDITION TRUE
TST010: RET             ;THIS IS REPLACED BY A CONDITIONAL RETURN
        MVI     A,0     ;CLEAR A IF CONDITION FALSE
        RET             ;
;
;CONDITIONAL JUMPS
;
JUMP:   LHLD    PC      ;GET USER PROGRAM COUNTER
        PUSH    H       ;SAVE IT
        PUSH    PSW     ;SAVE PSW
        MVI     B,3     ;THIS IS 3 BYTES
        CALL    MVINST  ;MOVE INSTRUCTION TO EXECUTION AREA
        POP     PSW     ;GET PSW BACK
        PUSH    PSW     ;SAVE IT AGAIN
        LXI     H,HIHOP2        ;ADDRESS OF MNEUMONIC
        LXI     B,HIHOP2+1      ;ADDRESS TO PUT FLAG INTO
        CALL    GTFLAG          ;WHAT CONDITION?
        POP     PSW             ;GET INSTRUCTION BACK
        CALL    TSTFLG          ;TEST CONDITION
        POP     H               ;GET PC AGAIN
        ANA     A               ;CHECK RESULT OF FLAG TEST
        RZ              ;RETURN IF RESULT WAS NEGATIVE
        INX     H       ;UPDATE PC
        MOV     A,M     ;GET ADDRESS TO JUMP TO
        STA     PC      ;AND STORE TO USER'S PROGRAM COUNTER
        INX     H       ;
        MOV     A,M     ;
        STA     PC+1    ;
        RET             ;
;
;THIS ROUTINE PROCESSES ALL IMMEDIATE MODE COMMANDS
;
IMMEDT: MOV     C,A     ;SAVE INSTRUCTION
        MVI     B,2     ;ALL ARE 2 BYTES
        CALL    MVINST  ;MOVE INSTRUCTION TO EXECUTION AREA
        MOV     A,C     ;RSTORE INSTRUCTION
        ANI     38H     ;DETERMINE TYPE OF IMMEDIATE INSTRUCTION
        RRC             ;SCALE FOR INDEXING
        MOV     E,A     ;POSITION FOR INDEXING
        MVI     D,0     ;
        LXI     H,HIHOP6        ;GET BASE ADDRESS OF IMMEDIATE CODES
        DAD     D       ;ADD INDEX
        MOV     B,H     ;POSITION FOR SUBROUTINE CALL
        MOV     C,L     ;
        LXI     D,'  '  ;OTHER CHARACTERS ARE BLANK
        CALL    MVNMNC  ;DISPLAY MNEUMONIC
        CALL    OPEXEC  ;EXECUTE INSTRUCTION
        RET             ;
;
;MISCELANEOUS INSTRUCTIONS
;
MISC:   PUSH    PSW     ;SAVE INSTRUCTION
        ANI     38H     ;DETERMINE TYPE
        RRC             ;
        MOV     E,A     ;
        MVI     D,0     ;
        LXI     H,HIHOP3        ;
        DAD     D       
        MOV     C,L     ;
        MOV     B,H     ;
        LXI     D,'  '  ;
        CALL    MVNMNC  ;DISPLAY CODE
        POP     PSW     ;GET INSTRUCTION
        CPI     0E3H    ;
        JNC     XSDE    ;
        CPI     0D3H    ;
        JNC     IO      ;
        CPI     0CBH    ;
        JNC     NOOP    ;
        MVI     B,3     ;
        CALL    MVINST  ;
        LHLD    PC      ;
        DCX     H       ;
        MOV     A,M     ;
        STA     PC+1    ;
        DCX     H       ;
        MOV     A,M     ;
        STA     PC      ;
        RET             ;
NOOP:   LXI     B,HIHOP5+8      ;
        LXI     D,'  '  ;
        CALL    MVNMNC  ;
        MVI     B,1     ;
        CALL    MVINST  ;
        RET             ;
IO:     MVI     B,2     ;
        CALL    MVINST  ;
        CALL    OPEXEC  ;
        RET             ;
XSDE:   MVI     B,1     ;
        CALL    MVINST  ;
        CALL    OPEXEC  ;
        RET             ;
;
;CONDITIONAL CALL ROUTINE
;
CLINST: PUSH    PSW     ;
        MVI     B,3     ;
        CALL    MVINST  ;
        POP     PSW     ;
        PUSH    PSW     ;
        LXI     H,HIHOP4        ;
        LXI     B,HIHOP4+1      ;
        CALL    GTFLAG  ;
        POP     PSW     ;
        CALL    TSTFLG  ;
        ANA     A       ;
        RZ              
CAL010: LHLD    PC      ;
        XCHG            ;
        LHLD    STKPTR      ;
        DCX     H       ;
        MOV     M,D     ;
        DCX     H       ;
        MOV     M,E     ;
        SHLD    STKPTR      ;
        LHLD    PC      ;
        DCX     H       ;
        MOV     A,M     ;
        STA     PC+1    ;
        DCX     H       ;
        MOV     A,M     ;
        STA     PC      ;
        RET             ;
;
;CONDITIONAL RETURN
;
RETURN: PUSH    PSW     ;
        MVI     B,1     ;
        CALL    MVINST  ;
        POP     PSW     ;
        PUSH    PSW     ;
        LXI     H,HIGHOP        ;
        LXI     B,HIGHOP+1      ;
        CALL    GTFLAG  ;
        POP     PSW     ;
        CALL    TSTFLG  ;
        ANA     A       ;
        RZ              ;
RET010: LHLD    STKPTR      ;
        MOV     A,M     ;
        STA     PC      ;
        INX     H       ;
        MOV     A,M     ;
        STA     PC+1    ;
        INX     H       ;
        SHLD    STKPTR      ;
        RET             ;
;
;MISCELAEOUS STACK INSRUCTIONS
;
STKWRD: DB      ' B   D   H   PSW'      ;
;
PPINST: PUSH    PSW     ;
        ANI     08H     ;
        JNZ     NOTPOP  ;
        LXI     B,HIHOP1        ;
POP010: LXI     D,4     ;
        LXI     H,INSTA ;
        CALL    SETLNE  ;
        POP     PSW     ;
        PUSH    PSW     ;
        ANI     '0'     ;
        RRC             ;
        RRC             ;
        MOV     C,A     ;
        MVI     B,0     ;
        LXI     H,STKWRD        ;
        DAD     B       ;
        MOV     B,H     ;
        MOV     C,L     ;
        LXI     H,INSTA+4       ;
        LXI     D,4     ;
        CALL    SETLNE  ;
        POP     PSW     ;
        MVI     B,1     ;
        CALL    MVINST  ;
        CALL    OPEXEC  ;
        RET             ;
NOTPOP: POP     PSW     ;
        CPI     0C9H    ;
        JNZ     NOTRET  ;
        MVI     B,1     ;
        CALL    MVINST  ;
        LXI     B,HIHOP1+4      ;
        LXI     D,'  '  ;
        CALL    MVNMNC  ;
        JMP     RET010  ;
NOTRET: CPI     0F9H    ;
        JNZ     NTSPHL  ;
        MVI     B,1     ;
        CALL    MVINST  ;
        LXI     B,HIHOP1+16     ;
        LXI     D,'  '  ;
        CALL    MVNMNC  ;
        LHLD    HL      ;
        SHLD    STKPTR      ;
        RET             ;
NTSPHL: CPI     0E9H    ;
        JNZ     NOOP    ;
        MVI     B,1     ;
        CALL    MVINST  ;
        LXI     B,HIHOP1+12     ;
        LXI     D,'  '  ;
        CALL    MVNMNC  ;
        LXI     H,HL    ;
        MOV     A,M     ;
        STA     PC      ;
        INX     H       ;
        MOV     A,M     ;
        STA     PC+1    ;
        RET             ;
;
;PUSH AND UNCONDITIONAL CALL
;
PSINST: PUSH    PSW     ;
        ANI     08H     ;
        JNZ     CALLUN  ;
        LXI     B,HIHOP5        ;
        JMP     POP010  ;
CALLUN: POP     PSW     ;
        CPI     0CDH    ;
        JNZ     NOOP    ;
        LHLD    PC      ;
        PUSH    H       ;
        MVI     B,3     ;
        CALL    MVINST  ;
        LXI     B,HIHOP5+4      ;
        LXI     D,'  '  ;
        LXI     H,INSTA ;
        CALL    MVNMNC  ;
        POP     B       ;
        JMP     CAL010  ;
;
;RESTARTS
;
RESTRT: PUSH    PSW     ;
	MVI	B,1	;
	POP	PSW	;
        PUSH    PSW     ;
        ANI     38H     ;
        RRC             ;
        RRC             ;
        RRC             ;
        CALL    HEXASC  ;
        MOV     D,C     ;
        MVI     E,' '   ;
        LXI     B,HIHOP7        ;
        CALL    MVNMNC  ;
        LHLD    PC      ;
        XCHG            ;
        LHLD    STKPTR      ;
        DCX     H       ;
        MOV     M,D     ;
        DCX     H       ;
        MOV     M,E     ;
        SHLD    STKPTR      ;
        POP     PSW     ;
        ANI     38H     ;
        MOV     L,A     ;
        MVI     H,0     ;
        SHLD    PC      ;
        RET             ;
;
;THE GO ROUTINE CONTROLS SIMULATED EXECUTION OF USER PROGRAMS
;
GO:     LHLD    CPOSIT  ;
        MVI     A,'-'   ;
        MOV     M,A     ;
        INX     H       ;
        SHLD    CPOSIT  ;
        CALL    GETADR  ;
        SHLD    PC      ;
        CALL    BMPLNE  ;
        LXI     B,STPADR        ;
        LXI     D,8     ;
        LXI     H,LINE15        ;
        CALL    SETLNE  ;
        LXI     H,LINE15+8      ;
        SHLD    CPOSIT  ;
        CALL    GETADR  ;
        CALL    BMPLNE  ;
        XCHG            ;
GO010:  LHLD    PC      ;
        MOV     A,D     ;
        SUB     H       ;
        JNZ     GO020   ;
        MOV     A,E     ;
        SUB     L       ;
        RZ              ;
GO020:  PUSH    D       ;
        PUSH    H       ;
        LHLD    INSTSP  ;
GO030:  DCX     H       ;
        MVI     D,10H   ;
GO040:  DCR     D       ;
        JNZ     GO040   ;
        MOV     A,H     ;
        ANA     A       ;
        JNZ     GO030   ;
        CALL    STEP    ;
        CALL    DSREGS  ;
        POP     H       ;
        POP     D       ;
        IN      KSTAT  ;
        ANI     KBDRDY  ;
        RZ     	;REPLACE WITH RNZ FOR BOARDS WITH INVERTED I/O STATUS
        JMP     GO010   ;
STPADR: DB      'STOP AT-'      ;
;
;THIS ROUTINE READS INTEL FORMAT TAPES
;
READTP: CALL    BMPLNE  ;
        CALL    TAPEIN  ;
        MOV     A,C     ;
        RZ              ;
        MVI     B,0     ;
        LXI     D,16    ;
        SUI     10H     ;
        MOV     C,A     ;
        LXI     H,ERRMES        ;
        DAD     B       ;
        MOV     B,H     ;
        MOV     C,L     ;
        LHLD    CPOSIT  ;
        CALL    BMPLNE  ;
        CALL    SETLNE  ;
        CALL    BMPLNE  ;
        RET             ;
;
;
;
;
TAPEIN: MVI     C,0     ;
        MVI     A,0FFH  ;
        OUT     SWTCHS  ;
BBLK:   CALL    INPUT   ;
        CPI     3AH     ;
        JNZ     BBLK    ;
	MVI	B,0	;
        CALL    RDBYTE  ;
        MOV     D,A     ;
        CALL    RDBYTE  ;
        MOV     H,A     ;
        CALL    RDBYTE  ;
        MOV     L,A     ;
	CALL	RDBYTE	;
        MOV     E,D     ;
        INR     E       ;
LD10:   DCR     E       ;
        JZ      LD20    ;
        MOV     A,L     ;
        CMA             ;
        OUT     SWTCHS  ;
        CALL    RDBYTE  ;
        MOV     M,A     ;
	CMP	M	;
	INX	H	;
	JZ	LD10	;
	MVI	C,20H	;
	RET		;
LD20:   MOV     A,H     ;
        CMA             ;
        OUT     SWTCHS  ;
        CALL    RDBYTE  ;
        MOV     A,B     ;
        ORA     A       ;
        JZ      NBLK    ;
        MVI     C,10H   ;
        RET             ;
NBLK:   MOV     A,D     ;
        ORA     A       ;
        JNZ     BBLK    ;
        RET             ;
;
;
;
RDBYTE:	PUSH	D	;SAVE LENGTH
	CALL	INDIGT	;GET 1 HEX DIGIT FROM TAPE
	ADD	A	;MULTIPLY BY 16
	ADD	A	;
	ADD	A	;
	ADD	A	;
	MOV	D,A	;SAVE MSD
	CALL	INDIGT	;GET NEXT HEX DIGIT FROM TAPE
	ORA	D	;COMBINE HEX DIGITS TO FORM BYTE
	MOV	D,A	;SAVE BYTE WHILE DOING CHKSUM
	ADD	B	;ADD CHKSUM TO THE NEW BYTE
	MOV	B,A	;REPLACE OLD CHKSUM WITH NEW
	MOV	A,D	;GET NEW BYTE BACK
	POP	D	;RESTORE LENGTH
	RET
;
;
;
INDIGT:	CALL	INPUT	;READ A FRAME FROM TAPE
	CPI	'9'+1	;INSPECT DATA
	JM	IND010	;OK IF DATA < 10
	ADI	9	;ELSE ADJUST FOR ASCII BIAS
IND010:	ANI	0FH	;REDUCE MOD 16
	RET		;
;
;
INPUT:	IN	RSTAT	;GET READER STATUS FROM 3P+S
        ANI     RDRRDY  ;TURN OFF NON READER BITS
	JNZ	INPUT	;LOOP UNTIL DATA AVAILABLE
	IN	READER	;GET DATA
	ANI	7FH	;CLEAR PARITY BIT
        RET             ;
;
;TAPE READER ROUTINE ERROR MESSAGES
;
ERRMES: DB      'CHECK SUM ERROR '
	DB	'MEMORY FAILURE  '
;
;THIS ROUTINE ZEROES A BLOCK OF MEMORY
;
ZERMEM: CALL    GTLMTS  ;
ZER010: MVI     A,0     ;
        MOV     M,A     ;
        INX     H       ;
        MOV     A,D     ;
        SUB H           ;
        JNZ     ZER010  ;
        MOV     A,E     ;
        SUB     L       ;
        JNZ     ZER010  ;
        RET             ;
;
;
;
ISPEED: CALL    KEYBDI  ;
        CALL    ASCHEX  ;
        ADI     01H     ;
        MOV     H,A     ;
        MVI     L,0     ;
        MVI     A,10H   ;
        SUB     H       ;
        MOV     H,A     ;
        SHLD    INSTSP  ;
        CALL    BMPLNE  ;
        RET             ;
INSTSP: DW      0400H   ;
;
;
;
        END
