

;	-----------------------------------------------------------
;	DUMP.COM is a utility provided by Digital Research in their
;	CP/M package. However, it is convenient to supplement the
;	original program with some additional features, as well as
;	cleaning up the code which is based on their PL/M compiler.
;	Accordingly, the display line formed from a serial address
;	and sixteen hexadecimal bytes is supplemented by the ASCII
;	interpretation of these same bytes, as is done by DDT.
;
;		    DUMMP.ASM   Copyright (C) 1983
;		    Universidad Autonoma de Puebla
;		          September 22, 1983
;
;	[Harold V. McIntosh, 22 September 1983]
;	-----------------------------------------------------------


BDOS	equ	0005H	;BDOS entry point

TFCB	equ	5CH	;FILE CONTROL BLOCK ADDRESS
TSIZ	equ	80H	;size of input buffer
TBUF	equ	80H	;input buffer address

;	Non-graphic characters

CR	equ	0DH	;carriage return
LF	equ	0AH	;line feed


;	-------------
	org	0100H
;	-------------

begn:	lxi	h,0000
	dad	sp
	shld	stak
	lxi	sp,stak
	lda	TFCB+1
	cpi	' '
	jz	tuto
	lxi	h,TFCB+9
	mov	a,m
	cpi	' '
	jnz	yext
	mvi	m,'C'
	inx	h
	mvi	m,'O'
	inx	h
	mvi	m,'M'
yext:	call	opef
	lxi	b,0000	;byte counter, kept in BC

loop:	call	rdsk
	ora	a
	jnz	gbye
	call	wbuf
	call	break	;check for manual interruption
	rrc
	jnc	loop
	lxi	d,dint
	call	mssg
gbye:	call	crlf
	lhld	stak
	sphl
	ret

wbuf:	lxi	h,TBUF
	call	wfor
wfor:	call	wtwo
wtwo:	call	wone
wone:	call	word
	call	dubl
	mov	a,c
	adi	16
	mov	c,a
	mov	a,b
	aci	0
	mov	b,a
	push	h
	call	hlin
	call	sngl
	pop	h
	call	alin
	jmp	crlf

hlin:	call	heig
heig:	call	hfor
hfor:	call	htwo
htwo:	call	hone
hone:	mov	a,m
	call	byte
	mvi	a,' '
	call	cona
	inx	h
	ret

alin:	call	aeig
aeig:	call	afor
afor:	call	atwo
atwo	call	aone
aone:	mov	a,m
	call	prpr
	inx	h
	ret

;	SUBROUTINES

break:	push	h
	push	d
	push	b
	mvi	c,11	;(0B) console status
	call	BDOS
	push	psw
	rrc
	jnc	brk
	mvi	c,1	;(01) read console
	call	BDOS
brk:	pop	psw
	pop	b
	pop	d
	pop	h
	ret

dubl:	call	sngl
sngl:	mvi	a,' '
	jmp	cona

crlf:	mvi	a,CR
	call	cona
	mvi	a,LF
	jmp	cona

word:	mov	a,b
	call	byte
	mov	a,c
byte:	push	psw
	rrc
	rrc
	rrc
	rrc
	call	nibl
	pop	psw
nibl:	ani	0FH
	adi	90H
	daa
	aci	40H
	daa
cona:	push	h
	push	d
	push	b
	mvi	c,2	;(02) char to console
	mov	e,a
	call	BDOS
	pop	b
	pop	d
	pop	h
	ret

;	Print printables, put dot for rest.

prpr:	cpi	07FH	;rubout
	jnc	prdo
	cpi	' '
	jnc	cona
prdo:	mvi	a,'.'
	jmp	cona

mssg:	mvi	c,9	;(09) print buffer
	jmp	BDOS

opef:	xra	a	;ZERO TO ACCUM
	sta	TFCB+32	;CLEAR CURRENT RECORD
	lxi	d,TFCB
	mvi	c,15	;(0F) open file
	call	BDOS
	inr	a
	rnz
	lxi	d,nfil
	call	mssg
	jmp	gbye

rdsk:	push	h
	push	d
	push	b
	lxi	d,TFCB
	mvi	c,20	;(14) read one record
	call	BDOS
	pop	b
	pop	d
	pop	h
	ret

tuto:	lxi	d,logo
	call	mssg
	jmp	gbye

nfil:	db	CR,LF,'Requested file not present.$'
dint:	db	'Dump interrupted.$'
logo:	db	CR,LF,'File Dump/ICUAP/September 22, 1983.',CR,LF,CR,LF
	db	'	DUMMP [D:]FILE[.EXT]',CR,LF,CR,LF
	db	'will allow viewing of FILE on the console. If .EXT',CR,LF
	db	'is not given, .CMD is assumed. Sixteen bytes will',CR,LF
	db	'be shown first in hexadecimal, then in ASCII, for',CR,LF
	db	'each line. Press any key to stop the display.',CR,LF
	db	'$'

	ds	16
stak	ds	2

	end
