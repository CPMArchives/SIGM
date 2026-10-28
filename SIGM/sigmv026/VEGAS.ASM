;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
;          Las Vegas Super-Slot, (c) 1980 by David W. Friedman
;
;                              for the
;
;              Vector Graphics Flashwriter I Video Board
;
;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
;
; Copyright 1980 (c) by: David W. Friedman
;                        2-8-24 Okubo, Shinjuku-Ku
;                        Tokyo, Japan 160
;
; From an article:       Dr. Dobb's Journal
;                        Number 50, November/December 1980
;                        Volume 5, Issue 10
;                        Pages 10-22
;
; Entered by:		 Kelly Smith, MP/M-net (tm)
;                        805-527-9321 (Modem, 300 Baud)
;

true	equ	-1	; define true
false	equ	not true; define false
printer	equ	false	; define printer (used)

base	equ	0	; system base address
wmstt	equ	base
bdos	equ	base+5	; bdos entry address
fcb	equ	base+5ch; file control block
dmad	equ	base+80h; dma address
tpa	equ	base+100h	; transient program area

setbdos	equ	13	; drive number A, default dma address
openf	equ	15	; open file function
closef	equ	16	; close file function
deletef	equ	19	; delete file function
readf	equ	20	; read file function
writef	equ	21	; write file function
creatf	equ	22	; create file function

vid	equ	base+0d000h	; base of video memory
vidh	equ	vid/100h
attb	equ	vid+400h	; base of video attribute memory
attbh	equ	attb/100h
vidndh	equ	vidh+8
lnlgth	equ	64		; video screen length
scrnht	equ	16		; video screen height
blkon	equ	8080h
blkoff	equ	0

ctrl	equ	00011111b	; assembler control key mask
crmk	equ	ctrl and 'M'
bkspmk	equ	ctrl and 'H'
belmk	equ	ctrl and 'G'

	org	tpa	; transient program start address

start:	lxi	sp,stkptr
	call	initiz
main:	call	ready
	call	keytest
	call	pcread
	cpi	'$'
	cz	collect
	cpi	ctrl and 'E'
	cz	exit
	cpi	ctrl and 'T'
	cz	test
	cpi	ctrl and 'Z'
	cz	zero
	cpi	ctrl and 'P'
	cz	plays
	cpi	crmk
	jnz	main
	call	accept
	jz	main
	call	nready
	call	operate
	jnc	main
	call	payjack
	call	svjack
	jmp	main

exit:	lxi	h,exitstg+1
	call	match
	mvi	a,crmk
	rnz
	call	erase
	call	svjack
	jmp	wmstt	; return to CP/M

operate:call	charge
	xra	a
	sta	value
	call	showin
	call	crank
	call	speed
	mvi	a,12	; minimum initial spin time 4
	call	spin1
	call	winchk
	call	showin
credout:lda	value
	ora	a	; carry = 0
	rz
	mov	e,a
	lhld	credtv
bump:	inx	h
	shld	credtv
	call	bksout
	push	h
	push	d
	call	shocred
	pop	d
	pop	h
	call	timerx
	dcr	e
	jnz	bump
	call	spcout	; at least 1 space if big payback
	lda	value
	sui	250
	cmc
	ret

test:	lxi	h,tstmch+1
	call	match
	mvi	a,crmk
	rnz
	lxi	d,tststg
	call	ready1
	lxi	h,100
	call	charge1
test1:	mvi	h,10
test2:	call	timerx
	dcr	h
	jnz	test2
	lxi	h,random
	inr	m
	call	pcin
	ora	a
	jz	test3
	call	pcread
	cpi	crmk
	jnz	test2
	lxi	h,0
	jmp	charge1
test3:	call	accept
	rz
	call	operate
	jmp	test1

zero:	lxi	h,zerostg+1
	call	match
	mvi	a,crmk
	rnz
	lxi	h,0
	shld	recipt
	jmp	plays1

plays:	lxi	h,playstg+1
	call	match
	mvi	a,crmk
	rnz
plays1:	lxi	d,rcptstg
	lxi	h,vid+7*lnlgth+49
	call	shostg
	call	nready
	lhld	recipt
	call	shocrd1
	call	svjack
plays2:	call	pcread
	cpi	crmk
	jnz	plays2
	jmp	shocred

match:	call	pcread
	cmp	m
	inx	h
	rnz
	mov	a,m
	ora	a
	jnz	match
	ret

