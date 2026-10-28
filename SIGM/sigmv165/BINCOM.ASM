
;	--------------------------------------------------------
;	BINCOM.COM is a program which can be used to compare
;	two files, which will probably be binary, to find the
;	differences between them. The files are compared byte
;	for byte. No attempt is made to vary the match points
;	to establish a different synchronization if a prolonged
;	mismatch is found, as would be done for ASCII files.
;	The command line is:
;
;	      BINCOM [X:]FILE1.COM,[Y:]FILE2.COM
;
;	Discrepancies will be noted at the console in a line
;	of the form
;			XXXX YY ZZ
;	where XXXX is the number of the discrepant byte, YY in
;	FILE1 but ZZ in FILE2. Pressing any key at the console
;	will stop the comparison, but in any event there will
;	be a final total shown of the bytes compared and the
;	number of mismatches encountered.
;
;		    BINCOM .ASM Copyright (C) 1983
;		    Universidad Autonoma de Puebla
;			  September 16, 1983
;
;	[Harold V. McIntosh, 16 September 1983]
;	--------------------------------------------------------


LF	equ	0AH	;line feed
CR	equ	0DH	;carriage return

BDOS	equ	0005H	;jump to BDOS
TFCB	equ	005CH	;DDT's file control block
TSIZ	equ	0080H	;size of record buffer

;	-------------
	org	0100H
;	-------------

begn:	lxi	h,0000
	dad	sp
	shld	stak
	lxi	sp,stak
	lxi	h,logo		;"BINCOM/UAP"
	call	mssg
	lda	TFCB+1		;file name
	cpi	' '
	jz	tuto
	call	setup

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

	xra	a
	sta	fcb1+32
	sta	fcb2+32
	sta	byct
	sta	neql
	inr	a
	sta	rect
	mvi	a,4
	sta	clmn

	lxi	h,0000
	shld	erct

	lxi	b,0000

loop:	lda	byct
	ani	07FH
	jnz	rnb	;bytes in the buffer
	lda	rect
	dcr	a
	jnz	rna
	push	b

	lxi	b,0008H	;eight-sector buffer
	lxi	d,buf1
	lxi	h,fcb1
	call	filb

	push	b
	lxi	b,0008H	;eight-sector buffer
	lxi	d,buf2
	lxi	h,fcb2
	call	filb

	pop	psw
	cmp	b
	jz	eql
	lxi	h,neql
	jc	neq
	mov	a,b
	mvi	m,'2'
	jmp	eql
neq:	mvi	m,'1'
eql:	pop	b
	cpi	00
	jz	enfi	;end of record
	lxi	d,buf1
	lxi	h,buf2
rna:	sta	rect
	mvi	a,80H
rnb:	dcr	a	;read next pair of bytes
	sta	byct
	ldax	d
	cmp	m
	cnz	rprt	;report discrepancy
	call	recs
	jnz	quit
	inx	b
	inx	d
	inx	h
	jmp	loop

;	Type summary message at the end of the run.

quit:	call	crlf
	lxi	h,me3
	call	mssg
enfi:	push	b
	call	crlf
	lxi	h,me1
	call	mssg
	pop	h
	call	word
	mvi	a,'H'
	call	aout
	call	crlf
	lxi	h,me2
	call	mssg
	lhld	erct
	call	word
	mvi	a,'H'
	call	aout
	call	crlf
	lda	neql
	ora	a
	jz	gbye
	lxi	h,fcb1+1
	cpi	'1'
	jz	enf
	lxi	h,fcb2+1
enf:	call	mssg
	lxi	h,me4
	call	mssg
gbye:	lhld	stak
	sphl
	ret

setup:	mvi	b,16
	lxi	d,TFCB
	lxi	h,fcb1
	call	moov

	lxi	h,me5
	call	mssg
	lxi	h,fcb1+1
	call	mssg
	call	crlf

	mvi	b,16
	lxi	d,TFCB+16
	lxi	h,fcb2
	call	moov

	lxi	h,me6
	call	mssg
	lxi	h,fcb2+1
	call	mssg
	call	crlf
	jmp	crlf

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

;	Fill buffer DE using FCB HL. On return, B = # sectors read.

