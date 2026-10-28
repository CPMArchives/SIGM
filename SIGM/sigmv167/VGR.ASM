
msk:	equ	00CC9H
wy:	equ	00CCAH	;wy,ex form a double byte in this order
ex:	equ	00CCBH
wye:	equ	00CCCH
eks:	equ	00CCDH
ssiz:	equ	02000H
rsiz:	equ	040H
sorg:	equ	04000H

	org	0100H
	jmp gdem


;	point mode: move cursor right

pxpl:	lxi h,msk
	mov a,m
	ani 0AAH
	jz  pxp1
	rrc
	mov m,a
	ret
pxp1:	mov a,m
	rrc
	rrc
	rrc
	mov m,a
	ani 0A0H
	rz
	lda ex
	adi 004H
	sta ex
	ret

;	point mode: move cursor left

pxmi:	lxi h,msk
	mov a,m
	ani 055H
	jz  pxm1
	rlc
	mov m,a
	ret
pxm1:	mov a,m
	rlc
	rlc
	rlc
	mov m,a
	ani 005H
	rz
	lda ex
	sui 004H
	sta ex
	ret

;	point mode: move cursor up

pypl:	lxi h,msk
	mov a,m
	ani 033H
	jz  pyp1
	rlc
	rlc
	mov m,a
	ret
pyp1:	mov a,m
	rrc
	rrc
	mov m,a
	lda wy
	sui 002H
	sta wy
	ret

;	point mode: move cursor down

pymi:	lxi h,msk
	mov a,m
	ani 0CCH
	jz  pym1
	rrc
	rrc
	mov m,a
	ret
pym1	mov a,m
	rlc
	rlc
	mov m,a
	lda wy
	adi 002H
	sta wy
	ret

;	load acc with mask, HL with byte address from
;	(msk,wy,ex)

dot:	lhld wy
	mov a,h
	mvi h,sorg/02000H
	dad h
	dad h
	dad h
	dad h
	dad h
	rrc
	rrc
	ora l
	mov l,a
	lda msk
	ret

;	point mode: home cursor

phom:	lxi h,08080H
	shld wy
	mvi a,040H
	sta msk
	ret

;	point mode: make white dot at cursor

pwhit:	call dot
	ora m
	mov m,a
	ret

;	point mode: make black dot at cursor

pblak:	call dot
	cma
	ana m
	mov m,a
	ret

;	point mode: reverse dot under cursor

prev:	call dot
	xra m
	mov m,a
	ret

;	point mode: test dot under cursor

ptest:	call dot
	ana m
	ret

;	both modes: clear screen to white

whit:	lxi d,ssiz
	lxi h,sorg
whi1:	mvi m,0FFH
	inx h
	dcr e
	jnz whi1
	dcr d
	jnz whi1
	ret

;	both modes: clear screen to black

blak:	lxi d,ssiz
	lxi h,sorg
bla1:	mvi m,000H
	inx h
	dcr e
	jnz bla1
	dcr d
	jnz bla1
	ret

;	both modes: reverse entire screen

reve:	lxi d,ssiz
	lxi h,sorg
rev1:	mov a,m
	xri 0FFH
	mov m,a
	inx h
	dcr e
	jnz rev1
	dcr d
	jnz rev1
	ret

;	point mode:	given a cartesian address, form a bit
;	mask and byte address for the cursor

pcar:	lhld wye
	mvi b,001H
	mov a,h
	rrc
	jnc pca1
	mov h,a
	mov a,b
	rlc
	mov b,a
	mov a,h
pca1:	rrc
	jnc pca2
	mov a,b
	rlc
	rlc
	rlc
	rlc
	mov b,a
pca2:	mov a,l
	rrc
	mov b,a
	jnc pca3
	rlc
	rlc
pca3:	sta msk
	lda wye
	ani 0FCH
	sta wy
	lda eks
	ani 0FEH
	sta wy
	ret

;	point mode:  draw a line between two points
;	given the increments (B,C)=(dx,dy)

plin:	lxi h,pxpl
	mov a,b
	ora a
	jp  pli1
	cma
	inr a
	mov b,a
	lxi h,pxmi
pli1:	lxi d,pypl
	mov a,c
	ora a
	jp  pli2
	cma
	inr a
	mov c,a
	lxi d,pymi
