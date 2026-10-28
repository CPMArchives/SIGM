*
*   Atlanta Data Base Users Society Banking System Balance Command File
*
*			Program Name	: XBALANCE.CMD
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
STORE 'Y'	TO BALANCE
STORE '                              '	TO BLNKS
STORE F	TO XEND
@ 10,25 SAY 'Calculating - Please Wait'

* ----------------------------------------------------------------------------
*		ADD UP NON-CANCELLED DEPOSITS AND CHECKS  
* ----------------------------------------------------------------------------
	SUM AMOUNT TO CK:OUT FOR .NOT. CANCEL .AND. NUMBER > 0.0
	SUM AMOUNT TO DP:OUT FOR .NOT. CANCEL .AND. NUMBER = 0.0
* ----------------------------------------------------------------------------
*		ADD UP ALL DEPOSITS AND CHECKS
* ----------------------------------------------------------------------------
	SUM AMOUNT TO CKTOTAL FOR NUMBER > 0.0
	SUM AMOUNT TO DPTOTAL FOR NUMBER = 0.0
* ----------------------------------------------------------------------------
*	    COMPUTE BALANCES & DISPLAY TOTAL DEPOSITS & CHECKS 
* ----------------------------------------------------------------------------
	STORE DPTOTAL - CKTOTAL		TO CK:BAL
	STORE CK:BAL - DP:OUT + CK:OUT TO BK:BAL

	@ 2,15 SAY 'Atlanta Data Base Users Society Bank Account System'
	@ 3,19 SAY '   Balance & Reconcilliation Program '

	@ 6,10  SAY '  Balance per Bank Statement ' + $(BLNKS,1,20) + STR(BK:BAL,10,2)
	@ 7,10  SAY '     Less Outstanding Checks ' + STR(CK:OUT,10,2)
	@ 8,10  SAY '   Plus Outstanding Deposits ' + STR(DP:OUT,10,2)
	@ 9,39	SAY '____________'
	@ 10,10 SAY 'Checkbook & Adjusted Balance ' + $(BLNKS,1,20) + STR(CK:BAL,10,2)

	@ 21,0 SAY 'Do You Want a Reconcilliation (Y)es or (N)o'
	WAIT TO ANSWER
IF ANSWER = 'Y'
	STORE T TO PRNT
	SET PRINT ON
	SET CONSOLE OFF
	EJECT
	? CHR(18) + CHR(27) + CHR(70) + CHR(27) + CHR(72)
	? CHR(14) + '        ADBUS BANKING SYSTEM    '
	? CHR(14) + '        Bank Reconcilliation'
	? CHR(14) + '           Date ' + DATE()
	?
	?
	? $(BLNKS,1,10) + 'Balance per Bank Statement ' + $(BLNKS,1,20) + STR(BK:BAL,10,2)
	?
	? $(BLNKS,1,10) + 'Less Outstanding Checks: '
	GO TOP
	LOCATE FOR NUMBER > 0.0 .AND. .NOT. CANCEL
	IF .NOT. EOF
		? $(BLNKS,1,10) + '    Check No.          Amount'
		DO WHILE PRNT
			IF NUMBER > 0.0 .AND. .NOT. CANCEL
			? $(BLNKS,1,14) + STR(NUMBER,7,1) + $(BLNKS,1,10) + STR(AMOUNT,10,2)
			ENDIF
			SKIP
			IF EOF
				STORE F TO PRNT
				? $(BLNKS,1,27) + '-------------'
				? $(BLNKS,1,10) + 'Total Outstd. Cks  ' + STR(CK:OUT,10,2)
				?
			ENDIF
		ENDDO
	ENDIF
	IF PRNT
		? $(BLNKS,1,10) + 'Total Outstanding Checks   ' + STR(CK:OUT,10,2)
	ENDIF
		? $(BLNKS,1,10) + 'Plus Outstanding Deposits: '
		STORE T TO PRNT
		GO TOP
		LOCATE FOR NUMBER = 0.0 .AND. .NOT. CANCEL
	IF .NOT. EOF
		? $(BLNKS,1,10) + '      Date              Amount'
		DO WHILE PRNT
			IF NUMBER = 0.0 .AND. .NOT. CANCEL
			? $(BLNKS,1,14) + DATE + $(BLNKS,1,8) + STR(AMOUNT,10,2)
			ENDIF
			SKIP
			IF EOF
				STORE F TO PRNT
				? $(BLNKS,1,27) + '-------------'
				? $(BLNKS,1,10) + 'Total Outstd. Dep.  ' + STR(DP:OUT,10,2)
			ENDIF
		ENDDO
	ENDIF
	IF PRNT
		? $(BLNKS,1,10) + 'Total Outstanding Deposits ' + STR(DP:OUT,10,2)
	ENDIF
		?
		? $(BLNKS,1,10) + 'Adjusted & Checkbook Balance ' + $(BLNKS,1,18) + STR(CK:BAL,10,2)
		?
		EJECT
		SET PRINT OFF
		SET CONSOLE ON
ENDIF
ERASE
RELEASE ALL
SET TALK ON
RETURN  
*
*		END OF BALANCE & RECONCILLIATION COMMAND FILE
*
