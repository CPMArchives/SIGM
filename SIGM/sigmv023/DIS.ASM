
;
;       TDL BASED Z80 DISASSEMBLER
;       BASED ON A Z80-ZAP DISASSEMBLER FROM
;       DDJ, MAY, 1979 BY B.W. LEE
;       ADAPTED FOR CPM BY TIM BURKE
;       SEPTEMBER, 1979.
;
        .TITLE  "Z80 DISASSEMBLER"
        .SBTTL  "TIM BURKE, SEPT., 1979"
        .LADDR
        .LALL
        .PABS
;
;       SYSTEM EQUATES
;
MSIZE   =       47      ;56K-DRIVERS(4K)-I/O(1K)
;	MSIZE WAS 56 FOR TIMS VERSION
BIASC   =       (MSIZE-16)*1024
PRSIZE  =       PREND-PRBEG
LOCATE  =       3100H+BIASC-PRSIZE
PRLOC   =       9000H
SYCOUN  =       900     ;NUMBER OF SYMBOLS
SYMNUM  =       SYCOUN*7
;
;
BDOSV   =       5       ;DOS ENTRY
WBOOTV  =       0       ;WARM BOOT
WTFN    =       9       ;CONSOLE BUFF. WRITE
RDFN    =       10      ;BUFF. READ
COFN    =       2       ;CONSOLE CHAR. WRITE
FCB     =       5CH     ;READ FCB ADD.
OPENF   =       15      ;FILE OPEN
BUFF    =       80H     ;READ BUFF. ADD.
READF   =       20      ;READ SECTOR
LOGIN   =       14      ;LOG IN DISK
SEARCH  =       17      ;SEARCH FOR FILE
DELETE  =       19      ;ERASE FILE
MAKEF   =       22      ;CREATE FILE
SDMA    =       26      ;SET DMA ADD.
DWRIT   =       21      ;WRITE SECTOR
CLSFN   =       16      ;CLOSE FILE
CR      =       0DH
LF      =       0AH
TAB     =       'I'-40H
TRUE    =       0FFH
FALSE   =       0
;
;
        .LOC    PRLOC
;
;
PRBEG:  LXI     SP,STKTOP
        LHLD    BDOSV+1
        SHLD    BDOS+1
        LHLD    WBOOTV+1
        SHLD    WBOOT+1
        XRA     A
        STA     CBYTE
        STA     KBYTE
        STA     FCBW+32
        STA     FCBW+12
        JMPR    ENTRE
BDOS:   JMP     BDOSV
WBOOT:  JMP     WBOOTV
ENTRE:  LXI     D,HERALD
        MVI     C,WTFN
        CALL    BDOS
EXPR:   LXI     SP,STKTOP
        LXI     D,ENMES
        MVI     C,WTFN
        CALL    BDOS
        LXI     D,RDBUF
        MVI     C,RDFN
        CALL    BDOS
        LDA     RDCNT
        CPI     0
        JRZ     EXPR
        LXI     H,COMAND
        LDA     RDCNT
        MOV     B,A
UCON1:  MOV     A,M
        CPI     91
        JM      UCON2
        SUI     32
UCON2:  MOV     M,A
        INX     H
        DJNZ    UCON1
        LXI     X,COMAND
POINT:  MOV     A,0(X)
        INX     X
        CPI     ' '
        JRNZ    TST1
        LDA     RDCNT
        DCR     A
        STA     RDCNT
        JMPR    POINT
TST1:   CPI     'D'
        JRNZ    TST2
        JMP     DISASM
TST2:   CPI     'H'
        JRNZ    TST3
        JMP     HEXMAT
TST3:   CPI     'R'
        JRNZ    TST4
        JMP     RDFILE
TST4:   CPI     'O'
        JRNZ    TST5
        JMP     OPTION
TST5:   CPI     'M'
        JRNZ    TST6
        JMP     MOVEM
TST6:   CPI     'Q'
        JRNZ    TST7
        CALL    CRLF
        LXI     D,FINMES
        MVI     C,WTFN
        CALL    BDOS
        LHLD    SYMBC
        CALL    LADR
        CALL    CRLF
        JMP     WBOOT
TST7:   CPI     'S'
        JRNZ    TST8
        JMP     SHOW
TST8:   CPI     'T'
        JNZ     TST9
        JMP     TYPEIT
TST9:   CPI     'C'
        JNZ     EXPR
        LDA     FCBW+32
        ORA     A
        JRNZ    VERDI
        LDA     FCBW+12
        ORA     A
        JZ      EXPR
VERDI:  XRA     A
        STA     TABC
        LXI     H,ESFSG
        MVI     B,ESFSL
AFTERA: MOV     C,M
        CALL    PO
        INX     H
        DJNZ    AFTERA
        JMP     CDKF
;
;
HEXMAT: CALL    CRLF
        CALL    CRLF
        CALL    PARAM
        LHLD    BIAS
        LDED    RELO
        PUSH    H
        DAD     D
        CALL    LADR
        MVI     C,' '
        CALL    CO
        POP     H
        ORA     A
        DSBC    D
        CALL    LADR
        CALL    CRLF
        JMP     EXPR
;
;
TYPEIT: CALL    CRLF
        CALL    PARAM
        LHLD    BIAS
        LDED    RELO
..T0D:  CALL    LFADR
        MVI     B,16
..T1D:  MOV     A,M
        ANI     7FH
        CPI     ' '
        JRNC    ..T3D
..T2D:  MVI     A,'.'
..T3D:  CPI     07CH
        JRNC    ..T2D
        MOV     C,A
        CALL    CO
        CALL    HILOX
        DJNZ    ..T1D
        JMPR    ..T0D
MOVEM:  CALL    CRLF
        CALL    PARAM
        LHLD    BIAS
        LDED    RELO
        LBCD    OFFST
..M:    MOV     A,M
        STAX    B
        INX     B
        CALL    HILOX
        JMPR    ..M
HILOX:  CALL    HILO
        RNC
        JMP     EXPR
HILO:   INX     H
        MOV     A,H
        ORA     L
        STC
        RZ
        MOV     A,E
        SUB     L
        MOV     A,D
        SBB     H
        RET
;
;
SHOW:   CALL    CRLF
        CALL    PARAM
        LHLD    BIAS
        LDED    RELO
..D0:   CALL    LFADR
..D1:   CALL    BLK
        MOV     A,M
        CALL    LBYTE
        CALL    HILOX
        MOV     A,L
        ANI     0FH
        JRNZ    ..D1
        JMPR    ..D0
