*
*  Atlanta Data Base Users Society Banking System Deposit Modify Command File
*
*			Program Name	: XMODDEP.CMD
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
*	2/1/83		Added decimal check numbers           Keith R. Plossl
*			to data file & programs.
*
*	7/15/83		Set to Public Domain with Atlanta	Keith R. Plossl
*			Data Base Users Society.
*
* -----------------------------------------------------------------------------
ERASE
STORE 'Y'	TO MODIFY
STORE '                              '	TO BLNKS
STORE F	TO XEND
GO BOTTOM
STORE DATE TO CH:DAT
STORE 0.00 TO CH:AMT
DO WHILE MODIFY <> 'F'

	GO TOP
	@ 2,15 SAY 'Atlanta Data Base Users Society Bank Account System'
	@ 3,22 SAY 'Deposit Modification Program'
	@ 6,10 SAY '     Deposit Date  ' GET CH:DAT PICTURE '99/99/99'
	@ 7,10 SAY 'Amount of Deposit  ' GET CH:AMT
	READ

	LOCATE FOR DATE = CH:DAT .AND. AMOUNT = CH:AMT .AND. NUMBER = 0.0
	ERASE
	@ 2,15 SAY 'Atlanta Data Base Users Society Bank Account System'
	@ 3,22 SAY 'Deposit Modification Program'
	IF .NOT.EOF
		@ 6,10 SAY '     Deposit Date : ' + DATE
		@ 7,10 SAY 'Amount of Deposit : ' + STR(AMOUNT,10,2)

		@ 21,0 SAY 'Modify This Deposit (Y)es or (N)o'
		WAIT TO MODF
		IF MODF = 'Y'
			ERASE
		@ 2,15 SAY 'Atlanta Data Base Users Society Bank Account System'
		@ 3,22 SAY 'Deposit Modification Program'
		@ 6,10 SAY '     Deposit Date  ' GET CH:DAT PICTURE '99/99/99'
		@ 7,10 SAY 'Amount of Deposit  ' GET CH:AMT
		READ
		@ 21,0	SAY BLNKS + BLNKS
		@ 22,0	SAY BLNKS
		@ 21,0  SAY 'Update This Record (Y)es or (N)o'
		WAIT TO ANSWER
		IF ANSWER = 'Y'
			REPLACE AMOUNT	WITH CH:AMT
			REPLACE	DATE	WITH CH:DAT
		ENDIF
		ENDIF
	ELSE
		@ 10,10 SAY 'No Such Deposit on File'
		STORE T TO XEND
	ENDIF
	IF .NOT. XEND
		@ 21,0  SAY BLNKS
		@ 22,0	SAY BLNKS
		@ 21,0	SAY 'Continue Modifying Records (Y)es or (N)o'
		WAIT TO ANSWER			
	ENDIF
	IF XEND
		STORE 'N'  TO ANSWER
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
			STORE 'F' TO MODIFY
		ENDIF
	ENDIF
	ERASE
ENDDO MODIFY
RELEASE ALL
SET TALK ON
RETURN  
*
*		END OF MODIFY DEPOSIT COMMAND FILE
*
