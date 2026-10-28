
;	-------------------------------------------------------
;	Adaptation of VTI for UAP's POLY-88
;		[Version October 15,1978]
;
;		VTI88  -  Copyright (C) 1978
;		Universidad Autonoma de Puebla
;
;	written by Harold V. McIntosh, summer 1978, with
;	reference to: Harvey A. Cohen, "The Oznaki LIFE",
;	Dr. Dobbs Journal of Computer Calisthenics and
;	Orthodontia, volume 3, issue 4 (April 1978) pp. 10-11;
;	and with acknowledgements to the hospitality of the
;	Quantum Theory Project, University of Florida,
;	Gainesville, Florida.
;
;	Note that this board has been modified: bit 7=1 now
;	signifies graphic mode, contrary to the normal board.
;	------------------------------------------------------

	org	09000H
                
                
read:	equ	0C20H	;POLY-88 WH0 keyboard input routine
kbfl:	equ	0C0CH	;keyboard input ready flag

;	-------------------------------------------------------
;	Constants defining screen size and location.  Note that
;	while the programmer has some discretion in assigning
;	these constants, there is highly implicit usage of the
;	assumption that the screen memory begins at a 1K Hex
;	boundary, and that the row length is a power of 2.
;	Thus the video board origin may be changed through its
;	address switches, and new parameters defined without
;	difficulty; nevertheless adaptation to an 80-column 
;	board would require restructuring the subroutines.
;	-------------------------------------------------------

vorg:	equ	0F800H	;origin of video screen memory area
vsiz:	equ	00400H	;size of video screen memory area
rsiz	equ	00040H	;length of a single display line
rmsk:	equ	rsiz-1	;mask for single row addresses
morg:	equ	04000H	;area for defining macros

;	-------------------------------------------------------
;	Data storage locations required by the subroutines.
;	-------------------------------------------------------

ma:	equ	00CC9H	;bit mask to locate pixel within byte
wy:	equ	00CCAH	;row count * 16  -  16 rows total
ex:	equ	00CCBH	;column count * 4  -  64 columns total
wye:	equ	00CCCH	;8-bit cartesian y-coordinate
eks:	equ	00CCDH	;8-bit cartesian x-coordinate

;	-----------------------------------------------------
;	Entry vector designed to systematize communication with
;	calling programs written in BASIC or other external
;	languages.  These entry points should remain the same
;	even though the subroutines are revised, corrected, or
;	otherwise modified.

	jmp	ypl	;move cursor up one pixel
	jmp	ymi	;move cursor down one pixel
	jmp	xpl	;move cursor right one pixel
	jmp	xmi	;move cursor left one pixel
	jmp	home	;place cursor at screen center
	jmp	cuex	;extinguish the cursor
	jmp	culi	;illuminate the cursor
	jmp	cure	;reverse the cursor
	jmp	cuse	;sense the cursor (zero test afterward)
	jmp	blak	;make the whole screen black
	jmp	whit	;make the whole screen white
	jmp	reve	;reverse the whole screen
	jmp	cart	;form (ma, wy, ex) from (wye, eks)
	jmp	line	;line segment with increments (dx,dy)
	jmp	ekspl	;rotate whole screen right
	jmp	eksmi	;rotate whole screen left
	jmp	wyepl	;rotate whole screen up
	jmp	wyemi	;rotate whole screen down
	jmp	hh	;advance one cycle of LIFE
	jmp	ee	;move cursor east one LIFE cell
	jmp	ww	;move cursor west one LIFE cell
	jmp	nn	;move cursor north one LIFE cell
	jmp	ss	;move cursor south one LIFE cell
	jmp	kk	;deactivate cell under cursor
	jmp	ll	;activate cell under cursor
	jmp	eas	;rotate screen and cursor one cell east
	jmp	wes	;rotate screen and cursor one cell west
	jmp	nor	;rotate screen and cursor one cell north
	jmp	sou	;rotate screen and cursor one cell south
	jmp	coop	;fetch count and terminating character
	jmp	pair	;fetch a pair of coordinates