;
;
RDFILE: LXI     Y,FCB
        CALL    BLANK
        LXI     Y,FCB
        CALL    FORMIT
        CALL    CRLF
        LXI     B,3
        LXI     H,COMEX
        LXI     D,FCB+9
        LDIR
        LXI     D,FCB
        MVI     C,OPENF
        CALL    BDOS
        CPI     255
        JRNZ    OPNOK
        CALL    CRLF
        LXI     D,OPNM
        MVI     C,WTFN
        CALL    BDOS
        JMP     EXPR
OPNOK:  XRA     A
        STA     FCB+32
        LXI     D,100H
LOOP:   LXI     H,BUFF
        CALL    DISKR
        MVI     B,128
CONTE:  MOV     A,M
        XCHG
        MOV     M,A
        XCHG
        INX     H
        INX     D
        DJNZ    CONTE
        JMPR    LOOP
DISKR:  PUSH    H
        PUSH    D
        PUSH    B
        LXI     D,FCB
        MVI     C,READF
        CALL    BDOS
        POP     B
        POP     D
        POP     H
        CPI     0
        RZ
        CPI     1
        JZ      FINAL
        CALL    CRLF
        LXI     D,RDERRM
        MVI     C,WTFN
        CALL    BDOS
        JMP     EXPR
FINAL:  CALL    CRLF
        LXI     D,MESA3
        MVI     C,WTFN
        CALL    BDOS
        LDA     FCB+12
        MOV     H,A
        LDA     FCB+32
        MOV     L,A
        CALL    LADR
        MVI     B,7
SHIT:   SLAR    L
        RALR    H
        DJNZ    SHIT
        LXI     B,100H
        DAD     B
        PUSH    H
        CALL    CRLF
        LXI     D,MESA4
        MVI     C,WTFN
        CALL    BDOS
        POP     H
        CALL    LADR
        JMP     EXPR
;
;
OPTION: CALL    CRLF
        CALL    CRLF
        XRA     A
        STA     CBYTE
        STA     KBYTE
        MOV     D,A
        MOV     E,A
        LDA     RDCNT
        DCR     A
        JZ      EXPR
        PUSH    D
        LXI     D,OPTMES
        MVI     C,WTFN
        CALL    BDOS
        POP     D
        LDA     RDCNT
        MOV     H,A
LOPIT:  MOV     A,0(X)
        MOV     C,A
        INX     X
        DCR     H
        JRZ     NOWPT
        CPI     'A'
        JRNZ    TMT1
        SET     0,D
        CALL    CO
        JMPR    LOPIT
TMT1:   CPI     'B'
        JRNZ    TMT2
        SET     1,D
        CALL    CO
        JMPR    LOPIT
TMT2:   CPI     'C'
        JRNZ    TMT3
        SET     2,D
        CALL    CO
        JMPR    LOPIT
TMT3:   CPI     'D'
        JRNZ    TMT4
        SET     3,D
        CALL    CO
        JMPR    LOPIT
TMT4:   CPI     'E'
        JRNZ    TMT5
        SET     4,D
        CALL    CO
        JMPR    LOPIT
TMT5:   CPI     'F'
        JRNZ    TMT6
        SET     5,D
        CALL    CO
        JMPR    LOPIT
TMT6:   CPI     'G'
        JRNZ    TMT7
        SET     6,D
        CALL    CO
        JMPR    LOPIT
TMT7:   CPI     'H'
        JRNZ    TMT8
        SET     7,D
        CALL    CO
        JMPR    LOPIT
TMT8:   CPI     'I'
        JRNZ    TMT9
        SET     0,E
        CALL    CO
        JMPR    LOPIT
TMT9:   CPI     'J'
        JRNZ    TMT10
        SET     1,E
        CALL    CO
        JMPR    LOPIT
TMT10:  CPI     'K'
        JRNZ    LOPIT
        SET     2,E
        CALL    CO
        JMP     LOPIT
NOWPT:  CALL    CRLF
        CALL    CRLF
        MOV     A,D
        STA     CBYTE
        MOV     A,E
        STA     KBYTE
        JMP     EXPR
;
;
;       SUBROUTINES
;
CRLF:   MVI     C,CR
        CALL    CO
        MVI     C,LF
        CALL    CO
        RET
LFADR:  CALL    CRLF
HLSP:   CALL    LADR
BLK:    MVI     C,' '
CO:     PUSH    B
        PUSH    H
        PUSH    D
        MVI     D,0
        MOV     E,C
        MVI     C,COFN
        CALL    BDOS
        POP     D
        POP     H
        POP     B
        MOV     A,C
        RET
PARAM:  LXI     H,0
        SHLD    BIAS
        SHLD    RELO
        SHLD    OFFST
        LDA     RDCNT
        DCR     A
        RZ
        MOV     C,A
DREN:   MOV     A,0(X)
        CPI     ' '
        JRNZ    BRA2
        DCR     C
        INX     X
        RZ
        JMPR    DREN
BRA2:   CALL    CONVER
        JRC     ..EX1
        DAD     H
        DAD     H
        DAD     H
        DAD     H
        ORA     L
        MOV     L,A
        DCR     C
        JRNZ    BRA2
        SHLD    BIAS
        RET
..EX1:  SHLD    BIAS
        MOV     A,B
        CPI     ' '
        JRZ     CONT
        CPI     ','
        JRZ     CONT
        JMP     EXPR
CONT:   LXI     H,0
        DCR     C
        RZ
BRA1:   CALL    CONVER
        JRC     ..EX2
        DAD     H
        DAD     H
        DAD     H
        DAD     H
        ORA     L
        MOV     L,A
        DCR     C
        JRNZ    BRA1
        SHLD    RELO
        RET
..EX2:  SHLD    RELO
        MOV     A,B
        CPI     ' '
        JRZ     CONT1
        CPI     ','
        JRZ     CONT1
        JMP     EXPR
CONT1:  LXI     H,0
        DCR     C
        RZ
BRA3:   CALL    CONVER
        JC      EXPR
        DAD     H
        DAD     H
        DAD     H
        DAD     H
        ORA     L
        MOV     L,A
        DCR     C
        JRNZ    BRA3
        SHLD    OFFST
        RET
CONVER: MOV     A,0(X)
        INX     X
        MOV     B,A
CONV:   SUI     '0'
        RC
        CPI     'G'-'0'
        CMC
        RC
        CPI     10
        CMC
        RNC
        SUI     'A'-'9'-1
        CPI     0AH
        RET
LADR:   MOV     A,H
        CALL    LBYTE
        MOV     A,L
LBYTE:  PUSH    PSW
        RRC
        RRC
        RRC
        RRC
        CALL    ..2
        POP     PSW
..2:    CALL    ZONV
        JMP     CO
ZONV:   ANI     0FH
        ADI     90H
        DAA
        ACI     40H
        DAA
        MOV     C,A
        RET
BLANK:  MVI     A,1
        MOV     0(Y),A
        MVI     B,11
        MVI     A,' '
