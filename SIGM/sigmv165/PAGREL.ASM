
LF	equ	0AH	;line feed
CR	equ	0DH	;carriage return

BDOS	equ	0005	;jump to CP/M

	org	0100H

X0100:	jmp	X013D
porg:	dw	0BBBBH	;program origin (even page)
pend:	dw	0EEEEH	;program end (even number of pages)
hiya:	db	'hello',CR,LF,'$'
X013D:	lxi	sp,stak
	lhld	pend
	xchg
	lhld	porg
	mov	a,e
	sub	l
	mov	l,a
	mov	a,d
	sbb	h
	mov	h,a
	push	h
	push	h
	lxi	d,hiya
	mvi	c,09		;(09) print buffer
	call	0005
	pop	b
	lxi	h,BDOS+2	;end of memory
	mov	a,m
	dcr	a
	sub	b
	mov	d,a
	mvi	e,00
	push	d
	lhld	porg
shif:	mov	a,b
	ora	c
	jz	rloc
	dcx	b
	mov	a,m
	stax	d
	inx	d
	inx	h
	jmp	shif

rloc:	pop	d
	pop	b
	push	h
	mov	h,d
relo:	mov	a,b
	ora	c
	jz	gogo
	dcx	b
	mov	a,e
	ani	07
	jnz	rotl
	xthl
	mov	a,m
	inx	h
	xthl
	mov	l,a
rotl:	mov	a,l
	ral	
	mov	l,a
	jnc	nmod
	ldax	d
	add	h
	stax	d
nmod:	inx	d
	jmp	relo

gogo:	pop	d
	mvi	l,00
	pchl

	org	0200H

stak:	ds	0

	end
