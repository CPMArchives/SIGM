
;Little-Ada L/0 machine interperter
;Edited June 21, 1980
;Copyright 1980 by Ralph E. Kenyon Jr.
;Version 1547 Re-designated L/1 Jan 81
;Stripped down, no debug version

        REFS SYSTEM.SY  ;Library file
        REF Warm        ;Warmstart
        REF WH0         ;Consol Char in
        REF WH1         ;Consol Char out
        REF Msg         ;Message writer
        REF USER        ;Start of user memory
        REF MEMTOP      ;Last good memory
        REF Ret         ;Return from overlay
        REF Dio         ;Disk In/Out
        REF Err         ;System error handler
        REF FILE        ;File data buffer
        REF Ovrto       ;Overlay handler
        REF CMPTR       ;Command buffer pointer
        REF Ioret       ;Return from Interupt

        REFS <#>L0CODE.SY
;Open L/0 code MACRO Library
        REF L0CODE
;Macro which defines all L/0 code macros.

CR      EQU 13

        ORG USER
        IDNT $,$        ;$ is current value PC

        JMP Start
        JMP GO

        L0CODE
        LIST 0

DBZ     DB CR,'Division by zero not defined!',CR,0

Inst    DS 1    ;Instruction register
Base    DS 2    ;Base register
Static  DS 2    ;Static link conversion register
Level   DS 1    ;Level register
AR1     DS 2    ;Arithemetic storage 1
AR2     DS 2    ;Arithemetic storage 2
AR3     DS 2    ;Arithemetic storage 3
TMStack DS 2    ;Stack start
FDB     DS 44   ;File descriptor buffer
IFD     DS 1    ;Input file drive
IFA     DS 2    ;Input file disk address
IFS     DS 2    ;Input file disk sector
IFP     DS 2    ;Input file buffer pointer
IFB     DS 256  ;Input file buffer
OFD     DS 1    ;Output file drive
OFA     DS 2    ;Output file disk address
OFS     DS 2    ;Output file disk sector
OFP     DS 2    ;Output file buffer pointer
OFB     DS 256  ;Output file buffer
Flag    DS 1    ;Output file in use flag

IFflg   DB 1    ;initialize flag
OFflg   DB 1    ;initialize flag

Fetch   LDAX B  ;Instruction fetch cycle
        INX B
        STA Inst
        ORA A
        RET

Push    MOV M,E         ;DE to S(t)
        DCX H           ;t+1 to HL
        MOV M,D
        DCX H
        RET

Pop     INX H           ;S(t) to DE
        MOV D,M         ;t-1 to HL
        INX H
        MOV E,M
        RET

MinDE   PUSH PSW        ;Two's complement
        MOV A,D         ;of DE. All other
        CMA             ;registers preserved.
        MOV D,A
        MOV A,E
        CMA
        MOV E,A
        INX D
        POP PSW
        RET

CONV    PUSH H          ;Requires T in DE
        CALL MinDE      ;(Static)
        LHLD TMStack
        DAD D           ;<[(TMStack)-(Static)]
        MOV A,H         ;We're going to divide by 2
        CMP H           ;(Just reset carry)
        RAR             ;Puts lo bit in carry
        MOV D,A         ;Right shifted by 1
        MOV A,L         ;Lo byte
        RAR             ;Carry goes into hi bit
        MOV E,A         ;(16 bits right shift)
        POP H
        RET             ;Result in DE

;This section computes the static link
;by finding the ltack position base for
;L levels down.

GStL    PUSH PSW
        PUSH H
        LDA Inst        ;get & stow level

GStL1   ANI 0FH
        LHLD Base       ;get & stow base
        SHLD Static
        JMP BASE

BASE1   LHLD Static     ;get base
        XCHG
        LHLD TMStack
        INX D           ;We need to be above by 1
        CALL MinDE
        DAD D           ;(MEMTOP-2*T)
        DAD D           ;stack address now in hl
        CALL Pop        ;Get S(S(t))
        XCHG
        SHLD Static
        LDA Level       ;get level
        DCR A

