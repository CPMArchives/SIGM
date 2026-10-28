

;	----------------------------------------------------------
;	Reassembly of FIND.COM, which was originally extracted
;	from the CBBS(R) package available from Ward Christensen
;	and Randy Suess. However, considerable rearrangement has
;	taken place, most notably the following:
;	    <no file name> results in a screen of information
;	    the search pattern may be a regular expression
;	    label+line number as an alternative to line number
;	    instance count reported, both per file and globally
;	To achieve compatibility with MicroShell the vertical bar
;	was replaced by exclamation point; all syntactic elements
;	are defined by EQU's and may be redefined. LABEL!PATTERN
;	is checked for balanced parentheses and non-null arguments
;	to forestall the most common failure modes. Had MicroShell
;	not been available, an option to direct the output to some
;	disk file would probably have been included.
;
;		    FYNDE.ASM   Copyright (C) 1982
;		    Universidad Autonoma de Puebla
;
;	[Harold V. McIntosh, 20 December 1982]
;	----------------------------------------------------------

HT	equ	09H	;horizontal tab
LF	equ	0AH	;line feed
CR	equ	0DH	;carriage return
KZ	equ	1AH	;^Z

;	Delimiters for the command line

LSQ	equ	'['	;begin alternative list
RSQ	equ	']'	;end alternative list
LBR	equ	'{'	;begin iterated expression
RBR	equ	'}'	;end iterated expression
ORR	equ	'!'	;separate alternatives

;	Representatives of characters or classes.

TAB	equ	'_'	;substitute for tab
QUE	equ	'?'	;represent any byte
ALF	equ	'@'	;represent any alphanumeric

;	CPM locations and parameters

cfcb	equ	005CH	;CP/M's file control block
cblk	equ	007CH	;CP/M's block counter
csiz	equ	0080H	;CP/M's record size
cbuf	equ	0080H	;CP/M's record buffer
ksiz	equ	26	;sector capacity of IN buffer
isiz	equ	ksiz*128

	org	100H

X0100:	lxi	sp,stak
	lda	cfcb+1	;file name
	cpi	' '
	jnz	X0143
	lxi	h,M1
	call	mssg
	jmp	0000

X0143:	lxi	h,M2
	call	mssg
	mvi	c,12
	lxi	d,cfcb
	lxi	h,file
	call	miuc
	xra	a
	sta	enth
	lxi	h,cbuf	;CP/M's record buffer
	mov	e,m
	mov	c,e
	mov	d,a
	xchg
	inx	d
	dad	d
	mov	m,a
	xchg
X0152:	inx	h
	dcr	c
	mov	a,m
	ora	a
	jz	X029C
	cpi	' '
	jnz	X0152
	inx	h
	call	bala	;check balance of [], {}.
	call	nula	;check for null alternatives
	lxi	d,patt	;command line pattern
	call	muve
	mvi	c,4
	lxi	d,lzer
	lxi	h,dtot
	call	miuc
	lxi	h,0000
	shld	lapo
	lxi	h,patt	;command line pattern
	shld	papo
	call	next
	ora	a
	jz	scan
	shld	papo
	lxi	h,patt
	shld	lapo

;	Scan the directory for file names.

scan:	mvi	c,26	;(1A) set DMA address
	lxi	d,cbuf	;CP/M's record buffer
	call	0005	; - B D O S -
	mvi	c,17	;(11) search once
	lxi	d,file
	call	0005	; - B D O S -
	lxi	h,enth
	inr	m
	mov	c,m
fnth:	inr	a
	jz	done	;we're all done
	dcr	c
	jz	this
	push	b
	mvi	c,18	;(12) search again
	lxi	d,file
	call	0005	; - B D O S -
	pop	b
	jmp	fnth

;	We're all done.

done:	lxi	h,dtot
	call	mssg
	jmp	0000

;	A prospective file has been located

