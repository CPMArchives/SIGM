;===============================================================
;
;	Prom Based CP/M and ISIS 4.0 Bios, August 9, 1981
;
;                        Version 1.0
;
;       (For Tarbell Disk Controller and Dynabyte Video)
;
;===============================================================
;
; This module contains the input/output routines used by ISIS II
; and a CP/M cold boot loader.
;
true	equ	-1		; define value of true
false	equ	not true	; define value of false
debug	equ	false		; set true if setup assembly for 
				; ram based debug at 32 memory size
;
stprat	equ	2		; rate 1=6ms, 2=10ms, 3=20ms
hlab	equ	8		; 8 for hd ld at beg of seek
;
; define disk controller base addresses for operations
;
disk	equ	0f8h		; disk base address
dcom	equ	disk		; disk command port
dstat	equ	disk		; disk status port
track	equ	disk+1		; disk track port
sectp	equ	disk+2		; disk sector port
ddata	equ	disk+3		; disk data port
wait	equ	disk+4		; disk wait port
dcont	equ	disk+4		; disk control port
;
; define console and printer interface parameter equates
;
cstat	equ	00h		; console status port
cdata	equ	01h		; console data port
lstat	equ	42h		; list status port
ldata	equ	43h		; list data port
ckbr	equ	00000001b	; keyboard ready bit
cptr	equ	10000000b	; crt out ready bit
lptr	equ	00000001b	; printer output ready bit
;
; define stack top location
;
stack	equ	100h	; top of stack
;
; define ASCII character codes that are referenced
;
cr	equ	0dh		; ASCII cariage return
lf	equ	0ah		; ASCII linefeed
;
; define ISIS and CP/M storage locations and constants
;
iobyte	equ	0003h		; INTEL iobyte
initio	equ	0006h		; initial I/O config
memtop	equ	0004h		; location ISIS stores the top of ram
;
	if	debug
monitor	equ	08800h		; monitor start
memsiz	equ	32		; ram memory size in decimal kilo bytes
	endif			; debug
;
	if	not debug
monitor	equ	0f800h		; monitor start
memsiz	equ	62		; ram memory size in decimal kilo bytes
	endif			; not debug
;
memmax	equ	((memsiz*1024)/256)-1	; memory map area
date	equ	0715h		; date
verh	equ	10h		; version 1.0
;
	org	0ffffh
;
	db	0		; set version number of monitor
;
; start of CP/M and ISIS boot load point routine
;
	org	monitor		; origin of this program
;
	jmp	start0		; reset entry point
	jmp	conin		; console input
	jmp	reader		; reader input
	jmp	conout		; console output
	jmp	punch		; punch output
	jmp	list		; list output
	jmp	const		; console input status
	jmp	iochk		; I/O system status
	jmp	ioset		; set I/O configuration
	jmp	memchk		; compute size of memory
	jmp	dummy		; define user I/O entry points
	jmp	dummy
	dw	date		; date stamp for monitor rom
	jmp	dummy		; upp input
	jmp	dummy		; upp output
	jmp	dummy		; upp status
	db	verh		; version stamp for monitor rom
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	; dummy copyright
	jmp	dummy		; ioccom entry point
	jmp	dummy		; ioc output
	jmp	stat78		; disk controller 1 status
	jmp	stat88		; disk controller 2 status
	jmp	cmmd78		; disk controller 1
	jmp	cmmd88		; disk controller 2
	jmp	rtyp78		; disk controller 1 result type
	jmp	rtyp88		; disk controller 2 result type
	jmp	rbyt78		; disk controller 1 result byte
	jmp	rbyt88		; disk controller 2 result byte
;
; disk command to controller that should be at 88h
; hl points to address of I/O parameter block
;
cmmd88:	mvi	a,2		; mark this is for controller 2
	jmp	cmmdent		; go do common I/O command
