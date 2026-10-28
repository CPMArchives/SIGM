* LIST/PRT.CMD ...............VERSION 1.0 .................... OCTOBER 30, 1980
* by Allen Cleveland                                     CLEVELAND & ASSOCIATES
*
* A program to print out the contents of the ADBUG/1.DBF data base.
* The program assumes continuous 8 1/2" wide (9 1/2" pin feed ) X 11" paper.
*
* This program is called by ADBUG.CMD (Menu) and uses ADBUG/1.DBF.
*
*
SET TALK OFF
SET FORMAT TO SCREEN
SET SCREEN ON
@ 17, 8 SAY "  SET UP PRINTER FOR 8 1/2 IN. WIDE CONTINUOUS  "
@ 18, 8 SAY "  PAPER ....HIT RETURN WHEN READY (ESC TO ABORT)"
WAIT
@ 19, 7 SAY "|"
SET FORMAT TO PRINT
SET PRINT ON
SET CONSOLE OFF
STORE DATE() TO RPT:DATE
USE ADBUG/1
*  Compute total number of pages in report for sheet numbering
*  and set up counters.
COUNT TO REC:CNT
IF REC:CNT/10 = INT(REC:CNT/10)
    STORE REC:CNT/10 TO TOTPAGE
ELSE
    STORE INT(REC:CNT/10) + 1 TO TOTPAGE
ENDIF
STORE STR(TOTPAGE,2,0) TO TP
STORE 1 TO PAGENO
STORE 0 TO LINECNT
GOTO TOP
DO WHILE .NOT. EOF
*        Format address field into one variable of 30 char. length
     STORE ", " + STATE TO STATE:T
     STORE ".  " + ZIP TO ZIP:T
     STORE CITY - STATE:T - ZIP:T TO CITYLINE
*        Format the name fields for printing (last name first).
     STORE TRIM(FIRST:NAME) TO NAME:1
     IF MID:NAME = " "
          STORE TRIM(LAST:NAME) + ", " + NAME:1 TO NAMELINE
     ELSE
          STORE TRIM(LAST:NAME) + ", " + NAME:1 + " " + MID:NAME + "." ;
                TO NAMELINE
     ENDIF
*          Check for presence of a 2 line address, if not move cityline up.
     STORE ADDRESS:1 TO ADDRLINE:1
     IF ADDRESS:2 = "                              "
          STORE CITYLINE TO ADDRLINE:2
          STORE "                              " TO CITYLINE
     ELSE
          STORE ADDRESS:2 TO ADDRLINE:2
     ENDIF
*          Get the record number which is being printed.
     STORE # TO REC:NUM
     STORE STR(REC:NUM,2,0) TO RN
*         Format phone numbers and dates for printing.
*         Variable names with length as data length to assist formating line.
     STORE SELEC:CODE TO SD
     IF H:PHONE = "       " .OR. !(H:PHONE) = "UNKNOWN"
          STORE "Unknown " to PHONE:HO
     ELSE
          STORE $(H:PHONE,1,3) + "-" + $(H:PHONE,4,4) TO PHONE:HO
     ENDIF
     IF B:PHONE = "       " .OR. !(B:PHONE) = "UNKNOWN"
          STORE "Unknown " to PHONE:BU
     ELSE
          STORE $(B:PHONE,1,3) + "-" + $(B:PHONE,4,4) TO PHONE:BU
     ENDIF
     STORE $(ENTERED,3,2) + "/" + $(ENTERED,5,2) + "/" + $(ENTERED,1,2) ;
           TO ENT:DATE
     STORE $(DATE:SENT,3,2) + "/" + $(DATE:SENT,5,2) + "/" + ;
           $(DATE:SENT,1,2) TO SND:DATE
*         Check for beginning of a sheet to output col headers.
     STORE STR(PAGENO,2,0) TO PN
     IF LINECNT = 0
          ?
          ?
          ?
          ?
          ??  "ATLANTA dBASE II USERS GROUP               "
          ??  RPT:DATE + "              Page " + PN + " of " + TP
          ?
          ?
          ?? "NO.  MEMBER                        STAT. CODE  "
          ?? "HOME      BUSINESS  LAST FORM:"
          ?
          ?? "     NAME & ADDRESS:               ENTER DATE  "
          ?? "PHONE:    PHONE:    DATE SENT:"
          ?
          ?
     ENDIF
*       Print one record on next five lines
     ?  RN + "  " + NAMELINE
     ?  "     " + ADDRLINE:1 + "    " + SD + "      "
     ?? PHONE:HO + "   " + PHONE:BU + "  " + LAST:SENT
     ?  "     " + ADDRLINE:2 + " " + ENT:DATE
     ?? "                        " + SND:DATE
     ?  "     " + CITYLINE
     ?
*       Add one to the number of records printed this page.
     STORE LINECNT + 1 TO LINECNT
*       Check to see if page is full (10 records to a page).
     IF LINECNT = 10
*             If at end of page is it also last page in report.
           IF PAGENO = TOTPAGE
               ?
               ?
               ? "                                    (END)"
               EJECT
               STORE 0 TO LINECNT
           ELSE
*                End of page but not end of report.
               ?
               ? "                             ( Cont. on next page)"
               EJECT
               STORE 0 TO LINECNT
               STORE PAGENO + 1 TO PAGENO
           ENDIF
     ENDIF
*          Get next record.
     SKIP
ENDDO                     * END MAIN PROCEDURE *
*  If final record was not also end of page (see above) print "end".
IF LINECNT <> 10
    ?
    ?? "                                    (END)"
    EJECT
ENDIF
*      Return to ADBUG>CMD (Menu)
SET PRINT OFF
SET FORMAT TO SCREEN
SET SCREEN ON
SET COLON OFF
RETURN
