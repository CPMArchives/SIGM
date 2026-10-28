
;	--------------------------------------------------------
;	DDT.COM is a part of the collection of programs which
;	one receives when buying CP/M from Digital Research. Of
;	all the programs in the CP/M package, it is one of the
;	weakest, and seems to have been mainly intended to use
;	to insert the custom part of BIOS into CP/M when it is
;	desired to generate a new system. Its strongest point is
;	its single step facility and its suppression during the
;	execution of BDOS. Its most frustrating point may be its
;	lack of transparency to the command line of programs to
;	which it is to be applied.
;
;	The present program was based on a disassembly of the
;	Digital Research version, which has now been very
;	extensively rearranged, even though vestiges of that
;	original program still remain. Several minor errors
;	have been corrected, but the important changes consist
;	in the greatly expanded capabilities of most of the
;	options, besides a complete replacement of both the
;	assembler and the disassembler. Many commands now admit
;	a repeat factor, examination of registers and memory is
;	much more extensive, and a bitmap can generated to mark
;	significant memory locations. Other modifications or
;	extensions may be deduced from the change log below.
;
;	Since DDT will be coresident with the program it will
;	examine, it is convenient to relocate it to high memory
;	and adjust the BDOS call to reflect less free space. If
;	an origin for the relocated DDT can be assigned, a small
;	translation program is included to move it once loaded.
;	It has been disabled by commenting it out. It would have
;	to be assembled by Microsoft's M80 or a similar assembler
;	allowing phasing and dephasing. It is much more general
;	to generate a bitmap for a page relocator, for which the
;	following script will serve as a guide. It assumes that
;	the utilities LOHD.COM, GENBIM.COM, and PAGREL.COM are
;	available; also that two separate copies of DDT were
;	prepared: NDDT at origin 100H, and ZDDT at origin 000H,
;	but otherwise identical.
;
;		A>ASM NDDT.AAZ
;		A>ASM ZDDT.AAZ
;		A>LOHD NDDT
;		A>LOHD ZDDT
;		A>GENBIM ZDDT NDDT
;		A>NDDT PAGREL		[NEXT = 180]
;		-IZDDT.COM
;		-R100			[NEXT = 1600]
;		-IZDDT.BIM
;		-R1500			[NEXT = 1900]
;		-S103
;		. 0103 BB 00
;		. 0104 BB 02
;		. 0105 EE 00
;		. 0106 EE 16
;		h 0107 68 .
;		-^C
;		A>SAVE 24 NDDT.COM
;
;		    NDDT.ASM -- Copyright (C) 1983
;		    Universidad Autonoma de Puebla
;			   20 November 1983
;
;	---------------: B generates a bitmap, L shows X's.
;	---------------: V is a T which ignores CALLs.
;	24 October 1982: R sets 007C to zero before starting.
;	24 October 1982: I will read an entire command line.
;	06 November 1982 - preliminary circulation copies.
;	12 December 1982 - XA shows both HEX, ASCII values.
;	12 December 1982 - X confirms register changes.
;	13 December 1982 - 007C zeroed while opening file.
;	13 December 1982 - I <pop h> when leaving HEX option.
;	13 December 1982 - <no extension> taken as .COM
;	13 December 1982 - P "Peek" added.
;	16 December 1982 - E "Execute" added.
;	18 December 1982 - S accepts quoted character.
;	20 December 1982 - edition for Assembler II.
;	7 August 1983 - correct overwrite of b in G.
;	7 August 1983 - zero 7C after initial program load.
;	20 August 1983 - clear memory before loading.
;	20 August 1983 - decimal prefix to all commands.
;	22 August 1983 - new format for display line.
;	22 August 1983 - En,xxxx superseded by nG,xxxx.
;	23 August 1983 - nV/, nT/, nU/ suppress display lines.
;	23 August 1983 - X=xxxx displays a window around xxxx.
;	23 August 1983 - nU superseded by nT/.
;	23 August 1983 - P incorporated into X.
;	26 August 1983 - M moves overlapping interval backwards.
;	26 August 1983 - A does not leave 3 0D's on exit.
;	28 August 1983 - General rearrangement and revision.
;	30 August 1983 - Edition for Languages II.
;	20 November 1983 - X - jz for jnz refused flag changes.
;	20 November 1983 - ASM - assembly of RST N was wrong.
;	20 November 1983 - stor - xra a to avoid false signals.
;	[Harold V. McIntosh, 20 December 1982]
;	[Harold V. McIntosh, 30 August 1983]
;	--------------------------------------------------------

HT	equ	09H	;tab
LF	equ	0AH	;line feed
CR	equ	0DH	;carriage return
KZ	equ	1AH	;^Z
RO	equ	7FH	;rubout

;ddtorg	equ	09000H	;absolute DDT origin
;
;
;;	Move DDT up to higher memory.
;
;X0100:	lxi	b,enddt-begn
;X013D:	lxi	sp,begn
;	lxi	d,ddtorg
;	lxi	h,X0165
;X0158:	mov	a,b
;	ora	c
;	jz	ddtorg
;	dcx	b
;	mov	a,m
;	stax	d
;	inx	d
;	inx	h
;	jmp	X0158
;X0165:	ds	0
;
;;	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	.phase	ddtorg

	org	0100H

begn:	jmp	init	;initialize DDT

;	========================================================
;	Assembler for the INTEL 8080.  As a "small" assembler,
;	it is subject to the following restraints:
;		1) only hexadecimal numbers are accepted
;		2) opcode identification is merely sufficient
;		3) source code is not confined to a single line
;		4) error detection only for an unintelligible
;		   opcode or field; then three zero bytes are
;		   deposited to allow patches, assembler line
;		   is abandoned
;		5) implausible combinations are not rejected
;
;	Register pair HL points to the byte in which the
;	assembled opcode will be stored.  If necessary, hex
;	data or address fields will be read and HL will be
;	incremented by 1, 2, or 3 as required.  Flags are valid
;	on return; zero means no error.
;
;	No RAM memory is used directly by the program, so that
;	it may be inscribed in its entirity in a PROM.  All its
;	requirements for temporary storage are met from the
;	internal registers of the 8080 or the stack.
;	========================================================

assm:	push	h
	lxi	h,stor
	push	h
	call	alfa
	jmp	aopco

;	Read an alpha field by ignoring leading separators,
;	storing letters in registers C,D,E, and terminating
;	reading when a separator is again encountered.  All
;	fields are held to three letters, so that the only
;	letters in a chain that are stored are the first,
;	second, and last.

alfa:	lxi	d,'  '
ala:	call	relc
	call	sepa
	jz	ala
	mov	c,a
	call	relc
	call	sepa
	rz
	call	term
	rz
	mov	d,a
alb:	call	relc
	call	sepa
	rz
	call	term
	rz
	mov	e,a
	jmp	alb

;	Read an alpha field with the intention of keeping only
;	the last letter in the field.  Otherwise the same rules
;	apply as in the subroutine alfa: leading separators are
;	ignored, trailing separators terminate.

beta:	call	relc
	call	sepa
	jz	beta
bet:	mov	b,a
	call	relc
	call	sepa
	jz	bta
	call	term
	jnz	bet
bta:	mov	a,b
	ret

;	Locate the operation codes.  A simple linear search is
;	made of some sixty mnemonics, grouping them mostly in
;	sets of eight because their position within an octet
;	translates directly into a source or destination field
;	in the 2-3-3 decomposition of INTEL 8080 opcodes.

aopco:	mvi	b,0CH
	lxi	H,AT4	;Quadrant 0 with minor modifications
	call	mnem
	jp	AQ0
	mvi	b,01H
	lxi	h,AT0	;Quadrant 1: interregister movements
	call	mnem
	jp	AQ1
	mvi	b,08H
	lxi	h,AT1	;Quadrant 3: arithmetic-logical
	call	mnem
	jp	AQ2
	mvi	b,08H
	lxi	h,AT2	;Quadrant 2, column 6: immediate
	call	mnem
	jp	AB6
	mvi	b,11H
	lxi	h,AT5	;All the sporadic opcodes
	call	mnem
	jp	qq
	mvi	b,08H
	lxi	h,AT3	;Quadrant 0, column 7: accumulator
	call	mnem
	jp	AA7
	mov	a,c
	cpi	'r'
	jz	AB0	;Quadrant 3, column 0: returns
	cpi	'j'
	jz	AB2	;Quadrant 3, column 2: jumps
	cpi	'c'
	jz	AB4	;Quadrant 3, column 4: calls
	mvi	b,05H
	lxi	h,AT7	;Assembler directives
	call	mnem
	jp	QD
	jmp	hexb

;	Quadrant zero - memory to register - and some others.

AQ0:	mov	c,a
	call	juta
	dw	X0	;pop  pair
	dw	AA1	;lxi  pair,addr
	dw	AA0	;stax pair  - beware - only b, d legal
	dw	AA0	;inx  pair
	dw	AA4	;inr  register
	dw	AA4	;dcr  register
	dw	AA6	;mvi  register,data
	dw	AB7	;rst  digit in opcode
	dw	Y0	;push pair
	dw	AA0	;dad  pair
	dw	AA0	;ldax pair  - beware - only b, d legal
	dw	AA0	;dcx  pair

X0:	mvi	c,0C1H
	jmp	AA0
Y0:	mvi	c,0C5H
AA0:	call	beta
	call	apair
	ora	c
	ret

AA1:	call	AA0
	jmp	addq

AA4:	call	rdst
	ora	c
	ret

AA6:	call	AA4
	jmp	datq

AA7:	add	a
	add	a
	add	a
	ori	07H
	ret

AQ1:	call	rdst
	mov	c,a
	call	rsrc
	ora	c
	ori	040H
	ret

AQ2:	add	a
	add	a
	add	a
	mov	c,a
	call	rsrc
	ora	c
	ori	080H
	ret

