;		      COPYFAST.ASM Version 3.5
;		(See the DOC file for change history)
;
	ORG	0100H
;
;
;	Equates
;
FALSE	EQU	0	; define false
TRUE	EQU	NOT FALSE;  define true
;
EXITCP	EQU	0	; warm start return to CP/M
FCB	EQU	5CH	; default FCB address
;
CR	EQU	0DH	; ASCII Carriage return
LF	EQU	0AH	; ASCII line feed
CTRLC	EQU	3	; ASCII control-C
;
;	User-modifiable switches
;
SINGLE	EQU	FALSE	; TRUE for single drive copy program
RSKEW	EQU	FALSE	; TRUE if read interleaving needed
;			; Note: change READTAB if TRUE
DOCOMP	EQU	TRUE	; TRUE if byte-by-byte comparison
;			; desired on read-after-write check
TRSKW	EQU	TRUE 	; TRUE if track skewing is wanted
;			; on non-interleaved reads
;			; (RSKEW MUST be false)
WRSWCH	EQU	FALSE	; TRUE if CP/M 2.2 block/deblock
;			; routines need various values in
;			; reg. C during writes. See WRTAB
;
NUMERR	EQU	4	; number of error retries done
;
BUFFNU  EQU	0	; the number of full track buffers
;	that will fit in your system. This figure includes
;	the space used by the read-back buffers, if used
;	(minimum 2). If zero, the number of buffers will
;	be automatically computed at execution.
;
TSKEW	EQU	6	; Amount of track-to-track skew
;			; (if TRSKW is TRUE and RSKEW is FALSE)
;			; Should be less than SDLAST
;
;	The next two values specify the copy range, and the program
;	can be run in other ways by the parameter (first character
;	of the first filename) given when COPYFAST is first invoked:
;
;	All	0-(Lastrk-1)		Entire disk
;	Data	Firstrk-(Lastrk-1)	CP/M data area
;	First	Firstrk			CP/M directory track 
;	Last	(Lastrk-1)		Last track on disk
;	One	1			Track one, UCSD directory
;	Pascal	1-(Lastrk-1)		UCSD Pascal data area
;	System	0-(Firstrk-1)		CP/M bootstrap
;	Zero	0			Track zero, UCSD bootstrap
;			(Note: only complete tracks are copied)
;	The default range, currently Firstrk to Lastrk-1, is given
;	in the two values at TRKSRT.
;
FIRSTRK EQU	2		; the first data track copied.
;				; The bootstrap is assumed to be
;				; on tracks 0 to Firstrk-1
LASTRK	EQU	77		; the last track copied plus one
;
DIFFTRK	EQU	0		; difference between first source
;				; track and the first object track.
;				; (applies only when default range
;				; is used)
;
SDLAST  EQU	26		; the number of sectors per track
;				; Also determines the lengths of
;				; WRTAB, READTAB, and WRITAB
;
SECSIZ	EQU	128		; number of bytes per sector.
;
WRCODE	EQU	2		; value passed to sector write rtn
;				; in reg. C if WRSWCH is FALSE
	IF	TRSKW AND RSKEW
TRSKW	SET	FALSE		; option is wrong
	ENDIF
;
;	A set of dummy branch points to the CBIOS that are
;	filled in by the VECTOR routine.
;
START:
	JMP	VECTOR		; go initialize the branches
WBOOT:
	JMP	$-$		; not used
CONST:
	JMP	$-$
CONIN:
	JMP	$-$
CONOUT:
	JMP	$-$
LIST:
	JMP	$-$		; not used
PUNCH:
	JMP	$-$		; not used
READER:
	JMP	$-$		; not used
HOME:
	JMP	$-$
SELDIS:
	JMP	$-$
SETRAK:
	JMP	$-$
SETSCT:
	JMP	$-$
SETDMA:
	JMP	$-$
READ:
	JMP	$-$
WRITE:
	JMP	$-$
;
;	Useful constants placed here for finding easily
;	These can be changed using DDT to alter some of
;	the characteristics of the program to suit your
;	taste.
;
TRKSRT:				; default first and last+1 track numbers
;				; Can be changed at run time
	DB	FIRSTRK
	DB	LASTRK
BUFFNMB:			; max. number of buffers
	DB	BUFFNU
SRCTRAK:			; source track - object track
	DB	DIFFTRK
;
;	This  is the point where the program returns to repeat  the
;	copy. Everything is re-initialized.
;
REPEAT:
	LXI	SP,STKTOP	; re-initialize stack
	LXI	D,SOURCE
	CALL	PRINT		; ask for source drive
