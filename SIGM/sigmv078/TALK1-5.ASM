.title	'Program to microcommunicate with other computer systems'
.sbttl	'	Version of 10-Jul-81'
.ident	talk
.entry	start
.if1,[ .prntx	'TALK v1.5 - CP/M to host file transfer program']
;
;	Simple program that can send and receive characters
;	from the CP/M console or floppy disk to another
;	computer/ acoustic modem/ or terminal that is connected
;	to a Z80 SIO or DART (serial asynchronous interface).
;
;	It is my first attempt at writing a program using
;	interrupts so that I can fully utilise my hardware's
;	capabilities. (I have a Godbout DISK 1 DMA floppy disk
;	controller, Wire-wrapped 4 MHz IEEE 696 Z80 CPU with
;	2x Z80 SIO's, Z80 CTC and Z80 PIO allowing use of Mode 2
;	vectored interrupts, 64Kbytes RAM and a Fulcrum VIO-X2
;	intelligent video board).
;
;	Sorry the source is in TDL Macro assembly language and
;	requires Phoenix Software Associates PASM or TDL/Xitan
;	Macroassembler to assemble. Conversion to ASM should
;	be straight forward, though you lose all the nice
;	features of this assembler.
;
;	Author:		Anthony Nicholson
;
;	Address:	54 Carnley Avenue,
;			New Lambton, NSW, 2305,
;			Australia.
;
;	Phone:		049-526017
;
;	Date written:	20-Dec-1981
;
;	Modification history:
;
;	* Rev 5  10-Jul-1982
;			Tidy up and add Z80 processor check
;			for submission to 'Public Domain'.
;
;	* Rev 4  13-Jun-1982
;			Add log file feature and change
;			abort character to ^^ (so I can
;			communicate with a VAX-11/780 which
;			uses ^Y).
;
;	* Rev 3  21-Mar-1982
;			Add delay to SENDFILE to allow
;			host computer to catch up when
;			using fast (2400baud) transmission,
;			and echo what is sent for testing
;			(This was found to be necessary when
;			TALKing to a timesharing host PDP-11/70
;			which required time to process its
;			input buffer).
;
;	* Rev 2  07-Mar-1982
;			Implement file send to host.
;
;	* Rev 1  27-Jan-1982
;			Fix GETFCB filename scan. Also
;			add conditional assembly for use
;			with the Ferguson Big Board and
;			for testing using my hardware.
;
;	* Rev 0  20-Dec-1981
;			Initial version for my hardware.
;
;
;
; C P / M   D E F I N I T I O N S
;
bdos	==	5	;CP/M entry address
base	==	0	;CP/M base re-entry address
;
conwr$	==	2	;Console write
dirio$	==	6	;Direct console i/o
print$	==	9	;Print string
rdbuf$	==	10	;Read console buffer
openf$	==	15	;Open file
close$	==	16	;Close file
delet$	==	19	;Delete file
readf$	==	20	;Read file
write$	==	21	;Write file
creat$	==	22	;Create file
sdma$	==	26	;Set DMA address
;
; G E T   B U F F E R   S I Z E
;
bufsiz	=\	'File blocking buffer size (must be multiple of 128)'
	.ifn	bufsiz @ 128,[
		.error	'?ILLEGAL BUFFER SIZE' 
		]
;
; C O N T R O L  C H A R A C T E R S
;
			; Command characters to
