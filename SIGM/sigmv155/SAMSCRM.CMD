*SAMSCRM-SAMPLE PROGRAM MENU-SCREEN  REFER TO PUBLIC DOMAIN NOTICE
*DATE OF LAST UPDATE 05/10/83        DATED 5/20/83 BY DOUGLAS G. COUSE
*REVISION NUMBER 001.00              PROGRAM # SAM001 OR SAM002 OR SAMMENU

*NOTE----any comment labelled (*P-) is a procedural section numbering reference
*that should be used in flowcharting and other program documentation.

*P-001-{START}. Screen literal display section.
SET INTENSITY OFF
@  1,25 SAY "*********************"
@  2,25 SAY "*     THE MENU      *"
@  3,25 SAY "*********************"
@  7, 0 SAY "----------------------------------------------------------------------------"
@ 22, 0 SAY "----------------------------------------------------------------------------"
SET INTENSITY ON
@ 14,05 SAY "1. Enter New Name & Number Data "
@ 15,05 SAY "2. Update or inquire about Old Name & Number Data"
RETURN
*P-001-{END}.
