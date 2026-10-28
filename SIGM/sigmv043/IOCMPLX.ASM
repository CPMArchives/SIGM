	entry	?iopen,?atach,?ioctl,ntabs,?bclof
	entry	?bread,?bwrit,?init,?ifcb,?endin
	entry	?rdbuf,?wrbuf
	extrn	?bdos,ldem,?boot


ntabs	equ	6	; number i/o entries in tables

@open	equ	15	; open file
@srch	equ	17	; search for file in directory
@del	equ	19	; delete file from mfd
@make	equ	22	; build file entry in mfd
@read	equ	20	; read disk
@write	equ	21	; write disk
@close	equ	16	; close file
@setdma	equ	26	; set dm address
tbuff	equ	80h	; temporary buffer
cr	equ	0dh	; carriage return

false	equ	0
true	equ	not false
testsys	equ	false
nsisys	equ	false

	common	/IOCTRL/
er:	db	0	; er - byte er; used by i/o subsystem
.ac:	db	0	; number of files on control statement
.iav:	ds	2*ntabs ; one word per file
	cseg
?iopen:	sta	op	; save operation (read or write)
	xra	a	; clear hanging trash in er byte
	sta	er	; so that it won't give false error
	mov	a,l	; iav the block number is used as a file number
	xchg		; put associated buffer in hl
	shld	bfr	; save open file buffer address
	call	sioctl	; search i/o control table for this file (a)
	jc	iopn1	; file not in table (not prepared)
	mvi	a,4	; look for prepared bit in table slot
	ana	m	; (bit=00000100) means association was made
	jnz	iopn2	; between filename and a unique block number
iopn0:	sta	er	; indicate error
	ret		; return to user
iopn1:	mvi	a,5	; er=5 *error* file not in table
	jmp	iopn0	; association not made
iopn2:	mvi	m,1	; set bit 1 for read operation
	lda	op	; see if we are really going to read
	cpi	'R'	; upper case R means read (BYTE VBL)
	jz	iopn3	; jump to read segment
	cpi	'W'	; test for write
	mvi	m,2	; set write bit
	jz	iopn4	; go to write segment
; heres the spot for random file i/o you write it
	mvi	a,6	; er=6 *error* operation not R or W
	jmp	iopn0	; return to user
iopn3:	call	iopn9	; store buffer address in table
	call	ldem	; gets fcb address in de
	mvi	c,@open	; open file
	push	h	; save buffer counter address
	call	?bdos	; thru cp/m
	pop	h	;retreive buffer counter address
	mvi	m,128	; set ctr to 128 indicate buffer empty
	inr	a	; a < 255?
	rnz		; yup, return, file open for read
	mvi	a,7	; er=7 *error* file not catalogued
	jmp	iopn0	; return error to user
iopn4:	call	iopn9	; set buffer address in table
	call	ldem	; obtain fcb address
	push	d	; keep de for future calls
	mvi	c,@srch	; search for file in directory
	call	?bdos
	pop	d	; get fcb address back
	inr	a	; if a=255 then no file with given name
	jz	iopn5	; don't bother to delete and remake
	push	d	; save fcb
	mvi	c,@del	; delete file
	call	?bdos	; from mfd
	pop	d
iopn5:	mvi	c,@make	; make file entry
	call	?bdos	; in mfd for this file
	ret		; return to user

iowait:	mvi	c,11
	call	?bdos
	ora	a
	rz
	mvi	c,1
	call	?bdos
	ret
;
; subroutine to store buffer address in io control table
;
; NOTE: THE FORMAT OF THIS TABLE IS THAT THERE ARE NTAB
; ENTRIES ALL 7 BYTES LONG.  NTAB CONTROLS THE REPT OPERATION
; AND IS EXTERNAL SO THAT YOU CAN'T GO WRONG HERE
;
;		__________________________________
; byte 0:	|    operation designator	 |
;		----------------------------------
; byte 1:	|	file number from iav	 |
;		----------------------------------
; byte 2 & 3:	|	buffer memory		 |
;		|		address		 |
;		----------------------------------
; byte 4 & 5:	| cp/m file control table adrs	 |
;		| set by associate command	 |
;		----------------------------------
; byte 6:	|	buffer counter		 |
;		----------------------------------
;
; iav =>the lower 7 bits must be unique for each file.  This will
; hold up PROBABLY if you use good sense.  It can't be =0.
;
;
iopn9:	inx	h	; point to buffer memory address
	inx	h	; (was pointing to byte 0) see above
	xchg		; get it de
	lhld	bfr	; get saved address
	mov	a,l	; tranfer it to memory
	stax	d
	inx	d
	mov	a,h
	stax	d
	inx	h
	inx	d
	xchg		; important make hl point to fcb area
	ret		; prior to return