;	-------------------------------------------------------

;	move cursor up one pixel

ypl:	lxi h,ma
	mov a,m
	ani 024H
	jnz yp1
	mov a,m
	rlc
	mov m,a
	ret
yp1:	rrc
	rrc
	mov m,a
	lda wy
	sui 010H
	sta wy
	ret

;	move cursor down one pixel

ymi:	lxi h,ma
	mov a,m
	ani 009H
	jnz ym1
	mov a,m
	rrc
	mov m,a
	ret
ym1:	rlc
	rlc
	mov m,a
	lda wy
	adi 010H
	sta wy
	ret

;	move cursor right one pixel

xpl:	lxi h,ma
	mov a,m
	ani 007H
	jnz xp1
	mov a,m
	rrc
	rrc
	rrc
	mov m,a
	ret
xp1:	rlc
	rlc
	rlc
	mov m,a
	lda ex
	adi 004H
	sta ex
	ret

;	move cursor left one pixel

xmi:	lxi h,ma
	mov a,m
	ani 038H
	jnz xm1
	mov a,m
	rlc
	rlc
	rlc
	mov m,a
	ret
xm1:	rrc
	rrc
	rrc
	mov m,a
	lda ex
	sui 004H
	sta ex
	ret

;	load A with the bit mask, HL with a byte address
;	given the cursor positioning data at (ma,wy,ex)

dot:	lhld wy
	mov a,h
	mvi h,vorg/0400H
	dad h
	dad h
	rrc
	rrc
	ora l
	mov l,a
	lda ma
	ret

;	home the cursor

home:	lxi h,8080H
	shld wy
	mvi a,008H
	sta ma
	ret

;	extinguish the cursor

cuex:	call dot
	ora m
	mov m,a
	ret

;	light the cursor

culi:	call dot
	cma
	ana m
	mov m,a
	ret

;	reverse the cursor

cure:	call dot
	xra m
	mov m,a
	ret

;	sense the cursor

cuse:	call dot
	ana m
	ani 03FH
	ret

;	clear the whole screen to black

blak:	lxi d,vsiz
	lxi h,vorg
bl1:	mvi m,0FFH
	inx h
	dcr e
	jnz bl1
	dcr d
	jnz bl1
	ret

;	clear the whole screen to white

whit:	lxi d,vsiz
	lxi h,vorg
whi:	mvi m,080H
	inx h
	dcr e
	jnz whi
	dcr d
	jnz whi
	ret

;	reverse the whole screen

reve:	lxi d,vsiz
	lxi h,vorg
rev1:	mov a,m
	xri 03FH
	mov m,a
	inx h
	dcr e
	jnz rev1
	dcr d
	jnz rev1
	ret

;	transform cartesian coordinates in the form of x,y
;	to a mask and byte address

cart:	mvi b,018H
	mvi c,004H
	lda wye
	cma
	adi 031H
car1:	cmp b
	jc car2
	sub b
car2:	cmc
	adc a
	dcr c
	jnz car1
	mov c,a
	ani 00FH
	rlc
	rlc
	rlc
	rlc
	sta wy
	mov a,c
	ani 0F0H
	jnz car3
	mvi a,020H
	jmp car4
car3:	xri 030H
	rrc
car4:	mov c,a
	lda eks
	dcr a
	mov b,a
	rlc
	ani 0FCH
	sta ex
	mov a,b
	ani 001H
	mov a,c
	jz car5
	rrc
	rrc
	rrc
car5:	sta ma
	ret

;	draw a line with increments dx,dy = (B,C).  Increment
;	may be + or - using complementary arithmetic, but less
;	than 64 in absolute value to avoid overflow problems.

line:	lxi h,ypl
	mov a,c
	ora a
	jp lin1
	cma
	inr a
	mov c,a
	lxi h,ymi
