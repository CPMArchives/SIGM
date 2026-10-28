;
;********************************************************
;*		Extended Submit for			*
;*			CP/M				*
;********************************************************
;
; Revised 09/13/81 (RGF): added control character translation
;			  fixed bug in line number reporting
;
;		Version 1.1		by Ron Fowler
;		2/18/81 (first written)     Westland, MI
;
; Published in Lifelines, Volume II, Number 8- Jan 82
;
;
;	This program is intended as a replacement for the
; SUBMIT program provided with CP/M.  It provides several
; new facilities:
;	1) Nestable SUBMIT runs
;	2) Interactive entry of SUBMIT job (no need
;	   to use an editor for simple SUBMIT runs)
;	3) Command line entry of small SUBMIT jobs
;	4) Ability to enter blank lines in an edited
;	   SUBMIT file
;	5) User customization of number of parameters
;	   and drive to send $$$.SUB to
;
;
;  Define Booleans
;
false	equ	0
true	equ	not false
;
;*************************************************************
;	--- User Customizable options ---
;
npar	equ	10	; Number of Allowable Parameters
subdrv	equ	0	; Make 0 for dflt - 1,2,3 for A,B,C
quiet	equ	false	; Set to true to eliminate sign-on msg
cpbase	equ	0	; Set to 4200h for Heath CP/M
;
;
;
;***************************************************************
;
;  CP/M Definitions
;
fpchar	equ	2	; Print char function
printf	equ	9	; Print string function
rdbuf	equ	10	; Read console buffer
openf	equ	15	; Open file function
closef	equ	16	; Close file function
deletf	equ	19	; Delete file function
readf	equ	20	; Read record function
writef	equ	21	; Write record function
makef	equ	22	; Make (create) file function
;
bdos	equ	cpbase+5
;
fcb	equ	5ch	; Default file control block
fcbrc	equ	15	; FCB Offset to record  count
fcbnr	equ	32	; FCB Offset to next record
fn	equ	1	; FCB Offset to file name
ft	equ	9	; FCB Offset to file type
tbuf	equ	cpbase+80h	; Default buffer
tpa	equ	cpbase+100h	; Transient program area
;
putcnt	equ	tbuf	; Counter for output chars
;
;  Define Some Text Characters
;
cr	equ	13	; Carriage return
lf	equ	10	; Line feed
tab	equ	9	; Tab Char
;
;  Start of Program Code
;
	org	tpa
;
;	Get the ball rolling
;
submit:	lxi	h,0	; Save stack in case
	dad	sp	;  only help requested
	shld	spsave	; (Not otherwise used)
	lxi	sp,stack
	call	start
;
;  Sign on Message
;
	if	not quiet
	db	'SuperSUB V1.1'
	endif
;
	db	cr,lf,'$'	; Newline even if quiet
;
start:	pop	d	; Retrieve string pointer
	mvi	c,printf
	lda	fcb+1	; Anything on CMd line?
	cpi	' '
	jz	help	; No, Go print help
	call	bdos	; Print the sign-on
	call	initvar	; Initialize the variable area
	call	getpar	; Get command line parameters
	call	setup	; Set up read of submit file
	call	rdfile	; Read the submit file
	call	wrset	; Set up write of "$$$.SUB"
	call	wrsub	; Write "$$$.SUB"
	jmp	cpbase	; Go start the SUBMIT
;
;
;  Setup sets up the file control block
;  for reading the the .SUB text file
;
setup:	lxi	h,fcb+ft  ; Look at 1st char of
	mov	a,m	;    file type.  If it is
	cpi	' '	;    blank, then go move
	jz	putsub	;    "SUB" into FT field
	lxi	d,subtyp; It's not blank to make
	mvi	b,3	;   sure it's already
	call	compar	;    "SUB"
	jnz	notfnd	; If not, it's an error
	ret
;
;  Move "SUB" into the file type
;
putsub:	xchg
	lxi	h,subtyp	; By convention, move
	mvi	b,3		;  @HL to @DE
	call	move
	ret
;
;  Move # bytes in B Register from @HL to @DE
;
move:	mov	a,m	; Pick up
	stax	d	; Put down
	inx	h	; I'm sure
	inx	d	;  you've seen this
	dcr	b	;  before..
	jnz	move	;
	ret
