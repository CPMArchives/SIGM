;                   FINDBAD.ASM ver. 4.2
;		     (revised 02/05/81)
;
;FINDBAD will find all bad blocks on a disk and build a file
;named [UNUSED].BAD to allocate them, thus "locking out" the
;bad blocks so CP/M will not use them.
;
;Originally written by Gene Cotton,  published in "Interface
;Age", September 1980 issue, page 80.
;
;This program now supports the following disk drives:
;
;	- STANDARD 8" SINGLE DENSITY
;	- MICROPOLIS MOD II
;	- MICROMATION DOUBLE DENSITY
;	- DIGITAL MICROSYSTEMS FDC3 DBL DENS
;	- IMSAI DOUBLE DENSITY (IMDOS)
;	- DISCUS 2D (SINGLE SIDED) 256/512/1024 BYTE SECTORS
;	- NATIONAL MULTIPLEX DD 1/2 SIDED 256/512 BYTE SECTORS
;	- HEATH H-17 5.25" SINGLE SIDED SINGLE DENSITY
;       - ICOM MICROFLOPPY 5.25" SINGLE SIDED, SINGLE DENSITY  
;       - JADE DOUBLE DENSITY/SINGLE SIDED
;	- NORTH STAR HORIZON DOUBLE DENSITY, SINGLE OR DOUBLE SIDED
;
;As presently set up, this program will perform properly on an
;8" single-density soft-sectored disk recorded in standard IBM
;format (i.e., 77 tracks, 26 sectors/track, 243 blocks/disk, 8
;sectors/block, 128 bytes/sector).  If your disk is not an IBM
;8" standard, then you must set the conditional assembly 
;switches to one of the defined disk systems or modify the 
;existing disk parameter definitions according to the 
;guidelines established in this documentation.  See notes
;below concerning 'TEST' conditional assembly option.
;
;NOTE: If you want to add conditional assembly for other disk
;systems, or otherwise update this program, make sure you have
;the latest version first.  After adding your changes, please
;modem a copy of the new file to "TECHNICAL CBBS" in Dearborn,
;Michigan - phone 313-846-6127 (110, 300, 450 or 600 baud).
;Use the filename FINDBAD.NEW.   (KBP)
;
;Revisions/modifications: (listed in reverse order
;to minimize reading time)
;
;02/05/81 Merged 2/2/81 and 1/24/81 changes, which were done
;	  independently by Clyne and Mack.  (KBP)
;
;02/02/81 Added equates for North Star Horizon - 5.25" drives,
;	  double density, single and double sided. (Bob Clyne)
;
;01/24/81 Added equates for Jade DD disk controller
;         (Pete H. Mack)
;
;01/19/81 Added equates for Icom Microfloppy 5.25" drives.
;         (Eddie Currie)
;
;01/05/81 Added equates for Heath H-17 5.25" drives.
;	  (Ben Goldfarb)
;
;12/08/80 Added equates for National Multiplex D3S/D4S
;         double-density board in various formats.
;         (David Fiedler)
;
;09/22/80 Added equates for Morrow Disk Jockey 2D/SS, 256,
;	  512 and 1024-byte sector options.  Fix 'S2' update
;	  flag for larger max number of extents. Cleaned up
;	  file. (Ben Bronson and KBP)
;
;09/14/80 Corrected DGROUP equate for MMDBL. Added new routine
;	  to correct for IMDOS group allocation.  Corrected
;	  error in instructions for using TEST routine.
;	  (CHS) (AJ) (KBP) - (a group effort)
;
;09/08/80 Fixed several errors in Al Jewer's mods.  Changed
;	  return to CP/M to warm boot so bitmap in memory will
;	  be properly updated. Added conditional assembly for
;	  testing program. (KBP)
;
;09/02/80 Added IMDOS double-density equates & modified for 
;	  more then 256 blocks per disk. (Al Jewer)
;
;09/01/80 Changed equates so that parameters are automatically
;	  set for each disk system conditional assembly (KBP)
;
;08/31/80 Add conditional assembly for Digital Microsystems FDC3
;	  controller board in double-density format and fix to
;	  do 256 blocks in one register. (Thomas V. Churbuck)
;
;08/31/80 Correct MAXB equate - MAXB must include the directory
;	  blocks as well as the data blocks.  Fix to make sure
;	  any [UNUSED].BAD file is erased before data area is
;	  checked. (KBP)
;
;08/30/80 Added conditional assembly for Micromation
;	  double-density format. (Charles H. Strom)
;
;08/27/80 Fix missing conditional assembly in FINDB routine.
;	  Put version number in sign-on message. (KBP)
;
;08/26/80 Modified by Keith Petersen, W8SDZ, to:
;	  (1) Add conditional assembly for 1k/2k groups
;	  (2) Add conditional assembly for standard drives
;	      and Micropolis MOD II
;	  (3) Make compatible with CP/M-2.x
;	  (4) Remove unneeded code to check for drive name
;	      (CP/M does it for you and returns it in the FCB)
;	  (5) Changed to open additional extents as needed for
;	      overflow, instead of additional files
;	  (6) Add conditional assembly for system tracks check
;	      (some double-density disks have single-density
;	      system tracks which cannot be read by this program)
;	  (7) Increased stack area (some systems use more than
;	      others).
;
;08/06/80 Added comments and crunched some code.
;	  KELLY SMITH.  805-527-9321 (Modem, 300 Baud)
;			805-527-0518 (Verbal)
;
;
;			Using the Program
;
; Before  using this program to "reclaim" a diskette,  it  is
;recommended that the diskette be reformatted. If this is not
;possible,  at least assure yourself that any existing  files
;on the diskette  do not contain unreadable  sectors.  If you
;have changed disks since the last warm-boot, you  must warm-
;boot again before running this program.
;
; To  use the program,  insert  both the disk containing  the
;program  FINDBAD.COM and the diskette to be checked into the
;disk drives. It is possible that the diskette containing the
;program is the one to be checked. Assume that the program is
;on drive "A" and the suspected bad disk is on drive "B".  In
;response to the CP/M prompt "A>",  type in FINDBAD B:.  This
;will  load the file FINDBAD.COM from drive "A" and test  the
;diskette  on  drive "B" for  unreadable  sectors.  The  only
;allowable  parameter  after  the  program name  is  a  drive
;specification  (of the form " N:") for up to four (A  to  D)
;disk drives.  If no drive is specified, the currently logged
;in drive is assumed to contain the diskette to check.
;
; The  program first checks the CP/M System tracks (0 and 1),
;and  any  errors here prohibit the disk from being  used  on
;drive  "A",  since all "warm  boots" occur using the  system
;tracks from the "A" drive.
;
; The  program next checks the first two data blocks  (groups
;to some of us) containing the directory of the diskette.  If
;errors  occur  here,  the  program  terminates  and  control
;returns  to  CP/M  (no other data blocks are  checked  since
;errors in the directory render the disk useless).
;
; Finally,  all  the remaining data blocks are  checked.  Any
;sectors  which  are  unreadable cause the data  block  which
;contains them to be stored temporarily as a "bad block".  At
;the end of this phase,  the message "XX bad blocks found" is
;displayed (where XX is replaced by the number of bad blocks,
;or "No" if no read errors occur).  If bad blocks occur,  the
;filname [UNUSED].BAD is created, the list of "bad blocks" is
;placed  in  the allocation map of the  directory  entry  for
;[UNUSED].BAD,  and the file is closed.  Note,  that when the
;number of "bad blocks" exceeds 16,  the  program  will  open
;additional  extents  as  required  to  hold the overflow.  I
;suggest that if the diskette has more than  32 "bad blocks",
;perhaps it should be sent to the "big disk drive in the sky"
;for the rest it deserves.
;
; The  nifty part of all this is that if any "bad blocks"  do
;occur, they are allocated to [UNUSED].BAD and no longer will
;be available to CP/M for future allocation...bad sectors are
;logically locked out on the diskette!
;
;
;              Using the TEST conditional assembly
;
;A  conditional  assembly has been added to allow  testing  this 
;program  to  make sure it is reading all sectors on  your  disk 
;that  are accessible to CP/M.  The program reads the disk on  a 
;block by block basis, so it is necessary to first determine the 
;number of blocks present.  To start, we must know the number of 
;sectors/block (8 sectors/block for standard IBM single  density 
;format).  If  this  value  is  not  known,  it  can  easily  be 
;determined  by saving one page in a test file and interrogating 
;using the STAT command:
;
;	A>SAVE 1 TEST.SIZ
;	A>STAT TEST.SIZ
;
;For standard single-density STAT will report this file as being
;1k.  The file size reported (in bytes) is the size of a  block. 
;This  value  divided  by 128 bytes/sector  (the  standard  CP/M 
;sector  size)  will  give sectors/block.  For  our  IBM  single 
;density example, we have:
;
;  (1024 bytes/block) / (128 bytes/sector) = 8 sectors/block.
;
;We  can now calculate blocks/track (assuming we know the number 
;of sectors/track). In our example:
;
;  (26 sectors/track) / (8 sectors/block) = 3.25 blocks/track
;
;Now  armed with the total number of data tracks (75 in our  IBM 
;single density example), we get toatal blocks accessible: 
;
;  75 (tracks/disk) x (3.25 blocks/track) = 243.75 blocks/disk 
;
;CP/M cannot access a fractional block, so we round down (to 243 
;blocks  in  our  example).  Now  multiplying  total  blocks  by 
;sectors/block  results in total sectors as should  be  reported 
;when TEST is set TRUE and a good disk is read. For our example, 
;this value is 1944 sectors. 
;
;Finally,  note that if SYSTEM is set TRUE,  the sectors present 
;on  the  first  two tracks must be added in  as  well.  In  the 
;previous  example,  this  results in  1944 + 52 = 1996  sectors 
;reported by the TEST conditional.
;
;Run the program on a KNOWN-GOOD disk.  It should report that it
;has read  the  correct number of sectors.  The test conditional
;assembly should then be set FALSE and the program re-assembled.
;The test routines  cannot be left in  because this program does
;not read all the sectors in a block that is found to be bad and
;thus will report an inaccurate number of sectors read.
;
;
;Define TRUE and FALSE
;
FALSE	EQU	0
TRUE	EQU	NOT FALSE
;
;******************************************************************
;Conditional assembly switches (only one should be true)
STDDRV	EQU	TRUE 	;TRUE IF STANDARD 8" SINGLE DENSITY DRIVE
MICROP	EQU	FALSE	;TRUE IF MICROPOLIS MOD II
MMDBL	EQU	FALSE	;TRUE IF MICROMATION DOUBLE DENSITY
DIGDBL	EQU	FALSE	;TRUE IF DIGITAL MICROSYSTEMS FDC3 DBL DENS
IMDOS	EQU	FALSE 	;TRUE IF IMSAI DOUBLE DENSITY
DJ256S	EQU	FALSE	;TRUE IF MORROW 2D/SS  (256-BYTE SECTOR)
DJ512S	EQU	FALSE	;TRUE IF MORROW 2D/SS  (512-BYTE SECTOR)
DJ1024	EQU	FALSE	;TRUE IF MORROW 2D/SS (1024-BYTE SECTOR)
NM256	EQU	FALSE	;TRUE IF NATMUX 2D     (256-BYTE SECTOR)
NM512	EQU	FALSE	;TRUE IF NATMUX 2D     (512-BYTE SECTOR)
H17	EQU	FALSE	;TRUE IF HEATH H-17 5.25" SGL. DENS.
ICOM	EQU	FALSE	;TRUE IF ICOM MICROFLOPPY
JADEDD	EQU	FALSE	;TRUE IF JADE DD DISK CONTROLLER
HORIZON	EQU	FALSE	;TRUE IF NORTH STAR HORIZON
;******************************************************************
;
;Conditional assembly switch for double-sided drives
;(presently supported for National Multiplex and Horizon only)
;
SIDES2	EQU	FALSE	;TRUE FOR NATMUX D3S/D4S OR HORIZON DOUBLE SIDED ONLY
;
;******************************************************************
;
;Conditional assembly switch for testing this program
;(for initial testing phase only - see remarks above)
;
TEST	EQU	FALSE	;TRUE FOR TESTING ONLY
;******************************************************************
;
;System equates
;
BASE	EQU	0	;STANDARD CP/M BASE ADDRESS (4200H FOR ALTCPM)
BDOS	EQU	BASE+5	;CP/M WARM BOOT ENTRY
FCB	EQU	BASE+5CH;CP/M DEFAULT FCB LOCATION
;
;Define disk system parameters
;
	IF	STDDRV