LPAGE:  INX     Y
        MOV     0(Y),A
        DCR     B
        JRNZ    LPAGE
        XRA     A
        MVI     B,21
OVAGP:  INX     Y
        MOV     0(Y),A
        DCR     B
        JRNZ    OVAGP
        RET
FORMIT: LDA     RDCNT
        DCR     A
        JZ      EXPR
        MOV     C,A
ALTOS:  MOV     A,0(X)
        CPI     ' '
        JRNZ    NITS
        DCR     C
        INX     X
        JZ      EXPR
        JMPR    ALTOS
NITS:   MOV     A,1(X)
        CPI     ':'
        JRZ     FOUND1
        JMPR    FORT2
FOUND1: MOV     A,0(X)
        INX     X
        INX     X
        DCR     C
        DCR     C
        SUI     64
        MOV     0(Y),A
FORT2:  INX     Y
        MOV     A,0(X)
        CPI     '.'
        RZ
        MOV     0(Y),A
        INX     X
        DCR     C
        JRNZ    FORT2
        RET
TOM1:   MOV     C,M
        INX     H
        CALL    CO
        DJNZ    TOM1
        RET
RSDF:   LXI     D,OFCMD
        MVI     C,WTFN
        CALL    BDOS
        LXI     D,RDBUF
        MVI     C,RDFN
        CALL    BDOS
        LDA     RDCNT
        CPI     0
        JRZ     RSDF
        LXI     H,COMAND
        LDA     RDCNT
        MOV     B,A
ACON1:  MOV     A,M
        CPI     91
        JM      ACON2
        SUI     32
ACON2:  MOV     M,A
        INX     H
        DCR     B
        JRNZ    ACON1
        LXI     X,COMAND
POINTA: MOV     A,0(X)
        INX     X
        CPI     ' '
        JRNZ    OKNDT
        LDA     RDCNT
        DCR     A
        STA     RDCNT
        JMPR    POINTA
OKNDT:  LXI     Y,FCBW
        LDA     RDCNT
        INR     A
        STA     RDCNT
        DCX     X
        CALL    BLANK
        LXI     Y,FCBW
        CALL    FORMIT
        LXI     B,3
        LXI     H,TDLT
        LXI     D,FCBW+9
        LDIR
        LDA     FCBW
        DCR     A
        MVI     D,0
        MOV     E,A
        MVI     C,LOGIN
        CALL    BDOS
        LXI     D,FCBW
        MVI     C,SEARCH
        CALL    BDOS
        CPI     255
        JRZ     MAKE
        LXI     D,FCBW
        MVI     C,DELETE
        CALL    BDOS
MAKE:   LXI     D,FCBW
        MVI     C,MAKEF
        CALL    BDOS
        CPI     255
        JRNZ    OPEN
        CALL    CRLF
        LXI     D,DIREM
        MVI     C,WTFN
        CALL    BDOS
OPEN:   LXI     D,FCBW
        MVI     C,OPENF
        CALL    BDOS
        CPI     255
        JRNZ    OOKK
        CALL    CRLF
        LXI     D,OPNM
        MVI     C,WTFN
        CALL    BDOS
        JMP     EXPR
OOKK:   XRA     A
        STA     FCBW+32
        STA     WTPTR
        RET
PEOL:   MVI     C,CR
        CALL    PO
        MVI     C,LF
PO:     PUSH    X
        LXI     X,FCBW
        CALL    WDSKF
        POP     X
        RET
WDSKF:  PUSH    H
        PUSH    D
        PUSH    B
        LDA     WTPTR
        CPI     80H
        JRNZ    WTBYT
        CALL    DISKWR
        XRA     A
WTBYT:  MOV     E,A
        MVI     D,0
        INR     A
        STA     WTPTR
        LXI     H,WTBUF
        DAD     D
        MOV     M,C
        POP     B
        POP     D
        POP     H
        MOV     A,C
        RET
DISKWR: PUSH    B
        LXI     D,WTBUF
        MVI     C,SDMA
        CALL    BDOS
        PUSH    X
        POP     D
        MVI     C,DWRIT
        CALL    BDOS
        PUSH    PSW
        LXI     D,BUFF
        MVI     C,SDMA
        CALL    BDOS
        POP     PSW
        CPI     0
        JRZ     BNC2
        CALL    CRLF
        LXI     D,WEMS1
        MVI     C,WTFN
        CALL    BDOS
        POP     H
        POP     H
        POP     H
        POP     H
        CALL    LADR
        CALL    CRLF
        JMP     ABTRR
BNC2:   POP     B
        RET
CONSTA: PUSH    H
        PUSH    D
        PUSH    B
        MVI     C,11
        CALL    BDOS
        ANI     1
        JRNZ    TRUX
        XRA     A
        JMPR    EXST1
TRUX:   MVI     A,TRUE
EXST1:  POP     B
        POP     D
        POP     H
        RET
CI:     PUSH    H
        PUSH    D
        PUSH    B
        MVI     C,1
        CALL    BDOS
        ANI     7FH
        POP     B
        POP     D
        POP     H
        RET
CDKF:   MVI     C,'Z'-40H
        CALL    PO
        LXI     X,FCBW
        CALL    DISKWR
ABTRR:  LXI     D,FCBW
        MVI     C,CLSFN
        CALL    BDOS
        CPI     255
        JNZ     EXPR
        CALL    CRLF
        LXI     D,CLEER
        MVI     C,WTFN
        CALL    BDOS
        CALL    CRLF
        JMP     EXPR
;
;       MAIN PROGRAM
;
DISASM: CALL    CRLF
        CALL    PARAM
        LHLD    BIAS
        LDED    RELO
        SHLD    BBUF
        SDED    EBUF
        LXI     H,SGNMG
        MVI     B,SNMGL
        CALL    TOM1
        .RADIX  16
BEGIN:  LDA     CBYTE
        ANI     2
        JRNZ    APNFL
NEWFL:  LDA     CBYTE
        ANI     04
        JRZ     KSFIN
        XRA     A
        STA     SYMTB
        LXI     H,0
        SHLD    SYMBC
        LXI     H,SYMNUM
        SHLD    SYMBC1
KSFIN:  LDA     CBYTE
        ANI     80
        JRZ     START
        CALL    RSDF
        CALL    PEOL
START:  LHLD    BBUF
DISAM:  CALL    LINE
        CALL    ENDCK
        JMPR    DISAM
APNFL:  LDA     KBYTE
        ANI     01
        JRNZ    KSFIN
        JMPR    START
LINE:   LDA     KBYTE
        ANI     04
        CZ      LADR
        MVI     A,0FC
        STA     TABC
        MVI     A,TAB
        CALL    TYPE
        MOV     B,H
        MOV     C,L
        LDA     CBYTE
        ANI     01
        CNZ     PRTLB
        JRNC    ..A0
        MVI     A,':'
        CALL    ZTYPE
