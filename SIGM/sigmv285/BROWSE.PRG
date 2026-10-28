**    Last revision: July 4, 1986 at 10:42

* Name:    BROWSE.prg    a dBASEIII Browse emulation for Clipper
* Use :    RUN BROWSE <filename>
*          DO Browse WITH <filename>

* 07/04/86 by: H.M. Van Tassell
* This browse was inspired by a browse procedure written by S.J. Straley.
* It ia a completely rewritten version of the his original procedure.

* This program is freely placed in the Public Domain with no
* rights reserved. It is a non-copyrighted work!

* NOTE: uses CALLs to Curson & CursOff which are contained in the
* author's CLIP-BRO.ARC CURSOR.OBJ ready for linking to this program.

********[ If using browse as a procedure in another pgm ]***********
**                                                                **
** If database file is already open, comment out "DO B_OpnFil"    **
**   which is about 37 lines forward.                             **
**                                                                **
** Suggest that SET ScoreBoard=Off, Confirm=On, Deleted = Off     **
**   this should be done prior to calling Browse                  **
**                                                                **
********************************************************************

  SET SCOREBOARD OFF 
  SET CONFIRM ON     

**  PROCEDURE Browse                                               
PARAMETER file
PRIVATE temp, last_fld, curr_rec, curr_top, col_pos, row_pos, cur_field   
PRIVATE last_posit, frst_posit, cur_posit, in_val, in_command, last_row
PRIVATE curr_bot, Field_Length
*                                                                             *
*    last_fld    :   provides the number of fields available in given file.   *
*    curr_rec    :   curr_rec record number of database highlited                       *
*    curr_top    :   record number currently first on screen
*    curr_bot    :   record number currently last on screen
*    col_pos     :   column position of cursor on screen                      *
*    row_pos     :   row position of cursor on screen                          *
*    last_row    :   row count of current last row
*    cur_field   :   the field number currently BROWSE is resting on in       *
*                    CURRENT record of used FILE.                             *
*    last_posit  :   the field number allowed to be shown in the last         *
*                    column position                                          *
*    frst_posit  :   the field number allowed to be shown in the first        *
*                    column position                                          *
*    in_val      :   the name of the field at any given cur_field              *
*    in_command  :   the variable to store the INKEY()                        *
*    Field_Length[]  an array of field lengths
*
file = UPPER(TRIM(file))
IF AT(".",file) = 0
   file = file + ".DBF"
ENDIF
**  If database file is already open, comment out "DO B_OpnFil"
  DO B_OpnFil
**
CALL CursOff
DO B_DrMenu
@ 0,62 SAY TRIM(file)

curr_rec   = RECNO()
curr_top   = curr_rec 

* for speed, setup an array of field lengths
last_fld = B_FLDCNT()
DECLARE Field_Length[last_fld]
FOR cur_posit = 1 TO last_fld
  Field_Length[cur_posit] = B_FLDLEN(cur_posit)
NEXT
col_pos    = 1
cur_field  = 1
row_pos    = 9
frst_posit = 1
last_posit = 0

last_posit = B_R_PAN()
DO B_RecNum
DO B_DrHead
GoTo curr_rec
DO B_ReDraw
GoTo curr_rec
DO B_ShoRev