ctrld	==	04h	;  - download file
ctrle	==	05h	;  - send file
ctrlf	==	06h	;  - log file
ctrlq	==	11h	;  - XON to host
ctrls	==	13h	;  - XOFF to host
ctrly	==	1eh	;  - Abort (really ^^)
ctrlz	==	1ah	;  - EOF char
;
lf	==	0ah
cr	==	0dh
;
noparity==	07fh	;parity bit mask
;
false	==	0
true	==	# false
.opsyn	.ife,.ifnot
.opsyn	.ifn,.if
;
testing	=\	'Version required (TEST=1, Bigboard=0) '
;
baudc	=\	'Baud rate for Z80 SIO <Default=300> '
;
opt.delay=\	'Is a delay required after sending a line (Yes=1, No=0) '
;
.ifnot	testing,[
	;
	; Ferguson BIG BOARD equates
	;
	bauda	==	0ch	;Baud rate generator
				; Value output to baud
				; rate generator is
				; determined below with
				; a default of 300baud.
				;For other baud rates,
				; extend the conditional
				; making sure to match
				; all parentheses.
	.ife	baudc-2400,[
	    baudr   ==      1010b
	    ]
	    [.ife    baudc-1200,[
		baudr	==	1000b
		]
		[.ife	baudc-600,[
		    baudr   ==      0110b
		    ]
		    [
			baudr	==	0101b
		    ]
		]
	    ]
	delcnt	==	2*1000	;delay count for 2MHz Z80
	siobc	==	07h	;Uses Z80 SIO channel B
	siobd	==	05h	; at ports 05 & 07h
	intvec	==	0ff00h	; and its associated interrupt
	rx.v	==	intvec+4; vectors for rx char
	rxe.v	==	intvec+6; and rx char error
]
.if	testing,[
	;
	; Test equates using my hardware
	;
	intvec:	.word	ierror	;I need to set up an
		.word	ierror	; interrupt vector table
		.word	ierror	; for the Z80 SIO
		.word	ierror
		.word	ierror
		.word	ierror
		.word	ierror
		.word	ierror
	;
	ierror:	lxi	d,imsg	; This routine will
		call	prints	;handle anything funny
		hlt		;that may occur by HALTing!!!
		jmpr	ierror
	;
	imsg:	.ascii	[cr][lf]'?SPURIOUS INTERRUPT$'
	;
	rx.v	==	intvec+4;vector assignment for SIO
	rxe.v	==	intvec+6; channel B
	ctcb	==	11h	;CTC controls the baud rate
	.ife	baudc-2400,[
	    baudr   ==      00011000b
	    ]
	    [.ife   baudc-1200,[
		baudr	==	00110000b
		]
		[.ife	baudc-600,[
		    baudr    ==      01100000b
		    ]
		    [
			baudr	==	11000000b
		    ]
		]
	    ]
	siobd	==	01h	;data register of SIO
	siobc	==	03h	;control register of SIO
	delcnt	==	4*1000	;delay count for 4MHz Z80
]
;
; B E G I N   P R O G R A M   ' T A L K '
;
start:	mvi	a,7fH	;Identify processor
	add	a	; cause overflow
	jpe	Z80	; conclusive proof of Z80
	lxi	d,z80msg;Give them the bad news
	call	prints
	jmp	base	;Return to CP/M
;
z80msg:	.ascii	'?TALK - This program requires a Z80 processor$'
;
z80:	lxi	d,signon ;print("TALK V1.n")
	call	prints
	call	rxecho
	call	inisio	;initialise SIO
;
next1:	call	getch	;get a character
	ora	a	; from console.
	jrnz	proc1	;if we get one then off we go...
	call	prxch	;otherwise print any character
	jmp	next1	; we got down the line.
;
proc1:	cpi	ctrld	;if ch="^D" then
	jrz	..6	; transfer file to CP/M
	cpi	ctrlf	;else if ch="^F" then
	jrnz	..2	; do log file function
	mvi	a,true	; by setting log flag
	sta	log.flag
	lxi	d,logmsg; and getting prompt
	jmpr	..7	; message ready.
;	
..6:	lxi	d,filmsg
;
..7:	call	prints	; print "filename ?"
	call	inputl	; get filename
	lxi	d,newlin
	call	prints
	lxi	h,conbuf+2
	lxi	d,fcb
	call	getfcb	; set up file control
			; block
	jrz	..1	;if not ok then
..0:	lxi	d,fnerrm ; print "filename error"
	call	prints
	jmpr	..8	;else
;
..1:	call	getfile	; transfer file
;
..8:	mvi	a,false	;when done, reset
	sta	log.flag; log flag
	jmp	next1
..2:
	cpi	ctrly	;if ch="^Y" then 
	jrnz	..3

	lxi	d,byemsg; print "exiting..."
	call	prints
	call	close	; close files and
	call	rxdint	; disable host rx interrupts
	jmp	base	;Return to CP/M
..3:
	cpi	ctrle	;if ch="^E" then
	jrnz	..4
	lxi	d,sndmsg; print "filename to send?"
	call	prints
	call	inputl	; get filename
	lxi	d,newlin
	call	prints
	lxi	h,conbuf+2
	lxi	d,fcb
	call	getfcb
	jrz	..5

	lxi	d,fnerrm; print "filename error"
	call	prints
	jmp	next1