BASE    STA Level
        JNZ BASE1
        XCHG            ;Returns static level in DE
        POP H
        POP PSW
        RET

Out2    MVI E,2         ;Output file already exists
        JMP Out0

Out3    MVI E,3         ;Input file not specified

Out0    MVI D,7

Out     JMP Err

Gf      MVI A,0E0H

Gf1     CALL Ovrto
        DB 'Gfid'
        RET

;Parameters for Dio set up by start code
;Here's where we get the file to be
;interpretered

GETP    CALL Dio        ;Go get it.
        JC Out          ;Something Wrong!
        LXI H,Pgmaddr   ;get the program
        PUSH H
        POP B           ;Set TMPC to first byte
        LHLD TMStack    ;Set initialize TMSP
        LXI D,0         ;First position on stack for
        CALL Push       ;Character in/out
        CALL Push       ;Static link
        INX D
        XCHG
        SHLD Base       ;set Base 1st
        XCHG
        CALL Push       ;Dynamic link same
        LXI D,Origin    ;addr of that 'hlt' byte
        CALL Push
        CALL INB
        CALL OUTB

;This routine sets itself up as a return address

GO      PUSH H          ;Return to here
        LXI H,GO
        XTHL            ;Put our addr on stack
        CALL Fetch
        RAL
        JNC branch      ;0 means br or bnz
        RAL
        JNC oprlic
        RAL
        RC              ;111XXXXX is NOP
        CALL GStL       ;For both lad & call
        RAL             ;Now which one
        JC Call         ;do we have?

;Here we have to get the address from
;the program immediate data (two bytes)

Lad     PUSH H
        LHLD Static
        CALL Fetch
        MOV D,A         ;Address hi byte
        CALL Fetch
        MOV E,A         ;Address lo byte
        DAD D           ;Add in the stack base
        XCHG            ;put it in DE
        POP H
        JMP Push        ;Let push return

;This routine puts links on stack
;followed by return address

Call    PUSH H          ;We need TMSP later
        XCHG
        LHLD Static
        XCHG
        CALL Push       ;Static link first
        XCHG
        LHLD Base
        XCHG
        CALL Push       ;Dynamic link second
        XTHL            ;TMSP to stack
        XCHG
        CALL CONV
        XCHG
        SHLD Base       ;Set new base
        CALL Fetch      ;lets get that address
        MOV D,A
        CALL Fetch
        MOV E,A
        LXI H,Pgmaddr
        DAD D
        XTHL            ;Addr to top of stack
        PUSH B
        POP D
        POP B
        JMP Push        ;return address

oprlic  RAL             ;Check next bit for oprlic
        JC Lic

;For opr, we must get last 5 bits from inst
;We'll use a computed goto to get the
;routine for the sub-operation.

opr     LDA Inst
        ANI 1FH
        ADD A           ;Times 2
        MOV E,A
        MVI D,0
        PUSH H          ;save TMSP
        LXI H,Jtbl      ;jmp table
        DAD D           ;add position
        MOV E,M
        INX H
        MOV D,M
        XCHG            ;addr to HL
        XTHL            ;addr to stack
        RET             ;Jump to addr

;Now we've got to sort out the number of
;bytes used for the constant in this lic

Lic     RAL
        JC Lic1
        LDA Inst        ;1 byte
        ANI 0FH
        MVI D,0
        JMP lic4

Lic1    RAL
        JC lic2
        LDA Inst        ;2 byte
        ANI 7
        JMP lic3

lic2    CALL Fetch      ;3 byte

lic3    MOV D,A
        CALL Fetch

lic4    MOV E,A
        JMP Push        ;let push RET for us

branch  RAL
        JNC Br
        CALL Pop
        MOV A,D
        ORA A
        JNZ Br          ;(bnz)
        ADD E
        JNZ Br          ;(bnz)
        JMP Fetch       ;Skip this byte
                        ;let Fetch return