lin1:	lxi d,xpl
	mov a,b
	ora a
	jp lin2
	cma
	inr a
	mov b,a
	lxi d,xmi
lin2:	cmp c
	jnc lin3
	xchg
	mov b,c
	mov c,a
lin3:	mov a,b
	sta eks
	mov a,c
	add a
	mov c,a
	sub b
	push psw
	sub b
	mov b,a
lin4:	pop psw
	push h
	lxi h,culi
	xthl
	cpi 001H
	jm lin5
	push h
	add b
	jmp lin6
lin5:	add c
lin6:	push d
	push psw
	lda eks
	dcr a
	sta eks
	jnz lin4
	pop psw
	ret

;	the movements in one byte necessary to shift the
;	whole screen right one pixel.

expl:	mov a,m
	ani 03FH
	mov b,a
	ani 038H
	rrc
	rrc
	rrc
	ora c
	mov c,a
	mov a,b
	rlc
	rlc
	rlc
	ani 038H
	mov b,c
	mov c,a
	ret

;	the movements within one byte necessary for shifting
;	the whole screen left one pixel.

exmi:	mov a,m
	ani 03FH
	mov b,a
	rlc
	rlc
	rlc
	ani 038H
	ora c
	mov c,a
	mov a,b
	ani 038H
	rrc
	rrc
	rrc
	mov b,c
	mov c,a
	ret

;	the movements necessary within one byte to shift the
;	whole screen down one pixel.

wymi:	mov a,m
	ani 03FH
	mov b,a
	ani 036H
	rrc
	ora c
	mov c,a
	mov a,b
	rlc
	rlc
	ani 024H
	mov b,c
	mov c,a
	ret

;	the movements necessary within one byte to shift the
;	whole screen up one pixel.

wypl:	mov a,m
	ani 03FH
	mov b,a
	rlc
	ani 036H
	ora c
	mov c,a
	mov a,b
	ani 024H
	rrc
	rrc
	mov b,c
	mov c,a
	ret

;	rotate the whole screen right one pixel

ekspl:	lxi h,vorg
	lxi d,rsiz-1
eksp1:	push h
	dad d
	call expl
	pop h
eksp2:	call expl
	mov a,b
	ori 080H
	mov m,a
	inx h
	mov a,l
	ani rmsk
	jnz eksp2
	mov a,h
	cpi (vorg+vsiz)/0100H
	jnz eksp1
	ret

;	rotate the whole screen left one pixel

eksmi:	lxi h,vorg+vsiz-1
	lxi d,-rsiz+1
eksm1:	push h
	dad d
	call exmi
	pop h
eksm2:	call exmi
	mov a,b
	ori 080H
	mov m,a
	mov a,l
	ani rmsk
	dcx h
	jnz eksm2
	mov a,h
	cpi (vorg/0100H)-1
	jnz eksm1
	ret

;	rotate the whole screen up one pixel.

wyepl:	lxi h,vorg+vsiz-1
wyep1:	lxi d,-vsiz+rsiz
	push h
	dad d
	call wypl
	pop h
	push h
	lxi d,-rsiz
wyep2:	call wypl
	mov a,b
	ori 080H
	mov m,a
	dad d
	mov a,h
	cpi (vorg/0100H)-1
	jnz wyep2
	pop h
	mov a,l
	ani rmsk
	dcx h
	jnz wyep1
	ret

;	rotate the whole screen down one pixel

wyemi:	lxi h,vorg
wyem1:	lxi d,vsiz-rsiz
	push h
	dad d
	call wymi
	pop h
	push h
	lxi d,rsiz
wyem2:	call wymi
	mov a,b
	ori 080H
	mov m,a
	dad d
	mov a,h
	cpi (vorg+vsiz)/0100H
	jnz wyem2
	pop h
	inx h
	mov a,l
	ani rmsk
	jnz wyem1
	ret

;	Add to the neighbor count of adjoining cells according
;	to the bits in this byte.  We do the middle pixel,
;	adding to the count of three successive neighbors in
;	registers B,C,D.

