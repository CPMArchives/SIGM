

;	------------------------------------------------------------
;	LOHD.ASM is a revision of Digital Research's LOAD.COM, which
;	is evidently a PL/M program. The revision has reduced its
;	volume by 2/3, but its execution is disk-bound to the point
;	that the speed difference is not outwardly apparent. Other
;	changes include:
;	    1. An origin below 0100H - CP/M's transient origin - no
;	  longer produces an error condition if it is 0000H. Thus a
;	  file assembled to origin 0000 can be passed from .HEX to
;	  .COM, such as if it were the code for a self-relocating
;	  program such as DDT.
;	    2. The .COM buffer is zeroed before each use, so that
;	  gaps in the code sequence, the result of a <ds> or of an
;	  <org>, are filled with zeroes rather than being left to
;	  gather whatever trash is in the buffer as they are found.
;	  The .COM code is passed through a one-page window, so that
;	  any origin redefined below that range will draw an error
;	  message, as in LOAD.COM.
;
;	[Harold V. McIntosh, 22 September 1983]
;	------------------------------------------------------------


BDOS	equ	0005H
TFCB	equ	005CH
TSIZ	equ	0080H
TORG	equ	0100H
CSIZ	equ	0100H	;size of .COM buffer
HSIZ	equ	0400H	;size of hexfile buffer

LF	equ	0AH
CR	equ	0DH

;	-------------
	org	0100H
;	-------------

begn:	lxi	h,0000
	dad	sp
	shld	stak	;save sp
	lxi	sp,stak	;stackend
	lxi	h,CSIZ
	shld	cinx	;.COM index
	call	cbuz	;clear CBUF
	lxi	h,HSIZ
	shld	hinx	;hexfile index
	lda	TFCB+1
	cpi	' '
	jnz	nnul
	lxi	d,logo
	call	mssg
	lxi	d,tuto
	call	mssg
	jmp	gbye	;normal exit

nnul:	mvi	c,021H	;count
	lxi	d,TFCB	;source
	lxi	h,HFCB	;.HEX FCB = destination
	call	miuc

	mvi	c,4	;count
	lxi	d,X01F7	;'hex' = source
	lxi	h,HFCB+9;.HEX ext = destination
	call	miuc

	lxi	d,HFCB	;.HEX FCB
	mvi	c,15	;(0F) open file
	call	BDOS
	cpi	0FFH
	lxi	d,X01FB	;'can''t open source'
	jz	tema	;type err mess w/addr

	mvi	c,3	;count
	lxi	d,X020E	;'COM' = source
	lxi	h,TFCB+9;destination
	call	miuc

	lxi	d,TFCB
	mvi	c,19	;(13) delete file
	call	BDOS

	lxi	d,TFCB
	mvi	c,22	;(16) create file
	call	BDOS

	lxi	d,TFCB
	mvi	c,15	;(0F) open file
	call	BDOS
	cpi	0FFH
	lxi	d,X0211	;'no more directory'
	jz	tema	;type err mess w/addr

	call	hefi	;process the .HEX file

	lxi	d,TFCB
	mvi	c,16	;(10) close file
	call	BDOS
	cpi	0FFH
	lxi	d,X0229	;'can''t close file'
	jz	tema	;type err mess w/addr

fini:	call	crlf	;CR,LF
gbye:	lhld	stak	;save sp
	sphl
	ret

;	Type CR, LF.

crlf:	mvi	a,CR
	call	cona	;console from A
	mvi	a,LF
	jmp	cona	;console from A

word:	mov	a,h
	call	byte	;type A as two nibbles
	mov	a,l
byte:	push	psw
	rar
	rar
	rar
	rar
	call	nibl	;type A as hex
	pop	psw
nibl:	ani	0FH
	adi	90H
	daa
	aci	40H
	daa
cona:	push	h
	push	d
	mov	e,a
	mvi	c,2	;(02) write console
	call	BDOS
	pop	d
	pop	h
	ret

;	Type message at (DE).

