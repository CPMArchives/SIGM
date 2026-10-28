        page    55
        maclib  bds
        maclib  cmac
        maclib  z80
 
        direct
        define  cursor
        define  remcur
        define  mwa
        define  exycall
        define  hidecur
        enddir
;
;********************************************************
;*                                                      *
;*              BDS-C Supplementary Library             *
;*                      release 2                       *
;*                                                      *
;*              Steve de Plater, Nov. 1980              *
;*                    66 Priam St.                      *
;*                    Chester Hill,                     *
;*                    NSW, 2162                         *
;*                    Australia                         *
;*              Phone: (02) 644 4009                    *
;*                                                      *
;*              This file: GZ0.ASM release 1            *
;*                                                      *
;********************************************************
;
;********************************************************
;*                                                      *
;*      THIS IS THE ONLY FILE WHICH IS SPECIFIC         *
;*      TO THE EXIDY SORCERER.                          *
;*      IT IS ALSO THE ONLY FILE REQUIRING THE          *
;*      "Z80.LIB" MACRO LIBRARY.                        *
;*      TO RECONFIGURE FOR YOUR OWN SYSTEM ALL THAT     *
;*      IS ESSENTIAL IS TO PROVIDE A "cursor(x,y)"      *
;*      FUNCTION WHICH CONFORMS TO THE FOLLOWING        *
;*      STANDARDS:                                      *
;*      (1)     PLACES THE CURSOR AT POSITION (X,Y)     *
;*              ON THE VIDEO SCREEN (WHERE X IS THE     *
;*              ROW (DOWN) AND Y IS THE COLUMN (ACROSS))*
;*      (2)     IF (X,Y) IS NOT A VALID SCREEN POSITION *
;*              (EG: -VE) THEN NO CURSOR MOVEMENT IS    *
;*              PERFORMED.                              *
;*      (3)     IN ALL CASES THE ADDRESS OF THE CURSOR  *
;*              (ON COMPLETION) IS RETURNED TO THE      *
;*              CALLING FUNCTION.                       *
;*                                                      *
;********************************************************
;
;============================================================
;
; int cursor(x,y);
;
;   moves the cursor to position x (line), y (column) of
;   the Sorcerer screen. (if possible)!
;   Returns the offset from the beginning of the screen RAM
;   of the new cursor position.
 
        prelude cursor
        call    arghak          ;get the arguements
        push    b               ;we need it!
 
getiy   equ     0e1a2h          ;Exidy Monitor entry points
wcur    equ     0e9cch          ;write cursor
rec     equ     0e9e8h          ;remove the old one
ptrset  equ     0e9d6h          ;find the cursor address
 
        lda     arg2            ;get the column
        ora     a
        reloc   jm,curses       ;you can't have a -ve column!
        cpi     64
        reloc   jnc,curses      ;or one > 63
        lda     arg1            ;get the line
        ora     a
        reloc   jm,curses       ;you can't have a -ve line!
        cpi     30
        reloc   jnc,curses      ;or one > 29
 
        lda     arg1+1
        ora     a
        reloc   jnz,curses
        lda     arg2+1
        ora     a
        reloc   jnz,curses
 
        call    getiy
        call    rec
        lda     arg1
        mov     e,a             ;and multiply it be 64
        mvi     d,0
        mvi     b,6
cur04:  sla     e
        rl      d
        djnz    cur04
        stiy    e,68h           ;and save it in the MWA
        stiy    d,69h           ;(both bytes)
        lda     arg2            ;now get the column
        stiy    a,6ah           ;and save it too
        stiyi   0,6bh           ;high byte is zero
        call    wcur            ;and put the cursor there!
 
curses: call    ptrset          ;just in case we hadn't
        pop     b               ;told you we'd need it
        ret                     ;home we go
        postlude cursor         ;generate relocation table
 
getiy   equ     0e1a2h
pushix  equ     0e5ddh
pushiy  equ     0e5fdh
inxix   equ     023ddh
scan    equ     0e225h
;
;==============================================================
;
; int remcur()
;
;   Removes the cursor from the screen.
;   Returns the cursor address.
;
        prelude remcur
 
        push    b
        call    getiy
        call    rec
        pop     b
        ret
 
        postlude remcur
;
;==============================================================
;
; int mwa();
;
;   Returns the MWA address.
;
        prelude mwa
 
        call    getiy
        dw      pushiy
        pop     h
        ret
 
        postlude mwa
;
;============================================================= 
;
; int exycall();
;
;   Calls the Exidy Standard Monitor
;   using the monitor command found at MWA.
;   Returns 0 if illegal command (or no command)
;     or    1 if command successfully executed.
;
;   WARNING: This function may not return AT ALL if you
;   crash it in the Monitor itself! ;BE WARNED!
;
        prelude exycall
 
        push    b               ;just in case!
        dw      pushiy          ;move IY
        pop     h               ;  to HL
        call    scan            ;get delims
        jr      z,exyc5         ;NONE!
        db      0ddh,021h,012h,0e3h
exyc1:  push    h
        dw      pushix
        mvi     b,2
exyc2:  db      0ddh,07eh,00h
        cmp     m
        jr      nz,exyc4
        inx     h
        dw      inxix
        djnz    exyc2
        pop     d
        pop     d
        reloc   <lxi b,>,exyc6
        push    b
exyc3:  db      0ddh,06eh,00h
        db      0ddh,066h,01h
        pchl
exyc4:  db      0ddh,0e1h
        pop     h
        dw      inxix
        dw      inxix
        dw      inxix
        dw      inxix
        db      0ddh,07eh,00h
        ora     a
        jr      nz,exyc1
exyc5:  lxi     h,0
        pop     b
        ret
exyc6:  lxi     h,1
        pop     b
        ret
 
        postlude exycall
;
;=============================================================
;
; int hidecur(c)
;   char c;
;
;       Hides the character passed under the cursor (so that
;       when the cursor is moved then "all secrets will be
;       made known" (or at least displayed on the screen))!
;
;       Returns the cursor address.
;
        prelude hidecur
 
        call    arghak
        push    b
 
        call    getiy                   ;we may not have it
        lda     arg1                    ;the char to hide
        stiy    a,067h                  ;and hide it there!
        call    ptrset                  ;get cursor address
 
        pop     b
        ret                             ;and return
 
        postlude hidecur
  ;get cursor address
 
        