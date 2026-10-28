*
*		BANKING SYSTEM COMMAND MENU PROGRAM

*   		Program Name 	: XMENU.CMD
*		Author		: Keith R. Plossl
*		Date Written	: July 1982
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
*	2/1/83		Added decimal check numbers           	Keith R. Plossl
*			to data file & programs.
*
*	2/26/83		Set Number Index on for use of FIND.	Keith R. Plossl
*
*	7/15/83		Set to Public Domain with Atlanta	Keith R. Plossl
*			Data Base Users Society.
* -----------------------------------------------------------------------------
*  - turn off display of commands to screen
SET TALK OFF
ERASE
SET INTENSITY OFF
STORE 'B:'	TO F:DSK
STORE 'ABUSBANK' TO DBF
STORE 'B:'	TO C:DSK

@ 2,16 SAY 'Data Base Users Society Bank Account Main Menu'
@ 4,10 SAY '          Enter Data Base File Name '	GET DBF
@ 5,10 SAY '  Enter Data File Disk Drive Letter '	GET F:DSK
@ 6,10 SAY 'Enter Command File Disk Drive Letter' 	GET C:DSK
READ

SET DEFAULT TO &F:DSK
USE &DBF
SET INDEX TO CKNUM
SET DEFAULT TO &C:DSK
DO WHILE T
SET TALK OFF
@ 8,5 SAY '                       BANKING SYSTEM USER MENU'

@ 10,5 SAY '        0 - EXIT'
@ 11,5 SAY '        1 - Enter New Checks              6 - Modify Checks'
@ 12,5 SAY '        2 - Enter Deposits                7 - Modify Deposits'
@ 13,5 SAY '        3 - Enter Cancelled Checks        8 - Index Records'
@ 14,5 SAY '        4 - Enter Cancelled Deposits      9 - Report Subsystem'
@ 15,5 SAY '        5 - Balance & Reconcilliation     B - Make Backup File'
@ 17,5 SAY ' Enter Desired Option'
WAIT TO ACTION
DO CASE

	CASE ACTION = '0'
 	SET TALK ON
	QUIT

	CASE ACTION = '1'
	DO XNEWENTR

	CASE ACTION = '2'
	DO XDEPOSIT

	CASE ACTION = '3'
	DO XCANCEL

	CASE ACTION = '4'
	DO XDEPCANC

	CASE ACTION = '5'
	DO XBALANCE

	CASE ACTION = '6'
	DO XMODCKS

	CASE ACTION = '7'
	DO XMODDEP

	CASE ACTION = '8'
	DO XINDX

	CASE ACTION = '9'
	DO XPRNTCK

	CASE ACTION = 'B'
	SET DEFAULT TO &F:DSK
	SET TALK ON
	COPY TO ABUSBKUP
	SET TALK OFF
	SET DEFAULT TO &C:DSK
	ERASE

* ----------------------------------------------------------------------------
* 		INVALID ENTRY ESCAPE ROUTINE
* ----------------------------------------------------------------------------

	OTHERWISE
        @ 19,5 SAY 'Numbers 0 thru 9 & Letter B ONLY - Please'

  ENDCASE

ENDDO
RETURN

*		END OF BANKING SYSTEM MAIN MENU COMMAND FILE
*
