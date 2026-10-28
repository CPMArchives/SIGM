
;	------------------------------------------------------------
;	.REL files are encoded as a bitstream according to certain
;	rules which are spelled out in Microsoft's FORTRAN manual.
;	As a consequence a normal disk dump program will not be very
;	intelligible, even to people who have learned to recognize
;	8080 opcodes in hexadecimal form, or to spot ASCII constants
;	in a program. The purpose of READREL.COM is to generate a
;	hexadecimal dump of a .REL file, interspersed with special
;	directives as they are produced by M80.COM, F80.COM or other
;	relocating assemblers using the same format.
;
;		     READREL - Copyright (C) 1983
;		    Universidad Autonoma de Puebla
;		          November 20, 1983
;
;	[Harold V. McIntosh, 20 November 1983]
;	------------------------------------------------------------


bdos	equ	0005H
tfcb	equ	005CH
tsiz	equ	0080H		;CP/M's record size
dsiz	equ	0100H		;size of .OUT buffer (must be 100H)
rsiz	equ	0400H		;size of relfile buffer
lsiz:	equ	16		;line length (maximum spaces per line)

LF	equ	0AH
CR	equ	0DH

;	-------------
	org	0100H
;	-------------

begn:	lxi	h,0000
	shld	bctr		;byte counter
	dad	sp
	shld	stak		;save sp
	lxi	sp,stak		;stackend
	lxi	h,dsiz		;size of OUT buffer
	shld	dctr		;output downcounter
	lxi	h,dbuf		;output buffer
	shld	dptr		;output pointer
	lxi	h,rsiz		;size of relfile buffer
	shld	rinx		;relfile index
	mvi	a,lsiz		;max spaces/line
	sta	lctr		;count 16 bytes/line
	xra	a
	sta	colm		;FF=column 1
	lda	tfcb+1
	cpi	' '
	jnz	nnul
	lxi	d,logo		;'UAP...'
	call	mssg		;type text at (DE)
	lxi	d,tuto		;instructions for usage
	call	mssg		;type text at (DE)
	jmp	gbye		;normal exit

nnul:	mvi	c,021H		;count
	lxi	d,tfcb		;source
	lxi	h,rfcb		;.REL FCB = destination
	call	miuc		;block move

	lxi	h,rfcb+9	;.REL ext = destination
	mvi	m,'R'
	inx	h
	mvi	m,'E'
	inx	h
	mvi	m,'L'
	inx	h
	mvi	m,00H

	mvi	c,15		;(0F) open file
	lxi	d,rfcb		;.REL FCB
	call	bdos
	cpi	0FFH
	lxi	d,coso		;'can''t open .REL file'
	jz	tema		;type text at (DE), quit

	xra	a
	sta	dout		;z=no disk output
	lda	tfcb+17		;output filename
	cpi	' '
	jz	nout
	sta	dout		;z=no disk output

	mvi	c,16
	lxi	d,tfcb+16
	lxi	h,tfcb		;CP/M's file control block (.OUT)
	call	miuc

	lxi	h,tfcb+9	;output extension
	mov	a,m
	cpi	' '
	jnz	yext
	mvi	m,'O'
	inx	h
	mvi	m,'U'
	inx	h
	mvi	m,'T'

yext:	mvi	c,3
	lxi	h,tfcb+9
	lxi	d,rfcb+9
yexx:	ldax	d
	cmp	m
	jnz	neql
	inx	h
	inx	d
	dcr	c
	jnz	yexx
	lxi	d,meql		;'extensions equal'
	jmp	tema		;type text at (DE), quit

neql:	mvi	c,19		;(13) delete file
	lxi	d,tfcb		;CP/M's file control block (.OUT)
	call	bdos

	mvi	c,22		;(16) create file
	lxi	d,tfcb		;CP/M's file control block (.OUT)
	call	bdos

	mvi	c,15		;(0F) open file
	lxi	d,tfcb		;CP/M's file control block (.OUT)
	call	bdos
	cpi	0FFH
	lxi	d,ddfu		;'no more directory'
	jz	tema		;type text at (DE), quit

