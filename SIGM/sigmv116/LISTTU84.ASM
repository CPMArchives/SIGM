
; LISTT v1.3  --  File utility program for printers   --  02/22/83
;
; 03/17/83
;
;	LISTT v1.3 has been modified to provide the following capabilities:
;
;	  1) Program some of the OKIDATA Microline printer's 
;	     attributes on selective basis before printing each file.
;
;	  2) Time/Date stamp each page of the printed output using
;	     Electralogics Incorporated's MFIO Reat Time Clock.
;
;	Since I prefer to use 8 1/2 inch paper, I have chosen to set
;	all form width characteristics relative to that preference.
;	These values may be easily changed to suit your own 
;	requirements.
;
;	I have also chosen to set the default specifications for the
;	printer as:- 8 lines per inch vertically and 17 characters
;	per inch horizontally. The headers are set up to locate
;	pertinent data in the same relative locations at the top of
;	the printed page regardless of the print/line characteristics
;	selected.
;
;	One more little thing; I like to leave a left margin of 20
;	spaces at 17 characters per inch, 10 spaces at 12 characters
;	per inch and no spaces at 10 characters per inch. 
;		
;	When the program is executed, the current printer parameters
;	are displayed and you are then asked if you wish to
;	alter the printer parameters (print density, or lines per
;	inch). If you answer in the affirmative, options will be
;	offered. Don't forget to answer "d" (for done) when you have
;	completed your option selection. The answer "n" will result
;	in the selection of the default parameters discussed above.
;
;	If a particular parameter is changed, for example - 6 lines
;	per inch is selected, then the variable "TEXT" is modified
;	to allow more lines of text per page. A similar
;	modification to the code is made if a different print
;	density is selected. The column in which the page number 
;	starts to print is also changed to reflect the new density.
;
;	Changes to Irv Hoff's code have been left in lower case to
;	ease recognition of them.
;
;	The code isn't elegant but it works. My apologies to Irv Hoff
;	for the liberties that I have taken with his efforts. Also my
;	thanks are extended to him for the education that this little
;	effort has given me.
;
;	If you care to leave any comments, or pose any questions,
;	leave a message on Jud's system.
;
;
;				Bill Harnell,
;				Scarborough, Ontario
;
;	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
;
;                        Irvin M. Hoff
;                  Los Altos Hills, CA  94022
;
;      "LISTT" is a printer utility program that lists any re-
;      quested file on your printer.  The name was selected so
;      it would be easy to type, easy to remember, and be illus-
;      trative of its capabilities.  It works equally well on
;      printers that do/do not respond to form feed characters.
;
;      When requesting the program, include the name of the
;      file (and its extent) that is to be listed:
;
;
;                      A>LISTT HELLO.ASM
;
;
;      A menu then appears asking several questions:
;
;         1) Roll paper or fanfold (it adds tear tabs each
;               11" if using roll paper).
;         2) Ability to include 0-99 spaces at the left
;               margin for those printers without adjust-
;               able margins.
;         3) Ignore form feeds (Y/N) - By default accepts normal
;               form feeds.  (Automatically paginates with or
;               without form feeds).
;         4) Heading desired (such as current date, etc.)
;               The name of the file plus current page num-
;               ber near the right margin are both automatic.
;         5) Asks for starting page (defaults to page 1).
;         6) Asks for page to stop at (defaults to end of
;               file).
;
;      Thus you can compensate for various printers and can print
;      any portion of the file you wish.
;
;      NOTE:  There are two options which may be user-set.  They  
;             are locations 0103 and 0104.  They may be set with
;             "DDT", "SID" or by editing and reassembling:
;
;             1)  PAGCOL   --  Sets the column the Page number
;                              starts at.  Some printers have
;                              72 columns, some 80, some 132, etc.
;
;             2)  TTABN    --  Sets the space between tear tabs
;                              for fan fold.  Some printers have
;                              72 columns, some 80, some 132, etc.
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
; 02/02/83 v1.2 Fixed the heading to indent on all pages, instead of
;               only the first. (Has worked correctly if using roll
;               paper with tear tabs, but not on fanfold.)
;                                       - Irv Hoff
;
; 01/17/83 v1.1 Would only display 99 pages and start over. Now goes 
;               to 99 pages.            - Irv Hoff
;
; * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;
;
        ORG   100H           
;
;
        JMP   BEGIN          
;
;
; SPECIAL STORAGE LOCATIONS
;
datcol:	dw	head3		;column to start date/time
PAGCOL: DB      85              ;COLUMN TO START PAGE NUMBER
TTABN:  DB      78              ;SPACE BETWEEN TEAR TABS FOR ROLL PAPER
lspc:	db	08		;6 std - 6 or 8 permitted
chwd:	db	17		;10 std - 10, 12 or 17 permitted
stdflg:	db	00		;standard print parameter flag
;.....
;
; 
; ASCII CONTROL CHARACTERS
;
esc	equ    1bh	     ;escape character
BS      EQU   'H'-40H        ;CONTROL-H FOR BACKSPACE
TAB     EQU   'I'-40H        ;CONTROL-I FOR TAB
LF      EQU   'J'-40H        ;CONTROL-J FOR LINE FEED
FFD     EQU   'L'-40H        ;CONTROL-L FOR FORM FEED
CR      EQU   'M'-40H        ;CONTROL-M FOR CARRIAGE RETURN
SI      EQU   'V'-40H        ;CONTROL-V FOR SYNCH IDLE
EOF     EQU   'Z'-40H        ;CONTROL-Z FOR END OF FILE
;.....
;
;
; CP/M ROUTINES AND FILE MANAGEMENT
;
BDOS    EQU   0005H          ;SYSTEM CALL ENTRY POINT
CONIN   EQU   1              ;CONSOLE INPUT CHAR
CONOUT  EQU   2              ;DISPLAY CHAR ON CONSOLE
FCB     EQU   5CH            ;LOCATION OF FILE CONTROL BLOCK
LIST    EQU   5              ;SEND CHAR. TO LIST DEVICE
pagenm	equ   3	             ;allows up to 999 pages
STATUS  EQU   11             ;CONSOLE STATUS
TBUFF   EQU   80H            ;BUFFER FOR FILE CONTROL BLOCK
TFCB    EQU   005CH          ;DEFAULT FILE CONTROL BLOCK
;.....
;
;
; MISC STORAGE LOCATIONS
;
;
CCP:    DB    0              ;INITIAL 'CCP' PAGE
COLMN:  DB    0              ;POSITION ON THE LINE
FRMFD:  DB    0              ;FORM FEED CONTROL
LCNT:   DB    0              ;LINE COUNT FOR HARD COPY
NOTAB:	DB    0		     ;CHANGES TO '1' IF USING TEAR TABS
START:	DB    0              ;START PRINTING FLAG
text:	db    76             ;number of lines of text per page
				;66 lpp = 54, 88 lpp = 76