SRCELU:
	CALL	CONIN		; read response (upper case)
	CPI	CTRLC
	JZ	EXIT		; CTRL-C means abort
	ANI	5FH
	CPI	'A'	;41H
	JC	SRCELU		; bad value - less than A
	CPI	'F'	;46H
	JZ	SETSOU
	JC	SETSOU
	JMP	SRCELU		; bad value - greater than F
SETSOU:
	STA	SRCEME		; save the source drive
	IF	SINGLE
	STA	OBJMES
	ENDIF
	SUI	'A'	;41H
	STA	SRCEDR		; convert value to CP/M number
	LDA	SRCEME
	CALL	CONOUT		; echo value to console
	IF	NOT SINGLE
	LXI	D,OBJECT	; prompt for destination disk
	CALL	PRINT
OBJLUP:				; read response
	CALL	CONIN
	CPI	CTRLC		; CTRL-C means abort
	JZ	EXIT
	ANI	5FH		; convert to upper case
	CPI	'A'	;41H
	JC	OBJLUP		; bad value - less than A
	CPI	'F'	;46H
	JZ	SETOBJ
	JC	SETOBJ
	JMP	OBJLUP		; bad value - greater than F
SETOBJ:
	LXI	H,SRCEME	; Cannot have a one drive copy
	CMP	M
	JZ	OBJLUP
	STA	OBJMES		; save the destination drive
	SUI	'A'	;41H
	STA	OBJDRI		; convert value to CP/M number
	LDA	OBJMES
	CALL	CONOUT		; echo object drive
	LXI	D,SIGNON
	CALL	PRINT		; now give chance to change disks
;				; or give up
AGIN:
	CALL	CONIN		; read response from keyboard
	CPI	CTRLC
	JZ	EXIT		; ctrl-C means quit
	CPI	CR
	JNZ	AGIN 		; CR means go. Ignore anything else
	ENDIF
;
;	now go do it !
;
	LXI	D,CRLF
	CALL	PRINT		; now start actual copy
	CALL	COPY
	LXI	D,DONMSG
	CALL	PRINT		; copy is now done, say so
;
;	end of this copy
;
EXIT:
	LXI	SP,STKTOP	; re-initialize stack
	LDA	SRCEDR		; first, select source drive
	MOV	C,A
	CALL	SELDSK
	CALL	HOME		; home the disk in case
	IF	NOT SINGLE
	LDA	OBJDRI
	MOV	C,A		; now, select destination drive
	CALL	SELDSK
	CALL	HOME		; and home that disk, in case
	ENDIF
	LXI	D,REPMES	; ask if another copy is desired
	CALL	PRINT
	CALL	CONIN		; read response, upper case
	ANI	5FH
	CPI	'R'		; R means repeat
	JZ	REPEAT
	CPI	CR		; carriage return means back to CP/M
	JNZ	EXIT
	MVI	C,0		; set default disk back to A
	CALL	SELDSK
	JMP	EXITCP		; and warmstart back to CP/M
;
;	convert value in A reg. to ASCII hex and print it
;
PRTHEX:
	PUSH	PSW		; save for LSN
	RAR
	RAR			; shift MSN nibble to LSN
	RAR
	RAR
	CALL	PRTNBL		; now print it
	POP	PSW		; and then do LSN
PRTNBL:
	ANI	0FH
	ADI	'0'		;convert to ASCII value
	CPI	'0'+10		; over 9 ?
	JC	SML
	ADI	7		; convert 10 to A, etc.
SML:
	MOV	C,A		; move to C for BDOS call
	CALL	CONOUT
	RET
;
;
;	this is the main copy routine
;
COPY:
	LDA	SRCEDR		; first, select source drive
	MOV	C,A
	CALL	SELDSK
	CALL	HOME		; home the disk first, in case
;				; the controller requires it.
;				; (this might be the first time
;				; the drive has been used)
	LDA	TRKSRT
	CALL	SETTRK		; now start with first track
	IF	NOT SINGLE
	LDA	OBJDRI
	MOV	C,A		; now, select destination drive
	CALL	SELDSK
	CALL	HOME		; and home that disk, in case
	ENDIF
;
;	return here to continue copy
;
RDLOOP:
	LDA	TRK		; note current track
	STA	TRKSAV
	XRA	A		; reset error counter
	STA	CMPERR
	LXI	D,TRKM		; print the current starting track
	CALL	PRINT		; being copied
	LDA	TRKSAV
	CALL	PRTHEX
TRYRDA:
	IF	SINGLE
	LXI	D,SIGNON	; now give operator chance to change disk
	ENDIF
	LDA	SRCEDR		; select source drive
