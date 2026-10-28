
;	=======================================================
;
;	REC module for the operators and predicates pertaining
;	to the pushdown list, other than the most important
;	ones already contained in the REC nucleus.  These
;	comprise:
;
;		arithmetic
;
;			+	sum modulo 2**16
;			-	difference modulo 2**16
;			*	product modulo 2**16
;			/	remainder, quotient
;			=	equality
;			~	complement or negative
;			d	decrement, false on zero
;			^	increment
;			N	comparison of top 2 args
;
;		modification of arguments
;
;			H	hex ASCII string to binary
;			!	binary to hex ASCII string
;			%	restrict argument to one byte
;			\	embed argument in two bytes
;			&	exchange top arguments
;			|	concatinate top arguments
;
;		block movements
;
;			G	fetch a block from memory
;			g	address fetch
;			r	replace address by contents
;			u	incrementing byte fetch
;			y	incrementing word fetch
;			P	put buffer block in memory
;			S	store block in memory
;			s	store into buffer
;			v	incrementing byte store
;			m	move arg to end of PDL space
;			n	recover arg from end of PDL
;
;		generate pointers
;
;			c	reserve block, generate pointer
;			p	put px, py-px on PDL
;			l	put pz on PDL
;			$	form addr of variable cell
;
;	-------------------------------------------------------
;	Version of REC released during the summer school, 1980
;	-------------------------------------------------------
;
;		 PDL86  -  Copyright (C) 1982
;		Universidad Autonoma de Puebla
;		     All Rights Reserved
;
;	     [Harold V. McIntosh, 25 April 1982]
;
;	May 29, 1983 - & exchanges arbitrary arguments
;	May 29, 1983 - ~ discontinued; use m&n instead
;	May 29, 1983 - ~ Complement or Negate top element
;	May 29, 1983 - N for Numerical comparison on PDL
;	July 7, 1983 - $ with char arg gets subroutine addr
;	=======================================================

;	=======================================================
;	A collection of subroutines for two-byte arithmetic,
;	including loading and storage of the 8080 registers
;	from the pushdown list.
;	=======================================================

;	-------------------------------------------------------
;	Load and store subroutines for 2-byte arithmetic.
;	-------------------------------------------------------

;	Push a one-byte value onto the PDL.  The value to be
;	pushed should be placed on the 8080's stack in the
;	low byte position (say by using <push psw>) before
;	calling PUON.

PUON:	ld	cx,#1		;one byte is required
	call	NARG		;close old variable, reserve space
	pop	bp		;source was pushed before calling
	pop	ax
	sto	al,[bx]		;store byte, which is low order
	inc	bx		;pointer to next byte
	sto	bx,PY		;close new argument
	jmp	bp

;	Push a two-byte value onto the PDL.  The value to be
;	pushed should be placed on the 8080's stack before
;	calling PUTW.

PUTW:	ld	cx,#2		;two bytes are required
	call	NARG		;close old variable, reserve space
	mov	bp,sp
	ld	ax,[bp+2]
	sto	ax,[bx]		;store low order byte
	inc	bx		;on to high order destination
	inc	bx		;always leave pointer in good condition
	sto	bx,PY		;close top argument
	ret	2

;	(&) Exchange top two arguments, assumed two-byte.

EXCH:	ld	ax,PY
	ld	bx,PX		;org1
	sub	ax,bx		;siz1
	ld	dx,[bx-2]	;org2
	lea	cx,[bx-2]
	sub	cx,dx		;siz2
	cmp	ax,cx
	jnz	XTNE
	jcxz	XTRE
XTEQ:	ld	al,[bx]
	xchg	bx,dx
	ld	ah,[bx]
	sto	al,[bx]
	xchg	bx,dx
	sto	ah,[bx]
	inc	bx
	inc	dx
	loop	XTEQ