;.....
;
;
; FILE HANDLING DATA
;
FILEADR:      DW    BUFFER
FILELEN:      DB    0,0
FILEPTR:      DB    0,0
FILESIZ:      DB    0,0
FCBSTR:       DB    0,0,0,0,0,0,0,0,0,0,0,0
              DB    0,0,0,0,0,0,0,0,0,0,0,0
              DB    0,0,0,0,0,0,0,0,0
;.....
;
;
; HEADING LINE FOR HARD COPY
;
HEAD1:  DB    SI,SI,SI,SI,SI,SI,SI,SI,SI,SI,SI,SI,'  '
HEAD2:  DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB    0,0,0,0,0,0,0,0,0,0,0,0,0
HEAD3:  DB    '                        - Page '
HEAD4:  DB    SI,SI,'1',CR,LF,LF,LF,0
PAGES:  DB    SI,SI,'1   '
PAGEQ:  DB    SI,SI,'    '
QUIT:   DB    CR,LF,LF,LF,LF,LF,LF,LF,LF,LF,0
QUITR:  DB    CR,LF,LF,LF,LF,LF,0
TURNUP:	DB    CR,LF,LF,LF,LF,LF,LF,LF,LF,LF,CR,LF,0
;
;.....
;
;
; MESSAGES
;
MERRN:  DB    '== No file by that name on this disk =='
        DB    CR,LF,'$'
MERRR:  DB    '== No file requested ==',CR,LF,LF,'$'
MERRW:  DB    '== No "*" or "?" please ==',CR,LF,'$'
;
MSG1:   DB    CR,LF,'        LISTT Pgm v1.3  02/22/83',CR,LF
	DB    '(With Okidata Microline u84 Enhancements)',cr,lf,lf,0
MSG1B:  DB    cr,lf,'Do you want tear tabs to use roll paper? (y/n):  ',0
MSG1C:  DB    'Number of spaces to augment left margin (0-99):  ',0
MSG1D:  DB    'Accept FF (y/n):  ',0
MSG1E:  DB    'Heading is:  ',0
MSG1F:  DB    'Start at page  :  ',0
MSG1G:  DB    'Quit  at page  :  ',0
MSG2:   DB    'HIGHEST PAGE IS:  ',0
MSG3:   DB     CR,LF,0
;
;.....
;
msgpc:	db	cr,lf,lf,lf
	db	'Following are Microline 84 printer options',cr,lf
	db	'(Parenthetical notes show current values)',cr,lf,lf,0
msgpc1:	db	' 1. Line Spacing               (  )',cr,lf
	db	'	(6 or 8 lpi permitted)',cr,lf,0
msgpc2:	db	' 2. Print Density              (  )',cr,lf
	db	'	(10, 12 or 17 cpi permitted)',cr,lf,0
msgpc5:	db	cr,lf,'Changes Desired (y, n or (d)one) ==> ',0
msgpc6:	db	cr,lf,lf,'Enter 1 or 2                  ==> ',0
;
lsmsg:	db	cr,lf,'Enter Lines Per Inch (6 or 8) ==> ',0
lsmsg6:	db	esc,'6',cr,0		;6 lpi
lsmsg8:	db	esc,'8',cr,0		;8 lpi
tofmsg:	db	esc,'5',cr,0		;top of form message
;
cwmsg:	db	cr,lf,'Enter Print Density (10, 12 or 17 cpi)'
	db	cr,lf,'1 = 10, 2 = 12 or 3 = 17 cpi  ==> ',0
cwmsg10:db	30,cr,0			;10 cpi
cwmsg12:db	29,cr,0			;12 cpi
cwmsg17:db	28,cr,0			;17 cpi
;
;
;.....
;
;
; TO GIVE THE FINAL LISTING A LEFT-MARGIN SO THAT IT CAN BE  MORE EASILY
; USED IN A BINDER, EXTRA SPACES CAN BE INSERTED AUTOMATICALLY INTO THE
; LEFT MARGIN AREA WHEN ANSWERING THE QUESTION AT BOOT TIME.  (NONE ARE
; NEEDED IF YOUR PRINTER HAS ADJUSTABLE MARGINS.)
;
FILLS:  DB    '    '         ;TELLS HOW FAR TO MOVE THE MARGIN
;
MARGIN: DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        DB    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;
;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;                                                                      ;
;                                                                      ;
;                    PROGRAM STARTS HERE                               ;
;                                                                      ;
;                                                                      ;
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;
;
BEGIN:	POP   H              ;GET RETURN ADDRESS TO'CCP'
	SHLD  EXIT+1         ;STORE FOR RETURN TO 'CCP'
        LXI   SP,STACK       ;SETUP NEW STACK FOR THIS PGM
;
;
; SIGN-ON MESSAGE
;
        LXI   H,MSG1
        CALL  STRNGC         ;WRITE STRING TO CRT  
;
;*****************************
;
; MOVE PGM NAME INTO HEADING BUFFER
;
;*****************************
;
; SEE IF ANY FILE WAS REQUESTED
;
TITL:   LXI   H,TBUFF        ;FILE CONTROL BLOCK BUFFER
        MOV   A,M            ;GET FIRST CHARACTER
        ORA   A
        JZ    ERRORR         ;IF ZERO, NO FILE WAS REQUESTED
			     ;check for printer parm. change
;
; IF YES, SEE IF A DRIVE WAS MENTIONED, DO NOT PRINT THAT
;
        LXI   H,TBUFF+3      ;SEE IF THEY SPECIFIED A DRIVE
        MOV   A,M
        CPI   ':'
        JZ    TITL1+1        ;IF YES IGNORE
        LXI   H,TBUFF        ;IF NOT, RESET TO NORMAL
;       
TITL1:  INX   H              ;IGNORE THE SPACE CHAR.
        LXI   D,HEAD1        ;LOCATION OF HEADING BUFFER
;.....
;
; see if printer parameter changes necessary
;
	push psw!push b!push d!push h
	call	shpcol
	pop h!pop d!pop b!pop psw
;.....
;
; MOVE THE FILE NAME AND HEADING/DATE INTO THE BUFFER
;
TITL2:  INX   H              ;NEXT LOCATION
        MOV   A,M            ;GET THE CHARACTER
        ORA   A              ;BINARY ZERO?
        JZ    TITL3          ;IF YES, FINISHED
        CPI   ' '            ;A SPACE AFTER FILENAME?
        JZ    TITL3          ;IF YES, ALL FINISHED
        STAX  D              ;AND STORE IN BUFFER
        INX   D              ;ADVANCE BUFFER LOCATION
        JMP   TITL2          ;IF NOT, CONTINUE
;
;
; CHECK FOR ANY WILD CARD CHARACTERS AND IF PRESENT SHOW ERROR
;
TITL3:  LXI   H,FCB          ;WHERE NAME IS
        MVI   B,11           ;NUMBER OF CHARS POSSIBLE
;
TITL4:  INX   H              ;NEXT LOCATION IN FILE NAME
        MOV   A,M            ;GET CHARACTER
        CPI   '?'            ;CHECK FOR ANY WILD CARD CHARS.
        JZ    ERRORW         ;ERROR IF ONE IS FOUND
        DCR   B              ;COUNT CHARACTERS TO TEST
        JNZ   TITL4          ;LOOP BACK UNLESS DONE