;
;  Getpar moves the substitution parameters specified
; in the command line into memory, and stores their
; addresses in the parameter table.  This allows
; substitution of $1, $2, etc., in the SUBMIT commands
; with their actual values specified in the command
; line.
;
getpar:	lxi	h,tbuf+1	; Where we find the command tail
	call	scanto	; Skip submit file name
	sta	option	; First char of cmd line is option
	rc		; Line ended?
	cpi	'/'	; No, check option
	jnz	glpo	; Not keyboard input, read file
	inx	h	; point past '/'
slscan:	shld	clptr	; Save cmd line ptr
	mov	a,m	; Kbd is source, get EOL flag
	sta	clflag	; Save as EOL flag
	cpi	' '	; Allow spaces after '/'
	rnz		; Not non-blank - done
	inx	h	; Else continue scan
	jmp	slscan
glpo:	mov	a,m	; Input is from a .SUB file. This
	inx	h	;   code skips over the name of
	ora	a	;   the SUB file to get to the
	rz		;   command line parameters
	cpi	' '
	jz	glp
	cpi	tab
	jnz	glpo
glp:	call	scanto	; Pass up the blanks
	rc		; CY returned if end of cmd line
	call	putpar	; Not put the parameter into Mem
	rc		; CY returned if end of cmd line
	jmp	glp	; Get them all.
;
;  SCANTO scans past blanks to the first non-blank.  If
; end of command line is found, returns carry set.
;
scanto:	mov	a,m
	inx	h
	ora	a	; Set flags on zero
	stc		; In case zero found
	rz
	cpi	' '
	jz	scanto	; Scan past blanks
	cpi	tab	; Do tabs to, just for
	jz	scanto	;  good measure.
	dcx	h	; Found char, point back to it
	ora	a	; insure carry clear
	ret
;
;  PUTPAR puts the parameter pointed to by HL into
; memory pointed to by "TXTPTR".  Also stores the
; address of the parameter into the parameter table
; for easy access later, when we write $$$.SUB
;
putpar:	push	h	; Save pointer to parm
	lhld	txtptr	; Next free memory
	xchg		;   into DE
	lhld	tblptr	; Next pree area of table
	mov	a,m	; Non-zero in table
	ora	a	;  indicates table
	jnz	parovf	;  overflow
	mov	m,e	; Store the parm adrs
	inx	h
	mov	m,d
	inx	h
	shld	tblptr	; Save table pntr for next time
	pop	h	; Get back parm pointer
	push	d	; Save free mem pointer because
			;   we will have to have it back
			;   later to store the length
	inx	d	; Point past length storage
	mvi	b,0	; Initialize length of parm
pplp:	mov	a,m	; Get next byte of parm
	inx	h
	ora	a	; Test for end of cmd line
	jz	pp2	; Jump if End
	cpi	' '	; Test for end of Command
	jz	pp2
	cpi	tab	; Tab also ends command
	jz	pp2
	stax	d	; Put parameter byte-by-byte
	inx	d	;  into free memory
	inr	b	; Bump length
	jmp	pplp
pp2:	xchg
	shld	txtptr	; New free memory pointer
	pop	h	; Remember our length pointer?
	mov	m,b	; Store the length
	xchg		; Have to retn HL > cmd line
	ora	a	; Now return end of line flag
	stc
	rz		; Return CY is zero (EOL Mark)
	cmc
	ret
;
;  RDFILE reads the .SUB file specified
; in the SUBMIT command into memory
;
rdfile:	lxi	h,0	; Init line number
	shld	linnum
	lda	option	; Using a file?
	cpi	'/'	; Option tells
	jz	line	; Jump if not
	lxi	d,fcb	; We are, open it.
	mvi	c,openf
	call	bdos
	inr	a	; if 0FFh returned,
	jz	notfnd	;   then file not found.
line:	lhld	linnum	; Bump line number
	inx	h
	shld	linnum
	lhld	prev	; Get prev line pointer
	xchg
	lhld	txtptr	; Get current free mem pointer
	shld	prev	; Make it the prev line (for next pass)
	mov	m,e	; Store at begin of current line.
	inx	h	;  a pointer to the previous
	mov	m,d
	inx	h
	push	h	; Later we will put length here
	inx	h	; Skip past length
	mvi	c,0	; Initialize length to zero
