
;	----------------------------------------------------------
;	FFYNDE.ASM is a variant of FYNDE.ASM in which a family of
;	files can be searched for many different keywords, which
;	are taken one at a time from an auxiliary file. Indices or
;	cross-reference listings are readily prepared by using it,
;	supposing that a previous pass has isolated the indexing
;	items and placed them in the auxiliary file. XREF.CNV can
;	be used for the initial pass.
;
;	Beware:
;		spaces count as part of patterns, especialy the
;		first ones: <file.ext  patt> has ONE space. So
;		does <file.ext patt >.
;
;		{?} requires at least ONE character.
;
;		    FFYNDE.ASM  Copyright (C) 1984
;		    Universidad Autonoma de Puebla
;
;	[Harold V. McIntosh, 20 August 1984]
;	----------------------------------------------------------

HT	equ	09H		;horizontal tab
LF	equ	0AH		;line feed
CR	equ	0DH		;carriage return
KZ	equ	1AH		;^Z

;	Delimiters for the command line

LSQ	equ	'['		;begin alternative list
RSQ	equ	']'		;end alternative list
LBR	equ	'{'		;begin iterated expression
RBR	equ	'}'		;end iterated expression
ORR	equ	'!'		;separate alternatives

;	Representatives of characters or classes.

TAB	equ	'_'		;substitute for tab
QUE	equ	'?'		;represent any byte
ALF	equ	'@'		;represent any alphanumeric

;	CP/M and other locations and parameters

cfcb	equ	005CH		;CP/M's file control block
csiz	equ	0080H		;CP/M's record size
cbuf	equ	0080H		;CP/M's record buffer
ksiz	equ	26		;sector capacity of IN buffer
isiz	equ	ksiz*128
hsiz	equ	257		;max characters in Huffman code

;	------------
	org	100H
;	------------

begn:	lxi	sp,stak
	lda	cfcb+1		;file name
	cpi	' '
	jnz	ntut
	lxi	h,M1		;tutorial
ferm:	call	mssg		;message to console
	jmp	0000

ntut:	lxi	h,M2		;signon message
	call	xref		;message to .XRF file
	call	mssg		;message to console

	mvi	c,12
	lxi	d,cfcb		;CP/M's file control block
	lxi	h,sfam		;search family
	call	miuc		;block move

	mvi	c,12
	lxi	d,cfcb+16	;CP/M's file control block
	lxi	h,kfil		;keyword FCB
	call	miuc		;block move
	lxi	b,0015H		;21 0's
	call	fiuc		;block fill
	lxi	h,kfil+9	;keyword FCB
	mov	a,m
	cpi	' '
	jnz	kext
	mvi	m,'S'
	inx	h
	mvi	m,'Y'
	inx	h
	mvi	m,'M'

kext:	mvi	c,9
	lxi	d,cfcb+16	;CP/M's file control block
	lxi	h,xfil		;.XRF FCB
	call	miuc		;block move
	mvi	m,'X'
	inx	h
	mvi	m,'R'
	inx	h
	mvi	m,'F'
	inx	h
	lxi	b,0015h 	;21 0's
	call	fiuc		;block fill

	lxi	h,cbuf		;CP/M's record buffer
	mov	e,m
	mvi	d,0
	inx	d
	xchg
	dad	d
	mvi	m,0
	xchg

;	Skip any initial spaces.

ispa:	inx	h
	mov	a,m
	ora	a
	jz	X029C
	cpi	' '
	jz	ispa

;	Skip over file name.

sfil:	inx	h
	mov	a,m
	ora	a
	jz	X029C
	cpi	' '
	jnz	sfil

;	skip over blanks

sblk:	inx	h
	mov	a,m
	ora	a
	jz	X029C
	cpi	' '
	jz	sblk

;	skip keyfile name

skey:	inx	h
	mov	a,m
	ora	a
	jz	hedr		;no header desired
	cpi	' '
	jnz	skey
	inx	h		;pass over last space