;
;
; disk command to controller that should be at 78h
; hl points to address of I/O parameter block
;
cmmd78:	xra	a		; mark this is for controller 1
cmmdent:shld	iopb		; save pointer to iopb
	lxi	h,0		; make hl 0 for dad
	dad	sp
	shld	ostack		; save old stack pointer
	lxi	sp,newstk	; set up new stack
	push	d		; save d and e
	push	b		; save b and c
	mov	c,a		; drive select bit 1
	lxi	h,iodone	; make return address
	push	h		; put it on stack
;
; copy iopb into scratch area
;
	lxi	d,ioblk		; point to ioblk destination
	lhld	iopb		; point to source
	mvi	b,7		; number of bytes to move
ibkmov:	mov	a,m		; get a byte
	stax	d		; store a byte
	inx	h		; bump pointers
	inx	d
	dcr	b		; decrement count
	jnz	ibkmov		; loop if not done
;
; select disk drive specified in iopb
;
	lda	dskins		; get disk instruction
	rrc
	rrc
	rrc
	rrc			; drive select bits to 1 and 2
	ani	1		; select bit 0
	ora	c		; select bit 1
	call	seldsk		; select drive
;
; test if selected drive is ready, error if not ready
;
	in	dstat		; read status
	rlc			; look at drive ready bit
	jc	rdyerr		; error if not ready
;
; execute disk instruction from iopb
;
	lda	dskins		; get disk instruction
	ani	7		; look at opcode only
	cpi	4
	jz	iread		; goto INTEL read
	cpi	6
	jz	iwrite		; goto INTEL write
	cpi	7
	jz	iwrite		; do deleted write like normal write
	cpi	5
	jz	iverf		; goto INTEL verify
	cpi	1
	jz	seek		; goto INTEL seek
	cpi	2
	jz	ifrmat		; INTEL format
	cpi	3
	jz	home		; do INTEL home
	xra	a		; nop, ret result byte=0
	ret
;
; disk I/O complete restore regs and restore sp and return
; disk controller simulator exit point
;
iodone:	sta	resbyt		; save disk status
	pop	b		; restore regs
	pop	d
	lhld	ostack
	sphl			; restore stack
	lhld	iopb
	ret			; return to ISIS
;
; user entry point to check the status of the I/O byte
;
iochk:	lda	iobyte		; get status byte
	ret
;
; user entry point to change the I/O byte to a new value
;
ioset:	mov	a,c		; put new value into the memory
	sta	iobyte
	ret
;
; user entry point to get the value of the top of available memory
;
memchk:	lda	memtop+1	; msbyt of top address of memory
	dcr	a		; change one page less to permit
				; monitor to use 256 bytes of ram
	mov	b,a		; msbyt in b reg
	mvi	a,0c0h		; ab points to base of user stack
	ret			; in 2'nd from top page of ram
;
; dummy I/O routine
;
dummy:	xra	a
	ret			; dummy routine
;
; routine to simulate getting ready status of the single density
; INTEL disk controller hardware
;
stat78:	equ	$
;
stat88:	mvi	a,0bh		; show always ready
	ret
;
; routine to imitate return of result type byte from the disk 
; controller hardware
;
rtyp78:	equ	$
;
rtyp88:	xra	a
	ret
;
; routine to imitate reading of the result byte from the disk
; controller hardware code was made by the disk operation
; command routines and stored at resbyt in the top page of ram
;
rbyt78:	equ	$
;
rbyt88:	lda	resbyt		; get result byte
	ret
;
; here to setup start of command inquiry loop to boot either
; a CP/M system disk of up to 62k size or to load an ISIS 40
; system disk that has been patched for disk I/O through this 
; prom based i/c-bios software
;
start0:	lxi	sp,stack	; set stack pointer
;
; put jump to monitor at zero
;
	mvi	a,0c3h		; put jump to monitor at 0
	sta	0000h
	lxi	h,monitor
	shld	0001h
	mvi	a,01h		; console is crt
	sta	iobyte
	sta	initio
;
; calculate top of memory and store at "memtop" for the ISIS 
; system operation
;
	lxi	h,03f00h	; start point for test
