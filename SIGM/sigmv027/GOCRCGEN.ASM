title 'GOCRCGEN - Cpm utility to download code to GCP		02/12/81'
;---------------------------------------------------------
;GOCRCGEN.COM is a special load program used to get a 
;	copy of the GCP code that resides on disk, 
;	Download it to the GCP boot for storage in RAM
;	and then give it control.  The first block
;	on disk is a header block that contains the
;	download commands to download, and then execute
;	downloaded code. Format of this block is as follows:
;
;	Modiified by D.C.Barrick 810206
;                 by D.A.STEELE  12 FEB 81
;	Length byte of command (6)
;	Download opcode (either 7 or 7*4)
;	Download program id (1). This is not used but added for
;	   compatibility with downloaded code.
;	Download program address (2 bytes) Specifies load address
;	   in the GCP.
;	Download program length (2 bytes) Specifies length of
;	    program to be downloaded.
;
;	Length count for execution command (usually 3)
;	Execute command opcode (16 or 16*4)
;	Execute program id (1)
;	Execution address (2 bytes)
;
;
;
;	The second and subsequent blocks
;	are the memory image.
;
;	The file is always  saved as CRCGEN.COM 
;	and is assumed to be on the A: drive.
;
;---------------------------------------------------------
	cr	equ	0dh
	lf	equ	0ah
	@bdos	equ	0005h

page
;--------------------------------------------------------
; The following equates establish the linkage between
; the program in the TPA and the special GCP routines
; hidden in the BIOS
;--------------------------------------------------------

msize	equ	62		; This should be set to system RAM size
				; Note: This BIOS requires 2k more than the
				; standard CP/M BIOS. Therefore the CCP/BDOS
				; routines must be located 2k lower than normal.
				; This is automactically accomplished by the 
				; MOVCPM.COM supplied with InterSystems
				; CP/M package. For example:
				; MOVCPM 64 *    will create a CCP/BDOS
				; which starts at DC00h instead of E400h.Šbias	equ	(msize-22)*1024
ccp	equ	3400h+bias	; base of CCP
bdos	equ	ccp+806h	; base address of BDOS (about 7k below the BIOS)
bios	equ	ccp+1600h	; base address of BIOS (basic input/output system)

gxo	equ	bios+51		; routine for transparent send to the GCP (char in <C>).
dmawrt	equ	bios+69		; routine to do DMA write to GCP
				; <BC> has length, <DE> has data address

page
	aseg
	ORG	100H
START:
	; save CP/M's stack

	di
	lxi	h,0
	dad	sp
	shld	OLD$STACK
	lxi	sp, USER$STACK
	ei
 
	LXI	D,FCB
	MVI	C,0FH		;OPEN CODE
	CALL	@bdos
	ANI	0FCH		;XXXX XX..
	JZ	OPENOK
	;----------------------------------
	; The file CRCGEN.COM  doesn't exist, Tell someone and 
	; then exit.
	;----------------------------------
	lxi	d,msg1
	mvi	c,9
	call	@bdos
	;--------------------------------------
	; return to CP/M
	;--------------------------------------
	jmp	return
openok:
;---------------------------------------------------------
; Read in the header block
;-----------------------------------------------------------
	lxi	d,header
	mvi	c,1ah		;set dma address
	call	@bdos

	lxi	d,fcb
	mvi	c,20		;read in header
	call	@bdos
	ani	0FCh		;ignore low two bits as error
	ora	a
	jnz	rderr

;-----------------------------------------------------------
; CRCGEN file has been opened and it's header block read intoŠ; memory.  Send the program download command and then 
; start the actual reads and DMA transfers.
;----------------------------------------------------------

	lxi	h,header
	call	send		;send to GCP
	shld	execadd		;save execute command address

	lxi	d,rdbuffer
	mvi	c,1ah		;set DMA address for data
	call	@bdos
