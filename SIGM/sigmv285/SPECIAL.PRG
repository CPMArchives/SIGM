**    Last revision: June 18, 1986 at 18:58
* special.prg prepares special reports
STOR .t. TO more3
SET DELIMITER OFF
SET DELETED ON
DO WHIL more3
 DO s_first
 SET COLOR TO &revvideo
 @ 17,00
 @ 18,00
 @ 17,10 SAY "Input only information which is required for search. Where"
 @ 18,10 SAY "more than one selection in a field, do multiple searches."
 SET COLOR TO &stdvideo
 STOR '   ' TO extra
 STOR 0 TO count
 STOR '.NOT.DELETED()' TO finder
 STOR .f. TO first
 STOR SPACE(25) TO mlastname
 STOR SPACE(20) TO mfname
 STOR SPACE(15) TO mspouse
 STOR SPACE(14) TO mmr
 STOR SPACE(35) TO mtitle
 STOR SPACE(35) TO mcompany1
 STOR SPACE(35) TO mcompany2
 STOR SPACE(35) TO mcaddress
 STOR SPACE(10) TO msuite
 STOR SPACE(20) TO mccity
 STOR SPACE(2) TO mcst
 STOR SPACE(10) TO mczip
 STOR SPACE(35) TO maddress
 STOR SPACE(10) TO mapt
 STOR SPACE(20) TO mcity
 STOR SPACE(2) TO mst
 STOR SPACE(10) TO mzip
 STOR SPACE(13) TO mophone
 STOR SPACE(13) TO mphone
 STOR SPACE(22) TO mdear
 STOR SPACE(1) TO msend
 STOR SPACE(1) TO mcs1
 STOR SPACE(4) TO mcs2
 STOR SPACE(8) TO mupdate
 @ 3,13 GET mlastname
 @ 3,58 GET mfname
 @ 4,13 GET mspouse
 @ 4,58 GET mmr
 @ 6,13 GET mtitle
 @ 7,13 GET mcompany1
 @ 8,13 GET mcompany2
 @ 9,13 GET mcaddress
 @ 9,58 GET msuite
 @ 10,13 GET mccity
 @ 10,44 GET mcst
 @ 10,58 GET mczip
 @ 12,13 GET maddress
 @ 12,58 GET mapt
 @ 13,13 GET mcity
 @ 13,44 GET mst
 @ 13,58 GET mzip
 @ 14,21 GET mophone
 @ 14,58 GET mphone
 @ 15,13 GET mdear
 @ 15,58 GET msend
 @ 16,13 GET mcs1
 @ 16,44 GET mcs2
 @ 16,58 GET mupdate
 READ
 CLEA GETS
 SET DELIMITER ON
 STOR .f. TO toolong
 IF mlastname <> ' '.AND.(.NOT.toolong)
  STOR TRIM(finder) +".AND.'"+TRIM(UPPER(mlastname))+"'"+'$UPPER(lastname)'  TO finder
 ENDI
 RELE mlastname
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mfname <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mfname))+"'" TO mfname1
  STOR TRIM(finder) + mfname1+'$UPPER(fname)'  TO finder
 ENDI
 RELE mffname, mfname1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mmr  <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mmr))+"'" TO mmr1
  STOR TRIM(finder) +mmr1+'$UPPER(mr)'  TO finder
 ENDI
 RELE mmr, mmr1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mtitle <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mtitle))+"'" TO mtitle1
  STOR TRIM(finder) + mtitle1+'$UPPER(title)'  TO finder
 ENDI
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 RELE mtitle, mtitle1
 IF mcompany1 <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mcompany1))+"'" TO mco1
  STOR TRIM(finder) +mco1+'$UPPER(company1)'  TO finder
 ENDI
 RELE mcompany1, mco1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mcompany2 <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mcompany2))+"'" TO mco2
  STOR TRIM(finder) + mco21+'$UPPER(company2)'  TO finder
 ENDI
 RELE mcompany2, mco2
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mcaddress <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mcaddress))+"'" TO mcadr
  STOR TRIM(finder) + mcadr+'$UPPER(address)'  TO finder
 ENDI
 RELE mcaddress, mcadr
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF msuite <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(msuite))+"'" TO msuite1
  STOR TRIM(finder) +msuite1+'$UPPER(suite)'  TO finder
 ENDI
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 RELE msuite, msuite1
 IF mccity <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mccity))+"'" TO mccity1
  STOR TRIM(finder) +mccity1+'$UPPER(mccity)'  TO finder
 ENDI
 RELE mccity, mccity1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mcst <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mcst))+"'" TO mcst1
  STOR TRIM(finder) +mcst1+'$UPPER(cst)'  TO finder
 ENDI
 RELE mcst, mcst1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mczip <> ' ' .AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mczip))+"'" TO mczip1
  STOR TRIM(finder) +mczip1+'$UPPER(czip)'  TO finder
 ENDI
 RELE mczip, mczip1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF maddress <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(maddress))+"'" TO mad1
  STOR TRIM(finder) +mad1+'$UPPER(address)'  TO finder
 ENDI
 RELE maddress, mad1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mapt <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mapt))+"'" TO mapt1
  STOR TRIM(finder) +mapt1+'$UPPER(apt)'  TO finder
 ENDI
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 RELE mapt, mapt1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mcity <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mcity))+"'" TO mcity1
  STOR TRIM(finder) +mcity1+'$UPPER(city)'  TO finder
 ENDI
 RELE mcity, mcity1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mst <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mst))+"'" TO mst1
  STOR TRIM(finder) +mst1+'$UPPER(st)'  TO finder
 ENDI
 RELE mst, mst1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mzip <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mzip))+"'" TO mzip1
  STOR TRIM(finder) +mzip1+'$UPPER(zip)'  TO finder
 ENDI
 RELE mzip, mzip1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mophone <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mophone))+"'" TO moph
  STOR TRIM(finder) +moph+'$UPPER(ophone)'  TO finder
 ENDI
 RELE mophone, moph
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mphone <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mphone))+"'" TO mph
  STOR TRIM(finder) +mph+'$UPPER(phone)'  TO finder
 ENDI
 RELE mphone, mph
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mdear <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mdear))+"'" TO mdear1
  STOR TRIM(finder) +mdear1+'$UPPER(dear)'  TO finder
 ENDI
 RELE mdear, mdear1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF msend <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(msend))+"'" TO msend1
  STOR TRIM(finder) +msend1+'$UPPER(send)'  TO finder
 ENDI
 RELE msend, msend1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mcs1 <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mcs1))+"'" TO mcs11
  STOR TRIM(finder) +mcs11+'$UPPER(cs1)'  TO finder
 ENDI
 RELE mcs1, mcs11
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mcs2 <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mcs2))+"'" TO mcs21
  STOR TRIM(finder) +mcs21+'$UPPER(cs2)'  TO finder
 ENDI
 RELE mcs2, mcs21
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF mupdate <> ' '.AND.(.NOT.toolong)
  STOR ".AND.'"+TRIM(UPPER(mupdate))+"'" TO mupd1
  STOR TRIM(finder) +mupd1+'$UPPER(update)'  TO finder
 ENDI
 RELE mupdate, mupd1
 IF LEN(finder) > 140
  STOR .t. TO toolong
 ENDI
 IF LEN(finder) < 12
  STOR "*" TO finder
  STOR '              STANDARD = deleted files ' TO extra
 ENDI
 @ 20,00
 @ 21,00
 @ 22,00
 STOR ' ' TO dowhat
 @ 20,00 SAY "SELECT: <C>ount, <L>abels, <R>eport, <W>ordstar file or <Q>uit "
 DO WHIL AT(dowhat,'RWLCQ')=0
  @ 20,65 GET dowhat PICTURE '!'
  READ
 ENDD
 DO CASE
 CASE dowhat = 'C'
  IF toolong
   CLEA
   @ 10,10 SAY 'The search string is too long - you can have no more than '
   @ 11,10 SAY '140 characters in the string and the field names.  Please '
   @ 12,10 SAY 'try again.'
   @ 13,30 SAY 'HIT ANY KEY TO CONTINUE'
   SET CONSOL OFF
   WAIT
   SET CONSOL ON
  ELSE
   CLEA
   STOR 0 TO counter
   CLEA
   @ 10,10 SAY 'I am looking for the first instance of a file which meets your'
   @ 11,10 SAY 'requirements. Please be patient.'
   SET FILTER TO &finder
   GO TOP
   IF .NOT. (EOF() .OR. BOF())
    CLEA
    DO WHIL .NOT.EOF().OR. BOF()
     STOR counter + 1 TO counter
     @ 10,10 SAY '            Count so far is ' + STR(counter,5)
     SKIP
    ENDD whil .NOT. eof
    @ 10,00
    @ 10,10 SAY '              TOTAL COUNT IS ' + STR(counter,5)
    ? '    '
    ? '                      ***  HIT ANY KEY TO CONTINUE  *** '
    SET CONSOL OFF
    WAIT
    SET CONSOL ON
   ENDI
  ENDI toolong
  SET DELIMITER OFF
  STOR .f. TO more3
 CASE dowhat = 'R'
  IF toolong
   CLEA
   @ 10,10 SAY 'The search string is too long - you can have no more than '
   @ 11,10 SAY '140 characters in the string and the field names.  Please '
   @ 12,10 SAY 'try again.'
   @ 13,30 SAY 'HIT ANY KEY TO CONTINUE'
   SET CONSOL OFF
   WAIT
   SET CONSOL ON
  ELSE
   STOR 'Y' TO printer
   STOR 'N' TO disk
   STOR '        ' TO filename
   STOR ' ' TO command
   @ 20,00
   @ 20,22 SAY "Send Report to the Printer (Y/N)"
   @ 20,55 GET printer PICTURE '!'
   READ
   @ 21,22 SAY "Send Report to a Disk File (Y/N)"
   @ 21,55 GET disk PICTURE '!'
   READ
   IF disk ='Y'
    @ 22,22 SAY "Enter Disk File Name"
    @ 22,44 GET filename PICTURE '!!!!!!!!'
    @ 22,54 SAY "(.TXT will be added )"
    READ
    STOR 'C' TO dr
    @ 22,00
    @ 22,22 SAY 'Select drive to put Files on  ' GET dr PICTURE '!'
    READ
    DO WHIL AT(dr,'ABC') = 0
     @ 22,00
     @ 22,22 SAY 'Select drive to put Files on  ' GET dr PICTURE '!'
     READ
    ENDD
   ENDI
   STOR '                                                            ' TO caption
   STOR 'Y' TO again
   @ 20,00
   @ 21,00
   @ 22,00
   @ 20,12 SAY 'Please State the Caption of the Report (do not center):'
   @ 21,10 GET caption PICTURE '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
   READ
   @ 22,20 SAY 'Is the caption correct ?'
   @ 22,49 GET again PICTURE '!'
   READ
   IF again = 'N'
    @ 21,10 GET caption PICTURE '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    READ
   ENDI again
   STOR '                                                                   ' TO pad
   STOR TRIM(caption) TO caption
   STOR (122-LEN(caption))/2  TO adjust
   STOR SUBSTR(pad,1,adjust) + caption TO caption
   RELE pad, adjust, again
   IF disk = 'Y' .AND. filename <> ' '
    STOR AT('.',filename) TO length
    IF length = 0 .OR. length > 8
     STOR 9 TO length
    ENDI
    STOR SUBSTR(filename,1,length-1) TO filename
    STOR '&dr.:'+filename+'.TXT' TO filename
    SET ALTERNATE TO &filename
    SET ALTERNATE ON
   ENDI
   STOR 'Y' TO command
   STOR 0 TO pagen
   CLEA
   @ 10,10 SAY 'I am looking for the first instance of a file which meets your'
   @ 11,10 SAY 'requirements. Please be patient.'
   SET FILTER TO &finder
   GO TOP
   IF .NOT. (EOF() .OR. BOF())
    IF printer = 'Y'
     SET PRINT ON
     EJEC
    ENDI
    STOR .t. TO more2
    DO WHIL more2
     STOR pagen + 1 TO pagen
     STOR 0 TO lineno
     ? '  '
