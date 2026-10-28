;
;    RUN80 Version 2.0, Modified: 04/08/81 by Kelly Smith
;
;    Ver. 2.0 Mod's: changed BASE equate from 4200H to 0000H for
;                    "standard CP/M" compatiblity.
;
;                    changed all "-1" values to 0FFH to allow
;                    assembly with Digital Research's ASM.COM.
;
;                    made TITLE string a comment field to allow
;                    assemby with DR's ASM.COM and MAC.COM.
;
;                    removed "exclamation" in comment field string
;                    "SCARE YOU", that caused 'L' error using
;                    DR's ASM.COM.
;
;                    swapped order of first two characters in filetypes
;                    to OPEN (i.e., RNO and MEM) so that files WOULD open.
;                    Version 1.A was trying to OPEN NRO and EMM when using
;                    DR's ASM.COM...someone was confused here I think.
;
;                    cleaned-up some of the "free-form" editing job,
;                    to make it a little easier to read...I gave up at
;                    label CTR:, 'cause it's to much like work. Ahhh, for
;                    for the glory of Control-I...wish someone had used it.
;
; copyright (C) 1981, T. Shapin, Orange, Ca. This program may not be sold,
; but may be distributed without charge.
;
;<DP.SHAPIN>RUN80.S80.61,  7-Feb-80 09:44:46, Edit by DP.SHAPIN
;
;        TITLE   RUN80 - K AND P TEXT FORMATTER
;
; FROM DR. DOBBS JOURNAL, MAY 1979.
; FORMAT ... THE SOFTWARE TOOLS TEXT FORMATTER
;
; MIKE GABRIELSON   12/2/78
;
; THIS PROGRAM IS A SOMEWHAT MODIFIED VERSION
; OF THE FORMAT PROGRAM IN THE BOOK "SOFTWARE TOOLS" BY
; KERNIHAN AND PLAUGER. DON'T LET
; THE ABSENCE OF COMMENTS SCARE YOU. THE BOOK CONTAINS COMPLETE
; DOCUMENTATION FOR THIS CODE.
;
; MODIFIED FOR CP/M (C) DIGITAL RESEARCH BY
; TED SHAPIN
;
; START THIS PROGRAM BY GIVING THE COMMAND 'RUN80 filename'.
;  IT WILL READ A FILE filename.RNO AND WRITE A FORMATTED
;  FILE WITH THE NAME: filename.MEM
;
; FORMATTING COMMANDS
;
; COMMAND       BREAK?  DEFAULT FUNCTION
; -------       ------  ------- --------
; .BR           YES             CAUSE A LINE BREAK
; .CE   N       YES     N= 1    CENTER THE NEXT N LINES
; .FI           YES             START FILLING (MOVE WORDS TO FILL LINES)
; .FO           NO      EMPTY   FOOTER TITLE
; .HE           NO      EMPTY   HEADER TITLE
; .IN   N       NO      N=0     INDENT N SPACES
; .NF           YES             STOP FILLING
; .PG   N       YES     N=+1    BEGIN PAGE NUMBERED N
; .PL   N       NO      N=66    SET PAGE LENGTH TO N
; .RM   N       NO      N=60    SET RIGHT MARGIN TO N
; .SK   N       YES     N=1     SPACE DOWN N LINES
; .SP   N       NO      N=1     LINE SPACING IS N
; .TA N,N...    NO      CLEARS  SET TAB STOPS (10 MAX)
; .TI   N       YES     N=0     TEMPORARY INDENT OF N
; .UL   N       NO      N=1     UNDERLINE WORDS FROM NEXT N LINES
;
; -------------------------------------------------------------
;
BACKSPACE	EQU	8
EOS		EQU	0
HUGE		EQU	1000
LINSIZ		EQU	80
LIT     	EQU     '`'     ; SYMBOL TO TAKE NEXT CHAR LITERALLY
NEWLINE		EQU	0DH
NONEX   	EQU     '#'     ; SYMBOL FOR NON-EXPANDING BLANK
                        ;  IN FILLED TEXT
NO		EQU	0
PGLEN		EQU	66
PAGENUM		EQU	'#' ; SYMBOL TO PRINT PAGE NUMBER IN HEADER OR FOOTER
PGWID		EQU	60
TAB		EQU	9
TRIPLE		EQU	LINSIZ*3+3   ;UNDERLINING TRIPLES THE LENGTH
YES		EQU	0FFH
;
CR		EQU	0DH
LF		EQU	0AH
;
BASE    EQU     0000H           ; BASE OF CP/M VERSION
BDOS    EQU     BASE+5
BUFF    EQU     BASE+80H
;
FCB     EQU     BASE+05CH       ; FILE CONTROL BLOCK
FCBDN   EQU     FCB+0   ; NAME OF INPUT HEX FORMAT FILE
FCBNM   EQU     FCB+1   ; FILE NAME
FCBFT   EQU     FCB+9   ; DISK FILE TYPE (3 CHARS)
FCBRL   EQU     FCB+12  ; FILE'S CURRENT REEL NUMBER
FCBRC   EQU     FCB+15  ; FILE'S RECORD COUNT (0 TO 128)
FCBBM   EQU     FCB+16  ; START OF BIT MAP
FCBNM2  EQU     FCB+16  ; SECOND FILE NAME (OUTPUT)
FCBCR   EQU     FCB+32  ; CURRENT (NEXT) RECORD NUMBER (0 TO 127)
FCBDM   EQU     FCB+33  ; START OF DISK ALLOCATION MAP
FCBLN   EQU     FCB+33  ; FCB LENGTH
;
;
        ORG     100H+BASE
        LXI     SP,STACK
        CALL    DSKINI
        CALL    INIT
        JMP     MAINL
  
GNASC:  PUSH	H  ; GET NEXT ASCII 
        PUSH	D ; LEAVE WITH CARRY SET IF AT EOF
        PUSH	B
GNA2:   LDA	IPTR       ; INPUT BUFFER POINTER
        CPI	128        ; 128 BYTES PER SECTOR (INPUT RECORD)
        JZ	FREAD      ; READ NEXT FILE RECORD
GNA1:	MVI	D,00H
        MOV	E,A
        LXI	H,BUFF
        DAD	D
        MOV	A,M
        CPI	1AH        ; CONTROL-Z IS EOF
        JZ	GNA4
        LXI	H,IPTR
        INR	M
        CPI     LF      ; DON'T TRANSMIT
        JNZ     GNA3    ; LINE FEEDS
        INX     D
        JMP     GNA2
GNA3:   ORA     A       ; CLEAR CARRY
        JMP  GNA9

