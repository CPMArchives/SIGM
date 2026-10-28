*
*            Atlanta Data Base Users Society Bank Account System
*		          Print Checks Command File
*
*   			Program Name	: XPRNTCK.CMD
*  			Author		: Keith R. Plossl
*			Date Written	: August 1982
*
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
*     	2/14/83     Modified to total and print the amount,   Keith R. Plossl
*		    the sales tax and interest if purpose
*		    code sorted data is printed.
*
*       5/27/83     Modified print routine to skip deposits   Keith R. Plossl
*		    before checking if printed.
*
*	7/15/83		Set to Public Domain with Atlanta	Keith R. Plossl
*			Data Base Users Society.
*
* -----------------------------------------------------------------------------
ERASE
SET TALK OFF
SET INTENSITY OFF
SET DEFAULT TO &F:DSK
STORE 0.00	TO TOT:CK
STORE 0.00	TO TOT:TX
STORE 0.00	TO TOT:IN
STORE '     '	TO VBLNKS
STORE VBLNKS + VBLNKS		TO XBLNKS
STORE '                    '	TO XXBLNKS
STORE T	TO TRUE
@ 2,15  SAY 'Atlanta Data Base Users Society Banking System'
@ 3,25  SAY '   Report Subsystem Menu Program'
@ 5,30  SAY ' MENU'
@ 7,20  SAY ' 0 = EXIT to Main Menu'
@ 8,20  SAY ' 1 = Print All Checks in Numerical Order'
@ 9,20  SAY ' 2 = Print Checks not Printed Previously'
@ 10,20 SAY ' 3 = Print All Deposits in Date Order'
@ 11,20 SAY ' 4 = Print Deposits not Printed Previously'
@ 12,20 SAY ' 5 = Print Checks Sorted by Written to:'
@ 13,20 SAY ' 6 = Print Checks Sorted by Memo:'
@ 14,20 SAY ' 7 = Print Checks Sorted by Purpose Code'
@ 15,20 SAY ' 8 = Print Checks Sorted by Date'
@ 16,20 SAY ' 9 = Print Checks in Special Sequence'
@ 17,0  SAY ' Files MUST have been Indexed to Print - If not Indexed Select 0'
WAIT TO SELECT

	IF SELECT = '1'
		USE &DBF INDEX CKNUM
		STORE T TO PRINTIT
		STORE F TO CHECKIT
	ENDIF
	IF SELECT = '2'
		USE &DBF INDEX CKNUM
		STORE T TO PRINTIT
		STORE T TO CHECKIT
	ENDIF
	IF SELECT = '3'
		USE &DBF INDEX CKDATE
		STORE T TO PRINTIT
		STORE F TO CHECKIT
	ENDIF
	IF SELECT = '4'
		USE &DBF INDEX CKDATE
		STORE T TO PRINTIT
		STORE T TO CHECKIT
	ENDIF
	IF SELECT = '5'
		USE &DBF INDEX CKTO
		STORE T TO PRINTIT
		STORE F TO CHECKIT
	ENDIF
	IF SELECT = '6'
		USE &DBF INDEX CKMEMO
		STORE T TO PRINTIT
		STORE F TO CHECKIT
	ENDIF
	IF SELECT = '7'
		USE &DBF INDEX PURPOSE
		STORE T TO PRINTIT
		STORE F TO CHECKIT
	ENDIF
	IF SELECT = '8'
		USE &DBF INDEX CKDATE
		STORE T TO PRINTIT
		STORE F TO CHECKIT
	ENDIF
	IF SELECT = '9'
		@ 18,10 SAY 'Name of Index File to Use'
		WAIT TO FILENAME
		USE &DBF INDEX &FILENAME
		STORE T TO PRINTIT
		STORE F TO CHECKIT
	ENDIF
	IF SELECT = '0'
		STORE F TO PRINTIT
	ENDIF

IF PRINTIT
SET PRINT ON
STORE 0 TO PAGE
GO TOP
IF SELECT = '7'
	STORE PURPOSE		TO PREV:PURP
ENDIF
DO WHILE .NOT. EOF
	EJECT
	STORE PAGE + 1	TO PAGE
	? CHR(18) + CHR(27) + CHR(70) + CHR(27) + CHR(72)
	? CHR(14) + ' Data Base Users Society Banking System'
	? CHR(14) + '---------------------------------------'
	? CHR(14) + '   Banking Deposit & Check Report'
	? CHR(14) + '---------------------------------------'
	? CHR(14) + 'Page ' + STR(PAGE,3,0) + '                  ' + 'Date ' + Date()
	IF SELECT = '3' .OR. SELECT = '4'
	?
	? XXBLNKS + '  DATE OF DEPOSIT   ' + ' AMOUNT OF DEPOSIT '
	?
	ELSE 
	?