SYSTEM	EQU	TRUE	;TRUE IF CHECK SYSTEM TRACKS WANTED
TRACKS	EQU	77	;TOTAL NUMBER OF TRACKS/DISK
SECTS	EQU	26	;TOTAL NUMBER OF SECTORS/TRACK
DBASE	EQU	2	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK NUMBER FOR DATA
MAXB	EQU	243	;MAX NUMBER OF BLOCKS (including directory)
BLOCK	EQU	8	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	FALSE	;TRUE IF 2k GROUP SIZE
	ENDIF		;STDDRV
;
	IF	MICROP
SYSTEM	EQU	TRUE	;TRUE IF CHECK SYSTEM TRACKS WANTED
TRACKS	EQU	77	;TOTAL NUMBER OF TRACKS/DISK
SECTS	EQU	32	;TOTAL NUMBER OF SECTORS/TRACK
DBASE	EQU	2	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK NUMBER FOR DATA
MAXB	EQU	150	;MAX NUMBER OF BLOCKS (including directory)
BLOCK	EQU	16	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	TRUE	;TRUE IF 2k GROUP SIZE
	ENDIF		;MICROP
;
	IF	MMDBL
SYSTEM	EQU	FALSE	;FALSE IF CHECK SYSTEM TRACKS NOT WANTED
TRACKS	EQU	77	;TOTAL NUMBER OF TRACKS/DISK
SECTS	EQU	52	;TOTAL NUMBER OF SECTORS/TRACK
DBASE	EQU	2	;DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK FOR DATA
MAXB	EQU	243	;MAXIMUM NUMBER OF BLOCKS (including directory)
BLOCK	EQU	16	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	TRUE	;TRUE IF 2k GROUP SIZE
	ENDIF		;MMDBL
