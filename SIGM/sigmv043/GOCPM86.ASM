	title	'gocpm86 - Transfer control to cp/m-86'
;
; Processor: CompuPro 8085/8088 dual processor
; Author: Bruce R. Ratoff
; Modified: 05/02/81
;
; Note:  This routine is to be merged with a copy of CPM86.SYS
;	 which has been moved up to its execution address of 0400H.
;	 It sets the reset vector in high memory and then swaps
;	 processors.
;
vector	equ	0fff0h		; 8088 reset vector address
voffset	equ	2500h		; cp/m-86 bios offset
vsegmnt	equ	0040h		; segment 40=address 00400=base of cp/m-86
jumpf	equ	0eah		; 8086 long jump opcode
cpuport	equ	0fdh		; cpu control port (in cpuport swaps cpu's)
;
	org	0100h
gocpm86:
	mvi	a,jumpf		; store intra-segment jump opcode
	sta	vector
	lxi	h,voffset	; store offset address
	shld	vector+1
	lxi	h,vsegmnt	; store segment address
	shld	vector+3
	in	cpuport		; this should turn on 8088
	jmp	0		; just in case it fails
;
	ds	37fh-$		; fill up to start of CPM.SYS
	db	0		; so we can get right setup from PIP
;
	end	gocpm86