;
;
;*****************************
;
; CALCULATE MAXIMUM AVAILABLE BUFFER SIZE
;
;*****************************
;
;
        LXI   D,BUFFER
        LDA   BDOS+2         ;GET BDOS ADDRESS
        SUI   8              ;PROTECT 'CCP'
        MOV   H,A            ;GET THE MAIN PAGE
        STA   CCP            ;STORE FOR "CLEAR BUFFER"
        XRA   A              ;CLEAR CARRY IF SET
;
;
; CALCULATE THE DIFFERENCE TO GET SPACE AVAILABLE
;
        SUB   E
        MOV   L,A
;
        MOV   A,H
        SBB   D
        MOV   H,A
;
;
; FREE SPACE AVAILABLE NOW IN 'HL', SO STORE FOR BUFFER SIZE
;
        SHLD  FILESIZ
;
;*****************************
;
; OPEN REQUESTED FILE TO READ THE DATA TO LIST
;
;*****************************
;
        LXI   H,FCB          ;LOCATION OF FILE CONTROL BLOCK
        LXI   D,FCBSTR
        MVI   C,12           ;NORMAL FILE LENGTH
        CALL  STORE
;
        XRA   A
        STA   FCBSTR+12      ;NULL LOCATION FOLLOWING FILE NAME
        STA   FCBSTR+32
        LHLD  FILESIZ
        SHLD  FILELEN
        SHLD  FILEPTR
        MVI   C,15
        LXI   D,FCBSTR       ;OPEN FILE
        CALL  BDOS
        INR   A
        JZ    ERRORN         ;IF UNABLE, TERMINATE
;
;
;*****************************
;
; ASK ABOUT ROLL PAPER, MARGINS, STARTING PAGE, ETC.
;
;*****************************
;
;
        CALL  PRHC           ;ASK QUESTIONS
;
;
;***********************************************************************
;                                                                      ;
;                     MAIN PRINT LOOP                                  ;
;                                                                      ;
;***********************************************************************
;
;
; HANDLES TOP OF NEW PAGE
;
MAIN:   call  time           ;set time/date etc. into header
	CALL  NEWPG          ;SET PARAMETERS FOR A NEW PAGE
        CALL  SKIP           ;SKIP CR, LF, EOF OR FFD AT NEW PAGE
        JMP   MAIN2          ;ALREADY HAVE FIRST GOOD CHAR.
;
;
; HANDLE ASCII CHARACTERS
;
MAIN1:  CALL  GETCH          ;GET NEW CHARACTER
        CPI   EOF            ;END OF FILE IN MIDDLE OF LINE?
        JZ    ROLL
;
MAIN2:  CPI   ' '            ;PRINTING CHAR.?
        JC    MAIN4          ;IF NOT, EXIT
;
MAIN3:  CALL  WRITE2         ;WRITE CHARACTER
        JMP   MAIN1          ;GET THE NEXT CHAR.
;...
;
;
; HANDLE NON-PRINTING CHARS.
;
MAIN4:  CPI   CR             ;CARRIAGE RETURN
        JZ    MAIN5
        CPI   FFD            ;FORM FEED
        JZ    MAIN6
        CPI   LF             ;LINE FEED
        JZ    MAIN7
        CPI   TAB            ;TAB CHARACTER
        JZ    MAIN8
        JMP   MAIN9          ;NONE OF THESE SEND SPECIAL CHAR.
;.....
;
;
; HANDLE 'CR' CHAR.
;
MAIN5:  CALL  ABORT          ;WANT TO TERMINATE?
        MVI   A,CR           ;RESTORE THE CHAR.
        JMP   MAIN3          ;GET NEXT CHAR.
;...
;
;
; HANDLE FORM FEED CHAR.
;
MAIN6:  CALL  ABORT          ;WANT TO TERMINATE?
        LDA   FRMFD          ;RESPONDING TO FORM FEED?
        ORA   A
        JNZ   MAIN1          ;IF NOT, IGNORE
;
        LDA   LCNT           ;INCREMENT LINE COUNT
        INR   A
        STA   LCNT
        push  h
	lxi   h,text
	cmp   m
	pop   h
        JNC   MAIN71         ;IF DONE, TURN UP NEW PAGE
        MVI   A,LF
        CALL  WRITEP         ;PRINT NEW LINE, DO NOT DISPLAY
        JMP   MAIN6          ;CHECK AGAIN
;...
;
;
; HANDLE 'LF' CHARS.
;
MAIN7:  LDA   LCNT           ;INCREMENT THE TEXT LINE COUNT
        INR   A
        STA   LCNT
        push  h
	lxi   h,text
	cmp   m
	pop   h	             ;MAXIMUM NUMBER OF LINES NOW?
        JNC   MAIN71         ;IF YES, FINISH THE PAGE
	MVI   A,LF
        CALL  WRITE3
        CALL  INDENT         ;INDENT IF REQUESTED
        JMP   MAIN1          ;HANDLE NORMALLY
;...
;
;
;    'LF' SO START A NEW PAGE
;
MAIN71: CALL  ABORT          ;WANT TO TERMINATE NOW?
        CALL  SKIP           ;SKIP ANY CR, LF, EOF OR FFD TOP OF PAGE
        PUSH  PSW            ;OTHERWISE SAVE CHAR.
        CALL  TTABS          ;CHECK FOR ROLL PAPER
        CALL  NMBR           ;INCREMENT THE PAGE NUMBER
        CALL  CKSP           ;READY TO STOP AS YET?
        CALL  INDENT
;
MAIN72:	LXI   H,HEAD1        ;SEND THE NEW PAGE HEADING
        CALL  STRNGB         ;DISPLAY AND PRINT
        CALL  PAGNO          ;SET IN PAGE NUMBER
	CALL  NEWPG          ;SET UP PARAMETERS FOR A NEW PAGE
	POP   PSW            ;GET THE CHAR. BACK WE LOOKED AT
        JMP   MAIN2          ;IGNORE GETTING A NEW CHAR.
;...
;
;
; HANDLE TAB CHARACTERS
;
MAIN8:  MVI   A,' '          ;SEND A SPACE IN PLACE OF TAB
        CALL  WRITE2         ;DISPLAY AND PRINT
        LDA   COLMN          ;FIND WHAT COLUMN
        ANI   7
        JNZ   MAIN8          ;IF NOT EVEN 8, DO ANOTHER SPACE
        JMP   MAIN1          ;BACK TO WORK
;...
;
;
; DISPLAY CONTROL-CHARACTERS
;
MAIN9:  PUSH  PSW            ;SAVE THE CHAR.
        MVI   A,'^'          ;SHOW A SPECIAL "CTL-CHAR."
        CALL  WRITE2         ;DISPLAY/PRINT
        POP   PSW
        ADI   40H            ;CONVERT TO PRINTING CHAR.
        CALL  WRITE2
        JMP   MAIN           ;GET NEXT CHAR.
