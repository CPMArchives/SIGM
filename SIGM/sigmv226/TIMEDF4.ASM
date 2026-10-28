;TIMEDF4.ASM v1.00
;12/28/83
;By S. Kluger
;
; This is a module for use with RMAC and can be adapted to
; M80 with minimum effort.
;
; Purpose:
; Evaluate two ASCII character strings in HH:MM format and
; return their difference.
;
; Entry point:	TIMDF4
; Externals:	STTIM4
;		ENTIM4
;		ELATM4
;
; Input parameters:
; sttim4 holds a time string of HH:MM format. sttim4 must point
; to the tens hours digit. The time string must be in 24 hour format.
; The time stored there should be the beginning time of an event.
;
; entim4 holds a string with the same format. The time stored there
; should be the end of an event.
;
; On return, elatm4 will be filled with the elapsed time in
; hours and minutes and the accumulator will be cleared with the
; ZERO flag SET. If either entry parameter contained an illegal
; quantity, the CARRY flag will be SET and elatm4 will be undefined.
; NOTE: TIMDIF will not place delimiters into elatm4!
;
;
; NOTE:
; If entim4 is smaller than sttim4, then 24 hours are added to entim4.
;
; This routine is intended for application where the event time will
; never be greater than 23:59:59 (RCPM and BBS use mainly).
;
	PUBLIC	TIMDF4		;entry point
	EXTRN	STTIM4		;start time field
	EXTRN	ENTIM4		;end time field
	EXTRN	ELATM4		;elapsed time field
;
	cseg
;
; Entry point. All registers meet their doom...
;
timdf4:	lxi	h,sttim4+3	;point to seconds start
	call	getbin		;get binary
	mov	d,a		;save it
	lxi	h,entim4+3	;seconds end
	call	getbin		;get binary
	mvi	e,0		;reset our private borrow flag
	sub	d		;subtract
	jnc	skbs		;skip if no borrow
	dcr	e		;set our borrow flag
	adi	60		;make mod 60
skbs:	lxi	h,elatm4+4	;store as result
	call	stora
;
; Finally, here go the hours.
;
	lxi	h,sttim4	;hours start
	call	getbin		;get 'em
	mov	d,a		;save start hours
	lxi	h,entim4	;hours end
	call	getbin		;get binary
	inr	e		;if not borrow...
	jnz	skbh1		;...then skip...
	inr	d		;...else add borrowed hour
skbh1:	sub	d		;subtract
	jnc	skbh2		;jump if no borrow
	adi	24		;else add 24 hours
skbh2:	lxi	h,elatm4+1	;save as hours
	call	stora
	xra	a		;make sure error is reset
	ret			;end of execution, back to caller.
;
; Get the ASCII value at HL as a binary into A
;
getbin:	mov	a,m		;get tens
	ani	0fh		;strip ASCII offset
	mov	b,a		;save tens
	xra	a		;set accumulator
	mvi	c,10		;set up cheap multiplier
mul:	add	c
	dcr	b
	jnz	mul
	mov	b,a		;save tens
	inx	h		;point to units
	mov	a,m		;get units
	ani	0fh		;same treatment
	add	b		;add the tens
	ret
;
; Store accumulator as ASCII digits at HL and HL+1
;
stora:	mvi	b,-1
tlp:	inr	b
	sui	10		;subtract 10
	jnc	tlp		;until borrow
	adi	10		;make mod 10
	ori	'0'		;make ASCII
	mov	m,a
	dcx	h
	mvi	a,'0'
	add	b
	mov	m,a
	ret
;
	end
ours st