pag:	inr	h		; set to next page
	jz	fnd		; stop if at end
	mov	a,m		; get memory byte
	cma			; complement it
	mov	m,a		; put comp in memory
	cmp	m		; did it go in ok
	cma			; invert back
	mov	m,a		; restore original
	jz	pag		; loop to next 256 bytes if it changed
fnd:	dcx	h		; back up a page
	mov	a,h
	cpi	memmax		; less than f700h
	jc	x11		; if yes then use this value
;
fnd1:	mvi	h,memmax	; otherwise set memtop to 0f7ffh
;
x11:	shld	memtop		; set ISIS memory top address
;
; command check loop for monitor operation select
;
iboot:	lxi	h,stmsg		; point to start msg
	call	pmsg		; print message
iboot1:	call	conin		; wait for response
	push	psw		; echo operator response
	mov	c,a
	call	conout
	pop	psw
	ani	05fh		; convert input to upper case
	cpi	'C'		; check if CP/M boot
	jz	cpmboot
	cpi	'I'		; or if ISIS boot
	jnz	iboot		; if neither then prompt again
;
; print ISIS prompt message and then load disk on input of a "cr"
;
isisboot:
;
	lxi	h,isisms	; print ISIS load message
	call	pmsg
	call	conin		; get ready status
	cpi	cr		; see if a cr
	jnz	iboot		; start all over if not ISIS boot
	lxi	h,crlf		; print carriage return linefeed
	call	pmsg
;
; force interrupt
;
	mvi	a,0d0h		; force interrupt command
	out	dcom
	in	dstat		; clear interrupt
;
; setup scratch area
;
	lxi	h,0ffffh
	shld	trtab		; preset track table
	shld	trtab+2
	mvi	a,4		; set up initial out of range disk
	sta	diskno
	xra	a
	call	seldsk		; select drive 0
;
; boot in ISISt0 to location 3000 and execute
;
	lxi	h,bootpb	; point to boot parameter block
	call	cmmd78		; read in disk
	ora	a
	jz	3000h		; if no errors goto ISIS
	lxi	h,bmsg
	call 	pmsg		; print boot error message
	jmp	iboot		; if error then go try for another command
;
; iopb for booting ISISt0 in to 3000h
;
bootpb:	db	80h		; iocw, no update bit set
	db	04h		; I/O instruction, read disk 0
	db	26		; read 26 sectors
	db	0		; track 0
	db	1		; sector 1
	dw	3000h		; load address
;
; print CP/M prompt message and then load disk on input of a "cr"
;
cpmboot:lxi	h,cpmms		; print CP/M load message
	call	pmsg
	call	conin		; get ready status
	cpi	cr		; see if a cr
	jnz	iboot		; start all over if not CP/M boot
	lxi	h,crlf		; print carriage return linefeed
	call	pmsg
;
; force interrupt
;
	mvi	a,0d0h		; force interrupt command
	out	dcom
	in	dstat		; clear interrupt
;
; setup scratch area
;
	lxi	h,0ffffh
	shld	trtab		; preset track table
	shld	trtab+2
	mvi	a,4		; set up initial out of range disk
	sta	diskno
	xra	a
	call	seldsk		; select drive 0
;
; boot normal CP/M track zero sector 1 into ram at zero and
; jump to it to get in rest of CP/M
;
	lxi	h,cpmpb		; point to boot parameter block
	call	cmmd78		; read in disk
	ora	a
	jz	0000h		; if no errors goto CP/M loader
	lxi	h,bmsg
	call 	pmsg		; print boot error message
	jmp	iboot		; if error then go try for another command
;
; iopb for booting CP/M track 0 sector 1 into 0000h
;
cpmpb:	db	80h		; iocw, no update bit set
	db	04h		; I/O instruction, read disk 0
	db	01		; read one sector
	db	0		; track 0
	db	1		; sector 1
	dw	0000h		; load address