;.....
;
;
;***********************************************************************
;                                                                      ;
;                                                                      ;
;                    ROUTINES START HERE                               ;
;                                                                      ;
;                                                                      ;
;***********************************************************************
;
;
; CLEAR KEYBOARD OF ANY OTHER CHARS.
;
ABORT:  MVI   C,STATUS
        CALL  BDOS
        RAR	
        RNC
;
        MVI   C,CONIN        ;GET THE CHAR.
        CALL  BDOS
        CPI   'C'-40H        ;WANT TO TERMINATE?
        JNZ   ABORT          ;EXIT IF NOT CTL-C
;
ABORT1: LDA   NOTAB          ;USING FANFOLD PAPER?
	ORA   A
	JZ    EXIT           ;IF YES, LEAVE IN NORMAL POSITION
	LXI   H,TURNUP       ;OTHERWISE, TERMINATE
        CALL  STRNGP         ;DISPLAY AND PRINT SOME LINE FEEDS
	LXI   H,QUITR-7      ;..A FEW EXTRA LINES
	CALL  STRNGP
	JMP   EXIT
;
ABORT2: LXI   H,QUITR-3
        CALL  STRNGC
        JMP   EXIT           ;FINISHED NOW
;.....
;
;
; HANDLE A BACKSPACE CHAR. WHILE ENTERING A FILE NAME
;
BCKSP:  MOV   A,B            ;GET POSITION ON LINE
        ORA   A
        JNZ   BCKSP1         ;EXIT IF AT INITIAL COLUMN
        MVI   A,' '          ;DELETE THE CHAR.
        JMP   BCKSP3
;
BCKSP1: DCR   B              ;SHOW ONE LESS COLUMN USED
        DCX   H              ;DECREASE BUFFER LOCATION
        MVI   A,' '
        MOV   M,A            ;REPLACE TO ORIGINAL
        CALL  WRITCC         ;BACKSPACE THE CRT
;
BCKSP2: MVI   A,BS           ;RESET THE CRT AGAIN
;
BCKSP3: CALL  WRITCC         ;WRITE TO CRT
        RET
;.....
;
;
; CHECK TO SEE IF READY TO STOP PRINTING YET
;
CKSP:   PUSH  H              ;SAVE THE REGS.
        PUSH  D
        PUSH  B
        LXI   H,PAGEQ+2      ;ADDRESS OF QUITTING PAGE ANSWER
;
CKSP1:  INX   H              ;FIND THE RIGHTMOST DIGIT
        MOV   A,M
        CPI   ' '
        JNZ   CKSP1
        DCX   H
;
        LXI   D,HEAD4+2      ;RIGHTMOST DIGIT FOR PAGE NUMBER
        MVI   C,PAGENM	     ;ALLOWS UP TO 9,999 PAGES
;
CKSP2:  LDAX  D              ;COMPARE TWO STRINGS OF NUMBERS
        CMP   M
        JNZ   CKSP3          ;IF DIFFERENT, NOT READY YET
;
        DCX   D              ;CHECK NEXT DIGIT
        DCX   H
        DCR   C
        JNZ   CKSP2
;
        JMP   ABORT1
;
CKSP3:  POP   B              ;RESTORE THE REGS.
        POP   D
        POP   H
        RET
;.....
;
;
; CHECK TO SEE IF READY TO START PRINTING YET
;
CKST:   PUSH  H              ;SAVE THE REGS.
        PUSH  D
        PUSH  B
        LXI   H,PAGES+2      ;ADDRESS OF STARTING PAGE ANSWER
;
CKST1:  INX   H              ;FIND THE RIGHTMOST DIGIT
        MOV   A,M
        CPI   ' '
        JNZ   CKST1
        DCX   H
;
        LXI   D,HEAD4+2      ;RIGHTMOST DIGIT FOR PAGE NUMBER
        MVI   C,PAGENM
;
CKST2:  LDAX  D              ;COMPARE TWO STRINGS OF NUMBERS
        CMP   M
        JNZ   CKST4          ;IF DIFFERENT, NOT READY YET
;
        DCX   D              ;CHECK NEXT DIGIT
        DCX   H
        DCR   C
        JNZ   CKST2
;
        STA   START          ;ALLOWS HARD COPY TO COMMENCE
        MVI   A,CR
        CALL  WRITEP         ;POSITION PRINTER TO LEFT FOR FIRST LINE
	LDA   NOTAB	     ;USING TEAR TABS?
	ORA   A
	CNZ   TTABS	     ;IF YES, START FIRST PAGE WITH TEAR TABS
        CALL  INDENT         ;INDENT IF REQUESTED
;
CKST3:  LXI   H,HEAD1
        CALL  STRNGB
        CALL  PAGNO          ;SET IN PAGE NUMBER
;
CKST4:  POP   B              ;RESTORE THE REGS.
        POP   D
        POP   H
        RET
;.....
;
;
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;                                                                     ;
;              LOAD THE DISK FILE INTO MEMORY, GET A CHAR             ;
;                                                                     ;
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;
;
; SEE IF ANYTHING ALREADY IN THE BUFFER
;
DISK1:  LHLD  FILELEN
        XCHG
        LHLD  FILEPTR
        MOV   A,L
        SUB   E
        MOV   A,H
        SBB   D
        JC    DISK5          ;IF NOT EMPTY GO GET CHAR.
;
;
; IF EMPTY, FILL BUFFER
;
        LXI   H,0
        SHLD  FILEPTR        ;ZERO THE FILE POINTERS
;
;
; GET NEXT DISK SECTOR, CHECK FOR END OF FILE MARKER
;
DISK2:  XCHG                 ;PUT INTO 'DE'
        LHLD  FILELEN        ;SET 'HL' TO MAXIMUM BUFFER LENGTH
        MOV   A,E
        SUB   L
        MOV   A,D
        SBB   H
        JNC   DISK4          ;IF NOW FULL, EXIT
;
;
; OTHERWISE GET NEXT SECTOR
;	
        LHLD  FILEADR        ;START OF BUFFER
        DAD   D              ;ADD IN FILE POINTER VALUE
        XCHG                 ;ADDRESS FOR NEXT DISK SECTOR TO GO
        MVI   C,26           ;SET DMA ADDRESS
        CALL  BDOS
        LXI   D,FCBSTR       ;ADDRESS OF DISK FILE NAME
        MVI   C,20           ;READ SEQUENTIAL INTO MEMORY BUFFER
        CALL  BDOS
        ORA   A              ;CHECK FOR END OF FILE
        JNZ   DISK3          ;IF YES, EXIT
;
        LXI   D,TBUFF        ;SECTOR SIZE IS 128 BYTES
        LHLD  FILEPTR        ;NEXT LOCATION TO PUT SECTOR        
        DAD   D              ;ADD THE SECTOR SIZE
        SHLD  FILEPTR        ;STORE FOR NEXT SECTOR-FILL
        JMP   DISK2          ;CHECK FOR FULL, IF NOT KEEP GOING