XTRE:	ret
XTNE:	push	cx
	push	dx
	push	bx
	push	ax
	push	dx
	call	NARG
	mov	ax,ds
	mov	es,ax
	cld
	mov	di,bx
	pop	si
	rep
	movsb
	pop	cx
	pop	si
	pop	di
	push	di
	rep
	movsb
	pop	[di]
	lea	di,[di+2]
	ld	si,PX
	sto	di,PX
	pop	cx
	rep
	movsb
	sto	di,PY
	ret

;	Load top three arguments into (cx),(dx),(bx).  In
;	reality so many permutations exist for places to put
;	the arguments as they are taken off the REC stack that
;	they are simply transferred to the 8080 stack, to be
;	popped into the desired registers on return from the
;	corresponding call.  It is assumed that all quantities
;	involved in these transactions are of two bytes.  A
;	sequence of entry points is provided so as to pop off
;	one, two, or three arguments.

THRG:	ld	bx,PX		;get pointer to top argument
THRL:	pop	bp		;enter here if (bx) already loaded
	push	[bx]
	push	bp
	call	UCL		;pop top argument, load (bx) from px
TWOL:	pop	bp		;continue, or entry for two args
	push	[bx]
	push	bp
	call	UCL		;pop argument, put px in (bx)
ONEL:	pop	bp		;continue, or entry for one argument
	push	[bx]
	push	bp
	jmp	UCL		;pop the last argument, quit

;	Load up pointers to top two arguments.

ARGG:	ld	di,PX		;org1
	ld	cx,[di-2]
	jcxz	arge		;no second argument
	ld	ax,PY
	sub	ax,di		;siz1
	mov	bx,cx		;org2
	lea	dx,[di-2]
	mov	cx,dx
	sub	cx,bx		;siz2
	cmp	cx,ax
	jnz	arge		;arguments not same length
	ret
ARGE:	call	rer
ARGS:	call	ARGG
	sto	bx,PX
	sto	dx,PY
	ret

;	-------------------------------------------------------
;	Two-byte arithmetic according to the four operations.
;	-------------------------------------------------------

;	(+)  Add top registers on pdl: <a,b,+> leaves (a+b).
;	The sum is calculated modulo 2**16, no evidence of any
;	overflow remains behind.

SUM:	call	args
	cmp	ax,#01
	jz	SUM1
	cmp	ax,#02
	jz	SUM2
	call	rer
SUM1:	ld	al,[di]
	or	[bx],al
	ret
SUM2:	ld	ax,[di]
	add	[bx],ax
	ret

;	(-)  Subtract top from next: <a,b,-> leaves (a-b).
;	Reverse subtraction can be accomplished by exchanging
;	arguments: write <a,b,&,-> to get (b-a).  Subtraction
;	is carried out modulo 2**16; thus -1 = FFFF hex.

DIF:	call	args
	cmp	ax,#01
	jz	DIF1
	cmp	ax,#02
	jz	DIF2
	call	rer
DIF1:	ld	al,[di]
	xor	[bx],al
	ret
DIF2:	ld	ax,[di]
	sub	[bx],ax
	ret

;	(*)  Multiply top: <a,b,*> leaves (a*b).  The product
;	is for integer arithmetic, modulo 2**16, and so is not
;	directly suitable for a 32-bit product.

MPY:	call	args
	cmp	ax,#01
	jz	MPY1
	cmp	ax,#02
	jz	MPY2
	call	rer
MPY1:	ld	al,[di]
	and	[bx],al
	ret
MPY2:	ld	ax,[di]
	mul	[bx]
	sto	ax,[bx]
	ret

;	(/)  Divide top: <a,b,/> leaves rem(a/b), int(a/b).
;	Reverse division is possible by exchanging arguments;
;	thus <b,a,&,/> leaves rem(b/a), int(b/a).  If just
;	the remainder is required, write <a,b,/,L>, while if
;	only the quotient is desired, write <a,b,/,&,L>, and
;	finally, if the order of the remainder and quotient is
;	not satisfactory, they can be exchanged.  The division
;	is unsigned integer division.  It can also be used to
;	split a two-byte word into two parts through division
;	by the corresponding power of two.