initiz:	call	erase
	lxi	h,vid+0*lnlgth+0
	lxi	d,payoff
	call	shostg
	lxi	h,vid+14*lnlgth+0
	call	shostg
	lxi	b,blkon+100h*4+12	; 4 X 12 area
	lxi	h,attb+6*lnlgth+0
	call	boxy
	lxi	h,attb+6*lnlgth+48
	call	boxy
	lxi	b,blkon+100h*4+36	; 4 X 36 area
	lxi	h,attb+10*lnlgth+12
	mvi	a,8	; half intensity shading
	call	graph
	lxi	h,attb+2*lnlgth+12
	push	h
	call	graph
	pop	h
	push	h
	lxi	b,blkon+100h*12+10	; 12 X 10 area
	call	graphon
	pop	h
	call	boxy
	lxi	d,(25-12) or (38-25)	; corner delta
	dad	d
	push	h
	call	graphon
	pop	h
	call	boxy
	dad	d
	push	h
	call	graphon
	pop	h
	call	boxy
	lxi	h,attb+8*lnlgth+12
	lxi	b,0302h	; B = 3 columns, C = horizontal line graphics
ticks:	push	h
	mov	a,c
	ora	m
	mov	m,a
	mov	a,l
	adi	9	; 10-1 = box width-1
	mov	l,a
	mov	a,c
	ora	m
	mov	m,a
	pop	h
	dad	d
	dcr	b
	jnz	ticks
	lxi	h,bell	; initial reel display
	shld	reel3p
	lxi	h,bell1x
	shld	reel2p
	lxi	h,bellx
	shld	reel1p
	lxi	h,1010h	; last 16 counts = 4 lines
	shld	reel1s
	shld	reel2s	; includes "reels3"
	call	spin	; applies pattern
	call	crank	; applies handle
	lxi	h,0
	shld	value
	shld	credtv
	shld	recipt
	call	showin
	call	shocred
	call	ldjack
	jp	shojack
	lxi	h,100
init2:	shld	jackpot
shojack:call	belout
	call	timerx
	lxi	d,jackstg
	lxi	h,vid+3*lnlgth+0
	call	shostg
	lxi	d,vid+4*lnlgth+3
	lhld	jackpot
	mvi	b,1
	jmp	sho5dig

keytest:call	pcin	; returns A = 1, if key waiting
	ora	a
	inx	b
	jnz	keytest
	mov	a,c
	sta	random
	ret

collect:call	accept
	mvi	a,crmk
	rnz		; credits remaining
	lxi	d,20
	lhld	recipt
	dad	d
	shld	recipt
	lhld	credtv
	dad	d
	push	d
	call	charge1
	pop	d
	mov	a,e
	jmp	pljack

payjack:lhld	jackpot
	lxi	d,-10
	dad	d
	jnc	paid
	shld	jackpot
	lhld	credtv
	lxi	d,10
	dad	d
	call	charge1
	call	shojack
	lxi	d,jackstg
	lxi	h,vid+8*lnlgth+0
	push	h
	call	shostg
	call	spcout
	call	bksout
	call	bksout
	call	timerx
	pop	h
	call	shostg	; "njackstg" follows "jackstg"
	jmp	payjack

paid:	lxi	h,0
	jmp	init2

accept:	lhld	credtv
	mov	a,h
	ora	l
	ret

crank:	lxi	h,attb+2*lnlgth+55
	push	h
	call	handof
	lxi	h,attb+9*lnlgth+55
	push	h
	call	handon
	pop	h
	call	timerx
	call	crout
	call	timerx
	call	handof
	pop	h
handon:	lxi	b,blkon+100h*2+8	; 2 X 8 box
	call	boxy
	lxi	d,2*lnlgth+6		; lever relative position
	dad	d
	lxi	b,blkon+100h*15+2	; full X 2 box
	jmp	boxy

handof:	lxi	b,blkoff+100h*2+8
	call	boxy
	lxi	d,2*lnlgth+6
	dad	d
	lxi	b,blkoff+100h*15+2
boxy:	push	d
	push	h
	push	h
	push	b
	call	gphrhz	; horizontal lines
	pop	b
	push	b
	ora	a
	cz	boxy2	; if not past right
	pop	b
	pop	h
	push	b
	call	boxy2	; left vertical lines
	pop	b
	push	b
	call	gphrhz	; bottom horizontal lines
	pop	b
	pop	h
	pop	d
	ret

boxy2:	mvi	a,80h
	ana	c	; pickup blkon/off condition
	ori	1	; only 1 wide needed
	mov	c,a
	mvi	a,0100b	; verticle line graphics
	jmp	graph