;
	IF	DIGDBL
SYSTEM	EQU	FALSE	;FALSE IF CHECK SYSTEM TRACKS NOT WANTED
TRACKS	EQU	77	;TOTAL NUMBER OF TRACKS/DISK
SECTS	EQU	58	;TOTAL NUMBER OF SECTORS/TRACK
DBASE	EQU	2	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK NUMBER FOR DATA
MAXB	EQU	256	;MAXIMUM NUMBER OF BLOCKS (including directory)
BLOCK	EQU	16	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	TRUE	;TRUE IF 2k GROUP SIZE
	ENDIF		;DIGDBL
;
	IF	IMDOS
SYSTEM	EQU	FALSE	;TRUE IF CHECK SYSTEM TRACKS WANTED
TRACKS	EQU	77	;TOTAL NUMBER OF TRACKS/DISK
SECTS	EQU	58	;TOTAL NUMBER OF SECTORS/TRACK
DBASE	EQU	2	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK NUMBER FOR DATA
MAXB	EQU	271	;MAX NUMBER OF BLOCKS (including directory)
BLOCK	EQU	16	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	TRUE	;TRUE IF 2k GROUP SIZE
	ENDIF		;IMDOS
;
	IF	DJ256S OR NM256 AND NOT SIDES2
SYSTEM	EQU	FALSE	;FALSE IF CHECK SYSTEM TRACKS NOT WANTED
TRACKS	EQU	77	;TOTAL NUMBER OF TRACKS/DISK
SECTS	EQU	52	;TOTAL NUMBER OF SECTORS/TRACK
DBASE	EQU	2	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK NUMBER FOR DATA
MAXB	EQU	243	;MAXIMUM NUMBER OF BLOCKS (including directory)
BLOCK	EQU	16	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	TRUE	;TRUE IF 2k GROUP SIZE
	ENDIF		;MORROW DJ256S OR NM256
;
	IF	DJ512S OR NM512 AND NOT SIDES2
SYSTEM	EQU	FALSE	;FALSE IF CHECK SYSTEM TRACKS NOT WANTED
TRACKS	EQU	77	;TOTAL NUMBER OF TRACKS/DISK
SECTS	EQU	60	;TOTAL NUMBER OF SECTORS/TRACK
DBASE	EQU	2	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK NUMBER FOR DATA
MAXB	EQU	281	;MAXIMUM NUMBER OF BLOCKS (including directory)
BLOCK	EQU	16	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	TRUE	;TRUE IF 2k GROUP SIZE
	ENDIF		;MORROW DJ512S OR NM512
;
	IF	DJ1024
SYSTEM	EQU	FALSE	;FALSE IF CHECK SYSTEM TRACKS NOT WANTED
TRACKS	EQU	77	;TOTAL NUMBER OF TRACKS/DISK
SECTS	EQU	64	;TOTAL NUMBER OF SECTORS/TRACK
DBASE	EQU	2	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK NUMBER FOR DATA
MAXB	EQU	300	;MAXIMUM NUMBER OF BLOCKS (including directory)
BLOCK	EQU	16	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	TRUE	;TRUE IF 2k GROUP SIZE
	ENDIF		;MORROW DJ1024
;
	IF	NM256 AND SIDES2
SYSTEM	EQU	FALSE	;FALSE IF CHECK SYSTEM TRACKS NOT WANTED
TRACKS	EQU	77 * 2	;TOTAL NUMBER OF TRACKS/DISK
SECTS	EQU	52	;TOTAL NUMBER OF SECTORS/TRACK
DBASE	EQU	2	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK NUMBER FOR DATA
MAXB	EQU	487	;MAXIMUM NUMBER OF BLOCKS (including directory)
BLOCK	EQU	16	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	TRUE	;TRUE IF 2k GROUP SIZE
	ENDIF		;MORROW DJ256S OR NM256
;
	IF	NM512 AND SIDES2
