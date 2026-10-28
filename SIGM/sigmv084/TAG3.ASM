;	TAG Version 1.3 - Original by Bruce Ratoff
;	Latest Revision: 07/Jun/82  Bill Bolton
;
	TITLE	'TAG - set or reset and display the attribute bits on a file'
;
;	Version list (most recent version first)
;
;07/Jun/82 Added conditional assembly to do any combination
;	  of "f1", "f2", "SYS" and "R/O" for setting multiple
;	  attributes at once. Bill Bolton
;
;17/Feb/81 Added conditional assy to tag either "f1" or
;	  "f2" bit for MP/M v1.1 compatibility.
;	  XMODEM v4.1 now tests both "f1" and "f2" for
;	  tagged files. TN
;
;19/May/80 Modified display 4 across. BRR
;
;18/May/80 Original version by Bruce Ratoff
;
;
; The purpose of this program is to set or reset the f1' bit on a file.
; This is used by the XMODEM program to indicate that a file may not
; be transmitted.  The anticipated purpose is to allow remote use of
; licensed programs without the danger of their being copied by the
; remote users.  This should protect the licensee from liabilities
; associated with dissemination of licensed software.
;
; To Set the attribute bits on a file, type:
;    A>TAG d:filename.typ S
; To Reset the bits (allows copying via XMODEM), type:
;    A>TAG d:filename.typ R
;
; The filename.typ may contain the wildcards "*" and "?".
;
; Please forward all comments, suggestions and improvements to:
;	Bruce R. Ratoff
;	80 Gill Lane, Apt 1B
;	Iselin, New Jersey 08830
;
;
false	equ	0		;define false.
true	equ	not false	;define true
;
f1tag	equ	false		;True  = f1 tag
f2tag	equ	true		;True  = f2 tag
systag	equ	true		;True  = SYS tag
rotag	equ	true		;True  = R/O tag
;
;
bdos	equ	5		;cp/m entry point
exit	equ	0		;cp/m exit point
dfcb	equ	5ch		;cp/m default fcb
dbuff	equ	80h		;default disk buffer
;
pchar	equ	2		;print character function
pmessg	equ	9		;print message function
seldsk	equ	14		;select drive function
srchfst	equ	17		;search for first file match
srchnxt	equ	18		;search for next file match
attrib	equ	30		;set file attributes function
;
;
	org	100h
begin:
	lhld	bdos+1		;set up a stack
	sphl			;at top of tpa
;
; Signon message - reports version and attribute used
;		   for tagging "f1" or "f2".
;
	lxi	d,signon	;get signon address.
	mvi	c,pmessg	;print string fuction.
	call	bdos		;print it.
;
signon:	db	13,10
	db	'TAG - V1.3  June 7, 1982'
	db	13,10
	db	'Tags '
;
	if	f1tag
	' "f1",'
	endif	;f1tag
;
	if	f2tag
	db	' "f2",'
	endif	;f2tag
;
	if	systag
	db	' "SYS",'
	endif	;systag
;
	if	rotag
	db	' "R/O"'
	endif	;rotag
;
	db	13,10,13,10,'$'
;
	lda	dfcb		;check for specific drive
	dcr	a
	mov	e,a		;set up for select disk call
	mvi	c,seldsk
	inr	a		;if no specified drive, skip call
	cnz	bdos
	sub	a		;now zap out drive spec
	sta	dfcb
	mvi	a,'?'		;force extent number wild
	sta	dfcb+12
	lda	dfcb+17		;get "S" or "R" option
	sta	sropt
	cpi	'S'
	jz	okopt
	cpi	'R'
	jz	okopt
	cpi	' '
	jz	okopt
badopt:
	lxi	d,ilgopt
	mvi	c,pmessg	;bitch about illegal option
	call	bdos
	jmp	exit
ilgopt:
	db	'Invalid option letter$'
okopt:
	sub	a		;zero out file count
	sta	filcnt
	lxi	d,dfcb		;find the first file and get its block map
	mvi	c,srchfst
	call	bdos
	inr	a		;search successful?
	jnz	gotfile		;yes, go process rest
	lxi	d,nofile
	mvi	c,pmessg	;say "no file"
	call	bdos
	jmp	exit
nofile:
	db	'File not found$'
gotfile:
	dcr	a		;compensate for inr above
	rrc			;file offset to bits 5 and 6
	rrc
	rrc
	ani	60h
	lxi	h,dbuff		;point to base of buffer
	mov	c,a
	mvi	b,0
	dad	b		;index by file offset
	push	h		;save for the moment
	lxi	b,filetable
	call	filepoint	;get table pointer to hl
	xchg			;de now points to place in table
	lda	filcnt
	inr	a
	sta	filcnt		;bump file count
	pop	h		;hl points to directory entry
	mvi	b,32
	call	blkmov		;copy entry into table
	mvi	c,srchnxt	;search for another entry
	lxi	d,dfcb
	call	bdos
	inr	a		;returns 0ffh at end of search
	jnz	gotfile		;got another one...go save it