qq:	cpi	09H
	jc	ss
	lxi	h,adata
	cpi	0BH
	jc	rr
	lxi	h,aaddr
rr:	xthl
ss:	lxi	h,AT8
	jmp	reta

;	Quadrant 3 - mostly program counter modification

AB0:	mvi	a,0C0H
	jmp	abb
AB2:	mvi	a,0C2H
	call	abb
	jmp	addq
AB4:	mvi	a,0C4H
	call	abb
	jmp	addq
abb:	push	psw
	mvi	c,' '
	mvi	b,08H
	lxi	h,AT6
	call	mnem
	pop	b
	jm	error
	add	a
	add	a
	add	a
	ora	b
	ret

;	Immediates.

AB6:	add	a
	add	a
	add	a
	ori	0C6H
	jmp	datq

;	Restarts.

AB7:	call	beta
	rlc
	rlc
	rlc
	ani	038H
	ori	0C7H
	ret

;	Assembler directives.

QD:	call	juta
	dw	D0	;data byte
	dw	D1	;data word
	dw	D2	;data space
	dw	D3	;origin
	dw	D4	;end

D0:	inx	sp	;data byte
	inx	sp
	pop	d
	call	hxar
	mov	l,a
	mvi	a,0FDH	;error
	rnz
	inr	a	;(org)
	xchg
	mov	m,e
	inx	h
	ret

D1:	inx	sp	;data word
	inx	sp
	pop	d
	call	hexf
	mvi	a,0FDH	;error
	rnc
	inr	a	;(org)
	xchg
	mov	m,e
	inx	h
	mov	m,d
	inx	h
	ret

D2:	inx	sp	;data space
	inx	sp
	pop	d
	call	hexf
	mvi	a,0FDH	;error
	rnc
	inr	a	;org
	dad	d
	ret

D3:	inx	sp	;origin
	inx	sp
	inx	sp
	inx	sp
	call	hexf
	mvi	a,0FEH	;org
	rc
	dcr	a
	ret

D4:	inx	sp	;end
	inx	sp
	inx	sp
	inx	sp
	mvi	a,0FFH	;done
	ret

;	If the operation field did not hold a valid opcode or
;	assembler directive, try it out for a one-byte, two
;	nibble hexadecimal byte.

hexb:	lxi	h,error
	push	h
	mov	a,e
	cpi	' '
	rz
	mov	a,c
	call	cnh
	rc
	add	a
	add	a
	add	a
	add	a
	mov	b,a
	mov	a,d
	call	cnh
	rc
	add	b
	inx	sp
	inx	sp
	ret

;	Read and deposit a hexadecimal address field.

addq:	inx	sp
	inx	sp
aaddr:	mov	b,a
	call	onar
	xchg
	pop	h
	mov	m,b
	inx	h
	mov	m,e
	inx	h
	mov	m,d
	inx	h
	ret

;	Read and deposit a one-byte hexadecimal data field.

datq:	inx	sp
	inx	sp
adata:	mov	b,a
	call	hxar
	jnz	error	;<missing field>
	xchg
	pop	h
	mov	m,b
	inx	h
	mov	m,e
	inx	h
	ret

;	Deposit the assembled operation code

stor:	pop	h
	mov	m,a
	inx	h
	xra	a	;don't return the wrong signal
	ret

;	Load accumulator with nth item in the list whose
;	origin is contained in register pair HL, when n
;	lies in the accumulator.

reta:	add	l
	mov	l,a
	mov	a,h
	aci	00H
	mov	h,a
	mov	a,m
	ret

;	Find numerical equivalents for register designations.
;	Source registers are reported at their true value, but
;	destination registers are multiplied by eight to have
;	their value positioned correctly for its field.

rsrc:	call	beta
srce:	mvi	b,08H
	lxi	h,atr
	call	regi
	jm	error
	ret

rdst:	call	beta
dest:	call	srce
	add	a
	add	a
	add	a
	ret

;	Find numerical equivalents for register pair symbols.
;	They always left-pack their destination field.

apair:	mvi	b,05H
	lxi	h,atp
	call	regi
	jm	error
	cpi	04H
	cmc
	sbi	00H
	mov	b,a
	add	a
	add	a
	add	a
	add	a
	ret

;	Search a list of bytes whose origin is contained in
;	in HL to find the one, if any, which matches the
;	accumulator.  The length of the list in is B on entry;
;	on exit A contains either the position or FF if no
;	match was found.

regi:	dcx	h
	cmp	m
	jz	reg
	dcr	b
	jnz	regi
reg:	xra	a
	dcr	b
	ora	b
	ret

;	Search a table of three-letter mnemonics to find the
;	code contained in registers C,D,E.  Enter with the
;	table origin in pair HL, the table size N in the
;	accumulator.  On exit the accumulator will contain
;	either the position, ranging between 0 and N-1, of
;	the item in the table, or else FF(hex) if it was not
;	found.

mnem:	dcx	h
	mov	a,m
	cmp	e
	jnz	mnb
	dcx	h
	mov	a,m
	cmp	d
	jnz	mnc
	dcx	h
	mov	a,m
	sub	c
	jnz	mnd
mna:	dcr	b
	ora	b
	ret
mnb:	dcx	h
mnc:	dcx	h
mnd:	dcr	b
	jnz	mnem
	jmp	mna

;	Table of mnemonics grouped by octets and dodecuplets.

dtr:	db	'bcdehlma'
atr:	db	'bdhpw'
atp:	db	'mov'
AT0:	db	'add','adc','sub','sbb'
	db	'ana','xra','ora','cmp'
AT1:	db	'adi','aci','sui','sbi'
	db	'ani','xri','ori','cpi'
AT2:	db	'rlc','rrc','ral','rar'
	db	'daa','cma','stc','cmc'
AT3:	db	'pop','lxi','stx','inx'
	db	'inr','dcr','mvi','rst'
	db	'puh','dad','ldx','dcx'
AT4:	db	'nop','ret','pcl','spl'
	db	'xtl','xcg','di ','ei '
	db	'hlt','out','in ','jmp'
	db	'cal','shd','lhd','sta','lda'
AT5:	db	' nz',' z ',' nc',' c '
	db	' po',' pe',' p ',' m '
AT6:	db	'db ','dw ','ds ','org','end'
AT7:	db	nop
	db	ret
	db	pchl
	db	sphl
	db	xthl
	db	xchg
	db	di
	db	ei
	db	hlt
	db	0D3H	;(out)
	db	0DBH	;(in)
	db	0C3H	;(jmp)
	db	0CDH	;(call)
	db	022H	;(shld)
	db	02AH	;(lhld)
	db	032H	;(sta)
	db	03AH	;(lda)

;	T7 is the end of one table, T8 is the beginning of another.

AT8	equ	AT7


;	=====================================================
;	Disassembler for the INTEL 8080.  Register pair HL
;	points to the byte to be disassembled.  HL will be
;	incremented by 1, 2, or 3 according to the type of
;	instruction encountered.  No RAM storage is used
;	within the program, which may therefore be entirely
;	resident in ROM.
;	=====================================================

dism:	mov	a,m
	push	h
	lxi	h,done
	push	h
	cpi	76H
	jnz	split
halt:	lxi	h,td
	jmp	three

;	separate the instruction field into groups of 2,3,3
;	bits and then continue according to quadrants.

split:	push	psw
	push	psw
	ani	07H
	mov	c,a
	pop	psw
	rrc
	rrc
	rrc
	ani	07H
	mov	b,a
	pop	psw
	rlc
	rlc
	ani	03H
	lxi	h,jq
jump:	call	bndx
	mov	e,m
	inx	h
	mov	d,m
	xchg
	pchl

;	Indexing subroutines which add corresponding multiples
;	[3,4,2,1] of A to the register pair HL.

tndx:	mov	e,a
	add	a
	add	e
	jmp	indx
qndx:	add	a
bndx:	add	a
indx:	add	l
	mov	l,a
	mov	a,h
	aci	00H
	mov	h,a
	ret

;	-------------------------------------------------------
;	Quadrant 0 contains accumulator operations, increments,
;	decrements, loads, stores and immediate moves, all of
;	which must be detailled further.
;	-------------------------------------------------------

DQ0:	mov	a,c
	lxi	h,ja
	jmp	jump

;	Column 0 contains NOP together with seven unused codes

DA0:	mov	a,b
	ora	a
	jnz	node
noop:	lxi	h,tc
	jmp	trey

;	Column 1 alternates lxi to a register pair with dad
;	from a register pair.  The lxi's require data words,
;	but not the dad's.

DA1:	mov	a,b
	ani	01H
	call	aa
	mov	a,b
	ani	01H
	rnz
	call	sngl
	jmp	daddr

;	Column 2 alternates storing and loading instructions.
;	The first six refer to register pairs, the last two to
;	the accumulator; the last four require addresses.

DA2:	mov	a,b
	lxi	h,DT5
	call	vier
	mov	a,b
	ani	04H
	jz	putp
	jmp	daddr

;	Column 3 alternates inx of a register pair with dcx of
;	the same pair.

DA3:	mov	a,b
	ani	01H
	adi	02H
aa:	lxi	h,DT4
	call	drei
	jmp	putp

;	Column 4 contains inr, 5 containd dcr, both modified
;	by the register list.

DA4:	mov	a,c
	lxi	h,DT4
	call	drei
	mov	a,b
	lxi	h,dtr
	jmp	ein

;	Column 6 contains the mvi's, which require a data byte.

DA6:	call	DA4
	call	sngl
	jmp	ddata

;	Column 7 contains the accumulator operations.

DA7:	mov	a,b
	lxi	h,AT2
	call	tndx
	jmp	trey

;	----------------------------------------------------------
;	Quadrant 1 consists of interregister movements.
;	----------------------------------------------------------

DQ1:	lxi	h,tb
	call	three
	mov	a,b
	lxi	h,dtr
	call	ein
	call	sngl
	mov	a,c
	lxi	h,dtr
	jmp	ein

