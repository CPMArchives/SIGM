

;	=======================================================
;
;	REC module containing RAM storage, I/O programs, main
;	program, and the directory. The complete set of modules
;	comprises REC.MAC, PDL.MAC, MARKOV.MAC, RECLIB.MAC, and
;	FXT.MAC.  RECLIB.MAC may be omitted if the operator X
;	isn't used, and must be substituted by another module
;	if the collection of subroutines to be called by X is
;	to be changed.
;
;	FXT.MAC contains the following REC operators and
;	predicates:
;
;		C	compile a REC expression
;		i	input from designated port
;		k	call CP/M without residue
;		K	call CP/M, preserve FCB, return value
;		o	output from designated port
;		R	read one character from console
;		t	type message given header
;		T	type argument on PDL
;		W	write argument on LST:
;		x	execute REC subroutine
;		`	test if a character waits at keyboard
;
;	REC version released during the 1980  Summer School of
;	the Microcomputer Applications Group of the I.C.U.A.P.
;
;		     FXT86  -  Copyright (C) 1982
;		    Universidad Autonoma de Puebla
;	      49 Poniente 1102 -  Puebla, Puebla, Mexico
;			 All Rights Reserved
;
;		 [Harold V. McIntosh,  28 August 1980]
;
;	Modification 1 - 1 January 1981.
;		a) Main program derives the values of const,
;		   conin, conou from the address rst0 supposing
;		   that BIOS starts out with the standard jump
;		   vector.  Thus, REC need not be reassembled
;		   to have fast access to I/O when CP/M varies.
;		b) T protected by pushes and pops of dx and bx.
;		c) Some changes made in memory allocation.
;	24 May 1981 - Zero flag to restrain L from too many pops
;	25 March 1982 - Y is now a predicate
;	29 May 1983 - ~ discontinued as argument exchange
;	29 May 1983 - ~ for unary negative or complement
;	29 May 1983 - N for numerical comparison on PDL
;	29 May 1983 - h discontinued, replaced by ''w
;	30 May 1983 - CPIR: jumps to BOOT rather than RER
;	8 July 1983 - C has object program origin as argument
;	8 July 1983 - C is an operator
;	8 July 1983 - C0 defined as lower bound of compile area
;	8 July 1983 - x moved from RECLIB
;	8 July 1983 - x is a predicate to call REC subroutines
;	9 July 1983 - Buffered CP/M input if no disk file given
;	14 July 1983 - W had its arguments reversed
;	=======================================================

;	Absolute program locations used by CP/M.

bdos	equ	224		;CP/M-86 software interrupt vector

TFCB	equ	005CH		;CP/M file control block
TALT	equ	006CH		;CP/M alternate file name
FSIZ	equ	0010H		;CP/M file name size
HSIZ	equ	FSIZ/2
TBUF	equ	0080H		;CP/M disk buffer location
TSIZ	equ	0080H		;CP/M disk buffer size

;	-----------------------------------------------------
;	RAM memory which is required for the operation of REC
;	-----------------------------------------------------

;	Relay area for input and output subroutines.

read:	dw	chin		;character input for REC compiler
tyin:	dw	chin		;single character input for R
tyou:	dw	chou		;single character output for T

;	Temporary storage used by the REC compiler.

XPD:	dw	0000		;colon jump back to left parenthesis
YPD:	dw	0000		;false predicate jump chain
ZPD:	dw	0000		;semicolon exit chain

;	Pointers to the directories.

FXT:	dw	FT		;pointer to fixed operator directory
VRT:	dw	VT		;pointer to subroutine directory

;	Pointers to the area of compiled subroutines.

C0:	dw	KA		;lower limit of compile area
C1:	dw	KA		;beginning of present compilation
C2:	dw	EK		;upper limit of compile area

;	Pointers to REC/MARKOV pushdown list.

PX:	dw	PD+2		;beginning of pushdown text
PY:	dw	PD+2		;end of pushdown text
PZ:	dw	EP		;end of available pushdown space

;	Workspace pointers.

P0:	dw	WS		;beginning of workspace
P1:	dw	WS		;beginning of marked segment
P2:	dw	WS		;end of marked segment
P3:	dw	WS		;end of text
P4:	dw	EW		;end of workspace

;	I-O pointers.

RX:	dw	0000
RY:	dw	0000

;	Linkage to input-output through ports.

QIN:	DB	0ECH		;8-bit static IN instruction
QI:	DB	00H
	ret

QOU:	DB	0E6H		;8-bit static OUT instruction
QO:	DB	00H
	ret

;	Error flag.

ER:	dw	0000

;	=======================================================
;	Programs related to input-output and disk usage.
;	=======================================================

;	bootstrap routine

boot:	ld	cl,#ze
	ld	dl,#ze
	int	bdos

;	Buffer read routine.

PTY:	push	bx		;conserve (bx)
	ld	bx,RX		;pointer to read buffer
	ld	al,[bx]		;fetch byte
	inc	bx		;advance pointer to next byte
	sto	bx,RX		;update buffer pointer
	pop	bx		;restore (bx) - preserve all reg pairs
	ret

;	Console character read routine.  Strict CP/M compatible
;	version, which has characteristics undesirable for some
;	applications, such as an automatic echo or preemption
;	of some of the control characters for editing purposes.
;	When it is used, programs must forego their own echo,
;	and do their own editing when required.  This version has
;	direct access to CONIN.

chin:	push	cx
	push	dx
chi:	ld	dl,#-1
	ld	cl,#6
	int	bdos
	or	al,al
	jz	chi
	pop	dx
	pop	cx
	ret

;	Buffered console character read routine, which is more
;	practical for use with CP/M.  Up to 126 characters may be
;	read using CP/M function 10, which is sufficient for
;	bootstrapping or generating test programs. CHIN should be
;	used for longer input sequences, which must be error-free
;	- incoming through a modem for example.

buin:	push	bx
	push	cx
	push	dx
	ld	bx,RX
	cmp	bx,RY
	jnz	BI5
	ld	cl,#9		;(09) write message
	ld	dx,#bume
	int	bdos
	ld	cl,#10		;(0A) buffered read
	ld	dx,#TBUF
	int	bdos
	ld	cl,#9		;(09) write message
	ld	dx,#crlf
	int	bdos
	ld	bx,#TBUF+2
	sto	bx,RX
	ld	al,[bx-1]
	ld	ah,#0
	add	ax,bx
	sto	ax,RY
BI5:	ld	al,[bx]
	inc	bx
	sto	bx,RX
	pop	dx
	pop	cx
	pop	bx
	ret

logo:	db	0DH,0AH,'        REC(8086)/ICUAP',0DH,0AH
	db	'Universidad Autonoma de Puebla',0DH,0AH
	db	'         July 20, 1983',0DH,0AH,'$'
bume:	db	0DH,0AH,'REC86> $'
crlf:	db	0DH,0AH,'$'

bure:	ld	al,#TSIZ-2
	sto	al,TBUF
	ld	ax,#buin
	sto	ax,read
	ld	ax,#TBUF
	sto	ax,RX
	sto	ax,RY
	ret

;	Console character out routine.  Strict CP/M compatible
;	version, which unfortunately makes so many tests and
;	jumps that it is unsuitable for programs such as the
;	cursor editor which frequently write a full screen.
;	This is a version with direct access to CONOUT.

chou:	push	cx
	push	dx
	mov	dl,al
	ld	cl,#6		;direct console I-O
	int	bdos
	pop	dx
	pop	cx
	ret

;	(`)  Test for presence of waiting character (FALSE if
;	none waiting).  This is a version with fast access to 
;	CONST, which is required when the fast CHIN is used,
;	because CP/M has some internal buffers which will 
;	otherwise distort the results.

