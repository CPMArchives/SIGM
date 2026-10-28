; 
;         MENU.ASM Version 2.0 as of April 26, 1981
; 
;     Original Program by: James J. Frantz, May 31, 1979
; 
; Menu Program Selection for '.BAS', '.INT' or '.COM' Files
; 
; 
;          Modified from original by: Kelly Smith
; 
;     Version 2.0 contains the following modifications:
; 
; (1)  Made  CP/M  2.X compatible;  previous  version  would 
;    "clobber"  the  '$' string delimiter  in  filename  and 
;    would   display   filenames  and  garbage  memory   'ad 
;    nauseum'.
; 
; (2)  Added  equates for either MBASIC or  CBASIC  assembly 
;    function, and corresponding 'heading'.
; 
;      Note:  You  must  have MBASIC.COM  on  the  currently 
;             logged  diskette if 'mbasic$program' equate is 
;             true, and it will expect files of type '.BAS'. 
;             If 'cbasic$program' equate is true,  you  must 
;             have   CRUN.COM   on  the   currently   logged 
;             diskette,  and  it  will expect files of  type 
;             '.INT'.  If neither is equated to true, '.COM' 
;             filetypes are assumed.
; 
; (3)   Added  command  option  to  select  drive  for  user 
;    requested MENU.  (i.e.,  MENU B:<cr>). If corresponding 
;    filetype  is not found for assembled MENU  type  (.BAS, 
;    .INT  or .COM),  MENU will display  "+++ File Not Found 
;    +++" and return to the default drive.
; 
; (4) Added "Disk Drive - X:" to heading display,  where 'X' 
;     is the selected drive.
; 
; (5)  Added  conditional  assembly  switches  for   'upper' 
;     (uppercase only terminals),  'stdcpm' (standard CP/M), 
;     'altcpm' (alternate CP/M).
; 
; (6)  Added conditional assembly switch for 'no$sys$files',     
;     to inhibit display of CP/M 2.X 'SYS' files.  Handy, if 
;     running a Remote CP/M System and you don't want to let 
;     the whole world know whats 'hidden'...
; 
; (7)  Stripped  MSB "tag bit" for files set-up  for  Remote 
;     CP/M  Systems as "not for distribution".  Files  would 
;     not  be  sorted  in proper order for  display  without 
;     this...this   will   also   work   for   MP/M   system 
;     configuration where "tag bit" must be 'Bit 6' (NOT Bit 
;     7)...Bit  7 used as "tag" in MP/M environment fouls up 
;     the 'Control-S' start/stop video scroll  function,  so 
;     some users are switching to Bit 6 as "tag"...
; 
; (8)  Fixed  bug  when MENU is set for BASIC  file  (either 
;     MBASIC or CBASIC) and is in B:  (or greater drive) and 
;     attempting  to load the MBASIC (or CRUN) and THEN  the 
;     '.BAS'  (or '.INT') file...now looks on same  diskette 
;     that MENU is on.
;
; (9)  Added 'widecrt' equate for two CRT  terminal  display 
;     formats. Set  the equate 'widecrt' to true if your CRT 
;     terminal  can  display  80   columns  by  24  rows. If 
;     'widecrt' is false, the default display is 64  columns 
;     by 16 rows.
; 
;  As supplied,  MENU.ASM is set-up for the following system 
; configuration and display format:
; 
;      Lowercase terminal display:   upper = false
; 
;      80 column by 24 row display:  widecrt = true
; 
;      Standard CP/M:                stdcpm = true
;                                    altcpm = false
; 
;      Display '.COM' Menu:          mbasic$program = false
;                                    cbasic$program = false
; 
;      No display of 'SYS' files:    no$sys$files = true
; 
;
;
;          A Generalized Suggestions for Using MENU
; 
;  If you have kids that love to play games on your  system, 
; this  is  perhaps the most 'protective' way to keep  there 
; "busy   little   hands"   out  of   the   CP/M   operating 
; system...Just set the little BAST..errr,  pardon  me...set 
; your  "prodigy  child"  up  with  a  GAMES  diskette  that 
; AUTOLOAD's the MENU program, and never ever again will you 
; hear "Gee Dad, I tried ERA *.* and now nuthi'n works...".
; 
;
;
true	equ	-1	; define true
false	equ	not true; define false
;
mbasic$program	equ	false	; true = .BAS
cbasic$program	equ	false	; true = .INT
				;
				; Note: Only one may be true, and
				;       both false = .COM