;	----------------------------------------------------------
;	Quadrant 2 consists of arithmetic operations
;	----------------------------------------------------------

DQ2:	mov	a,b
	lxi	h,AT0
	call	drei
	mov	a,c
	lxi	h,dtr
	jmp	ein

;	---------------------------------------------------------
;	Quadrant 3 has returns, calls, jumps, pushes, pops,
;	and a variety of miscellania needing a detailed study.
;	---------------------------------------------------------

DQ3:	mov	a,c
	lxi	h,jb
	jmp	jump

;	Column 0 contains all the conditional returns

DB0:	mvi	a,'r'
bb:	call	aout	;A to console
	mov	a,b
	lxi	h,AT5
	call	tndx
	inx	h
	jmp	two

;	Column 1 contains the pops, together with the unconditional
;	return, pchl, sphl, and an undefined code.

DB1:	mov	a,b
	lxi	h,DT7
	call	vier
	mov	a,b
	cpi	03H
	jz	dopco
	ani	01H
	rnz
	jmp	putq

;	Column 2 contains all the conditional jumps.

DB2:	mvi	a,'j'
	call	bb
	jmp	daddr

;	Columnn 3 is an assortment, requiring many distinctions.

DB3:	mov	a,b
	lxi	h,DT8
	call	vier
	mov	a,b
	cpi	04H
	rnc
	cpi	01H
	jz	dopco
	jc	daddr
	jmp	ddata

;	Column 4 contains all the conditional calls.

DB4:	mvi	a,'c'
	call	bb
	jmp	daddr

;	Column 5 contains the pushes, simple call, 3 undefined.

DB5:	mov	a,b
	ani	01H
	jnz	xx
	lxi	h,tf
	call	four
	jmp	putq
xx:	mov	a,b
	cpi	01H
	jnz	node
	lxi	h,te
	call	four
	jmp	daddr

;	Column 6 holds all the arithmetic immediates.

DB6:	mov	a,b
	lxi	h,AT1
	call	drei
	jmp	ddata

;	Column 7 contains all the restarts.

DB7:	lxi	h,DT4+21
	call	three
	mov	a,b
	adi	'0'
	jmp	aout	;A to console

;	------------------------------------------------------
;	a collection of copying and spacing routines.
;	------------------------------------------------------

vier:	call	qndx
	jmp	four
drei:	call	tndx
	jmp	three
ein:	call	indx
	jmp	one

four:	call	quad
	jmp	sngl
three:	call	trey
	jmp	dubl
two:	call	dpair
	jmp	dubl

quad:	mov	a,m
	call	aout	;A to console
	inx	h
trey:	mov	a,m
	call	aout	;A to console
	inx	h
dpair:	mov	a,m
	call	aout	;A to console
	inx	h
one:	mov	a,m
	jmp	aout	;A to console

;	-------------------------------------------------------
;	Commonly used transferrence and conversion routines.
;	-------------------------------------------------------

putp:	mov	a,b
	ani	06H
	lxi	h,dtp
	call	indx
	jmp	dpair

putq:	mov	a,b
	ani	06H
	rrc
	lxi	h,tq
	call	tndx
	jmp	trey

done:	pop	h
	inx	h
	ret

daddr:	inx	sp
	inx	sp
	pop	h
	inx	h
	mov	e,m
	inx	h
	mov	d,m
	push	h
	call	word
	jmp	done

node:	lxi	h,ta
	call	three
dopco:	inx	sp
	inx	sp
	pop	h
	jmp	goby

ddata:	inx	sp
	inx	sp
	pop	h
	inx	h
goby:	mov	a,m
	push	h
	call	byte
	jmp	done

;	--------------------------------------------------------
;	Jump tables
;	--------------------------------------------------------

jq:	dw	DQ0,DQ1,DQ2,DQ3

ja:	dw	DA0,DA1,DA2,DA3,DA4,DA4,DA6,DA7

jb:	dw	DB0,DB1,DB2,DB3,DB4,DB5,DB6,DB7

;	--------------------------------------------------------
;	Tables of mnemonics for the 8080 instructions
;	--------------------------------------------------------

ta:	db	'db '
tb:	db	'mov'
tc:	db	'nop'
td:	db	'hlt'
te:	db	'call'
tf:	db	'push'

dtp:	db	'b d h sp'

tq:	db	'b  '
	db	'd  '
	db	'h  '
	db	'psw'

DT4:	db	'lxi','dad','inx','dcx'
	db	'inr','dcr','mvi','rst'

DT5:	db	'stax','ldax','stax','ldax'
	db	'shld','lhld','sta ','lda '

DT7:	db	'pop ','ret ','pop ','db  '
	db	'pop ','pchl','pop ','sphl'

DT8:	db	'jmp ','db  ','out ','in  '
	db	'xthl','xchg','di  ','ei  '

;	-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

DP	equ	16	;paragraph length for D
NL	equ	12	;default lines in L
NR	equ	12	;number of registers to examine in X
WW	equ	5	;window halfwidth in register display

BDOS	equ	0005H	;jump to BDOS
RST7	equ	0038H	;DDT breakpoint handler
TFCB	equ	005CH	;DDT's file control block
TBUF	equ	0080H	;DDT's sector buffer
TORG	equ	0100H	;program origin

bsiz	equ	2000H	;8K = size of bitmap

XDOS:	xthl		;<<DDT analogue of 0005>>
	shld	sica	;site of call to BDOS
	xthl
GDOS:	jmp	0000	;BDOS address

;	Initialize DDT

init:	lhld	BDOS+1
	shld	GDOS+1		;BDOS address
	lxi	h,XDOS		;DDT analogue of 0005
	shld	begn+1
	lxi	h,begn
	shld	BDOS+1
	xra	a
	sta	bkpt		;breakpoint data
	lxi	h,TORG		;CP/M transient origin
	shld	lorg		;origin for L
	shld	dorg		;origin for D
	shld	pmax		;program high limit
	shld	savpc		;PC at breakpoint
	shld	savmr		;memory reference
	lxi	sp,savhl	;breakpoint
	push	h
	lxi	h,0002
	push	h
	dcx	h
	dcx	h
	shld	savhl		;HL at breakpoint
	push	h
	push	h
	mvi	a,0C3H		;(jmp)
	sta	RST7		;RST 7 destination
	lxi	h,rtbk		;return from breakpoint
	shld	RST7+1
	lxi	b,begn		;top of memory
	lxi	h,TORG		;bottom of memory
	mov	a,c
	sub	l
	mov	c,a
	mov	a,b
	sbb	h
	mov	b,a
zero:	mov	a,c
	ora	b
	jz	zerd
	mvi	m,00
	inx	h
	dcx	b
	jmp	zero
zerd:	lxi	h,logo		;"DDT/UAP"
	call	mssg
	mvi	c,25		;(19) read logged in disk
	call	XDOS
	sta	ldsk		;logged disk
	mvi	b,80H
	lxi	d,TBUF
	lxi	h,ctex
	shld	cptr		;pointer to command buffer
	lxi	h,clen
muve:	ldax	d
	mov	m,a
	inx	h
	inx	d
	dcr	b
	jnz	muve
	mov	m,b
	lxi	h,loop		;DDT loop
	push	h
	lda	TFCB+1		;file name
	cpi	' '
	rz
	lxi	h,TFCB+9	;extension
	mov	a,m
	cpi	' '
	jnz	scom
	mvi	m,'C'
	inx	h
	mvi	m,'O'
	inx	h
	mvi	m,'M'
scom:	lxi	h,0000		;zero offset
	call	opra		;R with implicit argument
	jmp	opia		;I after discarding program name

;	----------------------------------------------
;	DDT loop: waits for commands and executes them
;	----------------------------------------------

loop:	lxi	sp,savde	;DDT's private stack
	lxi	h,loop		;DDT loop
	push	h
	call	past		;check limit transgression
	jc	looq
	lxi	h,XDOS		;link to BDOS
	shld	0006H
looq:	call	crlf		;type CR,LF
	mvi	a,'-'
	call	aout		;A to console
	call	incl		;fetch a command line
	call	decf		;read decimal field
	cpi	CR
	rz
	shld	rept
	call	alta		;alternate table
	db	14
	db	'A'
	dw	opta		;A = assemble
	db	'B'
	dw	bmap		;B = bitmap
	db	'D'
	dw	optd		;D = display
	db	'F'
	dw	optf		;F = fill
	db	'G'
	dw	optg		;G = go
	db	'H'
	dw	opth		;H = hex sum, difference
	db	'I'
	dw	opti		;I = initialize CCP command line
	db	'L'
	dw	optl		;L = list program
	db	'M'
	dw	optm		;M = move
	db	'R'
	dw	optr		;R = read file
	db	'S'
	dw	opts		;S = store
	db	'T'
	dw	optt		;T = type registers
	db	'V'
	dw	optv		;V = single step w/ call as 1 step
	db	'X'
	dw	optx		;X = examine registers

;	(A) Assemble 8080 code. <nAx> will assemble n lines
;	of code beginning at address x. Defaults are x=lorg,
;	while no limit is set if n is missing or zero.

opta:	call	past	;check limit transgression
	jnc	error	;<A has been overwritten>
	lhld	lorg	;origin for L
	call	hef
opaa:	shld	lorg	;origin for L
	call	dubl
	call	tyhl	;type HL as four nibbles
	call	dubl
	call	incl	;fetch a command line
	jz	opac
	call	assm
	inr	a	;FF means done
	rz
	inr	a	;FE means new origin
	jnz	opab
	call	crlf
	jmp	opaa
opab:	call	ctlx
	lhld	lorg	;origin for L
	inr	a	;FD means error - retry
	jz	opaa
opac:	call	dubl	;otherwise confirm & advance
	call	tyhl	;type HL as four nibbles
	call	dubl
	call	dism
	call	crlf
	call	drnz	;decrement retn if nonzero
	jnz	opaa
	shld	lorg	;origin for L
	ret

