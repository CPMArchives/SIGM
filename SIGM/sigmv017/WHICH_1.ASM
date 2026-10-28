;	which.asm
;
;	this program returns size and version
;	of cp/m you are running.
;	this can be useful when running under
;	fast, despool, ddt, sid, etc.
;
;	version of 25 nov 1980
;
;	by David Fiedler
;	   InfoPro Systems
;	   Denville, NJ

;	Copyright 1980 InfoPro Systems.  This program may
;	not be used for commercial purposes without written
;	permission from InfoPro Systems.  However it may
;	be used by hackers to their heart's content as long
;	as they don't try to sell it or pass it off as their
;	own.
;
;	Please note that this has not been tried out under
;	other than CP/M 2.2, although it should work fine.
;
;	code adapted from tpa3.asm by:
;	   Ron Fowler	
;	   Westland, Mich.
;
;	   fixes and code optimizations to tpa3 by
;	   Keith Petersen
;
;	conditional assemblies added for Micropolis Mod II CP/M
;	   by Ray Glueck 1/12/81
;
;
false	equ	0
true	equ	not false
;
stdcpm	equ	false
microp	equ	true
;
	org	100h
;
base:	lxi	h,0
	dad	sp	;get local stack
	shld	oldstk	;save old stack

	call	tb
msg:	db	'Welcome to $'

tb:	mvi	c,9	;print msg function
	pop	d	;get msg adrs
	call	5	;print it

	mvi	c,12	;get version number function
	call	5
	shld	retword	;hold for later
	mov	a,h	;multi-tasking?
	cpi	1
	jz	mpm	;yes.
	mvi	a,'C'	;no.
	sta	versms	;so announce properly
	jmp	getsiz
mpm:
	mvi	a,'M'
	sta	versms
		
getsiz:	lhld	6	;get the bdos address
	xchg		;into de
	lhld	retword
	mov	a,l
	cpi	0
	jnz	newone
	lxi	h,-3100h	;get 16k bdos address for cp/m 1.4
	dad	d		;subtract it, answer left in hl
	if stdcpm
	lxi	d,(16 * 1024)	;this would print 16k if addresses were equal
	endif
	if microp
	lxi	d,(17 * 1024)
	endif
	dad	d		;not efficient but clear at least
	jmp	print
newone:	
	lxi	h,-3c00h	;20k bdos offset for 2.0
	dad	d
	if stdcpm
	lxi	d,(20 * 1024)
	endif
	if microp
	lxi	d,(21 * 1024)
	endif
	dad	d
print:	
	mov	a,h
	rrc			;divide by 2
	rrc			;divide by 4
	ani	7fh		;mask to positive
	mov	l,a		;effectively divide by 2 ^ 8
	mvi	h,0		;for a total of 2 ^ 10 = 1K
	call	decout		;print it
	call	tb1		;print the line
sizems:	db	'K '
versms:	db	' P/M Version $'
;
;
tb1:	mvi	c,9	;print msg function
	pop	d	;get msg adrs
	call	5	;print it
;
getnum:
	lhld	retword
	mov	a,l
	cpi	0	;previous to 2.2?
	jz	oldone	;yes.
	push	psw	;save value
	ani	0f0h	;get high nibble
	rrc
	rrc
	rrc
	rrc		;into low nibble
	adi	'0'	;make ascii
	call	co	;print
	mvi	a,'.'
	call	co
	pop	psw	;retrieve lower four bits
	ani	0fh	;mask them
	adi	'0'
	call	co
	call	tb2
	db	13,10,'$'
;
oldone:
	call	tb2
	db	'1.4',13,10,'$'
;
;
tb2:	mvi	c,9	;print msg function
	pop	d	;get msg adrs
	call	5	;print it
	lhld	oldstk	;restore ccp stack
	sphl
	ret		;back to the ccp
;
;	subroutines
;
; Console output routine
;	prints character in 'a' register
;
co:	push	h
	push	d
	push	b
	mov	e,a	;character to e for CP/M
	mvi	c,2	;print console function
	call	5	;print character
	pop	b
	pop	d
	pop	h
	ret
;
; Decimal output routine
;	this routine has following
;	entry and external parameters:
;
;	   entry:    hl=binary number to print in decimal
;	   external calls: co routine
;	   ** note...this routine is recursive, and uses
;	   6 bytes of stack for each recursive call, in ad-
;	   dition to any stack space used by the co routine.
;
decout: push	b
	push	d
	push	h
	lxi	b,-10
	lxi	d,-1
;
decou2: dad	b
	inx	d
	jc	decou2
	lxi	b,10
	dad	b
	xchg
	mov	a,h
	ora	l
	cnz	decout
	mov	a,e
	adi	'0'
	call	co
	pop	h
	pop	d
	pop	b
	ret
;
stack	equ	$+80	;40 level stack
;
oldstk:	ds	2
retword:ds	2

	end	base