DVD:	call	ARGG
	cmp	[di],#0000
	jz	DER
	ld	ax,[bx]
	ld	dx,#0000
	div	[di]
	sto	ax,[di]
	sto	dx,[bx]
	ret
DER:	call	RER

;	(~)  Complement or Negate the top of the pushdown list.

comp:	ld	bx,PX
	ld	cx,PY
	sub	cx,bx
	cmp	ax,#01
	jz	com1
	cmp	ax,#02
	jz	com2
	call	rer
com1:	notb	[bx]
	ret
com2:	neg	[bx]
	ret

;	(^)  Increment the top of the pushdown list.

INCR:	ld	bx,PX		;pointer to argument
	inc	[bx]
	ret

;	(d)  Decrement top of PDL if it is not zero; otherwise
;	FALSE, erasing the counter.  Equivalent to ((0=;1-)).

DECR:	ld	bx,PX		;fetch pointer to argument
	sub	[bx],#1		;dec won't work because of c flag
	jc	DCF
	jmp	SKP		;no carry means TRUE
DCF:	jmp	UCL		;when FALSE, erase counter

;	(N) Numerical comparison of top two elements on PDL. <a,b,N>
;	is TRUE if a .LE. b; both arguments are erased irrespective
;	of the result.  Numerical comparison is for integers; for one-
;	byte arguments the comparison is logical.

UCN:	call	args
	cmp	ax,#01
	jz	UN1
	cmp	ax,#02
	jz	UN2
	call	rer
UN1:	ld	al,[di]
	test	al,[bx]
	jz	UNF
	jmp	UNT
UN2:	ld	ax,[di]
	cmp	ax,[bx]
	jz	UNF
UNT:	jmp	CUCL
UNF:	jmp	UCL

;	-------------------------------------------------------
;	Conversion between binary and hexadecimal ASCII strings
;	-------------------------------------------------------

;	Return if not hexadecimal. A unchanged if not hex, else
;	reduced to binary.

RNH:	cmp	al,#'G'		;no hex characters beyond F
	jnc	RH2
	cmp	al,#'A'		;hex letters equal A or beyond
	jc	RH1
	sub	al,#'7'		;compensate the gap between 9 and A
	ret
RH1:	jmp	RND
RH2:	inc	sp
	inc	sp
	ret

;	Cummulation to convert a hex ASCII string to binary.

HXP:	add	bx,bx		;shift left 4 bits
	add	bx,bx		;
	add	bx,bx		;
	add	bx,bx		;
	or	bl,al		;or in the nibble in the accumulator
	ret

;	(H) Convert a hex ASCII string on the PDL into binary.
;	Whatever the length of the argument, conversion will be
;	made to a two-byte binary number.  Thus, if more than
;	four hex digits are present, the result will be reduced
;	modulo 2**16.  It should be noted that the conversion
;	starts with the first byte of the argument and procedes
;	onward.

HE:	ld	cx,#2		;two bytes required for result
	call	OARG		;check if they are available
	ld	bx,PY		;fetch terminal address of string
	stob	#ZE,[bx]	;zero signals its end
	ld	dx,PX		;fetch beginning of string
	ld	bx,#ZE		;place zero in (bx) to prime conversion
H1:	xchg	bx,dx
	ld	al,[bx]
	xchg	bx,dx		;fetch ASCII character
	inc	dx		;ready for the next one
	or	al,al		;check the terminator byte
	jz	H2		;when end reached, close off argument

	call	RNH		;if not hex digit, forget it all
	call	HXP		;otherwise times 16 plus new digit
	jmp	H1		;repeat the cycle
H2:	xchg	bx,dx		;binary number into (dx)
	ld	bx,PX		;place to store the result
	sto	dx,[bx]		;store low byte
	inc	bx		;on to high byte
	inc	bx		;pointer must always be one ahead
	sto	bx,PY		;store terminal address
	jmp	SKP		;TRUE return from predicate

