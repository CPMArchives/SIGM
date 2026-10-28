**    Last revision: June 14, 1986 at 7:53

**    Revised by H.M. Van Tassell to write LINKEM.LNK file

*******************************************************************************
* Name       COMPILE.prg
* Date       January 29, 1986
* Author     Stephen Straley
* Note       This program will check the directory for files, and write
*            CLIP files accordingly as well as the batch file for the
*            compile
*
*******************************************************************************


SET SCOREBOARD OFF
scrframe  = "ษอปบผอศบ "
scrbar    = "ฬ" + REPLICATE("อ",78) + "น"
scrlin    = "บ"
STORE SPACE(4096) TO scr_page1, scr_page2

DO Scrinit
DO Input_it
CLOSE DATABASES
DO Port_it1
CLOSE DATABASES
DO Port_it2
CLOSE DATABASES
DO Port_it3
CLOSE DATABASES
DO Choice
DO Exiting


PROCEDURE Scrinit

   CLEAR
   @ 0,0,20,79 BOX SUBSTR(scrframe,1,8)
   @ 4,0 SAY scrbar
   FOR x = 1 TO 3
      @ x,1 SAY REPLICATE("Û",78)
   NEXT
   @ 1,5 SAY " MAKECLiP "
   @ 1,75 - LEN(" Version 1.10 ") SAY " Version 1.10 "
   @ 3,40 - LEN(" The Clipper Utility Program - Main Menu ")/2 SAY " The Clipper Utility Program - Main Menu "
   CALL _scrsave WITH scr_page1
   @ 10,5 SAY "The follow program was designed to make Clip Files out of all available"
   @ 12,5 SAY "program, format,  and procedure files  available to the  program on the"
   @ 14,5 SAY "registered directory/drive.   If you are unsure what CLiP files are  or"
   @ 16,5 SAY "to their purpose, please strike  FUNCTION KEY 1 (F1) for a description."
   STORE "Y" TO continue
   @ 18,25 SAY "Would you like to continue? " GET continue PICT "!" VALID(continue $"YN")
   READ
   IF continue = "N"
      @ 23,0 SAY ""
      QUIT
   ENDIF
   
PROCEDURE Input_it

* This routine will take a directory of all PRG, PRC, and FMT files on disk

@ 0,0 CLEAR
@ 4,0,20,79 BOX SUBSTR(scrframe,1,8)
CALL _scrsave WITH scr_page2
@ 10,10 SAY ""
?? "Reading Disk Information"
@ 11,10 SAY ""
IF .NOT. FILE("*.PRG")
   ?? "There are no Program Files Available on drive"
ELSE
   RUN DIR *.PRG > CAPTURE.TXT
ENDIF
@ 12,10 SAY ""
IF .NOT. FILE("*.PRC")
   ?? "There are no Procedure Files Available on drive"
ELSE
   RUN DIR *.PRC >>CAPTURE.TXT
ENDIF
@ 13,10 SAY ""
IF .NOT. FILE("*.FMT")
   ?? "There are no Format Files Avilable on drive"
ELSE
   RUN DIR *.FMT >>CAPTURE.TXT
ENDIF

PROCEDURE Port_it1

* This procedure will take the captured file and port it into a raw data
* base.

CREATE Template
USE Template
APPEND BLANK
REPLACE field_name WITH "TEMP", field_type WITH "C", field_len WITH 80
USE
CREATE Port1 FROM Template
ERASE Template
USE Port1
APPEND FROM Capture.txt SDF
USE

PROCEDURE Port_it2