SYSTEM	EQU	FALSE	;FALSE IF CHECK SYSTEM TRACKS NOT WANTED
TRACKS	EQU	77 * 2	;TOTAL NUMBER OF TRACKS/DISK
SECTS	EQU	60	;TOTAL NUMBER OF SECTORS/TRACK
DBASE	EQU	2	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK NUMBER FOR DATA
MAXB	EQU	281 * 2	;MAXIMUM NUMBER OF BLOCKS (including directory)
BLOCK	EQU	16	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	TRUE	;TRUE IF 2k GROUP SIZE
	ENDIF		;MORROW DJ512S OR NM512
;
	IF	H17
SYSTEM	EQU	TRUE	;FALSE IF CHECK SYSTEM TRACKS NOT WANTED
TRACKS	EQU	40	;NUMBER OF TRACKS/DISK
SECTS	EQU	20	;NUMBER OF SECTS/TRACK
DBASE	EQU	3	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	1	;FIRST BLOCK NUMBER FOR DATA
MAXB	EQU	92	;MAXIMUM NUMBER OF BLOCKS (including directory)
BLOCK	EQU	8	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	FALSE	;TRUE IF 2k GROUP SIZE
	ENDIF		;H17
;
	IF	ICOM
SYSTEM	EQU	TRUE	;FALSE IF CHECK SYSTEM TRACKS NOT WANTED
TRACKS	EQU	35	;NUMBER OF TRACKS/DISK
SECTS	EQU	18	;NUMBER OF SECTS/TRACK
DBASE	EQU	3	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK NUMBER FOR DATA  
MAXB	EQU	72	;MAXIMUM NUMBER OF BLOCKS (including directory)
BLOCK	EQU	8	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	FALSE	;TRUE IF 2k GROUP SIZE
	ENDIF		;ICOM
;
	IF	JADEDD
SYSTEM	EQU	FALSE	;FALSE IF CHECK SYSTEM TRACKS NOT WANTED
TRACKS	EQU	77	;NUMBER OF TRACKS/DISK
SECTS	EQU	50	;NUMBER OF SECTORS/TRACK
DBASE	EQU	2	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK NUMBER FOR DATA
MAXB	EQU	233	;MAXIMUM NUMBER OF BLOCKS (including directory)
BLOCK	EQU	16	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	TRUE	;TRUE IF 2k GROUP SIZE
	ENDIF		;JADEDD
;
	IF	HORIZON AND NOT SIDES2
SYSTEM	EQU	TRUE	;TRUE IF CHECK SYSTEM TRACKS WANTED
TRACKS	EQU	35	;TOTAL NUMBER OF TRACKS/DISK
SECTS	EQU	40	;TOTAL NUMBER OF SECTORS/TRACK
DBASE	EQU	2	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK NUMBER FOR DATA
MAXB	EQU	165	;MAX NUMBER OF BLOCKS (including directory)
BLOCK	EQU	8	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	FALSE	;TRUE IF 2k GROUP SIZE
	ENDIF		;HORIZON
;
	IF	HORIZON AND SIDES2
SYSTEM	EQU	TRUE	;TRUE IF CHECK SYSTEM TRACKS WANTED
TRACKS	EQU	70	;TOTAL NUMBER OF TRACKS/DISK
SECTS	EQU	40	;TOTAL NUMBER OF SECTORS/TRACK
DBASE	EQU	2	;DIRECTORY & DATA AREA STARTING TRACK NUMBER
BBASE	EQU	2	;FIRST BLOCK NUMBER FOR DATA
MAXB	EQU	170	;MAX NUMBER OF BLOCKS (including directory)
BLOCK	EQU	16	;NUMBER OF SECTORS/BLOCK
DGROUP	EQU	TRUE	;TRUE IF 2k GROUP SIZE
	ENDIF		;HORIZON
;
;Define ASCII characters used
;
CR	EQU	0DH	;CARRIAGE RETURN CHARACTER
LF	EQU	0AH	;LINE FEED CHARACTER
TAB	EQU	09H	;TAB CHARACTER
;
;
	ORG	BASE+100H
;
START:	LXI	SP,NEWSTK ;MAKE NEW STACK
;
	IF	IMDOS
	XRA	A
	OUT	0FFH	;CLEAR FRONT PANEL
	ENDIF		;IMDOS
;
	LXI	D,IDMSG	;IDENT MESSAGE
	CALL	START2	;GO PRINT IT
;
IDMSG:	DB	CR,LF,'FINDBAD - ver 4.2'
	DB	CR,LF,'Bad sector lockout '
	DB	'program',CR,LF
;
	IF	STDDRV
	DB	'For single-density 8"'
	ENDIF
;
	IF	MICROP
	DB	'For Micropolis Mod II'
	ENDIF
;
	IF	MMDBL
	DB	'For Micromation double-density'
	ENDIF
;
	IF	DIGDBL
	DB	'For Digital Microsystems',CR,LF
	DB	'FDC3 cntlr dbl dens'
	ENDIF
;
	IF	IMDOS
	DB	'For IMSAI IMDOS double-density'
	ENDIF
;
	IF	DJ256S
	DB	'For Discus 2-dens./1-side/256-byte sectors'
	ENDIF
;
	IF	DJ512S
	DB	'For Discus 2-dens./1-side/512-byte sectors'
	ENDIF
;
	IF	DJ1024
	DB	'For Discus 2-dens./1-side/1024-byte sectors'
	ENDIF
;
	IF	NM256 OR NM512
	DB	'For National Multiplex double density'
	ENDIF
;
	IF	HORIZON
	DB	'For North Star Horizon - 5.25" drives, double density,'
	ENDIF
;
	IF	SIDES2 AND (NM256 OR NM512 OR HORIZON)
	DB	' double sided'
	ENDIF
;
	IF	NOT SIDES2 AND (NM256 OR NM512 OR HORIZON)
	DB	' single sided'
	ENDIF
;	
	IF	NM256
	DB	' 256-byte sectors'
	ENDIF
;
	IF	NM512
	DB	' 512-byte sectors'
	ENDIF
;
	IF	H17
	DB	'For Heath H-17 5.25" drives'
	ENDIF
;
	IF	ICOM
	DB	'For ICOM Microfloppy'
	ENDIF
;
	IF	JADEDD
	DB	'For Jade Double Density/Single Sided'
	ENDIF
;
	DB	' only.',CR,LF,'$'