;
; search i/o control table for file number in a
; exit with address in hl of start of 7 word entry when found.
; 	carry will be =0
; if not found hl=>garbages carry set
;
sioctl:	lxi	h,?ioctl+1 ; point to file number part of table
	mvi	c,ntabs	; number of table entries
	lxi	d,iosize ; entry length (now 7 bytes)
sio0:	cmp	m	; check for = file number
	jz	sio1	; found
	dad	d	; step table
	dcr	c	; next entry?
	jnz	sio0	; loop
	stc		; set carry, not found
	ret		; return to user code
sio1:	dcx	h	; point to byte 0 of table entry (not 1)
	ora	a	; clear carry flag
	ret		; return to user
;
; general subroutines used by read/write and close as well as others
;
;
; SETDMA ADDRESS
;
SETDMA:	lhld	bfr
	xchg
	mvi	c,@setdma
	CALL	?bdos
	RET		;RETURN TO USER CODE

;
; XDEHL - tests buffer address in memory against DE
;
xdehl:	lda	bfr
	xra	e
	rnz		; not equal
	lda	bfr+1
	xra	d	;
	ret		; ?
;
; Preset registers for iocontrol table search
; - assumes bfr address is in de
;
preset:	xchg
	shld	bfr
setup:	lxi	b,iosize ; entry length
	mvi	d,ntabs	; number of entries
	lxi	h,?ioctl ; table base address
	ret
;
; Get buffer address from control table
;
gbfa:	shld	tempoh	; retain this
	xchg
	shld	tempod	; and this in case compare blows up
	xchg		; get registers back to first state
	inx	h
	inx	h	; skip over first two bytes
	jmp	ldem	; loads de from (hl) bumps hl by +2
			; it advances hl by 2 ( uses its ret to get back)
;
; write block to selected file
;
wrblk:	mvi	c,@write
	call	?bdos
	ora	a
	ret
;
; read byte to pidgin
;
; INVOKED BY: "READ k FROM b"
;
?bread:	xra	a	; set er byte to zero
	sta	er	; don't let casual use bomb program
	if	testsys
	mvi	a,'r'	; reading
	sta	which
	endif
	shld	destad	; destination address for byte
	call	preset	; load registers
	mvi	a,1	; look for read operation in table
br0:	cmp	m
	jz	br2	; found read operation
	dad	b	; next entry
	dcr	d
	jnz	br0
	mvi	a,2	; er=2 *error* no read files open
br1:	sta	er
	if	testsys	; if running tests, print errors on console
	ori	'0'	; add ascii bits

	lxi	d,hunh+1
	stax	d
	dcx	d
	lda	which
	stax	d
	mvi	c,9
	call	?bdos
	endif
	ret		; return to user
br2:	call	gbfa	; go get buffer address in de
	call	xdehl	; does de = current buffer address?
	jnz	br4	; fails
; here, we have correct buffer and read operation
; get buffer count here and return character to user
;
	call	ldem	; get fcb address
	mov	a,m	; get buffer count
	cpi	128	; is buffer full?
	jnz	br3	; no
	push	d	; save fcb
	push	h	; save address of buffer count
	call	setdma	; prepare to read
	pop	h	; get  buffer count address back
	pop	d	; get back fcb address
	push	h	; resave buffer count ( xchg two entries on stack )
	mvi	c,@read	; read block
	call	?bdos	; from disk
	pop	h	; get back buffer count address
	ora	a	; get status of read
	sta	er	; save it
	jnz	br5	; bad read return from bdos
	mov	m,a	; zero buffer counter
