;
; title		Wordmaster patch for VDM-1
; filename	wmpat.asm
; author	Robert A. Van Valzah   3/14/79
; last revisor	R. A. V.  11/11/79
; reason	revised for word master 1.06, added routine
;		to actually do a carriage return when needed
;
screen	equ	0cc00h
;
; These equates must be set by disassembling a virgin copy
; of wordmaster to find present values.
;
pastwm	equ	29b8h	;value dw'd in pbegmem
;
;
	org	180h	;clear screen and home
	push	h	;save wm reg h
	lxi	h,screen
	shld	cursor
clr:
	mvi	m,' '
	inx	h
	mov	a,h
	cpi	(screen shr 8)+4
	jnz	clr
	jmp	morclr	;cont'd below
;
	org	196h
tcursor:
	push	h	;save line & cold
	call	csoff
	pop	h
	push	h
	push	d
	lxi	d,screen
	mov	a,h	;save col
	mvi	h,0	;multiply line by 64
	rept	6
	  dad	h
	endm
	dad	d	;add displacement to screen base
	add	l	;add col to line
	mov	l,a
	call	cson
	pop	d
	pop	h
	ret
;
	org	1b7h	;patch in new end of memory to take into account
	dw	neweom	;added code
	db	16	;patch in new hight of 25 lines
	db	64	;patch in new line length
	db	0	;no erase to end of line
;
	org	1c1h	;patch out all delays
	db	0, 0, 0
;
	org	pastwm	;org to patch area
morclr:
	lxi	h,screen
	call	cson
	pop	h	;restore wm's reg h
	lda	initdone
	ora	a
	rnz
	push	h	;save wm's reg h
	mvi	a,0ffh	;set init done flag
	sta	initdone
	lhld	1
	inx	h
	push	h	;save address of address field of
	mov	a,m	;boot jmp in cbios table
	inx	h
	mov	h,m
	mov	l,a
	shld	oldboot	;save old boot routine address
	pop	h
	mvi	m,low(boot) ;poke address of out boot routine
	inx	h
	mvi	m,high(boot)
	lhld	1	;as above for co jump
	mvi	l,0dh
	push	h	;save address of co jump
	mov	a,m
	inx	h
	mov	h,m
	mov	l,a
	shld	oldco
	pop	h
	mvi	m,low(outch)
	inx	h
	mvi	m,high(outch)
	pop	h	;restore wm's reg h
	ret
;
boot:	;resore old boot and co jumps
	lhld	oldboot
	xchg
	lhld	1
	inx	h
	mov	m,e
	inx	h
	mov	m,d
	lhld	oldco
	xchg
	lhld	1
	mvi	l,0dh
	mov	m,e
	inx	h
	mov	m,d
	jmp	0
;
outch:
	push	h	;save wm's reg h
	call	csoff	;off with old cursor
	mov	a,c
	cpi	10	;new line?
	jz	lf	;yes
	cpi	13	;carriage return?
	jz	cr
	mov	m,c	;no put new chr on screen
	inx	h
onret:			;turn on cursor & return
	call	cson
	pop	h	;restore wm's reg h
	ret
cr:
	mov	a,l	;move cursor to start of line
	ani	255-63
	mov	l,a
	jmp	onret	;and return
lf:			;process line feed char
	inx	h	;move cursor to start of next line
	mov	a,l
	ani	63
	jnz	lf
	mov	a,h	;off end of screen?
	cpi	(screen shr 8)+4
	jnz	onret	;no - just return
	push	d	;yes - scroll
	lxi	h,screen
	lxi	d,screen+40h
movup:
	ldax	d
	mov	m,a
	inx	d
	inx	h
	mov	a,d
	cpi	(screen shr 8)+4
	jnz	movup
	push	h	;blank new line
blnk:
	mvi	m,' '
	inx	h
	mov	a,h
	cpi	(screen shr 8)+4
	jnz	blnk
	pop	h
	pop	d
	jmp	onret
;
csoff:
	lhld	cursor
	mov	a,m
	ani	7fh
	mov	m,a
	ret
;
cson:
	shld	cursor
	mov	a,m
	ori	80h
	mov	m,a
	ret
;
initdone db	0
oldco	ds	2
oldboot	ds	2
cursor	ds	2
;
neweom:
;
	end