;.....
;
; RESET FOR END-OF-FILE MARKER LOCATION
;
DISK3:  LHLD  FILEPTR
        SHLD  FILELEN
;
; SET FOR BUFFER FULL
;
DISK4:  LXI   D,TBUFF        ;POINT TO TEMPORARY BUFFER ADDRESS
        MVI   C,26           ;SET DMA ADDRESS
        CALL  BDOS
        LXI   H,0            ;RESET FILE POINTER TO START OF BUFFER
        SHLD  FILEPTR
;
;
; GET THE NEXT CHARACTER FROM THE BUFFER
;
DISK5:  XCHG                 ;FILE POINTER LOCATION
        LHLD  FILEADR        ;START OF MEMORY BUFFER
        DAD   D              ;ADDRESS OF NEXT CHARACTER TO GET
        XCHG                 ;PUT INTO 'DE'
        LHLD  FILELEN        ;GET LENGTH OF FILE
        MOV   A,L            ;SEE IF EMPTY NOW
        ORA   H
        MVI   A,EOF          ;END OF FILE MARKER (CTL-Z)
        RZ                   ;DONE IF 'H' AND 'L' BOTH ZERO
;
        LDAX  D              ;GET THE CHAR.
        LHLD  FILEPTR        ;BUMP THE POINTERS FOR NEXT CHARACTER
        INX   H
        SHLD  FILEPTR
        RET
;.....
;
;
; EXIT IF HAVING A PROBLEM OPENING A FILE
;
ERROR:  MVI   C,9            ;PRINT STRING
        CALL  BDOS
	JMP   EXIT
;
ERRORR: LXI   D,MERRR        ;NO FILE REQUESTED - ERROR MSG
        JMP   ERROR
;
ERRORN: LXI   D,MERRN        ;NO FILE BY THAT NAME - ERROR MSG
        JMP   ERROR
;
ERRORW: LXI   D,MERRW        ;NO WILDCARD - ERROR MSG
        JMP   ERROR
;.....
;
;
;EXIT ROUTINE
;
EXIT:	JMP   0000H          ;FILLED IN BY 'BEGIN' FOR RETURN TO 'CCP'
;.....
;
;
; GET A CHARACTER FROM THE BUFFER
;
GETCH:  CALL  DISK1          ;PICK OFF THE CHAR.
        ANI   7FH            ;STRIP OFF ANY PARITY
        RET
;.....
;
;
; INDENT FOR NEW LEFT MARGIN, IF REQUESTED
;
INDENT: PUSH  PSW            ;SAVE THE CHAR.
        LXI   H,MARGIN
        CALL  STRNGP         ;WRITE THE STRING
        XRA   A
        STA   COLMN          ;RESET THE COLUMN COUNT
        POP   PSW            ;RESTORE THE CHAR.
        RET
;.....
;
;
; GET A CHARACTER FROM THE KEYBOARD
;
INPUT:  PUSH  H
        PUSH  B
        MVI   C,CONIN
        CALL  BDOS
        ANI   7FH            ;STRIP OFF ANY PARITY
        POP   B
        POP   H
        CPI   3              ;CONTROL-C ?
        JZ    ABORT2         ;IF YES, GO TERMINATE
        RET
;.....
;
;
; SET PARAMETERS FOR A NEW PAGE
;
NEWPG:  XRA   A
        STA   LCNT           ;RESET THE TEXT COUNT
        STA   COLMN          ;RESET THE COLUMN COUNT
        LDA   START          ;ALREADY PRINTING?
        ORA   A
        CZ    CKST           ;IF NOT CHECK WHETHER READY NOW
        JMP   INDENT         ;SET IN ANY LEFT MARGIN SPACES
;.....
;
;
; INCREMENT THE PAGE NUMBER FOR HARD COPY
;
NMBR:   LXI   H,HEAD4+2
        MVI   C,PAGENM
;       
NMBR1:  MOV   A,M            ;GET THE VALUE
        CPI   ' '            ;IS IT A SPACE?
        JZ    NMBR2          ;EXIT IF NOT
        CPI   SI             ;SYNCH CHAR.?
        JNZ   NMBR3
;
NMBR2:  MVI   A,'0'          ;OTHERWISE CALL IT A ZERO
;
NMBR3:  INR   A
        MOV   M,A
        CPI   '9'+1          ;READY TO START NEXT DIGIT?
        JNZ   NMBR4          ;IF NOT, FINISHED
;
        MVI   M,'0'          ;OTHERWISE MAKE THIS ONE A ZERO
        DCX   H              ;WORK ON NEXT COLUMN
        DCR   C              ;ONE LESS TO GO
        JNZ   NMBR1          ;GO DO THE NEXT ONE
;
NMBR4:  RET                  ;FINISHED
;.....
;
;
; IF NO PRINT, TELL WHAT MAXIMUM PAGE WAS
;
NOPNT:  LXI   H,MSG3         ;TURN UP A BLANK LINE
        CALL  STRNGC
        LXI   H,MSG2         ;FINAL PAGE MSG
        CALL  STRNGC
        LXI   H,HEAD4
        CALL  STRNGC
        JMP   EXIT           ;ALL DONE NOW
;.....
;
; TO START A NEW PAGE
;
NUPAGE:	LXI   H,TURNUP	     ;SEND A STRING OF LINE FEEDS TO
	JMP   STRNGB	     ;..START A NEW PAGE
;.....
;
;
; DISPLAY AND PRINT THE PAGE NUMBER
;
PAGNO: 	MVI   A,' '          ;SPACE CHARACTER
        CALL  WRITE2         ;DISPLAY AND PRINT AND COUNT
        LDA   PAGCOL         ;FIND COLUMN TO START PAGE NUMBER
        MOV   B,A
        LDA   COLMN          ;GET PRESENT COLUMN
        ADI   1              ;COMPENSATE FOR LEFT MARGIN "0" COUNT
        SUB   B              ;SEE IF ROOM LEFT FOR SPACES
        JC    PAGNO          ;IF YES SEND ANOTHER SPACE
;
        LXI   H,HEAD3        ;PAGE NUMBER STRING
        JMP   STRNGB         ;DISPLAY AND PRINT, FINISHED
;
;.....
;
;
; ASKS VARIOUS QUESTIONS SUCH AS HEADING, PAGE NUMBERS, ETC.
;
;    TABS FOR ROLL PAPER REQUEST
;
PRHC:   CALL  RPAPER         ;USING ROLL PAPER?
;
;.....
;
;    ASK FOR ANY FILL CHARS. TO AUGMENT LEFT MARGIN
;
        LXI   H,MSG1C        ;WANT FILL CHARS.?
        CALL  STRNGC
        MVI   B,0
        LXI   H,FILLS+1      ;STORAGE FOR NUMBER OF FILL CHARS.
;
PRHC1:  CALL  INPUT          ;GET KEYBOARD ANSWER
        CPI   CR             ;CARRIAGE RETURN TO QUIT?
        JZ    PRHC4
        CPI   BS             ;BACKSPACE CHAR.?
        JNZ   PRHC2
        CALL  BCKSP          ;BACKSPACE
        JMP   PRHC1
