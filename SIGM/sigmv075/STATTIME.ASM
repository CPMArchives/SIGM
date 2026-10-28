
	title	'STATTIME as of April 6, 1982'

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
;	06/Apr/82	Revised for Godbout System Support 1 clock
;			by Bill Bolton, Software Tools, Australia
;
;	20/Oct/80	Original version by Kelly Smith
;
;
;
bdos	equ	5
pbuf	equ	9

stat	equ	433h	; STAT.COM entry address

cr	equ	0dh	; ASCII carriage return
lf	equ	0ah	; ASCII line feed

true	equ	0ffh
false	equ	not true; define false
clkread	equ	10H
timlen	equ	12

gbclkc	equ	08Ah	; real time clock base port address
gbclkd	equ	gbclkc+1


	org     0100h

	jmp	date

	org	1501h	; version 2.2 stat.com entry address

date:	push	psw
	push	b
	push	d
	push	h
start:
	mvi	a,0+clkread
	out	gbclkc
	in	gbclkd
	cpi	0ffh	; clock board present?
	jz	done1	; no, just run normally
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
	lxi	d,pdate	; point to date and time message
	mvi	c,pbuf	; print buffer function
	call	bdos	; let CP/M do the work...
	lda	month	; get high byte of the month
	cpi	'1'	; in the range of january to september?
	jnz	jansept ; yes
	lda	month+1
	cpi	'0'
	lxi	d,oct	; October?
	jz	pmonth	; print, if so
	cpi	'1'	; november?
	lxi	d,nov
	jz	pmonth	; print, if so
	lxi	d,dec	; december.
	jmp	pmonth	; print it...
;
jansept:
	lda	month+1	; it's january to september
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
pmonth:
	mvi	c,pbuf	; print buffer function
	call	bdos	; let CP/M do the work...
done:
	lxi	d,day	; get the day
	mvi	c,pbuf	; print buffer function
	call	bdos	; let CP/M do the work...
done1:
	pop	h
	pop	d
	pop	b
	pop	psw
	jmp	stat	; now jump into STAT...

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
pdate:	db	'Date: $'
month:	ds	2	; the month
day:	db	'xx, '	; the day...
	db	'19'
year	db	'80'	; the year...
	db	'  Time: '
hour:	db	'xx:'	; the hour...
minutes:db	'xx:'	; the minute...
seconds:db	'xx'	; the second...
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