graphon:mvi	a,0001b	; graphics bit
graph:	push	d
	push	b
	push	psw
	lxi	d,lnlgth
graph1:	mov	a,b
	ani	scrnht-1
	jz	graphed	; if no more
	pop	psw
	push	psw
	push	b
	push	h
	call	grapher
	pop	h
	pop	b
	dad	d
	mov	a,h
	cpi	vidndh
	jnc	graphed	; if past bottom
	dcr	b
	jmp	graph1
graphed:pop	psw
	pop	b
	pop	d
	ret

gphrhz:	mvi	a,0010b	; horizontal line graphics
grapher:mov	b,a
graphr1:mov	a,c
	ani	lnlgth-1
	rz		; if no more
	mov	a,b
	cma		; create bit mask
	ana	m
	mov	m,a
	mov	a,c
	ora	a
	jp	grphof	; if blkoff, then done
	mov	a,b
	ora	m
	mov	m,a	; set bit to 1
grphof:	inx	h	; next byte
	mov	a,l
	ani	lnlgth-1
	mov	a,h	; A reg. non-zero on return, if past right edge
	rz
	dcr	c
	jmp	graphr1

speed:	lxi	d,reel1s
	lhld	random	; in L reg.
	mvi	a,00110000b
	ana	l
	ori	80h
	stax	d	; range 80, 90, a0, b0
	inx	d	; reel2s
	mvi	a,00011000b
	ana	l
	ori	0c0h
	stax	d	; range c0, c8, d0,d8
	inx	d	; reel3s
	mvi	a,00001100b
	ana	l
	ori	10h
	mov	h,a	; random+1 range 10, 14, 18, 1c
	shld	random	; specified in H reg. (random+1)
	ori	0f0h
	stax	d
	ret

spin:	mvi	a,4	; 4 line/pattern
spin1:	sta	spincnt
	lxi	b,reel1s
	lhld	reel1p
	lxi	d,vid+2*lnlgth+12
	call	spiner
	shld	reel1p
	lxi	b,reel2s
	lhld	reel2p
	lxi	d,vid+2*lnlgth+25
	call	spiner
	shld	reel2p
	lxi	b,reel3s
	lhld	reel3p
	lxi	d,vid+2*lnlgth+38
	call	spiner
	shld	reel3p
	lda	spincnt
	dcr	a
	jnz	spin1
	call	pcin
	ora	a
	jnz	stopkey
stopcmp:lda	reel3s
	lhld	reel1s	; reel2s in H reg.
	ora	h
	ora	l
	jnz	spin
	ret

stopkey:call	pcread
	lhld	random+1	; specification in L reg.
	lxi	d,reel1s
	sui	'1'
	mvi	h,0
	jz	stopky1
	dcr	a
	inx	d	; reel2s
	mvi	h,4
	jz	stopky1	; if '2'
	dcr	a
	jnz	spin	; if not '3'
	inx	d	; reel3s
	mvi	h,8
stopky1:ldax	d
	cpi	11h
	jc	spin	; if now stopping
	mov	a,h
	ora	l
	stax	d	; ranges from 10h to 1ch
	mvi	a,8	; minimum time between stop keys
	jmp	spin1

spiner:	ldax	b
spiner1:ora	a
	jz	timer1	; keep speed constant
	dcr	a
	stax	b
	cpi	11h
	jnc	resetp	; if not slowing
	ani	3
	cpi	1
	jnc	timer1	; fill 3/4ths of time
	call	spcout	; sound effects
resetp:	mov	a,m
	cpi	40h	; cherry marker
	jc	resetp1
	lxi	h,cherryy
resetp1:push	d
	lxi	d,-10	; 10 bytes/line
	dad	d
	pop	d
	push	h
	xchg
	call	mvptn
	pop	h	; restore new pattern position for save
	ret

mvptn:	lxi	b,100h*10+12	; 10 wide X 12 high
mvptn2:	push	b
	push	h
mvptn1:	ldax	d
	mov	m,a
	inx	h
	inx	d
	dcr	b
	jnz	mvptn1
	pop	h
	pop	b
	push	d
	lxi	d,lnlgth
	dad	d
	pop	d	; next line, same horizontal position
	dcr	c
	jnz	mvptn2
	ret

timerx:	mvi	a,180	; about right for me...
	jmp	timer

timer1	mvi	a,8	; run a bit faster (9 is exact)
timer:	push	h
	mov	h,a
timea:	dcr	a
	jnz	timea
	dcr	h
	jnz	timea
	pop	h
	ret