nout:	lxi	h,0FF00H
	shld	roby		;rotating byte, bit counter
	lxi	d,0000
	call	refi		;process the .REL file
	lda	dout		;z=no disk output
	ora	a
	jz	fini

;	Fill the remainder of the output file with ^Z's, write
;	the tag end to disk, and close the file.

	lhld	dctr		;output downcounter
	xchg
	lhld	dptr		;output pointer
cloo:	mov	a,e
	ora	d
	jz	clop
	mvi	m,1AH
	dcx	d
	jmp	cloo

clop:	lxi	d,dbuf
	ldax	d
	cpi	1AH		;^Z
	jz	clos
	mvi	c,26		;(1A) set DMA address
	call	bdos

	call	budk		;record to disk

	lxi	d,dbuf+tsiz		;CP/M's record size
	ldax	d
	cpi	1AH		;^Z
	jz	clos
	mvi	c,26		;(1A) set DMA address
	call	bdos

	call	budk		;record to disk

clos:	mvi	c,16		;(10) close file
	lxi	d,tfcb		;CP/M's file control block (.OUT)
	call	bdos
	cpi	0FFH
	lxi	d,nclo		;'can''t close file'
	jz	edsk		;delete .OUT file, type messages

fini:	call	crlf		;CR,LF
gbye:	lhld	stak		;save sp
	sphl
	ret

;	Type CR, LF.

crlf:	mvi	a,CR
	call	cona		;console from A
	mvi	a,LF
	call	cona		;console from A
	mvi	a,lsiz		;max spaces/line
	sta	lctr		;count 16 bytes/line
	mvi	a,0FFH
	sta	colm		;FF=column 1
	mvi	c,11		;(0B) console status
	call	bdos
	ora	a
	rz
	mvi	c,1		;(01) read console
	call	bdos
	lxi	d,irrp		;'analysis interrupted'
	call	mssg
	lda	dout		;z=no disk output
	ora	a
	jz	gbye
	jmp	edsq		;delete .OUT file, type messages

;	word: type HL as four nibbles.
;	byte: type A as two nibbles.

word:	mov	a,d
	call	byte		;type A as two nibbles
	mov	a,e
byte:	call	tadr		;type address if column 1
beit:	push	psw
	rar
	rar
	rar
	rar
	call	nibl		;type A as hex
	pop	psw
nibl:	ani	0FH
	adi	90H
	daa
	aci	40H
	daa
cona:	push	h
	push	d
	push	psw
	mvi	c,2		;(02) write console
	mov	e,a
	call	bdos
	pop	b
	lda	dout		;z=no disk output
	ora	a
	jz	conb
	mov	a,b
	call	ddda
conb:	pop	d
	pop	h
	ret

;	Type several spaces.

dubl:	call	sngl		;type one space
sngl:	push	h
	lxi	h,lctr		;count 16 bytes/line
	dcr	m
	cz	crlf
	pop	h
	mvi	a,' '
	jmp	cona

;	Type relative address if at start of a new line.

tadr:	push	h
	lxi	h,colm		;FF=column 1
	inr	m
	jnz	tret
	push	psw
	mvi	a,'('
	call	cona
	lhld	bctr
	mov	a,h
	call	beit
	mov	a,l
	call	beit
	mvi	a,')'
	call	cona
	call	sngl
	pop	psw
tret:	pop	h
	ret

;	Type message at (DE).

mssg:	xchg
mssh:	mov	a,m
	cpi	'$'
	rz
	call	cona
	inx	h
	jmp	mssh

;	Type message, erase .OUT file, quit.

edsk:	call	mssg
edsq:	mvi	c,19		;(13) delete file
	lxi	d,tfcb		;CP.M's file control block (.OUT)
	call	bdos		;don't leave a partial file
	lxi	d,erad		;'output file erased'
tema:	call	mssg
	jmp	gbye

;	Block move.

miuc:	ldax	d
	mov	m,a
	inx	h
	inx	d
	dcr	c
	jnz	miuc		;block move
	ret

