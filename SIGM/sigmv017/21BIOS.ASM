	TITLE	'CP/M BASIC INPUT/OUTPUT ROUTINES'
; CP/M BASIC INPUT/OUTPUT OPERATING SYSTEM (BIOS)
; TARBELL ELECTRONICS
; 2.1 VERSION OF 1-9-80
; CHANGE SIGN-ON DATE FOR CP/M 2.1
;
; UPDATED BY:
; ROBERT M. WHITE
; H & W COMPUTER SYSTEMS, INC.
; 8530 STONEHAVEN
; BOISE, ID  83704
;
;
; THIS MODULE CONTAINS ALL THE INPUT/OUTPUT
; ROUTINES FOR THE CP/M SYSTEM, INCLUDING
; THE DISK ROUTINES.  It has been designed
; to provide a full implementation for a
; Tarbell controller and console configura-
; tion.  The disk drivers fully support
; various sector sizes and densities as
; documented later.  The I/O drivers fully
; support the IOBYTE as defined in the
; CP/M Alteration Manual.  Note this is an
; oversized BIOS and requires that the CCP
; be defined as a file on the default drive.
; Thus only the BDOS and BIOS are on the
; system tracks allowing a BIOS of 2.75k
; when both tracks are single density.
; Currently, a total of 4k is being allocated
; to the BIOS.  Therefore, the max CP/M
; memory size is 61k.  To calculate this,
; do as follows:
;	Max memory size+1 (64k) =10000H
;	10000H-1000H = F000H (Bios Base)
;	F000H-1600H = DA00H (CP/M Base)
;	DA00H-3400H = A600H (CBASE)
;	A600H/400H = 41
;	41+20 = 61 (Max CP/M Size)
;
; To SYSGEN, do the following:
;	1. Assemble this BIOS using MAC and
;	   creating the file, 21BIOS.HEX.
;	2. Assemble the special Boot creating
;	   the file, 21BOOT.HEX.
;	3. Create a CCP file on the
;	   new default disk as follows:
;		DDT CPMxx.COM
;		-M980,1180,100
;		-^C
;		SAVE 8 CCP.COM
;	4. Put BDOS, BOOT & BIOS on the
;	   new default disk as follows:
;		DDT CPMxx.COM
;		-M1180,1F80,980
;		-I21BOOT.HEX
;		-R900
;		-I21BIOS.HEX
;		-H1780,nnnn
;		 xxxx yyyy       (Returned by DDT)
;		-Ryyyy
;		-^C
;		SYSGEN
;			(Answer as normal).
;
; Note -- A handy way of debugging this BIOS is
; to have an operating CP/M which is 16k larger.
; Boot this bios.  To capture data areas, simply
; re-boot the other and look at them with DDT.
; This technique was used extensively to get this
; BIOS operational.
;
;
; THIS SECTION DEFINES THE I/O PORTS AND
; STATUS BITS.  BY SETTING THE PROPER VALUES
; FOR THE EQU STATEMENTS, THE I/O MAY BE
; AUTOMATICALLY RECONFIGURED TO FIT MOST
; SITUATIONS.  THE TRUE AND FALSE ONES
; CONTROL CONDITIONAL ASSEMBLIES OF DIFFERENT
; SECTIONS OF I/O ROUTINES TO FIT DIFFERENT
; INTERFACE REQUIREMENTS.

	MACLIB	SPCLMAC

TRUE	EQU  0FFFFH	;DEFINE VALUE OF TRUE.
FALSE	EQU  NOT TRUE	;DEFINE VALUE OF FALSE.
BC	EQU  B		;DOUBLE REGISTER EQUATES
DE	EQU  D
HL	EQU  H

;***************************************************
;*** THIS BEGINS THE AREA WHICH REQUIRES CHANGES ***
;***      FOR DIFFERENT CONSOLE I/O SYSTEMS      ***
;***************************************************

MSIZE	EQU  61		;MEMORY SIZE IN KBYTES.
INTRP	EQU  FALSE	;TRUE IF INTERRUPTS ALLOWED.
DFTDSK	EQU  0		;DEFAULT DISK ON BOOT (0-3)
DFTUSR	EQU  0		;DEFAULT USER ON BOOT (0-15)

OLDTARB EQU  FALSE	;TRUE IF OLD TARBELL CONTROLLER (1771)
TARBELL EQU  TRUE	;TRUE IF NEW TARBELL CONTROLLER (1791)

DEBUG	EQU  FALSE	;TRUE FOR SPECIAL DEBUGGING MESSAGES
SPOOL	EQU  FALSE	;TRUE IF USING KLH SPOOLER.
NDISK	EQU  3		;DEFINES THE NUMBER DRIVES IN SYSTEM.

CSTAT	EQU  16		;CONSOLE STATUS PORT.
CCOM	EQU  16		;CONSOLE COMMAND PORT.
CDATA	EQU  17		;CONSOLE DATA PORT.
CONUL	EQU  FALSE	;CONSOLE NULLS?
CNULL	EQU  0		;CONSOLE NULL COUNT.

LSTAT	EQU  18		;LIST STATUS PORT.
LCOM	EQU  18		;LIST COMMAND PORT.
LDATA	EQU  19		;LIST DATA PORT.
LSTNUL	EQU  FALSE	;LIST DEVICE NULLS?
LNULL	EQU  0		;LIST NULL COUNT.
LSTPAG	EQU  FALSE	;LIST DEVICE PAGING?
LINCNT	EQU  66		;LINES PER PAGE.

STPRAT	EQU  2		;RATE 1=6MS, 2=10MS, 3=20MS.
DUAL	EQU  FALSE	;TRUE IF DUAL DRIVE.
PERSCI	EQU  FALSE	;TRUE IF FAST SEEK (PERSCI).

;*******************************************************
;*** THIS IS THE END OF THE AREA WHICH NORMALLY NEED ***
;***     BE CHANGED FOR MOST CONSOLE I/O SYSTEMS     ***
;*******************************************************

DISK	EQU  0F8H	;DISK BASE ADDRESS.
DCOM	EQU  DISK	;DISK COMMAND PORT.
DSTAT	EQU  DISK	;DISK STATUS PORT.
TRACK	EQU  DISK+1	;DISK TRACK PORT.
SECTP	EQU  DISK+2	;DISK SECTOR PORT.
DDATA	EQU  DISK+3	;DISK DATA PORT.
WAIT	EQU  DISK+4	;DISK WAIT PORT.
DCONT	EQU  DISK+4	;DISK CONTROL PORT.
	IF	TARBELL
DMACHK	EQU  DISK+5	;DMA CHECK PORT.
	ENDIF

RTCNT	EQU  10		;RETRY COUNT.

CKBR	EQU  00000001B	;KEYBOARD READY BIT.
CPTR	EQU  00000010B	;PRINT READY BIT.
LKBR	EQU  00000001B	;LISTER READY BIT.
LPTR	EQU  00000010B	;LISTER READY BIT.


IOBYTE	EQU  3			;ADDRESS OF I/O BYTE.
CBASE	EQU  (MSIZE-20)*1024  	;BIAS FOR LARGER THAN 20K.
CPMB	EQU  CBASE+3400H	;START OF CPM 2.0
BDOS	EQU  CPMB+806H		;START OF BDOS 2.0.
BIOS	EQU  CPMB+1600H		;START OF CBIOS IO.
CDISK	EQU  4			;LOCATION 4 IS CURRENT DISK.
NSECTS	EQU  44			;NUMBER OF SECTORS IN IT.

	ORG  BIOS		;START OF CBIOS STRUCTURE.