;
;	read  loop
;
	CALL	STARTL		; start the copy loop (reading source)
LOOP1:
	CALL	READT		; read one track
	JZ	LOOP4		; if all tracks read, go check errors
	LDA	ERR1
	ORA	A		; not all done, but see if error already
	JNZ	LOOP1		; and go try another track
;
;	now see if any errors in the previous operations
;
LOOP4:
	LDA	ERR1		; now check if any errors
	ORA	A
	JNZ	RDSKIP		; jump if no errors at all
	MVI	A,10H
	STA	ERR1		; reset error flag
;
;	allow NUMERR errors before giving up
;
	LDA	CMPERR		; check the retry counter
	INR	A
	STA	CMPERR
	CPI	NUMERR		; normally ten retries max
	JNZ	LOOP1	; WAS TRYRDA
	LXI	D,MESGC		; if maximum error count,
	CALL	PRINT		;   print message
	XRA	A
	STA	CMPERR		; full track error, reset error counter
	CALL	ENDLUP
	JNZ	LOOP1		; now bump up track and see if done
;
;	write loop
;
RDSKIP:
	XRA	A		; reset error counter
	STA	CMPERR
TRYAGA:
	IF	SINGLE
	LXI	D,OBJMSG	; give chance to put in object disk
	ENDIF
	LDA	OBJDRI		; now select destination disk
	CALL	STARTL		; start the write loop
LOOP2:
	CALL	WRITET		; write one track (and readback check)
	JZ	LOOP3		; if all tracks written, go check errors
	LDA	ERR1
	ORA	A		; not all done, but see if error already
	JNZ	LOOP2
;
;	now see if any errors in the previous operations
;
LOOP3:
	LDA	ERR1		; now check if any errors
	ORA	A
	JNZ	SKIP		; jump if no errors at all
;
;	allow NUMERR errors before giving up
;
	LDA	CMPERR		; check the retry counter
	INR	A
	STA	CMPERR
	CPI	NUMERR		; normally ten retries max
	JNZ	TRYAGA
	LXI	D,MESGC		; if maximum error count,
	CALL	PRINT		;   print message
	LDA	BUFFNMB
	MOV	H,A
	LDA	TRK		;   and set next track
	INR	A		;   past track in error
	SUB	H
	STA	TRKSAV
;
;	copied all tracks correctly (or NUMERR errors)
;
SKIP:
	LDA	BUFFNMB		; get number of buffers
	MOV	H,A
	LDA	TRKSAV		; bump up track counter
	ADD	H
	STA	TRK
	LXI	H,TRKSRT+1	; see if copy operation is done
	CMP	M
	RNC
	JNZ	RDLOOP		; go back and do more
	RET
;
;	This routine selects the disk,  and initializes the  buffer
;	address,  buffer counter, and track counter,and seeks to the
;	right track.
;
STARTL:
	IF	SINGLE
	CALL	HOME		; Home the disk for a deblocking CBIOS
;				; to get a chance to flush the buffer
	CALL	PRINT		; now give chance to change disks
;				; or give up
AGIN:
	CALL	CONIN		; read response from keyboard
	CPI	CTRLC
	JZ	EXIT		; CTRL-C means quit
	CPI	CR
	JNZ	AGIN 		; CR means go. Ignore anything else
	ENDIF
	IF	NOT SINGLE
	MOV	C,A		; select the disk first
	CALL	SELDSK
	ENDIF
	IF	TRSKW
	XRA	A		; zero out track sector skew
	STA	TSECT
	STA	TBUFF		; zero out coresponding buffer addr
	STA	TBUFF+1
	ENDIF
	LXI	H,BUF0		; load address of first buffer
	SHLD	BUF0SA
	MVI	A,10H		; reset error flag
	STA	ERR1
	LDA	BUFFNMB		; load number of buffers
	STA	BUFFCO
	LDA	TRKSAV		; load first track copied
;
;	set the track to be used, and add offset if source
;	drive. Save track number for error routine.
;
SETTRK:
	STA	TRK		; save current track
	IF	(NOT SINGLE)
	LDA	CURRDI		; check drive
	MOV	C,A
	LDA	SRCEDR		; is it source
	CMP	C
	LDA	TRK		; if object, skip
	JNZ	SETTR0
	MOV	C,A		; now get difference
	LDA	SRCTRAK
	ADD	C		; and do correction
SETTR0:
	ENDIF
	MOV	C,A		; now go set track
	JMP	SETRAK