llp:	call	gnb	; Get next byte from input source
	jc	eof	; CY set if end of file found
	call	ucase	; Convert to upper case
	cpi	1ah	;  See if CP/M End of File
	jz	eof
	cpi	lf	; Ignore linefeeds
	jz	llp
	cpi	cr	; If it's a carriage return,
	jz	eol	;   then do end of line
	mov	m,a	; Store all others into memory
	inx	h
	call	size	; Make sure no memory overflow
	inr	c	; Bump char count
	jm	lenerr	; Max of 128 chars per line
	jmp	llp	; Go to next char
;
;  Do End of Line Sequence 
;
eol:	shld	txtptr	; Save free memory pointer
	pop	h	; Current line's length pointer
	mov	m,c	; Store length away
	jmp	line	; Go do next line
;
;  End of Text File
;
eof:	shld	txtptr	; Save free memory pointer
	pop	h	; Current line's length pointer
	mov	m,c	; Store length away
	ret		; All done reading SUB file
;
;  Get next byte from Input File
;
gnb:	push	h	; Don't alter anybody
	push	d
	push	b
	lda	option	; Input from .SUB file?
	cpi	'/'	; Told by orig cmd line option
	jnz	nslash	; Jump if we are
	call	gnbkbd	; No, get a byte from kbd input
	jmp	gnbxit	; Then leave
nslash:	lda	ibp	; Get buffer pointer
	ora	a	; Past end?
	cm	fill	; Wrapped around
	jnc	gnb1	; No end of file
	mvi	1,1ah	; Fake EOF
gnb1:	mov	e,a	; put in DE
	mvi	d,0
	inr	a	; Point to next
	sta	ibp	; Put away
	lxi	h,tbuf	; Now offset into buff
	dad	d
	mov	a,m	; Get char there
gnbxit:	pop	b	; Restore everybody
	pop	d
	pop	h
	ora	a	; Turn on carry
	ret
;
;  Fill input buffer
;
fill:	mvi	c,readf
	lxi	d,fcb
	call	bdos
	ora	a
	mvi	a,0
	stc
	rnz		; Rtn CY=EOF
	cmc		; No EOF, No CY
	ret
;
;  Come here to get a .SUB character when
;  we're not using a .SUB file ('/' option)
;
gnbkbd:	lda	clflag	; Use CP/M Cmd line?
	ora	a
	jnz	gnbcl	; Then go do it
	lda	clcnt	; Not, check local
	ora	a	;   cmd line char count
	cm	clfill	; Refill when it wraps back
	jc	gkend	; Got carry (from CLFILL), return EOF
	dcr	a	; Count down
	sta	clcnt
	jp	gnbcl	; If plus, buffer not empty
	mvi	a,cr	; Out of chars, return a CR
	ret
;
gkend:	mvi	a,1ah	; Return EOF
	ret
;
;  Get next byte of input from cmd line @clptr
;
gnbcl:	lhld	clptr	; Load the pointer
	mov	a,m	; Get the char
	inx	h	; Bump pointer for next time
	shld	clptr
	cpi	';'	; Logical end-of-line?
	jnz	nsemi	; Jump if not
	mvi	a,cr	; Yes, translate it
	ret
nsemi:	ora	a	; Physical End-of-Line
	rnz		;  This only needed when input
			;  Source is orig cpm cmd line
	mvi	a,1ah	; Translate that to End of File
	ret
;
;  Subroutine to re-fill the local command line
;
clfill:	lxi	d,prompt	; Print a prompt
	mvi	c,printf	; Use CP/M function 9
	call	bdos
	lxi	d,clbuf	; Now fill the buffer
	mvi	c,rdbuf
	call	bdos
	lda	clcnt	; Return with count in A
	lxi	h,cltext	; Reset the cmd line pointer
	shld	clptr
	ora	a	; Set CY on len NZ
	stc
	rz
	cmc
	ret
;
;  Make sure no memory overflow
;
size:	lda	bdos+2	; Highest page pointer
	dcr	a	; Make it be under BDOS
	cmp	h	; Check it against current page
	rnc		; NC= all okay
	jmp	memerr	; Otherwise Abort
;
;  Set up the $$$.SUB file
;   For Writing
;
wrset:	lxi	d,subfcb
	mvi	c,openf
	call	bdos	; Open the file
	inr	a	; Check CPM return
	jz	none1	; None exists already
