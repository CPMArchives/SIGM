	public	strip, vowel, sl

;	entry	p1 -> char to be stripped
;
strip:
	call	getp1
	mov	a,m		; get char
	ani	7fh		; strip msb
	cpi	'a'		; and convert to upper case
	jc	st1
	cpi	'z'+1
	jnc	st1
	ani	01011111b
st1:
	mov	m,a		; restore character
	ret
;
;	entry:	p1 -> character to be compared with vowels
;
vowel:
	call	getp1
	mov	a,m		; get char
	irp	char,<'A','E','I','O','U'>
	cpi	char
	jz	rtrue
	endm
	xra	a		; return zero
	ret
rtrue:	mvi	a,80h		; return '1'b to PL/I
	ret
;
; sl moves a four character array left one character
; 	entry:	p1 -> first character of array char (4)
sl:
	call	getp1
	mov	e,l		; copy address into de
	mov	d,h
	inx	h
	mov	a,m		; get character
	stax	d		; put it back but down one
	inx	h
	inx	d
	mov	a,m
	stax	d
	inx	h
	inx	d
	mov	a,m
	stax	d
	ret

getp1:
	mov	e,m		; get address of parameter
	inx	h
	mov	d,m
	xchg			; address now in hl
	ret

	end
