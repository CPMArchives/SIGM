;
; sysmon.asm - system monitor
;
; revision 02.00 - 05/12/81
;
; Copyright (C) 1978, 1979, 1980, 1981 by Terence M. Kennedy
; All Rights Reserved Worldwide
;
; Permission is hereby granted to the SIG/M library to distribute
; this work in whatever form and manner it pleases. This permission
; is non-transferable.
;
; Computer hobbyists may use this code, in any form, modified or
; unmodified, for non-commercial purposes.
;
; Refer all requests for commercial distribution to the SIG/M Library.
;
; I define 'Commercial distribution' to include distribution by
; the 'CP/M User's Group' run by Intersoft Corp. (Lifeboat Associates)
;
; NOTE: CP/M is a (registered) trademark of Digital Research, Inc.,
;	Pacific Grove, California. Reference to this trademark within
;	the body of this text is only to indicate that this code will
;	interface with said trademarked product, and does not imply
;	that the owner of the trademark owns, approves, or uses this
;	code.
;
false	equ	0		;logical false value
true	equ	not false	;logical true value
;
testing	equ	true		;if testing
help	equ	true		;if '?' command to display commands desired
cpmio	equ	true		;if using CP/M console I/O instead of hardware
;
	if	(not testing) and cpmio
--> cannot have cpmio true and testing false <--
	endif
;
	if	testing
pbase	equ	00100h		;program base
dbase	equ	02000h		;data area base
	endif
;
	if	not testing
pbase	equ	0e000h		;program base in bytesaver
dbase	equ	0bf00h		;data area base (below bytesaver)
	endif
;
	if	cpmio		;if using CP/M I/O calls
conrdy	equ	006h		;console status
conin	equ	009h		;console input
conout	equ	00ch		;console output
	endif
;
wboot	equ	0000h		;CP/M warm boot entry point
;
; misc. equates
;
cr	equ	0dh		;carriage return
lf	equ	0ah		;line feed
bs	equ	08h		;back space
sl	equ	'/'		;slash
cntrlc	equ	'C'-40h		;control-C
cntrlq	equ	'Q'-40h		;control-Q
cntrls	equ	'S'-40h		;control-S
cntrlx	equ	'X'-40h		;control-X
cntrlz	equ	'Z'-40h		;control-Z
bell	equ	07h		;ring console bell
;
; device equates
;
fpanel	equ	0ffh		;front panel device address
consta	equ	000h		;console status port
condat	equ	001h		;console data port
rdrsta	equ	002h		;reader status port
rdrdat	equ	003h		;reader data port
dsksta	equ	07fh		;disk drive status
dskcmd	equ	07fh		;disk drive command port
dskc2	equ	07ch		;disk drive 2nd command port
dmah	equ	07eh		;high order byte of dma address
dmal	equ	07dh		;low order byte of dma address
;
; device control bits
;
trk0	equ	004h		;if at track 0
iof	equ	008h		;if I/O is complete
notrdy	equ	080h		;if drive is not ready
done	equ	notrdy or iof	;done w/ command (one way or another)
errors	equ	0f0h		;error bits
tbe	equ	080h		;transmit buffer empty (all serial ports)
rda	equ	040h		;data available (all serial ports)
readf	equ	0bfh		;read disk function
;
; data areas (uninitialized)
;
	org	dbase
;
userpc:	ds	2		;user's PC for R command
svc:	ds	1		;supervisor call no.
ibuf:	ds	128		;input buffer
stack:	ds	64		;program stack
pflag1:	ds	1		;parameter flags
pflag2:	ds	1
param1:	ds	2		;parameters
param2:	ds	2
cbuf:	ds	1		;command buffer
dmpad:	ds	2		;dump address
temp:	ds	10h		;temp. workspace for B, I & O commands
oflst	equ	temp		;object file loader state
oflce	equ	temp+1		;object file loader checksum error flag
oflcs	equ	temp+2		;object file loader checksum
oflbc	equ	temp+3		;object file loader byte count
oflbb	equ	temp+4		;object file loader byte buffer
oflla	equ	temp+5		;object file loader load address (word value)
oflfrr	equ	temp+7		;object file loader first record read flag
addr:	ds	2		;hexmon current address
data:	ds	1		;hexmon working data
diagfg:	ds	1		;diagnostic load flag
srcnam:	ds	10h		;name of tape file searching for
fndnam:	ds	10h		;name of tape file found
;
; code area
;
	org	pbase
;
monitr:	jmp	main		;jump to main code
super:	jmp	supvsr		;jump to supervisor
main:	lxi	sp,stack+64	;set up sp
	lxi	h,0		;clear user PC to 0
	shld	userpc
	lxi	h,cs		;clear screen code
	call	wasc		;send it
	in	fpanel		;read sense switches
	cpi	0ffh		;test for no front panel
	jz	main1		;if no panel
	cpi	80h		;test if entering sysmon
	jnz	boot		;no, boot disk right away
main1:	lxi	h,signon	;get signon message
	call	wasc		;send to con:
	call	weolc		;do cr/lf
prompt:	mvi	a,'@'		;our prompt
	call	wacc		;to console
	lxi	h,ibuf		;input buffer pointer
	call	rasc		;get command line
	mov	a,m		;test if terminated with '/'
	cpi	sl
	jz	hexmon		;if so, use hex monitor
	mvi	m,' '		;insure at least one blank at end
	inx	h		;followed by cr
	mvi	m,cr
	lxi	d,ibuf		;points to 1st character of input line
parse:	ldax	d		;get command
	cpi	' '		;test for null command
	jz	prompt		;if so, re-issue prompt
	sta	cbuf		;if not, put command keyword in cbuf
	inx	d		;points to param1 now
