* FORM/PRT.CMD ---------------  VERSION 1.0 -----------------  OCTOBER 30, 1982
* by Allen Cleveland                                     CLEVELAND & ASSOCIATES
*
* A program to print out "personalized" Form Letters to selected names maint-
* ained on a Data Base (type .DBF file) and records the fact that a letter
* (and which letter) has been printed in the Data Base record for that name.
*
* This file is "called" by FORM/LTR.CMD . This file in turn "calls" a
* LETTERXX.CMD file to do the actual printing of the form letter.
*
* This file uses the memory variables stored in FORM/LTR.MEM by FORM/LTR.CMD
* which contain the SELECT:CODE (C1) and pause selection (R1).
*
* This .CMD file uses ADBUG/1.DBF which is assumed to be on disk drive A,
* (default logged-on drive). This file also assumes a printer with 8 1/2" wide
* X 11" (66 line) paper (either continuous or individual sheets).
* The LETTERXX.CMD files is also expected to be on Drive A
*
*   Configure dBASE for interaction with operator.
SET TALK OFF
SET COLON OFF
SET ECHO OFF
SET FORMAT TO SCREEN
SET SCREEN ON
*            Get the variables as created and "saved" by FORM/LTR.CMD
*            for use below and initilize new variables.
RESTORE FROM FORM/LTR
STORE "                  " TO DATELINE
STORE T TO PAUSE
*    Clean off the file directory area (put on screen by FORM/LTR.CMD).
@ 16, 0 SAY "                                        " + ;
            "                                        "
@ 17, 0 SAY "                                        " + ;
            "                                        "
@ 18, 0 SAY "                                        " + ;
            "                                        "
@ 19, 0 SAY "                                        " + ;
            "                                        "
@ 20, 0 SAY "                                        " + ;
            "                                        "
@ 21, 0 SAY "                                        " + ;
            "                                        "
@ 22, 0 SAY "                                        " + ;
            "                                        "
*         Display operator instructions for printer set-up.
@ 17, 7 SAY " SET UP YOUR PRINTER FOR 8 1/2  PAPER,LEFT MARGIN AT COL.# 5"
@ 18, 7 SAY " SINGLE SPACE, TOP OF FORM AND PRINT HEAD OVER POSITION OF  "
@ 19, 7 SAY " 1ST POS. TO BE PRINTED. HIT RETURN WHEN READY OR ESC = ABORT"
WAIT
*   Clean off above message lines for subsequent prompts and status msgs.
@ 17, 7 SAY "                                                             "
@ 18, 7 SAY "                                                             "
@ 19, 7 SAY "                                                             "
*            Get a DATELINE for printing on the form.
@ 17, 7 SAY "Enter the date line exactly as to be printed on form"
@ 18,12 SAY "---> " GET DATELINE
READ
*       Form complete form file name from previous operator input.
STORE F1 TO S:CODE
STORE "LETTER" + F2 TO FILENAME
*      Depending on response confirm selection  for pause or no-pause.
IF !(R1) = "Y"
     STORE T TO PAUSE
     @ 17, 7 SAY "      PRINTING WILL PAUSE AFTER EA. FORM                "
ELSE
     STORE F TO PAUSE
     @ 17, 7 SAY "      PRINTING WILL CONTINUE W/O PAUSES                 "
ENDIF
*         Get the data base and set to first record in file.
USE ADBUG/1
GOTO TOP
*                    * BEGIN MAIN PROCEDURE *
DO WHILE .NOT. EOF
*       Check the SELEC:CODE and LAST:SENT fields for this record.
*           Skip this record if form has already been typed.
     IF LAST:SENT = FILENAME
          SKIP
          LOOP
     ELSE
*       Skip this record if it doesn't have a matching SELEC:CODE.
          IF SELEC:CODE <> S:CODE
               SKIP
               LOOP
          ENDIF
     ENDIF
*       Format the name and address fields for subsequent printing
     STORE TRIM(FIRST:NAME) TO NAME:1
     STORE TRIM(CITY) TO CITY:T
     STORE CITY:T + ", " + STATE + ". " + ZIP TO CITYLINE
*       Check for presence of a middle initial, if so format.
     IF MID:NAME = " "
          STORE NAME:1 + " " + TRIM(LAST:NAME) TO NAMELINE
     ELSE
          STORE NAME:1 + " " + MID:NAME + ". " + TRIM(LAST:NAME) TO NAMELINE
     ENDIF
*       Check for presence of a two line address, if not move cityline up.
     STORE ADDRESS:1 TO ADDLINE:1
     IF ADDRESS:2 = "                              "
          STORE CITYLINE TO ADDLINE:2
          STORE "                              " TO CITYLINE
     ELSE
          STORE ADDRESS:2 TO ADDLINE:2
     ENDIF
*       Get the record number which is being processed.
     STORE # TO REC:NUM
*       Report status of process (Which name and record number ).
     @ 19, 7 SAY "                                                 "
     @ 20, 7 SAY "                                                 "
     @ 19, 7 SAY "-->NOW PRINTING FORM FOR  " + NAMELINE
     @ 20,30 SAY "    (RECORD NO. " + STR(REC:NUM,3,0) + ")"
*       Save all the variables for passing to LETTERXX.CMD
     SAVE TO FORM/PRT
*       Configure dBASE for printing operations.
     SET SCREEN OFF
     SET FORMAT TO PRINT
     SET PRINT ON
     SET CONSOLE OFF
*       Get and perform the LETTERXX.CMD command file (the form letter).
     DO  &FILENAME
*       Issue a form feed to printer at completetion of printing.
     EJECT
*       Update the record to show form has been printed and which form
*       (Insert form file name in LAST:SENT field and clear DATE:SENT field).
     REPLACE LAST:SENT WITH  FILENAME
     REPLACE DATE:SENT WITH "      "
*       Configure dBASE for interaction with operator
     SET PRINT OFF
     SET FORMAT TO SCREEN
     SET SCREEN ON
*       If pause at end of each form was selected, prompt for when ready
     IF PAUSE
          @ 19, 7 SAY " *** PAUSING FOR THE INSERTION OF PAPER FOR NEXT *** "
          @ 20, 7 SAY " *** FORM, HIT 'RETURN' WHEN READY.('Q" TO ABORT)*** "
          WAIT TO RESPONSE
          IF !(RESPONSE) = "Q"
               RETURN
          ENDIF
     ENDIF
*       Clean off pause prompt.
          @ 19, 7 SAY "                                                     "
          @ 20, 7 SAY "                                                     "
*       Move to next record in data base
     SKIP
ENDDO                  * END MAIN PROCEDURE *
*  All printing for this SELEC:CODE done, return to FORM/LTR.CMD for more?
RETURN

