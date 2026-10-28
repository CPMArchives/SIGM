CLEA
SET BELL OFF
SET TALK OFF
USE phone
GO BOTT
STOR # TO stat
IF FILE('phone.ndx')
 SET INDE TO phone
ELSE
 ? 'Making new index'
 INDE ON !(name) TO phone
ENDI
STOR f TO flag,m1
DO WHIL .not.m1
 ERAS
 @ 1,57 SAY stat USIN '#####'
 @ 1,63 SAY 'active entries.'
 @ 4,20 SAY ' '
 ?? '*** TELEPHONE DIRECTORY SYSTEM ***'
 @ 7,10 SAY 'Press      In order to'
 @ 8,10 SAY '=====      ======================================'
 @ 9,12 SAY 'S        SEARCH directory to find or EDIT entry'
 @ 10,12 SAY 'A        ADD a new entry to directory'
 @ 11,12 SAY 'D        DELETE an existing entry'
 @ 12,12 SAY 'X        EXIT directory system'
 @ 15,20 SAY ' '
 ?? 'Enter your choice here'
 STOR ' ' TO c1
 DO WHIL .not.c1$'SADX'
  STOR ' ' TO c1
  @ 15,45 GET c1 PICT '!'
  READ
  @ 22,0
  IF .not.c1$'SADX'
   @ 22,0 SAY 'Invalid selection'+chr(7)
  ENDI
  IF c1='X'
   STOR t TO m1
   @ 22,0
   @ 22,21 SAY 'Do you REALLY want to quit? (T/F) ' GET m1  
   READ
   IF .not.m1
    STOR ' ' TO c1
   ENDI
  ENDI
  IF c1$('SD').and.stat=0
   @ 22,0 SAY 'No entries to edit'+chr(7)
   STOR ' ' TO c1
  ENDI
 ENDD
 IF m1
  LOOP
 ENDI
 ERAS
 @ 1,1 SAY ' '
 IF c1='S'
  ?? '(SEARCH / EDIT MODE)'
 ELSE
  IF c1='D'
    ?? '(DELETE MODE)'
  ELSE
   ?? '(ADD MODE)'
  ENDI
 ENDI
 @ 4,21 SAY ' '
 ?? '*** TELEPHONE DIRECTORY SYSTEM ***'
 @ 6,02 SAY 'Name .............'
 @ 8,02 SAY 'Office telephone .'
 @ 10,02 SAY 'Home telephone ..'
 @ 12,02 SAY 'Address .........'
 @ 15,02 SAY 'City ............'
 @ 15,42 SAY 'State'
 @ 15,55 SAY 'Zip'
 IF c1$'SD'
  STOR t TO s1
  DO WHIL s1
   STOR '                              ' TO sname
   @ 22,21 SAY ' Enter any part of name to be searched.    '
   @ 6,22 GET sname PICT '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
   READ
   COUN FOR TRIM(sname)$(!(name)).AND..NOT.* TO hold
   IF hold=0
    @ 22,21 SAY 'Unable to find name. Try again? (T/F)  ' GET s1            
    READ
    LOOP
   ELSE
    STOR f TO s1
   ENDI
  ENDD
  IF hold=0
   LOOP
  ENDI
  GO TOP
  LOCA FOR TRIM(sname)$(!(name)).AND..NOT.*
  STOR 1 TO cu
  @ 1,39 SAY 'Working #     of     matching entries.'
  @ 1,56 SAY hold USIN '###'
  DO WHIL .NOT.EOF
   @ 1,49 SAY cu USIN '###'
   @ 6,22 SAY name
   @ 8,22 SAY offphone
   @ 10,22 SAY homphone
   @ 12,22 SAY addr1
   @ 13,22 SAY addr2
   @ 14,22 SAY addr3
   @ 15,22 SAY city
   @ 15,50 SAY state
   @ 15,62 SAY zip
   STOR cu+1 TO cu
   STOR f TO de
   CLEA GET
   @ 22,0
   IF c1='D'
    @ 22,21 SAY 'Delete this entry? (T/F) ' GET de           
    READ
    IF de
     DELE
     STOR stat-1 TO stat
     STOR t TO flag
    ENDI
    CONT
    LOOP
   ENDI
   IF c1='S'
    @ 22,21 SAY 'Edit this entry ? (T/F) ' GET de          
    READ
    IF .not.de
     CONT
     LOOP
    ELSE
     STOR name TO mname
     STOR offphone TO moffphon
     STOR homphone TO mhomphon
     STOR addr1 TO maddr1
     STOR addr2 TO maddr2
     STOR addr3 TO maddr3
     STOR city TO mcity
     STOR state TO mstate
     STOR zip TO mzip
     STOR f TO de
     DO WHIL .not.de
      CLEA GET
      @ 6,21 GET mname PICT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
      @ 8,21 GET moffphon PICT '(999) 999-9999'
      @ 10,21 GET mhomphon PICT '(999) 999-9999'
      @ 12,21 GET maddr1 PICT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
      @ 13,21 GET maddr2 PICT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
      @ 14,21 GET maddr3 PICT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
      @ 15,21 GET mcity PICT 'XXXXXXXXXXXXXXXXXX'
      @ 15,49 GET mstate PICT '!!'
      @ 15,61 GET mzip PICT '99999X9999'
      READ
      CLEA GET
      STOR t TO ck
      DO WHIL ck
       IF mstate+'.'$'  .AL.AK.AZ.AR.CA.CO.CT.DE.DC.FL.GA.HI.ID.;