pli2:	cmp b
	jnc pli3
	xchg
	mov c,b
	mov b,a
pli3:	mov a,c
	sta eks
	mov a,b
	add a
	mov b,a
	sub c
	push psw
	sub c
	mov c,a
pli4:	pop psw
	push h
	lxi h,prev
	xthl
	cpi 001H
	jm  pli5
	push h
	add c
	jmp pli6
pli5:	add b
pli6:	push d
	push psw
	lda eks
	dcr a
	sta eks
	jnz pli4
	pop psw
	ret

;	point mode: shift within one byte to scroll the
;	screen right one pixel

pexpl:	mov a,m
	rrc
	mov b,a
	ani 055H
	ora c
	mov c,a
	mov a,b
	rrc
	rrc
	mov b,a
	ani 00AH
	ora c
	mov c,a
	mov a,b
	ani 0A0H
	mov b,c
	mov c,a
	ret

;	point mode: intra-byte shift to scroll left one pixel

pexmi:	mov a,m
	rlc
	mov b,a
	ani 0AAH
	ora c
	mov c,a
	mov a,b
	rlc
	rlc
	mov b,a
	ani 050H
	ora c
	mov c,a
	mov a,b
	ani 005H
	mov b,c
	mov c,a
	ret

;	point mode: intrabyte shift to scroll up one pixel

pwypl:	mov a,m
	mov b,a
	rlc
	rlc
	ani 0CCH
	ora c
	mov c,a
	mov a,b
	ani 0CCH
	rrc
	rrc
	mov b,c
	mov c,a
	ret

;	point mode: intrabyte shift to scroll down one pixel

pwymi:	mov a,m
	mov b,a
	rrc
	rrc
	ani 033H
	ora c
	mov c,a
	mov a,b
	ani 033H
	rlc
	rlc
	mov b,c
	mov c,a
	ret

;	point mode: move entire screen right one pixel

pekspl:	lxi h,sorg
	lxi d,rsiz-1
peksp1:	push h
	dad d
	call pexpl
	pop h
peksp2:	call pexpl
	mov m,b
	inx h
	mov a,l
	ani 03FH
	jnz peksp2
	mov a,h
	cpi (sorg+ssiz)/0100H
	jnz peksp1
	ret

;	point mode: shift entire screen left one pixel

peksmi:	lxi h,sorg+ssiz-1
	lxi d,-rsiz+1
peksm1:	push h
	dad d
	call pexmi
	pop h
peksm2:	call pexmi
	mov m,b
	mov a,l
	ani 03FH
	dcx h
	jnz peksm2
	mov a,h
	cpi sorg/0100H-1
	jnz peksm1
	ret

;	point mode: shift entire screen up one pixel

pwyepl:	lxi h,sorg+ssiz-1
pwyep1:	lxi d,-ssiz+rsiz
	push h
	dad d
	call pwypl
	pop h
	push h
	lxi d,-rsiz
pwyep2:	call pwypl
	mov m,b
	dad d
	mov a,h
	cpi sorg/0100H-1
	jnz pwyep2
	pop h
	mov a,l
	ani 03FH
	dcx h
	jnz pwyep1
	ret

;	point mode: move entire screen down one pixel

pwyemi:	lxi h,sorg
pwyem1:	lxi d,ssiz-rsiz
	push h
	dad d
	call pwymi
	pop h
	push h
	lxi d,rsiz
pwyem2:	call pwymi
	mov m,b
	dad d
	mov a,h
	cpi (sorg+ssiz)/0100H
	jnz pwyem2
	pop h
	inx h
	mov a,l
	ani 03FH
	jnz pwyem1
	ret

;	fast right shift of 4 pixels= 1 byte

fxpl:	lxi h,sorg
	lxi d,rsiz-1
fxp1:	push h
	dad d
	mov b,m
	pop h
fxp2:	mov a,m
	mov m,b
	mov b,a
	inx h
	mov a,l
	ani 03FH
	jnz fxp2
	mov a,h
	cpi (sorg+ssiz)/0100H
	jnz fxp1
	ret

;	fast left shift of 4 pixels which is one byte

fxmi:	lxi h,sorg+ssiz-1
	lxi d,-rsiz+1
fxm1:	push h
	dad d
	mov b,m
	pop h
