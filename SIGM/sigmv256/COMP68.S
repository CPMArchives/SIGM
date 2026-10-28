		.ttl	COMPARE TWO FILES


* os interface

sysreset	equ	0
conout		equ	2
pstring		equ	9
fopen		equ	15
fclose		equ	16
readsequ	equ	20
setdma		equ	26


* base page offsets

deffcb1		equ	$5c			* 1st parsed fcb
deffcb2		equ	$38			* 2nd parsed fcb


* registers

position	equ	d5
f1dmaptr	equ	a3
f2dmaptr	equ	a4
f1fcbptr	equ	a5
f2fcbptr	equ	a6


* ascii characters

lf		equ	$0a
cr		equ	$0d


* misc. constants

blank		equ	$20
eof		equ	$ff
sequrec		equ	32			* current record offset
sectsize	equ	128
bufsize		equ	128			* sectors/buffer


	.text

start:
	move.l	4(sp),a0		* ^base page
	bsr	setup
	bsr	tryopen			* exit on failure
mainloop:
	bsr	f1rd8sct		* read file1 sectors
	bsr	f2rd8sct		* read file2 sectors
	bsr	compsect		* compare sectors, exit on eof
	bra	mainloop


setup:
	lea	deffcb1(a0),a1		* ^first parsed fcb
	lea	file1fcb,f1fcbptr	* ^fcb of file1
	move.l	f1fcbptr,a2
	bsr	xferfcb
	lea	deffcb2(a0),a1		* ^2nd parsed fcb
	lea	file2fcb,f2fcbptr	* ^fcb of file2
	move.l	f2fcbptr,a2
	bsr	xferfcb
	lea	file1dma,f1dmaptr	* ^file1 dma address
	lea	file2dma,f2dmaptr	* ^file2 dma address
	moveq	#0,position		* position counter
	rts


xferfcb:
	movem.l	d0/a1-a2,-(sp)
	moveq	#12,d0			* drive code & filespec
xferloop:
	move.b	(a1)+,(a2)+
	subq.b	#1,d0
	bne	xferloop
	movem.l	(sp)+,d0/a1-a2
	rts


tryopen:
	move.l	f1fcbptr,d1
	bsr	openfile
	tst.b	d0
	bpl	trynext
	move.l	#f1nftxt,d1
	bra	exit


trynext:
	move.l	f2fcbptr,d1
	bsr	openfile
	tst.b	d0
	bpl	goodtry
	move.l	#f2nftxt,d1


exit:
	moveq	#pstring,d0
	bsr	bdos
	moveq	#sysreset,d0
	trap	#2


goodtry:
	clr.b	sequrec(f1fcbptr)	* clear current record
	clr.b	sequrec(f2fcbptr)	* field in fcbs
	rts


openfile:
	moveq	#fopen,d0
	bsr	bdos
	rts


f1rd8sct:
	movem.l	d0-d1/f1dmaptr,-(sp)
	clr.b	f1sctib			* reset sect in buf count
f1rd8lp:
	move.l	f1dmaptr,d1
	moveq	#setdma,d0
	bsr	bdos			* set dma address
	move.l	f1fcbptr,d1
	moveq	#readsequ,d0
	bsr	bdos			* read 1 logical sector
	tst.b	d0			* eof?
	bne	f1rd8ex			* yes, exit
	addq.b	#1,f1sctib		* update sector count
	cmp.b	#bufsize,f1sctib	* buffer full?
	beq	f1rd8ex			* yes, exit
	add.l	#sectsize,f1dmaptr	* update ^dma buffer
	bra	f1rd8lp			* go for next sector

f1rd8ex:
	movem.l	(sp)+,d0-d1/f1dmaptr
	rts


f2rd8sct:
	movem.l	d0-d1/f2dmaptr,-(sp)
	clr.b	f2sctib			* reset sect in buf count
f2rd8lp:
	move.l	f2dmaptr,d1
	moveq	#setdma,d0
	bsr	bdos			* set dma address
	move.l	f2fcbptr,d1
	moveq	#readsequ,d0
	bsr	bdos			* read 1 logical sector
	tst.b	d0			* eof?
	bne	f2rd8ex			* yes
	addq.b	#1,f2sctib		* update sector count
	cmp.b	#bufsize,f2sctib	* buffer full?
	beq	f2rd8ex			* yes, exit
	add.l	#sectsize,f2dmaptr	* update ^dma buffer
	bra	f2rd8lp

f2rd8ex:
	movem.l	(sp)+,d0-d1/f2dmaptr
	rts


ltoahx:
	movem.l	d0-d1/position/a0,-(sp)
	lea	postring+6,a0		* ^ascii 'hex' string
	moveq	#5,d0			* length counter
ltoahxlp:
	move.b	position,d1
	bsr	makeascii		* convert 1 nibble
	move.b	d1,-(a0)		* store it
	lsr.l	#4,position		* prep next nibble
	dbf	d0,ltoahxlp		* do all 6 nibbles
	movem.l	(sp)+,d0-d1/position/a0
	rts


btohx:
	move.b	d0,d1
	bsr	makeascii		* convert lo nibble
	exg	d0,d1
	lsr.b	#4,d1			* move hi to lo nibble
	bsr	makeascii		* convert hi nibble
	rts


makeascii:
	and.b	#$0f,d1			* mask hi nibble
	add.b	#'0',d1			* 0 becomes '0', etc.
	cmp.b	#'9',d1			* >'9'?
	ble	makeasc1		* no
	addq.b	#7,d1			* $10 becomes 'A', etc.
