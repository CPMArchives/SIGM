* DATE 08/27/84  12:12                 
* mail.prg 
* This is a highly complicated program and your help in both clearing
* up the bugs and making suggestions will be appreciated. My thanks to the
* many people who helped test and revise this program - and especially to
* Lee Hilliard for some great code and for his pretty print and dBASE syntax
* checker program. Lee is at Hilco Software, 304 N. 17th St., Mt. Vernon
* WA 98273. (206) 428-0474. I might add that the coded portion of the program
* was done using RECODE by Hilco.
*
* Please contact:
*                   Stephen M. Leon
*                   200 Winston Drive
*                   Cliffside Park, NJ 07010
*                   (201) 886-1658
*                         or
*                   Department of Law
*                   2 World Trade Center
*                   New York, NY 10047
*                   (212) 488-7677
*******************************************************************************
* This program is distributed free (for a nominal media charge) by SIG/M      *
* Special Interest Group/Microcomputers, Box 97, Iselin, NJ 08830.            *
* SIG/M is a not-for-profit undertaking of the Amateur Computer Group of New  *
* Jersey and the New York Amateur Computer Club. This program is also made    *
* available for PC users via PC/BLUE SOFTWARE, also a not-for profit under-   *
* taking of the New Jersey and New York clubs. Permission is granted to any   *
* other not-for-profit group to include this program in their library so long *
* as this notice is retained. Copyright 1984 by STEPHEN. M. LEON              *
*******************************************************************************
CLEA
RELE ALL
RESE
SET TALK OFF
IF .NOT. file ("MAIL.DAT")
 DO INIT.ACG
ENDI .NOT. file
REST from mail.dat additive
IF escap = 'N'
 SET ESCAPE OFF
ENDI excap = 'Y'
IF bells = 'N'
 SET BELL OFF
ENDI bells
IF bright = 'I'
 SET INTENSITY OFF
ENDI brght = 'I'
IF PASS = 'Y'
 ERAS
 @ 12,10 SAY 'PLEASE ENTER THE PASSWORD SLOWLY ........'
 SET EXACT ON
 SET COLON OFF
 STOR '12345678' TO passt
 STOR ' ' TO passt1
 STOR ' ' TO one
 STOR ' ' to one1
 STOR 0 to count
 DO WHIL count < 8
  SET CONSOLE OFF
  @ 12,50 SAY passt1
  WAIT TO one1
  @ 12,50 ACCEPT one1
  SET CONSOLE ON
  STOR TRIM(one) + one1 TO one
  STOR count + 1 TO count
  STOR $(passt,1,count) TO passt1
  @ 12,50 SAY passt1
  SET CONSOLE OFF
 ENDD
 SET CONSOLE ON
 STOR $(one,2,9) TO passt
 IF passt <> passp
  ERAS
  @ 14,10 SAY "U N A U T H O R I Z E D       A C C E S S  "
  @ 17,10
  SET CONSOLE OFF
  QUIT
 ENDI passt
 SET EXACT OFF
 SET COLON ON
ENDI pass
ERAS
TEXT

 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 *                                                                           *
 *                 AMATEUR COMPUTER GROUP OF NEW JERSEY                      *
 *                                                                           *
 *                                                                           *
 *                                                                           *
 *                                                                           *
 *                                                                           *
 *                                                                           *
 *                                                                           *
 *                                                                           *
 *                                                                           *
 *                                                                           *
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
          





ENDT
@ 6,18 SAY "SIG/M   M A I L I N G   M A N A G E R"
STOR 55 TO length
STOR 18 TO  times
DO WHIL times < length
 @ 7,times SAY '_'
 STOR times + 1 TO times
 LOOP
ENDD
TEXT
 *                                                                           *
 *                   A dBASEII DATA MANAGEMENT PROGRAM                       *
 *                     For Mailing List Maintainenace                        *
 *                             by Stephen M. Leon                            *
 *                                                                           *
 *                                        Vers 2.0   Oct 1984 (c) 1984       *
 *                                                                           *
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<






ENDT
RELE times, length
IF C = 'Y'
 STOR 41984 TO adr
*in cp/m 80 there is a jmp at location 0 & 5
 IF (PEEK(0)=195 .AND. PEEK(5)=195)
*use 8080 code
  POKE adr ,35,17,37,164,14,6,6,2,26,19,198,16,211,90,254,21,219,91,194,23,164,214,8,198,48,119,35,5,194,8,164,35,13,194,6,164,201,10,9,8,7,12,11,5,4,3,2,1,0
 ELSE
*use 8086 code
  POKE adr ,67,190,38,164,177,6,181,2,138,4,70,4,16,230,90,60,21,228,91,117,2,44,8,4,48,136,7,67,254,205,117,232,67,254,201,117,225,195,10,9,8,7,12,11,5,4,3,2,1,0
 ENDI (PEEK)
 SET CALL TO adr
 STOR '  /  /  ,  :  :  ' TO mem:var
 CALL mem:var
 STOR $(mem:var,1,8) TO mdate
 STOR $(mem:var,10,8) TO mtime
 SET DATE  TO &mdate
 @ 17,10 SAY 'Today is ' + mdate
 @ 17,32 SAY '....and the time is  ' + mtime
* Regular date program
ENDI C='Y'
IF I = 'N'
 STOR '                                                  ' TO BLNKS
 IF DATE() = '00/00/00'
  STOR F   TO OK
 ELSE
  STOR T   TO OK
  STOR 0   TO MM
 ENDI
 DO WHIL .NOT. OK
  STOR $(BLNKS,1,8)            TO DATE:VAR
  STOR $(BLNKS,1,42)	   TO ERRX
  @ 18,15 SAY 'Enter Date as MM/DD/YY '
  @ 18,43 GET DATE:VAR  picture '##/##/##'
  READ
  STOR val($(DATE:VAR,1,2))    TO MM
  STOR val($(DATE:VAR,4,2))    TO DD
  STOR val($(DATE:VAR,7,2))    TO YY
  DO CASE
  CASE MM<1 .or. MM>12 .or. DD<1 .or. DD>31 .or. YY<80
   STOR '       Invalid Date - Reenter'   to ERRX
  CASE MM=4 .or. MM=6 .or. MM=9 .or. MM=11
   IF DD>30
    STOR 'Thirty Days hath September, etc. - Reenter'   to ERRX
   ELSE
    STOR T TO OK
   ENDI dd
  CASE MM=2 .and. DD>28 .and. ((1900 + YY)/4)<>int(((1900 + YY)/4))
   STOR '     Not a leap year - Try Again'   TO ERRX
  CASE MM=2 .and. DD>29
   STOR 'February has a Maximum of 29 Days - Reenter' TO ERRX
  OTHE
   @ 20,00
   STOR T   TO OK
   LOOP
  ENDC
  @ 20,00
  @ 20,15 SAY ERRX
 ENDD (.not. OK)
 IF MM>0
  RELE ERRX, OK, MM, DD, YY
  SET date TO &DATE:VAR
  CLEA GETS
 ENDI mm
ENDI I = 'N'
* poke drive letter into memory 039 hex
* IF converting to dBASEIII - set up a public memory variable for drive letter
* You will also have to change the PEEK in each module.
POKE 063,(64+@(dr,'ABCDEFGHIJKLMNOPQRSTUVWXYZ'))
RELE ALL
DO main.acg

