

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;<>******************************************************<>
;<>* 		 					*<>
;<>*	   	          D D D              		*<>
;<>*							*<>
;<>*	            Dysan Corporation       		*<>
;<>*	      Customer Engineering Division		*<>
;<>*	          1244  Reamwood  Avenue		*<>
;<>*		 Sunnyvale, Cal.    94086		*<>
;<>*							*<>
;<>******************************************************<>
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><> 



;	This document contains information developed by
;	Dysan Corporation (Dysan) and is furnished for 
;	information only.

;	Dysan makes no warranty or representation (expressed
;	or implied) with respect to the accuracy, completeness
;	or usefulness of the information contained herein.
;	Further Dysan assumes no responsibility for liability
;	or damage of any kind which may result from the use 
;	of the information contained herein.

;	THIS PROGRAM IS IN THE PUBLIC DOMAIN, AND MAY BE
;			FREELY COPIED AND DISTRIBUTED
;
;



;	****************************************************************
;
;	USAGE:
;
;	To use this program, a digital alignment disk is required.
;	You may purchase the required "Digital Diagnostic Diskette" (tm)
;	directly from Dysan Corporation.  Available DDD(tm) models are:
;
;	SIDES:............SINGLE SIDED.............DOUBLE SIDED
;	DENSITY:......SINGLE(FM) DOUBLE(MFM)...SINGLE(FM) DOUBLE(MFM)
;	SIZE & TPI:
;	8"     48 TPI   808-100   808-200        808-300   808-400
;	5.25"  48 TPI   508-100   508-200        508-300   508-400
;	5.25"  96 TPI   506-100   506-200        506-300   506-400
;	5.25" 100 TPI   CALL FOR AVAILABILITY    CALL FOR AVAILABILITY
;
;
;	PRICES:	 Single Sided - $30.00     Double Sided - $40.00
;		 Plus appropriate sales taxes and shipping costs
;		 Prices and models subject to change without notice
;
;
;	ORDERING:  Contact your local Dysan sales Rep. or call
;		   Inside Northern California:  (408) 988-3472
;		   Outside Northern California: (800) 551-9000
;
;
;	TECHNICAL INFORMATION:  For information regarding DDD(tm)
;				applications contact Dysan's
;				CE Division TECH-LINE: (408)734-1624
;
;



;	****************************************************************
;
;	HISTORY:
;
;	VERSION 1.0: Developed by Dysan for their Single Card Computer
;					and Hazeltine 1500 terminal
;
;	VERSION 1.1: Modified by Loren Amelang, Box 24, Philo, Ca.
;						  95466 0024
;		Added drive selection; commented out code which required
;		a macro assembler (you can now use ASM); substituted 
;		CP/M BDOS calls for version 1.0 BIOS calls; modified cline
;		& its usage for terminals without clear-to-end-of-line;
;		added display of last sectors read; modified disc
;		read routines for CCS 2422 controller and
;		programmed I/O transfer; 
;
;



;	****************************************************************
;
;	ENVIRONMENT:
;	
;	Digital Research's  MAC  macro assembler has
;	been  used to compile this program.
;
;		    Digitial Research
;	              P.O. Box 579
;		  801 Lighthouse Avenue
;		  Pacific Grove, Ca 93950
;		     (408) 649-3896
;
;	This example skeleton program may be used to read
;	the Digital Diagnostic Diskette. Many features can
;	be added to make a more substantial program. The
;	read routines are directed at the 8 inch "DDD",but
;	can be altered for 5 1/4 inch "DDD"
;		
;	The Western Digital 1793 floppy controller has been
;	chosen because of its wide use in micro computers.
;	This program dosn't depend upon this controller, but
;	the controller used must be able to read FM or MFM
;	formats.
;		
;		   Western Digital Corp
;		      P.O. Box 2180
;	           3128 Redhill Avenue
;		  Newport Beach, Cal 92663
;		      (714) 557-3550
;
;	The following features of { DDD } are utilized: 
;		
;			Radial alignment check
;			Azimuth alignment check
;			Centering 
;			Stepper Hysteresis
;			Index Timing
;
;	The RPM check is not a function of the { DDD }.
;
;	Original configuration (Version 1.0):
;
;	A. Hazeltine 1500 Terminal   
;	B. 8080 Assembly language
;	C. Timing based on 4mhz Z80 processor
;	D. Direct Console I/O to CP/M 80
;	E. Disk operations written for Dysan's
;	   Single Card Computer.
;	F. Diagnostic Disk (808-100)
;
;



;	****************************************************************
;
;	PROGRAM SOURCE CODE:
;
;	title	'Drive Diagnostic Program for CP/M 80 1/15/83'
;
;	File ddd.asm
;

wboot	equ	0		; warm boot address

bdos	equ	5		; jump address for bdos calls


**********************
*** "CONDITIONALS" ***
**********************
;
;	Choose the appropriate assemble time options for your system,
;	or use this space to add new system options.
;
true	equ	0ffffh
false	equ	not true
;
Dysan	equ	false	;set this true for Dysan controller
CCS	equ	true	;set this true for CCS 2422 controller 
			;	programmed i/o transfer, etc.
lineclr	equ	false	;set this true if your console has
			;	a clear-to-end-of-line command
Hazel	equ	false	;set this true for Hazeltine 1500 terminal
			;	(requiring "lead-in" to commands)
Loren	equ	true	;set this true for Loren's homebrew terminal...
;
;ADD CONDITIONAL OPTIONS FOR YOUR ENVIRONMENT HERE...
;
;

	
********************************
*** "MACRO CALL BIOS DIRECT" *** 
********************************
;
;	This macro was used in version 1.0 to Link console I/O
;	only, the disk i/o routines also may be linked
;	to CP/M 2.2 with this macro.
;
;	e.g.  gobios 24		; select drive
;
;
;	Function:
;	Loads Warm boot address to bios
;	and computes offset to routine.
;
;
;gobios	macro	@func		
;	lhld	wboot+1		; Warm boot address
;	lxi	d,@func		; Offset
;	dad	d		; Add offset
;	pchl			; Go to bios routine
;	endm


***************************
*** "CONSOLE FUNCTIONS" ***
***************************

;	The following are direct console commands
;	which can be altered for most consoles.

;	note:
;	     The text print routine must be altered
;	     if "Row" is sent before "Column" or 
;            bias is needed.

	if	Hazel		;version 1.0
add$cur equ	17		; address cursor command
clr$co	equ	28		; clear to foreground spaces
lead$in	equ	126		; console lead-in 
end$ln	equ	15		; clear to end of line
	endif

	if	Loren		;version 1.1
add$cur equ	01		; address cursor command
clr$co	equ	05		; clear to foreground spaces
	endif

cr	equ	0dh		; carriage return
lf	equ	0ah		; line feed
esc	equ	1Bh		; escape
bs 	equ	8		; back space
bell	equ	7		; audio alert


****************************************
*** "FLOPPY CONTROLLER PORT EQUATES" ***
****************************************

;	Change the following Port assignments for
;	Your system.
;
;	"FDC"  Acronym  Floppy Disk Controller
;
;	FDC port assignments:
;
	if	Dysan		;version 1.0
