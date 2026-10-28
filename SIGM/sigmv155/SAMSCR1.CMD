*SAMSCR1-Name & number table SCREEN OVERLAY. REFER TO PUBLIC DOMAIN NOTICE
*DATE OF LAST UPDATE  05/10/83               DATED 5/20/83 BY DOUGLAS G. COUSE
*REVISION NUMBER 001.00                      PROGRAM # SAM001 OR SAM002 OR SAMMENU

*NOTE----any comment labelled (*P-) is a procedural section numbering reference
*that should be used in flowcharting and other program documentation.

*P-001-{START}.  Initial screen literal display.
*and execution procedure
SET INTENSITY OFF
@  1,13 SAY "**************************************"
@  2,13 SAY "**    NAME & NUMBER TABLE "+PROGRAM+"    **"
@  3,13 SAY "**************************************"
@  4, 0 SAY "---------------------------------------------------------------------"
@  5, 0 SAY "|Number  Name    |Number  Name    |Number  Name    |Number  Name    |"
@  6, 0 SAY "---------------------------------------------------------------------"
@  7, 0 SAY "|   -            |   -            |   -            |   -            |"
@  8, 0 SAY "|   -            |   -            |   -            |   -            |"
@  9, 0 SAY "|   -            |   -            |   -            |   -            |"
@ 10, 0 SAY "|   -            |   -            |   -            |   -            |"    
@ 11, 0 SAY "|   -            |   -            |   -            |   -            |"
@ 12, 0 SAY "|   -            |   -            |   -            |   -            |"
@ 13, 0 SAY "|   -            |   -            |   -            |   -            |"
@ 14, 0 SAY "|   -            |   -            |   -            |   -            |"
@ 15, 0 SAY "|   -            |   -            |   -            |   -            |"
@ 16, 0 SAY "|   -            |   -            |   -            |   -            |"
@ 17, 0 SAY "|   -            |   -            |   -            |   -            |"
@ 18, 0 SAY "|   -            |   -            |   -            |   -            |"
@ 19, 0 SAY "|   -            |   -            |   -            |   -            |"
@ 20, 0 SAY "|   -            |   -            |   -            |   -            |"
@ 21, 0 SAY "|   -            |   -            |   -            |   -            |"
@ 22, 0 SAY "---------------------------------------------------------------------"
SET INTENSITY ON 
RETURN
*P-001-{END}
