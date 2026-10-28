*
*   Atlanta Data Base Users Society Banking System Add Deposits Command File
*
*			Program Name	: XDEPOSIT.CMD
*			Author		: Keith R. Plossl
*			Date Written	: July 1982
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
*	7/15/83		Set to Public Domain with Atlanta	Keith R. Plossl
*			Data Base Users Society.
*
* -----------------------------------------------------------------------------
ERASE
GO BOTTOM
STORE 'Y'	TO ADDING
STORE '                              '	TO BLNKS
DO WHILE ADDING <> 'F'
	STORE DATE	TO CH:DAT
	STORE 0.00	TO C:AMT
	@ 2,15 SAY 'Atlanta Data Base Users Society Bank Account System'
	@ 3,25 SAY 'New Deposit Entry Program'

	@ 6,20 SAY 'Enter Amount of 0 to EXIT'
	@ 8,20 SAY '  Date of Deposit '	GET CH:DAT PICTURE '99/99/99'
	@ 9,20 SAY 'Amount of Deposit '	GET C:AMT
	READ

IF C:AMT <> 0
	@ 21,0 SAY 'Cancel This Deposit (Y)es or (N)o'
	WAIT TO XCEL
	IF XCEL = 'Y'
		STORE T	TO CAN
	ELSE
		STORE F TO CAN
	ENDIF
	@ 21,0	SAY BLNKS + BLNKS
	@ 22,0	SAY BLNKS
	@ 21,0  SAY 'Add This Record (Y)es or (N)o'
	WAIT TO ANSWER
	IF ANSWER = 'Y'
		APPEND BLANK
		REPLACE NUMBER	WITH 0.0
		REPLACE TO	WITH 'DEPOSIT'
		REPLACE AMOUNT	WITH C:AMT
		REPLACE	DATE	WITH CH:DAT
		REPLACE CANCEL	WITH CAN
	ENDIF
	@ 21,0  SAY BLNKS + BLNKS
	@ 22,0	SAY BLNKS
	@ 21,0	SAY 'Continue Adding Records (Y)es or (N)o'
	WAIT TO ANSWER
ENDIF
IF C:AMT = 0
	STORE 'N' TO ANSWER
ENDIF
	IF ANSWER = 'N'
		@ 21,0 SAY BLNKS + BLNKS
		@ 22,0 SAY BLNKS
		@ 21,0 SAY 'Enter (F)inished or <CR> to QUIT'
		WAIT TO END
		IF END <> 'F'
			ERASE
			QUIT
		ELSE
			STORE 'F' TO ADDING
		ENDIF
	ENDIF
	IF ANSWER = 'Y'
		STORE 'Y' TO ADDING
	ENDIF
	ERASE
ENDDO ADDING
RELEASE ALL
SET TALK ON
RETURN  
*
*		END OF DEPOSIT ENTRY COMMAND PROGRAM
*
