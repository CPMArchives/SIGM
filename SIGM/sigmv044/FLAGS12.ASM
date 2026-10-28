version	equ	12
;************************************************
;						*
;	<<<  Flags Editor  >>>			*
;						*
;		by Dick Lieber			*
;		   comment at 312-326-4014	*
;		   or via Chicago CBBS		*
;						*
;		11/7/81				*
;						*
;11/14/81 Screen functions generalized, f1, f2	*
;	  attributes corrected. (C. Strom)	*
;************************************************
;							
no	equ	0
yes	equ	not no
;
	org	100h
;********************************************************
;	<<< This must be configured for	 >>>		*
;	<<< your own terminal parameters >>>		*
;							*
lineeded equ	yes	;yes if term needs lead-in	*
lichar	equ	126	;lead in char for your term	*
clrchar	equ	28 	;clear screen character		*
;			;modify for your terminal	*
;
homeimp	 equ	yes	;yes if you have a home cursor	*
;			;character.  lineeded applies.	*
;			;clrchar is used if no		*
homechar equ	18	;character to home cursor	*
;							*
;********************************************************

bdos	equ	05H
deffcb	equ	5CH		;used for inital search
dmarea	equ	80H		;used only
filenamlen equ	0CH
ptextlength equ	10H		;length of each flag descriptor
combuflen equ	16

cr	equ	0dh
bs	equ	8
ctlu	equ	15h		;key to press to update flags
esc	equ	1bh
;
;	bdos commands
;
conin	equ	1
conout	equ	2	
prstr	equ	9
readbuff equ	10
searchf	equ	17
setattr	equ	30
;
;	saveold and setup private stack
;
	lxi	h,0
	dad	sp
	shld	oldstack
	lxi	sp,stacktop
;
	call	inlnprt
	db	'Set  & Display file flags'
	db	0dh,0ah
	db	'Version '
	db	version/10 + '0','.',version mod 10 + '0'
	db	0
	call	crlf
;
;	check if file was specified
;
	lxi	h,deffcb+1
	mvi	a,' '
	cmp	m
	jz	leaveflags
;
;	process file in defalut fcb at 5ch
;
again:
	lxi	d,deffcb	;use default fcb
	mvi	c,searchf	;find file
	call	bdos
	cpi	0ffh		;ff if not found
	jz	nofile
	lxi	h,dmarea	;
	rlc			;calculate address of found fcb
	rlc
	rlc
	rlc
	rlc
	mov	e,a
	mvi	d,0
	dad	d
	shld	filefcb		;save absolute fcb address
	if	homeimp	;if using home cursor screen must be erased
	call	erase	;initially
	endif
;
;	copy found fcb to a workspace
;
movoldtowk:
	lhld	filefcb
	lxi	d,workfcb
	lxi	b,filenamlen
	call	move
;
;	move drive code to workfcb
;
	lda	deffcb		;get drive code
	sta	workfcb		;put drive code into workfcb
;
;	main loop - this changes/displays flags in workfcb
;
doover:	call	doheader	;print top of page
	call	displayflags	;show flags status
	call	crlf
	call	crlf
	call	inlnprt
	db	'         Enter letter of flag to change or option > '
;
;	need to erase old char if not erasing screen each time
;
	if	homeimp
	db	' ',bs,0
	else
	db	0
	endif
;
;	get character from operator
;
	mvi	c,conin
	call	bdos
	cpi	esc
	jz	movoldtowk	;get old flags
	cpi	3
	jz	leaveflags	;quit
	cpi	ctlu
	jz	updfile		;change flags in directory
	ori	20h	;make lower case
	cpi	'l'
	jnc	doover		;out of range, loop back
	cpi	'a'
	JC	DOOVER		;out of range, loop back
;
;	Change flag in temporary fcb
;	a has flag position in 4 ls bits
;
	lxi	h,workfcb	;point to name
	ani	0fh		;kill ascii
	mov	e,a		;put into de
	mvi	d,0
	dad	d		;point to absolute address 
	mov	a,m		;get byte
	xri	80h		;toggle flag
	mov	m,a		;put it back
	jmp	doover		;loopbac to begining
;
;	update flags in directory
;
updfile:
	lxi	d,workfcb
	lda	deffcb		;get drive code
	stax	d		;set drive code in filename for setattr
	mvi	c,setattr
	call	bdos
	jmp	leaveflags
;
;	print top of page
;
doheader:
	if	homeimp
	call	homecur
	else
	call	erase
	endif
	call	inlnprt
	db	0DH,0AH,0AH
	db	'  File Parameter Flag Display/Change'
	db	' ver '
	db	version/10 + '0','.',version mod 10 + '0'
	db	0DH,0AH,0AH
	db	'          Options:            ^C - leave as is'
	db	0DH,0AH
	db	'                              ^U - update file'
	db	0Dh,0AH
	db	'                              ESC -original flags'
	db	0DH,0AH,0AH
	db	'	File: ',0 		
	lxi	h,workfcb
	call	shnm1		;show mane of file
	call	crlf
	call	crlf
	ret