FREAD:			; READ THE NEXT FILE RECORD
        LXI     D,BUFF  ; SET DISK BUFFER ADDRESS
        MVI     C,1AH   ; SET DMA ADDR
        CALL    BDOS
        MVI	C,14H      ;READ FILE RECORD
        LXI	D,FCB
        CALL	BDOS
        ORA	A
        JNZ	GNA4
        STA	IPTR       ; ZERO PTR FOR START OF BUFFER
        JMP	GNA1

GNA4:	MVI	A,1AH        ; INDICATE EOF
        STC		; BY SETTING CARRY
GNA9:   POP	B
	POP	D
	POP	H
	RET
;
;       
PUTC:   PUSH    H       ; SEND A CHAR TO DISK BUFFER AND
        PUSH    B       ; WRITE IT IF IT IS FULL
        PUSH    D
        PUSH    PSW     ; SAVE CHAR IN CASE ITS A CR
PUTC2:  LHLD    OPTR
        MOV     M,A     ; CHAR TO WRITE
        INX     H
        SHLD    OPTR
        MOV     A,L     ; NOW SEE IF 128 BUFFER IS FULL
        CPI     128
        CNC     SAVDSK  ; WRITE THE BUFFER
        POP     PSW
        CPI     NEWLINE ; IF IT WAS A CR,
        JNZ     PUTCX   ; WE NEED TO ADD
        MVI     A,LF
        PUSH    PSW     ; A LF
        JMP     PUTC2
PUTCX:  POP     D
        POP     B
        POP     H       ; DONE
        RET
;
SAVDSK:
        LXI     H,DBUFF ;POINT TO START OF AREA TO SAVE
SAVD10:
        SHLD    OPTR            ;RESET POINTER
        XCHG                    ;SET BUFFER ADR TO DBUFF
        MVI     C,26
        CALL    BDOS
        LXI     D,OUTFCB                ;WRITE NEXT RECORD TO DISK
        MVI     C,21
        CALL    BDOS
        CPI     0               ;WAS THERE AN ERROR?
        RZ              ; NO. RETURN
        LXI     D,DERMES        ;YES: COMPLAIN, CLOSE FILE & RET
        MVI     C,9
        CALL    BDOS
        LXI     D,OUTFCB
        MVI     C,16
        CALL    BDOS
        JMP     RETCPM
;
AWAIT:  MVI     C,11    ; TEST CONSOLE STATUS
        CALL    BDOS    ; FOR A CHARACTER
        ANI     1       ; READY
        JZ      AWAIT
        RET             ; GOT ONE
  
DSKINI:                 ; INITIALIZE INPUT AND OUTPUT DISK FILES
        LXI     D,IDMSG ; PRINT SIGN ON MSG
        CALL    PRINT
        LDA     FCBNM
        CPI     20H
        JZ      NONAME  ; PRINT HELP MESSAGE
        LXI     H,'RN'  ; FILL IN 'RNO' FOR
        SHLD    FCBFT   ; FILE NAME EXTENSION
        MVI     A,'O'
        STA     FCBFT+2
;
        LXI     H,OUTFCB
        LXI     D,FCB
;
        MVI     B,13    ; NOW
DSKL:   LDAX    D       ; MOVE OUTPUT FILE NAME TO OUTFCB
        MOV     M,A     ; INCLUDING REEL NO.
        INX     H
        INX     D
        DCR     B
        JNZ     DSKL
;
        LXI     H,'ME'  ; FILL IN 'MEM' FOR
        SHLD    OUTFCB+9 ; FILE NAME EXTENSION
        MVI     A,'M'
        STA     OUTFCB+11
;
        LXI     D,OUTFCB
        PUSH    D
        MVI     C,13H   ; DELETE OUTPUT FILE NAME
        CALL    BDOS

        POP     D
        MVI     C,22    ; MAKE A NEW OUTPUT FILE
        CALL    BDOS

        CPI     0FFH
        JZ      XOUTF   ; CANNOT CREATE NEW OUTPUT FILE NAME
        XRA     A
        STA     ORECN   ; SET OUTPUT RECORD NUMBER TO 0
        LXI     H,DBUFF ; INITIALIZE DISK BUFFER
        SHLD    OPTR    ; POINTER
        MVI     C,0FH   ; OPEN INPUT FILE
        LXI     D,FCB
        CALL    BDOS

        CPI     0FFH
        JZ      NOINF   ; INPUT FILE NOT FOUND
        LXI     H,IPTR  ; SET POINTER TO END OF RECORD BUFF
        MVI     M,128   ; SO INITIAL READ WILL HAPPEN
        RET     

NOINF:  LXI     D,NOINFM
        CALL    PRINT   
        JMP     RETCPM
        
NOINFM: DB      CR,LF,'INPUT (.RNO) FILE NOT FOUND$'
        
DERMES: DB      CR,LF,'ERROR WRITING OUTPUT RECORD$'

IXM:    LXI     D,IXMS
        CALL    PRINT   ;       PRINT   MSG
        JMP     RETCPM
        
IDMSG:  DB      CR,LF,'RUN80 TEXT FORMATTER, Ver. 2.0 as of 04/08/81',CR,LF,'$'
 
IXMS:   DB      CR,LF,'INPUT READ ERROR$'
        
NONAME: DB      CR,LF,'START THIS PROGRAM AS: RUN80 filename$'
        
XOUTF:  LXI     D,XOUTM
        CALL    PRINT   ;       PRINT   MSG
        JMP     RETCPM

XOUTM:  DB      'CANNOT CREATE OUTPUT FILE$'
        
PRINT:  MVI     C,9     ;PRINT A MSG TO '$'
        CALL    BDOS
        RET     

RETCPM  JMP     BASE
;
;       DATA    AREAS
;
IPTR:   DW      0       ;POINTER TO ASCII CHAR. IN INPUT BUFFER
OUTFCB: DS      33      ; FCB FOR OUTPUT FILE
ORECN   EQU     OUTFCB+32       ; RECORD NUMBER
;
        DS      2       ; SAFETY SPACE
MAINL:
        LXI	H,INBUF
        CALL	GETLIN
        JC	FLUSH
        MVI	A,'.'       ; COMMAND STARTS WITH PERIOD
        CMP	M
        JNZ	ITSTEXT
        CALL	 COMAND
        JMP	MAINL
ITSTEXT:
        CALL	TEXT
        JMP	MAINL
FLUSH:  CALL	BRK        ; FINISH ANY POSSIBLE LINE 0
        LHLD	LINENO
        MOV	A,H
        ORA	L
        CZ      FINISH  ; TRULY AT TOP OF A PAGE
        LXI	H,HUGE
        CALL	SPACE
FINISH: MVI     A,1AH   ; WRITE CP/M EOF CHARACTER
        CALL    PUTC
        LHLD    OPTR    ; SMALL CHANCE THAT WE JUST
        LXI     D,DBUFF ; FINISHED WRITING A DISK BUFFER
        CALL    COMPARE
        CNZ     SAVDSK  ; WRITE BUFFER ON DISK
        MVI     C,16    ; NOW CLOSE
        LXI     D,FCB   ; INPUT FILE
        CALL    BDOS
        LXI     D,OUTFCB        ; AND CLOSE
        MVI     C,16    ; OUTPUT FILE
        CALL    BDOS
        CALL	RETCPM
