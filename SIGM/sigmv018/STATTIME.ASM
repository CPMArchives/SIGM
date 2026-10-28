
	title	'STATTIME as of october 20, 1980'

; 
; 
;  Here  is  an  interesting  "patch"  to  Digital  Research's 
; STAT.COM, that incorporates a "real time clock display. This 
; patch  works with STAT.COM for CP/M version 2.2 ONLY.  Merge 
; it into STAT.COM as follows:
; 
;      A>DDT STAT.COM<cr>
;      NEXT   PC
;      1580  0100
;      -ISTATTIME.HEX<cr>
;      -R<cr>
;      NEXT   PC
;      16CD  0000
;      -^C
;      A>SAVE 22 STATTIME.COM<cr>
; 
;  Now you have a new "STAT" command file called STATTIME.COM, 
; and it will display the "real time" on every execution...
; 
;                         Best regards,
;           
;                         Kelly Smith, MP/M-Net (tm) Sysop
;                         (805) 527-9321 (Modem, 300 Baud)
;
;
;
;	STATTIME.ASM (revised 10/16/80)
;
;	Revised from the May 1980, INTERFACE AGE MAGAZINE
;
;	For Compu-Time T-102 TIME/DATE board (With MM 5375 AC)
;
;       or,
;
;	QT Computer Systems Inc. "Clock/Calendar +" board
;
;
bdos	equ	5
pbuf	equ	9

stat	equ	433h	; STAT.COM entry address

cr	equ	0dh	; ASCII carriage return
lf	equ	0ah	; ASCII line feed

true	equ	-1	; define true
false	equ	not true; define false
qt	equ	true	; define QT Computer Systems Clock/Calendar + board
ct	equ	false	; Compu-Time Time/Date board

	if qt

clock	equ	080h	; real time clock base port address

	endif

	if ct

clock	equ	024h	; real time clock base port address

	endif


	org     0100h

	jmp	date

	org	1501h	; version 2.2 stat.com entry address

date:	push psw ! push b ! push d ! push h
	lxi	h,month	; point to month
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
	lxi	d,pdate	; point to date and time message
	mvi	c,pbuf	; print buffer function
	call	bdos	; let CP/M do the work...
	lda	month	; get high byte of the month
	cpi	' '	; in the range of january to september?
	jz	jansept
	lda	month+1	; must be october to december...
	cpi	'0'	; october?
	lxi	d,oct
	jz	pmonth	; print, if so
	cpi	'1'	; november?
	lxi	d,nov
	jz	pmonth	; print, if so
	lxi	d,dec	; december.
	jmp	pmonth	; print it...
jansept:lda	month+1	; it's january to september
	cpi	'1'	; january?
	lxi	d,jan
	jz	pmonth	; print, if so
	cpi	'2'	; february?
	lxi	d,feb
	jz	pmonth	; print, if so
	cpi	'3'	; march?
	lxi	d,mar
	jz	pmonth	; print, if so
	cpi	'4'	; april?
	lxi	d,apr
	jz	pmonth	; print, if so
	cpi	'5'	; may?
	lxi	d,may
	jz	pmonth	; print, if so
	cpi	'6'	; june?
	lxi	d,jun
	jz	pmonth	; print month
	cpi	'7'	; july?
	lxi	d,jul
	jz	pmonth	; print, if so
	cpi	'8'	; august?
	lxi	d,aug
	jz	pmonth	; print, if so
	lxi	d,sep	; it's september
pmonth:	mvi	c,pbuf	; print buffer function
	call	bdos	; let CP/M do the work...
done:	lxi	d,day	; get the day
	mvi	c,pbuf	; print buffer function
	call	bdos	; let CP/M do the work...
	pop h ! pop d ! pop b ! pop psw
	jmp	stat	; now jump into STAT...

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

pdate:	db	cr,lf,'Date: $'
month:	ds	2	; the month
day:	db	'xx, '	; the day...
	db	'1980'	; the year...
	db	'  Time: '
hour:	db	'xx:'	; the hour...
	db	'xx:'	; the minute...
	db	'xx'	; the second...
	db	cr,lf,'$'	; string delimeter

errmsg:	db	cr,lf,'The Clock Board is NOT INSTALLED!',cr,lf,'$'

jan:	db	'January $'
feb:	db	'February $'
mar:	db	'March $'
apr:	db	'April $'
may:	db	'May $'
jun:	db	'June $'
jul:	db	'July $'
Aug:	db	'August $'
sep:	db	'September $'
oct:	db	'October $'
nov:	db	'November $'
dec:	db	'December $'

	end