parse1:	xra	a		;clear parameter flags
	sta	pflag1
	sta	pflag2
	call	dhs		;decode first parameter
	jc	comerr		;if command error in param.
	sta	pflag1		;save parameter flag
	shld	param1		;and parameter
	call	dhs		;decode second parameter (same as first)
	jc	comerr
	sta	pflag2
	shld	param2
	lda	pflag1		;get first parameter flag
	ora	a		;see if set
	jnz	$+9		;yes, skip next code
	lxi	h,100h		;no, default to 100 hex
	shld	param1
	lda	pflag2		;get second parameter flag
	ora	a		;test it
	jnz	$+9		;if already got one
	lhld	param1		;else default it to same as first one
	shld	param2
decode:	lxi	h,ctable	;lookup table for keywords
decod1:	lxi	d,cbuf		;points to command input by user
	mvi	c,1		;compare only 1 character
	mvi	b,1		;set match flag
decod2:	ldax	d		;get command
	cmp	m		;compare w/ keyword table
	jz	$+5		;if match
	mvi	b,0		;else reset match flag
	inx	d
	inx	h
	dcr	c		;this would flush rest of keyword if >1 char.
	jnz	decod2
	dcr	b		;test match flag
	jz	match		;if successful match
	inx	h		;else skip address field
	inx	h
	mov	a,m		;test if end of table
	ora	a
	jnz	decod1		;if not at end
	lxi	h,badcom	;at end, send 'bad command' message
	call	wasc
	jmp	prompt		;and go back to main prompt
match:	mov	e,m		;copy address to DE
	inx	h
	mov	d,m
	lxi	b,prompt	;create return address
	push	b		;this puts prompt on stack for second RET
	push	d		;this puts the routine address on the stack
	lhld	param2		;put second parameter in DE (see xchg below)
	xchg
	lhld	param1		;put first parameter in HL
	ret			;this causes jmp to address in D, pushed above
comerr:	lxi	h,badstx	;give 'bad syntax' message
	call	wasc
	jmp	prompt
;
; command table
;
ctable:	db	'D'		;dump command
	dw	dump
	db	'H'		;halt command
	dw	halt
	db	'B'		;boot standard system
	dw	boot
	db	'S'		;boot diagnostic system
	dw	diag
	db	'R'		;display register set
	dw	regdis
	db	'E'		;enter command
	dw	enter
	db	'M'		;move command
	dw	move
	db	'F'		;fill command
	dw	fill
	db	'G'		;go command
	dw	go
	db	'I'		;input command
	dw	rip
	db	'O'		;output command
	dw	wop
	db	'L'		;load diagnostic tape
	dw	loader
;
	if	help
	db	'?'		;output command summary
	dw	hlpdis
	endif
;
	if	testing
	db	'Q'		;quit command
	dw	wboot		;to CP/M warm boot
	db	'T'		;supervisor call test
	dw	svctst
	endif
;
	db	0		;end of command table
;
; supvsr - supervisor call handler
;
supvsr:	push	h		;save user parameters
	push	d
	push	b
	push	psw
sup1:	lxi	h,stable	;supervisor call table pointer
sup2:	lda	svc		;get supervisor call no.
	cmp	m		;compare with call no. in table
	inx	h		;point to address in any case
	jz	sup3		;if found
	inx	h		;skip to next svc no.
	inx	h
	mov	a,m
	cpi	0ffh
	jz	sup4		;if at end of table
	jmp	sup2		;and retry
sup3:	mvi	a,jmp		;stuff a jump in temp. area
	sta	temp
	mov	e,m		;get address from table
	inx	h
	mov	d,m
	xchg			;put in hl
	shld	temp+1		;save address in temp+1
	pop	psw		;restore user's registers
	pop	b
	pop	d
	pop	h
	jmp	temp		;go to routine
sup4:	mvi	b,8		;8 bytes to remove
sup5:	inx	sp
	dcr	b
	jnz	sup5		;if not done
	lxi	h,ilsum1	;print illegal supervisor call message
	call	wasc
	lda	svc		;print svc no. causing error
	call	whbc
	lxi	h,ilsum2	;print rest of message
	call	wasc
	inx	sp		;get high byte
	lxi	h,0		;copy sp to hl
	dad	sp
	mov	d,m		;get byte 1
	dcx	h
	mov	e,m
	xchg
	dcx	h		;point to call address
	dcx	h
	dcx	h
	mov	a,h		;output hi byte
	call	whbc
	mov	a,l		;output low byte
	call	whbc
	call	weolc		;do 2 cr/lf's
sup6:	call	weolc		;do cr/lf
	lxi	sp,stack+64	;reset sp
	jmp	prompt		;and issue prompt
;
; supervisor call table
;
stable:	db	0		;return to monitor
	dw	sup6
	db	1		;return version number
	dw	vers
	db	2		;console in
	dw	racc
	db	3		;console out
	dw	wacc
	db	4		;console status
	dw	const
	db	5		;console string in
	dw	rasc
	db	6		;console string out
	dw	wasc
	db	7		;do cr/lf on console
	dw	weolc
	db	8		;ring bell on console
	dw	ding
	db	9		;test for legal digit
	dw	legal
	db	10		;decode hex string
	dw	dhs
	db	11		;write hex digit to console
	dw	whdc
	db	12		;write hex byte to console
	dw	whbc
	db	13		;dump hex & ascii on console
	dw	dmp
	db	14		;dump register set
	dw	regdis
	db	15		;compute difference
	dw	diff
	db	16		;move up
	dw	moveup
	db	17		;move down
	dw	movedn
	db	18		;boot dos
	dw	boot
	db	19		;boot ddos
	dw	diag
	db	20		;delay
	dw	delay
	db	21		;read byte from reader
	dw	reader
	db	22		;process object byte
	dw	ofl
	db	0ffh		;end of table