filb:	push	b
	push	d
	push	h
	mvi	c,26	;(1A) set DMA address
	call	BDOS
	pop	d
	push	d
	mvi	c,20	;(14) read one record
	call	BDOS
	pop	d
	pop	h
	lxi	b,TSIZ
	dad	b
	xchg
	pop	b
	cpi	00
	jnz	fic
	inr	b
	dcr	c
	jnz	filb
	ret
fic:	cpi	01
	rz
	ret

;	Type CR,LF.

crlf:	mvi	a,CR
	call	aout	;A to console
	mvi	a,LF
	jmp	aout	;A to console

;	Type one, two, or four spaces.

quad:	call	dubl
dubl:	call	sngl
sngl:	mvi	a,' '

;	A to console

aout:	push	h
	push	d
	push	b
	mov	e,a
	mvi	c,02	;(02) A to console
	call	BDOS
	pop	b
	pop	d
	pop	h
	ret	

;	Read console status: nz/z = char waiting/not.

recs:	push	b
	push	d
	push	h
	mvi	c,11	;(0B) read console status
	call	BDOS
	ani	01
	push	psw
	jz	rcs
	mvi	c,1	;(01) read console
	call	BDOS
rcs:	pop	psw
	pop	h
	pop	d
	pop	b
	ret

;	Type A as two nibbles

word:	mov	a,h
	call	byte
	mov	a,l
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

;	Type discrepancy report.

rprt:	push	h
	push	b
	lhld	erct
	inx	h
	shld	erct
	pop	h
	call	word
	call	dubl
	pop	h
	mov	a,m
	call	byte
	call	sngl
	ldax	d
	call	byte
	call	sngl
	call	quad
	lda	clmn
	dcr	a
	jnz	rpr
	call	crlf
	mvi	a,4
rpr:	sta	clmn
	ret

;	Message terminated by zero to console

mssg:	mov	a,m
	ora	a
	rz
	call	aout	;A to console
	inx	h
	jmp	mssg

err1:	lxi	h,er1
	jmp	cmss

err2:	lxi	h,er2
	jmp	cmss

tuto:	lxi	h,scrp
cmss:	call	mssg
	jmp	gbye

;	---------------------------------------------------------

logo:	db	'         BINCOM/ICUAP',CR,LF
	db	'Universidad Autonoma de Puebla',CR,LF
	db	'      September 16, 1983',CR,LF,CR,LF,00

er1:	db	'Cannot open first file.',00
er2:	db	'Cannot open second file.',00
me1:	db	'Number of bytes compared:   ',00
me2:	db	'Number of mismatches found: ',00
me3:	db	'Comparison interrupted...',00
me4:	db	' was shorter.',CR,LF,00
me5:	db	'File 1:  ',00
me6:	db	'File 2:  ',00
scrp:	db	'BINCOM.COM is a program which can be used to compare',CR,LF
	db	'two files, which will probably be binary, to find the',CR,LF
	db	'differences between them. The files are compared byte',CR,LF
	db	'for byte. No attempt is made to vary the match points',CR,LF
	db	'to establish a different synchronization if a prolonged',CR,LF
	db	'mismatch is found, as would be done for ASCII files.',CR,LF
	db	'The command line is:',CR,LF,CR,LF
	db	'      BINCOM [X:]FILE1.COM,[Y:]FILE2.COM',CR,LF,CR,LF
	db	'Discrepancies will be noted in the form',CR,LF,CR,LF
	db	'		XXXX YY ZZ',CR,LF,CR,LF
	db	'where XXXX is the discrepant byte, YY in FILE1 but ZZ',CR,LF
	db	'in FILE2. Use any key to halt the comparison. Final',CR,LF
	db	'totals - of bytes compared and mismatches found - will',CR,LF
	db	'always be shown.',CR,LF
	db	00

	ds	20
stak:	ds	2
fcb1:	ds	33
fcb2:	ds	33
byct:	ds	1	;byte count
rect:	ds	1	;record count
erct:	ds	2
neql:	ds	1	;FF=different file lengths
clmn:	ds	1	;coumn counter
borg:	ds	2
buf1:	ds	400H	;eight-sector buffer
buf2:	ds	400H	;eight-sector buffer

	end
