*
*   Atlanta Data Base Users Society Banking System Modify Checks Command File
*
*   			Program Name	: XMODCKS.CMD
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
*	2/1/83		Added decimal check numbers           	Keith R. Plossl
*			to data file & programs.
*
*	2/26/83		Replaced LOCATE with FIND.		Keith R. Plossl
*
*	7/15/83		Set to Public Domain with Atlanta	Keith R. Plossl
*			Data Base Users Society.
*
* -----------------------------------------------------------------------------
ERASE
STORE 'Y' TO MODIFY
STORE '                              '	TO BLNKS
DO WHILE MODIFY <> 'F'
	STORE 0.0	TO M:NO
	@ 2,15 SAY 'Atlanta Data Base Users Society Bank Account System'
	@ 3,25 SAY ' Check Modification Program'
	@ 5,0  SAY 'Enter Check Number of 0 to EXIT'

	@ 7,10 SAY 'Check Number to Modify'	GET M:NO PICTURE '999999.9'
	READ
	GO TOP
	IF M:NO <> 0.0
	STORE STR(M:NO,7,1)	TO STM:NO
	FIND &STM:NO
	IF # > 0
	  	STORE TO		TO CH:TO
  		STORE AMOUNT   		TO CH:AMT
  		STORE MEMO		TO CH:MEMO
  		STORE NUMBER	 	TO M:NO
		STORE INTEREST		TO I:PAID
		STORE SLSTAX		TO S:TAX
		STORE PURPOSE		TO PURP
		STORE DATE		TO CH:DAT
	ELSE
		@ 9,10 SAY 'Check '+ STR(M:NO,7,1) + ' not on file.'
	ENDIF
	IF # > 0
	ERASE
* ----------------------------------------------------------------------------
*			Records Display Screen
* ----------------------------------------------------------------------------
	@ 2,15 SAY 'Atlanta Data Base Users Society Bank Account System'
	@ 3,25 SAY ' Check Modifying Program'

  	@ 6,40 SAY 'Check Number  ' + STR(M:NO,7,1)
  	@ 7,40 SAY 'Date Written  ' + CH:DAT
  	@ 8,0  SAY 'Pay to The Order of : ' + CH:TO
  	@ 9,40 SAY 'Amount ($)  ' + STR(CH:AMT,10,2)
	@ 10,0  SAY 'Memo :' + CH:MEMO
	@ 11,0  SAY 'Sales Tax Paid  ' + STR(S:TAX,5,2)
	@ 12,0  SAY 'Interest Paid   ' + STR(I:PAID,5,2)
	@ 13,0  SAY '-------------------------------- Purpose of Check ---------------------'
  	@ 14,0  SAY 'AU - Automobile         EL - Electricity             MO - Mortgage     '  
	@ 15,0  SAY 'BC - Bank Charges       FO - Food                    RE - Repairs      '
  	@ 16,0  SAY 'BU - Business Expense   GA - Gas                     TA - Taxes        '
  	@ 17,0  SAY 'CL - Clothing           HI - Home Improvements       TE - Telephone    '
	@ 18,0  SAY 'DP - Dues + Public.     IN - Insurance               WA - Water        '
  	@ 19,0  SAY 'ED - Education          MD - Medical & Dental        MI - Miscellaneous'
  	@ 20,0  SAY 'Purpose Letter : ' + PURP

	@ 22,0 SAY 'Modify This Check (Y)es or (N)o'
	WAIT TO MODF
	IF MODF = 'Y'
		ERASE
* ----------------------------------------------------------------------------
*		Add Records Display Screen
* ----------------------------------------------------------------------------
		@ 2,15 SAY 'Atlanta Data Base Users Society Bank Account System'
		@ 3,25 SAY ' Check Modification Program'

		@ 5,0  SAY 'Enter Check Number of 0 to EXIT'
  		@ 6,40 SAY 'Check Number  ' 	GET M:NO PICTURE '999999.9'
  		@ 7,40 SAY 'Date Written  ' 	GET CH:DAT PICTURE '99/99/99'
  		@ 8,0  SAY 'Pay to The Order of  ' 	GET CH:TO
  		@ 9,40 SAY 'Amount ($)  ' 	GET CH:AMT 
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
		IF M:NO <> 0.0
			@ 22,0 SAY 'Cancel This Check (Y)es or (N)o'
			WAIT TO XCEL
		IF XCEL = 'Y'
			STORE T		TO CAN
		ELSE
			STORE F		TO CAN
		ENDIF
		@ 22,0 SAY BLNKS + BLNKS
		@ 23,0 SAY BLNKS
  		@ 22,0 SAY 'Update this Record (Y)es or (N)o'
		WAIT TO ANSWER
		IF ANSWER = 'Y'
			REPLACE NUMBER		WITH M:NO
			REPLACE TO		WITH CH:TO
			REPLACE AMOUNT		WITH CH:AMT
			REPLACE MEMO		WITH CH:MEMO
			REPLACE SLSTAX		WITH S:TAX
			REPLACE INTEREST	WITH I:PAID
			REPLACE PURPOSE		WITH PURP
			REPLACE DATE		WITH CH:DAT
			REPLACE CANCEL		WITH CAN
		ENDIF
		ENDIF	
	ENDIF
	ENDIF
	@ 23,0 SAY BLNKS
	@ 22,0 SAY 'Continue Modifying Checks (Y)es or (N)o'
	WAIT TO ANSWER
	IF M:NO	= 0.0
		STORE 'N'	TO ANSWER
	ENDIF
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
			STORE 'F' TO MODIFY
		ENDIF
	ENDIF
	IF ANSWER = 'Y'
		STORE 'Y' TO MODIFY
	ENDIF
	
	ERASE
ENDDO MODIFY
RELEASE ALL
SET TALK ON
RETURN
*
*		-- END OF CHECK MODIFICATION COMMAND PROGRAM
*

