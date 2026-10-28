*
*    Atlanta Data Base Users Society Banking System Add Checks Command File
*
*   			Program Name	: XNEWENTR.CMD
*  			Author		: Keith R. Plossl
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
GO BOTTOM
DO WHILE NUMBER = 0 .AND. # > 1
	SKIP -1
ENDDO
STORE 'Y' TO ADDING
DO WHILE ADDING <> 'F'
  	STORE '                              '  TO CH:TO
  	STORE 0.00     				TO M:AMT
  	STORE '                    ' 		TO CH:MEMO
  	STORE NUMBER + 1 			TO M:NO
	STORE '                              ' 	TO BLNKS
	STORE 0.00				TO I:PAID
	STORE 0.00				TO S:TAX
	STORE '  '				TO PURP
	STORE DATE				TO CH:DAT
	STORE F					TO PRNT
* ----------------------------------------------------------------------------
*		Add Records Display Screen
* ----------------------------------------------------------------------------
	@ 2,15 SAY 'Atl. Data Base Users Society Bank Account System'
	@ 3,25 SAY ' New Check Entry Program'

	@ 5,0  SAY 'Enter Check Number of 0 to EXIT'
  	@ 6,40 SAY 'Check Number  ' 	GET M:NO PICTURE '999999.9'
  	@ 7,40 SAY 'Date Written  ' 	GET CH:DAT PICTURE '99/99/99'
  	@ 8,0  SAY 'Pay to The Order of  ' 	GET CH:TO
  	@ 9,40 SAY 'Amount ($)  ' 	GET M:AMT 
	@ 10,0  SAY 'Memo'		GET CH:MEMO
	@ 11,0  SAY 'Sales Tax Paid  '	GET S:TAX
	@ 12,0  SAY 'Interest Paid   '	GET I:PAID
	@ 13,0  SAY '-------------------------------- Purpose of Check ---------------------'
  	@ 14,0  SAY 'AU - Automobile         EL - Electricity             MO - Mortgage     '  
	@ 15,0  SAY 'BC - Bank Charges       FO - Food                    RE - Repairs      '
  	@ 16,0  SAY 'BU - Business Expense   GA - Gas                     TA - Taxes        '
  	@ 17,0  SAY 'CL - Clothing           HI - Home Improvements       TE - Telephone    '
	@ 18,0  SAY 'DP - Dues + Public.     IN - Insurance               WA - Water        '
  	@ 19,0  SAY 'ED - Education          MD - Medical & Dental        MI - Miscellaneous'
  	@ 20,0  SAY 'Enter Purpose Letter' GET PURP
  	READ
	IF M:NO <> 0
		@ 22,0 SAY 'Cancel This Check (Y)es or (N)o'
		WAIT TO XCEL
		IF XCEL = 'Y'
			STORE T		TO CAN
		ELSE
			STORE F		TO CAN
		ENDIF
		@ 22,0 SAY BLNKS + BLNKS
		@ 23,0 SAY BLNKS
  		@ 22,0 SAY 'Add this Record (Y)es or (N)o'
		WAIT TO ANSWER
		IF ANSWER = 'Y'
  			APPEND BLANK
			REPLACE NUMBER		WITH M:NO
			REPLACE TO		WITH CH:TO
			REPLACE AMOUNT		WITH M:AMT
			REPLACE MEMO		WITH CH:MEMO
			REPLACE SLSTAX		WITH S:TAX
			REPLACE INTEREST	WITH I:PAID
			REPLACE PURPOSE		WITH PURP
			REPLACE DATE		WITH CH:DAT
			REPLACE CANCEL		WITH CAN
			REPLACE PRINTED		WITH PRNT
		ENDIF

		@ 23,0 SAY BLNKS
		@ 22,0 SAY 'Continue Adding Records (Y)es or (N)o'
		WAIT TO ANSWER
	ENDIF
	IF M:NO	= 0
		STORE 'N'	TO ANSWER
	ENDIF
		IF ANSWER = 'N'
			@ 22,0 SAY BLNKS + BLNKS
			@ 23,0 SAY BLNKS
			@ 22,0 SAY 'Enter (F)inished or <CR> to QUIT'
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

*		-- END OF CHECK ENTRY COMMAND PROGRAM
*