;
; loader - load specified diagnostic from tape
;
loader:	lxi	h,askfil	;ask for filename
	call	wasc
	lxi	h,srcnam	;input buffer address
	call	rasc		;read user's response
	lxi	h,askply	;tell him to press play
	call	wasc		;do cr/lf
load1:	call	reader		;get character
	cpi	';'		;test for header
	jnz	load1		;skip till found
	lxi	h,fndnam	;pointer to 'found name'
load2:	call	reader		;get filename
	cpi	cr		;see if all done
	jz	load3
	mov	m,a		;store away
	inx	h		;next free loc.
	jmp	load2		;do next char
load3:	mvi	m,0		;force end of string
	lxi	h,found		;print 'Found '
	call	wasc
	lxi	h,fndnam	;send name we found on tape
	call	wasc		;to console
	lxi	d,srcnam	;pointer to search name
	lxi	h,fndnam	;pointer to name found on tape
	mvi	b,10h		;max. no. of bytes to compare
load4:	mov	c,m		;byte from found name
	ldax	d		;byte from wanted name
	cpi	cr		;test if last byte in source
	jz	load5		;if so...
	cmp	c		;compare
	jnz	load1		;if not a match
	inx	h		;next bytes
	inx	d
	dcr	b		;see if have done 10h yet...
	jnz	load4		;if not
load5:	lxi	h,loadng	;print 'Loading'
	call	wasc
	xra	a		;initialize loader
	sta	oflst
	sta	oflce
	sta	oflfrr
load6:	call	reader		;get character
	cpi	cntrlz		;test if eof
	jz	load7		;if so...
	call	ofl		;process byte
	lda	oflce		;test for checksum error
	ora	a
	jz	load6		;if ok
	jmp	load8		;if error
load7:	lxi	h,execad	;print 'Execute address: '
	call	wasc
	lhld	addr		;now print address
	mov	a,h		;hi byte first
	call	whbc
	mov	a,l		;next, the low byte
	call	whbc
	call	weolc		;do cr/lf
	call	weolc
	ret			;return to main monitor
load8:	lxi	h,cksume	;print 'Checksum error'
	call	wasc
	ret
;
; diag - boot diagnostic system from disk
;
diag:	mvi	a,0ffh		;set diagnostic flag
	jmp	bootd		;proceed as a standard boot
;
; boot - boot DOS from diskette (maybe)
;
boot:
;
	if	testing		;prevent odd things from
	jmp	main1		;happening to first-time SIG/M users
	endif
;
	mvi	a,0		;reset diag. flag
bootd:	sta	diagfg
	in	dsksta		;get disk status
	cpi	0ffh		;test if no disk in computer
	jnz	boot2		;if disk is there
boot1:	lxi	h,wutdsk	;what disk?
	call	wasc
	jmp	main1		;back to system monitor
boot2:	mvi	a,0ffh		;issue null commands to update status
	out	dskc2
	out	dskcmd
	mvi	a,35		;do 35 ms head load delay
	call	delay
boot21:	in	dsksta		;get status again
	ani	trk0		;test track 0 bit
	jz	boot3		;if at track 0
	mvi	a,0ffh		;this code steps the head in
	out	dskcmd
	ani	0fdh
	out	dskcmd
	ori	002h
	out	dskcmd
	mvi	a,8		;delay 8 ms between steps
	call	delay		;do delay
	jmp	boot21		;test track 0 again
boot3:	mvi	a,0f0h		;set dma address to 1000h(-3)
	out	dmah
	mvi	a,002h
	out	dmal
	mvi	a,0		;track 0
	sta	0ffdh		;@ dma-3
	mvi	a,1		;sector 1
	sta	0ffeh		;@ dma-2
	mvi	a,0fbh		;sd id mark (not really needed)
	sta	0fffh
	mvi	a,readf		;issue read function
	out	dskcmd		;issue as command
boot4:	in	dsksta		;read status
	ani	done		;test if done
	jz	boot4		;not yet...
	in	dsksta		;read status again
	push	psw		;save full byte for later
	ani	errors		;test for errors
	jz	boot5		;if no errors
	lxi	h,booter	;say boot error
	call	wasc		;send
	pop	psw		;get status back
	call	whbc		;to console
	call	weolc		;do cr/lf
	jmp	main1		;to main monitor
boot5:	pop	psw		;clean up stack
	lxi	h,1000h		;source address of move
	lxi	d,80h		;no. of bytes to move
	lxi	b,0		;destination address
	call	moveup		;do move
	lda	0		;get first byte of bootstrap
	cpi	0e5h		;test for push h
	jnz	boot6		;if not, execute code
	lxi	h,nosys		;say no system
	call	wasc		;send
	jmp	main1		;go to monitor
;
	if	not testing	;if running from rom
boot6:	lda	diagfg		;get diagnostic flag
	cpi	0ffh		;see if set
	jz	0		;if so, proceed directly to boot
	lxi	h,bootc		;source
	lxi	d,0bh		;no. of bytes
	lxi	b,temp		;destination
	call	moveup		;do move
	jmp	temp		;turn off rom, turn on ram, jmp to bootstrap
	endif
;
	if	testing		;if running from ram
boot6:	jmp	0		;we don't need to turn off rom board
	endif
;
	if	not testing
bootc:	db	3eh,0		;mvi a,0
	db	0d3h,40h	;out 40h
	db	3eh,1		;mvi a,1
	db	0d3h,41h	;out 41h
	db	0c3h,0,0	;jmp 0
	endif
;
	if	help
;
; hlpdis - display help menu [optional]
;
hlpdis:	lxi	h,hlpmsg	;print the whole thing
	call	wasc
	jmp	weolc		;exit w/ cr/lf
	endif
;
	if	testing
;
; svctst - test supervisor call
;
svctst:	mov	a,l		;put svc no. into A
	sta	svc		;save in svc
	call	super		;call supervisor
	jmp	weolc		;exit w/ cr/lf
	endif
