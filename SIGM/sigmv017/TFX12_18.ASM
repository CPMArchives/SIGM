; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; +           CP/M to CP/M file transfer utility             +
; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
; Revised 12/18/80,  to allow "wild card" filenames and  type,
; as well as "multi-file transfers"
; 
;                    TFX.ASM Version 1.2
; 
;                           as of
; 
;                     December 18, 1980
; 
; 
;                     HARWARE DEPENDENCE
;                     ------------------
; 
;  The  harware  requirment for inter-system file transfer  is 
; simply  two disk sub-systems of same or  differing  hardware 
; requirments  operating under the same host main frame micro-
; computer,  both  of which are capable of operating  under  a 
; CP/M environment.
; 
;                    SOFTWARE DEPENDENCE
;                    -------------------
;  
;  Both  disk sub-systems must be capable of running the  CP/M 
; disk  operating system.  Memory size of these systems is  of 
; little  importance  other  than one system 'MUST' be  of  at 
; least 5 kilo-bytes larger in size.
; 
;                        OPERATION
;                        ---------
; 
;  The  'Resident'  and 'Co-resident' systems are  defined  as 
; follows:
; 
;                     RESIDENT SYSYTEM
; 
;  The  resident  CP/M system,  larger in  terms  of  SYSGENed 
; memory size.
; 
;                    CO-RESIDENT SYSTEM
;    
;  The  co-resident CP/M system,  smaller in terms of SYSGENed 
; memory size.
; 
;  Initially you start up by booting the co-resident system as 
; you  normally  do and then transfer control to the  resident 
; system. There are several ways of doing this, the easiest is 
; using a file called GO.COM,  it's operation is simple;  type 
; GO 'XXXX' where XXXX represents the hexadecimal address  you 
; wish your processor to jump to, others include (with a front 
; panel  system) STOP,EXAMINE,RUN ( as for a MITS 8800b micro-
; computer)  the  address refered to is the  "primitive"  boot 
; address to your resident system.
; 
;  After completing the above operation, type:
;  TFX S:FN.FT D:FN.FT<cr>
; 
;  Where:
; 
;  TFX  is the com file transfer utility
;  
;  S:   is  the source drive reference (RESIDENT  system), A: 
;       thru P: under CP/M version 2.x
;  
;  D:   is  the  destination  drive  reference  (CO-RESIDENT 
;       system), A: thru P: under CP/M version 2.x
; 
;  FN:  is the file name (1 to 8 character)
;  
;  FT:  is the file type (1 to 3 character)
; 
;  <cr> carriage return, on your console keyboard
; 
; 
;  Note:  D:FN.FT does not have to agree with S:FN.FT; this is 
; an enventual call to 'make file' function to the co-resident 
; BDOS in CP/M.  Also, "wild card" filenames and  types may be
; used.
; 
; 
;                          MESSAGES
;                          --------
; 
; Resident bdos entry = XXXXH (hex address resident)
; 
; Co-resident bdos entry = XXXXH (hex  address  co-resident) 
; 
; No source file (source file can't be found)
; 
; No directory space (directory full on destination disk)
; 
; Write protected (destination disk is write protected)
; 
; Copy complete (file transfer has completed)
; 
; 
; 			 PATCH NOTES
; 			 -----------
; 
;  In   view  of  the  various  CP/M  (versions)  systems  and 
; programmers implementations (Lifeboat associates,...ugh),  I 
; have decided not to do any version checking (an attribute of 
; CP/M  2.x).  In  the TFX.ASM source file,  you  will  see  a 
; subroutine  that  calculates  the  co-resident  jump  vector 
; entries,  saves this address and then biases this value by a 
; constant  to  determine  the bdos entry  - the  address  you 
; normally  find  at  0005h.  This bias value is based  on  my 
; system  and  more than likely will have to  be  changed  for 
; yours.  This  is  simply the difference between 'warm  boot' 
; (this address is stored at 0000h) and BDOS (this address  is 
; stored  at 0005h).  I then simply take this address and do a 
; DAD  (double  add) to this bias,  a  subtraction  operation. 
; These address references are of cource with respect to  your 
; co-resident CP/M system. WARNING: DO NOT USE DDT (or SID) to 
; examine  address  0005h to use in your offset  calculations. 
; This address will overlayed by either debugger,  and will be 
; wrong.
; 
;  This  is  a  very simple file transfer  function,  in  fact 
; primitive.  I am in the process of writting a program  which 
; operates  in similar fashion to PIP.COM,  which is a  common 
; utility...at  the  time of this writting it's  still  pretty 
; "buggy".
; 
;                         Crable Enterprises - Brent J. Crable
; 
;
;
;++++++++++++++++++++++++++++++++++++++++++++++++
;+    CP/M to CP/M inter-system file transfer	+
;+    written by: Brent J. Crable   12/18/80	+
;++++++++++++++++++++++++++++++++++++++++++++++++
;
boot:	    equ     0	    ;system reboot
bdos:	    equ     5	    ;bdos entry point
tfcb:	    equ     5ch     ;system file control block
disk$buf:   equ     80h     ;system disk buffer
fn:	    equ     1	    ;file name offset
ft:	    equ     9	    ;file type offset
ex:	    equ     12	    ;extent number offset
nr:	    equ     32	    ;next record offset
;
cr	    equ     0dh
lf	    equ     0ah
;
;+++++++++++++++++++++++++++++++++++++++++++++++
;+	CP/M primitive bdos functions	       +
;+++++++++++++++++++++++++++++++++++++++++++++++
;
read$con:   equ     1	    ;read console
write$con:  equ     2	    ;print console
printf:     equ     9	    ;print buffer
reset:	    equ     13	    ;reset disk
open:	    equ     15	    ;open file
close:	    equ     16	    ;close file
sfirst:     equ     17	    ;search first
snext:	    equ     18	    ;search next
delt:	    equ     19	    ;delete file
read:	    equ     20	    ;read record
write:	    equ     21	    ;write record
make:	    equ     22	    ;make file
setdma:     equ     26	    ;set address
;
;**********    macro definitons    ****************
;
mess	macro	m	;print message m
;
	lxi	d,m	;;point to message
	mvi	c,printf;;load cp/m print code
	call	bdos	;;disk primitive entry point
	endm
;
;**************************************************
;
	org	100h
;
tfx:	lxi	sp,stack
;
	mess	msg0	;sign on
	mess	msg1
	lhld	bdos+1
	mov	a,h	;print bdos addr
	call	phex
	mov	a,l
	call	phex
	mvi	a,'H'
	call	pchar
	call	crlf
	xra	a
	sta	inp$buf$flg
	sta	opt$buf$flg
;
;++++++++++++++++++++++++++++++++++++++++++++++
;+ calculate co-resident cp/m system location +
;++++++++++++++++++++++++++++++++++++++++++++++
;
fndsys: lxi	h,4a00h ;set a start value
tryag:	push	h	;set pointer
	mvi	b,15	;number of jumps to match
match:	mov	a,m
	cpi	0c3h	;look for jmp instruction
	jz	jmpok	;yes
	pop	h
	inr	h
	jmp	tryag
;
jmpok:	inx	h
	inx	h
	inx	h
	dcr	b
	jnz	match
;+++++++++++++++++++++++++++++++++++++++++++
;+ we found something that is probably the +
;+ co-resident CP/M bdos entry		   +
;+++++++++++++++++++++++++++++++++++++++++++
	pop	h	;recover address
	shld	xentry	;co-res jmp vectors
	lxi	d,-3578 ;bias to bdos (patchable)
	dad	d
	shld	xbdos
	mess	msg1a
	lhld	xbdos
	mov	a,h	;print xbdos addr
	call	phex
	mov	a,l
	call	phex
	mvi	a,'H'
	call	pchar
	call	crlf
;
;++++++++++++++++++++++++++++++++++++++++++++++++++++
;+ calculate buffer size =(xbdos-mbuff/modulus 128) +
;++++++++++++++++++++++++++++++++++++++++++++++++++++
;
	lhld	xbdos
	lxi	d,-6	;hl = xbdos-6
	dad	d
	mov	a,l
	ani	80h	;hl = hl mod 128
	mov	l,a
	lxi	d,mbuf
	mov	a,l
	sub	e
	mov	l,a
	mov	a,h
	sbb	d
	mov	h,a
	dad	h	;hl = hl / 128
	mov	l,h
	mvi	a,0
	aci	0
	mov	h,a
	dcx	h	;subtract one
	shld	aval$space   ;save as buffer size
	mess	msg2	;print buffer size =
	lhld	aval$space   ;print size of buffer
	call	wdwc
	mess	msg3	;print sectors
	call	crlf
;+++++++++++++++++++++++++++++++++++++++++++++++++++
;+  notify user to mount data disk in host system  +
;+++++++++++++++++++++++++++++++++++++++++++++++++++
;
	lda	tfcb+1	;see if file name specified
	cpi	' '
	jnz	tfx1
	mess	msgz	;error - no file name
	jmp	boot
;
tfx1:	mess	msg4
	call	racc	;read response
	cpi	cr	;loop if anything but cr
	jnz	tfx1
tfx1a:	call	crlf
	lda	inp$buf$flg   ;jump if input buffer flag set
	ora	a
	jnz	tfx2a
;+++++++++++++++++++++++++++++++++++++++++++++++
;+ Move command line image into command buffer +
;+++++++++++++++++++++++++++++++++++++++++++++++
	lxi	h,disk$buf  ;source
	lxi	d,cmd$buf      ;destination
	mov	b,m	;fetch command line image length
	inx	h
tfx2:	mov	a,m	;fetch next byte from cli
	inx	h
	stax	d
	inx	d
	dcr	b	;decrement count
	jnz	tfx2	;loop untill zero
	xra	a	;store zero byte at end
	stax	d
	lxi	h,cmd$buf  ;reset cmd$bufp
	shld	cmd$pt$buf
	call	cfnt	;create file name table
	lxi	h,file$nt   ;reset file$nt pointers
	shld	inp$fil$ntp
	shld	opt$fil$ntp
tfx2a:	lxi	h,mbuf	;reset mbuf pointer
	shld	mem$pt$buf
	lhld	aval$space   ;reset msize
	shld	mem$size
	lda	inp$buf$flg   ;jump if inp$buf$flg not set
	ora	a
	jz	tfx3
	lxi	h,input$fcb  ;copy input$fcb into tfcb
	lxi	d,tfcb
	mvi	b,33
	call	move
	xra	a	;clear inp$buf$flg
	sta	inp$buf$flg
	mvi	a,1	;set opt$buf$flg
	sta	opt$buf$flg
	lhld	inp$fil$ntp   ;back inp$fil$ntp up 4 bytes
	lxi	d,-4
	dad	d
	shld	inp$fil$ntp
	lxi	h,tfcb+fn ;print file name
	call	wasc
	mess	msg6	;print -
	lhld	inp$fil$ntp   ;de = inp$fil$ntp
	xchg
	jmp	tfx4	;continue reading previous file
;++++++++++++++++++++++++++++++++++++++++++++++
;+ process next file name from command buffer +
;++++++++++++++++++++++++++++++++++++++++++++++
;
tfx3:	lhld	inp$fil$ntp   ;fetch input fnt pointer
	mov	a,m	;jump if end of table
	cpi	0ffh
	jz	tfx9
	mvi	m,1	;set 'file read' flag
	inx	h
	lxi	d,tfcb+fn  ;copy filename into tfcb
	mvi	b,11
	call	move
	shld	inp$fil$ntp   ;save input fnt pointer
	lxi	h,tfcb+fn  ;print file name
	call	wasc
	mess	msg6
	xra	a	;setup tfcb
	sta	tfcb
	sta	tfcb+ex
	sta	tfcb+nr
	lxi	d,tfcb
	mvi	c,open	;open file
	call	bdos
	lhld	inp$fil$ntp
	xchg
tfx4:	lhld	mem$pt$buf
	mov	a,h	;copy into fnt entry
	stax	d
	inx	d
	mov	a,l
	stax	d
	inx	d
	xchg		;save fnt pointer
	shld	inp$fil$ntp
	lxi	h,0	;file size (in sectors) = 0
	shld	file$size
;
; read next file from input disk
;
tfx6:	lhld	mem$pt$buf
	xchg
	mvi	c,setdma
	call	bdos
	lxi	d,tfcb	;read next sector (8)
	mvi	c,read
	call	bdos
	ora	a	;jump if normal transfer
	jz	tfx7
	cpi	1	;jump if eof
	jz	tfx8
	mess	msg8	;print read error - '
	jmp	tfx8	;continue as if eof
;
tfx7:	lhld	mem$pt$buf   ;mem$pt$buf = mem$pt$buf + 128
	lxi	d,128
	dad	d
	shld	mem$pt$buf
	lhld	file$size   ;file$size = file$size + 1
	inx	h
	shld	file$size
	lhld	mem$size
	dcx	h
	shld	mem$size
	mov	a,h	;loop if still positive
	ora	l
	jnz	tfx6
	lxi	h,tfcb	;copy tfcb into input$fcb
	lxi	d,input$fcb
	mvi	b,33
	call	move
	mvi	a,1	;set inp$buf$flg
	sta	inp$buf$flg
tfx8:	lxi	d,disk$buf  ;reset dma pointer
	mvi	c,setdma
	call	bdos
	lxi	d,tfcb
	mvi	c,close  ;close file (8)
	call	bdos
	lhld	file$size   ;print file size
	call	wdwc
	mess	msg9	;print sectors read'
;
; update file$nt, loop
;
	lhld	file$size   ;de = file size
	xchg
	lhld	inp$fil$ntp   ;store file size in fnt entry
	mov	m,d
	inx	h
	mov	m,e
	inx	h
	shld	inp$fil$ntp   ;save fnt pointer
	lda	inp$buf$flg   ;loop if inp$buf$flg not set
	ora	a
	jz	tfx3
;
; ask user to mount output disk
;
tfx9:	lda	pauseflg
	ora	a
	jz	tfx9a
	xra	a
	sta	pauseflg
	mess	msga	;print mount output disk, type cr
	call	racc	;read response
	cpi	cr	;loop if anything but cr
	jnz	tfx9
	call	crlf
	jmp	tfx10
;
tfx9a:	call	crlf
	mess	msga1
	call	crlf
tfx10:	mvi	c,reset;reset disk system (make r/w)
	call	entry
	lda	opt$buf$flg   ;jump if opt$buf$flg not set
	ora	a
	jz	tfxa
	lxi	h,output$fcb  ;copy output$fcb into tfcb
	lxi	d,tfcb
	mvi	b,33
	call	move
	lxi	d,tfcb
	mvi	c,open	;open previos file
	call	entry
	lhld	opt$fil$ntp   ;backup output fnt pointer 4 bytes
	lxi	d,-4
	dad	d
	shld	opt$fil$ntp
	lxi	h,tfcb+fn	;print file name
	call	wasc
	mess	msg6	;print -
	jmp	tfxb	;continue writing previous file
;
pauseflg:
	db	1	;set true
;+++++++++++++++++++++++++++++++++++++++
;+ Write next file to destination disk +
;+++++++++++++++++++++++++++++++++++++++
tfxa:	lhld	opt$fil$ntp
	mov	a,m
	ora	a
	jz	tfxf
	cpi	0ffh
	jz	tfxf
	inx	h
	lxi	d,tfcb+fn
	mvi	b,11
	call	move
	shld	opt$fil$ntp
	lxi	h,tfcb+fn
	call	wasc
	mess	msg6
	xra	a
	sta	tfcb
	sta	tfcb+ex
	sta	tfcb+nr
	lda	tfcb+9	;fource to $r/w for 2.0
	ani	7fh
	sta	tfcb+9	;fource to $dir for 2.0
	lda	tfcb+10
	ani	7fh
	sta	tfcb+10
	lxi	d,tfcb	;try to create output file (5)
	mvi	c,delt
	call	entry
	lxi	d,tfcb
	mvi	c,make
	call	entry
	cpi	255	;jump if o.k.
	jnz	tfxb
	mess	msgb	;print unable to create'
	jmp	tfxg
;
tfxb:	lhld	opt$fil$ntp
	mov	d,m	;fetch fwa of file from fnt
	inx	h
	mov	e,m
	inx	h
	xchg
	shld	mem$pt$buf   ;save it
	xchg
	mov	d,m	;fetch size of file from pointer
	inx	h
	mov	e,m
	inx	h
	xchg
	shld	file$size   ;save it
	shld	prt$size   ;save for printout
	xchg
	shld	opt$fil$ntp
	lhld	file$size   ;jump   if file$size = 0
	mov	a,h
	ora	l
	jz	tfxda
tfxc:	lhld	mem$pt$buf   ;set dma address to mbuff
	xchg
	mvi	c,setdma
	call	entry
	lxi	d,tfcb	;write next sector (5)
	mvi	c,write
	call	entry
	ora	a	;jump if ok
	jz	tfxd
	mess	msgc	;error writting file
	jmp	tfxg
;
tfxd:	lhld	mem$pt$buf   ;mem$pt$buf = mem$pt$buf + 128
	lxi	d,128
	dad	d
	shld	mem$pt$buf
	lhld	file$size   ;file$size = file$size - 1
	dcx	h
	shld	file$size
	mov	a,h	;loop until zero
	ora	l
	jnz	tfxc
tfxda:	lxi	h,tfcb	;copy tfcb into output$fcb
	lxi	d,output$fcb
	mvi	b,33
	call	move
	lxi	d,disk$buf  ;reset dma pointer
	mvi	c,setdma
	call	entry
	mvi	c,close ;try to close file (5)
	lxi	d,tfcb
	call	entry
	cpi	255	;jump if ok
	jnz	tfxe
	mess	msgd	;unable to close
tfxe:	lhld	prt$size   ;print number of sectors written
	call	wdwc
	mess	msge	;print sectors written
	jmp	tfxa
;
tfxf:	lda	inp$buf$flg   ;loop if inp$buf$flg set
	ora	a
	jnz	tfxh
tfxg:	mess	msgf	;exit to cp/m
	call	racc	;read response
	cpi	cr	;loop if anything but cr
	jnz	tfxg
	jmp	boot	;reboot cp/m
;
tfxh:	call	crlf
	mess	msgg
	jmp	tfx1a
;
;	subroutines
;
move:	mov	a,m
	inx	h
	stax	d
	inx	d
	dcr	b
	jnz	move
	ret
;+++++++++++++++++++++++++++++++++++
;+    get file name subroutine	   +
;+++++++++++++++++++++++++++++++++++
getn:	mov	a,m
	ora	a
	rz
	cpi	' '
	jnz	getno
	inx	h
	jmp	getn
;
getno:	lxi	d,temp$fcb
	xra	a
	stax	d
	inx	d
	push	d
	mvi	b,11
	mvi	a,' '
getn6:	stax	d
	inx	d
	dcr	b
	jnz	getn6
	pop	d
	mvi	b,9
getn1:	mov	a,m
	ora	a
	jz	getn4
	inx	h
	cpi	' '
	jz	getn4
	cpi	'.'
	jz	getn2
	cpi	'*'
	jz	getn7
	stax	d
	inx	d
	dcr	b
	jz	getn5
	jmp	getn1
;
getn7:	dcr	b
	jz	getn9
	mvi	a,'?'
	stax	d
	inx	d
	jmp	getn7
;
getn9:	mov	a,m
	cpi	'.'
	jnz	getn4
	inx	h
getn2:	lxi	d,temp$fcb+ft
	mvi	b,4
getn3:	mov	a,m
	ora	a
	jz	getn4
	inx	h
	cpi	' '
	jz	getn4
	cpi	'*'
	jz	getn8
	stax	d
	inx	d
	dcr	b
	jz	getn5
	jmp	getn3
;
getn8:	dcr	b
	jz	getn4
	mvi	a,'?'
	stax	d
	inx	d
	jmp	getn8
;
getn4:	xra	a
	ret
;
getn5:	stc
	ret
;
;+++++++++++++++++++++++++++++++++++
;+    create file names table	   +
;+++++++++++++++++++++++++++++++++++
;
cfnt:	lxi	h,file$nt   ;reset inp$fil$ntp
	shld	inp$fil$ntp
cfnt1:	lhld	cmd$pt$buf   ;get cmd$pt$buf
	mov	a,m
	ora	a
	rz
	call	getn	 ;get next afn
	shld	cmd$pt$buf   ;save command buffer ptr
	jnc	cfnt2
	mess	msg5	;print syntax error in filename
	jmp	cfnt1
;
cfnt2:	xra	a	;clear temp$fcb extent field
	sta	temp$fcb+ex
	lxi	d,temp$fcb  ;search for first occurance
	mvi	c,sfirst
	call	bdos
	cpi	255	;jump found
	jnz	cfnt3
	lxi	h,temp$fcb+fn  ;print filename
	call	wasc
	mess	msg7	;print not found
	jmp	boot	;exit to cp/m
;
cfnt3:	ani	3	;index into cbuf
	mov	l,a
	mvi	h,0
	dad	h	;*2
	dad	h	;*4
	dad	h	;*8
	dad	h	;*16
	dad	h	;*32
	lxi	d,disk$buf
	dad	d
	xchg		;copy filename into file$nt
	lhld	inp$fil$ntp
	xchg
	mvi	b,12
	call	move
	lxi	h,nulls ;buffer rest of entry
	mvi	b,4
	call	move
	xchg
	shld	inp$fil$ntp   ;save input file$nt pointer
	mvi	m,0ffh	;insure ff byte at end
	lxi	d,temp$fcb  ;search for next occurance
	mvi	c,snext
	call	bdos
	cpi	255	;jump if found
	jnz	cfnt3
	jmp	cfnt1	;go get next afn
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;+   print ascii string to console - terminated by '0'	 +
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
wasc:	mov	a,m
	ora	a
	rz
	call	pchar	 ;print it
	inx	h
	jmp	wasc
;++++++++++++++++++++++++++++++++++++
;+   print end of line to console   +
;++++++++++++++++++++++++++++++++++++
crlf:	mess	msgx
	ret
;++++++++++++++++++++++++++++++++++++
;+   print decimal word to console  +
;++++++++++++++++++++++++++++++++++++
wdwc:	push	h
	push	d
	push	b
	mvi	b,0	;clear b
	lxi	d,10000 ;print 1st digit
	call	wndd
	lxi	d,1000	;print 2nd digit
	call	wndd
	lxi	d,100	;print 3rd digit
	call	wndd
	lxi	d,10	;print 4th digit
	call	wndd
	lxi	d,1	;print 5th digit
	mvi	b,1	;force last digit to print
	call	wndd
	pop	b
	pop	d
	pop	h
	ret
;
wndd:	mvi	c,0	;c = 0
wndd1:	mov	a,l	;hl = hl - de
	sub	e
	mov	l,a
	mov	a,h
	sbb	d
	mov	h,a
	jc	wndd2	;jump if < 0
	inr	c	;c = c + 1
	jmp	wndd1	;loop
;
wndd2:	dad	d	;hl = hl + de
	mov	a,c	;jump if c non-zero
	ora	c
	jnz	wndd4
	mov	a,b	;jump if digit written
	ora	b
	jnz	wndd4
	mvi	a,' '	;print one space
	jmp	pchar
;
wndd4:	mvi	b,1	;set 'digit written' flag
	mov	a,c	;encode c into decimal ascii
	adi	'0'
	jmp	pchar	 ;go print it
;
phex:	push	psw
	rrc
	rrc
	rrc
	rrc		;shift right 4
	call	pnib	;print nibble
	pop	psw
	call	pnib
	ret
;
pnib:	ani	0fh
	cpi	10
	jnc	p10
;less than or equal to 9
	adi	'0'
	jmp	prn
;greater or equal to 10
p10:	adi	'A'-10
prn:	call	pchar
	ret
;++++++++++++++++++++++++++++++++++++++++++++
;+ pchar - print ascii character to console +
;++++++++++++++++++++++++++++++++++++++++++++
pchar:	push	h	;no - this isn't over kill !
	push	d
	push	b
	push	psw
	mvi	c,write$con
	mov	e,a	;character to e
	call	bdos
	pop	psw
	pop	b
	pop	d
	pop	h
	ret
;
; racc - read ascii character from console
;
racc:	mvi	c,read$con
	jmp	bdos
;
entry:	db	0cdh	;call instruction
xbdos:	ds	2	;address to xbdos
	ret		;return to caller
;
;
msg0:	db	' >>   CP/M to CP/M file transfer utility   <<'
	db	cr,lf
	db	' Version 1.2  as of 12/18 by: Brent J. Crable'
	db	cr,lf,cr,lf,'$'
msg1:	db	'   resident bdos entry = $'
msg1a:	db	'co-resident bdos entry = $'
msg2:	db	'buffer size =$'
msg3:	db	' (128) byte sectors',cr,lf,'$'
msg4:	db	'Mount source disk in <A>, type CR',cr,lf,'$'
msg5:	db	'syntax error in file name',cr,lf,'$'
msg6:	db	' - $'
msg7:	db	' not found',cr,lf,'$'
msg8:	db	'read error - $'
msg9:	db	' sectors read',cr,lf,'$'
msga:	db	cr,lf,'Mount destination disk in <A>, type CR',cr,lf,'$'
msga1:	db	'+++ Writing to destination disk +++',cr,lf,'$'
msgb:	db	'unable to create',cr,lf,'$'
msgc:	db	'error writing file',cr,lf,'$'
msgd:	db	'unable to close',cr,lf,'$'
msge:	db	' sectors written',cr,lf,'$'
msgf:	db	cr,lf,'insert host cp/m disk, type CR$'
msgg:	db	'+++ Reading from source disk +++',cr,lf,'$'
msgx:	db	cr,lf,'$'
msgz:	db	'+++ no file name specified +++$'
;
;
nulls:	db	0,0,0,0
;
	org	($+15)/16*16
;
file$nt:      ds      16*64+1 ;file name table
stack:	      ds      64      ;64 level stack
aval$space:   ds      2       ;available space
mem$size:     ds      2       ;memory size
cmd$buf:      ds      80      ;command buffer
cmd$pt$buf:   ds      2       ;command buffer pointer
file$size:    ds      2       ;file size in sectors
prt$size:     ds      2       ;file size for printout
inp$fil$ntp:  ds      2       ;input fnt pointer
opt$fil$ntp:  ds      2       ;output fnt pointer
mem$pt$buf:   ds      2       ;memory buffer pointer
input$fcb:    ds      33      ;input file control block
output$fcb:   ds      33      ;output file control block
temp$fcb:     ds      33      ;temporary file control block
inp$buf$flg:  ds      1       ;input break flag
opt$buf$flg:  ds      1       ;output break flag
xentry:       ds      2       ;co-resident jmp table entry
;
mbuf:	equ	$
	end	tfx