;	Read header description.

hedr:	call	bala		;check balance of [], {}.
	call	nula		;check for null alternatives
	lxi	d,patt		;command line pattern
	call	muve		;copy & semicompile cmd line

;	Open keyword file.

	mvi	c,15		;(0F) open file
	lxi	d,kfil		;keyword FCB
	call	0005		; - B D O S -
	inr	a
	jnz	okey
	lxi	h,nkey		;'cannot open keyword file'
	jmp	ferm		;final (error) message

;	Create crossreference file.

okey:	mvi	c,17		;(11) search for file
	lxi	d,xfil		;.XRF FCB
	call	0005		; - B D O S -
	inr	a
	jz	cxrf
	lxi	h,yexi		;'file already exists'
	jmp	ferm		;final (error) message

cxrf:	mvi	c,22		;(16) create file
	lxi	d,xfil		;.XRF FCB
	call	0005		; - B D O S -
	inr	a
	jnz	gogo
	lxi	d,nxrf		;'can''t open file'
	jmp	ferm		;final (error) message

gogo:	mvi	c,4
	lxi	d,lzer		;zero line for counter
	lxi	h,ktot		;keyword total
	call	miuc		;block move

	lxi	h,csiz		;CP/M's record size
	shld	xctr		;crossreference counter
	lxi	h,xbuf		;crossreference buffer
	shld	xptr		;crossreference pointer
	lxi	h,0000
	shld	kctr		;keyword counter
	shld	lapo		;label pointer
	lxi	h,patt		;command line pattern
	mov	a,m
	ora	a
	jz	golu
	shld	lapo		;label pointer

golu:	lxi	d,kwrd		;keyword pattern
	lxi	h,keyr		;raw keyword
	call	meuv		;read & semicompile keyword
	cpi	01AH
	jz	golv
	xra	a
	stax	d
	mov	m,a
	sta	enth		;search-again counter
	lxi	h,kwdi		;'keyword is'
	call	xref		;message to .XRF file
	call	mssg		;message to console
	lxi	h,crlf
	call	xref		;message to .XRF file
	call	mssg		;message to console
	call	ongo
	lxi	h,ktot+3	;total # keywords
	call	inco		;increment counter
	jmp	golu

golv:	lxi	h,ktot		;'keyword totals'
	call	xref		;message to .XRF file
	call	mssg		;message to console
	call	zxrf
	jmp	0000

ongo:	mvi	c,4
	lxi	d,lzer		;zero line for counter
	lxi	h,dtot		;total throughout disk
	call	miuc		;block move

;	Scan the directory for file names.

scan:	mvi	c,26		;(1A) set DMA address
	lxi	d,cbuf		;CP/M's record buffer
	call	0005		; - B D O S -

	lxi	h,cfcb+12
	mvi	m,00

	mvi	c,17		;(11) search once
	lxi	d,sfam		;search family
	call	0005		; - B D O S -

	lxi	h,enth		;search-again counter
	inr	m
	mov	c,m
fnth:	inr	a
	jz	done		;we're all done
	dcr	c
	jz	this
	push	b
	mvi	c,18		;(12) search again
	lxi	d,sfam		;search family
	call	0005		; - B D O S -
	pop	b
	jmp	fnth

;	We're all done.

done:	lxi	h,dtot		;total throughout disk
	call	xref		;message to .XRF file
	jmp	mssg		;message to console

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
	lxi	h,cfcb+1	;CP/M's file control block
	call	miuc		;block move

	lxi	h,cfcb+9	;CP/M's file control block
	call	dcom		;disregard .COM files
	jz	scan
	lxi	h,cfcb+9	;CP/M's file control block
	call	dcmd		;disregard .CMD files
	jz	scan
	lxi	h,cfcb+9	;CP/M's file control block
	call	dxrf		;disregard .XRF files
	jz	scan

