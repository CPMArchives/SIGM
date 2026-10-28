; PIPPATCH.ASM mod B
;
; Notes on PIPPATCH mod A
;
; One problem which is often encountered with PIP.COM is that 
; there is no convenient method to transfer files to and from 
; several different diskettes without rebooting CP/M and rerunning 
; PIP after each output disk change.  This is especially a problem 
; when some of your archive disks do not contain a system, and also 
; when your system does not allow warmbooting from a single density 
; disk.  These patches to PIP.COM add a special command to allow 
; the disk system to be reset, which allows the output diskettes to 
; be changed and then restored to R/W status.  
;
; The idea for these patches came from LIFELINES, October 1981. 
; This coding of the idea, however, is my own and is placed in the
; PUBLIC DOMAIN for all to use as they desire.
;
; The useage is simple:  When you have finished with an output 
; disk, change it.  Then, before doing anything else, let your 
; first command be the single character which you specified in this 
; file to be your reset character.  I chose "R".  When the prompt 
; returns, all disks have been restored to R/W status.
;
; Also, the opportunity was taken to make PIP give a signon 
; message, to help weed out the old versions, especially v1.4
;
; Additional notes on PIPPATCH mod B
;
; While I was at it, it seemed a good idea to be able to repeat 
; the previous command without having to retype it.  This feature 
; takes advantage of the fact that CP/M doesn't bother to clear the 
; console input buffer, but instead just overwrites a portion of 
; it, based on what was typed.  The command to repeat the last 
; command is also specified at assembly time.  I have chosen the 
; "!" for this, for no particular reason.  If you don't like it, 
; change it!
;
; Patches courtesy of:
;	Lewis Moseley, Jr.
;	2576 Glendale Ct. NE
;	Conyers, GA 30208
; 				Reciprocation encouraged.



	org	100H		;program start

	jmp	signon

	org	110H		;custom I/O area

signon:	lda	fcb+1		;was a command given on the command line?
	cpi	' '
	jnz	04CEH		;skip new signon message if so

	lxi	d,msg1		;else give new signon message
	mvi	c,9
	call	bdos		;write it to console
	jmp	04CEH 		;join mainline code

msg1:	db	0dh,0ah
	db	'PIP v2.2 mod B',0dh,0ah,'$'

getcon:	lxi	h,buff
	mvi	m,80H		;specify max length of reply
	xchg			;buffer address to DE
	mvi	c,10		;bdos command to read console buffer
	call	bdos		;ask bdos to do it

	lda	buff+1		;length of reply
	cpi	1		;just 1 caharacter entered?
	jnz	gobak		;let PIP process the command if not
	
	lda	buff+2		;first (and only) char typed
	cpi	rptchr		;was it the repeat command?
	jnz	getc1		;jump if not
;
;
; REPEAT command - Restore first 4 chars of the console buffer to
;		   their former contents, echo the old command to
;		   console, RESET disk system, and let PIP reprocess it
;
	lhld	stash		;restore length and first char typed
	shld	buff+1

	lxi	d,msg3		;'Disk system reset' msg
	mvi	c,9
	call	bdos

	lxi	d,msg2		;'Repeating...' message
	mvi	c,9
	call	bdos		;write it to console

	lxi	h,buff+1	;get length byte
	mov	c,m		;to reg BC
	mvi	b,0
	inx	h		;get buffer start address to HL
	dad	b		;point to first free position in buffer
	mvi	m,'$'		;flag end of line with a "$"
	lxi	d,buff+2
	mvi	c,9
	call	bdos		;echo line

	mvi	c,13		;bdos command to RESET
	call	bdos

	ret			;let PIP process the previous command again

msg2:	db	0dh,0ah
	db	'Repeating:  $'

getc1:	ani	5FH		;convert lc to UC (note: don't use for numbers)
	cpi	rstchr		;is it the user-specified RESET command?
	jnz	gobak		;let PIP process if not
;
; RESET command - make all diskettes R/W
;
	lxi	d,msg3		;'Disk system reset' msg
	mvi	c,9
	call	bdos
	mvi	c,13		;bdos command to RESET
	call	bdos
	call	crlf

	pop	h		;clear stack
	jmp	53CH		;rejoin command loop within PIP

msg3:	db	0DH,0AH
	db	'All disks made R/W.$'

;
; not a special command, so stash the console buffer for later
;
gobak:	lhld	buff+1		;save length and first char typed
	shld	stash
	ret			;and back to PIP to process

stash	dw	0		;no initial command


	org	96FH		;patch PIP to vector to this routine

	jmp	getcon



bdos	equ	5		;cp/m entry point
fcb	equ	05CH		;default fcb

crlf	equ	082EH		;PIP's internal CR-LF routine
buff	equ	1ECBH		;PIP's input buffer

rstchr	equ	'R'		;put your choice for the reset char here
rptchr	equ	'!'		;same here for the repeat command char