;	(!)  Convert a two-byte binary number into an ASCII
;	string.  A one-byte number will also be converted, but
;	into two nibbles rather than four, to serve in some
;	applications where the leading zeroes are not wanted.

HX:	ld	cx,PY
	sub	cx,PX
	cmp	cx,#1		;see if it's one byte
	jnz	HS		;if not, continue elsewhere

HN:	ld	cx,#2		;two nibble result for 1 byte
	call	OARG		;see that there's that much space
	ld	bx,PX
	ld	dl,[bx]		;load low bit
	jmp	HSI		;
HS:	ld	cx,#4		;four nibble result for 2 bytes
	call	OARG		;be sure there's space for it
	ld	bx,PX		;pointer to first byte
	ld	dx,[bx]		;load low byte
	mov	al,dh		;separate high byte first
	call	HSA		;write out left nibble
	mov	al,dh		;high byte again
	call	HSB		;write out right nibble
HSI:	mov	al,dl		;separate low byte
	call	HSA		;write out left nibble
	mov	al,dl		;low byte second trip
	call	HSB		;write out right nibble
	sto	bx,PY		;store end of argument
	ret

HSA:	ROR	al		;shift byte right four bits
	ROR	al		;
	ROR	al		;
	ROR	al		;
HSB:	and	al,#0FH		;mask in right nibble
	add	al,#90H		;prepare for some carries from <daa>
	daa			;create gap if nibble beyond 10
	adc	al,#40H		;code for @ if we have a letter
	daa			;decide 3 for digit, 4 for letter
	sto	al,[bx]		;record the ASCII digit
	inc	bx		;pointer ready for next deposit
	ret

;	-------------------------------------------------------
;	Fetch and store bytes, addresses, and blocks to and fro
;	between the PDL and the memory.  The following chart
;	shows the relation between all the different operators
;	which are available.
;
;				byte	word	block
;				----	----	-----
;
;	replace			-	r	G
;	fetch, nonincement	g	-	-
;	fetch, increment	u	y	-
;
;	store			-	-	S
;	store, increment	-	-	v
;	store w.r.t. limit	-	-	s
;	store into buffer	-	-	P
;
;	variable head cell	-	$	-
;
;	The main operators for saving and fetching variables
;	are G and S.  The remainder were especially chosen
;	on the one hand to scrutinize the memory under REC
;	control, and on the other to give the widest possible
;	latitude in defining variables in applications of REC.
;
;	The following chart shows how to employ variables:
;
;	    'data' n$ S		define 2-byte variable
;	     n$ r		fetch 2-byte variable
;	    'data' ml n$ S	save fixed variable
;	     n$ ryG		fetch fixed variable
;	    'data' n$rs		redefine existing fixed var
;	     kc Lml n$ S	create k-byte buffered variable
;	     kc n$ S		alternative k-byte buffered var
;	    'data' n$r P	redefine buffered variable
;	     n$ ryLyG		fetch buffered variable
;
;	Memory can be examined bytewise with the following
;	combinations:
;
;	    org g		fetch a byte, keep origin
;	    org u		autoincrementing byte fetch
;	    org v		autoincrementing byte store
;	    org (g  ... v:;)	read, modify, store, ready next
;	    o1 o2 (u~...v&:;)	move from o1 to o2
;
;	-------------------------------------------------------

;	(g) (u)  Fetch a byte from memory and leave on PDL. The
;	sequence <org, g> leaves <org, (org)[1 byte]> on PDL.
;	The sequence <org, u> leaves <org+1, (org)[1 byte]> on
;	PDL.

GB:	ld	bx,PX		;/g/ pointer to top argument
	push	[bx]		;fetch low byte of origin
	jmp	GBJ		;if the origin is not to be incremented
GBI:	ld	bx,PX		;/u/ pointer to arg, which is org
	push	[bx]		;fetch low byte of origin
	inc	[bx]