..A0:   MVI     A,TAB
        CALL    ZTYPE
        LDA     CBYTE
        ANI     20
        JNZ     PRDB
        PUSH    H
        MOV     H,M
        LXI     B,OTABM
;
;       OPCODE TABLE LOOKUP
;
ULP:    LDAX    B
        ORA     A
        JZ      SFRET
        ANA     H
        MOV     L,A
        INX     B
        LDAX    B
        CMP     L
        JZ      FOUND
        MOV     A,C
        ADI     06
        MOV     C,A
        JRNC    ULP
        INR     B
        JMPR    ULP
;
FOUND:  INX     B
        LDAX    B
        STA     TYFLG
        PUSH    D
        MOV     E,A
        MVI     D,00
        LXI     H,JMTBL
        DAD     D
        DAD     D
        MOV     D,M
        INX     H
        MOV     H,M
        MOV     L,D
        POP     D
        XTHL
        RET
;
TYPE0:  CALL    PROP
IXHRT:  INX     H
        JMP     RET
;
TYPE1:  CALL    PROP
T1B:    CALL    REG
        JMPR    IXHRT
;
TYPE2:  CALL    PROP
        CALL    REGM
        JMPR    IXHRT
;
TYPE3:  CALL    PROP
        CALL    XR
        JMPR    IXHRT
;
TYPE4:  CALL    PROP
        CALL    REGM
T4B:    CALL    COMMA
        JMPR    T52
;
TYPE5:  CALL    PROP
T52:    INX     H
T53:    MOV     A,M
        CALL    X00
T54:    MVI     A,'H'
        CALL    ZTYPE
        MOV     A,M
        INX     H
        PUSH    B
        MOV     B,A
        LDA     CBYTE
        ANI     10
        MOV     A,B
        POP     B
        JZ      RET
        CPI     ' '
        JC      RET
        CPI     'Z'+1
        JNC     RET
        LDA     TYFLG
        CPI     04
        JC      RET
        CPI     06
        JNC     RET
        MVI     A,TAB
        CALL    ZTYPE
        MVI     A,';'
        CALL    ZTYPE
        DCX     H
        MOV     A,M
        INX     H
QCHAR:  PUSH    PSW
        CALL    OQ
        POP     PSW
        MVI     A,27
        CALL    ZTYPE
        JMP     RET
;
TYPE6:  CALL    PROP
        CALL    XR
T6B:    CALL    COMMA
        LDA     CBYTE
        ANI     40
        JRZ     TYP6H
PRT2X:  CALL    SYMBO
        JC      RET
TYP6H:  INX     H
        MOV     B,M
        INX     H
        MOV     A,M
        CALL    X00
        MOV     A,B
        CALL    X0
        JMPR    T54
;
TYPREL: CALL    PROP
        INX     H
        MOV     A,M
        CALL    X21
        JMP     T54
;
TYPE7:  CALL    PROP
        CALL    SYMBO
        JC      RET
        LDA     CBYTE
        ANI     08
        JRZ     TYP6H
        MVI     A,'L'
        CALL    ZTYPE
        INX     H
        MOV     B,M
        INX     H
        MOV     A,M
        CALL    X00
        MOV     A,B
        CALL    X0
        JMP     IXHRT
;
TYPE8:  INX     B
        LDAX    B
        STA     CC1
        CALL    GETCC
        JMPR    TYPE7
;
TYPE9:  MVI     A,'R'
        STA     CC1
        CALL    GETCC
        JMP     TYPE0
;
TYPEA:  CALL    PROP
        RAR
        RAR
        RAR
        ANI     07
        ADI     '0'
        CALL    ZTYPE
        JMP     IXHRT
;
TYPEB:  CALL    PROP
        CALL    REGM
        CALL    COMMA
        MOV     A,M
        JMP     T1B
;
TYPEC   =       TYPREL
;
TYPED:  INX     B
        LDAX    B
        STA     CC1-1
        INX     B
        LDAX    B
        STA     CC1
        MOV     A,M
        ANI     0DF
        CALL    GETC
        DCX     B
        JMP     TYPREL
;
TYPEE:  INX     H
        PUSH    H
        MOV     H,M
        LXI     B,OTABC
ULP1:   MVI     A,21
ULP2:   STA     TYFLG
        JMP     ULP
;
TYPEF:  INX     H
        PUSH    H
        MOV     H,M
        LXI     B,OTABE
        JMPR    ULP1
;
TYP10:  INX     B
        PUSH    B
        INX     H
        PUSH    H
        MOV     H,M
        MVI     A,0CB
        CMP     H
        JZ      TY10C
        LXI     B,OTBIR
        MVI     A,41
        JMPR    ULP2
;
TY10C:  POP     H
        INX     H
        INX     H
        PUSH    H
        MOV     H,M
        LXI     B,OTBIC
        MVI     A,43
        JMPR    ULP2
;
TYP11:  CALL    GRSCC
        JMP     TYPE1
;
TYP12:  CALL    PROP
        CALL    POTLM
        CALL    COMMA
        MOV     A,M
        JMP     T1B
;
TYP13:  INX     B
        LDAX    B
        STA     CC1
        INX     B
        INX     B
        INX     B
        LDAX    B
        STA     CCB
        CALL    GETXR
        JMP     TYPE7
;
TYP14:  INX     B
        LDAX    B
        STA     CC1
        INX     B
        LDAX    B
        STA     CC1+1
        CALL    GETBX
        JMP     TYPE0
;
TYP15:  MVI     A,'O'
        CALL    ZTYPE
        JMPR    TYP14
;
TYP16:  INX     B
        LDAX    B
        STA     CC1
        INX     B
        LDAX    B
        STA     CC1+1
        POP     B
        MVI     A,'I'
        STA     CC1+2
        INX     B
        LDAX    B
        STA     CCB
        LXI     B,CC1-1
        JMP     TYPE0
;
TYP17:  CALL    PROP
        POP     B
        CALL    PRIR
        JMP     IXHRT
;
TYP18:  CALL    PROP
        INX     H
        MOV     A,M
        CALL    X00
        POP     B
        CALL    PRIRP
        MVI     A,04
        STA     TYFLG
        JMP     T4B
;
TYP19:  CALL    PROP
        POP     B
        CALL    PRIR
        JMP     T6B
;
TYP1A:  INX     B
        LDAX    B
        STA     CC1
        INX     B
        INX     B
        INX     B
        LDAX    B
        STA     CCB
        POP     B
        MVI     A,'I'
        STA     CC1+1
        INX     B
        LDAX    B
        STA     CC1+2
        LXI     B,CC1-1
        JMP     TYPE7
