		.ttl	ERASE WITH SINGLE FILE QUERY


* os interface

dconio		equ	6
srch1st		equ	17
srchnxt		equ	18
erafile		equ	19
setdma		equ	26


* base page offsets

deffcb1		equ	$5c			* 1st parsed fcb


* registers

dmabfptr	equ	a4			* ^dma buffer
wkfcbptr	equ	a5			* ^work fcb
nmsbfptr	equ	a6			* ^names buffer


* ascii characters

ctrl_c		equ	$03
lf		equ	$0a
cr		equ	$0d


* misc. constants

extlen		equ	3
fnamelen	equ	8
fspeclen	equ	12
sectsize	equ	128
eobuf		equ	$ff
cnstatrq	equ	$00fe
inprequ		equ	$00ff


	.text

start:
	move.l	4(sp),a0		* ^base page
	lea	deffcb1(a0),a0		* ^default fcb 1
	lea	workfcb,wkfcbptr	* ^work fcb
	lea	dmabuf,dmabfptr		* ^dma buffer
	lea	namesbuf,nmsbfptr	* ^found names buffer

	move.l	wkfcbptr,a1		* ^work fcb
	moveq	#fspeclen-1,d0		* length count
xferlp1:
	move.b	(a0)+,(a1)+		* xfer search name
	dbf	d0,xferlp1

	move.l	dmabfptr,d1		* ^dma buffer
	moveq	#setdma,d0
	bsr	bdos			* set dma address

	move.l	wkfcbptr,d1		* ^work fcb
	moveq	#srch1st,d0
	bsr	bdos			* search for first
	tst.b	d0			* file found?
	bmi	exit			* no
	

cpytonms:
	ext.l	d0			* clear hi word
	mulu	#32,d0			* offset into dma buffer
	add.l	dmabfptr,d0		* ^found filename
	move.l	d0,a0
	addq.l	#1,a0			* skip user #
	move.b	(wkfcbptr),(nmsbfptr)+	* insert drive #
	moveq	#fspeclen-2,d2		* length count
cpynmslp:
	move.b	(a0)+,(nmsbfptr)+	* copy name to names buffer
	dbf	d2,cpynmslp

	move.l	wkfcbptr,d1
	moveq	#srchnxt,d0
	bsr	bdos			* search for next
	tst.b	d0			* file found?
	bpl	cpytonms		* yes

	move.b	#eobuf,(nmsbfptr)	* write end of buffer mark
	lea	namesbuf,nmsbfptr	* reset pointer
	move.l	nmsbfptr,a0		* duplicate
showname:
	move.b	(a0)+,d1
	cmp.b	#eobuf,d1		* end of names buffer
	beq	exit			* yes
	add.b	#'A'-1,d1		* get drive name
	bsr	dodconio		* print it
	move.b	#':',d1
	bsr	dodconio		* print ':'
	moveq	#fnamelen-1,d2		* length count
shownme1:
	move.b	(a0)+,d1
	bsr	dodconio		* print file name
	dbf	d2,shownme1		* (8 chars)
	move.b	#'.',d1
	bsr	dodconio		* print '.'
	moveq	#extlen-1,d2		* length count
shownme2:
	move.b	(a0)+,d1
	bsr	dodconio		* print file type
	dbf	d2,shownme2		* (3 chars)
	lea	yesnotxt,a1		* ^msg
	bsr	pstringz		* print it
querase:
	move.w	#cnstatrq,d1
	bsr	dodconio		* get con: status
	tst.b	d0			* con: ready?
	beq	querase			* not yet
	move.w	#inprequ,d1
	bsr	dodconio		* get con: char
	and.b	#$5f,d0			* fold to upper case
	cmp.b	#ctrl_c,d0		* abort?
	beq	exit			* yes
	cmp.b	#'Y',d0			* erase?
	bne	querase2		* no
	move.l	wkfcbptr,a1		* ^fcb
	move.l	nmsbfptr,a0		* filename
	moveq	#fspeclen-1,d2		* length count
querase1:
	move.b	(a0)+,(a1)+		* copy filespec to wkfcb
	dbf	d2,querase1
	
	move.l	wkfcbptr,d1
	moveq	#erafile,d0
	bsr	bdos			* erase file

	lea	eratxt,a1		* ^msg
	bsr	pstringz		* confirm erase
	bra	updnmptr

querase2:
	cmp.b	#'N',d0
	bne	querase			* invalid reply
	lea	crlf,a1
	bsr	pstringz		* print cr/lf

updnmptr:
	move.l	a0,nmsbfptr		* ^next name
	bra	showname		* process next file


exit:
	rts				* return to ccp


bdos:
	movem.l	d1-d7/a0-a6,-(sp)
	trap	#2
	movem.l	(sp)+,d1-d7/a0-a6
	rts


dodconio:
	moveq	#dconio,d0
	bsr	bdos			* perform direct console i/o
	rts


pstringz:
	movem.l	d1/a1,-(sp)		* print 0 terminated string
	moveq	#0,d1			* pointed to by a1
pstrz1:
	move.b	(a1)+,d1		* fetch char
	beq	expstrz			* end of string
	bsr	dodconio		* print char
	bra	pstrz1			* loop for next char
expstrz:
	movem.l	(sp)+,d1/a1
	rts




	.data

workfcb:
	dc.b	0			* drive code
	dc.b	'filename'		* file name
	dc.b	'ext'			* file type
	dc.b	0			* extent #
	dc.b	0			* s1, reserved
	dc.b	0			* s2, reserved
	dc.b	0			* rc, reserved
	ds.b	16			* d0-dn, reserved
	dc.b	0			* current sequ. record
	dc.b	0,0,0			* r0,r1,r2 (r. access)


eratxt:
	dc.b	'erased.'
crlf:
	dc.b	cr,lf,0

	
yesnotxt:
	dc.b	'  (Y/N) '
	dc.b	0
	
	.even


	.bss

dmabuf:
	ds.b	sectsize

namesbuf:
	ds.b	fspeclen*4096

	
	.end