;
PRHC2:  CPI   ' '
        JC    PRHC1          ;IF NON-PRINTING, IGNORE
        MOV   M,A            ;STORE CHARACTER
        INX   H              ;NEXT STORAGE LOCATION
        INR   B              ;INCREMENT COUNT
        CPI   '0'
        JC    PRHC3          ;DIGITS FROM 0-9 ACCEPTABLE
        CPI   '9'+1
        JNC   PRHC3          ;DIGITS FROM 0-9 ACCEPTABLE
        MOV   A,B
        CPI   2+1            ;TWO MAXIMUM DIGITS FOR 0-99
        JC    PRHC1
;
PRHC3:  CALL  BCKSP2         ;WON'T ALLOW THREE DIGITS
        CALL  BCKSP1         ;   (OR NON-NUMERIC CHARS.)
        JMP   PRHC1          ;GET NEXT CHAR.
;...
;
;
; NOW PUT THE NUMBER OF "INDENT SPACES" INTO THE "MARGIN" BUFFER
;
PRHC4:  LXI   D,MARGIN       ;LOCATION OF THE "INDENT SPACES"
        LXI   H,FILLS+2      ;SEE IF 2 DIGITS THIS TIME
        MOV   A,M
        CPI   ' '
        JNZ   UNITS          ;IF NOT, HANDLE AS A UNIT-DIGIT
        DCX   H
        MOV   A,M
        CPI   ' '            ;THIS ONE HAVE ANYTHING?
        JZ    PRHC5          ;IF NOT, NO FILLS WANTED
;
UNITS:  SUI   '0'            ;CONVERT TO BINARY
        JZ    TENS           ;IF ALREADY ZERO, EXIT
        MOV   B,A            ;STORE
        MVI   A,' '
;
UNITS1: STAX  D              ;STORE A SPACE
        INX   D
        DCR   B
        JNZ   UNITS1
;
TENS:   DCX   H
        MOV   A,M
        CPI   '1'            ;A NUMBER FROM 1-9?
        JC    PRHC5          ;IF NOT, ALL DONE
        SUI   '0'            ;IF YES, CONVERT TO BINARY
        MOV   B,A            ;STORE
;
TENS1:  MVI   C,10           ;10 SPACES FOR EACH "TENS" NUMBER
        MVI   A,' '
;
TENS2:  STAX  D              ;STORE A SPACE
        INX   D              ;NEXT LOCATION
        DCR   C
        JNZ   TENS2
        DCR   B
        JNZ   TENS1          ;RELOAD 'C' TO 10 IF NEEDED
;......
;
;
;    WANT NORMAL FORM FEED?
;       
PRHC5:  LXI   H,MSG3         ;TURN UP A NEW LINE
        CALL  STRNGC
        LXI   H,MSG1D        ;FORM FEED MSG
        CALL  STRNGC
;
        CALL  INPUT          ;GET KEYBOARD CHAR.
        ANI   5FH            ;CHANGE TO UPPER CASE IF NEEDED
        CPI   'Y'            ;FINISHED IF 'RET'
        JNZ   PRHC6
        STA   FRMFD
;...
;
;
;    ASK FOR CURRENT HEADING/DATE
;
PRHC6:  LXI   H,MSG3	     ;TURN UP A NEW LINE
	CALL  STRNGC
	LXI   H,MSG1E	     ;HEADING/DATE MESSAGE
	CALL  STRNGC
        MVI   B,0
        LXI   H,HEAD2
;
PRHC7:  CALL  INPUT          ;GET KEYBOARD CHAR.
        CPI   CR             ;FINISHED IF 'RET'
        JZ    PRHC9
        CPI   BS
        JNZ   PRHC8
        CALL  BCKSP
        JMP   PRHC7
;
PRHC8:  MOV   M,A
        INX   H
        INR   B
        MOV   A,B
        CPI   124+1          ;ROOM FOR 124 CHARS. IN BUFFER
        JC    PRHC7
        CALL  BCKSP2
        CALL  BCKSP1         ;DO NOT ALLOW A TOO-LONG LINE
        JMP   PRHC7
;
;
;    ASK FOR STARTING PAGE
;
PRHC9:  LXI   H,MSG3         ;TURN UP A NEW LINE
        CALL  STRNGC
        LXI   H,MSG1F
        CALL  STRNGC
        MVI   B,0
        LXI   H,PAGES+2      ;STARTING PAGE STORAGE
;
PRHC10: CALL  INPUT
        CPI   CR
        JZ    PRHC12
        CPI   BS
        JNZ   PRHC11
        CALL  BCKSP
        JMP   PRHC10
;
PRHC11: MOV   M,A
        INX   H
        INR   B
        MOV   A,B
        CPI   3+1            ;THREE MAXIMUM PAGE NUMBERS
        JC    PRHC10
        CALL  BCKSP2
        CALL  BCKSP1         ;DO NOT ALLOW A TOO-LONG LINE
        JMP   PRHC10
;
;
;    ASK FOR STOPPING PAGE
;
PRHC12: LXI   H,MSG3         ;TURN UP A NEW LINE
        CALL  STRNGC
        LXI   H,MSG1G
        CALL  STRNGC
        MVI   B,0
        LXI   H,PAGEQ+2      ;QUITTING PAGE STORAGE
;
PRHC13: CALL  INPUT
        CPI   CR
        JZ    PRHC15
        CPI   BS
        JNZ   PRHC14
        CALL  BCKSP
        JMP   PRHC13
;
PRHC14: MOV   M,A
        INX   H
        INR   B
        MOV   A,B
        CPI   3+1            ;THREE MAXIMUM PAGE NUMBERS
        JC    PRHC13
        CALL  BCKSP2
        CALL  BCKSP1         ;DO NOT ALLOW A TOO-LONG LINE
        JMP   PRHC13
;       
PRHC15: LXI   H,MSG3         ;TURN UP A NEW LINE
        CALL  STRNGC
        RET
;.....
;
; show form & printer parameters - changes necessary ?
;
shpcol:	lxi	h,msgpc		;point to message
	call	strngc		; and display it
;
	lda	lspc		;get spacing data
	mov	e,a		; and store in E
	lxi	h,msgpc1+32	;point to destination
	call	biasc		; convert and fill
	lxi	h,msgpc1	;  point to spacing message
	call	strngc		; and show it
;
	lda	chwd		;get print density
	mov	e,a		; and save in E
	lxi	h,msgpc2+32	;point to destination
	call	biasc		; convert and fill
	lxi	h,msgpc2	;  point to density message
	call	strngc		; and show it
;
askch:	lxi	h,msgpc5	;changes necessary?
	call	strngc		; print it
	call	input		;  and get answer
	ani	5fh		;   make ucase
	cpi	'Y'
	jz	chang		;changes needed 
	cpi	'N'		; no changes, bail out
	jz	stdcfg		;  and set standard printer parms
	cpi	'D'		;changes done?
	rz			; yes, bail out!
	jmp	askch		;wait for valid input