winchk:	xra	a
	sta	value
	lxi	h,vid+6*lnlgth+13
	call	bytina
	mov	e,a
	lxi	h,vid+6*lnlgth+26
	call	bytina
	mov	d,a
	lxi	h,vid+6*lnlgth+39
	call	bytina
	cpi	7	; bar code
	jnz	notbar
	cmp	d
	jz	winer3	; any+2 bars, is o.k.
	mov	a,e	; reel 3's code = 1's
notbar:	cmp	e	; r3 verses r1
	jnz	lowchk
	cmp	d	; r3 verses r2
	jnz	lowchk
winer3:	mvi	d,0
	lxi	h,paytbl
	dad	d
	mov	a,m	; table+code = win value
	jmp	strval
lowchk:	mov	a,e
	cpi	1	; cherry's code
	rnz
	cmp	d	; r1 verses r2
	mvi	a,2	; just for first cherry
	jnz	strval
	mvi	a,5	; for both cherries
strval:	sta	value
	cpi	250
	rz
	ora	a
	jz	addjak	; if lemon, won
	cpi	14
	rc
pljack:	rrc
	rrc
	rrc
	ani	0fh
	rz
addjak:	mov	e,a
	mvi	d,0
	inx	d
	lhld	jackpot
	dad	d	; adds from 1 to 13 on jackpot
	jmp	init2

bytina:	mvi	a,01000000b	; non-display code bit
	mov	c,a
	ana	m
	rlc
	mov	b,a
	mov	a,c
	inx	h
	ana	m
	ora	b
	rlc
	mov	b,a
	mov	a,c
	inx	h
	ana	m
	ora	b
	rlc
	rlc		; adjust to lowest bits
	ret

charge:	lhld	credtv
	dcx	h
charge1:shld	credtv
shocred:lxi	d,kredit
	lxi	h,vid+7*lnlgth+49
	call	shostg
	lhld	credtv
shocrd1:lxi	d,vid+8*lnlgth+52
	mvi	b,1	; all zeros show
	jmp	sho5dig

showin:	lxi	d,winstg
	lxi	h,vid+7*lnlgth+2
	call	shostg
	lxi	d,vid+8*lnlgth+2
	lhld	value
	mvi	b,0	; leading zeros suppressed
sho5dig:push	d
	lxi	d,-10000	; X = 10000 divisor
	call	divx
	pop	d
	stax	d
	inx	d
	push	d
	lxi	d,-1000
	call	divx
	pop	d
	stax	d
	inx	d
	push	d
	lxi	d,-100
	call	divx
	pop	d
	stax	d
	inx	d
	push	d
	lxi	d,-10
	call	divx
	pop	d
	stax	d
	inx	d
	push	d
	lxi	d,-1
	call	divx
	pop	d
	cpi	' '
	jnz	lastd
	mvi	a,'0'	; show at least 1 disgit, if zero
lastd:	stax	d
	ret

divx:	mvi	c,'0'-1
divx1:	inr	c
	dad	d
	jc	divx1
	mov	a,e
	cma
	mov	e,a
	mov	a,d
	cma
	mov	d,a
	inx	d	; two's complement in D reg.
	dad	d
	mov	a,c
	ora	b
	mov	b,a	; set suppress flag
	cpi	'0'
	jnz	nlzero
	mvi	c,' '	; if only zeros to here
nlzero:	mov	a,c
	ret

ldjack:	mvi	a,5
ldjak1:	sta	trials
	call	setdsk
	call	setfcb
	call	open
	rm
	call	read
	jnz	tryagn
	lhld	dmad
	shld	jackpot
	lhld	dmad+2
	shld	recipt
	jmp	close
tryagn:	lda	trials
	dcr	a
	jnz	ldjak1
	dcr	a
	ret

svjack:	mvi	a,5
svjack1:sta	trials
	call	setdsk
	call	setfcb
	call	delete
	call	create
	cpi	55
	rnc
	lhld	jackpot
	shld	dmad
	lhld	recipt
	shld	dmad+2
	call	write
	jnz	retry
	call	close
	rp
retry:	lda	trials
	dcr	a
	jnz	svjack1
	ret

mvzfcb:	lxi	b,21h
	lxi	h,fcb
mvcybm:	push	h
mvcybm1:mov	m,b
	inx	h
	dcr	c
	jnz	mvcybm1
	pop	h
	ret

setfcb:	call	mvzfcb
	lxi	d,jackfl
	inx	h
	jmp	shostg

nready:	lxi	d,nredy
	jmp	ready1

ready:	lxi	d,redy
ready1:	lxi	h,vid+11*lnlgth+2
shostg:	ldax	d
	inx	d	; now to skip stop on return
	ora	a
	rz
	mov	m,a
	inx	h
	jmp	shostg