DO WHILE .T.
   DO B_ClrKey
   in_command = UPPER(CHR(INKEY(0)))
   DO B_ClrKey

   DO CASE
   CASE in_command = CHR(27)  && ESC quit/exit
      CLEAR
      CALL CursOn
      RETURN

   CASE in_command = "G"   && GoTo record
     temp = curr_rec
     @ 23,18 SAY "GoTo which record ?"
     @ 24,27 SAY "Range 1 to "
     @ 24,38 SAY RECCOUNT() PICTURE "@B"
     CALL CursOn
     @ 23,38 GET temp PICTURE "9999999" 
     READ
     DO WHILE temp <1 .OR. temp > RECCOUNT()
       @ 23,38 GET temp PICTURE "9999999"
       READ
     ENDDO
     CLEAR GETS
     CALL CursOff
     @ 23,0
     @ 24,0
     IF temp <> curr_rec
       curr_rec = temp
       curr_top = curr_rec
       GoTo curr_rec
       DO B_RecNum
       DO B_ReDraw
       row_pos = 9
       GoTo curr_rec
       DO B_ShoRev
     ENDIF

   CASE in_command = CHR(25)   && ^Y  delete field
      in_val = FIELDNAME(cur_field)
      DO CASE
      CASE TYPE(in_val) = "C"
         REPLACE &in_val WITH SPACE(Field_Length[cur_field])
      CASE TYPE(in_val) = "N"
         REPLACE &in_val WITH 0.00
      CASE TYPE(in_val) = "D"
         REPLACE &in_val WITH CTOD("  /  /  ")
      CASE TYPE(in_val) = "L"
         REPLACE &in_val WITH .F.
      ENDCASE
      DO B_ShoRev

   CASE in_command = "E"
      IF TYPE(in_val) <> "M"
        @ row_pos, col_pos GET &in_val
        CALL CursOn
        READ
        CALL CursOff
        tempin = FIELDNAME(cur_field)
        REPLACE &tempin WITH &in_val
        CLEAR GETS
      ENDIF

   CASE in_command = CHR(21)  && ^U  delete record
      IF DELETED()
         RECALL
         @ row_pos,0 SAY " "
         @ 00,50 SAY "     "
      ELSE
         DELETE
         @ row_pos,0 SAY "*"
         @ 00,50 SAY "*DEL*"
      ENDIF

   CASE in_command = CHR(4)  && RtArrow
      IF cur_field < last_fld
         IF cur_field < last_posit
            DO B_SayRt
            cur_field = cur_field + 1
            DO B_ShoRev
         ELSE
            * pan right
            IF Field_Length[last_posit]+Field_Length[last_posit+1] > 80
              frst_posit = last_posit + 1
            ELSE
              frst_posit = last_posit
            ENDIF
            cur_field = frst_posit
            last_posit = B_R_PAN()
            DO B_DrHead
            GoTo curr_top
            DO B_ReDraw
            GoTo curr_rec
            col_pos = 1
            DO B_ShoRev
         ENDIF
      ENDIF

   CASE in_command = CHR(19) && LtArrow
      IF cur_field  > 1
         IF cur_field > frst_posit
            cur_field = cur_field - 1
            DO B_SayLt
            DO B_ShoRev
          ELSE 
            ** cur_field is equal to frst_posit so pan left
            IF Field_Length[frst_posit]+Field_Length[frst_posit-1] > 80
              last_posit = frst_posit - 1
            ELSE
              last_posit = frst_posit
            ENDIF
            cur_field = last_posit   
            frst_posit = B_L_PAN()  
            cur_field = frst_posit
            IF cur_field = 1
              * make sure max fields displayed on screen
              last_posit = B_R_PAN()
            ENDIF
            DO B_DrHead
            GoTo curr_top
            DO B_ReDraw
            GoTo curr_rec
            col_pos = 1
            DO B_ShoRev
         ENDIF
      ENDIF

   CASE in_command = CHR(2)  && ^RtArrow pan right
      IF last_posit < last_fld
         IF Field_Length[last_posit]+Field_Length[last_posit+1] > 80
           frst_posit = last_posit + 1
         ELSE
           frst_posit = last_posit
         ENDIF
        cur_field = frst_posit
        last_posit = B_R_PAN()
        DO B_DrHead
        GoTo curr_top
        DO B_ReDraw
        GoTo curr_rec
        col_pos = 1
        DO B_ShoRev
      ENDIF

   CASE in_command = CHR(26) && ^LtArrow  pan left
      IF frst_posit  > 1
        IF Field_Length[frst_posit]+Field_Length[frst_posit-1] > 80
          last_posit = frst_posit - 1
        ELSE
          last_posit = frst_posit
        ENDIF
        cur_field = last_posit   
        frst_posit = B_L_PAN()  
        cur_field = frst_posit
         IF cur_field = 1
           * make sure max fields displayed on screen
           last_posit = B_R_PAN()
        ENDIF
        DO B_DrHead
        GoTo curr_top
        DO B_ReDraw
        GoTo curr_rec
        col_pos = 1
        DO B_ShoRev
      ENDIF

   CASE in_command = CHR(18) && PgUp   
      GoTo curr_top
      SKIP - 12
      curr_rec = RECNO()
      curr_top=curr_rec
      DO B_RecNum
      DO B_ReDraw
      row_pos = 9
      GoTo curr_rec
      DO B_ShoRev

   CASE in_command = CHR(3)  && PgDn   
      GoTo curr_bot
      SKIP + 1
      IF EOF()
        SKIP - 1
      ENDIF
      curr_rec = RECNO()
      curr_top = curr_rec
      DO B_RecNum
      DO B_ReDraw
      row_pos = 9
      GoTo curr_rec
      DO B_ShoRev


   CASE in_command =  CHR(31)  && ^PgUp go to top of file
      GoTo TOP
      curr_rec = RECNO()
      curr_top=curr_rec
      DO B_RecNum
      DO B_ReDraw
      row_pos = 9
      GoTo curr_rec
      DO B_ShoRev

   CASE in_command = CHR(30)  && ^PgDn go to bottom of file
      GoTo BOTTOM
      curr_rec = RECNO()
      curr_top = curr_rec
      DO B_RecNum
      DO B_ReDraw
      row_pos = 9
      GoTo curr_rec
      DO B_ShoRev

   CASE in_command = CHR(24) && DnArrow
      SKIP
      IF EOF()
         SKIP - 1
      ELSE
         SKIP - 1
         row_pos = row_pos + 1
         DO B_DnRec
         SKIP + 1
         curr_rec = RECNO()
         DO B_RecNum
         DO B_ShoRev
      ENDIF

   CASE in_command = CHR(5)  && UpArrow
      SKIP - 1
      IF BOF()
         GoTo curr_rec
      ELSE
         SKIP + 1
         row_pos = row_pos - 1
         DO B_UpRec
         SKIP - 1
         curr_rec = RECNO()
         DO B_RecNum
         DO B_ShoRev
      ENDIF

   CASE in_command = CHR(1) && HOME move to first  screen row
      IF TYPE(in_val) = "M"
         @ row_pos,col_pos SAY "memo"
      ELSE
         @ row_pos,col_pos SAY &in_val
      ENDIF
      row_pos = 9
      GoTo curr_top 
      curr_rec = RECNO()
      DO B_RecNum
      DO B_ShoRev

   CASE in_command = CHR(6) && END  move to bottom screen row
      IF TYPE(in_val) = "M"
         @ row_pos,col_pos SAY "memo"
      ELSE
         @ row_pos,col_pos SAY &in_val
      ENDIF
      GoTo curr_bot
      curr_rec = RECNO()
      row_pos = last_row
      DO B_RecNum
      DO B_ShoRev

   OTHERWISE
   ENDCASE