;
;  $$$.SUB exists, so set
;  FCB to append to it
;
	lda	subfcb+fcbrc	; Get record count
	sta	subfcb+fcbnr	; Make that next rec
	ret
;
;  Come here when no $$$.SUB exists
;
none1:	lxi	d,subfcb
	mvi	c,makef
	call	bdos
	inr	a
	jz	nomake	; 0FFh=Can't create file
	ret
;
;  Write the "$$$.SUB" file
;
wrsub:	lhld	prev	; This code scans backward
	mov	a,h	;  Thru the file stored in
	ora	l	;  memory to the first non-
	jz	notext	;  nul line.  If none is
	mov	e,m	;  found, Aborts
	inx	h
	mov	d,m	; Here, we pick up pntr to prev line
	inx	h	; Now we point to length
	xchg		; We need to store away
	shld	prev	;  pointer to prev line
	xchg
	mov	a,m	; Now pick up the length
	ora	a	; Set Z flag on length
	jnz	wrntry	; Got line w/length: go do it
	lhld	linnum	; Nothing here, fix line number
	dcx	h	; (working backward now)
	shld	linnum
	jmp	wrsub
wrlop:	lhld	prev	; Get prev line pointer
	mov	a,h
	ora	l	; If there is no prev line
	jz	close	;  then we are done
	mov	e,m	; Else set up prev for next
	inx	h	;   pass thru here
	mov	d,m
	inx	h
	xchg		; Now store it away
	shld	prev
	xchg
wrntry:	call	putlin	; Write the line to the file
	lhld	linnum	; Bump the line number
	dcx	h	; Down (working back now)
	shld	linnum
	jmp	wrlop
;
;  $$$.SUB is written, Close the file
;
close:	lxi	d,subfcb
	mvi	c,closef
	jmp	bdos
;
;  This subroutine writes a line
; to the $$$.SUB file buffer,
; and flushes the buffer after
; the line is written.
;
putlin:	mov	a,m	; Pick up length byte
	inx	h	; Point past it
	sta	getcnt	; Make a count for "GET"
	shld	getptr	; Make a pointer for "get"
	lxi	h,tbuf+1	; Text goes after length
	shld	putptr	; Make pointer for "Put"
	xra	a	; Initialize PUT count
	sta	putcnt
	mov	b,l	; Count for clear loop
clr:	mov	m,a	; Zero out buffer loc
	inx	h
	inr	b	; Count
	jnz	clr
;
;  This loop collects characters
; from the line stored in memory
; and writes them to the file.
; If the "$" parameter specifier
; is encountered, parameter sub-
; stitution is done.
;
putlp:	call	getchr	; Pick up a character
	jc	flush	; CY = no more char in line
	cpi	'^'	; Control char translate prefix?
	jnz	notcx
	call	getchr	; Yes, get the next
	jc	ccerr	; Error: Early end of input
	sui	'@'	; Make it a control-char
	jc	ccerr	; Error: Too small
	cpi	' '
	jnc	ccerr	; Error: Too large
notcx:	cpi	'$'	; Parameter specifier?
	jnz	stobyt	; If not, just write char
	lda	option	; Check option: '$' doesn't
	cpi	'/'	;  count in '/' mode
	mvi	a,'$'	; (Restore the '$')
	jz	stobyt
	call	lkahed	; Peek at next char
	jc	parerr	; Line ending means param err
	cpi	'$'	; Another "$"?
	jnz	subs	; If not then go do substitution
	call	getchr	; Get the 2nd "$" (We only looked
			;  ahead before)
stobyt:	call	putchr	; Write char to file
	jmp	putlp
;
;  Parameter substitution...Looks up the
; parameter # after the "$" and plugs it
; in if it exists.
;
subs:	call	numtst	; It better be a number
	jc	parerr	;  otherwise param error
	mvi	b,0	; Initialize parm #
	jmp	lpntry	; We join loop in progress...
sublp:	call	lkahed	; Look at next char
	jc	dosubs	; If line empty, then plug in parm
	call	numtst	; Check for numric
	jc	dosubs	; Done in not
