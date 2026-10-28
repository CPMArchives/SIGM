*
*  Atlanta Data Base Users Society Banking System Deposit Cancel Command File
*
*			Program Name	: XDEPCANC.CMD
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
STORE 'Y'	TO XCANING
STORE '                              '	TO BLNKS
STORE F	TO XEND
DO WHILE XCANING <> 'F'
	GO TOP
	LOCATE FOR NUMBER = 0.0 .AND. .NOT. CANCEL
	@ 2,15 SAY 'Atlanta Data Base Users Society Bank Account System'
	@ 3,22 SAY 'Deposit Cancelling Program'
	IF .NOT.EOF
		@ 6,10 SAY '     Deposit Date : ' + DATE
		@ 7,10 SAY 'Amount of Deposit : ' + STR(AMOUNT,10,2)

		@ 21,0 SAY 'Cancel This Deposit (Y)es or (N)o'
		WAIT TO XCEL
		IF XCEL = 'Y'
			REPLACE CANCEL	WITH T
		ENDIF
  	ELSE  
		@ 10,15 SAY 'All Deposits on File Are Cancelled'
		STORE T	TO XEND
	ENDIF 
	IF .NOT. XEND
	@ 22,0 SAY BLNKS
	@ 21,0 SAY BLNKS + BLNKS
	@ 21,0 SAY 'Continue Cancelling Deposits (Y)es or (N)o'
	WAIT TO ANSWER
	ENDIF
	IF XEND
		STORE 'N'	TO ANSWER
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
			STORE 'F' TO XCANING
		ENDIF
	ENDIF
	ERASE
ENDDO XCANING
RELEASE ALL
SET TALK ON
RETURN  
*
*		END OF DEPOSIT CANCELLING COMMAND FILE
*