br3:	mvi	b,0
	mov	c,a	; bc=words in buffer
	inr	m	; advance buffer counter
	lhld	bfr
	dad	b	; calculate byte address in buffer
	xchg		; caculated bfr adr
	lhld	destad	; address of byte in pidgin program
	ldax	d	; get the byte
	mov	m,a	; give it to pidgin
	call	iowait
	ret
br4:	lhld	tempod
	xchg
	lhld	tempoh
	dad	b
	dcr	d
	jnz	br0-2	; try next one
	mvi	a,4	; er=4 *error* improper read buffer
	jmp	br1
br5:	lhld	destad	; end of file on input file
	mvi	m,26
	mvi	a,1
	jmp	br1	; exit for eof
;
; end of pidgin read
;
;------------------------------------------------------------
;
; subroutine ?bwrit / pidgin write routine
;
; INVOKED BY:
;
; WRITE b  INTO m
;
?bwrit:	sta	op	; save char temporarily in op
	if	testsys
	mvi	a,'w'
	sta	which
	endif
	call	preset	; preset registers for search
	mvi	a,2	; look for active write bits
bw0:	cmp	m	; is this entry a write entry
	jz	bw1	; found
	dad	b
	dcr	d	; more?
	jnz	bw0	; yup!
	jmp	br1	; er=2 *error* no active write on this buffer
bw1:	call	gbfa	; go load table's buffer address into de
	call	xdehl	; check it against buffer address in call
	jnz	bw3	; not same buffer, look some more
	call	ldem	; get users fcb
	push	d	; save it for further use
	mov	a,m	; get count of characters in buffer
	cpi	128	; is buffer full?
	jz	bw4	; yes, write it out
bw2:	mov	c,a	; form address of corrent character
	mvi	b,0
	inr	m	; step buffer counter
	lhld	bfr	; get buffer address
	dad	b
	lda	op	; get the character back
	mov	m,a	; put it in buffer
	pop	d	; pop fcb address off stack
	call	iowait
	ret		; return to user code
bw3:	lhld	tempod
	xchg
	lhld	tempoh
	dad	b
	dcr	d	; more?
	jnz	bw0-2	; yerse
	mvi	a,2	; er=2 *error* write buffer not located
	jmp	br1	; in io control tables
bw4:	push	h	; save address of buffer counter
	call	setdma	; set output buffer address
	pop	h
	pop	d	; retrieve fcb address
	push	h
	call	wrblk	; write a block
	jnz	bw5	; jump to error
	pop	h
	mvi	m,1	; reset buffer counter
	lhld	bfr	; get buffer address
	lda	op	; get character
	mov	m,a	; stuff it in buffer
	call	iowait
	ret		; return to user
bw5:	mvi	a,2	; er=2 *error* write operation failed
	pop	h
	jmp	br1	; error exit
;
; end of pidgin write subroutine
;
;-------------------------------------------------------------
;
; close pidgin file
;
; INVOKED BY:
;
; CLOSE b
;
; this routine closes any file attached to the write buffer
;
; and any read buffer files as well.  write buffer is flushed at close
;
;
?bclof:	shld	bfr	; keep buffer address
	call	setup	; set up registers only
clo0:	mvi	a,3	; set for read or write
			; note !!!! random files won't allow this test
	ana	m	; sense bit
	jz	clo1
	call	gbfa	; get buffer address from table
	call	xdehl	; is it same as one supplied?
	lhld	tempod
	xchg
	lhld	tempoh
	jz	clo3	; yes, close that file
clo1:	dad	b
	dcr	d
	jnz	clo0	; loop looking for another file
clo2:	mvi	a,2	; er=2 *error* file doesn't exist
	sta	er
	ret
clo3:	lxi	b,4	; set to get fcb from io control table
	mov	a,m	; get byte 0 of ioctl (operation)
	ani	2	; check for write
	jnz	clo4	; write operation
	mov	m,a	; zeroize it now
	inx	h
	mov	m,a	; clear file number
	dcx	h	; (both byte 0 & 1 are now =0)
	dad	b	; meaning file is logically closed
	call	ldem	; get fcb address in de now
	mvi	m,0	; clear buffer counter
	mvi	c,@close
	call	?bdos
	xra	a
	jmp	clo2+2
