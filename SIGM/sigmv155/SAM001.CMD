*SAM001-Name & number table entry.**************************************
*DATE OF LAST UPDATE  05/10/83                                         *
*REVISION NUMBER 001.00                                                *
*								       *
*                         THIS PROGRAM PLACED INTO PUBLIC DOMAIN BY    *
*                         DOUGLAS G. COUSE, ATLANTA, GA 5/20/83        *
*                         COPYING FOR NON-COMMERCIAL OR EDUCATIONAL    *
*                         PURPOSES ALLOWED, PROVIDED THIS NOTICE IS    *
*                         NOT REMOVED. COMMERCIAL RESALE IS PROHIBITED.*
*                                                                      *
************************************************************************

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
STORE "ENTRY " TO PROGRAM
STORE 00 TO M:NUMBER
STORE 7 TO LINE
STORE 2 TO COL
DO SAMSCR1
*P-001-{END}.

*================================================================================

*P-005-{START}. Database accessing and doloop initialization. 
SET INTENSITY OFF
STORE "T" TO ALWAYS
USE SAMFILE INDEX SAMAKEY
GOTO TOP
LOCATE FOR NUMBER = 99
IF EOF .OR. # = 0
ELSE
	@ 22,1 SAY "-"
	REMARK SPACE EXHAUSTED, entry of data not allowed, strike any key to continue
	STORE "F" TO ALWAYS
	SET CONSOLE OFF
	WAIT
	SET CONSOLE ON
ENDIF
STORE NUMBER TO M:NUMBER
*P-005-{END}

*================================================================================

*P-010-{START}. New RECORD entry section.
DO WHILE ALWAYS = "T"
STORE M:NUMBER +01 TO M:NUMBER
STORE "          " TO M:NAME
@ LINE, COL SAY M:NUMBER USING '99'
STORE COL + 4 TO COL
@ LINE, COL GET M:NAME
READ
SET EXACT ON
IF $(M:NAME,1,3) = "END"
	STORE "F" TO ALWAYS
	SET EXACT OFF
	LOOP
ENDIF
SET EXACT OFF
APPEND BLANK
STORE STR(M:NUMBER,2) TO M:KEY
REPLACE NUMBER WITH M:NUMBER
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
IF M:NUMBER = 99
	STORE "F" TO ALWAYS
	LOOP
ENDIF
LOOP
ENDDO
*P-010-{END}

*===============================================================================

*P-020-{START}. Link to maintenance or End of program execution and exit to menu
USE
STORE "." TO RESPOND
DO WHILE RESPOND # " "
STORE " " TO RESPOND
@ 23, 1 SAY "Strike <E> key to update table, or strike <RETURN> key to EXIT......... " GET RESPOND
READ
IF RESPOND = "E"
	DO SAM002
	STORE " " TO RESPOND
	LOOP
ENDIF
IF RESPOND = " "
	LOOP
ENDIF
STORE "." TO RESPOND
LOOP
ENDDO
SET INTENSITY ON
SET COLON ON
ERASE
RELEASE ALL
RETURN
*P-020-{END} 
