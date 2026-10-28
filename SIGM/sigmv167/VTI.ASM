
;	org 0100H
	org 9000H

	jmp main

go:	equ	ge
chin:	equ	0C20H	;POLY-88 WH0 (keyboard wormhole)
;chin:	equ	read	;subroutine to read VDM (port EC)

vorg:	equ	0F800H
vsiz:	equ	00400H
rsiz	equ	00040H
msk:	equ	00CC9H
wye:	equ	00CCAH
eks:	equ	00CCBH
wy:	equ	00CCCH
ex:	equ	00CCDH

;	move cursor up one pixel

ypl:	lxi h,msk
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
	lda wye
	sui 010H
	sta wye
	ret

;	move cursor down one pixel

ymi:	lxi h,msk
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
	lda wye
	adi 010H
	sta wye
	ret

;	move cursor right one pixel

xpl:	lxi h,msk
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
	lda eks
	adi 004H
	sta eks
	ret

;	move cursor left one pixel

xmi:	lxi h,msk
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
	lda eks
	sui 004H
	sta eks
	ret

;	load A with the bit mask, HL with a byte address
;	given the cursor positioning data at (msk,wye,eks)

dot:	lhld wye
	mov a,h
	mvi h,03EH
	dad h
	dad h
	rrc
	rrc
	ora l
	mov l,a
	lda msk
	ret

;	home the cursor

home:	lxi h,8080H
	shld wye
	mvi a,008H
	sta msk
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

crev:	call dot
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
wh1:	mvi m,080H
	inx h
	dcr e
	jnz wh1
	dcr d
	jnz wh1
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

cart:	mvi b,016H
	mvi c,004H
	lda wy
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
	sta wye
	mov a,c
	ani 0F0H
	jnz car3
	mvi a,006H
car3:	mov c,a
	ani 026H
	jz car4
	xri 026H
	mov c,a
car4:	lda ex
	dcr a
	mov b,a
	rlc
	ani 0FCH
	sta eks
	mov a,b
	ani 001H
	mov a,c
	jnz car5
	rrc
	rrc
	rrc
car5:	sta msk
	ret

;	draw a line with increments dx,dy = (C,B).  increment
;	may be + or - using complementary arithmetic, but less
;	than 64 in absolute value to avoid overflow problems.

line:	lxi h,ypl
	mov a,b
	ora a
	jp lin1
	cma
	inr a
	mov b,a
	lxi h,ymi
lin1:	lxi d,xpl
	mov a,c
	ora a
	jp lin2
	cma
	inr a
	mov c,a
	lxi d,xmi
lin2:	cmp b
	jnc lin3
	xchg
	mov c,b
	mov b,a
lin3:	mov a,c
	sta wy
	mov a,b
	add a
	mov b,a
	sub c
	push psw
	sub c
	mov c,a
lin4:	pop psw
	push h
	lxi h,culi
	xthl
	cpi 001H
	jm lin5
	push h
	add c
	jmp lin6
lin5:	add b
lin6:	push d
	push psw
	lda ex
	dcr a
	sta ex
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

;	the movements within one pixel necessary for shifting
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

;	move the whole screen right one pixel

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
	ani 03FH
	jnz eksp2
	mov a,h
	cpi 0FCH
	jnz eksp1
	ret

;	move the whole screen left one pixel

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
	ani 03FH
	dcx h
	jnz eksm2
	mov a,h
	cpi 0F7H
	jnz eksm1
	ret

;	Move the whole screen up one pixel.
;	this is the control loop which calls the shift of
;	a column in such a way as to make it cyclic.

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
	cpi 0F7H
	jnz wyep2
	pop h
	mov a,l
	ani 03FH
	dcx h
	jnz wyep1
	ret

;	Move the whole screen down one pixel

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
	cpi 0FCH
	jnz wyem2
	pop h
	inx h
	mov a,l
	ani 03FH
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
	ani 03FH
	jnz delt
	push d
	lxi d,007FH
	dad d
	pop d
	mov a,h
	cpi 0FCH
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
	cpi 0FCH
	jnz cyc1
	ret

;	execute a single cycle of LIFE by updating the middle
;	pixel and making three sweeps after shifting each time

hh:	call epsi
	call wyepl
	call epsi
	call wyepl
	call epsi
	call wyemi
	call wyemi
	call cycl
	ret

;	repeat h unless an ASCII character is waiting
;	(version for VDM using port ED)

gg:	in  0EDH
	ani 040H
	rnz
	call hh
	jmp  gg

;	version for POLY-88 using keyboard flag at 0C0CH

ge:	lda 0C0CH
	ora a
	rz
	call hh
	jmp ge

;	extinguish cursor, move two pixels east, light cursor

ee:	call crev
	call xpl
	call xpl
	jmp  crev

;	extinguish cursor, two pixels west, light cursor

ww:	call crev
	call xmi
	call xmi
	jmp  crev

;	extinguish cursor, one pixel north, light cursor

nn:	call crev
	call ypl
	jmp  crev

;	extinguish cursor, one pixel south, light cursor

ss:	call crev
	call ymi
	jmp  crev

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

;	directory vector for LIFE demonstration

vect:	cpi 'N'
	jz  nor
	cpi 'S'
	jz  sou
	cpi 'E'
	jz  eas
	cpi 'W'
	jz  wes
	cpi 06EH
	jz  nn
	cpi 073H
	jz  ss
	cpi 065H
	jz  ee
	cpi 077H
	jz  ww
	cpi 06BH
	jz  kk
	cpi 06CH
	jz  ll
	cpi 063H
	jz  blak
	cpi 072H
	jz  reve
	cpi 068H
	jz  hh
	cpi 067H
	jz  go
	cpi '.'
	jz  crev
	cpi ';'
	jz  0000H
	ret

;	keyboard read routine

read:	in  0EDH
	ani 040H
	jz   read
	in  0EFH
	ani 07FH
	ret

;	MAIN PROGRAM for LIFE demonstration

main:	call blak
	call home
	call crev
here:	lxi h,here
	push h
	call chin
	jmp  vect

	end
