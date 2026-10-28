;
;	this program returns the amount
;	of free space in the tpa.
;	this can be useful when running under
;	fast, despool, ddt, sid, etc.
;
;	version of 8/30/80
;
;
;	by Ron Fowler	
;	   Westland, Mich.
;	   8/24/80
;
;	   fixes and code optimizations by
;	   Keith Petersen
;
	org	100h
;
base:	lxi	h,0
	dad	sp	;get local stack
	lxi	sp,stack
	push	h	;save old stack
	lhld	6	;get the top of memory
	xchg		;put it in de
	push	d	;save it for later
	lxi	h,-100h ;get the start of mem
	dad	d	;subtract it, answer left in hl
	call	decout	;print it
	call	tb1	;print the rest of line
	db	' bytes total tpa space.',13,10,'$'
;
tb1:	mvi	c,9	;print msg function
	pop	d	;get msg adrs
	call	5	;print it
	pop	d	;get top of memory back
	lxi	H,-(800h+100h) ;ccp size + tpa
	dad	d	;subtract it, answer left in hl
	call	decout	;print it
	call	tb2	;print rest of line
	db	' bytes before overlaying the ccp.',13,10,'$'
;
tb2:	mvi	c,9	;print msg function
	pop	d	;get msg adrs
	call	5	;print it
	pop	h	;restore ccp stack
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
	end