lpntry:	call	getchr	; Now remove the char from input stream
	sui	'0'	; Remove ASCII bias
	mov	c,a	; Save it
	mov	a,b	; Our accumulated count
	add	a	; Multiply by ten
	add	a
	add	b
	add	a
	add	c	; then add in new digit
	mov	b,a	; restore count
	jmp	sublp
;
;  Perform the substitution
;
dosubs:	mov	a,b	; Get parm #
	dcr	a	; Make zero relative
	jm	parerr	; oops
	call	lookup	; Look it up in parm table
	jc	parerr	; It's not there
	mov	b,a	; Length in B
sublp1:	inr	b	; Test B for zero
	dcr	b
	jz	putlp	; Done
	mov	a,m	; Get char of real parameter
	inx	h	; Point past for next time
	push	h	; Save real parm pointer
	call	putchr	; Put it in the file
	pop	h	; Get back real parm pointer
	dcr	b	; Countdown
	jmp	sublp1
;
;  Come here when a line is finished,
; and we need to write the buffer to disk.
;
flush:	lxi	d,subfcb
	mvi	c,writef
	call	bdos
	ora	a
	jnz	wrerr	; CPM returned a write error
	ret
;
;  GETCHR gets one char from
; line stored in memory
;
getchr:	lxi	h,getcnt
	mov	a,m	; Pick up count
	dcr	a	; Remove this char
	stc		; Preset error
	rm		; Return CY if out of chars
	mov	m,a	; Update count
	lhld	getptr	; Current char pointer
	mov	a,m	; Pick up char
	inx	h	; Bump pointer
	shld	getptr	; Put it back
	cmc		; Turn carry off
	ret
;
;  PUTCHR puts one char to
; the output buffer
;
putchr:	lxi	h,putcnt
	inr	m	; Increment count
	jm	lenerr	; Line went to > 128 chars
	lhld	putptr	; Get buffer pointer
	mov	m,a	; Put char there
	inx	h	; Bump pointer
	shld	putptr	; Put it back
	ret		; All done
;
;  Look ahead one char in
; the input stream.  Set
; carry if none left.
;
lkahed:	lda	getcnt
	ora	a	; See if count is down to zero
	stc		; Preset indicator
	rz
	mov	a,m	; Pick up char
	cmc		; Turn off carry flag
	ret
;
;  Look up parameter with number in
; a reg.  Return A=length of parm,
; and HL => parameter
;
lookup:	cpi	npar
	jnc	parovf	; Parm # too high
	mov	l,a
	mvi	h,0	; Now have 16 bit number
	dad	h	; Double for word offset
	lxi	d,table
	dad	d	; Do the offset
	mov	e,m	; Get the address of parm
	inx	h
	mov	d,m
	mov	a,d	; Anything there?
	ora	e
	jnz	lkupok
	xra	a	; No, zero length
	ret
lkupok:	xchg		; Now in DE
	mov	a,m	; Pick up length
	inx	h	; Point past length
	ret
;
;  Utility compare subroutine
;
compar:	ldax	d
	cmp	m
	rnz
	inx	h
	inx	d
	dcr	b
	jnz	compar
	ret
;
;  Numeric Test Utility Subroutine
;
numtst:	cpi	'0'
	rc
	cpi	'9'+1
	cmc
	ret
;
;  Decimal output routine
;
decout:	push	b
	push	d
	push	h
	lxi	b,-10
	lxi	d,-1
;
decou2:	dad	b
	inx	d
	jc	decou2
	lxi	b,10
	dad	b
	xchg
	mov	a,h
	ora	l
	cnz	decout
	mov	a,e
	adi	'0'
	call	type
	pop	h
	pop	d
	pop	b
	ret
;
;  Print CR, LF on console
;
crlf:	mvi	a,cr
	call	type
	mvi	a,lf
;
;  Print char in A on console
;
type:	push	h
	push	d
	push	b
	mov	e,a	; Put in E for CP/M
	mvi	c,fpchar
	call	bdos	; Print it
	pop	b
	pop	d
	pop	h
	ret
;
;  Convert char in A to Upper Case
;
ucase:	cpi	'a'	; Validate case
	rc
	cpi	'z'+1
	rnc
	ani	5fh	; Got LC, conv to UC
	ret
;
;  Error Handlers
;
wrerr:	call	errxit
	db	'Disk full$'
nomake:	call	errxit
	db	'Directory full$'
memerr:	call	errxit
	db	'Memory full$'
