title	'BISHOW.ASM'
;A buffered, bidirectional version of SHOW.ASM.
;Ver 1.0, 23 Aug 82
;Phil Cary, 748 Kenilworth Parkway, Baton Rouge, LA  70808
;Ver 1.1, 30 Mar 83 added BDOS function 6 W.F.McGee
;
;BISHOW is a buffered, bidirectional version of SHOW.ASM which first
;appeared in Interface Age, November, 1981.  That program could
;only scroll forward in a file, and read sectors from disk one at a
;time as they were sent to the console.  I used SHOW frequently to take
;a quick look at a file without loading a big text editor, and to examine
;another file with the RUN command while in Wordstar.  TYPE does not work
;since it is not a file that Wordstar can load and run.
;
;It was annoying when I went past the point I was looking for in a file 
;with SHOW, and could not go backwards.  Thus, this bidirectional version 
;which uses random access reads. In addition, buffering was added so that
;the number of disk reads would be reduced, and moving back and forth
;in a moderate sized file would be speeded up.  There is a trade off
;between the size of the buffer and the length of time it takes to refill
;the buffer which should be set to the user's preference.
;
;There are three customizing items in this program.  One is the equate
;"maxsec" which sets the buffer size.  The other is the string in the
;subroutinå "clrscr" just after the org statement.  Thió shoulä bå changeä 
;tï thå erase screen and home cursor sequence for the user's terminal. The 
;program is presently set up for a H/Z-19.  The program, as written, does
;require a 24 X 80 screen with an erase screen and home cursor function.
;Finally, direct I/O to the console is used to avoid echoing the commands
;to the console as the CP/M write console function does.  Three equates
;under "Console equates" must be changed to match the user's system.
;
;Just a small contribution to the public domain software as partial
;payment for the many fine and educational programs the system has
;given me.  Phil Cary.

; Begin code

false	equ	0
true	equ	not false
APPLE	EQU	TRUE

; BDOS equates

boot	equ	0	;warm boot
wrcon	equ	2	;console write
bdos	equ	5	;bdos entry
open	equ	15	;open file
readr	equ	33	;read file random access
stdma	equ	26	;set dma address

; FCB equates

fcb	equ	05ch	;default fcb drive number
fcbfn	equ	fcb+1	;start of filename
fcbft	equ	fcb+9	;start of filetype
fcbex	equ	fcb+12	;current extent number
fcbcrr	equ	fcb+33	;current record number, random access

; ASCII equates

cr	equ	0dh	;carriage return
lf	equ	0ah	;line feed
eof	equ	01ah	;end of file
esc	equ	01bh	;escape
bell	equ	07h	;bell


; Operational equates

maxsec	equ	64	;number of sectors in buffer

	org	100h

fulbuf:	set	dskbuf+(maxsec*128)	;need to know end of buffer
	jmp	start			;skip over next subroutine

clrscr:	call	ilprt		;code to erase screen and home cursor

	IF NOT APPLE
	db	esc,'E',0	;..for H/Z-19 terminal. change as required
	ENDIF
	IF APPLE
	db	esc,'*',0	;..for terminal screen function table
	ENDIF
	ret

start:	lxi	sp,stack	;set up local stack
	call	clrscr		;clear the screen
	call	opnfil		;open file in default fcb
	xra	a		;get a 0
	sta	lincnt		;store in line count
	sta	fcbex		;zero current extent
	sta	fcbcrr		;zero current record
	sta	fcbcrr+1	;..both bytes
	sta	fcbcrr+2	;..and the overflow
	call	filbuf		;fill the disk buffer

wrtfwd:	lxi	h,dskbuf	;point to beginning of buffer
wrtfwd1	mov	a,m		;get a character
	cpi	eof		;if it is EOF
	jz	getcmd		;..loop for another command
	push	psw		;save character from BDOS clobber
	call	ctype		;put it on console
	pop	psw		;get character
	cpi	cr		;see if end of line
	jz	fwdcnt		;yes, count line
wrtfwd2	inx	h		;no, bump buffer
	lxi	d,fulbuf	;get end of buffer address
	mov	a,d		;compare high
	cmp	h		;..order bytes
	jnz	wrtfwd1		;if not equal, continue
	mov	a,e		;else compare low
	cmp	l		;..order bytes
	cz	filbuf		;if end of buffer, go refill
	jz	wrtfwd		;..and start at beginning of buffer
	jmp	wrtfwd1		;else, continue with next character

fwdcnt:	lda	lincnt		;get number of lines displayed
	inr	a		;bump it
	sta	lincnt		;..and store it
	xchg			;save the buffer pointer
	lxi	h,linmax	;point to max number of line for this pass
	cmp	m		;compare with line count
	xchg			;restore pointer
	jnz	wrtfwd2		;if not there, continue, else get command
	xra	a		;zero the
	sta	lincnt		;..line count

getcmd:
	push	h
	push	d
	push	b
getcmd1:
	mvi 	c,06
	mvi	e,0FFH
	call	bdos
	cmp	00h
	jz	getcmd1
	ani	5fH		;make it upper case
	cpi	'F'		;scroll forward?
	push	psw		;save flags
	mvi	a,22		;set up for only 22 lines on forward
	sta	linmax		;..scrolls
	pop	psw		;get flags
	pop	b
	pop	d
	pop	h
	jz	wrtfwd1		;scroll forward
	push	psw		;else save character and flags again
	mvi	a,24		;set up for full screen on scroll
	sta	linmax		;..backward
	pop	psw		;get character and flags
	cpi	'B'		;scroll backward?
	jz	wrtbak		;yes
	cpi	'X'		;must be exit
	jz	exit		;yes, or
	call	ilprt		;..a wrong choice so give message
	db	cr,lf,'Enter F to scroll forward, B to scroll backward, '
	db	'or X to exit.',cr,lf,bell,0
	jmp	getcmd		;try again for command