;
TYP1B:  CALL    PROP
        INX     H
        MOV     A,M
        CALL    X00
        POP     B
        CALL    PRIRP
        DCX     H
        CALL    COMMA
        MOV     A,M
        CALL    REG
IXHHR:  INX     H
        JMP     IXHRT
;
TYP1C:  CALL    PROP
        CALL    REGM
        CALL    COMMA
        INX     H
        MOV     A,M
        CALL    X00
        POP     B
        CALL    PRIRP
        JMP     IXHRT
;
TYP1D:  CALL    PROP
        CALL    POTLM
        CALL    COMMA
TY1DB:  DCX     H
        MOV     A,M
        CALL    X00
        POP     B
        CALL    PRIRP
        JMPR    IXHHR
;
TYP1E:  CALL    GRSCC
        CALL    PROP
        JMPR    TY1DB
;
TYP1F:  CALL    PROP
        INX     H
        MOV     A,M
        CALL    X00
        POP     B
        CALL    PRIRP
        JMP     IXHRT
;
TYP20:  INX     B
        LDAX    B
        STA     CC1
        INX     B
        LDAX    B
        STA     CC1+1
        POP     B
        MVI     A,'D'
        STA     CC1+2
        INX     B
        LDAX    B
        STA     CCB
        LXI     B,CC1-1
        CALL    PROP
        CALL    TST20
        MOV     A,B
        CALL    ZTYPE
        JMP     IXHRT
TST20:  CPI     09
        MVI     B,'B'
        RZ
        CPI     19
        MVI     B,'D'
        RZ
        CPI     39
        JRNZ    ATST1
        MVI     A,'S'
        CALL    ZTYPE
        MVI     B,'P'
        RET
ATST1:  DCX     H
        MOV     A,M
        CPI     0DD
        JRNZ    YTST1
        MVI     B,'X'
        INX     H
        RET
YTST1:  INX     H
        MVI     B,'Y'
        RET
;
SFRET:  LDA     TYFLG
        CPI     20
        POP     H
        JC      PRDB
        CPI     40
        JRC     BKUPH
        POP     B
BKUPH:  ANI     0F
        MOV     B,A
        XRA     A
        STA     TYFLG
BUHLP:  DCX     H
        DJNZ    BUHLP
        JMP     PRDB
;
;       DISASSEMBLER SUBROUTINES
;
COMMA:  MVI     A,','
        JMP     ZTYPE
;
PRDB:   PUSH    H
        LXI     H,BYTSG
        MVI     B,BYSGL
PRDB1:  MOV     A,M
        CALL    ZTYPE
        INX     H
        DJNZ    PRDB1
        MVI     A,TAB
        CALL    ZTYPE
        POP     H
        LDA     CBYTE
        ANI     30
        CPI     30
        JNZ     T53
        MOV     A,M
        CPI     ' '
        JC      T53
        CPI     'Z'+1
        JNC     T53
        INX     H
        JMP     QCHAR
;
GETCC:  MOV     A,M
GETC:   RAR
        RAR
        ANI     0E
        PUSH    H
        LXI     H,CCTAB
        CALL    ADD
        MOV     A,M
        STA     CC1+1
        INX     H
        MOV     A,M
        STA     CC1+2
        POP     H
        LXI     B,CC1-1
        MVI     A,' '
        STA     CCB
        RET
;
HEXL:   RAR
        RAR
        RAR
        RAR
HEXR:   ANI     0F
        CPI     0A
        JC      HEXRN
        ADI     07
HEXRN:  ADI     '0'
        RET
;
X0:     PUSH    PSW
        CALL    HEXL
        CALL    ZTYPE
        POP     PSW
        CALL    HEXR
        JMP     ZTYPE
;
OQ:     PUSH    PSW
        MVI     A,' '
        CALL    ZTYPE
        MVI     A,27
        CALL    ZTYPE
        POP     PSW
        JMP     ZTYPE
;
PROP:   PUSH    D
        MVI     D,4
PROPL:  INX     B
        LDAX    B
        CALL    ZTYPE
        DCR     D
        JRNZ    PROPL
        MVI     A,TAB
        CALL    ZTYPE
        POP     D
        MOV     A,M
        RET
;
XR:     RAR
        RAR
        RAR
        ANI     06
        CPI     06
        JRNZ    REG
        MOV     A,M
        ORA     A
        JM      PRPSW
PRTSP:  MVI     A,'S'
        CALL    ZTYPE
        MVI     A,'P'
        JMP     ZTYPE
PRPSW:  MVI     A,'P'
        CALL    ZTYPE
        MVI     A,'S'
        CALL    ZTYPE
        MVI     A,'W'
        JMP     ZTYPE
;
REGM:   RAR
        RAR
        RAR
;
REG:    PUSH    H
        LXI     H,RTAB
        ANI     07
        CALL    ADD
        MOV     A,M
        POP     H
        JMP     ZTYPE
;
ADD:    ADD     L
        MOV     L,A
        RNC
        INR     H
        RET
;
X21:    PUSH    H
        PUSH    PSW
        DCX     H
        MOV     A,M
        CPI     10
        JZ      RELADD
        CPI     38
        JZ      RELADD
        CPI     18
        JZ      RELADD
        CPI     30
        JZ      RELADD
        CPI     20
        JZ      RELADD
        CPI     28
        JZ      RELADD
X000:   POP     PSW
        POP     H
X00:    CPI     0A0
        JC      X0
        PUSH    PSW
        MVI     A,'0'
        CALL    ZTYPE
        POP     PSW
        JMP     X0
RELADD: PUSH    D
        MVI     D,0
        INX     H
        MOV     A,M
        INX     H
        ORA     A
        JM      SUBIT
        MOV     E,A
        DAD     D
        SHLD    TEMHL
        JMPR    ZIPIT
SUBIT:  CMA
        ADI     01
        MOV     E,A
        SLAR    D
        DSBC    D
        SHLD    TEMHL
ZIPIT:  LXI     H,TEMHL-1
        CALL    SYMBO
        POP     D
        JNC     X000
        POP     PSW
        POP     H
        SHLD    TEMHL
        POP     H
        LHLD    TEMHL
        JMP     IXHRT
TEMHL:  .WORD   0
;
RET:    MVI     A,CR
;
ZTYPE:  PUSH    B
        MOV     B,A
        LDA     CBYTE
        RAL
        MOV     A,B
        JRNC    TYPEP
DFOUT:  MOV     C,A
        CALL    PO
TYPEP:  POP     B
TYPE:   PUSH    B
        CPI     TAB
        JRZ     TABX
        MOV     C,A
        LDA     KBYTE
        ANI     04
        MOV     A,C
        JRNZ    FFFFD
        CALL    CO
FFFFD:  MOV     B,A
        LDA     TABC
        DCR     A
        STA     TABC
        MOV     A,B
        POP     B
        CPI     CR
        RNZ
