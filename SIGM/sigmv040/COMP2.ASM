;                COMP2.ASM as of April 29, 1981
; 
;  This  routine is extracted and CP/Mified from an  article 
; 'An  Inroduction  to Data Compression' by  Harold  Corbin, 
; that appeared in the April 1981 issue of Byte magazine.
; 
; CP/Mified by: Kelly Smith, CP/M-Net "SYSOP" April 29, 1981
; 
;  COMP2  (text  compression  routine) takes  keyboard  text 
; (uppercase  letters  ONLY) and compresses them  using  the 
; Huffman coding technique.  The first two bytes in the data 
; buffer (dbuf) are the bit count. Encoded data is stored in 
; the data buffer in packed form, 8 bits to the data byte.
; 
;  The Huffman Code was derived for the following table,  by 
; the  relative frequency of occurence in a random  sampling 
; of English text.  Frequently used characters are  assigned 
; shorter  bit 'code' patterns,  and seldom used  characters 
; are  assigned longer bit 'code' patterns.  Note:  with any 
; set of codes generated, it is important that no code has a 
; shorter code as part of its beginning. For example, if the 
; letter  'E'  is 100,  then 10010 cannot be  the  code  for 
; another  letter...because in scanning the bit stream  from 
; left  to right (using EXP2,  the text expansion  routine), 
; the decoding algorithm would think that 10010 is 'E' (100) 
; followed  by  10  and NOT the different  letter  that  was 
; intended.
; 
;           Letter    Frequency (%)  Huffman Code
; 
;           E         13.0           100
;           T         10.5           001
;           A          8.1           1111
;           O          7.9           1110
;           N          7.1           1100
;           R          6.8           1011
;           I          6.3           1010
;           S          6.1           0110
;           H          5.2           0101
;           D          3.8           11011
;           L          3.4           01111
;           F          2.9           01001
;           C          2.7           01000
;           M          2.5           00011
;           U          2.4           00010
;           G          2.0           00001
;           Y          1.9           00000
;           P          1.9           110101
;           W          1.5           011101
;           B          1.4           011100
;           V           .9           1101001
;           K           .4           110100011
;           X           .15          110100001
;           J           .13          110100000
;           Q           .11          1101000101
;           Z           .07          1101000100
; 
;  The  COMP2  program  takes  characters  entered  via  the 
; keyboard,  checks for a legal character, finds the Huffman 
; Code  corresponding  to  the entered  character,  and  the 
; serial  bit stream that results from the encoding  process 
; is packed and stored 8 bits to the byte.
; 
;  The heart of the program's operation is the table  lookup 
; and shifting function.  Based upon a letter ASCII code, an 
; index  is computed that is then added to the base  address 
; of  the  encoding  table.  This table  has  the  following 
; format: two 8 bit words are required for each letter to be 
; encoded;  the low order 4 bits of the first word in memory 
; contain  a count of the number of bits required to  encode 
; the  letter.  The remaining 12 bits,  8 in the second byte 
; followed  by 4 in the top half of the first byte are  used 
; to  store the compressed code.  The code is  stored  left-
; justified in the 12 bit word.
; 
;  With  the compressing code located,  it is serialized  by 
; shifting  left according to the count in the 4 bit part of 
; the table. As each bit is shifted out, the total bit count 
; in  the  buffer is updated.  The processing of  the  input 
; stream  continues  until a period  (.)  is  detected,  and 
; control  returns to CP/M.  The data buffer at address 4000 
; Hex then remains intact for expansion by EXP2.
; 
; 
; 
true	equ	-1	; define true
false	equ	not true; define false
;
stdcpm	equ	true	; true if regular CP/M (base address 0000h)
altcpm	equ	false	; true if alternate CP/M (base address 4200h)
;
	if	stdcpm	; if standard CP/M...
base	equ	0000h	; bsae for standard CP/M system
	endif		; end if...
;
	if	altcpm	; if alternate CP/M...
base	equ	4200h	; base for H8 or TRS-80 CP/M system
	endif		; end if...