;
; hardware interface I/O routines for ISIS bios software
;
; check console input status
;
const:	in	cstat		; read console status
	ani	ckbr
	mvi	a,0		; set a=0
	rnz			; return if not ready with a=0
	cma
	ret
;
; read a character from console
;
conin:	in	cstat		; read console status
	ani	ckbr		; if not ready
	jnz	conin		; keep waiting
	in	cdata		; read a character
	ani	7fh		; make most sig bit=0
	ret
;
; write a character to the console device
;
conout:	in	cstat		; read console status
	ani	cptr		; if not ready,
	jnz	conout		; keep waiting
	mov	a,c		; get character
	out	cdata		; print it
	ret
;
; write a character to the list device
;
list:	in	lstat		; read list port status
	ani	lptr		; if not ready,
	jz	list		; then keep waiting
	mov	a,c		; get character
	out	ldata		; print it
	ret
;
; select disk number according to register a
;
seldsk:	lxi	h,diskno	; get addr of old disk no
	cmp	m		; new=old?
	mov	c,a		; c=new drive
	jz	seld1
;
; if changing to a new drive perform a seek to the same track
; this is an undocumented procedure which unloads the head
;
	in	track		; get the present track
	out	ddata		; put in 1771 data reg
	mvi	a,10h		; seek command
	out	dcom		; seek same track
	in	wait
;
; get old track number from 1771 and put into table
;
	mov	e,m		; e=old disk no
	mvi	d,0		; clear d for dad
	lxi	h,trtab		; point to table
	dad	d		; index into table
	in	track		; read 1771 track reg
	mov	m,a		; put into table
;
; get new drive track number from table and put in 1771
;
	mov	e,c		; e=new disk no
	mvi	d,0		; clear d for dad
	lxi	h,trtab		; point to table
	dad	d		; index into table
	mov	a,m		; get new track number
	out	track		; update 1771 track reg
;
; update diskno and select new drive
;
seld1:	mov	a,c		; update old disk number
	sta	diskno
	cma
	add	a		; put bits 1 and 2 at 4 and 5
	add	a
	add	a
	add	a
	ori	2
	sta	latch		; update latch
	out	dcont		; select drive
;
; if table entry for this drive is ff then this drive is not logged
; and we must do a recalibrate before returning from seldsk
;
	mov	a,m		; get track from table
	inr	a		; if 0ffh then recalibrate
	rnz
;
; move disk to track zero
;
home:	mvi	a,stprat+hlab	; restore command
	out	dcom		; to controller
	in	wait		; wait for restore complete
	in	dstat		; read status
	ani	91h		; look at these bits
	rz			; return good
	mvi	a,00000100b	; seek error
	ret			; return bad
;
; seek track specified in iopb
;
seek:	lda	itrack		; get track # from iopb
	cpi	77		; more than 77 ?
	jnc	adrerr		; error if more
	mov	b,a		; b=destination track
	in	track		; a= present track no
	mov	c,a		; c= present track also
	cmp	b		; dest=present ??
	rz			; return if same
;
; this routine is to allow time for the drive
; tunnel erase to terminate before moving the
; head the delay is approx 700 micro-sec @
; 4 mhz cpu time, and  double this for 2 mhz cpu's
;
	push	psw
	mvi	a,208		; delay count
busy1:	dcr	a		; count=count-1
	jnz	busy1		; loop til count=0
	pop	psw
	mov	a,b		; a=destination track
	out	ddata		; track to data register
busy:	in	dstat		; read disk status
	rrc			; look at bit 0
	jc	busy		; wait till not busy
	mvi	a,10h+stprat+hlab ; get step rate and head load
	out	dcom		; do seek
	in	wait		; wait for seek done
	in	dstat		; read controller status
	ani	91h		; look at these bits
	rz			; return good
	mvi	a,00000100b	; seek error
	ret			; return bad
;
; hdld-get head-load bit if required
;
hdld:	in	dstat		; read 1771 status
	ani	20h		; look at hl bit
	jz	hdldy		; load if not loaded
	xra	a		; otherwise, a=0
	ret			; return from hdld