rdloop:
	lxi	d,fcb
	mvi	c,20		;read a block
	call	@bdos
	ani	0FCh		;ignore read type bits
	ora	a
	jnz	rderr		;go to write error msg
	;-----------------------------------------------
	; Drop the count by 128, if less than zero 
	; we must do a residual dma write, if new length is
	; zero, we must send a full 128 and then stop
	;-----------------------------------------------
	lhld	addr4
	lxi	d,128
	call	sub16
	jc	partial

	;---------------------------------------------------
	; Must have been 128 or greater so DMA 128 bytes
	;---------------------------------------------------
	shld	addr4
	lxi	b,128		;DMA length
	lxi	d,rdbuffer	;address
	call	dmawrt

	;----------------------------------
	; Now see if done. i.e. new length of zero
	;-----------------------------------
	lhld	addr4
	mov	a,l
	ora	h
	jz	endit

	jmp	rdloop		;more
	;--------------------------------------
	; error condition
	; on write
	;---------------------------------------
rderr:	lxi	d,msg2
	mvi	c,9
	call	@bdos
	mvi	c,0
	call	@bdos
;----------------------------------------------Š; All done except for the last short block
;-----------------------------------------------
partial:
	lhld	addr4		;get the partial buffer count
	mov	b,h
	mov	c,l
	lxi	d,rdbuffer
	call	dmawrt

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
	jmp	return
;------------------------------------------------
; all done successfully
;
;	send the start execution code
;------------------------------------------------
endok:
	lhld	execadd		;restore execute command address & send
	call	send

;------------------------------------------------
; wait a while for the GCP to start up
; then return to CP/M
;------------------------------------------------
	lxi	h,1000h
delay:
	dcx	h
	mov	a,h
	ora	l
	jnz	delay
	jmp	return
page
;---------------------------------------------
; Subtract 16 bit DE from 16 bit HL leaving
; result in HL
;---------------------------------------------
sub16:
	mov	a,l
	sub	eŠ	mov	l,a
	mov	a,h
	sbb	d
	mov	h,a
	ret

;-------------------------------------------------------
; SEND  This is used to send a command sequence to the
;	Skeleton GCP. The HL register must point to the
;	command length byte. NOTE that the length byte
;	doesn't include itself.   On completeion
;	<HL> should point to the next commands length byte.
;---------------------------------------------------------
send:
	mov	a,m		;get length byte
	inr	a		;add one to get length that I must send.
send2:
	push	h
	push	psw
	mov	c,m		;get a byte 
	call	gxo		;and send
	pop	psw
	pop	h
	inx	h		;step to next
	dcr	a		;drop count
	rz			;return on all sent
	jmp	send2		;go send more

;-----------------------------------------------------------
; Restore CP/M's stack and return
;-----------------------------------------------------------
return:
	di
	lhld	old$stack
	sphl
	ei
	ret 

page
;------------------------------------------------------------
; The following is the header block.  It is an image of the
; download and the execute command that will be sent to
; cause the rest of the code in the file to download

;------------------------------------------------------------
header:
	ds	1		;length of download command
	ds	1		;download command opcode
	ds	1		;dummy program id
addr1:	ds	2		;start of image location
addr4:	ds	2		;calculated length of image

	
	ds	1		;length of execute command
	ds	1		;execute commands opcodeŠ	ds	1		;dummy program id
addr3:	ds	2		;execution start address

	ds	3		;dummy area
addr2:	ds	2		;hold area for stop address

rdaddr: ds	2		;write address hold
execadd:ds	2		;hold for executes command address

rdbuffer: ds	128		;download buffer

msg1:	db	'No CRCGEN.COM file on drive A.',cr,lf,'$'
msg2:	db	'GCP Read file failed',cr,lf,'$'
msg3:	db	'Close failed',cr,lf,'$'

fcb:	db	0,'CRCGEN  COM'
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	db	0,0,0,0,0,0,0,0
	ds	80h		; user stack space
user$stack	equ	$

old$stack:
	ds	2		; save location for CP/M's stack pointer
	end	start

