; ******************************************************
; *
; *  CBASTEST.ASM
; *
; ******************************************************
; 
; This program will test the use and linkage of assembly language files
; with CBASIC2
;
BDOSADDR	EQU	0A206H
BDOS		EQU	5
PRINT$		EQU	9
;
;
		ORG	09200H
;
START		LXI	D,TEST$
		MVI	C,PRINT$
		CALL	BDOS
		RET
;
TEST$  		DB	0DH,0AH
		DB	'This is a test string from an assembly Language '
		DB	'program'
		DB	0DH,0AH
		DB	24H
;
		END