makeasc1:
	rts


compsect:
	movem.l	d0-d2/a3-a4,-(sp)
	move.b	f1sctib,d6		* file 1 sectors in buf
	move.b	f2sctib,d7		* file 2 sectors in buf
cmpsctlp:
	move.b	#128,d2			* sector length
cpbytelp:
	move.b	(f1dmaptr),d0
	cmp.b	(f2dmaptr),d0		* bytes equal?
	beq	cmpsctup		* yes, just updt ptrs
	cmp.b	#blank,d0		* printing char?
	bcs	npchr1			* no
	cmp.b	#$7f,d0			* > printing char?
	bcc	npchr1			* yes, do not print
	move.b	d0,f1asc		* is printing char
	bra	npchr11

npchr1:
	move.b	#blank,f1asc		* substitute blank
npchr11:
	bsr	btohx
	move.b	d1,f1hxhi		* store hi asc 'nibble'
	move.b	d0,f1hxlo		* store lo asc 'nibble'
	move.b	(f2dmaptr),d0		* file2 byte
	cmp.b	#blank,d0		* printing char?
	bcs	npchr2			* no
	cmp.b	#$7f,d0			* > printing char?
	bcc	npchr2			* yes, do not print
	move.b	d0,f2asc		* is printing char
	bra	npchr21

npchr2:
	move.b	#blank,f2asc		* substitute blank
npchr21:
	bsr	btohx
	move.b	d1,f2hxhi		* store hi asc 'nibble'
	move.b	d0,f2hxlo		* store lo asc 'nibble'
	bsr	ltoahx			* conv posn to ascii
	bsr	ppostrng		* print string incl '$'
cmpsctup:
	addq.l	#1,f1dmaptr		* ^next byte
	addq.l	#1,f2dmaptr
	addq.l	#1,position
	subq.b	#1,d2			* done complete sector?
	bne	cpbytelp		* no, loop
	subq.b	#1,d6			* sector count file 1
	beq	tsteof			* file 1 buffer done
	subq.b	#1,d7			* sector count file 2
	bne	cmpsctlp		* compare next sector
	move.l	#f2tstxt,d1		* premature end of file 2
	bra	exit

tsteof:
	subq.b	#1,d7			* file 2 sector count
	cmp.b	d6,d7			* both zero?
	bhi	f1peof			* premature eof file 1
	cmp.b	#bufsize,f1sctib	* were both buffers full?
	bne	botheof			* no, must be both eof
	movem.l	(sp)+,d0-d2/a3-a4
	rts


f1peof:
	move.l	#f1tstxt,d1
	bra	exit		* print txt & exit

botheof:
	move.l	#eoptxt,d1
	bra	exit


ppostrng:
	movem.l	d0-d1/a0,-(sp)		* print string incl '$'
	moveq	#0,d1
	lea	postxt,a0		* ^string
ppostrlp:
	move.b	(a0)+,d1
	beq	exppostr		* end of string
	moveq	#conout,d0
	bsr	bdos
	bra	ppostrlp

exppostr:
	movem.l	(sp)+,d0-d1/a0
	rts


bdos:
	movem.l	d1-d7/a0-a6,-(sp)
	trap	#2
	movem.l	(sp)+,d1-d7/a0-a6
	rts


	.data

file1fcb:
	dc.b	0			* drive code
	dc.b	'filename'		* file name
	dc.b	'one'			* file type
	dc.b	0			* extent #
	dc.b	0			* s1, reserved
	dc.b	0			* s2, reserved
	dc.b	0			* rc, reserved
	ds.b	16			* d0-dn, reserved
	dc.b	0			* current sequ. record
	dc.b	0,0,0			* r0,r1,r2 (r. access)

	.even

file2fcb:
	dc.b	0			* drive code
	dc.b	'filename'		* file name
	dc.b	'two'			* file type
	dc.b	0			* extent #
	dc.b	0			* s1, reserved
	dc.b	0			* s2, reserved
	dc.b	0			* rc, reserved
	ds.b	16			* d0-dn, reserved
	dc.b	0			* current sequ. record
	dc.b	0,0,0			* r0,r1,r2 (r. access)


f1sctib:
	dc.b	0			* file 1 buffer fill count
f2sctib:
	dc.b	0			* file 2 buffer fill count


f1nftxt:
	dc.b	'First file not found.'
	dc.b	cr,lf,'$'

f2nftxt:
	dc.b	'Second file not found.'
	dc.b	cr,lf,'$'

f1tstxt:
	dc.b	'Premature end of first file.'
	dc.b	cr,lf,'$'

f2tstxt:
	dc.b	'Premature end of second file.'
	dc.b	cr,lf,'$'

eoptxt:
	dc.b	'End of program.'
	dc.b	cr,lf,'$'

postxt:
	dc.b	'Position  '
postring:
	dc.b	'000000    '
f1text:
	dc.b	'File 1 = '
f1hxhi:
	dc.b	'0'
f1hxlo:
	dc.b	'0 '
f1asc:
	dc.b	'       '

f2text:
	dc.b	'File 2 = '
f2hxhi:
	dc.b	'0'
f2hxlo:
	dc.b	'0 '
f2asc:
	dc.b	' '
	dc.b	cr,lf,0

	.even

	.bss

file1dma:
	ds.b	sectsize*bufsize
file2dma:
	ds.b	sectsize*bufsize

	.end