Br      LDA Inst
        ANI 3FH         ;Kill opcode
        MOV D,A         ;Hi addr
        CALL Fetch      ;rest of addr
        MOV E,A         ;Lo addr
        PUSH H
        LXI H,Pgmaddr   ;Adjust for program
        DAD D           ;load address
        XTHL
        POP B
        RET

Jtbl    DW Halt         ;0

; Halt closes both the input and the
; output files before invoking Exec.
; The input and output file setup routines
; are restored to IFR and OFR also.

        DW addsub       ;1
        DW addsub       ;2
        DW muldiv       ;3
        DW muldiv       ;4
        DW Mod          ;5
        DW Neg          ;6
        DW Not          ;7
        DW Sete         ;8
        DW Setlg        ;9
        DW Setlg        ;A
        DW Swap         ;B
        DW retn         ;C
        DW Rav          ;D
        DW Sto          ;E
        DW inc          ;F

IFR     DW INB          ;10

; INB sets up the input file data for Dio
; and puts the address of Inb into IFR.
; If a file is not selected, INB puts the
; address of Cinb into IFR (input from consol)

OFR     DW OUTB         ;11

; OUTB sets up the output file data for Dio
; and puts the address of Outb into OFR.
; If a file is not selected, OUTB puts the
; address of Coutb into OFR (output to consol)

;These remaining are all treated as nop

        DW Ret          ;12 insurance
        DW Ret          ;13
        DW Ret          ;14
        DW Ret          ;15
        DW Ret          ;16
        DW Ret          ;17
        DW Ret          ;18
        DW Ret          ;19
        DW Ret          ;1A
        DW Ret          ;1B
        DW Ret          ;1C
        DW Ret          ;1D
        DW Ret          ;1E
        DW Ret          ;1F

Halt    CALL TURNOFF    ;Close open output file
        LXI H,INB       ;Restore Input file
        SHLD IFR        ;Open sequence
        POP D           ;Clean up stack
        RET

addsub  CALL Pop        ;S(t)
        PUSH D
        CALL Pop        ;S(t-1)
        XTHL            ;S(t) to HL
        XCHG            ;S(t) to DE
        LDA Inst
        ANI 2           ;is it a subtract?
        CNZ MinDE
        DAD D           ;S(t-1)-S(t) IN HL
        XCHG
        POP H           ;Get TMSP back
        JMP Push        ;let push return for us

muldiv  CALL Pop
        XCHG
        SHLD AR1
        XCHG
        CALL Pop
        XCHG
        SHLD AR2
        LDA Inst
        ANI 4           ;not multiply?
        CZ MULT
        CNZ DIVD
        LHLD AR3
        XCHG
        JMP Push        ;let push return for us

MULT    PUSH PSW        ;16 bit multiply
        PUSH B          ;with no overflow test
        PUSH D          ;returns product mod 10000H
        PUSH H
        LHLD AR1
        MOV A,H
        ORA A
        JNZ MULT1
        ADD L
        JZ MULT7
        XCHG

MULT1   LHLD AR2
        MOV A,H
        ORA A
        JNZ MULT2
        ADD L
        JZ MULT7

MULT2   MOV C,H         ;save hi byte
        MOV A,L         ;do lo byte
        LXI H,0
        MVI B,8

MULT3   RRC
        JNC MULT4
        DAD D

MULT4   XCHG
        DAD H
        XCHG
        DCR B
        JNZ MULT3
        MOV A,C         ;now do hi byte
        MVI B,8

MULT5   RRC
        JNC MULT6
        DAD D

MULT6   XCHG
        DAD H
        XCHG
        DCR B
        JNZ MULT5
        JMP MULT8

MULT7   LXI H,0

MULT8   SHLD AR3
        JMP Ioret