notfnd:	call	errxit
	db	'Submit file not found$'
parerr:	call	errxit
	db	'Parameter$' 
parovf:	call	errxit
	db	'Too many parameters:$'
lenerr:	call	errxit
	db	'Line too long:$'
notext:	call	errxit
	db	'Submit file empty$'
ccerr:	call	errxit
	db	'Control character$'
errxit:	pop	d
	mvi	c,printf
	call	bdos
	lxi	d,errmsg	; Print the 2nd half msg
	mvi	c,printf
	call	bdos
	lhld	linnum		; Tell line number
	call	decout
	call	crlf
	lxi	d,subfcb	; Delete the $$$.SUB file
	mvi	c,deletf
	call	bdos
	jmp	cpbase
;
errmsg:	db	' error on line number: $'
;
; Prompt for command line input
prompt:	db	cr,lf,'*$'
;
;  Initialize all variables
;
initvar:
	lxi	h,var
	lxi	b,endvar-var
initlp:	mvi	m,0		; Zero entire var area
	inx	h
	dcx	b
	mov	a,b
	ora	c
	jnz	initlp
	lxi	h,table	; Init parm table pointer
	shld	tblptr
	lxi	h,0ffffh; Mark end of table
	shld	endtbl
	lxi	h,fremem; Free memory starts txt area
	shld	txtptr
	mvi	a,80h	; Force read
	sta	ibp
	sta	clcnt	; Force console read
	ret
;
;  Print help with program options
;
help:	lxi	d,hlpmsg  ; Print the help stuff
	mvi	c,printf
	call	bdos
	lhld	spsave	; Then return w/no warm boot
	sphl
	ret
;
hlpmsg:	db	cr,lf,'How to use SUPERSUB:',cr,lf
	db	cr,lf,'SUPERSUB<CR>		:print this HELP message'
	db	cr,lf,'SUPERSUB /<CR>		:go into interactive mode'
	db	cr,lf,'SUPERSUB /<cmd lines>	:use SUMMARY mode'
	db	cr,lf,'SUPERSUB <FILE> <PARMS>	:as in standard SUBMIT.COM'
	db	cr,lf
	db	cr,lf,'IN "/" (interactive) mode, SUPERSUB will prompt you'
	db	cr,lf,'a line at a time for the SUBMIT job input...logical'
	db	cr,lf,'lines may be combined on the same input line by sep-'
	db	cr,lf,'erating them with semicolons.  Example:'
	db	cr,lf,'   A>SUPERSUB /STAT;DIR'
	db	cr,lf,'specifies two commands on the same input line.',cr,lf
	db	cr,lf,'Submitted jobs may be nested...SUPERSUB does not erase'
	db	cr,lf,'any existing submit job (appends to them instead).'
	db	cr,lf
	db	cr,lf,'To insert a control character into the output, pre-'
	db	cr,lf,'fix it with a "^" (works in any mode).'
	db	cr,lf,'$'
;
;  Variable Storage
;
var	equ	$
;
txtptr:	dw	0	; Free memory pointer
tblptr:	dw	0	; Pointer to Parm Table
linnum:	dw	0	; Current line number
prev:	dw	0	; Pointer to previous line
getcnt:	db	0	; Counter for 'Get'
getptr:	dw	0	; Pointer for 'Get'
putptr:	dw	0	; Pointer for 'Put'
ibp:	db	0	; Input Buffer Pointer
clptr:	dw	0	; Command Line Pointer
clflag:	db	0	; Use CP/M cmd line flag
option:	db	0	; '/' option flag store
table:	ds	npar*3	; Parameter table
endtbl:	dw	0	; End of Parameter table
;
endvar	equ	$
;
;  Command Line Buffer... Not Initialized
;
clbuf:	db	128	; Buffer length
clcnt:	db	0	; Character Counter
cltext:	ds	128	; The buffer itself
;
spsave:	dw	0	; Stack Pointer Save
;
;
;  FCB for $$$.SUB
;
subfcb:	db	subdrv	; Driver Specifier
	db	'$$$     '
subtyp:	db	'SUB'
	dw	0,0,0,0	; Initialize rest of FCB
	dw	0,0,0,0
	dw	0,0
;
;  Stack Area
;
	ds	200
stack	equ	$
fremem	equ	$
;
	end	submit