IL.IN.IA.KS.KY.LA.ME.MD.MA.MI.MN.MS.MO.MT.NE.NV.NH.NJ.NM.NY.NC.ND.OH.;
OK.OR.PA.RI.SC.SD.TN.TX.UT.VT.VA.WA.WV.WI.WY.'
        STOR f TO ck
        @ 22,0
       ELSE
        @ 22,0 SAY 'Invalid State'+chr(7)
        @ 15,49 GET mstate PICT '!!' 
        READ
        CLEA GET
        LOOP
       ENDI
      ENDD
      STOR t TO de
      @ 22,21 SAY 'Is information correct? (T/F) ' GET de          
      READ
      IF .not.de
       @ 22,21 SAY 'Change the desired information   '
      ENDI
     ENDD
     REPL name WITH mname,offphone WITH moffphon,homphone WITH mhomphon,;
addr1 WITH maddr1, addr2 WITH maddr2,addr3 WITH maddr3,city WITH mcity,;
state WITH mstate,zip WITH mzip
    ENDI
   ENDI
   CONT
  ENDD
 ENDI
 IF c1='A'
  STOR t TO de
  DO WHIL de
   STOR '                                        ' TO mname
   STOR $(mname,1,14) TO moffphon,mhomphon
   STOR $(mname,1,30) TO maddr1,maddr2,maddr3
   STOR $(mname,1,18) TO mcity
   STOR $(mname,1,2) TO mstate
   STOR $(mname,1,10) TO mzip
   STOR f TO de
   DO WHIL .not.de
    CLEA GET
    @ 6,21 GET mname PICT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    @ 8,21 GET moffphon PICT '(999) 999-9999'
    @ 10,21 GET mhomphon PICT '(999) 999-9999'
    @ 12,21 GET maddr1 PICT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    @ 13,21 GET maddr2 PICT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    @ 14,21 GET maddr3 PICT 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
    @ 15,21 GET mcity PICT 'XXXXXXXXXXXXXXXXXX'
    @ 15,49 GET mstate PICT '!!'
    @ 15,61 GET mzip PICT '99999X9999'
    READ
    CLEA GET
    STOR t TO ck
    DO WHIL ck
     IF mstate+'.'$'  .AL.AK.AZ.AR.CA.CO.CT.DE.DC.FL.GA.HI.ID.;
IL.IN.IA.KS.KY.LA.ME.MD.MA.MI.MN.MS.MO.MT.NE.NV.NH.NJ.NM.NY.NC.ND.OH.;
OK.OR.PA.RI.SC.SD.TN.TX.UT.VT.VA.WA.WV.WI.WY.'
      STOR f TO ck
      @ 22,0
     ELSE
      @ 22,0 SAY 'Invalid State'+chr(7)
      @ 15,49 GET mstate PICT '!!' 
      READ
      CLEA GET
      LOOP
     ENDIF
    ENDD
    STOR t TO de
    @ 22,21 SAY 'Is information correct? (T/F)  ' GET de          
    READ
    IF .not.de
    @ 22,21 SAY 'Change the desired information    '
    ENDI
   ENDD
   APPE BLAN
   REPL name WITH mname,offphone WITH moffphon,homphone WITH mhomphon,;
addr1 WITH maddr1, addr2 WITH maddr2,addr3 WITH maddr3,city WITH mcity,;
state WITH mstate,zip WITH mzip
   STOR stat+1 TO stat
   CLEA GET
   @ 22,21 SAY 'Another entry now ? (T/F)      ' GET de           
   READ
   @ 22,0
  ENDD
 ENDI
ENDD
@ 22,0
IF flag
 @ 22,0 SAY 'Packing database '
 COPY TO temp
 USE temp
 INDE ON !(name) TO phone
 USE
 SELE SECO
 USE
 DELE FILE phone.dbf
 RENA temp.dbf TO phone.dbf
ENDI
@ 22,0 SAY 'Program terminated '
QUIT
* STRUCTURE FOR FILE:  PHONE.DBF
* FLD     NAME       TYPE  WIDTH
* 001     NAME         C    040
* 002     OFFPHONE     C    014
* 003     HOMPHONE     C    014
* 004     ADDR1        C    030
* 005     ADDR2        C    030
* 006     ADDR3        C    030
* 007     CITY         C    018
* 008     STATE        C    002
* 009     ZIP          C    010
* ** TOTAL **             00190