DIVD    PUSH PSW
        PUSH B
        PUSH D
        PUSH H
        LXI B,0         ;Result goes here
        LHLD AR1
        MOV A,H         ;lets see if
        ORA A           ;the idiot wants
        JNZ DIVD1       ;to divide by
        ADD L           ;zero.
        JZ DBZER        ;He does!

DIVD1   XCHG            ;nope, so get
        LHLD AR2        ;dividend
        MOV A,D         ;If it's
        ORA A           ;zero
        JNZ DIVD2       ;then
        ADD E           ;result's
        JNZ DIVD2       ;also

DIVD7   LXI H,0         ;zero
        JMP DIVD6

DIVD2   MOV A,H
        CMP D
        JC DIVD4
        JZ DIVD3
        INX B
        JMP SUBT

DIVD3   MOV A,L
        CMP E
        JC DIVD4
        INX B
        JZ DIVD4

SUBT    PUSH D
        CALL MinDE
        DAD D
        POP D
        JMP DIVD2

DIVD4   PUSH B
        POP H

DIVD6   SHLD AR3
        JMP Ioret

DBZER   CALL DBZ1
        JMP DIVD7

DBZ1    LXI H,DBZ
        CALL Msg
        RET

Mod     CALL Pop        ;S(t) to DE
        PUSH D          ;S(t) to top of stack
        CALL Pop        ;S(t-1) to DE
        XTHL            ;S(t) to HL
        MOV A,H         ;lets see if
        ORA A           ;the idiot wants
        JNZ Mod1        ;to divide by
        ADD L           ;zero.
        JNZ Mod1
        CALL DBZ1
        JMP Mod3        ;He does!

Mod1    MOV A,D         ;see if we
        ORA A           ;start with
        JNZ TEST        ;zero
        ADD E
        JNZ TEST
        JMP Mod3

SUBTR   XCHG
        PUSH D          ;Save
        CALL MinDE
        DAD D           ;Add -DE
        POP D           ;Restore
        XCHG
TEST    MOV A,D         ;Hi byte of S(t)
        CMP H
        JC Done         ;Hi byte of S(t-1)
                        ;<Hi byte of S(t)
        JNZ SUBTR       ;its bigger
        MOV A,E         ;It's equal so
        CMP L           ;Check lo byte
        JC Done
        JNZ SUBTR       ;its bigger

Mod3    LXI D,0         ;its equal

Done    XCHG
        XTHL
        POP D
        JMP Push        ;let push return for us

Neg     CALL Pop        ;S(t) to DE
        CALL MinDE
        JMP Push        ;DE to S(t) let push ret

Not     CALL Pop        ;look
        MOV A,D         ;hi byte
        ORA A           ;set flags
        JNZ Not2

Not1    ADD E           ;lo byte
        JNZ Not2
        LXI D,1         ;its Zero so change result
        JMP Push

Not2    LXI D,0
        JMP Push        ;onto stack let
                        ;push ret for us

Swap    CALL Pop        ;S(t)
        PUSH D          ;to TOS
        CALL Pop        ;S(t-1) to DE
        XTHL            ;S(t) TO HL, t-1 to TOS
        XCHG            ;S(t) to DE, S(t-1) to HL
        XTHL            ;t-1 to HL, S(t-1) to TOS
        CALL Push       ;S(t-1) to TOS
        POP D           ;S(t-1) to DE
        JMP Push        ;S(t-1) to TMS
                        ;let push return for us.

retn    LHLD Base
        LXI D,3
        DAD D
        DAD H
        XCHG
        CALL MinDE
        LHLD TMStack
        DAD D
        CALL Pop        ;TMPC
        PUSH D
        POP B
        CALL Pop        ;Dynamic link
        XCHG
        SHLD Base
        XCHG
        INX H           ;We don't need that
        INX H           ;static link now
        RET