fdc 	equ	0f8H		; Base port address FDC
;
cmd	equ	fdc		; command reg.
stat  	equ	fdc		; status reg.
trk	equ	fdc+1		; track reg.
sec	equ	fdc+2		; sector reg.
data	equ	fdc+3		; data reg.
dma 	equ	fdc+4		; Dma controller
dsel	equ	fdc+5		; drive select
	endif

	if 	CCS		;version 1.1
fdc 	equ	30H		; Base port address FDC
;
cmd	equ	fdc		; command reg.
stat  	equ	fdc		; status reg.
trk	equ	fdc+1		; track reg.
sec	equ	fdc+2		; sector reg.
data	equ	fdc+3		; data reg.
dma 	equ	004CH		;memory address of pointer to 
;                                          sector buffer
dsel	equ	fdc+4		; drive select port:
				;output BX for single density
				;       FX for double density
				;   where X = 1 for drive A
				;             2 for drive B
				;             4 for drive C
				;             8 for drive D
	endif
	
************************************
*** "FLOPPY CONTROLLER COMMANDS" ***
************************************

;	These are common to most systems using the 1793.
;	sdma is a Dysan controller command, ignored in V. 1.1.

clear	equ	0d0h		; clear FDC
sdma    equ	87h		; Start Dma Transfer
rsec	equ	80h		; read sector
raddr	equ	0c0h		; read address
seek	equ	18h		; seek track
restore	equ	8		; home Head(s)
sdelay	equ	4		; seek delay flag

*************************************
*** "FLOPPY CONTROLLER VARIABLES" ***
*************************************

rate	equ	1		; step rate 
retry	equ	1		; read retries
fdelay	equ	11	; FDC delay
			; see "delay" routine - this value is for
			; 4 Mhz. Z-80;  adjust here or in "delay"
			; to suit your clock and processor...
indxbyt	equ	2	; byte in status reg. when index hole
			; is passing sensor
busybyt	equ	1	; byte in status reg. when controller
			; is busy
drqbyt	equ	2	; byte in status reg. when data is 
			; waiting to be read by the computer

******************************
*** "DDD DISKETTE EQUATES" *** 
******************************

;	Adjust to match your diskette size and format.

ttrk 	equ	76		; total number of tracks
sectors	equ	26		; sectors per track
				; 26 for 8" DDD, 16 for 5.25" DDD
lneg	equ	sectors+2		; last neg. sector +2
lpos	equ	sectors+1		; last pos. sector +2
tsec	equ	(sectors/2)-1	; centering test

	if 	Dysan
ref	equ	798		; reference time (single Den)
				; (used in "index 7")
	endif

	if	CCS
ref	equ	24eh		; experimentally determined...
	endif



***************************
*** "MAIN PROGRAM LOOP" *** 
***************************

	org	100h
;	====	====
	lxi	sp,stack	; init stack
	call	select		; select drive
;
main:
	lxi	sp,stack	; reset stack 
	call	cls		; clear display
	lxi	h,me1		; display Menu..
	call	text
	call	ci		; selection?
	cpi	'R'		; "Radial"
	jz	radial 		   
	cpi	'A'		; "Azimuth"
	jz	azimuth
	cpi	'C'		; "Centering"
	jz	center
	cpi	'H'		; "Hysteresis"
	jz	hyster 
	cpi	'S'		; "RPM"
	jz	rpm
	cpi	'I'		; "Index"
	jz	index
	cpi	'D'		;"Drive Select"
	jnz	ex
	call	select
	jmp	main		;new drive selected - get option

ex:	cpi	'E'		; "Exit to DOS"
	jz	exit 		
	mvi	a,bell		; Not valid
	call	co
	jmp	main		; try again...


**********************
*** " EXIT TO DOS" ***
**********************

exit:
	call	cls		; clear display
	jmp	wboot

*************************
*** "CONSOLE  STATUS" ***   
*************************

;	returns with zero status flag set.
 
cstat:
	push	h		; save all registers
	push	d
	push	b
;	call	cstat1		; Data ready?
	mvi	c,11		; BDOS console status
	call	bdos		; function call added for V1.1
	pop	b
	pop	d
	pop	h
	ora	a
	ret
;cstat1:
;	gobios	3		; macro

***********************
*** "CONSOLE INPUT" *** 
***********************
;
;	Returns character in "A" reg.
ci:
	push	h		; Save all registers
	push	d
	push	b
;	call	ci1		; take  character 
	mvi	c,1		; BDOS console input
	call	bdos		; function call added for V1.1
	pop	b
	pop	d
	pop	h
	cpi	esc		; Exit?
	jz	main 		; YES!
	cpi	'a'		; convert to upper case
	rc			; only...
	cpi	'{'
	rnc
	ani	'^'+1		
	ret

;ci1:
;	gobios	6		; macro



************************
*** "CONSOLE OUTPUT" *** 
************************
;
;	Enter with character in "A" reg.

co:
	push	psw
	push	h		; save all registers
	push	d
	push	b
;	mov	c,a		; Pass char in "C" reg
	mov	e,a		; Pass char in "E" reg for V1.1
	mvi	c,6		; BDOS direct console i/o
	call	bdos		; function call added for V1.1
;	call	co1		
	pop	b
	pop	d
	pop	h
	pop	psw
	ret

;co1:
;	gobios	9		; macro


********************
*** "LINE INPUT" ***
********************

;	used to input data greater then one
;	character which is terminated by "CR".
;	(used only by "offset:" directly below here...)

getln:
;	lxi	d,buffer	; input buffer

; Following code added to V1.1 to use standard BDOS call for Line Input:
	lxi	d,inbuf		; input buffer in BDOS 10 format
	mvi	c,0Ah		; Console Input Line function
	call	bdos		; added for V 1.1
	lhld	incnt		; get # of characterrs read
	mvi	h,0		; incnt is only one byte...
	xchg			; move to de reg
	lxi	h,buffer	; get text buffer address
	dad	d		; increment buffer pointer by # chars
	mvi	m,0dh		; place "cr" after valid chars
				; 	as V1.0 expects...
	ret
;
;gl1:	
;	call	ci		; Wait for Input
;	cpi	lf		; Line feeds Not allowed
;	jz 	gl1
;	cpi	'_'		; treat as back space
;	jz 	back
;	cpi	bs		; check for back space
;	jz 	back
;	cpi	7fh		; Delete char?
;	jz 	back
;	cpi	cr		
;	jz 	gl2
;	cpi	' '
;	jc 	gl1		; control Characters Not allowed
;;
;gl2:
;	stax	d		; store char
;	inx	d		; next address
;	call	co		; echo char
;	cpi	cr		; end of Line?
;	rz			; Yes!
;	lxi	h,buffer+4	; end of Buffer
;	call	dehl		; check 
;	jnz 	gl1		; No!
;	jnz 	gl1		; No!
;	jnz 	gl1		; No!
;;
;back:
;	lxi	h,buffer	; can backup ?
;	call	dehl
;	jz 	gl1		; NO!
;	dcx	d		; Backup text pointer
;	mvi	a,bs		; backup cursor
;	call	co
;	mvi	a,' '		; store Space
;	call	co
;	mvi	a,bs		; adjust cursor
;	call	co
;	jmp	gl1		; New char

**********************************
*** "BIAS FROM SELECTED TRACK" ***
**********************************
;
;	Sets the required offset for Hysteresis
;	test.