;
no$sys$files	equ	true	; true = no SYS display, false = SYS display
;
upper	equ	false	; true if uppercase only terminal
widecrt	equ	true	; true if 80 column/24 row terminal
;
stdcpm	equ	true	; true if standard CP/M (base address 0000h)
altcpm	equ	false	; true if alternate CP/M (base address 4200h)
;
	if	stdcpm	; if standard CP/M...
base	equ	0000h	; base for standard CP/M system
	endif		; end if...
;
	if	altcpm	; if alternate CP/M...
base	equ	4200h	; base for H8 or TRS-80 CP/M system
	endif		; end if...
;
bdos	equ	base+5	; CP/M BDOS entry address for function call
tfcb	equ	base+5ch; transient file control block base address
;
nbr$col		equ	4	; number of columns to display

	if	widecrt		; if 80 column/24 row crt terminal...
screen$size	equ	24	; terminal has 24 lines/screen display
screen$hgt	equ	80	; terminal has 80 rows/screen display
	endif			; end if...

	if	not widecrt	; if 64 column/16 row crt terminal...
screen$size	equ	16	; terminal has 16 lines/screen display
screen$hgt	equ	64	; terminal has 64 rows/screen display
	endif			; end if...
;
ccp$len	equ	3c06h-3400h	; calculate CCP length
;
bel	equ	007h		; (^g) bell - human attention required
lf	equ	00ah		; (^j) line feed
cr	equ	00dh		; (^m) carriage return

	org	base+100h

start:	lxi	sp,stack$area	; set up a stack
	lda	tfcb		; get drive specification
	ora	a		; was drive explicity requested?
	jnz	drive$request	; if yes, skip interrogate disk request
	mvi	c,25		; 'interrogate disk' function
	call	bdos		; find out which disk we're on...
	inr	a		; make A: = 1
;
drive$request:
;
	adi	'A'-1		; make it ASCII
	sta	driveid		; save the ASCII drive identification
	sbi	'@'		; make it HEX
	sta	srch$fcb	; set selection for requested or default drive
	mvi	c,17		; 'search first' command
; 
sort$loop:
;
	lxi	d,srch$fcb	; point file control block
	call	bdos		; use CP/M entry point
	ora	a		; test for -1
	jm	assign$menu$nbr	; print empty
	jz	kludge		; do not set file found, if zero
	sta	file$found	; set file found flag
kludge:	rrc			; this is the same as
	rrc			; 5 "add a's"
	rrc
	ani	60h 		; mask correct bits
	adi	80h		; add base address (0080h)
	mov	e,a		; put pointer in (de)
	mvi	d,0		; as 16 bit value
	lxi	h,dirtable	; point start of table of
				; sorted names
	inx	d		; point past erase field
; 
compare$loop:
; 
	push	d		; save pointer to next
				; entry from disk directory
	mvi	c,8		; length of compare
	push	h		; save pointer to table
; 
compare1:
;
	ldax	d		; get trial name char
	ani	7fh		; mask-off high bit 'cause may be
				; "tagged" as 'not for distribution' for RCPM's
	cmp	m		; match?
	jnz	end$compare	; if not, try next entry
	inx	h		; advance pointers
	inx	d				
	dcr	c		; one less char to compare	
	jnz	compare1	; keep testing	
;
end$compare:	
;
	pop	b		; restore table pointer
	jc	insert$name	; directory name goes in	
				; front of current table
				; entry if lower (cy = 1)
	lxi	h,14		; length of table entry
	dad	b		; (hl) to next table entry
	pop	d		; recover trailer name point
	jmp	compare$loop	; loop again
; 
insert$name:
;
	if	no$sys$files	; if no SYStem files to be displayed...
	push	b		; save pointer to table entry
	push	d		; save pointer to file name
	xchg
	lxi	d,9		; add bias for "SYS" flag character
	dad	d
	mov	a,m		; get character
	ani	80h		; mask for "SYS" flag
	pop	d		; adjust stack, in case we take the next jump
	pop	b		; ...or we really need the pointers
	jnz	abort		; abort this filename, if "SYS"
	endif			; end if...

	ldax	d		; get first byte of filename
	ani	7fh		; mask-off high bit 'cause may be
				; "tagged" as 'not for distribution' for RCPM's
	stax	d		; and save back, so proper file sort display
	lxi	h,file$count	; count the number of files
	inr	m		; to be displayed
	lhld	end$of$table	; get pointer to table
	xchg
	lxi	h,14		; distance to move
	dad	d		; (hl) point destination
	shld	end$of$table	; save the new end of table
	inx	h
	inx	d
