*
*   	    Atlanta Data Base Users Society Banking System
*		     Index Checks Command File
*
*   			Program Name	: XINDX.CMD
*  			Author		: Keith R. Plossl
*			Date Written	: August 1982
*
* -----------------------------------------------------------------------------
*	   P U B L I C   D O M A I N   S O F T W A R E   N O T I C E
*
*   This program has been placed in the public domain by Keith R. Plossl
*   for the Atlanta Data Base Users Society, Inc. Atlanta, Georgia
*   and may be copied, modified or used NON-COMMERCIALLY provided this
*   notice, the title block and modification history have not been 
*   removed.  The COMMERCIAL sale or use of this program for profit 
*   is strictly prohibited.  KRP 7/15/83
*   
* -----------------------------------------------------------------------------
*			    Modification History
*
*	2/1/83		Added decimal check numbers           Keith R. Plossl
*			to data file & programs.
*
*	7/15/83		Set to Public Domain with Atlanta	Keith R. Plossl
*			Data Base Users Society.
*
* -----------------------------------------------------------------------------
ERASE
SET TALK OFF
SET DEFAULT TO &F:DSK
USE &DBF
@ 2,15 SAY 'Atlanta Data Base Users Society Bank Account System'
@ 3,15  SAY '  Data File Indexing & Sorting System'

@ 5,0 SAY ' This Program will produce all indexes needed for print selection.'
@ 8,25 SAY '    SELECTION MENU'
@ 10,15 SAY ' I = Produce All indexes Except for Special'
@ 11,15 SAY ' S = Produce Special Index'
@ 12,15 SAY ' M = Return to Main Menu'
@ 13,15 SAY ' X = Quit Dbase and Return to Operating System'
WAIT TO SELECT

	IF SELECT = 'X'
		ERASE
		QUIT
	ENDIF
	IF SELECT = 'M'
		STORE F TO INDEX
	ENDIF
	IF SELECT = 'S'
		ERASE
		STORE '        ' TO FLD1
		STORE '        ' TO FLD2
		STORE '        ' TO FLD3
		@ 2,15 SAY 'Atlanta Data Base Users Society Bank Account System'
		@ 3,15  SAY ' Data File Indexing & Sorting System'
		@ 7,15  SAY 'First Field Name to Index on'	GET FLD1
		@ 8,15  SAY 'Second Field Name to Index on'	GET FLD2
		@ 9,15  SAY 'Third Field Name to Index on'	GET FLD3
		@ 10,15 SAY 'Name of Special Index File'	GET NDX
		READ
		STORE TRIM(FLD1)	TO FLD1
		STORE TRIM(FLD2)	TO FLD2
		STORE TRIM(FLD3)	TO FLD3
		STORE TRIM(NDX)		TO NDX

		IF LEN(FLD1) > 2
			IF LEN(FLD3) = 1 .AND. LEN(FLD2) = 1
				INDEX ON &FLD1  	TO &NDX
			ENDIF
			IF LEN(FLD3) = 1 .AND. LEN(FLD2) > 2
				INDEX ON &FLD1 + &FLD2	TO &NDX
			ENDIF
			IF LEN(FLD3) > 2 .AND. LEN(FLD2) > 2
				INDEX ON &FLD1 + &FLD2 + &FLD3	TO &NDX
			ENDIF
		ENDIF
		@ 12,20 SAY 'Special Index Produced'
	ENDIF
	IF !(SELECT) = 'I' 
		ERASE
		@ 12,20 SAY 'Producing Indexes - Please Wait'
		INDEX ON NUMBER		TO CKNUM
		@ 14,10 SAY 'Number Index Complete - Working on Date       '
		INDEX ON DATE		TO CKDATE
		@ 14,10 SAY 'Date Index Complete - Working on Written to   '
		INDEX ON TO		TO CKTO
		@ 14,10 SAY 'Written to Index Complete - Working on Memo   '
		INDEX ON MEMO		TO CKMEMO
		@ 14,10 SAY 'Memo Index Complete - Working on Account No.  '
		INDEX ON PURPOSE TO PURPOSE
		@ 14,10 SAY ' ***** All Indexes Complete *****               '
	ENDIF
SET TALK ON
ERASE
RETURN
*
* ----------- END OF BANKING SYSTEM INDEXING COMMAND PROGRAM ----------
*