;	Place disk output in buffer, store the buffer in the
;	disk as it is filled and reinitialize it.

ddda:	push	psw
	lhld	dctr		;output downcounter
	mov	a,l
	ora	h
	cz	budi
dddb:	dcx	h
	shld	dctr		;output downcounter
	lhld	dptr		;output pointer
	pop	psw
	mov	m,a
	inx	h
	shld	dptr		;output pointer
	ret

;	Send dbuf to disk. Must return with dsiz in HL.

budi:	call	budj
	lxi	h,dbuf		;output buffer
	shld	dptr		;output pointer
	lxi	h,dsiz
	ret

budj:	mvi	c,26		;(1A) set DMA address
	lxi	d,dbuf		;output buffer
	call	bdos

	call	budk		;record to disk

	mvi	c,26		;(1A) set DMA address
	lxi	d,dbuf+tsiz	;CP/M's record size
	call	bdos

budk:	mvi	c,21		;(15) write one record
	lxi	d,tfcb		;CP/M's file control block (.OUT)
	call	bdos
	cpi	00H
	lxi	d,diwr		;'disk write error'
	jnz	edsk		;delete .OUT file, type messages
	ret

;	Get next bit.

gebi:	push	h
	lxi	h,roby		;rotating byte, bit counter
	mov	a,m
	inx	h
	inr	m
	jnz	gebj
	call	nxhx
	mvi	m,0F8H
gebj:	add	a
	dcx	h
	mov	m,a
	pop	h
	ret

;	Read a full byte from the .REL file.

geby:	mvi	c,08
bits:	mvi	b,00
more:	call	gebi		;get next bit
	mov	a,b
	ral
	mov	b,a
	dcr	c
	jnz	more
	ret

;	Get next relfile element.

nxhx:	push	b
	push	h
	lhld	rinx		;relfile index
	inx	h
	lxi	d,rsiz		;size of relfile buffer
	mov	a,l
	sub	e
	mov	a,h
	sbb	d
	jc	nxhv		;byte available
	lxi	h,0000
nxhy:	shld	rinx		;relfile index
	lxi	d,rsiz		;size of relfile buffer
	mov	a,l
	sub	e
	mov	a,h
	sbb	d
	jnc	nxhu		;reset relfile, read 1st element
	lxi	d,rbuf		;relfile buffer
	dad	d
	xchg
	mvi	c,26		;(1A) set DMA address
	call	bdos
	lxi	d,rfcb		;.REL FCB
	mvi	c,20		;(14) read one record
	call	bdos
	cpi	000H
	jz	nxhz		;add record to relfile
	cpi	001H
	lxi	d,dird		;'disk read error'
	jnz	tema		;type text at (DE), quit
	lxi	h,rsiz-1
	shld	rinx		;relfile index
nxhz:	lhld	rinx		;relfile index
	lxi	d,tsiz		;CP/M's record size
	dad	d
	jmp	nxhy		;no more refills

nxhu:	lxi	h,0000
nxhv:	shld	rinx		;relfile index
	lxi	d,rbuf		;relfile buffer
	dad	d
	mov	a,m
	pop	h
	pop	b
	ret

;	-------------------
;	Read the .REL file.
;	-------------------


;	The first bit read determines whether a single byte
;	follows (bit = 0), to be used without alteration, or
;	whether the following information may be relocatable
;	(bit = 1).

refi:	call	gebi		;get next bit
	jc	rela		;not absolute byte
	call	geby		;full byte from .REL
	call	byte		;type A as two nibbles
	call	sngl		;type one space
	lhld	bctr		;byte counter
	inx	h
	shld	bctr		;byte counter
	jmp	refi		;.REL read loop

;	When the leadin bit is 1, two more bits are read to
;	distinguish four alternatives: 00 for further analysis,
;	01 for program segment, 10 for data segment, or 11 for
;	common segment. In the latter three cases, a two-byte
;	address will be read, which a loader would assign to its
;	proper memory segment.