chaw:	push	cx
	push	dx
	ld	dl,#-2
	ld	cl,#6		;direct console I-O
	int	bdos
	pop	dx
	pop	cx
	ror	al
	jc	chw
	ret
chw:	jmp	SKP

;	Printer output routine.

PROU:	push	bx
	push	dx
	push	cx
	ld	cl,#5		;output through LST:
	MOV	dl,al
	int	bdos
	pop	cx
	pop	dx
	pop	bx
	ret

;	(R)  REC read operator.

UCR:	ld	cx,#1		;one byte to be inserted
	call	NARG		;close last arg, verify space
	push	bx
	ld	bx,tyin
	call	bx		;get byte from console input
	pop	bx
	sto	al,[bx]		;store on PDL
	inc	bx		;advance pointer
	sto	bx,PY		;save as terminator
	ret

;	(t) Write indirect operator.  <org,siz,t> prints the
;	indicated message, leaves no residue.

LCT:	ld	bx,PX		;fetch argument pointer
	call	TWOL		;move two args to 8080 stack
	pop	dx		;second arg (org) into (dx)
	pop	bx		;top arg (siz) into (bx)
	add	bx,dx		;org+siz=end
	xchg	bx,dx		;(dx)=end, (bx)=org
	jmp	UT1		;use write cycle in UCT

