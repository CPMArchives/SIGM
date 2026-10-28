;
;	Program to dump Microsoft format
;	rel files field by field
;	with field comments
;
;	See Microsoft 'linking loader' manual
;	for more information on .rel files
;
;
;	Requires Digital Research 'MAC'
;	assembler, or alternatively, you
;	can expand the macros and use
;	the cp/m assembler 'asm'.
;
;
;	8/22/80 	by Ron Fowler
;			   Westland, Mich.
;
cr	equ	13
lf	equ	10
bdos	equ	5
fcb	equ	5ch
buf	equ	80h
;
cifnc	equ	1
prtchr	equ	2
printf	equ	9
cstsf	equ	11
openf	equ	15
readf	equ	20
;
maxperline equ	16 ;abs items per line
;
;	define some macros
;
pchar	macro	x
	if not nul x
	mvi	a,x
	endif
	call	outchr
	endm
;
print	macro	string
	local	overstring
	call	overstring
	db	string
overstring:
	pop	d
	mvi	c,printf
	call	bdos
	endm
;
bits	macro	num
	mvi	b,num
	call	getbits
	endm
	page
;
;	get local stack and
;	set up fcb
;
	ORG	100H
;
base:	lxi	h,0
	dad	sp
	shld	stack
	lxi	sp,stack
	lda	fcb+9	;look at filetype
	cpi	' '	;see if type specified
	jnz	sk1	;jmp if so
	lxi	h,'RE'	;part of 'REl'
	shld	fcb+9	;store into fcb
	mvi	a,'L'	;rest of 'reL'
	sta	fcb+11
sk1:	mvi	c,openf ;open the .rel file
	lxi	d,fcb
	call	bdos
	cpi	0ffh	;should not be
	jnz	main	;jump if not
	call	msgxit	;else say can't find
	db	'File not found.$'
	page
;
;	main work loop
;
main:	call	item	;identify one item
	jc	done	;cy is eof indicator
	call	stop	;console says stop?
	jnc	main	;continue if not
done:	call	msgxit	;else print 'done'
	db	cr,lf,'done.$'
;
stop:	mvi	c,cstsf
	call	bdos
	ora	a
	rz
	mvi	c,cifnc
	call	bdos
	cpi	'C'-40h ;control-c?
	stc		;says stop
	rz
	cmc		;false char
	ret
	page
;
;	decode an item
;
item:	bits	1	;get first bit of item
	ora	a	;test for zero
	jnz	not$abs  ;not zero, jmp for rel
	lxi	h,relflg
	mov	a,m
	mvi	m,0
	ora	a
	jz	cont1
	call	crlf
	mvi	a,maxperline+1
	sta	abscnt
cont1:	lxi	h,abscnt ;line up abs values
	mov	a,m
	inr	a
	mov	m,a
	cpi	maxperline
	jc	lnok	;max values per line
	xra	a
	mov	m,a
	call	crlf
	print	'ABS: $'
lnok:	bits	8	;get 8 absolute bits
	call	hexout	;display 'em
	pchar	' '
	ora	a	;no eof yet
	ret
;
not$abs:
	call	crlf
	call	crlf
	mvi	a,0ffh	;idntfy rel iterm
	sta	relflg
	mvi	a,maxperline+1 ;make new abs line
	sta	abscnt
	print	'REL: type $'
	bits	2	;get rel type spec
	push	psw
	call	hexout
	pop	psw
	ora	a
	jz	spl	;0 is special type
	dcr	a
	jz	prgrel ;1 is program relative
	dcr	a
	jz	datrel ;2 is data relative
;
;	must be 3, common relative
;
	print	', com rel, val=$'
	jmp	prnt16
prgrel: print	', prg rel, val=$' 
	jmp	prnt16
datrel: print	', dat rel, val=$'
prnt16: bits	8	;get rel byte
	push	psw	;save lst sig byte
	bits	8	;next
	call	hexout	;print most sig
	pop	psw
	call	hexout	;print least sig
	pchar	' '	;print a space
	ora	a	;not eof yet
	ret
	page
;
;	handle special relative field
;
spl:	print	', (special), ctrl fld=$'
	bits	4	;spl fld has..
	sta	ctrlfld ;..4 bits
	push	psw
	call	hexout	;print it
	print	', $'
	pop	psw
	mov	l,a
	mvi	h,0	;ctl fld in hl
	dad	h	;offset for table
	lxi	d,msgtable
	dad	d
	mov	e,m	;get lo byte
	inx	h
	mov	d,m	;de has field msg
	mvi	c,printf
	call	bdos	;identify type
	lda	ctrlfld ;get control byte
	cpi	15	;15 is eof
	stc		;so say so
	rz
	push	psw	;new lin for a & b flds
	call	crlf
	print	'     $';tab over
	pop	psw
	cpi	4+1	;type 0-4 has no a fld
	jc	bonly
	call	afield	;show the a field
	lda	ctrlfld 
	cpi	14	;end program...
	jnz	not14	;..forces byte boundary
	call	refill	;go next byte
	ora	a	;return cy clr
	ret
not14:	cpi	9	;type 9-15 has no b
	rnc
bonly:	call	bfield
	ora	a	;say no eof
	ret
	page