mssg:	call	crlf	;CR,LF
mess:	mvi	c,9	;(09) type buffer
	jmp	BDOS

;	Type error message with address.

tema:	push	d
	lxi	d,X0129	;'error'
	call	mssg	;type CRLF, mssg
	pop	d
	call	mess	;type mess at (DE)
	lxi	d,X0131	;'load address'
	call	mess	;type mess at (DE)
	lhld	cinx	;.COM index
	call	word	;type HL in four nibbles
	jmp	gbye	;normal exit

;	Block move.

miuc:	ldax	d
	mov	m,a
	inx	h
	inx	d
	dcr	c
	jnz	miuc
	ret

;	Get next hexfile element.

nxhx:	lhld	hinx	;hexfile index
	inx	h
	lxi	d,HSIZ
	mov	a,l
	sub	e
	mov	a,h
	sbb	d
	jc	nxhv	;byte available
	lxi	h,0000
nxhy:	shld	hinx	;hexfile index
	lxi	d,HSIZ
	mov	a,l
	sub	e
	mov	a,h
	sbb	d
	jnc	nxhu	;reset hexfile, read 1st element
	lxi	d,HBUF
	dad	d
	xchg
	mvi	c,26	;(1A) set DMA address
	call	BDOS
	lxi	d,HFCB	;.HEX FCB
	mvi	c,20	;(14) read one record
	call	BDOS
	cpi	000H
	jz	nxhz	;add record to hexfile
	cpi	001H
	lxi	d,X0141	;'disk read'
	jnz	tema	;type err mess w/addr
	lhld	hinx	;hexfile index
	lxi	d,HBUF	;hexfile buffer
	dad	d
	mvi	m,01AH	;^Z
	lxi	h,HSIZ-1
	shld	hinx	;hexfile index
nxhz:	lhld	hinx	;hexfile index
	lxi	d,TSIZ
	dad	d
	jmp	nxhy	;no more refills

nxhu:	lxi	h,0000
nxhv:	shld	hinx	;hexfile index
	lxi	d,HBUF	;hexfile buffer
	dad	d
	mov	a,m
	ret

;	Start reading the .HEX file, and keep going.

hefi:	lxi	h,0FFFFH
	shld	mina	;minimum address
	lxi	h,0000
	shld	maxa	;maximum address
	shld	byco	;byte counter
	xra	a
	sta	reco	;record counter
	lxi	h,TORG
	shld	ladr	;load address
	shld	rbrk	;record breakpoint
	shld	cinx	;.COM index
	lxi	h,HBUF	;hexfile buffer
	mvi	m,01AH	;^Z
inhx:	call	nxhx	;next hexfile element
	sui	':'
	jnz	inhx	;advance to ":"
	mov	d,a	;checksum in D
	call	hexb	;assemble byte, augment checksum
	mov	e,a	;bytecount in E
	cpi	00H
	jnz	nlin	;this isn't "end" line
	lhld	cinx	;.COM index
	xchg
elin:	lhld	rbrk	;record breakpoint
	mov	a,l	;cmp(HL,DE)
	sub	e
	mov	a,h
	sbb	d
	jnc	stat	;type statistics
	xra	a
	call	comb	;insert byte in .COM buffer
	jmp	elin	;fill out buffer with zeroes

nlin:	lhld	byco	;byte counter
	push	d
	mvi	d,00
	dad	d
	pop	d
	shld	byco	;byte counter
	call	hexb	;assemble byte, augment checksum
	push	psw
	call	hexb	;assemble byte, augment checksum
	pop	h
	mov	l,a
	ora	h
	jnz	horg	;high (non-zero) origin
	shld	rbrk	;record breakpoint
horg:	shld	ladr	;load address
	shld	cinx	;.COM index
	lhld	mina	;minimum address
	inx	h
	mov	a,h
	ora	l
	jnz	nmin
	lhld	cinx	;.COM index
	shld	mina	;minimum address
