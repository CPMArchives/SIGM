        page    55
        maclib  bds
        maclib  cmac
 
        direct
        define  swaphl
        define  wait
        define  getplot
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
;*              This file: G82.ASM release 1            *
;*                                                      *
;********************************************************
;
;============================================================= 
;
; int swaphl(p1)
;  int p1;
;
;    Returns the 16 bit word P1 with HI and LO bytes swapped.
;
        prelude swaphl
 
        call    ma1toh          ;get the word to swap to HL
        mov     d,h             ;and swap it!
        mov     h,l
        mov     l,d
        ret
 
        postlude swaphl
;
;
;============================================================= 
;
; int wait(port,mask,polarity);
;
;    Used to generate tight status port loops
;    If polarity is TRUE (non zero) then the routine returns
;    when (PORT AND MASK) gives a ZERO result
;    (ie when PORT and MASK have NO bits in common)
;    If polarity is FALSE (zero) then the routine returns
;    when (PORT AND MASK) gives a NON ZERO result
;    (ie when PORT and MASK have SOME bits in common)
;    The value returned is data input from the port.
;
        prelude wait
 
        call    arghak          ;get the parameters
        push    b
 
        lda     arg1            ;the port number
        reloc   sta,wait2a      ;I hate self
        reloc   sta,wait4a      ;  modifying
        reloc   sta,wait6a      ;    code!
        lda     arg2            ;the MASK
        mov     b,a
        lda     arg3            ;the polarity
        ora     a               ;false polarity ?
        reloc   jz,wait4        ;yes - jump
wait2:  in      0               ;input the port
        ana     b               ;and MASK
        reloc   jnz,wait2       ;and loop while NZ
        reloc   jmp,wait6
wait4:  in      0               ;input the port
        ana     b               ;and MASK
        reloc   jz,wait4        ;and loop while Z
wait6:  in      0               ;get the port again
        mov     l,a             ;and into HL
        mvi     h,0
        pop     b
        ret
 
wait2a  equ     wait2+1         ;KLUDGE!
wait4a  equ     wait4+1
wait6a  equ     wait6+1
 
        postlude wait
;
;==============================================================
;
; int *getplot()
;
;   Returns a pointer to the beginning of the data area in
;   c.ccc which contain the dma plotting information.
;
;    int *pbase;        /* points to base addr of screen RAM */
;    int *ysize;        /* points to no. of columns          */
;    int *xsize;        /* points to no. of rows             */
;    int *psize;        /* points to size of plot area       */
;
;    pbase=getplot();
;    ysize=pbase+1;     /* pointers are NOT integers         */
;    xsize=ysize+1;
;    psize=xsize+1;
;
        prelude getplot
 
        lxi     h,pbase
        ret
 
        postlude getplot
;
+1;
;    psize=xsize+1;
;
        prelude getplot
 
        lxi 