Sete    CALL Pop
        PUSH D
        CALL Pop
        XTHL
        MOV A,D
        CMP H
        JNZ SETE1
        MOV A,E
        CMP L
        JNZ SETE1
        LXI D,1         ;they're equal
        POP H
        JMP Push        ;let push return for us

SETE1   LXI D,0         
        POP H
        JMP Push        ;let push return for us

Setlg   CALL Pop
        PUSH D          ;S(t) to TOS
        CALL Pop        ;S(t-1) to DE
        XTHL            ;S(t) to HL
        LDA Inst
        ANI 2           ;Setgt?
        JZ Set1
        XCHG            ;Reverse for Setgt

Set1    CALL MinDE      ;-S(t-1)
        DAD D           ;Want 0<S(t)-S(t-1)
        DCX H           ;Sign test uses >= 0
        MOV A,H         ;Look at sign
        ORA A           ;Set flags
        POP H           ;TMSP
        LXI D,1         ;Assume true
        JP Set2         ;Jump if true
        DCX D           ;Falls thru if false
Set2    JMP Push        ;Let Push return for us

;Note: RAV assumes that the address on the stack
;is a relative address from the TM stack pointer
;with 1 for each 16 bit push or pop.  We multiply
;the two's complement by 2 and add it to
;the address in TMStack (Top of memory)

Rav     CALL Pop        ;Get S(t)
        PUSH H          ;Save SP
        LHLD TMStack
        INX D           ;We need to be above by 1
        CALL MinDE
        DAD D           ;(MEMTOP-2*T)
        DAD D           ;stack address now in hl
        CALL Pop        ;Get S(S(t))
        POP H           ;Restore TMSP
        JMP Push        ;S(t):=S(S(t))

