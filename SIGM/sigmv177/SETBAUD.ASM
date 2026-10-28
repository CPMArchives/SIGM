;SETBAUD.ASM v 1.00 as of 08/21/83
; Written and released to the public domain by
; S. Kluger, El Paso RCPM
;
; This program is currently written for the Compupro
; Interfacer 4 using relative ports 1 and 2.
; Relative port 3 is covered by BAUDRATE.ASM
;
; It does the following:
;
; Displays a menu of baud rates on the screen and asks for
; your choice of baud rate.
; After pressing the key of your choice, the program will
; initialize the desired port to the desired baud rate.
;
; General EQU's
;
tpa	equ	100h
bdos	equ	5
print	equ	9
getch	equ	1
cr	equ	0dh
lf	equ	0ah
cls	equ	26	;your clear-screen byte
;
; Interfacer 4 equates (the necessary ones only)
;
base	equ	10h	;base port address
mode	equ	base+2	;mode port
select	equ	base+7
offset	equ	4	;offset rel -> abs
modem	equ	offset+2	;modem port
aux	equ	offset+1	;auxiliary port
mode1	equ	6eh	;mode1 byte
mode2	equ	70h	;mode2 byte less baud rate
;
	org	tpa
;
start:	lxi	h,0
	dad	sp
	shld	stksave	;save stack
	lxi	sp,stack
	lxi	d,menu
tryagn:	mvi	c,print
	call	bdos
	mvi	c,getch
	call	bdos
	call	ucase
	cpi	'A'
	jc	error
	cpi	'Q'
	jnc	error
	sui	10h	;make range '1'..'?'
	sta	p1
;
; now, ask for port
;
inv:	lxi	d,which
	mvi	c,print
	call	bdos
	mvi	c,getch
	call	bdos
	call	ucase
	cpi	'A'
	mvi	b,aux
	jz	setusart
	cpi	'M'
	jnz	inv
	mvi	b,modem
;
; now, the USART has to be initialized...
;
setusart:
	mov	a,b
	out	select
	mvi	a,mode1
	out	mode
	mvi	b,mode2
	lda	p1		;get baud rate
	ani	0fh		;strip high nybble
	dcr	a
	ora	b		;finish mode2
	out	mode		;done!
;
	lhld	stksave		;get CP/M stack back
	sphl
	ret
;
; ucase routine
;
ucase:	cpi	'a'
	rc
	sui	20h
	ret
;
; Come here in case of error
;
error:	lxi	d,ermenu
	jmp	tryagn
;
; setterm - terminal init string
;
; this is the baud rate menu
;
ermenu:	db	7,7,7,7,7,7,7
menu:	db	cls,cr,lf
	db	'Press  To change to baud rate:',cr,lf
	db	'  A       50',cr,lf
	db	'  B       75',cr,lf
	db	'  C      110',cr,lf
	db	'  D      135',cr,lf
	db	'  E      150',cr,lf
	db	'  F      300',cr,lf
	db	'  G      600',cr,lf
	db	'  H     1200',cr,lf
	db	'  I     1800',cr,lf
	db	'  J     2000',cr,lf
	db	'  K     2400',cr,lf
	db	'  L     3600',cr,lf
	db	'  M     4800',cr,lf
	db	'  N     7200',cr,lf
	db	'  O     9600',cr,lf
	db	'  P    19200',cr,lf,lf,lf
	db	'Your choice : $'
;
which:	db	cr,lf
	db	'Press A for AUX port, or',cr,lf
	db	'press M for MODEM port :$'
;
p1:	db	0
;
stksave:dw	0
	ds	50
stack:	equ	$
	end
	'Press A for AUX port, 