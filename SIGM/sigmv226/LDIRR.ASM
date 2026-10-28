; LDIRR.ASM v1.00
; S. Kluger 01-02-84
;
; LDIRR is a simple library directory support function
; which displays the member names and, if a member is
; squeezed, its original name.
; As far as I know, you can simply rename it to .MAC
; and assemble with M80. I prefer RMAC...
;
; NOTE: Link SORT.REL first, i.e. LINK LDIRR,SORT,SYSLIB[S] !!!
;
	cseg
;
	EXTRN	BDOS	;SYSLIB BDOS call
	EXTRN	CONDIN	;SYSLIB conditional input
	EXTRN	CIN	;SYSLIB character in
	EXTRN	COUT	;SYSLIB character out
	EXTRN	CRLF	;SYSLIB newline
	EXTRN	F$OPEN	;SYSLIB open file
	EXTRN	F$READ	;SYSLIB file read
	EXTRN	FNAME	;SYSLIB file name parser
	EXTRN	PUTUD	;SYSLIB save current user/drive
	EXTRN	GETUD	;SYSLIB restore default user/drive
	EXTRN	LOGUD	;SYSLIB log drive/user
	EXTRN	PRINT	;SYSLIB print routine
	EXTRN	RETUD	;SYSLIB return drive/user
	EXTRN	SORT	;my shell-metzner sort
;
cr	equ	0dh
lf	equ	0ah
;
dbuf	equ	80h	;default buffer
dfcb	equ	5ch	;default fcb
maxdrv	equ	'P'-40H	;highest accessible drive
maxusr	equ	15	;highest accessible user
;
begin:	lxi	h,0		;save CP/M stack pointer
	dad	sp
	shld	stack
	lxi	sp,stack	;set up local stack
	call	putud		;put away default DU
	lda	dfcb+1		;check if no file name specified
	cpi	' '
	jz	what		;give help if no argument
	call	retud		;get current drive/user
	mov	h,b
	mov	l,c
	shld	userno		;save current DU
	lxi	h,dbuf+2	;point to argument
	lxi	d,fcb		;hopefully .lbr file
	call	fname		;make fcb
	jz	what		;not a valid file name
noopt:	lxi	h,fcb+1
	mvi	a,'?'		;see if there is any...
	mvi	e,11		;...ambiguity in the file spec
ckamlp:	cmp	m
	jz	noamb		;complain if ambiguous fn
	inx	h
	dcr	e
	jnz	ckamlp
	mov	a,b		;get specified drive
	dcr	b		;get into range 0..f
	cpi	0ffh		;ff means current drive
	jnz	newdsk		;skip if different
	lda	driveno		;get current drive
	mov	b,a		;into b
newdsk:	cpi	maxdrv+1	;illegal drive specified?
	jnc	illdu		;yes - complain
	mov	a,c		;get specified user area
	cpi	'?'		;all user areas???
	jz	illdu		;yes - complain
	cpi	0ffh		;current user area?
	jnz	newusr
	lda	userno		;get current user area
	mov	c,a
newusr:	cpi	maxusr+1	;illegal user specified?
	jnc	illdu		;yes - complain
	call	logud		;log into specified DU:
	lxi	h,fcb+9
	mvi	m,'L'		;default to .LBR
	inx	h
	mvi	m,'B'
	inx	h
	mvi	m,'R'
	lxi	d,fcb
	call	f$open		;attempt to open file
	inr	a
	jz	nofile		;barf if not found
	mvi	a,2
	sta	column		;set column count to 2
	call	print
	db	cr,lf
	db	'LBR directory for ',0
	lxi	h,fcb+1
	call	fnout		;print LBR file name
	call	crlf		;...and start a new line
	lxi	d,fcb
	call	f$read		;read first sector
	lxi	h,80h
	mov	a,m
	ora	a
	jnz	baddir		;bad directory
	inx	h
	mvi	b,11		;eleven chars to check
cklp:	mov	a,m
	cpi	' '
	jnz	baddir
	dcr	b
	inx	h
	jnz	cklp
	inx	h		;now point to size
	inx	h
	mov	a,m		;no dir ever > 255 sectors!?!?!
	sta	dirsiz		;save dir size
	add	a
	add	a
	dcr	a		;dirsec*4-1 total entries
	sta	entries
	mov	b,a
	lxi	h,dirbuf
	shld	dbufp
rlp:	call	move
	lxi	d,fcb
	call	f$read
	dcr	b
	jnz	rlp
;
; directory is now fully in ram. print ruler.
;
	call	print
	db	cr,lf
	db	'FILE NAME      ORIGINAL NAME'
	db	'       FILE NAME      ORIGINAL NAME',cr,lf,lf,0 
	lxi	h,dirbuf+20h	;skip directory itself
	shld	dbufp
	lda	entries		;get # of records
	mov	c,a
	mvi	b,0		;into BC
	lxi	d,20h		;record length into DE
	push	h		;save dir buffer
	call	sort		;sort the stuff
	pop	h		;get pointer back