;
;	set the DMA address (in HL)
;
DMASET:
	MOV	C,L		; move HL to BC
	MOV	B,H
	PUSH	B		; save result and call CBIOS
	CALL	SETDMA
	POP	B
	RET
;
;	these are the disk error handling routines
;
FAILR:
	LXI	D,MESGD		; read error message
	JMP	DIE
FAILW:
	LXI	D,MESGE		; write error message
DIE:
	CALL	PRINT		; print the main error message
	LXI	D,ERM
	CALL	PRINT
	LDA	TRK  		; print the track number
	CALL	PRTHEX
	LXI	D,MESGB		; print sector message
	CALL	PRINT
	LDA	SECTOR		; and print sector
	CALL	PRTHEX
	LXI	D,DRIVE		; print drive message
	CALL	PRINT
	LDA	CURRDI
	ADI	'A'		; convert drive number to ASCII
	MOV	C,A
	CALL	CONOUT		; and finally print drive
	XRA	A
	STA	ERR1 		; note the error so this track is retried
	CALL	CONST
	ORA	A		; see if any console input present
	JZ	ENDLUP
	CALL	CONIN		; yes, see if aborting
	CPI	CTRLC
	JZ	EXIT		; die if CTRL-C was hit
	JMP	ENDLUP
;
;	read the full track now, no interleaving
;
READT:
	CALL	CONST
	ORA	A		; see if any console input present
	JZ	READT0
	CALL	CONIN		; yes, see if aborting
	CPI	CTRLC
	JZ	EXIT		; die if CTRL-C was hit
READT0:
	IF	(NOT RSKEW) AND (NOT TRSKW)
	LHLD	BUF0SA		; first, get beginning of buffer
	SHLD	DMAAD
	ENDIF
	IF	TRSKW
	LHLD	BUF0SA		; first, get beginning of buffer
	XCHG
	LHLD	TBUFF		; and correct for skew
	DAD	D
	SHLD	DMAAD
	LDA	TSECT		; initialize first sector
	MOV	C,A
	ENDIF
	IF	(NOT TRSKW)
	MVI	C,0		; initialize first sector
	ENDIF
	MVI	B,SDLAST	; initialize sector count
RT3:
	IF	TRSKW
	MOV	A,C		; check for skew too big
	CPI	SDLAST
	JC	RT4		; jump if sector within range
	XRA	A
	MOV	C,A		; out of range, back to sector 1
	LHLD	BUF0SA
	SHLD	DMAAD
RT4:
	ENDIF
	IF	RSKEW
	INR	C		; increment sector counter
	PUSH	B
	LXI	H,READTAB-1	; find the interleaved sector number
	MVI	B,0
	DAD	B		; using the READTAB
	MOV	C,M
	CALL	SETSEC		; and set the sector
	MVI	H,0
	DCR	C		; now compute the buffer location
	MOV	L,C
;
	DAD	H		; corresponding to that sector
	DAD	H
	DAD	H		; by multiplying by 128
	DAD	H
	DAD	H		; The number of DAD H instructions
	DAD	H		; MUST correspond to the buffer size
	DAD	H		; i.e. 7 DADs means 128 byte (2^7)
;
	XCHG
	LHLD	BUF0SA		; and then adding to the buffer start
	DAD	D
	CALL	DMASET		; set the DMA and do the read
	ENDIF
	IF	(NOT RSKEW)
	INR	C		; increment sector counter
	PUSH	B
	CALL	SETSEC		; set the sector
	LHLD	DMAAD
	CALL	DMASET		; set the DMA
	LXI	H,SECSIZ
	DAD	B		; bump up the DMA for next time
	SHLD	DMAAD
	ENDIF
	CALL	READ		; now read one sector
	RAR
	CC	FAILR		; if returned 01, read error
	POP	B
	DCR	B		; see if all sectors read
	JNZ	RT3
	IF	TRSKW
	LHLD	TBUFF		; bump up skewed buffer
	LXI	D,SECSIZ*TSKEW
	DAD	D		; add the skew
	SHLD	TBUFF
	LDA	TSECT		; now bump starting sector
	ADI	TSKEW
	STA	TSECT		; and put it back
	SBI	SDLAST
	JC	ENDLUP		; jump if sector within range
	STA	TSECT
	LHLD	TBUFF
	LXI	D,-SDLAST*SECSIZ; correct sector start and
	DAD	D
	SHLD	TBUFF		;  buffer skew address
	ENDIF
	JMP	ENDLUP		; return with complete track read
