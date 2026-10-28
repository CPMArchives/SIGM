;TIMEDIF.ASM v1.10
;12/28/83
;By S. Kluger
;
; the fact that a major bug has not been discovered yet by
; anyone proves the popularity of the program...
;
; This is a module for use with RMAC and can be adapted to
; M80 with minimum effort.
;
; Purpose:
; Evaluate two ASCII character strings in HH:MM:SS format and
; return their difference.
;
; Entry point:	TIMDIF
; Externals:	STTIME
;		ENTIME
;		ELAPTM
;
; Input parameters:
; STTIME holds a time string of HH:MM:SS format. STTIME must point
; to the tens hours digit. The time string must be in 24 hour format.
; The time stored there should be the beginning time of an event.
;
; ENTIME holds a string with the same format. The time stored there
; should be the end of an event.
;
; On return, ELAPTM will be filled with the elapsed time in
; hours and minutes and the accumulator will be cleared with the
; ZERO flag SET. If either entry parameter contained an illegal
; quantity, the CARRY flag will be SET and ELAPTM will be undefined.
; NOTE: TIMDIF will not place delimiters into ELAPTM!
;
; Only the first 8 characters of the strings are processed and checked
; for proper range. Be sure to zero the seconds field if not needed!
;
; NOTE:
; If ENTIME is smaller than STTIME, then 24 hours are added to ENTIME.
;
; This routine is intended for application where the event time will
; never be greater than 23:59:59 (RCPM and BBS use mainly).
;
	PUBLIC	TIMDIF		;entry point
	EXTRN	STTIME		;start time field
	EXTRN	ENTIME		;end time field
	EXTRN	ELAPTM		;elapsed time field
;
	cseg
;
; Entry point. All registers meet their doom...
;
timdif:	lxi	h,sttime	;point to start time
	call	chform		;check proper format
	rc			;return if error
	lxi	h,entime	;point to end time
	call	chform		;check that too
	rc
;
; The stage is set - let's get down to business...
;
	lxi	h,sttime+6	;point to seconds start
	call	getbin		;get binary
	mov	d,a		;save it
	lxi	h,entime+6	;seconds end
	call	getbin		;get binary
	mvi	e,0		;reset our private borrow flag
	sub	d		;subtract
	jnc	skbs		;skip if no borrow
	dcr	e		;set our borrow flag
	adi	60		;make mod 60
skbs:	lxi	h,elaptm+7	;store as result
	call	stora
;
; Do the same stuff for minutes
;
	lxi	h,sttime+3	;minutes start
	call	getbin		;get binary
	mov	d,a		;save binary
	lxi	h,entime+3	;minutes end
	call	getbin		;get binary
	inr	e		;if not borrow...
	jnz	skbm1		;then skip...
	inr	d		;...else add borrowed value
skbm1:	mvi	e,0		;make sure borrow flag reset
	sub	d		;subtract
	jnc	skbm2		;skip if no borrow
	dcr	e		;set borrow
	adi	60		;make mod 60
skbm2:	lxi	h,elaptm+4	;store elapsed minutes
	call	stora
;
; Finally, here go the hours.
;
	lxi	h,sttime	;hours start
	call	getbin		;get 'em
	mov	d,a		;save start hours
	lxi	h,entime	;hours end
	call	getbin		;get binary
	inr	e		;if not borrow...
	jnz	skbh1		;...then skip...
	inr	d		;...else add borrowed hour
skbh1:	sub	d		;subtract
	jnc	skbh2		;jump if no borrow
	adi	24		;else add 24 hours
skbh2:	lxi	h,elaptm+1	;save as hours
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
; Check format of HH:MM:SS string. Checks all digits for presence
; and validity.
;
chform:	mov	a,m		;get 10s H
	cpi	'0'
	rc
	cpi	'3'
	cmc
	rc
	inx	h
	mov	a,m		;get 1s H
	call	ck10		;check decimal
	rc
	inx	h		;get colon
	mov	a,m
	cpi	':'
	stc
	rnz
	inx	h		;point to 10s M
	mov	a,m
	call	ck6		;check hex
	rc
	inx	h
	mov	a,m		;1s M
	call	ck10
	rc
	inx	h
	mov	a,m		;get delimiter
	cpi	':'
	stc
	rnz
	inx	h
	mov	a,m		;get 10s S
	call	ck6
	rc
	inx	h
	mov	a,m
ck10:	cpi	'0'
	rc
	cpi	'9'+1
	cmc
	ret
;
ck6:	cpi	'0'
	rc
	cpi	'7'
	cmc
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
tor
	