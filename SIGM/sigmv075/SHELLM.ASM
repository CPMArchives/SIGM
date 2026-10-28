.TITLE	'IN MEMORY SHELL-metzner sort'
.sbttl	'from KILOBAUD april 1981 p164'
;
.remark	'For fixed length records stored in memory
	Put no. of records in n1 and m1. The length
	of each record is stored at k1, and the starting
	address at j1. Start sort by calling location
	"entry". To change to descending sort change the
	instruction at neq: to DAH.'
;
n1:	.word	0	; number of records
m1:	.word	0	; ..same here
k1:	.word	0	; length of records
j1:	.word	0	; starting address of strings
i1:	.word	0	; ptr
ml1:	.word	0	; ptr
dj1:	.word	0	; ptr
di1:	.word	0	;ptr
;
entry:	lhld	j1	; get start address
	push	h	; ..save
	lhld	k1	; get length
	push	h	; ..it too
div:	xra	a	; m1=m1/2
	lhld	m1
	mov	a,h
	rar
	mov	h,a
	mov	a,l
	rar
	mov	l,a
	shld	m1	; save new m1
;
	ora	h	; check if done
	jnz	ndon
	pop	b	; finished
	pop	d	; ..so return
	ret		; ...now
;
;	set k1=n1-m1
;
ndon:	xchg		; m1 to de
	lhld	n1
	mov	a,l
	sub	e
	mov	l,a
	mov	a,h
	sbb	d
	mov	h,a
	shld	k1
	lxi	h,1	; set and save i=j=1
	shld	j1
	shld	i1
;
;	calc & save addr offset = m1*i1
;
	dcr	l
	pop	b	; length of str=i1
	push	b	; ..put it back
lp1:	dad	d
	dcx	b
	mov	a,b
	ora	c
	jnz	lp1
	shld	ml1
;
	xchg		; calc & save d(j), d(i), d(i+m)
	pop	b
	pop	h
	push	h
	push	b
lp2:	shld	dj1
	shld	di1
	xchg
	dad	d
	xchg		; HL has d(i), DE has d(i+m)
;
;	compare strings and switch
;
cp1:	pop	b	; len of string=l1
	push	b
lp3:	ldax	d	; compare each byte
	sub	m
	jnz	neq	; not equal
	inx	h	; if =, then next byte
	inx	d
	dcx	b
	mov	a,b
	ora	c
	jnz	lp3
	jmp	nsw	; if done, don't switch
;
;	change next instruction to jc for descending
;
neq:	jnc	nsw	; if d(i)<d(i+m) don't switch
;
sw:	push	b	; switch bytes not equal
	mov	b,m
	ldax	d
	mov	m,a
	mov	a,b
	stax	d
	inx	h
	inx	d
	pop	b
	dcx	b
	mov	a,b
	ora	c
	jnz	sw
;
;	strings switched, chk if i1-m1 < 1
;
	lhld	m1
	mov	a,h
	cma
	mov	d,a
	mov	a,l
	cma	
	mov	e,a
	lhld	i1
	dad	d	; if i1-m1<1 then jump to same as
			; ..no switch
	jnc	nsw
;
;	calc new d(i), d(i+m)
;
	inx	h	; save	new i1=i1-m
	shld	i1
	lhld	di1	; old d(i)=new d(i+m)
	xchg
	lhld	ml1	; address offset
	mov	a,e	; new d(i)=old d(i)-offset
	sub	l
	mov	l,a
	mov	a,d
	sbb	h
	mov	h,a
	shld	di1	; save new d(i)
	jmp	cp1	; goto compare strings
;
;	check for j>k
;
nsw:	lhld	j1
	inx	h	; save new j=old j+1
	shld	j1
	shld	i1
	xchg
	lhld	k1
	mov	a,l
	sub	e
	mov	a,h
	sbb	d
	jc	div	; if j>k goto beginning and
			; ..divide m1
;
;	calc new d(j), d(i)
;
	lhld	dj1
	pop	d
	push	d
	dad	d	; new d(j)=old d(j+1)
	xchg
	lhld	ml1
	xchg
	jmp	lp2
;
; that all folks
;
	.end	entry