alfa:	mov a,m
	rrc
	jc alf1
	inr b
	inr c
	inr d
alf1:	rrc
	jc alf2
	inr b
	inr d
alf2:	rrc
	rc
	inr b
	inr c
	inr d
	ret

;	shift the neighbor count as we move forward one byte in
;	a row scan

beta:	mov b,c
	mov c,d
	mvi d,00H
	inx h
	mov a,l
	ani 03FH
	rnz
	push d
	lxi d,-rsiz
	dad d
	pop d
	ret

;	PRINCIPAL PROGRAM for carrying out a cycle of LIFE.
;	Only the middle pixel in each byte is calculated
;	so that three passes are necessary after each of three
;	shifts. Two adjacent pixels are used, the right to hold
;	the present living status and the left for information
;	for the next cycle.

epsi:	lxi h,vorg+rsiz-1
gama:	mvi d,00H
	call alfa
	call beta
	call alfa
delt:	push h
	call beta
	call alfa
	xthl
	mov a,b
	cpi 002H
	jz eta
	cpi 003H
	jz zeta
	mov a,m
	ori 010H
	mov m,a
	jmp thet
zeta:	mov a,m
	ani 0EFH
	mov m,a
	jmp thet
eta:	mov a,m
	ani 0EFH
	mov e,a
	ani 002H
	rlc
	rlc
	rlc
	ora e
	mov m,a
thet:	pop h
	mov a,l
	ani rmsk
	jnz delt
	push d
	lxi d,2*rsiz-1
	dad d
	pop d
	mov a,h
	cpi (vorg+vsiz)/0100H
	jnz gama
	ret

;	updating loop, moving left pixel to right

cycl:	lxi h,vorg
cyc1:	mov a,m
	ani 038H
	mov b,a
	rrc
	rrc
	rrc
	ora b
	ori 080H
	mov m,a
	inx h
	mov a,h
	cpi (vorg+vsiz)/0100H
	jnz cyc1
	ret

;	execute a single cycle of LIFE by updating the middle
;	pixel and making three sweeps while shifting each time

hh:	call epsi
	call wyepl
	call epsi
	call wyepl
	call epsi
	call wyemi
	call wyemi
	jmp cycl

;	extinguish cursor, move two pixels east, light cursor

ee:	call cure
	call xpl
	call xpl
	jmp  cure

;	extinguish cursor, two pixels west, light cursor

ww:	call cure
	call xmi
	call xmi
	jmp  cure

;	extinguish cursor, one pixel north, light cursor

nn:	call cure
	call ypl
	jmp  cure

;	extinguish cursor, one pixel south, light cursor

ss:	call cure
	call ymi
	jmp  cure

;	extinguish a life cell

kk:	call xpl
	call cuex
	jmp xmi

;	activate a life cell

ll:	call xpl
	call culi
	jmp  xmi

;	move whole screen right one life cell, with cursor

eas:	call ekspl
	call ekspl
	call xpl
	jmp  xpl

;	move the whole screen left one life cell, with cursor

wes:	call eksmi
	call eksmi
	call xmi
	jmp  xmi

;	move the whole screen up one life cell, with cursor

nor:	call wyepl
	jmp  ypl

;	move the whole screen down one life cell, with cursor

sou:	call wyemi
	jmp  ymi

;	build up one-byte decimal number from digit string
;	null string =1, minus creates negative modulo 256
;	to correct an error type four zeroes and start over

decm:	mvi b,01H
	call read
	cpi '-'
	jnz dec1
	lxi h,dec3
	push h
	call read
dec1:	cpi '0'
	rc
	cpi '9'+1
	rnc
	mvi b,00H
dec2:	cpi '0'
	rc
	cpi '9'+1
	rnc
	sui '0'
	mov c,a
	mov a,b
	rlc
	rlc
	add b
	rlc
	add c
	mov b,a
	call read
	jmp dec2