GBJ:	ld	cx,#1		;require space for one byte
	call	NARG		;close old arg, check space, open new
	pop	dx		;here's the origin we saved
	xchg	bx,dx
	ld	al,[bx]
	xchg	bx,dx		;fetch the byte there
	sto	al,[bx]		;store on the PDL
	inc	bx		;pointer always ready for next byte
	sto	bx,PY		;right deliniter of argument
	ret

;	(y)  Fetch two bytes from memory and leave on PDL.
;	The sequence <org, y> leaves <org+2, (org)[2 bytes]>
;	on PDL.

GW:	ld	bx,PX		;/ / pointer to the argument
	push	[bx]		;low byte of origin
	jmp	GWJ		;common continuation of gw, gwi
GWI:	ld	bx,PX		;/y/ pointer to the argument
	push	[bx]		;place low byte in A
	add	[bx],#2		;origin to be incremented by 2
GWJ:	ld	cx,#2		;require space for two bytes
	call	NARG		;close old arg, check space, open new
	pop	dx		;now we're ready for that origin
	xchg	bx,dx
	ld	ax,[bx]
	xchg	bx,dx		;fetch the byte sitting there
	sto	ax,[bx]		;and store it on PDL
	inc	bx
	inc	bx		;keep the pointer moving along
	sto	bx,PY		;value's finished, store its end
	ret

;	(G)  Fetch a block from memory, leave on PDL.
;	<org,siz, G> leaves (org, ...) on PDL.

GA:	call	CXLD		;load siz into (cx)
	call	OARG		;reuse the argument, but with siz bytes
	ld	bx,PX		;fetch the destination address
	ld	si,[bx]		;but the source address is stored there
	cld
	mov	di,bx
	mov	ax,ds
	mov	es,ax
	rep
	movsb
	sto	di,PY		;(bx) holds the destination terminator
	ret

;	(S)  Store a block forward from the designated memory
;	location.  <'data' org S> stores 'data' starting at
;	org; leaves no residue on the PDL.

SA:	call	CXLD		;fetch destination origin
	mov	di,cx		;save it for a while
	ld	si,PX
	ld	cx,PY
	sub	cx,si
	cld
	mov	ax,ds
	mov	es,ax
	rep
	movsb
	jmp	UCL		;pop the second argument too

;	(v)  Store a block, leaving incremented address.
;	<org,'data' v> leaves org+size['data'] on PDL, stores
;	'data' starting from org.

SAI:	ld	si,PX
	ld	cx,PY
	sub	cx,si		;determine length of data
	call	UCL		;pop top argument, exposing second
	ld	di,[bx]		;(bx) has px, which is destn address
	mov	ax,ds
	mov	es,ax
	mov	ax,si
	add	ax,cx
	cmp	di,ax
	jc	LVB
	cld
	rep
	movsb
	sto	di,[bx]
	ret
LVB:	std
	add	si,cx
	add	di,cx
	sto	di,[bx]
	dec	si
	dec	di
	rep
	movsb
	ret

;	(s)  Store into an area of limited size. The sequence
;	<'data' org s> will store 'data' beginning at org+2,
;	supposing that siz('data') is less than or equal to
;	(org, org+1).  In either event no residue is left, but
;	an error notation is generated if the data doesn't fit.
;	No data at all is stored if all will not fit.  If it
;	matters to know how much of the space was used, the
;	operator P should probably be used instead.

LCS:	call	CXLD		;fetch destination origin
	mov	bx,cx		;save it while calling psiz
	ld	si,PX
	ld	cx,PY
	sub	cx,si		;determine length of data
	ld	ax,[bx]		;low byte of capacity
	cmp	ax,cx
	jnc	LST
	call	UCL
	call	RER		;note error, return if it won't fit
LST:	cld
	inc	bx
	inc	bx
	mov	di,bx
	mov	ax,ds
	mov	es,ax
	rep
	movsb
	jmp	UCL		;pop second argument