erase:	mvi	a,vidndh
	lxi	h,vid
erase1:	mvi	m,' '
	inx	h
	cmp	h
	jnz	erase1
	ret

pcin:	push	b
	mvi	b,6	; low address byte of bios "console status"
	jmp	caler

pcread:	push	b
	mvi	b,9	; low address byte of bios "console input"
	jmp	caler

belout:	mvi	a,belmk
	jmp	prchr

spcout:	mvi	a,' '
	jmp	prchr

bksout:	mvi	a,bkspmk
	jmp	prchr

crout:	mvi	a,crmk
prchr:	push	b

	if printer
	mvi	b,0fh	; low address byte of bios "list"
	endif

	if not printer
	mvi	b,0ch	; low address byte of bios "conout"
	endif

caler:	push	d
	push	h
	mov	c,a	; routines expect value in C reg.
	lhld	wmstt+1	; H&L regs. = bios warmboot = xx03h
	mov	l,b
	lxi	d,rtnbak
	push	d
	pchl

;
;  BIOS routine executes here
;
rtnbak:	pop	h
	pop	d
	pop	b
	ret

setdsk:	mvi	a,setbdos
	jmp	abdos

delete:	mvi	a,deletef
	jmp	abdos

create:	mvi	a,creatf
	jmp	abdos

write:	mvi	a,writef
	jmp	abdos

close:	mvi	a,closef
	jmp	abdos

open:	mvi	a,openf
	jmp	abdos

read:	mvi	a,readf
abdos:	mov	c,a
	lxi	d,fcb
	call	bdos
	push	a
	lda	attb-lnlgth
	cpi	'B'
	jnz	abdos1
	call	erase
	lxi	d,dskerr
	lxi	h,vid+6*lnlgth+9
	call	shostg
	jmp	wmstt	; bail out to CP/M
abdos1:	pop	a
	ora	a
	ret

dskerr:	db	'Problem with drive A: disk, returning to CP/M',0

jackstg:db	'$' or 80h,' ' or 80h,'J' or 80h
	db	'A' or 80h,'C' or 80h,'K' or 80h
	db	'P' or 80h,'O' or 80h,'T' or 80h
	db	' ' or 80h,'$' or 80H,' ' or 80h,0

njakstg:db	'     '
nredy:	db	'       ',0

redy:	db	' ' or 80h,'R' or 80h,'E' or 80h
	db	'A' or 80h,'D' or 80h,'Y' or 80h
	db	' ' or 80h,0

jackfl:	db	'jackpotslot',0

tststg:	db	'Testing',0

kredit:	db	'$ Credit $',0

rcptstg:db	' Receipts ',0

winstg:	db	'$ Wins $',0

exitstg:db	ctrl and 'E',ctrl and 'X',ctrl and 'I',ctrl and 'T',0

zerostg:db	ctrl and 'Z',ctrl and 'E',ctrl and 'R',ctrl and 'O',0

tstmch:	db	ctrl and 'T',ctrl and 'E',ctrl and 'S',ctrl and 'T',0

playstg:db	ctrl and 'P',ctrl and 'L',ctrl and 'A',ctrl and 'Y',0

;
;  paytable, where:
;
; lem=0, cht=10, org=10, plm=14, bel=20, $$$=50, mel=100, bar=250
;
paytbl:	db	0,10,10,14,20,50,100,250

payoff:	db	' All bars= 250+jackpot '
	db	'  Las Vegas     '
	db	'Melon+ M/Bar+M/Bar=100    '
	db	'$$$$+$$/Bar+$$/Bar=50 '
	db	'  Super-Slot    '
	db	'Bell+BL/Bar+BL/Bar=20',0
	db	' Plum+PL/Bar+PL/Bar=14 '
	db	'   (c) 1980     '
	db	'Orange+0/Bar+0/Bar=10     '
	db	'Cherry+C/Bar+C/Bar=10 '
	db	' Dave Friedman  '
	db	'C+C+Any=5   C+Any=2',0

