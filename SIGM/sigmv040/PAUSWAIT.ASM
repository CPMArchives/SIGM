;
;      PAUSE/WAIT.ASM Version 1.0 as of April 19, 1981
; 
;             by: Kelly Smith, CP/M-Net "SYSOP"
; 
;  This  program  is intended for usage with  SUBMIT.COM  as 
; either a 'PAUSE' (contine SUBMIT file when any key  struck 
; on  your  keyboard)  function,  or as a  'WAIT'  (continue 
; SUBMIT  file when any key struck on your keyboard  OR  the 
; programmable delay (up to 90 seconds) times out) function.
; 
;  PAUSEWAIT.ASM is handy,  if you need time to do something 
; between  functions in your SUBMIT file (i.e,  run  to  the 
; 'frig'  for another beer and don't want to miss  anything, 
; etc.).  This  program was NOT inspired by any direct  need
; for  it,  as much as in RETALIATION to SuperSoft selling a 
; CP/M  utilities  diskette ("...that no programmer  can  be 
; without")  that  includes PUBLIC DOMAIN software  programs 
; like XDIR, SORT, (looks like Ward's SORT-V12 to me), PRINT 
; (probably   from  CPMUG  by  Tony  Gold),   PG   (MLIST42) 
; etc.,etc...really  'ticks-me-off' when I see  stuff  being 
; sold to the people thats FREE...so much for my ranting and 
; raving.  PAUSWAIT.ASM  is intended to go one step  further 
; with SuperSoft's PAUSE utility.  Not to hack SuperSoft too 
; much,  the  DIAGNOSTICS  II software package is  excellent 
; (although  they still don't understand how the  PSW  works 
; for  various 'flavors' of 8080/8085/Z80 CPU's in their CPU 
; test)...Gee, and I said I wasn't going to hack them...
; 
;  PAUSWAIT.ASM  may be assembled for 'PAUSE' by setting the 
; equate 'pause' to TRUE (as supplied here) or assembled  as 
; 'WAIT', by setting the equate 'pause' to FALSE.
; 
;  Additional  conditional  assemblies  may  be  set-up,  by 
; various  TRUE/FALSE configurations for 'upper'  (uppercase 
; only  terminals),   'stdcpm'  (standard  CP/M),   'altcpm' 
; (alternate CP/M),  'mpmprl' (MP/M program relocatable), or 
; 'fastclk' (4 Mhz CPU system clock).
; 
;  When  assembled  as  'PAUSE',  just enter PAUSE  in  your 
; SUBMIT  file...then when it's running,  strike any key  on 
; your keyboard to continue.  When assembled as 'WAIT', just 
; enter  WAIT  1 (for 10 seconds delay) up to  WAIT  9  (you 
; guessed  it,  90 seconds delay) in your SUBMIT file,  then 
; wait  out the programmed delay or strike any key  on  your 
; keyboard  to  continue.  If 'WAIT' does not have  a  value 
; specified  (or you followed it with something  weird),  it 
; defaults to a 90 second delay time...
;
;
;
true	equ	-1	; define true
false	equ	not true; define false
;
pause	equ	true	; true, if "pause" assembly
			; false, if "wait" assembly
upper	equ	false	; true if uppercase only terminal
stdcpm	equ	true	; true if regular CP/M (base address 0000h)
altcpm	equ	false	; true if alternate CP/M (base address 4200h)
mpmprl	equ	false	; true if MP/M program relocatable format
fastclk	equ	false	; true if 4 mhz system clock
;
	if	stdcpm	; if standard CP/M...
base	equ	0000h	; bsae for standard CP/M system
	endif		; end if...
;
	if	altcpm	; if alternate CP/M...
base	equ	4200h	; base for H8 or TRS-80 CP/M system
	endif		; end if...
;
bdos	equ	base+5	; CP/M BDOS entry address for function call
tfcb	equ	base+5ch; transient file control block base address
;
rdcon	equ	1	; read console character
wrcbuf	equ	9	; write buffer contents to console
const	equ	11	; console (data available) status
;
lf	equ	00ah	; (^j) line feed
cr	equ	00dh	; (^m) carriage return
bel	equ	007h	; (^g) bell - human attention required

	if	mpmprl	; if MP/M program relocatable...
	org	base
	endif		; end if...
;
	if	not mpmprl	; if not MP/M program relocatable...
	org	base+100h
	endif		; end if...

	if	pause	; if "pause"
start:	lxi	h,0	; save "old" CP/M stack pointer
	dad	sp
	shld	oldstk
	lxi	sp,stack; make "new" stack pointer
	lxi	d,msg1	; display "Pausing, for any keyboard entry to continue"
	mvi	c,wrcbuf; write console buffer function
	call	bdos	; let CP/M do the work...
pausek:	mvi	c,const	; get console status function
	call	bdos	; let CP/M do the work...
	rrc		; any key struck?
	jnc	pausek	; pause until any key struck, to exit
	mvi	c,rdcon	; read console character function
	call	bdos
	lhld	oldstk	; get "old" CP/M stack pointer
	sphl		; and restore for...
	ret		; return to CP/M
	endif		; end if "pause"
;
	if	pause and upper	; if uppercase only terminal...
MSG1:	DB	BEL,'PAUSING, FOR ANY KEYBOARD ENTRY TO CONTINUE: $'
	endif		; end if...
;
	if	pause and not upper	; if not uppercase only terminal...
msg1:	db	bel,'Pausing, for any keyboard entry to continue: $'
	endif		; end if...

	if	not pause	; if not "pause" assembly
start:	lxi	h,0	; save "old" CP/M stack pointer
	dad	sp
	shld	oldstk
	lxi	sp,stack; make "new" stack pointer
	lxi	d,msg1	; display "Waiting for any keyboard entry, or timeout"
	mvi	c,wrcbuf; write console buffer function
	call	bdos	; let CP/M do the work...
	lda	tfcb+1	; get number of ten second delays required
	sui	'0'	; make hex value from ASCII value
	cpi	1	; < 10 seconds requested?
	jc	timebad	; if so, bad time requested
	cpi	9	; > 90 seconds requested?
	jz	timeok	; if = 90 seconds, that's o.k.
	jc	timeok	; if not, time is o.k.
timebad:lxi	d,msg2	; display "Bad entry equals 90 seconds "
	mvi	c,wrcbuf; write console buffer function
	call	bdos	; let CP/M do the work...
	mvi	a,9	; force 90 second delay on this dummy...
timeok:	sta	cnt	; save number of ten second delays
next:	call	delay	; do ten second delay
	lda	cnt	; de-bump number of 10 second delays to left to do
	dcr	a
	sta	cnt	; and save for next time...
	push	psw	; save temporarily...
	lxi	d,msg3	; display "bel" and ". "
	mvi	c,wrcbuf; write console buffer function
	call	bdos	; let CP/M do the work...
	pop	psw	; get flags, check for all timed out
	jnz	next	; if not timed out, do next 10 second delay
	jmp	exitold	; exit, on CP/M's "old" stack pointer
	endif		; end if...
;
	if	not pause and fastclk	; 4 mhz system clock
delay:	mvi	a,44	; 10 seconds, with 4 Mhz system clock
	endif		; end if...
; 
	if	not pause and not fastclk
delay:	mvi	a,22	; 10 seconds, with 2 Mhz system clock
	endif		; end if...
; 
	if	not pause	; if not "pause" assembly...
delay1:	lxi	h,0
	lxi	d,33	; loop delay value (fine tuned)...
waitcnt:dad	d	; wait between bell rings
	push	psw	; exile all registers
	push	b
	push	d
	push	h
	mvi	c,const	; get console status function
	call	bdos	; let CP/M do the work...
	rrc		; any key struck?
	jc	exit	; exit via CP/M "old" stack pointer, if any key entry
	pop	h	; get all registers back from exile
	pop	d
	pop	b
	pop	psw
	jnc	waitcnt	; minor delay loop done?
	dcr	a	; major delay loop done?
	jnz	delay1	; no, loop
	ret		; return from "delay", no keyboard entry yet
exit:	mvi	c,rdcon	; read console character function
	call	bdos
exitold:lhld	oldstk	; get "old" CP/M stack pointer
	sphl		; and restore for...
	ret		; return to CP/M
	endif		; end if "not pause"
; 
	if	not pause and upper	; if uppercase only terminal...
MSG1:	DB	'WAITING FOR ANY KEYBOARD ENTRY, OR TIMEOUT: $'
;
MSG2:	DB	CR,LF,'BAD ENTRY (MUST BE 1 TO 9) EQUALS 90 SECONDS! $'
	endif		; end if...
;
	if	not pause and not upper	; if not uppercase only terminal...
msg1:	db	'Waiting for any keyboard entry, or timeout: $'
msg2:	db	cr,lf,'Bad entry (must be 1 to 9) equals 90 seconds! $'
	endif		; end if...
;
	if	not pause	; if not "pause" assembly...
msg3:	db	bel,'. $'
;
cnt:	ds	1	; 10 second increments storage counter
	endif		; end if "not pause"

oldstk:	ds	2	; storage for "old" CP/M stack pointer
	ds	32	; storage for 16 level stack
stack	equ	$	; storage for "new" stack pointer
;
	if	mpmprl
	db	0	; force allocation of storage space
	endif
; 
	end	start