Sto     CALL Pop        ;S(t) to be stowed
        PUSH D          ;save it
        CALL Pop        ;address to stow S(t) in
        XTHL            ;(We'll want S(t) first)
        PUSH H          ;Need to use HL
        CALL MinDE      ;Convert Stack
        LHLD TMStack    ;address
        DAD D           ;(MEMTOP-2*T)
        DAD D           ;stack address now in hl
        POP D           ;Get S(t)
        CALL Push       ;S(S(T-1)):=S(T)
        POP H           ;T-2 to TMSP
        RET

Inc     CALL Pop        ;S(t) to de, t-1 in HL
        CALL MinDE
        DAD D
        DAD D           ;S(t)+t-1 to HL
        RET

INB     PUSH H          ;Save VMSP
        PUSH B          ;Save VMPC
        LXI H,Ifpr      ;get one from him.

IFR1    LXI D,FILE      ;File descriptor buffer
        LXI B,'AD'      ;Default file extension
        CALL Gf
        JNC IFR2        ;Gfid found the file
                        ;so go read it

        XRA A           ;Checks for error
        ADD D           ;code 0503H
        CPI 5
        JNZ Err         ;Wrong one
        ADD E
        CPI 8           ;adds up to 8
        JNZ Err         ;No good!
        LXI H,Cinb      ;Set up to get input
        SHLD IFR        ;from the consol
        POP B           ;VMPC
        POP H           ;VMSP
        RET

; Additional inputs jump to here

Cinb    CALL WH0        ;We're inputting from
        PUSH H          ;the consol
        LHLD TMStack    ;Where it goes
        MOV M,A         ;Put it in
        POP H           ;VMSP
        RET

Ifprn   DB CR,'The input file''s empty.'
	DB CR,'What''s the continuation file''s name? ',0

Ifpr    DB 'What''s the input file name? ',0

IFR2    LXI H,FILE      ;READ starts here
        MOV A,M
        ANI 7           ;trim down to drive no.
        STA IFD         ;Drive number
        INX H
        MOV A,M         ;FDE flag byte
        ANI 1FH         ;trim to file size
        ADI 3           ;point past extension
        MOV E,A         ;Put into DE
        MVI D,0
        DAD D           ;Add to Address in HL
        XCHG            ;FDA pointer now in DE
        LXI H,IFA       ;Where the addresses go
        MVI C,4         ;4 bytes to copy

CIFD    LDAX D          ;Get the data
        MOV M,A         ;from the FDB (FILE)
        INX H           ;and copy into the
        INX D           ;areas for our Dio
        DCR C           ;routines
        JNZ CIFD        ;More to copy
        LXI H,IFB+100H  ;Reset the
        SHLD IFP        ;buffer pointer too
        LXI H,Inb       ;Furthur calls to Reader
        SHLD IFR        ;the reader
        POP B           ;VMPC
        POP H           ;VMSP
        RET

; Routine to input from an open file

Inb     PUSH H          ;Save VMSP
        PUSH B          ;Save VMPC

RD1     LHLD IFP
        LXI D,IFB+100H
        MOV A,H
        CMP D
        JNZ RD2
        MOV A,L
        CMP E
        JZ RD3

RD2     MOV A,M
        INX H
        SHLD IFP
        POP B           ;VMPC
        LHLD TMStack    ;Here's where
        MOV M,A         ;we put it
        POP H           ;VMSP
        RET

RD3     LHLD IFS
        MOV A,H
        ORA A
        JNZ RD4
        ORA L
        JNZ RD4

; We've reached the end of the input file
; so, we ask for another one

        LXI H,Ifprn
        JMP IFR1

RD4     DCX H           ;Got to get another
        SHLD IFS        ;sector from disk
        LXI H,IFB
        SHLD IFP
        PUSH D
        XCHG
        LHLD IFA        ;Get disk address
        INX H           ;update for next time
        SHLD IFA        ;and save
        DCX H           ;back to the one we want
        PUSH B          ;going to preserve B
        MVI B,1         ;Read
        LDA IFD         ;Drive for input file
        MOV C,A         ;into C
        MVI A,1         ;1 sector
        CALL Dio        ;Get it
        POP B           ;restore
        POP D           ;this too
        JNC RD1         ;Now we can get another byte
        JMP Err

Ofpr    DB 'What''s the output file name? ',0

CK1     CPI 3           ;Now lets check
        JNZ Err         ;for the 0503 error
        ADD D
        CPI 8           ;adds up to 8
        JNZ Err         ;No good!
        LXI H,Coutb
        SHLD OFR
        POP B           ;VMPC
        POP H           ;VMSP
        RET

; Ouputs jump to here

Coutb   PUSH H          ;We're outputting to the consol
        LHLD TMStack
        MOV A,M
        CALL WH1
        POP H
        RET

OUTB    PUSH H          ;Save VMSP
        PUSH B          ;Save VMPC
        LXI H,Ofpr      ;get one from him.
        LXI D,FDB       ;File descriptor buffer
        LXI B,'AI'      ;('AI' is default ext)
        CALL Gf
        JNC Out2
        XRA A           ;Checks for error
        ADD E           ;code 0300H or 0503H
        JNZ CK1         ;Does not return
        ADD D           ;unless one was
        CPI 3           ;found. Sets CARRY
        JNZ Err         ;Need to have
                        ;a 0300 error
        LXI H,FDB       ;We need to save this
                        ;for close
        MOV A,M
        ANI 7           ;trim down to drive no.
        STA OFD         ;Drive number
        INX H
        MOV A,M         ;FDE flag byte
        ANI 1FH         ;trim to file size
        ADI 3           ;point past extension
        MOV E,A         ;Put into DE
        MVI D,0
        DAD D           ;Add to Address in HL
        XCHG            ;FDA pointer now in DE
        LXI H,OFA       ;Where the addresses go
        MVI C,4         ;4 bytes to copy

COFD    LDAX D          ;Get the data
        MOV M,A         ;from the FDB
        INX H           ;and copy into the
        INX D           ;areas for our Dio
        DCR C           ;routines
        JNZ COFD        ;More to copy
        LXI H,OFB       ;Reset the
        SHLD OFP        ;buffer pointer too
        LXI H,Outb      ;characters thru
        SHLD OFR
        POP B           ;VMPC
        POP H           ;VMSP
        RET

; Routine to output to an open file
; thru calls to Outb

Outb    PUSH PSW        ;For writing
        PUSH B
        PUSH D
        PUSH H
        LXI H,Ioret
        PUSH H
        LHLD TMStack    ;Get the char
        MOV A,M

;The rest of this is called as a subroutine for
;filling up the last sector with zeros also.

Store   LHLD OFP
        MOV M,A         ;put char in buffer
        LXI D,Flag
        LDAX D
        ORA A
        JNZ Store1
        DCR A           ;We've been had!
        STAX D

Store1  INX H           ;bump pointer
        SHLD OFP
        LXI D,OFB
        DCR H
        MOV A,H
        CMP D
        RNZ
        MOV A,L
        CMP E
        RNZ

;pointer now points at OFB so do DIO.

        SHLD OFP        ;DE points at OFB
        LHLD OFS        ;Number of sectors
        INX H           ;One more
        SHLD OFS
        LHLD OFA        ;Disk address
        INX H           ;Up date for next time
        SHLD OFA
        DCX H           ;Here's where we write
        LDA OFD         ;Drive
        MOV C,A         ;Drive no.
        MVI B,0         ;Write
        MVI A,1         ;one sector
        CALL Dio
        JC Err
        RET

; Routines for closing the file

TURNOFF PUSH H          ;Save VMSP
        PUSH B          ;Save VMPC
        LDA Flag        ;See if we're
                        ;still Virgin.
        ORA A           ;(Also for closing
        JZ TO1          ;a read file.)
Fill    LDA OFP         ;Not virgin,
        CPI OFB AND 0FFH
        MVI A,0
        JZ Close1
        CALL Store      ;fill up last sector
        JMP Fill        ;with zeros

Close1  LXI H,FDB+1
        MOV A,M
        ANI 1FH         ;strip down to length
        ADI 5           ;Point past ext and FDA
        MOV E,A
        MVI D,0
        DAD D
        XCHG            ;adr of DNS now in DE
        LHLD OFS
        XCHG
        MOV M,E
        INX H
        MOV M,D         ;length now updated
        LXI H,FDB
        MOV A,M
        ANI 7FH
        MOV M,A
        MVI A,1         ;enter new output
                        ;file in directory
        CALL Gf1
        JC Err
TO1     XRA A           ;Virgin exit.
        STA Flag
Out1    LXI H,OUTB      ;Restore calling address
        SHLD OFR        ;to open a file
        POP B           ;VMPC
        POP H           ;VMSP
        RET

Origin  hlt     ;L0 MACRO instruction
Origin  DB 80H
Pgmaddr EQU $

; We load the executable file on top
;of the Start code !!

Start   LHLD MEMTOP
        SHLD TMStack
        LXI H,USER
        MVI M,RET       ;Don't START again
        LHLD CMPTR      ;Cmd pointer
        MOV A,M
        CPI CR
        JZ Out3
        LXI D,FDB       ;File descriptor block
                        ;built by Gfid
        LXI B,4C30H     ;L/0 extension for
                        ;default is L0
        MVI A,60H
        CALL Gf1
        JC Out          ;Something Wrong!
        LXI H,FDB
        MOV A,M
        ANI 7           ;Kill flags
        MOV M,A
        INX H           ;Move up to FDE flags.
        MOV A,M
        ANI 1FH         ;Kill flags
        ADI 3           ;Point past ext
        MOV E,A
        MVI D,0
        DAD D           ;Addr of FDA
        MOV E,M
        INX H
        MOV D,M
        INX H
        LDA FDB
        MOV C,A         ;Drive to C
        MVI B,1         ;Read
        MOV A,M         ;DNS
        XCHG            ;FDA to HL
        LXI D,Pgmaddr   ;Where to put it
        JMP GETP

        END