;
;	Write the full track,  with interleaving,  and then check it
;	by reading it all back in.
;
WRITET:
	CALL	CONST
	ORA	A		; see if any console input present
	JZ	WRITE0
	CALL	CONIN		; yes, see if aborting
	CPI	CTRLC
	JZ	EXIT		; die if CTRL-C was hit
WRITE0:
	LHLD	BUF0SA		; first, get the beginning of buffer
	SHLD	DMAAD
	MVI	C,0
	MVI	B,SDLAST	; initialize sector counter
WT3:
	PUSH	B
	LXI	H,WRITAB	; find the interleaved sector number
	MVI	B,0
	DAD	B		; using the WRITAB
	MOV	C,M
	CALL	SETSEC		; and set the sector
	MVI	H,0
	DCR	C		; now compute the buffer location
	MOV	L,C
;
	DAD	H		; corresponding to that sector
	DAD	H
	DAD	H		; by multiplying by 128
	DAD	H
	DAD	H		; NOTE: see comments in RT3 for
	DAD	H		; changing this code for other
	DAD	H		; than 128 byte sectors
;
	XCHG
	LHLD	DMAAD		; and then adding to the buffer start
	DAD	D
	CALL	DMASET		; set the DMA and do the write
	IF	NOT WRSWCH
	MVI	C,WRCODE	; value for CP/M 2.2 routine
	ENDIF
	IF	WRSWCH
	POP	B		; get sector number
	PUSH	B
	LXI	H,WRTAB-1	; find the C reg. value for this
	MVI	B,0
	DAD	B		; sector using the WRTAB
	MOV	C,M
	ENDIF
	CALL	WRITE
	RAR			; if 01 returned, write error
	CC	FAILW
	POP	B
	INR	C		; increment sector count
	DCR	B
	JNZ	WT3		; and loop back if not done
	IF	DOCOMP AND (NOT RSKEW)
	LXI	H,BUF1		; first, get beginning of buffer
	SHLD	DMAAD
	ENDIF
	MVI	C,0
	MVI	B,SDLAST	; reinitialize sector counts for read
WT4:
	INR	C		; bump up sector counter
	PUSH	B
	IF	RSKEW
	LXI	H,READTAB-1	; find the interleaved sector number
	MVI	B,0
	DAD	B		; using the READTAB
	MOV	C,M
	CALL	SETSEC		; and set the sector
	ENDIF
	IF	RSKEW AND DOCOMP
	MVI	H,0
	DCR	C		; now compute the buffer location
	MOV	L,C
	DAD	H		; corresponding to that sector
	DAD	H
	DAD	H		; by multiplying by 128
	DAD	H
	DAD	H		; (2 ^ 7 = 128)
	DAD	H
	DAD	H
	XCHG
	LXI	H,BUF1		; and then adding to the buffer start
	DAD	D
	CALL	DMASET		; now set the read buffer
	ENDIF
	IF	(NOT RSKEW) AND DOCOMP
	CALL	SETSEC		; set the sector
	LHLD	DMAAD
	CALL	DMASET		; set the DMA
	LXI	H,SECSIZ
	DAD	B		; bump up the DMA for next time
	SHLD	DMAAD
	ENDIF
	IF	RSKEW AND (NOT DOCOMP)
	LXI	H,BUF1		; load the buffer address
	CALL	DMASET		; and set the read buffer
	ENDIF
	IF	(NOT RSKEW) AND (NOT DOCOMP)
	CALL	SETSEC		; now set the sector
	LXI	H,BUF1
	CALL	DMASET		; and set the read buffer
	ENDIF
	CALL	READ
	RAR			; was bit 0 set by disk error?
	CC	FAILR
	POP	B		; no error, see if all sectors read
	DCR	B
	JNZ	WT4		; if not all done, go back
	IF	DOCOMP
	LXI	B,SECSIZ*SDLAST	; now, compare the track read in
	LHLD	BUF0SA
	LXI	D,BUF1
CMPLP:	LDAX	D		; get read data
	CMP	M
	JNZ	CERR		; and if not what was written, error
	INX	H
	INX	D		; bump counters
	DCX	B
	MOV	A,C		; and count BC down to zero
	ORA	B
	JNZ	CMPLP		; if all done, return
	JMP	ENDLUP