;
; regdis - display 8080 register set
;
regdis:	push	h		;save registers
	push	d
	push	b
	push	psw
	lxi	h,regmsg	;issue register message
	call	wasc
	lhld	userpc		;get user's PC
	call	reg1		;display it
	lxi	h,regsp		;issue SP message
	call	wasc
	lxi	h,0
	dad	sp		;sneaky way to get SP
	call	reg1
	lxi	h,regaf		;issue AF message
	call	wasc
	pop	h		;get AF
	call	reg1
	lxi	h,regbc		;issue BC message
	call	wasc
	pop	h		;get BC
	call	reg1
	lxi	h,regde		;issue DE message
	call	wasc
	pop	h		;get DE
	call	reg1
	lxi	h,reghl		;issue HL message
	call	wasc
	pop	h		;get HL
	call	reg1
	jmp	weolc		;exit via cr/lf
reg1:	mov	a,h		;get high byte
	call	whbc
	mov	a,l		;get low byte
	call	whbc
	ret			;return to caller
;
; rip - read input port
;
rip:	mvi	a,in		;input instruction
	sta	temp		;save in temp code area
	mov	a,l		;HL (param1) has input port address
	sta	temp+1
	mvi	a,ret		;return instruction
	sta	temp+2
	call	temp		;execute code just built
	call	whbc		;write result on console
	jmp	weolc		;equal to call weolc ! ret
;
; wop - write output port
;
wop:	mvi	a,out		;output instruction
	sta	temp		;mainly the same as above
	mov	a,l
	sta	temp+1
	mvi	a,ret
	sta	temp+2
	mov	a,e		;get value to send from param2
	call	temp
	jmp	weolc
;
; halt - halt computer
;
halt:	hlt			;that was simple!!!
;
; dump - dump memory to console in hex & ascii
;
dump:	lda	pflag1		;see if address was typed
	ora	a
	jz	weolc		;no, exit
	call	diff		;get difference between param1 & param2 in DE
	inx	d		;+1
	shld	dmpad		;save param1 as starting dump address
	jmp	dmp		;do actual dump
;
; enter - enter bytes into memory
;
enter:	mov	a,h		;prompt w/ current load address
	call	whbc
	mov	a,l
	call	whbc
	mvi	a,':'
	call	wacc
	mvi	a,' '
	call	wacc
	push	h		;save load address
	lxi	h,ibuf		;read user's input
	call	rasc
	dcr	b		;test for empty line
	jz	enter3		;empty, exit
	lxi	d,ibuf		;pointer to buffer
enter1:	call	dhs		;decode 1 byte
	jc	enterr		;if error
	ora	a		;test for end of line
	jz	enter2
	mov	a,l		;L has low byte of entered value
	pop	h		;restore load address
	mov	m,a		;move byte into memory
	inx	h		;increment load address
	push	h		;save again...
	jmp	enter1		;do next byte on line
enter2:	pop	h		;restore load address
	jmp	enter		;get next line
enter3:	pop	h		;clean up stack
	jmp	weolc		;exit w/ cr/lf
enterr:	pop	h		;clean up stack
	lxi	h,badval	;send 'bad hex value' message
	jmp	wasc		;exit
;
move:	lda	pflag1		;make sure we have two parameters
	ora	a
	jz	moverr
	lda	pflag2
	ora	a
	jz	moverr
	call	diff		;find difference between param1 & param2
	inx	d		;+1
	push	d		;save param1 & param2
	push	h
	lxi	h,moveto	;ask 'to?'
	call	wasc
	lxi	h,ibuf		;get answer
	call	rasc
	lxi	d,ibuf		;reset pointer
	call	dhs		;decode answer
	jnc	move1		;if ok
	pop	h		;else clean up stack
	pop	d
	jmp	enterr+1	;print 'bad hex value' message
move1:	xchg			;DE= address to move to
	mov	b,d		;copy to BC
	mov	c,e
	pop	h		;get source address
	call	diff		;compute distance to move
	pop	d		;restore size of block to move
	jnc	movedn		;move downward
	jmp	moveup		;move upward
moverr:	lxi	h,twopar	;issue 'two parameters' message
	jmp	wasc
;
; fill - fill memory with specified value
;
fill:	lda	pflag1		;test for two parameters
	ora	a
	jz	moverr
	lda	pflag2
	ora	a
	jz	moverr
	call	diff		;compute # of bytes to fill
	inx	d		;+1
	push	h		;save parameters (h now has length)
	push	d
	lxi	h,fillw		;print 'With?'
	call	wasc
	lxi	h,ibuf		;get answer
	call	rasc
	lxi	d,ibuf
	call	dhs		;decode it
	jnc	fill1		;if ok
	pop	d
	pop	h		;clean up stack
	jmp	enterr+1	;print 'bad hex value'
fill1:	mov	b,l		;byte to fill w/ --> B
	pop	d
	pop	h		;restore source & length
fill2:	mov	a,d		;return when count=0
	ora	e
	rz
	mov	m,b		;place fill byte
	inx	h		;loc=loc+1
	dcx	d		;# to do=# to do-1
	jmp	fill2
;
; go - go to location specified by param1
;
go:	mvi	a,call		;stuff call instruction
	sta	temp		;place in temp code
	shld	temp+1		;save param1 as address of call
	mvi	a,jmp		;save jump
	sta	temp+3
	lxi	h,go1		;where to return to...
	shld	temp+4
	jmp	temp		;execute code
go1:	jmp	weolc		;exit w/ cr/lf
;
; hexmon - hexadecimal monitor
;
hexmon:	call	wacc		;echo '/'
	lxi	d,ibuf		;decode address(?) just entered
	call	dhs
	jc	hex8		;if not valid
	shld	addr		;save address