hdldy:	mvi	a,4		; set bit to load head
	ret			; return from hdld
;
; write sector or sectors specified in iopb
;
iwrite:	call	seek		; check params and seek track
	rnz			; return if seek error
	mvi	c,20h		; set (c) to write code
	jmp	ddio		; go do common I/O
;
; verify sector or sectors specified in iopb
;
iverf:	call	seek		; check parms and perform seek
	rnz			; return if seek error
	mvi	c,080h		; set verify function bit
	jmp	ddio		; go do common I/O
;
; read sector or sectors specified in iopb
;
iread:	call	seek		; check params and seek track
	rnz			; return if seek error
	mvi	c,0		; set read function code and 
				; fall through to common I/O
;
; do disk common operations
;
ddio:	lhld	dmaadd		; get dma address in h and l
	mvi	a,0d0h
	out	dcom		; force interupt
	lda	sect		; get iopb sector
	ani	1fh		; strip select bit
	cpi	27		; more than 26 ?
	jnc	adrerr		; error if more
	out	sectp		; sector to 1771
	call	hdld		; head loaded ?
	adi	88h
	push	b		; save function byte in (c)
	push	psw		; strip possible verify bit off (c)
	mov	a,c
	ani	07fh
	mov	c,a
	pop	psw
	ora	c		; read/write
	out	dcom		; command to 1771
	pop	b
	mov	a,c		; get read/write
	cpi	020h		; check for write
	jz	wloop		; if 020h then write
	cpi	080h		; check for verify
	jz	vloop		; if 080h then verify
				; must be read if not write/verify
;
; read loop			; else read
;
rloop:	in	wait		; wait for drq or intrq
	ora	a		; set flags
	jp	rdone		; if p then was intrq, done
	in	ddata		; otherwise drq, get byte
poke:	mov	m,a		; put into memory
	inx	h		; bump memory pointer
	jmp	rloop		; continue reading
;
; read exit
;
rdone:	in 	dstat		; get status
	ani	9dh		; look at these error bits
	jnz	dskerr
				; fall through to next record check
;
; next record of multiple record check
;
nxtrec:	lxi	h,numrec	; point to numrec in iopb
	dcr	m		; numrec=numrec-1
	rz			; return if numrec=0
	lhld	dmaadd		; else get dma address
	lxi	d,128
	dad	d		; hl=hl+128
	shld	dmaadd		; update dma address
	lxi	h,sect		; point to sector # in iopb
	inr	m		; sect=sect+1
	mov	a,m
	cpi	27		; greater than 26 ??
	jc	ddio		; continue if range ok
	jmp	adrerr		; otherwise error
;
; verify loop
;
vloop:	in	wait		; wait for drq or intrq
	ora	a		; set flags
	jp	vdone		; if p then was intrq and done
	in	ddata		; otherwise drq so get data
				; we wont use data if a verify op
	inx	h		; do pointer anyway
	jmp	vloop		; go for next byte
;
; verify exit
;
vdone:	in	dstat		; get operation status
	ani	09dh		; mask appropiate bits
	jnz	dskerr		; go to error tree if I/O error
	jmp	nxtrec		; see if more records to do
;
; write loop
;
wloop:	in 	wait		; wait for drq or intrq
	ora	a		; set flags
	jp	wdone		; if p then was intrq, done
	mov	a,m		; get a byte from memory
	out 	ddata		; send to 1771
	inx	h		; bump memory pointer
	jmp	wloop		; continue writing
;
; write done
;
wdone:	in 	dstat		; read status
	ani	0fdh		; look at these error bits
	jz	nxtrec		; see if more records
;
; disk I/O error sorting tree that converts 1771 error codes into
; those required to emulate an INTEL disk controller
;
dskerr:	cpi	10000000b	; test for not ready
	jz	rdyerr
	cpi	01000000b	; test for write protect
	jz	wprot
	cpi	00000100b	; test for lost data
	jz	losdat
	cpi	00011000b	; test for id crc error
	jz	idcrc
	cpi	00010000b	; test for record not found
	jz	idcrc
				; lets say all else is crc
