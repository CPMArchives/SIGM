

;	----------------------------------------------------------
;	Reassembly of FIND.COM, which was originally extracted
;	from the CBBS(R) package available from Ward Christensen
;	and Randy Suess. However, considerable rearrangement has
;	taken place, most notably the following:
;	 -  <no file name> results in a screen of information
;	 -  the search pattern may be a regular expression
;	 -  instance count reported, both per file and globally
;	To achieve compatibility with MicroShell the vertical bar
;	was replaced by exclamation point; all syntactic elements
;	are defined by EQU's and may be redefined. LABEL!PATTERN
;	is checked for balanced parentheses and non-null arguments
;	to forestall the most common failure modes. Had MicroShell
;	not been available, an option to direct the output to some
;	disk file would probably have been included. STUTE.ASM
;	differs from FIND in that the patterns found are replaced
;	by a constant rather than just being located.
;
;		    STUTE.ASM   Copyright (C) 1983
;		    Universidad Autonoma de Puebla
;
;	[Harold V. McIntosh, 28 February 1983]
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
osiz	equ	128

;	-------------
	org	0100H
;	-------------

begn:	lxi	h,0000
	dad	sp
	shld	stak
	lxi	sp,stak
	lda	cfcb+1	;file name
	cpi	' '
	jnz	X0143
	lxi	h,tuto	;tutorial message
	call	mssg
	jmp	gbye

X0143:	lxi	h,logo	;identification line
	call	mssg
	mvi	c,12
	lxi	d,cfcb	;CP/M's FCB
	lxi	h,file	;generic filename
	call	miuc
	lda	file	;generic filename
	sta	kfil	;backup file (.BAK)
	sta	ifil	;input file  (.EXT)
	sta	ofil	;output file (.$$$)
	sta	ufil	;active output (.$$$)
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
	call	bala		;check balance of [], {}.
	call	nula		;check for null alternatives
	lxi	d,patt		;command line pattern
	call	muve
	xchg
	dcx	h
	shld	sund
	mvi	c,4
	lxi	d,lzer
	lxi	h,dtot
	call	miuc
	lxi	h,patt		;command line pattern
	shld	papo
	call	next
	shld	supo		;substitute pointer

;	Scan the directory for file names.

prep:	xra	a
	inr	a
	sta	dctr	;directory counter
	lxi	h,diry	;directory extract
	shld	dptr	;directory pointer
	push	h
	mvi	c,26	;(1A) set DMA address
	lxi	d,cbuf	;CP/M's record buffer
	call	0005	; - B D O S -

	mvi	c,17	;(11) search once
	lxi	d,file	;generic filename
	call	0005	; - B D O S -

fnth:	pop	h
	inr	a
	jz	scan	;all relevant files located
	push	h
	dcr	a
	ani	03
	add	a
	add	a
	add	a
	add	a
	add	a
	adi	81H
	mov	e,a
	mvi	d,00
	lxi	h,8
	dad	d
	push	h
	mov	a,m
	cpi	'B'
	jnz	nbak
	inx	h
	mov	a,m
	cpi	'A'
	jnz	nbak
	inx	h
	mov	a,m
	cpi	'K'
	pop	h
	jz	omit
	jmp	nbac
nbak:	pop	h
nbac:	mvi	a,'$'
	cmp	m
	jnz	ndol
	inx	h
	cmp	m
	jnz	ndol
	inx	h
	cmp	m
	jz	omit
ndol:	mvi	c,12
	pop	h
	call	miuc
	push	h
	lxi	h,dctr	;directory counter
	inr	m

omit:	mvi	c,18	;(12) search again
	lxi	d,file	;generic filename
	call	0005	; - B D O S -

	jmp	fnth

;	We're all done.

done:	lxi	h,dtot
	call	mssg
gbye:	lhld	stak
	sphl
	ret

;	A prospective file has been located