;
;	move bc bytes from hl to de
;
move:	mov	a,b
	ora	c
	rz
	mov	a,m
	stax	d
	inx	h
	inx	d
	dcx	b
	jmp	move
;
;	display status of flags, menu style
;	workfcb contains file name with flags set
;
displayflags:
	mvi	a,'a'		;first letter of line
	sta	letterofline	;save for later
	lxi	h,flagsm	;point to start of flag descriptors
	shld	textpoint
	lxi	h,workfcb
	shld	flagpoint
displayloop:
	call	inlnprt
	db	'               ',0	;a crude tab
	lda	letterofline		;print line letter
	mov	e,a
	cpi	6ch		;must be less than 'l'
	rz
	inr	a
	sta	letterofline
	mov	a,e
	call	printchar
	mvi	a,' '
	call	printchar
;
;	point to next char in filename
;
	lhld	flagpoint
	inx	h
	shld	flagpoint
	mov	a,m
	ani	80h
	jz	displayblank
;
;	flag set - write SET
;
	call	displayset
	jmp	describflg
;
;	flag not set - write four blanks
;
displayblank:
	call	blanks4
;
;	now write flags discriptor text
;
describflg:
	lhld	textpoint
	xchg
	mvi	c,prstr
	call	bdos
	call	crlf
	lhld	textpoint
	lxi	d,ptextlength
	dad	d
	shld	textpoint
	jmp	displayloop
;
;	send char in a to con:
;
printchar:
	mov	e,a
	push	h
	push	b
	mvi	c,conout
	call	bdos
	pop	b
	pop	h
	ret
;
;	write four blanks
;
blanks4:
	call	inlnprt
	db	'    ',0
	ret
;
;	display the work SET
;
displayset:
	call	inlnprt
	db	'SET ',0
	ret
;
;	search didn't find file
;	
nofile:
	call	erase
	call	inlnprt
	db	0ah,0ah,0ah,0ah,9,9
	db	0
	lxi	h,deffcb
	call	shnm1
	call	inlnprt
	db	' was not found.',0
	jmp	leaveflags1
crlf:
	call	inlnprt
	db	0DH,0AH,0
	ret
;
;	display a file name
;	hl points to file name/type as in fcb
;
showname:
	lhld	filefcb
shnm1:			;calling program set pointer
	push	h
;
;	first show drive code if not current
;
	mov	a,m
	inx	h	;point to first char of name
	ora	a	;set flags
;
;	print drive code if not current
;
	jz	dispfn
	adi	'@'
	call	printchar
	mvi	a,':'
	call	printchar
;
;	print filename
;	
dispfn:	mvi	c,8	;max length of filename
	call	dispfnft
;
;	then a dot
;
	mvi	a,'.'
	call	printchar
;
;	and last the filetype
;
	pop	h	;get begining of name
	lxi	b,9	;namelength + drive code length
	dad	b	;point to filetype
	mvi	c,3	;max length of filetype
	call	dispfnft
	ret
;
;	display print character until count in c up or ' ' found
;
dispfnft:
	mov	a,m		;get char from fcb
	cpi	' '		;quit if space
	rz
	call	printchar	;print character
	inx	h		;next charw
	dcr	c
	rz			;quit if count up
	jmp	dispfnft
;
;	In line print
;
inlnprt:
	pop	h	;get address of string
inlnloop:
	mov	a,m
	ora	a
	jz	inlndone
	mov	e,a
	mvi	c,conout
	push	h
	call	bdos
	pop	h
	inx	h
	jmp	inlnloop
inlndone:
	inx	h	;push to code after text
	pchl		;go there
;
;	exit this program
;	give user a few choices
;
leaveflags:
leaveflags1:
	call	inlnprt
	db	0dh,0ah,0ah,0ah,09h
	db	'Enter file or RETURN to exit > ',0
	lxi	h,combuff
;
;	fill buffer with ' ' so makefcb sees proper terminator
;
	push	h
	pop	d
	lxi	b,combuflen
	mvi	a,' '
	call	fillb		;in makefcb.lib
;	
	mvi	m,combuflen-1	;set max
	xchg
	mvi	c,readbuff
	push	d
	call	bdos
	pop	d
	xchg
	inx	h
	mov	a,m
	ora	a
	jnz	newfile	;if zero length then quit 
	lhld	oldstack
	sphl
	ret		;to ccp with old stack intact
newfile:
	inx	h		;point to start of command string
	lxi	d,deffcb 	;where to build fcb
	call	makefcb		;make fcb from string
	jnc	again		;if no error do flags again
	call	crlf
	call	inlnprt
	db	9,9
	db	'Bad file name: ',0
	lxi	h,deffcb
	call	shnm1
	jmp	leaveflags1
;
;	erase screen
;
erase:
	if 	lineeded
	mvi	a,lichar
	call	printchar
	endif
	mvi	a,clrchar
	jmp	printchar
;
;	home cursor	(optional)
;
	if	homeimp