* and write TITLE
     ? caption
     ? ' '
     ? 'Report of ' +DTOC(date()) + '.        ' + '             Page: '+STR(pagen,3)
* now fill up rest of page to 55 lines with names etc
     DO WHIL lineno < 55
* now do a page if not end of file
      IF .NOT. EOF()
       ? '-------------------------------------------------------------------'
       ? '     ' +  "Name: "+ TRIM(mr)+' ' + TRIM(fname) +' ' + lastname
       ? '     ' + "Spouse: " + spouse + "Address as: " + dear
       ? '     ' + "Title: " + title
       ? '     ' + "Company: " + company1
       ? '     ' + "       : " + company2
       ? '     ' + "Address: " + TRIM(caddress) + "  " + suite
       ? '     ' + "         " + TRIM(ccity) +'  ' + cst + '  ' +czip
       ? '     ' + "Home address: " + TRIM(address) + "  " + apt
       ? '     ' + "              " + TRIM(city) +'   '+  st + '  ' +zip
       ? '     ' + 'Phones - office: ' + ophone + ' home: ' + phone
       ? '     ' + "List:  " + cs1 + "   Code: " + cs2
       ? '     ' + "Send to office: " + send
       ? '     ' + "Date update: " + update
       STOR lineno +13 TO lineno
       SKIP
