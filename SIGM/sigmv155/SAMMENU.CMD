*SAMMENU-Sample Menu Program.*********************************************
*DATE OF LAST UPDATE  05/17/83                                           *
*REVISION NUMBER 001.00                                                  *
*									 *
*                           THIS PROGRAM PLACED INTO PUBLIC DOMAIN BY    *
*                           DOUGLAS G. COUSE, ATLANTA, GA. 5/20/83       *
*                           COPYING FOR NON-COMMMERCIAL OR EDUCATIONAL   *
*                           PURPOSES ALLOWED, PROVIDED THIS NOTICE IS    *
*                           NOT REMOVED.  COMMERCIAL RESALE IS PROHIBITED*
*                                                                        *
**************************************************************************

********************************************************************************
*NOTE----any comment labelled (*P-) is a procedural section numbering reference*
*that should be used in flowcharting and other program documentation.          *
********************************************************************************

*P-001-{START}. Program and screen initialization.
ERASE
SET ECHO OFF
SET TALK OFF
CLEAR
RELEASE
USE
*P-001-{END}.

*================================================================================

*P-005-{START}.  Doloop (initialization and execution) section.
STORE "T" TO MORE
DO WHILE MORE = "T"
*P-005-{END}.

*================================================================================

*P-010-{START}. Link variable initialization SECTION.
STORE "SAM" TO PREFIX
*P-010-{END}.

*================================================================================

*P-020-{START}. Screen literal display program call & execution section.
DO SAMSCRM
*P-020-{END}.

*================================================================================

*P-030-{START}. Option message display and option entry/validation section.
STORE 00 TO SUFFIX
SET INTENSITY OFF
@ 21,05 SAY 'Enter selection ## or strike <RETURN> to END ' GET SUFFIX PICTURE '99'
READ
SET INTENSITY ON
IF SUFFIX = 00
	STORE "F" TO MORE
	LOOP 
ELSE
	IF SUFFIX >2  
		SET INTENSITY OFF
		@ 22,1 SAY "-"
		REMARK Invalid option, strike any key to repeat
		SET INTENSITY ON
		SET CONSOLE OFF
		WAIT
		SET CONSOLE ON
		ERASE
		LOOP 		
	ENDIF 2
ENDIF 1
*P-030-{END}.

*================================================================================

*P-040-{START}. Program link variable generation & execution section.
STORE PREFIX+"00"+STR(SUFFIX,1) TO PROGRAM
RELEASE PREFIX
RELEASE SUFFIX
DO &PROGRAM 
*P-040-{END}.

*================================================================================

*P-050-{START}. Re-entry point after called program has been exited.
STORE "T" TO MORE
LOOP
*P-050-{END}.

*================================================================================

*P-060-{START}. End of program execution and exit to operating system.
ENDDO
ERASE
RELEASE
CLEAR
USE
QUIT
*P-060-{END}.
