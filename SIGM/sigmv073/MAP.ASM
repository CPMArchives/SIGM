*********************************************************
*							*
*	REPORT REMAINING DISK SPACE ROUTINE		*
*							*
*	A LINKABLE MODULE IN THE MICROSOFT		*
*	RELOCATION FORMAT				*
*							*
*	1981,	  Software Tools			*
*		  P.O. Box 80				*
*		  Newport Beach				*
*		  NSW, 2106				*
*		  AUSTRALIA				*
*							*
*	Written by:	Bill Bolton			*
*							*
*	Date:		26/Jan/1981			*
*							*
*	Version:	1.2	(Initial Release)	*
*							*
*	-------------------------------------------	*
*							*
*	INPUT PARAMETERS:				*
*							*
*	1st. passed in HL = Address of variable for	*
*			    returned value		*
*							*
*	2nd. passed in DE = Address of drive identifier.*
*			    Addressed contents must be	*
*			    the	binary value of an	*
*			    ASCII character A to P	*
*			    (uppercase only). No	*
*			    range checking is done	*
*			    by this module.		*	
*							*
*	RETURNED VALUE:					*
*							*
*	1st. passed by writing value of remaining	*
*		    no. of Kbytes on disk into		*
*		    address of variable passed as	*
*		    input parameter 1. Value		*
*		    is returned as an unsigned		*
*		    16 bit binary number, low		*
*		    byte first.				*
*							*
*	ERROR CONDITIONS:				*
*							*
*			    No error conditions are	*
*			    explicitly reported by	*
*			    this module, BDOS will	*
*			    report an error if the	*
*			    drive identifier is		*
*			    invalid or out of bounds.	*
*							*
*	------------------------------------------	*
*							*
*	Assembler:	RMAC.ASM (Digital Research)	*
*							*
*	Support:	MACRO3.LIB (Software Tools)	*
*							*
*********************************************************	    

PUBLIC	MAP			;GLOBAL LABLE

	MACLIB	MACRO3		;USEFUL MACRO LIBRARY

	CSEG			;RELOCATABLE MODEULE

MAP:
	SHLD	VALUE		;SAVE POINTER TO RETURN VARIABLE
	LXI	H,0		;SET UP STACK FOR THIS MODULE
	DAD	SP
	SHLD	OLDSTAK
	LXI	SP,STACK
	LDAX	D		;A <---- DRIVE IDENT
	SUI	41H		;REMOVE ASCII OFFSET
	MOV	E,A		;E <---- DRIVE IDENT
	DISKIO	LOGIN		;LOG IN SELECTED DRIVE
	DISKIO	?ALLOC		;GET POINTER TO ALLOCATION MAP
	MOV	H,B
	MOV	L,A		;HL <--- POINTER TO MAP
	SHLD	IPOINT		;SAVE IT
	LXI	H,0
	SHLD	G		;ZERO COUNT OF UNUSED GROUPS
	XRA	A
	DISKIO	?DPB		;GET DISK PARAMETER BLOCK
	     			;HL POINTS TO BIOS DPB ON RETURN
	LXI	D,2		;OFFSET TO BSH
	DAD	D		;HL <---- POINTER TO BSH
	MOV	A,M		;A <---- BSH
	STA	BSH		;SAVE BSH FOR LATER SIZE CALC
	INX	D		;DE <---- OFFSET FROM BSH TO DSM
	DAD	D		;HL <---- POINTER TO DSM
	CONTENTS		;HL <---- DSM VALUE
	INX	H
	SHLD	MAP$COUNT	;SAVE FOR BLOCKS+1
	LHLD	IPOINT		;POINTER TO DISK ALLOCATION MAP
MAP3:
	MVI	B,8		;BITS PER WORD
	MOV	A,M		;GET A BYTE FROM ALLOC MAP
MAP4:
	RAL			;BLOCK ALLOCATED
	SAVE	B,D,H,PSW
	JC	MAP6		;YES
	LHLD	G		;NO, HL <---- UNUSED GROUPS
	INX	H		;ADD 1
	SHLD	G		;STORE IT BACK
MAP6:
	RESTORE	PSW,H,D,B
	SAVE	PSW,H		;SAVE BIT MAP BYTE
	LHLD	MAP$COUNT	;GET BLOCKS REMAINING
	DCX	H		
	SHLD	MAP$COUNT	;SAVE NEW BLOCKS LEFT
	DJZ	FINISHED	;QUIT IF DONE
	MOV	A,B		;BIT COUNT
	CPI	1		;LAST BIT OF BYTE?
	JZ	BITS		;YES
	DCR	B
	RESTORE H,PSW
	JMP	MAP4
;
BITS:
	RESTORE H
	INX	H		;BUMP POINTER TO NEXT BYTE		
	RESTORE PSW
	JMP	MAP3
;
;
FINISHED:
	RESTORE PSW
	LHLD	G		;HL <---- NO OF UNUSED BLOCKS
	LDA	BSH		;GET BLOCK SHIFT FACTOR
	DCR	A		;MINIMUM VALUE OF BSH
	DCR	A		; IS 3, FOR 1K BLOCKS
MULTIPLY:
	DCR	A		;FINISHED LOOP?
	JZ	EXIT		;YES
	DAD	H		;NO, MULTIPLY BY 2
	JMP	MULTIPLY	;TEST FOR EXIT
;
EXIT:
	XCHG			;DE <---- NO OF UNUSED KBYTES
	LHLD	VALUE		;HL <---- POINTER TO RETURN VARIABLE
	MOV	M,D		;SAVE HI BYTE
	INX	H
	MOV	M,E 
	LHLD	OLDSTAK		;RESTORE CALLER'S STACK
	SPHL
	RET
;
;	DATA STORAGE
;
	DSEG
;
VALUE:
	DW	0		;ADDRESS OF VARIABLE FOR RETURNED VALUE
G:
	DW	0		;NUMBER OF UNUSED BLOCKS
IPOINT:
	DW	0		;POINTER TO ALLOCATION MAP BYTE
MAP$COUNT:
	DW	0		;NUMBER OF BLOCKS REMAINING
BSH:
	DB	0		;BLOCK SHIFT FACTOR
OLDSTAK:
	DS	2		;CALLER'S STACK POINTER
SPACE:
	DS	14		;STACK
STACK:
	DS	2		;STACK TOP
;
	END