fxm2:	mov a,m
	mov m,b
	mov b,a
	mov a,l
	ani 03FH
	dcx h
	jnz fxm2
	mov a,h
	cpi sorg/0100H-1
	jnz fxm1
	ret

;	fast shift up by 2 pixels = 1 byte

fypl:	lxi h,sorg+ssiz-1
fyp1:	lxi d,-ssiz+rsiz
	push h
	dad d
	mov b,m
	pop h
	push h
	lxi d,-rsiz
fyp2:	mov a,m
	mov m,b
	mov b,a
	dad d
	mov a,h
	cpi sorg/0100H-1
	jnz fyp2
	pop h
	mov a,l
	ani 03FH
	dcx h
	jnz fyp1
	ret

;	fast down shift of entire screen by 2 pixels = 1 byte

fymi:	lxi h,sorg
fym1:	lxi d,ssiz-rsiz
	push h
	dad d
	mov b,m
	pop h
	push h
	lxi d,rsiz
fym2:	mov a,m
	mov m,b
	mov b,a
	dad d
	mov a,h
	cpi (sorg+ssiz)/0100H
	jnz fym2
	pop h
	inx h
	mov a,l
	ani 03FH
	jnz fym1
	ret

;	gray mode: in-byte right shift

gexpl:	mov a,m
	rrc
	rrc
	rrc
	rrc
	mov b,a
	ani 00FH
	ora c
	mov c,a
	mov a,b
	ani 0F0H
	mov b,c
	mov c,a
	ret

;	gray mode: intrabyte left shift of one pixel

gexmi:	mov a,m
	rlc
	rlc
	rlc
	rlc
	mov b,a
	ani 0E0H
	ora c
	mov c,a
	mov a,b
	ani 00FH
	mov b,c
	mov c,a
	ret

;	gray mode: shift whole screen 1 pixel right

gekspl:	lxi h,sorg
	lxi d,rsiz-1
geksp1:	push h
	dad d
	call gexpl
	pop h
geksp2:	call gexpl
	mov m,b
	inx h
	mov a,l
	ani 03FH
	jnz geksp2
	mov a,h
	cpi (sorg+ssiz)/0100H
	jnz geksp1
	ret

;	gray mode: shift entire screen left one pixel

geksmi:	lxi h,sorg+ssiz-1
	lxi d,-rsiz+1
geksm1:	push h
	dad d
	call gexmi
	pop h
geksm2:	call gexmi
	mov m,b
	mov a,l
	ani 03FH
	dcx h
	jnz geksm2
	mov a,h
	cpi sorg/0100H-1
	jnz geksm1
	ret

;	gray mode: move cursor right one pixel

gxpl:	lxi h,msk
	mov a,m
	ani 0F0H
	jz  gxp1
	mvi m,00FH
	ret
gxp1:	mvi m,0F0H
	lda ex
	adi 004H
	sta ex
	ret

;	gray mode: shift cursor left one pixel

gxmi:	lxi h,msk
	mov a,m
	ani 00FH
	jz  gxm1
	mvi m,0F0H
	ret
gxm1:	mvi m,00FH
	lda ex
	sui 004H
	sta ex
	ret

;	gray mode: move cursor up one pixel

gypl:	lda wy
	sui 002H
	sta wy
	ret

;	gray mode: move cursor down one pixel

gymi:	lda wy
	adi 002H
	sta wy
	ret

;	gray mode: home cursor

ghom:	lxi h,08080H
	shld wy
	mvi a,00FH
	sta msk
	ret

;	gray mode: make cursor pixel white

gwhi:	call dot
	ora m
	mov m,a
	ret

;	gray mode: make cursor pixel black

gbla:	call dot
	cma
	ana m
	mov m,a
	ret

;	gray mode: reverse cursor pixel

grev:	call dot
	xra m
	mov m,a
	ret

;	gray mode: sense cursor pixel

gsen:	call dot
	ana m
	rz
	push psw
	ani 0F0H
	pop psw
	rz
	rrc
	rrc
	rrc
	rrc
	ret

;	gray mode: raise gray level of cursor pixel

gzpl:	call dot
	mov b,a
	cma
	ana m
	mov c,a
	mov a,b
	ana m
	adi 011H
	ana b
	ora c
	mov m,a
	ret

;	gray mode: lower pixel under cursor one gray level