;	(P)  Store into a buffer and note length.  Used to
;	store data of variable length into an area whose
;	maximum length is fixed.  The buffer has the form
;
;	   /available/used/data/data/.../data/.../end/
;
;	The sequence <'data' org P> will store the data
;	in the buffer beginning at org. (org, org+1) holds
;	the maximum length of data that may be stored in the
;	buffer, (org+2, org+3) is siz('data'), and 'data' is
;	stored from org+4 onward if it will fit.  If it will
;	not, P is a noop and error is set.

UCP:	call	CXLD		;pointer to destination
	mov	bx,cx		;save destination while calling psiz
	ld	si,PX
	ld	cx,PY
	sub	cx,si		;load (cx) with length of data
	inc	cx		;data has to appear two bytes larger
	inc	cx		;to include cell showing its size
	ld	ax,[bx]		;low byte of destination capacity
	inc	bx		;
	inc	bx		;
	cmp	ax,cx
	jnc	UP1
	call	RER		;capacity exceeded: mark error, return
UP1:	dec	cx		;we want to store the true size
	dec	cx		;subtract out the two byte margin
	sto	cx,[bx]		;low byte into usage cell
	inc	bx		;just keep moving along
	inc	bx		;ready to start moving data
	cld
	mov	di,bx
	mov	ax,ds
	mov	es,ax
	rep
	movsb
	jmp	UCL		;lift second argument, leave nothing

;	(r)  Replace address on top of pdl by its contents.

IND:	ld	bx,PX		;pointer to top argument
	ld	dx,[bx]		;load low byte
	xchg	bx,dx		;(bx) now has top argument
	ld	ax,[bx]		;low byte of indirect address
	xchg	bx,dx		;address of top argument again
	sto	ax,[bx]		;store low indirect byte
	ret

;	($)  Generate the address of the nth cell in the array
;	of variables, which is a block of two-byte addresses.
;	These cells may be used to store data directly - for
;	example counters or addresses - or indirectly through
;	pointers to the actual location of the data.  By giving
;	a one-byte character argument, <'x'$>, the location where
;	the address of subroutine x is stored may be obtained.

VBLE:	ld	bx,PX		;pointer to argument
	ld	cx,PY
	sub	cx,bx
	cmp	cx,#2
	jz	VBLF
	ld	cx,#2
	call	OARG
	ld	bx,PX
	ld	al,[bx]
	ld	ah,#0
	jmp	VBLG
VBLF:	ld	ax,[bx]
VBLG:	add	ax,ax
	add	ax,VRT
	sto	ax,[bx]
	add	bx,#2
	sto	bx,PY
	ret

;	(l)  Load pz onto PDL.

LCL:	push	PZ		;putw requires arg on 8080 stack
	call	PUTW		;record two-byte argument
	ret			;can't use simply <jmp putw>

;	(m)  Set aside top argument on PDL.  It is moved to the
;	other end of the array reserved for the PDL, which can
;	be used as a temporary storage stack without name.  The
;	mechanism by which pz is moved and the block size is
;	recorded makes this an attractive mechanism to create
;	storage space for REC variables.

LCM:	ld	si,PY
	mov	cx,si
	sub	cx,PX		;get length of top argument
	push	cx
	call	UCL		;pop top argument
	ld	di,PZ		;load destination origin
	std
	dec	si
	dec	di
	mov	ax,ds
	mov	es,ax
	rep
	movsb
	lea	bx,[di-1]
	sto	bx,PZ
	pop	[bx]		;recover length
	ret

;	(n)  Recover segment which was set aside.

LCN:	ld	cx,#ZE		;there won't be any net length change
	call	NARG		;close old argument, ready for new
	mov	di,bx		;place destination origin in (dx)
	ld	bx,PZ		;place source origin in (bx)
	ld	cx,[bx]		;place length in cx
	lea	si,[bx+2]
	cld
	mov	ax,ds
	mov	es,ax
	rep
	movsb
	sto	di,PY		;end of destination is end of argument
	sto	si,PZ		;update pz
	ret

;	(|)  Concatinate the top arguments on the PDL.