nmin:	call	hexb	;assemble byte, augment checksum
ihli:	call	hexb	;assemble byte, augment checksum
	call	comb	;insert byte in .COM buffer
	dcr	e
	jnz	ihli
	push	d
	lhld	maxa	;maximum address
	xchg
	lhld	cinx	;.COM index
	mov	a,e
	sub	l
	mov	a,d
	sbb	h
	jnc	nmax
	dcx	h
	shld	maxa	;maximum address
nmax:	pop	d
	call	hexb	;assemble byte, augment checksum
	mov	a,d
	cpi	00H
	jz	inhx	;on to next line
	lxi	d,X01A8	;'check sum error'
	call	mssg	;type CRLF, mssg
	jmp	erst	;type error statistics

;	Type summary of statistics.

stat:	lxi	d,X01B9	;'first address'
	call	mssg	;type CRLF, mssg
	lhld	mina	;minimum address
	call	word	;type HL in four nibbles
	lxi	d,X01C8	;'last address'
	call	mssg	;type CRLF, mssg
	lhld	maxa	;maximum address
	call	word	;type HL in four nibbles
	lxi	d,X01D7	;'bytes read'
	call	mssg	;type CRLF, mssg
	lhld	byco	;byte counter
	call	word	;type HL in four nibbles
	lxi	d,X01E6	;'records written'
	call	mssg	;type CRLF, mssg
	lda	reco	;record counter
	call	byte	;type A as two nibbles
	jmp	crlf	;CR,LF

;	Insert byte in .COM buffer.

comb:	push	d
	push	psw
	lhld	rbrk	;record breakpoint
	xchg
	lhld	cinx	;.COM index
	mov	a,l	;cmp(HL,DE)
	sub	e
	mov	a,h
	sbb	d
	lxi	d,X014B	;'inverted load address'
	jc	tema	;type err mess w/addr
	lxi	d,CSIZ	;nc means 'rbrk .le. index'
	lhld	rbrk	;record breakpoint
	dad	d
	xchg
	lhld	cinx	;.COM index
	mov	a,l	;cmp(HL,DE)
	sub	e
	mov	a,h
	sbb	d
	cnc	budi	;send CBUF to disk
	lxi	d,CBUF	;.COM buffer
	mvi	h,00
	dad	d
	pop	psw
	mov	m,a
	lhld	cinx	;.COM index
	inx	h
	shld	cinx	;.COM index
	pop	d
	ret

;	Send CBUF to disk.

budi:	push	h
	call	budj
	pop	h
	ret

budj:	mvi	c,26	;(1A) set DMA address
	lxi	d,CBUF
	call	BDOS

	call	budk	;record to disk

	lxi	d,CBUF+TSIZ
	mvi	c,26	;(1A) set DMA address
	call	BDOS

	call	budk	;record to disk

;	Fill CBUF with zeroes.

cbuz:	xra	a
	mvi	b,2	;CBUF holds 2 records
	lxi	h,CBUF
cbuy:	mvi	c,TSIZ
cbux:	mov	m,a
	inx	h
	dcr	c
	jnz	cbux
	dcr	b
	jnz	cbuy
	ret

budk:	lhld	rbrk	;record breakpoint
	lxi	d,TSIZ
	dad	d
	shld	rbrk	;record breakpoint
	lxi	h,reco	;record counter
	inr	m

	lxi	d,TFCB
	mvi	c,21	;(15) write one record
	call	BDOS
	cpi	00H
	lxi	d,X0161	;'disk write'
	jnz	tema	;type err mess w/addr
	ret

;	Type error statistics.

erst:	lxi	d,X016C	;'load address'
	call	mssg	;type CRLF, mssg
	lhld	ladr	;load address
	call	word	;type HL in four nibbles
	lxi	d,X017B	;'error address'
	call	mssg	;type CRLF, mssg
	lhld	cinx	;.COM index
	call	word	;type HL in four nibbles
	lxi	d,X018A	;'bytes read'
	call	mssg	;type CRLF, mssg
	call	tyla	;type load address:
ersu:	lhld	cinx	;.COM index
	xchg
	lhld	ladr	;load address
	mov	a,l
	sub	e
	mov	a,h
	sbb	d
	jnc	fini	;CR,LF,exit
	lhld	ladr	;load address
	mov	a,l
	ani	00FH
	cpi	000H
	jnz	ersv
	call	tyla	;type load address:
ersv:	lhld	rbrk	;record breakpoint
	xchg
	lhld	ladr	;load address
	mov	a,l
	sub	e
	mov	l,a
	mov	a,h
	sbb	d
	mov	h,a
	lxi	b,CBUF	;.COM buffer
	dad	b
	mov	a,m
	call	byte	;type A as two nibbles
	lhld	ladr	;load address
	inx	h
	shld	ladr	;load address
	mvi	a,' '
	call	cona	;console from A
	jmp	ersu

;	Type <load address>:.

tyla:	call	crlf	;CR,LF
	lhld	ladr	;load address
	call	word	;type HL in four nibbles
	mvi	a,':'
	call	cona	;console from A
	mvi	a,' '
	jmp	cona	;console from A

;	Make up general hexdigit.

hexn:	call	nxhx	;next hexfile element
	sui	'0'
	cpi	10	;ten
	rc
	sui	7	;seven
	cpi	10	;ten
	jc	nhex
	cpi	16	;sixteen
	rc
nhex:	lxi	d,X0196	;'invalid hex digit'
	call	mssg	;type CRLF, mssg
	jmp	erst	;type error statistics

;	Join hexinhx nibbles to form byte.

hexb:	push	b
	push	h
	push	d
	call	hexn	;general hexdigit
	add	a
	add	a
	add	a
	add	a
	push	psw
	call	hexn	;general hexdigit
	pop	b
	ora	b
	mov	b,a
	pop	d
	add	d
	mov	d,a
	mov	a,b
	pop	h
	pop	b
	ret

logo:	db	'          LOHD/ICUAP',CR,LF
	db	'Universidad Autonoma de Puebla',CR,LF
	db	'      September 22, 1983',CR,LF,'$'

tuto:	db	'LOHD.ASM is a variant of Digital Research''s LOAD.COM',CR,LF
	db	'which was reduced to 2/3 its original volume by using',CR,LF
	db	'machine language rather than PL/M. It accepts 0000H as',CR,LF
	db	'an origin lower than 0100H, facilitating the generation',CR,LF
	db	'of the master file for a self-relocating program. Gaps',CR,LF
	db	'caused by <ds> or <org> are filled with zeroes rather',CR,LF
	db	'than trash from the memory.',CR,LF
	db	CR,LF
	db	'    LOHD [X:]FILE[.QQQ]',CR,LF
	db	CR,LF
	db	'will read [X:]FILE.HEX to produce [X:]FILE.COM.',CR,LF
	db	'$'
X0129:	db	'error: $'
X0131:	db	', load address $'
X0141:	db	'Disk read$'
X014B:	db	'Load address cannot be accomodated'
X0161:	db	'Disk write$'
X016C:	db	'Load  address $'
X017B:	db	'Error address $'
X018A:	db	'Bytes read:$'
X0196:	db	'Invalid hex digit$'
X01A8:	db	'Check sum error $'
X01B9:	db	'First address $'
X01C8:	db	'Last  address $'
X01D7:	db	'Bytes read    $'
X01E6:	db	'Records written $'
X01F7:	db	'HEX',00
X01FB:	db	'Can''t open source$'
X020E:	db	'COM'
X0211:	db	'Disk or Directory full$'
X0229:	db	'Cannot close file$'

HFCB:	ds	21H	;.HEX FCB
HBUF:	ds	HSIZ+1	;hexfile buffer (400H)
hinx:	ds	2	;hexfile index
cinx:	ds	2	;.COM index
ladr:	ds	2	;load address
mina:	ds	2	;minimum address
maxa:	ds	2	;maximum address
byco:	ds	2	;byte counter
CBUF:	ds	100H	;.COM buffer
reco:	ds	1	;record counter
rbrk:	ds	2	;record breakpoint
	ds	20H
stak:	ds	2	;stackend

	end