gzmi:	call dot
	mov b,a
	cma
	ana m
	mov c,a
	mov a,b
	ana m
	adi 0FFH
	ana b
	ora c
	mov m,a
	ret

;	gray mode: cartesian coordinates to mask, byte address

gcart:	lhld wye
	mov a,l
	ani 03FH
	rlc
	sta wy
	mov a,h
	ani 03FH
	rrc
	push psw
	rlc
	rlc
	rlc
	sta ex
	pop psw
	mvi a,00FH
	jc  gcar1
	xri 0FFH
gcar1:	sta msk
	ret

;	form decimal number from digit string

nure:	mvi b,000H
nur1:	call read
	cpi '-'
	jz  numi
	cpi '0'
	rc
	cpi ':'
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
	jmp nur1
numi:	lxi h,minu
	push h
	jmp nur1
minu:	push psw
	mov a,b
	cma
	inr a
	mov b,a
	pop psw
	ret

;	get (B,C)=(count, operation)

coop:	call nure
	mov c,a
	mov a,b
	ora a
	rnz
	mvi b,001H
	ret

;	get (B,C)=(x,y)

coor:	call nure
	push b
	call nure
	pop psw
	mov c,b
	mov b,a
	ret

;	repeat the subroutine in (HL) (B) times

iter:	push b
	mov a,c
	push h
	lxi d,ite1
	push d
	pchl
ite1:	pop h
	pop b
	dcr b
	rz
	jmp iter

	nop
	nop

;	block of combined cursor movements and cursor
;	inversions in the point mode - for demonstration

pn:	call prev
	call pypl
	jmp  prev

ps:	call prev
	call pymi
	jmp  prev

pe:	call prev
	call pxpl
	jmp  prev

pw:	call prev
	call pxmi
	jmp  prev

;	place the individual negatives of the bytes B,C in H,L

negl:	mov a,c
	cma
	inr a
	mov l,a
	mov a,b
	cma
	inr a
	mov h,a
	ret

;	add D,E to H,L as two separate bytes, sum in H,L

addl:	mov a,e
	add l
	mov l,a
	mov a,d
	add h
	mov h,a
	ret

;	command i reads increment pair, plots line

pii:	call coor
	jmp  plin

;	command t reads two adjacent edges, plots triangle

tt:	call coor
	call negl
	push h
	push b
	call coor
	call negl
	pop d
	call addl
	push h
	call plin
	pop b
	call plin
	pop b
	jmp  plin

;	command p reads cartesian coordinates, plots point

pp:	call coor
	mov a,b
	adi 080H
	sta eks
	mov a,c
	cma
	adi 081H
	sta wye
	call pcar
	jmp  prev

;	block of combined screen-cursor shifts

pea:	call pekspl
	jmp  pxpl

pwe:	call peksmi
	jmp  pxmi

pno:	call pwyepl
	jmp  pypl

pso:	call pwyemi
	jmp  pymi

;	similar block for grey mode

gea:	call gekspl
	jmp  gxpl

gwe:	call geksmi
	jmp  gxmi

gno:	call fypl
	jmp  gypl

gso:	call fymi
	jmp  gymi

;	combined cursor movement and 8-level gray shift

ge:	call gzeh
	call gxpl
	jmp  gzeh

gw:	call gzeh
	call gxmi
	jmp  gzeh

gn:	call gzeh
	call gypl
	jmp  gzeh

gs:	call gzeh
	call gymi
	jmp  gzeh

;	move whole screen through 8 gray points

gzeeh:	lxi d,ssiz
	lxi h,sorg
gzee1:	mov b,m
	mov a,b
	ani 0F0H
	mov c,a
	mov a,b
	adi 008H
	ani 00FH
	ora c
	adi 080H
	mov m,a
	inx h
	dcr e
	jnz gzee1
	dcr d
	jnz gzee1
	ret

;	lighten the whole screen by one grey point

gzeepl:	lxi d,ssiz
	lxi h,sorg
gzeep1:	mov b,m
	mov a,b
	ani 0F0H
	mov c,a
	mov a,b
	adi 001H
	ani 00FH
	ora c
	adi 010H
	mov m,a
	inx h
	dcr e
	jnz gzeep1
	dcr d
	jnz gzeep1
	ret

;	darken whole screen by one gray point

gzeemi:	lxi d,ssiz
	lxi h,sorg
