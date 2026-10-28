	public chain ; (char(12))
	extrn	?signal
			; /* loads another COM file, and executes it */
bdos	equ	5
openf	equ	15
readf	equ	20
dmaf	equ	26

	cseg
chain:
	mov e,m ! inx h ! mov d,m ! xchg	; get first arg address
	lxi d,fcb ! mvi c,12 ! call move	; move string to fcb
	lxi d,fcb+12 ! mvi a,0 ! mvi c,21 ! call fill	
						; zero rest of fcb
	lhld bdos+1 ! lxi b,-code$len ! dad b	; make space at top of TPA
	shld jmpr+1				; jump address 
	push h					; save code address for RET
	xchg ! lxi h,fcb-code ! dad d		; make address of FCB
	shld FCBR+1				; and fix LXI
	push h					; save FCB destination address
	lxi h,code ! mvi c,code$len ! call move	; dest. in DE
	pop d					; recover address of FCB
	mvi c,openf ! call BDOS			; open file
	inr a ! jz sig				; if any error, signal error
	pop h ! sphl ! push h			; point stack to top of TPA 
						; and save code addr
	lxi h,100h				; point to start of TPA
	ret
code:
	push h ! xchg ! mvi c,dmaf ! call BDOS	; set the DMA address
FCBR:	lxi d,$-$ ! mvi c,readf ! call BDOS	; read the next record
	ora a ! jnz 100h			; EOF -> start TPA
	pop h ! lxi d,128 ! dad d		; recover and bump DMA address
jmpr:	jmp $-$					; jump to code


FCB:
	ds	1				; drive code
	ds	8				; file name
	ds	3				; file type
	ds	4				; control info
	ds	16				; disk map
	ds	1				; rrec
codelen	equ	$-code

						; c  = # bytes
						; hl = source
move:						; de = destination
	mov a,m ! stax d
	inx h ! inx d ! dcr c
	jnz move
	ret

						; c = # bytes
						; d = start addr
fill:						; a = byte to fill
	stax d ! inx d
	dcr c ! jnz fill
	ret

sig:
	lxi h,siglist ! call ?signal ! jmp 0	; signal error

siglist:					; (fixed(6),bit(8),ptr,ptr)
	dw sigcode,sigsub,sigfil,message

sigcode db	6				; undefined file error
sigsub	db	2				; arbitrary subcode for id
sigfil	dw	fpb				; ptr to file parameter block
message	dw	quack				; auxiliary operator message
	
fpb:						; PL/I file parameter block

fcbptr	dw	FCB-1				; .fcb-1
fpblst  dw	0				; (unused) ptr
column  dw	0				; current column fixed(15)
curline dw	0				; current line     "
curpage dw      0				; current page     "
currec	dw	0 				; (unused)         "
lookchr	db	0				; lookahead char char(1)
ioend   dw	0				; i/o end address
iostk	dw	0				; user stack upon sio entry
spacer	ds	4				; spacer
linesz	dw	0				; line size fixed(15)
pagesz	dw	0				; page size   "
fixedsz	dw	0				; fixed size  "
blocksz	dw	0				; block size  "
filedes	dw	0				; file descriptor
dtitle	db	0,''        			; default title 
						;   char(14) varying

quack	db	17,'Bad Chain Attempt',0	; error message