rela:	mvi	c,2
	call	bits		;get C bits from .REL
	ora	a
	jz	spec		;'special LINK element'
	call	tadr		;type address if column 1
	call	gtyq		;fetch segment descriptor
	call	mssg		;type text at (DE)
	call	geby		;full byte from .REL
	push	psw
	call	geby		;full byte from .REL
	pop	d
	mov	e,d
	mov	d,a
	call	word		;type HL as four nibbles
	call	crlf		;CR, LF
	lhld	bctr		;byte counter
	inx	h
	inx	h
	shld	bctr		;byte counter
	jmp	refi		;.REL read loop

;	There are sixteen 'special LINK elements' ranging from
;	entry point definitions to the EOF indicator. They fall
;	into three or four general groups, depending on whether
;	they are associated with an eight-byte ASCII label, a
;	relocatable address, both, or neither. Since they represent
;	parenthetic information, they are set off on a line by
;	themselves.

spec:	lda	lctr		;count 16 bytes/line
	cpi	lsiz		;max spaces/line
	cnz	crlf		;CR,LF
	xra	a
	sta	colm		;FF=column 1
	mvi	c,4
	call	bits		;get C bits from .REL
	add	a		;case number indexes two tables
	mov	c,a
	mvi	b,0
	lxi	h,meta		;case table for messages
	dad	b
	mov	e,m
	inx	h
	mov	d,m
	lxi	h,juta		;case table for interpretations
	dad	b
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	push	h		;action address after typing mssg
	jmp	mssg		;type text at (DE)

;	Message table, to correspond to the 'special' relocation
;	elements, of which there are sixteen. These are the
;	descriptive messages inserted into the output stream.

meta:	dw	me0		;'entry symbol'
	dw	me1		;'COMMON block'
	dw	me2		;'program name'
	dw	me3		;'request library search'
	dw	me4		; reserved
	dw	me5		;'COMMON size'
	dw	me6		;'chain external'
	dw	me7		;'define entry'
	dw	me8		; reserved
	dw	me9		;'external add offset'
	dw	mea		;'size of DATA area'
	dw	meb		;'loading location counter'
	dw	mec		;'chain address'
	dw	med		;'define program size'
	dw	mee		;'end of program'
	dw	mef		;'end of file'

;	There may be a label or a further address associated
;	with each 'special LINK item.' These subroutines take
;	the appropriate action in each case.

juta:	dw	text		;ASCII label
	dw	text		;ASCII label
	dw	text		;ASCII label
	dw	text		;ASCII label
	dw	text		;ASCII label
	dw	styp		;storage type
	dw	styp		;storage type
	dw	styp		;storage type
	dw	styp		;storage type
	dw	phue		;storage type w/ address
	dw	phue		;storage type w/ address
	dw	phue		;storage type w/ address
	dw	phue		;storage type w/ address
	dw	phue		;storage type w/ address
	dw	phoo		;program end - flush byte
	dw	eofi		;EOF

;	The 'special LINK item' includes an 8-byte label
;	or similar ASCII string. 8 bytes is maximum, there
;	must be at least 1, 8 is taken for 0.

text:	mvi	c,3
	call	bits		;get C bits from .REL
	ora	a		;take 0 to mean 8
	jnz	x2x
	mvi	a,8
x2x:	push	psw
	call	geby		;full byte from .REL
	call	cona
	pop	psw
	dcr	a
	jnz	x2x
	call	crlf		;CR,LF
	jmp	refi		;.REL read loop

;	The 'special LINK item' requires identification via
;	the following two bits, as to whether it is absolute
;	(00), code (01), data (10), or common (11).

styp:	call	gtyp		;ascertain storage type
	call	mssg		;type text at (DE)
	call	twrd		;read & type word from .REL
	call	dubl		;type one space
	jmp	text		;ASCII label

;	Read two bits to ascertain storage type, then load
;	address of appropriate descriptor for console typing.

gtyp:	mvi	c,2
	call	bits		;get C bits from .REL