;
FOOTER: DS LINSIZ+3     ; INCLUDES CR, LF AND EOS
HEADER: DS LINSIZ+3
INBUF:  DS TRIPLE       ; HOLDS INPUT LINE
OUTBUF: DS TRIPLE       ; LINES TO BE FILLED COLLECT HERE
WRDBUF: DS TRIPLE       ; USED BY PUTWRD
BACKUP: DS 1    ; ROOM FOR ONE CHAR PUSHED BACK ONTO INPUT STREAM
BOTTOM: DS 2    ; LAST LIVE LINE = PLVAL-M3VAL-M4VAL
CEVAL:  DS 2    ; NUMBER OF INPUT LINES TO CENTER
CURPAG: DS 2    ; CURRENT OUTPUT PAGE NO. (INIT = 0)
DIR:    DS      1       ; DIRECTION OF SPREADING LINE TO ADD SPACES
FILL:   DS 1    ; FILL IF YES (INIT = YES)
INVAL:  DS 2    ; CURRENT INDENT VALUE. (INIT = 0)
LAST:   DS 2
LINENO: DS 2    ; NEXT LINE TO BE PRINTED. (INIT = 0)
LLVAL:  DS 2
LSVAL:  DS 2    ; CURRENT LINE SPACING (INIT = 1)
M1VAL:  DS 2    ; MARGIN BEFORE AND INCLUDING HEADER (INIT = 3)
M2VAL:  DS 2    ; MARGIN AFTER HEADER
M3VAL:  DS 2    ; MARGIN AFTER LAST TEXT LINE
M4VAL:  DS 2    ; BOTTOM MARGIN, INCLUDING FOOTER
NB:     DS 2
NNE:    DS 2
NEWPAG: DS 2    ; NEXT OUTPUT PAGE NUMBER. (INIT = 1)
NEXTRA: DS 2
NHOLES: DS 2
OUTP:   DS 2    ; LAST CHAR POSITION IN OUTBUF. (INIT = 0)
OUTW:   DS 2    ; WIDTH OF TEXT NOW IN OUTPUT BUFF. (INIT = 0)
OUTWDS: DS 2    ; NUMBER OF WORDS IN OUTBUF. (INIT = 0)
PLVAL:  DS 2    ; PAGE LENGTH IN LINES. (INIT = PAGELEN)
RMVAL:  DS 2    ; CURRENT RIGHT MARGIN. (INIT = PAGEWID)
SPVAL:  DS 2
TABSON: DS 1    ; SPACE FOR TABS FLAG. (INIT = NO TABS)
TABPOS: DS 11   ; SPACE FOR UP TO 10 TAB STOPS AND END MARKER
TIVAL:  DS 2    ; TEMPORARY INDENT VALUE. (INIT = 0)
ULVAL:  DS 2    ; NUMBER OF INPUT LINES TO UNDERLINE
WAITUP: DS 1            ;YES IF FORMAT SHOULD WAIT AT START OF EACH
;                       ; PAGE
CMDTAB:
        DB      'BR'
        DW      BREAKC
        DB      'CE'
        DW      CTRC
        DB      'FI'
        DW      FILLC
        DB      'FO'
        DW      FOOTC
        DB      'HE'
        DW      HDR
        DB      'IN'
        DW      IND
        DB      'NF'
        DW      NOFILL
        DB      'PG'
        DW      PAGEC
        DB      'PL'
        DW      LGT
        DB      'RM'
        DW      MARGIN
        DB      'SK'
        DW      SKP
        DB      'SP'
        DW      SPACEC
        DB      'TA'
        DW      TABSET
        DB      'TI'
        DW      TEMPI
        DB      'UL'
        DW      UNDERC
;
        DB      0       ; FLAG END OF TABLE
;
;-----
; ALPHA - TEST CHARACTER FOR LETTER
; ACCEPTS: A = CHARACTER
; RETURNS: CARRY SET IF A = A-Z OR a-z
;-----
;
ALPHA:  CPI	'a'
        JC	NOTLC
        CPI	'z'+1
        RC
NOTLC:  CPI	'Z'+1
        RNC
        CPI	'A'
        CMC
        RET
;
; BRK - END CURRENT FILLED LINE
;-----
;
BRK:    PUSH	PSW
        PUSH	B
        PUSH    D
        PUSH	H
        LXI	D,0
        LHLD	OUTP
        CALL	COMPARE
        JNC	EMPTY
        LXI	D,OUTBUF
        DAD	D
        MVI	M,EOS
        DCX     H
        MVI     M,NEWLINE
        XCHG
        CALL	PUT
EMPTY:  LXI	H,0
        SHLD	OUTP
        SHLD	OUTW
        SHLD	OUTWDS
        POP	H
        POP     D
        POP	B
        POP	PSW
        RET
;
;-----
; CENTER - CENTER A LINE BY SETTING TIVAL
; ACCEPTS: HL = A LINE
;-----
;
CTR:    PUSH H
        CALL WIDTH
        LHLD TIVAL
        XCHG
        CALL DELESSHL
        XCHG
        LHLD RMVAL
        DAD D
        CALL DIVBY2
        LXI D,0
        CALL MAX
        SHLD TIVAL
        POP H
        RET
;
;-----
; CHRBAK - PUSH CHARACTER BACK ONTO INPUT
; ACCEPTS: B = CHARACTER
;-----
;
CHRBAK: MOV A,B
        STA BACKUP
        RET
;
;-----
; COMMAND - PERFORM FORMATTING COMMAND
;-----
;
COMAND:
        LXI D,CMDTAB
        INX H           ;GET ADDR KEYWORD (SKIP .)
        CALL SEARCH     ;COMMAND IN TABLE?
        RC              ;NO, IGNORE
        PUSH D          ;STACK DISPATCH ADDRESS
        CALL GETVAL
        RET             ;JUMP TO COMMAND HANDLER
;                       ;DE = ADDR END OF COMMAND.
;                       ;HL = ARGUMENT VALUE
BREAKC: CALL BRK
        RET
;
CTRC:
        CALL BRK
        LXI B,0
        PUSH B
        INX B
        LXI D,HUGE
        PUSH D
        XCHG
        LHLD CEVAL
        CALL PSET
        SHLD CEVAL
        RET
;
FOOTC:
        LXI H,FOOTER
        CALL GETTL
        RET
;
TEMPI:
        CALL    BRK
        LXI B,0
        PUSH B
        XCHG
        LHLD RMVAL
        PUSH H
        LHLD TIVAL
        CALL PSET
        SHLD TIVAL
        RET