**  Debuging stuff
**     @ 23,1  SAY "Frst_posit =" + STR( frst_posit,3)
**     @ 23,20 SAY "Last_posit =" + STR( last_posit,3)
**     @ 23,40 SAY "cur_field =" + STR( cur_field,3) 
**     @ 23,60  SAY "last_fld = " + STR( last_fld,3) 
**
**     @ 24,1  SAY "Row_pos =" + STR( row_pos,3) 
**     @ 24,20  SAY "curr_top =" + STR( curr_top,3) 
**     @ 24,40 SAY "Col_pos =" + STR( col_pos,3) 
**     @ 24,60 SAY "in_val = " + in_val + SPACE(10-LEN(in_val))

ENDDO

********* begin procedures and functions ******************

PROCEDURE B_OpnFil

  IF file = "."
     file = SPACE(14)
     @ ROW(),0 SAY "No database is in USE.  Enter file name: " GET file PICTURE "!!!!!!!!!!!!!!"
     READ
     file = TRIM(file)
     IF AT(".",file) = 0
        file = file + ".DBF"
     ENDIF
  ENDIF
  IF .NOT. FILE("&file")
     ? file + " not found"
     WAIT
     QUIT
  ENDIF
  USE &file
  RETURN

PROCEDURE B_ClrKey
   * clear out the key board buffer
   PRIVATE temp
   temp = 1
   DO WHILE temp <> 0
     temp = INKEY()
   ENDDO
   RETURN