;
START2	POP	D	;GET MSG ADRS
	MVI	C,9	;BDOS PRINT BUFFER FUNCTION
	CALL	BDOS	;PRINT SIGN-ON MSG
	CALL	IBIOS	;SET BIOS ENTRY, AND CHECK DRIVE
	CALL	FINDB	;ESTABLISH ALL BAD BLOCKS
	JZ	NOBAD	;SAY NO BAD BLOCKS, IF SO
	CALL	OPENB	;OPEN [UNUSED].BAD ALLOCATION
	CALL	SETDM	;FIX DM BYTES IN FCB
	CALL	CLOSEB	;CLOSE [UNUSED].BAD
	CALL	SETNUM	;PUT NUMBER OF BAD BLOCKS IN MESSAGE
;
NOBAD:	LXI	D,ENDMSG ;SAY HOW MANY BAD BLOCKS
;
PMSG:	MVI	C,9	;BDOS PRINT BUFFER FUNCTION
	CALL	BDOS
;
	IF	TEST
	MVI	A,TAB	;GET A TAB
	CALL	TYPE	;PRINT IT
	LHLD	SECCNT	;GET NUMBER OF SECTORS READ
	CALL	DECOUT	;PRINT IT
	LXI	D,SECMSG ;POINT TO MESSAGE
	MVI	C,9	;BDOS PRINT BUFFER FUNCTION
	CALL	BDOS	;PRINT IT
	ENDIF		;TEST
;
	IF	IMDOS
	XRA	A
	OUT	0FFH	;CLEAR FRONT PANEL
	ENDIF		;IMDOS
;
	JMP	BASE	;EXIT TO CP/M WARM BOOT
;
;Get actual address of BIOS routines
;
IBIOS:	LHLD	BASE+1	;GET BASE ADDRESS OF BIOS VECTORS
;
;WARNING...Program modification takes place here...do not change.
;
	LXI	D,27	 ;OFFSET TO "SETTRK"
	DAD	D
	SHLD	SETTRK+1 ;FIX OUR CALL ADDRESS
	LXI	D,3	 ;OFFSET TO "SETSEC"
	DAD	D
	SHLD	SETSEC+1 ;FIX OUR CALL ADDRESS
	LXI	D,6	 ;OFFSET TO "DREAD"
	DAD	D
	SHLD	DREAD+1	 ;FIX OUR CALL ADDRESS
;
;Check for drive specification
;
	LDA	FCB	;GET DRIVE NAME
	ORA	A	;ZERO?
	RZ		;YES, NO DRIVE CHANGE REQUIRED
	CPI	4+1	;CHECK FOR HIGHEST DRIVE NUMBER
	JNC	ERROR4
	DCR	A	;BACK OFF FOR CP/M
	MOV	E,A	;MAKE DISK NUMBER
	MVI	C,14	;BDOS SELECT DISK FUNCTION
	CALL	BDOS
	RET		;RETURN FROM "IBIOS"
;
;Look for bad blocks
;
FINDB:	EQU	$
;
	IF	SYSTEM
	CALL	CHKSYS	;CHECK FOR BAD BLOCKS ON TRACK 0 AND 1
	ENDIF		;SYSTEM
;
	CALL	CHKDIR	;CHECK FOR BAD BLOCKS IN DIRECTORY
	CALL	ERAB	;ERASE ANY [UNUSED].BAD FILE
	LXI	B,BBASE	;START AT FIRST DATA BLOCK
;
FINDBA:	CALL	READB	;READ THE BLOCK
	CNZ	SETBD	;IF BAD, ADD BLOCK TO LIST
	INX	B	;BUMP TO NEXT BLOCK
	MOV	A,C	;SEE IF MORE TO CHECK
	CPI	MAXB AND 0FFH
	JNZ	FINDBA
	MOV	A,B	;THEN CHECK HI BYTE
	CPI	MAXB SHR 8
	JNZ	FINDBA	;LOOP TILL DONE	
	LHLD	DMCNT	;GET NUMBER OF BAD SECTORS
	MOV	A,H
	ORA	L	;SET ZERO FLAG, IF NO BAD BLOCKS
	RET		;RETURN FROM "FINDB"
;
	IF	SYSTEM
;
;Check system tracks, notify user if bad, but continue
;
CHKSYS:	LXI	H,1	;SET TRACK 0, SECTOR 1
;
CHKSY1:	CALL	READS	;READ A SECTOR
	JNZ	SYSERR	;NOTIFY, IF BAD BLOCKS HERE
	MOV	A,H	;BOTH SYSTEM TRACKS DONE?
	CPI	DBASE
	JC	CHKSY1
	RET		;RETURN FROM "CHKSYS"
;
SYSERR:	LXI	D,ERMSG5 ;SAY NO GO, AND BAIL OUT
	MVI	C,9	;BDOS PRINT BUFFER FUNCTION
	CALL	BDOS
	RET		;RETURN FROM "SYSERR"
;
	ENDIF		;SYSTEM
;
;Check for bad blocks in directory area
;
CHKDIR:	LXI	B,0	;START AT BLOCK 0
;
CHKDI1:	CALL	READB	;READ A BLOCK
	JNZ	ERROR6	;IF BAD, INDICATE ERROR IN DIRECTORY AREA
	INX	B	;BUMP FOR NEXT BLOCK
	MOV	A,C	;GET BLOCK NUMBER
	CPI	BBASE	;ALL DONE CHECKING DIRECTORY AREA?
	JC	CHKDI1	;PRESS ON, IF NOT
	RET		;RETURN FROM "CHKDIR"
;
;Read all sectors in block, and return zero flag set if none bad
;
READB:	CALL	CNVRTB	;CONVERT TO TRACK/SECTOR IN H&L REGS.
	MVI	D,BLOCK	;NUMBER OF SECTORS/BLOCK
;
READBA:	PUSH	D
	CALL	READS	;READ SKEWED SECTOR
	POP	D
	RNZ		;ERROR IF NOT ZERO...
	DCR	D	;DEBUMP SECTOR/BLOCK
	JNZ	READBA	;DO NEXT, IF NOT FINISHED
	RET		;RETURN FROM "READBA"