..5:	call	sendfile
	jmp	next1
..4:
	call	send	;send character to host
	jmp	next1
;
signon:
.ascii	'TALK V1.5 Program to talk to host computer via serial data line'[cr][lf]
.if	testing,[	.ascii	'TESTING VERSION'[cr][lf]]
.ascii	'Command characters are:'[cr][lf][cr][lf]
.ascii	'	^^	abort current process (returns to CP/M)'[cr][lf]
.ascii	'	^D	prompt for CP/M filename to receive characters'[cr][lf]
.ascii	'		from host and initiate the transfer (by'[cr][lf]
.ascii	'		sending a <return> to host) (^F logfile)'[cr][lf]
.ascii	'	^E	prompt for CP/M filename to send to host'[cr][lf]
.ascii	'		and initiate the transfer (assumes host is'[cr][lf]
.ascii	'		ready to receive characters)'[cr][lf]
.ascii	'	^Z	when in file transfer mode causes the'[cr][lf]
.ascii	'		current operation to terminate'[cr][lf][cr][lf]
.ascii	'You are now talking to the host...'[cr][lf]'$'
;
filmsg:	.ascii	[cr][lf]'filename to receive?$'
;
newlin:	.ascii	[cr][lf]'$'
;
fnerrm:	.ascii	[cr][lf]'filename error, ignoring input...'[cr][lf]'$'
;
byemsg:	.ascii	[cr][lf]'exiting...$'
;
sndmsg:	.ascii	[cr][lf]'filename to send?$'
;
logmsg:	.ascii	[cr][lf]'log filename?$'
;
;-----------------------
;
; S U B R O U T I N E S
;
;-----------------------
;
; getch - get a character from console
;
;	exit:	character -> a
;
getch:	mvi	c,dirio$
	mvi	e,0ffh
bdose:	push	b
	push	d
	push	h
	call	bdos
	pop	h
	pop	d
	pop	b
	ret
;-----------------------
;
; prints - print ascii string on console
;
;	entry:	de -> address of string
;
prints:	mvi	c,print$
	jmp	bdose
;
; inputl - input line from console
;
;	flushes buffer with spaces
;
inputl:	mvi	b,cbfsiz;initialise console
	lxi	h,conbuf; input buffer CONBUF
	mov	m,b	; and fill with spaces
	inx	h
	xra	a
	mov	m,a
	inx	h
..0:	mvi	m,' '
	inx	h
	djnz	..0
	mvi	c,rdbuf$ ;read chars into buffer
	lxi	d,conbuf
	jmp	bdose
;-----------------------
;
; getfcb - build a CP/M filename from input string
;
;	entry:	HL -> ascii filename string
;		DE -> FCB
;	exit:	z flag <- 0 if error (A<>0)
;			  1 if ok (A=0)
;
getfcb:	xra	a	;Set result status=OK
	sta	..okfl	; and get File Control Block
	push	d
	mov	b,m	;first char might be
	inx	h	; drivename
	mov	a,m	;if this is a ":" then we
	cpi	':'	; have a drivename
	jrnz	..nodv
	mov	a,b
	call	..cpan	;check alphanumeric drive name
	inx	h	; point past colon
	ani	7	; mask drive A to H
	jmpr	..stdv
;
..nodv:	
	dcx	h	;no drivename so
	xra	a	; set to default drive
..stdv:
	stax	d	;store drivename
	inx	d	; in first byte of FCB
	mvi	b,8	;get filename (8 chars)
	call	..name
	mov	a,m
	cpi	'.'	;check optional '.'
	jrnz	..ext
	inx	h
..ext:	mvi	b,3	;get extension (3 chars)
	call	..name
	mvi	b,24	;clear rest of FCB
	xra	a
..crst:	stax	d
	inx	d
	djnz	..crst
	lda	..okfl	;Get return status
	ana	a	; set flag bits
	pop	d	; and return
	ret
;
..okfl:	.byte	0
;
..cpan:	cpi	' '	;if space or '.' then
	jrz	..cnok	; return z bit reset.
	cpi	'.'
	jrz	..cnok
	cpi	'Z'+1	;convert lower case
	jrc	..0	; alpha to upper case
	sui	020h