offset:
	call	cls		; clear display
	lxi	h,me6		; OFFSET?
	call	text
	call	getln		; Input offset
	call	getnum		; convert to hex
	cpi	cr		; at end of line?
	jnz	offset1		; error...
	mov	a,h		; check Limits 
	ora 	a
	jnz	offset1
	mov	a,l
	cpi	ttrk+1		; Greater then last track?
	jnc	offset1
	sta	bais		; save offset 
	ret
;
offset1:
	mvi	a,bell		; alert operator
	call	co
	jmp	offset


*******************************
*** "INPUT TRACK LOCATIONS" *** 
*******************************

;	Input track locations for Radial
;	Hysteresis,Centering and Index tests.
;	"B" contents Upper Limit upon entry.

inp$trk:
	call	cls		; clear display...
	call	text
;
inp$trk1:
	call	ci		; waiting...
	cmp	b  		; within limits?
	jnc	inp$trk2	; no... 
	sui	'A'		
	jc	inp$trk2	; try again  
	lhld	temp     	; table pointer
	mvi	d,0
	mov	e,a
	dad	d		; add offset
	mov	a,m		; load track
	jmp 	track		; seek to track
;
inp$trk2:
	mvi	a,bell		; alert
	call	co
	jmp	inp$trk1	; try again...

***********************************************
*** "RADIAL AND HYSTERESIS TRACK LOCATIONS" ***
***********************************************

rh$tbl
	db	0		
	db	3
;	Note:  some Dysan spec sheets list track 5 rather 
;	than 3 as an index track - my Revision A DDD definitely
;	uses track 3...  LA.
	db	38
	db	41
	db	70
	db	73

***************************   
*** "INDEX TRACK TABLE" *** 
***************************   

ix$tbl:
	db	0
	db	76

*************************
** "CENTERING TRACKS" ***
*************************

cen$tbl:
	db	35
	db	44
	db	47


*******************************
*** "PRINT DECIMAL NUMBERS" *** 
*******************************
;
;	Enter with number to be printed in
;	'DE' reg.

pnum:
	push	h		; Setup Stack
	lxi	h,10		; Terminator...
	push	h
	push	h
;
pn1:	
	call	div16		; Divide Number By (10)
	mov	a,d		; Check result
	ora	e		; = 0
	jz 	pn2
	xthl
	dcr	l
	push	h
	lxi	h,10
	jmp	pn1		; Divide Again
;
pn2:
	pop	d		; Display Values
	mov	e,l
;
pn3:
	mov	a,e		; Check for Terminator (10)
	cpi	10
	pop	d		; Next digit 
	rz
	adi	'0'		; Add ascii Bias
	call	co
	jmp	pn3		


****************************
*** "16 BIT SUBTRACTION" *** 
****************************
;
;	Subtract "DE" from "HL"
subde:	
	mov	a,l		
	sub	e
	mov	l,a		
	mov	a,h		
	sbb	d
	mov	h,a		
	ret


************************************************
*** "CONVERT ASCII DECIMAL NUMBER TO BINARY" ***    
************************************************
;
;	Returns 16 bit hex value in "HL" regs.

get$num:
	call	sksp		; Skip Spaces and Return Char
	lxi	h,0		; Clear counter
	mov	b,h		; Clear "B"
;
get$num1:
	cpi	cr		; end of line?
	cpi	'0'		; less than
	rc			; yes Error!
	cpi	':'		; Upper Limit
	rnc			; Returns "CR"
	mvi	a,0f0h		; mask Upper Nibble
	ana	h
	rnz			
	inr	b		; +1
	push	b		; Save count..
	mov	b,h
	mov	c,l		; Swap "HL" with "BC"
	dad	h
	dad	h
	dad	b
	dad	h
	ldax	d		; Load Same Char..
	inx	d		; next Char 
	ani	0fh		; Mask Lower Nibble
	add 	l
	mov	l,a		; save result
	mvi	a,0		; Clear "A"
	adc	h		; Add carry
	mov	h,a
	pop	b		; restore counter..
	ldax	d		; Load next Char..
	jmp	getnum1 
	
*****************************************
*** "SKIP OVER SPACES IN TEXT BUFFER" *** 
*****************************************

sksp:
	lxi	d,buffer	; point to text buffer
;
sksp1:
	ldax	d  		; check for Space
	cpi	' '		; First Non Space return
	rnz
	inx	d
	jmp	sksp1

*****************************
*** "COMPARE "DE" TO "HL" ***   
*****************************

dehl:
	mov	a,l		; compare "E" to "L"
	cmp	e		; If not zero return
	rnz
	mov	a,h
	cmp	d 
	ret



**********************************
*** "16/24 BIT DIVIDE ROUTINE" ***
**********************************

;	Divide "HL" by "DE"
;

div16:	
	xra	a		; optional 16 bit divide
;
div24:	
	sta	msb		; Normal 24 bit divide
	shld	msb1
	lxi	h,msb2
	mvi	m,24+1
	lxi	b,0
	push	b
div25:	
	mov	a,e
	ral
	mov	e,a
	mov	a,d
	ral
	mov	d,a
	lda	msb
	ral
	sta	msb
	dcr	m
	pop	h
	rz
	mvi	a,0
	aci	0
	dad	h
	mov	b,h
	add	l
	lhld	msb1
	sub	l
	mov	c,a
	mov	a,b
	sbb	h
	mov	b,a
	push	b
	jnc	div26
	dad	b
	xthl
;
div26:	
	lxi	h,msb2
	cmc
	jmp	div25



******************************
*** "CLEAR CONSOLE DISLAY" *** 
******************************

;	Clear console to foreground spaces.
 
cls:
	if 	Hazel
	mvi	a,lead$in	; lead in 
	call	co
	endif

	mvi	a,clr$co	; clear to foreground spaces
	jmp 	co

****************************
*** "CLEAR DISPLAY LINE" ***
****************************

cline:
	if 	lineclr
	mvi	a,0		; starting column
	sta	column
	lxi	h,set$cur	; set cursor
	call	text
	endif
	
	if 	Hazel AND lineclr
	mvi	a,lead$in	; lead in byte
	call	co
	endif

	if	lineclr
	mvi	a,end$ln	; clear to end of line
	call	co
	endif

	if	NOT lineclr
	mvi	a,11		; starting column
	sta	column
	lxi	h,set$cur	; set cursor
	call	text
	lxi	h,blanks	;address of a string of 56 blanks...
	call	text
	endif

	ret

*************************
*** "FATAL ERROR MSG" ***
*************************

fatal:
	if 	lineclr
	call	cline		; clear line
	endif

	mvi	a,30		; column position
	sta	column
	lxi	h,set$cur
	call	text
	lxi	h,me2		; Fatal error msg
	call	text
	ret


******************************
*** "PRINT STRING OF TEXT" *** 
******************************