;
;Convert block number to track and skewed sector number
;
CNVRTB:	PUSH	B	;SAVE BLOCK NUMBER
	MOV	L,C	;BLOCK NUMBER TO H&L REGS.
	MOV	H,B
	DAD	H	;*2
	DAD	H	;*4
	DAD	H	;*8
;
	IF	DGROUP
	DAD	H	;*16 FOR 2k GROUP SIZE
	ENDIF		;DGROUP
;
	LXI	D,DBASE*256	;MAKE BASE TRACK NUMBER
	LXI	B,-SECTS	;DIVIDE BY SECTORS/TRACK
;
CNVRTC:	MOV	A,H	;OVER SECTORS...
	ORA	A
	JNZ	CNVRTT	;...BYE GROUPS?
	MOV	A,L	;OVER SECTORS...
	CPI	SECTS
	JC	CNVRTS	;...AND DOWN TO TRACKS?
;
CNVRTT:	DAD	B	;TAKE AWAY SECTORS
	INR	D	;+1 TO TRACK NUMBER
	JMP	CNVRTC	;...AND GO BACK FOR MORE
;
CNVRTS:	MOV	E,L	;RESIDUAL = SKEWED SECTOR-1
	INR	E	;BUMP FOR SECTORS 1 TO 32
	XCHG		;TRACK/SECTOR IN H&L REGS.
	POP	B	;RECOVER BLOCK NUMBER
	RET		;RETURN FROM "CNVRTB"
;
;Reads a logical sector (if it can), and returns zero flag set if no error
;
READS:	PUSH	B	;EXILE BLOCK
	PUSH	H	;...AND TRACK/SECTOR
	CALL	LTOP	;CONVERT LOGICAL TO PHYSICAL SECTOR
	PUSH	H	;SAVE SECTOR NUMBER
	MOV	C,H	;TRACK NUMBER IN H REG...
;
SETTRK:	CALL	$-$	;BIOS SET TRACK (MODIFIED BY IBIOS)
	POP	B	;PUT SECTOR IN C
;
SETSEC:	CALL	$-$	;BIOS SET SECTOR (MODIFIED BY IBIOS)
;
DREAD:	CALL	$-$	;BIOS READ SECTOR (MODIFIED BY IBIOS)
	ORA	A	;SET FLAGS FOR POSSIBLE BAD SECTOR
;
	IF	TEST
	LHLD	SECCNT	;GET NUMBER OF SECTORS READ
	INX	H	;INCREMENT
	SHLD	SECCNT	;SAVE NEW NUMBER
	ENDIF		;TEST
;
	POP	H
	POP	B	;BACK FROM EXILE...
	PUSH	PSW	;SAVE FLAGS
	INR	L	;BUMP FOR NEXT SECTOR
	MOV	A,L
	CPI	SECTS+1	;TRACK OVERFLOW?
	JC	READSR
	MVI	L,1	;YUP, RESET SECTOR NUMBER TO 1...
	INR	H	;...AND BUMP TRACK NUMBER
;
READSR:	POP	PSW	;GET FLAGS, TO CHECK IF ERROR ON RETURN
	RET		;RETURN FROM "READS"
;
;Convert logical to physical sector
;
LTOP:	XCHG
	LXI	B,LPMAP-1 ;GET BASE OF LOGICAL TO PHYSICAL MAPPING
	MOV	L,E
	MVI	H,0	;LOGICAL SECTOR OFFSET
	DAD	B	;+ BIAS
	MOV	E,M	;GET PHYSICAL SECTOR
	XCHG		;PUT H&L REGS. BACK...
	RET		;RETURN FROM "LTOP"
;
;Logical to physical mapping vectors (sector skew table)
;
	IF	STDDRV
LPMAP:	DB	01,07,13,19,25,05,11,17,23,03,09,15,21
	DB	02,08,14,20,26,06,12,18,24,04,10,16,22
	ENDIF		;STDDRV
;
	IF	MICROP
LPMAP:	DB	01,02,11,12,21,22,31,32,09,10,19,20,29,30,07,08
	DB	17,18,27,28,05,06,15,16,25,26,03,04,13,14,23,24
	ENDIF		;MICROP
;
	IF	MMDBL
LPMAP:	DB	01,14,27,40,10,23,36,49,06,19,32,45,02,15,28,41
	DB	11,24,37,50,07,20,33,46,03,16,29,42,12,25,38,51
	DB	08,21,34,47,04,17,30,43,13,26,39,52,09,22,35,48
	DB	05,18,31,44
	ENDIF		;MMDBL
;
	IF	DIGDBL
LPMAP:	DB	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16
	DB	17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32
	DB	33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48
	DB	49,50,51,52,53,54,55,56,57,58
	ENDIF		;DIGDBL
;
	IF	IMDOS
LPMAP:	DB	1,8,15,22,29,36,43,50,57,6,13,20,27,34,41,48,55
	DB	4,11,18,25,32,39,46,53,2,9,16,23,30,37,44,51,58
	DB	7,14,21,28,35,42,49,56,5,12,19,26,33,40,47,54
	DB	3,10,17,24,31,38,45,52
	ENDIF		;IMDOS
;
	IF	DJ256S
LPMAP:	DB	01,02,19,20,37,38,03,04,21,22,39,40,05,06,23,24
	DB	41,42,07,08,25,26,43,44,09,10,27,28,45,46,11,12
	DB	29,30,47,48,13,14,31,32,49,50,15,16,33,34,51,52
	DB	17,18,35,36
	ENDIF		;DJ256S
;
	IF	NM256
LPMAP:	DB	01,02,23,24,45,46,15,16,37,38,07,08,29,30,51,52
	DB	21,22,43,44,13,14,35,36,05,06,27,28,49,50,19,20
	DB	41,42,11,12,33,34,03,04,25,26,47,48,17,18,39,40
	DB	09,10,31,32
	ENDIF		;NM256
;
	IF	DJ512S OR NM512
LPMAP:	DB	01,02,03,04,17,18,19,20,33,34,35,36,49,50,51,52
	DB	05,06,07,08,21,22,23,24,37,38,39,40,53,54,55,56
	DB	09,10,11,12,25,26,27,28,41,42,43,44,57,58,59,60
	DB	13,14,15,16,29,30,31,32,45,46,47,48
	ENDIF		;DJ512S or NM512
