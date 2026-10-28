; BAUDRATE.ASM ver 1.00 as of 07/27/83
; Written and released to the public domain by
; S. Kluger, El Paso RCPM
;
; This program is currently written for the Compupro
; Interfacer 4 driving a Televideo 950 terminal.
;
; I see no big use in this program, I mainly wrote it out of pure
; curiosity, since I just installed an Interfacer 4. If you feel
; any need for it, you're welcome to do with it whatever you want
; whenever you want, but if you modify and redistribute it,
; please leave your name in the source file.
;
; It does the following:
;
; Displays a menu of baud rates on the screen and asks for
; your choice of console baud rate.
; After pressing the key of your choice, the program will
; initialize first the terminal, then the computer console
; port to the desired baud rate.
;
; General EQU's
;
tpa	equ	100h
bdos	equ	5
print	equ	9
getch	equ	1
cr	equ	0dh
lf	equ	0ah
;
; Interfacer 4 equates (the necessary ones only)
;
base	equ	10h	;base port address
mode	equ	base+2	;mode port
select	equ	base+7
relusr	equ	3	;USART relative user number
offset	equ	4	;offset rel -> abs
usart	equ	relusr+offset	;actual USART number
mode1	equ	6eh	;mode1 byte
mode2	equ	70h	;mode2 byte less baud rate
;
; Terminal equates (for TVI 950)
; The sequence is ESC { p1 p2 p3 p4, where p1=baud rate,
;     p2=stop bits, p3=parity, p4=length.
;     p2..p4 are fixed.
;
esc	equ	27
cls	equ	26	;clear screen
prefix	equ	'{'
p2	equ	'0'	;1 stop bit
p3	equ	'0'	;no parity
p4	equ	'0'	;8 bits
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
	cpi	'P'
	jnc	error
;
; we have the response. Now, convert A to something
; more meaningful to the TVI 950 and send the command
; string to the terminal.
;
	sui	10h	;make range '1'..'?'
	sta	p1
	lxi	d,setterm
	mvi	c,print
	call	bdos
	call	delay
;
; now, the USART has to be initialized...
;
	mvi	a,usart
	out	select
	mvi	a,mode1
	out	mode
	mvi	b,mode2
	lda	p1		;get baud rate
	ani	0fh		;strip high nybble
;
; since the IF3/4 can do one better than the TVI950, we have to
;program around that fact. (The IF3/4 can do 2000 baud...)
;
	cpi	10
	jc	no2000
	inr	a
no2000:	dcr	a
	ora	b		;finish mode2
	out	mode		;done!
;
	lhld	stksave		;get CP/M stack back
	sphl
	ret
;
; delay routine. This routine is needed, since without it
; I experienced hangup problems in the terminal. Could be that
; the terminal doesn't get enough time to let the new baud rate
; take effect...
;
delay:	lxi	h,0ffffh
dely:	dcx	h
	mov	a,h
	ora	l
	jnz	dely
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
setterm:
	db	esc,prefix
p1:	db	0,p2,p3,p4,'$'
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
	db	'  J     2400',cr,lf
	db	'  K     3600',cr,lf
	db	'  L     4800',cr,lf
	db	'  M     7200',cr,lf
	db	'  N     9600',cr,lf
	db	'  O    19200',cr,lf,lf,lf
	db	'Your choice : $'
;
;
stksave:dw	0
	ds	50
stack:	equ	$
	end
	'  N     9600',cr,lf
	db	'  O    19200',cr,lf,lf,lf
	db	'Your choice : $'