* if deleted, skip again
       IF DELETE()
        SKIP
       ENDI
      ELSE
       STOR .f. TO more2
       STOR 60 TO lineno
      ENDI .NOT. EOF
     ENDD while lineno < 55
    ENDD more2
    IF printer = 'Y'
     EJEC
    ENDI
    SET PRINT OFF
   ENDI .NOT. eof
  ENDI toolong
  SET DELIMITER OFF
  STOR .f. TO more3
 CASE dowhat = 'L'
  IF toolong
   CLEA
   @ 10,10 SAY 'The search string is too long - you can have no more than '
   @ 11,10 SAY '140 characters in the string and the field names.  Please '
   @ 12,10 SAY 'try again.'
   @ 13,30 SAY 'HIT ANY KEY TO CONTINUE'
   SET CONSOL OFF
   WAIT
   SET CONSOL ON
  ELSE
   CLEA
   STOR 0 TO counter
   CLEA
   @ 10,10 SAY 'I am looking for the first instance of a file which meets your'
   @ 11,10 SAY 'requirements. Please be patient.'
   SET FILTER TO &finder
   GO TOP
   IF .NOT. (EOF() .OR. BOF())
    CLEA
    SET print on
* if you have to set your printer for labels
* put the code in here i.e. ? chr(29) (small type on OKIDATA 92)
    SET margin to 5
    SET PRINT OFF
    STOR .t. TO lineup
    DO WHIL LINEUP
     STOR 'Y' TO command
     @ 10,00
     @ 11,00
     @ 10,10 SAY 'Please line up the top of the ribbon with the top of the label'
     @ 11,10 SAY 'When lined up hit ENTER for a print check.'
     SET CONSOLE OFF
     WAIT
     SET PRINT ON
     SET MARGIN TO 0
     ? 'THE TOP OF THE TOP LINE SHOULD BE ABOUT'
     ? '1/4" FROM THE TOP OF THE LABEL'
     ? ' '
     SET PRINT OFF
     SET CONSOLE ON
     @ 10,00
     @ 11,00
     @ 10,10 SAY 'Are you lined up to print (Y/N) '
     @ 10,44 GET command picture '!'
     READ
     CLEA GETS
     IF command = 'Y'
      SET PRINT ON
      ? ' '
      ? ' '
      SET PRINT OFF
      STOR .f. TO lineup
     ENDI command = y
    ENDD while lineup
    CLEA
    DO WHIL .NOT.(EOF().OR. BOF())
     SET PRINT ON
     STOR 0 TO count
     IF send = 'Y'
      ? TRIM(mr)+' ' + TRIM(fname) +' ' + lastname
      IF SUBSTR(title,1,6) <> '      '      
       ? title
      ELSE
       STOR count+1 TO count
      ENDI
      IF SUBSTR(company1,1,6) <> '      '      
      ? company1
      ELSE
       STOR count+1 TO count
      ENDIF
      IF SUBSTR(company2,1,6) <> '      '      
       ? company2
      ELSE
       STOR count+1 TO count
      ENDI
      ? TRIM(caddress) + "  " + suite
      ? TRIM(ccity) +'    ' + cst + '  ' +czip
      DO WHIL count > 0
       ? '  '
       STOR count -1 TO count
      ENDD
     ELSE
      ? ' '
      ? TRIM(mr)+' ' + TRIM(fname) +' ' + lastname
      ? TRIM(address)+ '    ' + apt
      ? TRIM(city) + '   ' + st + '  ' + zip
      ? ' '
      ? '  '
      ? '  '
     ENDI
     SKIP
    ENDD while not eof
    EJEC
    SET PRINT OFF
    SET MARGIN TO 0
   ENDI
  ENDI toolong
  SET DELIMITER OFF
  STOR .f. TO more3
 CASE dowhat = 'W'
  IF toolong
   CLEA
   @ 10,10 SAY 'The search string is too long - you can have no more than '
   @ 11,10 SAY '140 characters in the string and the field names.  Please '
   @ 12,10 SAY 'try again.'
   @ 13,30 SAY 'HIT ANY KEY TO CONTINUE'
   SET CONSOL OFF
   WAIT
   SET CONSOL ON
  ELSE
   CLEA
   STOR 0 TO counter
   CLEA
   @ 10,10 SAY 'I am looking for the first instance of a file which meets your'
   @ 11,10 SAY 'requirements. Please be patient.'
   SET FILTER TO &finder
   GO TOP
   IF .NOT. (EOF() .OR. BOF())
    STOR .t. TO continue
    DO WHIL continue
     STOR 1 TO counter
     CLEA
     STOR 'C' TO dri
     @ 20,00
     @ 21,00
     @ 22,00
     @ 20,10 SAY 'On what drive do you want the file ?'
     @ 20,50 GET dri PICTURE '!'
     READ
     DO WHIL AT(dri,'CAB')=0
      @ 20,50 GET dri PICTURE '!'
      READ
     ENDD
     STOR '      ' TO file_dat
     @ 21,10 SAY 'Enter Name of the WordStar-MailMerge file  '
     @ 21,55 GET file_dat PICTURE '!!!!!!'
     READ
     DO WHIL file_dat = '      '
      @ 21,55 GET file_dat PICTURE '!!!!!!'
      READ
     ENDD
     STOR dri+':'+file_dat TO file_dat
     STOR 'W' TO prg
     @ 22,10 SAY 'Will the printing be with <W>ordstar or <N>ewword ?'
     @ 22,60 GET prg PICTURE '!'
     READ
     DO WHIL AT(prg,'NW')=0
      @ 22,60 GET prg PICTURE '!'
      READ
     ENDD
     IF prg = 'N'
      STOR ' ' TO ending
     ELSE
      STOR ',' TO ending
     ENDI
     CLEA
     STOR UPPER(file_dat) TO file_dat
     STOR SUBSTR(file_dat,1,8) TO file_dat
     STOR file_dat+'.DOC'  TO file_doc
     STOR file_dat+'.DAT'  TO file_dat
     @ 03,10 SAY  'Creating WordStar-MailMerge Document file:  '+file_doc
     SET CONSOLE OFF
     SET ALTERNATE TO &file_doc
     SET ALTERNATE ON
     ? '.OP'
     ? '.DF '+file_dat
     ? '.RV '+' last-name, first-name, mr, dear, title, company1, company2, street, suite-apt, city, state, zip'
     ? '.. for title, company1, company2  use &title/O&, &company1/O&, &company2/O&'
     ? '.. to automatically omit empty data fields'
     SET ALTERNATE OFF
     SET CONSOLE ON
     @ 05,10 SAY  ' Creating WordStar-MailMerge Data file:  '+file_dat
     ?
     ?
     ?? 'Writing record #     '
     SET CONSOLE OFF
     SET ALTERNATE TO &file_dat
     SET ALTERNATE ON