;
stdcfg:	mvi	a,1		;get a "1"
	sta	stdflg		; and set the flag
	call	lspac8		;set 6 lines/in.
	call	cwid17		; and 10 cpi
	call	tof		;  and top-of-form
	xra	a		;   then
	sta	stdflg		;  clear the flag
	ret
;
mdone:	call	stroki		;send a string to the oki
	lda	stdflg
	ora	a		; see if zero
	jz	shpcol		;  if yes, then maybe done
	call	tof		;if not, set top-of-form
	ret			; and bail out
;
; set the top-of-form on the okidata u84
;
tof:	lxi	h,tofmsg	;point to the tof message
	call	stroki		; and tell the printer
	ret
;
chang:	lxi	h,msgpc6	;ask for changes
	call	strngc
	call	input		; get change number
	cpi	'1'		;line spacing change
	jz	lspac
	cpi	'2'		;chars. per inch
	jz	cwid
	jmp	chang		;wait for valid input
;
;.....
;
; Set up line spacing parameter for Microline 84
;
lspac:	lxi	h,lsmsg		;ask for lpi
	call	strngc
	call	input		;get answer
	cpi	'6'
	jz	lspac6		;set 6 lpi
	cpi	'8'
	jz	lspac8		;set 8 lpi
	jmp	lspac		;wait for good value
;
lspac6:	mvi	a,6		;get a 6
	sta	lspc		; store new variable
	mvi	a,54		;lines of text/page
	sta	text		; for 6lpi
	lxi	h,lsmsg6	;point to message string
	jmp	mdone		; and send to printer
;
lspac8:	mvi	a,8		;get an 8
	sta	lspc		; store new variable
	mvi	a,76		;lines of text/page
	sta	text		; for 8 lpi
	lxi	h,lsmsg8	;point to message string
	jmp	mdone		; and send to printer
;
;.....
;
; set up print density (chars/inch) for Microline 84
;
cwid:	lxi	h,cwmsg		;ask for cwid
	call	strngc
	call	input		;get value
	cpi	'1'
	jz	cwid10
	cpi	'2'
	jz	cwid12
	cpi	'3'
	jz	cwid17
	jmp	cwid
;
cwid10:	mvi	a,50		;pg# loc. for 10 cpi
	sta	pagcol		; store it
	mvi	a,10
	sta	chwd
	lxi	h,cwmsg10	;point to message string
	jmp	mdone		;  and sent to printer
;
cwid12:	mvi	a,56		;pg# loc. for 12 cpi
	sta	pagcol		; and store it
	mvi	a,12
	sta	chwd
	lxi	h,cwmsg12	;point to message string
	jmp	mdone		;  and send to printer
;
cwid17:	mvi	a,85		;pg# loc. for 17 cpi
	sta	pagcol		; and store it
	mvi	a,17
	sta	chwd
	lxi	h,cwmsg17	;point to message string
	jmp	mdone		;  and send to printer
;
;.....
;
; binary to ascii conversion routine accepts binary
; data in register E with HL pointing to the destination
; of the 2 ascii bytes.
;
biasc:	push psw! push b	;save registers
	lxi	b,0		; and clear BC
	mov	a,e		;recall data byte
	mvi	c,10		;  value to subtract
bitod:	sub	c		;sub 10 from bin value
	inr	b		; and tell tens accumulator
	jnc	bitod		;  continue till A exhausted
	add	c		;   too much, add once to C
	dcr	b		;    and reduce count in B
	adi	'0'		;now, make units value ascii
	mov	c,a		; and store it in C
	mov	a,b		;get the tens data
	adi	'0'		; and make it ascii
	mov	m,a		;  store it in table area
	inx	h		;increment table pointer
	mov	m,c		;get the units data to table area
	pop b! pop psw
	ret
;
;.....
;
; Electralogics Real Time Clock Routines
;
;
BLK	EQU 40H
BLKSEL	EQU 48H
;
;
TIME:	JMP RDCLK
;
TEXIT:	RET
;.....
;
; CONVERT CHAR IN A TO HEX AND DISPLAY
; ------------------------------------
DYHEX:	PUSH PSW ! RAR ! RAR ! RAR ! RAR
	CALL DYNIB ! POP PSW
DYNIB:	ANI 0FH ! ADI 30H ! CPI 3AH ! JC DY
	ADI 7
;.....
;
; place time character into header
; ----------------------
DY:	PUSH H
	LHLD DATCOL ! MOV M,A
	INX H ! SHLD DATCOL 
	POP H 
	RET
;
SPACE:	MVI B,1
SPACES:	MVI A,20H ! CALL DY
	DCR B ! JNZ SPACES
	RET
;
;
CLKFLD:		;Set from clock  (Packed BCD format)
	DB 0	;Day of week
	DB 0	;Day of month
	DB 0	;Month
	DB 83H	;Year
	DB 0	;Hour
	DB 0	;Minutes
	DB 0	;Seconds
;
;
DAYLST:
	DB 'SUNMONTUEWEDTHUFRISAT'
MONTHLST:
	DB 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC'
;
;
;
RDCLK:	MVI A,0CH ! OUT BLKSEL		;Select counters
	LXI H,CLKFLD
	IN BLK+5 ! MOV M,A ! INX H	;Read day of week
	IN BLK+6 ! MOV M,A ! INX H	;  day of month
	IN BLK+7 ! MOV M,A ! INX H	;  month
	INX H				;  bypass year
	IN BLK+4 ! MOV M,A ! INX H	;  hour
	IN BLK+3 ! MOV M,A ! INX H	;  minutes
	IN BLK+2 ! MOV M,A		;  seconds
	MVI A,0EH ! OUT BLKSEL		;Select clock status block
	IN BLK+4 ! ANI 1 ! JNZ RDCLK	;Retry if time not valid
	IN BLK+0			;Reset interrupt
;
	LXI D,CLKFLD
	LXI H,DAYLST
	LDAX D ! INX D ! CALL DYTX	;Day of week
	CALL SPACE
	LDAX D ! INX D ! CALL DYHEX	;Day
	CALL SPACE
	LXI H,MONTHLST			;Month
	LDAX D ! INX D ! CALL DYTX
	CALL SPACE
	LDAX D  ! INX D ! CALL DYHEX	;Year
	MVI B,2 ! CALL SPACES
	LDAX D  ! INX D ! CALL DYHEX	;Hour
	MVI A,':' ! CALL DY
	LDAX D ! INX D ! CALL DYHEX	;Minutes
	MVI A,':' ! CALL DY
	LDAX D ! CALL DYHEX		;Seconds
	JMP TEXIT
;.....
;
; DISPLAY TABLE ENTRY
; Accepts: HL = ptr to table, A = BCD index into table
;
DYTX:
	CPI 10H ! JC DYTX1	;Convert index to binary
	ANI 0FH ! ADI 10