EOL:    MVI     A,LF
        JMPR    ZTYPE
TABX:   PUSH    PSW
        LDA     TABC
        MOV     B,A
TABXL:  MVI     C,20
        LDA     KBYTE
        ANI     04
        JRNZ    AAAAF
        CALL    CO
AAAAF:  MOV     A,B
        ANI     07
        MOV     B,A
        DJNZ    TABXL
        XRA     A
        STA     TABC
        POP     PSW
        POP     B
        RET
;
SYMBO:  LDA     CBYTE
        ANI     05
        RZ
        ANI     01
        JRNZ    FRMTB
;
        CALL    SYBLD
        ORA     A
        RET
;
FRMTB:  INX     H
        MOV     C,M
        INX     H
        MOV     B,M
        INX     H
        CALL    PRTLB
        RC
        DCX     H
        DCX     H
        DCX     H
        ORA     A
        RET
PRTLB:  CALL    LOOKU
        CMC
        RNC
        MVI     B,5
SYPLP:  LDAX    D
        INX     D
        ORA     A
        JRZ     SYPEX
        CALL    ZTYPE
        DJNZ    SYPLP
SYPEX:  STC
        RET
;
SYBLD:  INX     H
        MOV     C,M
        INX     H
        MOV     B,M
        DCX     H
        DCX     H
        CALL    LOOKU
        RNC
        MVI     A,'L'
        STAX    D
        INX     D
        MOV     A,B
        CALL    SYSTX
        MOV     A,C
        CALL    SYSTX
        MOV     A,B
        STAX    D
        INX     D
        MOV     A,C
        STAX    D
        XRA     A
        INX     D
        STAX    D
        PUSH    H
        LHLD    SYMBC
        INX     H
        SHLD    SYMBC
        LHLD    SYMBC1
        DCX     H
        MOV     A,H
        ORA     L
        JRNZ    HITIT
        CALL    CRLF
        MVI     C,WTFN
        LXI     D,TERRM
        CALL    BDOS
        CALL    CRLF
        JMP     EXPR
HITIT:  SHLD    SYMBC1
        POP     H
        STC
        RET
;
SYSTX:  PUSH    PSW
        CALL    HEXL
        STAX    D
        INX     D
        POP     PSW
        CALL    HEXR
        STAX    D
        INX     D
        RET
;
LOOKU:  LXI     D,SYMTB
LULP:   LDAX    D
        ORA     A
        STC
        RZ
        INX     D
	INX	D
        INX     D
        INX     D
        INX     D
        LDAX    D
        CMP     B
        INX     D
        JRNZ    LUNO
        LDAX    D
        CMP     C
        JRNZ    LUNO
        DCX     D
        DCX     D
        DCX     D
        DCX     D
        DCX     D
        DCX     D
        ORA     A
        RET
LUNO:   INX     D
        JMPR    LULP
;
GRSCC:  MOV     A,M
        RAR
        ANI     1C
        PUSH    H
        LXI     H,RSTAB
        CALL    ADD
        MOV     A,M
        STA     CC1
        INX     H
        MOV     A,M
        STA     CC1+1
        INX     H
        MOV     A,M
        STA     CC1+2
        INX     H
        MOV     A,M
        STA     CCB
        POP     H
        LXI     B,CC1-1
        RET
;
POTLM:  RAR
        RAR
        RAR
POTL:   ANI     07
        ADI     30
        JMP     ZTYPE
;
GETXR:  MOV     A,M
        RAR
        RAR
        RAR
        ANI     06
        CPI     06
        JRNZ    GETRP
        MVI     A,'S'
        STA     CC1+1
        MVI     A,'P'
        STA     CC1+2
        LXI     B,CC1-1
        RET
;
GETRP:  PUSH    H
        LXI     H,RTAB
        CALL    ADD
        MOV     A,M
        STA     CC1+1
        INX     H
        MOV     A,M
        STA     CC1+2
        JMPR    GETEX
;
GETBX:  MOV     A,M
        RAR
        RAR
        ANI     06
        PUSH    H
        LXI     H,BXTAB
        CALL    ADD
        MOV     A,M
        STA     CC1+2
        INX     H
        MOV     A,M
        STA     CCB
GETEX:  POP     H
        LXI     B,CC1-1
        RET
;
PRIR:   INX     B
        LDAX    B
        CALL    ZTYPE
        RET
PRIRP:  MVI     A,'H'
        CALL    ZTYPE
        PUSH    D
        MVI     D,03
        DCX     B
PIRPL:  INX     B
        LDAX    B
        CALL    ZTYPE
        DCR     D
        JRNZ    PIRPL
        POP     D
        RET
;
ENDCK:  LDA     EBUF
        SUB     L
        LDA     EBUF+1
        SBB     H
        JRNC    CKCTC
END:    LDA     KBYTE
        ANI     02
        JZ      EXPR
ENDSF:  PUSH    H
        XRA     A
        STA     TABC
        LXI     H,ESFSG
        MVI     B,ESFSL
EDSFL:  MOV     A,M
        CALL    ZTYPE
        INX     H
        DJNZ    EDSFL
        POP     H
        JMP     CDKF
CKCTC:  CALL    CONSTA
        CPI     TRUE
        RNZ
        CALL    CI
        CPI     'K'-40
        JZ      EXPR
        CPI     'S'-40
        RNZ
        CALL    CI
        CPI     'K'-40
        JZ      EXPR
        RET
;
;       TABLES
;
JMTBL:  .WORD   TYPE0
        .WORD   TYPE1
        .WORD   TYPE2
        .WORD   TYPE3
        .WORD   TYPE4
        .WORD   TYPE5
        .WORD   TYPE6
        .WORD   TYPE7
        .WORD   TYPE8
        .WORD   TYPE9
        .WORD   TYPEA
        .WORD   TYPEB
        .WORD   TYPEC
        .WORD   TYPED
        .WORD   TYPEE
        .WORD   TYPEF
        .WORD   TYP10
        .WORD   TYP11
        .WORD   TYP12
        .WORD   TYP13
        .WORD   TYP14
        .WORD   TYP15
        .WORD   TYP16
        .WORD   TYP17
        .WORD   TYP18
        .WORD   TYP19
        .WORD   TYP1A
        .WORD   TYP1B
        .WORD   TYP1C
        .WORD   TYP1D
        .WORD   TYP1E
        .WORD   TYP1F
        .WORD   TYP20
        .WORD   PRDB
;
CCTAB:  .ASCII  'NZ'
        .ASCII  'Z '
        .ASCII  'NC'
        .ASCII  'C '
        .ASCII  'PO'
        .ASCII  'PE'
        .ASCII  'P '
        .ASCII  'M '
;
RTAB:   .ASCII  'BC'
        .ASCII  'DE'
        .ASCII  'HL'
        .ASCII  'MA'