;
; I/O JUMP VECTOR
; THIS IS WHERE CPM CALLS WHENEVER IT NEEDS
; TO DO ANY INPUT/OUTPUT OPERATION.
; USER PROGRAMS MAY USE THESE ENTRY POINTS
; ALSO, BUT NOTE THAT THE LOCATION OF THIS
; VECTOR CHANGES WITH THE MEMORY SIZE.
;
	JMP  BOOT		;FROM COLD START LOADER.
WBOOTE:	JMP  WBOOT		;FROM WARM BOOT.
	JMP  CONST		;CHECK CONSOLE KB STATUS.
	JMP  CONIN		;READ CONSOLE CHARACTER.
	JMP  CONOUT		;WRITE CONSOLE CHARACTER.
	JMP  LSTOUT		;WRITE LISTING CHAR.
	JMP  PUNOUT		;WRITE PUNCH CHAR.
	JMP  RDRIN		;READ READER CHAR.
	JMP  HOME		;MOVE DISK TO TRACK ZERO.
	JMP  SELDSK		;SELECT DISK DRIVE.
	JMP  SETTRK		;SEEK TO TRACK IN REG A.
	JMP  SETSEC		;SET SECTOR NUMBER.
	JMP  SETDMA		;SET DISK STARTING ADR.
	JMP  READ		;READ SELECTED SECTOR.
	JMP  WRITE		;WRITE SELECTED SECTOR.
	JMP  LSTST		;LIST STATUS CHECK.
	JMP  SECTRAN		;SECTOR TRANSLATE ROUTINE.

	; THESE ENTRY POINTS ADDED BY TARBELL ELECTRONICS.

	IF  SPOOL		;IF USING KLH SPOOLER.
	DB   0FFH		;FLAG FOR SPOOLER.
	DW   LTBSY		;LISTER STATUS LOCATION
	DW   LTBSY		;FOR SPOOLER - -
	DW   LTBSY		;I DON'T KNOW WHY IT'S
	DW   LTBSY		;HERE 4 TIMES EITHER.
	ENDIF

;		SPECIAL ENTRY POINTS FOR DIRECT DISK I/O
	JMP  Pselct		;Select the drive in (C).
	JMP  Phome		;Home current drive.
	JMP  Pseek		;Seek track in (C).
	JMP  Pread		;Read a sector in (C), dma in (HL)
	JMP  Pwrite		;Write a sector in (C), dma in (HL)



;*****************************************************
;*                                                   *
;*      Sector Deblocking Algorithms for CP/M 2.0    *
;*                                                   *
;*****************************************************
;
;	This section of programming provides the disk
;drivers for the BIOS.  They are designed to handle
;many combinations of disk formats and sector sizes.
;Currently, the definitions of these combinations are
;defined as in DFOCO distributed by S. J. Singer via
;the CP/M User's Group.  For further information, see
;the documentation for that fine program.
;	The actual routines are divided into two sec-
;tions.  The first performs logical blocking and de-
;blocking of the host physical sectors.  The second
;section contains the actual physical routines to per-
;form the I/O functions necessary for proper operation
;of the disk drives.  Currently, these routines assume
;a Tarbell Single or Double Density Controller.  The
;original logical routines were supplied by Digital
;Research as a part of CP/M 2.0.
;
;*****************************************************
;*                                                   *
;*         CP/M to host disk constants               *
;*                                                   *
;*****************************************************
hstmax	equ	1024		;host max disk sector size
;
;*****************************************************
;*                                                   *
;*        BDOS constants on entry to write           *
;*                                                   *
;*****************************************************
wrall	equ	0		;write to allocated
wrdir	equ	1		;write to directory
wrual	equ	2		;write to unallocated



;/////////////////////////////////////////////////////
;/	   Logical Disk I/O Driver Routines	     /
;/////////////////////////////////////////////////////


;*****************************************************
;*                                                   *
;*	The BDOS entry points given below show the   *
;*      code which is relevant to deblocking only.   *
;*                                                   *
;*****************************************************
;
;	DISKDEF macro, or hand coded tables go here
;
;		* * *  Disk Parameter Header  * * *
;	In general, each disk has an associated Disk
;Parameter Header which both contains information about
;the disk drive and provides a scratchpad area for 
;certain BDOS operations.
;
dphbase	equ	$		;disk param block header
DPE0	equ	$		;** Disk A **
	dw	00000H,00000H	;XLT adr, Scratch
	dw	00000H,00000H	;Scratch, Scratch
	dw	dirbuf,00000H	;Dir Buf adr, DPB adr
	dw	CSV0,ALV0	;CSV adr, ALV adr
DPE1	equ	$		;** Disk B **
	dw	00000H,00000H	;XLT adr, Scratch
	dw	00000H,00000H	;Scratch, Scratch
	dw	dirbuf,00000H	;Dir Buf adr, DPB adr
	dw	CSV1,ALV1	;CSV adr, ALV adr
DPE2	equ	$		;** Disk C **
	dw	00000H,00000H	;XLT adr, Scratch
	dw	00000H,00000H	;Scratch, Scratch
	dw	dirbuf,00000H	;Dir Buf adr, DPB adr
	dw	CSV2,ALV2	;CSV adr, ALV adr
DPE3	equ	$		;** Disk D **
	dw	00000H,00000H	;XLT adr, Scratch
	dw	00000H,00000H	;Scratch, Scratch
	dw	dirbuf,00000H	;Dir Buf adr, DPB adr
	dw	CSV3,ALV3	;CSV adr, ALV adr
;
;		* * *  Disk Parameter Block  * * *
;	In general, each DPH, Disk Parameter Header, 
;points to a particular DPB, Disk Parameter Block.
;The DPB contains information directly relating to
;the organition of data on the disk and its hardware
;characteristics.
;
;		* *  DPB Field Displacements  * *
dpbspt	equ	0	;host CP/M sectors/track
dpbbsh	equ	2	;block shift factor
dpbblm	equ	3	;block shift mask
dpbexm	equ	4	;extent mask
dpbdsm	equ	5	;max block rcd #
dpbdrm	equ	7	;max dir mask
dpbal0	equ	9	;dir allocation vector
dpbal1	equ	10	;dir allocation vector
dpbcks	equ	11	;dir check value
dpboff	equ	13	;rsvd tracks offset
dpbdfc	equ	15	;disk format code
dpbssc	equ	16	;host sector size
dpbhbm	equ	18	;host sector mask
dpbhbs	equ	19	;host sector shift value
dpbxlt	equ	20	;xlt ptr
dpblen	equ	22	;DPB length
;
dpbbase	equ	$	;Base of Disk Parameter Blocks
dpbs00	equ	$	;** Single Density, 128 byte Sectors **
	DPB	020H,128,26,1024,243,64,64,2,xlts00
dpbs01	equ	$	;** Single Density, 256 byte Sectors **
	DPB	021H,256,16,2048,150,64,64,2,0
dpbs02	equ	$	;** Single Density, 512 byte Sectors **
	DPB	022H,512,8,2048,150,64,64,2,0
dpbs03	equ	$	;** Single Density, 1024 byte Sectors **
	DPB	023H,1024,4,2048,150,64,64,2,0
dpbd00	equ	$	;** Double Density, 128 byte Sectors **
	DPB	010H,128,51,2048,239,128,128,2,xltd00
dpbd01	equ	$	;** Double Density, 256 byte Sectors **
	DPB	011H,256,26,2048,243,128,128,2,0
dpbd02	equ	$	;** Double Density, 512 byte Sectors **
	DPB	012H,512,16,2048,300,128,128,2,0