;
HDR:
        LXI H,HEADER
        CALL GETTL
        RET
;
IND:
        LXI B,0
        PUSH B
        XCHG
        LHLD RMVAL
        DCX H
        PUSH H
        LHLD INVAL
        CALL PSET
        SHLD INVAL
        SHLD TIVAL
        RET
;
NOFILL:
        CALL BRK
        MVI A,NO
        STA FILL
        RET
;
FILLC:
        CALL BRK
        MVI A,YES
        STA FILL
        RET
;
LGT:
        PUSH H
        LHLD M1VAL
        XCHG
        LHLD M2VAL
        DAD D
        XCHG
        LHLD M3VAL
        DAD D
        XCHG
        LHLD M4VAL
        DAD D
        INX H
        XTHL
        LXI B,HUGE
        PUSH B
        LXI B,PGLEN
        XCHG
        LHLD PLVAL
        CALL PSET
        SHLD PLVAL
        XCHG
        LHLD M3VAL
        CALL DELESSHL
        XCHG
        LHLD M4VAL
        CALL DELESSHL
        SHLD BOTTOM
        RET
;
MARGIN:
        XCHG
        LHLD TIVAL
        INX H
        PUSH H
        LXI H,HUGE
        PUSH H
        LXI B,PGWID
        LHLD RMVAL
        CALL PSET
        SHLD RMVAL
        RET
;
PAGEC:  PUSH H
        PUSH PSW
        LXI D,0
        LHLD LINENO
        CALL COMPARE
        LXI H,HUGE
        CC SPACE
        POP PSW
        POP D
        LXI B,-HUGE
        PUSH B
        LXI B,HUGE
        PUSH B
        LHLD CURPAG
        MOV B,H
        MOV C,L
        INX B
        CALL PSET
        SHLD CURPAG
        SHLD NEWPAG
        RET
;
SKP:    LXI B,0         ;STACK MINIMUM
        PUSH B
        INX B           ;FORM DEFAULT
        LXI D,HUGE      ;STACK MAXIMUM
        PUSH D
        XCHG
        LHLD SPVAL
        CALL PSET
        SHLD SPVAL
        CALL SPACE
        RET
SPACEC: LXI B,1         ;GET MINIMUM AND DEFAULT
        PUSH B          ;STACK MINIMUM
        LXI D,HUGE      ;STACK MAXIMUM
;
        PUSH D
        XCHG            ;DE := ARGUMENT VALUE
        LHLD LSVAL
        CALL PSET
        SHLD LSVAL
        RET
;
UNDERC: LXI B,1
        PUSH B
        DCX B
        LXI D,HUGE
        PUSH D
        XCHG
        LHLD ULVAL
        CALL PSET
        SHLD ULVAL
        RET
;
;-----
; COMPARE - COMPARE TWO SIGNED NUMBERS
; ACCEPTS:  NUMBERS IN DE, HL
; RETURNS:  Z SET IF DE = HL
;           C SET IF DE < HL
;           C CLEAR IF DE >= HL
; DO THE USUAL SUBTACT, BUT COMPLEMENT THE CARRY
; IF THE ORIGINAL SIGNS ARE NOT EQUAL
;-----
;
COMPARE:
        MOV A,E
        SUB L
        MOV A,D
        SBB H
        PUSH PSW
        MOV A,D
        XRA H
        ANI 80H
        JNZ SIGNEQ
        POP PSW
        RET
;
SIGNEQ: POP PSW
        CMC
        RET
;
;-----
; DELESSHL - SUBTRACT HL FROM DE
; RETURNS: HL = DE - HL
;-----
;
DELESSHL:
        MOV A,E
        SUB L
        MOV L,A
        MOV A,D
        SBB H
        MOV H,A
        RET
;
;-----
; DIVBY2 - DIVIDE SIGNED NUMBER IN HL BY TWO
; (SHIFT RIGHT BUT PROPAGATE THE SIGN)
;-----
;
DIVBY2: MOV A,H
        RAL
        MOV A,H
        RAR
        MOV H,A
        MOV A,L
        RAR
        MOV L,A
        RET
;
;-----
; DIVIDE - DIVIDE DE BY HL
; ACCEPTS: HL = DIVISOR
;          DE = DIVIDEND
; RETURNS: HL = QUOTIENT
;-----
;
DIVIDE: MOV B,H         ;MOVE DIVISOR TO BC
        MOV C,L
        LXI H,0         ;FORM INITIAL QUOTIENT
DVLOOP: MOV A,E         ;DIVIDE BY SUBTRACTION
        SUB C           ;(DE := DE - BC)
        MOV E,A
        MOV A,D
        SBB B
        MOV D,A
        RC
        INX H
        JMP DVLOOP
;
;-----
; EXTEND - EXTEND A STRING BY INSERTING ONE CHARACTER
; ACCEPTS: C = CHAR TO INSERT
;          HL = ADDR OF WHERE TO INSERT IT IN STRING
;-----
;
EXTEND: PUSH    H
        PUSH    B
EXTD2:  MOV     A,M     ; GET CHAR TO BE MOVED
        MOV     M,C     ; REPLACE IT WITH CHAR IN C
        MOV     C,A     ; AND REPEAT
        INX     H       ; STEP TO NEXT CHAR
        CPI     EOS     ; UNTIL THE END OF STRING
        JNZ     EXTD2
        MOV     M,C     ; STORE THE LAST CHAR = EOS
        POP     B
        POP     H
        RET
;-----
; GETCHR - GET NEXT CHARACTER
; RETURNS:  CARRY SET IF EOF
;           ELSE A = CHARACTER
;-----
;
GETCHR: LDA BACKUP      ;ANY CHARACTER BACKED UP?
        CPI NEWLINE     ;(NEWLINE CAN'T BE BACKED UP,
;                       ; IT MEANS BACKUP IS EMPTY)
        JZ GETC         ;NO, READ NEXT CHARACTER
        MOV B,A         ;YES, SAVE CHARACTER IN B
        MVI A,NEWLINE   ;GET NEWLINE
        STA BACKUP      ;EMPTY BACKUP
        MOV A,B         ;RESTORE CHARACTER
        ORA A           ;CLEAR CARRY
        RET
GETC:   CALL GNASC      ;GET NEXT CHARACTER
        RET
;
;-----
; GETLIN - FILL BUFFER WITH NEXT INPUT LINE
; ACCEPTS:  HL (SAVED) = ADDR BUFFER
; RETURNS:  CARRY SET IF EOF
;           ELSE LINE TERMINATED BY EOL, EOS
;-----
;
GETLIN: MOV D,H         ;SAVE ADDR OF  BUFFER IN DE
        MOV E,L
        MVI C,0         ;INITIALIZE LINE LENGTH