; close write buffer
clo4:	mvi	m,0	; zero buffer counter
	dad	b	; calculate fcb address
	call	ldem	; get fcb in de
	push	d	; stack it
	mov	c,m	; get buffer count
	mvi	a,128	; buffer size
	sub 	c	; 128-current
	jnz	clo5
	mvi	a,128	; if buffer is full, write new block
clo5:	lhld	bfr	; of all 1ah
	push	b	; save bfr count
	call	setdma	; set output buffer address
	pop	b	; restore counter
	lhld	bfr	; get buffer address back
	mvi	b,0
	dad	b	; point to last used loc in buffer
	mov	c,a	; count of unused portion of buffer
clo6:	mvi	m,01ah	; write eof into buffer
	inx	h
	dcr	c
	jnz	clo6	; loop
	pop	d
	push	d
	call	wrblk	; write block
	pop	d
	mvi	c,@close
	call	?bdos
	xra	a
	sta	er
	ret
;
; end of pidgin close
;
?rdbuf: ;/ buffer read
;
?wrbuf: ;/buffer write
	ret
;
;---------------------------------------------------------------
;
;
; attach routine - peculiar to cp/m pidgin - attachs user fcb
; to buffer / file
;
;---------------------------------------------------------------
;
?atach:	push	d	; save exec fcb
	push	h
af0:	xra	a
	sta	er
	call	sioctl	; search table looking for zero slot
	jnc	af1	; found, continue
	mvi	a,1	; er=1 *error* table full
	pop	b
	pop	b	; reset stack
	sta	er
	ret		; return
af1:	pop	d	; get adr of file id
	ldax	d	; get file id
	push	h	; save zero slot in table
	call	sioctl	; search for this particular file
	pop	h	; get back zero slot
	jc	af2	; goo, file not in table
	pop	d	; unstack fcb
	mvi	a,2	; er=2 *error* file already in use
	sta	er
	ret
af2:	mvi	m,4	; set operation to prepared
	inx	h	; point to file id
	mov	m,a	; set file # in table
	inx	h
	inx	h
	inx	h
	pop	d	; get fcb
	mov	m,e
	inx	h
	mov	m,d
	inx	h
	mvi	m,0	; set bfr count to zero
	ret
;
;
; ?ENDING / close all files and terminate pidgin
; program correctly
;
;
?endin:	
	call	setup
end1:	mvi	a,1	; set to look for read operation
	ana	m	; read op?
	cnz	rclose	; close read file
	mvi	a,2	; write operation
	ana	m	; is this write?
	cnz	wclose	; close write file
	dad	b	; next entry
	dcr	d
	jnz	end1	; loop till all files closed
	ret
rclose:
	push	h
	push	d
	push	b
	xra	a
	mov	m,a	; set operation to zero
	dad	b	; set hl=>next entry
	dcx	h	; hl=> buffer counter
	mov	m,a	; zero buffer count
	dcx	h	; ho byte of fcb address
	mov	d,m	; load de from (hl) [fcb address]
	dcx	h	;
	mov	e,m	; de=>address of read file's fcb
	mvi	c,@close ; close file function
	call	?bdos	; do it
	pop	b
	pop	d
	pop	h
	ret		; note: remainder of ctl tbl not zeroed out!
;
; wclose / close write file.  This must first flush the write buffer.
;	then, go to cp/m to write directory table entry into track 2.
;
wclose:
	push	h
	push	d
	push	b
	xra	a
	mov	m,a
	inx	h
	mov	m,a
	inx	h
	call	ldem	; load de with buffer address
	xchg		; de=>hl (store de in bfr)
	shld	bfr	; save buffer address
	xchg		; get it back
	call	ldem	; get fcb address
	xchg
	shld	tempod	; save fcb address for use later
	xchg
	mov	c,m	; get buffer count
	mvi	a,128	; buffer size
	sub	c	; how much buffer is left
	jz	$+4	; if none, write a buffer of all 1ah
	lxi	d,803eh	; becomes mvi a,128
	mov	c,a	; remaining buffer locations
	mvi	b,0
	lhld	bfr	; base address of buffer
	dad	b	; address to store 1ah's at
	mvi	a,1ah