;	Open the file, check for squeezing.

	mvi	c,15		;(0F) open file
	lxi	d,cfcb		;CP/M's FCB
	call	0005		; - B D O S -
	inr	a
	jz	0000		;quit [without message]
	xra	a
	sta	cfcb+32
	sta	cfcb+32		;block pointer
	sta	dens		;z/nz=un/squeezed
	sta	mult		;repeat factor
	lxi	h,0000
	shld	ictr		;input counter

	lxi	h,cfcb+10	;CP/M's file control block
	mov	a,m
	cpi	'Q'
	jnz	nsqz
	call	gbyt		;fetch one byte
	cpi	076H
	jnz	nsqz
	call	gbyt		;fetch one byte
	cpi	0FFH
	jnz	nsqz
	lxi	h,dens		;z/nz=un/squeezed
	mvi	m,0FFH
	call	rwor		;fetch word

;	unsqueezed file name

	lxi	b,200CH		;twelve spaces
	lxi	h,uzfn		;unsqueezed file's name
	call	fiuc		;block fill

	mvi	b,8
	lxi	d,uzfn		;unsqueezed file's name
luup:	call	gbyt		;fetch one byte
	ora	a
	jz	luut
	cpi	'.'
	jz	luuw
	stax	d
	inx	d
	dcr	b
	jnz	luup
luuz:	call	gbyt
	ora	a
	jz	luut
	cpi	'.'
	jnz	luuz
luuw:	mvi	b,3
	lxi	d,uzfn+8
	stax	d
	inx	d
luur:	call	gbyt
	ora	a
	jz	luut
	stax	d
	inx	d
	dcr	b
	jnz	luur
luus:	call	gbyt
	ora	a
	jnz	luus

luut:	lxi	h,uzfn+9	;unsqueezed FCB
	call	dcom		;disregard .COM files
	jz	scan
	lxi	h,uzfn+9	;unsqueezed FCB
	call	dcmd		;disregard .CMD files
	jz	scan
	lxi	h,cfcb+9	;unsqueezed FCB
	call	dxrf		;disregard .XRF files
	jz	scan


;	load code directory

ldic:	call	rwor		;fetch word
	lxi	b,hsiz
	mov	a,c
	sub	l
	mov	a,b
	sbb	h
	jnc	ldii
	lxi	h,M8		;'code table won't fit'
	call	mssg		;message to console
	jmp	scan

ldii:	dad	h
	dad	h
	mov	c,l
	mov	b,h
	lxi	d,code		;code table
ldij:	call	gbyt		;fetch one byte
	stax	d
	inx	d
	dcx	b
	mov	a,c
	ora	b
	jnz	ldij

	lxi	h,roco		;rotation count
	mvi	m,1

nsqz:	mvi	c,4
	lxi	d,lzer		;zero line for counter
	lxi	h,lnum		;'line number'
	call	miuc		;block move

	mvi	c,4
	lxi	d,lzer		;zero line for counter
	lxi	h,ftot		;'file total'
	call	miuc		;block move

	mvi	c,8
	lxi	d,cfcb+1	;file name
	lxi	h,fnam		;'file name'
	call	miuc		;block move

	mvi	c,3
	lxi	d,0065H		;extension
	lxi	h,fext		;'file extension'
	call	miuc		;block move

	lxi	h,fhed		;'header ----> FILE'
	call	xref		;message to .XRF file
	call	mssg		;message to console
	lda	dens
	ora	a
	jz	sixs
	lxi	h,hesq		;'[original]'
	call	xref		;message to .XRF file
	call	mssg		;message to console

sixs:	lxi	b,2006H		;six spaces
	lxi	h,llbl
	call	fiuc		;block fill

X01C8:	lxi	h,lnum+3	;line number
	call	inco		;increment counter
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
	call	xref		;message to .XRF file
	call	mssg		;message to console
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
	cpi	03H		;^C
	jnz	skpf

	mvi	c,19		;(13) delete file
	lxi	d,xfil		;.XRF FCB
	call	0005		; - B D O S -
	lxi	h,M4		;"search terminated"
	jmp	ferm		;final (error) message

