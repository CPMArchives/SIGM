; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
; *+ Version 1 -  SCREEN.CNT (Screen Control File) for PACMAN.COM/.DAT +*
; *+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*
;
;       Warning -> PACMAN.COM is for Z80 CPUs ONLY <- Warning
;
;   October 2, 1982 - Kelly Smith, CP/M-Net SYSOP, (805) 527-9321  
;
; Hah, Fooled you didn't I(?).  Bet you thought this was going to be 
; assembly language source for PACMAN...  Sorry, but this is a file 
; to  be  used  as the SCREEN CONTROL file for the  PACMAN.COM  and 
; PACMAN.DAT  files.   The  original files from FOG (First  Osborne 
; User's  Group) included a bunch of object code '.CNT' files  that 
; you  were  supposed to rename to SCREEN.CNT for  your  particular 
; terminal/computer  type...  I thought we might get more "mileage" 
; out  of the program if I set-up one source program that could  be 
; modified  to  suit  ANYONEs  needs.    Choose  your  'true/false' 
; terminal  parameter  switch...set to TRUE (and ONLY  ONE  may  be 
; TRUE), rename to 'SCREEN.CNT', assemble, load, and run PACMAN.COM
; (and note, that all files must be on the same 'logged-in' disk).
; 
; This PACMAN program has a larger maze than the PACMAN95.COM  that 
; has appeared on many RCPM systems...it's also a little bit easier 
; (i. e.,  slower) to play.  I have verified it's operation on both 
; the  Osborne I (be sure and run SETUP to turn the AUTO SCROLL  to 
; OFF)  and the KAYPRO II computers,  and it really works nice with 
; the cursor arrow keys (a particular challenge with the 52  column 
; wide screen display of the Osborne I computer).
; 
; Please  feel  free to add YOUR favorite flavor of terminal  CLEAR 
; SCREEN  and CURSOR POSITION command to this program...and  'bump' 
; the version number,  add your name and date,  so we can all  keep 
; track of the changes.   Send any updates to either my RCPM (CP/M-
; Net,  (805) 527-9321) or Trevor Marshall's (Technical RCPM, (805) 
; 492-5472)...Thanks
;
;
;
true		equ	-1	; define true
false		equ	not true; define false
;
adm3		equ	true	; Televideo 950/ADM-3/Osborne I/Kaypro II
vt52		equ	false	; DEC VT52
hazel		equ	false	; Hazeltine
;
bdos		equ	5	; CP/M-80 BDOS entry address
tpa		equ	0100h	; standard origin for CP/M-80
;
;
;
	org	tpa
;
; clear screen subroutine
;
	if	adm3
	mvi	e,'Z'-40h	; clear screen
	endif

	if	vt52
	mvi	e,'['-40h
	mvi	c,6
	call	bdos
	mvi	e,'H'
	mvi	c,6
	call	bdos
	mvi	e,'['-40h
	mvi	c,6
	call	bdos
	mvi	e,'J'
	endif

	if	hazel
	mvi	e,'~'
	mvi	c,6
	call	bdos
	mvi	e,'\'-40h
	endif

	mvi	c,6
	call	bdos
	ret			; return from clear screen routine
;
;
;
	org	tpa+40h		; leave plenty of room for clear screen
;
; cursor addressing subroutine
;
	push	h		; save column and line co-ordinate pointers
	push	d

	if	adm3
	mvi	e,'['-40h	; send first leadin character
	mvi	c,6
	call	bdos
	mvi	e,'='		; send second leadin character
	endif

	if	vt52
	mvi	e,'['-40h
	mvi	c,6
	call	bdos
	mvi	e,'Y'
	endif

	if	hazel
	mvi	e,'~'
	mvi	c,6
	call	bdos
	mvi	e,'Q'-40h
	endif

	mvi	c,6
	call	bdos
	pop	h		; get line pointer
	mov	a,m		; get line number
	adi	32		; add offset
	mov	e,a		; send line number
	mvi	c,6
	call	bdos
	pop	h		; get column point
	mov	a,m		; get column number
	adi	32		; add offset
	mov	e,a		; send column number
	mvi	c,6
	call	bdos
	ret			; return from cursor position routine
;
;
;
	org	tpa+080h	; leave plenty of room for cursor routine
;
;
;
	end