this:	dcr	a
	ani	03
	add	a
	add	a
	add	a
	add	a
	add	a
	adi	81H
	mov	e,a
	mvi	d,00
	mvi	c,12
	lxi	h,cfcb+1
	call	miuc
	mvi	c,15	;(0F) open file
	lxi	d,cfcb	;CP/M's FCB
	call	0005	; - B I O S -
	inr	a
	jz	0000	;quit [without message]
	xra	a
	sta	cblk	;block pointer

	mvi	c,4
	lxi	d,lzer
	lxi	h,lnum	;'line number'
	call	miuc
	mvi	c,4
	lxi	d,lzer
	lxi	h,ftot	;'file total'
	call	miuc
	mvi	c,8
	lxi	d,cfcb+1	;file name
	lxi	h,fnam	;'file name'
	call	miuc
	mvi	c,3
	lxi	d,0065H	;extension
	lxi	h,fext	;'file extension'
	call	miuc
	lxi	h,fhed
	call	mssg	;message to console
	lxi	b,2006H	;six spaces
	lxi	h,llbl
	call	fiuc

X01C2:	lxi	h,0000
	shld	ictr
X01C8:	lxi	h,lnum+3	;increment l.c.
	call	inco	;increment line counter
	lxi	h,lbuf	;line buffer
	mvi	b,0FFH
X01E0:	inr	b
	jm	X01FD
	push	b
	push	h
	call	inch	;char from big bffr to line bffr
	pop	h
	pop	b
	mov	m,a
	inx	h
	cpi	KZ
	jnz	X01E8
	lxi	h,ftot
	call	mssg
	jmp	scan
X01E8:	cpi	LF
	jnz	X01E0
	jmp	X0202

X01FD:	mvi	m,CR
	inx	h
	mvi	m,LF
	inx	h

;	Check console for termination request. If one
;	is present, clear it out before leaving.


X0202:	mvi	m,00	;guarantee right hand fence
	mvi	c,11	;(0B) console status
	call	0005	; - B I O S -
	ora	a
	jz	culi
	mvi	c,1	;(01) read console
	call	0005	; - B D O S -
	lxi	h,M4	;"search terminated"
	call	mssg
	jmp	0000

;	Scan the current line.
;	First see if it is labelled.

culi:	lhld	lapo
	mov	a,h
	ora	l
	jz	X0217	;no label requested
	xchg
	lxi	h,lbuf
	call	chek
	jnz	X0217	;label not found
	push	h
	lxi	b,2006H	;six spaces
	lxi	h,llbl
	call	fiuc
	pop	h
	lxi	d,llbl+5
	mvi	c,6
didl:	dcx	h
	mov	a,m
	cpi	HT	;ignore tabs in text
	jz	didl
	cpi	' '	;quit at head of line
	jc	dido
	stax	d
	dcx	d
	dcr	c
	jnz	didl
dido:	mvi	c,4
	lxi	d,lzer
	lxi	h,lnum
	call	miuc

;	Now look for the pattern

X0217:	lxi	h,lbuf	;line buffer
X021A:	xchg
	lhld	papo	;pattern pointer
	xchg
	push	h
	call	chek
	pop	h
	jz	X0263
	inx	h
	mov	a,m
	cpi	CR
	jnz	X021A
	jmp	X01C8	;increment l.c. at X026A

;	Pattern matches, so type label & line containing it

X0263:	lxi	h,llbl	;line label
	call	mssg	;message to console
	lxi	h,lbuf	;line buffer
	call	mssg	;message to console
	lxi	h,ftot+3
	call	inco
	lxi	h,dtot+3
	call	inco
	jmp	X01C8	;increment l.c. at X026A

;	Increment ASCII counter at (HL-3).

inco:	mov	a,m
	ori	30H
	inr	a
	mov	m,a
	cpi	':'
	rnz
	mvi	m,'0'
	dcx	h
	jmp	inco

;	Memory to console

mssg:	mov	e,m
	inx	h
	push	h
	mvi	c,2	;(02) write console
	call	0005	; - B I O S -
	pop	h
	mov	a,m
	ora	a
	jnz	mssg
	ret

X029C:	lxi	h,M3	;"bad pattern"
	call	mssg
	jmp	0000

inch:	lhld	ictr
	mov	a,h
	ora	l
	cz	indi	;disk to IN area
	lhld	ictr
	dcx	h
	shld	ictr
	lhld	iptr
	mov	a,m
	cpi	KZ
	rz
	inx	h
	shld	iptr
	ret

indi:	mvi	b,ksiz
	lxi	h,isiz
	shld	ictr
	lxi	h,ibuf
	shld	iptr