wcl1:	mov	m,a	; loop to fill buffer with eof's
	inx	h	;
	dcr	c	;
	jnz	wcl1	;
	call	setdma	; set address of write transfer
	lhld	tempod
	xchg		; get fcb into de
	call	wrblk	; write block to disk
	lhld	tempod
	xchg		; get fcb back
	mvi	c,@close
	call	?bdos	; close write file
	pop	b
	pop	d
	pop	h
	ret		; return
;------------------------------------------------------;
;
; This is the initialization segment for all PIDGIN
; programs.  It is entered by the statement "BEGINMAIN"
; and its functions are:
; 1: construct a series of up to ntabs FCB's by scanning
;    the processor call line.
; 2: store the number of files on the call line in .AC
; 3: move a series of integers from 1 to 6 in each of
;    six words, .IAV(0) thru .IAV(5)
; 4: do any thing else that the user may want done prior
;    to execution such as set the clock etc...
;    NOTE: USER CODE SHOULD BE INSERTED AT INIT2: OR BEYOND
;
;;
;-----------------------------------------------------;
;

?init:	lxi	h,0	; clear hl
	dad	sp	; get stack pointer
	shld	destad	; save stack pointer
	lxi	b,ntabs
	lxi	sp,.iav+((ntabs-1)*2)-1	; iav=integer operating system array
	push	b	; store values into .iav
	dcr	c
	jnz	$-2
	lhld	destad
	sphl
	lxi	h,fcb1
	shld	nxtfcb	; save first fcb location
	xchg
	lxi	h,tbuff
	xra	a	; set ac to zero
	sta	.ac	; indicates no files
	ora	m	; or in bits from buffer count
	jz	init2	; tbuffer empty, just skip all of this
	push	h
	lxi	b,0
	mov	c,m
	dad	b	; form ending address of string
	inx	h	; adjust it
	mvi	m,cr	; put a cr at end of string for 2.x and mp/m
	pop	h
	inx	h	; point to tbuff+1
init1:	call	mtfcb
	jc	init3	; if error ask for reboot
	shld	destad	; use temporary storage
	lxi	b,fcbsiz
	xchg
	lhld	nxtfcb
	dad	b
	shld	nxtfcb
	lxi	h,.ac
	inr	m
	cpi	0dh	; was character a c/r?
	jz	init2	; yes, done statement scan
	mvi	a,ntabs
	cmp	m
	jz	init2
	lhld	nxtfcb
	xchg
	lhld	destad
	jmp	init1
init2:
	if	nsisys
	mvi	c,9
	lxi	d,exmsg	; on console
	call	?bdos
	endif
	ret
init3:	mvi	c,9
	lda	.ac	; get file counter
	inr	a
	ori	'0'
	sta	flno
	lxi	d,fnbad
	call	?bdos
	jmp	?boot
;++++++++++++++++++++++++++++++++++++++++++++++
;
; MAKE CP/M FILE CONTROL BLOCK
;
; MAKEFCB.LIB  -  Version 0.2  -  28 OCT 77
;
; JEFFREY W. SHOOK
; P.O. BOX 185
; ROCKY POINT, NEW YORK 11778
; (516) 744 7133
;
;++++++++++++++++++++++++++++++++++++++++++++++


; Create a CP/M file control block  from
; a command string at the address in HL
; and place it at the address in DE.  Return
; with the carry set if an error occurs.


; DEFINITIONS

fcbsiz	EQU	36	; length of FCB in cp/m 2.2 **alb 10/81**
fnmlen	EQU	11	; File name length


MTFCB:	PUSH	H	; Save cmd string ptr
	PUSH	D	; Save FCB address
	
	LXI	B,FCBSIZ; Clear entire FCB area
	xra	a	; set a=0	**alb 10/81**
	CALL	FILLB	;

	POP	D	; Fill file name with spaces
	PUSH	D	;
	INX	D	;
	LXI	B,FNMLEN;
	MVI	A,' '	;
	CALL	FILLB	;

	POP	D	; Restore pointers
	POP	H	;

	CALL	SKIPS	; Skip leading spaces

	INX	H	; Check for disk code
	MOV	A,M	;
	DCX	H	;
	CPI	':'	;
	JNZ	MTFCB1	; Jump on no code

	MOV	A,M	; Test if disk code good
	INX	H	;
	INX	H	;
	SBI	'@'	;
	RC		; Make error return if bad
	CPI	'Z'+1	;
	CMC		;
	RC		;

	STAX	D	; Store disk code at FCB + 0