CONC:	ld	si,PX
	ld	cx,PY
	sub	cx,si		;get length of top argument
	call	UCL		;pop top argument, set up pntrs to next
	mov	di,dx		;new py is destination
	cld
	mov	ax,ds
	mov	es,ax
	rep
	movsb
	sto	di,PY		;record new terminal address
	ret

;	(%)  Restrict multiple-byte argument to one byte.

PE:	ld	ax,PX
	cmp	ax,PY
	jz	PE1		;leave a null argument in peace
	inc	ax		;add one to it
	sto	ax,PY		;store as limit to the argument
PE1:	ret

;	(\)  Embed a single byte in a pair.

IP:	ld	cx,#2		;we want to have two bytes
	call	OARG		;verify that that much space remains
	ld	bx,PX		;pointer to argument
	inc	bx		;pass over first byte
	stob	#ZE,[bx]	;make high byte zero
	inc	bx		;pass on to next byte
	sto	bx,PY		;record end of argument
	ret

;	(p)  Put px and siz on the pushdown list.

GXS:	ld	dx,PX
	ld	bx,PY
	mov	cx,bx
	sub	cx,dx		;calculate length of top argument
	push	cx		;put length on 8080 stack
	push	dx		;put origin on 8080 stack
	call	PUTW		;put top of 8080 stack on REC PDL
	call	PUTW		;put the next item there too
	ret			;can't combine <call, ret> into <jmp>

;	(c) Reserve a block on the pushdown list. <n,c> creates
;	a block of length n, and puts n-2 at the front of the
;	block as a size indicator.  Then, if n .ge. 2, it will
;	be there as a length indicator for a buffer.   <=====maybe change this?

BLOK:	ld	bx,PX		;pointer to argument
	ld	cx,[bx]		;fetch the argument
	sto	cx,[bx]		;store header
	sub	[bx],#2
	call	OARG		;is there enough space to reuse arg?
	sto	bx,PY		;increment in (bx), it goes into py
	push	PX		;px has origin of block just formed
	call	PUTW		;record block origin as new argument
	ret			;can't replace <call putw, ret> by jmp

;	Load a single variable into (cx) from the pushdown
;	list.  No register is sure to be preserved.

CXLD:	ld	bx,PX		;pointer to argument
	ld	cx,[bx]		;fetch low order byte
	jmp	UCL		;erase argument [(cx) is unchanged]

;	Load register pair (dx) from the pushdown list.
;	(cx) will be preserved, (bx) not.

DXLD:	ld	bx,PX		;pointer to argument
	push	[bx]		;fetch word
	call	UCL		;erase argument
	pop	dx		;restore (dx) since UCL modified it
	ret

;	(=)  Test the two top arguments on the pushdown list
;	for equality.  The arguments may be of any length, but
;	will be equal only when of the same length and composed
;	of the same sequence of bytes. The top argument will be
;	popped whatever the outcome, but when equality is true
;	both will be popped.

EQL:	ld	di,PX		;under argument
	ld	cx,PY
	sub	cx,di		;obtain length of top argument
	call	UCL		;lift top argument
	ld	si,PX
	ld	bx,PY
	sub	bx,si
	cmp	bx,cx		;compare lengths
	jnz	EQF
	cld
	mov	ax,ds
	mov	es,ax
	repz
	cmpsb
	jnz	EQF
	jmp	CUCL		;both agree, erase second arg, TRUE
EQF:	ret			;disagree so FALSE

;	-------------------------------------------------------
;
;	Some of the service routines which are likely to be
;	external references in other modules are:
;
;		puon	push one byte on PDL
;		putw	push address on PDL
;		thrl	load  three arguments onto 8080 stack
;		twol	load two arguments onto 8080 stack
;		onel	load one argument onto 8080 stack
;		bcld	load (cx) from PDL, pop PDL
;		deld	load (dx) from PDL, pop PDL
;
;	-------------------------------------------------------

	LINK	MKV86.ASM

