**    Last revision: June 17, 1986 at 19:45
* main.prg
* main command program of database
* do display sign-on message and initialize variables
DO WHIL SUBSTR(DTOC(DATE()),7,2) = '80'
 CLEA
 ! DATE
 ! TIME
ENDD
DO init
* set up database
USE ag
SET INDEX TO lastname
STOR .t. TO first
* set up the forever loop for this data base
DO WHIL .t.
 IF first
  DO s_first
 ENDI first
 STOR .f. TO first
 STOR "  OPTIONS:  <A>dd new records,   <E>dit this record,   <P>rint this record  " TO prompt1
 STOR '            <S>earch by lastname or a<N>y data in file,  prepare <R>eports ' TO prompt2
 STOR '            <F>orward,  <B>ackward, <D>elete/Recall, <M>aintenance, <Q>uit ' TO prompt3
 STOR CDOW(DATE())+' '+CMONTH(DATE())+' '+STR(DAY(DATE()),2)+", "+STR(YEAR(DATE()),4) TO mday
 STOR 'MAIN MENU' TO mode
 SET COLOR TO &revvideo
 @ 1,00
 @ 1,01 SAY mday
 @ 1,35 SAY mode
 SET COLOR TO &stdvideo
 IF clipper
  @ 19,0, 23,79 BOX frame
 ELSE
  @ 19,0 TO 23,79 double
 ENDI clipper
 @ 20,01 SAY prompt1
 @ 21,01 SAY prompt2
 @ 22,01 SAY prompt3
 STOR ' ' TO command
 IF DELETE()
  STOR 'Deleted Record' TO deleted
 ELSE
  STOR '              ' TO deleted
 ENDI DELETED
 SET COLOR TO &revvideo
 @ 1,65 SAY deleted
 SET COLOR TO &stdvideo
 @ 3,13 SAY lastname
 @ 3,58 SAY fname
 @ 4,13 SAY spouse
 @ 4,58 SAY mr
 @ 6,13 SAY title
 @ 7,13 SAY company1
 @ 8,13 SAY company2
 @ 9,13 SAY caddress
 @ 9,58 SAY suite
 @ 10,13 SAY ccity
 @ 10,44 SAY cst
 @ 10,58 SAY czip
 @ 12,13 SAY address
 @ 12,58 SAY apt
 @ 13,13 SAY city
 @ 13,44 SAY st
 @ 13,58 SAY zip
 @ 14,21 SAY ophone
 @ 14,58 SAY phone
 @ 15,13 SAY dear
 @ 15,58 SAY send
 @ 16,13 SAY cs1
 @ 16,44 SAY cs2
 @ 16,58 SAY update
 @ 23,33 SAY 'SELECT:'
 @ 23,43 GET command PICTURE '!'
 READ
 CLEA GETS
 DO CASE
 CASE command = 'A'
  DO add
  LOOP
 CASE (command = 'B' .OR. command = ',')
  SKIP -1
  LOOP
 CASE command = 'D'
  IF DELETE()
   RECA
  ELSE
   DELE
  ENDI
  LOOP
 CASE command = 'E'
  SET DELIMITER OFF
  STOR lastname TO mlastname
  STOR fname TO mfname
  STOR spouse TO mspouse
  STOR mr TO mmr
  STOR title TO mtitle
  STOR company1 TO mcompany1
  STOR company2 TO mcompany2
  STOR caddress TO mcaddress
  STOR suite TO msuite
  STOR ccity TO mccity
  STOR cst TO mcst
  STOR czip TO mczip
  STOR address TO maddress
  STOR apt TO mapt
  STOR city TO mcity
  STOR st TO mst
  STOR zip TO mzip
  STOR ophone TO mophone
  STOR phone TO mphone
  STOR dear TO mdear
  STOR send TO msend
  STOR cs1 TO mcs1
  STOR cs2 TO mcs2
  STOR update TO mupdate
