* FORM/LTR.CMD ----------------- VERSION 1.0 ----------------- OCTOBER 30, 1982
* by Allen V. Cleveland                                  CLEVELAND & ASSOCIATES
*
* This program sets up screen to prompt and get operator selections for
* the printing of a form letter as contained in the LETTERXX.CMD files.
*
* This file is "called" by ADBUG.CMD (Menu) file. This file "calls"
* FORM/PRT.CMD in turn which controls accessing data base and printing.
*
*   Configure dBASE for interaction with operator.
SET TALK OFF
SET SCREEN ON
SET FORMAT TO SCREEN
SET COLON OFF
STORE T TO MOREFORM
*                         * BEGIN MAIN PROCEDURE *
DO WHILE MOREFORM
STORE T TO BAD:ENTRY
STORE "  " TO F1, F2
STORE " " TO R1, R2, RESPONSE
STORE DATE() TO D1
*                          "Paint" the screen.
     ERASE
     @  2, 7 SAY "+---------------------------------------------" + ;
          "---------------------+"
     @  3, 7 SAY "| Atlanta dBASE II Users Group   Membership Da" + ;
         "ta Base"
     @  3,63 SAY D1
     @  3,74 SAY "|"
     @  4, 7 SAY "+---------------------------------------------" + ;
          "---------------------+"
     @  5, 7 SAY "| Program to PRINT FORM LETTER ---- Make the f" + ;
          "ollowing selections: |"
     @  6, 7 SAY "|"
     @  6,74 SAY "|"
     @  7, 7 SAY "|  SELECTOR CODE (Two character code)........." + ;
          ".............."
     @  7,68 GET F1
     @  7,74 SAY "|"
     @  8, 7 SAY "|"
     @  8,74 SAY "|"
     @  9, 7 SAY "|  FORM NUMBER (last two digits of file name shown below)..."
     @  9,68 GET F2
     @  9,74 SAY "|"
     @ 10, 7 SAY "|"
     @ 10,74 SAY "|"
     @ 11, 7 SAY "|  PAUSE after printing ea. form for seperate shts. (Y or N)."
     @ 11,68 GET R1
     @ 11,74 SAY "|"
     @ 12, 7 SAY "|"
     @ 12,74 SAY "|"
     @ 13, 7 SAY "|      Are all selections correct? (Return = yes, N =No)"
     @ 13,66 GET R2
     @ 13,74 SAY "|"
     @ 14, 7 SAY "|                     (Control-C will abort)"
     @ 14,74 SAY "|"
     @ 15, 7 SAY "+---------------------------------------------" + ;
          "---------------------+"
     @ 16,11 SAY "The form files (LETTERXX.CMD) available on this disk are:"
*        Show directory of LETTERXX type files for operator selection.
     DISPLAY FILES LIKE LETTER??.CMD
*             Get selections from operator.
     READ
*                            * BEGIN SUB-PROCEDURE *
*           Check to see if operator wants to re-do all entries.
     DO WHILE  BAD:ENTRY
     IF !(R2) = "N"
          STORE "  "TO F1, F2
          STORE " " TO R1, R2
          @  7,68 GET F1
          @  9,68 GET F2
          @ 11,68 GET R1
          @ 13,66 GET R2
          READ
     ELSE
          STORE F TO BAD:ENTRY
     ENDIF
     ENDDO                   * END SUB-PROCEDURE *
*         Save the selection variables for use by next program
     SAVE TO FORM/LTR
*         "Call" the FORM/PRT.CMD file to control printing.
     DO FORM/PRT
*   See if there are more forms to be printed.
@ 19, 7 SAY "                                                             "
@ 20, 7 SAY "                                                             "
@ 19, 7 SAY "    DO YOU WANT TO PRINT MORE FORMS NOW?"
@ 20, 7 SAY "    ('RETURN = Yes, 'N' = No) --> " GET RESPONSE
READ
IF !(RESPONSE) = "N"
     STORE F TO MOREFORM
ENDIF
ENDDO                  *END MAIN PROCEDURE*
*        Returns to ADBUG.CMD (Menu)
RETURN