;
;	print read verify compare error
;
CERR:	PUSH	H		; save the goodies
	PUSH	D
	PUSH	B
	LXI	D,MESGA		; start the error message
	CALL	PRINT
	LDA	TRK		; print the track number
	CALL	PRTHEX
	LXI	D,MESGB		; print more
	CALL	PRINT
	POP	H		; pop the down counter
	DCX	H
	DAD	H		; multiply by 2 to get sectors left
	MVI	A,SDLAST
	SUB	H		; subtract from total number of sectors
	CALL	PRTHEX		; to get sector number, and print it
	LXI	D,MEM
	CALL	PRINT		; print second line
	POP	H
	MOV	A,M		; get byte read
	STA	DATA1		; and save it
	PUSH	H
	MOV	A,H		; print high order byte of address
	CALL	PRTHEX
	POP	H
	MOV	A,L		; print low order byte of address
	CALL	PRTHEX
	MVI	C,','
	CALL	CONOUT		; comma
	POP	H
	MOV	A,M		; get byte written
	STA	DATA2		; and save it
	PUSH	H
	MOV	A,H		; print high order byte of address
	CALL	PRTHEX
	POP	H
	MOV	A,L		; print low order byte of address
	CALL	PRTHEX
	LXI	D,DATAM		; print data header
	CALL	PRINT
	LDA	DATA1		; print byte read
	CALL	PRTHEX
	MVI	C,','		; comma
	CALL	CONOUT
	LDA	DATA2		; print byte written
	CALL	PRTHEX
	XRA	A
	STA	ERR1		; note the error so this track is retried
	ENDIF
;
;	This  routine  is  used to check if another track is  to  be
;	read/written:   it   increments  buffer  address  and  track
;	counter,   and  decrements  the  buffer  counter.  Then,  it
;	terminates  the  loop if all buffers are full  or  the  last
;	track has been processed (Z flag set).
;
ENDLUP:
	LDA	ERR1		; now check if any errors
	ORA	A		; and return if so
	RZ
	LDA	TRK		; increment track
	INR	A
	LXI	H,TRKSRT+1	; check if last track
	CMP	M
	RZ			; return if last track
	CALL	SETTRK
	LXI	H,BUFFCO	; decrement buffer counter
	DCR	M
	RZ			; return if all buffers full/empty
	LXI	D,SECSIZ*SDLAST
	LHLD	BUF0SA		; increment buffer address
	DAD	D
	SHLD	BUF0SA
	ORI	255		; non-zero to indicate more
	RET	
;
;	this  routine  writes  messages  to  the  console.  Message
;	address  is in DE,  and terminates on a $.  The BDOS call is
;	not  used  here because BDOS may be destroyed by  the  track
;	buffers
;
PRINT:
	LDAX	D		; get the character
	CPI	'$'	;24H
	RZ			; quit if $
	PUSH	D
	MOV	C,A		; send it to the console
	CALL	CONOUT
	POP	D		; go check next character
	INX	D
	JMP	PRINT
;
;	set the next sector to be used, and save that
;	number for the error routine, in case
;
SETSEC:
	MOV	A,C		; save the sector number
	STA	SECTOR
	PUSH	B		; save regs, in case
	CALL	SETSCT		; now go set the sector
	POP	B
	RET
;
;	set the disk to be used, and save that
;	for the error routine, in case
;
SELDSK:
	MOV	A,C		; save the disk number
	STA	CURRDI
	JMP	SELDIS		; now select the disk
;
;	all messages here for convenience in disassembling
;
DONMSG:
	DB	CR,LF,'*** COPY COMPLETE ***$'
DRIVE:
	DB	', DRIVE $'
ERM:
	DB	CR,LF,'+ ERROR ON TRACK (HEX)$'
MESGB:
	DB	' SECTOR (HEX)$'
MESGC:
	DB	CR,LF,'++PERMANENT $'
MESGD:
	DB	CR,LF,'+ READ ERROR $'
MESGE:
	DB	CR,LF,'+ WRITE ERROR $'
SIGNON:
	DB	CR,LF,'SOURCE ON '
SRCEME:
	DB	0			; will be filled in later
	IF	NOT SINGLE
	DB	': OBJECT ON '
OBJMES:
	DB	0			; will be filled in later
	DB	':'
	ENDIF
SINOFF:
	DB	CR,LF,'TYPE <RET> TO CONTINUE, OR CONTROL-C TO EXIT: $'
	IF	SINGLE
OBJMSG:
	DB	CR,LF,'OBJECT ON '
OBJMES:
	DB	0			; will be filled in later
	DB	':'
	DB	CR,LF,'TYPE <RET> TO CONTINUE, OR CONTROL-C TO EXIT: $'
	ENDIF
REPMES:
	DB	CR,LF,'TYPE <RET> OR "R", TO REPEAT COPY: $'
CRLF:
	DB	CR,LF,'$'
SOURCE:
	DB	CR,LF,'SOURCE DRIVE (A THRU F): $'
	IF	NOT SINGLE