indd:	mvi	m,KZ
	push	h
	push	b
	xchg
	mvi	c,26	;(1A) set DMA address
	call	0005	; - B D O S -
	lxi	d,cfcb	;CP/M's file control block
	mvi	c,20	;(14) read one record
	call	0005	; - B D O S -
	pop	b
	pop	h
	ora	a
	rnz
	dcr	b
	rz
	lxi	d,csiz	;CP/M's record size
	dad	d
	jmp	indd

;	Advance to next alternative

nexx:	mov	e,m
	inx	h
	mov	d,m
	xchg
next:	mov	a,m
	ora	a
	rz
	inx	h
	call	enda
	rz
	call	begb
	jz	nexx
	jmp	next

fiuc:	mov	m,b
	inx	h
	dcr	c
	jnz	fiuc
	ret

miuc:	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	miuc
	ret

;	Move and semi-compile the command line.

muve:	mov	a,m
	cpi	TAB
	jnz	munt
	mvi	a,HT
munt:	stax	d
	inx	h
	inx	d
	cpi	RBR
	jz	murb
	cpi	RSQ
	jz	murb
	cpi	LBR
	jz	mulb
	cpi	LSQ
	jz	mulb
must:	dcr	c
	jnz	muve
	ret

murb:	xthl
	mov	m,e
	inx	h
	mov	m,d
	pop	h
	jmp	must

mulb:	push	d
	inx	d
	inx	d
	jmp	must

;	Check balance of []'s and {}'s.

bala:	push	h
	push	b
	lxi	b,0101H
balb:	mov	a,m
	inx	h
	cpi	LSQ
	jnz	balc
	inr	b
	jmp	balb
balc:	cpi	RSQ
	jnz	bald
	dcr	b
	jz	balx
	jmp	balb
bald:	cpi	LBR
	jnz	bale
	inr	c
	jmp	balb
bale:	cpi	RBR
	jnz	balf
	dcr	c
	jz	balx
	jmp	balb
balf:	ora	a
	jnz	balb
	mov	a,c
	cpi	01
	jnz	balx
	mov	a,b
	cpi	01
	pop	b
	pop	h
	rz
balx:	lxi	h,M3	;"bad pattern"
	call	mssg
	jmp	0000	;PDL unbalanced but doesn't matter

;	Check for termination of alternative.

enda:	cpi	ORR
	rz
endb:	cpi	RSQ
	rz
	cpi	RBR
	rz
	ora	a
	ret

;	Check for beginning of alternative.

bega:	cpi	ORR
	rz
begb:	cpi	LSQ
	rz
	cpi	LBR
	ret

;	Check for null alternative.

nula:	push	h
	call	nulb
	pop	h
	ret
nulb:	mov	a,m
	inx	h
	ora	a
	rz
	call	bega
	jnz	nulb
	mov	a,m
	call	enda
	jnz	nulb
	jmp	balx

;	Check for given expression.

chek:	ldax	d
	inx	d
	call	enda
	rz
	mov	b,a
	mov	a,m
	cpi	CR
	jz	chno
	mov	a,b
	cpi	LBR
	jz	chlb
	cpi	LSQ
	jz	chsq
	mov	c,m
	inx	h
	cpi	QUE
	jz	chek
	cpi	ALF
	jz	chal
	cmp	c
	jz	chek
	mov	b,a
	mov	a,c
	cpi	'a'
	jc	chno
	cpi	'{'
	jnc	chno
	ani	05FH
	cmp	b
	jz	chek
chno:	ori	0FFH
	ret

;	Check alphanumeric.

chal:	mov	a,c
	cpi	'0'
	jc	chno
	cpi	':'
	jc	chek
	cpi	'A'
	jc	chno
	cpi	'['
	jc	chek
	cpi	'a'
	jc	chno
	cpi	'{'
	jc	chek
	jmp	chno

;	Check list of alternatives.

chsq:	mov	c,l
	mov	b,h
	lhld	sqxx
	push	h
	lhld	sqaa
	push	h
	lhld	sqzz
	push	h
	mov	l,c
	mov	h,b
	shld	sqxx
	xchg
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	shld	sqaa
	xchg
	shld	sqzz
chaa:	lhld	sqxx
	call	chek
	jz	chff
chbb:	lhld	sqaa	;fail so find next alternative
chcc:	call	next
	cpi	RSQ
	jz	chdd	;no more alternatives, so fail
	cpi	ORR
	jnz	chcc
	shld	sqaa
	xchg
	jmp	chaa	;try next alternative