PROCEDURE B_DrMenu
CLEAR
@ 0,1 SAY "Record No.                   BROWSE                                             "
@ 1,0 SAY "ษออออออออออออออออออหออออออออออออออออออออหออออออออออออออออออหอออออออออออออออออออป"
@ 2,0 SAY "บ CURSOR   Lt  Rt  บ        UP   DOWN   บ      DELETE      บ      ACTION       บ"
@ 3,0 SAY "บ  Char:   -  -  บ Rec:             บ Char:     DEL    บ GoTo Rec #:   G   บ"
@ 4,0 SAY "บ  Field:  -  -  บ Page:  PgUp  PgDn  บ Field:     ^Y    บ Edit Field:   E   บ"
@ 5,0 SAY "บ  Pan:   ^- ^-  บ File: ^PgUp ^PgDn  บ Record:    ^U    บ Quit/Exit:   ESC  บ"
@ 6,0 SAY "ศออออออออออออออออออสออออออออออออออออออออสออออออออออออออออออสอออออออออออออออออออผ"
RETURN              

PROCEDURE B_DrHead
   * Draws the table header of fieldnames
   PRIVATE temp, cur_posit, fldlen, namelen
   temp = 1
   @ 7,0 CLEAR
   FOR cur_posit = frst_posit TO last_posit
      in_val = FIELDNAME(cur_posit)
      fldlen = Field_Length[cur_posit]
      namelen = LEN(in_val)
      @ 7,temp SAY TRIM(in_val) + REPLICATE("-",fldlen-namelen)
      @ 8,temp SAY REPLICATE("อ",fldlen)
      temp = temp + fldlen +1
   NEXT
   RETURN

PROCEDURE B_ReDraw
   * Draws the table of fields down and across the screen
   PRIVATE down, across, cur_posit
   @ 9,0 CLEAR
   FOR down = 9 TO 20
      last_row = down
      curr_bot = RECNO()
      IF DELETED()
         @ down,0 SAY "*"
      ENDIF
      across = 1
      FOR cur_posit = frst_posit TO last_posit
         in_val = FIELDNAME(cur_posit)
         IF TYPE(in_val) = "M"
            @ down,across SAY "memo"
         ELSE
            @ down,across SAY &in_val
         ENDIF
         across = across + Field_Length[cur_posit] + 1 
      NEXT
      SKIP + 1
      IF EOF()
         down = 21
         SKIP - 1
      ENDIF
   NEXT
   RETURN

PROCEDURE B_UpRec
   * B_UpRec goes up a record *
   IF row_pos < 9
      SKIP - 1
      curr_top = RECNO()
      DO B_ReDraw
      GoTo curr_rec
      row_pos = 9
   ELSE
      IF TYPE(in_val) = "M"
         @ row_pos+1,col_pos SAY "memo"
      ELSE
         @ row_pos+1,col_pos SAY &in_val
      ENDIF
   ENDIF
   RETURN

PROCEDURE B_DnRec
   * B_DnRec getting things ready to go down *
   IF row_pos > 20
      SKIP
      curr_top = RECNO()
      DO B_ReDraw
      GoTo curr_rec
      row_pos = 9
   ELSE
      IF TYPE(in_val) = "M"
         @ row_pos-1,col_pos SAY "memo"
      ELSE
         @ row_pos-1,col_pos SAY &in_val
      ENDIF
   ENDIF
   RETURN