;	(T)  REC write operator.  <'XXX' T> will write XXX on
;	the console, leaving it on the PDL.

uct:	ld	dx,py		;fetch terminal address
	ld	bx,px		;beginning address to (bx)
ut1:	cmp	dx,bx		;
	jz	ut2		;they match, we're done
	ld	al,[bx]		;get byte out of memory
	push	bx		;the registers dx and bx
	push	dx		;are essential for the loop
	ld	bx,tyou
	call	bx
	pop	dx		;recover the saved registers
	pop	bx		;
	inc	bx		;advance pointer
	jmp	UT1		;repeat
ut2:	ret

;	(W)  REC print operator.  <org, siz, W> will print the
;	indicated text on the list device, and then erase its
;	arguments.

UCW:	ld	bx,PX		;pointer to arguments
	call	TWOL		;2 args from PDL to 8080 stack
	pop	bx		;place text origin in (bx)
	pop	dx		;place length in (dx)
UWW:	cmp	dx,dx		;check for zero length
	jz	UWX		;no more to print
	ld	al,[bx]		;fetch a byte
	push	bx		;we need to be sure that dx and bx are
	push	dx		;preserved whatever the print routine
	call	PROU		;send it to printer
	pop	dx		;recover bx
	pop	bx		;and dx
	dec	dx		;diminish count
	inc	bx		;advance pointer
	jmp	UWW		;repeat
UWX:	ret

;	(i)  Input from designated port.  <port, i> leaves
;	<port, byte> so that after disposing of <byte>, <port>
;	can be reused.

LCI:	ld	bx,PX		;get pointer to top argument on PDL
	ld	al,[bx]		;only the low order byte matters
	sto	al,QI		;place it in teme IN instruction
	ld	cx,#1		;we're only going to read one byte
	call	NARG		;prepare a place for it on the PDL
	call	QIN		;execute the captive IN instruction
	sto	al,[bx]		;storing the incoming byte on the PDL
	inc	bx		;always ready for the next byte
	sto	bx,PY		;close off the argument
	ret			;and we're through

;	(o) Output from designated port  -  <port, byte, o>
;	leaves <port>, facilitating multiple OUTs through the
;	same port.

LCO:	ld	bx,PX		;pointer to last argument - output byte
	ld	CH,[bx]		;tuck it into register b
	call	UCL		;erase the top argument
	ld	al,[bx]		;(bx) points to next argument - get it
	sto	al,QO		;store in tame OUT instruction
	MOV	al,CH		;output must be from accumulator
	jmp	QOU		;execute the prepared OUT instruction

