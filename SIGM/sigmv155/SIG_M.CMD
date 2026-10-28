* SIG/M.CMD  12/18/83
* THIS IS THE STARTING PROGRAM IN A RATHER COMPREHENSIVE DUAL DATA
* BASE. THE KEY PROGRAMS ARE MAIN.SIG AND MAIN.INV. MENU.SIG IS
* THE "TRAFFIC COP." THE ORDERS DATA BASE IS CALLED SIG/M. THE
* INVENTORY DATA BASE IS CALLED STOCK. WHEN AN ORDER IS ENTERED
* THE PROGRAM DETERMINES IT VALIDITY, DELETES IT FROM INVENTORY
* OR BACKORDERS IT. IT PRINTS ALL SORTS OF REPORTS, ETC.
* A TUTORIAL DATA BASE WAS ISSUED ON SIG/M VOLUME 110. BECAUSE OF THE
* LARGE NUMBER OF REQUESTS FOR THAT VOLUME (COUPLED WITH A SIG/M RE-
* QUIREMENT FOR AN INVENTORY DATA BASE) WITH THE SIGNIFICANT HELP OF
* HARRY VAN TASSELL I WROTE THIS PROGRAM. THE VOLUME 110 DATA BASE
* IS NOT MAXIMIZED FOR SPEED - THIS IS. ON OUR WORKING VERSION OF THIS PROGRAM
* WE REMOVED ALL COMMENTS AND SET UP EVERYTHING USING FASTBASE. IN THIS
* LIBRARY FILE WE HAVE LEFT IT AS PRETTY PRINTED BY FASTBASE FOR EASE IN
* UNDERSTANDING. SPEAKING OF FASTBASE, I HAVE TRIED MOST OF THE dBASE
* GENERATORS AND EXCEPT FOR ZIP FIND THEM OF LITTLE VALUE. I RECENTLY
* PURCHASED FASTBASE FROM FOURCOLOR DATA SYSTEMS IN DAYTON AND WAS
* SO IMPRESSED WITH SOME OF THE THINGS IT COULD DO THAT I INCLUDED AS
* SEARCH1.SIG THE SEARCH FILE IT GENERATED. IT FINDS ANY STRING ANY
* PLACE IN ANY FIELD AND IN EVERY RECORD. ITS INDEX SEARCH IS ALSO
* EXCELLENT AND THE DISPLAY IN SO-CALLED FAST MODE IF FAR BETTER
* THAN THE dBASE NORMAL DISPLAY.
* THE PROGRAM IS PRETTY MUCH SELF EXPLANATORY. TRY IT - SEE HOW IT
* WORKS AND ADJUST IT FOR YOUR OWN REQUIREMENTS.  PLEASE LET US KNOW OF
* ANY PROBLEMS AND SEND US ANY IMPROVEMENTS.
*                                        Steve Leon
*                                        200 Winston Drive
*                                        Cliffside Park, NJ 07010
*                                        (201) 886-1658
* This initialization program is run once, when the program is first started
* it will initialize the variables, set up environment and do a sign-on.
* Place all command which affect the entire system here.
* place your choice of intensity, confirm, etc. here.
* If you want to use highlighting, we suggest you not do it
* here. Do it in connection with the "IF FIRST" on the main
* screen calls. See MAIN.SIG and MAIN.INV
SET TALK OFF
SET INTENSITY OFF
* THIS PROGRAM RUNS FINE UNDER CPM/86. JUST CHANGE ITS NAME TO SIG/M.PRG
* WE ARE ABLE TO DISTINGUISH BETWEEN CP/M 80 AND CPM/86 ON ALL
* SYSTEMS WE HAVE TRIED.  IF YOU HAVE A PROBLEM WITH YOUR SYSTEM
* JUST TAKE OUT THE AUTOMATIC RECOGNITION AND/OR AUTOMATIC INPUT.
* HOWEVER, NEVER USE A CP/M 80 MEMORY FILE ON CP/86 AND VICE
* VERSA. JUST DELETE IT - THE PROGRAM WILL CREATE A NEW ONE
* HERE WE CREATE OUR VARIABLES FOR ADDING RECORDS TO THE .SIG FILES
IF .NOT. FILE("add.mem")
    STORE '         ' TO morder
    STORE ' ' TO mback
    STORE ' ' TO mcomp
    STORE '                    ' TO mlname
    STORE '               ' TO mfname
    STORE '                                   ' TO maddr1
    STORE '                                   ' TO maddr2
    STORE '                                   ' TO maddr3
    STORE '                         ' TO mcity
    STORE '  ' TO mstate
    STORE '     ' TO mzip
    STORE 000.00 TO mamt
    STORE 999 TO mvol
    STORE '            ' TO mstatus
    STORE '                                                                                                                                    ' TO mvol1
    STORE '        ' TO mentered
    STORE '        ' TO mshipped
    STORE '                                                                  ' TO mrem1
    STORE '                                                                  ' TO mrem2
    STORE '                                                                                                  ' TO mbo
    STORE ' ' TO mcatalog
    STORE '        ' TO mbo:ship
    STORE '        ' TO mbo2:ship
    STORE '        ' TO mdayu
    STORE '             ' TO mstatus
    SAVE TO ADD
    RELEASE ALL