cherry:

	db	40h
	db	00h
	db	00h
	db	40h
	db	00h
	db	00h
	db	00h
	db	00h
	db	03h
	db	10h
	db	00h
	db	00h
	db	00h
	db	1fh
	db	3fh
	db	3fh
	db	3bh
	db	01h
	db	1eh
	db	00h
	db	00h
	db	09h
	db	1bh
	db	1fh
	db	2dh
	db	37h
	db	1fh
	db	3fh
	db	19h
	db	08h
	db	00h
	db	26h
	db	36h
	db	36h
	db	20h
	db	04h
	db	36h
	db	36h
	db	34h
	db	20h
	db	00h
	db	40h
	db	49h
	db	12h
	db	1bh
	db	19h
	db	09h
	db	08h
	db	00h
	db	00h
	db	01h
	db	34h
	db	0ch
	db	10h
	db	04h
	db	3bh
	db	2dh
	db	2eh
	db	3bh
	db	08h
	db	06h
	db	08h
	db	02h
	db	05h
	db	01h
	db	3ch
	db	2dh
	db	1bh
	db	1eh
	db	20h
	db	00h
	db	04h
	db	22h
	db	12h
	db	36h
	db	34h
	db	24h
	db	20h
	db	00h
	db	00h

bell:

	db	00h
	db	40h
	db	12h
	db	12h
	db	13h
	db	1ah
	db	12h
	db	12h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	1fh
	db	3fh
	db	3fh
	db	3bh
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	0bh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	19h
	db	00h
	db	00h
	db	00h
	db	04h
	db	24h
	db	24h
	db	26h
	db	34h
	db	24h
	db	24h
	db	20h
	db	00h
	db	01h
	db	49h
	db	49h
	db	49h
	db	09h
	db	09h
	db	09h
	db	09h
	db	09h
	db	08h
	db	07h
	db	02h
	db	11h
	db	38h
	db	1bh
	db	18h
	db	38h
	db	12h
	db	07h
	db	38h
	db	07h
	db	06h
	db	30h
	db	38h
	db	1bh
	db	18h
	db	38h
	db	3bh
	db	2eh
	db	38h
	db	04h
	db	24h
	db	24h
	db	24h
	db	24h
	db	24h
	db	24h
	db	24h
	db	24h
	db	20h
	db	00h
	db	00h
	db	40h
	db	01h
	db	09h
	db	09h
	db	09h
	db	08h
	db	00h
	db	00h
	db	00h
	db	0bh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	3bh
	db	00h
	db	00h
	db	37h
	db	3fh
	db	3dh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	34h
	db	00h
	db	00h
	db	00h
	db	24h
	db	24h
	db	24h
	db	24h
	db	20h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	09h
	db	09h
	db	09h
	db	00h
	db	00h
	db	00h
	db	1bh
	db	1fh
	db	24h
	db	3fh
	db	3fh
	db	3fh
	db	30h
	db	00h
	db	00h
	db	0fh
	db	3fh
	db	3fh
	db	12h
	db	12h
	db	16h
	db	24h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	40h
	db	40h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	01h
	db	0bh
	db	1bh
	db	3fh
	db	3fh
	db	3bh
	db	18h
	db	00h
	db	00h
	db	02h
	db	3eh
	db	3fh
	db	3fh
	db	3eh
	db	34h
	db	20h
	db	00h
	db	00h
	db	02h
	db	34h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	40h
	db	01h
	db	09h
	db	09h
	db	09h
	db	08h
	db	00h
	db	00h
	db	00h
	db	0bh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	3bh
	db	00h
	db	00h
	db	37h
	db	3fh
	db	3dh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	34h
	db	00h
	db	00h
	db	00h
	db	24h
	db	24h
	db	24h
	db	24h
	db	20h
	db	00h
	db	00h
	db	00h
	db	00h
	db	40h
	db	00h
	db	42h
	db	1ah
	db	02h
	db	1ah
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	3ch
	db	24h
	db	3ch
	db	24h
	db	3ch
	db	24h
	db	20h
	db	00h
	db	00h
	db	00h
	db	24h
	db	24h
	db	3ch
	db	24h
	db	3ch
	db	24h
	db	38h
	db	00h
	db	00h
	db	00h
	db	24h
	db	24h
	db	36h
	db	36h
	db	34h
	db	24h
	db	20h
	db	00h
	db	00h
	db	00h
	db	40h
	db	41h
	db	09h
	db	09h
	db	08h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	16h
	db	24h
	db	00h
	db	00h
	db	2dh
	db	3ah
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	02h
	db	34h
	db	20h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	04h
	db	20h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	40h
	db	12h
	db	12h
	db	13h
	db	1ah
	db	12h
	db	12h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	1fh
	db	3fh
	db	3fh
	db	3bh
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	0bh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	19h
	db	00h
	db	00h
	db	00h
	db	04h
	db	24h
	db	24h
	db	26h
	db	34h
	db	24h
	db	24h
	db	20h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	09h
	db	09h
	db	09h
	db	00h
	db	00h
	db	00h
	db	1bh
	db	1fh
	db	24h
	db	3fh
	db	3fh
	db	3fh
	db	30h
	db	00h
	db	00h
	db	0fh
	db	3fh
	db	3fh
	db	12h
	db	12h
	db	16h
	db	24h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	40h
	db	00h
	db	00h
	db	00h
	db	00h
	db	03h
	db	10h
	db	00h
	db	00h
	db	00h
	db	1fh
	db	3fh
	db	3fh
	db	3bh
	db	01h
	db	1eh
	db	00h
	db	00h
	db	09h
	db	1bh
	db	1fh
	db	2dh
	db	37h
	db	1fh
	db	3fh
	db	19h
	db	08h
	db	00h
	db	26h
	db	36h
	db	36h
	db	20h
	db	04h
	db	36h
	db	36h
	db	34h
	db	20h
	db	00h
	db	40h
	db	49h
	db	12h
	db	1bh
	db	19h
	db	09h
	db	08h
	db	00h
	db	00h
	db	01h
	db	34h
	db	0ch
	db	10h
	db	04h
	db	3bh
	db	2dh
	db	2eh
	db	3bh
	db	08h
	db	06h
	db	08h
	db	02h
	db	05h
	db	01h
	db	3ch
	db	2dh
	db	1bh
	db	1eh
	db	20h
	db	00h
	db	04h
	db	22h
	db	12h
	db	36h
	db	34h
	db	24h
	db	20h
	db	00h
	db	00h