;	Enter with "HL" pointing to text string,
;	terminate string with Null.
;
;	Direction cursor position is used for displays.
;	The value (-1) at the start of string indicates 
;	to this routine
;	that column and row position will follow.
;	This format does not necessarily go out to 
;	your terminal.   If your terminal needs row sent before column, 
;	or a constant bias added (0,0 is not the upper left
;	corner of the screen), you'll have to invent code
;	within this routine to accomplish that.
;
;	This is the internal representation format:
;	     db -1,50,10,'NOW IS THE TIME'
;		 ^  ^  ^
;		 |  |  |_Row position (add bias if needed)
;		 |  |_Column position (add bias if needed)
;		 |_Flag (send console lead-in sequence.

text:
	mov	a,m		; load char.
	ora	a		; end of string?
	rz			; yes
	cpi	(-1) AND 0FFH	; position cursor?
				; "and offh" added for ASM compatibility
	jz	text1		; yes
	inx	h		; next char.
	call	co		; output
	jmp	text
;
text1:
	inx	h		; move passed command

	if 	Hazel
	mvi	a,lead$in	; leading for console
	call	co		; issue.
	endif

	mvi	a,add$cur	; address cursor
	call	co
	mov	a,m		; column position...
	inx	h
	call	co
	mov	a,m		; row position
	call	co
	inx	h		
	jmp	text		 

*************************
*** "CENTERING CHECK" *** 
*************************

;
;	Centering test requires the FDC to read
;	all the sectors before diskette centering
;	is consider OK.

center:
	lxi	h,cen$tbl	; track table
	shld	temp
	lxi	h,me9		; tracks with 
	mvi	b,'D'		; limit
	call	inp$trk		; seek track  
	call	cls		; clear display
	lxi	h,me10		; centering msg.
	call	text
	lxi	h,me15		; frame
	call	text
	lxi	h,me11		; New track msg
	call	text
;
center1:
	call	rd$trk		; read centering track
	mvi	a,10		; set row position
	sta	row		
	jc	center3		; fatal error..

	if 	lineclr
	call	cline		; clear line
	endif

	mvi	a,30		; set cursor...
	sta	column		; column position
	lxi	h,set$cur
	call	text
	lda	diff 		; must = 0
	ora	a
	lxi	h,me3		; "RE-CLAMP DISKETTE"
	jnz	center2
	mov	a,c
	cpi	tsec      	; all sec read? 
	jnz	center2
	lxi	h,me4		; "CENTERING OK"
;
center2:
	call	text
	call	cstat		; abort?
	jz	center1
	call	ci
	cpi	' '		; new track?
	jnz	center1		; no...
	jmp	center		; yes..
;
center3:
	call	fatal		; fatal error
	jmp	center2


*********************************
*** "AZIMUTH ALIGNMENT CHECK" *** 
*********************************

azimuth:
	call	cls		; clear display...
	mvi	a,76		; seek to azimuth track
	call	track		; move...
	lxi	h,me12		; type of test msg
	call	text
	lxi	h,me15		; frame
	call	text
;
azimuth1:
	lxi	h,azi$tab	; set translation table 
	shld	xpoint		; pointers
	shld	ypoint
	call	rd$trk		; read azimuth track
	mvi	a,10		; set row position
	sta	row		
	jc	azimuth3	; fatal error...

	if	lineclr
	call	cline		; clear line
	endif

	mvi	a,20		; Display negative angle
	sta	column
	lxi	h,set$cur	; set cursor
	call	text
	mvi	a,'-'		; direction of angle
	call	co		; output...
	mvi	a,' '		; space
	call	co
	lhld	ypoint		; translation
	mov	e,m		; data negative...
	mvi	d,0
	call	pnum		; display
	lxi	h,me5		; print minutes
	call	text
	mvi	a,45		; Display Positive angle
	sta	column
	lxi	h,set$cur
	call	text
	mvi	a,'+'		; direction of angle
	call	co		; output...
	mvi	a,' '		; space
	call	co
	lhld	xpoint		; translation
	mov	e,m		; data positive..
	mvi	d,0
	call	pnum		; display
	lxi	h,me5		; print minutes
	call	text
;
azimuth2:
	call	cstat		; abort?
	jz	azimuth1
	call	ci		; test...
	jmp	azimuth1	; no..
;
;	Fatal error Has occurred
;
azimuth3:
	call	fatal		; fatal read error
	jmp	azimuth2


********************************
*** "RADIAL ALIGNMENT CHECK" *** 
********************************


radial:
	lxi	h,rh$tbl	; table pointer
	shld	temp
	lxi	h,me7		; track display..
	mvi	b,'G'		; limit  
	call	inp$trk		; select track and seek
	call	cls
	lxi	h,me8		; print scale...
	call	text
	lxi	h,me11		; Space bar msg
	call	text
;
radial1:
;
	lxi	h,rad$pos	; radial positive 
	shld	xpoint		; cursor table
;
	lxi	h,rad$neg	; radial negative
	shld	ypoint		; cursor table
;
	call	rd$trk		; read radial track
	mvi	a,11		; set row position
	sta	row
	jc	radial4		; Fatal error has occurred
	call	cline		; clear line (1)
	lda	row		
	push	psw		  
	inr	a		; clear line (2)
	sta	row		
	call	cline
	pop	psw		; reset line position
	sta	row
	lhld	ypoint 		; negative 
	mov	a,m
	sta	column		; position cursor
	mov	b,a 
	lxi	h,set$cur	
	call	text
	mvi	a,'^'		; set pointer
	call	co
	lhld	xpoint
	mov	a,m		; positive position
	sta	column 		
	mov	c,a		; save cursor position 
	lxi	h,set$cur	; set cursor
	call	text
	mvi	a,'^'
	call	co
	mov	a,b		 
	sta	column		; reset column position
	lda	row		; down one line
	inr	a
	sta	row


************************************
*** "SET POINTERS AND DRAW LINE" ***
************************************

;	used to draw the graphic display of the
;	radial error.

	lxi	h,set$cur	; position cursor
	call	text
	mov	a,c
	sub	b		; line length
	dcr	a		; less (1)
	mov	b,a
	mvi	a,'|'		; pointer...
	call	co
;
radial2:
	mvi	a,'_'		; jointing line
	call	co
	dcr	b		; line length -1
	jnz	radial2
	mvi	a,'|'
	call	co
;
radial3:
	call	cstat		; check for abort
	jz	radial1		; read again
	call	ci		; new track?
	cpi	' '		
	jnz	radial1		; no...
	jmp	radial		; new track...
 
****************************
*** "FATAL RADIAL ERROR" ***
****************************

radial4:

	if	lineclr
	call	cline		; clear display
	lda	row		; next line
	inr	a		
	sta	row
	call	cline
	endif

	call	fatal		; fatal read error
	jmp	radial3		; abort?


**********************************
*** "STEPPER HYSTERESIS CHECK" ***
**********************************

;
;	This routine uses one of the progressive offset
;	tracks to determine the stepper motor hysteresis.

hyster:
	lxi	h,rh$tbl	; table pointer
	shld	temp
	lxi	h,me7		; track msg
	mvi	b,'G'		; limit
	call	inp$trk		; seek track
	call	offset		; offset from
	call	cls		; selected track.
	lxi	h,me14		; display test
	call	text
	lxi	h,me15		; frame
	call	text
	lxi	h,me11		; new track Msg.
	call	text
;
hyster1:
	lda	bais		; offset from track
	mov	b,a
	lda	ctrk		; save current track
	sta	savtrk
	add	b		; add bais to current track
	cpi	ttrk  		; within limits?
	jc 	hyster2		; OK!
	mvi	a,ttrk  	; set last track
;
;	Move to (ID) inside diameter

hyster2:
	call	track		; seek to track
	lda	savtrk		; back to test track
	call	track		; seek...
	call	rd$trk		; read track...
	mvi	a,10		; set row 
	sta	row
	jc	hyster8		; fatal error!!!
	lda	diff 		; difference
	sta	hyerr		; save the difference

;	Move to (OD) outside Diameter

	lda	bais		; tracks to move
	mov	b,a
	lda	ctrk		; current track
	sub	b
	jnc	hyster4		; Ok to move
	xra	a		; set to track (0)

;
hyster4:
	call	track		; seek to track
	lda	savtrk		; back to test track
	call	track		 
	call	rd$trk		; read track 
	mvi	a,10		; set row 
	sta	row
	jc	hyster8		; fatal Error!!
	lda	hyerr		; load error First 
	mov	c,a		; read operation
	lda	diff 		; last reading
	sub	c
	jp	hyster6
	cma	
	inr	a
;
hyster6:
	call	hyster9
;
hyster7:
 	call	cstat		; abort?
	jz	hyster1		; re-test
	call	ci		  
	cpi	' '		; new parameters
	jz	hyster 
	jmp	hyster1		; new track and offset
;
hyster8:
	call	fatal		; fatal read error
	call	home		; recal.drive
	jmp	hyster7


**********************************
*** "DISPLAY HYSTERESIS ERROR" ***
**********************************
;
;	Presently setup for 48 tpi drives
;	with increments in .5 millinches.

hyster9:
	push	psw		; save error

	if 	lineclr
	call	cline		; clear display
	endif

	mvi	a,25	 	; set column
	sta	column
	lxi	h,set$cur
	call	text
	lxi	h,me16		; Hysteresis error msg
	call	text
	pop	psw
	ora	a
	jz 	hyster11
	mov	c,a		; count
	mvi	b,5		; increments
	xra	a		; clear acc.
;
hyster10:
	add	b
	daa			; decimal adjust
	dcr	c
	jnz	hyster10
;
hyster11:
	push	psw
	ani	0f0h		; mask upper nibble
	rar!rar!rar!rar
	adi	'0'		; add ascii bais
	call	co
	mvi	a,'.'		; decimal point
	call	co
	pop	psw
	ani	0fh
	adi	'0'
	call	co
 	ret



**********************
*** "INDEX TIMING" *** 
**********************

;
;	This function computes the time from leading
;	edge of index to first sector ID mark
;	and displays it in 10.0 Us. increments
;	note:
;	     (Dysan AAD disk) is used for reference.
index: 
	mvi	a,10		; set row
	sta	row
	lxi	h,ix$tbl	; track table
	shld	temp
	lxi	h,me13		; track locations
	mvi	b,'C'
	call	inp$trk		; move to Index track
	call	cls		; clear display..
	lxi	h,me17		; display scale
	call	text
	lxi	h,me15
	call	text
	lxi	h,me11		
	call	text
;
index1:
	lxi	h,0		; clear counter
	shld	temp		
	mvi	c,5		; average (5) readings
;
index2:
	call	clpend		; clear FDC
	call	prg$dma		; program controller
	lxi	d,0		; clear counter
;
index3:
	in	stat		; wait for next Index
	ani	indxbyt		
	jnz 	index3

;	Compute time from index to ID 

index4:
	in	stat		; loop until next
	ani	indxbyt		; index...
	jz 	index4		
;
;	Read address..
;
	nop			; 1.00
	mvi	a,raddr		; 1.75
	out	cmd		; 2.75
	call	delay		; [ 50 usec ]

	if	Dysan
	mvi	a,sdma		; 1.75
	out	dma		; 2.75
	endif

	if	CCS
;
;	10 Usec Test cnt. loop
index5:
	inx	d		; 1.50 [ counter ]
	inx	h		; 1.50
	in	stat		; 2.75 
	ani	drqbyt		; 1.75 - loop until drq set...
	jz	index5		; 2.50
	LHLD	DMA
	IN	DATA
	MOV	M,A
	INX	H
	IN	DATA
	MOV	M,A
	INX	H
	IN	DATA
	MOV	M,A	
	INX	H
	IN	DATA
	MOV	M,A
	INX	H
	IN	DATA
	MOV	M,A
	INX	H
	IN	DATA
	MOV	M,A
	endif


	if 	Dysan
;
;	10 Usec Test cnt. loop
index5:
	inx	d		; 1.50 [ counter ]
	inx	h		; 1.50
	in	stat		; 2.75 
	ani	busybyt		; 1.75 - loop until not busy
	jnz	index5		; 2.50
	endif
;
index6:
	lxi	h,6		; adj. over head
	dad	d		; error (60usec)
	xchg
	lhld	temp
	dad	d		; add cnt
	shld	temp
	dcr	c		; next reading
	jnz	index2
	xchg
	lxi	h,5		; divide by 5
	call	div16 
	dad	d		; add remainder
	xchg
	lxi	h,0		; counter...
	lda	secbuf+2	; must contain sec (1) ID
	cpi	1
	jnz	index9		; out of range
	mvi	a,10		; loop time * cnt
index7:
	dad	d
	dcr	a
	jnz	index7
	lxi	d,ref   	; Timing ref  
				; Value of ref is in DDD variable
				;equates... it is subtracted from
				;the measured # of microsec. here
				;to adjust timing to a standard
				;Analog Alignment Diskette...
	; If you have a 4 Mhz. Z-80 and single density DDD
	; and are using the Dysan environment, 798 is the 
	; magic number.  Otherwise you'll have to "cut and try"
	; and without the AAD you'll have to guess...
	; (A relative measure is better than no measure...)
	call	subde		
	xchg			
	jnc	index8
	mov	a,e
	cma
	mov	e,a
	mov	a,d		; negate "DE"
	cma
	mov	d,a
	inx	d
	lxi	h,200		; 200 - error
	call	subde
	jnc	index9
	lxi	h,0		; out of range
	jmp	index9
;
index8:
	lxi	h,200		; 200  + error
	dad	d
;
index9:
	xchg
	push	d

	if	lineclr
	call	cline		; clear line
	endif

	mvi	a,25
	sta	column
	lxi	h,set$cur	; position cursor
	call	text
	lxi	h,me18		; time in MS.
	call	text
	pop	d
	call	pnum		; display time...
	call	cstat		; abort?
	jz	index1		; re-test
	call	ci		; esc?
	cpi	' '		; new track?
	jz	index 		; yes..
	jmp	index1		; new track...
 

*****************************
*** "CHECK SPINDLE SPEED" *** 
*****************************
;
;	All timing is based on 4mhz Z80 Cpu
;
rpm:
	call	cls		; clear display
	lxi	h,me19		; test performed
	call	text
	lxi	h,me15		; frame...
	call	text
	mvi	a,10		; set row
	sta	row
;
rpm1:
	call	rpm2		; compute time in 100us increments
	shld	temp 		; store count

	if	lineclr
	call	cline		; clear line
	endif

	mvi	a,19		; set cursor  
	sta	column
	lxi	h,set$cur
	call	text
	lhld	temp
	xchg			; convert to milliseconds
	lxi	h,10
	call	div16			  
	push	h		; Save remainder
	call	pnum
	mvi	a,'.'		; decimal point
	call	co     
	pop	h
	xchg
	call	pnum		; fraction
	lxi	h,me20		; milliseconds msg
	call	text
	mvi	a,50
	sta	column
	lxi	h,set$cur
	call	text
	lhld	temp 		; convert to RPM 
	mvi	a,9		; divide By 600,000
	lxi	d,27c0h
	call	div24
	push	h		; remainder
	call	pnum
	mvi	a,'.'		; fraction
	call	co
	pop	h
	xchg
	call	pnum
	lxi	h,me21		; rpm msg
	call	text
	call	cstat		; abort?
	jz	rpm1		; No..
	call	ci		; Esc key?
	jmp	rpm1		; No..


*******************************
*** "INDEX TO INDEX TIMING" ***
*******************************

;
;	With 4 Mhz. Z-80,
;	returns time in 100 Us increments to caller
;	in "HL" regs.

rpm2:
	call	clpend  	; Clear pending commands
	lxi	h,0		; Clear Counter
rpm3: 
	in 	stat   		; Loop Until Index
	ani	2		; Mask All But Index Bit
	jnz 	rpm3 		; No Index
rpm4:
	in 	stat   		; if Index...
	ani	2		; Wait for No Index
	jz  	rpm4		; In Index Hole

;	Add index hole to count
rpm5: 
	call	rpm7 		; 4.25
	in 	stat   		; 2.75
	ani	2		; 1.75
	jnz	rpm5 		; 2.50
				; Total = 11.25
;	Count until  next Index
 
rpm6: 	
	call	rpm7 		; 4.25
	in 	stat		; 2.75
	ani	2		; 1.75
	jz	rpm6 		; 2.50
	ret			; total = 11.25

*************************
*** "RPM TIMING LOOP" *** 
*************************
;
;	The loop time must be adjusted for 100us  
;	increments at your clock speed with your processor.
;	
;	note:	"RPM5 or RPM6" loop time must be counted.
;

rpm7:				
	inx	h		; 1.50 
	mvi	a,22		; 1.75 
;
rpm8: 
	dcr	a		; 1.00  (22 * 1.00) = 22 Usec
	jnz	rpm8 		; 2.50  (22 * 2.50) = 55 Usec
	inx	d		; 1.50
	inx	d		; 1.50
	inx	d		; 1.50
	inx	d		; 1.50
	ret			; 2.50
				; total = 88.75  


************************
*** "READ DDD TRACK" *** 
************************
;
;	Att: Main read routine for program.
;	     ==============================
;
;	Reads the Positive and Negative offset
;	sectors and returns pointers to the   
;	translation tables set by caller.
;

rd$trk:
	MVI	A,7	;Upper case code adds a simple display of
			;	last sector read (+ & -), giving
			;	? and @ if first sectors fail
			;	and A thru Z representing the 26
			;	possible sectors on an 8" disk
			;	or A thru P for a 5.25" disk
	STA	ROW
	MVI	A,39
	STA	COLUMN
	LXI	H,SET$CUR
	CALL	TEXT
	mvi	c,lpos		; last sector
	mvi	a,1		; beginning sector positive
	call	rd$sec 		; read positive offsets
	ADI	3eH	; translate sector # to alpha code */
	CALL	CO	; display on console  */
	SUI	3eH	; return to sector # */
	cpi	1		; unable to read
	jz 	rd$trk2		; first sec?
	sta	diff 		; store last sector tested
	mvi	c,lneg
	mvi	a,2		; beginning sector negative
	call	rd$sec 		; read negative offsets 
	ADI	3eH
	CALL	CO
	SUI	3eH
	cpi	2		; fatal error?
	jz	rd$trk2		; set error flag
;
;	Positive sector Translation
;
	lda	diff  
	inr	a		; adj. sector Num.
	sui	4		
	rar			; divide by two
	lhld	xpoint		; translate Table pointer
	mvi	d,0		; setup for Offset
	mov	e,a 
	dad	d		; add offset
	shld	xpoint		; set pointer
;
;	Negative Sector Translation

	in	sec		; last sector
	sui	4		
	rar 			; divide by two
	mov	c,a
	sub	e		; diff. for Hysteresis
	sta	diff 	
	mov	e,c		; offset
	lhld	ypoint		; translation table pointer
	dad	d		; offset in table
	shld	ypoint		; set pointer
	ora	a		; clear carry
	ret

;	Set fatal error Flag, caller processes
;	the error.

rd$trk2:
	stc			; carry = Fatal error
	ret
	


*******************************************
*** "READ SECTORS BY INCREMENTS OF TWO"	***
*******************************************

;
;	Enter with first sector to be read in 'A' reg.
;	Returns to caller on Error or Last sector.
;	note:
;	    Z flag set if good read else Nz
rd$sec: 
	call	read		; read sector
	in	sec  		; current sector
	rnz
	adi	2
	out	sec
	cmp	c		; last sec?
	rz			; yes...
	jmp	rd$sec

********************************************************
***  "THE FOLLOWING ARE HARDWARE DEPENDENT ROUTINES" ***
********************************************************
;
;
**********************
*** "DRIVE SELECT" *** 
**********************
;
;	The drive select routine must be expanded  
;	for selected systems. 

select:

	if	Dysan
	mvi	a,21h		; select bits
	out	dsel		; select drive...
	endif


	if	CCS	;The upper case code performs drive 
			; selection on the CCS 2422 controller
			; for single side double density...
	CALL	CLS	; clear console */
	LXI	H,SELMSG
	CALL	TEXT	; print drive selection request */
	CALL	CI	; get response */
	CPI	'A'	; accept A,B,C,D, as responses */
	JZ	SELECT1
	JC	SELECT
	CPI	'B'
	JZ	SELECT1
	CPI	'C'
	JZ	SELECT3
	CPI	'D'
	JZ	SELECT4
	JMP	SELECT	; repeat if invalid choice */

	
SELECT4:ADI	3	; make low nybble an 8 */
SELECT3:INR	A	; make a 4 */
SELECT1:SUI	'@'	; make B into 2 or A into 1 */
	ORI	0F0H	; add high nybble: */
			; F for double density, B for single
	STA	SELPT	; store select bits for future use... */
	OUT	DSEL
	MVI	A,40H	; select side 0...  00 selects side 1... */
	OUT	04	; secondary control port */
	endif
	
	jmp	home		; home drive

*******************************
*** "SEEK HEAD(S) TO TRACK" *** 
*******************************
;
;	Enter with new track location in
;	'A' register.

track:
	out	data		; new track
	call	clpend		; clear FDC
 	mvi	a,seek+rate	; seek command + step rate
;
track1:
	out	cmd		; issue...

	if 	Dysan
	call	delay		; delay for FDC	
	endif

	if	CCS	;This controller seems to need more 
			; delay - I can't explain why... LA.
	call	delayB		; delay for FDC	
	endif

;
track2:
	in	stat		; busy ?
	rrc			; test
	jc	track2		; still busy...
	mvi	a,sdelay	; set seek delay bit
	sta	dflag
	in 	trk		; set current track
	sta	ctrk
	ret

	if	CCS
DELAYB:	PUSH	B	; extra delay for CCS controller... */
	LXI	B,2000H
	
DELAYC:	DCX	B
	MOV	A,C
	ORA	B
	JNZ	DELAYC
	POP	B
	RET
	endif


***************************************
*** "RESTORE HEAD(S) TO TRACK ZERO" ***
***************************************

home:
	call	clpend		; clear FDC
	mvi	a,restore+rate	; restore command + step rate
	jmp	track1		; issue command...

*****************************
*** "READ SECTOR ROUTINE" *** 
*****************************

;	Enter this routine with the sector to
;	be read in the 'A' register.
;
;	This routine will keep trying to read
;	the sector until retry count equals zero.
;
;	The 1793 controller has a built-in automatic
;	four retries to read ID, so the value set in
;	the equate (RETRY) is equal to [ 4 * retry + 1].

read:
	out	sec		; set sector  
	mvi	e,retry		; to read
;
read1:
	call	clpend		; clear FDC
	call	prg$dma		; program "DMA" controller

	if 	CCS
	LHLD	DMA	; get pointer to memory buffer */
	MVI	B,40H	; initialize loop counter for I/O */
			;transfers: 40 for 8" DD, 20 for 8" SD
	endif

	lda	dflag		; seek delay flag
	ori	rsec		; read sector command
	out	cmd		; issue..

	if 	Dysan
	mvi	a,sdma		; start transfer
	out	dma
	endif

	if	CCS
BREAD:	IN	DATA	; code to perform I/O transfer of  */
	MOV	M,A	; 	data to memory */
	INX	H
	IN	DATA
	MOV	M,A
	INX	H
	IN	DATA
	MOV	M,A
	INX	H
	IN	DATA
	MOV	M,A
	INX	H
	DCR	B	; decrement loop counter... */
	JNZ	BREAD
	endif

	call	comp		; transfer completed?
;
read2:
	xra	a		; clear seek delay
	sta	dflag
	in	stat		; good read?
	ora	a
	rz			; yes...
	dcr	e		; count off retries
	jnz	read1		; try again
	in	stat		; return status
	ora	a
	ret


**************************************
*** "WAIT FOR END OF DMA TRANSFER" ***
**************************************

comp:	
	call	delay		; before each check
	in	stat     	; Completed Transfer?
	rrc			
	rnc			; YES!
	jmp	comp		


********************************
*** "PROGRAM DISK CONTROLLER" ***
********************************

prg$dma:

	if	Dysan
	mvi	b,15		; Bytes Count 
	lxi	h,cmd$tbl	; Command Table
;
prg$dma1:
	mov	a,m		; load
	out	dma		; write to controller
	inx	h
	dcr	b		; -1
	jnz	prg$dma1
	endif

	if	CCS
	LXI	H,SECBUF	; store address of memory buffer */
	SHLD	DMA	; in pointer for disk controller */
	LDA	SELPT	; get drive select bits */
	OUT	DSEL	; sets autowait for 2422 controller... */
			; to ensure synchronization of I/O transfer
	endif

	ret

**************************************
*** "COMMAND TABLE DMA CONTROLLER" ***
**************************************

;	This data is used to program Zilog's
;	z80 DMA controller.

cmd$tbl:

	if	Dysan
 	db	0c3h		; Re-Set DMA Controller
	db	8bh		; Clear Block Counter
	db	79h		; Recieve Block 
	dw	secbuf		; Address To Store Block 
	dw	256 		; Block Size 
	db	14h		; Define Port (B) Address
	db	28h	 	; Define Port (A) Address
	db	85h		
	db	data   		; Data Reg FDC
	db	8ah		; Set DMA Controller Active HIGH
	db	0cfh
	db	3		; Data  ----> Memory
	db	0cfh
	endif


************************************
*** "CLEAR PENDING COMMANDS FDC" ***
************************************
;
;	Clears the floppy controller of any
;	pending commands.

clpend:
	mvi	a,clear		; clear FDC command
	out	cmd		; issue...

***************************************
*** "FDC DELAY TO PROCESS COMMANDS" ***
***************************************
;
;	This delay must be adjusted for different
;	clock speeds. 50 usec delay loop. 
;
;	Note:
;	     If altered, Ajust Index Timing Routine.

delay:				;  4.25
	mvi	a,fdelay	;  1.75
delay1:
	dcr	a		; 11.00
	jnz	delay1		; 27.50
	nop			;  1.00
	nop			;  1.00
	nop			;  1.00
	ret			;  2.50

********************************
*** "RADIAL TRANSLATE TABLE" *** 
********************************

;	Cursor Positioning table for radial
;	alignment test.

rad$neg:
	db	38	      	; 1  millinch
	db	36		; 2  "	  "
	db	34		; 3  "	  "
	db	32		; 4  "	  "
	db	30		; 5  "	  "
	db	28		; 6  "    "
	db	26		; 7  "	  "
	db	24		; 8  "    "
	db	22		; 9  "    "
	db	20		; 10 "    "
	db	17		; 11 "    "
	db	14		; 12 "    "
	db	11		; 13 "    "

rad$pos:
	db	40		; 1  millinch
	db	42		; 2  "     "
	db	44		; 3  "     "
	db	46		; 4  "     "
	db	48		; 5  "     "
	db	50		; 6  "     "
	db	52		; 7  "     "
	db	54		; 8  "     "
	db	56		; 9  "     "
	db	58		; 10 "     "
	db	61 		; 11 "     "
	db	64		; 12 "     "
	db      67		; 13 "     "

*********************************
*** "AZIMUTH TRANSLATE TABLE" *** 
*********************************

azi$tab:
	db	18		; head azmuith angle
	db	20		; +/- minutes
	db	22
	db	24
	db	26
	db	28
	db	30
	db	32
	db	34
	db	36
	db	38
	db	40
	db	42

**************************
*** "PROGRAM MESSAGES" *** 
**************************

me1:	

	if	Dysan
	db 	(-1) AND 0FFH,27,1,'Drive Diagnostic Program'
	db      (-1) AND 0FFH,31,2,'CP/M 80  Ver 1.0'
	db      (-1) AND 0FFH,23,4,'( Dysan Corp.   Santa Clara, Ca. )'
	endif

	db 	(-1) AND 0FFH,18,5,'<*>======================================<*>'
	db   	(-1) AND 0FFH,18,6,'<*>        DIAGNOSTIC COMMAND MENU       <*>'
	db      (-1) AND 0FFH,18,7,'<*>======================================<*>'
	db      (-1) AND 0FFH,18,8,'<*>                                      <*>'
	db      (-1) AND 0FFH,18,9,'<*>   R = Radial      H = Hysteresis     <*>'
	db     (-1) AND 0FFH,18,10,'<*>                                      <*>'
	db     (-1) AND 0FFH,18,11,'<*>   A = Azimuth     I = Index Timing   <*>'
	db     (-1) AND 0FFH,18,12,'<*>                                      <*>'
	db     (-1) AND 0FFH,18,13,'<*>   C = Centering   S = Spindle Speed  <*>'
	db     (-1) AND 0FFH,18,14,'<*>                                      <*>'
	db     (-1) AND 0FFH,18,15,'<*>   D = Drive Sel   E = Exit Program   <*>'
	db     (-1) AND 0FFH,18,16,'<*>                                      <*>'
	db     (-1) AND 0FFH,18,17,'<*><*><*<*><*><*><*><*><*><*><*><*><*><*><*>' 
	db     (-1) AND 0FFH,18,19,'SELECTION? ....',bs,0

me2:	db	'FATAL READ ERROR      ',0
me3:	db	'RE-CLAMP DISKETTE ....',bs,0
me4:	db	'CENTERING OK ....     ',bs,0
me5:	db	'  Minutes            ',0
me6:	db	(-1) AND 0FFH,25,2,'<>==========================<>'
	db	(-1) AND 0FFH,25,3,'<>       TRACK OFFSET       <>'
	db	(-1) AND 0FFH,25,4,'<>==========================<>'
	db      (-1) AND 0FFH,25,5,'<>                          <>'
	db	(-1) AND 0FFH,25,6,'<>       0   ---> 76        <>'
	db	(-1) AND 0FFH,25,7,'<>                          <>'
	db      (-1) AND 0FFH,25,8,'<>==========================<>'
	db      (-1) AND 0FFH,25,9,'<>   <ESC>  Cancels Test    <>'
	db     (-1) AND 0FFH,25,10,'<>==========================<>'
	db     (-1) AND 0FFH,25,12,'OFFSET? ...',bs,0


me7:	db	(-1) AND 0FFH,25,2,'<>==========================<>'
	db	(-1) AND 0FFH,25,3,'<>     TRACK SELECTION      <>'
	db	(-1) AND 0FFH,25,4,'<>==========================<>'
	db	(-1) AND 0FFH,25,5,'<>                          <>'
	db	(-1) AND 0FFH,25,6,'<>   A = (0)      D = (41)  <>'
	db	(-1) AND 0FFH,25,7,'<>                          <>'
	db     (-1) AND 0FFH,25, 8,'<>   B = (3)      E = (70)  <>'
	db     (-1) AND 0FFH,25, 9,'<>                          <>'
	db     (-1) AND 0FFH,25,10,'<>   C = (38)     F = (73)  <>'
	db     (-1) AND 0FFH,25,11,'<>                          <>'
	db     (-1) AND 0FFH,25,12,'<>==========================<>'
	db     (-1) AND 0FFH,25,13,'<>    <ESC> Cancels Test    <>'
	db     (-1) AND 0FFH,25,14,'<>==========================<>'
	db     (-1) AND 0FFH,25,16,'TRACK? ...',bs,0

me8:	db	(-1) AND 0FFH,24,5,'---  RADIAL ALIGNMENT CHECK ---'
	db	(-1) AND 0FFH,10,9,'Away',(-1) AND 0FFH,36,9,'Spindle',(-1) AND 0FFH,63,9,'Toward'
	db	(-1) AND 0FFH,10,10,'13 12 11 10 9 8 7 6 5 4 3 2 1'
	db	        '-1 2 3 4 5 6 7 8 9 10 11 12 13',0

me9:	db	(-1) AND 0FFH,25,2,'<>==========================<>'
	db	(-1) AND 0FFH,25,3,'<>      TRACK SELECTION     <>'
	db	(-1) AND 0FFH,25,4,'<>==========================<>'
	db      (-1) AND 0FFH,25,5,'<>                          <>'
	db      (-1) AND 0FFH,25,6,'<>    A = (35)   B = (44)   <>'
	db      (-1) AND 0FFH,25,7,'<>                          <>'
	db      (-1) AND 0FFH,25,8,'<>          C = (47)        <>'
	db      (-1) AND 0FFH,25,9,'<>                          <>'
	db     (-1) AND 0FFH,25,10,'<>==========================<>'
	db     (-1) AND 0FFH,25,11,'<>   <ESC>  Cancels Test    <>'
	db     (-1) AND 0FFH,25,12,'<>==========================<>'
	db     (-1) AND 0FFH,25,14,'TRACK? ...',bs,0

me10:	db	(-1) AND 0FFH,23,5,'---  DISKETTE CENTERING CHECK ---',0

me11:	db	(-1) AND 0FFH,23,14,'Press <SPACE BAR> For New Track',0

me12:	db	(-1) AND 0FFH,24,5,'--- AZIMUTH ALIGNMENT CHECK ---'  
	db	(-1) AND 0FFH,25,14,'<ESC> Will Cancel AZIMUTH Check',0

me13:	db	(-1) AND 0FFH,25,2,'<>==========================<>'
	db      (-1) AND 0FFH,25,3,'<>      TRACK SELECTION     <>'
	db      (-1) AND 0FFH,25,4,'<>==========================<>'
	db	(-1) AND 0FFH,25,5,'<>                          <>'
	db      (-1) AND 0FFH,25,6,'<>    A = (0)    B = (76)   <>'
	db      (-1) AND 0FFH,25,7,'<>                          <>'
	db      (-1) AND 0FFH,25,8,'<>==========================<>'
	db      (-1) AND 0FFH,25,9,'<>    <ESC> Cancels Test    <>'
	db     (-1) AND 0FFH,25,10,'<>==========================<>'
	db     (-1) AND 0FFH,25,12,'TRACK? ...',bs,0 

me14:	db	(-1) AND 0FFH,28,5,'--- HYSTERESIS CHECK ---',0

me15: 	db	(-1) AND 0FFH,15,8,'##################################################'
	db     (-1) AND 0FFH,15,12,'##################################################',0

me16:	db	'Positioner Hysteresis = ',0
me17:	db	(-1) AND 0FFH,25,5,'--- INDEX TO DATA TIME ---',0
me18:	db	'Index To ID In Usecs = ',0
me19:	db	(-1) AND 0FFH,27,5,'--- SPINDLE SPEED CHECK ---'  
	db	(-1) AND 0FFH,25,14,'<ESC>  Will Cancel RPM Check',0

me20:	db	'  Milliseconds',0
me21:	db	'  RPM',0

BLANKS:	DB	'                                        '
	DB	'                ',0
		                                                   
SELMSG:	DB	(-1) AND 0FFH,15,12,'WHICH DRIVE HAS THE DDD - A,B,C,D ?'
	DB	(-1) AND 0FFH,25,14,'SELECTION ? ....',0
		                                         

*************************
*** "POSITION CURSOR" ***
*************************

set$cur	db	0ffh
column	ds	1		; set column
row	ds	1		; set row
	db	0		; terminator

***********************************
*** "PROGRAM VARIABLE STORAGE" ***
***********************************

temp	ds	2		; temp storage 
diff 	ds	1		;  1st - 2nd read
ctrk	ds	1		; current track
savtrk	ds	1		; temp storage Hysteresis test
dflag	ds	1		; seek delay flag
point	ds	2		; table pointer
xpoint	ds	2		; table pointer positive
ypoint	ds	2		; table pointer negative
xoff	ds	1		; positive offset
yoff	ds	1		; negative offset
bais	ds	1		; bais from test track (Hysteresis)
hyerr	ds	1		; hysteresis error on first reading
SELPT	DS	1	;STORES BYTE FOR DISC CONTROL PORT

;
;	Storage area for 16/24 bit divide routine
;
msb	ds	1
msb1	ds	2
msb2	ds	2

inbuf:	db	3		;"max" byte for BDOS 10
incnt	ds	1		;"cnt" buffer for BDOS 10
buffer	ds	4		; console input buffer
secbuf	ds	256		; sector buffer

	ds	100		; stack space
stack	equ	$		; top down...