hex1:	mvi	a,' '		;send a blank
	call	wacc
	mov	a,m		;get data that's there
	call	whbc		;and send to console
hex2:	mvi	a,' '		;another blank
	call	wacc
hex3:	call	racc		;get character
	cpi	cr		;test cr
	push	psw		;save flags
	cz	weolc		;do cr/lf if cr
	pop	psw		;restore flags
	jz	prompt		;if so, go back to main prompt
	cpi	'^'		;test for open previous
	jz	hex5		;if match...
	cpi	lf		;test for open next
	jz	hex7		;if match...
	push	psw		;save value
	call	legal		;test for legal value
	jc	hex10		;if invalid, kill stack and retry
	rlc			;move to high nibble
	rlc
	rlc
	rlc
	sta	data		;save as data byte
	pop	psw		;restore ascii version
	call	wacc		;echo to console
hex4:	call	racc		;get next nibble
	push	psw
	call	legal		;test if valid
	jc	hex9		;if not, kill pushed stuff & try again
	mov	b,a		;save in B
	lda	data		;data already has hi nibble
	ora	b		;add in low nibble
	sta	data		;save as data again
	pop	psw		;restore ascii
	call	wacc
	lhld	addr		;get working address
	lda	data		;get data
	mov	m,a		;move
	call	weolc		;do cr/lf
	inx	h		;next address
	jmp	hex6
hex5:	call	wacc		;echo '^'
	call	weolc		;do cr/lf
	lhld	addr
	dcx	h		;prev. address
hex6:	shld	addr		;save as current
	mov	a,h		;print on console
	call	whbc
	mov	a,l
	call	whbc
	mvi	a,sl		;put up slash
	call	wacc
	jmp	hex1		;go to entry mode
hex7:	call	weolc		;open next address
	lhld	addr
	inx	h
	jmp	hex6
hex8:	lxi	h,baddr		;say bad address
	call	wasc
	jmp	prompt		;return to prompt
hex9:	pop	psw		;kill old char.
	call	ding		;ring bell
	jmp	hex4		;try again
hex10:	pop	psw		;kill old
	call	ding
	jmp	hex3		;and retry
;
; utility routine section - many are available by external programs
;
;
; ding - ring console bell
;
ding:	push	psw		;save user's A
	mvi	a,bell
	call	wacc		;print a bell
	pop	psw		;restore user's A
	ret			;return to caller
;
; vers - return version number in hl
;
vers:	lxi	h,0100h		;version 01.00
	ret			;give to user
;
; moveup - move memory towards zero
;
moveup:	mov	a,d		;de=# of bytes to move
	ora	e
	rz			;if done moving
	mov	a,m		;get byte from source
	inx	h		;increment source address
	stax	b		;save in destination
	inx	b		;increment destination address
	dcx	d		;decrement # of bytes left to move
	jmp	moveup		;go do another...
;
; movedn - move memory towards ffff
;
movedn:	dad	d		;add source address to # of bytes, giving last
	mov	a,c		;byte to move
	add	e
	mov	c,a
	mov	a,b
	adc	d
	mov	b,a
movdn1:	mov	a,d		;see if done
	ora	e
	rz			;if done
	dcx	h		;decrement source address
	mov	a,m		;get byte
	dcx	b		;decrement destination address
	stax	b		;store at dest. address
	dcx	d		;1 less byte to move...
	jmp	movdn1		;go again
;
; diff - compute difference between de & hl and place in de
;
diff:	mov	a,e		;do first 8-bit subtract
	sub	l
	mov	e,a		;return to E
	mov	a,d		;now do second
	sbb	h
	mov	d,a		;and return to D
	ret			;return to caller
;
; dmp - dump memory in hex and ascii to console
;
dmp:	mov	a,d		;see if done
	ora	e
	jz	weolc		;if so, exit via weolc
;
	if	not cpmio	;if hardware I/O
	in	condat		;get current data from console
	cpi	cntrlc		;see if ^C typed...
	jnz	dmp1
	endif
;
	if	cpmio
	jmp	dmp1		;can't stop output under CP/M
	endif
;
	jmp	weolc		;...and exit
dmp1:	call	weolc		;start new line
	lda	dmpad+1		;get high byte of address
	call	whbc		;write to console
	lda	dmpad		;do same w/ low byte
	call	whbc
	push	h		;save address
	push	d		;save count
	mvi	c,16		;16 bytes per line
dmp2:	mov	a,d		;test if done with hex for this line
	ora	e
	jz	dmp3
	mvi	a,' '		;put a blank between bytes
	call	wacc
	mov	a,m		;get byte to be dumped
	inx	h		;increment pointer
	call	whbc		;print hex byte on console
	push	h		;save address
	lhld	dmpad		;increment user's relative address
	inx	h
	shld	dmpad
	pop	h		;restore our address
	dcx	d		;decrement # of bytes left
	dcr	c		;decrement # of bytes left on this line
	jnz	dmp2		;if more
	jmp	dmp4		;if not more, do ascii
dmp3:	inr	c		;this puts ascii in right place if last address
	dcr	c		;to dump was not on 16 byte boundary
	jz	dmp4		;if done
	mvi	a,' '		;print 3 spaces
	call	wacc
	call	wacc
	call	wacc
	jmp	dmp3+1		;continue
dmp4:	pop	d		;restore byte count
	pop	h		;restore pointer
	mvi	a,' '		;print 2 spaces
	call	wacc
	call	wacc
	mvi	c,16		;16 ascii bytes / line