gtyq:	lxi	d,mabs		;'ABS:'
	ora	a
	rz
	lxi	d,mprg		;'PREL'
	dcr	a
	rz
	lxi	d,mdat		;'DREL'
	dcr	a
	rz
	lxi	d,mcom		;'CREL'
	ret

;	This class of 'special LINK items' require a two-bit
;	storage classigication followed by a two-byte address.

phue:	call	gtyp		;ascertain storage type
	call	mssg		;type text at (DE)
	call	twrd		;read & type word from .REL
	call	crlf		;CR,LF
	jmp	refi		;.REL read loop

;	At the program end, the bit stream should be squared
;	off at a byte boundary. A start address may be present.

phoo:	call	gtyp		;ascertain storage type
	call	mssg		;type text at (DE)
	call	twrd		;read & type word from .REL
	call	crlf		;CR,LF
	lxi	h,0FF00H
	shld	roby		;rotating byte, bit counter
	jmp	refi		;.REL read loop

;	End of File.

eofi:	ret

;	Read a word from .REL and type it.

twrd:	call	geby		;full byte from .REL
	push	psw
	call	geby		;full byte from .REL
	pop	d
	mov	e,d
	mov	d,a
	jmp	word		;type HL as four nibbles

;	-------------------------------------------------------


logo:	db	CR,LF
	db	'        READREL/ICUAP',CR,LF
	db	'Universidad Autonoma de Puebla',CR,LF
	db	'      November 20, 1983',CR,LF,'$'

tuto:	db	CR,LF
	db	'READREL.COM will decompose the bitstream which',CR,LF
	db	'constitutes a .REL file into hexadecimal bytes',CR,LF
	db	'and addresses interspersed with commentaries',CR,LF
	db	'derived from the ''special LINK elements'' and',CR,LF
	db	'other clarifying information. The command:',CR,LF,CR,LF
	db	'    READREL [D:]FILE[.REL] [[D:]LIST[.EXT]]',CR,LF,CR,LF
	db	'will analyze the requested file. If no extension',CR,LF
	db	'is given, .REL will be used. The analysis will',CR,LF
	db	'always appear at the console; but if a second file',CR,LF
	db	'is mentioned, it will also be used for output. Its',CR,LF
	db	'default extension will be .OUT',CR,LF
	db	'$'

me0:	db	'entry symbol  $'
me1:	db	'COMMON block  $'
me2:	db	'program name  $'
me3:	db	'req lib srch  $'
me4:	db	'reserved      $'
me5:	db	'COM  size $'
me6:	db	'chain ext $'
me7:	db	'def entry $'
me8:	db	'reserved  $'
me9:	db	'extnl + offset $'
mea:	db	'size DATA area $'
meb:	db	'ldng locn cntr $'
mec:	db	'chain address  $'
med:	db	'def prgrm size $'
mee:	db	'end of program $'
mef:	db	'EOF$'
mabs:	db	'ABS: $'
mprg:	db	'PREL $'
mdat:	db	'DREL $'
mcom:	db	'CREL $'
dird:	db	'Disk read error.$'
diwr:	db	'Disk write error.$'
coso:	db	'Can''t open .REL file.$'
ddfu:	db	'Disk or Directory full.$'
nclo:	db	'Cannot close file.$'
meql:	db	'Duplicate extensions.$'
irrp:	db	'-- Analysis interrupted --',CR,LF,'$'
erad:	db	'- Output file suppressed -$'

rfcb:	ds	21H		;.REL FCB
rbuf:	ds	rsiz+1		;relfile buffer (400H)
rinx:	ds	2		;relfile index
dout:	ds	1		;z=no disk output
dctr:	ds	2		;output downcounter
dptr:	ds	2		;output pointer
lctr:	ds	1		;count 16 bytes/line
colm:	ds	1		;FF=column 1
bctr:	ds	2		;byte counter
dbuf:	ds	100H		;.OUT buffer
reco:	ds	1		;record counter
rbrk:	ds	2		;record breakpoint
roby:	ds	2		;rotating byte, bit counter
	ds	20H
stak:	ds	2		;stackend

	end