crcerr:	mvi	a,00000010b	; make code for crc error
	ret
;
wprot:	mvi	a,00100000b	; make code for write protect
	ret
;
rdyerr:	mvi	a,10000000b	; make code for not ready
	ret
;
losdat:	mvi	a,00010000b	; make code for lost data
	ret
;
idcrc:	mvi	a,00001010b	; make code for id crc
	ret
;
adrerr:	mvi	a,00001000b	; make code for adress error
	ret
;
; format a track-this routine here due to fact that INTEL controller
; directly supports a track format operation for the "idisk" command
;
ifrmat:	in	dstat		; read disk status
	ani	01000000b
	jnz	wprot		; error if write protected
	call	seek		; seek desired track
	lda	chword		; get channel word
	ani	01000000b	; look at format sequence
	jnz	random		; go setup table for random
;
; sequential format-fill table with fill characters and sequential
; sector numbers fill byte pointed to by dmaadd
;
seq:	lhld	dmaadd		; point to fill byte
	mov	d,m		; put fill byte into (d)
	mvi	a,01h		; start sector number
	lxi	h,fmttab	; point to format table
seqlp:	mov	m,a		; put sector into table
	inx	h
	mov	m,d		; put fill char into the table
	inx	h
	inr	a		; increment sector number
	cpi	27		; table all filled yet?
	jnz	seqlp
	jmp	seq1		; go start format
;
; random format-fill table with sector and fill bytes that was
; built by caller in the iopb pointed data buffer
;
random:	lhld	dmaadd		; point to callers table
	mvi	b,52		; number of entries to move across
	lxi	d,fmttab	; point to our table
randlp:	mov	a,m		; get users byte
	stax	d		; put into our table
	inx	h		; do pointer adjust for loop
	inx	d
	dcr	b		; moved all bytes yet?
	jnz	randlp
seq1:	lxi	h,fmttab	; point to format order table
	lda	itrack		; get track number
	mov	c,a		; put it in c
	mvi	e,26		; set max # sectors
	mvi	b,40		; gap 4 preindex 40 bytes of 0ffh
	mvi	a,0f4h		; load track write command
	out	dcom		; issue track write
;
; write preindex fill
;
preind:	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	mvi	a,0ffh		; byte=0ffh
	out	ddata		; write it on disk
	dcr	b		; count=count-1
	jnz	preind		; loop til count=0
	mvi	b,6		; count=6
prein1:	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	xra	a		; byte=0
	out	ddata		; write it on disk
	dcr	b		; count=count-1
	jnz	prein1		; loop til count=0
;
; write address mark on track
;
	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	mvi	a,0fch		; load address mark
	out	ddata		; write it on disk
;
; post index gap
;
postgap:mvi	b,26		; count=26
postid:	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	mvi	a,0ffh		; byte=0ffh
	out	ddata		; write it on disk
	dcr	b		; count=count-1
	jnz	postid		; loop til count=0
;
; pre id section
;
asect:	mvi	b,6		; count=6
sector:	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	xra	a		; byte=0
	out	ddata		; write it on track
	dcr	b		; count=count-1
	jnz	sector		; loop til count=0
;
; write id address mark
;
	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; if error jmp out
	mvi	a,0feh		; get address mark
	out	ddata		; write it on disk
;
; write track number on disk
;
	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	mov	a,c		; get track number
	out	ddata		; write it on disk
;
; write one byte of 00
;
	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	xra	a		; byte=0
	out	ddata		; write it on disk
;
; write sector # on disk
;
	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	mov	a,m		; get sector #
	out	ddata		; write it on disk
;
; increment table pointer to next byte to point to sector fill byte
;
	inx	h		; point to fill byte
;
; one more byte 0
;
	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	xra	a		; byte=0
	out	ddata		; write it on disk
	inr	d		; bump sector count
;
; write 2 crc's on this sector
;
	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	mvi	a,0f7h		; get crc pattern
	out	ddata		; write it on disk
