; MATHLIB: a 16 Bit Arithmetic Package for 6805
; Sourced Feb '81 by 	Trevor Marshall
;			SYSOP, Thousand Oaks, Tech RBBS
;
;MULTIPLY:  16 x 16 Bit multiplication
;
; RESULT,RESULT+1 = MPLICAND,MPLICAND+1
;                         x MPLIER,MPLIER+1
; MPLIER, MPLICAND may be destroyed
;COUNT:	DS	1	;loop counter
;RESULT: DS	2
;MPLICAND DS	2
;MPLIER	DS	2
;
;	Example: 5 x 3
;		101
;	     x  011
;	----------------
;		101	(Shifted LSBit=1)
;	       101	(Shifted LSBit=1)
;	      000	(Shifted LSBit=0,no add)
;	----------------
;	      01111	(Result)
;
MULTIPLY: LDA	#16	;initialize count
	STA	COUNT
	CLR	RESULT+1 ;and result
	CLR	RESULT
;
; is multiplier LSBit = 1 ?
ZZMULT:	SHR	MPLIER ;right shift multIplier MSB
;			; 0 -> MSBit, LSBit -> Carry
	RRC	MPLIER+1 ;shift right multiplier LSB
;			;Carry-> MSBit, LSBit -> Carry
	BNC	ZZNOADD ;LSBit not 1, don't add
;
; Could test for overflow here:
; (.Z80) CCF	;Carry will be 1, C -> 0
;	ADC	HL,DE
;	JR	C,OVERFLOW.ROUTINE
; But will add without carry
	LDA	MPLICAND+1 ;LSBit=1, so add multiplicand
;			;to (shifted) result
	ADD	RESULT+1
	STA	RESULT+1
	LDA	MPLICAND
	ADC	RESULT
	STA	RESULT
;
ZZNOADD: SHL	MPLICAND+1 ; 0 -> LSBit, MSBit -> Carry
	RLC	MPLICAND   ;Carry -> LSBit, MSBit -> Carry
	DEC	COUNT
	BNZ	ZZMULT
	RET             ; ***** DONE *****
;
;
;
;DIVIDE: ;16 Bit by 16 Bit Integer Division
;
;                        (DIVIDEND,DIVIDEND+1)
; DIVIDEND,DIVIDEND+1  =----------------------- + REM,REM+1
;                        (DIVISOR,DIVISOR+1)
; The dividend & divisor are stored in memory with
;   the MSByte first
; Their location is via EQU statements
;COUNTER:  EQU	$39	;A scratch location for loop count
;DIVIDEND: EQU	$3A	;2 locs at top of user RAM
;RESULT:   EQU	$	;Result replaces dividend
;DIVISOR:  EQU	$3C	; "
;REM:	   EQU	$3E	; "
;
; The divisor is successively subtracted from the high 
;   order bits of the dividend. After each subtraction 
;   the result is used instead of the initial dividend
; The result is increased by 1 each time.
; When the result of the subtraction is negative the 
;   partial result is restored by adding the divisor 
;   back to it.
; The result is simulataneously decremented by 1
;
;First check if divisor is 0
DIVIDE:	LDA	DIVISOR
	XOR	DIVISOR+1
	BZ	DIVBY0
;clear result
	CLRA
	STA	REM
	STA	REM+1
;loop counter
	LDA	#16
	STA	COUNTER
;
;Rotate Dividend left 
	CLRC
ZZDIV1:	RLC	DIVIDEND+1
	RLC	DIVIDEND
;Rotate Remainder left and collect carry result
	RLC	REM+1
	RLC	REM
	LDA	REM+1
	SUB	DIVISOR+1
	STA	REM+1	;Modify to reflect result
	LDA	REM
	SBC	DIVISOR
	STA	REM	;	"
	BNC	ZZPOS
;otherwise negative
	LDA	REM+1	;Restore dividend
	ADD	DIVISOR+1
	STA	REM+1
	LDA	REM
	ADC	DIVISOR
	STA	REM
ZZPOS:	BNC	ZZPOS1 ;If carry is clear set it
	CLRC           ;if set, clear it
	BR	ZZPOS2 ;Thus complement the carry
ZZPOS1:	SETC
ZZPOS2:	DEC	COUNTER
	BNZ	ZZDIV1
	RLC	DIVIDEND+1 ;Shift in last result bit
	RLC	DIVIDEND
	RET             ; ***** DONE ****
;
DIVBY0	LDA	$FF	;infinity
	STA	DIVIDEND+1
	STA	DIVIDEND
; Output a diagnostic message if desired
	RET
;
