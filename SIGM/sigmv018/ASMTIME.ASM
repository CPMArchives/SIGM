; 
; 
;  Here  is  an  interesting  "patch"  to  Digital  Research's 
; ASM.COM, that incorporates a "real time clock display.  This 
; patch   works with ASM.COM version 2.0 ONLY.  Merge it  into 
; ASM.COM as follows:
; 
;      A>DDT ASM.COM<cr>
;      NEXT   PC
;      2100  0100
;      -IASMTIME.HEX<cr>
;      -R<cr>
;      NEXT   PC
;      22BE  0000
;      -^C
;      A>SAVE 34 ASMTIME.COM<cr>
; 
;  Now  you have a new "ASM" command file called  ASMTIME.COM; 
; now  re-assemble  ASMTIME.ASM (assuming your  clock/calendar 
; board, and the time is properly set) with ASMTIME.COM.
; 
;  Notice,  that  the date and time will be displayed  at  the 
; start  of execution.
; 
;                         Best regards,
;           
;                         Kelly Smith, MP/M-Net (tm) Sysop
;                         (805) 527-9321 (Modem, 300 Baud)
;
;
;
; For Compu-Time T-102 TIME/DATE board (With MM 5375 AC)
;
; or,
;
; QT Computer Systems Inc. "Clock/Calendar +" board
;
;
true	equ	-1	; define true
false	equ	not true; define false
qt	equ	true	; define QT Computer Systems Inc. board
ct	equ	false	; define Compu-Time board

bdos	equ	5
pbuf	equ	9

cr	equ	0dh	; ASCII carriage return
lf	equ	0ah	; ASCII line feed

asm	equ	200h	; entry address to ASM.COM

overlay	equ	0fa0h	; overlay area in ASM.COM

	if	qt

clock	equ	080h	; real time clock base port address

	endif

	if	ct

clock	equ	024h	; real time clock base port address

	endif

	org	109h

	jmp	date	; jump to set date and time

	org	2100h	; date and time routine

date:	lxi	h,month	; point to month
	mvi	d,8	; select month tens digit
	call	digit	; read and store high digit
	rlc ! rlc ! rlc ! rlc	; shift to high order hex digit
	mov	b,a	; save in b reg.
	call	digit	; read and store month units digit
	ora	b	; or-in the units and tens digit
	mov	b,a	; save the month in b reg.
	call	digit	; read and store the day tens digit
	rlc ! rlc ! rlc ! rlc	; shift to high order hex digit
	mov	c,a	; save in c reg.
	call	digit	; read and store day units digit
	ora	c	; or-in the units and tens digit
	mov	c,a	; save the day in c reg.

;
; test the date, and convert it to four year calendar format
;

	cpi	031h	; 31st day?
	mov	a,b	; get the month, for next test
	jnz	m2	; if not the 31st, test for february
	cpi	2	; test for months < 31 days
	jz	fix	; ...and fix if needed
	cpi	4
	jz	fix
	cpi	6
	jz	fix
	cpi	9
	jz	fix
	cpi	011h
	jz	fix
m2:	cpi	2	; test for february
	jnz	time	; if not february, then read time
	mov	a,c	; get day for test
	cpi	029h	; is this the 29th day?

;
; insert two NOP's over previous instruction, if this is a leap year
;
	jz	fix	; fix date...
	cpi	030h	; 30th day?
	jnz	time	; if not the 29th or 30th, go read time
fix:	mvi	a,41	; select month units and fast set
	call	rdigit	; read the month units digit
	mov	b,a	; save in b reg.
floop:	in	clock	; read the months unit digit
	cmp	b	; test for digit changed
	jz	floop	; wait until month is bumped (stable data)
