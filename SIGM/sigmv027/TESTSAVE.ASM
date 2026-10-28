
Title 'DISAVE - Cpm Utility to save gcp image to disk     12/30/80'
;---------------------------------------------------------
; ISAVE.HEX is a selective save program that loads into
;	low core and prompts the user for the address
;	range and start address of the image to be stored 
;	on disk.  
;
;	The first block on the disk is the program download
;	command that will be sent to the GCP to download this
;	image.  Its image is as follows:
;
;	length byte of command (6)
;	download opcode (either 7 or 7*4)
;	download program id (1). This is not used but added for
;	   compatibility with downloaded code.
;	download program address (2 bytes) Specifies load address
;	   in the GCP.
;	Download program length (2 bytes) Specifies length of
;	    program to be downloaded.
;
;	Length count for execution command (usually 3)
;	Execute command opcode (16 or 16*4)
;	execute program id (1)
;	Execution address (2 bytes)
;
;
;
;	The second and subsequent blocks
;	are the memory image.
;
;	The file will always be saved as GCPMON .COM
;
;       This version of iload is altered to omit the request
;       for the start execution command.  This command
;       will be given from the iload program at the time
;       the diagnostic subroutine is called.
;
;---------------------------------------------------------
	cr	equ	0dh
	lf	equ	0ah
	@bdos	equ	0005h
	pgmcmd	equ	7*4		;opcode specifing download
	execcmd	equ	16*4		;opcode specifing program execute

page
;aseg
	ORG	100H
START:
	LXI	SP,STK		;SET STACKPOINTER
	LXI	D,FCB
	MVI	C,0FH		;OPEN CODE
	call	@bdos
	ANI	0FCH		;XXXX XX..
	JZ	OPENOKŠ	;----------------------------------
	; OPENFAILED  TRY A MAKE
	;----------------------------------
	LXI	D,FCB
	MVI	C,16H		;MAKEA FILE
	call	@bdos
	ANI	0FCH		;XXX XX..
	JZ	OPENOK
	;----------------------------------
	; CAN'T OPEN OR MAKE TTHE FILE
	; TELL SOMEONE
	;----------------------------------
	lxi	d,msg1
	mvi	c,9
	call	@bdos
	;--------------------------------------
	; reboot
	;--------------------------------------
	mvi	c,0
	call	@bdos
	jmp	0
;----------------------------------------------
; openok.... transfer alllto disk
;----------------------------------------------
openok:
	;------------------------------------
	; Get start address
	;------------------------------------
	lxi	d,starmsg
	mvi	c,9
	call	@bdos
	call	getaddr
	shld	addr1
	;-------------------------------------
	; Get end address
	;-------------------------------------
	lxi	d,endmsg
	mvi	c,9
	call	@bdos
	call	getaddr
	shld	addr2

	jmp	wrtb0		;go write block 0
starmsg:	
	db	cr,lf,'Start address....$'
endmsg:
	db	cr,lf,'End address.....$'
;---------------------------------------------------
;
;   Write out the first block to disk. it contains 
;	the three data addresses.
;---------------------------------------------------
wrtb0:
	;-----------------------------------
	; Calculate lengthŠ	;----------------------------------
	lhld	addr1		;get start address in de
	xchg
	lhld	addr2		;get stop address
	call	sub16
	jc	ouch		;overflow
	inx	h		;add one for last byte
	shld	addr4
	jmp	wrthdr		;go write header

ouch:	lxi	d,oflow
	mvi	c,9
	call	@bdos
	mvi	c,0
	call	@bdos
	jmp	0
oflow:
	db	cr,lf,'End address less than start$'
	;-----------------------------------
	; Write out header block
	;----------------------------------
wrthdr:
	lxi	d,header
	mvi	c,1ah		;set dma address
	call	@bdos

	lxi	d,fcb
	mvi	c,15h		;write???
	call	@bdos
	ora	a
	jnz	wrterr

	lhld	addr1		;get start address
	shld	wrtaddr		;save original write add
