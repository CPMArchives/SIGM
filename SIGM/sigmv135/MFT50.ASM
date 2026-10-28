;******************************************************
;*						      *
;*	      MFT - Multiple File Transfer	      *
;*	       (for single drive systems)	      *
;*						      *
;*    Based on an article in Dr. Dobbs Journal of     *
;*	Computer Calisthenics & Orthodontia #49,      *
;*	      Box E, Menlo Park, Ca. 94025	      *
;*						      *
;*  Vers 5.0 - 2/10/83 by William King (Time-11:32pm) *
;*	       - Modified the main title (pretty).    *
;*	       - Converted all code to Z-80 so it     *
;*	       could be assembled with "EXASM.COM".   *
;*	       - Optimised code for Z-80 (ie use      *
;*	       LDIR,JR and DJNZ).		      *
;*	       - Added check on CP/M version No.      *
;*	       - Using direct console I/O and using   *
;*	       function No.30 (change file attributes)*
;*	       - Close after a read file bug fixed.   *
;*	       - Error check on opening a previous    *
;*	       output file added.		      *
;*	   *** - User response routine added so when  *
;*	       a file exists on the output disk, you  *
;*	       may either erase it or leave it (this  *
;*	       routine includes erasure of R/O files) *
;*	       - MOVE routine deleted.		      *
;*	       - Fixed bug encounted when trying to   *
;*	       copy r/o files (you couldn't!),by      *
;*	       doing AND 07FH on ALL characters put   *
;*	       into the filename table !!	      *
;*	       - Fixed filename printing stuff.	      *
;*	       - Spread out messages for readability. *
;*	       - Changed size of filename table from  *
;*	       64 entries to 128 entries, so large    *
;*	       disk directories can be copied.	      *
;*	       - Added explanation of how each entry  *
;*	       in the filename table is constructed.  *
;*						      *
;*	 (***) = main bulk of code added.	      *
;*						      *
;*  Vers 4.5 - 10/29/80 - Deleted system disk request *
;*	       of V4.0 to shorten messages, minor     *
;*	       changes in abort options and other     *
;*	       messages. Moved disk reset of V4.1 to  *
;*	       point before directory search. (CHS)   *
;*						      *
;*  Vers 4.4 - 10/28/80 - Modified to bail out with   *
;*	       message if no FCB is specified.	      *
;*	       Updates rearranged with most recent    *
;*	       first for reader convenience.	      *
;*	       (Charles H. Strom)		      *
;*						      *
;*  VERS 4.3 - BY LEWIS MOSELEY, JR.  3/22/80	      *
;*	       FIXED BUG WHICH SHOWED UP WHEN MULTIPLE*
;*	       COPIES WERE MADE OF A MULTIPLE EXTENT  *
;*	       FILE, IN THAT CP/M OPEN THE NEXT EXTENT*
;*	       USING THE DATA AREA TO SEARCH THE      *
;*	       DIRECTORY, SCREWING UP THE DATA BLOCK  *
;*	       THAT IS THERE.			      *
;*						      *
;*  VERS 4.2 - BY LEWIS MOSELEY, JR.  2/23/80	      *
;*	       FIXED BUG THAT OCCURRED WHEN ONLY A    *
;*	       SINGLE FILE WAS SPECIFIED AND THAT     *
;*	       FILE WAS NOT FOUND : PROGRAM HUNG IN A *
;*	       LOOP.				      *
;*						      *
;*  VERS 4.1 - BY LES FREED AND LEWIS MOSELEY 2/11/80 *
;*	       ADDED DISK RESET ON DISK CHANGE TO     *
;*	       ALLOW CHANGING DENSITY BETWEEN DISKS   *
;*	       ADDED CTL-C ABORT		      *
;*						      *
;*  VERS 4.0 - BY LEWIS MOSELEY, JR.  12/79	      *
;*	       ADDED OPTION FOR MULTIPLE OUTPUT	      *
;*	       COPIES ADDED REQUEST FOR SYSTEM DISK   *
;*	       BEFORE REBOOT			      *
;*						      *
;*	       l.e. hughes    (9/1979)		      *
;*	       mycroft labs			      *
;*	       atlanta, ga			      *
;*						      *
;*  MODIFIED - FOR SOL & COMPATABLE COMPUTERS BY      *
;*	       LEWIS MOSELEY, JR. - ATLANTA,GA.	      *
;*						      *
;******************************************************


;*  EQUATES  *


VERSION EQU	5
MODLEV	EQU	0

ENTRY:	EQU	0005H	      ;bdos entry point
TFCB:	EQU	005CH	      ;system file control blk
DBUF:	EQU	0080H	      ;system disk buffer

CR:	EQU	0DH
LF:	EQU	0AH

RCFC:	EQU	01	      ;read console
WCFC:	EQU	02	      ;write console
CONSOL: EQU	06	      ;direct console i/o
VERS:	EQU	12	      ;version number function
RDFC:	EQU	13	      ;reset disk
OFFC:	EQU	15	      ;open file
CFFC:	EQU	16	      ;close file
SFFC:	EQU	17	      ;search first
SNFC:	EQU	18	      ;search next
DFFC:	EQU	19	      ;delete file
RRFC:	EQU	20	      ;read record
WRFC:	EQU	21	      ;write record
MFFC:	EQU	22	      ;make file
SAFC:	EQU	26	      ;set address

FN:	EQU	01	      ;file name offset
FT:	EQU	09	      ;file type offset
EX:	EQU	12	      ;extent number offset
NR:	EQU	32	      ;next record offset


	ORG	00100H


MFT:	LD	SP,STACK+64
	LD	HL,MSG1	      ;print 'MFT V5.0'
	CALL	WASC

	LD	C,VERS	      ;get version #
	CALL	ENTRY
	LD	A,L
	CP	020H	      ;vers >= 2.0 ?
	JR	NC,OK1-$      ;yes,then go on

	LD	HL,BADVER     ;"Sorry you need 2.0"
	CALL	WASC

OK2:	LD	HL,MSGG	      ;"type ^c"
	CALL	WASC

	CALL	RACC
	CP	3
	JR	NZ,OK2-$

	JP	00000H	      ;reboot

OK1:	XOR	A	      ;clear break flags
	LD	(IBFLG),A
	LD	(OBFLG),A
	LD	(NDFLG),A     ;CLEAR NO DUP FLAG

	LD	A,(TFCB+1)    ;If no FCB specified
	CP	' '	      ;then say so
	JR	NZ,OK-$

	LD	HL,MSGK	      ;and bail out
	CALL	WASC	      ;here
	JP	00000H

;*  calculate buffer size = fwa(BDOS) - fwa(MBUF)  *

OK:	LD	HL,(ENTRY+1)  ;hl = (entry+1) - 6
	LD	DE,-6
	ADD	HL,DE
	LD	A,L
	AND	80H	      ;hl = hl mod 128
	LD	L,A
	LD	DE,MBUF	      ;hl = hl - fwa(MBUF)
	LD	A,L
	SUB	E
	LD	L,A
	LD	A,H
	SBC	A,D
	LD	H,A
	ADD	HL,HL	      ;hl = hl / 128
	LD	L,H
	LD	A,0	      ;don't touch cf
	ADC	A,0
	LD	H,A
	DEC	HL	      ;subtract one
	LD	(SPACE),HL    ;save as buffer size
	PUSH	HL	      ;save size

	LD	HL,MSG2	      ;write 'Buffer size = '
	CALL	WASC

	POP	HL	      ;get size back
	CALL	WDWC	      ;print size of buffer

	LD	HL,MSG3	      ;write ' sectors'
	CALL	WASC

;*  ask user to mount input disk  *

MFT1:	LD	HL,MSG4	      ;"Mount input disk,"
	CALL	WASC

	CALL	RACC	      ;read response
	CP	03	      ;CTL-C ?
	JP	Z,MFTL	      ;ABORT WITH MESSAGE

	CP	CR	      ;loop if anything but CR
	JR	NZ,MFT1-$

	CALL	WEOLC	      ;echo CR,LF

	CALL	RESET	      ;adjust density

	LD	A,(IBFLG)     ;jump if ibflg set
	OR	A
	JR	NZ,MFT2A-$

;*  copy command line into cbuf	 *

	LD	HL,DBUF	      ;fwa of command line
			      ;image
	LD	DE,CBUF	      ;fwa of command buffer
	LD	B,(HL)	      ;fetch comm. line length
	INC	HL
MFT2:	LD	A,(HL)	      ;fetch next byte from cli
	INC	HL
	LD	(DE),A	      ;store in dbuf
	INC	DE
	DEC	B	      ;decrement count
	JR	NZ,MFT2-$     ;loop until zero

	XOR	A	      ;store zero byte at end
	LD	(DE),A

	LD	HL,CBUF	      ;reset cbufp
	LD	(CBUFP),HL

	CALL	CFNT	      ;create file name table

	LD	HL,FNT	      ;reset fnt pointers
	LD	(IFNTP),HL
	LD	(OFNTP),HL

MFT2A:	LD	HL,MBUF	      ;reset mbuf pointer
	LD	(MBUFP),HL

	LD	HL,(SPACE)    ;reset msize
	LD	(MSIZE),HL

	LD	A,(IBFLG)     ;jump if ibflg not set
	OR	A
	JR	Z,MFT3-$

	LD	A,(NERAS)     ;get last file not 
			      ;written flag
	OR	A
	JR	Z,MFT2B-$     ;not set the read more of
			      ;previously opened file

	XOR	A
	LD	(NERAS),A
	LD	(IBFLG),A
	LD	(OBFLG),A

	JR	MFT3-$

MFT2B:	LD	HL,IFCB	      ;copy IFCB into TFCB
	LD	DE,TFCB
	LD	BC,33
	LDIR		      ;move the stuff

	XOR	A	      ;clear ibflg
	LD	(IBFLG),A
	INC	A	      ;set obflg
	LD	(OBFLG),A

	LD	HL,(IFNTP)    ;back ifntp up 4 bytes
	LD	DE,-4
	ADD	HL,DE
	LD	(IFNTP),HL

	LD	HL,TFCB+FN    ;write filename
	CALL	WFNC
	LD	HL,MSG6	      ;write ' - '
	CALL	WASC

	LD	HL,(IFNTP)    ;DE = ifntp
	EX	DE,HL

	JR	MFT4-$	      ;continue reading
			      ;previous file

;*  parse off next name from cbuf  *

MFT3:	LD	HL,(IFNTP)    ;fetch input fnt pointer
	LD	A,(HL)	      ;jump if end of table
	CP	0FFH
	JP	Z,MFT9

	LD	(HL),1	      ;set 'file has been read'
			      ; flag
	INC	HL
	LD	DE,TFCB+FN    ;copy filename into tfcb
	LD	BC,11
	LDIR		      ;move the stuff

	LD	(IFNTP),HL    ;save input fnt pointer

	LD	HL,TFCB+FN    ;write filename
	CALL	WFNC

	LD	HL,MSG6	       ;write ' - '
	CALL	WASC

	XOR	A	      ;setup tfcb
	LD	(TFCB),A
	LD	(TFCB+EX),A
	LD	(TFCB+NR),A

	CALL	OPEN	      ;open file
	LD	HL,(IFNTP)
	EX	DE,HL

MFT4:	LD	HL,(MBUFP)
	LD	A,H	      ;copy into fnt entry
	LD	(DE),A
	INC	DE
	LD	A,L
	LD	(DE),A
	INC	DE
	EX	DE,HL	      ;save fnt pointer
	LD	(IFNTP),HL

	LD	HL,0	      ;file size (in secs.) = 0
	LD	(FSIZE),HL

;*  read next file from input disk  *

MFT6:	LD	HL,(MBUFP)
	EX	DE,HL
	CALL	SETDMA
	CALL	READ	      ;read next sector
	OR	A	      ;jump if normal transfer
	JR	Z,MFT7-$

	CP	1	      ;jump if EOF
	JR	Z,MFT8-$

	LD	HL,MSG8	      ;write 'read error - '
	CALL	WASC
	JR	MFT8-$	      ;continue as if EOF

MFT7:	LD	HL,(MBUFP)    ;mbufp = mbufp + 128
	LD	DE,128
	ADD	HL,DE
	LD	(MBUFP),HL

	LD	HL,(FSIZE)    ;fsize = fsize + 1
	INC	HL
	LD	(FSIZE),HL

	LD	HL,(MSIZE)    ;decrement msize
	DEC	HL
	LD	(MSIZE),HL

	LD	A,H	      ;loop if still positive
	OR	L
	JR	NZ,MFT6-$

	LD	HL,TFCB	      ;copy tfcb into ifcb
	LD	DE,IFCB
	LD	BC,33
	LDIR		      ;move the stuff

	LD	A,1	      ;set ibflg
	LD	(IBFLG),A

MFT8:	LD	DE,DBUF	      ;reset dma pointer
	CALL	SETDMA
			      ;deleted close file from
			      ;here (don't close after
			      ;a read !!)

	LD	HL,(FSIZE)    ;write file size
	CALL	WDWC

	LD	HL,MSG9	      ;write ' sectors read'
	CALL	WASC

;*  update fnt, loop  *

	LD	HL,(FSIZE)    ;DE = file size
	EX	DE,HL
	LD	HL,(IFNTP)    ;store file size in fnt
			      ;entry
	LD	(HL),D
	INC	HL
	LD	(HL),E
	INC	HL
	LD	(IFNTP),HL    ;save fnt pointer

	LD	A,(IBFLG)     ;loop if ibflg not set
	OR	A
	JP	Z,MFT3

;*  FLAG THAT THE MEMORY BUFFER HAS BEEN EXCEEDED,  *
;*  TELL USER THAT DUPLICATE COPIES CANNOT BE MADE  *

	LD	A,(NDFLG)     ;TOLD HIM ALREADY?
	OR	A
	JR	NZ,MFT9-$     ;JUMP IF SO

	LD	HL,MSGH	      ;IF NOT, TELL HIM
	CALL	WASC

	LD	A,1	      ;SET NDFLG THIS TIME
	LD	(NDFLG),A

;*  Ask user to mount output disk  *

MFT9:	LD	HL,MSGA	      ;"Mount output disk,"
	CALL	WASC
	CALL	RACC	      ;read response
	CP	03	      ;CTL-C?
	JP	Z,MFTL	      ;ABORT WITH MESSAGE IF SO
	CP	CR	      ;loop if anything but CR
	JR	NZ,MFT9-$

	CALL	WEOLC	      ;echo CR,LF
	CALL	RESET	      ;reset disk system, make
			      ; r/w and check density
	LD	A,(OBFLG)     ;jump if obflg not set
	OR	A
	JR	Z,MFTA-$

	LD	HL,OFCB	      ;copy ofcb into tfcb
	LD	DE,TFCB
	LD	BC,33
	LDIR		      ;move the stuff

	CALL	OPEN	      ;open previous file
	CP	255	      ;previous file present?
	JR	NZ,MFT9B-$    ;yes,then ok to go on

	LD	HL,REOPER     ;"Reopen error!!"
	CALL	WASC

MFT9A:	LD	HL,MSGG	      ;"press ^c to reboot"
	CALL	WASC

	CALL	RACC	      ;get a char
	CP	03	      ;"^C"?
	JR	NZ,MFT9A-$    ;no,then get proper ans.

	JP	00000H	      ;reboot

MFT9B:	LD	HL,(OFNTP)    ;backup output fnt
			      ; pointer 4 bytes
	LD	DE,-4
	ADD	HL,DE
	LD	(OFNTP),HL

	LD	HL,TFCB+FN    ;write file name
	CALL	WFNC
	LD	HL,MSG6	      ;write ' - '
	CALL	WASC
	JP	MFTB	      ;continue writing
			      ; previous file

;*  write next file to output disk  *

MFTA:	LD	HL,(OFNTP)
	LD	A,(HL)	      ;get file read flag
	OR	A	      ;last read in file
	JP	Z,MFTF	      ;yes,then end of write

	CP	0FFH	      ;end of filename table?
	JP	Z,MFTF	      ;yes,then go

	INC	HL
	LD	DE,TFCB+FN
	LD	BC,11
	LDIR		      ;move the stuff

	LD	(OFNTP),HL

	LD	HL,TFCB+FN    ;print "filename"
	CALL	WFNC

	LD	HL,MSG6	      ;print " - "
	CALL	WASC

	XOR	A
	LD	(TFCB),A
	LD	(TFCB+EX),A
	LD	(TFCB+NR),A

;*  Start of version 5.0 erase mods  *

	LD	DE,TFCB
	CALL	SRCHF	      ;does file already exist?
	CP	255
	JP	Z,MFTAA	      ;no,then normal write

	LD	(SAVE),A      ;save dir pointer

	LD	HL,TFCB	      ;copy tfcb into ofcb
	LD	DE,OFCB
	LD	BC,33
	LDIR		      ;move the stuff

	LD	HL,MSGL	      ;"file exists. erase?"
	CALL	WASC

LOOK:	LD	C,CONSOL      ;input char with no echo
	LD	E,0FFH
	CALL	ENTRY
	CP	'N'
	JR	Z,LOOK1-$
	CP	'Y'
	JR	NZ,LOOK-$

LOOK1:	PUSH	AF	      ;save answer
	LD	C,CONSOL      ;echo the char
	LD	E,A
	CALL	ENTRY
	CALL	WEOLC	      ;do cr-lf
	POP	AF	      ;get answer back

	CP	'Y'
	JR	Z,LOOK5-$     ;if yes then delete file

	LD	A,1
	LD	(NERAS),A     ;set last file not
			      ;written flag

	LD	HL,(OFNTP)    ;get fnt pointer
	INC	HL
	INC	HL
	INC	HL
	INC	HL	      ;point to next entry

LOOK2:	PUSH	HL	      ;save for later
	INC	HL	      ;point to next filename
	LD	DE,TFCB+FN    ;point to last filename
	LD	B,11	      ;length to test

LOOK3:	LD	A,(DE)	      ;compare the names
	CP	(HL)
	JR	NZ,LOOK4-$    ;if they are NOT the same
			      ;then go ahead and use
			      ;the name being compared

	INC	HL
	INC	DE
	DJNZ	LOOK3-$	      ;do whole name

			      ;if here then both names
			      ;are the same thus don't
			      ;use this name in fnt.
			      ;must point to next name
			      ;after this name

	POP	HL	      ;get this fnt pointer
	LD	DE,16	      ;offset
	ADD	HL,DE

	LD	A,(HL)	      ;check if this file read
	OR	A
	JP	Z,MFTF	      ;no,not read yet
	CP	0FFH	      ;end of table?
	JP	Z,MFTF	      ;yes,end of fnt reached

	JR	LOOK2-$	      ;compare next file

			      ;must keep comparing name
			      ;until : a no-match ;
			      ;or end of table or last
			      ;read file is found.

LOOK4:	POP	HL	      ;get fnt pointer back
	LD	(OFNTP),HL    ;save it for much later
	JP	MFTA	      ;do next file

LOOK5:	LD	HL,TFCB+FN    ;"filename"
	CALL	WFNC
	LD	HL,MSG6	      ;" - "
	CALL	WASC

	LD	A,(SAVE)      ;get dir pointer back
	AND	3
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL	      ;get offset into dir blk.
	LD	DE,DBUF+FT    ;point to filetype byte
			      ;in found dir entry.
	ADD	HL,DE
	LD	A,(HL)	      ;1st filetype byte
	BIT	7,A	      ;check for r/o = set
	JR	Z,LOOK7-$     ;not set,then erase ok

			      ;here if file to be
			      ;erased is r/o. Ask Q
			      ;if want erase anyway?

	LD	HL,FILERO     ;"file is r/o. Erase?"
	CALL	WASC

LOOK6:	LD	C,CONSOL      ;get char
	LD	E,0FFH
	CALL	ENTRY
	CP	'N'
	JP	Z,LOOK1	      ;don't erase it

	CP	'Y'
	JR	NZ,LOOK6-$

	LD	C,CONSOL      ;echo
	LD	E,A
	CALL	ENTRY
	CALL	WEOLC	      ;cr-lf

	LD	DE,TFCB
	LD	C,30	      ;set file attr. to r/w
	CALL	ENTRY

	LD	HL,TFCB+FN    ;"filename"
	CALL	WFNC
	LD	HL,MSG6	      ;" - "
	CALL	WASC

LOOK7:	XOR	A
	LD	(TFCB),A
	LD	(TFCB+EX),A
	LD	(TFCB+NR),A

	CALL	DELT	      ;delete existing file

;*  End of version 5.0 erase mods  *

MFTAA:	LD	HL,TFCB	      ;copy tfcb into ofcb
	LD	DE,OFCB
	LD	BC,33
	LDIR		      ;move the stuff

	CALL	MAKE
	CP	255	      ;jump if ok
	JR	NZ,MFTB-$

	LD	HL,MSGB	      ;write 'unable to create'
	CALL	WASC
	JP	MFTG

MFTB:	LD	HL,(OFNTP)
	LD	D,(HL)	      ;fetch fwa of file from
			      ; fnt
	INC	HL
	LD	E,(HL)
	INC	HL
	EX	DE,HL
	LD	(MBUFP),HL    ;save it
	EX	DE,HL
	LD	D,(HL)	      ;fetch size of file from
			      ; fnt
	INC	HL
	LD	E,(HL)
	INC	HL
	EX	DE,HL
	LD	(FSIZE),HL    ;save it
	LD	(XSIZE),HL    ;save for printout
	EX	DE,HL
	LD	(OFNTP),HL
	LD	HL,(FSIZE)    ;jump if fsize=0
	LD	A,H
	OR	L
	JR	Z,MFTDA-$

MFTC:	LD	HL,(MBUFP)    ;set dma address to mbufp
	EX	DE,HL
	CALL	SETDMA
	CALL	WRITE	      ;write next sector
	OR	A	      ;jump if ok
	JR	Z,MFTD-$

	LD	HL,MSGC	      ;"error writing file"
	CALL	WASC
	JP	MFTG

MFTD:	LD	HL,(MBUFP)    ;mbufp = mbufp + 128
	LD	DE,128
	ADD	HL,DE
	LD	(MBUFP),HL

	LD	HL,(FSIZE)    ;fsize = fsize - 1
	DEC	HL
	LD	(FSIZE),HL

	LD	A,H	      ;loop until zero
	OR	L
	JR	NZ,MFTC-$

MFTDA:	LD	HL,TFCB	      ;copy tfcb into ofcb
	LD	DE,OFCB
	LD	BC,33
	LDIR		      ;move the stuff

	LD	DE,DBUF	      ;reset dma pointer
	CALL	SETDMA
	CALL	CLOSE	      ;try to close file
	CP	255	      ;jump if ok
	JR	NZ,MFTE-$

	LD	HL,MSGD	      ;write 'unable to close'
	CALL	WASC

MFTE:	LD	HL,(XSIZE)    ;number of sectors done
	CALL	WDWC

	LD	HL,MSGE	      ;write ' sectors written'
	CALL	WASC

	XOR	A
	LD	(NERAS),A     ;clear last file not
			      ;writen flag

	JP	MFTA

MFTF:	LD	A,(IBFLG)     ;loop if ibflg set
	OR	A
	JP	NZ,MFT1


;*  Terminate program here on irrecoverable error or  *
;*  when all files have been copied.  Must reload     *
;*  system disk to avoid crash when copying to	      *
;*  someone else's disk.                              *
;*  If normal end, and if buffer has not been	      *
;*  exceeded, give user the option of making another  *
;*  copy of the same set of files.		      *


MFTG:	LD	HL,MSGF	      ;SEE IF OPTION IS ALLOWED
	LD	A,(NDFLG)
	OR	A
	JR	NZ,MFTH-$     ;JUMP IF NOT ALLOWED

	CALL	WASC	      ;ELSE TELL ABOUT OPTION

MFTH:	LD	HL,MSGG	      ;ASK FOR SYSTEM DISK
	CALL	WASC
	CALL	RACC	      ;wait for response
	CP	03H	      ;WARM BOOT IF ^C
	JP	Z,00000H

	CP	CR	      ;ATTEMPT REPEAT IF <CR>
	JR	NZ,MFTG-$     ;LOOP TILL GOOD RESPONSE

MFTJ:	CALL	WEOLC	      ;ACKNOWLEDGE COMMAND
	LD	A,(NDFLG)     ;REPEAT ALLOWED?
	OR	A
	JR	NZ,MFTK-$     ;JUMP IF NOT

	LD	HL,FNT	       ;ELSE RESET FNT POINTER
	LD	(OFNTP),HL

	LD	HL,MBUF	      ;RESET MEM BUF POINTER
	LD	(MBUFP),HL

	XOR	A	      ;RESET OUTPUT INTERRUPTED
			      ; FLAG
	LD	(OBFLG),A
	JP	MFT9	      ;AND DO AGAIN

MFTK:	LD	HL,MSGH	      ;CANNOT REPEAT, TELL HIM
	CALL	WASC
	JR	MFTG-$	      ;AND WAIT FOR SYSTEM DISK

MFTL:	LD	HL,MSGJ	      ;ABORT MESSAGE
	CALL	WASC
	JP	00000H	      ;WARM BOOT

;*  subroutines	 *

			      ;MOVE deleted from here

;*  gfn - get file name	 *

GFN:	LD	A,(HL)
	OR	A
	RET	Z

	CP	' '
	JR	NZ,GFN0-$

	INC	HL
	JR	GFN-$

GFN0:	LD	DE,XFCB
	XOR	A
	LD	(DE),A
	INC	DE
	PUSH	DE
	LD	B,11
	LD	A,' '
GFN6:	LD	(DE),A
	INC	DE
	DEC	B
	JR	NZ,GFN6-$

	POP	DE
	LD	B,9
GFN1:	LD	A,(HL)
	OR	A
	JP	Z,GFN4

	INC	HL
	CP	' '
	JP	Z,GFN4

	CP	'.'
	JR	Z,GFN2-$

	CP	'*'
	JR	Z,GFN7-$

	LD	(DE),A
	INC	DE
	DEC	B
	JP	Z,GFN5
	JR	GFN1-$

GFN7:	DEC	B
	JR	Z,GFN9-$
	LD	A,'?'
	LD	(DE),A
	INC	DE
	JR	GFN7-$

GFN9:	LD	A,(HL)
	CP	'.'
	JR	NZ,GFN4-$
	INC	HL
GFN2:	LD	DE,XFCB+FT
	LD	B,4
GFN3:	LD	A,(HL)
	OR	A
	JR	Z,GFN4-$

	INC	HL
	CP	' '
	JR	Z,GFN4-$

	CP	'*'
	JR	Z,GFN8-$
	LD	(DE),A
	INC	DE
	DEC	B
	JR	Z,GFN5-$
	JR	GFN3-$

GFN8:	DEC	B
	JR	Z,GFN4-$
	LD	A,'?'
	LD	(DE),A
	INC	DE
	JR	GFN8-$

GFN4:	XOR	A
	RET

GFN5:	SCF
	RET

;*  cfnt - create file name table  *

CFNT:	LD	HL,FNT	      ;reset ifntp
	LD	(IFNTP),HL
	LD	(HL),0FFH     ;VER 4.2 BUG FIX 
CFNT1:	LD	HL,(CBUFP)    ;get cbufp
	LD	A,(HL)	      ;exit if end of list
	OR	A
	RET	Z

	CALL	GFN	      ;get next afn
	LD	(CBUFP),HL    ;save command buffer ptr
	JR	NC,CFNT2-$    ;jump if filename ok

	LD	HL,MSG5	      ;"Syntax error in name"
	CALL	WASC
	JR	CFNT1-$	      ;loop

CFNT2:	XOR	A	      ;clear xfcb extent field
	LD	(XFCB+EX),A

	LD	DE,XFCB	      ;search for first occur.
	CALL	SRCHF
	CP	255	      ;jump if found
	JR	NZ,CFNT3-$

	LD	HL,XFCB+FN    ;write filename
	CALL	WFNC
	LD	HL,MSG7	       ;write ' not found'
	CALL	WASC
	JR	CFNT1-$	      ;loop

CFNT3:	AND	3	      ;index into cbuf
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,DBUF
	ADD	HL,DE
	EX	DE,HL	      ;copy filename into fnt
	LD	HL,(IFNTP)
	EX	DE,HL
	LD	B,12

CFNT4:	LD	A,(HL)
	AND	07FH	      ;set bit 7 to 0 !!!
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	CFNT4-$

	LD	HL,ZEROS      ;zero fill rest of entry
	LD	BC,4
	LDIR		      ;move the stuff

	EX	DE,HL
	LD	(IFNTP),HL    ;save input fnt pointer
	LD	(HL),0FFH     ;insure FF byte at end

	LD	DE,XFCB	      ;search for next occur.
	CALL	SRCHN
	CP	255	      ;jump if found
	JR	NZ,CFNT3-$

	JP	CFNT1	      ;go get next afn

;*  wasc - write ascii string to console  *

WASC:	LD	A,(HL)
	OR	A
	RET	Z

	CALL	WACC
	INC	HL
	JR	WASC-$


;*  wfnc - write file name to console		      *

;*  Note: Under SOLOS and CUTER, 01 is the cursor-    *
;*	  left character.			      *
;*	  When MFTing a multi-extent file, the extent *
;*	  character must be filtered out of the file- *
;*	  name-block to avoid wierd console output.   *

WFNC:	PUSH	BC

	LD	B,8

WFNC1:	LD	A,(HL)
	AND	07FH
	CALL	WACC
	INC	HL
	DJNZ	WFNC1-$

	LD	A,'.'
	CALL	WACC

	LD	B,3

WFNC2:	LD	A,(HL)
	AND	07FH
	CALL	WACC
	INC	HL
	DJNZ	WFNC2-$

	POP	BC
	RET

;*  weolc - write end of line to console  *

WEOLC:	PUSH	AF
	LD	A,CR
	CALL	WACC
	LD	A,LF
	CALL	WACC
	POP	AF
	RET

;*  wdwc - write decimal word to console  *

WDWC:	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	B,0	      ;clear 'digit written'
			      ; flag
	LD	DE,10000      ;write 1st digit
	CALL	WNDD
	LD	DE,1000	      ;write 2nd digit
	CALL	WNDD
	LD	DE,100	      ;write 3rd digit
	CALL	WNDD
	LD	DE,10	      ;write 4th digit
	CALL	WNDD
	LD	DE,1	      ;write 5th digit
	LD	B,1	      ;force last digit to
			      ;print
	CALL	WNDD
	POP	BC
	POP	DE
	POP	HL
	RET

WNDD:	LD	C,0	      ;c=0
WNDD1:	LD	A,L	      ;hl = hl - de
	SUB	E
	LD	L,A
	LD	A,H
	SBC	A,D
	LD	H,A
	JR	C,WNDD2-$     ;jump if < 0
	INC	C	      ;c = c + 1
	JR	WNDD1-$	      ;loop

WNDD2:	ADD	HL,DE	      ;hl = hl + de
	LD	A,C	      ;jump if c non-zero
	OR	C
	JR	NZ,WNDD4-$
	LD	A,B	      ;jump if digit written
	OR	B
	JR	NZ,WNDD4-$
	LD	A,' '	      ;write one space
	JR	WACC-$

WNDD4:	LD	B,1	      ;set 'digit written' flag
	LD	A,C	      ;encode c into decimal
			      ; ascii
	ADD	A,'0'
	JR	WACC-$	      ;go write it

;*  wacc - write ascii character to console  *

WACC:	PUSH	HL
	PUSH	DE
	PUSH	BC
	PUSH	AF

	LD	C,WCFC
	LD	E,A
	CALL	ENTRY

	POP	AF
	POP	BC
	POP	DE
	POP	HL
	RET

;*  racc - read ascii character from console  *

RACC:	PUSH	HL
	PUSH	DE
	PUSH	BC

	LD	C,RCFC
	CALL	ENTRY

	POP	BC
	POP	DE
	POP	HL
	RET

;*  reset - reset disk system  *

RESET:	PUSH	HL
	PUSH	DE
	PUSH	BC

	LD	C,RDFC
	CALL	ENTRY

	POP	BC
	POP	DE
	POP	HL
	RET

;*  open - open disk file  *

OPEN:	PUSH	HL
	PUSH	DE
	PUSH	BC

	LD	DE,TFCB
	LD	C,OFFC
	CALL	ENTRY

	POP	BC
	POP	DE
	POP	HL
	RET

;*  read - read record from disk file  *

READ:	PUSH	HL
	PUSH	DE
	PUSH	BC

	LD	DE,TFCB
	LD	C,RRFC
	CALL	ENTRY

	POP	BC
	POP	DE
	POP	HL
	RET

;*  close - close disk file  *

CLOSE:	PUSH	HL
	PUSH	DE
	PUSH	BC

	LD	DE,TFCB
	LD	C,CFFC
	CALL	ENTRY

	POP	BC
	POP	DE
	POP	HL
	RET

;*  delt - delete disk file  *

DELT:	PUSH	HL
	PUSH	DE
	PUSH	BC

	LD	DE,TFCB
	LD	C,DFFC
	CALL	ENTRY

	POP	BC
	POP	DE
	POP	HL
	RET

;*  make - make new disk file  *

MAKE:	PUSH	HL
	PUSH	DE
	PUSH	BC

	LD	DE,TFCB
	LD	C,MFFC
	CALL	ENTRY

	POP	BC
	POP	DE
	POP	HL
	RET

;*  write - write record to file  *

WRITE:	PUSH	HL
	PUSH	DE
	PUSH	BC

;*  REVISION 4.3 MODS  *

	LD	A,(TFCB+NR)   ;LAST RECORD IN EXTENT?
	CP	7FH
	JR	NZ,WRITE1-$   ;NO, CONTINUE
	LD	HL,(MBUFP)    ;EXISTING DATA AREA
	LD	DE,DBUF	      ;POINT TO SAFE AREA
	CALL	SETDMA	      ;FROM HERE
	LD	BC,80H	      ;LENGTH TO MOVE
	LDIR		      ;MOVE DATA AWAY SO...

;*  CP/M DOESN'T OVERWRITE THE REAL DATA IN OPENING   *
;*  NEXT EXTENT					      *

;*  END REVISION 4.3 MODS  *

WRITE1: LD	DE,TFCB
	LD	C,WRFC
	CALL	ENTRY

	POP	BC
	POP	DE
	POP	HL
	RET

;*  setdma - set dma address  *

SETDMA: PUSH	HL
	PUSH	DE
	PUSH	BC

	LD	C,SAFC
	CALL	ENTRY

	POP	BC
	POP	DE
	POP	HL
	RET

;*  srchf - search for first occurance of afn  *

SRCHF:	PUSH	HL
	PUSH	DE
	PUSH	BC

	LD	C,SFFC
	CALL	ENTRY

	POP	BC
	POP	DE
	POP	HL
	RET

;*  srchn - search for next occurance of afn  *

SRCHN:	PUSH	HL
	PUSH	DE
	PUSH	BC

	LD	C,SNFC
	CALL	ENTRY

	POP	BC
	POP	DE
	POP	HL
	RET


;*  mesages here  *


MSG1:	DB	CR,LF
	DB	'MFT V'
	DB	VERSION+'0'   ;VERSION #
	DB	'.'
	DB	MODLEV+'0'    ;MODIFICATION LEVEL
	DB	CR,LF
	DB	'Multi-File-Transfer for single '
	DB	'disk,'
	DB	CR,LF
	DB	'With multiple-copy option.'
	DB	CR,LF,LF
	DB	0

MSG2:	DB	'Buffer size = '
	DB	0

MSG3:	DB	' sectors.'
	DB	CR,LF,LF
	DB	0

MSG4:	DB	'Mount INPUT disk, type RETURN (or ^C '
	DB	'to reboot)...'
	DB	0

MSG5:	DB	'-- Syntax error in filename --'
	DB	CR,LF
	DB	0

MSG6:	DB	' - '
	DB	0

MSG7:	DB	' not found !'
	DB	CR,LF
	DB	0

MSG8:	DB	'read error - '
	DB	0

MSG9:	DB	' sectors read.'
	DB	CR,LF
	DB	0
MSGA:	DB	'Mount OUTPUT disk, type RETURN (or '
	DB	'^C to reboot)...'
	DB	0

MSGB:	DB	'-- unable to create --'
	DB	CR,LF
	DB	0

MSGC:	DB	'-- error writing file --'
	DB	CR,LF
	DB	0

MSGD:	DB	'-- unable to close --'
	DB	CR,LF
	DB	0

MSGE:	DB	' sectors written.'
	DB	CR,LF
	DB	0

MSGF:	DB	CR,LF
	DB	'Completed. '
	DB	'Type RETURN for another copy, OR...'
	DB	0

MSGG:	DB	CR,LF
	DB	'Type ^C to reboot.'
	DB	CR,LF
	DB	0

MSGH:	DB	CR,LF
	DB	'++ Memory buffer exceeded, cannot '
	DB	CR,LF
	DB	'make duplicate copies this time ; '
	DB	CR,LF
	DB	'last ouput file is defective ++'
	DB	CR,LF,LF
	DB	0

MSGJ:	DB	CR,LF
	DB	'++ PROGRAM ABORTED ++'
	DB	CR,LF
	DB	0

MSGK:	DB	CR,LF
	DB	'-- No file name specified --'
	DB	CR,LF
	DB	0

MSGL:	DB	'exists. Erase it (Y/N) ? '
	DB	0

FILERO: DB	'is a R/O file. Confirm erasure '
	DB	'(Y/N) ? '
	DB	0

BADVER: DB	'Sorry, you need CP/M version 2.0 or '
	DB	'higher.'
	DB	CR,LF
	DB	0

REOPER: DB	'-- Reopen error , insert correct '
	DB	'output disk next time --'
	DB	CR,LF
	DB	0


ZEROS:	DB	0,0,0,0


	ORG	($+15)/16*16


FNT:	DEFS	16*128+1      ;changed fnt entries from
			      ;64 to 128 !!

STACK:	DEFS	64
SPACE:	DEFS	2	      ;available space
MSIZE:	DEFS	2	      ;memory size
CBUF:	DEFS	80	      ;command buffer
CBUFP:	DEFS	2	      ;command buffer pointer
FSIZE:	DEFS	2	      ;file size in sectors
XSIZE:	DEFS	2	      ;file size for printout
IFNTP:	DEFS	2	      ;input fnt pointer
OFNTP:	DEFS	2	      ;output fnt pointer
MBUFP:	DEFS	2	      ;memory buffer pointer
IFCB:	DEFS	33	      ;input fcb
OFCB:	DEFS	33	      ;output fcb
XFCB:	DEFS	33	      ;temporary fcb
IBFLG:	DEFS	1	      ;input break flag
OBFLG:	DEFS	1	      ;output break flag
NDFLG:	DEFS	1	      ;NO DUPLICATE ALLOWED
			      ; FLAG
SAVE:	DEFS	1	      ;temp. store of directory
			      ;pointer in erase routine
NERAS:	DEFS	1	      ;last output file not
			      ;written to disk flag !


MBUF:	EQU	$


	END	MFT


;******************************************************
;*						      *
;* Explanation as to structure of entries in the FNT  *
;* -------------------------------------------------  *
;*						      *
;*	 -------------------------------------	      *
;*	 |00|01|02|..|..|..|10|11|12|13|14|15|	      *
;*	 -------------------------------------	      *
;*						      *
;* 00	 = read done flag ; set to 1 if this name has *
;*			    already been read in.     *
;*						      *
;* 01-08 = filename.				      *
;*						      *
;* 09-11 = filetype.				      *
;*						      *
;* 12-13 = start address of data for this file.	      *
;*						      *
;* 14-15 = length of file in 128 byte sectors.	      *
;*						      *
;* Note : 00-15 are offset from start of FNT entry.   *
;*						      *
;******************************************************