;
	IF	DJ1024
LPMAP:	DB	01,02,03,04,05,06,07,08,25,26,27,28,29,30,31,32
	DB	49,50,51,52,53,54,55,56,09,10,11,12,13,14,15,16
	DB	33,34,35,36,37,38,39,40,57,58,59,60,61,62,63,64
	DB	17,18,19,20,21,22,23,24,41,42,43,44,45,46,47,48
	ENDIF		;DJ1024
;
	IF	H17
LPMAP:	DB	01,02,09,10,17,18,05,06,13,14,03,04,11,12,19,20
	DB	07,08,15,16
	ENDIF		;H17
;
	IF	ICOM
LPMAP:	DB	01,05,09,13,17,04,08,12,16,03,07,11,15,02,06,10
	DB	14,18
	ENDIF		;ICOM
;
	IF	JADEDD
LPMAP:	DB	01,11,21,31,41,02,12,22,32,42,03,13,23,33,43
	DB	04,14,24,34,44,05,15,25,35,45,06,16,26,36,46
	DB	07,17,27,37,47,08,18,28,38,48,09,19,29,39,49
	DB	10,20,30,40,50
	ENDIF		;JADEDD
;
	IF	HORIZON
LPMAP:	DB	01,02,03,04,21,22,23,24
	DB	05,06,07,08,25,26,27,28
	DB	09,10,11,12,29,30,31,32
	DB	13,14,15,16,33,34,35,36
	DB	17,18,19,20,37,38,39,40
	ENDIF		;HORIZON	
;
;Put bad block in bad block list
;
SETBD:	LHLD	DMCNT	;GET NUMBER OF SECTORS
	LXI	D,BLOCK
	DAD	D	;BUMP BY NUMBER IN THIS BLOCK
	SHLD	DMCNT	;UPDATE NUMBER OF SECTORS
	LHLD	DMPTR	;GET POINTER INTO DM
	MOV	M,C	;...AND PUT BAD BLOCK NUMBER
	INX	H	;BUMP TO NEXT AVAILABLE EXTENT
;
	IF	IMDOS OR DJ512S OR DJ1024 OR NM256 OR NM512
	MOV	M,B	;PUT IN 2ND BYTE FOR IMDOS OR DJ512/1024
	INX	H	;POINT TO NEXT AVAILABLE EXTENT
	ENDIF		;IMDOS OR DJ512S OR DJ1024 OR NM256 OR NM512
;
	SHLD	DMPTR	;SAVE DM POINTER, FOR NEXT TIME THROUGH HERE
	RET		;RETURN FROM "SETBD"
;
;Eliminate any previous [UNUSED].BAD entries
;
ERAB:	LXI	D,BFCB	;POINT TO BAD FCB
	MVI	C,19	;BDOS DELETE FILE FUNCTION
	CALL	BDOS
	RET
;
;Create [UNUSED].BAD file entry
;
OPENB:	LXI	D,BFCB	;POINT TO BAD FCB
	PUSH	D	;SAVE IT...
	MVI	C,22	;BDOS MAKE FILE FUNCTION
	CALL	BDOS
	POP	D	;RECOVER BAD FCB POINTER
	MVI	C,15	;BDOS OPEN FILE FUNCTION
	CALL	BDOS
	CPI	0FFH	;CHECK FOR OPEN ERROR
	RNZ		;RETURN FROM "OPENB", IF NO ERROR
	JMP	ERROR7	;BAIL OUT...CAN'T CREATE [UNUSED].BAD
;
;Move bad area DM to BFCB
;
SETDM:	LXI	H,DM	;GET DM
	SHLD	DMPTR	;SAVE AS NEW POINTER
	LHLD	DMCNT	;GET THE COUNT
;
SETDM0:	MOV	A,H
	ORA	A
	JNZ	GOBIG
	MOV	A,L
	CPI	129	;ALL BYTES MOVED?
	JC	SETDME
;
GOBIG:	LXI	D,-128
	DAD	D
	PUSH	H
	MVI	A,128
	CALL	SETDME
	XCHG
	SHLD	DMPTR
	CALL	CLOSEB	;CLOSE OLD EXTENT
	LDA	EXTNUM	;GET OLD EXTENT NUMBER
	INR	A	;INCREMENT IT
	STA	EXTNUM	;SAVE NEW EXTENT NUMBER
	STA	BFCB+12	;PUT NEW EXTENT NUMBER INTO OUR FCB
	CALL	OPENB	;OPEN NEW EXTENT
	POP	H
	JMP	SETDM0
;
SETDME:	STA	BFCB+15	;PUT RC IN PLACE
	IF	NOT DGROUP
	MVI	B,16	;NUMBER OF BYTES TO MOVE
	ENDIF		;NOT DGROUP
;
	IF	DGROUP
	MVI	B,8	;NUMBER OF BYTES TO MOVE
	ENDIF		;DGROUP
;
	LHLD	DMPTR	;GET BAD DMAP POINTER
	XCHG		;TO DE
	LXI	H,BFCB+16 ;POINT AT OUR FCB