* set up screen and prompt for editing
  STOR " OPTIONS: Enter the new or corrected information. Control 'Q' or 'W' to end." TO prompt4
  SET COLOR TO &revvideo
  @ 1,00
  @ 1,01 SAY mday
  @ 1,35 SAY mode
  SET COLOR TO &stdvideo
  @ 19,00 CLEAR
  IF clipper
   @ 19,0, 23,79 BOX frame
  ELSE
   @ 19,0 TO 23,79 double
  ENDI clipper
  @ 20,01 SAY prompt4
  @ 3,13 GET mlastname PICTURE '!XXXXXXXXXXXXXXXXXXXXXXXX'
  @ 3,58 GET mfname PICTURE '!XXXXXXXXXXXXXXXXXXX'
  @ 4,13 GET mspouse
  @ 4,58 GET mmr
  @ 6,13 GET mtitle
  @ 7,13 GET mcompany1
  @ 8,13 GET mcompany2
  @ 9,13 GET mcaddress
  @ 9,58 GET msuite
  @ 10,13 GET mccity
  @ 10,44 GET mcst picture '!!'
  @ 10,58 GET mczip picture '!!!!!!!!!!'
  @ 12,13 GET maddress
  @ 12,58 GET mapt
  @ 13,13 GET mcity
  @ 13,44 GET mst picture '!!'
  @ 13,58 GET mzip picture '!!!!!!!!!!'
  @ 14,21 GET mophone picture '(999)999-9999'
  @ 14,58 GET mphone picture '(999)999-9999'
  @ 15,13 GET mdear
  @ 15,58 GET msend picture '!'
  @ 16,13 GET mcs1 PICTURE '!'
  @ 16,44 GET mcs2 PICTURE '!!!!'
  @ 16,58 GET mupdate picture '99/99/99'
  READ
  CLEA GETS
* test if there is an error
  DO check
  SET DELIMITER ON
  STOR 'N' TO comman
  @ 20,01 SAY SPACE(77)
  @ 21,01 SAY SPACE(77)
  @ 22,01 SAY SPACE(77)
  @ 20,15 SAY 'Are there any more changes ?                        '
  @ 20,48 GET comman picture '!'
  READ
  SET DELIMITER OFF
  IF comman = 'Y'
   @ 20,01 SAY SPACE(77)
   @ 3,13 GET mlastname PICTURE '!XXXXXXXXXXXXXXXXXXXXXXXX'
   @ 3,58 GET mfname PICTURE '!XXXXXXXXXXXXXXXXXXX'
   @ 4,13 GET mspouse
   @ 4,58 GET mmr
   @ 6,13 GET mtitle
   @ 7,13 GET mcompany1
   @ 8,13 GET mcompany2
   @ 9,13 GET mcaddress
   @ 9,58 GET msuite
   @ 10,13 GET mccity
   @ 10,44 GET mcst picture '!!'
   @ 10,58 GET mczip picture '!!!!!!!!!!'
   @ 12,13 GET maddress
   @ 12,58 GET mapt
   @ 13,13 GET mcity
   @ 13,44 GET mst picture '!!'
   @ 13,58 GET mzip picture '!!!!!!!!!!'
   @ 14,21 GET mophone picture '(999)999-9999'
   @ 14,58 GET mphone picture '(999)999-9999'
   @ 15,13 GET mdear
   @ 15,58 GET msend picture '!'
   @ 16,13 GET mcs1 PICTURE '!'
   @ 16,44 GET mcs2 PICTURE '!!!!'
   @ 16,58 GET mupdate picture '99/99/99'
* let user enter data
   READ
   CLEA GETS
   DO check
  ENDI command = 'Y'
  REPL lastname WITH mlastname, fname WITH mfname, spouse WITH mspouse, mr WITH mmr
  REPL title WITH mtitle, company1 WITH mcompany1, company2 WITH mcompany2, caddress WITH mcaddress
  REPL suite WITH msuite, ccity WITH mccity, cst WITH mcst, apt WITH mapt
  REPL czip WITH mczip, address WITH maddress, city WITH mcity, st WITH mst
  REPL zip WITH mzip, ophone WITH mophone, phone WITH mphone, dear WITH mdear
  REPL send WITH msend, cs1 WITH mcs1, cs2 WITH mcs2
* ask if an automatic update of the date is wanted
  SET DELIMITER ON
  STOR 'Y' TO comman
  @ 20,01 SAY SPACE(77)
  @ 21,01 SAY SPACE(77)
  @ 22,01 SAY SPACE(77)
  @ 20,12 SAY 'Do You want to Update to Todays Date (Y/N) ?'
  @ 20,57 GET comman PICTURE '!'
  READ
  IF comman = 'Y'
   REPL update WITH DTOC(date())
  ELSE
   REPL update WITH mupdate         
  ENDI
  LOOP
 CASE (command = 'F' .OR. command = '.')