ENDIF
ERASE
? '   *>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'
? '   *                                                                      *'
? '   *               AMATEUR COMPUTER GROUP OF NEW JERSEY                   *'
? '   *                                                                      *'
? '   *                              SIG/M                                   *'
? '   *                 LIBRARY OF PUBLIC DOMAIN SOFTWARE                    *'
? '   *                                                                      *'
? '   *           A dBASEII Program by Steve Leon for..........              *'
? '   *                                                                      *'
? '   *              DISK INVENTORY            ORDER PROCESSING              *'
? '   *                 SHIPPING                  DISK LABELS                *'
? '   *                                                                      *'
? '   *                                              Vers 1.1 Dec. 18, 1983  *'
? '   *>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*'
* If you have a Compupro System Support Board leave the following code in.
* It automatically sets the date. Otherwise, since the program requires
* that the date be entered, you will have to manually enter the date in
* response to the prompt.
* Read date from Compupro System Support board, store the date into DBASE
* DATE() function.  See file DATETIME.ASM for assembly language source code
* from which the POKE list values are determined.
*
*
*STORE 41984 TO adr       
*in cp/m 80 there is a jmp at location 0 & 5
*IF (PEEK(0)=195 .AND. PEEK(5)=195)
*use 8080 code
*POKE adr ,35,17,37,164,14,6,6,2,26,19,198,16,211,90,254,21,219,91,194;
*,23,164,214,8,198,48,119,35,5,194,8,164,35,13,194,6,164;
*,201,10,9,8,7,12,11,5,4,3,2,1,0
*ELSE                             
*use 8086 code
*POKE adr ,67,190,38,164,177,6,181,2,138,4,70,4,16,230,90,60,21,228,91,117;
*,2,44,8,4,48,136,7,67,254,205,117,232,67,254,201,117,225,195,10,9;
*,8,7,12,11,5,4,3,2,1,0
*ENDIF
*SET CALL TO adr       
*STORE '  /  /  ,  :  :  ' TO mem:var
*CALL mem:var
*STORE $(mem:var,1,8) TO mdate
*STORE $(mem:var,10,8) TO mtime
*SET DATE  TO &mdate
***************************************************************************
*@ 17,10 SAY 'Today is ' + mdate 
*@ 17,32 SAY '....and the time is  ' + mtime 
****************************************************************************
* IF YOU DO NOT HAVE AUTOMATIC DATE READ - YOU WILL HAVE TO INPUT DATENPU
* THE PROGRAM REQUIRES THAT YOU INPUT A DATE AND A DATE VALIDATION PROGRAM
* BY WILLIAM G. HURST WE FOUND IN dNEWS IS INCLUDED.
* AS MODIFIED TO RUN UNDER DBASEII VERSION 2.4
* set up for date
DO WHILE $(DATE(),1,2)='00'
STORE '        ' TO date:var
@ 18,15 SAY 'Enter date as MM/DD/YY '
@ 18,43 GET date:var  PICTURE '##/##/##'
READ
CLEAR GETS
* flag set to'1'
STORE '1' TO invalid
DO WHILE invalid = '1'
STORE $(date:var,1,2) TO mm1
STORE VAL(mm1) TO mm
STORE $(date:var,4,2) to dd1
STORE VAL(dd1) to dd
STORE $(date:var,7,2) TO yy1
STORE VAL(yy1) TO yy
* Each case below is a negative test. Date is valid
* if none of the tests prove true.
DO CASE
* check for improper month, day or year
CASE mm<1 .OR. mm>12 .OR. dd<1 .OR. dd>31 .OR. yy<83
STORE '        ' TO date:var
@ 20,00
@ 20,15 SAY 'NO SUCH DATE - PLEASE TRY AGAIN'
@ 18,43 GET date:var PICTURE '##/##/##'
READ
CLEAR GETS
* check for 31 days in 30 day month
CASE(((mm<8.AND.mm/2=INT(mm/2)).OR.(mm>7.AND.;
 mm/2<>INT(mm/2))).AND.dd>30
* invalid date:user is prompted for reentry
STORE '        ' TO date:var
@ 20,00
@ 20,15 SAY 'SORRY - WRONG NUMBER OF DAYS FOR THE MONTH - TRY AGAIN'
@ 18,43 GET date:var PICTURE '##/##/##'
READ
CLEAR GETS
* test for February, if month is not Feb, and it has
* 'failed' the tests so far the date is OK
CASE mm<>2
*date is OK;invalid = '0' drops out of DO WHILE LOOP
STORE '0' TO invalid
* if month is Feb., check number of days in non-leap year
* does not exceed 28
CASE((yy/4<>INT(yy/4).OR.(yy/100=INT(yy/100).AND.;
yy/400<>INT(yy/400))).AND. dd>28
* invalid date, user is prompted for reentry
STORE '        ' TO date:var
@ 20,00
@ 20,15 SAY 'REMEMBER - FEBRUARY IS A SHORT MONTH! - PLEASE TRY AGAIN'
@ 18,43 GET date:var PICTURE '##/##/##'
READ
CLEAR GETS
* finally, check days in leap year February <30
CASE dd=30
* invalid date; user is prompted for reentry
STORE '        ' TO date:var
@ 20,00
@ 20,15 SAY 'EVEN A LEAP YEAR FEBRUARY ONLY HAS 29 DAYS - PLEASE REENTER'
@ 18,43  GET date:var PICTURE '##/##/##'
READ
CLEAR GETS
OTHERWISE
@ 20,00
STORE '0' TO invalid
ENDCASE
* end of DO WHILE loop if valid = '0' program terminates
* if invalid #'0'loop repeats
ENDDO while invalid
RELEASE nn1,dd1,yy1,dd,yy
SET DATE TO &date:var
ENDDO while date
* set up bell
STORE 'Y' TO command
@ 20,00
@ 19,15 SAY'Do you wish to use signal beep ? ' GET command PICTURE '!'
READ
IF command = 'N'
    SET BELL OFF
ENDIF command = N
* set up drive for data disk
* Thanks to Harry Van Tassell we store the default drive to dr
* However, if you do not keep the data on the default drive we suggest
* you change the code to eliminate the drives you do not have. This
* way you cannot accidentally select a drive
STORE 41984 TO ADDRESS
STORE ' ' TO dr
* find out if you are running under CP/M 80
IF (PEEK(0) = 195 .AND. PEEK(5) = 195)
    *8080 code
    POKE ADDRESS ,35,229,14,25,205,5,0,225,198,65,119,201
ELSE
    *8086 code
    POKE ADDRESS,67,83,177,25,205,224,4,65,91,136,7,195
ENDIF peek
SET CALL TO ADDRESS
CALL dr
RELEASE ADDRESS
@ 20,15 SAY 'In which drive is the DATA disk ? ' GET dr PICTURE '!'
READ
DO WHILE @(dr,'ABCDM') = 0
    @ 20,15 SAY 'In which drive is the DATA disk ? ' GET dr PICTURE '!'
    READ
ENDDO while @dr
* poke drive letter into memory 039 hex
POKE 063,(64+@(dr,'ABCDM'))
RELEASE ALL
DO MENU.SIG