;
;	handle special rel fields
;
afield: print	'a fld type: $'
	bits	2	;get the a field
	push	psw
	call	hexout	;print it
	print	', $'	;make a comma,spc
	pop	psw	;get back a field
	ora	a	;examine it for type
	jz	absad	;0=absolute adrs
	dcr	a
	jz	prg2	;1=program rel
	dcr	a
	jz	data2	;2=data rel
;
;	must be common relative
;
	print	'(common rel) value= $'
	jmp	prnt16
data2:	print	'(data   rel) value= $'
	jmp	prnt16
prg2:	print	'(prog   rel) value= $'
	jmp	prnt16
absad:	print	'(absolute) value= $'
	jmp	prnt16
;
bfield: bits	3	;get b-field size
	mov	e,a	;make a counter
	pchar	'"'	;enclose in quotes
bsym:	mov	a,e	;when e is zero
	ora	a	;then we are done
	jz	brout
	dcr	e	;count down
	bits	8	;get sym char
	pchar		;print it
	jmp	bsym	;loop till done
brout:	pchar	'"'	;close quotes
	ret
	page
;
;*************************
;*     subroutines	 *
;*************************
;
;
;	get number of bits from
;	input stream as in b reg
;
getbits: 
	push	h
	push	d
	xra	a	;zero our byte
bitlop: call	nxtbit	;next bit into cy flg
	ral		;shift into our byte
	dcr	b	;count down
	jnz	bitlop
	pop	d
	pop	h
	ret
;
;	get next bit from input stream
;
nxtbit: push	b
	mov	b,a	;can't alter a
	lda	bitcnt	;any left this byte?
	ora	a
	cz	refill	;get another if not
	dcr	a
	sta	bitcnt	;update for nxt time
	lda	char	;current byte
	ral		;bit into cy
	sta	char
	mov	a,b	;restore accumulator
	pop	b
	ret
;
;	get the next byte from input buffer
;
refill: push	b
	lda	bufptr
	cpi	80h	;see if buf empty
	cz	diskrd	;fill if so
	mov	l,a
	mvi	h,0	;form 16 bits
	inr	a	;update buf pntr
	sta	bufptr
	lxi	d,buf
	dad	d	;point into buffer
	mov	a,m	;reach in and get byte
	sta	char	;save it
	mvi	a,8	;new bit count
	sta	bitcnt
	pop	b
	ret
;
;	read next sector from file
;
diskrd: mvi	c,readf
	lxi	d,fcb
	call	bdos
	cpi	0ffh	;should not be..
	mvi	a,0	;..early eof
	rnz
	call	msgxit	;oops!
	db	'??? Unexpected end of file.$'
;
;	print message pointed
;	to by tos then exit
;
msgxit: pop	d
	mvi	c,printf
	call	bdos
	lhld	stack
	sphl
	ret		;to ccp
crlf:	mvi	a,cr
	call	outx
	mvi	a,lf
	call	outx
	lda	lincnt
	inr	a
	sta	lincnt
	cpi	61	;lines/page
	rnz
	mvi	b,6	;lines to nxt page
formfd: mvi	a,lf
	call	outx	;<<<
	dcr	b
	jnz	formfd
	mvi	a,1	;say first line
	sta	lincnt
	ret
hexout: push	psw
	rar
	rar
	rar
	rar
	call	nybble
	pop	psw
nybble: ani	0fh
	cpi	10
	jc	xnum
	adi	7
xnum:	adi	'0'
	pchar
	ret
	page
;
;	print char in a (called from
;	macros only).
;
outchr: cpi	' '	;check for printable..
	jnc	chka	;..characters, make...
fix:	mvi	a,'.'	;...non-printing chars....
chka:	cpi	7fh	;....dots
	jnc	fix
outx:	push	h
	push	d
	push	b
	mvi	c,prtchr
	mov	e,a
	call	bdos
	pop	b
	pop	d
	pop	h
	ret
;
;	table of control-field
;	type messages
;
msgtable:
	dw	m0,m1,m2,m3
	dw	m4,m5,m6,m7
	dw	m8,m9,m10,m11
	dw	m12,m13,m14,m15
;
;	the messages:
;
m0:	db	'*      entry symbol      *$'
m1:	db	'*      sel com blk       *$'
m2:	db	'*      program name      *$'
m3:	db	'* request library search *$'
m4:	db	'*   extension link item  *$'
m5:	db	'*       common size      *$'
m6:	db	'*      chain external    *$'
m7:	db	'*    define entry point  *$'
m8:	db	'*    external - offset   *$'
m9:	db	'*    external + offset   *$'
m10:	db	'*    define data size    *$'
m11:	db	'*     set loc counter    *$'
m12:	db	'*      chain address     *$'
m13:	db	'*      program size      *$'
m14:	db	'*       end program      *$'
m15:	db	'*       end of file      *$'
	page
;
;	variables
;
bufptr: db	80h	;force initial read
bitcnt: db	0	;and empty char
char:	db	0
ctrlfld: db	0
abscnt: db	maxperline+1  ;force initial crlf
lincnt: db	1	;start paper at line 1
relflg: db	0
	db	0
	ds	50	;stack space
stack:			;stk prt save
	end
rce initial crlf
lincnt: db	1	;start paper at line 1
relflg: db	0
	db	0
	ds	50	;stack space
stack:			;stk prt save
	end