;
bdos	equ	base+5	; CP/M BDOS entry address for function call
;
rdcon	equ	1	; read console character
;
dbuf	equ	04000h	; data buffer for compressed data
;
	org	base+100h

start:	lxi	h,0	; save "old" CP/M stack pointer
	shld	dbuf	; clear compressed bit count
	dad	sp
	shld	oldstk
	lxi	sp,stack; make "new" stack pointer
	lxi	h,dbuf+2; store pointer to next bit location in data buffer
	shld	dadd
	xra	a	; clear bit position
	sta	pos
;
; get character from keyboard, check if end of text '.' character
;
get$character:
;
	push	b	; save reigisters
	push	d
	push	h
	mvi	c,rdcon	; read console character function
	call	bdos
	pop	h	; restore registers
	pop	d
	pop	b
	ani	07fh	; mask-off parity bit
	cpi	'.'	; end of text?
	jnz	process	; if not, process this character
	lhld	dadd	; clean up partial byte remaining
	lda	pos	; compute remaining shift count
	mov	b,a
	mvi	a,8
	sub	b
	ani	7
	mov	b,a	; keep shift count
	mov	a,m	; get compressed byte
shift:	jz	exit	; exit to CP/M, if all bytes processed
	ral
	dcr	b
	mov	m,a	; replace compressed byte
	jmp	shift	; loop 'till done
process:sui	'A'	; character < 'A'?
	jc	get$character
	cpi	'Z'-'A'+1	; character > 'Z'?
	jnc	get$character
	add	a	; multiply by 2 to get table index
	mov	c,a
	mvi	b,0	; make index bias to table
	lxi	h,compression$table	; point to base of table
	dad	b	; add index bias to table pointer
	mov	e,m	; get encoded value
	inx	h
	mov	d,m
	mov	a,e	; get bit count for this character
	ani	00fh	; mask-off high nibble
	mov	b,a	; keep bit count
	xchg		; swap pointer for encoded value
next:	xra	a
	dad	h	; shift out bit stream...
	ral		; ...MSB first
	ani	1	; mask-off all but output bit
	push	h
	lhld	dadd	; get pointer to next bit location
	mov	d,a
	lda	pos	; get current bit position
	mov	e,a	; keep it
	mov	a,m	; get "old" compressed data
	ral		; make room...
	ora	d	; ...compress
	mov	m,a	; save it, done with this compression
	inr	e	; update position
	mov	a,e
	cpi	8	; full byte processed?
	jnz	stor
	xra	a	; clear position
	inx	h	; bump for next bit location
	shld	dadd
stor:	sta	pos
	lhld	dbuf	; update compressed bit count
	inx	h
	shld	dbuf
	pop	h
	dcr	b	; de-bump count
	jnz	next	; continue compression, if not done
	jmp	get$character	; get next character, and compress
;
exit:	lhld	oldstk	; get "old" CP/M stack pointer
	sphl		; and restore...
	ret		; return to CP/M
;
compression$table:
;
	dw	0f004h	; 'A'
	dw	07006h	; 'B'
	dw	04005h	; 'C'
	dw	0d805h	; 'D'
	dw	08003h	; 'E'
	dw	04805h	; 'F'
	dw	00805h	; 'G'
	dw	05004h	; 'H'
	dw	0a004h	; 'I'
	dw	0d009h	; 'J'
	dw	0d189h	; 'K'
	dw	07805h	; 'L'
	dw	01805h	; 'M'
	dw	0c004h	; 'N'
	dw	0e004h	; 'O'
	dw	0d406h	; 'P'
	dw	0d14ah	; 'Q'
	dw	0b004h	; 'R'
	dw	06004h	; 'S'
	dw	02003h	; 'T'
	dw	01005h	; 'U'
	dw	0d207h	; 'V'
	dw	07406h	; 'W'
	dw	0d089h	; 'X'
	dw	00005h	; 'Y'
	dw	0d10ah	; 'Z'
;
dadd:	dw	0	; next bit location
;
pos:	ds	1	; current bit location
;
oldstk:	ds	2	; storage for "old" CP/M stack pointer
	ds	32	; storage for 16 level stack
stack	equ	$	; top of local stack
;
	end	start