PROCEDURE B_RecNum
   * B_RecNum displays the current reccord number to the screen *
   @ 0,12 SAY SPACE(8)
   @ 0,12 SAY curr_rec PICT "@B"
   IF DELETED()
     @ 00,50 SAY "*DEL*"
   ELSE
     @ 00,50 SAY "     "
   ENDIF
   RETURN

PROCEDURE B_ShoRev
   PRIVATE tempit
   * B_ShoRev will Reverse video the field...of current position    *
   * displays accordingly to the screen at row_pos and col_pos  *
   in_val = FIELDNAME(cur_field)
   IF TYPE(in_val) = "M"
      tempit = "memo"
      @ row_pos,col_pos GET tempit
   ELSE
      @ row_pos,col_pos GET &in_val
   ENDIF
   CLEAR GETS
   RETURN

PROCEDURE B_SayLt
   * B_SayLT will SAY field and increment col_pos to the left *
   IF TYPE(in_val) = "M"
      @ row_pos,col_pos SAY "memo"
   ELSE
      @ row_pos,col_pos SAY &in_val
   ENDIF
   col_pos = col_pos - Field_Length[cur_field] - 1
   RETURN

PROCEDURE B_SayRt
   * B_SayRT will SAY a field and increment col_pos to the right *
   IF TYPE(in_val) = "M"
      @ row_pos,col_pos SAY "memo"
   ELSE
      @ row_pos,col_pos SAY &in_val
   ENDIF
   col_pos = col_pos + Field_Length[cur_field] + 1
   RETURN

FUNCTION B_R_PAN
   * Returns the number of the field from current first field position
   * that will fit onto the screen going up in count
   PRIVATE length, cnt_pos, rover
   length = 0
   FOR cnt_pos = cur_field TO last_fld 
      rover = cnt_pos
      length = length + Field_Length[cnt_pos] + 1
      IF length > 80
         IF rover = cur_field
            RETURN(rover)
         ELSE
            RETURN(rover - 1)
         ENDIF
      ENDIF
   NEXT
   * The remaining fields all fit on the screen
   RETURN(rover)

FUNCTION B_L_PAN
   * Returns the number of the field from current last field position
   * that will fit onto the screen going down in count
   PRIVATE length, cnt_pos, lover
   length = 0
   FOR cnt_pos = cur_field TO 1 STEP -1
      lover = cnt_pos
      length = length + Field_Length[cnt_pos] + 1
      IF length > 80
         IF lover = cur_field
            RETURN(lover)
         ELSE
            RETURN(lover + 1)
         ENDIF
      ENDIF
   NEXT
   * The remaining fields all fit on the screen
   RETURN(lover)


FUNCTION B_FLDCNT
   * This function determines the number of the last field in database
   PRIVATE count
   count = 1
   DO WHILE (count < 1025) .AND. (LEN(FIELDNAME(count+1)) > 0)
      count = count + 1
   ENDDO
   RETURN(count)

FUNCTION B_FLDLEN
   * B_FLDLEN function					 *
   * Returns LEN() for character strings *
   * Returns LEN(STR()) for numeric		 *
   * Returns 1 for logical				 *
   * Returns 8 for date					 *
   * Returns 4 for memo					 *
   * OR Returns length of field name *
   ***************************************
   PARAMETER field_num
   PRIVATE lenght
   field_name = FIELDNAME(field_num)
   DO CASE
     CASE TYPE(field_name) = "C"
       length = LEN(&field_name)
     CASE TYPE(field_name) = "N"
        length = LEN(STR(&field_name))
     OTHERWISE
        length = AT(TYPE(field_name), "L  M   D")
   ENDCASE
   IF LEN(field_name) > length
     RETURN(LEN(field_name))
   ELSE
     RETURN(length)
   ENDIF

 **[eof]
                   