;UNDATE.ASM v 1.00         10/26/83
; S. Kluger  El Paso RCPM
;
; This routine will take a standard ASCII date string
; and change it into Digital Research date format.
;
; Input: none
; 	(The program expects the external variable @dcfld
;	to be a pointer to a properly set up date string.
;	The string must conform to MM/DD/YY format.)
; Output: HL holds the number of days since 1-1-78
;	The carry flag indicates a possible date format error.
;
	EXTRN	@DCFLD
	PUBLIC	@UDCVT
;
@udcvt:	lxi	h,@dcfld+7	;point to units year
	mov	a,m		;get it
	call	cknum		;if not numeric...
	rc			;...then error
	mov	b,a		;save for now
	dcx	h		;point to tens year
	mov	a,m		;get it
	call	cknum		;check numeric
	rc			;abort if error
	mov	c,a		;tens into c
	inr	c		;plus one for our loop
	mvi	d,10
	xra	a
mcy:	dcr	c
	jz	mcyd		;zero = done
	add	d
	jmp	mcy
;
mcyd:	add	b		;add units
	mvi	b,78		;set up years counter
	cmp	b
	rc			;error if year < 78
	mov	c,a		;year into c
	ani	0fch		;is current leap?
	cmp	c
	mvi	a,28		;expect not
	jnz	nocl
	inr	a
nocl:	sta	feb
	lxi	h,0		;set day counter
ylp:	mov	a,c		;get year
	cmp	b		;is it 78 now?
	jz	ydone		;yes, exit this routine
	lxi	d,365		;set days for 1 year
	dcr	c		;decrement year
	dcr	a		;both times
	ani	0fch		;check leap year
	cmp	c		;if not leap year...
	jnz	nolp		;...then leap
	inx	d		;else make 366 days
nolp:	dad	d		;sum up days
	jmp	ylp
;
; years done, process months
;
ydone:	shld	days		;save day count for now
	lxi	h,@dcfld+1	;point to units month
	mov	a,m		;get them
	call	cknum		;check numeric
	rc			;ret if error
	mov	b,a		;save units
	dcx	h		;point to units
	mov	a,m		;get 'em
	call	cknum		;check
	rc			;ret if error
	cpi	2		;if > 1
	cmc ! rc		;then error
	ora	a		;if not zero...
	mvi	a,10		;...then it's gotta be 10
	jnz	adu
	xra	a
adu:	add	b		;easier than years!
	lxi	b,month		;point to months
	mvi	h,0
	mov	l,a
	dad	b		;make months pointer
	mov	b,h
	mov	c,l
	dcx	b
	lhld	days
	mvi	d,0		;prepare for add
mlp:	dcr	a		;decrement year
	dcx	b
	jz	mdone		;go to next routine
	push	psw
	ldax	b		;get days
	mov	e,a
	dad	d		;add to total
	pop	psw
	jmp	mlp
;
; months done, now process the days
;
mdone:	shld	days		;save days for now
	lxi	h,@dcfld+4	;point to days units
	mov	a,m		;get them
	call	cknum		;if not numeric
	rc			;then return
	mov	b,a		;save units
	dcx	h		;point to tens
	mov	a,m
	call	cknum
	rc
	cpi	4		;if over 30
	cmc ! rc		;then error
	mov	c,a		;save count
	inr	c		;0=1, 1=2, etc
	xra	a
	mvi	d,10		;ready for "multiply"
mc:	dcr	c		;dec counter
	jz	mulok		;finished multiplying
	add	d
	jmp	mc
;
mulok:	add	b		;now make binary days
	mov	e,a
	mvi	d,0
	lhld	days
	dad	d
	ora	a		;reset carry
	ret
;
; check numeric digit, convert to binary if ok
;
cknum:	cpi	'0'
	rc
	cpi	'9'+1
	cmc ! rc
	ani	0fh
	ret
;
month:	db	31		;Jan
feb:	db	28,31,30,31,30	;Feb-Jun
	db	31,31,30,31,30	;Jul-Nov
;
days:	dw	0
	end
mov	b,h
	mov	c,l
	dcx	b
	lhld	days
	mvi	d,0		;prepare for add
mlp:	dcr	a		;dec