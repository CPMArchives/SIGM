;DATE.ASM v 1.10   10/26/83
; S. Kluger El Paso RCPM
;
; This module will take the date in Digital Research
; format and change it into human-readable form.
;
;Input: The number of days since 01/01/78. @DCFLD
;	must be defined in the main module and be
;	a structure of format "mm/dd/yy$"
;Output:The structure at @DCFLD will contain the
;	date in ASCII.
;
; The routine works, don't ask me why. If you think it's
; too kludgy or too big, feel free to change it. Just
; don't leave my name off the ASM file, ok?
;
	PUBLIC	@DCVRT
	EXTRN	@DCFLD
;
	CSEG
;
; Enter with the number of days since 1-1-78 in HL
;
@dcvrt:	shld	drtime		;save it for now
	mvi	b,78		;set years counter
loop:	call	ckleap
	lxi	d,-365		;set up for subtract
	jnz	nolpy		;skip if no leap year
	dcx	d		;set for leap year
nolpy:	dad	d		;subtract
	jnc	ydone		;continue if years done
	mov	a,h
	ora	l
	jz	ydone
	shld	drtime		;else save days count
	inr	b		;increment years count
	jmp	loop		;and do again
;
; The years are now finished, the years count is in B
; and drtime holds the days (HL is invalid)
;
ydone:	call	ckleap		;check if leap year
	mvi	a,-28
	jnz	febno		;february not 29 days
	mvi	a,-29		;leap year
febno	sta	feb		;set february
	mov	a,b		;get years count
	lxi	h,@dcfld+7	;point to years field
	call	stasha		;stash A into years field
	lhld	drtime		;get days count
	lxi	d,mtable	;point to months table
	mvi	b,0ffh		;set up b for subtract
	mvi	a,0		;set a for # of months
mloop:	push	psw
	ldax	d		;get month
	mov	c,a		;put in C for subtract
	pop	psw
	shld	drtime		;save days count
	dad	b		;subtract
	inx	d		;increment months counter
	inr	a
	jc	mloop		;and loop for next month
;
; The months are finished, days count is on stack.
; First, calculate month.
;
mdone:	mov	b,a		;save months
	lhld	drtime
	mov	a,h
	ora	l
	jnz	nzd
	dcx d ! dcx d
	ldax	d
	cma ! inr a
	mov	l,a
	shld	drtime
	dcr	b
nzd:	mov	a,b
	push	h
	lxi	h,@dcfld+1	;point to months field
	call	stasha		;put a into months field
	pop	h		;get days count back
	mov	a,l		;into a
	lxi	h,@dcfld+4	;point to day field
;
; Plug the accumulator into <HL> as decimal
;
stasha:	push	b		;save bc as counter
	mvi	b,0		;initialize tens
stl:	cpi	10		; > 10?
	jc	got10		;no, done
	sui	10		;subtract 10 from A
	inr	b		;increment tens
	jmp	stl		;and loop
;
; B has the tens, A has the units. Store the units first
;
got10:	adi	'0'		;make ascii
	mov	m,a		;stash units
	mov	a,b		;get tens
	adi	'0'		;make ascii
	dcx	h		;point to tens
	mov	m,a
	pop	b		;restore bc
	ret
;
; This routine checks for leap years.
;
ckleap:	mov	a,b
	ani	0fch
	cmp	b
	ret
;
; This is the months table
;
mtable:	db	-31		;January
feb:	db	-28		;February
	db	-31,-30,-31,-30	;Mar-Jun
	db	-31,-31,-30	;Jul-Sep
	db	-31,-30,-31	;Oct-Dec
;
drtime:	dw	0		;temporary storage
;
	end

zd
	dcx d ! dcx d
	ldax	d
	cma ! inr a
	mov	l,a
	sh