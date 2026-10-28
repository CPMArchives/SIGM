	title	'CCT.ASM	05/29/82'

;Used to combine multiple small files into one large file.

;command format:

;	CCT output [string] ]string[ = input1 , input2....

;;	blanks may be used before and after (but not
;;	within) the filenames for readability. The
;;	commas are also optional, except there must be
;;	something separating the filenames.

;;The input and output files may have the standard form
;;		drive:filename.ext
;;	where the drive may be A: to N: and is optional,
;;	and ext is the optional file extension.

;;If the output filename is * (not *.*), the program will
;;	create the file $$$.SUB on drive A in correct SUBMIT
;;	format. That is, CCT can be used as a replacement
;;	for SUBMIT, except for parameter substitution. The
;;	program will automatically stop at 128 lines of input,
;;	since that is what most CP/M systems allow.

;;The [string] is the optional prefix string, which will be
;;	put at the beginning of every line of the output file.
;;	The [ and ] are required punctuation, and the ] cannot
;;	be within the string, tho almost anything else can be.
;;	The surrounding brackets will not be included in the
;;	string. When present, the prefix string will always be
;;	the first characters of the output file, unless the
;;	output is completely empty.

;;The ]string[ is the optional suffix string, which will be
;;	put at the end of every line on the output file. The
;;	] and [ are required punctuation, and the [ cannot be
;;	within the string. The suffix string may be specified
;;	in the command line in front of the prefix string, as
;;	long as both are after the output filename and before
;;	the equal sign (=)

;;An input filename %N will give a CRLF (hex 0D 0A)
;;An input filename %F will give a Formfeed (hex 0C)
;;An input filename %T will give a Tab (^I, hex 09)

;;An input file name of n (a number from 1 to 65535) will cause
;;	an automatic CRLF after "n" characters on one line. The
;;	CR and LF are not counted in the number of characters
;;	per line, and this option will hold for all successive
;;	files until changed. Any characters being inserted
;;	by prefix or suffix strings are not counted. To turn
;;	off this option after using it on an earlier input file,
;;	use option 65535

;;An input file name of +n (a number from 1 to 65565) will cause
;;	the program to skip the first "n" lines of each following
;;	input file, until changed. To turn this option back off,
;;	specify option +0

;;An input file name of -n (a number from 1 to 65535) will cause
;;	the program to stop after the "n"th line is read from
;;	each file, until changed. To turn this option back off,
;;	specify an option of -65535

;;The "n" "+n" and "-n" options are absolutely independent of each
;;	other, and may appear many times in the command, each or
;;	together.

;;An * as an input  filename, such as A=* or A=B,*,C will
;;	switch to the console for input. All the standard
;;	line-editing functions are available, such as
;;	backspacing. Up to 254 characters may be input,
;;	and the input terminates with a null line or a
;;	EOF (Control-Z, hex 1A)

;;If the output file is omitted (no =), the console will
;;	be the destination

;; For example :

;;	CCT -60 CCT.ASM		Types the first 60 lines of CCT.ASM

;;	CCT A = B FOO.ASM	Concatenates B and FOO.ASM giving A

;;	CCT A,C:B,C		Concatenates A, B (from the C drive),
;;				 and C with output to the console

;;	CCT A=*			Create file A from your console input

;;	CCT A = *, +5 X.ASM	Accepts whatever you type in, followed
;;				by all but the first 5 lines of X.ASM

;;			Note: CCT works under XSUB and will accept
;;			the input from the "console" that XSUB
;;			fakes out. Use the ^z to terminate input.

;;	CCT NEW.ASM=OLD.ASM	Copies OLD.ASM to NEW.ASM
;;				NOTE:  only for ASCII files

;;	CCT X.ASM = Y %N Z	Concatenates Y, adds a CRLF, then Z
;;				 output going to X.ASM

;;	CCT %N %N %N %N		Sends four CRLFs to the console

;;	CCT COMMENT.ASM [; ] = COMMENT.DOC  Puts a ; and a blank at
;;				the beginning of every line in the
;;				.DOC file and puts the results in
;;				the COMMENT.ASM file

;;	CCT * = *		Accepts a series of commands from
;;				the console, and creates a submit
;;				file that will automatically start
;;				executing when CCT is done.

;;	CCT * [PIP C:=B:] = NAMES.SUB  Puts "PIP C:=B:" in front of
;;				every line from NAMES.SUB and will
;;				submit the results to CP/M. This may
;;				be useful if NAMES.SUB is a list of
;;				files on drive B:

;;			Note: Ward Christensen's FMAP utility
;;			can create a file containing a list
;;			of filenames. This is very handy.

;;	CCT -5 A B		Will type the first 5 lines of file A
;;				followed by the first 5 lines of file B.

;;	CCT B = +6 A		Will copy file A to file B, skipping
;;				the first 6 lines of A.

;;	CCT -7 A +5 B		Will copy the first 7 lines of file A
;;				followed by lines 6 and 7 of file B.

;;	CCT 80 C		Will type file C, putting an automatic
;;				CR-LF every 80 bytes on every line that
;;				is over 80 bytes long. Lines under 80
;;				bytes long will be unchanged.

;;	CCT D = -7 E -9 F	Will type the first 7 lines of E followed
;;				by the first 9 lines of F.


;;Bugs or restrictions

;;	If BLKSIZE is 16, as supplied, the program will require a
;;		a minimum 24K CP/M system, and will allow a maximum
;;		of 128 (16K/128) lines of Submit output. The BLKSIZE
;;		does not affect other types of files except for per-
;;		formance.

;;	Ambiguous filenames are not allowed (no ? in filename)
;;		The files might not be concatenated in the order
;;		you wanted anyway.

;;	As the exception to the above statement, an output filename
;;		beginning with ? will be treated as *, because it was
;;		not deemed worth the effort to put in any extra code.

;;	If the output file exists, it will be erased and replaced,
;;		so CCT A = A,B  will not do what you want

;;	A filename with nothing but an extension ( .ASM) is con-
;;		sidered an error

;;	It is possible to use a file called %N, %F, %T, +n, -n, or n
;;		- just put a period after it, e.g. %N. or +5. or 988.

;;	Multiple commas get swallowed - A,,,B is wierd but OK.
;;		This might be useful in a submit file if a parameter
;;		is missing, such as   CCT $1=$2,$3,$4

;;	The program will stop when it hits a Control-Z (hex 1A), so
;;		using it to copy .COM files is not recommended.

;;	There will be only one Control-Z at the end, but there will
;;		always be one there, even if the input files do not
;;		have one, & that will be the only one in the file.

;;	When creating a file from console input, it is possible to
;;		choose whether there will be a CR-LF (hex 0D 0A) at
;;		the end. If you want it, stop with a null line. If
;;		you don't, stop by typing a Control-Z before hitting
;;		Return on the last line.

;;	Entering an ASCII NUL (hex 00, Control-@) can cause wierd
;;		problems anywhere in CP/M, and should be avoided.

;;	Entering CCT * will echo console input back to the console,
;;		but most systems will not see anything, because the
;;		output line will exactly overlay the input line.
;;		This command might be useful for Microshell, tho.

;;	The brackets [ and ] must be paired right, and may not appear
;;		in the output or any input filename.

;;	The %N is not changed into a CRLF within the prefix and suffix
;;		strings. In fact, I haven't found a way of getting
;;		a CRLF into the strings yet.

;;	If you want prefix or suffix strings on console output, you
;;		must put an = after the strings. Under any other con-
;;		dition, you cannot use an = if you want console out.
;;		E.g. CCT [<<<]=A and CCT A are legal, CCT =A is not

;;	It is adviseable to put spaces in between the output filename
;;		and the [ or ] if a prefix or suffix string is desired.
;;		In some versions of CP/M, if you are putting "funny"
;;		characters in the strings, it may be necessary to put a 
;;		. (period) before the strings start (and after the output
;;		filename) e.g.   CCT A . [^I.A::^I::??] = B

;;	If * is the output filename, the file $$$.SUB will be erased
;;		on the A: drive and a new file will be created. This
;;		may be desireable or not, but it will happen. It is
;;		possible to use CCT to chain to another file at the
;;		end of a submit file if the CCT *=filename is the
;;		last command in the first Submit file. CCT will acc-
;;		null lines from the input file, unlike Submit.

;;	The algorithm used for the prefix and suffix strings will in-
;;		tentionally not put the strings on the last line of
;;		the output file, if that line is empty. That is, if
;;		the end of the last file is CR LF EOF, the output file
;;		will also be that way.

;;	The algorithm used for line determination also treats the CR and
;;		LF as equivalent, and basically nul - that is, it doesn't
;;		care whether there is a CR, a CR-LF, an LF, or maybe CR-
;;		LF-CR-LF-LF, they're all the same. This most seriously
;;		affects the +n and -n options if there are nul lines.

;;	If both are used, the + number must be less than the - number, or
;;		there will be no output from that file. The file(s) will
;;		be opened, though, so that might be a way of testing for
;;		files. For example,  CCT -0 +1 A B  just sees if files
;;		A and B are present.

;;	The character-per-line counter (used by the "n" option) does not
;;		treat tabs specially - that is, tabs are not expanded when
;;		computing the number of characters on the line.

;adapted from	'COMBINE.ASM'
;12/10/78 BY Ward Christensen

;Modified by Bob Van Valzah & Steve Ness on 1/9/79 to allow
;source files on any drive and remove comments preceded by blanks.

;Modified by Steve Ness on 12/20/79 to allow filetypes on source files.

;; 05/16/82 by Chuck Weingart, take out comment killer (above),
;;	add the %n inserter, rename to CCT to make a UNIX-like
;;	filter (the name CAT was already taken), add more error
;;	checks, allow console input, add prefix and suffix strings,
;;	and ignore blanks on command line.

;; 05/29/82 by Chuck Weingart, Add the %F and %T inserter from an
;;	idea of Jim Mills. Add GETNUM and the line and character
;;	counters etc. code to restrict the output. Includes code
;;	from /.ASM by John M. Kodis, CP/M U.G. contribution Novem-
;;	ber 1980, on CPMUG 78. (Based on "/.COM", CPMUG 40.1,
;;	originally written by Ward Christensen)

TEST	EQU	0
;;		The BLKSIZE parameter determines the maximum
;;		number of lines allowed in a $$$.SUB file, and
;;		is used otherwise for efficiency.
K	EQU	1024	;1K
BLKSIZE	EQU	16*K	;OUTPUT FILE BLOCKSIZE
;;
tpa	equ	100h	;transient program area
;;
EOF	EQU	1AH	;;Control-Z
CR	EQU	0DH	;;Carriage Return
LF	EQU	0AH	;;Line Feed
;
;(FROM EQU7.LIB...)
MF	SET	0	;SHOW MOVE NOT REQUESTED
CF	SET	0	;SHOW COMP NOT REQUESTED

;
;DEFINE SOME MACROS TO MAKE THINGS EASIER
;
;DEFINE DATA MOVE MACRO
;
MOVE	MACRO	?F,?T,?L,?I
	IF	NOT NUL ?F
	LXI	H,?F
	ENDIF
	IF	NOT NUL ?T
	LXI	D,?T
	ENDIF
	IF	NOT NUL ?L
	LXI	B,?L
	ENDIF
	IF	NOT NUL ?I
	LOCAL	?B,?Z
	CALL	?Z
?B	DB	?I
?Z	POP	H	;GET TO
	LXI	B,?Z-?B
	ENDIF
	CALL	MOVER
MF	SET	-1	;;SHOW EXPANSION
	ENDM
;COMPARE MACRO
COMP	MACRO	?F,?T,?L,?I
	IF	NOT NUL ?F
	LXI	H,?F
	ENDIF
	IF	NOT NUL ?T
	LXI	D,?T
	ENDIF
	IF	NOT NUL ?L
	LXI	B,?L
	ENDIF
	IF	NOT NUL ?I
	LOCAL	?B,?Z
	CALL	?Z
?B	DB	?I
?Z	POP	D	;GET TO
	LXI	B,?Z-?B
	ENDIF
	CALL	COMPR
CF	SET	-1	;;SHOW EXPANSION
	ENDM
;
;DEFINE CP/M MACRO - CPM FNC,PARM
;
CPM	MACRO	?F,?P
	PUSH	B
	PUSH	D
	PUSH	H
	IF	NOT NUL ?F
	MVI	C,?F
	ENDIF
	IF	NOT NUL ?P
	LXI	D,?P
	ENDIF
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	ENDM
;
	ORG	tpa
;INIT LOCAL STACK
;
	LXI	H,0
	DAD	SP
	SHLD	STACK
	LXI	SP,STACK
	lxi	h,cibuf
	mov	a,l	;;from /.asm
	add	m
	inr	a
	mov	l,a
	mvi	m,0	;zero the byte after the end of the command line.
;
;
;START OF PROGRAM EXECUTION
;
;MOVE THE COMMAND BUFFER
	MOVE	cibuf,HOLD,128 ;FROM,TO,LENGTH
	COMP	FCB,,,<0,'?'>
	JNZ	POSITION ;;check for *, or a close resemblance
	COMP	FCB+9,,,'   '
	JNZ	POSITION
	MVI	A,0C3H	;;now flag the *
	STA	STRFLAG
POSITION	; TO FIRST NAME TO COPY (FOLLOWS =)
	LXI	H,HOLD
	SHLD	NAMEADD	;;save in case of no file
SKIPEQ	INX	H
	MOV	A,M
	ORA	A	;;check if end of line
	JZ	CONSOL
	CPI	'['	;;look for boxes
	JZ	SKIPBRK
	CPI	']'
	JZ	S2IPBRK
	CPI	'='
	JNZ	SKIPEQ
	SHLD	NAMEADD	;SAVE POINTER
	LDA	STRFLAG
	ORA	A	;;see if got the *
	JZ	QMTEST
	MOVE	XFCB,FCB,24
	lxi	h,subbuf+1;hl is the destination pointer.
	SHLD	SUBOUT
	LXI	H,BLKSIZE/128	;;maximum number of lines
	SHLD	MINSNUM
	JMP	EQDONE
QMTEST
	LXI	H,FCB+1	;;now set up to scan FCB
	MOV	A,M
	MVI	B,11
QMLOOP
	CPI	'='	;;see if got equal in filename
	JZ	EQLOOP
	CPI	'>'
	JZ	EQLOOP
	CPI	'?'	;;see if ambiguous
	JZ	QMFILE
	CPI	'['	;;kill the boxes, too
	JZ	EQLOOP
	CPI	']'
	JZ	EQLOOP
	INX	H	;;check next character
	MOV	A,M
	DCR	B	;;see if done
	JNZ	QMLOOP
;ERASE THE OUTPUT FILE
EQDONE
	LDA	FCB+1	;;see if error
	CPI	' '
	JZ	NOFILE2
	IF	NOT TEST
	CPM	delete,FCB
	CPM	makef,FCB
	INR	A
	JZ	NOROOM
	ENDIF
	CALL	NEXTFL	;PRIME THINGS
	JC	NOFILE
LOOP	CALL	WRBYTE
	CALL	RDBYTE
	JNC	LOOP
;DONE -
NOFILE0
	MVI	A,EOF	;;gotta end the file
	CALL	WRBYTE
	LDA	STRFLAG	;;buffers for $$$.sub already flushed
	ORA	A
	JNZ	DONEIT
	LHLD	WRCOUNT
	LXI	D,128
	DAD	D	;FORCE LAST SECTOR
	SHLD	WRCOUNT	;..WRITE
	CALL	WRBUFS	;WRITE THE BUFFER
DONEIT
	CPM	closef,FCB
	INR	A
	JNZ	EXIT
	CALL	ERXIT
	DB	'++CLOSE ERROR++$'
;
EQLOOP
	MVI	M,' '	;;gonna blank out rest of FCB
	INX	H
	DCR	B	;;see if done
	JNZ	EQLOOP
	JMP	EQDONE
;;
SKIPBRK
	SHLD	BRAKAD	;;save address
SKIPLUP
	INX	H	;;bump to next
	MOV	A,M
	ORA	A	;;check if end of line
	JZ	BADNAME
	SBI	']'	;;stop at bracket
	JNZ	SKIPLUP
	MOV	M,A	;;note for later use
	JMP	SKIPEQ
;;
S2IPBRK
	SHLD	B2AKAD	;;save address
S2IPLUP
	INX	H	;;bump to next
	MOV	A,M
	ORA	A	;;check if end of line
	JZ	BADNAME
	SBI	'['	;;stop at bracket
	JNZ	S2IPLUP
	MOV	M,A	;;note for later use
	JMP	SKIPEQ
;;
QMFILE
	CALL	ERXIT	;;
	DB	'++AMBIGUOUS FILE++$'
;
NOFILE
	LDA	PCTFLAG	;;see if just percents
	ORA	A
	JZ	NOFILE1
	LDA	CNFLAG	;;see if submit file out
	ORA	A
	JZ	NOFILE0
	JMP	EXIT	;;if console out, nothing to close
NOFILE1
	CALL	ERXIT	;;nothing at all
	DB	'++MISSING FILE++$'
;;
;;
NOFILE2
	LHLD	BRAKAD	;;see if prefix or suffix strings
	MOV	A,H
	ORA	L
	LHLD	B2AKAD
	ORA	H
	ORA	L
	JZ	NOFILE1	;; = is OK if had strings
;;
CONSOL
	MVI	A,0C3H
	STA	CNFLAG
	CALL	NEXTFL	;;set up loop
	JC	NOFILE
LOOPC	CALL	WRBYTE	;;now copy to console
	CALL	RDBYTE
	JNC	LOOPC	;;see if all done
	JMP	EXIT
;
;WRITE BYTE TO OUTPUT FILE
;
WRBYTE
	MOV	B,A	;;save the character
	CPI	EOF	;;see if end
	JZ	WRCRLF
	CPI	CR	;;look for CR or LF
	JZ	WRCRLF
	CPI	LF
	JZ	WRCRLF
;;	Just got a character not CR, LF, or EOF
	LHLD	WIDTH	;;bump up char. #
	INX	H
	SHLD	WIDTH
	XCHG
	LHLD	WIDNUM	;;load max width
	MOV	A,L
	SUB	E
	MOV	A,H	;;compare width to max
	SBB	D
	JNC	WRBY2
	PUSH	B	;;save the character
	MVI	A,CR
	CALL	WRBYTE	;;recursive call to end line
	MVI	B,LF
	CALL	WRBYT
	POP	B	;;now r	la;OZ0'mYacter on new line
WRBY2
	LDA	CRFLAG	;;now check if just had CR or LF
	ORA	A
	JZ	WRBYT
	LHLD	LINE	;;bump up line counter
	INX	H
	SHLD	LINE
	XRA	A	;;now turn off CRLF
	STA	CRFLAG
	LHLD	BRAKAD	;;at beginning of line, put out prefix
	MOV	A,L
	ORA	H	;;see if prefix
	JZ	WRBYT
PREFLUP
	INX	H
	MOV	A,M	;;get a character
	ORA	A
	JZ	WRBYT	;;jump if end of prefix string
	PUSH	H
	PUSH	B
	MOV	B,A
	CALL	WRBYT	;;pump out character
	POP	B
	POP	H
	JMP	PREFLUP
;;
;;	Just found a CR or LF
WRCRLF
	LXI	H,0	;;zero out line width
	SHLD	WIDTH
	LDA	CRFLAG	;;now check if just had CR or LF
	ORA	A
	JNZ	WRBYT
	CMA		;;now indicate CRLF
	STA	CRFLAG
	LHLD	B2AKAD	;;at end of line, put out suffix
	MOV	A,L
	ORA	H	;;see if suffix
	JZ	WRBYT
SUFFLUP
	INX	H
	MOV	A,M	;;get a character
	ORA	A
	JZ	WRBYT	;;jump if end of prefix string
	PUSH	H
	PUSH	B
	MOV	B,A
	CALL	WRBYT	;;pump out character
	POP	B
	POP	H
	JMP	SUFFLUP
;;
;;	Now put out character wherever it goes
WRBYT
	LHLD	LINE	;;get line #
	MOV	A,L
	ORA	H	;;if very first line, accept CR and LF
	JZ	WRBY3
	XCHG
	LHLD	PLUSNUM	;;get starting #
	MOV	A,L
	SUB	E
	MOV	A,H	;;compare line # vs start
	SBB	D
	RNC
	LHLD	MINSNUM	;;get ending line #
	DCX	D
	MOV	A,E
	SUB	L
	MOV	A,D	;;compare line # vs end
	SBB	H
	JNC	FAKEOF	;;tell RDBYTE to get next file
WRBY3
	LDA	CNFLAG
	ORA	A	;;if console output, go do it
	MOV	A,B
	JNZ	TYPE
	LDA	STRFLAG
	ORA	A	;;if submit output, go do it
	JNZ	SUBCMD
	LHLD	WRBUFAD	;;disk i/o is buffered
	MOV	M,B
	INX	H	;;bump up to next character
	SHLD	WRBUFAD
;BUMP COUNT
	LHLD	WRCOUNT
	INX	H
	SHLD	WRCOUNT
;SEE IF TIME TO WRITE BUFFER
	DAD	H	;H=# SECTORS
	MOV	A,H
	CPI	BLKSIZE/128
	RNZ
;TIME TO WRITE THE OUTPUT BUFFER
;
WRBUFS	LXI	H,WRBUFF
	SHLD	WRBUFAD
	XCHG
	LHLD	WRCOUNT
	DAD	H	;H=# SECTORS
	MOV	B,H	;SAVE SECTOR COUNT
	MOV	A,B
	ORA	A	;0 SECTORS? (POSS AT EOF)
	JNZ	WRBFLP
	INR	B	;FUDGE IN PARTIAL SECTOR
WRBFLP	CPM	dmaf
	CPM	writef,FCB
	ORA	A
	JNZ	WRERR
	LXI	H,128
	DAD	D
	XCHG
	DCR	B
	JNZ	WRBFLP
	LXI	H,0
	SHLD	WRCOUNT
	RET
;
;	all this from /.asm , with thanks
;
SUBCMD
	MOV	A,B
	CPI	LF	;;skip linefeeds
	RZ
	LHLD	SUBOUT
	CPI	CR	;;see if end of line
	jz	cmdend
	CPI	EOF	;;end of file ?
	jz	cmdend
	mov	m,a	;if neither, xfer it to the output buffer,
	inx	h	;bump pointer
	SHLD	SUBOUT
	RET		;and try again.
;
cmdend:	mvi	m,0	;zero the byte after the end of the line.
	mov	a,l
	dcr	a
	ani	7fh	;accumulator has character count.
	mov	c,a	;save it.
	mov	a,l
	ani	80h
	mov	l,a	;hl points to the character count byte.
	mov	m,c
;
	MOV	A,B
	CPI	EOF	;if we've reached the end of the input line...
	jz	fileit	;let's "file it".
	lxi	b,129
	dad	b
	SHLD	SUBOUT
	RET		;back for the next command.
;
fileit:		
;
wrloop:	push	h	;save address of last zone
	xchg
	mvi	c,dmaf
	call	bdos
;
	lxi	d,fcb
	mvi	c,writef
	call	bdos	;write the new commands, one command per
			;disk sector, writing the last command first.
	ORA	A
	JNZ	WRERR
;
	pop	h	;get current dma address
	lxi	d,-128
	dad	d
	lxi	d,subbuf
	mov	a,l
	sub	e
	mov	a,h
	sbb	d
	jnc	wrloop
	RET
;
WRERR	CALL	ERXIT
	DB	'++WRITE ERROR++$'
;;
FAKEOF
	LXI	H,RDBUFF ;;create EOF so RDBYTE will
	SHLD	RDBUFAD	 ;;get next file
	MVI	A,EOF
	MOV	M,A
	STA	RDCOUNT
	RET
;
;READ BYTE FROM INPUT FILE
;
RDBYTE	LHLD	RDBUFAD
	LDA	RDCOUNT	;GET CHAR COUNT
	ORA	A	;TIME TO READ?
	JP	NOREAD
;HAVE TO READ
	CPM	dmaf,RDBUFF
	CPM	readf,RDFCB
	ORA	A
	JNZ	NEXTFL	;;if disk EOF, go get next file
	CPM	dmaf,cibuf
	LXI	H,RDBUFF
	MVI	A,0
NOREAD	INR	A
	STA	RDCOUNT	;SAVE CHAR COUNT
	MOV	A,M	;GET CHAR
	INX	H
	SHLD	RDBUFAD
	CPI	EOF	;EOF?
	JZ	NEXTFL
	ORA	A	;CARRY OFF SHOWN NOT EOF
	RET
;
;GOT EOF - GET NEXT FILE
NEXTFL
	LXI	H,0
	SHLD	WIDTH	;;zero out counters for new file
	SHLD	LINE
	LHLD	NAMEADD	;GET NAME POINTER
	MOV	A,M	;GET DELIMITER
	ORA	A
	STC
	RZ		;RET IF ALL DONE
MOVEX
	INX	H	;SKIP DELIMITER
	MOV	A,M
	CPI	' '	;;gonna skip by blanks
	JZ	MOVEX
	CPI	','	;;   and commas
	JZ	MOVEX
	ORA	A
	STC		;;return if nothing but blanks
	RZ
	LXI	D,RDFCB ;POINT TO NAME
	xra	a	;prepare to use default drive
	stax	d
	STA	PRFLAG	;;zero out period flag
	inx	d
	PUSH	D
;BLANK THE FCB
	MVI	A,' '
	MVI	B,11
BLANK	STAX	D
	INX	D
	DCR	B
	JNZ	BLANK
	POP	D
;
	inx	h	;look ahead for colon, indicating drive
	mov	a,m
	dcx	h	;backup j.i.c. not there
	cpi	':'	;was a drive specified?
	jnz	moven	;nope - just scan off file name
	mov	a,m	;yup - insert drive name into fcb
	sui	'A'-1
	JC	MOVEN	;;skip bad drive name
	CPI	16	;;and make sure valid
	JNC	BADNAME
	sta	rdfcb
	inx	h	;move source pointer over drive spec.
	inx	h
MOVEN	MOV	A,M
	CPI	':'	;;see if extraneous colon
	JZ	BADNAME
	CPI	'>'
	JZ	BADNAME
	CPI	'?'	;;dont allow ambiguity
	JZ	QMFILE
	CPI	','
	JZ	MOVED
	CPI	' '	;;stop at comma or blank
	JZ	MOVED
	cpi	'.'
	jz	movft
	ORA	A	;ZERO @ END?
	JZ	MOVEZ
	CPI	'['	;;no bad filenames
	JZ	BADNAME
	CPI	']'
	JZ	BADNAME
	STAX	D
	MVI	A,FCBEXT ;;is it past FCB ?
	CP	E
	JNC	BADNAME
	INX	H
	INX	D
	JMP	MOVEN
movft
	LDA	PRFLAG	;;check if already got period
	ORA	A
	JNZ	BADNAME
	CMA
	STA	PRFLAG	;;indicate found period
	inx	h
	lxi	d,rdfcb+9	;address filetype of read block
	jmp	moven
;
MOVEZ
	SHLD	NAMEADD	;SAVE NAME LIST ADDR
	LDA	RDFCB+1
	CPI	' '	;;look at file name
	STC
	RZ
;ALL DONE MOVING
MOVED	SHLD	NAMEADD	;SAVE NAME LIST ADDR
	LDA	RDFCB+1	;;see if no file
	CPI	' '
	JZ	NOFILE
	LDA	PRFLAG
	ORA	A	;;if got a period, not special name
	JNZ	NOCENT
	CALL	GETNUM	;;see if have valid number
	JNC	GOTNUM
;;	check for special filenames
	COMP	RDFCB,,,<0,'*   '>
	JZ	GOTBLNK
	COMP	RDFCB,,,<0,'%F  '>
	JZ	FORMFEED
	COMP	RDFCB,,,<0,'%T  '>
	JZ	TABCHAR
	COMP	RDFCB,,,<0,'%N  '>
	JNZ	NOCENT
	MVI	A,CR	;; CR
	STA	PCTFLAG
	CALL	WRBYTE
	MVI	A,LF	;; LF
	CALL	WRBYTE
	JMP	NEXTFL	;;now go skip by filename
FORMFEED
	MVI	A,0CH	;; FF
	STA	PCTFLAG
	CALL	WRBYTE	;; put it out
	JMP	NEXTFL
TABCHAR
	MVI	A,09H	;; Tab
	STA	PCTFLAG
	CALL	WRBYTE	;; put it out
	JMP	NEXTFL
NOCENT
	XRA	A
	STA	RDEXT	;ZERO EXTENT
	STA	RDRNO	;ZERO RECORD #
	CPM	dmaf,RDBUFF
	CPM	openf,RDFCB
	INR	A
	JZ	OPENERR
	MVI	A,128	;SHOW TIME TO READ
	STA	RDCOUNT
	CPM	dmaf,cibuf
	JMP	RDBYTE
;;
;;	Do console input here
GOTBLNK
	LDA	PRFLAG
	ORA	A	;;see if bad news
	JNZ	BADNAME
	CMA
	STA	PCTFLAG	;;deactivate error message
GOTLIN
	CPM	CONIN,INAREA
	LXI	H,INAREA+1 ;;get character count
	MOV	A,M
	ORA	A	;;see if no line
	JZ	NEXTFL
	MOV	B,A	;;initialize loop
	INR	B
GOTLUP
	DCR	B	;;see if end of line
	JZ	GOTEND
	INX	H	;;get next character
	MOV	A,M
	ORA	A	;;stop if NUL
	JZ	NEXTFL
	CPI	EOF	;;see of EOF
	JZ	NEXTFL
	PUSH	B
	PUSH	H
	CALL	WRBYTE	;;pop out character
	POP	H
	POP	B
	JMP	GOTLUP	;;no go get another
GOTEND
	MVI	A,CR	;;put out CR
	CALL	WRBYTE
	MVI	A,LF	;;put out LF
	CALL	WRBYTE
	LDA	CNFLAG	;;see if console in, file out
	ORA	A
	JNZ	GOTLIN
	MVI	A,LF	;;LF after CR if console in
	CALL	TYPE
	JMP	GOTLIN	;;go get another line
;;
;;	Now process the three numeric options
GOTNUM
	XCHG		;;put number in HL
	LDA	SGNFLAG
	ORA	A	;;check sign
	JNZ	GOTNUM2
	SHLD	WIDNUM	;;no sign
	JMP	NEXTFL
GOTNUM2
	CPI	'-'
	JNZ	GOTPLS
	SHLD	MINSNUM	;;minus sign
	JMP	NEXTFL
GOTPLS
	SHLD	PLUSNUM	;;plus sign
	JMP	NEXTFL
;;
;;
OPENERR	LXI	H,RDFCB+1
	MVI	B,11
NAMELP	MOV	A,M
	CALL	TYPE
	INX	H
	DCR	B
	JNZ	NAMELP
	CALL	ERXIT
	DB	': ++OPEN FAILED++$'
;;
;;
BADNAME
	LXI	H,RDFCB+1
	MVI	B,11
NAMEZZ	MOV	A,M
	CALL	TYPE
	INX	H
	DCR	B
	JNZ	NAMEZZ
	CALL	ERXIT
	DB	'++INVALID FILENAME++$'
;
;
NOROOM	CALL	ERXIT
	DB	'++NO ROOM ON OUTPUT DISK$'
;
TYPE	MOV	E,A
	CPM	WRCON
	RET
;;
;;	This code scans RDFCB for a decimal number and converts
;;	it into a 16-bit number in DE. Leading plus and minus
;;	signs are accepted and indicated in SGNFLAG. If there
;;	are any problems (bad digits or overflows), the carry
;;	flag is set and the routine stops.
;;
GETNUM
	LXI	H,RDFCB+1	;; initialize first
	MVI	B,8
	XRA	A
	MOV	E,A
	MOV	D,A
	STA	SGNFLAG
	MOV	A,M
	CPI	'+'		;; now check for leading +
	JZ	GOTSIGN
	CPI	'-'		;; or -
	JNZ	GETDIG
GOTSIGN
	STA	SGNFLAG		;; indicate the sign
GITLUP
	INX	H		;; bump up to next char
	DCR	B
	RZ			;; return if done
	MOV	A,M
	CPI	' '
	RZ
GETDIG
	CPI	'9'+1		;; now check for valid numeric
	CMC
	RC
	SBI	'0'		;; test and subtract combined
	RC
	MOV	C,A		;; now have 0-9 in C
	PUSH	H
	MOV	H,D
	MOV	L,E		;; DE - HL
	DAD	H
	RC			;; * 2
	MOV	D,H
	MOV	E,L
	DAD	H		;; * 4
	RC
	DAD	H		;; * 8
	RC
	DAD	D		;; * 10 = * ( 8+2 )
	RC
	XRA	A
	MOV	D,A		;; now add in digit
	MOV	E,C
	DAD	D
	RC
	XCHG			;; result back in DE
	POP	H
	JMP	GITLUP
;
;FOLLOWING FROM 'EQU7.LIB'---->
;
;MOVE SUBROUTINE
;
	IF	MF	;MACRO EXPANSION FLAG SET?
MOVER	MOV	A,M
	STAX	D
	INX	H
	INX	D
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	MOVER
	RET
	ENDIF
;
	IF	CF	;MACRO EXPANSION FLAG SET?
COMPR	LDAX	D
	CMP	M
	RNZ
	INX	D
	INX	H
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	COMPR
	RET
	ENDIF
;
;
;EXIT WITH ERROR MESSAGE
MSGEXIT	EQU	$	;EXIT W/"INFORMATIONAL" MSG
ERXIT	POP	D	;GET MSG
	MVI	C,PRINT
	CALL	BDOS
;EXIT, RESTORING STACK AND RETURN
EXIT	LHLD	STACK
	SPHL
;
	rst	boot	;back to cp/m via a warm start.
			;changing this to a "ret" will return
			;to CP/M without the warm start, and so
			;the command file will not be executed
			;until the next boot from this disk.
;;
;;
BRAKAD
	DW	0	;;start of prefix string
B2AKAD
	DW	0	;;start of suffix string
PCTFLAG
	DB	0	;;flag to indicate percent
PRFLAG
	DB	0	;;flag to indicate period
CNFLAG
	DB	0	;;flag indicating console
CRFLAG
	DB	1	;;flag indicating CR or LF
STRFLAG
	DB	0	;;flag indicating doing $$$.sub
WIDNUM
	DW	65535	;;maximum line width
MINSNUM
	DW	65535	;;maximum line number
PLUSNUM
	DW	0	;;beginning line number
WIDTH
	DW	0	;;current line width
LINE
	DW	0	;;current line number
;;
WRBUFAD	DW	WRBUFF	;OUTPUT BUFFER ADDR
WRCOUNT	DW	0	;BYTE COUNTER
RDBUFAD	DW	RDBUFF
RDDRV	DB	0	;DRIVE NAME TO READ FROM
RDFCB	DB	0,'filenameext'
RDEXT	DB	0
	DS	19
RDRNO	DB	0
RDCOUNT	DB	128	;CHARACTER COUNT IN BUFF
;
xfcb:	db	1, '$$$     SUB'	;;note file on A: drive
	dw	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
;;
;;CONSOLE INPUT LINE BUFFER
INAREA	DB	254
	DS	255
;;
;;	Only unitialized RAM after this 
;;
	DS	40H	;STACK AREA
STACK	DS	2
;;
;POINTER TO LIST OF FILENAMES
NAMEADD	DS	2
;;
SUBOUT
	DS	2	;;pointer to submit output buffer
;;
SGNFLAG
	DS	1	;;indicates if a sign was found in GETNUM
;;
;COPY OF INPUT COMMAND BUFFER (FROM 80H)
HOLD	DS	128
;;
;OUTPUT DISK BUFFER
	ORG	($+255) AND 0FF00H ;TO PAGE
RDBUFF	DS	128
subbuf:
WRBUFF	DS	BLKSIZE
;;
;;	The end of the buffer must not overlay the BIOS
ENDBUF
;;
;BDOS/CBIOS EQUATES (VERSION 7)	
RDCON	EQU	1
WRCON	EQU	2
PRINT	EQU	9
CONIN	EQU	10
CONST	EQU	11
openf	equ	15
closef	equ	16
SRCHF	EQU	17
SRCHN	EQU	18
delete	equ	19
readf	EQU	20
writef	equ	21
makef	equ	22
REN	EQU	23
dmaf	equ	26
;
boot	equ	  0	;for a warm start
bdos	equ	  5	;cp/m entry point
FCB	EQU	5CH 
FCB2	EQU	6CH
FCBEXT	EQU	FCB+12
FCBRNO	EQU	FCB+32
cibuf	equ	080h	;console input buffer
	END
