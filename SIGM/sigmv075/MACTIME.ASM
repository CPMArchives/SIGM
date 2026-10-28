
	title	'MACTIME as of April 6, 1982'

; 
; 
;  Here  is  an  interesting  "patch"  to  Digital  Research's 
; MAC.COM, that incorporates a "real time clock display.  This 
; patch   works with MAC.COM version 2.0 ONLY.  Merge it  into 
; MAC.COM as follows:
; 
;      A>DDT MAC.COM<cr>
;      NEXT   PC
;      2F00  0100
;      -IMACTIME.HEX<cr>
;      -R<cr>
;      NEXT   PC
;      308E  0000
;      -^C
;      A>SAVE 48 MACTIME.COM<cr>
; 
;  Now  you have a new "MAC" command file called  MACTIME.COM; 
; now  re-assemble  MACTIME.ASM (assuming your  clock/calendar 
; board, and the time is properly set) with MACTIME.COM.
; 
;  Notice,  that  the date and time will be displayed  at  the 
; start  of execution.  Also because the "title" pseudo-op was 
; used,  the  time  is  listed  in the  ".PRN"  file  that  is 
; generated, on each page heading.
; 
;                         Best regards,
;           
;                         Kelly Smith, MP/M-Net (tm) Sysop
;                         (805) 527-9321 (Modem, 300 Baud)
;
;	06/Apr/82	Revised for Godbout System Support 1 clock
;			by Bill Bolton, Software Tools, Australia
;
;	20/Oct/80	Original version by Kelly Smith
;
;
;
bdos	equ	5
pbuf	equ	9

mac	equ	128h	; MAC.COM entry address
overlay	equ	2cd3H

cr	equ	0dh	; ASCII carriage return
lf	equ	0ah	; ASCII line feed

true	equ	0ffh
false	equ	not true; define false
clkread	equ	10H
timlen	equ	12

gbclkc	equ	06Ah	; real time clock base port address
gbclkd	equ	gbclkc+1


	org     0100h

	jmp	start

	org	2f00h	; version 2.0 mac.com entry address

start:
	mvi	a,0+clkread
	out	gbclkc
	in	gbclkd
	cpi	0ffh		;clock board present?
	jz	done		;no, just run normally
	call	rtime
	lxi	h,time
	mov	a,m
	cpi	'0'
	jnz	go$on
	mvi	a,' '
go$on:
	sta	day
	inx	h
	mov	a,m
	sta	day+1
	inx	h
	mov	a,m
	sta	month
	inx	h
	mov	a,m
	sta	month+1
	inx	h
	mov	a,m
	sta	year
	inx	h
	mov	a,m
	sta	year+1
	inx	h
	mov	a,m
	sta	hour
	inx	h
	mov	a,m
	sta	hour+1
	inx	h
	mov	a,m
	sta	minutes
	inx	h
	mov	a,m
	sta	minutes+1
	inx	h
	mov	a,m
	sta	seconds
	inx	h
	mov	a,m
	sta	seconds+1
;
; test the date, and convert it to four year calendar format
;
	lda	month	; get high byte of the month
	cpi	'1'	; in the range of january to september?
	jnz	jansept ; yes
	lda	month+1
	cpi	'0'
	lxi	d,oct	; October?
	jz	mmonth	; print, if so
	cpi	'1'	; november?
	lxi	d,nov
	jz	mmonth	; print, if so
	lxi	d,dec	; december.
	jmp	mmonth	; print it...
;
jansept:
	lda	month+1	; it's january to september
	cpi	'1'	; january?
	lxi	d,jan
	jz	mmonth	; print, if so
	cpi	'2'	; february?
	lxi	d,feb
	jz	mmonth	; print, if so
	cpi	'3'	; march?
	lxi	d,mar
	jz	mmonth	; print, if so
	cpi	'4'	; april?
	lxi	d,apr
	jz	mmonth	; print, if so
	cpi	'5'	; may?
	lxi	d,may
	jz	mmonth	; print, if so
	cpi	'6'	; june?
	lxi	d,jun
	jz	mmonth	; print month
	cpi	'7'	; july?
	lxi	d,jul
	jz	mmonth	; print, if so
	cpi	'8'	; august?
	lxi	d,aug
	jz	mmonth	; print, if so
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
done:	jmp	mac	; now jump into MAC...

rtime:
	lxi	h,time		;Address of time save area
	lxi	d,atable	;Address of digit table
	mvi	b,timlen/2	;Number of loops to do
tloop:
	call	rone		;get digit value
	ani	0fh		;mask of high nibble
	adi	'0'
	mov	m,a
	inx	h
	call	rone
	ani	0fh
	adi	'0'
	mov	m,a		;save into table
	inx	h		;point to next digit
	dcr	b		;adjust loop count
	jnz	tloop
	ret

rone:
	ldax	d		;Get the digit address
	inx	d		;Point to next address
	out	gbclkc		;Output the digit address
	cpi	5+clkread	;Check for hours 10 digit
	in	gbclkd		;Get the digit
	rnz			;If not the hours ten digit
	sui	8		;Kill the 24 hour bit
	ret
;
ATABLE:
	DB	8+clkread	;digit address table
	DB	7+clkread
	DB	10+clkread
	DB	9+clkread
	DB	12+clkread
	DB	11+clkread
	DB	5+clkread
	DB	4+clkread
	DB	3+clkread
	DB	2+clkread
	DB	1+clkread
	DB	0+clkread
;
; message buffers
;

time	db	0,0,0,0,0,0,0,0,0,0,0,0

start$move	equ	$	; start moving from here
fakem:	ds	2	; storage for faked-out month,
			; which will overlay the next four bytes
month:	ds	2	; storage for the real month and date
day:	ds	2
	db	', 19'
year:	db	'82 '	; the year...
hour:	db	'xx:'	; the hour...
minutes:db	'xx:'	; the minute...
seconds:db	'xx'	; the second...
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