;	=======================================================
;
;	Communication with CP/M takes two forms:  <FCB, n, K>
;	which leaves <FCB, code> on the pushdown list, or else
;	<FCB, n, k> which leaves nothing on the pushdown list.
;	In either case - FCB is a two-byte parameter, usually
;	the address of the file control block - but it could
;	also be a DMA address or sometimes even null for the
;	sake of uniformity.  Approximately thirty options are
;	available which are numbered serially, indicated by the
;	argument n.  The difference between K and k is that the
;	former conserves the parameter FCB for possible use by
;	a subsequent CP/M call, and reports a result in the
;	one-byte result <code>.  This could be the character
;	read by an input routine or an error code for the disk
;	routines.
;
;	The options are:
;
;	num	function		"FCB"	"code"
;	---	--------		-----	------
;
;	 0	system reset		-	-
;	 1	read console		-	char
;	 2	write console		char	-
;	 3	read reader		-	char
;	 4	write punch		char	-
;	 5	write list		char	-
;	 6	-			-	-
;	 7	read i/o stat		-	stat
;	 8	write i/ stat		stat	-
;	 9	print buffer		buffer	-
;	10	read buffer		buffer	-
;	11	console status	-	stat
;
;	12	lift disk head		-	-
;	13	init disk only		-	-
;	14	select disk		disk	-
;	15	open file		fcb	code
;	16	close file		fcb	code
;	17	search once		fcb	code
;	18	search again		fcb	code
;	19	delete file		fcb	code
;	20	read 1 record		fcb	code
;	21	write 1 record		fcb	code
;	22	create file		fcb	code
;	23	rename file		fcb	code
;	24	read login		-	logv
;	25	read disklog		-	disk
;	26	set DMA address		dma	-
;	27	read bitmap		-	-
;
;	Fuller details of all the CP/M options and the way they
;	function can be obtained through consulting Digital
;	Research's manuals for CP/M, especially their "CP/M
;	Interface Guide."
;
;	=======================================================

;	(K)  Set up communication with CP/M - top into (bx),
;	next into (dx).  Preserve next, call BDOS, (Aze) into
;	top.

CPM:	ld	bx,PX		;fetch pointer to top argument
	ld	cx,[bx]		;load C from low byte
	ld	dx,[bx-2]	;load up (dx) with high byte
	xchg	bx,dx		;pointer into (bx)
	ld	dx,[bx]		;low byte of under argument
	int	bdos		;call BDOS with args in (bx), (dx)
	ld	bx,PX		;pointer to top argument again
	sto	al,[bx]		;save low byte from A
	stob	#ZE,[bx+1]	;make high byte a zero
	ret

;	(k)  Call to CP/M without any value returned.

CPML:	call	CXLD		;load top arg into (cx), lift it
	call	DXLD		;load next arg into (dx), lift it too
	int	bdos		;execute indicated operation
	ret

;	-------------------------------------------------------
;	Disk input-output routine working through CP/M.
;	-------------------------------------------------------

;	Set up a file control block with a given file name and
;	the default extension REC.  The pushdown list contains
;	the disk unit designation, then by the filename without
;	any extension. No protection is afforded against an
;	overly long file name, a nonexistent disk, or the like.
;	Some errors of this type must be caught by CP/M since
;	REC cannot know such things as the exact number of disk
;	drives that there will be.

DIIN:	cld
	mov	ax,ds
	mov	es,ax
	ld	cx,#21H		;FCB requires 33 bytes
	ld	di,#TFCB	;use CP/M's transient FCB
	ld	al,#00H		;	;fill it with zeroes
	rep
	stosb
	ld	cx,#11		;filename field is 11 bytes long
	ld	di,#TFCB+1	;field begins at second byte
	ld	al,#' '		;fill it with blanks
	rep
	stosb
	ld	bx,PX		;fetch pointer to top argument
	ld	al,[bx]		;load disk unit designator
	SUB	al,#'@'		;normalize to uppercase letters
	sto	al,TFCB		;store it in file control block
	call	UCL		;pop top argument
	ld	si,PX		;fetch pointer to file name
	ld	cx,PY		;end of file name
	sub	cx,si		;place py - px in (cx)
	ld	di,#TFCB+1	;destination origin
	rep
	movsb