skpf:	lxi	h,M5		;"remainder of file skipped"
	call	xref		;message to .XRF file
	call	mssg		;message to console
	jmp	scan

;	Scan the current line.
;	First see if it is labelled.

culi:	lhld	lapo		;label pointer
	mov	a,h
	ora	l
	jz	X0217		;no label requested
	xchg
	lxi	h,lbuf
	call	chek
	jnz	X0217		;label not found
	push	h
	lxi	b,2006H		;six spaces
	lxi	h,llbl
	call	fiuc		;block fill
	pop	h
	lxi	d,llbl+5
	mvi	c,6
didl:	dcx	h
	mov	a,m
	cpi	HT		;ignore tabs in text
	jz	didl
	cpi	' '		;quit at head of line
	jc	dido
	stax	d
	dcx	d
	dcr	c
	jnz	didl
dido:	mvi	c,4
	lxi	d,lzer		;zero line for counter
	lxi	h,lnum		;line number
	call	miuc		;block move

;	Now look for the pattern

X0217:	lxi	h,lbuf		;line buffer
X021A:	lxi	d,kwrd		;keyword pattern
	push	h
	call	chek
	pop	h
	jz	X0263
	mov	a,m
	cpi	CR
	jz	X01C8		;increment l.c. at X026A
	inx	h
	jmp	X021A

;	Pattern matches, so type label & line containing it

X0263:	lxi	h,llbl		;line label
	call	xref		;message to .XRF file
	call	mssg		;message to console
	lxi	h,lbuf		;line buffer
	call	xref		;message to .XRF file
	call	mssg		;message to console
	lxi	h,ftot+3
	call	inco		;increment counter
	lxi	h,dtot+3	;total throughout disk
	call	inco		;increment counter
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
	jmp	inco		;increment counter

;	Memory to console

mssg:	mov	e,m
	inx	h
	push	h
	mvi	c,2		;(02) write console
	call	0005		; - B D O S -
	pop	h
	mov	a,m
	ora	a
	jnz	mssg		;message to console
	ret

X029C:	lxi	h,M3		;"bad pattern"
	call	ferm		;final (error) message

;	decode next character

dnch:	lxi	h,code		;code table
dncr:	call	rbit
	jnc	dncs
	inx	h
	inx	h
dncs:	mov	e,m
	inx	h
	mov	d,m
	mov	a,d
	cpi	0FEH
	jz	dnct
	ora	a
	jp	dncu
	mov	a,e
	cma
	stc
	cmc
	ret

dnct:	stc
	ret

;	Calculate <code>+4*<offset>.

dncu:	lxi	h,code		;code table
	dad	d
	dad	d
	dad	d
	dad	d
	jmp	dncr

;	read one bit at a time

rbit:	push	h
	lxi	h,roco		;rotation count
	dcr	m
	jnz	rbiu
	mvi	m,8
	call	gbyt		;fetch one byte
	sta	roby		;rotating byte
rbiu:	lda	roby		;rotating byte
	rar
	sta	roby		;rotating byte
	pop	h
	ret

;	read one word

rwor:	call	gbyt		;fetch one byte
	push	psw
	call	gbyt		;fetch one byte
	pop	h
	mov	l,h
	mov	h,a
	ret

;	Fetch the next byte. The input buffer will be refreshed if it
;	is necessary. For normal files, one byte will be extracted from
;	the input buffer; for squeezed files, one byte will be decoded
;	from the incoming bit stream and subtracted from the checksum.

inch:	lda	dens		;z/nz = un/squeezed
	ora	a
	jz	gbyt		;fetch one byte
	lda	mult		;repeat factor
	ora	a
	jz	gusq
	dcr	a
	sta	mult		;repeat factor
	lda	lach		;last character read
	ret

gusq:	call	dnch
	jnc	guss
	mvi	a,1AH
	ret

guss:	cpi	090H
	jz	gusu
	sta	lach		;last character read
	ret

