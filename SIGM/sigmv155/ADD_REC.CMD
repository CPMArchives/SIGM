* ADD/REC.CMD  ------------------ VERSION 1.0 ----------------- OCTOBER 30, 1982
* By Allen Cleveland                                      CLEVELAND & ASSOCIATES
*
* This program is "called" by the ADBUG.CMD (menu) file. This file prompts
* and gets input data from operator for the creation of new records in the
* ADBUG/1.DBF data base.
*         NOTE: No data validation is performed as data is input.
*
*   Configure dBASE for interaction with operator.
SET TALK OFF
SET FORMAT TO SCREEN
SET COLON OFF
SET SCREEN ON
USE ADBUG/1
STORE T TO MORE, BAD:ENTRY
*                            * BEGIN MAIN PROCEDURE *
DO WHILE MORE
     STORE "            " TO F1
     STORE " " TO F2, R1, R2
     STORE "                " TO F3
     STORE "                              " TO F4, F5
     STORE "                  " TO F6
     STORE "  " TO F7, C1
     STORE "     " TO F8
     STORE "   " TO H1, B1
     STORE "    " TO H2, B2
     STORE DATE() TO D1
*                           "Paint" the screen.
     ERASE
     @  1, 7 SAY "+----------------------------------------------" + ;
          "--------------------+"
     @  2, 7 SAY "| Atlanta dBASE II Users Group    Membership Da" + ;
          "ta Base             |"
     @  2,64 SAY D1
     @  3, 7 SAY "+--------------------------------------------+-" + ;
          "--------------------+"
     @  4, 7 SAY "|   Program to add records to the Data Base  |" + ;
          "  EDITING AVAILABLE: |"
     @  5, 7 SAY "|   TO ADD A RECORD FILL IN THE FOLLOWING:   |" + ;
          "      (^ = Ctrl)     |"
     @  6, 7 SAY "| NAME:"
     @  6,19 GET F1
     @  6,30 SAY " "
     @  6,31 GET F2
     @  6,32 SAY "."
     @  6,33 GET F3
     @  6,52 SAY "|   RETURN or ^X jump |"
     @  7, 7 SAY "|           (First)  (M.I.)  (Last)          |" + ;
          "     to next field   |"
     @  8, 7 SAY "| ADDRESS:"
     @  8,19 GET F4
     @  8,52 SAY "|   ^E jump back to   |"
     @  9, 7 SAY "|           (Co., Apt. No. or Suite No.)*    |" + ;
          "     next field      |"
     @ 10, 7 SAY "|"
     @ 10,19 GET F5
     @ 10,52 SAY "|   ^D Cursor -->     |"
     @ 11, 7 SAY "|           (Street No. & Street Name)*      |" + ;
          "   ^S Cursor <--     |"
     @ 12, 7 SAY "|"
     @ 12,19 GET F6
     @ 12,36 SAY ", "
     @ 12,38 GET F7
     @ 12,40 SAY ". "
     @ 12,44 GET F8
     @ 12,52 SAY "|   ^G Delete under   |"
     @ 13, 7 SAY "|           (City)          (State)  (Zip)   |" + ;
          "     cursor          |"
     @ 14, 7 SAY "| PHONES"
     @ 14,19 GET H1
     @ 14,22 SAY "-"
     @ 14,23 GET H2
     @ 14,32 GET B1
     @ 14,35 SAY "-"
     @ 14,36 GET B2
     @ 14,47 GET C1
     @ 14,52 SAY "|   ^V Toggel insert  |"
     @ 15, 7 SAY "| & CODE:   (Home)      (Business)  (Code)   |"
     @ 15,74 SAY "|"
     @ 16, 7 say "|*St. No. etc. on 1st line for 1 line address|" + ;
          "   ^C to Abort Prgm. |"
     @ 17, 7 SAY "+--------------------------------------------+" + ;
          "---------------------+"
     @ 18, 7 SAY "|                  (Return = Yes, N = No)     "
     @ 18,74 SAY "|"
     @ 19, 7 SAY "|               Are all above entrees correct?"
     @ 19,55 GET R1
     @ 19,74 SAY "|"
     @ 20, 7 SAY "|"
     @ 20,74 SAY "|"
     @ 21, 7 SAY "+---------------------------------------------" + ;
           "---------------------+"
*                          Get data input from operator.
     READ
*                      * BEGIN SUB-PROCEDURE *
*                Check if operator wants to re-do entire data entry.
     DO WHILE BAD:ENTRY
          IF !(R1) = "N"
               STORE "            " TO F1
               STORE " " TO F2, R1, R2
               STORE "                " TO F3
               STORE "                              " TO F4, F5
               STORE "                  " TO F6
               STORE "  " TO F7, C1
               STORE "     " TO F8
               STORE "   " TO H1, B1
               STORE "    " TO H2, B2
               @  6,19 GET F1
               @  6,31 GET F2
               @  6,33 GET F3
               @  8,19 GET F4
               @ 10,19 GET F5
               @ 12,19 GET F6
               @ 12,38 GET F7
               @ 12,44 GET F8
               @ 14,19 GET H1
               @ 14,23 GET H2
               @ 14,32 GET B1
               @ 14,36 GET B2
               @ 14,47 GET C1
               @ 19,55 GET R1
               READ
          ELSE
               STORE F TO BAD:ENTRY
          ENDIF
     ENDDO                 * END SUB-PROCEDURE *
*            Add new record to data base with data as entered by  operator.
     APPEND BLANK
     REPLACE FIRST:NAME WITH F1, MID:NAME WITH F2, LAST:NAME WITH F3
     REPLACE ADDRESS:1 WITH F4, ADDRESS:2 WITH F5
     REPLACE CITY WITH F6, STATE WITH F7, ZIP WITH F8
     REPLACE H:PHONE WITH H1 + H2, B:PHONE WITH B1 + B2
     REPLACE SELEC:CODE WITH C1
     REPLACE ENTERED WITH $(D1,7,2) + $(D1,4,2) + $(D1,1,2)
 *          Check to see if more records to be added.
     @ 20, 7 SAY "|      Above Record has been added. Want to add another?"
     @ 20,64 GET R2
     @ 20,74 SAY "|"
     READ
     IF !(R2) = "N"
          STORE F TO MORE
     ENDIF
ENDDO                     * END MAIN PROCEEDURE *
SET TALK ON
SET COLON ON
RETURN
*     Returns to ADBUG.CMD (Menu)

