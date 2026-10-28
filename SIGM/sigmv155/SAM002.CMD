*SAM002-Name & number table maintenance***********************************
*DATE OF LAST UPDATE  05/10/83                                           *
*REVISION NUMBER 001.00                                                  *
*                           THIS PROGRAM PLACED INTO PUBLIC DOMAIN BY    *
*                           DOUGLAS G. COUSE, ATLANTA, GA. 5/20/83       *
*                           COPYING FOR NON-COMMERCIAL OR EDUCATIONAL    *
*                           PURPOSES ALLOWED, PROVIDED THIS NOTICE IS    *
*                           NOT REMOVED. COMMERCIAL RESALE IS PROHIBITED.*
*									 *
**************************************************************************

********************************************************************************
*NOTE----any comment labelled (*P-) is a procedural section numbering reference*
*that should be used in flowcharting and other program documentation.          *
********************************************************************************

*P-001-{START}. Program and screen initialization.
ERASE
CLEAR
USE
SET COLON OFF
SET TALK OFF
SET ECHO OFF
RELEASE
STORE "MAINT." TO PROGRAM
DO SAMSCR1
*P-001-{END}.

*================================================================================

*P-005-{START}. Database file open & record access doloop initialization
*and execution section.
USE SAMFILE INDEX SAMAKEY
SET INTENSITY OFF
STORE "T" TO MORE
DO WHILE MORE = "T"
STORE 00 TO RECNO
@ 23,1 SAY "Enter starting record ##, or strike <RETURN> to EXIT  " GET RECNO PICTURE '99' 
READ
IF RECNO = 0
	STORE "F" TO MORE
	LOOP
ENDIF
GOTO TOP
SET EXACT ON
LOCATE FOR NUMBER = RECNO
IF EOF .OR. # = 0
	@ 22, 1 SAY "-"
	REMARK data NOT on file, strike any key to continue...........
	SET CONSOLE OFF
	WAIT
	SET CONSOLE ON
	SET EXACT OFF
	LOOP
ENDIF
SET EXACT OFF
STORE "A" TO ALWAYS
STORE RECNO + 59 TO MAXIMUM
STORE 7 TO LINE
STORE 2 TO COL
*P-005-{END}

*================================================================================

*P-010-{START}. NAME & NUMBER TABLE record display loop section. 
DO WHILE ALWAYS = "A"
@ LINE, COL SAY NUMBER USING '99'
STORE COL + 4 TO COL
@ LINE, COL SAY NAME
SKIP
IF EOF .OR. # = 0 .OR. # > MAXIMUM
	STORE 7 TO LINE
	STORE 2 TO COL
	STORE "B" TO ALWAYS
	LOOP
ENDIF
STORE COL + 13 TO COL
IF COL = 70
	STORE LINE + 1 TO LINE
	STORE 2 TO COL
ENDIF 
LOOP 
ENDDO
*P-010-{END}.

*===============================================================================

*P-020-{START}.  RECORD update doloop section.
GOTO TOP
SET EXACT ON
LOCATE FOR NUMBER = RECNO
SET EXACT OFF
DO WHILE ALWAYS = "B" 
STORE NAME         TO M:NAME
@ LINE, COL SAY NUMBER USING '99'
STORE COL + 4 TO COL
@ LINE, COL GET M:NAME
READ
SET EXACT ON
IF $(M:NAME,1,3) = "END"
	STORE "C" TO ALWAYS
	SET EXACT OFF
	LOOP
ENDIF
SET EXACT OFF
REPLACE NAME WITH M:NAME
STORE COL + 13 TO COL
IF COL = 70
	STORE LINE + 1 TO LINE
	STORE 2 TO COL
ENDIF 
IF LINE > 21
	STORE 7 TO LINE
CLEAR GETS
ENDIF
SKIP
IF EOF .OR. # = 0 .OR. # > MAXIMUM
	STORE "C" TO ALWAYS
	LOOP
ENDIF
LOOP
ENDDO
STORE "T" TO MORE
LOOP
*P-020-{END}

*===============================================================================

*P-030-{START}. End of program execution and exit to menu
ENDDO
USE
SET INTENSITY ON
SET COLON ON
ERASE
RELEASE ALL
RETURN
*P-030-{END} 