dmp5:	mov	a,d		;test if done
	ora	e
	jz	weolc
	mov	a,m		;fetch next byte
	inx	h		;increment pointer
	ani	7fh		;mask out parity bit
	cpi	20h		;test if printable
	jnc	$+5		;if it isn't .lt. 20h
	mvi	a,'.'		;else use .
	cpi	7fh		;see if rubout
	jc	$+5		;if not
	mvi	a,'.'		;it is, substitute rubout
	call	wacc		;output to console
	dcx	d		;1 less byte to do
	dcr	c		;1 less on this line also
	jnz	dmp5		;if still more on this line
	jmp	dmp		;start a new line
;
; whbc - write hex byte to console
;
whbc:	push	psw		;save byte
	rrc			;do high nibble first
	rrc
	rrc
	rrc
	call	whdc		;do digit
	pop	psw		;get byte back
	push	psw		;save again
	call	whdc		;do low nibble
	pop	psw		;return w/ value
	ret
;
; whdc - write hex digit to console
;
whdc:	ani	0fh		;only look at low nibble
	cpi	10		;see if A-F
	jc	$+5		;no, 0-9
	adi	7		;make A-F
	adi	'0'		;make ascii
	jmp	wacc		;send & exit
;
; weolc - do cr/lf on console
;
weolc:	push	psw		;save acc
	mvi	a,cr		;send cr
	call	wacc
	mvi	a,lf		;send lf
	call	wacc
	pop	psw		;restore acc
	ret			;exit
;
; wasc - write ascii string to console
;
wasc:	mov	a,m		;get character
	inx	h		;increment pointer
	ora	a		;see if terminator
	rz			;return if so
	call	wacc		;else send character
	jmp	wasc		;and do another...
;
; rasc - read ascii string from console
;
rasc:	push	h		;save buffer pointer
	mvi	b,0		;0 characters entered
rasc1:	call	racc		;get a character
	cpi	cntrlx		;test for control-x
	jnz	rasc2		;no it, continue
	call	rasc7		;skip old line
	pop	h		;restore buffer pointer
	jmp	rasc		;try again
rasc2:	cpi	bs		;test for backspace
	jnz	rasc3		;if not
	inr	b		;see if at beginning of line
	dcr	b
	jz	rasc1		;if so, simply input again
	dcx	h		;decrement pointer
	dcr	b		;decrement count
	mvi	a,bs		;do bs/space/bs
	call	wacc
	mvi	a,' '
	call	wacc
	mvi	a,bs
	call	wacc
	jmp	rasc1		;get another character
rasc3:	mov	m,a		;put in buffer
	inr	b		;increment count
	mov	a,b		;test if room left in buffer
	cpi	126
	jm	rasc4		;if still room
	mvi	m,cr		;else stuff cr
	pop	h		;restore pointer
	ret			;and exit
rasc4:	mov	a,m		;get character back
	cpi	cr		;test for cr
	jz	rasc5		;if so, exit
	cpi	sl
	jz	rasc6		;test for slash
	inx	h		;increment pointer
	call	wacc		;echo character
	jmp	rasc1		;and go get another
rasc5:	inx	sp		;kill stuff on stack
	inx	sp
	jmp	weolc		;and exit
rasc6:	inx	sp		;kill stuff on stack
	inx	sp
	ret			;return to user w/o cr
rasc7:	mov	a,b		;get count to backspace over
	cpi	0
	rz			;if none, exit...
	mov	a,m		;get character
	dcx	h
	cpi	20h
	jc	rasc8		;if not printing
	cpi	7fh
	jz	rasc8		;likewise
	mvi	a,bs		;backspace over current char
	call	wacc
	mvi	a,' '
	call	wacc
	mvi	a,bs
	call	wacc
rasc8:	dcr	b
	jnz	rasc7
	ret
;
; dhs - decode hex string (ascii string @DE into binary in HL)
;
dhs:	lxi	h,0		;set result=0
	push	b		;save B register
	mvi	b,0		;clear 'digits found' counter
dhs1:	ldax	d		;get character
	cpi	cr		;test for cr
	jz	dhs5
	inx	d
	cpi	' '		;test for space
	jz	dhs1		;skip if so
	cpi	','		;test for comma
	jz	dhs1		;skip if so
dhs2:	dad	h		;HL=HL*16
	dad	h
	dad	h
	dad	h
	cpi	61h		;see if l/c
	jc	dhs3		;no
	sui	20h		;make it u/c
dhs3:	sui	'0'		;convert to binary
	jc	dhserr		;if error
	cpi	10		;see if <10
	jc	dhs4		;yes
	sui	7		;no, adjust for A-F
	cpi	10		;see if maybe between 9 & A
	jc	dhserr
dhs4:	cpi	16		;test if within bounds
	jnc	dhserr		;no, error
	add	l		;add to result
	mov	l,a		;replace
	jnc	$+4
	inr	h		;if carry
	inr	b		;increment 'digits found' counter
	ldax	d		;get next byte
	cpi	cr		;all these cause an exit
	jz	dhs5
	cpi	' '
	jz	dhs5
	cpi	','
	jz	dhs5
	cpi	sl		;test for slash
	jz	dhs5
	inx	d		;points to next
	jmp	dhs2		;decode value in A