;
RSTAB:  .ASCII  'RLCR'
        .ASCII  'RRCR'
        .ASCII  'RALR'
        .ASCII  'RARR'
        .ASCII  'SLAR'
        .ASCII  'SRAR'
        .ASCII  'UNDF'
        .ASCII  'SRLR'
;
BXTAB:  .ASCII  'I '
        .ASCII  'D '
        .ASCII  'IR'
        .ASCII  'DR'
;
;       OPCODE TABLES
;
OTABM:  .BYTE   0FF
        .WORD   0000
        .ASCII  'NOP '
        .BYTE   0FF
        .WORD   0007
        .ASCII  'RLC '
        .BYTE   0FF
        .WORD   000F
        .ASCII  'RRC '
        .BYTE   0FF
        .WORD   0017
        .ASCII  'RAL '
        .BYTE   0FF
        .WORD   00EB
        .ASCII  'XCHG'
        .BYTE   0FF
        .WORD   001F
        .ASCII  'RAR '
        .BYTE   0FF
        .WORD   0722
        .ASCII  'SHLD'
        .BYTE   0FF
        .WORD   0027
        .ASCII  'DAA '
        .BYTE   0FF
        .WORD   072A
        .ASCII  'LHLD'
        .BYTE   0FF
        .WORD   002F
        .ASCII  'CMA '
        .BYTE   0FF
        .WORD   0732
        .ASCII  'STA '
        .BYTE   0FF
        .WORD   0037
        .ASCII  'STC '
        .BYTE   0FF
        .WORD   073A
        .ASCII  'LDA '
        .BYTE   0FF
        .WORD   003F
        .ASCII  'CMC '
        .BYTE   0FF
        .WORD   0076
        .ASCII  'HLT '
        .BYTE   0C0
        .WORD   0B40
        .ASCII  'MOV '
        .BYTE   0FF
        .WORD   07C3
        .ASCII  'JMP '
        .BYTE   0FF
        .WORD   00C9
        .ASCII  'RET '
        .BYTE   0FF
        .WORD   07CD
        .ASCII  'CALL'
        .BYTE   0FF
        .WORD   05D3
        .ASCII  'OUT '
        .BYTE   0FF
        .WORD   05DB
        .ASCII  'IN  '
        .BYTE   0FF
        .WORD   00E3
        .ASCII  'XTHL'
        .BYTE   0FF
        .WORD   00E9
        .ASCII  'PCHL'
        .BYTE   0FF
        .WORD   00F3
        .ASCII  'DI  '
        .BYTE   0FF
        .WORD   00FB
        .ASCII  'EI  '
        .BYTE   0FF
        .WORD   00F9
        .ASCII  'SPHL'
        .BYTE   0FF
        .WORD   05C6
        .ASCII  'ADI '
        .BYTE   0FF
        .WORD   05CE
        .ASCII  'ACI '
        .BYTE   0FF
        .WORD   05D6
        .ASCII  'SUI '
        .BYTE   0FF
        .WORD   05DE
        .ASCII  'SBI '
        .BYTE   0FF
        .WORD   05E6
        .ASCII  'ANI '
        .BYTE   0FF
        .WORD   05EE
        .ASCII  'XRI '
        .BYTE   0FF
        .WORD   05F6
        .ASCII  'ORI '
        .BYTE   0FF
        .WORD   05FE
        .ASCII  'CPI '
        .BYTE   0FF
        .WORD   0008
        .ASCII  'EXAF'
        .BYTE   0FF
        .WORD   0C10
        .ASCII  'DJNZ'
        .BYTE   0FF
        .WORD   0C18
        .ASCII  'JMPR'
        .BYTE   0FF
        .WORD   00D9
        .ASCII  'EXX '
        .BYTE   0FF
        .WORD   0ECB
        .ASCII  '....'
        .BYTE   0FF
        .WORD   0FED
        .ASCII  '....'
        .BYTE   0FF
        .WORD   10DD
        .ASCII  '(X).'
        .BYTE   0FF
        .WORD   10FD
        .ASCII  '(Y).'
        .BYTE   0E7
        .WORD   0D20
        .ASCII  'JR..'
        .BYTE   0F8
        .WORD   0180
        .ASCII  'ADD '
        .BYTE   0F8
        .WORD   0188
        .ASCII  'ADC '
        .BYTE   0F8
        .WORD   0190
        .ASCII  'SUB '
        .BYTE   0F8
        .WORD   0198
        .ASCII  'SBB '
        .BYTE   0F8
        .WORD   01A0
        .ASCII  'ANA '
        .BYTE   0F8
        .WORD   01A8
        .ASCII  'XRA '
        .BYTE   0F8
        .WORD   01B0
        .ASCII  'ORA '
        .BYTE   0F8
        .WORD   01B8
        .ASCII  'CMP '
        .BYTE   0C7
        .WORD   0204
        .ASCII  'INR '
        .BYTE   0C7
        .WORD   0205
        .ASCII  'DCR '
        .BYTE   0EF
        .WORD   0302
        .ASCII  'STAX'
        .BYTE   0EF
        .WORD   030A
        .ASCII  'LDAX'
        .BYTE   0CF
        .WORD   03C1
        .ASCII  'POP '
        .BYTE   0CF
        .WORD   03C5
        .ASCII  'PUSH'
        .BYTE   0C7
        .WORD   0406
        .ASCII  'MVI '
        .BYTE   0CF
        .WORD   0303
        .ASCII  'INX '
        .BYTE   0CF
        .WORD   0309
        .ASCII  'DAD '
        .BYTE   0CF
        .WORD   030B
        .ASCII  'DCX '
        .BYTE   0C7
        .WORD   08C2
        .ASCII  'J...'
        .BYTE   0C7
        .WORD   08C4
        .ASCII  'C...'
        .BYTE   0CF
        .WORD   0601
        .ASCII  'LXI '
        .BYTE   0C7
        .WORD   09C0
        .ASCII  'R...'
        .BYTE   0C7
        .WORD   0AC7
        .ASCII  'RST '
        .BYTE   00
;
;
OTABC:  .BYTE   0C0
        .WORD   1100
        .ASCII  '....'
        .BYTE   0C0
        .WORD   1240
        .ASCII  'BIT '
        .BYTE   0C0
        .WORD   1280
        .ASCII  'RES '
        .BYTE   0C0
        .WORD   12C0
        .ASCII  'SET '
        .BYTE   00