dec3:	push sp
	mov a,b
	cma
	inr a
	mov b,a
	pop sp
	ret

;	get (B,C)= (count, operation)

coop:	call decm
	mov c,a
	ret

;	get (B,C) = (X,Y); for example a pair of coordinates
;	first read b=x, then c=y

pair:	call decm
	push b
	call decm
	pop sp
	mov c,b
	mov b,a
	ret

;	place a dot with coordinates x,y on the screen

pp:	call pair
	lxi h,wye
	mov m,c
	inx h
	mov m,b
	call cart
	jmp culi

;	draw a line with increments (dx,dy)

ii:	call pair
	jmp line

;	=======================================================
;	beginning of second ROM
;	=======================================================

	org	9400H

	jmp main

;	repeat the subroutine in (H,L) for the number of times
;	in B.

rept:	mov a,c
	push h
	push b
	lxi d,repi
	push d
	pchl
repi:	pop b
	pop h
	dcr b
	rz
	jmp rept

;	turn one ASCII digit into a macro location

mloc:	lxi h,0005H
	dad sp
	mov e,m
	mvi d,00H
	mvi m,01H
	lxi b,morg
	xchg
	dad h
	dad h
	dad h
	dad h
	dad h
	dad b
	ret

;	record a macro definition

mdef:	call mloc
mde1:	call coop
	mov m,b
	inx h
	mov m,c
	inx h
	mvi a,01BH
	cmp c
	rz
	push h
	lxi h,vect
	call rept
	pop h
	jmp mde1

;	execute a defined macro

mxec:	call mloc
	push h
mxe1:	pop h
	mov b,m
	inx h
	mov a,m
	inx h
	cpi 01BH
	rz
	cpi ')'
	jz rpar
	cpi '('
	jz lpar
	mov c,a
	push h
	lxi h,vect
	call rept
	jmp mxe1
rpar:	pop psw
	dcr a
	jz  rpa1
	pop h
	push h
	push psw
	push h
	jmp mxe1
rpa1:	xthl
	jmp mxe1
lpar:	push h
	mov a,b
	push psw
	push h
	jmp mxe1

;	directory vector for LIFE demonstration

vect:	cpi 'N'		;rotate screen north
	jz  nor
	cpi 'S'		;rotate screen south
	jz  sou
	cpi 'E'		;rotate screen east
    	jz  eas
	cpi 'W'		;rotate screen west
	jz  wes
	cpi 06EH	;'n' - move cursor north
	jz  nn
	cpi 073H	;'s' - move cursor south
	jz  ss
	cpi 065H	;'e' - move cursor east
	jz  ee
	cpi 077H	;'w' - move cursor west
	jz  ww
	cpi 06BH	;'k' - deactivate cell
	jz  kk
	cpi 06CH	;'l' - activate cell under cursor
	jz  ll
	cpi 'C'		;clear screen to black
	jz  blak
	cpi 'R'		;reverse the screen
	jz  reve
	cpi 068H	;'h' - advance one cycle of LIFE
	jz  hh
	cpi 067H	;'g' - repeat cycles of LIFE
	jz  gg
	cpi '.'		;reverse cursor illumination
	jz  cure
	cpi '!'
	jz mdef
	cpi '?'
	jz mxec
	cpi 069H
	jz  ii
	cpi 070H
	jz  pp
	cpi ';'		;exit to monitor
	jz  0000H
vend:	ret

;	call hh repeatedly unless keyboard input is waiting

gg:	lda kbfl
	ora a
	rz
	call hh
	jmp gg

;	MAIN PROGRAM for LIFE demonstration
;	commands consist of a count and a letter.  An operation
;	is repeated the number of times required, null and zero
;	both being taken as once.  The correspondence between
;	letters and operations is established by a sequence of
;	CPI's and JZ's in the array vect.

main:	call home
loop:	call coop
	lxi h,vect
	call rept
	jmp loop

	end