scan:	lxi	h,dctr
	dcr	m
	jz	done
	lhld	dptr
	xchg
	lxi	h,12
	dad	d
	shld	dptr
	push	d

	mvi	c,8
	pop	d
	push	d
	lxi	h,kfil+1	;backup file (.BAK)
	call	miuc

	mvi	c,11
	pop	d
	push	d
	lxi	h,ifil+1	;input file  (.EXT)
	call	miuc

	mvi	c,8
	pop	d
	push	d
	lxi	h,ofil+1	;output file (.$$$)
	call	miuc

	mvi	c,8
	pop	d
	push	d
	lxi	h,ufil+1	;active output (.$$$)
	call	miuc

	mvi	c,12
	pop	d
	lxi	h,cfcb+1	;CP/M's file control block
	call	miuc

	mvi	c,19		;(13) delete file
	lxi	d,kfil		;backup file (.BAK)
	call	0005		; - B D O S -

	mvi	c,19		;(13) delete file
	lxi	d,ofil		;output file (.$$$)
	call	0005		; - B D O S -

	mvi	c,22		;(16) create file
	lxi	d,ufil		;active output (.$$$)
	call	0005		; - B D O S -
	mvi	a,00
	sta	urec

	mvi	c,15		;(0F) open file
	lxi	d,cfcb		;CP/M's FCB
	call	0005		; - B D O S -
	inr	a
	jz	gbye		;quit [without message]
	xra	a
	sta	cblk		;block pointer

	mvi	c,4
	lxi	d,lzer
	lxi	h,lnum		;'line number'
	call	miuc
	mvi	c,4
	lxi	d,lzer
	lxi	h,ftot		;'file total'
	call	miuc
	mvi	c,8
	lxi	d,cfcb+1	;file name
	lxi	h,fnam		;'file name'
	call	miuc
	mvi	c,3
	lxi	d,0065H		;extension
	lxi	h,fext		;'file extension'
	call	miuc
	lxi	h,fhed
	call	mssg		;message to console
	lxi	b,2006H		;six spaces
	lxi	h,llbl
	call	fiuc		;fill until count

X01C2:	lxi	h,0000
	shld	ictr
	lxi	h,0080H
	shld	octr
	lxi	h,ubuf
	shld	optr
X01C8:	lxi	h,lnum+3	;increment l.c.
	call	inco		;increment line counter
	lxi	h,lbuf		;line buffer
	mvi	b,0FFH
X01E0:	inr	b
	jm	X01FD
	push	b
	push	h
	call	inch		;char from big bffr to line bffr
	pop	h
	pop	b
	mov	m,a
	inx	h
	cpi	KZ
	jnz	X01E8
	lxi	h,ftot
	call	mssg

;	Close out last, incomplete record.

lare:	lhld	octr
	mov	a,h
	ora	l
	jz	clof
	mvi	a,1AH
	call	ouch
	jmp	lare

clof:	mvi	c,21		;(15) write one record
	lxi	d,ufil	;active output (.$$$)
	call	0005		; - B D O S -

	mvi	c,16		;(10) close file
	lxi	d,ufil	;active output (.$$$)
	call	0005		; - B D O S -

	mvi	c,23		;(17) rename file
	lxi	d,ifil		;input file  (.EXT)
	call	0005		; - B D O S -

	mvi	c,23		;(17) rename file
	lxi	d,ofil		;output file (.$$$)
	call	0005		; - B D O S -

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


X0202:	mvi	m,00		;guarantee right hand fence
	mvi	c,11		;(0B) console status
	call	0005		; - B D O S -
	ora	a
	jz	culi
	mvi	c,1		;(01) read console
	call	0005		; - B D O S -
	lxi	h,M4		;"search terminated"
	call	mssg
	jmp	gbye

;	Scan the current line.

culi:	lxi	h,lbuf		;line buffer
	shld	alfa
	shld	beta
X021A:	lhld	papo		;substitute pointer
	xchg
	lhld	beta
	mov	a,m
	cpi	CR
	jz	nuli
	call	chek
	jnz	fail
	push	d
	push	h
	lxi	h,llbl
	call	mssg
	lxi	h,lbuf
	call	mssg
	lxi	h,ftot+3
	call	inco
	lxi	h,dtot+3
	call	inco
	lhld	beta
	xchg
	lhld	alfa
	call	ouli
	lhld	sund
	xchg
	lhld	supo
	call	ouli
	pop	h
	shld	alfa
	dcx	h
	shld	beta
	pop	d
fail:	lhld	beta
	inx	h
	shld	beta
	jmp	X021A

nuli:	lhld	beta
	inx	h
	inx	h
	xchg
	lhld	alfa
	call	ouli
	jmp	X01C8		;increment l.c. at X026A

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
	call	0005	; - B D O S -
	pop	h
	mov	a,m
	ora	a
	jnz	mssg
	ret

X029C:	lxi	h,M3	;"bad pattern"
	call	mssg
	jmp	gbye

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

;	Send a "line" [(HL) to (DE)] to out file

ouli:	mov	a,e
	sub	l
	mov	c,a
	mov	a,d
	sbb	h
	mov	b,a
oulj:	mov	a,b
	ora	c
	rz
	mov	a,m
	call	ouch
	dcx	b
	inx	h
	jmp	oulj