* repeat until end of file
     DO WHIL .NOT.(EOF() .OR. BOF())
* if there is a chance of a comma in a field then trim and put in quotes
      IF send <> 'Y'
* if it is NOT a company address then...
* make blanks for these first 3 variables
       STOR ' ' TO titleline
       STOR ' ' TO coname1
       STOR ' ' TO coname2
       STOR CHR(34)+TRIM(address)+CHR(34) TO street
       STOR CHR(34)+TRIM(city)+CHR(34) TO cityto
       STOR st TO stto
       STOR zip TO zipto
* if a field is empty then store it as a blank variable...
* but trim and put quotes around a non-empty field
       IF apt = ' '
        STOR ' ' TO room
       ELSE
        STOR CHR(34)+TRIM(apt)+CHR(34) TO room
       ENDI
      ELSE
* if it is a company address etc do the following...
       STOR CHR(34)+TRIM(caddress)+CHR(34) TO street
       STOR CHR(34)+TRIM(ccity)+CHR(34) TO cityto
       STOR cst TO stto
       STOR czip TO zipto
       IF title = ' '
        STOR ' ' TO titleline
       ELSE
        STOR CHR(34)+TRIM(title)+CHR(34) TO titleline
       ENDI
       IF company1 = ' '
        STOR ' ' TO coname1
       ELSE
        STOR CHR(34)+TRIM(company1)+CHR(34) TO coname1
       ENDI
       IF company2 = ' '
        STOR ' ' TO coname2
       ELSE
        STOR CHR(34)+TRIM(company2)+CHR(34) TO coname2
       ENDI
       IF suite = ' '
        STOR ' ' TO room
       ELSE
        STOR CHR(34)+TRIM(suite)+CHR(34) TO room
       ENDI
      ENDI send letter to office
