* ADBUG.CMD ------------------- VERSION 1.0 ------------------- OCTOBER 30, 1982
* by Allen Cleveland                                      CLEVELAND & ASSOCIATES
*
* A program to place a menu on the screen then get the operator selection of
* function:(A) add a record, (F) print form, (M) print mailing lables or
* (L) print listing of data base.
*
* This program is called directly by operator from the dBASE command level.
* This program in turn (depending on function selected) calls on of the
* following: ADD/REC.CMD, FORM/LTR.CMD, MAIL/LAB.CMD, or LIST/PRT.CMD.
*
*
SET TALK OFF
SET ECHO OFF
SET FORMAT TO SCREEN
SET COLON OFF
SET SCREEN ON
STORE " " TO SELECTION
STORE DATE() TO D1
STORE T TO BUSY
*                            * BEGIN MAIN PROCEDURE *
DO WHILE BUSY
     STORE T TO NO:CODE
*                           "Paint" the screen.
     ERASE
     @  1, 7 SAY "+------------------------------------------------------" + ;
                 "------------+"
     @  2, 7 SAY "| Atlanta dBASE II Users Group    Membership Data Base"
     @  2,64 SAY D1
     @  2,74 SAY "|"
     @  3, 7 SAY "+------------------------------------------------------" + ;
                 "------------+"
     @  4, 7 SAY "|                 MENU OF FUNCTIONS AVAILABLE"
     @  4,74 SAY "|"
     @  5, 7 SAY "|"
     @  5,74 SAY "|"
     @  6, 7 SAY "|    (A)-ADD a record to the data base."
     @  6,74 SAY "|"
     @  7, 7 SAY "|          (Add a new name, address and other date to list)"
     @  7,74 SAY "|"
     @  8, 7 SAY "|    (F)-FORM letter or notice from an existing" + ;
                 " LETTERXX.CMD file. |"
     @  9, 7 SAY "|          (Print forms addressed to selected names in" + ;
                 " data base)  |"
     @ 10, 7 SAY "|    (M)-MAILING lables for forms."
     @ 10,74 SAY "|"
     @ 11, 7 SAY "|          (Print mailing labels for forms which have " + ;
                 "been printed)|"
     @ 12, 7 SAY "|    (L)-LISTING of data base records."
     @ 12,74 SAY "|"
     @ 13, 7 SAY "|          (Print out a listing of contents of all records)"
     @ 13,74 SAY "|"
     @ 14, 7 SAY "|    (Q)-QUIT and return to dBASE II"
     @ 14,74 SAY "|"
     @ 15, 7 SAY "|"
     @ 15,74 SAY "|"
     @ 16, 7 SAY "|                     SELECT ONE -->"
     @ 16,44 GET SELECTION
     @ 16,74 SAY "|"
     @ 17, 7 SAY "|"
     @ 17,74 SAY "|"
     @ 18, 7 SAY "|"
     @ 18,74 SAY "|"
     @ 19, 7 SAY "|"
     @ 19,74 SAY "|"
     @ 20, 7 SAY "+-----------------------------------------------------" + ;
                 "-------------+"
*                               Get menu selection.
     READ
*                             * BEGIN SUB-PROCEDURE *
     DO WHILE NO:CODE
*                    Make sure that selection code is upper case.
          STORE !(SELECTION) TO MENU:CODE
*                  Check selection code against each valid choice.
          IF MENU:CODE = "A"
               STORE F TO NO:CODE
               @ 16,22 SAY "   ADD RECORD SELECTED    "
               DO ADD/REC
          ELSE
               IF MENU:CODE = "F"
                    STORE F TO NO:CODE
                    @ 16,22 SAY "    PRINT FORM LETTER SELECTED"
                    DO FORM/LTR
               ELSE
                    IF MENU:CODE = "M"
                         STORE F TO NO:CODE
                         @ 16,22 SAY "    PRINT MAILING LABELS SELECTED"
                         DO MAIL/LAB
                    ELSE
                         IF MENU:CODE = "L"
                              STORE F TO NO:CODE
                              @ 16,24 SAY "    PRINT DATA BASE SELECTED"
                              DO LIST/PRT
                         ELSE
                              IF MENU:CODE = "Q"
                                   STORE F TO NO:CODE
                                   STORE F TO BUSY
                              ELSE
*                                     Selection code is not valid.
                                   STORE " " to SELECTION
                                   @ 15,20 SAY "Enter ONLY an A, F, M, L or Q"
                                   @ 16,44 GET SELECTION
                                   READ
                                   LOOP
                              ENDIF
                         ENDIF
                    ENDIF
               ENDIF
          ENDIF
     STORE " " TO SELECTION
     ENDDO                * END SUB-PROCEDURE *
ENDDO                     * END MAIN PROCEDURE *
*     Make sure dBASE is re-configured the way you found it before "quiting".
SET CONSOLE ON
SET COLON ON
SET FORMAT TO SCREEN
SET SCREEN ON
SET PRINT OFF
SET TALK ON
*           "Returns" back to command level of dBASE
RETURN