* This procedure take the ported database in PORT1.DBF and sorts it into
* a secondary database by root file name, extention, and if it is going to
* be a major file (a file at the head of a CLIP file.

CREATE Template
USE Template
APPEND BLANK
REPLACE field_name WITH "ROOT", field_type WITH "C", field_len WITH 8
APPEND BLANK
REPLACE field_name WITH "EXT", field_type WITH "C", field_len WITH 3
APPEND BLANK
REPLACE field_name WITH "MAJOR", field_type WITH "L", field_len WITH 1
USE
CREATE Port2 FROM Template
ERASE Template


PROCEDURE Port_it3

* This will port between the two files....
*

SELECT 2
USE Port2
SELECT 1
USE Port1
DO WHILE .NOT. EOF()
   IF SUBSTR(temp,1,1) # " "
      SELECT 2
      APPEND BLANK
      REPLACE root  WITH SUBSTR(A->temp,1,8)
      REPLACE ext   WITH SUBSTR(A->temp,10,3)
      REPLACE major WITH .F.
      SELECT 1
   ENDIF
   SKIP
ENDDO

PROCEDURE Choice

CALL _scrrest WITH scr_page1
STORE "Y" TO input
@ 10,15 SAY "Would you like to compile every file seperately? " GET input PICT "!" VALID(input $"YN")
READ
IF input = "Y"
   DO Seperate
ELSE
   DO Indiv
ENDIF



PROCEDURE Indiv

SELECT 1
USE Port2
COPY STRUCTURE TO Port4
screen_no = 0
SET MESSAGE TO 22
DO WHILE screen_no >= 0
   CALL _scrrest WITH scr_page1
   position = RECNO()
   down      = 6
   over      = 5
   option    = 1
   count     = 1
   ending    = LASTREC()
   IF EOF()
      DO Exiting
   ENDIF
   DO WHILE count <= 30
      DO CASE
      CASE ext = "PRG"
         info = "This is a Program File"
      CASE ext = "PRC"
         info = "This is a Procedure File"
      OTHERWISE
         info = "This is a Format File"
      ENDCASE
      IF DELETED()
         info = info + " --- FILE ALREADY SELECTED/USED"
      ENDIF
      info = SPACE(5) + info
      @ down, over PROMPT root MESSAGE CENTRING(info)
      over = over + 15
      IF over > 70
         down = down + 2
         over = 5
      ENDIF
      count = count + 1
      SKIP
      IF EOF()
         EXIT
      ENDIF
   ENDDO
   @ down, over PROMPT "Write File" MESSAGE CENTRING("Selected FIles will be now written")
   over = over + 15
   IF over > 70
      down = down + 2
      over = 5
   ENDIF
   IF RECNO() < ending
      @ down, over PROMPT "Next Screen" MESSAGE SPACE(78)
   ENDIF

   SET KEY -1 TO Review
   SET KEY 24 TO Downprmt
   SET KEY  5 TO Upprmt
      
   MENU TO option

   SET KEY -1 TO
   SET KEY 24 TO
   SET KEY  5 TO

   DO CASE
   CASE option = 0
      screen_no = screen_no - 1
      IF screen_no >= 0
         GO position
         SKIP - 30
      ENDIF
   CASE option = 32
      screen_no = screen_no + 1
      count = 1
      CALL _scrrest WITH scr_page1
   CASE option = count
      DO Writfile
      screen_no = 0
   OTHERWISE
      GO (screen_no * 30 + option)
      IF DELETED()
         RECALL
      ELSE
         DELETE
      ENDIF
      GO position
      count = 1
   ENDCASE
ENDDO

PROCEDURE Writfile

   SET FILTER TO DELETED()
   GO TOP
   rec_count = 0
   DO WHILE .NOT. EOF()
      rec_count = rec_count + 1
      SKIP
   ENDDO
   IF rec_count > 32 .OR. rec_count = 0
      IF rec_count > 32
         a_mess = LTRIM(STR(rec_count)) + " is too many files in a CLIP file.  Unselect " + LTRIM(STR(32 - rec_count)) + " files. "
      ELSE
         a_mess = "An empty file can not be written.  Any Key to Continue.."
      ENDIF
      @ 22,0 SAY CENTRING(a_mess)
      qw = INKEY(0)
      SET FILTER TO
      GO TOP
      RETURN
   ENDIF
   COPY TO Port3
   STORE .F. TO Abort_it
   DO Outfile
   IF Abort_it
      RETURN
   ENDIF
   USE Port2
   PACK
   GO TOP

PROCEDURE Outfile

   option = 0
   down_out = 6
   over_out = 5
   USE Port3
   CALL _scrrest WITH scr_page1
   @ 3,1 SAY REPLICATE("Û",78)
   @ 3,26 SAY "CLIP File Selection Menu"
   DO WHILE .NOT. EOF()
      visual = TRIM(root) + "." + ext
      @ down_out, over_out PROMPT visual
      over_out = over_out + 15
      IF over_out > 70
         down_out = down_out + 2
         over_out = 5
      ENDIF
      SKIP
   ENDDO
   MENU TO option
   IF option = 0
      STORE .T. TO Abort_it
      RETURN
   ENDIF
   GO option
   REPLACE major WITH .T.
   DO Finalout

PROCEDURE Finalout

   LOCATE FOR major = .T.
   outfile = TRIM(root) + ".CLP"
   SET ALTERNATE TO &outfile
   @ 11,20,14,60 BOX scrframe
   @ 12,21 SAY SUBSTR(CENTRING("Now creating " + outfile),21,38)
   @ 13,21 SAY SUBSTR(CENTRING(" Listing " + TRIM(root) + "." + ext),21,38)
   SET CONSOLE OFF
   SET ALTERNATE ON
   ? TRIM(root)
   SET ALTERNATE OFF
   SET CONSOLE OFF
   GO TOP
   DO WHILE .NOT. EOF()
      IF .NOT. major
         @ 13,21 SAY SUBSTR(CENTRING(" Listing " + TRIM(root) + "." + ext),21,38)
         SET CONSOLE OFF
         SET ALTERNATE ON
         ? TRIM(root)
         SET ALTERNATE OFF
         SET CONSOLE OFF
      ENDIF
      IF ext = "PRC" .OR. ext = "FMT"
         ths_is_in = TRIM(root) + "." + ext
         ths_is_out = TRIM(root) + ".PRG"
         RENAME &ths_is_in. TO &ths_is_out
      ENDIF
      SKIP
   ENDDO
   GO option
   SELECT 2
   USE Port4
   APPEND BLANK
   REPLACE root WITH A->root, ext WITH A->ext, major WITH A->major
   SELECT 1
   ZAP

PROCEDURE Seperate

USE Port2
REPLACE ALL major WITH .T.
@ 12,01 SAY SUBSTR(CENTRING("Manipulating Data FIle for Output"),1,78)
COPY TO Port4
GO TOP
SET CONSOLE OFF
DO WHILE .NOT. EOF()
   outfile = TRIM(root) + ".CLP"
   a_mess = "Now working with " + TRIM(root) + "." + ext
   @ 12,01 SAY SUBSTR(CENTRING(a_mess),1,78)
   SET ALTERNATE TO &outfile
   SET ALTERNATE ON
   ? root
   SET ALTERNATE OFF
   CLOSE ALTERNATE
   SKIP
   @ 12,20 SAY SPACE(40)
ENDDO
SET CONSOLE ON



PROCEDURE Exiting

CLOSE DATABASES
CALL _scrrest WITH scr_page1
batch = "CLIPALL"
STORE "Y" TO input, ynput
@ 10,15 SAY "Would you like a BATCH file to compile your CLP files? " GET input PICT "!" VALID(input $"YN")
READ
@ 10,15 SAY SPACE(60)
IF input = "Y"
   @ 10,15 SAY "Would you like to PAUSE between every compile? " GET ynput PICT "!" VALID(ynput $"YN")
   READ
   @ 10,15 SAY SPACE(60)
   a_batch = SPACE(8)
   @ 10,15 SAY "Enter desired name of batch file: " GET a_batch PICT "!!!!!!!!"
   READ
   IF LEN(TRIM(a_batch)) <> 0
     batch = TRIM(a_batch)
   ENDIF
   USE Port4
   GO TOP
   outfile = batch +".BAT"
   @ 10,01 SAY SUBSTR(CENTRING("Now Writing " + outfile + " file."),1,78)
   SET ALTERNATE TO &outfile
   SET CONSOLE OFF
   DO WHILE .NOT. EOF()
      a_mess = "Now Writing for Clipper @" + TRIM(root)
      @ 12,1 SAY SUBSTR(CENTRING(a_mess),1,78)
      SET ALTERNATE ON
      ? "CLS"
      ? "CLIPPER @" + TRIM(root)
      IF ynput = "Y"
         ? "PAUSE"
      ENDIF
      SET ALTERNATE OFF
      SKIP
   ENDDO
   CLOSE ALTERNATE
   @ 10,1 SAY SPACE(78)
   @ 12,1 SAY SPACE(78)
   b_mess = "Run Batch File, "
ELSE
   b_mess = "Compile CLiP Files, "
ENDIF

**  add section to write a LNK file *******

USE Port4
GO TOP
@ 10,1 SAY SPACE(78)
@ 12,1 SAY SPACE(78)
outfile = batch +".LNK"
@ 10,01 SAY SUBSTR(CENTRING("Now Writing the "+ outfile + " file."),1,78)
SET ALTERNATE TO &outfile
SET CONSOLE OFF
SET ALTERNATE ON
? "ERROR: you MUST restructure this link file..."
? "The main module must be the first one in the file"
? "See the PLINK86 section of the manual for overlay information"
SET ALTERNATE OFF
DO WHILE .NOT. EOF()
   a_mess = "Now Writing for FI" + TRIM(root)
   @ 12,1 SAY SUBSTR(CENTRING(a_mess),1,78)
   SET ALTERNATE ON
   ? "FI " + TRIM(root)
   SET ALTERNATE OFF
   SKIP
ENDDO
SET ALTERNATE ON
? "LIB Clipper" 
SET ALTERNATE OFF
CLOSE ALTERNATE
@ 10,1 SAY SPACE(78)
@ 12,1 SAY SPACE(78)

** end of LNK section *******

a_mess = b_mess + "then revise '" + batch + ".LNK' to determine Link Structure"
@ 11,1 SAY SUBSTR(CENTRING(a_mess),1,78)
@ 13,1 SAY SUBSTR(CENTRING("Thank you for running MAKECLiP."),1,78)
ERASE Capture.txt
ERASE Template.dbf
ERASE Port1.dbf
ERASE Port2.dbf
IF FILE("Port3.dbf")
   ERASE Port3.dbf
ENDIF
@ 23,00 SAY ""
QUIT            
   
PROCEDURE Review
PARAMETER p, l, v
   
   SAVE SCREEN
   CALL _scrrest WITH scr_page2
   down_rev = 6
   over_rev = 5
   SET FILTER TO DELETED()
   GO TOP
   DO WHILE .NOT. EOF()
      @ down_rev, over_rev SAY root
      over_rev = over_rev + 15
      IF over_rev > 70
         down_rev = down_rev + 2
         over_rev = 5
      ENDIF
      SKIP
   ENDDO
   a_mess = "All Files Listed.  Any Key to Return to Main Menu"
   @ 22,00 SAY CENTRING(a_mess)
   qw = INKEY(0)
   SET FILTER TO
   GO position
   RESTORE SCREEN

PROCEDURE Help

   PARAMETERS aa, bb, cc

   SAVE SCREEN
   DO CASE
   CASE aa = "SCRINIT"
      @ 0,0 CLEAR
      TEXT
CLIP FILES ... are text files with .CLP extentions.  Inside of these text files
     are the names of the programs we wish to compile, either individually or
     in a group of files.  Consider the following file layout.

                                GL.prg
                                  บ
                       ษออออออออออสอออออออออออป
                       บ                      บ
                  GLMENU.prg            GLUTILITY.prg
                       บ                      บ
                       บ           ษออออออออออสออออออออออป
                       บ      BACKUP.prg              RESTORE.prg
                       บ
    ษออออออออออออออออออฮออออออออออออออออออออออหอออออออออออออออออออออออป
    บ                  บ                      บ                       บ
 GLCOA.prg         GLTRANS.prg           GLSORT.prg             GLLIST.prg
    บ                  บ                      บ
GLCOA_1.prg         ENTER.prg            SORT_1.prg
    บ                  บ 
GLCOA_2.prg          EDIT.prg
                       บ
                    DELETE.prg      (Any Key to Continue...or Q to Quit)
ENDTEXT
qw = INKEY(0)
IF qw = ASC("Q") .OR. qw = ASC("q")
   RESTORE SCREEN
   RETURN
ENDIF
@ 0,0 CLEAR
@ 0,00 SAY "CLIP FILES"
@ 2,00 SAY CENTRING("In the previous listed structure, GL.prg calls both GLMENU.prg and")
@ 4,00 SAY CENTRING("GLUTILITY.prg, which in turn call their respective sub-routines.  Now let's")
@ 6,00 SAY CENTRING("say you tried compiling this application by starting everything off with")
@ 8,30 SAY "C>"
@ ROW(),COL() SAY "C"
  qw = INKEY(.5)
@ ROW(),COL() SAY "L"
  qw = INKEY(.5)
@ ROW(),COL() SAY "I"
  qw = INKEY(.5)
@ ROW(),COL() SAY "P"
  qw = INKEY(.5)
@ ROW(),COL() SAY "P"
  qw = INKEY(.5)
@ ROW(),COL() SAY "E"
  qw = INKEY(.5)
@ ROW(),COL() SAY "R"
  qw = INKEY(.5)
@ ROW(),COL()+1 SAY "G"
  qw = INKEY(.5)
@ ROW(),COL() SAY "L"
  qw = INKEY(.5)
@ 10,00 SAY CENTRING("From this, one at a time, each program(sub-routine) would be called in and")
@ 12,00 SAY CENTRING("compiled.  Eventually, your screen may look like this...")
@ 14,00 SAY "Compiling GL.PRG      "
DO Counting WITH 150
@ 15,00 SAY "Compiling GLMENU.PRG  "
DO Counting WITH 76
@ 16,00 SAY "Compiling GLUTILTY.PRG"
DO Counting WITH 252
@ 17,00 SAY "Compiling GLCOA.PRG   "
DO Counting WITH 56
@ 18,00 SAY "Compiling GLCOA_1.PRG "
DO Counting WITH 32
@ 19,00 SAY "Compiling GLCOA_2.PRG "
DO Counting WITH 89
@ 20,00 SAY "Compiling GLTRANS.PRG "
DO Counting WITH 162
@ 21,00 SAY "Compiling ENTER.PRG   "
DO Counting WITH 52
@ 22,00 SAY "Too Many Constants           Press Any Key for Next Screen or 'Q' to Quit..."
qw = INKEY(0)
IF qw = ASC("Q") .OR. qw = ASC("q")
   RESTORE SCREEN
   RETURN
ENDIF
@ 0,0 CLEAR
TEXT
CLIP FILES

    At this point in the compiling process, the compiler is informing us that
too much is being compiled at this time.  Technically speaking, the compiler
establishes a point of reference in a special table for every constant ("STORE
0.00 TO a, STORE 1 TO b, etc...).  Once this special table is full, the
compiler can not compile any more souce code during this particular pass.

From this point on, every line of the program, and following programs, would 
produce the same error and bogus object code.   The solution is to break up the
amount of code the compiler has to see at one time.  To do this, you have to
use CLIP files.  CLIP files are also necessary in preparing your application
to be broken up for overlays.

CLIP files are no more than ordinary text files with a .CLP extention.  Inside
of a CLIP file, place the name of the program you wish to compile exclusively.
No matter if a program calls another program (sub-routine), only those programs
listed in the CLIP file will be compiled together making a single .OBJ file.
CLIP files may contain just one name of a program, or an entire group.  Making
the right decision is difficult when it pertains to overlays.  This program
will help deciper that for you.   So now, back to the example.  Let us make 3
unique .CLP files.     Any Key to Continue or 'Q' to Quit..."
ENDTEXT
qw = INKEY(0)
IF qw = ASC("Q") .OR. qw = ASC("q")
   RESTORE SCREEN
   RETURN
ENDIF
@ 0,0 CLEAR
TEXT
CLIP FILES

   Inside of GL.CLP, list the following programs:        GL
                                                         GLMENU
                                                         GLUTILTY
                                                         BACKUP
                                                         RESTORE
   Inside of GLCOA.CLP, list the following programs:     GLCOA
                                                         GLCOA_1
                                                         GLCOA_2
                                                         GLTRANS
                                                         ENTER
                                                         EDIT
                                                         DELETE
   Inside of FINAL.CLP, list the following programs:     GLSORT
                                                         GLSORT_1
                                                         GLLIST


So now there are an additional 3 files on your directory with the names of the
programs we wish to compile. 
                                    Any Key to Continue or 'Q' to Quit
ENDTEXT
qw = INKEY(0)
IF qw = ASC("Q") .OR. qw = ASC("q")
   RESTORE SCREEN
   RETURN
ENDIF
@ 0,0 CLEAR
TEXT
CLIP Files

   Now compile each CLIP file in the following manner:

              C>CLIPPER @GL
              C>CLIPPER @GLCOA
              C>CLIPPER @FINAL

   The results would be three seperate .OBJ files with the names of the
associated .CLP files.  So now on the disk there would be three new files
created after the three compiles:

              GL.OBJ
              GLCOA.OBJ
              FINAL.OBJ

Notice that no matter what is being compiled inside of the .CLP files, the name
of the CLIP file can be anything.  Keep in mind that the compiler will take the
name of the CLIP file and use that as the name of the .OBJ file.  In this
example, the last .CLP file is called FINAL.CLP for a good reason.

                           Any Key to Continue or 'Q' to Quit...
ENDTEXT
qw = INKEY(0)
IF qw = ASC("Q") .OR. qw = ASC("q")
   RESTORE SCREEN
   RETURN
ENDIF
@ 0,0 CLEAR
TEXT
CLIP Files

    Sometimes, we compile code which has problems in it, and these problems 
may not surface until we try to run our application.    It can be frustrating
to change one or two lines of cone in, let's say for example, GLLIST.prg.  For
once we have made the necessary changes, we would have to re-compile and re-
link our application together.  By using CLIP files, we can isolate code which
is "clean" from that which we are still trying to finish.  In this example, all
we would have to do once we changed the desired lines of code in GLLIST.PRG is
to re-compile the FINAL.CLP file by itself, and then to link it with the 
remaining two files previously compiled.  This method is very helpful in saving
time and energy when trying to get an application up and running.

   Finally, CLIP files are the only method in which to break up program,
procedure, and format files into logical sections for an overlay scheme.  The
linker which comes with Clipper does not automatically figure out the best
overlay scheme for you system.  It can't.  Consider your system.  Is it the
same exact system for your clients/customers.  Probably not.  Therefore it is
up to you to logically break up the programs into seperate/grouped compile and
from that, to link them together in an order best suited for your environment.

                                        Any Key to Continue ...
ENDTEXT
   CASE aa = "CHOICE"
      @ 0,0 SAY CENTRING("If you want to compile each and every PRG, FMT, and PRC file available")
      @ 1,0 SAY CENTRING("to be compiled individually (seperated and placed in  individual  CLIP")
      @ 2,0 SAY CENTRING("files, then answer 'Y' to this question.   Otherwise, you  may  choose")
      @ 3,0 SAY CENTRING("selectively which files to compile together.  Any Key to Continue...")
   CASE aa = "OUTFILE"
      @ 0,0 SAY CENTRING("The below listed files were chosen to be compiled together.  Please now")
      @ 1,0 SAY CENTRING("select which file wile head the list of the compile.  This  means  that")
      @ 2,0 SAY CENTRING("that the name of the CLIP file  wil take the name of  the first file in")
      @ 3,0 SAY CENTRING("the list.  RETURN for selected file; ESC key for first in list.")
   OTHERWISE
      @ 0,0 SAY CENTRING("To choose a file to join a list, move the cursor key to that file name")
      @ 1,0 SAY CENTRING("and strike the RETURN key.  To move to a previous menu, strike the ESC")
      @ 2,0 SAY CENTRING("key.  If there is no previous screen, the ESC key will return  to  the")
      @ 3,0 SAY CENTRING("DOS prompt.    Any Key to Return...")
   ENDCASE
   qw = INKEY(0)
   RESTORE SCREEN

PROCEDURE Counting
   
   PARAMETER end_count

   posit = ROW()+1
   FOR qw = 1 TO end_count
     @ posit,00 SAY "Line " + LTRIM(STR(qw))
   NEXT

PROCEDURE Downprmt

   PARAMETER p, l, v
 
   KEYBOARD REPLICATE(CHR(4),5)

PROCEDURE Upprmt

   PARAMETER p, l, v

   KEYBOARD REPLICATE(CHR(19),5)

FUNCTION Centring

   PARAMETER string

   temp = (80 - LEN(string))/2
   RETURN(SPACE(temp) + string + SPACE(temp))


                                                                                                        
                                                                  