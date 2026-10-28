;==> fixed bug caused by type	 11/5/80--RGF
;
; This patch modifies the cp/m 2.2 MOVCPM program for remote operation.
; This sets up the movcpm itself for the ccppatch mod, which causes
; the ccp to look on drive A for a com file not found on the current
; logged-in drive.  In addition, this patch allows changing the ccp
; commands.  This is useful for remote system security.
;
; REQUIREMENTS FOR USE
; --------------------
; This file will only work on cpm2.2 versions of movcpm.  Also, the
; movcpm must have the ccp located at 0A00H.  If it does not, then
; change the CCPBIAS equate to whereever it is in your system.	If
; your BIOS is a non-standard size, you will have to change the SIZE
; equate.  You can determine your system size by examining locations
; 802 and 801 of your movcpm program with ddt or sid, then set the
; SIZE equate accordingly.
;
; HOW TO PATCH THE MOVCPM PROGRAM
; -------------------------------
; After making any changes necessary to this file, use ASM or MAC
; to assemble it, and produce a HEX file.  Read in the movcpm program
; with the ccp command:
;		A>DDT MOVCPM.COM.
; Then read in the patch hex file with
;		*IMOVPATCH.HEX
;		*R
; After doing this, exit to cp/m command level with ^C, and
;		A>SAVE XX MOVCPMR.COM
; where XX is the size (in 256 byte pages) of your movcpm program.
; It is a good idea to change the name (as done above) to make the
; program easily recognizable as being the remote-cp/m version.
;
;			Ron Fowler
;			11/2/80 
;
; Notes from original version of CCPPATCH.ASM:
;
; This patch causes the CCP of a cp/m 2.x system to look on drive A
; when you are logged into a drive other than A and call for a .COM
; file that does not exist on that drive.  Giving an explicit drive
; reference overrides this feature, so that you can always force
; the file to be loaded from a specific drive.
;
;
;
;
;	equates (set up for standard digital research movcpm pgm)
;
SIZE	EQU	1B00H
CCPBIAS EQU	0A00H

;
;	SET-UP OF NEW CCP COMMANDS
;	NOTE: all command names must fill a 4-character field
;
	ORG	CCPBIAS+310H	;where the commands are
;
	DB	'DIR '		;<== put your new "DIR" cmd here
	DB	'ERA '		;<== put your new "ERA" cmd here
	DB	'TYPE'		;<== put your new "TYPE" cmd here
	DB	'SAVE'		;<== put your new "SAVE" cmd here
	DB	'REN '		;<== put your new "REN" cmd here
	DB	'USER'		;<== put your new "USER" cmd here
;
;
;	Modify the CCP for A-drive check for COM files
;
	ORG	CCPBIAS+6DBH
	JZ	7F2H		;jump to patch
;
	ORG	CCPBIAS+7F2H	;replaces an unused area of NOP's
	LXI	H,7F0H		;get drive from current command
	ORA	M		;accum was 0 on entry, so this fetches drive
	JNZ	76BH		;command has explicit drive...give error
	INR	M		;force explicit reference to drive A
	LXI	D,7D6H		;we need to do set up when..
	JMP	6CDH		;..we enter ccp
;
;
;	update the cpm bitmap for this patch
;
	ORG	CCPBIAS+SIZE+20H-2
	DB	8,89H		;these locations need relocation
;
	END

;
;	update the cpm bitmap for this patch
;
	ORG	CCPBIAS+SIZE+20H-2
	DB	8,89H		;