;
; end of directory encountered, now process them
;
tagfile:
	lxi	b,filetable-32	;allow for filcnt one greater than desired
	call	filepoint
	push	h
	lxi	d,dfcb		;copy next name to default fcb
	mvi	b,32
	call	blkmov
	sub	a
	sta	dfcb		;clear drive number
	lxi	d,-20		;point back to extent field
	dad	d
	mvi	m,'$'		;tag end of print here
	pop	d		;get back pointer to start of entry
	inx	d		;bump fwd to name
	mvi	c,pmessg
	call	bdos		;say what we're working on
	lda	dfcb+12		;get extent #
	push	psw		;save it
	adi	'0'		;convert to ascii
	mov	e,a
	mvi	c,pchar
	pop	psw
	ora	a		;print extent if nonzero
	jnz	pext
	mvi	e,' '
pext:
	call	bdos
	lda	sropt		;get S or R
	cpi	' '		;display only?
	jz	nextfile	;Yes
	rrc			;bit 7=0 for R, 1 for S
	ani	80h
	mov	b,a		;save mask
;
	if	f1tag
	lxi	d,dfcb+1	;Point to f1.
	ldax	d		;get it
	ani	7fh		;strip attribute bit
	ora	b		;set bit if option was S
	stax	d		;put it back
	endif	;f1tag
;
	if	f2tag
	lxi	d,dfcb+2	;Point to f2.
	ldax	d		;get it
	ani	7fh		;strip attribute
	ora	b		;set bit if option was S
	stax	d		;put it back
	endif	;f2tag
;
	if	systag
	lxi	d,dfcb+10	;Point to SYS
	ldax	d		;get it
	ani	7fh		;strip attribute
	ora	b		;set bit if option was S
	stax	d		;put it back
	endif	;systag
;
	if	rotag
	lxi	d,dfcb+9	;Point to R/O
	ldax	d		;get it
	ani	7fh		;strip attribute
	ora	b		;set bit if option was S
	stax	d		;put it back
	endif	;rotag
;
	ldax	d		;get it
	ani	7fh		;strip fx'
	ora	b		;set bit if option was S
	stax	d		;put it back
	dcx	d		;point to start of fcb
;
	lxi	d,dfcb
	sub	a		;zap out drive field
	stax	d
	mvi	c,attrib	;do set attributes call
	call	bdos

	if	f1tag
	lda	dfcb+1		;get f1
	endif	;f1tag

	if	f2tag
	lda	dfcb+2		;get f2
	endif	;f2tag

	if	systag
	lda	dfcb+10		;get sys
	endif	;systag

	if	rotag
	lda	dfcb+9		;get ro
	endif	;rotag

	rlc			;isolate attribute
	ani	1
	adi	'R'		;make an R or S
	sta	donmsg2+1
	lxi	d,donmsg2
	mvi	c,pmessg	;print completion message for this file
	call	bdos
	lda	filcnt		;get file counter
	ani	3		;multiple of 4?
	lxi	d,crlf
	mvi	c,9		;if so, time for new line
	cz	bdos
	lxi	h,filcnt	;point to file counter
	dcr	m		;count it down
	jz	exit		;exit if done
	jmp	tagfile
;
donmsg2:
	db	'  ',9,'$'
;
nextfile:
	if	f1tag
	lda	dfcb+1		;get f1
	rlc			;isolate attribute
	ani	1
	adi	'R'		;make an R or S
	sta	f1msg
	endif	;f1tag
;
	if	f2tag
	lda	dfcb+2		;get f2
	rlc			;isolate attribute
	ani	1
	adi	'R'		;make an R or S
	sta	f2msg
	endif	;f2tag
;
	if	systag
	lda	dfcb+10		;get sys
	rlc			;isolate attribute
	ani	1
	adi	'R'		;make an R or S
	sta	sysmsg
	endif	;systag
;
	if	rotag
	lda	dfcb+9		;get ro
	rlc			;isolate attribute
	ani	1
	adi	'R'		;make an R or S
	sta	romsg
	endif	;rotag
;
	lxi	d,donmsg1
	mvi	c,pmessg	;print completion message for this file
	call	bdos
	lxi	d,crlf
	mvi	c,9		;time for new line
	call	bdos
	lxi	h,filcnt	;point to file counter
	dcr	m		;count it down
	jz	exit		;exit if done
	jmp	tagfile		;and go work on next one
;
donmsg1:
	if	f1tag
	db	' f1='
f1msg:
	db	' ,'
	endif	;f1tag
;	
	if	f2tag
	db	' f2='
f2msg:
	db	' ,'
	endif	;f2tag
;
	if	systag
	db	' SYS='
sysmsg:
	db	' ,'
	endif	;systag
;
	if	rotag
	db	' R/O='
romsg:
	db	' ,'
	endif	;rotag
;
	db	'$'
;
crlf:
	db	13,10,'$'
;
;
; subroutine to do block moves
blkmov:
	mov	a,m		;copy byte from m(hl) to m(de)
	stax	d
	inx	h		;bump pointers
	inx	d
	dcr	b		;loop for count in b
	jnz	blkmov
	ret
;
;
; subroutine to index bc by file counter
filepoint:
	lhld	filcnt		;get file counter
	mvi	h,0		;force hi ord to 0
	dad	h		;multiply by 32
	dad	h
	dad	h
	dad	h
	dad	h
	dad	b		;use as index to file table
	ret
;
;
;
;
filcnt:	ds	1		;count of files in filetable
sropt:	ds	1		;storage for S or R option letter
;
filetable	equ	$	;start table here, take all avail memory
;
	end