;
;
OTABE:  .BYTE   0FF
        .WORD   0044
        .ASCII  'NEG '
        .BYTE   0FF
        .WORD   0045
        .ASCII  'RETN'
        .BYTE   0FF
        .WORD   004D
        .ASCII  'RETI'
        .BYTE   0FF
        .WORD   0046
        .ASCII  'IM0 '
        .BYTE   0FF
        .WORD   0056
        .ASCII  'IM1 '
        .BYTE   0FF
        .WORD   005E
        .ASCII  'IM2 '
        .BYTE   0FF
        .WORD   0067
        .ASCII  'RRD '
        .BYTE   0FF
        .WORD   006F
        .ASCII  'RLD '
        .BYTE   0FF
        .WORD   0047
        .ASCII  'STAI'
        .BYTE   0FF
        .WORD   004F
        .ASCII  'STAR'
        .BYTE   0FF
        .WORD   0057
        .ASCII  'LDAI'
        .BYTE   0FF
        .WORD   005F
        .ASCII  'LDAR'
        .BYTE   0CF
        .WORD   1343
        .ASCII  'S..D'
        .BYTE   0CF
        .WORD   134B
        .ASCII  'L..D'
        .BYTE   0E7
        .WORD   14A0
        .ASCII  'LD..'
        .BYTE   0E7
        .WORD   14A1
        .ASCII  'CC..'
        .BYTE   0E7
        .WORD   14A2
        .ASCII  'IN..'
        .BYTE   0E7
        .WORD   15A3
        .ASCII  'UT..'
        .BYTE   0C7
        .WORD   0240
        .ASCII  'INP '
        .BYTE   0C7
        .WORD   0241
        .ASCII  'OUTP'
        .BYTE   0CF
        .WORD   034A
        .ASCII  'DADC'
        .BYTE   0CF
        .WORD   0342
        .ASCII  'DSBC'
	.BYTE	00
;
;
OTBIR:  .BYTE   0FF
        .WORD   16E9
        .ASCII  'PC..'
        .BYTE   0C9
        .WORD   2009
        .ASCII  'DA..'
        .BYTE   0FF
        .WORD   16F9
        .ASCII  'SP..'
        .BYTE   0FF
        .WORD   16E3
        .ASCII  'XT..'
        .BYTE   0FF
        .WORD   17E1
        .ASCII  'POP '
        .BYTE   0FF
        .WORD   17E5
        .ASCII  'PUSH'
        .BYTE   0FF
        .WORD   1723
        .ASCII  'INX '
        .BYTE   0FF
        .WORD   172B
        .ASCII  'DCX '
        .BYTE   0FF
        .WORD   1836
        .ASCII  'MVI '
        .BYTE   0FF
        .WORD   1921
        .ASCII  'LXI '
        .BYTE   0FF
        .WORD   1A22
        .ASCII  'S..D'
        .BYTE   0FF
        .WORD   1A2A
        .ASCII  'L..D'
        .BYTE   0F8
        .WORD   1B70
        .ASCII  'MOV '
        .BYTE   0C7
        .WORD   1C46
        .ASCII  'MOV '
        .BYTE   0FF
        .WORD   1F86
        .ASCII  'ADD '
        .BYTE   0FF
        .WORD   1F34
        .ASCII  'INR '
        .BYTE   0FF
        .WORD   1F35
        .ASCII  'DCR '
        .BYTE   0FF
        .WORD   1F8E
        .ASCII  'ADC '
        .BYTE   0FF
        .WORD   1F96
        .ASCII  'SUB '
        .BYTE   0FF
        .WORD   1F9E
        .ASCII  'SBB '
        .BYTE   0FF
        .WORD   1FA6
        .ASCII  'ANA '
        .BYTE   0FF
        .WORD   1FB6
        .ASCII  'ORA '
        .BYTE   0FF
        .WORD   1FAE
        .ASCII  'XRA '
        .BYTE   0FF
        .WORD   1FBE
        .ASCII  'CMP '
        .BYTE   00
;
;
OTBIC:  .BYTE   0C7
        .WORD   1D46
        .ASCII  'BIT '
        .BYTE   0C7
        .WORD   1D86
        .ASCII  'RES '
        .BYTE   0C7
        .WORD   1DC6
        .ASCII  'SET '
        .BYTE   0C6
        .WORD   1E06
        .ASCII  '....'
        .BYTE   00
;
;
;
;
        .RADIX  10
;
;       STORAGE
;
RDBUF:  .BYTE   30
RDCNT:  .BYTE   0
COMAND: .BLKB   28
BIAS:   .WORD   0
RELO:   .WORD   0
OFFST:  .WORD   0
KBYTE:  .BYTE   0
CBYTE:  .BYTE   0
BBUF:   .WORD   0
EBUF:   .WORD   0
SYMBC:  .WORD   0
SYMBC1: .WORD   SYMNUM
FCBW:   .BLKB   33
WTPTR:  .BYTE   0
WTBUF:  .BLKB   128
TYFLG:  .BLKB   2
CC1:    .BLKB   3
CCB:    .BLKB   1
TABC:   .BYTE   0
STACK:  .BLKB   64
STKTOP  =       .
HERALD: .BYTE   126,28
        .ASCII  "CPM Z-80 DISASSEMBLER VER 1.0"
        .BYTE   CR,LF
        .ASCII  "ADAPTED FROM DDJ BY T.M.B., SEPT. 1979."
        .BYTE   CR,LF,CR,LF
        .ASCII  "$"
ENMES:  .BYTE   CR,LF
        .ASCII  "Command (c,d,m,o,r,q,h,s,t) ==> $"
COMEX:  .ASCII  "COM"
OPNM:   .ASCII  "ERROR ON opening FILE$"
MESA3:  .ASCII  "SECTORS READ = $"
MESA4:  .ASCII  "NEXT ADDRESS = $"
RDERRM: .ASCII  "ERROR ON reading SECTOR$"
ESFSG:  .BYTE   TAB
        .ASCII  ".END"
        .BYTE   CR,'Z'-40H
ESFSL   =       .-ESFSG
BYTSG:  .ASCII  ".BYTE"
BYSGL   =       .-BYTSG
SGNMG:  .ASCII  "DISASSEMBLER"
        .BYTE   CR,LF
SNMGL   =       .-SGNMG
OFCMD:  .BYTE   CR,LF
        .ASCII  "Output Filename ==> $"
DIREM:  .ASCII  "No more directory space $"
WEMS1:  .ASCII  "ERROR ON writing SECTOR...NOW CLOSING."
        .BYTE   CR,LF
        .ASCII  "LAST ADDRESS DISASSEMBLED ==> $"
TDLT:   .ASCII  "TDL"
CLEER:  .ASCII  "ERROR ON closing FILE$"
OPTMES: .ASCII  "OPTIONS SELECTED = $"
FINMES: .ASCII  "NUMBER OF ENTRIES IN SYMBOL TABLE = $"
TERRM:  .ASCII  ">>> WARNING <<< SYMBOL TABLE EXCEDED.$"
SYMTB:  .BLKB   SYMNUM
;
PREND   =       .
        .END