CPIN:	ld	cl,#15		;<open file>
	ld	dx,#TFCB	;file control block
	int	bdos		;
	cmp	al,#0FFH	;check for error
	jz	CPIR
	ld	bx,#TBUF	;origin of CP/M's sector buffer
	sto	bx,RX		;initial address of pseudotty
	sto	bx,RY		;provoke disk read
	ret
CPIR:	jmp	boot

;	Read from disk buffer, replenish buffer when empty.

DIRE:	push	bx		;save 3 8080 register pairs
	push	dx		;
	push	cx		;
	ld	bx,RX		;pointer to current byte
	cmp	bx,RY		;skip if equal
	jnz	DI5		;still have bytes in the buffer
	ld	cl,#20		;<read next record>
	ld	dx,#TFCB	;file control block
	int	bdos		;
	ld	bx,#TBUF+TSIZ	;end of buffer
	sto	bx,RY		;store it in ry
	ld	bx,#TBUF	;beginning of buffer
	sto	bx,RX		;store it in rx
DI5:	ld	al,[bx]		;common continuation
	inc	bx		;byte in acc, advance pointer
	sto	bx,RX		;store position of next byte
	pop	cx		;replace 3 register pairs
	pop	dx		;
	pop	bx		;
	ret

;	================
;	= main program =
;	================

MAIN:	mov	ax,cs
	mov	ss,ax
	ld	sp,#STAK
	ld	bx,#ZE		;
	sto	bx,PD		;mark bottom of pushdown list
	ld	al,TFCB+1
	cmp	al,#' '
	jz	tylo
	ld	cx,#HSIZ
	ld	bx,#TALT
pual:	push	[bx]		;save secondary file name
	inc	bx
	inc	bx
	loop	pual
	call	CPIN		;open disk file for REC program
	ld	bx,#DIRE	;REC input through disk
	sto	bx,read		;REC compiler's I-O linkage
	call	INRE		;initialize REC compiler RAM
	call	EMCX		;compile the program file
	ld	cx,#HSIZ
	ld	bx,#TFCB+FSIZ
	pop	dx
poal:	dec	bx
	dec	bx
	pop	[bx]
	loop	poal
	push	dx
	call	EMCU		;execute the program file
	jmps	bootie		;return to CP/M if false
	nop			;beware jump span
bootie:	jmp	boot		;or even if it was true
tylo:	ld	cl,#9		;(09) write message
	ld	dx,#logo
	int	bdos
nodi:	call	bure
	call	INRE
	call	EMCX
	call	EMCU
	jmps	nodi
	nop
	jmp	nodi