MTFCB1:	INX	D	;

	MVI	C,8	; Process file name field
	CALL	GETNAM	;

	MOV	A,M	; Test for file type separator
	INX	H	;
	CPI	'.'	;
	JNZ	MTFCB2	;

	MVI	C,3	; Process file type field
	CALL	GETNAM	;
	MOV	A,M	;
	INX	H	;

MTFCB2:	CALL	TERMT	; Test for corect terminator

	RET


; PROCESS NAME FIELD

GETNAM:	MOV	A,M	; Get char from cmd str
	INX	H	;

	CPI	'?'	; Allow ambig reference char
	JZ	GETNA1	;

	CPI	'*'	; Fill rest with ?
	JZ	GETNA2	;

	CALL	VALCHR	; Test for allowed char in name
	JC	GETNA3	;

GETNA1:	STAX	D	; Store char in TFCB
	INX	D	;

	DCR	C	; Check name size
	JNZ	GETNAM	;
	RET		;


GETNA2:	MVI	A,'?'	; Fill rest of field with ?
	MVI	B,0	;
	JMP	FILLB	;

GETNA3:	INX	D	; Move FCB ptr to end of field
	DCR	C	;
	JNZ	GETNA3	;
	DCX	H	;
	RET		;


; TEST FOR VALID CHAR IN  NAME FIELD
; Return with carry set if invalid.

VALCHR:	CPI	'*'
	CMC
	RZ

	CPI	','
	CMC
	RZ

	CPI	'.'
	CMC
	RZ		; **alb 10/81**

	CPI	' '
	RC

	CPI	'^'+1
	CMC
	RC

	CPI	':'
	CMC
	RNC

	CPI	'@'
	RET


; TEST FOR VALID FILENAME TERMINATOR CHAR
; Return with zarry set if invalid.

TERMT:	CPI	' '
	RZ

	CPI	','
	RZ

	CPI	CR
	RZ

	CPI	';'
	RZ

	ORA	A	; CHECK FOR NULL TERMINATION
	RZ		; YOU GOT IT

	STC
	RET


; SKIP SPACES IN CMD STRING

SKIPS:	MVI	A,' '
SKIPS1:	CMP	M	; **alb 10/81**
	RNZ
	INX	H
	JMP	SKIPS1


; FILL BLOCK WITH VALUE

; Enter with:
; A  = value for fill
; DE = start of block
; BC = length of block

CLRB:	MVI	A,0

FILLB:	INR	B
	DCR	B
	JNZ	FILLB1
	INR	C
	DCR	C
	RZ

FILLB1:	STAX	D

	INX	D
	DCX	B

	JMP	FILLB
	if	nsisys
exmsg:	db	27,'H',27,'J'
	db	'PIDGIN EXECUTION (1.0 (,m))'
	db	0dh,0ah,'$'
	endif
	dseg
fnbad:	db	0dh,0ah
	db	'Cannot interpret character correctly'
	db	' in file number: '
flno:	db	'0',0dh,0ah,'$'
bfr:	dw	0
nxtfcb:	dw	fcb1	; fcb chain
destad:	db	0	; destad=destad^op bytes
op:	db	0
tempoh:	dw	0	; temp storage for control of search loop
tempod:	dw	0
?ioctl:	db	0	; file operation
	db	0	; file id
	dw	0	; buffer address
	dw	0	; fcb address
	db	0	; buffer counter
iosize	equ	$-?ioctl
	rept	ntabs-1
	rept	iosize
	db	0
	endm
	endm
?ifcb:
fcb1:	ds	ntabs*fcbsiz	; fcb running hardware table
	if	testsys
which:	db	0
hunh:	db	'  ',0dh,0ah,'$'
	endif
	end