homecur:
	endif
	if	homeimp and lineeded
	mvi	a,lichar
	call	printchar
	endif
	if	homeimp
	mvi	a,homechar
	jmp	printchar
	endif
;
;
;	flag descriptors
;	these must remain 16 chars long or change ptextlength
;
flagsm:	
	DB	'f1 no xmdm CP/M$'
	DB	'f2 no xmdm MP/M$'
	DB	'f3             $'
	DB	'f4             $'
; above for user -- below reserved for system
	DB	'f5             $'
	DB	'f6             $'
	DB	'f7             $'
	DB	'f8             $'
        db	'read only      $'
	DB	'no directory   $'
	DB	't3             $'

;
;	make fcb from string with unambiguous file name
;	hl=filename; de=fcb
;	returns with carry set if bad name
;
makefcb:
	xra	a
	sta	flag	;flag non-zero if invalid char in name
	push	h	;save command pointer
	push	d	;save fcb pointer
;
;	clear fcb
;
	lxi	b,36
	call	clrb
;
;	put blanks in filename
;
	pop	d
	push	d
	inx	d	;point to start of filename
	lxi	b,11	;length of name + type
	mvi	a,' '	;char to fill
	call	fillb
;
;	skip any leading blanks in filename string
;
	call	skipb
;
;	look if drive specified
;
	pop	d	;get fcb
	xchg
	shld	mfcbfcb
	xchg
	pop	h	;get filename

	call	checkdrive
	inx	d	;point to file name in fcb
;
;	process filename
;	eight chars or until '.'
;
	mvi	c,8
	call	getname
;
;	there may be a dot here if we counted down to zero
;
	mov	a,m
	cpi	'.'
	jnz	nodot
	inx	h	;skip dot
nodot:
;
;	adjust de to start of filetype in fcb
;
	push	h
	lhld	mfcbfcb	;get fcbstart
	lxi	d,9	;offset from start of fcb to filetype
	dad	d
	xchg		;de is at filetype of fcb
	pop	h	;hl is at filetype (or 9th char of filename)
;
;	process filetype
;
	mvi	c,3
	call	getname
	lda	flag
	adi	1	;set carry if bad name
	ret
;
;	move chars from (hl) to (de) until count in c is up or '.' found
;
getname:
	mov	a,m
	inx	h
	call	upcase	;make upper case if lower
	call	checkvalid	;set flag if invalid
	cpi	'.'	;look for seperator
	rz
	cpi	' '
	rz
	stax	d	;put into fcb
	inx	d
	dcr	c	;count down
	rz	
	jmp	getname
;
;	check if char is legal
;	make flag non-zero if fails
;
checkvalid:
	cpi	'*'
	jz	badchar
	cpi	'['
	jz	badchar
	cpi	']'
	jz	badchar
	cpi	','
	mov	b,a
	ani	30h
	cpi	30h
	mov	a,b
	rnz		;char is valid in filename
	cpi	':'
	rc		;3xH chars less than : are ok
badchar:
	mvi	a,0ffh
	sta	flag
	ret
;
;	check and process drive
;	hl at start at first char of filename
;	put drive code into fcb pointed to by de, if there
;
checkdrive:
	inx	h	;2nd byte is a colon if drive spec'd
	mov	a,m
	dcx	h	;point back to beginingv
	cpi	':'
	rnz		;no ':' no drive
	mov	a,m
	call	upcase	;make upper
	ani	0fh	;remove ascii bias
	stax	d	;put into drive code of fcb
	inx	h	;point to colon
	inx	h	;point to first char of name
	ret
;
;	skip blanks in filename
;	hl left pointing at first non-blank
;
skipb:	mov	a,m
	cpi	' '
	rnz
	inx	h
	jmp	skipb
;
;	convert character to upper case (if needed)
;	char in and returned in a
;
upcase:	cpi	'`'	;' has 60h bits set but is not lower case
	rz
	cpi	'{'	;{ and above are good too
	rnc
	push	psw	;save char
	ani	60h	;isolate bits
	cpi	60h
	jnz	notlower
	pop	psw
	ani	5fh	;make upper
	ret
notlower:
	pop	psw
	ret
;
;	fill bc bytes with char in a, starting at de
;
clrb:	mvi	a,0
fillb:	inr	b
	dcr	b
	jnz	fillb1
	inr	c
	dcr	c
	rz
fillb1:	stax	d
	inx	d
	dcx	b
	jmp	fillb
;
;	ram storage area
;
workfcb:		;this is the temporary filename
	ds	36	;used for all operations
letterofline:		;letter for display
	ds	1
combuff:		;readbuffer for bdos cmd 10
	ds	combuflen
flagpoint:		;points to character in workfcb 
	ds	2
textpoint:		;points to flag descriptor in flagsm
	ds	2
oldstack ds	2	;save stack pointer for no-boot return
filefcb	ds	2	;absolute address of fcb
mfcbfcb	ds	2	;address of fcb under constructio for makefcb
flag:	ds	1	;ff if bad char in filename
	ds	30
stacktop equ	$	;private stack
	end