* move forward one record
  SKIP
 CASE (command = 'H' .OR. command = '?')
* display a screen full of instructions
  STOR .t. TO first
  CLEA
  TEXT

             M A I N    M E N U   H E L P   F I L E 

      Welcome to the Attorney General's Mailing List Data Base.   I am here to
      help you  - and you can call me anytime by just entering a ? mark at any 
      place where this program asks for a command. 

      When you go back to the screen you will see two lines    - on top of the 
      first line it says 'Main Module'    - thus, on top of the first line the 
      program always tells you where you are! 

      Between the two lines we have the information you or someone else placed
      in the computer. This information tells you all about a particular file.

      Below th line is the list of things you can do. To look at the next file
      hit 'F' (or a period).  To go back one record - hit 'B' (or a comma). To
      delete a record hit 'D' and a sign will appear at the upper left corner.
      To remove the delete - hit 'D' again. Don't worry -  you cannot delete a
      record just by hitting 'D'. You must run another program on the Mainten-
      ance Menu.

                                    Please hit any key to continue............
  ENDT
  SET CONSOLE OFF
  WAIT
  SET CONSOLE ON
  CLEA
  TEXT

      To find a file by lastname - hit 'S' for search.    You can find any data
      in any file using the 'N' search. To edit - select 'E'.

      To add more records you hit 'A'.   Once in add - you enter as many files
      as you want one at a time, and then can index if you wish.

      To prepare Wordstar data, reports or display records hit 'R'for reports.

      To reindex, purge files, check for duplicates, etc hit 'M' for maintain. 

      If all else fails - call Steve Leon at 488-7677. In the meantime - relax 
      this program is 'User Fiendly' and I am here to help you. 
      ------------------------------------------------------------------------
      WHATEVER YOU DO -  NEVER SHUT OFF THE MACHINE UNTIL YOU FIRST HIT 'Q' TO
      TO QUIT. You must first get back to the 'C>' (called C prompt) before you 
      shut the computer.........please, otherwise you will lose data!!!!
      ------------------------------------------------------------------------

                           Please hit any key to return to the data base......


  ENDT
  SET CONSOLE OFF
  WAIT
  SET CONSOLE ON
  CLEA
 CASE command = 'M'
  DO maintain
 CASE command = 'P'
  SET CONSOL OFF
  SET PRINT ON
  ? '     ' +  "Name: "+ mr + TRIM(fname) +' ' + lastname
  ? '     ' + "Spouse: " + spouse + "Address as: " + dear
  ? '     ' + "Title: " + title
  ? '     ' + "Company: " + company1
  ? '     ' + "       : " + company2
  ? '     ' + "Address: " + caddress + "  " + suite
  ? '     ' + "         " + ccity +', ' + cst + '  ' +czip
  ? '     ' + "Home address: " + address + "  " + apt
  ? '     ' + "              " + city +', '+  st + '  ' +zip
  ? '     ' + 'Phones - office: ' + ophone + ' home: ' + phone
  ? '     ' + "List:  " + cs1 + '   Code: ' + cs2
  ? '     ' + "Send to office: " + send
  ? '     ' + "Date update: " + update
  SET PRINT OFF
  SET CONSOL ON
 CASE command = 'Q'
* prevent sign-off message
  SET CONSOLE OFF
  CLEA
  QUIT
 CASE command = 'R'
  DO report
 CASE command = 'S'
  SET DELIMITER ON
  STOR SPACE(15) TO name
  STOR RECNO() TO rec_number
  @ 19,00 CLEAR
  IF clipper
   @ 19,0,23,79 BOX frame
  ELSE
   @ 19,0 TO 23,79 double
  ENDI clipper
  @ 20,12 SAY 'Please enter lastname  ' GET name
  READ
  STOR TRIM(name) TO name
  STOR UPPER(name) TO name
  SEEK name
  IF (EOF() .OR. BOF())
   @ 20,02 SAY SPACE(75)
   @ 20,12 SAY name+' is not in the file'
   @ 21,12 SAY 'Press RETURN to Continue'
   SET CONSOLE OFF
   WAIT
   SET CONSOLE ON
   GO rec_number
  ENDI EOF()
  LOOP
 CASE command = 'N'
  DO search1
  LOOP
 ENDC
* loop back again
ENDD

                     