gzeem1:	mov b,m
	mov a,b
	ani 0F0H
	mov c,a
	mov a,b
	adi 00FH
	ani 00FH
	ora c
	adi 0F0H
	mov m,a
	inx h
	dcr e
	jnz gzeem1
	dcr d
	jnz gzeem1
	ret

;	lighten the pixel under the cursor by 8 points

gzeh:	call dot
gzed:	mov c,a
	cma
	ana m
	mov b,a
	mov a,m
	ana c
	adi 088H
	ana c
	ora b
	mov m,a
	ret

;	lighten all pixels from here to left margin 8 points

edge:	call dot
	ora a
	jp edg1
	call gzed
edg1:	mov a,l
	ani 03FH
	rz
	dcx h
	mov b,m
	mov a,b
	ani 0F0H
	mov c,a
	mov a,b
	sui 008H
	ani 00FH
	ora c
	sui 080H
	mov m,a
	jmp edg1

;	block of combined cursor movements and pixel reverses

gee:	call gxpl
	jmp  gzeh

gww:	call gxmi
	jmp  gzeh

gnn:	call gypl
	jmp  gzeh

gss:	call gymi
	jmp  gzeh

;	draw a line with given increments in grey mode

glin:	lxi h,gxpl
	mov a,b
	ora a
	jp gli1
	cma
	inr a
	mov b,a
	lxi h,gxmi
gli1:	lxi d,gypl
	mov a,c
	ora a
	jp gli2
	cma
	inr a
	mov c,a
	lxi d,gymi
gli2:	cmp b
	jnc gli3
	xchg
	mov c,b
	mov b,a
gli3:	mov a,c
	sta eks
	mov a,b
	add a
	mov b,a
	sub c
	push psw
	sub c
	mov c,a
gli4:	pop psw
	push h
	lxi h,gzeh
	xthl
	cpi 001H
	jm gli5
	push h
	add c
	jmp gli6
gli5:	add b
gli6:	push d
	push psw
	lda eks
	dcr a
	sta eks
	jnz gli4
	pop psw
	ret

;	draw a shaded triangle

shat:	call coor
	call negl
	push h
	push b
	call coor
	call negl
	pop d
	call addl
	push h
	call glin
	call edge
	pop b
	call glin
	call edge
	pop b
	jmp  glin

;	- - -  LIFE in the gray mode - - -



;	ordinary cycle for neighbors of left pixel

olep:	push h
	push h
	dad d
	mov a,m
	adi 011H
	mov m,a
	dcx h
	inr m
	pop h
	dcx h
	inr m
	dad b
	inr m
	inx h
	mov a,m
	adi 011H
	mov m,a
	pop h
	ret

;	ordinary cycle for neighbors of right pixel

orip:	push h
	push h
	dad d
	mov a,m
	adi 011H
	mov m,a
	inx h
	mov a,m
	adi 010H
	mov m,a
	pop h
	inx h
	mov a,m
	adi 010H
	mov m,a
	dad b
	mov a,m
	adi 010H
	mov m,a
	dcx h
	mov a,m
	adi 011H
	mov m,a
	pop h
	ret

;	count neighbors of ordinary cells

onec:	lxi b,rsiz
	lxi d,-rsiz
	lxi h,sorg+rsiz
one1:	mov a,m
	ani 080H
	cnz rnom
	mov a,m
	ani 008H
	cnz lnom
	inx h
	mov a,l
	cpi 0C0H
	jnz one1
	mov a,h
	cpi (sorg+ssiz)/0100H-1
	jnz one1
	ret

;	update to next generation once neighbor count done

next:	lxi d,ssiz
	lxi h,sorg
nex1:	mov a,m
	ora a
	jz nex8
	mov c,a
	ani 077H
	mov b,a
	mov a,c
	ani 088H
	mov c,a
	rlc
	add b
	mov b,a
	push h
	lxi h,nex4
	xthl
	mov a,b
	ani 0F0H
	cpi 020H
	jz nex2
	cpi 030H
	jz nex3
	xra a
	ret
nex2:	mov a,c
	ani 080H
	ret
nex3:	mvi a,080H
	ret
nex4:	push psw
	push h
	lxi h,nex7
	xthl
	mov a,b
	ani 00FH
	cpi 002H
	jz nex5
	cpi 003H
	jz nex6
	xra a
	ret