wrtbak	mvi	a,44
	sta	lincnt
	call	clrscr		;clear the screen
wrtbak1	lxi	d,dskbuf	;get address of buffer start
	mov	a,d		;compare high
	cmp	h		;..order bytes
	jnz	wrtbak2		;continue if not equal
	mov	a,e		;else, compare low
	cmp	l		;..order bytes
	jnz	wrtbak2		;continue if not equal
	jmp	filbak		;..and go write it
wrtbak2	mov	a,m		;get a character
	cpi	cr		;see if end of line
	dcx	h		;decrement buffer
	jnz	wrtbak1		;..and loop if not

bakcnt:	lda	lincnt		;else, get number of lines to move back
	dcr	a		;..and decrement it
	sta	lincnt		;..store it
	jnz	wrtbak1		;..and loop if not there
	inx	h		;else bump pointer to account for lf with cr
	jmp	wrtfwd1		;..and go write a screen

filbak:	lxi	d,maxsec	;get the buffer size
	lhld	seccnt		;..anä numbeò oæ sectoró lasô read
	dad	d		;add them
	xchg			;..and put them in DE
	lda	fcbcrr		;subtract low order byte 
	sub	e		;..from current record count
	sta	fcbcrr		;..and store in current record count
	lda	fcbcrr+1	;same with high order byte
	sbb	d		;..but with borrow
	jm	filbeg		;if beyond beginning of file, go zero count
	sta	fcbcrr+1	;else, store high order byte
	call	filbuf		;fill the buffer
	lxi	h,fulbuf	;..and point to end of buffer
	call	clrscr		;clear the screen
	jmp	wrtbak2		;continue moving back in file
					
filbeg:	xra	a		;if beyond beginning of file
	sta	fcbcrr		;..zero the current record field
	sta	fcbcrr+1
	sta	lincnt		;..and the line count
	call 	filbuf		;fill the buffer again
	jmp	wrtfwd		;..and go write it

filbuf:	lxi	d,dskbuf	;load start of disk buffer
	mvi	b,maxsec	;number of sectors to resd
	lxi	h,0		;zero out the
	shld	seccnt		;..number of sectors in buffer
filbuf1	push	h		;save all
	push	d		;..registers from
	push	b		;..BDOS clobber
	mvi 	c,stdma		;set dma to
	call	bdos		;..disk buffer
	lxi	d,fcb		;set up to read
	mvi	c,readr		;..a record
	call	bdos		;do it
	cpi	0		;read OK?
	lhld	fcbcrr		;get current record number
	inx	h		;..bump it
	shld	fcbcrr		;..and save it
	lhld	seccnt		;get sectors in buffer
	inx	h		;bump it
	shld	seccnt		;store it
	jnz	rderr		;no, last sector read
	pop	b		;yes, get sector count
	dcr	b		;decrement it
	pop	d		;get de off stack to expose return address
	pop	h		;
	rz			;if done return
	lxi	h,128		;else, add 128 to
	dad	d		;..dma address
	xchg			;put it in de
	jmp	filbuf1		;read another sector

rderr:	pop	b		;restore
	pop	d		;..registers
	pop	h		;..and
	xra	a		;..get a zero to direct to start of buffer
	ret			;..on ret

opnfil:	lda	fcbfn		;point to first letter of filename
	cpi	' '		;anything there?
	jz	help		;no, give help message
	lxi	d,fcb		;file name in default fcb
	mvi	c,open		;set up to open
	call	bdos		;do it
	cpi	0ffh		;open OK?
	rnz			;yes
	call	ilprt		;else, give error msg and quit
	db	cr,lf,lf,'Requested file is not on this disk.',cr,lf,bell
	db	'Please check your spelling or use DIR.',cr,lf,lf,bell,0
	jmp	exit1		;leave msg on screen on exit

help:	call	ilprt
	db	'Correct usage of BISHOW is --',cr,lf,lf
	db	'    A>bishow filename  ',cr,lf,lf
	db	'After first page is displayed, press F to scroll forward, '
	db 	cr,lf
	db	'B to scroll backward, or X to exit.',bell,cr,lf,lf,0       
	jmp	exit1

ilprt:	xthl			;exchange top of stack and HL
ilprt1	mov	a,m		;HL now pointing to db message
	ora	a		;see if 0 at end of message
	jz	ilprt2		;yes, restore stack and return
	call	ctype		;no, print the character
	inx	h		;bump the pointer
	jmp	ilprt1		;..and loop
ilprt2	xthl			;get return address on top of stack
	ret			;..and return

ctype:	push	b		;Save the registers
	push	d		;..from bdos
	push	h		;..clobber
	mov	e,a		;set up character
	mvi	c,wrcon		;..to send to console
	call	bdos		;do it
	pop	h		;restore
	pop	d		;..the registers
	pop	b
	ret

exit:	call 	clrscr		;clear the screen
exit1	jmp	0		;warm boot

; Memory allocation

seccnt:	dw	0	;number of sectors read into buffer
linmax:	db	24	;number of to write lines on console
lincnt:	db	0	;line number on write or move back in buffer
	ds	60	;stack area
stack:	ds	2
dskbuf:	equ	$	;disk buffer area above the program

	end	100h
                                                                                                                                