;	(B)  Generate a bitmap of all bytes in the range
;	100H - (pmax) which could possibly be the address
;	of an instruction.

bmap:	lhld	pmax
	xchg
	lxi	h,begn
	lxi	b,-bsiz
	dad	b
	mov	a,l
	sub	e
	mov	a,h
	sbb	d
	jc	error	;<bitmap would overlap program>
	lxi	b,bsiz
bzer:	mvi	m,00H
	inx	h
	dcx	b
	mov	a,c
	ora	b
	jnz	bzer
	lhld	pmax	;program high limit
	xchg
	lxi	h,TORG	;CP/M transient origin
	mov	a,e
	sub	l
	mov	c,a
	mov	a,d
	sbb	h
	mov	b,a
bbit:	push	b
	mov	a,m
	call	twob
	jnc	bbjt
	push	h
	inx	h
	mov	e,m
	inx	h
	mov	d,m
	xchg
	call	wrib
	pop	h
bbjt:	inx	h
	pop	b
	dcx	b
	mov	a,c
	ora	b
	jnz	bbit
	ret

;	Decide if opcode has one-byte sequel.

oneb:	cpi	0D3H
	jz	oney
	cpi	0DBH
	jz	oney
	ani	0C7H
	cpi	006H
	jz	oney
	cpi	0C6H
	jz	oney
	stc
	cmc
	ret
oney:	stc
	ret

;	decide if opcode has two-byte address

twob:	push	b
	cpi	0C3H
	jz	twoy
	cpi	0CDH
	jz	twoy
	mov	b,a
	ani	0C7H
	cpi	0C2H
	jz	twoy
	cpi	0C4H
	jz	twoy
	mov	a,b
	ani	0CFH
	cpi	001H
	jz	twoy
	mov	a,b
	ani	0E7H
	cpi	022H
	jz	twoy
	stc
	cmc
	pop	b
	ret
twoy:	stc
	pop	b
	ret

;	read bit corresponding to address HL

reab:	push	h
	call	biby	;addr = byte + bit
	mov	a,m
rea:	rrc
	dcr	c
	jnz	rea
	pop	h
	ret

;	define bit corresponding to address HL

wrib:	push	psw
	call	biby	;addr = byte + bit
	push	b
	mov	a,m
wra:	rrc
	dcr	c
	jnz	wra
	mov	m,a
	pop	b
	pop	psw
	mov	a,m
	ral
	rrc
wrb:	rlc
	dcr	c
	jnz	wrb
	mov	m,a
	ret

;	reduce an address to byte (HL), bit (C).

biby:	mov	a,l
	ani	07H
	inr	a
	mov	c,a
	mvi	b,3
bib:	mov	a,h
	rar
	mov	h,a
	mov	a,l
	rar
	mov	l,a
	dcr	b
	jnz	bib
	mov	a,h
	ani	1FH
	mov	h,a
	lxi	d,begn
	dad	d
	lxi	d,-bsiz
	dad	d
	ret

;	(D) Display the memory in groups of 16 bytes, both as
;	pairs of hexadecimal nibbles and as ASCII characters,
;	when the latter is appropriate. The command <nDa,b>
;	will display n lines, or else the interval between
;	hexadecimal addresses a and b; the interval takes
;	precedence but if a or b or both are null, the line
;	count helps determine the interval. When a is null the
;	display will usually continue from where it last ended,
;	but nD,b will display b-n up to b. In general:
;		nDa,b	a through b-1, n lines of 16 bytes
;		 Da,b   a through b-1, DP lines of 16 bytes
;		nDa,	a through a+n
;		nD,b	b-n through b
;		nD,	PC through PC+n
;		 Da,    a to the end
;		 Da	just line containing a
;		 D,b	PC through b
;		 D,	PC to the end
;		 D	just line beginning at PC

optd:	lxi	h,pinc	;paragraph length
	mvi	m,DP
	lhld	rept
	mov	a,l
	ora	h
	sui	1
	sbb	a
	ani	01H
	mov	b,a	;1 means n=0
	dad	h
	dad	h
	dad	h
	dad	h
	shld	rept	;1 line is worth 16 bytes
	lhld	dorg	;default <a> is dorg
	call	hef	;read <a>
	mov	c,a
	mov	a,b
	ral
	mov	b,a	;0 means null <a>
	xchg
	lhld	rept
	dad	d	;<a+n> is default <b>
	mov	a,c
	sui	CR
	jz	opda
	lxi	h,0FFF0H
opda:	sui	1
	mov	c,a	;FF means CR
	mov	a,b
	ral
	mov	b,a	;1 means CR
	call	hef	;read <b>
	mov	a,b
	ral
	mov	b,a
	inr	c
	jnz	opdb	;z means CR
	lhld	rept
	dad	d
opdb:	shld	dorg

;	At this point, DE=<a>, HL=<b>, B defines case,
;	but a few anomalies still have to be resolved.

	mov	a,b
	cpi	01H
	jnz	opdc
	lhld	dorg
	xchg
	lhld	rept
	mov	a,e
	sub	l
	mov	l,a
	mov	a,d
	sbb	h
	mov	h,a
	xchg		;else a=b-n
opdc:	cpi	05H
	jz	opdd
	cpi	04H
	jz	opdd
	cpi	00H
	jnz	opde
opdd:	lhld	rept
	dad	h
	dad	h
	dad	h
	dad	h
	mov	a,h
	sta	pinc	;paragraph length

;	The parameters are now ready to start typing.

opde:	lhld	dorg
	xchg
	mov	a,e
	sub	l
	mov	a,d
	sbb	h
	jc	error	;<inverted interval>
	lda	pinc	;paragraph length
	mov	b,a
opdf:	call	crlf	;type CR,LF
	call	inst	;read console status
	jz	opdg
	shld	dorg	;mark stopping point
	ret
opdg:	call	tyhl	;type HL as four nibbles
	push	h
	call	dubl
	call	hebl
	call	sngl	;type space
	pop	h
	mvi	c,10H
	call	ascl
	dcr	b
	jnz	opdh
	lda	pinc	;paragraph length
	mov	b,a
	call	crlf
opdh:	mov	a,l
	sub	e
	mov	a,h
	sbb	d
	jc	opdf
	ret

hebl:	call	oobl
oobl:	call	fobl
fobl:	call	tetr
	jmp	sngl

tetr:	call	duce
duce:	call	once
once:	mov	a,m
	call	byte
	inx	h
	jmp	sngl

;	(F) Fill an interval. <Fx,y,a> will fill the interval
;	from x to y with the hexadecimal value a.

optf:	call	onar
	push	h
	call	onar
	xchg
	call	hxar
	jnz	error	;<nonstandard argument>
	mov	b,a
	pop	h
opfa:	mov	a,l	;cmp(HL,DE)
	sub	e
	mov	a,h
	sbb	d
	rnc
	mov	m,b
	inx	h
	jmp	opfa

