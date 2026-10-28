        page    55
        maclib  bds
        maclib  cmac
 
        direct
        define  fillb
        define  fill
        define  strrot
        define  hi
        define  lo
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
;*              This file: G81.ASM release 1            *
;*                                                      *
;********************************************************
;
;
;============================================================= 
;
; int fillb(a1,a2,c,mode)
;  char c;
;  int a1, a2, mode;
;
;   if (mode==0)
;     Fills memory from address a1 to address a2 (inclusive)
;     with the byte c.
;   else
;     Fills memory from address a1 for a2 bytes with byte c.
;
        prelude fillb
 
        call    arghak
        push    b
 
        lda     arg4            ;"from/to" or "from/count"
        ora     a               ;"from/to" - jump
        reloc   jz,fillb2
        lhld    arg2            ;"COUNT" value
        push    h               ;move it to
        pop     b               ;BC
        reloc   jmp,fillb4      ;and jump
 
fillb2: lhld    arg1            ;"FROM" address
        mov     a,l             ;turn it
        cma                     ;round
        mov     e,a             ;into the DE pair
        mov     a,h
        cma
        mov     d,a             ;to form "1's comp"
        inx     d               ;and now "2's comp"
        lhld    arg2            ;and now get "TO" addr
        dad     d               ;ie "TO" - "FROM" = range
        push    h               ;move it to
        pop     b               ;BC (bytes to fill)
        inx     b               ;include the end address too!
 
fillb4: lhld    arg1            ;"FROM" address
        lda     arg3            ;byte to fill with
        mov     e,a             ;just somewhere to put it!
 
fillb6: mov     m,a             ;and fill it in there!
        inx     h               ;point to next fill address
        dcx     b               ;one less to go!
        mov     a,b
        ora     c               ;finished ?
        reloc   jz,fillb8       ;yes - jump
        mov     a,e             ;get fill byte again
        reloc   jmp,fillb6      ;and fill with it
 
fillb8: pop     b               ;all over
        ret
 
        postlude fillb
;
;============================================================= 
;
; char *fill(saddr,eaddr,string,opt)
;   char *string;
;
;   If (opt==0)
;     Fills a contiguous block of RAM starting at saddr and 
;     ending at eaddr with the string pointed to by "string".
;   else
;     Fills a contiguous block of RAM starting at saddr of
;     length eaddr bytes with the string pointed to.
;
;   The string is reused until the fill is complete.
;   Returns the address of the fill string.
;
        prelude fill
 
        call    arghak
        push    b
 
        lda     arg4            ;"from/to" or "from/count"
        ora     a
        reloc   jz,fill02       ;"from/to" - jump
        lhld    arg2            ;get "COUNT"
        push    h               ;and move to
        pop     b               ;BC
        reloc   jmp,fill04      ;then jump
 
fill02: lhld    arg1            ;"FROM" address
        mov     a,l             ;turn it
        cma                     ;round
        mov     e,a             ;into the DE pair
        mov     a,h
        cma
        mov     d,a             ;to form "1's comp"
        inx     d               ;and now "2's comp"
        lhld    arg2            ;and now get "TO" addr
        dad     d               ;ie "TO" - "FROM" = range
        push    h               ;move it to
        pop     b               ;BC (bytes to fill)
        inx     b               ;include the end address too!
 
fill04: lhld    arg1            ;"FROM" address
        xchg                    ;to DE
        lhld    arg3            ;pointer to the "fill string"
        mov     a,m             ;get first char to fill with
        ora     a               ;null string ?
        reloc   jz,fill08       ;if so then quit
 
fill06: stax    d               ;and fill it in there!
        inx     d               ;point to next fill address
        inx     h               ;and next "fill string" char
        dcx     b               ;one less to go!
        mov     a,b
        ora     c               ;finished ?
        reloc   jz,fill08       ;yes - jump
        mov     a,m             ;get the next char to fill with
        ora     a               ;is it a 0 (end of string)
        reloc   jnz,fill06      ;no - fill with it then
        lhld    arg3            ;back to the start of string
        mov     a,m             ;get the first char
        reloc   jmp,fill06      ;and fill with it
 
fill08: lhld    arg3            ;return addr of the fill str 
        pop     b               ;all over
        ret
 
        postlude fill
;
;==============================================================
;
; char *strrot(mode,s)
;   char *s;
;
;    Rotates the string (end around) pointed to by "s".
;    If mode==0 then rotate LEFT, and
;    if mode<>0 then rotate RIGHT.
;    Returns the address of the string.
;
        prelude strrot
 
        call    arghak
        push    b
 
        lhld    arg2            ;point to string
        push    h
        pop     d               ;in DE as well
        inx     d               ;and point ahead one
        mvi     c,0             ;a counter to zero!
        lda     arg1            ;get MODE switch
        ora     a               ;rotate left ?
        reloc   jnz,strr06      ;no - jump
 
        mov     a,m             ;get char to rotate
        mov     b,a             ;and save it
strr02: ldax    d               ;get char
        ora     a               ;have we reached end of str
        reloc   jz,strr04       ;yes - jump
        mov     m,a             ;rotate the char
        inx     h               ;next please
        inx     d
        reloc   jmp,strr02      ;and back for more
strr04: mov     a,b             ;"the first shall be last.."
        mov     m,a
        reloc   jmp,strr14
 
strr06: mov     a,m             ;first scan for end
        inx     h
        inr     c               ;chars in string
        ora     a               ;there yet ?
        reloc   jnz,strr06      ;no - back we go
        dcx     h               ;point back to the null
        dcx     h               ;and then to last char
        dcr     c               ;we don't count the null
        push    h               ;and copy
        pop     d               ;to DE
        dcx     d               ;back one more
        mov     a,m             ;the end char to save
        mov     b,a             ;in B
strr10: dcr     c               ;have we rotated enough ?
        reloc   jz,strr12       ;yes - jump
        ldax    d               ;get char to rotate
        mov     m,a             ;and rotate it!
        dcx     h               ;back one more
        dcx     d
        reloc   jmp,strr10      ;next please
strr12: mov     a,b             ;".and the last shall be first"
        mov     m,a
strr14: lhld    arg2            ;return string address
        pop     b
        ret
 
        postlude strrot
;
;
;============================================================= 
;
; int hi(i)
;  int i;
;
;   Returns the high byte of i.
;
        prelude hi
 
        call    ma1toh
        mov     l,h
        mvi     h,0
        ret
 
        postlude hi
;
;============================================================= 
;
; int lo(i)
;  int i;
;
;   Returns the low byte of i.
;
        prelude lo
 
        call    ma1toh
        mvi     h,0
        ret
 
        postlude lo
;
low byte of i.