OBJECT:
	DB	CR,LF,'OBJECT DRIVE (A THRU F): $'
	ENDIF
TRKM:
	DB	CR,LF,'COPYING TRACK $'
;
	IF	DOCOMP
MESGA:
	DB	CR,LF,'+ MEMORY COMPARE ERROR ON TRACK (HEX)$'
MEM:
	DB	CR,LF,'+ MEMORY ADDRESS $'
DATAM:
	DB	' (OBJ,SRC)   DATA  $'
	ENDIF
;
;	 This  is  the  sector interleave table.  If  you  want  the
;	program to work,  all sector numbers must be here somewhere.
;
WRITAB:
;
;	Interleave table for very fast controllers
;
	DB	25,26,1,2,3,4,5,6,7,8,9,10,11,12
	DB	13,14,15,16,17,18,19,20,21,22,23,24
;
;
	IF	WRSWCH
;
;	This is the write switch table. The values in this table
;	are passed to the sector write routine of CP/M 2.2 in
;	reg. C when each write occurs. This table is modified if
;	and only if some particular pattern is needed for your
;	blocking routine to work as fast or as well as possible.
;	Refer to the CP/M 2.2 Alteration Guide for more details.
;
WRTAB:
	DB	2,2,2,2,2,2,2,2,2,2,2,2,2
	DB	2,2,2,2,2,2,2,2,2,2,2,2,2
	ENDIF
;
	IF	RSKEW
;
;	 This  is the read skew table,  if needed.  The same general
;	considerations as the write skew table apply here also,  but
;	the table should start with sector 1.  Both the read and the
;	read-after write use this table.  As you can see,  the write
;	and read interleaving doesn't have to be the same.
;
READTAB:
	DB	1,3,5,7,9,11,13,15,17,19,21,23,25
	DB	2,4,6,8,10,12,14,16,18,20,22,24,26
	ENDIF
;
;	This is the initialization code, and occupies the lowest area
;	of the stack, and may be clobbered by the stack during operation,
;	but it is used only once. (The stack is about 32 bytes long)
;
VECTOR:
	LHLD	1		; get bottom of CBIOS
	MOV	B,H
	LXI	D,SECSIZ*SDLAST	; get size of buffers
	LXI	H,BUF0		; start checking where buffer starts
VECT0:
	DAD	D		; add buffer size to buffer addr
	MOV	A,H
	CMP	B		; check hi order byte if high
	JZ	VECT1		; or equal
	JNC	VECT1
	LDA	BUFTMP		; buffer fits, add one to count
	INR	A
	STA	BUFTMP		; and store
	JMP	VECT0
;
;	the stack
;
	DS	8
STKTOP:
	DB	0
;
;	variables
;
BUF0SA:				; buffer address
	DB	0,0
TRKSAV:				; track save area during read and write
	DB	0
BUFFCO:				; buffer counter
	DB	0
CMPERR:				; number of disk errors
	DB	0
TRK:				; current track
	DB	0
SRCEDR:				; source drive
	IF	NOT SINGLE
	DB	0
	ENDIF
OBJDRI:				; destination drive
	DB	0
CURRDI:				; drive for current operation
	DB	0
DMAAD:				; DMA address for current operation
	DB	0,0
ERR1:				; error flag (0 = error)
	DB	0
SECTOR:				; sector number for current operation
	DB	0
;
	IF	TRSKW
TSECT:
	DB	0		; skewed sector start for track
TBUFF:
	DB	0,0		; skewed buffer address
	ENDIF
;
;	the track buffers. BUFEND must not overlay the BIOS !
;
;	BUF1 is where the read-after-write is performed
;
	IF	DOCOMP
DATA1:
	DS	1		; used in compare
DATA2:
	DS	1
BUF1:
	DS	SECSIZ*SDLAST	; space for a full track read
	ENDIF
;
	IF	NOT DOCOMP
BUF1:
	DS	SECSIZ		; just one sector for CRC only
	ENDIF
;
;	BUF0 is where all input tracks are read
;	Tho space for only one track is allocated here,
;	the program will use BUFFNU track buffers, or
;	up to the CBIOS, whichever is smaller
;
BUF0:	DS	SECSIZ*SDLAST
;
	ORG	BUF1
;
;	This is one-time code to initialize the branch table to
;	the CBIOS vectors. Only those vectors used are initialized.
;	Placed here so that it wont get clobbered by the stack
;
VECT1:
	LHLD	1		; get warm boot address
	SPHL			; and save it in SP for DAD
	LXI	H,3
	DAD	SP
	SHLD	CONST+1
;
	LXI	H,6
	DAD	SP
	SHLD	CONIN+1
