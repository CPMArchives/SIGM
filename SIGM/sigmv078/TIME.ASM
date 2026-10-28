.TITLE	'Print time and date on console'
;
base	=	50H	; base port address
clkcmd	=	base+10	; clock command
clkdta	=	base+11	; clock data
bdos	=	5	; CP/M
read	=	10H
write	=	20H
hold	=	40H	; hold bit
;
; Sign on message
;
start:	lxi	d,signon
	call	pmsg		; say HI
;
; edit and print time and date
;
clkprt:	lxi	h,atable
	call	print2		; first 2 digits
	mvi	a,':'
	call	pchar
	call	print2
	mvi	a,':'
	call	pchar
	call	print2
	mvi	a,' '
	push	psw
	call	pchar
	pop	psw
	call	pchar		; print 2 spaces
	call	print2
	mvi	a,'/'
	call	pchar
	call	print2
	mvi	a,'/'
	call	pchar
	call	print2		; print last 2 digits
	ret
;
; print two digits from clock
;
print2:	mov	a,m
	call	rddgt
	adi	30H		; ascii convers
	call	pchar
	inx	h
	mov	a,m
	call	rddgt
	adi	30H
	call	pchar
	inx	h
	ret
;
; read clock and mask bits
;
rddgt:	adi	read		; set read bit
	out	clkcmd
	cpi	read+5		; hours 10 digit
	in	clkdta		; get digit
	rnz			; ..not so done
	sui	08H
	ret
;
; CP/M interface
;
pchar:	push	d
	mov	e,a
	mvi	c,2
	push	h
	call	bdos
	pop	h
	pop	d
	ret
;
pmsg:	push	h
	mvi	c,9
	call	bdos
	pop	h
	ret
;
; message texts
;
signon:
	.ascii	'The time and date are: $'
;
; digit address table
;
atable:	.byte	5,4,3,2,1,0,8,7,0AH,9,0CH,0BH
;
	.end	start