nex5:	mov a,c
	ani 008H
	ret
nex6:	mvi a,008H
	ret
nex7:	pop b
	ora b
	mov m,a
nex8:	inx h
	dcr e
	jnz nex1
	dcr d
	jnz nex1
	ret

;	cycle for left pixel on left margin

llep:	push h
	push h
	push h
	dad d
	mov a,m
	adi 011H
	mov m,a
	mov a,l
	ori 03FH
	mov l,a
	inr m
	pop h
	mov a,l
	ori 03FH
	mov l,a
	inr m
	dad b
	inr m
	pop h
	dad b
	mov a,m
	adi 011H
	mov m,a
	pop h
	ret

;	cycle for right pixel on right margin

rrip:	push h
	push h
	push h
	dad d
	mov a,m
	adi 011H
	mov m,a
	mov a,l
	ani 0C0H
	mov l,a
	mov a,m
	adi 010H
	mov m,a
	pop h
	mov a,l
	ani 0C0H
	mov l,a
	mov a,m
	adi 010H
	mov m,a
	dad b
	mov a,m
	adi 010H
	mov m,a
	pop h
	dad b
	mov a,m
	adi 011H
	mov m,a
	pop h
	ret

;	left pixel: choose between normal or margin cycle

rnom:	mov a,l
	ani 03FH
	jz  llep
	jmp olep

;	right pixel: chose normal or margin cycle

lnom:	mov a,l
	ani 03FH
	cpi 03FH
	jz  rrip
	jmp orip

;	count neighbors along top margin

ncto:	lxi b,rsiz
	lxi d,ssiz-rsiz
	lxi h,sorg
ncti:	mov a,m
	ani 080H
	cnz rnom
	mov a,m
	ani 008H
	cnz lnom
	inx h
	mov a,l
	ani 03FH
	jnz ncti
	ret

;	count neighbors along bottom margin

ncbo:	lxi b,-ssiz+rsiz
	lxi d,-rsiz
	lxi h,sorg+ssiz-rsiz
	jmp ncti

;	execute one cycle of LIFE

life:	call onec
	call ncto
	call ncbo
	jmp next

;	demonstration for point mode graphics

pdem:	call phom
pden:	call coop
	lxi h,pvec
	call iter
	jmp pden

;	menu for point mode graphics

pvec:	cpi 06EH
	jz  pn
	cpi 073H
	jz  ps
	cpi 065H
	jz  pe
	cpi 077H
	jz  pw
	cpi 'N'
	jz  pno
	cpi 'S'
	jz pso
	cpi 'E'
	jz  pea
	cpi 'W'
	jz  pwe
	cpi 'C'
	jz  blak
	cpi 'R'
	jz  reve
	cpi '.'
	jz prev
	cpi 069H
	jz  pii
	cpi 074H
	jz  tt
	cpi 070H
	jz  pp
	cpi ';'
	jz  0000H
	cpi 'G'
	jz  gdem
	ret

;	demonstration for gray mode graphics

gdem:	call ghom
gden:	call coop
	lxi h,gvec
	call iter
	jmp gden


;	vector for gray mode graphic demonstration

gvec:	cpi 06EH
	jz  gn
	cpi 073H
	jz  gs
	cpi 065H
	jz  ge
	cpi 077H
	jz gw
	cpi 'N'
	jz  gno
	cpi 'S'
	jz  gso
	cpi 'E'
	jz  gea
	cpi 'W'
	jz  gwe
	cpi 'B'
	jz  whit
	cpi 07FH
	jz blak
	cpi 'C'
	jz  blak
	cpi 072H
	jz  grev
	cpi 068H
	jz  gzeh
	cpi 06BH
	jz  gzmi
	cpi 06CH
	jz  gzpl
	cpi 'R'
	jz reve
	cpi 'H'
	jz  gzeeh
	cpi 'K'
	jz  gzeemi
	cpi 'L'
	jz  gzeepl
	cpi 069H
	jz gii
	cpi 067H
	jz  life
	cpi '.'
	jz  gzeh
	cpi ';'
	jz  0000H
	cpi 'P'
	jz  pdem
	ret

;	i (= line) in gray mode

gii:	call coor
	jmp  glin

;	- - - read routine - - -

read:	in  0EDH
	ani 040H
	jz  read
	in  0EFH
	ani 07FH
	ret
	end