;
move$up:
;
	dcx	d
	dcx	h
	ldax	d		; get byte to move
	mov	m,a		; put in new spot
	mov	a,c		; test for done
	cmp	e		; (bc) = (de)?
	jnz	move$up
	mov	a,b
	cmp	d
	jnz	move$up
	pop	h		; recover pointer
	mvi	c,8
	call	block$move	; insert name in table
	lxi	h,menu$buff	; point menu number block
	mvi	c,6		; length of movek
	call	block$move	; insert text in table
abort:	mvi	c,18		; 'search next' command
	jmp	sort$loop
; 
assign$menu$nbr:
;
	lda	file$count
	mov	b,a		; save in (b)
	push	psw		; and on stack
	mvi	c,0		; initial file number
	lxi	h,dirtable+11	; point first file number
	lxi	d,13		; offset to other numbers
; 
number$files:
;
	mov	a,c		; put file number in (a)
	adi	1		; increment
	daa			; decimal convert
	mov	c,a		; resave	in (c)
	rrc			; get tens digit into
	rrc			; proper place
	rrc			; 
	rrc
	ani	0fh		; add mask
	jz	use$blank	; supress leading zero by
	adi	10h		; add either 20h (ASCII ' ')
;
use$blank:
;
	adi	' '		; or 20h + 10h for numeral
	mov	m,a		; put in text stream
	mov	a,c		; get units portion
	ani	0fh		; mask off tens portion
	adi	'0'		; convert to ASCII
	inx	h			
	mov	m,a
	dad	d		; repeat until all files
	dcr	b		; are sequentially numbered
	jnz	number$files
	pop	psw		; get file$count from stack
	push	psw		; and save again for later
	adi	nbr$col-1
	mvi	b,255		; (b) accumulates quotient
				; so set to -1 for at least
				; 1 pass thru gives 0
; 
divx:
;
	inr	b
	sui	nbr$col		; divide (file$count+3) by
				; fout to get offset1
	jp	divx
	adi	nbr$col		; substracted once too much
				; so add it back on
	lxi	h,offset1		
	mov	m,b		; insert offset1 into table
	inx	h		; point offset2 location
	jnz	setoffset2	; same as offset1 if non-
				; zero remainder
	dcr	b		; else offset2 = offset1-1
;
setoffset2:
;
	mov	m,b		; put offset2 in table
	inx	h		; point offset	for col 3
	dcr	a		; test for remainder of 1
	jnz	setoffset3	; if remainder <> 1, use
				; offset3 = offset2-1
	dcr	b		; else offset3 = offset2-1y
; 
setoffset3:
;
	mov	m,b		; else offset to column 4
; 	
reprint:
;
	pop	psw		; recover file count
; 
reprint1:	
;
	push	psw		; save again for later use
	sta	file$count	; save for counting	
	mvi	a,screen$hgt	; set for video display size
	sta	line$count
	lda	file$found	; get file$found flag
	ora	a		; and set psw flags
	jz	exit		; if zero, no files of this type found
	lxi	d,heading
	mvi	c,9		; buffer printer command
	call	bdos		; CP/M prints heading
	lxi	h,dir$table-14	; point dummy 0th entry
; 	
print$line:
;
	push	h		; save base address
	lxi	d,offset0	; point offset table
	mvi	a,nbr$col	; 4 column per line
; 
print$name:
;
	sta	column$cnt	; save count of columns
	push	h		; save current name pointer
	push	d		; save offset table pointer

	if	widecrt		; if 80 column/24 row crt terminal...
	lxi	d,doubl$space	; print 2 spaces
	mvi	c,9		; 'print buffer' command
	call	bdos		; use CP/M 
	endif			; end if...

	lxi	d,doubl$space	; print 2 spaces
	mvi	c,9		; 'print buffer' command
	call	bdos		; use CP/M 
	pop	d		; get offset table pointer
	pop	h		; get name pointer
	ldax	d		; get offset value
	lxi	b,14		; each name is 14 long