;
SETDML:	EQU	$
;
	IF	NOT IMDOS
	LDAX	D	;GET BYTE FROM DMAP
	MOV	M,A	;MOVE TO OUR FCB
	INX	D	;INCREMENT DMAP POINTER
	INX	H	;INCREMENT OUR FCB POINTER
	ENDIF		;NOT IMDOS (1 BYTE GROUP #)
;
	IF	DJ512S OR DJ1024 OR NM256 OR NM512
	LDAX	D	;GET SECOND BYTE FROM DMAP
	MOV	M,A	;MOVE TO OUR FCB
	INX	D	;INCREMENT DMAP POINTER
	INX	H	;INCREMENT OUR FCB POINTER
	ENDIF		;DJ512S OR DJ1024 OR NMXXXDS (2 BYTE GROUP #)
;
	IF	IMDOS
	LDAX	D	;GET FIRST (LO ORDER) BYTE FROM DMAP
	MOV	C,A	;SAVE IT IN C
	INX	D	;INCREMENT DMAP POINTER
	LDAX 	D	;THEN GET SECOND (HI ORDER) BYTE
	MOV	M,A	;STORE HI BYTE FIRST
	INX	H	;INCREMENT FCB POINTER
	MOV	M,C	;THEN LO BYTE FOR 16-BIT POINTER
	INX	H	;INCREMENT OUR FCB POINTER
	ENDIF		;IMDOS (2 BYTE GROUP #)
;
	DCR	B	;ONE LESS BYTE TO MOVE
	JNZ	SETDML	;NOT DONE, GO MOVE MORE
	RET		;ELSE RETURN FROM "SETDM"

;
CLOSEB:	XRA	A
	LDA	BFCB+14	;GET CP/M 2.x 'S2' BYTE
	ANI	1FH	;ZERO UPDATE FLAGS
	STA	BFCB+14	;RESTORE IT TO OUR FCB (WON'T HURT 1.4)
	LXI	D,BFCB	;FCB FOR [UNUSED].BAD
	MVI	C,16	;BDOS CLOSE FILE FUNCTION
	CALL	BDOS
	RET		;RETURN FROM "CLOSEB"
;
;Convert number of blocks to decimal ASCII, for printing
;
SETNUM:	LHLD	DMCNT	;GET NUMBER OF SECTORS
	DAD	H	;*2
	DAD	H	;*4
	DAD	H	;*8
	DAD	H	;*16
;
	IF	NOT DGROUP
	DAD	H	;*32 FOR 1k GROUP SIZE
	ENDIF
;
;H reg now equals number of blocks
	LXI	D,255
	DAD	D	;ROUND UP
	MOV	L,H
	MVI	H,0	;NOW HL=NUMBER OF BLOCKS
	LXI	D,NUMBAD
	CALL	DCNV
	RET		;RETURN FROM "SETNUM"
;
DCNV:	MVI	B,' '	;SET FOR PLUS
	MOV	A,H
	ORA	A
	JP	H3
	MVI	B,'-'
	MOV	A,L
	CMA
	INR	A
	MOV	L,A
	MOV	A,H
	CMA
	JNZ	H2
	INR	A
;
H2:	MOV	H,A
;
H3:	SHLD	DCNVHL
	MVI	A,' '
	STAX	D
	MOV	A,B
	STA	DCNVPM
	XCHG
	SHLD	DCNVAD
	XRA	A
	STA	DCNVFL
	LXI	B,-10000
	CALL	DFL8
	CALL	DSTC
	LXI	B,-1000
	CALL	DFL8
	CALL	DSTC
	LXI	B,-100
	CALL	DFL8
	CALL	DSTC
	LXI	B,-10
	CALL	DFL8
	CALL	DSTC
	LDA	DCNVHL
	ORI	'0'
	MOV	E,A
;
DSTC:	LHLD	DCNVAD
	LDA	DCNVFL
	ORA	A
	JNZ	DSTC3
;
DSTC1:	ADD	E
	STA	DCNVFL
	JNZ	DSTC2
	MVI	A,' '
	JMP	DSTC4
;
DSTC2:	LDA	DCNVPM
	MOV	M,A
;
DSTC3:	MVI	A,'0'
	ORA	E
;
DSTC4:	INX	H
	MOV	M,A
	SHLD	DCNVAD
	RET		;RETURN FROM "SETDM"
;
DCNVFL:	DB	0
DCNVHL:	DW	0
DCNVAD:	DW	0
DCNVPM:	DB	0
;
DFL8:	LHLD	DCNVHL
	MVI	E,0
;
DF1:	DAD	B
	MOV	A,H
	ORA	A
	RM
	INR	E
	SHLD	DCNVHL
	JMP	DF1
;
BFCB:	DB	0,'[UNUSED]BAD',0,0,0,0
	DS	17
;
ENDMSG:	DB	CR,LF,'	'
;
NUMBAD:	DB	'    No'
	DB	' bad blocks found',CR,LF,'$'
;
EXTNUM:	DB	0	;USED IF MORE THAN 16 BAD BLOCKS
DMCNT:	DW	0	;NUMBER OF BAD SECTORS
DMPTR:	DW	DM	;POINTER TO NEXT BLOCK ID
;
;Allocation map for bad blocks
;
DM:	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;
;Error messages
;
ERROR4:	LXI	D,ERMSG4 ;SAY NO GO, AND BAIL OUT
	JMP	PMSG
;
ERMSG4:	DB	CR,LF,'Only drives A to D allowed$'
;
	IF	SYSTEM
ERMSG5:	DB	CR,LF,'Warning...System tracks bad$'
	ENDIF		;SYSTEM
;
ERROR6:	LXI	D,ERMSG6 ;OOPS...CLOBBERED DIRECTORY
	JMP	PMSG
;
ERMSG6:	DB	CR,LF,'Bad directory area, try reformatting$'
;
ERROR7:	LXI	D,ERMSG7 ;SAY NO GO, AND BAIL OUT
	JMP	PMSG
;
ERMSG7:	DB	CR,LF,'Can''t create [UNUSED].BAD$'
;
	IF	TEST
;
;Decimal output routine
;
DECOUT:	PUSH	B
	PUSH	D
	PUSH	H
	LXI	B,-10
	LXI	D,-1
;
DECOU2:	DAD	B
	INX	D
	JC	DECOU2
	LXI	B,10
	DAD	B
	XCHG
	MOV	A,H
	ORA	L
	CNZ	DECOUT
	MOV	A,E
	ADI	'0'
	CALL	TYPE
	POP	H
	POP	D
	POP	B
	RET
;
TYPE:	PUSH	B
	PUSH	D
	PUSH	H
	MOV	E,A	;CHARACTER TO E FOR CP/M
	MVI	C,2	;PRINT CONSOLE FUNCTION
	CALL	BDOS	;PRINT CHARACTER
	POP	H
	POP	D
	POP	B
	RET
;
SECMSG:	DB	' total sectors read',CR,LF,'$'
;
SECCNT:	DW	0	;NUMBER OF SECTORS READ
;
	ENDIF		;TEST
;
	DS	64	;ROOM FOR 32 LEVEL STACK
NEWSTK	EQU	$	;OUR STACK
;
	END