gusu:	call	dnch
	ora	a
	jnz	gusv
	mvi	a,090H
	ret

gusv:	dcr	a
	dcr	a
	sta	mult		;repeat factor
	lda	lach		;last character read
	ret

;	unsqueezed (normal) text

gbyt:	lhld	ictr		;input counter
	mov	a,h
	ora	l
	cz	indi		;disk to IN area
	lhld	ictr		;input counter
	dcx	h
	shld	ictr		;input counter
	lhld	iptr		;input pointer
	mov	a,m
	inx	h
	shld	iptr		;input pointer
	ret

indi:	mvi	b,ksiz
	lxi	h,isiz
	shld	ictr		;input counter
	lxi	h,ibuf		;input buffer
	shld	iptr		;input pointer
indd:	mvi	m,KZ
	push	h
	push	b
	xchg
	mvi	c,26		;(1A) set DMA address
	call	0005		; - B D O S -
	lxi	d,cfcb		;CP/M's file control block
	mvi	c,20		;(14) read one record
	call	0005		; - B D O S -
	pop	b
	pop	h
	ora	a
	rnz
	dcr	b
	rz
	lxi	d,csiz		;CP/M's record size
	dad	d
	jmp	indd

;	Fetch next keyword byte.

gkey:	push	h
	lhld	kctr		;keyword counter
	mov	a,h
	ora	l
	cz	kndi		;disk to IN area
	lhld	kctr		;keyword counter
	dcx	h
	shld	kctr		;keyword counter
	lhld	kptr		;input pointer
	mov	a,m
	inx	h
	shld	kptr		;input pointer
	pop	h
	ret

kndi:	lxi	h,csiz		;CP/M's record size
	shld	kctr		;keyword counter
	lxi	h,kbuf		;input buffer
	shld	kptr		;input pointer
	mvi	m,KZ
	push	h
	push	d
	push	b
	xchg
	mvi	c,26		;(1A) set DMA address
	call	0005		; - B D O S -
	lxi	d,kfil		;keyword FCB
	mvi	c,20		;(14) read one record
	call	0005		; - B D O S -
	pop	b
	pop	d
	pop	h
	ora	a
	ret

;	Send line to .XRF FCB.

xref:	push	h
xreg:	mov	a,m
	ora	a
	jz	xreh
	inx	h
	push	h
	call	wxrf
	pop	h
	jmp	xreg		;message to .XRF file
xreh:	pop	h
	ret

;	Write next crossreference byte.

wxrf:	push	psw
	lhld	xctr		;crossreference counter
	mov	a,h
	ora	l
	cz	xndi		;disk to IN area
	lhld	xctr		;crossreference counter
	dcx	h
	shld	xctr		;crossreference counter
	lhld	xptr		;crossreference pointer
	pop	psw
	mov	m,a
	inx	h
	shld	xptr		;crossreference pointer
	ret

xndi:	lxi	h,csiz		;CP/M's record size
	shld	xctr		;crossreference counter
	lxi	h,xbuf		;crossreference buffer
	shld	xptr		;crossreference pointer
	push	h
	push	b
	xchg
	mvi	c,26		;(1A) set DMA address
	call	0005		; - B D O S -
	lxi	d,xfil		;.XRF FCB
	mvi	c,21		;(15) write one record
	call	0005		; - B D O S -
	cpi	00
	lxi	h,xwre		;'can''t write'
	jnz	ferm		;final (error) message
	pop	b
	pop	h
	ora	a
	ret

;	Close crossreference file.

zxrf:	lhld	xctr
	xchg
	mov	a,e
	ora	d
	jz	clos
	lhld	xptr		;crossreference pointer
zxrg:	mvi	m,01AH		;^Z
	inx	h
	dcx	d
	mov	a,e
	ora	d
	jnz	zxrg
	call	xndi

clos:	mvi	c,16		;(10) close file
	lxi	d,xfil		;.XRF FCB
	call	0005		; - B D O S -
	inr	a
	rnz
	lxi	h,cclo		;'can''t close'
	jmp	ferm		;final (error) message