; 
mult$14:
;
	dad	b		; add 14 for each offset
	dcr	a		; until offset = 0
	jnz	mult$14
	push	h		; save new name pointer
	push	d		; save offset pointer
	xchg			; pointer name to print w/(de)
	mvi	c,9		; print buffer
	call	bdos		; print file name
				; and it's menu number
; 
test$finish:
;
	lxi	h,file$count	; see if done printing
	dcr	m		; by testing count of files
	pop	d		; get offset pointer
	pop	h		; get pointer to last name
	jz	finish		; no more to print
	inx	d		; advance offset pointer
	lda	column$cnt
	dcr	a		; see if column left = 0
	jnz	print$name	; print another save line 
	call	crlf			
	pop	h		; get base of previous line
	lxi	d,14		; add offset
	dad	d	
	jmp	print$line
;
finish:
;
	pop	h		; unjunk stack
; 
lf$loop:
;
	call	crlf
	lxi	d,prompt	; point instruction message
	mvi	c,9			
	call	bdos
	lxi	d,input$buff
	mvi	a,10		; 10 characters maximum
	stax	d
	mvi	c,10		; 'read buffer' command
	call	bdos
	lxi	h,input$buff+1	; point to character counter
	mov	a,m		; get it and see if >2 
	cpi	3
	jnc	reprint		; reprint the menu
	mov	c,a		; count of digits to (c)
	mvi	b,0
; 
get$menu$nbr:
;
	inx	h		; point ASCII digit
	mov	a,m		; get it
	call	ascii$convert	; convert to binary
	jc	reprint		; re-display on error
	dcr	c		
	jnz	get$menu$nbr
	pop	psw		; recover file counter
	cmp	b		; file count - request number
	jc	reprint1	; redisplay menu if illegal
	lxi	d,14		; increment between names
	lxi	h,dir$table-14	; point dummy 0th entry
; 
find$name:
;
	dad	d		; add offset b times
	dcr	b			
	jnz	find$name
	push	d		; found filename, tidy-up screen...
	push	h
	lxi	d,crlfmsg
	mvi	c,9
	call	bdos
	pop	h
	pop	d
	xchg			; save pointer to file name
	lhld	base+6		; get bdos entry point
	lxi	b,-ccp$len	; offset to start of CP/M
	dad	b
	push	h		; save CP/M entry point
				; on stack for branch
	lxi	b,8		; offset to command buffer "autoload"
	dad	b		; (hl) points place to put name of 
				; .BAS, .INT, or .COM file to be
				; executed
	push	d		; save pointer to file name
	xchg			; (de) points to command buffer
	lxi	h,128		; offset to end of command buffer
				; where pointer is stored
	dad	d		; (hl) points to storage place
	mov	m,e		; update buffer pointer to
	inx	h		; the start of the command
	mov	m,d		; buffer so CP/M will read
	lda	driveid		; get selected drive identification
	stax	d		; store at start of command buffer
	inx	d		; bump for ':' delimeter position
	mvi	a,':'		; make delimeter
	stax	d		; and store it...
	inx	d		; bump for destination pointer to filename

	if	mbasic$program or cbasic$program	; if BASIC program...
	lxi	h,command$name	; point command name
	mvi	c,len$cmd$name	; length of command name
	call	block$move
	lda	driveid		; get selected drive identification
	stax	d		; store at start of command buffer
	inx	d		; bump for ':' delimeter position
	mvi	a,':'		; make delimeter
	stax	d		; and store it...
	inx	d		; bump for destination pointer to filename
	endif			; end if...

	pop	h		; point selected file name
	mvi	c,8		; length of file name
	call	block$move

	if	mbasic$program or cbasic$program	; if BASIC program...
	lxi	h, spec$type
	mvi	c,4
	call	block$move 
	endif			; end if...

	xra	a		; needs a 0 at end
	stax	d		; of command line
	ret
; 
block$move:
;
	mov	a,m
	stax	d
	inx	d
	inx	h
	dcr	c
	jnz	block$move
	ret