bellx:

	db	00h
	db	40h
	db	12h
	db	12h
	db	13h
	db	1ah
	db	12h
	db	12h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	1fh
	db	3fh
	db	3fh
	db	3bh
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	0bh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	19h
	db	00h
	db	00h
	db	00h
	db	04h
	db	24h
	db	24h
	db	26h
	db	34h
	db	24h
	db	24h
	db	20h
	db	00h
	db	00h
	db	40h
	db	00h
	db	42h
	db	1ah
	db	02h
	db	1ah
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	3ch
	db	24h
	db	3ch
	db	24h
	db	3ch
	db	24h
	db	20h
	db	00h
	db	00h
	db	00h
	db	24h
	db	24h
	db	3ch
	db	24h
	db	3ch
	db	24h
	db	28h
	db	00h
	db	00h
	db	00h
	db	24h
	db	24h
	db	36h
	db	36h
	db	34h
	db	24h
	db	20h
	db	00h
	db	00h
	db	00h
	db	40h
	db	40h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	01h
	db	0bh
	db	1bh
	db	3fh
	db	3fh
	db	3bh
	db	18h
	db	00h
	db	00h
	db	02h
	db	3eh
	db	3fh
	db	3fh
	db	3eh
	db	34h
	db	20h
	db	00h
	db	00h
	db	02h
	db	34h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	01h
	db	09h
	db	09h
	db	08h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	16h
	db	24h
	db	00h
	db	00h
	db	2dh
	db	3ah
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	02h
	db	34h
	db	20h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	04h
	db	20h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	40h
	db	01h
	db	09h
	db	09h
	db	09h
	db	08h
	db	00h
	db	00h
	db	00h
	db	0bh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	3bh
	db	00h
	db	00h
	db	37h
	db	3fh
	db	3dh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	34h
	db	00h
	db	00h
	db	00h
	db	24h
	db	24h
	db	24h
	db	24h
	db	20h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	40h
	db	00h
	db	00h
	db	00h
	db	00h
	db	03h
	db	10h
	db	00h
	db	00h
	db	00h
	db	1fh
	db	3fh
	db	3fh
	db	3bh
	db	01h
	db	1eh
	db	00h
	db	00h
	db	09h
	db	1bh
	db	1fh
	db	2dh
	db	37h
	db	1fh
	db	3fh
	db	19h
	db	08h
	db	00h
	db	26h
	db	36h
	db	36h
	db	20h
	db	04h
	db	36h
	db	36h
	db	34h
	db	20h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	09h
	db	09h
	db	09h
	db	00h
	db	00h
	db	00h
	db	1bh
	db	1fh
	db	24h
	db	3fh
	db	3fh
	db	3fh
	db	30h
	db	00h
	db	00h
	db	0fh
	db	3fh
	db	3fh
	db	12h
	db	12h
	db	16h
	db	24h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h