DYTX1:	MOV C,A ! DCR C ! XRA A
	ADD C ! ADD C ! ADD C
	MOV C,A ! MVI B,0 ! DAD B
	MOV A,M ! INX H ! CALL DY
	MOV A,M ! INX H ! CALL DY
	MOV A,M ! JMP DY
;.....
;
;
; ROLL UP PAGE TO TERMINATE
;
ROLL:   LDA   START          ;HAVE WE STARTED PRINTING AT ALL?
        ORA   A
        JZ    NOPNT          ;IF NOT, TELL WHAT MAXIMUM PAGE WAS
        MVI   A,CR
        CALL  WRITEP         ;SEND
;
ROLL1:  LDA   LCNT
        INR   A
        STA   LCNT
        push  h
	lxi   h,text
	cmp   m
	pop   h
        JNC   ROLL2 
        MVI   A,LF
        CALL  WRITEP         ;SEND
        JMP   ROLL1          ;GO DO ANOTHER UNTIL DONE
;
ROLL2:  CALL  TTABS          ;CHECK FOR TEAR TABS
	LDA   NOTAB          ;USING FANFOLD PAPER?
	ORA   A
	JZ    EXIT           ;IF YES, LEAVE IN NORMAL POSITION
        LXI   H,QUIT         ;FINAL LINES TO FINISH PAGE
        CALL  STRNGP
        JMP   EXIT           ;DONE
;.....
;
;
; OPTION FOR ROLL PAPER (CHANGES FANFOLD AREAS)
;
RPAPER: LXI   H,MSG1B        ;ASK IF USING ROLL PAPER
        CALL  STRNGC
        CALL  INPUT
        ANI   5FH            ;CHANGE TO UPPER CASE IF NEEDED
        CPI   'Y'                  
        JNZ   RPAP1          ;IF NOT, EXIT
;
        INR   A              ;INCREMENT TO '1'
        STA   NOTAB	     ;SHOW WE WANT TEAR TABS
;
RPAP1:  LXI   H,MSG3 
        CALL  STRNGC
        RET
;.....
;
;
; IGNORE CR, LF, FFD OR EOF AT TOP OF ANY NEW PAGE
;
SKIP:   CALL  GETCH          ;GET INPUT CHAR.
        CPI   CR
        JZ    SKIP           ;IF YES, SKIP
        CPI   LF
        JZ    SKIP           ;IF YES, SKIP
        CPI   EOF
        JZ    ROLL           ;IF YES, TERMINATE
        CPI   FFD
        JZ    SKIP           ;IF YES, IGNORE
        RET
;.....
;
;
; TRANSFER A STRING OF CHARS. FROM ONE AREA TO ANOTHER
;
STORE:  MOV   A,M
        STAX  D
        INX   H
        INX   D
        DCR   C
        JNZ   STORE
        RET
;.....
;
;
; PRINT AND DISPLAY A STRING OF CHARACTERS
;
STRNGB: MOV   A,M
        ORA   A
        RZ                   ;DONE IF ZERO
        CALL  WRITE2         ;DISPLAY AND PRINT CHAR.
        INX   H              ;NEXT LOCATION
        JMP   STRNGB         ;DO THE NEXT ONE
;.....
;
;
; WRITE ASCII STRING TO CRT ONLY
;
STRNGC: MOV   A,M
        ORA   A
        RZ
        CALL  WRITCC         ;DISPLAY ONLY
        INX   H
        JMP   STRNGC         ;DO NEXT CHAR.
;.....
;
;
; PRINT A STRING OF CHARACTERS
;
STRNGP: MOV   A,M            ;GET THE CHAR.
        ORA   A
        RZ                   ;DONE IF ZERO
        CALL  WRITEP         ;PRINT CHAR.
        INX   H
        JMP   STRNGP         ;DO THE NEXT ONE
;
;.....
;
; print a string of characters to OKI u84
;
stroki:	mov	a,m		;get the character
	ora	a
	rz			;done bail out
	mov	e,a		;put character in E reg.
	call	writpr		;print the character
	inx	h
	jmp	stroki		;loop till done
;.....
;
;
; ADDS TEAR TABS FOR ROLL PAPER
;
TTABS:  LDA   NOTAB	     ;WANT TEAR TABS?
	ORA   A
	JZ    NUPAGE	     ;IF NOT EXIT. SEND LINE FEEDS
        LXI   H,QUITR
        CALL  STRNGB         ;SEND LF TO FINISH THE PAGE
        MVI   A,'-'
        CALL  WRITE3
        LDA   TTABN          ;GET NUMBER OF SPACES BETWEEN TABS
        MOV   B,A
;
TTABS1: MVI   A,' '
        CALL  WRITE3
        DCR   B
        JNZ   TTABS1
;
        MVI   A,'-'
        CALL  WRITE2
        LXI   H,QUITR
        CALL  STRNGB
        XRA   A
        STA   COLMN          ;RESET THE COLUMN COUNTER
        RET
;.....  
;
;
; WRITE CHAR. TO CRT
;
WRITE2: CPI   SI             ;SYNCH CHAR.?
        RZ                   ;IF YES, IGNORE
        CPI   CR
        JZ    WRITE3         ;DO NOT COUNT
        CPI   LF
        JZ    WRITE3         ;DO NOT COUNT
        PUSH  PSW            ;SAVE THE CHAR. VALUE
        LDA   COLMN          ;INCREMENT THE COLUMN COUNT
        INR   A
        STA   COLMN
        POP   PSW            ;RESTORE THE CHAR. VALUE
;       
;
WRITE3: CALL  WRITEC
;
;
; WRITE CHAR. TO PRINTER
;
WRITE1: CALL  WRITEP
        RET
;.....
;
;
; WRITE ASCII CHARACTER TO CRT
;
WRITEC: MOV   E,A            ;STORE THE CHAR. TEMP.
        LDA   START          ;READY TO DISPLAY YET?
        ORA   A
        MOV   A,E            ;RESTORE THE CHAR.
        RZ
;
WRITCC: PUSH  H
        PUSH  D
        PUSH  B
        PUSH  PSW
        MOV   E,A
        MVI   C,CONOUT       ;WRITE TO THE CRT CONSOLE
        CALL  BDOS
        POP   PSW
        POP   B
        POP   D
        POP   H
        RET
;.....
;
;
; WRITE ASCII CHARACTER TO PRINTER
;
WRITEP: CPI   SI             ;SYNCH CHAR.?
        RZ                   ;IF YES, IGNORE
        MOV   E,A            ;PUT CHAR. IN 'E' REG.
        LDA   START          ;READY TO START YET?
        ORA   A
        RZ                   ;EXIT IF NOT READY YET
;
writpr:	PUSH  H
        PUSH  B
        MVI   C,LIST         ;WRITE TO THE PRINTER
        CALL  BDOS
        POP   B
        POP   H
        RET
;
;.....
;
;
	DS    40                ;MIMIMUM STACK DEPTH
STACK:	DS    0
;
BUFF	equ	($+127)/128*128	;GET ON AN EVEN PAGE
;
;
	ORG	BUFF
;
BUFFER  EQU   $
;.....
;
;
        END   START