wrtloop:
	lhld	wrtaddr
	xchg
	mvi	c,1ah		;set DMA address
	call	@bdos

	lhld	wrtaddr
	lxi	d,128
	dad	d
	shld	wrtaddr		;set up for next one

	lxi	d,fcb
	lxi	b,15h		;do a write
	call	@bdos

	ora	a
	jnz	wrterr		;go to write error msg
	;-----------------------------------------------
	; Drop the count by the length, if less than zero 
	; we are done.
	;-----------------------------------------------Š	lhld	addr4
	lxi	d,128
	call	sub16
	jc	endit

	shld	addr4
	jmp	wrtloop
	;--------------------------------------
	; error condition
	; on write
	;---------------------------------------
wrterr:	lxi	d,msg2
	mvi	c,9
	call	@bdos
	mvi	c,0
	call	@bdos
;------------------------------------------------
; close the file
;-------------------------------------------------
endit:
	lxi	d,fcb
	mvi	c,10h		;close
	call	@bdos
	ani	0fch
	jz	endok
	;-----------------------------------------
	; didn't close successfully
	;------------------------------------------
	lxi	d,msg3
	mvi	c,9
	call	@bdos
	mvi	c,0
	call	@bdos
	jmp	0
;------------------------------------------------
; all done successfully
;
;------------------------------------------------
endok:
	lxi	d,msg4
	mvi	c,9
	call	@bdos
	
	mvi	c,0
	call	@bdos
	jmp	0
;------------------------------------------------------------
; The following is used to get a four byte hex address.
; when successfully asseembled, it is returned in the
; HL register pair.
;-------------------------------------------------------------
getaddr:
	lxi	d,gomsg
	mvi	c,9
	call	@bdosŠ
	lxi	h,0
	push	h

	mvi	c,1
	call	@bdos

	call	nibble
	jc	badchar

	rlc
	rlc
	rlc
	rlc
	pop	h
	mov	h,a
	push	h

	mvi	c,1
	call	@bdos
	call	nibble
	jc	badchar
	pop	h
	ora	h
	mov	h,a
	push	h

	mvi	c,1
	call	@bdos
	call	nibble
	jc	badchar

	pop	h
	rlc
	rlc
	rlc
	rlc
	mov	l,a
	push	h

	mvi	c,1
	call	@bdos
	call	nibble
	jc	badchar
	pop	h
	ora	l
	mov	l,a
	ret
badchar:
	pop	h
	jmp	getaddr
gomsg:	db	cr,lf,'       enter 4 digit hex address:$'

nibble:
	sui	'0'Š	rc
	adi	0e9h
	rc
	adi	6
	jp	nio
	adi	7
	rc
nio:	adi	10
	ora	a
	ret
;---------------------------------------------
; Subtract 16 bit DE from 16 bit HL leaving
; result in HL
;---------------------------------------------
sub16:
	mov	a,l
	sub	e
	mov	l,a
	mov	a,h
	sbb	d
	mov	h,a
	ret

;------------------------------------------------------------
; The following is the header block.  It is an image of the
; download and the execute command that will be sent to
; cause the rest of the code in the file to download
;------------------------------------------------------------
header:
	db	6		;length of download command
	db	pgmcmd		;download opcode
	db	1		;dummy program id
addr1:	dw	0		;start of image location
addr4:	dw	0		;calculated length of image

	
	db	0		;length of execute command
	db	0      		;command opcode
	db	1		;dummy program id
addr3:	dw	0		;execution start address

	db	0,0,0
addr2:	dw	0		;hold area for stop address

wrtaddr: dw	0		;write address hold

msg1:	db	'Open file failed',cr,lf,'$'
msg2:	db	'Write file failed',cr,lf,'$'
msg3:	db	'Close failed',cr,lf,'$'
msg4:	db	cr,lf,'GCPMON .COM file created',cr,lf,'$'

fcb:	db	0,'GCPMON  COM'
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0Š	db	0,0,0,0,0,0,0,0
stak:	ds	40h
stk:	db	0

	end	start

