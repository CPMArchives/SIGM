;SETBAUD.ASM v 2.00 as of 01/19/84
; Written and released to the public domain by
; S. Kluger, El Paso RCPM
;
; This program is currently written for the Compupro
; Interfacer 4 using relative ports 1,2, and 3.
; If your CONSOLE port is on the IF4, you can specify
; the relative port at assembly time (default 7) so it
; will prompt for keypress before changing the console
; baud rate.
;
; SETBAUD v2.00 is a total rewrite of SETBAUD 1.00 of 8/21/83
; and works in two modes, automatic and prompted.
;
; In automatic mode, the two parameters have to be typed on the
; command line. If no errors are found, the port specified will
; be set to the specified baud rate. If the command line is
; empty or contains an error, then SETBAUD will display a short
; message and prompt for baud rate and port.
;
; Command syntax:
; A>setbaud[ rate port]
; where 'rate' is a valid baud rate, and 'port' is the number of
; the relative port (5, 6, or 7).
;
; General EQU's
;
cr	equ	0dh
lf	equ	0ah
cbaud	equ	5dh		;baudrate in command line
cport	equ	6dh		;port in command line
;
; Interfacer 4 equates (the necessary ones only)
;
base	equ	10h		;base port address
data	equ	base		;data port
mode	equ	base+2		;mode port
cmd	equ	base+3		;command port
select	equ	base+7
mode1	equ	6eh		;mode1 byte
mode2	equ	70h		;mode2 byte less baud rate
commd	equ	27h		;command byte (SETBAUD turns DTR on)
offset	equ	0		;offset from default (I.e. leave if
;			your ports are 4-7. set to 4 if ports 8-11,
;			or set to 0FCH if ports 0-3. Default is 4-7.
console	equ	7		;set this to your console port if the
;			IF4 is used for console I/O, else set to 0
;
; This program makes use of SYSLIB. Thanks, Rick Conn!
;
	extrn	eval10,comphd,print,bbline,cin
;
start:	lxi	h,0
	dad	sp
	shld	stksave		;save stack
	lxi	sp,stack
	call	print		;say who we are, praise our creator
	db	cr,lf
	db	'SETBAUD v2.00 by S. Kluger 1-18-84',cr,lf
	db	'For CompuPro Interfacer 4.',cr,lf,0
	lxi	h,cbaud		;point to baud rate
	mov	a,m		;is something there?
	cpi	' '		;maybe not???
	jz	menu		;well, then assist him a bit.
	call	eval10		;return binary value in DE
	call	getbrv		;get the baud rate into c. CY=error
	jc	errb		;go say he messed up
	lxi	h,cport		;now check the port
ckport:	mov	a,m		;get it
	cpi	'5'		;see if in range
	jc	errp		;boo if less..
	cpi	'8'
	jnc	errp		;...or too big
	ani	0fh		;make it binary
	adi	offset		;add offset from normal
	mov	b,a		;save it
	inx	h
	mov	a,m		;more junk there?
	cpi	' '
	jz	setu		;nope, finish up
	ora	a		;a null maybe?
	jnz	errp		;no, complain!
;
; now, the USART has to be initialized...
;
setu:	mvi	a,console
	cmp	b
	jnz	nocon
	call	print
	db	cr,lf
	db	'Ready - now hit any key to change baud rates',0
	call	cin
nocon:	mov	a,b		;b holds the port
	out	select
	mvi	a,mode1
	out	mode
	mvi	a,mode2
	ora	c		;finish mode2
	out	mode		;done!
	mvi	a,commd		;now turn DTR on
	out	cmd
	in	data		;flush usart
;
exit:	call	print
	db	cr,lf
	db	'*** FUNCTION COMPLETE ***',cr,lf,0
	lhld	stksave		;get CP/M stack back
	sphl
	ret
;
errb:	call	print
	db	cr,lf,7
	db	'COMMAND ERROR - invalid baud rate.',cr,lf,0
	jmp	menu
;
errp:	call	print
	db	cr,lf,7
	db	'COMMAND ERROR - invalid port number -- restart.',cr,lf,0
menu:	call	print
	db	cr,lf
	db	'Valid baud rates for Interfacer 4 are:',cr,lf,lf
	db	9,'  50       75      110      134',cr,lf
	db	9,' 150      300      600     1200',cr,lf
	db	9,'1800     2000     2400     3600',cr,lf
	db	9,'4800     7200     9600    19200',cr,lf,lf
	db	'Your choice ? ',0
	call	bbline
	call	eval10
	call	getbrv
	jc	errb
	call	print
	db	cr,lf,lf
	db	'Enter relative port number (5, 6, or 7) : ',0
	call	bbline
	jmp	ckport
;
; get baud rate value
;
getbrv:	mvi	c,0fh		;first baud rate
	lxi	h,table		;point to baud rate table
gbloop:	mov	b,m		;get low byte
	inx	h
	mov	a,m		;get high byte
	inx	h
	push	h		;save pointer
	mov	h,a		;table value...
	mov	l,b		;...into hl
	call	comphd		;compare
	pop	h		;restore pointer
	rz			;return if found
	dcr	c		;decrement baud rate counter
	jp	gbloop		;until it turns negative
	stc			;report error
	ret
;
; baud rate table
;
table:	dw	19200,9600,7200,4800,3600,2400,2000,1800
	dw	1200,600,300,150,134,110,75,50
;
stksave:dw	0
	ds	40
stack:	equ	$
	end
lf