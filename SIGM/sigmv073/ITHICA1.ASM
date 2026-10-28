*********************************************************
*							*
*	ITHICA 512 BYTE DPB INSTALLER FOR DJ2D BIOS	*
*							*
*							*
*	(C) 1981, Software Tools			*
*		  P.O. Box 80				*
*		  Newport Beach				*
*		  NSW, 2106				*
*		  AUSTRALIA				*
*							*
*	Written by:	Bill Bolton			*
*							*
*	Date:		15/Mar/1981			*
*							*
*	Version:	1.1	(Initial Release)	*
*							*
*	-------------------------------------------	*
*							*
*	INPUT PARAMETERS:				*
*							*
*			None				*
*							*
*	ACTION:						*
*							*
*			Overlays new DPB into		*
*			Morrow DPB area			* 
*							*
*	------------------------------------------	*
*							*
*	Assembler:	MAC.ASM (Digital Research)	*
*							*
*	Support:	MACRO3.LIB (Software Tools)	*
*							*
*********************************************************	    
;
;	Hackers Notes:
;
;	N.B. Intersystems 2D format doesn't have Track 0 in
;	single density so watch out !!!!!!
;
OFFSET1	EQU	10		;OFFSET DPH TO DPB POINTER
OFFSET2	EQU	64		;OFFSET FROM STORE 1 TO STORE 2
WBOOT	EQU	0		;CP/M WARM BOOT ENTRY
;
	MACLIB	MACRO3		;SOFTWARE TOOLS SPECIAL MACROS
;
	ORG	100H
;
START:	LXI	H,0		;Set up new stack
	DAD	SP
	SHLD	OLDSTAK
	LXI	SP,STACK
;
	PRINT	<'Software Tools - Dynamic Disk Parameter Block Modifier'>
	PRINT	<CR,LF,'For Morrow Designs Disk Jockey 2D CP/M',CR,LF>
	PRINT	<'This version installs Intersystems 512 DPB',CR,LF,LF>
;
	DISKIO	?DRIVE		;GET CURRENT DRIVE
	MOV	C,A		;C <---- CURRENT DRIVE
	CALLBIOS DSELDSK	;HL POINTS TO DPH ON RETURN
NEXT:
	LXI	D,OFFSET1	;DE <---- OFFSET TO DPB ADDRESS IN DPH
	DAD	D		;HL <---- POINTS TO DPB ADDRESS
	CONTENTS		;HL <---- 1024 BYTE DPB ADDRESS
	MOV	A,M		;GET SPT VALUE
	CPI	64		;SINGLE SIDED 1024 BYTE?
	JNZ	DOUBLE		;NO
	LXI	D,-16		;OFFSET TO 512 BYTE BLOCK
	DAD	D		;HL <---- POINTER TO 512 BYTE SS BLOCK
	JMP	GO$ON
;
DOUBLE:
	CPI	128
	JNZ	ERROR
	LXI	D,-80		;OFFSET TO SINGLE SIDED 512 BYTE BLOCK
	DAD	D		;HL <---- POINTER TO 512 BYTE SS BLOCK
GO$ON:
	LXI	D,DPB1		;DE <---- POINTER TO NEW BLOCK
	LXI	B,16		;BC <---- LENGTH OF BLOCK
	PUSH	H		;SAVE POINTER
	CALL	MOVER
	POP	H
;
	LXI	D,OFFSET2
	DAD	D
	LXI	D,DPB2
	LXI	B,16
	CALL	MOVER
;
	PRINT	<'Intersystems DPB for 512 bytes per sector disks',CR,LF>
	PRINT	<'now installed in BIOS in place of Morrow 512 byte DPB',CR,LF>
	PRINT	<'A cold boot will restore all usual DPBs',CR,LF,LF>
;
EXIT:
	LHLD	OLDSTAK		;Restore CP/M stack
	SPHL
	RET
;
MOVER:
	LDAX	D		;GET A BYTE
	MOV	M,A		;PUT A BYTE
	INX	D		;ADJUST POINTERS
	INX	H
	DCX	B		;DONE YET?
	MOV	A,B
	ORA	C
	JNZ	MOVER		;NO
	RET			;YES
;
ERROR:
	PRINT	<BEL,'DPB not located, no changes made to BIOS',BEL,CR,LF>
	PRINT	<'This program will only function correctly if called',CR,LF>
	PRINT	<'from a 1024 bytes per sector disk, with Morrow',CR,LF>
	PRINT	<'CP/M 2.X',CR,LF,LF>
	JMP	EXIT
;
DPB1:
	DW	60		; SPT, Sectors/cylinder
	DB	4		; BSH, Block shift factor
	DB	15		; BLM, Block mask.
	DB	0		; EXM, Null mask.
	DW	284		; DSM, Number of 2048 byte blocks.
	DW	191		; DRM, Number of directory entries - 1
	DB	0E0H		; AL0, Alloc 0 ( for directory )
	DB	0		; AL1, Alloc 1 (  "     "      )
	DW	48		; CKS, Check size.
	DW	1		; OFF, Number of reserved tracks.
	DB	33H		; Morrow Special Parameter
;
DPB2:
	DW	120		; SPT, Sectors/cylinder
	DB	5		; BSH, Block shift factor
	DB	31		; BLM, Block mask.
	DB	1		; EXM, Null mask.
	DW	285		; DSM, Number of 4096 byte blocks.
	DW	127		; DRM, Number of directory entries - 1
	DB	80H		; AL0, Alloc 0 ( for directory )
	DB	0		; AL1, Alloc 1 (  "     "      )
	DW	32		; CKS, Check size.
	DW	1		; OFF, Number of reserved tracks.
	DB	3BH		; Morrow Special Parameter
;
OLDSTAK	DS	2		;CP/M stack store
SPACE	DS	12		;Stack area
STACK	EQU	$		;Stack top
;
	END	START