..0:	cpi	'0'	;check for numeric
	jrc	..cper
	cpi	'9'+1
	jrc	..cok
	cpi	'A'	;check for alpha
	jrc	..cper
	cpi	'Z'+1
	jrnc	..cper
..cok:	cmp	a	;return with z flag
	ret		; set if alphanumeric


..cper:	push	psw	;not alphanumeric
	mvi	a,0ffh	; so set flag to
	sta	..okfl	; signify error
	pop	psw
..cnok:	ori	0ffh	;reset zero flag
	ret	
;
..name:	mov	a,m	;get char from buffer
	call	..cpan	; and check it
	jrnz	..nr	;if error change to ' '
	inx	h
	stax	d	;put it to FCB (we
	inx	d	; don't check errors
	djnz	..name	; 'til end)
	ret
..nr:	mvi	a,' '
	stax	d
	inx	d
	djnz	..nr
	ret
;-----------------------
;
; send - send character to host
;
;	entry:	A <- character
;
send:
	push	psw	;output the character
..wait:	in	siobc	; to sio channel B
	ani	00000100b; when the TxRDY bit
	jrz	..wait	; is set
	pop	psw
	out	siobd
	ret
;-----------------------
;
; conout - output character to console
;
;	entry:	A <- character
;
conout:	mov	e,a
	mvi	c,conwr$
	jmp	bdose
;-----------------------
;
; inisio - initialise Z80 SIO for interrupt
;	input from host
;
inisio:
	di
	lxi	h,intvec;set the interrupt
	mov	a,h	; vector on the cpu
	stai		; and store the low
	mov	a,l	; byte in sio control
	sta	ivec	; data area
	lxi	h,init$t;point to i/o init table
..1:	mov	b,m	; get # bytes,
	inx	h
	mov	c,m	;  i/o port
	inx	h
	outir		;  and output
	bit	7,m
	jrz	..1

	lxi	h,rxdvr	; interrupt vectors
	shld	rx.v	;  Rx channel B
	lxi	h,rxerra
	shld	rxe.v	;  Rx error channel B

	im2		;make sure its mode 2
	ei		; interrupts

	ret
;
; init$t - Z80 SIO and baud rate initialise
;	   data for Ferguson BIG BOARD
;
init$t:
	.ifnot	testing,[
	.byte	1	;Baud rate for
	.byte	bauda	; channel B on the
	.byte	baudr	; Big board.
]
	.if	testing,[
	.byte	2
	.byte	ctcb	;My system uses a Z80 CTC
	.byte	01000111b; as a clock for the Z80 SIO
	.byte	baudr
]
	.byte	12	;SIO channel B
	.byte	siobc			

	.byte	0,00011000b ;channel B reset
	.byte	4,01000100b ;16x clock, 1 stopbit, no parity
	.byte	1,00011100b ;Rx interrupt enable
	.byte	3,11000001b ;8bits / Rx character, Rx enable
	.byte	5,11101010b ;8bits / Tx character, DTR, RTS, Tx enable
	.byte	2
ivec:	.byte	0	   ;interrupt vector

	.byte	-1	;end of table marker

;-----------------------
;
; rxinten - set flag so characters received
;	    from host are buffered
;
rxinten:
	mvi	a,true
	sta	buf.active
	jmp	sendq
;-----------------------
;
; rxecho - set flag so characters received
;	   from host are echoed
;
rxecho:	mvi	a,false
	sta	buf.active
sendq:	mvi	a,ctrlq	;send ^Q to host
	jmp	send
;-----------------------
;
; rxdint - disable host receive
;	   character interrupts
;
rxdint:	mvi	a,1	;turn off so that
	out	siobc	; when we return to
	mvi	a,00000000b; CP/M we won't
	out	siobc	; bomb out (RXDVR is
	ret		; overlayed)
;-----------------------
;
; prxch - print the last received character
;	  from the host
;
prxch:	di		;let's not get any
	lda	rxchar	; interruptions while
	mov	c,a	; we talk a copy of
	xra	a	; the last character
	sta	rxchar	; received and clear
	ei		; it
	mov	a,c	;has a character been
	ora	a	; received ?
	rz		;no
	jmp	conout	;yes, print it so he
			; can see that something
			; is happening.
;-----------------------
;
; rxdvr - receive host character interrupt
;	   driver.
;
rxdvr:
	push	psw	;save registers
	push	b
	push	d
	push	h

rxdvr2:	lda	buf.active;check for buffered
	ora	a	; mode
	jrnz	rxbufi	;yes
	in	siobd	;no, just get the
	ani	noparity; character and save
	sta	rxchar	; it
	jmpr	retdvr
rxbufi:
	lhld	free.ptr;buffered mode.
	in	siobd	;get character
	ani	noparity; mask parity bit
	mov	m,a	; and store
	sta	rxchar
	inx	h	;bump pointer
	shld	free.ptr; and store.
	lda	buf.sub	;get end of buffer
	ora	a	; address depending
	lxi	d,buf2	; on buffer subscript
	jrz	..a
	lxi	d,bufend
..a:	mov	a,h	;is the current buffer
	cmp	d	; full (ie: is free.ptr
	jrnz	..ret	; now pointing past
	mov	a,l	; current buffer) ?
	cmp	e
	jrnz	..ret	;no.
..full:	
	lda	buf.sub	;swap buffer pointers
	ana	a	; to other buffer
	jrz	..0	; (using buffer
	lxi	h,buf1	; subscript)
	mvi	a,0
	jmpr	..1
..0:	lxi	h,buf2
	mvi	a,1
..1:	sta	buf.sub	;record new buffer
	shld	buf.ptr	; pointers
	shld	free.ptr

	mvi	a,true	;signal that write
	sta	buf.rdy	; buffer is ready

..ret:	lda	rxchar	;if character from
	cpi	ctrlz	; host was a "^Z"
	jrnz	retdvr	; then also set the
	mvi	a,true	; end of file flag
	sta	eof.flag

retdvr:	pop	h	;restore registers
	pop	d
	pop	b
	pop	psw
	ei		; and return
	reti
;
rxchar:	.byte	0
;
;-----------------------
;
; rxerra - receive host character error
;	   interrupt driver.
;
rxerra:
	push	psw	;if by some means
	push	b	; a parity or
	push	d	; framing error is
	push	h	; detected then
	mvi	a,00010000b
	out	siobc
	mvi	a,00110000b; error reset
	out	siobc
	jmp	rxdvr2	; and process character
;-----------------------
;
; getfile - get a CP/M file from host computer
;
;	entry:	FCB is file to get
;
getfile:
	lxi	h,buf1	;initialise buffer pointers
	shld	free.ptr; and subscripts for
	shld	buf.ptr	; transfer.
	shld	write.ptr
	mvi	a,0
	sta	buf.sub
	sta	wr.sub
	mvi	a,false	;clear done.flag, eof.flag,
	sta	done.flag; buf.rdy indicator and
	sta	eof.flag;  err.flag
	sta	buf.rdy
	sta	err.flag
	call	make	;open file
	rnz		; abort if error
	call	rxinten	;enable receive buffer interrupts
	lda	log.flag;if log file operation
	ana	a	; then skip sending a <CR>
	jrnz	..1
	mvi	a,cr	;send <CR>
	call	send	
..1:	lda	buf.rdy	;if buf.ready.flag set then
	ana	a
	jrz	..2
	mvi	a,false
	sta	buf.rdy
	call	stopsend; stop host from sending
	call	write	; write to file
	mvi	a,ctrlq	; send host resume
	call	send
	jmpr	..3
..2:
	lda	eof.flag;else if end.of.file then
	ora	a
	jrz	..3
	call	stopsend; stop host from sending
	call	puteofch; and put an end of file mark
			; in the buffer.
	call	write
	call	close
	mvi	a,true	; set done.flag
	sta	done.flag
..3:
	lda	done.flag
	ora	a	;if done.flag set then
	jrnz	getexit; exit
	lda	err.flag;if err.flag set then
	ora	a	; abort
	jrnz	..4
	call	prxch
	call	getch	;get char (if any) from
	ana	a	; console. Skip the
	jrz	..1	; tests if nothing typed
	cpi	ctrly	;test character and abort
	jrz	..4	; if ^Y is struck
	cpi	ctrlz
	jrz	..9
	push	psw
	lda	log.flag;if log file active
	ana	a	; then we want to send
	jrnz	..8	; characters typed
	pop	psw
	jmpr	..1
..8:	pop	psw
	call	send
	jmpr	..1
..9:	mvi	a,true
	sta	eof.flag
	jmpr	..1
..4:
	call	rxecho
	lxi	d,sabmsg; print "file transfer aborted"
	call	prints	; and return
	ret
getexit:
	call	rxecho	;disable host buffer Rx
	lxi	d,sdnmsg;print "file transferred"
	call	prints	; and return
	ret
;
sabmsg:	.ascii	[cr][lf]'file transfer aborted'[cr][lf]'$'
;
sdnmsg:	.ascii	[cr][lf]'file transferred from host'[cr][lf]'$'
;
;-----------------------
;
; sendfile - send CP/M file to host
;
sendfile:
	call	open	;open file
	rnz		; and return if error
	lxi	d,senmsg;print "sending file
	call	prints	; to host"
	mvi	a,cr	;send a <CR> to
	call	send	; host
..rdlp:	mvi	c,readf$;read next sector from
	lxi	d,fcb	; file to RBUF
	call	bdose
	ora	a	;CP/M end of file?
	jrnz	..eof	;yes
	xra	a	;no, clear newline
	sta	crflag	; flag so we only send
			; a <CR> for each <CR><LF>
	lxi	h,rbuf	;set address and
	mvi	b,128	; number of bytes

..slp:	lda	crflag	;was last char a <CR>?
	ora	a
	jrz	..sn	;no
	xra	a	;yes, reset flag
	sta	crflag
	.if	opt.delay,[
	    push    h	    ;delay 250ms to allow
	    lxi     h,250   ; host to process the
	    call    delay   ; last line.
	    pop     h
	]
	mov	a,m	;get next character
	inx	h
	cpi	lf	;ignore next linefeed
	jrz	..keep
	jmpr	..sn2
..sn:	mov	a,m	;get next char from
	inx	h	; read buffer
..sn2:	cpi	cr	;if it's a <CR> then
	jrnz	..sn1	; set flag
	sta	crflag
..sn1:	call	send	; and send it to host
	.if	testing,[
	    push    h       ;echo what we send
	    push    d       ; to the console.
	    push    b
	    push    psw
	    call    conout
	    pop     psw
	    pop     b
	    pop     d
	    pop     h
	]
	cpi	ctrlz	;was it a ^Z?
	jrz	..eof	;yes
..keep:	djnz	..slp	;no, keep sending...
	call	getch	;check for ^Y from
	cpi	ctrly	; console
	jrnz	..rdlp	; none, so keep going
	lxi	d,sabmsg;print "file transfer
	call	prints	; aborted"
	call	close
	ret
..eof:	call	close	;close input file
	lxi	d,fstmsg;print "file sent
	call	prints	; to host successfully"
	ret
;
senmsg:	.ascii	[cr][lf]'Sending file to host...'[cr][lf]'$'
;
fstmsg:	.ascii	[cr][lf]'File sent to host successfully'[cr][lf]'$'
;
;-----------------------
;
; make - create new CP/M file
;
make:	lxi	d,fcb	;delete any old
	mvi	c,delet$; file
	call	bdose
	lxi	d,fcb	; and open a new
	mvi	c,creat$; one
	call	bdose
	cpi	0ffh	;any errors ?
	jrz	..0	;yes
	mvi	a,false	;no, return status
	ora	a	; OK
	ret
..0:	lxi	d,opnmsg;error, print "open failure"
	call	prints
	mvi	a,true	;and return with status
	ora	a	; not OK
	ret
;
opnmsg:	.ascii	[cr][lf]'?CP/M file create failure'[cr][lf]'$'
;
;-----------------------
;
; open - open file (which must already exist)
;
open:	mvi	c,sdma$	;set buffer address
	lxi	d,rbuf	; for reads
	call	bdose
	mvi	c,openf$
	lxi	d,fcb
	call	bdose
	cpi	0ffh	;find it?
	jrz	..opnf
	xra	a
	ret
..opnf:	lxi	d,opfmsg;no, print "can't find
	call	prints	; file"
	mvi	a,0ffh
	ora	a
	ret
;
opfmsg:	.ascii	[cr][lf]"?Can't find CP/M file"[cr][lf]'$'
;
;-----------------------
;
; close - close file
;
close:
	lxi	d,fcb
	mvi	c,close$
	jmp	bdose
;-----------------------
;
; stopsend - stop host from sending
;
stopsend:
	mvi	a,ctrls	;send ^S
	call	send
..0:
	lhld	free.ptr; copy free.ptr
	shld	sav.ptr
	lxi	h,1000	; delay 1 second
	call	delay
	lhld	sav.ptr	; if free.pointer
	lded	free.ptr;  hasn't moved then
	ana	a	;  return, else
	dsbc	d	;  keep waiting
	jrnz	..0
	ret
;
sav.ptr:.blkb	2
;
;-----------------------
;
; write - write buffer to CP/M disk file
;
write:
	lda	eof.flag;if not end.of.file then
	ora	a	; write out a whole buffer
	jrz	..3
	lded	write.ptr; otherwise calculate
	lhld	free.ptr; the number of sectors
	ora	a	; = ((free.ptr - write.ptr)*2/256)+1
	dsbc	d
	dad	h
	mov	a,h
	inr	a
	jmpr	..2
;
..3:	mvi	a,numsec;set number of sectors
..2:	sta	..nsec	; to write.

..wnxt:
	lded	write.ptr;set disk buffer
	mvi	c,sdma$	; address
	call	bdose

	lxi	d,fcb	;write next sector
	mvi	c,write$
	call	bdose
	ana	a	;abort if write error
	jrnz	..err	; status returned.

	lhld	write.ptr;point to next logical
	lxi	b,128	; sector
	dad	b
	shld	write.ptr
	lda	..nsec	;repeat until all sectors
	dcr	a	; have been written
	sta	..nsec
	jrnz	..wnxt

	lda	wr.sub	;swap write.ptr and
	ora	a	; wr.sub to the
	jrz	..4	; other buffer so
	lxi	h,buf1	; we write it next
	mvi	a,0	; time.
	jmpr	..5
..4:	lxi	h,buf2
	mvi	a,1
..5:	sta	wr.sub
	shld	write.ptr
	ret

..err:	lxi	d,wremsg;print "write error"
	call	prints
	call	close	;close CP/M file
	mvi	a,true	; and set error flag
	sta	err.flag
	ret
;
..nsec:	.byte	0
;
wremsg:	.ascii	[cr][lf]'?CRITICAL ERROR - Disk full'[cr][lf]'$' 
;
;-----------------------
;
; puteofch - Put an end-of-file marker (^Z)
;	    at the end of the current buffer.
;
puteofch:

	di
	lhld	free.ptr
	mvi	m,ctrlz
	inx	h
	shld	free.ptr
	ei

	ret
;-----------------------
;
; delay - delay the millisecond count
;	  passed in the HL register pair
;
delay:	mvi	a,delcnt/26
..0:	dcx	h
	inx	h
	dcr	a
	jnz	..0
	dcx	h
	mov	a,l
	ora	h
	jnz	delay
	ret
;
; G L O B A L   F L A G S
;
done.flag:
	.byte	0	;set when transfer complete
eof.flag:
	.byte	0	;set when ^Z received from host
buf.rdy:
	.byte	0	;set when rx buffer full
err.flag:
	.byte	0	;set if a fatal error occurs
buf.active:
	.byte	0	;set when buffer i/o is active

crflag:	.byte	0	;set to filter <LF> from sent file
log.flag:
	.byte	0	;set to store characters received
			; in a log file.
;
; B U F F E R   P O I N T E R S
;
free.ptr:		;points to next free byte to
			; receive a character from
	.word	buf1	; the host.
buf.ptr:		;points to start of current
	.word	buf1	; receive buffer.
write.ptr:		;points to start of the next
	.word	buf1	; buffer to write to disk.
buf.sub:		;subscript into buffer
	.byte	0	;( 0=buf1, 1=buf2 )
wr.sub:	.byte	0
;
; fcb - CP/M file control block
;
fcb:	.blkb	36
;
; B U F F E R S
;
;
; conbuf - console input buffer
;
cbfsiz	=	64
conbuf:	.byte	cbfsiz
nchrs:	.byte	0
	.blkb	cbfsiz
;
numsec	==	bufsiz/128
;
buf1:	.blkb	bufsiz
buf2:	.blkb	bufsiz
bufend:
;
rbuf:	.blkb	128	;CP/M file read buffer
;
	.end	start
