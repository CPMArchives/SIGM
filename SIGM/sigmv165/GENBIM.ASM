
;	------------------------------------------------------------
;	Some programs, such as DDT.COM, can be executed together
;	with another program, but both of them cannot be situated
;	at the standard CP/M origin 0100H. To move one of them to
;	high memory without knowing in advance how much memory is
;	available needs a relocation scheme which can be carried
;	out at run time. Page relocation utilizes a bitmap which
;	shows the location of the high byte of all addresses that
;	the program contains. If the program has been assembled
;	with respect to origin zero, it can be moved to its final
;	location, following which its actual origin can be added
;	to all the bytes which have been marked. This is actually
;	the way that CP/M's DDT.COM has been written. GENBIM.ASM
;	is a program which will generate the necessary bitmap; it
;	requires two .COM files containing the same program, but
;	assembled at two different origins each corresponding to
;	a page boundary. Assuming that the only discrepancies be-
;	tween the two programs are the relocatable addresses, the
;	.BIM file is generated using the first disk and the first
;	filename as its own.
;
;		    GENBIM .ASM Copyright (C) 1983
;		    Universidad Autonoma de Puebla
;			  September 12, 1983
;
;	[Harold V. McIntosh, 12 Spetember 1983]
;	------------------------------------------------------------


LF	equ	0AH	;line feed
CR	equ	0DH	;carriage return

BDOS	equ	0005H	;jump to BDOS
TFCB	equ	005CH	;DDT's file control block
TBUF	equ	0080H	;DDT's sector buffer

;	-------------
	org	0100H
;	-------------

begn:	lxi	h,0000
	dad	sp
	shld	stak
	lxi	sp,stak
	lxi	h,logo		;"GENBIM/UAP"
	call	mssg
	lda	TFCB+1		;file name
	cpi	' '
	jz	tuto
	call	setup
	lxi	h,TFCB+9
	mvi	m,'B'
	inx	h
	mvi	m,'I'
	inx	h
	mvi	m,'M'

	mvi	c,15	;(0F) open file
	lxi	d,fcb1
	call	BDOS
	inr	a
	jz	err1
	mvi	c,15	;(0F) open file
	lxi	d,fcb2
	call	BDOS
	inr	a
	jz	err2
	mvi	c,19	;(13) delete file
	lxi	d,TFCB
	call	BDOS
	mvi	c,22	;(16) create file
	lxi	d,TFCB
	call	BDOS
	mvi	c,15	;(0F) open file
	lxi	d,TFCB
	call	BDOS

	xra	a
	sta	TFCB+32
	sta	fcb1+32
	sta	fcb2+32
	sta	byct
	inr	a
	lxi	b,TBUF
	stax	b

loop:	lda	byct
	ani	07FH
	jnz	rnb	;bytes in the buffer
	push	b
	mvi	c,26	;(1A) set DMA address
	lxi	d,buf1
	call	BDOS
	mvi	c,20	;(14) read one record
	lxi	d,fcb1
	call	BDOS
	mvi	c,26	;(1A) set DMA address
	lxi	d,buf2
	call	BDOS
	mvi	c,20	;(14) read one record
	lxi	d,fcb2
	call	BDOS
	ora	a
	pop	b
	jnz	reen	;end of record
	lxi	d,buf1
	lxi	h,buf2
	mvi	a,80H
rnb:	dcr	a
	sta	byct
	ldax	d
	sub	m
	sui	1
	cmc
	ldax	b
	ral
	stax	b
	jnc	inb
	inx	b
	mov	a,b
	ora	a
	jz	wri
	push	d
	push	h
	mvi	c,26	;(1A) set DMA address
	lxi	d,TBUF
	call	BDOS
	mvi	c,21	;(15) write one record
	lxi	d,TFCB
	call	BDOS
	lxi	b,TBUF
	pop	h
	pop	d
wri:	mvi	a,1
	stax	b
inb:	inx	d
	inx	h
	jmp	loop

reen:	ldax	b
	cpi	1
	jnz	last
	mov	a,b
	cpi	1
	jz	clos
last:	sub	a
	ldax	b
ree:	ral
	jnc	ree
	stax	b
rii:	inx	b
	mov	a,b
	ora	a
	jnz	finl
	xra	a
	stax	b
	jmp	rii
finl:	mvi	c,26	;(1A) set DMA address
	lxi	d,TBUF
	call	BDOS
	mvi	c,21	;(15) write one record
	lxi	d,TFCB
	call	BDOS
clos:	mvi	c,16	;(10) close file
	lxi	d,TFCB
	call	BDOS
gbye:	lhld	stak
	sphl
	ret

setup:	mvi	b,16
	lxi	d,TFCB
	lxi	h,fcb1
	call	moov
	mvi	b,16
	lxi	d,TFCB+16
	lxi	h,fcb2
moov:	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	b
	jnz	moov
	lxi	d,-7
	dad	d
	mov	a,m
	cpi	' '
	rnz
	mvi	m,'C'
	inx	h
	mvi	m,'O'
	inx	h
	mvi	m,'M'
	ret

;	Type CR,LF.

crlf:	mvi	a,CR
	call	aout	;A to console
	mvi	a,LF
	jmp	aout	;A to console

;	Type one or two spaces.

dubl:	call	sngl
sngl:	mvi	a,' '

;	A to console

aout:	push	h
	push	d
	push	b
	mov	e,a
	mvi	c,02
	call	BDOS
	pop	b
	pop	d
	pop	h
	ret	

;	Type A as two nibbles

word:	mov	a,d
	call	byte
	mov	a,e
byte:	push	psw	
	rar	
	rar	
	rar	
	rar	
	call	nybl
	pop	psw
nybl:	ani	0FH
	adi	90H
	daa
	aci	40H
	daa
	jmp	aout	;A to console

;	Message terminated by zero to console

mssg:	mov	a,m
	ora	a
	rz
	call	aout	;A to console
	inx	h
	jmp	mssg

err1:	lxi	h,er1
	call	mssg
	jmp	gbye

err2:	lxi	h,er2
	call	mssg
	jmp	gbye

tuto:	lxi	h,scrp
	call	mssg
	jmp	gbye

;	---------------------------------------------------------

logo:	db	'         GENBIM/ICUAP',CR,LF
	db	'Universidad Autonoma de Puebla',CR,LF
	db	'      September 12, 1983',CR,LF,00

er1:	db	'Cannot open .COM file',00
er2:	db	'Cannot open comparison file',00
scrp:	db	CR,LF,CR,LF
	db	'GENBIM.COM is a program which will generate a bitmap',CR,LF
	db	'which can be used for the pagewise relocation of a',CR,LF
	db	'binary file. It requires two copies of the same .COM',CR,LF
	db	'file, whose origins differ by an integral number of',CR,LF
	db	'pages. The command line:',CR,LF,CR,LF
	db	'      GENBIM [X:]FILE1[.AAA],[Y:]FILE2[.BBB]',CR,LF,CR,LF
	db	'will produce the bitmap in [X:]FILE1.BIM. The last',CR,LF
	db	'record will be completed with trailing zeroes. The',CR,LF
	db	'default extension is .COM, but some other explicit',CR,LF
	db	'extension may be used as desired.',CR,LF
	db	CR,LF
	db	00

	ds	20
stak:	ds	2
fcb1:	ds	33
fcb2:	ds	33
byct:	ds	1
bipt:	ds	2
borg:	ds	2
buf1:	ds	80H
buf2:	ds	80H


