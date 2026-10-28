;	MODULE NAME:  PASSWORD.ASM
;	LAST UPDATE:  15 DEC 84          BY: PEC
;	FUNCTION:     SECURITY PASSWORD FOR CP/M 2.2
;======================================================================

;	ASCII CHARACTERS

	CR	EQU	0DH	; CARRIAGE RETURN
	LF	EQU	0AH	; LINE FEED
	BYPASS	EQU	1AH	; CONTROL-Z, FOR INTERRUPT
	BDOS	EQU	5	; BDOS entry point
	DRIVE	EQU	4	; current drive number
	LOCKUP	EQU	7eh+15h	; will lock up keyboard of Hazeltine
				; Esprit
	TAB	EQU	09h	; horizontal tab

	ORG	100H	; TRANSIENT PROGRAMME AREA
;
savecpm:
	lxi	h,0	; save the CP/M stack
	dad	sp	; and the stack pointer
	shld	CPMSP
	lxi	sp,stack	; set up local stack
	lda	DRIVE	; save current disk
	sta	DRSAV
;
;	CLEAR SCREEN
;
	mvi	b,3	; use Register B as a counter
	call	clear
signon:
	lxi	d,msg1	; point to first message
	call	sprint	; and print it
	call	crlf	; space down
;
;	INPUT SECTION
;
getnom:	lxi	h,text	; point to the text
input:	mvi	e,0ffh	; initialise function 6 for input
	mvi	c,6
	push	h
	push	b
	call	BDOS	; and ask for character from console
	pop	b
	pop	h
	ora	a	; logical OR of Register A
	jz	input	; if zero then loop until key pressed
	cpi	BYPASS
	jz	DONE	; quit if a CONTROL-Z
	call	clcuc	; convert to upper case
	mov	m,a	; else put character into memory
	inx	h	; get ready for next character
	cpi	CR	; was it Return
	jz	check	; if so compare with PASSWORD
	jmp	input	; else loop
;
;	CHECK THE NAME
;
check:	lxi	d,name	; point to the permitted name
	lxi	h,text
match:	ldax	d	; character from NAME
	cpi	'$'	; finished yet?
	jz	pass	; ok then print welcome message
	cmp	m	; else compare with memory
	jnz	fail	; if not matched, then quit
	inx	d
	inx	h
	jmp	match	; else continue
;
;	OUTPUT SECTION
;
pass:	mvi	b,3	; re-set the counter
read:	lxi	h,text	; point to start of message
	call	crlf	; and space down
	push	h
	push	b
	lxi	d,msg3	; print welcome message
	mvi	c,9
	call	BDOS
	pop	b
	pop	h
it:	mov	a,m	; get character
	call	print	; and print to screen
	inx	h	; point to next character
	cpi	CR	; are we finished ?
	jz	id	; then get second message
;
	jmp	it	; else read another character
;
;
;	ID Number section
;
id:	lxi	d,msg2	; get second message
	call	sprint
	call	crlf
getid:	lxi	h,text2	; prepare buffer for ID Number
input2:	mvi	e,0ffh	; initialise function 6 for input
	push	b
	mvi	c,6
	push	h
	call	BDOS	; and ask for character from console
	pop	h
	pop	b
	ora	a	; logical OR of Register A
	jz	input2	; if zero then loop until key pressed
	cpi	BYPASS
	cz	DONE	; quit if CONTROL-Z
	mov	m,a	; else put character into memory
	inx	h	; get ready for next character
	cpi	CR	; was it Return
	jz	check2	; if so compare with ID Number
	jmp	input2	; else loop
;
check2:	lxi	d,number	; point to the permitted ID number
	lxi	h,text2
match2:	ldax	d	; character from NAME
	cpi	'$'	; finished yet?
	jz	success	; ok then print welcome message
	cmp	m	; else compare with memory
	jnz	fail2	; if not matched, then quit
	inx	d
	inx	h
	jmp	match2	; else continue
;
;	SUBROUTINES
;
;	CLCUC.ASM
;
;	convert lower case to upper case
;
;	entry:	A - character to convert
;	exit:	A - converted to upper case
;
clcuc:	cpi	'a'	; compare to "a"
	rc		; return if less than "a"
	cpi	'z'+1	; see if larger than "z"
	rnc		; not lower case, so quit
	sui	'a'-'A'	; change "a...z" into "A...Z"
	ret
;
;	CLEAR SCREEN - for Hazeltine Esprit
;
clear:	mvi	a,7eh	; tilde
	call	print
	mvi	a,1ch
	call	print
	ret
;
sprint:	push	h
	push	b
	mvi	c,9	;set up string print function
	call	BDOS	; call BDOS to do it
	pop	b
	pop	h
	ret
;
crlf:	push	psw	; save Register A
	mvi	a,CR	; return
	call	print
	mvi	a,LF	; line feed
	call	print
	pop	psw
	ret		; done
;
lfadj:	mvi	m,LF	; add line feed to memory
	inx	h	; increment the pointer
	ret
;
print:	mov	e,a	; put character into Register E
	push	b
	mvi	c,6	; initialise print routine
	push	psw
	push	h
	call	BDOS	; and do it
	pop	h
	pop	psw
	pop	b
	ret		; done
;
success:
	lxi	d,startup
	call	sprint
	call	DONE
;
fail:	dcr	b	; count down 1
	jnz	retry
	lxi	d,signoff
	call	sprint	; quit
	jmp	getnom
;
fail2:	dcr	b	; count down 1
	jnz	retry2
	lxi	d,signoff
	call	sprint	; quit
	jmp	getnom
;
retry:	call	clear
	lxi	d,again
	call	sprint
	jmp	getnom
;
retry2:	call	clear
	lxi	d,again2
	call	sprint
	jmp	getid
;
DONE:	lda	DRSAV	; return to CP/M without re-boot
	sta	DRIVE	; restore current disk
	lhld	CPMSP	; restore CP/M stack
	sphl
	ret
;
;	MESSAGES
;
again	db	CR,LF,'You missed that time, please try again'
	db	CR,LF,CR,LF
msg1	db	TAB,TAB,'PASSWORD - a programme to provide a secure'
	db	CR,LF,TAB,TAB,'sign on system for CP/M 2.2',CR,LF,LF
	db	'This programme does not print to screen.'
	db	CR,LF,'Enter your name please - ',CR,LF
	db	'Then type <RETURN> to allow check to be made.'
	db	CR,LF,'$'
again2	db	CR,LF,'You missed that time, please try again'
	db	CR,LF
msg2	db	CR,LF,CR,LF,'Now enter your ID Number - ',CR,LF,'$'
msg3	db	CR,LF,'Welcome $'
name	db	'NAME$'
number	db	'123$'
signoff	db	CR,LF,'You are not authorised to use the computer,'
	db	' goodbye now',LOCKUP,'$'
startup	db	CR,LF,'You are authorised to start now, go ahead$'
;
;	LOCAL STORAGE SPACE
;
DRSAV	db	0	; current drive number
CPMSP	dw	0	; CP/M stack pointer
;
	ds	20h	; 32-byte stack
stack:
;
text	equ	$	; begin message here
text2	equ	$+128	; begin second message for ID Number
;
	end
	
		
			a,