;	Send one character to the output file, conserve BC, HL

ouch:	push	b
	push	h
	push	psw
	lhld	octr
	mov	a,h
	ora	l
	cz	oudi		;OUT area to disk
	lhld	octr
	dcx	h
	shld	octr
	pop	psw
	lhld	optr
	mov	m,a
	inx	h
	shld	optr
	pop	h
	pop	b
	ret

oudi:	lxi	h,osiz
	shld	octr
	lxi	h,ubuf
	shld	optr
	xchg
	mvi	c,26	;(1A) set DMA address
	call	0005	; - B D O S -
	lxi	d,ufil	;active output (.$$$)
	mvi	c,21	;(15) write one record
	call	0005	; - B D O S -
	ora	a
	ret

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

;	Fill (with B) until count (C).

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
	jmp	gbye	;PDL unbalanced but doesn't matter

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

tuto:	db	'The command line',CR,LF
	db	'     STUTE D:FILE.EXT PATTERN!SKELETON',CR,LF
	db	'will search through all instances of FILE.EXT',CR,LF
	db	'(which may be an ambiguous reference) on disk D',CR,LF
	db	'to find lines containing PATTERN. Such lines will',CR,LF
	db	'be shown on the console preceded by a line number,',CR,LF
	db	'classified by file. Whenever the regular expression',CR,LF
	db	'PATTERN is found, it will be replaced by the constant',CR,LF
	db	'SKELETON. The PATTERN may contain:',CR,LF
	db	'     [p1!p2!...!pn]  alternative strings',CR,LF
	db	'     {p1!p2!...!pn}  repeated alternatives',CR,LF
	db	'     ? any single character',CR,LF
	db	'     @ for any alphanumeric: a-z, A-Z, 0-9',CR,LF
	db	'     _ in place of horizontal tab',CR,LF
	db	'A general PATTERN must be used with extreme caution',CR,LF
	db	'because the same constant will replace it, whatever',CR,LF
	db	'its form. The PATTERN may not involve more than one',CR,LF
	db	'single line, but more than one instance of the PATTERN',CR,LF
	db	'may occupy the same line.',CR,LF
	db	00

logo:	db	'STUTE.COM 28/FEB/83 ICUAP',CR,LF,00

M3:	db	'-- Bad Pattern --',00

M4:	db	CR,LF,'-- Substitution Terminated --',00

;	The following file control segments are arranged in just
;	the form shown so that they will be properly paired for
;	the renaming which has to be done after closing each file.

enth:	ds	1
file:	db	'DFilenameEXT',00,00,00,00	;generic filename
	ds	16
ofil:	db	'DFilename$$$',00,00,00,00	;output file (.$$$)
ifil:	db	'DFilenameEXT',00,00,00,00	;input file  (.EXT)
kfil:	db	'DFilenameBAK',00,00,00,00	;backup file (.BAK)
ufil:	db	'Dfilename$$$',00,00,00,00	;active output (.$$$)
	ds	16
urec:	ds	1
ubuf:	ds	80H
optr:	ds	2
octr:	ds	2

;	All the relevant files are located and noted before any
;	substitutions are made, to avoid a newly created file
;	being placed in the dictionary, being encountered again
;	later on and then being processed a second time. The worst
;	case would be to have to use all 64 files (minus one, for
;	elbow room) in the directory.

dctr:	ds	1	;directory counter
dptr:	ds	2	;directory pointer
diry:	ds	1024	;directory of file names, if needed

;	Temporary storage for the regular expression parser.

sqxx:	ds	2
sqaa:	ds	2
sqzz:	ds	2
text:	ds	2
texx:	ds	2
rest:	ds	2
rept:	ds	2
repp:	ds	2

alfa:	ds	2
beta:	ds	2

patt:	ds	256		;command line pattern
	ds	100		;stack area
stak:	ds	2		;initialize stack pointer
papo:	ds	2		;pattern pointer
supo:	ds	2		;substitute pointer
sund:	ds	2
fhed:	db	'----> File '
fnam:	db	'xxxxxxxx.'	;filename
fext:	db	'xxx',CR,LF,00	;file extension
llbl:	db	'      +'
lnum:	db	'         ',00
lzer:	db	'   0'
ftot:	db	'      lines found',CR,LF,00
dtot:	db	'      instances in the entire disk',CR,LF,00
	db	00		;fence for line buffer
lbuf:	ds	85H		;line buffer
ictr:	ds	2
iptr:	ds	2
ibuf:	ds	isiz
fini:	ds	0

	end