;	(C) REC compiling operator which takes the designation
;	of the compiling source from the PDL. The alternatives
;	are:
;
;	      ''C		input program from console
;	    'file' 'D' C	take <file.rec> from disk D
;	       pC		pushdown list
;	       qC		workspace
;	    <org,siz,C>		memory from address org onward
;
;	In general, if the top argument is of length zero, the
;	console is the source, if it is of length one the named
;	disk is the source [@=current disk, A, B, ... up to the
;	system's limit], and if the argument has length 2, the
;	combination of <org, siz> from the memory applies.  It
;	is the programmer's responsibility to avoid nonexistent
;	memory, disk units, and the like.

UCC:	ld	ax,PY
	sub	ax,PX
	jz	UC2		;zero means console
	cmp	ax,#1		;test for one byte
	jz	UC1		;one means disk designation
	cmp	ax,#2		;verify that we've got two bytes
	jnz	UC7		;no provision for other than 1, 2 bytes
	ld	bx,#PTY		;setup readin from pseudoteletype
	sto	bx,read		;
	call	CXLD		;load two numerical arguments
	ld	dx,[bx]		;bx contains PX for second argument
	sto	dx,RX		;origin of REC source code
	add	dx,cx		;length of source code
	sto	dx,RY		;end of source code
	jmp	UC4		;compile once rx, ry set up
UC1:	call	DIIN		;setup the CP/M FCB for given file
	ld	bx,#DIRE	;setup input from disk reader
	jmp	UC3		;compile once input source set up
UC2:	ld	bx,#CHIN	;input from the console
UC3:	sto	bx,read		;
UC4:	call	UCL
	ld	cx,PY
	sub	cx,PX
	cmp	cx,#0
	jnz	UC5
	ld	dx,C1
	jmp	UC6
UC5:	cmp	cx,#2
	jnz	UC7
	ld	bx,PX
	ld	dx,[bx]
	push	dx
	call	UCL
	pop	dx
	cmp	dx,C0
	jc	UC6
	cmp	C2,dx
	jc	UC6
	sto	dx,C1
UC6:	push	dx
	call	LEFT
	call	RECRR
	push	dx
	call	PUTW
	call	PUTW
	ret
UC7:	call	RER

;	(x)  Call a REC subroutine

go:	ld	bx,PX
	call	onel
	ret


;	======= here is the table of definitions of REC operators =====

FT:	dw	NOOP		;blank
	dw	NOOP
	dw	RECOP		; !	binary to hex string
	dw	HX
	dw	RECDQ		; "	quoted expression
	dw	QU
	dw	RECOP		; #	binary to decimal string
	dw	NS
	dw	RECOP		; $	fetch a variable cell
	dw	VBLE
	dw	RECOP		; %	restrict to one byte
	dw	PE
	dw	RECOP		; &	exchange top numeric pair
	dw	EXCH
	dw	RECSQ		; '	quoted expression
	dw	QU
	dw	RECLP		; (
	dw	NOOP
	dw	RECRP		; )
	dw	NOOP
	dw	RECOP		; *	multiply
	dw	MPY
	dw	RECOP		; +	add
	dw	SUM
	dw	NOOP		; ,	separator like space
	dw	NOOP
	dw	RECMS		; -	subtract
	dw	DIF
	dw	RECOP		; .
	dw	NOOP
	dw	RECOP		; /	divide [remainder, quotient]
	dw	DVD
	dw	RECDD		; 0	number
	dw	NU
	dw	RECDD		; 1	number
	dw	NU
	dw	RECDD		; 2	number
	dw	NU
	dw	RECDD		; 3	number
	dw	NU
	dw	RECDD		; 4	number
	dw	NU
	dw	RECDD		; 5	number
	dw	NU
	dw	RECDD		; 6	number
	dw	NU
	dw	RECDD		; 7	number
	dw	NU
	dw	RECDD		; 8	number
	dw	NU
	dw	RECDD		; 9	number
	dw	NU
	dw	RECCO		; :
	dw	NOOP
	dw	RECSC		; ;
	dw	NOOP
	dw	RECOP		; <	restrict workspace
	dw	BRA
	dw	RECPR		; =	test equality of top pair
	dw	EQL
	dw	RECOP		; >	open workspace
	dw	KET
	dw	RECPR		; ?	test for error report
	dw	QM
	dw	RECP1		; @	execute subroutine
	dw	AR
	dw	RECPR		; A	advance pointer 1
	dw	UCA
	dw	RECPR		; B	retract pointer 1
	dw	UCB
	dw	RECOP		; C	compile
	dw	UCC
	dw	RECOP		; D	delete text
	dw	UCD
	dw	RECPR		; E	equality between WS and PD
	dw	UCE
	dw	RECPR		; F	find specified text
	dw	UCF
	dw	RECOP		; G	fetch a block from memory
	dw	GA
	dw	RECPR		; H	ASCII hex to binary
	dw	HE
	dw	RECOP		; I	insert
	dw	UCI
	dw	RECOP		; J	jump to front
	dw	UCJ
	dw	RECOP		; K	call CP/M, keep (dx), put value
	dw	CPM
	dw	RECOP		; L	erase top of PDL
	dw	UCL
	dw	RECPR		; M	compare PDL and workspace
	dw	UCM
	dw	RECPR		; N	numerical comparison
	dw	UCN
	dw	RECPR		; O	decimal ASCII string to binary
	dw	UCO
	dw	RECOP		; P	put block into buffered memory
	dw	UCP
	dw	RECOP		; Q	put workspace segment on PD
	dw	UCQ
	dw	RECOP		; R	read from keyboard
	dw	UCR
	dw	RECOP		; S	store block in memory
	dw	SA
	dw	RECOP		; T	write on screen
	dw	UCT
	dw	RECPR		; U	search, yielding interval
	dw	UCU
	dw	RECPR		; V	U, including endpoints
	dw	UCV
	dw	RECOP		; W	write on printer
	dw	UCW
	dw	RECOP		; X	call library subroutine
	dw	LIBR
	dw	RECPR		; Y	recover previous position of p1
	dw	UCY
	dw	RECOP		; Z	pointer 2 to end of text
	dw	UCZ
	dw	RECCM		; [	comment
	dw	NOOP
	dw	RECOP		; \	insert single byte in pair
	dw	IP
	dw	RECOP		; ]
	dw	NOOP
	dw	RECOP		; ^	increment top argument
	dw	INCR
	dw	RECOP		; _	exit to monitor
	dw	boot
	dw	RECPR		; `	true for waiting character
	dw	CHAW
	dw	RECPR		; a	segment forward from p1
	dw	LCA
	dw	RECPR		; b	segment backward from p2
	dw	LCB
	dw	RECOP		; c	create block on PDL
	dw	BLOK
	dw	RECPR		; d 	decrement but skip on zero
	dw	decR
	dw	RECPR		; e	extend workspace
	dw	LCE
	dw	RECPR		; f	block fill
	dw	LCF
	dw	RECOP		; g	non-incrementing byte fetch
	dw	GB
	dw	RECOP		; h
	dw	NOOP
	dw	RECOP		; i	input from designated port
	dw	LCI
	dw	RECOP		; j	null interval at p1
	dw	LCJ
	dw	RECOP		; k	call CP/M: no returned values
	dw	CPML
	dw	RECOP		; l	put pz on PDL
	dw	Lcl
	dw	RECOP		; m	set aside top argument
	dw	LCM
	dw	RECOP		; n	recover set-aside argument
	dw	LCN
	dw	RECOP		; o	output from designated port
	dw	LCO
	dw	RECOP		; p	put px, py-px on PDL
	dw	GXS
	dw	RECOP		; q	put p1, p2-p1 on PDL
	dw	LCQ
	dw	RECOP		; r	indirect replacement of address
	dw	IND
	dw	RECOP		; s	store block in memory wrt limit
	dw	LCS
	dw	RECOP		; t	type out indicated interval
	dw	LCT
	dw	RECOP		; u	incrementing byte fetch
	dw	GBI
	dw	RECOP		; v	incrementing byte store
	dw	SAI
	dw	RECOP		; w	store workspace header
	dw	LCW
	dw	RECPR		; x	subroutine jump  - no arguments
	dw	GO
	dw	RECOP		; y	fetch byte pair to PDL incr org
	dw	GWI
	dw	RECOP		; z	null interval at p2
	dw	LCZ
	dw	LBR		; {	start a definition string
	dw	NOOP
	dw	RECOP		; |	concatinate top two arguments
	dw	CONC
	dw	RECOP		; }	end a definition string
	dw	NOOP
	dw	RECOP		; ~	complement or negate top arg
	dw	COMP
	dw	RECOP		; del
	dw	NOOP

ENDREC:	ds	0

;	Program locations and memory allocations.  Here is where
;	the memory is sectioned up into its functional components.

STAK	equ	0FFEEH		;8086's pushdown stack

EW	equ	STAK-0800H	;end of the workspace
WS	equ	0C000H		;beginning of the workspace

EK	equ	WS		;end of the compiling area
KA	equ	06000H		;beginning of the compiling area

VT	equ	KA-0400H	;directory for programs compiled by REC

EP	equ	VT		;end of the pushdown list
PD	equ	ENDREC		;beginning of the pushdown list

	END	MAIN