GETNXT: MVI A,LINSIZ    ; GET MAXIMUM CHARACTERS PER LINE
        CMP C           ;LINE BUFFER FULL?
        JZ LINFIN       ;YES, FORCE NEW LINE
        CALL    GETCHR  ;GET NEXT CHARACTER
        JC LINEND       ;HANDLE EOF
        MOV B,A         ;SAVE CHARACTER IN B
        CPI NEWLINE     ;END OF LINE?
        JZ      LINFIN  ; FOUND END OF LINE
        MOV M,B         ;SAVE CHARACTER IN BUFFER
        INX H           ;POINT TO NEXT CHARACTER POSITION
        INR C           ;ADJUST # OF CHARACTERS SAVED
        JMP GETNXT      ;GET NEXT CHARACTER
;
LINFIN: MVI M,NEWLINE   ;END LINE WITH CARRIAGE RETURN
        INX H           ;AND
        MVI M,EOS       ;END OF STRING
        XCHG            ;RESTORE HL
        ORA A           ;CLEAR CARRY
        RET
LINEND: MOV A,C         ;BUFFER EMPTY?
        ORA C           ;( COUNT ZERO?)
        JNZ LINFIN      ;NO, PROVIDE EOL 
        STC             ;YES, TRUE EOF
        RET