dpbd03	equ	$	;** Double Density, 1024 byte Sectors **
	DPB	013H,1024,8,2048,300,128,128,2,0
dpbnum	equ	($-dpbbase)/dpblen	;# of entries in table


;		* * *  Sector Translation Table  * * *
;	This section contains the STT, Sector Translation
;Table, for particular disk configurations (I.E.  DPB's).
;The table gives a logical to physical mapping of sector
;numbers.  Thereby, allowing different mappings for per-
;formance betterment.  Note that all entries must be rela-
;tive to zero, not one.
xltbase	equ	$	;Base of Sector Translation Tables
xlts00	equ	$	;** Single density, 128 byte sectors,
;			;   26 Sec/Trk, Skew 6 **
	db	0,6,12,18,24
	db	4,10,16,22,2
	db	8,14,20,1,7
	db	13,19,25,5,11
	db	17,23,3,9,15,21
xltd00	equ	$	;** Double density, 128 byte sectors,
;			;   51 Sec/Trk, Skew 18 **
	db	0,17,34,9,26,43,1,18,35,10,27
	db	44,2,19,36,11,28,45,3,20,37,12
	db	29,46,4,21,38,13,30,47,5,22,39
	db	14,31,48,6,23,40,15,32,49,7,24
	db	41,16,33,50,8,25,42
;
;
;*****************************************************
;*                                                   *
;*	BOOT - Cold Boot Routine.		     *
;*		Executed whenever Reset is pressed.  *
;*                                                   *
;*****************************************************

BOOT:
;		Do initialization.
	lxi	sp,080H	;set stack ptr.
	if	INTRP
	ei		;enable interrupts.
	endif

;		Initialize Mits 2SIO.
	mvi	a,3	;Issue reset.
	out	ccom
	out	lcom
	mvi	a,015H	;Set up Ports.
	out	ccom
	out	lcom
	in	cdata	;clear console port.

;		Save last six bytes of CCP.
	lxi	h,BDOS-6
	lxi	d,ccpsav
	mvi	c,6
	mov	a,m
	stax	d
	inx	h
	inx	d
	dcr	c
	jnz	$-5

;		Zero defined Scratch area.
	lxi	b,ENDZ-STARTZ
	lxi	h,STARTZ
	mvi	m,0
	inx	h
	dcx	b
	mov	a,b
	ora	c
	jnz	$-6

;		Set Low memory areas excluding jumps.
	mvi	a,095H	;IOBYTE := CON=CRT, LST=LPT, PUN=PTP,
	sta	IOBYTE	;	   RDR=PTR
	mvi	a,0	;Default disk = A:
	sta	CDISK

;		Issue opening message.
	lxi	h,smsg
	call	Pmsg

;		Finish by warm booting.
	jmp	WBOOT


;*****************************************************
;*                                                   *
;*	WBOOT - Warm Boot Routine.		     *
;*                                                   *
;*****************************************************

WBOOT:
;		Do initialization.
	lxi	sp,080H	;set stack ptr.
	if	INTRP
	di		;disable interrupts.
	endif

;		Set up jumps for CP/M in low memory.
	mvi	a,0C3H	;put (JMP) for WBOOT.
	sta	0
	lxi	h,WBOOTE
	shld	1
	sta	5	;put (JMP) for BDOS.
	lxi	h,BDOS
	shld	6

;		Issue loading CCP message.
	if	DEBUG
	lxi	h,lodccp
	call	pmsg
	endif

;		Zero Disk table.
	mvi	c,4*2
	lxi	h,dsktbl
	mvi	m,0
	inx	h
	dcr	c
	jnz	$-4

;		Reset Deblock fields.
	xra	a
	sta	hstact	;host buffer inactive
	sta	unacnt	;clear unalloc count.

;		Select and login default disk drive.
	mvi	c,DFTDSK	;do it.
	call	SELDSK

;		Set default user to zero for now.
	mvi	e,0
	mvi	c,020H
	call	BDOS

;		Reset disk system.
	mvi	c,00DH
	call	BDOS

;		Select default drive.
	mvi	e,DFTDSK
	mvi	c,00EH
	call	BDOS

;		Zero CCP's FCB.
	lxi	h,ccpfcb+12
	mvi	c,21
	mvi	m,0
	inx	h
	dcr	c
	jnz	$-4

;		Open CCP's FCB.
	lxi	d,ccpfcb
	mvi	c,00FH
	call	BDOS
	inr	a		;Error?
	jc	Bterr		;...yes.

;		Read in the CCP.
	mvi	c,16	;set # of sectors in CCP.
	lxi	d,128	;set sector size.
	lxi	h,CPMB	;set CCP base address.

	call	Ccpred	;Read a sector.
	dad	d	;bump ptr.
	dcr	c	;Decr count.
	jnz	$-5	;loop till done.

;		Restore CCP's last six bytes.
	lxi	h,ccpsav
	lxi	d,BDOS-6
	mvi	c,6
	mov	a,m
	stax	d
	inx	h
	inx	d
	dcr	c
	jnz	$-5

;		Issue CCP loaded Message.
	if	DEBUG
	lxi	h,ccplod
	call	Pmsg
	endif

;		Do misc initialization.
	lxi	h,080H	;set default buffer in dma.
	shld	dmaadr
	if	INTRP
	ei		;enable interrupts.
	endif

;		Set default drive and user and go to CCP.
	lda	CDISK	;get default drive.
	mov	c,a	;save it.
	mvi	a,DFTUSR ;get Default user (0-15).
	ral		;Put it in high hex digit.
	ral
	ral
	ral
	add	c	;add in default drive.
	mov	c,a	;set for CCP.
	jmp	CPMB	;go to CCP.


ccpfcb:	db	0,'CCP     ','COM',0,0,0,0
	db	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db	0

;		* *  Read a sector of CCP.  * *
Ccpred:
;		Do initialization.
	push	b	;save regs.
	push	d
	push	h

;		Set DMA for read.
	xchg
	mvi	c,01AH
	call	BDOS

;		Issue the read.
	lxi	d,ccpfcb
	mvi	c,014H
	call	BDOS
	ora	a	;Error?
	jnz	Bterr	;...yes.

;		Return to caller.
	pop	h	;restore regs.
	pop	d
	pop	b
	ret


;		* *  Handle boot errors  * *
Bterr:
;		Tell operator.
	lxi	h,btmsg	;Issue Boot error msg.
	call	Pmsg
	call	CONIN	;Wait.
	jmp	WBOOT	;Try warm boot again.


;*****************************************************
;*                                                   *
;*	SELDSK - Select a Disk.			     *
;*                                                   *
;*****************************************************

SELDSK:
;		Validate the disk #.
	lxi	h,0		;set for error.
	mov	a,c		;get the disk #.
	cpi	NDISK		;Undefined drive?
	rnc			;...yes, return w/error.
	mov	a,c		;selected disk number
	sta	sekdsk		;seek disk number

;		Get ptr to disk's DPH.
	mov	l,a		;disk number to HL
	mvi	h,0
	rept	4		;multiply by 16
	dad	h
	endm
	lxi	d,dphbase	;base of parm block
	dad	d		;hl=.dph(curdsk)
	shld	sekdph		;save it.

;		Log the disk if not already logged.
	mov	a,c		;point to disk table entry.
	call	Dskadr
	mov	a,m		;get flag byte.
	ora	a		;Already logged?
	jm	$+6		;...yes.
	call	Logdsk		;...no, log it in.

;		now get address of dpb.
	lhld	sekdph		;hl = .dph(curdsk)
	lxi	d,10		;hl = .dphdpb(curdsk)
	dad	d
	mov	e,m		;hl = .dpb(curdsk)
	inx	h
	mov	d,m
	xchg
	shld	sekdpb		;save it.

;		return to caller.
	lhld	sekdph
	ret


;*****************************************************
;*                                                   *
;*	Logdsk - Login disk in (C).    		     *
;*                                                   *
;*****************************************************

Logdsk:
;		Get the format code from sector 1 track 0.
	call	Pselct	;Physically select the drive.
	call	Phome	;Home the head.
	mvi	c,0	;Seek track 0 setting density.
	call	Pseek
	mvi	c,1	;Read in first Sector.
	lxi	h,dirbuf
	call	Pread
	lda	dirbuf+07FH ;Get the format code.
	sta	dskdfc	;save it.

;		Log the disk's DPH.
	lhld	sekdph
	call	Logdph

;		Log it into the disk table.
	lda	sekdsk	;point to disk table entry.
	call	Dskadr
	lda	dskdfc	;get the density code.
	ani	010H
	rrc		;put it in low order byte.
	rrc
	rrc
	rrc
	ori	080H	;add in logged bit.
	mov	m,a	;put it in table flag byte.

;		return to caller.
	ret


;*****************************************************
;*                                                   *
;*	Logdph - Login disk parameter header.	     *
;*                                                   *
;*****************************************************

Logdph:
;		Get the right DPB.
	xchg		;de = .dph
	lda	dskdfc	;get format code for search.
	call	Srcdpb	;Search the DPB table.

;		Put the XLT address in the DPH.
	push	h	;save DPB ptr.
	rxdld	b,<>,dpbxlt ;Get XLT address.
	xchg		;put it in DPH.
	mov	m,c
	inx	h
	mov	m,b

;		Put DPB address in DPH.
	lxi	d,9	;point to dphdpb.
	dad	d
	pop	d	;get DPB address.
	mov	m,e	;put it in DPH.
	inx	h
	mov	m,d

;		return to caller.
	ret


;*****************************************************
;*                                                   *
;*	Srcdpb - Search DPB table on format code.    *
;*                                                   *
;*****************************************************

Srcdpb:
;		Do initialization.
	push	b	;save regs.
	push	d
	mov	b,a	;save format code.
	mvi	c,dpbnum ;set for # of entries.
	lxi	h,dpbbase ;point to DPB table.
	lxi	d,dpblen ;get entry length.

;		Scan the table taking default if not
;		found.
Srcdpl:
	push	h	;save current entry ptr.
	rxld	a,<>,dpbdfc ;get entry's format code.
	pop	h
	cmp	b	;Did we find it?
	jz	Srcdpf	;...yes, return w/it.
	dad	d	;bump ptr to next entry.
	dcr	c	;loop till no more entries.
	jnz	Srcdpl
	lxi	h,dpbs00 ;Default to SD/SS 128 byte.

;		Return to caller w/entry ptr.
Srcdpf:
	pop	d	;restore regs.
	pop	b
	ret


;*****************************************************
;*                                                   *
;*	HOME - Home a particular disk.		     *
;*                                                   *
;*****************************************************

HOME:
	;set track given by registers BC
	lxi	h,0
	shld	sektrk		;track to seek
	ret


;*****************************************************
;*                                                   *
;*	SETTRK - Set appropriate track.		     *
;*                                                   *
;*****************************************************

SETTRK:
	;set track given by registers BC
	mov	h,b
	mov	l,c
	shld	sektrk		;track to seek
	ret


;*****************************************************
;*                                                   *
;*	SETSEC - Set appropriate sector.	     *
;*                                                   *
;*****************************************************

SETSEC:
	;set sector given by register c 
	mov	a,c
	sta	seksec		;sector to seek
	ret


;*****************************************************
;*                                                   *
;*	SETDMA - Set Data Memory Address.	     *
;*                                                   *
;*****************************************************

SETDMA:
	;set dma address given by BC
	mov	h,b
	mov	l,c
	shld	dmaadr
	ret


;*****************************************************
;*                                                   *
;*	SECTRAN - Do Sector Translation.	     *
;*                                                   *
;*****************************************************

SECTRAN:
	;translate sector number BC
	mvi	h,0	;hl = physical sector
	mov	l,c
	mov	a,d	;if not using xlat tbl then
	ora	e	;   return.
	rz
	xchg		;hl = .xlt
	dad	b	;hl = .xlt(sector)
	mov	l,m	;hl = xlt'd sector
	mvi	h,0
	ret


;*****************************************************
;*                                                   *
;*	The READ entry point takes the place of      *
;*	the previous BIOS defintion for READ.        *
;*                                                   *
;*****************************************************
READ:
	;read the selected CP/M sector
	xra	a		;accum = 00
	sta	unacnt		;unacnt= 00
	mvi	a,1
	sta	readop		;read operation
	sta	rsflag		;must read data
	mvi	a,wrual
	sta	wrtype		;treat as unalloc
	jmp	rwoper		;to perform the read


;*****************************************************
;*                                                   *
;*	The WRITE entry point takes the place of     *
;*	the previous BIOS defintion for WRITE.       *
;*                                                   *
;*****************************************************
WRITE:
	;write the selected CP/M sector
	xra	a		;0 to accumulator
	sta	readop		;not a read operation
	mov	a,c		;write type in c
	sta	wrtype
	cpi	wrual		;write unallocated?
	jnz	chkuna		;check for unalloc
;
;	write to unallocated, set parameters
	rxld	a,sekdpb,dpbblm	;a = dpbblm(sekdsk) + 1
	inr	a
	sta	unacnt
	lda	sekdsk		;disk to seek
	sta	unadsk		;unadsk = sekdsk
	lhld	sektrk
	shld	unatrk		;unatrk = sectrk
	lda	seksec
	sta	unasec		;unasec = seksec
;
chkuna:
	;check for write to unallocated sector
	lda	unacnt		;any unalloc remain?
	ora	a
	jz	alloc		;skip if not
;
;	more unallocated records remain
	dcr	a		;unacnt = unacnt-1
	sta	unacnt
	lda	sekdsk		;same disk?
	lxi	h,unadsk
	cmp	m		;sekdsk = unadsk?
	jnz	alloc		;skip if not
;
;	disks are the same
	lxi	h,unatrk
	call	sektrkcmp	;sektrk = unatrk?
	jnz	alloc		;skip if not
;
;	tracks are the same
	lda	seksec		;same sector?
	lxi	h,unasec
	cmp	m		;seksec = unasec?
	jnz	alloc		;skip if not
;
;	match, move to next sector for future ref
	inr	m		;unasec = unasec+1
	mov	a,m		;end of track?
	push	h
	rxad	sekdpb,dpbspt
	cmp	m
	pop	h
	jc	noovf		;skip if no overflow
;
;	overflow to next track
	mvi	m,0		;unasec = 0
	lhld	unatrk
	inx	h
	shld	unatrk		;unatrk = unatrk+1
;
noovf:
	;match found, mark as unnecessary read
	xra	a		;0 to accumulator
	sta	rsflag		;rsflag = 0
	jmp	rwoper		;to perform the write
;
alloc:
	;not an unallocated record, requires pre-read
	xra	a		;0 to accum
	sta	unacnt		;unacnt = 0
	inr	a		;1 to accum
	sta	rsflag		;rsflag = 1


;*****************************************************
;*                                                   *
;*	Common code for READ and WRITE follows       *
;*                                                   *
;*****************************************************
rwoper:
;		convert sector to host sector # by
;		dividing it by the number of sectors
;		per host sector.
	xra	a		;zero to accum
	sta	erflag		;no errors (yet)
	lda	seksec		;compute host sector
	rxld	b,sekdpb,dpbhbs	;b = dpbhbs(sekdpb)
	dcr	b		;b = 0?
	inr	b
	jz	rwope1		;...yes, use as is.
	ora	a		;carry = 0
	rar			;shift right
	dcr	b		;decr shift count.
	jnz	$-3		;go shift it again.
rwope1:
	sta	sekhst		;host sector to seek
;
;	active host sector?
	lxi	h,hstact	;host active flag
	mov	a,m
	mvi	m,1		;always becomes 1
	ora	a		;was it already?
	jz	filhst		;fill host if not
;
;	host buffer active, same as seek buffer?
	lda	sekdsk
	lxi	h,hstdsk	;same disk?
	cmp	m		;sekdsk = hstdsk?
	jnz	nomatch
;
;	same disk, same track?
	lxi	h,hsttrk
	call	sektrkcmp	;sektrk = hsttrk?
	jnz	nomatch
;
;	same disk, same track, same buffer?
	lda	sekhst
	lxi	h,hstsec	;sekhst = hstsec?
	cmp	m
	jz	match		;skip if match
;
nomatch:
	;proper disk, but not correct sector
	lda	hstwrt		;host written?
	ora	a
	cnz	writehst	;clear host buff
;
filhst:
	;may have to fill the host buffer
	lda	sekdsk
	sta	hstdsk
	lhld	sektrk
	shld	hsttrk
	lda	sekhst
	sta	hstsec
	lhld	sekdph
	shld	hstdph
	lhld	sekdpb
	shld	hstdpb
	lda	rsflag		;need to read?
	ora	a
	cnz	readhst		;yes, if 1
	xra	a		;0 to accum
	sta	hstwrt		;no pending write
;
match:
	;copy data to or from buffer
	lda	seksec		;mask buffer number
	rxad	sekdpb,dpbhbm	;hl = .dpbhbm(sekdpb)
	ana	m		;least signif bits
	mov	l,a		;ready to shift
	mvi	h,0		;double count
	rept	7		;shift left 7
	dad	h
	endm
;	hl has relative host buffer address
	lxi	d,hstbuf
	dad	d		;hl = host address
	xchg			;now in DE
	lhld	dmaadr		;get/put CP/M data
	mvi	c,128		;length of move
	lda	readop		;which way?
	ora	a
	jnz	rwmove		;skip if read
;
;	write operation, mark and switch direction
	mvi	a,1
	sta	hstwrt		;hstwrt = 1
	xchg			;source/dest swap
;
rwmove:
	;C initially 128, DE is source, HL is dest
	ldax	d		;source character
	inx	d
	mov	m,a		;to dest
	inx	h
	dcr	c		;loop 128 times
	jnz	rwmove
;
;	data has been moved to/from host buffer
	lda	wrtype		;write type
	cpi	wrdir		;to directory?
	lda	erflag		;in case of errors
	rnz			;no further processing
;
;	clear host buffer for directory write
	ora	a		;errors?
	rnz			;skip if so
	xra	a		;0 to accum
	sta	hstwrt		;buffer written
	call	writehst
	lda	erflag
	ret


;*****************************************************
;*                                                   *
;*	Utility subroutine for 16-bit compare        *
;*                                                   *
;*****************************************************
sektrkcmp:
	;HL = .unatrk or .hsttrk, compare with sektrk
	xchg
	lxi	h,sektrk
	ldax	d		;low byte compare
	cmp	m		;same?
	rnz			;return if not
;	low bytes equal, test high 1s
	inx	d
	inx	h
	ldax	d
	cmp	m	;sets flags
	ret
;
;*****************************************************
;*                                                   *
;*	WRITEHST performs the physical write to      *
;*	the host disk, READHST reads the physical    *
;*	disk.					     *
;*                                                   *
;*****************************************************
writehst:
	;hstdsk = host disk #, hsttrk = host track #,
	;hstsec = host sect #. write "hstsiz" bytes
	;from hstbuf and return error flag in erflag.
	;return erflag non-zero if error

;		Select the drive.
	lxi	h,hstdsk	;c = disk #
	mov	c,m
	call	Pselct		;Select it.

;		Set the head on the proper track.
	lxi	h,hsttrk	;c = track #
	mov	c,m
	call	Pseek		;do it.
	sta	erflag		;save error code.
	rnz			;return if error.

;		Write the sector.
	lxi	h,hstsec	;c = sector #
	mov	c,m
	inr	c		;make it relative to one.
	lxi	h,hstbuf	;hl = .buffer
	call	Pwrite		;do it.
	sta	erflag		;save error code.
	ret


readhst:
	;hstdsk = host disk #, hsttrk = host track #,
	;hstsec = host sect #. read "hstsiz" bytes
	;into hstbuf and return error flag in erflag.

;		Select the drive.
	lda	hstdsk		;c = disk #
	mov	c,a
	call	Pselct		;Select it.

;		Set the head on the proper track.
	lxi	h,hsttrk	;c = track #
	mov	c,m
	call	Pseek		;do it.
	sta	erflag		;save error code.
	rnz			;return if error.

;		Read the sector.
	lxi	h,hstsec	;c = sector #
	mov	c,m
	inr	c		;make it relative to one.
	lxi	h,hstbuf	;hl = .buffer
	call	Pread		;do it.
	sta	erflag		;save error code.
	ret


;/////////////////////////////////////////////////////
;/                                                   /
;/	Physical Disk I/O Driver Routines	     /
;/                                                   /
;/////////////////////////////////////////////////////


;*****************************************************
;*                                                   *
;*	Pselct - Physical Device Select		     *
;*                                                   *
;*****************************************************

Pselct:
;		Trace activity.
	if	DEBUG
	push	h
	lxi	h,trcact
	mvi	m,1
	pop	h
	endif

;	Save current disk's Track #.
	lda	dskcur	;point to Disk table entry.
	call	Dskadr
	inx	h	;point to track save.
	in	TRACK	;get the track #.
	mov	m,a	;save it.

;		Get the new track #.
	mov	a,c	;get new disk #.
	sta	dskcur	;make it the current one.
	call	Dskadr	;point to disk table entry.
	inx	h	;point to track save.
	mov	a,m	;get track #.
	sta	dsktrk	;save it.
	out	TRACK	;put it in controller.

;		Set the new disk's latch.
	mov	a,c	;get the disk #.
	if	OLDTARB
	cma		;invert it.
	add	a	;Put bits 1&2 in 4&5.
	add	a
	add	a
	add	a
	ori	2	;make latch command.
	endif
	if	TARBELL
	add	a	;Put bits 1&2 in 4&5.
	add	a
	add	a
	add	a
	endif
	sta	dsklth	;save new latch.

;		Return to caller.
	ret


;*****************************************************
;*                                                   *
;*	Phome - Physical Device Home		     *
;*                                                   *
;*****************************************************

Phome:
;		Trace activity.
	if	DEBUG
	push	h
	lxi	h,trcact
	mvi	m,2
	pop	h
	endif

;		Select the drive in single density.
	lda	dsklth	;Get current latch.
	out	DCONT	;Issue it to controller.

;		Wait for device not to be busy.
	in	DSTAT	;get disk status.
	rrc		;check busy bit.
	jc	$-3	;...loop till not busy.

;		Issue Restore Command.
	mvi	a,002H	;Restore cmd - no hdld, no verify
	out	DCOM	;Issue it.
	in	WAIT	;Wait for completion.

;		Delay 200 msec.
	mvi	a,200
	call	delay

;		Check the status for track zero.
	in	DSTAT
	ani	4	;Track zero?
	jz	Phome	;...no, try again.

;		Reset track # in table.
	lda	dskcur	;point to table entry.
	call	Dskadr
	inx	h	;point to track #.
	mvi	m,0	;reset it.
	lxi	h,dsktrk ;reset current track #.
	mvi	m,0

;		Return to caller.
	ret


;*****************************************************
;*                                                   *
;*	Pseek - Physical Device Seek		     *
;*                                                   *
;*****************************************************

Pseek:
;		Trace activity.
	if	DEBUG
	push	h
	lxi	h,trcact
	mvi	m,3
	pop	h
	endif

;		Select the drive and density.
	mov	a,c	;get track #.
	sta	dsktrk	;save it.
	sta	dsktrs	;...again.
	ora	a	;Track zero?
	jz	Pseek1	;...yes, force single density.
	lda	dskcur	;point to disk table entry.
	call	Dskadr
	mov	a,m	;get flag byte.
	ani	1	;Double density?
	jz	$+5	;...no.
	mvi	a,8	;...yes, set it.
Pseek1: mov	b,a	;save density.
	lda	dsklth	;get current latch.
	ora	b	;add in density.
	out	DCONT	;put it to controller.

;		If we've changed drives since last seek,
;		force a seek to the same track to unload
;		the head.  Thus insuring that the head
;		load bit is properly set for this drive.
	lhld	dsklth	;get old and new latches.
	mov	a,l	;Are they the same?
	cmp	h
	lda	dsklth	;reset them no matter what.
	sta	dskolt
	jnz	Pseek2-2 ;...no, insure seek to same track.

;		Check to see if current track is desired one.
	in	TRACK	;get current track.
	cmp	c	;Are they the same?
	rz		;...yes, return.

;		Issue the Seek command.
	mvi	b,RTCNT	;set retry count.
Pseek2: lda	dsktrk	;get the desired track #.
	out	DDATA	;tell controller.
	in	DSTAT	;Wait till not busy.
	rrc
	jc	$-3
	mvi	a,014H+STPRAT ;seek cmd w/verify.
	out	DCOM
	in	Wait	;Wait till complete.
	in	DSTAT	;get disk status.
	if	DEBUG
	sta	trcerr
	endif
	ani	091H	;Check for error.
	rz		;...none, return.

;		Handle errors.
	dcr	b	;Decr retry count.
	jz	Pseek3	;...hard error.
	call	Phome	;home the device.
	lda	dsktrs	;restore original trk #.
	sta	dsktrk
	jmp	Pseek2	;Try seeking again.
Pseek3:
	call	Recov	;Ask about recovery.
	lda	dsktrs	;restore original trk #.
	sta	dsktrk
	jmp	Pseek2-2 ;Try it again.


;*****************************************************
;*                                                   *
;*	Pread - Physical Sector read.		     *
;*                                                   *
;*****************************************************

Pread:
;		Trace activity.
	if	DEBUG
	push	h
	lxi	h,trcact
	mvi	m,4
	pop	h
	endif

;		Save input parameters.
	shld	dskdma	;dma address
	lxi	h,dsksec ;sector #
	mov	m,c
	if	INTRP
	di		;disable interrupts.
	endif

;		Set retry count and interrupt controller.
Prdagn:
	mvi	a,RTCNT	;Set retry count.
Prdrty:
	sta	dskerr
	mvi	a,0D0H	;Issue soft interrupt.
	out	DCOM
	xthl		;Do some delay.
	xthl

;		Set the Sector.
	lda	dsksec	;get it.
	out	SECTP

;		Point to buffer.
	lhld	dskdma

;		Issue Read command to controller.
	in	DSTAT	;get head load status.
	ani	020H
	xri	020H	;invert it.
	rrc		;put it in proper bit.
	rrc
	rrc
	if	OLDTARB
	ori	088H	;Read cmd w/o hdld
	endif
	if	TARBELL
	ori	080H	;Read cmd w/o hdld
	endif
	out	DCOM	;Issue it.

;		Read the data.
Prdlop:
	in	WAIT	;Wait for INTRQ.
	ora	a	;Is it there?
	jp	Prddon	;...yes, we're done.
	in	DDATA	;get a char.
	mov	m,a	;put it in buffer.
	inx	h	;bump ptr.
	jmp	Prdlop	;go get another.

;		Analyze read status.
Prddon:
	in	DSTAT	;get it.
	if	DEBUG
	sta	trcerr
	endif
	if	INTRP
	ei		;enable interrupts.
	endif
	ani	09DH	;any errors?
	rz		;...no, return.
	call	Erchk	;...yes, insure proper track.
	lda	dskerr	;get retry count.
	dcr	a	;Decr it.
	jnz	Prdrty	;...Try reading it again.
	call	Recov	;Give possible operater cancel.
	jmp	Prdagn	;Try reading again.


;*****************************************************
;*                                                   *
;*	Pwrite - Physical Sector Write.		     *
;*                                                   *
;*****************************************************

Pwrite:
;		Trace activity.
	if	DEBUG
	push	h
	lxi	h,trcact
	mvi	m,5
	pop	h
	endif

;		Save input parameters.
	shld	dskdma	;dma address
	lxi	h,dsksec ;sector #
	mov	m,c
	if	INTRP
	di		;disable interrupts.
	endif

;		Set retry count and interrupt controller.
Pwragn:
	mvi	a,RTCNT	;Set retry count.
Pwrrty:
	sta	dskerr
	mvi	a,0D0H	;Issue soft interrupt.
	out	DCOM
	xthl		;Do some delay.
	xthl

;		Set the Sector.
	lda	dsksec	;get it.
	out	SECTP

;		Point to buffer.
	lhld	dskdma

;		Issue Write command to controller.
	in	DSTAT	;get head load status.
	ani	020H
	xri	020H	;invert it.
	rrc		;put it in proper bit.
	rrc
	rrc
	if	OLDTARB
	ori	0A8H	;Write cmd w/o hdld
	endif
	if	TARBELL
	ori	0A0H	;Write cmd w/o hdld
	endif
	out	DCOM	;Issue it.

;		Write the data.
Pwrlop:
	in	WAIT	;Wait for INTRQ.
	ora	a	;Is it there?
	jp	Pwrdon	;...yes, we're done.
	mov	a,m	;get a char from the buffer.
	out	DDATA	;put it to disk.
	inx	h	;bump ptr.
	jmp	Pwrlop	;go get another.

;		Analyze read status.
Pwrdon:
	mvi	a,1	;delay some.
	call	Delay
	in	DSTAT	;get it.
	if	DEBUG
	sta	trcerr
	endif
	if	INTRP
	ei		;enable interrupts.
	endif
	ani	0FDH	;any errors?
	rz		;...no, return.
	call	Erchk	;...yes, insure proper track.
	lda	dskerr	;get retry count.
	dcr	a	;Decr it.
	jnz	Pwrrty	;...Try reading it again.
	call	Recov	;Give possible operater cancel.
	jmp	Pwragn	;Try reading again.




;*****************************************************
;*                                                   *
;*	Erchk - Insure proper seek on read/write     *
;*                                                   *
;*****************************************************

Erchk:
;		Return if not Rcd not found error.
	push	psw	;save error flags.
	ani	010H	;Record not found?
	jnz	Erchk1	;...yes, read address and seek.
	pop	psw	;...no, return.
	ora	a
	ret

;		Read the next address.
Erchk1:
	mvi	a,0C4H	;Read address w/15ms delay
	out	DCOM
	in	WAIT	;Wait for DRQ or INTRQ.
	in	DDATA	;Read track address.
	push	psw	;save it.

;		Flush rest of address data.
Erchk2:
	in	Wait	;Wait for INTRQ.
	ora	a	;Read done?
	jp	Erchk3	;...yes.
	in	DDATA	;...no, flush rest.
	jmp	Erchk2

;		Check on Read Status.
Erchk3:
	in	DSTAT	;Get read Status.
	ora	a	;Sucessful?
	jz	Erchk4	;...yes.
	pop	psw	;...no, clean up stack.
	call	Phome	;       home head
	jmp	Erchk1	;	and try again.

;		Put track # read in controller.
Erchk4:
	pop	psw	;restore track address.
	out	TRACK	;put it in controller.

;		Seek to proper track.
	lda	dsktrk	;get the proper track #.
	mov	c,a
	call	Pseek	;do the seek.
	pop	psw	;restore error flag.
	ret



;*****************************************************
;*                                                   *
;*	Dskadr - Get disk table entry ptr.	     *
;*                                                   *
;*****************************************************

Dskadr:
	push	d	;save regs.
	mov	l,a	;hl = disp to entry.
	mvi	h,0
	dad	h
	lxi	d,dsktbl ;get base adr.
	dad	d	;add base to disp.
	pop	d
	ret


;*****************************************************
;*                                                   *
;*	Recov - Recover from read, seek and write    *
;*		errors.				     *
;*                                                   *
;*****************************************************

Recov:
	lxi	h,errmsg	;Issue error message
	call	Pmsg		;      to console.
	call	conin		;get a response from operator.
	cpi	003H		;Control C?
	jz	WBOOT		;...yes, abort.
	ret


;*****************************************************
;*                                                   *
;*	Pmsg - Print message on console.	     *
;*                                                   *
;*****************************************************

Pmsg:
	mov	a,m		;get next char of msg.
	ora	a		;if zero, eom.
	rz
	push	b		;save bc.
	mov	c,a		;print char on console.
	call	CONOUT
	pop	b		;restore bc.
	inx	h		;bump msg ptr.
	jmp	Pmsg		;loop till eom.


;*****************************************************
;*                                                   *
;*	Delay - Delay (A) msec.			     *
;*                                                   *
;*****************************************************

Delay:
	push	d	;save regs.
	push	h
Delay1: lxi	d,1
	lxi	h,65335	;Constant for 1 msec @ 4mhz
	dad	d
	jnc	$-1
	dcr	a	;Decr msec count.
	jnz	Delay1	;...loop till done.
	pop	h	;restore regs.
	pop	d
	ret


;*****************************************************
;*                                                   *
;*		    BDOS Messages		     *
;*                                                   *
;*****************************************************

btmsg:	db	'** Boot Error **',0
errmsg: db	'** BDOS Error **',0
smsg:	db	00DH,00AH,'Tarbell'
	if	OLDTARB
	db	'(1771) '
	endif
	if	TARBELL
	db	'(1791) '
	endif
	db	MSIZE/10+'0',MSIZE mod 10 + '0'
	db	'K CP/M 2.1',0
	if	DEBUG
lodccp:	db	00DH,00AH,'***Loading CCP---',0
ccplod:	db	00DH,00AH,'***CCP is loaded!',0
	endif




;****************************************************************************
;*                L-O-G-I-C-A-L  D-E-V-I-C-E  D-R-I-V-E-R-S                 *
;*	THE FOLLOWING SECTION CONTAINS THE LOGICAL DEVICE DRIVERS FOR       *
;*	EACH LOGICAL DEVICE IN THE SYSTEM.  THESE DEVICES ARE DEFINED       *
;*	BY THE IOBYTE FUNCTION FOUND IN THE CP/M ALTERATION GUIDE.   	    *
;****************************************************************************


;*************************** CON - SYSTEM CONSOLE **************************
CONST:
	LDA 	IOBYTE		;GET IOBYTE.
	CALL	IOCAL		;EXIT TO SELECTED ROUTINE.
	DW	TTYST
	DW	CRTST
	DW	RDRST
	DW	DUMST
CONIN:
	LDA 	IOBYTE		;GET IOBYTE.
	CALL	IOCAL		;EXIT TO SELECTED ROUTINE.
	DW	TTYIN
	DW	CRTIN
	DW	RDRIN
	DW	DUMIN
CONOUT:
	LDA 	IOBYTE		;GET IOBYTE.
	CALL	IOCAL		;EXIT TO SELECTED ROUTINE.
	DW	TTYOUT
	DW	CRTOUT
	DW	PUNOUT
	DW	DUMOUT


;*************************** LST - OUTPUT LIST DEVICE **********************
LSTST:
	LDA 	IOBYTE		;GET IOBYTE.
	RLC			;SHIFT BITS.
	RLC
	CALL	IOCAL		;EXIT TO SELECTED ROUTINE.
	DW	TTYST
	DW	CRTST
	DW	LPTST
	DW	DUMST
LSTOUT:
	LDA 	IOBYTE		;GET IOBYTE.
	RLC			;SHIFT BITS.
	RLC
	CALL	IOCAL		;EXIT TO SELECTED ROUTINE.
	DW	TTYOUT
	DW	CRTOUT
	DW	LPTOUT
	DW	DUMOUT


;*************************** PUN - PAPER TAPE PUNCH ************************
PUNOUT:
	LDA 	IOBYTE		;GET IOBYTE.
	RRC			;SHIFT BITS.
	RRC
	RRC
	RRC
	CALL	IOCAL		;EXIT TO SELECTED ROUTINE.
	DW	TTYOUT
	DW	PTPOUT
	DW	DUMOUT
	DW	DUMOUT


;*************************** RDR - PAPER TAPE READER ***********************
RDRST:
	LDA 	IOBYTE		;GET IOBYTE.
	RRC			;SHIFT BITS.
	RRC
	CALL	IOCAL		;EXIT TO SELECTED ROUTINE.
	DW	TTYST
	DW	PTRST
	DW	DUMST
	DW	DUMST
RDRIN:
	LDA 	IOBYTE		;GET IOBYTE.
	RRC			;SHIFT BITS.
	RRC
	CALL	IOCAL		;EXIT TO SELECTED ROUTINE.
	DW	TTYIN
	DW	PTRIN
	DW	DUMIN
	DW	DUMIN


;*************************** I/O DISPATCHER ********************************
IOCAL:
	RLC			;SHIFT BITS.
	ANI	006H		;LIMIT BITS.
	XTHL			;SAVE HL, GET TABLE ADDRESS.
	PUSH	D		;SAVE DE.
	MOV	E,A		;GET SELECTION VALUE.
	MVI	D,0
	DAD	D		;GET TABLE ENTRY.
	MOV	A,M
	INX	H
	MOV 	H,M
	MOV	L,A
	POP	D		;RESTORE DE.
	XTHL			;RESTORE HL, SAVE RTN ADDRESS.
	RET			;EXIT TO ROUTINE.




;****************************************************************************
;*              P-H-Y-S-I-C-A-L  D-E-V-I-C-E  D-R-I-V-E-R-S                 *
;*	THE FOLLOWING SECTION CONTAINS THE PHYSICAL DEVICE DRIVERS FOR      *
;*	EACH ACTUAL DEVICE IN THE SYSTEM.  FOR EACH DEVICE, THERE MUST      *
;*	EXIST AT LEAST TWO OF THREE ROUTINES, A DEVICE STATUS ROUTINE	    *
;*	AND A DEVICE INPUT OR OUTPUT ROUTINE.  THE LOGICAL PORTION OF	    *
;*	THE BIOS WILL ONLY CALL A STATUS, INPUT OR OUTPUT ROUTINE.	    *
;****************************************************************************


;*************************** DUM - DUMMY DEVICE ****************************
DUMST:
	MVI	A,0FFH		;INDICATE READY.
	RET
DUMIN:
	MVI	A,01AH		;INDICATE <EOF>.
	RET
DUMOUT:
	RET


;*************************** CRT - HIGH SPEED CONSOLE **********************
CRTST:
	IN	CSTAT		;GET CONSOLE STATUS.
	ANI	CKBR		;IF NOT READY,
	MVI	A,0
	RZ			;   RETURN.
	CMA			;RETURN 0FFH.
	RET
CRTIN:
	IN	CSTAT		;GET CONSOLE STATUS.
	ANI	CKBR		;IF NOT READY,
	JZ	CRTIN		;   LOOP.
	IN	CDATA		;READ THE CHAR.
	ANI	07FH		;MAKE MOST SIG. BIT=0.
	RET
CRTOUT:
	IN	CSTAT		;GET CONSOLE STATUS.
	ANI	CPTR		;IF NOT READY,
	JZ	CRTOUT		;   LOOP.
	MOV	A,C		;GET THE CHAR.
	OUT	CDATA		;PRINT IT.
	RET


;*************************** LPT - LINE PRINTER ****************************
;NOTE -- THIS SECTION GIVES AN LA-36 DECWRITER SOME INTELLIGENCE.
LPTST:
	IN	LSTAT		;GET PRINTER STATUS.
	ANI	LPTR		;IF NOT READY,
	MVI	A,0
	RZ			;   RETURN.
	CMA			;RETURN 0FFH.
	RET
LPTIN	EQU	DUMIN
LPTOUT:
	MOV	A,C		;GET CHAR.
	CPI	007H		;<BELL>?
	JZ	LPTOUTC		;...YES.
	CPI	008H		;<BACKSPACE>?
	JZ	LPTBS		;...YES.
	CPI	009H		;<HORIZONTAL TAB>?
	JZ	LPTHT		;...YES.
	CPI	00AH		;<LINE FEED>?
	JZ	LPTLF		;...YES.
	CPI	00CH		;<FORM FEED>?
	JZ	LPTFF		;...YES.
	CPI	00DH		;<CARRIAGE RETURN>?
	JZ	LPTCR		;...YES.

LPTCLI:
	LDA	CLCNT		;INCR COLUMN COUNT.
	INR	A
	STA	CLCNT
	MOV	B,A		;SAVE IT.

LPTOUTC:
	IN	LSTAT		;GET PRINTER STATUS.
	ANI	LPTR		;IF NOT READY,
	JZ	LPTOUTC		;   LOOP.
	MOV	A,C		;GET THE CHAR.
	OUT	LDATA		;PRINT IT.
	RET

LPTBS:
	LDA	CLCNT		;DECR COLUMN COUNT.
	DCR	A
	RZ			;IF <0 THEN RETURN W/O PRINTING.
	STA	CLCNT
	JMP	LPTOUTC

LPTHT:
	MVI	C,' '		;ISSUE <BLANK>.
	CALL	LPTCLI
	MOV	A,B		;GET COLUMN COUNT.
	ANI	8-1		;ROUND TO MOD 8.
	JNZ	LPTHT		;LOOP TO MOD 8.
	RET

LPTLF:
	LDA	LFCNT		;INCR LF COUNT.
	CPI	66		;MAX VALUE?
	JC	$+4		;...NO.
	XRA	A		;...YES, RESET IT.
	INR	A
	STA	LFCNT
	JMP	LPTOUTC

LPTFF:
	LDA	LFCNT		;TOP OF FORM?
	CPI	1
	RZ			;...YES.
	MVI	C,00AH		;ISSUE <LF>.
	CALL	LPTLF
	JMP	LPTFF

LPTCR:
	XRA	A		;ZERO COLUMN COUNT.
	STA	CLCNT
	JMP	LPTOUTC

CLCNT:	DB	0		;COLUMN COUNT
LFCNT:	DB	1		;LINE FEED COUNT


;************************ PTP - PAPER TAPE PUNCH ***************************
PTPST	EQU	DUMST
PTPIN	EQU	DUMIN
PTPOUT	EQU	DUMOUT


;************************ PTR - PAPER TAPE READER **************************
PTRST	EQU	DUMST
PTRIN	EQU	DUMIN
PTROUT	EQU	DUMOUT


;************************ TTY - SLOW SPEED CONSOLE *************************
TTYST:
	IN	LSTAT		;GET TTY STATUS.
	ANI	LKBR		;IF NOT READY,
	MVI	A,0
	RZ			;   RETURN.
	CMA			;RETURN 0FFH.
	RET
TTYIN:
	IN	LSTAT		;GET TTY STATUS.
	ANI	LKBR		;IF NOT READY,
	JZ	TTYIN		;   LOOP.
	IN	LDATA		;READ THE CHAR.
	ANI	07FH		;MAKE MOST SIG. BIT=0.
	RET
TTYOUT	EQU	LPTOUT




;*****************************************************
;*                                                   *
;*	Unitialized RAM data areas		     *
;*                                                   *
;*****************************************************
;
STARTZ:		;** Start of zeroed area **
sekdsk:	ds	1		;seek disk number
sektrk:	ds	2		;seek track number
seksec:	ds	1		;seek sector number
sekdph: ds	2		;seek .dph(sekdsk)
sekdpb: ds	2		;seek .dpb(sekdsk)
;
hstdsk:	ds	1		;host disk number
hsttrk:	ds	2		;host track number
hstsec:	ds	1		;host sector number
hstdph: ds	2		;host .dph(sekdsk)
hstdpb: ds	2		;host .dpb(sekdsk)
;
sekhst:	ds	1		;seek shr secshf
hstact:	ds	1		;host active flag
hstwrt:	ds	1		;host written flag
;
unacnt:	ds	1		;unalloc rec cnt
unadsk:	ds	1		;last unalloc disk
unatrk:	ds	2		;last unalloc track
unasec:	ds	1		;last unalloc sector
;
dskcur:	ds	1		;current disk #
dsktrk:	ds	2		;current track #
dsksec:	ds	1		;current sector #
dsktrs:	ds	1		;current trk # (saved)
dskdfc:	ds	1		;current format code
;		note - the following two latches must be kept
;			contiguous.
dsklth:	ds	1		;current disk latch
dskolt:	ds	1		;old disk latch
dskdma:	ds	2		;current dma address
dskerr:	ds	1		;current disk error count
dsktbl: ds	4*2		;disk parameter table
;				;  one entry for each
;				;  physical drive
;	db	0nnH		;flags
;				 80 - 0=not logged, 1=disk logged
;				 40 - 0=single density, 1=double
;	db	nn		;current track
ENDZ:		;** End of Zeroed Area **


	if	DEBUG
trcact:	ds	1		;last traced activity number
trcerr:	ds	1		;last traced controller error
	endif
erflag:	ds	1		;error reporting
rsflag:	ds	1		;read sector flag
readop:	ds	1		;1 if read operation
wrtype:	ds	1		;write operation type
ccpsav:	ds	6		;CCP non-128-byte boundary data.
dmaadr:	ds	2		;last dma address
ALV0:	ds	48
CSV0:	ds	32
ALV1:	ds	48
CSV1:	ds	32
ALV2:	ds	48
CSV2:	ds	32
ALV3:	ds	48
CSV3:	ds	32
dirbuf:	ds	128		;directory buffer
hstbuf:	ds	hstmax		;host buffer
	end
