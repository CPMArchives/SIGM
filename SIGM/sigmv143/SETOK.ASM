; SETOK v1.0      OKIDATA PRINTER UTILITY          10/10/82
;
;                            by
;                       IRVIN M. HOFF
;                LOS ALTOS HILLS, CA  94022
;
;
;     This program sets an OKIDATA printer to various configur-
;     ations such as:
;
;              10 CPI or 16.5 CPI
;              6 or 8 vertical lines per inch
;              64 (short) or 80 (long) char. per line
;
;     There are numerous other selections that could be added.
;     This program should give you the background to include
;     other options, if desired, yourself.  These seemed the
;     most important.
;
;
;
;     COMMAND CHARACTERS FOR THE OKIDATA PRINTER:
;
;        17          CTL Q      Enable printer to receive data
;        27,'A'      ESC A      80 char. per line starting col. 3
;        27,'B'      ESC B      64 char. per line starting col. 9
;        29        CTL-SHFT-M   16.5 Characters per inch
;        30        CTL-SHFT-N   10 Characters per inch
;        31        CTL-SHFT-O   Wider characters
;        27,'6'      ESC 6      6 vertical lines per inch (Normal)
;        27,'8'      ESC 8      8 vertical lines per inch
;
; +   +   +   +   +   +   +   +   +   +   +   +   +   +   +   +   +   +
;
;
	ORG	100H
;
;
        JMP   START          ;JUMP INTO PROGRAM
;
;
; GENERAL EQU'S
;
BDOS    EQU   5              ;SYSTEM CALL ENTRY POINT
CONIN   EQU   1              ;GET KEYBOARD CHARACTER
CR      EQU   0DH            ;CONTROL-M FOR CARRIAGE RETURN
CONOUT  EQU   2              ;CRT OUTPUT ROUTINE
CTLC    EQU   3              ;CONTROL-C TO TERMINATE
ESC     EQU   1BH            ;ESCAPE CHARACTER
LF      EQU   0AH            ;CONTROL-J FOR LINE FEED
LIST    EQU   5              ;LIST DEVICE OUTPUT
STRING  EQU   9              ;PRINT STRING ON CONSOLE
TAB     EQU   09H            ;CONTROL-I FOR HORIZONTAOL TAB
;.....
;
;
; DATA STRINGS TO CONTROL EPXON MX-80 PRINTER
;
CN:     DB    ESC,'A',29,ESC,'6',0       ;16.5 CPI, NORMAL
UCN:    DB    ESC,'A',30,ESC,'6',0       ;10 CPI, NORMAL
DEFLT:  DB    17,ESC,'A',30,ESC,'6',0    ;DEFAULT PARAMETERS
EMPH:   DB    31,0                       ;EMPHASIZED
EIGHT:  DB    ESC,'8',0                  ;8 LINES PER INCH
SHORT:  DB    ESC,'B',0                  ;64 CHAR. LINES AT COL. 9
TURNUP: DB    CR,LF,'$'
;.....
;
;
; SIGN-ON MESSAGE
;
SOM:    DB    CR,LF,LF,LF,LF,LF,LF,LF
        DB    TAB,TAB,'OKIDATA Printer options v1.0 10/11/82'
        DB    CR,LF,LF,TAB,TAB,'0 = Reset to default parameters'
        DB    CR,LF,LF,TAB,TAB,'1 = 10   CPI, Normal'
        DB    CR,LF,TAB,TAB,'2 = 16.5 CPI, Normal'
        DB    CR,LF,LF,TAB,TAB,'3 = Wider Characters'
        DB    CR,LF,TAB,TAB,'4 = 64 Char. lines starting at col. 9'
        DB    CR,LF,TAB,TAB,'8 = 8 vertical lines per inch'
        DB    CR,LF,LF,LF,LF,LF,LF,LF,TAB,'Select: '
        DB    '$'
;.....
;
;
;**********************************************************************;
;                                                                      ;
;                     PROGRAM STARTS HERE                              ;
;                                                                      ;
;**********************************************************************;
;
;
START:  POP   H              ;RETURN ADDRESS TO 'CCP'
        SHLD  EXIT1+1        ;STORE
        LXI   SP,STACK       ;SET UP STACK
        LXI   D,SOM          ;SIGNON MESSAGE
        CALL  DSTRNG         ;SHOW ON THE CRT
        LXI   H,DEFLT        ;SET THE PRINTER TO NORMAL CONDITIONS
        JMP   PSTRNG
;...
;
;
SELECT: CALL  INPUT          ;GET A CHAR.
;
        CPI   '0'            ;RESET TO DEFAULT PARAMETERS
        LXI   H,DEFLT
        JZ    PSTRNG
;
        CPI   '1'
        LXI   H,UCN          ;10 CPI, NORMAL
        JZ    PSTRNG
;
        CPI   '2'
        LXI   H,CN           ;16.5 CPI, NORMAL
        JZ    PSTRNG
;
        CPI   '3'
        LXI   H,EMPH         ;EMPHASIZED
        JZ    PSTRNG
;
        CPI   '4'
        LXI   H,SHORT        ;64 CHARACTER LINES STARTING AT COL. 9
        JZ    PSTRNG
;
        CPI   '8'
        LXI   H,EIGHT        ;GO TO 8 VERTICAL LINES PER INCH
        JZ    PSTRNG
;
        JMP   SELECT         ;IF NONE OF THESE, ASK AGAIN
;.....
;
;
;======================================================================;
;                                                                      ;
;                     ROUTINES START HERE                              ;
;                                                                      ;
;======================================================================;
;
;
EXIT:   LXI   D,TURNUP       ;TURN UP SOME EXTRA LINES
        CALL  DSTRNG         ;DISPLAY ON THE CRT
;
EXIT1:  JMP   0              ;FILLED BY 'START' FOR RETURN TO 'CCP'
;.....
;
;
; GET A KEYBOARD CHARACTER
;
INPUT:1 MVI   C,CONIN        ;KEYBOARD ROUTINE
        CALL  BDOS
        ANI   7FH            ;STRIP AWAY ANY PARITY
        CPI   CTLC           ;CONTROL-C?
        JZ    EXIT           ;IF YES, ALL FINISHED
        CPI   CR             ;CONTROL-M FOR RETURN?
        JZ    EXIT           ;IF YES, ALL FINISHED
        RET
;.....
;
;
; DISPLAY A STRING ON THE CRT
;
DSTRNG: MVI   C,STRING       ;CONSOLE STRING ROUTINE
        JMP   BDOS           ;SEND TO THE CRT
;.....
;
;
; PRINT A STRING OF CHARS. ON THE EPSON MX-80
;
PSTRNG: MOV   A,M            ;GET THE CHARACTER IN THE STRING
        ORA   A              ;SEE IF FINISHED YET
        JZ    SELECT         ;GET NEW ANSWER IF ZERO
;
        PUSH  H              ;SAVE THE ADDRESS IN THE STRING
        MVI   C,LIST         ;PRINTER ROUTINE
        MOV   E,A            ;PUT THE CHAR. INTO 'E' REG.
        CALL  BDOS           ;SEND TO THE PRINTER
        POP   H              ;BACK TO THE STRING ADDRESS
        INX   H              ;NEXT LOCATION
        JMP   PSTRNG         ;DO THE NEXT ONE
;.....
;
;
;	STACK AREA
;
	DS	20H            ;ALLOW ROOM FOR STACK
;
STACK	DS	0
;
	END