;
;-----
; GETTL - COPY TITLE
; ACCEPTS:  DE = ADDR END OF COMMAND
;           HL = ADDR DESTINATION
;
;-----
;
GETTL:          ; called after leading blanks and tabs have been skipped
        LDAX D
        INX D
        CPI ''''
        JZ COPYTL
        CPI '"'
        JZ COPYTL
        DCX D
COPYTL: CALL SCOPY
        RET
;
;-----
; GETVAL - EVALUATE OPTIONAL NUMERIC ARGUMENT
; ACCEPTS:  DE = ADDR OF END OF COMMAND
; RETURNS:   A = ARGTYP
;           HL = ARGUMENT VALUE
;           DE = ADDR OF COMMAND PAST ARGUMENT
;-----
;
FNDARG: INX H           ;GET ADDR NEXT CHARACTER
GETVAL:
        MOV A,M         ;GET NEXT CHARACTER
        CPI ' '         ;BLANK?
        JZ FNDARG       ;YES, KEEP SEARCHING FOR ARGUMENT
        CPI TAB         ;NO, TAB?
        JZ FNDARG       ;YES, KEEP SEARCHING
        CPI ','         ; COMMA ALSO CAN BE
        JZ FNDARG       ; ALLOWED AS DELIMITER
        INX H           ;ASSUME CHARACTER IS '+' OR '-'
        CPI '+'         ;IS IT '+'?
        JZ CTOI         ;YES
        CPI '-'         ;NO, IS IT '-'?
        JZ CTOI         ;YES
        DCX H           ;NO, RESTORE ADDR ARGUMENT
CTOI:   PUSH PSW        ;SAVE ARGTYP
        XCHG            ;KEEP ADDR ARGUMENT IN DE
        LXI H,0         ;INITIALIZE ARGUMENT CHARACTER
VALOOP: LDAX D          ;GET NEXT ARGUMENT CHARACTER
        CPI '0'         ;< '0'?
        JC GOTVAL       ;YES, END OF ARGUMENT
        CPI '9'+1       ;NO, >'9'?
        JNC GOTVAL      ;YES, END OF ARGUMENT
        INX D           ;GET ADDR NEW ARGUMENT CHARACTER
        MOV B,H         ;NO, SAVE CURRENT VALUE
        MOV C,L         ;IN BC
        DAD H           ;DOUBLE CURRENT VALUE
        DAD H           ;QUADRUPLE
        DAD B           ;QUINTUPLE
        DAD H           ;DECTUPLE
        SUI '0'         ;CONVERT NEW CHARACTER IN BINARY
        ADD L           ;ADD TO NEW VALUE
        MOV L,A
        JNC VALOOP
        INR H
        JMP VALOOP
GOTVAL: POP PSW         ;RESTORE ARGTYP
        RET
;
;-----
; GETWRD - GET NEXT WORD
; ACCEPTS:  HL = ADDR TEXT
; RETURNS:  CARRY SET IF NONE FOUND
;           ELSE HL = ADDR EORD, EOS
;                DE = ADDR TEXT FOLLOWING WORD
;-----
;
GETWRD: MOV A,M
        INX H
        CPI ' '
        JZ GETWRD
        CPI TAB
        JZ GETWRD
        DCX H
        MOV D,H
        MOV E,L
GWLOOP: MOV A,M
        INX H
        CPI EOS
        JZ WRDEND
        CPI NEWLINE
        JZ WRDEND
        CPI TAB
        JZ WRDEND
        CPI ' '
        JNZ GWLOOP
WRDEND: DCX H
        MVI M,EOS
        CALL COMPARE
        XCHG
        CMC
        INX D
        RET
;
;-----
; INIT - INITIALIZE VARIABLES
;-----
;
INIT:   MVI A,NO
        STA WAITUP      ;SAVE WAIT OPTION FLAG
        STA TABSON      ; TURN TABS OFF
        STA TABPOS      ; FLAG END OF TABSTOP ARRAY
        MVI A,NEWLINE   ;INITIALIZE
        STA BACKUP      ;BACKUP CHARACTER
        STA HEADER
        STA FOOTER
        MVI A,EOS
        STA HEADER+1
        STA FOOTER+1
        MVI A,YES
        STA FILL
        LXI H,0
        SHLD INVAL
        SHLD TIVAL
        SHLD CEVAL
        SHLD ULVAL
        SHLD LINENO
        SHLD CURPAG
        SHLD OUTP
        SHLD OUTW
        SHLD OUTWDS
        INX H
        SHLD LSVAL
        SHLD NEWPAG
        INX H
        SHLD M2VAL
        SHLD M3VAL
        INX H
        SHLD M1VAL
        SHLD M4VAL
        LXI H,PGWID
        SHLD RMVAL
        LXI H,PGLEN
        SHLD PLVAL
        XCHG
        LHLD M3VAL
        CALL DELESSHL
        XCHG
        LHLD M4VAL
        CALL DELESSHL
        SHLD BOTTOM
        RET
;
;-----
; LEADBL - "DELETE"  LEADING BLANKS, SET TIVAL
; ACCEPTS: HL = ADDR LINE
; RETURNS: HL = ADDR FIRST NON-BLANK
;-----
;
LEADBL: CALL BRK
        LXI D,0
LBLOOP: MOV A,M
        INX D
        INX H
        CPI ' '
        JZ LBLOOP
        DCX H
        CPI NEWLINE
        RZ
        XCHG
        SHLD TIVAL
        XCHG
        RET
;
;-----
; LENGTH - COMPUTE LENGTH OF STRING
; ACCEPTS:  HL = ADDR STRING
; RETURNS:  DE = LENGTH
;-----
; 
LENGTH: LXI D,0
LENEXT: MOV A,M
        CPI EOS
        RZ
        INX D
        INX H
        JMP LENEXT
;
;-----
; MAX DETERMINE LARGER OF TWO NUMBERS
; ACCEPTS: NUMBERS IN DE, HL
; RETURNS:  HL = LARGER
;           DE = SMALLER
;-----
;
MAX:    CALL MIN
        XCHG
        RET
;
;-----
; MIN DETERMINE SMALLER OF TWO NUMBERS
; ACCEPTS: NUMBERS IN DE, HL
; RETURNS:  DE = LARGER
;           HL = SMALLER
;-----
;
MIN:    CALL COMPARE
        RNC
        XCHG
        RET
;
;-----
; PFOOT - PUT OUT PAGE FOOTER
;-----
;
PFOOT:  LHLD M3VAL
        CALL SKIP
        LXI D,0
        LHLD M4VAL
        CALL COMPARE
        RNC
        LXI D,FOOTER
        LHLD CURPAG
        CALL PUTTL
        LHLD M4VAL
        DCX H
        CALL SKIP
        RET
;
;-----
; PHEAD - PUT OUT PAGE HEADER
;-----
;
PHEAD:  PUSH D
        PUSH H          
        LDA WAITUP      ;GET W: OPTION FLAG
        CPI YES         ;WAIT FOR OPERATOR?
        CZ AWAIT        ;YES, WAIT FOR CONSOLE INPUT
        LHLD NEWPAG
        SHLD CURPAG
        INX H
        SHLD NEWPAG
        LHLD M1VAL
        PUSH H
        LXI D,0
        CALL COMPARE
        JNC SKPHDR
        DCX H
        CALL SKIP
        LXI D,HEADER
        LHLD CURPAG
        CALL PUTTL
SKPHDR: LHLD M2VAL
        PUSH H
        CALL SKIP
        POP H
        POP D
        DAD D
        INX H
        SHLD LINENO
        POP H
        POP D
        RET
;
;-----
; PUT - PUT OUT LINE WITH PROPER SPACING AND INDENTING
; ACCEPTS:  HL = ADDR LINE
;-----
;
PUT:    PUSH H
        LHLD LINENO
        MOV A,H
        ORA L
        JNZ NOT0
        CALL PHEAD
        JMP HEADED
NOT0:   XCHG
        LHLD BOTTOM
        XCHG
        CALL COMPARE
        JNC HEADED
        CALL PHEAD
HEADED: LHLD TIVAL
TITEST: MOV A,H
        ORA L
        JZ TIZERO
        MVI A,' '
        CALL PUTC
        DCX H
        JMP TITEST
TIZERO: LHLD INVAL
        SHLD TIVAL
        POP H
        CALL PUTLIN     ; PUT LINE OUT IN DISK BUFFER
        LHLD BOTTOM
        XCHG
        LHLD LINENO
        CALL DELESSHL
        XCHG
        LHLD LSVAL
        DCX H
        CALL MIN
        CALL SKIP
        LHLD LSVAL
        XCHG
        LHLD LINENO
        DAD D
        SHLD LINENO
        XCHG
        LHLD BOTTOM
        XCHG
        CALL COMPARE
        CC PFOOT
        RET
;
;-----
; PUTDEC - OUTPUT DECIMAL NUMBER
; ACCEPTS:  HL = NUMBER
;-----
;
PUTDEC: PUSH D
        PUSH H
        LXI D,TENTAB
        PUSH D
        MVI C,1
DOTPOS: XTHL
        MOV E,M
        INX H
        MOV D,M
        INX H
        XTHL
        MVI B,0FFH
DOTDIV: INR B
        MOV A,L
        SUB E
        MOV L,A
        MOV A,H
        SBB D
        MOV H,A
        JNC DOTDIV
        DAD D
        XRA A
        ORA B
        JNZ DOTPRI
        ORA C
        JNZ DOTSKP
DOTPRI: ORI '0'
        MVI C,0
        CALL PUTC
DOTSKP: MOV A,E
        CPI 1
        JNZ DOTPOS
        POP D
        POP H
        POP D
        RET
TENTAB: DW  10000
        DW 1000
        DW 100
        DW 10
        DW 1
;
;-----
; PUTLIN - OUTPUT LINE
; ACCEPTS: HL = ADDR LINE
;-----
;
PUTLIN: MOV A,M
        CPI EOS
        RZ
        LDA     FILL    ; IF FILLING
        CPI     NO      ; THEN POSSIBLE
        MOV     A,M     ; (GET CHAR BACK)
        JZ      PUTL6   ; TRANSLATION NEEDED
        CPI     LIT     ; IS NEXT CHAR TO BE
        JNZ     PUTL2   ; SENT LITERALLY?
        INX     H       ; YES. SO
        MOV     A,M     ; GET IT
        JMP     PUTL6
PUTL2:  CPI     NONEX   ; IS IT A NON-EXPANDABLE BLANK?
        JNZ     PUTL6   ; NO
        MVI     A,' '   ; YES. SO CHANGE IT TO BLANK.
PUTL6:  CALL PUTC
        INX H
        JMP PUTLIN
;-----
; PUTTL - PUT OUT TITLE LINE WITH OPTIONAL PAGE NUMBER
; ACCEPTS:  DE = ADDR LINE
;           HL = PAGE #
;-----
;
PUTTL:  LDAX D
        INX D
        CPI EOS
        RZ
        CPI PAGENUM
        JNZ TLCOPY
        CALL PUTDEC
        JMP PUTTL
TLCOPY: CALL PUTC
        JMP PUTTL
;
;-----
; PUTWRD - PUT A WORD IN OUTBUF
; ACCEPTS: HL = ADDR WORD
;-----
;
PUTWRD: PUSH D
        PUSH H
        CALL WIDTH
        MOV B,D         ;BC := W
        MOV C,E
        POP H
        PUSH H
        CALL LENGTH
        LHLD OUTP
        DAD D
        INX H
        SHLD LAST
        LHLD RMVAL
        XCHG
        LHLD TIVAL
        CALL DELESSHL
        SHLD LLVAL
        XCHG
        LHLD OUTW
        DAD B
        CALL COMPARE
        JC MAYFIT
        LHLD LAST
        XCHG
        LXI H,TRIPLE
        CALL COMPARE
        JC FITS
MAYFIT: LXI D,0
        LHLD OUTP
        CALL COMPARE
        JNC FITS
        XCHG
        LHLD LAST
        XCHG
        CALL DELESSHL
        SHLD LAST
        LHLD LLVAL
        XCHG
        LHLD OUTW
        CALL DELESSHL
        INX H
        SHLD NEXTRA
        PUSH B
        PUSH H
        CALL SPREAD
        POP H
        POP B
        LXI D,0
        CALL COMPARE
        JNC FLUSHIT
        INX D
        LHLD OUTWDS
        CALL COMPARE
        JNC FLUSHIT
        LHLD NEXTRA
        XCHG
        LHLD OUTP
        DAD D
        SHLD OUTP
FLUSHIT:        
        CALL BRK
FITS:   LXI D,OUTBUF
        LHLD OUTP
        DAD D
        POP D
        CALL SCOPY
        LHLD LAST
        SHLD OUTP
        LXI D,OUTBUF
        DAD D
        DCX H
        MVI M, ' '
        LHLD OUTW
        DAD B
        INX H
        SHLD OUTW
        LHLD OUTWDS
        INX H
        SHLD OUTWDS
        POP D
        RET
;
;-----
; SCOPY - COPY STRINGS
; ACCEPTS:  DE = ADDR SOURCE
;           HL = ADDR DESTINATION
;-----
;
SCOPY:  LDAX D
        MOV M,A
        CPI EOS
        RZ
        INX D
        INX H
        JMP SCOPY
;
;-----
; SEARCH - SEARCH TABLE FOR A COMMAND
; ACCEPTS:
;           DE = ADDR CMMND TABLE
;           HL = ADDR COMMAND
; RETURNS:  CARRY SET IF COMMAND NOT IN TABLE
;           ELSE DE = ADDRESS FROM TABLE
;                HL = ADDR END OF COMMAND
;-----
;
SEARCH: PUSH    H       ; SAVE START OF COMMAND
        LDAX    D       ; GET TABLE ENTRY
        ANA     A       ; AT END?
        JNZ     SRCH1   ; NO
        POP     H       ; NOT FOUND
        STC             ; YES
        RET
SRCH1:  XRA     M       ; COMBINE WITH FIRST COMMAND LETTER
        ANI     5FH     ; MAKE UPPER CASE
        JNZ     SRCH3   ; NO MATCH
        INX     D
        INX     H
        LDAX    D
        XRA     M
        ANI     5FH     ; CHECK SECOND CHARACTER
        JNZ     SRCH2   ; NO MATCH
; WE FOUND A COMMAND
        INX     D
        XCHG            ; POINT HL TO COMMAND ADDRESS
        MOV     E,M     ; PUT COMMAND ADDRESS
        INX     H
        MOV     D,M     ; IN DE
        POP     H       ; GET OLD START OF COMMAND
        INX     H       ; POINT PAST COMMAND
SRCH8:  INX     H       ; NOW MOVE TO END OF CMND WORD
        MOV     A,M
        CPI     EOS
        JZ      SRCH9   ; NO MORE ON LINE
        CPI     ' '     ; BLANK
        JZ      SRCH9
        CPI     TAB     ; OR TAB
        JNZ     SRCH8   ; MUST BE A LETTER
SRCH9:  ORA     A       ; CLEAR CARRY
        RET
;
SRCH3:  INX     D
SRCH2:  INX     D
        INX     D       ; BYPASS COMMAND ADDRESS
        INX     D
        POP     H
        JMP     SEARCH  ; AND LOOK SOME MORE
;
;
;-----
; SET - SET PARAMETER AND CHECK RANGE
; ACCEPTS:  A = ARGTYP
;          BC = DEFAULT VALUE
;          DE = ARGUMENT VALUE
;          HL = PARAMETER VALUE
;          TOP OF STACK = MAXIMUM VALUE
;          NEXT STACKED = MINIMUM VALUE
; RETURNS: HL = NEW PARAMETER VALUE
;-----
;
PSET:   CPI NEWLINE     ;IS THERE AN ARGUMENT?
        JZ DEFAULTED    ;NO
        CPI '+'         ;YES, INCREASE?
        JZ RELPLUS      ;YES
        CPI '-'         ;NO, DECREASE?
        XCHG            ;(ASSUME NOT: USE ABSOLUTE ARGUMENT)
        JZ RELMINUS     ;YES
MINMAX: POP B           ;GET RETURN ADDRESS
        POP D           ;HL = PARAM, GET MAXVAL
        CALL MIN        ;USE SMALLER OF MAXVAL AND PARAM
        POP D           ;GET MINVAL
        CALL MAX        ;USE LARGER OF MINVAL AND PARAM
        PUSH B
        RET
DEFAULTED:
        MOV H,B         ;USE DEFVAL
        MOV L,C         ;FOR PARAM
        JMP MINMAX
RELPLUS:
        DAD D           ;INCREASE PARAM
        JMP MINMAX
RELMINUS:
        CALL DELESSHL   ;DECREASE PARAM
        JMP MINMAX
;
;-----
; SKIP - OUTPUT BLANK LINES
; ACCEPTS:  HL = # OF LINES TO SKIP
;-----
;
SKIP:   MOV     A,H
        ORA L
        RZ
        MVI A,NEWLINE
        CALL PUTC
        DCX H
        JMP SKIP
;
;-----
; SPACE - SPACE SOME LINES OR TO BOTTOM OF PAGE
; ACCEPTS: HL = # OF LINES
;-----
;
SPACE:  CALL BRK
        MOV B,H
        MOV C,L
        LHLD BOTTOM
        XCHG
        LHLD LINENO
        CALL COMPARE
        RC
        PUSH B
        MOV A,H
        ORA L
        CZ PHEAD
        INX D
        CALL DELESSHL
        POP B
        MOV D,B
        MOV E,C
        CALL MIN
        CALL SKIP
        LHLD LINENO
        DAD B
        SHLD LINENO
        XCHG
        LHLD BOTTOM
        XCHG
        CALL COMPARE
        CC PFOOT
        RET
;
;-----
; SPREAD - SPREAD WORDS TO JUSTIFY RIGHT MARGIN
;-----
;
SPREAD: LXI D,0
        LHLD NEXTRA
        CALL COMPARE
        RNC
        INX D
        LHLD OUTWDS
        CALL COMPARE
        RNC
        LDA DIR
        CMA
        STA DIR
        DCX H
        SHLD NHOLES
        LHLD NEXTRA
        SHLD NNE
        XCHG
        LHLD OUTP
        DCX H
        PUSH H
        DAD D
        LXI D,TRIPLE-2
        CALL MIN
        LXI D,OUTBUF
        DAD D
        XTHL
        DAD D
        POP D
        XCHG
SPLOOP: DCX D
        DCX H
        CALL COMPARE
        RNC
        LDAX D
        MOV M,A
        CPI ' '
        JNZ SPLOOP
        PUSH D
        PUSH H
        LDA DIR
        PUSH PSW
        LHLD NNE
        CPI 0
        JNZ SP1
        DCX H
SP1:    XCHG
        LHLD NHOLES
        CALL DIVIDE
        POP PSW
        CPI 0
        JNZ SP2
        INX H
SP2:    SHLD NB
        XCHG
        LHLD NNE
        XCHG
        CALL DELESSHL
        SHLD NNE
        LHLD NHOLES
        DCX H
        SHLD NHOLES
        LXI D,0
        LHLD NB
SP3:    CALL COMPARE
        JNC SP4
        XTHL
        DCX H
        MVI M,' '
        XTHL
        DCX H
        JMP SP3
SP4:    POP H
        POP D
        JMP SPLOOP
;-----
; TABS - EXPAND TABS IN A LINE TO SPACES USING A TABPOS ARRAY
; ACCEPTS: HL = ADDR OF LINE
; RETURNS: HL UNCHANGED
;-----
;
TABS:   PUSH    H       ; SAVE FOR EXIT
        MVI     B,1     ; B COUNTS POSITION OF CHAR IN LINE
        LXI     D,TABPOS+10 ; ADDRESS OF FIRST TAB STOP
; LOOK FOR A TAB
TABS2:  MOV     A,M     ; GET CHAR
        CPI     TAB     ; IS IT A TAB?
        JZ      TABS4   ; YES
        CPI     EOS     ; IS IT THE END OF THE LINE
        JZ      TABSX   ; YES
TABS3:  INX     H       ; ADVANCE TO NEXT CHAR IN LINE
        INR     B       ; ADVANCE POSITION COUNT
        JMP     TABS2
TABS4:  LDA     FILL    ; IF WE NOT FILLING
        CPI     YES
        JZ      TABS5
        MVI     C,' '   ; USE A SPACE
        JMP     TABS6   ; OTHERWISE
TABS5:  MVI     C,NONEX ; USE A NON-EXPANDABLE BLANK
TABS6:  MOV     M,C     ; REPLACE TAB
TABS7:  INX     H
        INR     B
TABS8:  LDAX    D       ; GET TAB STOP POSITION
        CPI     0       ; AT END?
        JZ      TABSX   ; YES
        CMP     B       ; CHECK IT AGAINST LINE POSITION
        JZ      TABS3   ; ONE POSITION TOOK US TO NEXT STOP
        JC      TABS9   ; TRY THE NEXT TAB STOP
        CALL    EXTEND  ; MOVE THE LINE BY INSERTING REG C
        JMP     TABS7   ; SEE IF AT STOP NOW
;
TABS9:  DCX     D       ; TRY NEXT TAB STOP POSITION
        JMP     TABS8
;
TABSX:  POP     H
        RET
;
;-----
; TABSET - SCAN COMMAND LINE FOR TAB STOP POSITIONS
; ACCEPTS: HL = FIRST VALUE
;-----
;
;
TABSET:         ; SET TABSTOP ARRAY
        LXI     B,10
        MVI     A,NO    ; TURN OFF
        STA     TABSON  ; TABS. (DEFAULT)
TABSE2: MOV     A,L     ; GET FIRST VALUE
        LXI     H,TABPOS        ; ARRAY OF STOPS
        DAD     B
        MOV     M,A     ; AND STORE IT
        CPI     0       ; IF ZERO,
        RZ              ; WE ARE DONE
        MVI     A,YES
        STA     TABSON  ; TURN ON TABS
        XCHG            ; HL POINTS AT DELIM. OF VALUE
        PUSH    B       ; SAVE COUNT
        CALL    GETVAL  ; LOOK FOR MORE TAB POSITIONS
        POP     B
        DCX     B
        JNZ     TABSE2
        RET
;
;-----
; TEXT - PROCESS TEXT LINES
; ACCEPT:  HL = ADDR LINE
;-----
;
TEXT:   LDA     TABSON  ; SHOULD WE LOOK FOR TABS?
        CPI     NO
        JZ      TEXT2
        CALL    TABS    ; GO CONVERT TABS
TEXT2:  MOV A,M
        CPI ' '
        JZ MOVLFT
        CPI NEWLINE
        JNZ UNDERG
MOVLFT: CALL LEADBL
UNDERG:
        PUSH H
        LXI D,0
        LHLD ULVAL
        CALL COMPARE
        JNC CENTG
        LXI H,TRIPLE
        LXI D,WRDBUF
        POP B
        PUSH B
        CALL UNDERL
        LHLD ULVAL
        DCX H
        SHLD ULVAL
CENTG:
        LXI D,0
        LHLD CEVAL
        CALL COMPARE
        JNC ALLBLANK
        POP H
        CALL CTR
        CALL PUT
        LHLD CEVAL
        DCX H
        SHLD CEVAL
        RET
ALLBLANK:
        POP H
        MOV A,M
        CPI NEWLINE
        JNZ UNFILLED
        CALL PUT
        RET
UNFILLED:
        LDA FILL
        CPI NO
        JNZ FILLED
        CALL PUT
        RET
FILLED: CALL GETWRD
        RC
        CALL PUTWRD
        XCHG
        JMP FILLED
;
;-----
; UNDERL - UNDERLINE A LINE
; ACCEPTS:  BC = ADDR LINE
;           DE = ADDR TEMPORARY BUFFER
;           HL = SIZE OF LINE BUFFERS
;
;-----
;
UNDERL: PUSH B
        PUSH D
        DAD D           ;GET ADDR END OF TEMP BUF +1
        DCX H           ;GET ADDR LAST POSSIBLE CHAR POSITION
        DCX H           ;(NEWLINE & EOS TAKE LAST TWO)
        DCX H
        DCX H
        DCX H
        XCHG            ;DE "= ADDR LAST,  HL := TEMP BUF
UNLOOP: LDAX B
        CPI NEWLINE
        JZ ULINED
        CALL COMPARE
        JC ULINED
        LDAX B
        INX B
        MOV M,A
        INX H
        CPI ' '
        JZ UNLOOP
        CPI TAB
        JZ UNLOOP
        CPI BACKSPACE
        JZ UNLOOP
        MVI M,BACKSPACE
        INX H
        MVI M,'_'
        INX H
        JMP UNLOOP
ULINED: MVI M,NEWLINE
        INX H
        MVI M,EOS
        POP D
        POP H
        CALL SCOPY
        RET
;
;-----
; WIDTH - COMPUTE WIDTH OF CHARACTER STRING
; ACCEPTS:  HL = ADDR STRING
; RETURNS:  DE = WIDTH
;-----
;
WIDTH:  LXI D,0
WIDNXT: MOV A,M
        CPI EOS
        RZ
        INX H
        CPI BACKSPACE
        JZ NEGWID
        CPI NEWLINE
        JZ WIDNXT
        INX D
        JMP WIDNXT
;
NEGWID: DCX D
        JMP WIDNXT
;
OPTR:   DS      2       ; POINTER INTO DISK OUTPUT BUFFER
        DS      48
STACK   EQU     $
;
DBUFF   EQU     (($ SHR 8)+1) SHL 8     ;START OF FREE STORAGE FOR DISK BUFFER
;
        END
@