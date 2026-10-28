* MAIL/LAB.CMD ------------------- VERSION 1.0 ---------------- OCTOBER 30, 1982
*
* This command file is "called" by ADBUG.CMD.
*
* A program to print out mailing labels for the form letters as printed using
* the FORM/LTR.CMD. This program assumes the use of "ONE-UP" pin feed,
* continuous type labels which are at least 15/16 " high by 3.5" wide.
*
* A label is printed ONLY for those records in the data base which have the
* "DATE:SENT" field blank (filled with spaces). As each label is printed, the
* blank is replaced with the current (sign-on) date .
*
* This .CMD file uses ADBUG/1.DBF which is assumed to be on disk drive A,
* (default logged-on drive).
*
*  Get the sign-on date and format for insertion into record.
STORE DATE() TO WDATE
STORE $(WDATE,7,2) + $(WDATE,1,2) + $(WDATE,4,2) TO INDATE
*  Prompt operator for printer set-up.
@ 17,12 SAY "SET UP PRINTER AND LABELS FOR PRINTING           "
@ 18,12 SAY "WHEN READY HIT 'RETURN' (ESC TO ABORT)           "
WAIT
*  Clear previous prompt.
@ 17,12 SAY "                                                 "
@ 18,12 SAY "                                                 "
*  Get data base and set to 1st record.
USE ADBUG/1
GOTO TOP
*                          * BEGIN MAIN PROCEDURE *
*  Ckeck DATE:SENT field, if not blank then no form printed, hence no label.
DO WHILE .NOT. EOF
     IF DATE:SENT <> "      "
          SKIP
          LOOP
     ENDIF
     STORE # TO REC:NUM
*       Format name and address fields for printing.
     STORE TRIM(FIRST:NAME) TO NAME:1
     STORE TRIM(CITY) TO CITY:T
     STORE CITY:T + ", " + STATE + ". " + ZIP TO CITYLINE
     IF MID:NAME = " "
          STORE NAME:1 + " " + LAST:NAME TO NAMELINE
     ELSE
          STORE NAME:1 + " " + MID:NAME + ". " + LAST:NAME TO NAMELINE
     ENDIF
     STORE TRIM (ADDRESS:1) TO ADDLINE:1
     IF ADDRESS:2 = "                              "
          STORE CITYLINE TO ADDLINE:2
          STORE "                              " TO CITYLINE
     ELSE
          STORE TRIM(ADDRESS:2) TO ADDLINE:2
     ENDIF
     @ 16,12 SAY "PRINTING A LABEL FOR RECORD " + STR(REC:NUM,3,0)
     @ 17,12 SAY "    (" + NAMELINE + ")"
*       Configure dBASE for printing operations.
     SET FORMAT TO PRINT
     SET CONSOLE OFF
     SET PRINT ON
*       Actual printing here.
     ?? "                        " + SELEC:CODE + "-" + STR(REC:NUM,2,0)
     ? NAMELINE
     ? ADDLINE:1
     ? ADDLINE:2
     ? CITYLINE
     ?
     ?
*       Update the record to show that label printed and when,
*       Then move to next record  and continue proceedure.
     REPLACE DATE:SENT WITH INDATE
     SKIP
     SET FORMAT TO SCREEN
     SET PRINT OFF
ENDDO                     * END MAIN PROCEDURE *
* Configure dBASE for return to calling program.
SET SCREEN ON
SET CONSOLE ON
*        Returns to ADBUG.CMD (MENU)
RETURN