* now write data to the WS MailMerge file
* the first 4 variables are raw field names that must contain data...
* and can contain commas ; so trim them  and enclose in quotes
* all other variables have been 'fixed' in the above IF statements
      ?
      ?? CHR(34)+TRIM(lastname)+CHR(34) +','
      ?? CHR(34)+TRIM(fname)+CHR(34) +','
      ?? CHR(34)+TRIM(mr)+CHR(34) +','
      ?? CHR(34)+TRIM(dear)+CHR(34) +','
      ?? titleline +','
      ?? coname1 +','
      ?? coname2 +','
      ?? street +','
      ?? room +','
      ?? cityto +','
      ?? stto +','
      ?? zipto +ending
      SKIP
* tell em that you are busy
      SET CONSOLE ON
      SET ALTERNATE OFF
      SET CONSOLE ON
      ?? STR(COUNTER,5)
      SET CONSOLE OFF
      SET ALTERNATE ON
      STOR COUNTER + 1 TO COUNTER
     ENDD while not EOF
     STOR .f. TO continue
    ENDD continue
    SET ALTERNATE OFF
    SET CONSOLE ON
   ENDI
  ENDI toolong
  SET DELIMITER OFF
  STOR .f. TO more3
 CASE dowhat = 'Q'
  STOR .f. TO more3
 ENDC
ENDD while more3
SET FILTER TO
SET DELIMITER ON
RETU

                                                                                   