;
	LXI	H,9
	DAD	SP
	SHLD	CONOUT+1
;
	LXI	H,15H
	DAD	SP
	SHLD	HOME+1
;
	LXI	H,18H
	DAD	SP
	SHLD	SELDIS+1
;
	LXI	H,1BH
	DAD	SP
	SHLD	SETRAK+1
;
	LXI	H,1EH
	DAD	SP
	SHLD	SETSCT+1
;
	LXI	H,21H
	DAD	SP
	SHLD	SETDMA+1
;
	LXI	H,24H
	DAD	SP
	SHLD	READ+1
;
	LXI	H,27H
	DAD	SP
	SHLD	WRITE+1
;
;	Now check what kind of copy is wanted
;
	LXI	SP,STKTOP	; initial stack
	LXI	D,INIT
	CALL	PRINT		; start program
	LHLD	TRKSRT
	LDA	FCB+1		; get character of parameter
	ANI	5FH
	CPI	0		; check for default
	JZ	COPYDEF
	MOV	B,A
	XRA	A		; no track shift
	STA	SRCTRAK
	MOV	A,B
	CPI	'A'		; check for All
	JZ	COPYALL
	CPI	'D'		; check for Data
	JZ	COPYDAT
	CPI	'F'		; check for First
	JZ	COPYFIR
	CPI	'L'		; check for Last
	JZ	COPYLAS
	CPI	'O'		; check for One
	JZ	COPYONE
	CPI	'P'		; check for Pascal
	JZ	COPYPAS
	CPI	'S'		; check for System
	JZ	COPYSYS
	CPI	'Z'		; check for Zero
	JZ	COPYZER
	LXI	D,CALLERR	; got a bad value
	CALL	PRINT
	JMP	EXITCP
COPYALL:
	MVI	H,LASTRK	; All
	MVI	L,0
	JMP	COPYDEF
COPYDAT:
	MVI	H,LASTRK	; Data
	MVI	L,FIRSTRK
	JMP	COPYDEF
COPYFIR:
	MVI	H,FIRSTRK+1	; First
	MVI	L,FIRSTRK
	JMP	COPYDEF
COPYLAS:
	MVI	H,LASTRK	; Last
	MVI	L,LASTRK-1
	JMP	COPYDEF
COPYONE:
	MVI	H,2		; One
	MVI	L,1
	JMP	COPYDEF
COPYPAS:
	MVI	H,LASTRK	; Pascal
	MVI	L,1
	JMP	COPYDEF
COPYSYS:
	MVI	H,FIRSTRK	; System
	MVI	L,0
	JMP	COPYDEF
COPYZER:
	MVI	H,1		; Zero
	MVI	L,0
;
;	The one time finish - up routine
;
COPYDEF:
	SHLD	TRKSRT
	LXI	D,BGMES1	; Now print message giving copy range
	CALL	PRINT
	LDA	TRKSRT
	CALL	PRTHEX		; print first track
	LXI	D,BGMES2
	CALL	PRINT
	LDA	TRKSRT+1	; print last track
	DCR	A
	CALL	PRTHEX
	LDA	BUFFNMB		; load desired buffer number
	ORA	A
	JZ	VECT3		; if no autosize, put in
	IF	DOCOMP
	DCR	A		; subtract one for compare buffer
	STA	BUFFNMB
	ENDIF
	LXI	H,BUFTMP
	CMP	M		; compare against number found
	JZ	VECT2
	JC	VECT2		; branch if smaller
	LXI	D,BUFERR
	CALL	PRINT		; print out error msg
	LDA	BUFTMP
	CALL	PRTHEX		; print out buffer number
VECT3:
	LDA	BUFTMP
	STA	BUFFNMB		; put in smaller buffer number
VECT2:
	LXI	H,REPEAT	; go to mainline code now
	SHLD	START+1
	PCHL
;
BUFTMP:	DB	0		; temporary storage for buffer counter
INIT:
	DB	CR,LF,'FAST DISKETTE COPY PROGRAM, VER. 3.5$'
BUFERR:
	DB	CR,LF,'CP/M IS TOO SMALL - BUFFER SPACE REDUCED: $'
CALLERR:
	DB	CR,LF,'INVALID PARAMETER .. VALID COPYFAST PARAMETERS ARE'
	DB	CR,LF,'ALL, DATA, FIRST, LAST, ONE, PASCAL, SYSTEM, ZERO$'
BGMES1:
	DB	CR,LF,'COPYING FROM TRACK $'
BGMES2:
	DB	' TO TRACK $'
;
;
	END