dloop:	mov	a,m
	inx	h
	cpi	0		;entry deleted?
	jnz	skent		;yes, skip
	call	fnout		;print the file name
	mvi	a,' '		;single space breather
	call	cout
	dcx	h
	dcx	h		;get middle type byte
	mov	a,m
	cpi	'Q'
	cz	sqd		;see if squeezed
	call	print		;here only if not squeezed
	db	'              ',0	;blank the "original fn"
bdoor:	lda	column
	dcr	a
	sta	column		;allow 2 double-width columns
	jnz	nolf
	mvi	a,2
	sta	column
	call	crlf
	jmp	skent
;
nolf:	call	print
	db	'   ||   ',0	;print delimiter
skent:	lhld	dbufp		;skip to next dir entry
	lxi	d,20h
	dad	d
	shld	dbufp
	lda	entries
	dcr	a
	sta	entries
	jnz	dloop
	jmp	quit		;quit if all printed
;
; entry appears to be squeezed - lets see...
;
sqd:	inx	h
	inx	h		;let's get offset
	mov	e,m
	inx	h
	mov	d,m
	xchg			;random field in hl
	shld	fcb+33		;make random record
	mvi	c,33		;random read
	lxi	d,fcb
	call	bdos
	lxi	h,80h
	mov	a,m
	cpi	76h
	rnz			;return if not SQ file
	inx	h
	mov	a,m
	cpi	0ffh
	rnz
	pop	d		;clean up stack
	inx	h
	inx	h
	inx	h		;pointing to real fn now
	call	print
	db	'= ',0
	mvi	b,8		;8 characters is a filename long...
pfl:	mov	a,m
	cpi	'.'
	jz	eofnm		;end of file name
	call	cout
	inx	h
	dcr	b
	jnz	pfl
eofnm:	inr	b		;fill file name with spaces up to "."
spcl:	mvi	a,' '
	dcr	b
	jz	ft
	call	cout
	jmp	spcl
;
; finally, print the file type
;
ft:	mov	a,m
	inx	h
	cpi	0		;if all done
	jz	bdoor		;then jump in the back door
	call	cout
	jmp	ft
;
; buffer move routine. moves default buffer into dir buffer.
;
move:	lhld	dbufp
	lxi	d,80h
movlp:	ldax	d
	mov	m,a
	inx	h
	inr	e
	jnz	movlp
	shld	dbufp
	ret
;
; Print the file name
;
fnout:	mvi	b,11		;11 characters to print
fnol:	mov	a,m		;get character
	call	cout		;print character
	call	condin		;check ^C/^S
	jz	noch		;no char available
	cpi	'C'-40h		;^C?
	jz	quit		;yes, time to get out
	cpi	'S'-40h		;^S?
	jnz	noch		;no, skip
	call	cin		;wait for char typed
noch:	inx	h		;point to next
	dcr	b		;one character less to go
	rz			;finished?
	mov	a,b		;get character count
	cpi	3		;if only 3 left...
	jnz	fnol
	mvi	a,'.'		;then print a period
	call	cout
	jmp	fnol
;
; Here are the messages
;
baddir:	call	print
	db	'Bad directory - not LBR format',cr,lf,0
	jmp	what
;
illdu:	call	print
	db	cr,lf
	db	'Drive/user out of bounds',cr,lf,0
	jmp	what
;
nofile:	call	print
	db	cr,lf
	db	'No such file on disk',cr,lf,0
	jmp	what
;
noamb:	call	print
	db	cr,lf
	db	'No ambiguous file names allowed',0
what:	call	print
	db	cr,lf
	db	'USAGE: LDIRR [du:]ufn[.LBR]',cr,lf
	db	'Where: du: = drive and user, ufn = LBR file name'
	db	cr,lf
	db	'Examples:',cr,lf
	db	'A0>LDIRR C3:TEST',cr,lf
	db	'B2>LDIRR 0:TEST1',cr,lf
	db	'B0>LDIRR TEST1',cr,lf
	db	cr,lf,lf,0
quit:	call	getud		;restore default DU
	lhld	stack
	sphl
	ret
;
; Better stay out of hot water -- place the data area
; at the end of the program...
;
	dseg
;
dbufp:	dw	0	;dir buffer pointer
dirsiz:	db	0	;# of total dir sectors
entries:db	0	;total # of entries in dir
column:	db	0	;column count
userno:	db	0	;current user #
driveno:db	0	;current drive
fcb:	ds	36	;out fcb
	ds	50	;25 level stack
stack:	dw	0	;save CP/M stack pointer here
dirbuf	equ	$	;directory buffer starts here
	end
,0
	jmp	what
;
illdu:	call	print
	db	cr,lf
	db	'Drive/user out of bounds',cr,lf,0
	jmp	what
;
nofile