;
; get sector fill byte to (d) and inx table pointer for next sector
;
	mov	d,m		; get fill byte
	inx	h		; point to next sector number
;
; pre data 17 bytes 00
;
	mvi	b,11		; count=11
predat:	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	mvi	a,0ffh		; byte=0ffh
	out	ddata		; write it on disk
	dcr	b		; count=count-1
	jnz	predat		; loop til count=0
	mvi	b,6		; count=6
preda1:	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	xra	a		; byte=0
	out	ddata		; write it to disk
	dcr	b		; count=count-1
	jnz	preda1		; loop til count=0
;
; data address mark
;
	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	mvi	a,0fbh		; get data address mark
	out	ddata		; write it on disk
;
; fill data field with data from table
;
	mvi	b,128		; count=128
dfill:	in	wait		; wait for drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	mov	a,d		; get fill byte
	out	ddata		; write it on disk
	dcr	b		; count=count-1
	jnz	dfill		; loop til count=0
;
; write crc's
;
	in	wait		; wait till drq
	ora	a		; set flags
	jp	fmterr		; jmp out if error
	mvi	a,0f7h		; get crc byte
	out	ddata		; write it on disk
;
; end of sector fill
;
	dcr	e		; sectorcount=sectorcount-1
	jz	endtrk		; jmp if sectorcount=0
datgap:	in	wait		; wait for drq
	ora	a		; set flags	
	jp	fmterr		; jmp out if error
	mvi	a,0ffh		; byte=0ffh
	out	ddata		; write it on disk
	jmp	postgap		; do next sector
;
; do track and sector house keeping
;
endtrk:	in	wait		; wait for drq or intrq
	ora	a		; set flags
	jp	fdone		; jmp out if error
	mvi	a,0ffh		; load a with 0ffh
	out	ddata		; write it on disk
	jmp	endtrk		; do until intrq
;
; format error sort routine
;
fdone:	in	dstat		; read status
	ora	a		; test for flag
	rz			; return if no errors
fmterr:	in	dstat
	jmp	dskerr		; error if not zero
;
; read a character from reader device
;
reader:	mvi	a,1ah		; always return an eof char
;
punch:	ret			; punch is a do nothing output
;
; print data pointed to by h and l until a zero is found
;
pmsg:	mov	a,m		; get character
	ora	a		; set flags
	rz			; ret if char is a zero
	mov	c,a		; put char in "c"
	call	conout		; print character
	inx	h		; bump message pointer
	jmp	pmsg		; do another character
;
; bios messages
;
stmsg:	db	cr,lf
	db	'ISIS 4.0 Bios,  Ver.1.0 implemented by Kelly Smith'
	db	cr,lf
	db	'Use "I" to boot ISIS disk or "C" to boot CP/M disk'
	db	cr,lf,cr,lf,0
isisms:	db	cr,lf,cr,lf,'ISIS disk in drive A:, type return ',0
cpmms:	db	cr,lf,cr,lf,'CP/M disk in drive A:, type return ',0
;
crlf:	db	cr,lf,0
;
bmsg:	db	cr,lf,'+++Disk Boot Error+++',0
;
; bios scratch area placed at top of ram in system uses max of 256
; bytes in top ram page
;
	org	memmax*256		; set for top page of ram
;
;
trtab:	ds	5		; track table
diskno:	ds	1		; current disk number
latch:	ds	1		; current latch code
resbyt:	ds	1		; result byte
ostack:	ds	2		; old stack storage
iopb:	ds	2		; pointer to iopb
;
; copy of i/o parameter block
;
ioblk:	equ	$
chword:	ds	1		; channel byte
dskins:	ds	1		; disk instruction
numrec:	ds	1		; number of records to do
itrack:	ds	1		; track address
sect:	ds	1		; current sector address
dmaadd:	ds	2		; current r/w address
fmttab:	ds	52		; storage for format table
	ds	20		; stack space
newstk:	ds	1	
;
	end