time:	lxi	h,hour	; point to hour
	mvi	d,0	; select hour tens digit
	call	ddigit	; read hour tens and units
	inx	h	; step over ":"
	call	ddigit	; read minutes tens and units
	inx	h	; step over ":"
	call	ddigit	; read second tens and units
	lda	month	; get high byte of the month
	cpi	' '	; in the range of january to september?
	jz	jansept
	lda	month+1	; must be october to december...
	cpi	'0'	; october?
	lxi	d,oct
	jz	mmonth	; move, if so
	cpi	'1'	; november?
	lxi	d,nov
	jz	mmonth	; move, if so
	lxi	d,dec	; december!
	jmp	mmonth	; move it...
jansept:lda	month+1	; it's january to september
	cpi	'1'	; january?
	lxi	d,jan
	jz	mmonth	; move, if so
	cpi	'2'	; february?
	lxi	d,feb
	jz	mmonth	; move, if so
	cpi	'3'	; march?
	lxi	d,mar
	jz	mmonth	; move, if so
	cpi	'4'	; april?
	lxi	d,apr
	jz	mmonth	; move, if so
	cpi	'5'	; may?
	lxi	d,may
	jz	mmonth	; move, if so
	cpi	'6'	; june?
	lxi	d,jun
	jz	mmonth	; move month
	cpi	'7'	; july?
	lxi	d,jul
	jz	mmonth	; move, if so
	cpi	'8'	; august?
	lxi	d,aug
	jz	mmonth	; move, if so
	lxi	d,sep	; it's september
mmonth:	mvi	b,4	; four characters to move
	lxi	h,fakem	; place to move real month
movem:	ldax	d	; get the character to move
	mov	m,a	; move it
	inx	h	; bump both pointers
	inx	d
	dcr	b	; de-bump the count left to move..
	jnz	movem	; loop 'till all characters moved
	lxi	h,overlay		; point to overlay area
	lxi	d,fakem		; point to stuff to be moved
	mvi	b,end$move-start$move	; how much to move...
move1:	ldax	d	; get stuff to move
	mov	m,a	; move it...
	inx	h	; bump both pointers
	inx	d
	dcr	b	; de-bump the move counter
	jnz	move1	; loop 'till it's all moved
done:	jmp	asm	; now jump into ASM...

ddigit:	call	digit	; read and store two digits
digit:	mov	a,d	; move digit select code to a reg.
	call	rdigit	; read a clock digit
	cpi	0ffh	; test for board present
	jz	nobrd	; go print error message
	ori	030h	; convert digit to ASCII
	cpi	03fh	; test for blanked leading zero
	jnz	store	; go store digit, if not blanked
	mvi	a,020h	; convert to a blank
store:	mov	m,a	; store the digit in message buffer
	inx	h	; bump message pointer buffer location
	inr	d	; step to next digit
	ani	00fh	; mask off high ASCII nibble
	ret		; return with digit in a reg.

nobrd:	pop	h	; adjust the stack
	lxi	d,errmsg; point to the error message
	mvi	c,pbuf	; print buffer function
	call	bdos	; let CP/M do the work
	jmp	done	; print error message, and exit to CP/M

rdigit:	out	clock	; select digit
	mvi	a,0	; ...some delay time for settling
dloop:	dcr	a
	jnz	dloop
	in	clock	; read a digit
	ret		; return with digit in a reg.

;
; message buffers
;

start$move	equ	$	; start moving from here
fakem:	ds	2	; storage for faked-out month,
			; which will overlay the next four bytes
month:	ds	4	; storage for the real month and date
	db	',1980 '; the year...
hour:	db	'xx:'	; the hour...
	db	'xx:'	; the minute...
	db	'xx'	; the second...
	db	0dh	; string delimeter
end$move	equ	$	; end of move

errmsg:	db	cr,lf,'The Clock Board is NOT INSTALLED!',cr,lf,'$'

jan:	db	'Jan '
feb:	db	'Feb '
mar:	db	'Mar '
apr:	db	'Apr '
may:	db	'May '
jun:	db	'Jun '
jul:	db	'Jul '
Aug:	db	'Aug '
sep:	db	'Sep '
oct:	db	'Oct '
nov:	db	'Nov '
dec:	db	'Dec '

	end