;	Disregard .COM files

dcom:	mov	a,m
	cpi	'C'
	rnz
	inx	h
	mov	a,m
	cpi	'O'
	rnz
	inx	h
	mov	a,m
	cpi	'M'
	rnz
	lxi	h,M6		;".COM file disregarded"
	call	mssg		;message to console
	xra	a
	ret

;	Disregard .CMD files

dcmd:	mov	a,m
	cpi	'C'
	rnz
	inx	h
	mov	a,m
	cpi	'M'
	rnz
	inx	h
	mov	a,m
	cpi	'D'
	rnz
	lxi	h,M7		;".CMD file disregarded"
	call	mssg		;message to console
	xra	a
	ret

;	Disregard .XRF files

dxrf:	mov	a,m
	cpi	'X'
	rnz
	inx	h
	mov	a,m
	cpi	'R'
	rnz
	inx	h
	mov	a,m
	cpi	'F'
	rnz
	lxi	h,M9		;".XRF file disregarded"
	call	mssg		;message to console
	xra	a
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

;	Block fill with C B's starting at (HL).

fiuc:	mov	m,b
	inx	h
	dcr	c
	jnz	fiuc		;block fill
	ret

;	Block move of C bytes from (DE) to (HL).

miuc:	ldax	d
	mov	m,a
	inx	d
	inx	h
	dcr	c
	jnz	miuc		;block move
	ret

;	Read and semicompile the keyword.

meuv:	call	gkey
	cpi	CR
	jz	gkey		;remove following LF
	cpi	01AH		;^Z
	rz			;end of file
	mov	m,a
	inx	h
	cpi	TAB
	jnz	mvnt
	mvi	a,HT
mvnt:	stax	d
	inx	d
	cpi	RBR
	jz	mvrb
	cpi	RSQ
	jz	mvrb
	cpi	LBR
	jz	mvlb
	cpi	LSQ
	jz	mvlb
	jmp	meuv

mvrb:	xthl
	mov	m,e
	inx	h
	mov	m,d
	pop	h
	jmp	meuv

mvlb:	push	d
	inx	d
	inx	d
	jmp	meuv

;	Move and semi-compile the command line.
;	    HL points to the command line
;	    DE points to the pattern buffer
;	    copy until a zero byte is found

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
must:	ora	a
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
balx:	lxi	h,M3		;"bad pattern"
	jmp	ferm		;final (error) message

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
chbb:	lhld	sqaa		;fail so find next alternative
chcc:	call	next
	cpi	RSQ
	jz	chdd		;no more alternatives, so fail
	cpi	ORR
	jnz	chcc
	shld	sqaa
	xchg
	jmp	chaa		;try next alternative
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
chff:	xchg			;good alternative, try rest
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
	call	chek		;check rest
	jz	chzz
chii:	lhld	rept		;rest failed
	xchg
	lhld	text		;keep same text
	call	chek		;try out the repeater
	jnz	choo
	shld	text		;repeater worked, record progress
	lhld	repp		;start alternatives over again
	shld	rept
	jmp	chlc
choo:	lhld	rept		;repeater failed, try next
chxx:	call	next
	cpi	RBR
	jz	chyy		;this was the last, quit
	cpi	ORR
	jnz	chxx
	shld	rept
	jmp	chii
chyy:	lhld	texx
	ori	00		;emphasize the RBR
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