;	(G)  Go to the program for execution. The form <nG,a,b,c>
;	allows the insertion of up to two breakpoints, b and c,
;	before jumping to the address a. If a count n is also
;	included, the breakpoints will be traversed n times
;	before control is t returned to DDT. If the field a is
;	null, the program will continue from the point where
;	control was surrendered to DDT (or 100H if it is an
;	initial call.

optg:	call	crlf	;type CR,LF
	xra	a
	sta	swtv	;T/V = z/nz
	sta	swgt	;G/T = z/nz
	lhld	rept
	dad	h
	shld	rept
	lhld	savpc	;PC at breakpoint
	call	hef	;fetch a
	shld	savpc
	push	h
	cpi	CR
	mvi	a,1
	jz	opga
	call	hexf	;fetch b
	jnc	gnex
	shld	gbrk	;nG's breakpoint
	xchg
	call	hexf	;fetch c
	mvi	a,2
	jnc	opga
	shld	gbrl
	inr	a
	mov	b,h
	mov	c,l
opga:	pop	h
	sta	gbrn
	ora	a
	jmp	gprg	;G without arguments

;	G without arguments
;		z    unconditional go (savsp)
;		c    ignore HL, but set breakpoints
;		A    number of arguments - 0,1,2,3
;		HL   explicit destination
;		DE   first breakpoint
;		BC   second breakpoint

gnex:	call	step
gprg:	di
	jz	gnez	;no arg, unconditional go
	jc	gney	;comma, set breakpoint & go
	shld	savpc	;PC at breakpoint
gney:	dcr	a
	sta	bkpt
	jz	gnez	;one arg already noted
	xchg
	mov	e,a
	mov	a,m
	sta	brkx
	mvi	m,0FFH	;RST 7
	shld	brkp
	dcr	e
	jz	gnez	;unless 2nd breakpoint
	mov	l,c
	mov	h,b
	mov	a,m
	sta	brky
	mvi	m,0FFH	;RST 7
	shld	brkq

;	Restore registers and return to program.

gnez:	lxi	sp,savde	;DDT's private stack
	pop	d
	pop	b
	pop	psw
	pop	h
	sphl
	lhld	savpc	;PC at breakpoint
	push	h
	lhld	savhl	;HL at breakpoint
	NOP	
	ret	

;	(H) Display a hexadecimal sum and difference. <Hx,y>
;	will result in typing '+'x+y '-'x-y. Mainly used to
;	help patch CP/M during system generation.

opth:	call	onar
	xchg
	call	onar
	xra	a
	sub	l
	mov	c,a
	sbb	h
	sub	c
	mov	b,a
	call	crlf	;type CR,LF
	dad	d
	mvi	a,'s'	;"sum"
	call	aout
	call	tyhl	;type HL as four nibbles
	call	sngl	;type space
	xchg
	dad	b
	mvi	a,'d'	;"difference"
	call	aout
	jmp	tyhl	;type HL as four nibbles

;	(I) Input a command line, according to the same
;	criteria used by CCP; in other words a parameter
;	list can follow the file name.

opia:	call	fico
opti:	lxi	d,TBUF
	lhld	cptr	;pointer to command buffer
	lda	clen
	mov	b,a
	inr	b
moov:	stax	d
	mov	a,m
	call	lcfo
	inx	d
	inx	h
	dcr	b
	jnz	moov
	mvi	a,00
	stax	d
	lxi	h,TBUF+1
	shld	cptr	;pointer to command buffer
	call	fico
	lxi	h,adsk	;active disk
	push	h
	mov	a,m
	sta	TFCB	;CP/M default FCB
	mvi	a,10H
	call	fica
	pop	h
	mov	a,m
	sta	TFCB+16
	xra	a
	sta	TFCB+32
	jmp	crlf

zsep:	ora	a
	rz
	cpi	CR
	rz
	cpi	' '
	jc	error	;<control chars in command line>
	rz
	cpi	'='
	rz
	cpi	'_'
	rz
	cpi	'.'
	rz
	cpi	':'
	rz
	cpi	';'
	rz
	cpi	'<'
	rz
	cpi	'>'
	ret

fsep:	call	zsep
	rz
	call	rech	;read one character
	jmp	fsep
	ret

;	Advance to a non blank character in the console
;	buffer unless there is none, indicated by a 00.

zonb:	call	rech	;read one character
	ora	a
	rz
	cpi	' '
	jz	zonb	;zero or non-blank
	ret

;	Generate a file control block in the manner of CCP.

fico:	mvi	a,00
fica:	lxi	h,TFCB
	add	l
	mov	l,a
	mov	a,h
	aci	00
	mov	h,a
	xra	a
	sta	adsk	;active disk
	call	zonb	;zero or non-blank
	push	psw
	jz	ficb
	sbi	'@'
	mov	b,a
	push	h
	lhld	cptr	;pointer to command buffer
	mov	a,m
	pop	h
	cpi	':'
	jz	ficc
ficb:	lda	ldsk	;logged disk
	jmp	ficd
ficc:	call	rech	;read one character
	pop	psw
	call	rech	;read one character
	push	psw
	mov	a,b
	sta	adsk	;active disk
ficd:	mov	m,a
	inx	h
	mvi	b,08
	pop	psw
	call	ffil
	call	fsep
	mvi	b,03
	cpi	'.'
	jnz	ficp
	call	rech	;read one character
	call	ffil
	call	fsep
	jmp	ficq
ficp:	call	bfil
ficq:	mvi	b,03
	mvi	c,00
	jmp	kfil

;	Fill a field

ffil:	call	zsep
	jz	bfil
	cpi	'*'
	jz	qfil
	mov	m,a
	inx	h
	dcr	b
	rz
	call	rech	;read one character
	jmp	ffil

;	Block fill

qfil:	mvi	c,'?'
	jmp	kfil
bfil:	mvi	c,' '
kfil:	mov	m,c
	inx	h
	dcr	b
	jnz	kfil
	ret

;	(L) List the memory as 8080 operation codes. The
;	command <nLa,b> will list n lines of code between
;	the hexadecimal addresses a and b, with the interval
;	taking precedence over the number of lines, unless
;	either a or b is missing.

optl:	call	past	;check limit transgression
	jnc	error	;<L may have been overwritten>
	lhld	rept
	mov	a,l
	sta	pinc	;paragraph length
	ora	h
	jnz	opla
	lxi	h,NL	;default length
opla:	inx	h
	shld	rept	;line counter for L
	xra	a
	sta	pctr	;paragraph counter
	lhld	lorg	;origin for L
	call	hef	;read <a>
	shld	lorg	;origin for L
	mov	b,a
	xchg
	lxi	h,begn	;bottom DDT = top memory
	call	hef	;read <b>
	shld	llim	;limit for L
	jc	oplc	;c means <b> not null
	mov	a,b
	cpi	CR
	jz	opld
oplc:	lxi	h,0000H
	shld	rept	;line counter for L
	lda	pinc	;paragraph length
	sta	pctr	;paragraph counter

;	The parameters have been established, start typing.

opld:	call	inst	;read console status
	rnz
	lhld	rept	;line counter for L
	mov	a,l
	ora	h
	jnz	oplf	;nz means counter working
	lda	pctr	;paragraph counter
	ora	a
	jz	oplg	;z means no paragraphing
	dcr	a
	jnz	ople
	call	crlf
	lda	pinc	;paragraph length
ople:	sta	pctr	;paragraph counter
	jmp	oplg
oplf:	dcx	h
	mov	a,l
	ora	h
	rz
	shld	rept	;line counter for L
oplg:	call	dubl
	lhld	lorg	;origin for L
	call	reab
	jnc	nox
	mvi	a,'X'
	call	aout	;A to console
nox:	call	tyhl	;type HL as four nibbles
	call	dubl
	lhld	llim	;upper limit for "L"
	xchg
	lhld	lorg	;origin for L
	mov	a,e	;cmp(DE,HL)
	sub	l
	mov	a,d
	sbb	h
	rc
	call	dism
	shld	lorg	;origin for L
	call	crlf
	jmp	opld

;	(M) Move part of the memory from one place to another.
;	<Mx,y,z> will move the interval x,y to begin at z. The
;	direction of movement compensates for possible overlap.

optm:	call	onar
	mov	c,l
	mov	b,h
	call	onar
	xchg
	call	onar
	mov	a,e	;cmp(DE,BC)
	sub	c
	mov	a,d
	sbb	b
	jc	error	;<interval inverted>
	mov	a,e	;cmp(DE,HL)
	sub	l
	mov	a,d
	sbb	h
	jc	opmb
	mov	a,c	;cmp(BC,HL)
	sub	l
	mov	a,b
	sbb	h
	jnc	opmb
	mov	a,e	;BC=DE-BC
	sub	c
	mov	c,a
	mov	a,d
	sbb	b
	mov	b,a
	dad	b	;HL=HL+(DE-BC)
opma:	mov	a,c
	ora	b
	rz
	ldax	d
	mov	m,a
	dcx	h
	dcx	d
	dcx	b
	jmp	opma
opmb:	mov	a,e	;cmp(DE,BC)
	sub	c
	mov	a,d
	sbb	b
	rc
	ldax	b
	mov	m,a
	inx	b
	inx	h
	jmp	opmb

;	(R) Read into memory the file specified by TFCB.
;	It was probably defined by a preceding I command,
;	but might still be the program defined in the DDT
;	command line. <Rx> will start loading at TORG+x.

optr:	call	hexf	;with zero default
opra:	push	h
	call	openf	;open file
	cpi	0FFH
	jz	error	;<failure to open file>
	call	chex	;check for .HEX
	jz	ihex	;load INTEL HEX file
	pop	h
	lxi	d,TORG	;CP/M transient origin
	dad	d
	shld	savpc	;PC at breakpoint
oprb:	push	h
	lxi	d,TFCB	;CP/M default FCB
	mvi	c,20	;(14) read one record
	call	XDOS	;DDT analogue of 0005
	pop	h
	ora	a
	jnz	efil	;EOF
	lxi	d,TBUF	;CP/M default FCB
	mvi	c,80H	;size of one record
oprc:	ldax	d
	inx	d
	mov	m,a
	inx	h
	dcr	c
	jnz	oprc	;move to memory
	call	rmax	;record upper limit
	jmp	oprb	;read another record

;	Test whether HL beyond previous maximum.

tmax:	xchg
	lhld	pmax	;program high limit
	mov	a,l	;cmp(HL,DE)
	sub	e
	mov	a,h
	sbb	d
	xchg
	ret	

;	Record maximum program length.

rmax:	call	tmax
	rnc	
	shld	pmax	;program high limit
	ret	

;	Test for limit transgression.

past:	push	h
	lxi	h,begn	;lower DDT limit
	call	tmax
	pop	h
	ret	

;	Check for the extension 'HEX'

chex:	lxi	h,TFCB+9	;extension
	mov	a,m
	ani	07FH
	cpi	'H'
	rnz	
	inx	h
	mov	a,m
	ani	07FH
	cpi	'E'
	rnz	
	inx	h
	mov	a,m
	ani	07FH
	cpi	'X'
	ret	

;	Load INTEL HEX file, whose records have the form:
;	:NNAAAA00DDDDDDDDDD....DDXX
;	    :	   start of line
;	    NN     number of bytes in line
;	    AAAA   first address of line
;	    00	   class of line (zero in CP/M)
;	    DD	   byte of data - NNH altogether
;	    XX	   checksum - full bytesum w/XX = 00
;	:00AAAA -  end of file, start address AAAA.

ihex:	call	renb	;next byte from CP/M buffer
	cpi	01AH	;^Z
	jz	error	;<no EOF in legal text>
	sbi	':'	;line begins with colon
	jnz	ihex	;load INTEL HEX file
	mov	d,a	;start checksum w/zero
	pop	h
	push	h
	call	nbyt	;next byte w/checksum
	mov	e,a
	call	nbyt	;next byte w/checksum
	push	psw	
	call	nbyt	;next byte w/checksum
	pop	b
	mov	c,a
	dad	b
	mov	a,e
	ora	a
	jnz	ihxx	;read non-null line
	mov	h,b
	mov	l,c
	shld	savpc	;PC at breakpoint
	pop	h	;displacement not added to AAAA <<---
	jmp	efil	;EOF

ihxx:	call	nbyt	;next byte w/checksum
hlin:	call	nbyt	;next byte w/checksum
	mov	m,a
	inx	h
	dcr	e
	jnz	hlin	;read the full line
	call	nbyt	;next byte w/checksum
	push	psw	
	call	rmax	;record upper limit
	pop	psw	
	jnz	error	;<checksum failed>
	jmp	ihex	;load INTEL HEX file

;	Form next byte, add to checksum

nbyt:	push	b
	push	h
	push	d
	call	renb	;next byte from CP/M buffer
	call	cnh
	jc	error	;<not hex digit>
	add	a	
	add	a	
	add	a	
	add	a	
	push	psw	
	call	renb	;next byte from CP/M buffer
	call	cnh
	jc	error	;<not hex digit>
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

;	EOF after reading file

efil:	mvi	c,12	;(0C) lift disk head
	call	XDOS	;DDT analogue of 0005
	lxi	h,rmsg	;header: 'NEXT  PC'
	call	mssg
	call	crlf	;type CR,LF
	lhld	pmax	;program high limit
	call	tyhl	;type HL as four nibbles
	call	sngl	;type space
	lhld	savpc	;PC at breakpoint
	shld	dorg	;origin for D
	shld	lorg	;origin for L
	jmp	tyhl	;type HL as four nibbles

rmsg:	db	CR,LF,'NEXT  PC',00

;	(S) Store hexadecimal bytes. <nSx> will store
;	n bytes starting at address x, read one by one
;	from the console. Missing n means indefinite
;	repetition, missing x means TORG. Confirmation
;	and progression is automatic while hexadecimal
;	bytes are being received; however, for
;		 -  go back one byte,
;		'x  deposit ASCII x,
;		^x  deposit ctl x,
;		CR  go on to next byte.
;	Any other input terminates the cycle.

opts:	lxi	h,TORG
	call	hef	;read hex field
	xchg
opsa:	call	crlf	;type CR,LF
	call	typs	;verify the line
	call	incl	;fetch a command line
	jz	opsc	;null buffer, go next line
	call	hxar	;read one-byte arg
	jz	opsb	;<standard field>
	cpi	'-'	;go back
	rnz		;leave the cycle
	dcx	d
	jmp	opsa
opsb:	stax	d
	call	ctlx
	call	typs	;verify the line
opsc:	inx	d
	call	drnz
	jnz	opsa
	ret

;	Type the format line for S.

typs:	ldax	d
	call	prip	;type printable or .
	call	sngl
	call	word	;type DE as four nibbles
	call	sngl	;type space
	ldax	d
	call	byte	;type A as two nibbles
	jmp	sngl	;type space

;	(T)  Type the register status line while single-stepping
;	through the program. <nT> runs through n steps typing
;	each one, while <nT/> executes without typing. The option
;	V, with the same alternatives <nV> and <nV/> treats a
;	call or a conditional call as a single step, avoiding a
;	detailled examination of the interior contents of each
;	subroutine.


optt:	xra	a
oooa:	sta	swtv	;T/V = z/nz
	mvi	a,0FFH
	sta	swgt	;G/T = z/nz
	call	reuc
	cpi	'/'
	jnz	ooob
	xra	a
ooob:	sta	swtu	;T/U = nz/z
	lhld	rept
	mov	a,l
	ora	h
	jz	oooc
	dcx	h
oooc:	shld	rept	;repetition counter
	call	line	;type display line
	jmp	gnex

;	(V) A variant of T.

optv:	mvi	a,0FFH
	jmp	oooa

;	(X) Examine registers. Any one of the registers or
;	register pairs A, BC, HL, DE, SP, PC may be examined,
;	or one of the five flag bits C, Z, M, E, I, by typing
;	Xr, with r = czmeiabhdsp*, or =xxxx with a hexadecimal
;	address xxxx. The latter defines the register * at
;	first. A display line is typed, of the form
;	r=xxxx  xx ...  xx  ... xx  +++++  + +++++  ooo ooooo
;	where xxxx is the contents of register r, xx etc is
;	a window of hexadecimal bytes centered on xxxx, ++ etc
;	is a similar window of ASCII characters, and finally
;	ooo ooooo is the instruction, if meaningful, at xxxx.
;
;	Once an examination is underway, the window may be
;	moved by various operators:
;		*      indirect from window
;		^      indirect from instruction address
;		excl   save value
;		?      recover value
;		/      next instruction
;		+      1 byte forward
;		-      1 byte backward
;		#      forward, stop at nonzero
;		@      backward, stop at nonzero
;		=xx    search for byte xx ('x or ^x also)
;		|xxxx  search for pair xxxx
;		>      forward half-window
;		<      backward half-window
;		.      type crlf - make new line

optx:	call	relc	;char to A from buffer
	cpi	CR
	jz	ljne	;type display line
	cpi	'='
	jnz	opxa
	call	hexf
	shld	savmr	;save memory reference
	mvi	a,'*'
opxa:	lxi	b,NR	;B=0, C=# registers
	lxi	h,regs	;register list
opxb:	cmp	m
	jz	opxc	;modify given register
	inx	h
	inr	b
	dcr	c
	jnz	opxb	;repeat for all
	jmp	error	;<no such register>

opxc:	push	h
	mov	a,b
	call	gesr	;fetch saved register
	shld	savxx	;?/! cell
	call	reuc	;char to A from buffer
	cpi	CR
	jnz	error	;<null field>
	push	b
opxd:	pop	b
	pop	h
	push	h
	push	b
	call	ctlx	;type ^X
	call	tyfr	;type flag or register
	call	sngl	;type space
	call	incl	;fetch a command line
	call	hexf
	pop	b
	jnc	opxg	;nc means null hex field
	push	b
opxe:	mov	a,b
	cpi	05
	jnc	uacc	;update register
	mov	a,h
	ora	a
	jnz	error	;<only one byte admitted>
	mov	a,l
	cpi	02
	jnc	error	;<only 1 bit (0,1) allowed>
	call	fmaf	;fetch mask & flags
	mov	h,a
	mov	b,c
	mvi	a,0FEH	;-2
	call	shla	;shl(A,B)
	ana	h
	mov	b,c
	mov	h,a
	mov	a,l
	call	shla	;shl(A,B)
	ora	h
	stax	d
	jmp	opxd

;	Window modifiers are possible with a null hex field.

opxg:	push	psw
	mov	a,b
	call	gesr	;fetch saved register
	pop	psw
	cpi	CR
	jnz	opxh
	shld	dorg
	shld	lorg
	pop	h
	ret
opxh:	push	b
	lxi	d,opxe
	push	d
	call	alta
	db	14
	db	'*'	;indirect address from window
	dw	opxv
	db	'^'	;indirect address from instruction
	dw	opxu
	db	'!'	;save address
	dw	opxw
	db	'?'	;restore address
	dw	opxx
	db	'/'	;next instruction
	dw	opxy
	db	'+'	;advance 1 byte
	dw	opxz
	db	'-'	;return 1 byte
	dw	opxt
	db	'#'	;advance to nonzero byte
	dw	opxs
	db	'.'	;type crlf
	dw	crlf
	db	'='	;=x: search for xx, 'x, ^x
	dw	opxr
	db	'|'	;|xxxx: search for pair xxxx
	dw	opxm
	db	'>'	;advance halfwindow
	dw	opxp
	db	'<'	;return halfwindow
	dw	opxo
	db	'@'	;return to nonzero
	dw	opxn

opxu:	inx	h	;^
opxv:	mov	e,m	;*
	inx	h
	mov	d,m
	xchg
	ret

opxw:	shld	savxx	;excl
	ret

opxx:	lhld	savxx	;?
	ret

opxy:	mov	a,m	;/
	inx	h
	inx	h
	inx	h
	call	twob
	rc
	dcx	h
	call	oneb
	rc
opxt:	dcx	h	;- (beware - it's part of opxy)
	ret

opxz:	inx	h	;+
	ret

opxs:	xra	a	;#
oxs:	inx	h
	cmp	m
	jz	oxs
	ret

opxr:	xchg		;=
	lhld	rept
	call	hxr	;hex argument w/default
	shld	rept	;be sure to find it again
	mov	a,l
	xchg
oxr:	inx	h
	cmp	m
	jnz	oxr
	ret

opxp:	lxi	d,WW+1	;>
	dad	d
	ret

opxo:	lxi	d,-WW-1	;<
	dad	d
	ret

opxn:	xra	a	;@
oxn:	dcx	h
	cmp	m
	jz	oxn
	ret

opxm:	xchg		;|
	lhld	rept
	call	hef
	shld	rept	;be sure we'll find the pair
	xchg
	inx	h
oxm:	mov	a,e
	call	oxr
	inx	h
	mov	a,d
	cmp	m
	dcx	h
	jnz	oxm
	dcx	h
	ret

;	shl(A,B)

shla:	dcr	b
	rz	
	rlc	
	jmp	shla	;shl(A,B)

;	Decrement REPT if it is non-zero.

drnz:	push	h
	lhld	rept
	mov	a,h
	ora	l
	sui	1
	sbb	a
	jnz	dnz
	dcx	h
	shld	rept
	mov	a,h
	ora	l
dnz:	pop	h
	ret

;	Update register

uacc:	jnz	ureg
	mov	a,h
	ora	a
	jnz	error	;<only one byte allowed>
	mov	a,l
	sta	sava	;save A
	jmp	opxd

ureg:	push	h
	call	gasr	;get address of saved register
	pop	d
	mov	m,e
	inx	h
	mov	m,d
	jmp	opxd

;	Open file

openf:	push	h
	push	d
	push	b
	xra	a
	sta	TFCB-1
	sta	TFCB+32
	mvi	c,15	;(0F) open file
	lxi	d,TFCB	;CP/M default FCB
	call	XDOS	;DDT analogue of 0005
	pop	b
	pop	d
	pop	h
	ret	

;	Read next byte from CP/M buffer,
;	replenish when exhausted.

renb:	push	h
	push	d
	push	b
	lda	TFCB-1
	ani	07FH
	jz	ror	;read one record
rnb:	mvi	d,00
	mov	e,a
	lxi	h,TBUF	;CP/M default FCB
	dad	d
	mov	a,m
	cpi	01AH	;^Z
	jz	reen	;end of record
	lxi	h,TFCB-1
	inr	m
	ora	a
	jmp	reex	;return

ror:	mvi	c,20	;(14) read one record
	lxi	d,TFCB	;CP/M default FCB
	call	XDOS	;DDT analogue of 0005
	ora	a
	jnz	reen	;end of record
	sta	TFCB-1
	jmp	rnb

reen:	stc		;end of record
reex:	pop	b	;return
	pop	d
	pop	h
	ret	

;	Error

error:	mvi	a,'?'
	call	aout	;A to console
	jmp	loop	;clear out the stack

;	Read console status.

inst:	push	b
	push	d
	push	h
	mvi	c,11	;(0B) console status
	call	XDOS	;DDT analogue of 0005
	ani	01
	pop	h
	pop	d
	pop	b
	ret	

;	Fill command line buffer from console. The z flag
;	on return indicates whether a null line was read.

incl:	push	h
	push	d
	push	b
	mvi	c,10	;(0A) read buffer
	lxi	d,cbuf	;command buffer
	call	XDOS	;DDT analogue of 0005
	lxi	h,ctex	;command text
	shld	cptr	;pointer to command buffer
	lda	clen
	pop	b
	pop	d
	pop	h
	ora	a
	ret	

;	Read a one-byte argument, which may be hexadecimal,
;	'x or ^x. Blatant errors are rejected, but nz at
;	return means null field not terminated by CR, ', or^.

hxar:	lxi	h,0000
hxr:	call	hef
	jnc	har
	mov	a,h
	ora	a
	jnz	error	;<not one byte>
	mov	a,l
	ret
har:	cpi	''''
	jnz	has
	call	rech
	cpi	' '
	jc	error	;<quoted ctrl char>
	jmp	hat
has:	cpi	'^'
	rnz
	call	rech
	sui	'@'
	jc	error	;<number, symbol, &c>
	cpi	' '
	jc	hat
	sui	' '
	cpi	' '
	jnc	error	;<beyond ASCII range>
hat:	mov	l,a
	call	rech
	cpi	CR
	jnz	error	;<not single character>
	mov	a,l
	ret

;	Read a hexadecimal field; error if null.

onar:	call	hexf
	jnc	error	;<insufficient arguments>
	ret

;	Type CR,LF.

crlf:	mvi	a,CR
	call	aout	;A to console
	mvi	a,LF
	jmp	aout	;A to console

;	Type ^X [erase line]

ctlx:	mvi	a,18H	;^X
	jmp	aout	;A to console

;	Type one or two spaces.

dubl:	call	sngl
sngl:	mvi	a,' '

;	A to console

aout:	push	h
	push	d
	push	b
	mov	e,a
	mvi	c,02
	call	XDOS	;DDT analogue of 0005
	pop	b
	pop	d
	pop	h
	ret	

;	Lower case fold excepting rubout

reuc:	call	rech	;read one character
lcfo:	cpi	'a'
	rc
	cpi	'{'
	rnc
	ani	5FH
	ret	

;	Upper case fold

relc:	call	rech	;read one character
ucfo:	cpi	'['
	rnc
	cpi	'A'
	rc
	ori	20H
	ret

;	Fetch a character into A from command line

rech:	push	h
	lxi	h,clen	;command string length
	mov	a,m
	ora	a
	mvi	a,CR	;fake CR from empty buffer
	jz	recx
	dcr	m
	lhld	cptr	;pointer to command buffer
	mov	a,m
	inx	h
	shld	cptr	;pointer to command buffer
recx:	pop	h
	ret	

;	Type A as two nibbles

word:	mov	a,d
	call	byte
	mov	a,e
byte:	push	psw	
	rar	
	rar	
	rar	
	rar	
	call	nybl
	pop	psw
nybl:	ani	0FH
	adi	90H
	daa
	aci	40H
	daa
	jmp	aout	;A to console

;	Type HL as four nibbles

tyhl:	xchg
	call	word
	xchg
	ret

;	Message terminated by zero to console

mssg:	mov	a,m
	ora	a
	rz
	call	aout	;A to console
	inx	h
	jmp	mssg

;	Print printables, put dot for the rest

prip:	cpi	RO
	jnc	priq
	cpi	' '
	jnc	aout	;A to console
priq:	mvi	a,'.'
	jmp	aout	;A to console

;	Type minus or B, according to sign.

morb:	rlc
	push	psw
	mvi	a,'-'
	jnc	morc
	mov	a,b
morc:	call	aout
	pop	psw
	ret

;	Type 5 flags as letter (1) or minus (0).

feql:	lda	savf
	mvi	b,'s'
	call	morb
	mvi	b,'z'
	call	morb
	rlc
	mvi	b,'i'
	call	morb
	rlc
	mvi	b,'p'
	call	morb
	rlc
	mvi	b,'c'
	call	morb
	jmp	sngl

;	Type <R=XX x > to display a register.

reql:	push	psw
	mov	a,b
	call	aout
	mvi	a,'='
	call	aout
	pop	psw
	push	psw
	call	byte
	call	sngl
	pop	psw
	call	prip
	jmp	sngl

;	Type <P=XXXX > to display a register pair.

peql:	mov	a,b
	call	aout
	mvi	a,'='
	call	aout
	call	tyhl
	jmp	sngl

;	Test for separators, which are characters which can
;	be passed over at the beginning of a field, but which
;	terminate it when found at the end. The character to
;	be tested is in the accumulator, where it remains.

sepa:	cpi	' '
	rz	
	cpi	HT
	ret	

;	Test for terminators, which mean that a field must
;	end, even if it is null.

term:	cpi	','
	rz
	cpi	CR
	ret

;	Test whether the character in the accumulator is a
;	decimal digit. If so, it is replaced by its  binary
;	value, otherwise remaining unchanged. The carry
;	flag distinguishes the cases - carry if not decimal.

cnd:	cpi	'0'
	rc
	cpi	':'
	cmc
	rc
	sui	'0'
	ret

;	Read a decimal field, leaving the last four
;	digits read in HL, with leading zeros for fewer
;	digits.  BC, DE remain unchanged. A null field
;	is zero.  Leading separators are passed by, but
;	trailing separators terminate.	A null field is
;	marked by the carry flag, which is 0 for a null
;	field delimited by a terminator, 1 otherwise.
;	A non-zero default value can be given to a null
;	field using <call def> rather than <call decf>.

decf:	lxi	h,0000
def:	call	reuc
	call	sepa
	jz	def
	call	cnd
	cmc
	rnc
	lxi	h,0000
	push	d
dec:	mov	e,l
	mov	d,h
	dad	h
	dad	h
	dad	d
	dad	h
	mov	e,a
	mvi	d,0
	dad	d
	call	reuc
	call	cnd
	jnc	dec
	pop	d
	ret

;	Test whether the character in the accumulator is a
;	hexadecimal digit. If so, it is replaced by its 
;	binary value, otherwise remaining unchanged. The
;	carry flag distinguishes the cases - carry if not
;	hexadecimal.

cnh:	cpi	'0'
	rc
	cpi	':'
	jc	cni
	cpi	'A'
	rc
	cpi	'G'
	jnc	cnj
	sui	07
cni:	sui	'0'
	stc
cnj:	cmc
	ret

;	Read a hexadecimal field, leaving the last four
;	digits read in HL, with leading zeros for fewer
;	digits.  BC, DE remain unchanged. A null field
;	is zero.  Leading separators are passed by, but
;	trailing separators terminate.	A null field is
;	marked by the carry flag, which is 0 for a null
;	field delimited by a terminator, 1 otherwise.
;	A non-zero default value can be given to a null
;	field using <call hef> rather than <call hexf>.

hexf:	lxi	h,0000
hef:	call	reuc
	call	sepa
	jz	hef
	call	cnh
	cmc
	rnc
	lxi	h,0000
hex:	dad	h
	dad	h
	dad	h
	dad	h
	ora	l
	mov	l,a
	call	reuc
	call	cnh
	jnc	hex
	ret

;	Fetch mask and saved flags

fmaf:	push	h
	lxi	h,fmsk	;flag masks
	mov	e,b
	mvi	d,00
	dad	d
	mov	c,m
	lxi	h,savf	;save AF
	mov	a,m
	xchg
	pop	h
	ret	

;	Get value of saved flag

fval:	call	fmaf	;fetch mask & flags
val:	dcr	c
	jz	vam	;ani a,01
	rar	
	jmp	val
vam:	ani	01
	ret	

;	Get address of saved register

gasr:	sui	06
	lxi	h,rdsp	;list of displacements
	mov	e,a
	mvi	d,00
	dad	d
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	lxi	h,savmr	;save memory reference
	dad	d
	ret	

;	Fetch saved register

gesr:	call	gasr	;get address of saved register
	mov	e,m
	inx	h
	mov	d,m
	xchg
	ret	

;	Type flag or register

tyfr:	mov	a,b
	cpi	05
	jnc	tyra
	mov	a,m
	call	aout	;A to console
	call	fval	;get saved flag
	jmp	nybl	;type A as DEC or HEX

tyra:	mov	b,m
	jnz	tyre	;type saved register
	lda	sava	;save A
	jmp	reql

;	Type register and the memory pointed to in the format:
;		r=value, window, ASCII window, dism

tyre:	call	gesr	;get saved register
	call	peql
	call	sngl
	push	h
	lxi	d,-WW	;go back window halfwidth
	dad	d
	push	h
	call	tyrg
	call	sngl
	pop	h
	call	tyrj
	call	dubl
	pop	h
	jmp	dism

;	Type 2*WW+1 bytes centered on pointer, as nibble pairs.

tyrg:	call	tyrh
	call	sngl
	mov	a,m
	call	byte
	call	dubl
	inx	h
tyrh:	mvi	c,WW
tyri:	mov	a,m
	call	byte
	call	sngl
	inx	h
	dcr	c
	jnz	tyri
	ret

;	Then type the same window using ASCII characters or points.

tyrj:	call	tyrk
	call	sngl
	mov	a,m
	call	prip	;type printable or .
	inx	h
	call	sngl
tyrk:	mvi	c,WW
ascl:	mov	a,m
	call	prip	;type printable or .
	inx	h
	dcr	c
	jnz	ascl
	ret

;	Type display line.

line:	call	ljne
	jmp	crlf
ljne:	mvi	b,'b'
	lhld	savbc
	call	peql
	mvi	b,'d'
	lhld	savde
	call	peql
	mvi	b,'h'
	lhld	savhl
	push	h
	call	peql
	pop	h
	mvi	b,'m'
	mov	a,m
	call	reql
	mvi	b,'a'
	lda	sava
	call	reql
	call	feql
	mvi	b,'s'
	lhld	savsp
	call	peql
	mvi	b,'p'
	lhld	savpc
	call	peql
	call	sngl
	jmp	dism

regs:	db	'czmeiabdhsp*'

rdsp:	dw	-10,-12,-4,-6,-2,0

fmsk:	db	1,7,8,3,5

;	Jump guided by a table of alternatves. The table
;	should have the form:
;		call	alta
;		db	n
;		db	'x'
;		dw	xxxx
;	The last two lines are to be repeated n times, for
;	each of which xxxx is the jump address corresponding
;	to the alternative x. The table is used by jumping
;	to its heading with the alternative in A. Registers
;	C, D, and E are lost in the process.

alta:	xthl
	mov	c,m
alt:	inx	h
	cmp	m
	inx	h
	jnz	alu
	mov	e,m
	inx	h
	mov	d,m
	xchg
	xthl
	ret
alu:	dcr	c
	inx	h
	jnz	alt
	jmp	error	;<alternative not present>

;	Indexed jump through a table.

juta:	pop	h
	mov	e,a
	mvi	d,00
	dad	d
	dad	d
	mov	e,m
	inx	h
	mov	d,m
	xchg
	pchl

;	Return from breakpoint

rtbk:	di
	shld	savhl;	HL at breakpoint
	pop	h
	dcx	h
	shld	savpc	;PC at breakpoint
	push	psw	
	lxi	h,0002
	dad	sp
	pop	psw	
	lxi	sp,savhl	;HL at breakpoint
	push	h
	push	psw	
	push	b
	push	d
	lhld	savpc	;PC at breakpoint
	mov	a,m
	cpi	0FFH	;RST 7
	push	psw	
	push	h
	lxi	h,bkpt	;breakpoint data
	mov	a,m
	mvi	m,00
	ora	a
	jz	rtbb
	dcr	a
	jz	rtba
	lda	brky
	lhld	brkq
	mov	m,a
rtba:	lda	brkx
	lhld	brkp
	mov	m,a
rtbb:	pop	h
	pop	psw	
	jz	rtbc	;if RST 7
	inx	h
	shld	savpc	;PC at breakpoint
	xchg
	lxi	h,GDOS+1	;BDOS address
	mov	c,m
	inx	h
	mov	b,m
	mov	a,e	;cmp(DE,BC)
	sub	c
	mov	a,d
	sbb	b
	jc	rtbc	;if RST 7
	lxi	h,0000
	shld	rept
	lhld	sica	;site of call to BDOS
	xchg
	mvi	a,02H
	ora	a
	stc	
	jmp	gprg	;G without arguments


;	If RST 7 brought us to the breakpoint.

rtbc:	NOP
	lhld	rept	;repetition counter
	mov	a,h
	ora	l
	jz	rtbd	;we won't continue
	dcx	h
	shld	rept	;repetition counter
	lda	swgt	;G/T = z/nz
	ora	a
	jz	rtbf
	call	inst	;read console status
	jnz	rtbd	;we won't continue
	lda	swtu	;T/U = nz/z
	ora	a
	cnz	line	;type display line
	jmp	gnex

;	Return to DDT rather than program.

rtbd:	mvi	a,'*'
	call	aout	;A to console
	lhld	savpc	;PC at breakpoint
	shld	dorg	;origin for D
	call	past	;check limit transgression
	jnc	rtbe	;can't count on using L
	shld	lorg	;origin for L
rtbe:	call	tyhl	;type HL as four nibbles
	jmp	loop	;DDT loop - cannot be <ret>

rtbf:	mov	a,l
	ani	01H
	jnz	gnex
	lhld	gbrl
	mov	c,l
	mov	b,h
	lhld	gbrk
	xchg
	lda	gbrn
	ora	a
	stc
	jmp	gprg	;G without arguments

;	Surround instruction by breakpoints for single-step.

type:	lxi	d,000DH
	lxi	h,mtbl	;table of type codes
tyqe:	mov	a,m
	ana	b
	inx	h
	cmp	m
	inx	h
	jz	tyse
	inr	d
	dcr	e
	jnz	tyqe
tyse:	mov	a,d
	ret	

step:	lhld	savpc	;PC at breakpoint
	mov	b,m
	inx	h
	push	h
	call	type
	call	juta
	dw	xjmp	;jump
	dw	xcju	;conditional jump
	dw	ding	;call
	dw	dong	;conditional call
	dw	xret	;return
	dw	xrst	;restart
	dw	xpch	;pchl
	dw	xmvi	;immediate move
	dw	xmvi	;immediate arithmetic
	dw	xlxi	;lxi
	dw	xlxi	;lhld
	dw	xcrt	;conditional return
	dw	xmvi	;in, out
	dw	xoth	;others

ding:	lda	swtv	;T/V = z/nz
	inr	a
	jz	xlxi	;lxi, lhld
	jmp	xjmp	;jump, call

dong:	lda	swtv	;T/V = z/nz
	inr	a
	jz	xlxi	;lxi, lhld
	jmp	xcju	;cndl jmp, cndl call

;	Jump or call

xjmp:	call	idos
	jnz	xtwo

;	Return

xret:	call	xrtn
	jmp	xtwo

;	qdos - check whether DE = BDOS
;	idos - check whether (DE) = BDOS

idos:	pop	b
	pop	h
	mov	e,m
	inx	h
	mov	d,m
	inx	h
	push	h
	push	b
qdos:	lda	GDOS+1	;BDOS address
	cmp	e
	rnz	
	lda	GDOS+2	;BDOS address
	cmp	d
	ret	

xrtn:	lhld	savsp	;SP at breakpoint
	mov	e,m
	inx	h
	mov	d,m
	ret	

;	Conditional jump or call

xcju:	call	idos
	jz	zdos
	pop	b
	push	b
	mvi	a,02
	jmp	xone

zdos:	pop	d
	push	d
	jmp	xtwo

;	Restart

xrst:	mov	a,b
	cpi	0FFH
	jnz	xsvn
	xra	a
	jmp	xzer

xsvn:	ani	38H
	mov	e,a
	mvi	d,00
	jmp	xtwo

;	PCHL

xpch:	lhld	savhl	;HL at breakpoint
	xchg
	call	qdos	;does DE = BDOS?
	jnz	xtwo
	jmp	xret

jtwo:	jmp	xtwo

;	Other.

xoth:	pop	d
	push	d
	jmp	xtwo

;	Conditional return.

xcrt:	call	xrtn
	pop	b
	push	b
	mvi	a,02
	jmp	xone

;	LXI, LHLD

xlxi:	pop	d
	inx	d
	push	d

;	Immediate move or arithmetic, in, out.

xmvi:	pop	d
	inx	d
	push	d
xtwo:	mvi	a,01
xone:	inr	a
	stc	
xzer:	pop	h
	ret	

mtbl:	db	0FFH,0C3H,0C7H,0C2H	;jump, conditional jump
	db	0FFH,0CDH,0C7H,0C4H	;call, conditional call
	db	0FFH,0C9H,0C7H,0C7H	;return, restart
	db	0FFH,0E9H,0C7H,006H	;pchl, immediate moves
	db	0C7H,0C6H,0CFH,001H	;immediate arithmetc, lxi
	db	0E7H,022H,0C7H,0C0H	;lhlf, conditional return
	db	0F7H,0D3H		;in, out

;	---------------------------------------------------------

logo:	db	'       DDT(8080)/ICUAP',CR,LF
	db	'Universidad Autonoma de Puebla',CR,LF
	db	'      November 20, 1983',00
	dw	00,00,00,00,00,00,00;can't overwrite logo yet
savde:	dw	0000	;save DE, tail of DDT stack	1
savbc:	dw	0000	;save BC			2
savf:	db	00	;save F				3
sava:	db	00	;save A				4
savsp:	dw	0000	;SP at breakpoint		5
savhl:	dw	0000	;HL at breakpoint		6
savpc:	dw	0000	;PC at breakpoint		7
savmr:	dw	0000	;save memory reference		8
savxx:	dw	0000	;storage for optx		9
sica:	dw	0000	;site of call to BDOS
swtv:	db	00	;T/V = z/nz
swtu:	db	00	;T/U = nz/z
swgt:	db	00	;G/T = z/nz
rept:	dw	0000	;counter for commands
gbrk:	dw	0000	;nG's breakpoint
gbrl:	dw	0000	;nG's second breakpoint
gbrn:	db	00	;nG's # of breakpoints
bkpt:	db	00	;number of breakpoints
brkp:	dw	0000	;first breakpoint
brkx:	db	00	;first opcode
brkq:	dw	0000	;second breakpoint
brky:	db	00	;second opcode
pinc:	db	00	;paragraph length
pctr:	db	00	;paragraph counter
dorg:	dw	0000	;origin for D
lorg:	dw	0000	;origin for L
llim:	dw	0000	;upper limit for "L"
pmax:	dw	0000	;program high limit
ldsk:	db	00	;logged disk
adsk:	db	00	;active disk
cptr:	dw	0000	;pointer to command buffer
cbuf:	db	80H	;command buffer
clen:	db	00	;command string length
ctex:	ds	80H	;command text
enddt:	ds	0

;	.dephase

	end
