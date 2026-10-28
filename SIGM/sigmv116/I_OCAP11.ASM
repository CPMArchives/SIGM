;       I/O-CAP.ASM Version 1.0 as of September 13, 1981
; 
;                  By: Kelly Smith, CP/M-Net
;
; Version 1.0: Initial release by Kelly Smith
; Version 1.1: modified size for LF
;               added Apple ][ equates
; by Bill McGee (613-828-9130)  
;      Note:  Please  append  any  changes to I/O-CAP  with  a 
; 'Version  Log' and change comments (your name would be  nice 
; too) top-down from the initial Version 1.0 release.
;  
;      Running  I/O-CAP  (the  first time) will  relocate  the 
; CONIN,  and CONOUT jump vectors to high memory and then  ALL 
; subsequent   input  or  output  (depending  on   conditional 
; assembly  switches)  will  be  buffered  (16  sectors)   for  
; eventual  output  to  disk with a filename and type   called  
; USER.LOG.  This file will then be updated as long as I/O-CAP 
; is   active  in  the system.   Note:   I/O-CAP may  be  made 
; inactive  by just type I/O-CAP again,  to toggle it off  (or 
; on).
; 
;      I/O-CAP   requires   an  unusually  LARGE   amount   of 
; relocation  memory,  because it must buffer the entire  CP/M 
; system image to high memory to save and restore all CCP  and 
; BDOS pointers as it captures each 16 sector block of console 
; input or output...crude,  but the ONLY other wait to do this 
; would  be to  'hot-patch' the CCP and BDOS 'on-the-fly'  and 
; that  get's  just   a   bit  gruesome  from   a    UNIVERSAL   
; applications  standpoint...It's much easier to just SYSGEN a 
; smaller   CP/M  system  than your actual  maximum  available 
; memory,   and  then have I/O-CAP relocate itself above  your 
; BIOS.  If  anyone has a better way to do this  WITHOUT  this 
; relocation  crap,  I  would be eager to see it...I just  got 
; frustrated  with  trying to figure out what CP/M  was  doing 
; internally  to pursue it further...local  stacks,  pointers, 
; etc.,...ARGH...so I took the easy way out.
; 
;      Thanks  to  Mike Karas for discovering  the  BDOS  CALL 
; contention  problems  when the BDOS stack was not saved  and 
; restored when saving the console buffer to disk.
; 
;                       - Applications -
; 
; (1)   Don't have a printer,  and want 'Hard Copy' of a  user 
; dialog  with the system?  Use I/O-CAP to creat it as a  disk 
; file...for  instance,  when making patches into  'uncertain' 
; areas of the system with DDT (or SID,  or whatever) you  can 
; keep  a  running  history on disk of the patches  AND  their 
; effects.
; 
; (2)   Need to show example of console dialog for an  article 
; or book and you don't want to 'hand type' it in? Use I/O-CAP 
; to creat the examples for you,  and edit the dialog to  suit 
; your needs.
; 
; (3)   Need to know all the events in 'history form'  leading 
; to  some bizarre system blow-up?  Use I/O-CAP to record that 
; history  for you (but only if the blow-up is recoverable  by 
; NOT COLD BOOTING the system).
; 
; (4)   Want  to  (secretly) monitor the activities  of  other 
; users  of  the system?  Use I/O-CAP to record  user  console 
; input,  and check in from time-to-time to look at the system 
; activity.  Used  in  conjunction with BYE on a  remote  CP/M 
; system,  you can finally figure-out how that 'twit' clobbers 
; your  system from 3000 miles away...and NOT fill a room full 
; of  paper by logging all input to your  printer.  Note:  Run 
; I/O-CAP first,  then BYE.COM to 'grab' the vectors set-up by 
; the I/O-CAP program.The capture of incoming data will appear 
; to be transparent to the user,  with a slight pause when  it 
; updates the USER.LOG file...but this only happens every 2048 
; character entrys, so it should generally go un-noticed.
; 
;                      - Using I/O-CAP -
; 
;      Examine  the various conditional assembly switches  and 
; set  TRUE or FALSE depending on your requirements with  your 
; editor  (ED.COM).  Then assemble with ASM.COM (or  MAC.COM), 
; load it to creat a .COM file and then run.  The  conditional 
; assembly switches allow the following options:
; 
; (1)   DEBUG  -  I/O-CAP runs at 8000 Hex...about  right  for 
; most small applications programs that use memory from 100 to 
; 7FFF Hex in a 56K CP/M system.  If FALSE, I/O-CAP runs above 
; a  48K  CP/M  system (C800 Hex),  with  no  restrictions  on 
; applications programs.
; 
; (2)  QUIET - If FALSE, rings the console bell just before it 
; writes 2048 bytes of captured console INPUT or OUTPUT.
; 
; (3)   ERRDISP - If TRUE,  I/O-CAP will display an  'OOPS...' 
; message on the console if the disk or directory is full.
; 
; (4)   INPUT  - If  TRUE,  only  console  keyboard  INPUT  is 
; captured. Note: OUTPUT must be FALSE if INPUT is TRUE.
; 
; (5)   OUTPUT  - If  TRUE,  both console keyboard  INPUT  and 
; OUTPUT will be captured...uses 'gobs' of disk storage if you 
; let I/O-CAP run for any length of time.  Note: INPUT must be 
; FALSE if OUTPUT is TRUE.
; 
; (6) QUIT - If TRUE, when a Control-Z and Carriage Return are 
; entered  at  the console keyboard,  I/O-CAP will append  the 
; USER.LOG file with a physical end-of-file (i.e.,  no further 
; data  will  be  displayed in USER.LOG  although  it  may  be 
; physically appended to it)...Note: You must type I/O-CAP<cr> 
; to CLOSE the current USER.LOG,  and reset the disk to normal 
; R/W  status.  Failure  to  do so will result in a  R/O  BDOS 
; Error  on  any subsequent attempt to write to  the  disk  by 
; means other than I/O-CAP.
; 
; (7) SYSLOG - If TRUE,  creates USER.LOG as a $SYS (invisible 
; to  directory)  file,  so that 'secrecy' is maintained  when 
; capturing  user input...be sure and rename USER.LOG to  your 
; 'private' name, or replace the TYPE command with MLIST.COM.
; 
;      Please  send any changes,  'bug' reports,  suggestions, 
; comments,  gripes or bitches to the CP/M-Net  system,  (805) 
; 527-9321...have  fun with this program.  It's in the  public 
; domain, but NOT TO BE USED for COMMERCIAL BENEFIT.
; 
;                                    Best regards,
; 
;                                    Kelly Smith, CP/M-Net
; 
;
;
; define TRUE/FALSE assembly parameters
;
true	equ	-1	; define TRUE
false	equ	not true; define FALSE
debug	equ	true	; define DEBUG
quiet	equ	false	; define QUIET (ring BELL, if not true)
errdisp	equ	true	; define ERRDISP (display errors, if true)
quit	equ	true	; define QUIT (EOF, if Control-Z found)
syslog	equ	false	; define SYSLOG (make USER.LOG a $SYS file)
APPLE	equ	true	; for Apple ][ with 56K Softcard CP/M
; >>> Note: only one of the following two assembly switches may be true <<<
;
input	equ	true	; define INPUT (I/O-CAP console input)
output	equ	false	; define OUTPUT (I/O-CAP console output)
;
	if	DEBUG
dest	equ	08000h	; running location of code
	endif		; DEBUG

	if	not DEBUG
dest	equ	0c800h	; running location of code
	endif		; DEBUG
;
; BDOS entry point and function codes
; 
base	equ	0	; <<-- set to offset of CP/M for your
			; system, standard systems are 0, some
			; 'alternate' systems are 4200H
; 
bdos	equ	base+5
resdsk	equ	13	; reset disk system
offc	equ	15	; open file
cffc	equ	16	; close file
dffc	equ	19	; delete file
rrfc	equ	20	; read record
wrfc	equ	21	; write record
mffc	equ	22	; make file
sdma	equ	26	; set dma address
; 
; secondary FCB field definitions
; 
fn	equ	1	; file name field (rel)
ft	equ	9	; file type field (rel)
ex	equ	12	; file extent field (rel)
frc	equ	15	; file record count (rel)
nr	equ	32	; next record field (rel)
; 
; ASCII control characters
; 
cr	equ	0dh	; carriage return
lf	equ	0ah	; line feed
bel	equ	07h	; bell signal
;
; This  program runs up in high ram.  It gets there,  by being 
; moved  there  when 'I/O-CAP'  is typed. Change the following 
; equate to an area in your high memory where this program may 
; patch itself in.  Approximate memory requirements:  2k bytes 
; or more,  depending upon the options selected.  a marker has 
; been  placed  at  the  end to deliberately  print  an  error 
; message  during  assembly in order to determine  the  actual 
; ending  address of the program.  The error message will  not 
; affect the assembly.  make sure you have memory available up 
; to the address shown.
;
	org	base+100h
;
; Move 'I/O-CAP' program up to high ram and jump to it
;
	lxi	h,0	; save old stack pointer
	dad	sp
	shld	oldstk
	lxi	sp,stack; make a new stack pointer
	lxi	h,tbuf	; set pointer to tbuf
	shld	ptr
	lxi	h,0	; set size = 0
	shld	size
	lhld	base+1	; get BIOS pointer
	lxi	d,5	; add bias to console status address
	dad	d
	mov	d,m	; save in [d]
	lhld	newjtbl+1	; see if vector addresses active
	mov	a,h	; been patched by previous execution?
	cmp	d
	jz	unpatch	; un-patch, if so
	lxi	b,pend-start+1		; number of bytes to move
	lxi	h,dest+pend-start+1	; end of moved code
	lxi	d,source+pend-start	; end of source code
;
mvlp	ldax	d	; get byte
	dcx	h	; bump pointers
	mov	m,a	; new home
	dcx	d
	dcx	b	; bump byte count
	mov	a,b	; check if zero
	ora	c
	jnz	mvlp	; if not, do some more
	pchl		; do it, to it...
;
source	equ	$	; boundary memory marker
;
offset	equ	dest-source ; relocation amount
;
; The following code gets moved to high ram located at "dest", 
; where it is executed. C A U T I O N :  if modifying anything 
; in this program from here on: ALL labels must be of the form:
;
; label	equ	$+offset		
;
; ...in   order   that  the  relocation  to  high   ram   work 
; successfully.   Forgetting  to specify '$+offset' will cause 
; the program to jmp into whatever is currently in low memory, 
; with unpredictable results.  Be careful....		
;
start	equ	$+offset
;
; patch in the new jump table (saving the old)
;
patch	equ	$+offset
	call	tbladdr		; calc [hl] =  CP/M jmp table
	lxi	d,vcstat	; point to save location
	call	move		; move it
;
; now move new jump table to CP/M
;
	call	tbladdr		; calc [hl] = CP/M's jmp table
	xchg			; move to de
	lxi	h,newjtbl	; point to new
	call	move		; move it
	lxi	h,active$message
	call	msgout
	lhld	oldstk		; get old CP/M stack pointer
	sphl
	ret
;
unpatch equ	$+offset
	call	reset	; reset disk in case it's R/O
	lxi	h,inactive$message
	call	msgout
	call	tbladdr		; [hl] = CP/M's jmp table
	xchg			; move to de
	lxi	h,vcstat	; get saved table
	call	move		; move orig back
	lhld	oldstk		; get old CP/M stack pointer
	sphl
	ret			
;
; calculate [hl] = CP/M's jump table, [b] = length
;
tbladdr equ	$+offset
	lhld	base+1		; get BIOS pointer
	inx	h		; ..skip
	inx	h		; ..to
	inx	h		; ..console status
	mvi	b,9		; move console jump vectors
	ret
;
; move [hl] to [de], length in [b]
;
move	equ	$+offset
	mov	a,m		; get a byte
	stax	d		; put at new home
	inx	d		; bump pointers
	inx	h
	dcr	b		; decrement byte count
	jnz	move		; if more, do it
	ret			; if not, return
;
; move [hl] to [de], length in [bc]
;
movecpm	equ	$+offset
	mov	a,m		; get a byte
	stax	d		; put at new home
	inx	d		; bump pointers
	inx	h
	dcx	b		; decrement byte count
	mov	a,b
	ora	c
	jnz	movecpm		; if more, do it
	ret			; if not, return
;
msgout	equ	$+offset
	mov	a,m		; get character from message string
	ora	a		; all of string displayed?
	rz			; return, if so
	inx	h		; no, bump pointer for next character
	mov	c,a		; pass character to 'old' BIOS vector
	call	conout
	jmp	msgout		; display next character in message string
;
; This area is used for vectoring calls to the user's CBIOS, 
; but saving the registers first in case they are destroyed.
;
constat equ	$+offset
	push	b
	push	d
	push	h
	call	vcstat
	pop	h
	pop	d
	pop	b
	ret
;
conin	equ	$+offset
	push	b
	push	d
	push	h
	call	vcin
	pop	h
	pop	d
	pop	b
	ret
;
conout	equ	$+offset
	push	b
	push	d
	push	h
	call	vcout
	pop	h
	pop	d
	pop	b
	ret
;
; This  is  the jump table which is copied on top of  the  one 
; pointed to by location 1 in CP/M
;
newjtbl equ	$+offset
	jmp	constat	; console status test

	if	INPUT
	jmp	capture	; console input I/O-CAP routine
	endif		; INPUT

	if	OUTPUT
	jmp	conin	; console input routine
	endif		; OUTPUT

	if	INPUT
	jmp	conout	; console output routine
	endif		; INPUT

	if	OUTPUT
	jmp	capture	; console I/O-CAP output routine
	endif		; OUTPUT

;
capture	equ	$+offset
	push	h
	push	d
	push	b
	lxi	h,0	; save old stack pointer
	dad	sp
	shld	oldstk
	lxi	sp,stack; make a new stack pointer

	if	INPUT
	call	vcin	; get console input
	mov	c,a	; save in [c] for 'save'
	push	psw	; and save on the stack
	endif		; INPUT

	call	save	; save characters in buffer

	if	INPUT
	pop	psw	; get console input of the stack
	endif		; INPUT

	lhld	oldstk	; get old CP/M stack pointer
	sphl
	pop	b
	pop	d
	pop	h

	if	OUTPUT
	jmp	vcout
	endif		; OUTPUT

	if	INPUT
	ret
	endif		; INPUT

; 
save:	equ	$+offset
	lhld	size	; size = size + 1
	inx	h
	shld	size
	lhld	ptr
	mov	m,c
	inx	h

	if	INPUT
	mov	a,c
	cpi	cr	; carriage return?
	jnz	notcr
	mvi	m,lf	; yes, so add line feed because CP/M does not
	inx	h	; bump pointer, for next time thru
	shld	ptr	; added for 1.1 to
	lhld	size	;        /
	inx	h	;       /
	shld	size	;      /
	lhld	ptr	; here
	endif		; INPUT

notcr	equ	$+offset; make label for next instruction...

	if	QUIT
	mov	a,c
	cpi	'Z'-40h	; control-Z?
	jz	wtb	; write buffer, if so
	endif		; QUIT

	shld	ptr
	lxi	d,endmark	; get 'endmark' for buffer top address
	mov	a,d
	cmp	h	; getting near the end of buffer yet?
	rnz		; if not, just return
	mov	a,e	; very near the top now, final address loaded?
	cmp	l
	rnz		; if not, just return

	if	not QUIET
	mvi	c,bel	; warn user that we need to write to disk
	call	conout
	endif		; QUIET

; 
; wtb - write text buffer to disk
; 
wtb:	equ	$+offset
	IF NOT APPLE
	lhld	base+6	; get warm boot address for next bias to CCP
	lxi	d,0fffah; make bias to CCP
	dad	d	; add bias to [hl]
	lxi	b,1600h	; make quantity to move
	lxi	d,cpmbuf; buffer all of CP/M system
	call	movecpm	; move it...
	ENDIF
	IF APPLE
	lxi	h,0CC00h
	lxi	b,1400h
	lxi	d,cpmbuf
	call	movecpm
	lxi	h,0F000h
	lxi	b,1000h
	lxi	d,cpmbuf1
	call	movecpm
	ENDIF	; APPLE
	call	reset	; reset disk in case it's R/O
	call	open	; attempt to open USER.LOG
	inr	a	; check CP/M return code
	jnz	makeok	; USER.LOG already exist?
;
nolog:	equ	$+offset
;
	call	make	; make new file
	inr	a	; check CP/M return code
	jnz	makeok

	if	ERRDISP
	lxi	h,dirful; oops...can't make file, return to CP/M
	call	msgout
	endif		; ERRDISP

	jmp	base
;
; USER.LOG exists, so set the FCB entry for next append to file
;
makeok:	equ	$+offset
;
	lda	fcb+frc	; get record count
	sta	fcb+nr	; make next record
	lhld	size	; [de] = tbuf size
	xchg
	lxi	h,dbuf	; top of stack points to dbuf
	push	h
	lxi	h,tbuf	; [hl] points to tbuf
; 
wtb1:	equ	$+offset
	mvi	c,128	; disk buffer size
; 
wtb2:	equ	$+offset
	mov	a,m	; fetch next byte of tbuf
	inx	h
	xthl
	mov	m,a	; store in dbuf
	inx	h
	xthl
	dcx	d	; size = size - 1
	mov	a,d	; exit loop if size = 0
	ora	e
	jz	wtb3
	dcr	c	; loop until dbuf full
	jnz	wtb2
	call	setdma	; set dma to dbuf
	call	write	; write full dbuf to disk
	push	psw	; save possible error code
	lda	fcb+frc	; get record count
	sta	fcb+nr	; make next record
	pop	psw	; get possible error code
	ora	a	; check CP/M return code
	jz	nextbuf

	if	ERRDISP
	lxi	h,dskful; oops...disk is full
	call	msgout
	endif		; ERRDISP

	jmp	base
;
nextbuf	equ	$+offset
;
	xthl		; top of stack points to dbuf
	lxi	h,dbuf
	xthl
	jmp	wtb1	; loop until end of tbuf
; 
wtb3:	equ	$+offset
	pop	h	; [hl] points to current place in dbuf
; 
wtb4:	equ	$+offset
	mvi	m,'Z'-40h ; store eof code
	inx	h
	dcr	c	; loop thru rest if dbuf
	jnz	wtb4
	call	setdma	; set dma to dbuf
	call	write	; write last sector to disk
	push	psw	; save possible error code
	lda	fcb+frc	; get record count
	sta	fcb+nr	; make next record
	pop	psw	; get possible error code
	ora	a	; check CP/M return code
	jz	closeup

	if	ERRDISP
	lxi	h,dskful; oops...disk is full
	call	msgout
	endif		; ERRDISP

	jmp	base
;
closeup	equ	$+offset
;
	call	close	; clean up act and go home
	lxi	h,tbuf	; clear text buffer
	shld	ptr
	lxi	h,0
	shld	size
wtb5:	equ	$+offset
	IF NOT APPLE
	lhld	base+6	; get warm boot address for next bias to CCP
	lxi	d,0fffah; make bias to CCP
	dad	d	; add bias to [hl]
	lxi	b,1600h	; make quantity to move
	lxi	d,cpmbuf; buffer all of CP/M system
	xchg		; swap
	call	movecpm	; move it...
	ENDIF
	IF APPLE
	lxi	h,0CC00h
	lxi	b,1400h
	lxi	d,cpmbuf
	xchg
	call	movecpm
	lxi	h,0F000h
	lxi	b,1000h
	lxi	d,cpmbuf1
	xchg
	call	movecpm
	ENDIF	; APPLE
	ret
; 
;  reset - reset disk
;
reset:	equ	$+offset
	push	h
	push	d
	push	b
	mvi	c,resdsk
	call	bdos
	pop	b
	pop	d
	pop	h
	ret
; 
; open - open disk file
; 
open:	equ	$+offset
	push	h
	push	d
	push	b
	lxi	d,fcb
	mvi	c,offc
	call	bdos
	pop	b
	pop	d
	pop	h
	ret
; 
; read - read record from disk file
; 
read:	equ	$+offset
	push	h
	push	d
	push	b
	lxi	d,fcb
	mvi	c,rrfc
	call	bdos
	pop	b
	pop	d
	pop	h
	ret
; 
; close - close disk file
; 
close:	equ	$+offset
	push	h
	push	d
	push	b
	lxi	d,fcb
	mvi	c,cffc
	call	bdos
	pop	b
	pop	d
	pop	h
	ret
; 
; delt - delete disk file
; 
delt:	equ	$+offset
	push	h
	push	d
	push	b
	lxi	d,fcb
	mvi	c,dffc
	call	bdos
	pop	b
	pop	d
	pop	h
	ret
; 
; write - write record to disk
; 
write:	equ	$+offset
	push	h
	push	d
	push	b
	lxi	d,fcb
	mvi	c,wrfc
	call	bdos
	pop	b
	pop	d
	pop	h
	ret
; 
; make - make new disk file
; 
make:	equ	$+offset
	push	h
	push	d
	push	b
	lxi	d,fcb
	mvi	c,mffc
	call	bdos
	pop	b
	pop	d
	pop	h
	ret
; 
; setdma - set dma address for disk file
; 
setdma:	equ	$+offset
	push	h
	push	d
	push	b
	lxi	d,dbuf
	mvi	c,sdma
	call	bdos
	pop	b
	pop	d
	pop	h
	ret
;

	if	ERRDISP
dskful:	equ	$+offset
	db	cr,lf,bel,'OOPS...disk is full!',0
;
dirful:	equ	$+offset
	db	cr,lf,bel,'OOPS...directory is full!',0
	endif		; ERRDISP

;
active$message	equ	$+offset
	db	'  (Active)',0
;
inactive$message	equ	$+offset
	db	'  (Inactive)',0
;
fcb	equ	$+offset
	db	0	; default drive specifier

	if	SYSLOG
	db	'USER    L','O'+80h,'G'
	endif		; SYSLOG

	if	not SYSLOG
	db	'USER    LOG'
	endif		; SYSLOG

	db	0,0,0,0,0,0,0,0,0,0
;
pend	equ	$+offset; end of relocated code
;
; data area
; 
	ds	128	; 64 level stack
stack	equ	$+offset;local stack
;
ptr:	equ	$+offset
	ds	2	; text buffer pointer
;
size:	equ	$+offset
	ds	2	; text buffer size
;
; Save the CP/M jump table here
;
vcstat	equ	$+offset
	ds	3
;
vcin	equ	$+offset
	ds	3
;
vcout	equ	$+offset
	ds	3
;
oldstk	equ	$+offset
	ds	2	; storage for old CP/M stack pointer
;
	IF NOT APPLE
	cpmbuf	equ	$+offset
	ds	1600h	; storage CP/M system image
	ENDIF
	IF APPLE
	cpmbuf	equ	$+offset
	ds	1400h
	cpmbuf1	equ	$+offset
	ds	1000h
	ENDIF	;APPLE
;
dbuf	equ	$+offset
	ds	128	; secondary disk buffer address
;
tbuf:	equ	$+offset
	ds	16*128	; I/O-CAP storage for 16 sectors (2048 bytes)
;
endmark	equ	$+offset;! ignore error - this marks end of program
;
	end