? CHR(15) + "NUMBER   " + "  DATE      " + "     PAY TO ORDER OF           " + "    AMOUNT    " + "        MEMO             " + "PURPOSE       INTEREST       SALES TAX"
	?
	ENDIF
	STORE 1 TO INDEX

	DO WHILE INDEX < 51
* ----------------------------------------------------------------------------
* 		Select Checks or Deposit Records Only
* ----------------------------------------------------------------------------
		IF SELECT = '3' .OR. SELECT = '4'
			DO WHILE NUMBER <> 0.0 .AND. .NOT. EOF
				SKIP
			ENDDO
		ELSE
			DO WHILE NUMBER = 0.0 .AND. .NOT. EOF
				SKIP
			ENDDO
		ENDIF
* ----------------------------------------------------------------------------
*		Check for Data Already Printed
* ----------------------------------------------------------------------------
		IF CHECKIT
			STORE T	TO CHKD
			DO WHILE CHKD
				STORE PRINTED TO CHKD
				IF CHKD
					SKIP
				ENDIF
			ENDDO
		ENDIF
* ----------------------------------------------------------------------------
*		Store The Data for Printing
* ----------------------------------------------------------------------------
		
		STORE NUMBER	TO CH:NO
		STORE TO	TO CH:TO
		STORE AMOUNT	TO M:AMT
		STORE DATE	TO CH:DAT
		STORE MEMO	TO CH:MEMO
		STORE PURPOSE	TO PURP
		STORE STR(INTEREST,5,2)		TO INT
		STORE STR(SLSTAX,5,2)	        TO S:TAX
		STORE '  ' + PURP + '           ' + INT + '           ' + S:TAX TO S:ACCT
		IF SELECT = '7'
			IF PURP = PREV:PURP
				STORE M:AMT + TOT:CK	TO TOT:CK
				STORE SLSTAX + TOT:TX	TO TOT:TX
				STORE INTEREST + TOT:IN TO TOT:IN
			ELSE
*              		----------------------------------------------
*              		|               PRINT SUMMARY DATA           |
*              		----------------------------------------------
				?
				? 'Total Checks = $' + STR(TOT:CK,10,2);
				+ XBLNKS + '  Total Interest = $' + STR(TOT:IN,10,2);
				+ XBLNKS + '  Total Sales Tax = $' + STR(TOT:TX,10,2)
				?
				STORE INDEX + 3		TO INDEX
				STORE M:AMT		TO TOT:CK
				STORE SLSTAX		TO TOT:TX
				STORE INTEREST		TO TOT:IN
				STORE PURP		TO PREV:PURP

			ENDIF
		ENDIF
* ----------------------------------------------------------------------------
* 			Print Deposit Data
* ----------------------------------------------------------------------------

		IF SELECT = '3' .OR. SELECT = '4'
		? XXBLNKS + VBLNKS + CH:DAT + VBLNKS + VBLNKS + STR(M:AMT,10,2) 
		STORE INDEX + 1	TO INDEX
		REPLACE PRINTED	WITH TRUE
		SKIP
			IF EOF
				STORE 51	TO INDEX
				STORE F		TO PRINTIT
			ENDIF
		ELSE 

* ----------------------------------------------------------------------------
* 			Print Check Data
* ----------------------------------------------------------------------------

? STR(CH:NO,7,1) + '    ' + CH:DAT + '    ' + CH:TO + STR(M:AMT,10,2) + VBLNKS + CH:MEMO + VBLNKS + S:ACCT
		STORE INDEX + 1	TO INDEX
		REPLACE PRINTED WITH TRUE
		SKIP
			IF EOF
				STORE 51	TO INDEX
				STORE F		TO PRINTIT
			ENDIF
		ENDIF
	ENDDO
ENDDO
USE &DBF
GO BOTTOM
?
? 'Number of Total Check & Deposit Records on File ' + STR(#,5)
?
EJECT
ENDIF
RELEASE ALL
SET PRINT OFF
SET CONSOLE ON
ERASE
SET TALK ON
RETURN
*
*      --------- END OF BANKING SYSTEM REPORT SUBSYSTEM ---------
*
