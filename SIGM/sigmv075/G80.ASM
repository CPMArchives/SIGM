        page    55
        maclib  bds
        maclib  cmac
 
        direct
        define  supp
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
;*              This file: G80.ASM release 1            *
;*                                                      *
;********************************************************
;
;  THE (IN)FAMOUS BDS-C SUPPLEMENTARY LIBRARY
;    FOR THE EXIDY SORCERER COMPUTER SYSTEM
;
; int supp();
;
;   Returns the release number of the SUPP.CRL file
;   as a 16 bit number (heaven forbid)!
 
        prelude supp
 
release equ     2       ;DATE INSTALLED: 11 Nov 80
                        ;-------------------------
 
        lxi     h,release
        ret
 
        postlude supp
v 80
                        ;-------------------------
 
        lxi     h,release
        ret
 
        post