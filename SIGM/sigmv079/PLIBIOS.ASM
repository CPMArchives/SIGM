
	name	'PLIBIOS'
	title	'Direct BIOS Calls From PL/I-80'
;
;***********************************************************
;*                                                         *
;*	bios calls from pl/i for track, sector io          *
;*                                                         *
;***********************************************************
	public  seldsk	;select disk drive
	public	settrk	;set track number
	public	setsec	;set sector number
	public	rdsec	;read sector
	public	wrsec	;write sector
	public  sectrn	;translate sector number
;
;
	extrn	?boot	;system reboot entry point
	extrn	?bdos	;bdos entry point
;
;***********************************************************
;*                                                         *
;*        equates for interface to cp/m bios               *
;*                                                         *
;***********************************************************
cr	equ	0dh	;carriage return
lf	equ	0ah	;line feed
eof	equ	1ah	;end of file
;
base	equ	0
wboot	equ	base+1h	;warm boot entry point stored here
sdsk	equ	18h	;bios select disk entry point
strk	equ	1bh	;bios set track entry point
ssec	equ	1eh	;bios set sector entry point
read	equ	24h	;bios read sector entry point
write	equ	27h	;bios write sector entry point
stran	equ	2dh	;bios sector translation entry point
readc	equ	1	;read character from console
writc	equ	2	;write console character
rdrf	equ	3	;reader input
punf	equ	4	;punch output
listf	equ	5	;list output function
diof	equ	6	;direct i/o, version 2.0
getiof	equ	7	;get i/o byte
setiof	equ	8	;set i/o byte
printf	equ	9	;print string function
rdconf	equ	10	;read console buffer
statf	equ	11	;return console status
versf	equ	12	;get version number
resetf	equ	13	;system reset
seldf	equ	14	;select disk function
openf	equ	15	;open file function
closef	equ	16	;close file
serchf	equ	17	;search for file
serchn	equ	18	;search next
deletf	equ	19	;delete file
readf	equ	20	;read next record
writf	equ	21	;write next record
makef	equ	22	;make file
renamf	equ	23	;rename file
loginf	equ	24	;get login vector
cdiskf	equ	25	;get current disk number
setdmf	equ	26	;set dma function
getalf	equ	27	;get allocation base
wrprof	equ	28	;write protect disk
getrof	equ	29	;get r/o vector
setatf	equ	30	;set file attributes
getdpf	equ	31	;get disk parameter block
userf	equ	32	;set/get user code
rdranf	equ	33	;read random
wrranf	equ	34	;write random
filszf	equ	35	;compute file size
setrcf	equ	36	;set random record position
rsdrvf	equ	37	;reset drive function
wrrnzf	equ	40	;write random zero fill
;
;	utility functions
;
;***********************************************************
;***********************************************************
;*                                                         *
;*       general purpose routines used upon entry          *
;*                                                         *
;***********************************************************
;
;
getp:	;get parameter
	mov	e,m	;low (addr)
	inx	h
	mov	d,m	;high (addr)
	inx	h
	push	h	;save for next parameter
	xchg		;hl = .char
	mov	e,m	;to register e
	inx	h
	mov	d,m	;get high byte as well
	pop	h	;ready for next parameter
	ret
;
;
;***********************************************************
;*                                                         *
;***********************************************************
seldsk:	;select drive number 0-15, in C
	;1-> drive no.
	;returns-> pointer to translate table in HL
	call getp
	mov c,e		;c = drive no.
	lxi d,sdsk
	jmp gobios
;
;***********************************************************
;*                                                         *
;***********************************************************
settrk:	;set track number 0-76, 0-65535 in BC
	;1-> track no.
	call getp
	mov b,d
	mov c,e		;bc = track no.
	lxi d,strk
	jmp gobios
;
;***********************************************************
;*                                                         *
;***********************************************************
setsec:	;set sector number 1 - sectors per track
	;1-> sector no.
	call getp
	mov b,d
	mov c,e		;bc = sector no.
	lxi d,ssec
	jmp gobios
;
;***********************************************************
;*                                                         *
;***********************************************************
rdsec:	;read current sector into sector at dma addr
	;returns in A register:	0 if no errors 
	;			1 non-recoverable error
	lxi d,read
	jmp gobios
;***********************************************************
;*                                                         *
;***********************************************************
wrsec:	;writes contents of sector at dma addr to current sector
	;returns in A register:	0 errors occured
	;			1 non-recoverable error
	lxi d,write
	jmp gobios
;
;***********************************************************
;*                                                         *
;***********************************************************
sectrn:	;translate sector number
	;1-> logical sector number (fixed(15))
	;2-> pointer to translate table
	;returns-> physical sector number
	call getp	;first parameter
	mov b,d	
	mov c,e		;bc = logical sector no.
	call getp	;second parameter
	push d		;save it
	lxi d,stran
	lhld wboot
	dad d		;hl = sectran entry point
	pop d		;de = .translate-table 
	pchl
;***********************************************************
;***********************************************************
;***********************************************************
;*                                                         *
;*       compute offset from warm boot and jump to bios    *
;*                                                         *
;***********************************************************
;
;
gobios:	;jump to bios entry point
	;de ->  offset from warm boot entry point
	lhld	wboot
	dad	d
	pchl
;
	end