chdd:	lhld	sqxx
	ori	0FFH
chee:	mov	c,l
	mov	b,h
	pop	h
	shld	sqzz
	pop	h
	shld	sqaa
	pop	h
	shld	sqxx
	mov	l,c
	mov	h,b
	ret
chff:	xchg		;good alternative, try rest
	lhld	sqzz
	xchg
	call	chek
	jz	chee
	jmp	chbb

;	Check iterative pattern.

chlb:	mov	c,l
	mov	b,h
	lhld	text
	push	h
	lhld	texx
	push	h
	lhld	rest
	push	h
	lhld	rept
	push	h
	lhld	repp
	push	h
	mov	l,c
	mov	h,b
	shld	text
	shld	texx
	xchg
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	shld	rept
	shld	repp
	xchg
	shld	rest
chlc:	lhld	rest
	xchg
	lhld	text
	call	chek	;check rest
	jz	chzz
chii:	lhld	rept	;rest failed
	xchg
	lhld	text	;keep same text
	call	chek	;try out the repeater
	jnz	choo
	shld	text	;repeater worked, record progress
	lhld	repp	;start alternatives over again
	shld	rept
	jmp	chlc
choo:	lhld	rept	;repeater failed, try next
chxx:	call	next
	cpi	RBR
	jz	chyy	;this was the last, quit
	cpi	ORR
	jnz	chxx
	shld	rept
	jmp	chii
chyy:	lhld	texx
	ori	00	;emphasize the RBR
chzz:	mov	c,l
	mov	b,h
	pop	h
	shld	repp
	pop	h
	shld	rept
	pop	h
	shld	rest
	pop	h
	shld	texx
	pop	h
	shld	text
	mov	l,c
	mov	h,b
	ret

M1:	db	'The command line',CR,LF
	db	'     FYNDE D:FILE.EXT EXPRESSION',CR,LF
	db	'will search through all instances of FILE.EXT',CR,LF
	db	'(which may be an ambiguous reference) on disk D',CR,LF
	db	'to find lines containing EXPRESSION. Such lines',CR,LF
	db	'will be presented on the console preceded by a',CR,LF
	db	'line number, and classified by file. EXPRESSION',CR,LF
	db	'may have the form LABEL!PATTERN or simply the',CR,LF
	db	'form PATTERN. Both may contain:',CR,LF
	db	'     [p1!p2!...!pn]  alternative strings',CR,LF
	db	'     {p1!p2!...!pn}  repeated alternatives',CR,LF
	db	'     ? any single character',CR,LF
	db	'     @ for any alphanumeric: a-z, A-Z, 0-9',CR,LF
	db	'     _ in place of horizontal tab',CR,LF
	db	'When a label is present, lines will be numbered',CR,LF
	db	'relative to the label.  Example: X{?}:![call!ret]',CR,LF
	db	'will list calls and returns relative to labels',CR,LF
	db	'like X0100: or X33:. LABEL begins in column 1,',CR,LF
	db	'PATTERN can begin in any column.',CR,LF,00

M2:	db	'FYNDE.COM 12/20/82 ICUAP',CR,LF,00

M3:	db	'-- Bad Pattern --',00

M4:	db	CR,LF,'-- Search Terminated --',00

enth:	ds	1
file:	db	'DFilenameEXT',00
	ds	19

sqxx:	ds	2
sqaa:	ds	2
sqzz:	ds	2
text:	ds	2
texx:	ds	2
rest:	ds	2
rept:	ds	2
repp:	ds	2

patt:	ds	256	;command line pattern
	ds	100	;stack area
stak:	ds	0	;initialize stack pointer
lapo:	ds	2	;label pointer
papo:	ds	2	;pattern pointer
fhed:	db	'----> File '
fnam:	db	'xxxxxxxx.'	;filename
fext:	db	'xxx',CR,LF,00	;file extension
llbl:	db	'      +'
lnum:	db	'         ',00
lzer:	db	'   0'
ftot:	db	'      lines found',CR,LF,00
dtot:	db	'      instances in the entire disk',CR,LF,00
	db	00	;fence for line buffer
lbuf:	ds	85H	;line buffer
ictr:	ds	2
iptr:	ds	2
ibuf:	ds	isiz
fini:	ds	0

	end