; 
ascii$convert:
;
	sui	'0'		; subtract ASCII bias
	cpi	9+1		; be sure it's numeric
	cmc
	rc
	mov	d,a
	mov	a,b
	rlc
	rlc
	rlc
	add	b
	rc
	add	b
	rc
	add	d
	mov	b,a
	ret
; 
crlf:
;
	lxi	d,crlfmsg
	mvi	c,9
	call	bdos
	lxi	h,line$count
	dcr	m
	ret
; 
exit:	lxi	d,nofile	; indicate no files present
	mvi	c,9
	call	bdos
	jmp	base		; and exit to CP/M via "warm boot"
;
	if	upper		; if uppercase only terminal...
nofile:		db	cr,lf,lf,'+++ FILE NOT FOUND! +++',cr,lf,'$'
	endif

	if	not upper	; if not uppercase only terminal...
nofile:		db	cr,lf,lf,'+++ File Not Found! +++',cr,lf,'$'
	endif

crlfmsg:	db	cr,lf,'$'
; 
heading:	db	cr,lf,lf
	if	widecrt and mbasic$program
	db	'                   '
	endif

	if	not widecrt and mbasic$program
	db	'              '
	endif

	if	upper and mbasic$program
	db	'MICROSOFT COMPATIBLE BASIC FILE MENU'
	endif

	if	not upper and mbasic$program
	db	'Microsoft Compatible BASIC File Menu'
	endif

	if	widecrt and cbasic$program
	db	'                '
	endif

	if	not widecrt and cbasic$program
	db	'           '
	endif

	if	upper and cbasic$program
	db	'COMPILER SYSTEMS COMPATIBLE BASIC FILE MENU'
	endif

	if	not upper and cbasic$program
	db	'Compiler Systems Compatible BASIC File Menu'
	endif

	if	widecrt and not mbasic$program and not cbasic$program
	db	'                         '
	endif

	if	not widecrt and not mbasic$program and not cbasic$program
	db	'                    '
	endif

	if	upper and not mbasic$program and not cbasic$program
	db	'CP/M COMMAND FILE MENU'
	endif

	if	not upper and not mbasic$program and not cbasic$program
	db	'CP/M Command File Menu'
	endif

	db	cr,lf

	if	widecrt		; if 80 column/24 row crt terminal...
	db	'                             '
	endif			; end if...

	if	not widecrt	; if 64 column/16 row crt terminal
	db	'                       '
	endif			; end if...

	if	upper	; if uppercase only terminal...
	db	'DISK DRIVE - '
	endif		; end if...

	if	not upper	; if not uppercase only terminal
	db	'Disk Drive - '
	endif			; end if...

driveid:ds	1	; current logged ASCII drive identification

	db	':',cr,lf,lf,'$'

	if	upper		; if uppercase only terminal
prompt:	db	cr,lf,bel,' ENTER MENU NUMBER, AND PRESS RETURN: $'
	endif			; end if...

	if	not upper	; if not uppercase only terminal...
prompt:	db	cr,lf,bel,' Enter menu number, and press return: $'
	endif			; end if...

	if	mbasic$program	; if MBASIC program...
command$name:	db	'MBASIC '	; Microsoft BASIC
; 
len$cmd$name	equ	$-command$name
; 
spec$type:	db	'.BAS'
	endif			; end if...

	if	cbasic$program	; if CBASIC program...
command$name:	db	'CRUN '	; Compiler Systems BASIC
; 
len$cmd$name	equ	$-command$name
; 
spec$type:	db	'.INT'
	endif			; end if...

doubl$space:	db	'  $'
; 
menu$buff:	db	' - 00$'
; 
offset0:	db	1
;
offset1:	db	0,0,0
; 
end$of$table:	dw	dirtable
; 
file$count:	db	0
;
column$cnt:	db	4
;
line$count:	db	0
;
file$found:	db	0	; file found flag

	if	mbasic$program	; if MBASIC program...
srch$fcb:	db	0,'????????BAS',0,0,0,0
	endif			; end if...

	if	cbasic$program	; if CBASIC program...
srch$fcb:	db	0,'????????INT',0,0,0,0
	endif			; end if...

	if	not mbasic$program and not cbasic$program	; if not BASIC program...
srch$fcb:	db	0,'????????COM',0,0,0,0
	endif			; end if...

dir$table:	db	255
; 
stack$area	equ	200*14 + 30
; 
input$buff	equ	stack$area
; 
	end	start