bell1x:

	db	00h
	db	40h
	db	12h
	db	12h
	db	13h
	db	1ah
	db	12h
	db	12h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	1fh
	db	3fh
	db	3fh
	db	3bh
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	0bh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	19h
	db	00h
	db	00h
	db	00h
	db	04h
	db	24h
	db	24h
	db	26h
	db	34h
	db	24h
	db	24h
	db	20h
	db	00h
	db	01h
	db	49h
	db	49h
	db	49h
	db	09h
	db	09h
	db	09h
	db	09h
	db	09h
	db	08h
	db	07h
	db	02h
	db	11h
	db	38h
	db	1bh
	db	18h
	db	38h
	db	12h
	db	07h
	db	38h
	db	07h
	db	06h
	db	30h
	db	38h
	db	1bh
	db	18h
	db	38h
	db	3bh
	db	2eh
	db	38h
	db	04h
	db	24h
	db	24h
	db	24h
	db	24h
	db	24h
	db	24h
	db	24h
	db	24h
	db	20h
	db	00h
	db	00h
	db	40h
	db	01h
	db	09h
	db	09h
	db	09h
	db	08h
	db	00h
	db	00h
	db	00h
	db	0bh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	3bh
	db	00h
	db	00h
	db	37h
	db	3fh
	db	3dh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	34h
	db	00h
	db	00h
	db	00h
	db	24h
	db	24h
	db	24h
	db	24h
	db	20h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	40h
	db	40h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	01h
	db	0bh
	db	1bh
	db	3fh
	db	3fh
	db	3bh
	db	18h
	db	00h
	db	00h
	db	02h
	db	3eh
	db	3fh
	db	3fh
	db	3eh
	db	34h
	db	20h
	db	00h
	db	00h
	db	02h
	db	34h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	09h
	db	09h
	db	09h
	db	00h
	db	00h
	db	00h
	db	1bh
	db	1fh
	db	24h
	db	3fh
	db	3fh
	db	3fh
	db	30h
	db	00h
	db	00h
	db	0fh
	db	3fh
	db	3fh
	db	12h
	db	12h
	db	16h
	db	24h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	40h
	db	01h
	db	09h
	db	09h
	db	08h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	16h
	db	24h
	db	00h
	db	00h
	db	2dh
	db	3ah
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	02h
	db	34h
	db	20h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	04h
	db	20h
	db	00h
	db	00h
	db	00h
	db	00h

cherryy:

	db	40h
	db	00h
	db	00h
	db	40h
	db	00h
	db	00h
	db	00h
	db	00h
	db	03h
	db	10h
	db	00h
	db	00h
	db	00h
	db	1fh
	db	3fh
	db	3fh
	db	3bh
	db	01h
	db	1eh
	db	00h
	db	00h
	db	09h
	db	1bh
	db	1fh
	db	2dh
	db	37h
	db	1fh
	db	3fh
	db	19h
	db	08h
	db	00h
	db	26h
	db	36h
	db	36h
	db	20h
	db	04h
	db	36h
	db	36h
	db	34h
	db	20h
	db	00h
	db	40h
	db	49h
	db	12h
	db	1bh
	db	19h
	db	09h
	db	08h
	db	00h
	db	00h
	db	01h
	db	34h
	db	0ch
	db	10h
	db	04h
	db	3bh
	db	2dh
	db	2eh
	db	3bh
	db	08h
	db	06h
	db	08h
	db	02h
	db	05h
	db	01h
	db	3ch
	db	2dh
	db	1bh
	db	1eh
	db	20h
	db	00h
	db	04h
	db	22h
	db	12h
	db	36h
	db	34h
	db	24h
	db	20h
	db	00h
	db	00h
	db	00h
	db	40h
	db	12h
	db	12h
	db	13h
	db	1ah
	db	12h
	db	12h
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	1fh
	db	3fh
	db	3fh
	db	3bh
	db	00h
	db	00h
	db	00h
	db	00h
	db	00h
	db	0bh
	db	3fh
	db	3fh
	db	3fh
	db	3fh
	db	19h
	db	00h
	db	00h
	db	00h
	db	04h
	db	24h
	db	24h
	db	26h
	db	34h
	db	24h
	db	24h
	db	20h
	db	00h

final	equ	$
stkptr	equ	final+20*2
trials	equ	stkptr
spincnt	equ	stkptr
reel1s	equ	stkptr+1
reel2s	equ	stkptr+2
reel3s	equ	stkptr+3
reel1p	equ	stkptr+4
reel2p	equ	stkptr+6
reel3p	equ	stkptr+8
value	equ	stkptr+10
credtv	equ	stkptr+12
random	equ	stkptr+14
jackpot	equ	stkptr+16
recipt	equ	stkptr+18

	end