M1:	db	'The command line',CR,LF,CR,LF
	db	'     FFYNDE [D:]FILE.EXT [E:]KEY.SYM LABEL',CR,LF,CR,LF
	db	'will search through all instances of FILE.EXT (which',CR,LF
	db	'may be an ambiguous reference) on disk D for lines',CR,LF
	db	'containing keywords taken from KEY.SYM (whose disk may',CR,LF
	db	'be specified). Any of these keywords may be regular',CR,LF
	db	'expressions. Then the whole family of files will be',CR,LF
	db	'searched for each line in KEY, whose default extension',CR,LF
	db	'is SYM. Results will be shown on the console and placed',CR,LF
	db	'in [E:]KEY.XRF. LABEL, a regular expression too, is a',CR,LF
	db	'reference for relative line numbers; if it is omitted',CR,LF
	db	'lines will be numbered serially in each file. Regular',CR,LF
	db	'expressions are formed as follows:',CR,LF
	db	'     [p1!p2!...!pn]  alternative strings',CR,LF
	db	'     {p1!p2!...!pn}  repeated alternatives',CR,LF
	db	'     ? any single character',CR,LF
	db	'     @ for any alphanumeric: a-z, A-Z, 0-9',CR,LF
	db	'     _ in place of horizontal tab',CR,LF
	db	'Squeezed files will be searched as well as unsqueezed',CR,LF
	db	'ones. Use ^C to quit, any other key skips rest of file.',CR,LF
	db	00

M2:	db	'FFYNDE.COM 08/01/84 ICUAP',CR,LF,00

M3:	db	'-- Bad Pattern --',00

M4:	db	CR,LF,'-- Search Terminated --',00

M5:	db	' -- Remainder of File Skipped --',CR,LF,00

M6:	db	'.COM file disregarded.',CR,LF,00

M7:	db	'.CMD file disregarded.',CR,LF,00

M8:	db	' -- Code Table Won''t Fit --',CR,LF,00

M9:	db	'.XRF file disregarded.',CR,LF,00

nkey:	db	' -- Can''t Open Keyword File --',CR,LF,00

yexi:	db	' -- Crossreference File Already Exists --',CR,LF,00

nxrf:	db	' -- Can''t Open Crossreference File --',CR,LF,00

xwre:	db	' -- Write Error in Crossreference File --',CR,LF,00

cclo:	db	' -- Can''t Close Crossreference File --',CR,LF,00

enth:	ds	1		;search-again counter
sfam:	db	'DFilenameEXT',00
	ds	20

sqxx:	ds	2
sqaa:	ds	2
sqzz:	ds	2
text:	ds	2
texx:	ds	2
rest:	ds	2
rept:	ds	2
repp:	ds	2
lapo:	ds	2		;label pointer
kwdi:	db	'Keyword is:  '
keyr:	ds	64		;raw keyword
hesq:	db	'[original] : '
uzfn:	db	'original.xxx'	;unsqueezed file's name
crlf:	db	CR,LF,00
fhed:	db	'------> File '
fnam:	db	'xxxxxxxx.'	;filename
fext:	db	'xxx',CR,LF,00	;file extension
llbl:	db	'      +'
lnum:	db	'         ',00	;line number
lzer:	db	'   0'		;zero line for counter
ftot:	db	'      lines found',CR,LF,00
dtot:	db	'      instances in the entire disk',CR,LF,00
ktot:	db	'      keywords processed',CR,LF,00
	db	00		;fence for line buffer
lbuf:	ds	85H		;line buffer
dens:	ds	1		;z/nz = un/squeezed
roby:	ds	1		;rotating byte
roco:	ds	1		;rotation count
mult:	ds	1		;repeat factor
lach:	ds	1		;last character read
ictr:	ds	2		;input counter
iptr:	ds	2		;input pointer
ibuf:	ds	isiz		;input buffer
kfil:	ds	33		;keyword FCB
kctr:	ds	2		;keyword counter
kptr:	ds	2		;keyword pointer
kbuf:	ds	csiz		;keyword buffer
xfil:	ds	33		;.XRF FCB
xctr:	ds	2		;crossreference counter
xptr:	ds	2		;crossreference pointer
xbuf:	ds	csiz		;crossreference buffer
patt:	ds	256		;command line pattern
kwrd:	ds	256		;keyword pattern
code:	ds	4*hsiz		;Huffman code table

	ds	100		;stack area
stak:	ds	2		;initialize stack pointer
fini:	ds	0

	end