dhs5:	ldax	d		;normal exit
	mov	a,b		;count to A
	pop	b		;restore old B (user's)
yup:	stc			;general purpose 'yes'
	cmc
	ret
dhserr:	dcx	d		;error exit
	ldax	d		;put offending character in A
	pop	b		;restore user's BC
nope:	stc			;general purpose 'no'
	ret			;exit
;
; legal - test if an ascii character is a legal hex value
;
legal:	sui	'0'		;remove ascii offset
	jc	nope		;if less, it isn't
	cpi	10		;if less than 10...
	jc	legal1		;...it's ok
	sui	7		;test for a-f
	cpi	10
	jc	nope
legal1:	cpi	16		;now see if < 16
	jnc	nope		;if greater
	jmp	yup		;if less than
;
; ofl - Intel object file loader
;	Thanks to: L. E. Hughes / 8080 SDC / Florida
;
ofl:	push	psw		;save character
	lda	oflst		;check state
	cpi	1
	jnc	ofl1
	pop	psw		;state 0 - wait for a colon
	cpi	':'
	rnz			;wasn't it - throw away
	xra	a		;clear checksum
	sta	oflcs
	inr	a		;set state=1
	sta	oflst
	ret
ofl1:	cpi	2		;test if state 1
	jnc	ofl2		;no, skip
	inr	a		;set state=2
	sta	oflst
	call	oflcb		;clear byte buffer
	pop	psw
	jmp	oflad		;accum. first digit of byte count
ofl2:	cpi	3		;test if state 2
	jnc	ofl3		;no, skip
	inr	a		;set state=3
	sta	oflst
	pop	psw
	call	oflad		;get 2nd digit of byte count
	sta	oflbc		;save result as byte count
	jmp	ofluc		;add result into checksum
ofl3:	cpi	4		;test if state 3
	jnc	ofl4		;no, skip
	inr	a
	sta	oflst		;set state=4
	call	oflcb		;clear byte buffer
	pop	psw
	jmp	oflad		;accum. 1st digit of hi address byte
ofl4:	cpi	5		;test if state 4
	jnc	ofl5		;no, skip
	inr	a
	sta	oflst		;set state=5
	pop	psw
	call	oflad		;accum. 2nd digit of hi address byte
	sta	oflla+1		;save hi byte of load address
	jmp	ofluc		;update checksum
ofl5:	cpi	6		;test if state 5
	jnc	ofl6		;no, skip
	inr	a
	sta	oflst		;set state=6
	call	oflcb		;clear byte buffer
	pop	psw		;accum. 1st digit of low address byte
	jmp	oflad
ofl6:	cpi	7		;test if state 6
	jnc	ofl7		;no, skip
	inr	a
	sta	oflst		;set state=7
	pop	psw		;accum. 2nd digit of low address byte
	call	oflad
	sta	oflla		;save low byte of load address
	push	psw		;save for later
	lda	oflfrr		;see if first address
	cpi	0
	jnz	ofl61		;no, skip this...
	inr	a		;say not first time
	sta	oflfrr
	lhld	oflla		;get load address
	shld	addr		;save for user
ofl61:	pop	psw		;restore low byte
	jmp	ofluc		;update checksum
ofl7:	cpi	9		;test if state 8
	jnc	ofl8		;no, skip
	inr	a
	sta	oflst		;set state=9
	pop	psw		;ignore record type
	ret
ofl8:	cpi	10		;test if state 9
	jnc	ofl10		;no, skip
	inr	a
	sta	oflst		;set state=10
	lda	oflbc		;get byte count
	ora	a
	jz	ofl9		;skip if no data bytes in record
	call	oflcb		;clear byte buffer
	pop	psw
	jmp	oflad		;accum. 1st digit of next data byte
ofl9:	mvi	a,11		;set state=12 (all data bytes read)
	sta	oflst
	jmp	ofl11
ofl10:	cpi	11		;test if state 10
	jnc	ofl11		;no, skip
	dcr	a		;loop at previous state
	sta	oflst
	pop	psw
	call	oflad		;accum. 2nd digit of next data byte
	push	h
	lhld	oflla
	mov	m,a		;load byte
	inx	h		;increment load address
	shld	oflla
	pop	h
	call	ofluc		;update checksum
	lda	oflbc		;decrement byte count
	dcr	a
	sta	oflbc
	ret
ofl11:	cpi	12		;test if state 11
	jnc	ofl12		;no, skip
	inr	a
	sta	oflst		;set state=12
	call	oflcb		;clear byte buffer
	pop	psw
	jmp	oflad		;accum. 1st digit of checksum
ofl12:	pop	psw
	call	oflad		;accum. 2nd byte of checksum
	call	ofluc		;add into new checksum
	sta	oflce		;save as checksum
	xra	a
	sta	oflst		;back at state 0
	ret
oflcb:	xra	a		;clear byte buffer
	sta	oflbb
	ret
oflad:	call	legal		;convert to binary
	push	b		;accum. hex digit
	mov	b,a
	lda	oflbb		;fetch byte buffer
	add	a		; * 16
	add	a
	add	a
	add	a
	add	b		;add in new digit
	sta	oflbb		;replace old value
	pop	b
	ret
ofluc:	push	h		;update checksum
	lxi	h,oflcs		;point to checksum
	add	m		;add in new byte
	mov	m,a
	pop	h
	ret	
;
; this is the console driver
;
;
; racc - read ascii character from console
;
	if	not cpmio	;if hardware I/O
racc:	in	consta		;read status port
	ani	rda		;test rda bit
	jz	racc
	in	condat		;get data
	ani	7fh		;strip parity bit
	endif
;
	if	cpmio		;if running w/ CP/M I/O calls
racc:	push	b		;save user registers
	push	d
	push	h
	mvi	a,conin		;perform conin function
	call	cbios
	pop	h		;restore registers
	pop	d
	pop	b
	endif			;fall thru to case changer
;
	cpi	61h		;translate to u/c
	rm
	cpi	7bh
	rp
	sui	20h
	ret
;
; wacc - write ascii character to console, handling ^S/^Q
;
	if	not cpmio	;if hardware I/O
wacc:	push	psw		;save user's A
	in	consta		;get status
	ani	rda		;see if something typed
	jz	wacc1		;no, do straight output
	in	condat		;yes, get char.
	cpi	cntrls		;test for ^S
	jz	wacc2		;yes, do wait loop
wacc1:	in	consta		;get status again
	ani	tbe		;test tbe
	jz	wacc+1		;not there, wait
	pop	psw		;restore character
	out	condat		;send it
	ret			;exit
wacc2:	in	consta		;wait for ^Q
	ani	rda
	jz	wacc2		;wait for a key
	in	condat
	cpi	cntrlq		;test if ^Q
	jnz	wacc2		;no, get another
	jmp	wacc1		;return & output
	endif
;
	if	cpmio		;if running w/ CP/M I/O calls
wacc:	push	b		;save user registers
	push	d
	push	h
	push	psw
	mov	c,a		;put char in C
	mvi	a,conout	;do conout function
	call	cbios
	pop	psw
	pop	h		;restore user registers
	pop	d
	pop	b
	ret
	endif
;
	if	cpmio		;link to CP/M I/O handler
;
; cbios - call bios routine
;
cbios:	push	h
	push	d
	lhld	wboot+1
	sui	3
	mov	e,a
	mvi	d,0
	dad	d
	pop	d
	xthl
	ret
	endif
;
; delay - delay @(A) milliseconds
;
delay:	mvi	c,0b0h		;time constant (2 mhz)
delay1:	dcr	c
	jnz	delay1
	dcr	a
	jnz	delay
	ret
;
; const - see if user has typed anything
;
	if	not cpmio	;if using hardware I/O calls
const:	in	consta		;get status
	ani	rda		;test rda
	rz			;A=0=nothing
	mvi	a,0ffh		;A=FF=something
	ret
	endif
;
	if	cpmio		;if using CP/M I/O calls
const:	push	h		;save registers
	push	d
	push	b
	mvi	a,conrdy	;issue cbios call
	call	cbios
	pop	b
	pop	d
	pop	h
	ееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееin	rdrdat		;get data
	ani	7fh		;strip parity
	ret			;exit to caller
;
; message text area - all texts go here
;
;
cs:	db	27,28,0		;clear screen code, terminated w/ a zero
;
signon:	db	'SYSMON 02.00 - 04/10/81',cr,lf
;
	if	help
	db	'Type ? for command summary...',cr,lf
	endif
;
	db	0
;
badcom:	db	bell,'Unknown command',cr,lf,0
;
badstx:	db	bell,'Syntax error in command',cr,lf,0
;
badval:	db	bell,'Non-hexadecimal value entered',cr,lf,0
;
moveto:	db	'Move to? ',0
;
fillw:	db	'Fill with? ',0
;
twopar:	db	bell,'Two parameters are required',cr,lf,0
;
wutdsk:	db	bell,'Disk drive not ready...',cr,lf,0
;
booter:	db	bell,'Boot error, controller status: ',0
;
nosys:	db	bell,'No system image on disk...',cr,lf,0
;
baddr:	db	bell,bs,' <-- Bad address entered...',cr,lf,0
;
askfil:	db	'Filename? ',0
;
askply:	db	cr,lf,'Press PLAY on tape unit...',cr,lf,0
;
found:	db	cr,lf,'Found ',0
;
loadng:	db	cr,lf,'Loading...',0
;
execad:	db	cr,lf,'Execute address: ',0
;
cksume:	db	cr,lf,bell,'Checksum error!',cr,lf,0
;
regmsg:	db	'Register set:'
	db	cr,lf,'  PC: ',0
regsp:	db	cr,lf,'  SP: ',0
regaf:	db	cr,lf,'  AF: ',0
regbc:	db	cr,lf,'  BC: ',0
regde:	db	cr,lf,'  DE: ',0
reghl:	db	cr,lf,'  HL: ',0
;
ilsum1:	db	cr,lf,bell,'Illegal SVC (',0
ilsum2:	db	') from user PC: ',0
;
	if	help
hlpmsg:	db	cr,lf,'                  *** Command Summary ***',cr,lf,lf
	db	'  B               - Boot operating system from disk.',cr,lf
	db	'  D [start] [end] - Dump memory in ascii & hex from',cr,lf
	db	'                    [start] to [end], inclusive.',cr,lf
	db	'  E [address]     - Enter hex data beginning at [address].',cr,lf
	db	'                    Terminate w/ blank line.',cr,lf
	db	'  F [start] [end] - Fill memory with constant value. The',cr,lf
	db	'                    system will ask for the [constant].',cr,lf
	db	'  G [address]     - Jump to [address] and execute the code',cr,lf
	db	'                    there. Exit w/ a RET instruction.',cr,lf
	db	'  H               - Halt the computer.',cr,lf
	db	'  I [port]        - Input and display the data at [port].',cr,lf
	db	'  L               - Load diagnostic tape from tape unit.',cr,lf
	db	'                  - The system will ask for the [filename].',cr,lf
	db	'  M [from] [len]  - Move [len] bytes of data from address',cr,lf
	db	'                    [from]. The system will ask for the',cr,lf
	db	'                    [to] address.',cr,lf
	db	'  O [port] [data] - Output [data] to [port].',cr,lf
;
	if	testing
	db	'  Q               - Quit and return to operating system.',cr,lf
	endif
;
	db	'  R               - Display 8080 register set.',cr,lf
	db	'  S               - Perform load of diagnostics disk.',cr,lf
;
	if	testing
	db	'  T [call]        - Tests user SVC [call] with whatever is',cr,lf
	db	'                    currently in BC, DE, & HL.',cr,lf
	endif
;

	db	lf
	db	'  [addr]/         - Open memory location [addr] and display',cr,lf
	db	'                    its contents. Enter CR to return to the',cr,lf
	db	'                    prompt, LF to open the next location, ^',cr,lf
	db	'                    to open the previous one, or 2 hex dig-',cr,lf
	db	'                    its to replace the ones displayed.',cr,lf
	db	lf
	db	'  Arguments default to 100h except for M & F, which must be',cr,lf
	db	'explicitly entered. Do not enter the [], they are used only',cr,lf
	db	'for illustration. Arguments may be seperated by '','' or '' ''.',cr,lf
	db	lf
	db	0
	endif
;
	end
