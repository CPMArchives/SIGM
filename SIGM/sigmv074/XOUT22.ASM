;********************************************************
;*							*
;*	REMOVES XSUB WITHOUT COLD BOOTING		*
;*							*
;*	FOR XSUB DISTRIBUTED WITH CP/M 2.2		*
;*							*
;********************************************************
;
;	By		Bill Bolton
;			Software Tools
;			P.O. Box 80,
;			Newport Beach,
;			N.S.W., 2106
;			AUSTRALIA
;
;	Nov 21, 1980	Revised for XSUB 2.2
;
;	June 3, 1980	Written for XSUB 2.0
;
WBOOT	EQU	00001H			;BIOS WBOOT ADDRESS
BDOS	EQU	00005H			;BDOS ENTRY LOCATION
PRINT	EQU	9			;BDOS PRINT STRING FUNCT
XSUB1	EQU	17D4H			;XSUB OFFSET1
XSUB2	EQU	0A00H			;XSUB OFFSET2
;
	ORG	100H
;
START:	LDA	WBOOT			;GET VALUE OF WBOOT LOW BYTE
	CPI	03			;IS XSUB THERE?
	JZ	NOSUB			;NO, QUIT
	LHLD	WBOOT			;YES, GET XSUB'S WARM BOOT ADDR
	LXI	B,XSUB1			;GET XSUB OFFSET
	DAD	B			;FORM BIOS WARM BOOT ADDRESS
	SHLD	WBOOT			;STUFF IT INTO CP/M
	LHLD	6			;GET XSUB'S BDOS ADDRESS
	LXI	B,XSUB2			;GET XSUB OFFSET
	DAD	B			;FORM BDOS ENTRY
	SHLD	BDOS+1			;STUFF IT INTO CP/M
	LXI	D,MESSG1		;TELL THEM WHAT WE DID
EXIT:	MVI	C,PRINT
	CALL	BDOS
	JMP	0			;WARM BOOT
;
NOSUB:	LXI	D,MESSG2		;NO XSUB MESSAGE
	JMP	EXIT
;
MESSG1:	DB	'(Xsub 2.2 removed)$'
MESSG2:	DB	'(Xsub 2.2 was not loaded, no change made)$'
;
	END	START			;THAT'S ALL FOLKS
