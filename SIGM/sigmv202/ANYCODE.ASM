
; ANYCODE.ASM - A program to allow printer codes to be 
;	        transmitted to EPSON or other dot matrix 
;	        printer from within WordStar text.
;
;	    Author:  D. M. Hurst
;	    Date:    March 3, 1984
;
	ORG	02BBh	;WS 2.26/3.0 (02DEh) WS 3.3 (02BBh)
;
mysub:	cpi	'`'	;is it a code character?
                        ;you may sub " ` " if you use the
                        ;" ` " often in your text 
	jnz	ncheck	;no, so next check
	sta	lead	;yes, so store temporarily
	mvi	a,1	;get a 1 in accumulator
	sta	fl	;set fl flag
	ret		;get another character
			;without printing
ncheck: cpi	'~'	;is it other code character?
	jnz	hcheck	;no, so check if part of
			;code sequence
	sta	lead	;yes so store temporarily 
	mvi	a,1	;get a 1 in accumulator
	sta	fl	;set fl flag
	mvi	a,1bh	;~ means escape required so 
	jmp	pout	;send it.
hcheck: mov	b,a	;set input char aside
	lda	lead	;get contents of lead
	cpi	'`'	;are we in a code seq?
	mov	a,b	;char back in accumulator
	jz	flchk	;yes, so check if flag set
	mov	b,a	;no, so char back to b
	lda	lead	;check lead again
	cpi	'~'	;are we in a code seq?
	mov	a,b	;char back in accumulator
	jz	flchk	;yes, so check if flag set	
	jmp	pout	;no, so print char normally
flchk:	mov	b,a	;set char aside again
	lda	fl	;get fl flag
	cpi	00h	;1 if set set
	mov	a,b	;char back in accumulator
	jz	addsnd	;not set, so last char in seq
	mov	b,a	;yes, so set char aside again		
	mvi	a,00h	;no, so place 00h in accumulator
	sta	fl	;and lower the flag
	mov	a,b	;char back in accumulator	
        cpi	39h	;is code char a letter?
        jm	nolet1  ;no, so never mind 
        sui	07h	;yes, so make it a number
nolet1:	sui	30h	;now down it form ASCII
	rlc		;first char in code so 
	rlc		;move 4 low bits to high
	rlc
	rlc
	ani	0f0h	;0 4 lower bits
	sta	first	;store it
	ret		;go get second char code
addsnd:	mov	b,a	;set 2nd code char aside
	mvi	a,00	;0 the accumulator
	lxi	h,lead	;get lead addr pointer in hl
	mov	m,a	;0 out the lead
	inx	h	;up the hl
	mov	m,a	;also 0 the flag
	mov	a,b	;get char back
	cpi	39h	;was 2nd code char a letter?
	jm	nolet2	;so so skip it
	sui	07h	;yes so make it a number
nolet2:	sui	30h	;now down either from ASCII
	lxi	h,first	;point to first code char addr
	mov	b,m	;move actual char to b
	add	b	;add a to b (result in a)
pout:	mvi	c,5	;print full code char
	mov	e,a
	call	5
	ret		;back for next real char
;
lead	ds	1	;space for lead code
fl	ds	1	;flag space
first	ds	1	;store first code while
			;waiting for 2nd to pro-
			;cess.
	end
