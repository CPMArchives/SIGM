	TITLE	'BYE Vers 7.2G of August 8, 1982'
;
VER	EQU	72	;Current version number
REV	EQU	'G'	;Current sub revsion
DAY	EQU	8	;Day of the month in range 1 to 31
MONTH	EQU	8	;Month of the year in range 1 to 12
YEARS	EQU	82	;Year in range 00 to 99
;
;	Last minor change August 8, 1982
;
;		BYE V7.2G (revised 08/8/82)
;	REMOTE CONSOLE PROGRAM FOR CP/M AND MODEM
;
;This program allows modem callers to use your CP/M system
;just as if they were seated at the system console.  Special
;assembly-time options allow limiting the caller's access by
;password and/or access to only a message-service program.
;
;Based on an original program written by Dave Jaffe, January 1979
;Rewritten for PMMI modem by Ward Christensen, February 1979.
;Be sure to set the equates for the modem
;you are using.
;
;Thanks to Bill Precht for the "label + offset" idea allowing
;this program to relocate itself without using DDT to initially
;set it up.
;
;Adapted for Telecom Australia Auto answer modem
;operation with 2651 based UART interface. April, 1982
;
;Bill Bolton,
;Software Tools,
;P.O. Box 80,
;Newport Beach,
;NSW, 2106,
;Australia.
;
;Modifications/fixes: (in reverse order to minimize reading time)
;
;08/Aug/82 Added code to reset mode of 2651 UART before each new call.
;	   This will force a reseting of the baud rate etc., in case
;	   it got glitched. Also added date and version equates for
;	   signon message to make maintenance easier. Ver 7.2G <WFB>
;
;25/Jun/82 Added conditional code to trap RST 7 and jump to a
;	   Warm Boot. Ver 7.2F <WFB>
;
;18/Jun/82 Added code to clear tx register of the UART after
;	   each carrier loss. With CCITT direct connect modems
;	   CTS goes inactive simultaneously with Carrier detect.
;	   On the 2651 UART, CTS inactive clamps the transmitter
;	   even if its in the middle of a character.
;	   If carrier was permanently lost in the middle of a
;	   character, this would sometimes clamp the 2651
;          transmitter in a "space" condition. The next caller would
;	   get "ANSWER" carrier offset to the "space" and some modems
;	   don't carrier detect on that, therefore CD and CTS never went
;	   active and never unclamped the transmitter (round and round
;	   in ever decreasing circles until it....). Ver 7.2E <WFB>
;	   
;16/Jun/82 Added conditional code for "flip" to answer mode after
;	   upper case question. Ver 7.2D <WFB>
;
;11/Jun/82 Added code to protect current state of frequency mode
;	   bit in command byte of UART during error reset and also
;	   added a few more UART equates. Ver 7.2C <WFB>
;
;25/May/82 Added ring detect to carrier timeout loop enable full
;	   carrier detect period after answering a new call and to
;	   prevent hanging up on new call as soon as it is answered
;	   if it arrived at the end of a timeout period. Added
;	   CTIME equate for carrier timeout period. Ver 7.2B <WFB>
;
;24/May/82 Added correct error reset code for 2651 to overcome
;	   the system sending data but refusing to accept data from
;	   modem. Many comments tabbed over to constant column
;	   position. Carrier dropout counter added to detect
;	   Telecom "open line" beep which occurs if remote user
;	   hangs up or line drops out. Telecom modems detect this
;	   as intermitant carrier and otherwise BYE will never
;	   time out. Ver 7.2A <WFB>
;	
; 6/Apr/82 Deleted DC Hayes and PMMI routines and replaced
;	   with general purpose UART interface to control Telecom
;	   auto answer modem. Deleted CPM2 switch, now permanently
;	   set for CPM2. UART may be banked type. Deleted ringback
;	   code. <WFB>
;
;11/Oct/81 Print password on local console with DUAL$IO. Allow
;	  return from PRNLOG with USRLOG. Make <CR><LF> instead
;	  of <LF><CR> in USRLOG reports. Print out BYE version
;	  number for easy identification. Position PRNLOG after
;	  cold boot routine, and change cold boot routine to
;	  jump to MBOOT, thereby defining path to PRNLOG for
;	  all BYE programs and allowing one trivial program
;	  that can be run to get the BYE log. Make counters
;	  16 bits for greater range. By Steve Bogolub
;
;1/Oct/81 Added CALL CHECK to MSTAT routine to eliminate
;	  possibility of system crash when carrier lost while
;	  performing repeated console status checks without
;	  any console output.  This problem occurs during the
;	  password input of USERPW.ASM, and potentially any other
;	  program that does repeated direct console input, such
;	  as MBASIC, etc.  
;	  By Ron Fowler and Dave Hardy
;
;14/May/81 Added CCS disk support (to turn off disks when idle)
;	  Added support for Godbout SS1 Real time clock.
;	  Added Phone to Lister, Punch & Reader patch. (AAJ)
;
;20/Mar/81 Fixed MOUTPUT so parity bit is stripped before outputting
;	  character to modem.  Corrected 3/18/81 null fix.  Added
;	  additional description to heading of this file.  (KBP)
;
;18/Mar/81 Add first-ring debounce routine, change PMMI HANGUP
;	  to do break for faster disconnect, fix error in P3TODTR
;	  equate for PMMI, added end-of-program error message to
;	  mark ending address (see note at label DEST). By KBP.
;	  Fix bug that prevented nulls at end of line if DUAL$IO
;	  was true.  By Hank Szyszka.
;
;23/Feb/81 Conditional assembly added for Intertec SuperBrain
;	  with Racal-Vadic 3451 modem. Corrected lack of RET in
;	  CONIN. In MOUTPUT, replaced CZ CHECK with JNZ SILENT,
;	  CALL CHECK; this eliminates chance of looping in MOUTPUT
;	  if modem doesn't empty USART after carrier lost.
;	  Also had to write a routine to patch BIOS so that after
;	  the warm boot disk read this program repatches the BIOS.
;	  Apparently the SuperBrain warm boot overwrites a portion
;	  of the BIOS. By P.L. Kelley
;
;17/Feb/81 Added check for extraneous control characters in
;	   hardcopy log.  (Formfeed seems to be a common "hit").
;	   Changed local startup test to directly test for carrier
;	   instead of calling CARCK, to avoid 15 second delay.
;	   <BRR>
;
;15/Feb/81 Removed dependance on DC Hayes hardware timer so that
;          DCHAYES conditional assembly is compatible with both
;          old-style 80-103A and new-style MM100 boards.
;          Rearranged patch list to "most recent first" order.
;	   Added message for invalid-drive test.
;          Added ANI 7Fh to upper case conversion test so that
;          it's not fooled by bit 7 being set.
;          Added WELUSR equate for user # containing WELCOME file.
;          Removed PTRPORT equate and changed hardcopy logic to
;          work through the BIOS printer driver. <BRR>
;
;22/Jan/81 CHANGED CARRIER DETECT ROUTINE FOR DC HAYES TO WAIT FOR
;	   15 SECONDS AFTER LOSS OF CARRIER TO RETURN.  <DAVID KOZINN>
;
;17/Jan/81 CHANGED TIMING LOOPS TO USE DC HAYES HARDWARE TIMER
;	   IF PRESENT.   <DAVID KOZINN>
;
;16/Jan/81 ADDED EQUATES AND CODE FOR THE DC-HAYES 
;	   MICROMODEM 100.  <DAVID KOZINN>
;
;23/Sep/80 Fixed bugs that prevented "bye /a" and "bye /c" from
;	  working properly.  Also repaired several errors in
;	  conditional assembly nesting. -->Ron Fowler
;
;20/Sep/80 Modified status checking during ring-wait routine to
;	  use cp/m BDOS call, as suggested by Keith Petersen.
;	  This should make the program more portable.  Also
;	  added Bruce Ratoff's update to DCHBYE program (5.5),
;	  that allows the use of bye from non-zero user areas.
;	  By Ron Fowler
;
;19/Sep/80 Modified COM file load routine to prevent BDOS
;	  overwrite if the COM file won't fit in the TPA
;	  By Ron Fowler
;
;19/Sep/80 Added new '/' option C, which has the same affect as
;	  /A, except that /C loads the com file after answering
;	  the phone, while /A boots cp/m.
;	  By Ron Fowler
;
;19/Sep/80 Added conditional assembly to give the operator a
;	  'twit' logout key. Added conditionals for 'message
;	  from operator' and 'system down in 5 minutes' keys.
;	  Added front-panel selection of hard-copy log, remote
;	  'black-out', and password option.  Also, if cpm/2 is
;	  used, a message is printed when an unsupported user
;	  area is entered.
;	  By Ron Fowler and Dave Hardy
;
;19/Sep/80 Modified to prevent re-load of the com file when
;	  a voice call comes in.  Reset the DMA address back
;	  to 80h after the com file is loaded.
;	  By Ron Fowler
;
;16/Sep/80 Added conditional assembly to allow automatic
;	  loading of a com file instead of cp/m boot. Also
;	  added decimal usrlog counters as conditional as-
;	  sembly.
;	  By Ron Fowler
;
;15/Sep/80 Added conditional assembly for automatic timed
;	  log-out, drive and user number masking, lower
;	  case query at login, and cp/m 2.x.  Thanks to
;	  Bruce Ratoff for the routines (lifted from his
;	  'DCHBYE54.ASM') used to implement these functions
;	  NOTE: in order to implement the timed log-out, it
;	  was necessary to do timing in software loops.
;	  Therefore, a new equate, FASTCLK, has been added
;	  to allow for 4mhz clock speeds. Also added Bruce
;	  Ratoff's overrun/framing error checking when read-
;	  ing the modem port.
;	  By Ron Fowler
;
;16/Jul/80 Added "/R" command option to allow USRLOG
;	  counters to be reset upon entry.
;	  By Dave Hardy
;
;11/Jul/80 Added conditional assembly for password and
;	  user log routines, and routines to print USRLOG
;	  information on console after program exit.
;	  By Dave Hardy
;
;10/Jul/80 Added code to allow auto-answer after first
;	  or second ring for more reliable auto-answer
;	  when using "ringback" option.
;	  By Dave Hardy
;
;29/Jun/80 Added USRLOG routines to keep track of number
;	  of callers, and display on front panel
;	  of IMSAI (i.e. output number to port FFH).
;	  By Dave Hardy
;
;11/Jun/80 Added 710 Baud rate selection option at sign-on.
;	  By Dave Hardy and Bruce Levison.
;
;11/Jun/80 Added routines to allow conditional assembly for
;	  Morrow's Discus 2D board (all Rev's) with memory
;	  mapped I/O.
;	  By Dave Hardy
;
;24/Jan/80 Added routines to preserve registers when calling
;	  the user's CBIOS.  Added conditional assembly for
;	  callback feature.  Increased stack space to 60.
;	  By Keith Petersen.
;
;24/Sep/79 Added routines to allow automatic multiple baud
;	  rate selection, exit to CP/M from local console,
;	  echo nr. of nulls selected. By Keith Petersen,
;	  with thanks to Bob Mathias for suggestions.
;
;6/Jul/79 Added routine to allow "callback" operation so modem
;	  does not answer normal voice calls.  By Robbin Hough
;	  and Keith Petersen, W8SDZ.
;
;
;------------------------------------------------
;	SYSTEM EQUATES
FALSE	EQU	0
TRUE	EQU	NOT FALSE
BDOS	EQU	5
CR	EQU	0DH
LF	EQU	0AH
MINUTES	EQU	20*60	;CONSTANT FOR 1 MIN TIM DLY
;
;CHANGE THE FOLLOWING EQUATE TO AN AREA IN YOUR
;HI MEMORY WHERE THIS PROGRAM MAY PATCH ITSELF IN.
;APPROX MEMORY REQUIREMENTS: UP TO xxxx BYTES.
;
DEST	EQU	0F400H	;RUNNING LOCATION OF CODE
;
;YOU WILL LIKELY ALSO WANT TO CHANGE THE PASSWORD,
;LOCATED BELOW AT LABEL "PASSWD", AND THE MESSAGES
;PRINTED AT LABEL "WELCOME" AND JUST ABOVE LABEL
;"HANGUP"
;
;------------------------------------------------
;
;THIS PROGRAM RUNS UP IN HIGH RAM.  IT GETS THERE
;BY BEING MOVED THERE WHEN 'BYE' IS TYPED.
;
;THE PROGRAM IN HI RAM DOES THE FOLLOWING:
;
;	1.	HANGS UP THE PHONE
;	2.	AWAITS RING DETECT, ALLOWS EXIT
;		TO CP/M IF LOCAL KBD TYPES CTL-C
;	3.	OUTPUTS CARRIER
;	4.	AWAITS INCOMING CARRIER
;		GOING TO STEP 1 IF NONE
;		FOUND IN 25 SECONDS
;	5.	ASKS NUMBER OF NULLS (0-9)
;	6.	TYPES THE FILE "STARTUP" FROM
;		DISK, ALLOWING CTL-C TO SKIP IT
;	7.	OPTIONALLY ASKS FOR A PASSWORD, ALLOWING
;		5 TRIES TO GET IT RIGHT.
;	8.	WHEN PASSWORD ENTERED, IF USED, DROPS
;		INTO CP/M.
;	9.	CALLER CAN LEAVE BY HANGING UP,
;		(ANY TIME CARRIER IS LOST, IT
;		WAITS 25 SECONDS, THEN GOES
;		BACK TO STEP 1), OR THE CALLER
;		MAY TYPE THE PROGRAM NAME (BYE)
;
;
;****************************************************
;*	    OPTION CONFIGURATION SECTION	    *
;****************************************************
;
PRINTER EQU	FALSE	;WANT TO RETAIN LIST DEVICE?
DUAL$IO EQU	TRUE	;WANT CONSOLE & MODEM?
CALLBAK EQU	FALSE	;WANT CALLBACK FEATURE?
PWRQD	EQU	FALSE	;WANT TO USE PASSWORD?
USRLOG	EQU	TRUE	;WANT TO COUNT NUMBER OF USERS?
IMSAI	EQU	FALSE 	;ADDS VARIOUS OPIONS W/SENSE SW'S
MAX$USER EQU	0	;SET TO 0 FOR CP/M 1.X
MAX$DRIVE EQU	3	;HIGHEST DRIVE SUPPORTED
SPEED	EQU	4	;Speed in Mhz of CPU (for timing loops)
TIMEOUT EQU	TRUE	;WANT AUTO LOG-OFF FOR SLEEPY CALLERS?
TOVALUE EQU	5	;THIS IS 7 MINUTES TO AUTO LOGOUT
CTIME	EQU	25	;Number of seconds for carrier timeout (25 max)
MAXDROP	EQU	50	;Maximum number of allowable carrier losses
WELUSR	EQU	0	;USER # THAT WELCOME FILE IS KEPT IN
COMFILE EQU	TRUE	;WANT TO AUTOBOOT A COM FILE?
COMUSR	EQU	0	;USER # THAT COMFILE IS KEPT IN
DECIMAL EQU	TRUE	;WANT DECIMAL VALUES FOR LOGS?
CK$LWC	EQU	TRUE	;WANT TO TRAP LOWER CASE?
RTC	EQU	TRUE	;True if Godbout System Support 1
MOTOR	EQU	TRUE	;True for motor control of drives
INTER3	EQU	FALSE	;True for Gobout Interfacer 3/4 I/O board
FLIP	EQU	TRUE	;Want to swap modem mode?
RETIME	EQU	6	;Time for remote modem to detect new carrier 
RESTART	EQU	TRUE	;True for trapping one RST vector
RSVECT	EQU	038H	;Address of restart vector to patch
;
;
	if	motor
DISKON	EQU	0H	;Turn drive motor on for YE-180
DISKOFF	EQU	80H	;Turn drive motor off for YE-180
DISK	EQU	0C3H	;For Godbout Disk 1
	endif	;motor
;
; SPECIAL KEYS FOR SPECIAL FUNCTIONS
;
FKEYS	EQU	TRUE	;WANT SPECIAL FUNCTION KEYS?
;
;ASSIGN FUNCTION KEYS TO THE FOLLOWING CONTROL CODES (IF USED):
;
TWITKEY EQU	'N'-40H ;KEYCODE TO LOG-OUT A CREEP
MSGKEY	EQU	'Q'-40H ;KEYCODE TO PRINT 'MESG FROM OPER:'
SYSDKEY EQU	'O'-40H ;KEYCODE TO PRINT SYS DOWN MSG
;
;	FRONT-PANEL SELECTION OPTIONS
;
SENSE	EQU	0FFH	;SENSE SWITCH PORT NUMBER
;
BLACKOUT EQU	TRUE	;SWITCH TO TURN OFF REMOTE SEND
HARDLOG EQU	TRUE	;SWITCH TO ECHO REMOTE KBD TO PRINTER
SELPASS EQU	TRUE 	;SWITCH TO REQUIRE A PASSWORD
;
;	ASSIGNMENT OF FRONT-PANEL OPTIONS TO SWITCHES:
;
LOGSW	EQU	01H	;TURN ON FOR HARDCOPY
PWDSW	EQU	02H	;TURN ON FOR 'PASSWORD' MODE
BLACKSW EQU	04H	;TURN ON TO BLACK OUT REMOTE END
ENABLF	EQU	08H	;TURN ON TO ENABLE SPL FUNC KEYS
;
;****************************************************
;*	 END OF OPTION CONFIGURATION SECTION	    *
;****************************************************
;
;ALL MODEM I/O AND CONTROL ARE HERE.
;
;************************************************
;*						*
;*	     2651 Baud Rate Table		*
;*						*
;************************************************
;
B50	EQU	0000B			;50 bps
B75	EQU	0001B			;75 bps
B110	EQU	0010B			;110 bps
B134	EQU	0011B			;134.5 bps
B150	EQU	0100B			;150 bps
B300	EQU	0101B			;300 bps
B600	EQU	0110B			;600 bps
B1200	EQU	0111B			;1200 bps
B1800	EQU	1000B			;1800 bps
B2000	EQU	1001B			;2000 bps
B2400	EQU	1010B			;2400 bps
B3600	EQU	1011B			;3600 bps
B4800	EQU	1100B			;4800 bps
B7200	EQU	1101B			;7200 bps
B9600	EQU	1110B			;9600 bps
B19200	EQU	1111B			;19200 bps

;************************************************
;*						*
;*		2651 Equates			*
;*						*
;************************************************
;
BASE	EQU	5CH	;Interfacer 3 base port
DATA	EQU	BASE	;2651 data port
STATUS	EQU	BASE+1	;2651 status port
MODE	EQU	BASE+2	;2651 mode port
CMMD	EQU	BASE+3	;2651 command port

	if	inter3
USER	EQU	BASE+7H	;UART select port
CONS	EQU	0	;Console relative UART
MODEM	EQU	6	;Modem relative UART
	endif	;inter3

;
MODE1	EQU	01101110B		;Asynch,16x,8 data bits,
					; no parity, even, 1 stop bit
MODE2	EQU	01110000B + B300	;Baud rate
CMMDB	EQU	00100111B		;Tx enabled, RX enabled, no break
					; DTR high, RTS high
;
; Status bits
;
GBTBMT	equ	00000001b	;Transmit buffer empty
GBDAV	equ	00000010b	;Data available
GBTXE	equ	00000100b	;Transmit shift reg empty
GBPE	equ	00001000b	;Parity error
GBOE	equ	00010000b	;Overrun error
GBFE	equ	00100000b	;Framing error
GBCD	equ	01000000b	;RS 232 Carrier Detect input
GBDSR	equ	10000000b	;RS 232 Data Set Ready input
RING	EQU	GBDSR		;Ring detect input
;
; Control bits
;
GBTXEN	equ	00000001b	;Transmitter enable
GBDTR	equ	00000010b	;DTR (CCITT 108) control
GBRXEN	equ	00000100b	;Receiver enable
GBREAK	equ	00001000b	;Send break
ERESET	equ	00010000b	;Error reset
GBRTS	equ	00100000b	;RTS control (used as mode select)
;
;
	ORG	100H
;
;MOVE THE MODEM INTERFACE PROGRAM UP TO HI RAM
;AND JUMP TO IT.
;
MOVEUP	LXI	B,PEND-START+1	;NUMBER OF BYTES TO MOVE
	LXI	H,DEST+PEND-START+1 ;END OF MOVED CODE
	LXI	D,SOURCE+PEND-START	;END OF SOURCE CODE
MVLP	LDAX	D		;GET BYTE
	DCX	H		;BUMP POINTERS
	MOV	M,A		;NEW HOME
	DCX	D
	DCX	B		;BUMP BYTE COUNT
	MOV	A,B		;CHECK IF ZERO
	ORA	C
	JNZ	MVLP		;IF NOT, DO SOME MORE

	PUSH	H		;SAVE FOR LATER JUMP
	MVI	A,0C3H		;CLEAR ANY TRAPS SO SYSOP..
	STA	0		;CAN USER "BYE /A"
	XRA	A		;NEXT WARMBOOT TO USR0/DRV A
	STA	4
	MVI	C,14		;MAKE DRIVE A DEFAULT
	MOV	E,A		;LOG-IN DRIVE CP/M FUNCTION
	CALL	BDOS
	MVI	C,32		;GET/SET USR CP/M FUNCTION
	MVI	E,WELUSR
	CALL	BDOS
	RET			;TO ADRS PUSHED ABOVE
;
VMSG:	DB	'BYE version '
	DB	VER/10 + '0','.',(VER MOD 10) + '0',REV
	DB	' of '
	if	month = 1
	DB	'January'
	endif
	if	month = 2
	DB	'February'
	endif
	if	month = 3
	DB	'March'
	endif
	if	month = 4
	DB	'April'
	endif
	if	month = 5
	DB	'May'
	endif
	if	month = 6
	DB	'June'
	endif
	if	month = 7
	DB	'July'
	endif
	if	month = 8
	DB	'August'
	endif
	if	month = 9
	DB	'September'
	endif
	if	month = 10
	DB	'October'
	endif
	if	month = 11
	DB	'November'
	endif
	if	month = 12
	DB	'December'
	endif

	DB	' ',DAY/10 +'0',(DAY MOD 10) + '0'
	DB	', 19',YEARS/10 + '0', (YEARS MOD 10) + '0',CR,LF,'$'
;
SOURCE	EQU	$	;BOUNDARY MEMORY MARKER
;
OFFSET	EQU	DEST-SOURCE ;RELOC AMOUNT
;-----------------------------------------------;
;	THE FOLLOWING CODE GETS MOVED		;
;	 TO HI RAM LOCATED AT "DEST",		;
;	    WHERE IT IS EXECUTED.		;
;-----------------------------------------------;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;XX   C A U T I O N :  IF MODIFYING ANYTHING	XX
;XX	IN THIS PROGRAM FROM HERE ON:		XX
;XX	A-L-L  LABELS MUST BE OF THE FORM:	XX
;XX	label	EQU	$+OFFSET		XX
;XX	IN ORDER THAT THE RELOCATION TO HI RAM	XX
;XX	WORK SUCCESSFULLY.  FORGETTING TO	XX
;XX	SPECIFY '$+OFFSET' WILL CAUSE THE PRO-	XX
;XX	GRAM TO JMP INTO WHATEVER IS CURRENTLY	XX
;XX	IN LOW MEMORY, WITH UNPREDICTABLE	XX
;XX	RESULTS.  BE CAREFUL....		XX
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;
;	IF CARRIER LOST, HANG UP, AWAIT RING.
;	OTHERWISE, SAY GOODBYE, AND HANG UP
;
START	EQU	$+OFFSET
;
	XRA	A	;GET 0
	STA	LOSTFLG ;SHOW NO CARR. LOST
;
;	DON'T ALLOW A REMOTE USER TO DO 'BYE /A'
;
	if	inter3
	mvi	a,modem
	out	user	;Select modem UART
	endif	;inter3

	IN	STATUS
	ANI	GBCD	;Carrier?
	JNZ	GOODBY	;Yes, remote user so say goodbye

;
;Indentify version of program
;
	mvi	c,printf
	lxi	d,vmsg
	call	bdos
;
;CHECK FOR /A OPTION ON COMMAND - REQUEST TO
;GO IMMEDIATELY INTO ANSWER MODE
;
	LXI	H,FCB+1		;TO OPTION
	MOV	A,M
	CPI	'/'		;OPTION?
	JNZ	HANGUP
;GOT AN OPTION - VALIDATE IT
	INX	H		;TO OPTION BYTE
	MOV	A,M		;GET IT
	STA	OPTION		;MIGHT NEED LATER
	CPI	'A'		;ANSWER?
	JZ	ANSWER

	if	comfile
	CPI	'C'
	JZ	ANSWER
	endif	;comfile

	if	usrlog		;CHECK FOR RESET OF COUNTERS
	CPI	'R'
	CZ	RESET
	endif	;usrlog

	JMP	HANGUP		;WE KNOW IT'S LOCAL, SO SKIP CALL TO CARCK

;NO OPTION, OR INVALID ONE
NOSLASH EQU	$+OFFSET
	CALL	CARCK		;SIGNED OFF W/THIS PROG?
	JC	HANGUP		;NOBODY THERE
;
GOODBY	EQU	$+OFFSET
	CALL	ILPRT		;PRINT THIS MSG:
;
	DB	CR,LF,'GOOD BYE, CALL AGAIN'
;
	if	rtc
;
	db	CR,LF,CR,LF,'Off at ',0
;
	call	time
	call	ilprt
	endif	;RTC
;
	DB	CR,LF,0
;
	CALL	UNPATCH ;UNDO BIOS PATCHES
;
;	NOBODY THERE, OR WE ARE DONE, SO HANG UP
;
HANGUP	EQU	$+OFFSET
	LXI	SP,STACK	;SET UP LOCAL STACK
	XRA	A	 	;FORCE NEXT WARMBOOT TO USER 0
	STA	4	 	;AND DRIVE A
	MVI	C,14	 	;MAKE DRIVE A DEFAULT
	MOV	E,A
	CALL	BDOS
	MVI	A,' '		;DON'T ALLOW OPTIONS..
	STA	OPTION		;..AFTER 1 "BYE / <ANYTHING>"

	if	comfile
	MVI	C,32		;GET/SET USER CODE
	MVI	E,COMUSR	;LOCATION OF OUR COMFILE
	CALL	BDOS
	CALL	LODCOM		;LOAD THE COM FILE
	endif	;comfile

	if	restart
	MVI	A,0C3H		;Set up restart 7 trap
	STA	RSVECT		; to do a warm boot
	XRA	A
	STA	RSVECT+1
	STA	RSVECT+2
	endif	;restart
;
;
HANGUP2	EQU	$+OFFSET
;

	if	motor
	CALL	DSKOFF
	endif	;motor

;CLEAR DTR CAUSING PHONE TO HANG UP AND RESET BAUD
;RATE ON USART IN CASE IT GOT CHANGED

	if	inter3
	mvi	a,modem
	out	user		;Select modem UART
	endif	;inter3

	MVI	A,MODE1
	OUT	MODE
	MVI	A,MODE2
	OUT	MODE
	MVI	A,GBRTS		;Turn off DTR, Tx and Rx enable, break,
	OUT	CMMD		; reset and test modes (but not RTS)
	push	b
	mvi	b,10		;1 second delay

OFFTI	EQU	$+OFFSET
	call	delay
	dcr	b
	jnz	offti
	pop	b
	mvi	a,cmmdb		;Enable Tx, Rx, DTR, RTS
	out	cmmd
	MVI	A,0C3H		;CLEAR ANY TRAPS..
	STA	0		;..LEFT FROM COM FILE
	XRA	A
	STA	DROPOUT		;Initialise count of carrier losses
;
;	AWAIT RINGING
;
;CHECK LOCAL KEYBOARD FOR CTL-C EXIT REQUEST.
;NOTE: MUST DO DIRECT INPUT BECAUSE CBIOS PATCHES
;ARE NOT DONE UNTIL CALL COMES IN.
;
RINGWT	EQU	$+OFFSET
	CALL	UCSTS
	ANI	7FH		;STRIP PARITY BIT
	CPI	'C'-40H		;CONTROL C?

	if	motor
	CZ	DSKON
	endif	;motor

	if	NOT USRLOG
	JZ	0		;YES, --EXIT-- TO CP/M
	endif	;NOT USRLOG
;
	if	USRLOG		;PRINT OUT USER INFO
	cz	usrchk
	endif	;USRLOG
;
;SETUP MODEM
;
ANSWER	EQU	$+OFFSET
	if	usrlog		;COUNT # OF LOGON ATTEMPTS
	LXI	h,OLDUSR	;GET # OF ATTEPMTS
	call	boplog		;ADD THIS CALL
	endif	;usrlog

	if	inter3
	mvi	a,modem
	out	user		;Select modem UART
	endif	;inter3

	MVI	A,CMMDB		;TURN ON
	OUT	CMMD		;..DTR
	CALL	DELAY		;GIVE TIME FOR ANSWER
	CALL	UCSTS		;CLEAR LOCAL CONSOLE
	IN	DATA		;CLEAR MODEM PORT
	CALL	MRESET		;Reset any modem UART errors
	CALL	CARCK		;LOOK FOR CARRIER
	JC	HANGUP2		;Not found
	CALL	PATCH		;PATCH JMP TABLE
	JMP	WELCOME
;
;	Get the console status when unpatched
;
UCSTS	EQU	$+OFFSET
	MVI	C,DIRECTIO	;DIRECT I/O CALL WILL RETURN
	MVI	E,0FFH		;ASK FOR INPUT
	CALL	BDOS	   	;A=0 IF NO CHAR WAITING
	RET
;
;
;FOLLOWING ARE THE USRLOG ROUTINES
;
	if	usrlog		;INCLUDE RESET FUNCTIONS
RESET	EQU	$+OFFSET	;RESET ALL LOGON COUNTERS
	lxi	h,0
	endif	;usrlog

	if	usrlog and pwrqd
	shld	OLDUSR		;RESET ATTEMPT COUNTER
	endif	;usrlog and pwrqd

	if	usrlog
	shld	NEWUSR		;RESET LOGON COUNTER
	endif	;usrlog

	if	usrlog and imsai
	mvi	a,0ffh
	OUT	SENSE		;RESET IMSAI PANEL DISPLAY
	endif	;usrlog and imsai

	if	usrlog
	RET
	endif	;usrlog
;
MCBOOT	equ	$+offset
	jmp	mboot
;
;See comments above, PRNLOG must begin here
;
PRNLOG	EQU	$+OFFSET
;
	if	usrlog and pwrqd ;PRINT # OF LOGON ATTEMPTS
	MVI	C,printf
	LXI	D,ATMSG
	CALL	BDOS
	lxi	OLDUSR+1	;point to high byte
	CALL	HXOUT
	endif	;usrlog and pwrqd
;
	if	usrlog		;PRINT # OF LOGONS
	MVI	C,printf
	LXI	D,SUMSG
	CALL	BDOS
	lxi	h,newusr+1
	CALL	HXOUT
	endif	;usrlog

	RET

	if	usrlog
USRCHK	equ	$+offset
	call	prnlog		;give info
	mvi	c,printf
	lxi	d,rs1msg
	call	bdos		;prompt for resume bye
PRNREL	equ	$+offset
	call	ucsts		;get reply
	ora	a
	jz	prnrel
	cpi	'R'		;R for resume?
	jz	prnres		;yes
	cpi	'R'+20H		;lower case also
	jnz	0		;no, warm boot
PRNRES	equ	$+offset
	mvi	c,printf
	lxi	d,rs2msg
	jmp	bdos		;resume via bdos after message
;
;BOPLOG increments the 16 bit counter pointed to by HL
;If decimal switch is active, number is kept as 4 BCD digits
;
BOPLOG	equ	$+offset
	mov	a,m		;get low byte
	inr	a
	endif	;usrlog

	if	usrlog and decimal
	daa
	endif	;usrlog and decimal

	if	usrlog
	mov	m,a		;replace low order
	rnc			;if no carry, BOP done
	inx	h		; else carry to high byte
	mov	a,m		;get high byte
	inr	a
	endif	;usrlog

	if	usrlog and decimal
	daa
	endif	;usrlog and decimal

	if	usrlog
	mov	m,a		;replace high byte
	ret
	endif	;usrlog
;

	if	usrlog and pwrqd
ATMSG	EQU	$+OFFSET
	DB	CR,LF,'NUMBER OF LOGON ATTEMPTS: $'
	endif	;usrlog and pwrqd

	if	usrlog
SUMSG	EQU	$+OFFSET
	DB	CR,LF,'NUMBER OF LOGONS: $'
RS1MSG	equ	$+offset
	DB	CR,LF,CR,LF,'Type R to Resume,'
	DB	' anything else to Warm Boot: $'
RS2MSG	equ	$+offset
	DB	'Resuming . . .',CR,LF,'$'
	endif	;usrlog
	
	if	usrlog
HXOUT	EQU	$+OFFSET
	push	h		;save pointer
	call	hxhaf		;do high byte first
	pop	h
	dcx	h		;point to low byte

HXHAF	equ	$+offset
	mov	a,m
	MOV	B,A		;SAVE NUMBER
	RAR			;ROTATE RIGHT 4 BITS
	RAR			;TO MAKE AN ASCII DIGIT
	RAR
	RAR
	CALL	ONEOUT		;OUTPUT MSH TO CONSOLE
	MOV	A,B		;GET NUMBER BACK

ONEOUT	EQU	$+OFFSET
	ANI	0FH		;GET LSH FOR OUTPUT
	adi	90h
	daa
	aci	40h
	daa
	PUSH	B
	MVI	C,02H
	MOV	E,A		;OUTPUT THE NUMBER
	CALL	BDOS
	POP	B
	RET
	endif	;usrlog
;
;WELCOME TO THE SYSTEM
;
WELCOME	EQU	$+OFFSET
;
GETNULL EQU	$+OFFSET

	if	motor
	CALL	DSKON
	endif	;motor

	CALL	ILPRT		;PRINT THIS MSG:
;
	DB	CR,LF
	DB	'HOW MANY NULLS (0-9) DO YOU NEED? ',0
;
	CALL	MINPUT		;GET VALUE
	MOV	C,A
	CALL	MOUTPUT 	;ECHO CHAR
	MOV	A,C
	CPI	'0'
	JC	GETNULL		;BAD, RETRY
	CPI	'9'+1
	JNC	GETNULL		;BAD
	SUI	'0'		;MAKE BINARY
	STA	NULLS		;SAVE COUNT
;
	if	ck$lwc
GETULC	EQU	$+OFFSET
	CALL	ILPRT		;NOW, PRINT THIS MSG:
;
	DB	CR,LF
	DB	'CAN YOUR TERMINAL DISPLAY LOWER CASE? ',0
;
	MVI	A,20H		;FORCE CASE CONVERSION FOR NOW
	STA	ULCSW
	CALL	MINPUT		;GET Y OR N
	MOV	C,A
	CALL	MOUTPUT 	;ECHO
	MOV	A,C
	CPI	'N'
	JZ	DONEOPT 	;WE'RE ALREADY SET UP FOR NO LWR CASE
	CPI	'Y'
	JNZ	GETULC		;WASN'T Y OR N...ASK HIM AGAIN
	XRA	A
	STA	ULCSW		;SET FLAG FOR NO CONVERSION
;
DONEOPT EQU	$+OFFSET
	endif	;ck$lwc
;
	if	flip
FLIPMD	EQU	$ + OFFSET
	CALL	ILPRT
;
	DB	CR,LF
	DB	'DO YOU  WANT TO "FLIP" THE MODEM MODE ? ',0
;
	CALL	MINPUT		;GET Y OR N
	ANI	05FH		;Make upper case
	MOV	C,A
	CALL	MOUTPUT 	;ECHO
	MOV	A,C
	CPI	'N'		;NO?
	JZ	DONEFLP 	;OK, NO CHANGE
	CPI	'Y'
	JNZ	FLIPMD		;WASN'T Y OR N...ASK HIM AGAIN
	CALL	ILPRT
;
	DB	CR,LF,CR,LF
	DB	'If  you answer "Y" to the next question you have 20 seconds to',CR,LF
	DB	'switch your  modem to the "ANSWER"  mode.  If you change  mode',CR,LF
	DB	'now,  you  CAN''T  change  back until you get to  CP/M  command',CR,LF
	DB	'level.'
	DB	CR,LF,0
;
FLIPLP	EQU	$ + OFFSET
	CALL	ILPRT
;
	DB	CR,LF
	DB	'DO YOU WANT TO CHANGE TO "ANSWER" MODE ? ',0
;
	CALL	MINPUT		;GET Y OR N
	ANI	05FH		;Make upper case
	MOV	C,A
	CALL	MOUTPUT 	;ECHO
	MOV	A,C
	CPI	'N'		;NO?
	JZ	NOCHNG	 	;OK, NO CHANGE
	CPI	'Y'
	JNZ	FLIPLP		;WASN'T Y OR N...ASK HIM AGAIN
;
;SET MODEM FOR DTR ON & ORIGINATE
;
	IN	CMMD		;Get the current mode
	XRI	GBRTS		;Toggle the bit
	OUT	CMMD		;Flip the mode
	CALL	CARCK		;Wait for carrier
	MVI	B,RETIME*10
FLLOOP	EQU	$ + OFFSET
	CALL	DELAY		;Let remote modem detect carrier
	DCR	B		;Remote modem ready yet?
	JNZ	FLLOOP		;No
	CALL	ILPRT		;Yes
;
	DB	CR,LF,CR,LF
	DB	'If you see this, the mode change was successful.'
	DB	CR,LF,0
;
	JMP	DONEFLP
;
NOCHNG	EQU	$ + OFFSET
	CALL	ILPRT
;
	DB	CR,LF,CR,LF
	DB	'OK, NO CHANGE IN MODE',CR,LF,0
;
DONEFLP	EQU	$ +OFFSET
	endif	;flip
;
	CALL	ILPRT
;
	DB	CR,LF,CR,LF,0
;
;PRINT THE WELCOME FILE
	LXI	H,WELFILN 	;SOURCE
	LXI	D,FCB		;DESTINATION
	MVI	B,13		;LENGTH
	CALL	MOVE		;MOVE THE NAME
;SET DMA ADDR TO 80H
	LXI	D,80H
	MVI	C,STDMA
	CALL	BDOS
;
;SET USER FOR WELCOME FILE
	MVI	C,32
	MVI	E,WELUSR
	CALL	BDOS
;
;OPEN THE WELCOME FILE
	LXI	D,FCB
	MVI	C,OPEN
	CALL	BDOS
;DID IT EXIST?
	INR	A		;A=> 0 MEANS "NO"
	JZ	PASSINT 	;NO WELCOME FILE
;GOT A FILE, TYPE IT
	XRA	A		;GET 0
	STA	FCBRNO		;ZERO RECORD #
	LXI	H,100H		;GET INITIAL BUFF POINTER
;TYPE THE WELCOME FILE
WELTYLP EQU	$+OFFSET
	CALL	RDBYTE		;GET A BYTE
	CPI	1AH		;EOF?
	JZ	PASSINT 	;YES, DONE
	MOV	C,A		;SETUP FOR TYPE
	CALL	MOUTPUT 	;TYPE THE CHAR
	CALL	MSTAT		;CHECK FOR..
	ORA	A		;CHAR TYPED?
	JZ	WELTYLP 	;..NO, LOOP
	CALL	MINPUT		;..YES, GET CHAR
	CPI	'C'-40H 	;CTL-C?
	JNZ	WELTYLP 	;..NO, LOOP UNTIL EOF
;
;GET THE PASSWORD
;
PASSINT EQU	$+OFFSET
;
;
	if	pwrqd and imsai and selpass 
	IN	SENSE		;TURN THE SWITCH UP..
	ANI	PWDSW		;..TO REQUIRE THE PASSWORD
	JZ	NOPASS
	endif	;pwrqd and imsai and selpass

	if	pwrqd
	MVI	D,5		;5 TRIES AT PASSWORD
PASSINP EQU	$+OFFSET
	CALL	ILPRT
;
	DB	CR,LF,'ENTER PASSWORD: ',0
;
	LXI	H,PASSWD	;POINT TO PASSWORD
	MVI	E,0		;NO MISSED LETTERS

	if	inter3
	mvi	a,modem
	out	user		;Select modem UART
	endif	;inter3

	IN	DATA		;CLEAR OUT GARBAGE
PWMLP	EQU	$+OFFSET
	CALL	MINPUT		;GET A CHAR
	CPI	60H		;LOWER CASE?
	JC	NOTLC		;NO,
	ANI	5FH		;MAKE UPPER CASE ALPHA

	if	dual$io
	push	psw		;save chararcter
	cpi	' '		;control?
	jnc	pwdis		;no, display it
	mvi	c,'^'		;yes, prefix it
	call	conout
	pop	psw
	push	psw
	adi	40h
pwdis	equ	$+offset
	mov	c,a
	call	conout
	pop	psw
	endif	;dual$io
	
	cpi	'U'-40h		;Control-U?
	jz	passinp		;Yes, another try
	CMP	M		;MATCH PASSWORD?
	JZ	PWMAT		;..YES
	MVI	E,1		;..NO, SHOW MISS
	CPI	CR		;C/R?
	JNZ	PWMLP		;..NO, WAIT FOR C/R
;
;PASSWORD DIDN'T MATCH
;
PWNMAT	EQU	$+OFFSET
	CALL	ILPRT
;
	DB	'++INCORRECT++',CR,LF,0
;
	DCR	D		;MORE TRIES?
	JNZ	PASSINP 	;YES
	JMP	BADPASS 	;NO, GO HANG UP
;
;CHARACTER MATCHED IN PASSWORD
;
PWMAT	EQU	$+OFFSET
	INX	H		;TO NEXT CHAR
	CPI	CR		;END?
	JNZ	PWMLP		;..NO, LOOP
;END OF PASSWORD.  ANY MISSED CHARS?
	MOV	A,E		;GET FLAG
	ORA	A
	JNZ	PWNMAT		;NOT RIGHT
;PASSWORD CORRECT
	endif	;pwrqd

NOPASS	EQU	$+OFFSET

	if	rtc
	call	ilprt
;
	db	CR,LF,CR,LF,'On system at ',0
;
	call	time
	call	ilprt
;
	db	CR,LF,0
;
	endif	;rtc

	if	usrlog		;COUNT # OF SUCCESSFUL LOGONS
	lxi	h,NEWUSR	;GET LAST VALUE
	call	boplog		;add one
	endif	;usrlog

	if	usrlog and imsai	;DISPLAY ON IMSAI
	lda	newusr		;re-get low order value
	CMA			;invert for lights
	OUT	SENSE		;DISPLAY ON IMSAI FRONT PANEL
	endif	;usrlog and imsai

	CALL	ILPRT
;
;
	DB	CR,LF,'Please wait a moment . . .',CR,LF,CR,LF,0
;		       ^^^^^^^^^^^^^^^^^^^^^^^^^^etc
;			PUT BOOT-UP MSG HERE
;
	if	comfile
	MVI	C,32
	MVI	E,COMUSR	;SWITCH TO COM FILE USER #
	CALL	BDOS
	LDA	OPTION
	CPI	'A'		;SYSOP CAN BYPASS COM FILE BY..
	JZ	0		;..TYPING "BYE /A"
	CPI	'C'		;OPER CAN ALSO GO TO COM..
	JNZ	100H		;..FILE LOAD WITH "BYE /C"
	CALL	ILPRT		;PRINT THIS MESSAGE
;
	DB	'Loading system...',CR,LF,0
;
	CALL	LODCOM
	JMP	100H		;EVERYONE ELSE GETS COM FILE
	endif	;comfile

	if	not comfile
	JMP	0
	endif	;not comfile
;
CARCK	EQU	$+OFFSET
;	LOSS OF CONNECTION TEST
;
;IF WE DETECT THAT THERE IS NO CARRIER UPON ENTRY TO
;THIS ROUTINE, WE'LL KEEP CHECKING FOR 25 SECONDS TO SEE IF THE
;CARRIER RETURNS. IF SO, WE'LL JUST CONTINUE ON. IF NOT, WE'LL
;SIGNAL THIS BY SETTING THE CARRY FLAG.
;
	if	inter3
	mvi	a,modem
	out	user		;Select modem UART
	endif	;inter3

	IN	STATUS		;GET MODEM STATUS
	ANI	GBCD		;GOT A CARRIER?
	JNZ	CARCK2		;YES, GO ON WITH TESTS
	LDA	DROPOUT		;Get dropout count
	ADI	1		;Increment it
	CPI	MAXDROP		;Bad line?
	JZ	BADPASS		;Yes, reset system
	STA	DROPOUT		;Save for later
	PUSH	B		;PRESERVE BC SO WE CAN USE IT
	MVI	B,CTIME*10	;Initialise timeout value
CARLP	EQU	$+OFFSET
	CALL	DELAY		;WAIT .1 SECONDS
	IN	STATUS
	ANI	RING		;Phone ringing?
	JZ	NO$RING		;No
	MVI	B,CTIME*10	;Yes, reintialise count
NO$RING	EQU	$+OFFSET
	IN	STATUS		;GET MODEM STATUS
	ANI	GBCD		;HAS CARRIER RETURNED?
	MOV	A,B		;PRESERVE COUNTDOWN VALUE
	POP	B		;FIX STACK IN CASE ALL IS OK
	JNZ	CARCK2		;GOT CARRIER, CONTINUE ON
	DCR	A		;COUNT TIME DOWN
	STC			;IN CASE THIS IS THE END OF TIME
	RZ			;RETURN IF TIMED OUT
	PUSH	B		;PRESERVE B
	MOV	B,A		;GET COUNTER VALUE IN B
	JMP	CARLP		;KEEP CHECKING
;
;	NOW TEST DRIVE #'S AND (IF CPM 2.X)
;	USER #'S TO INSURE THAT MAXIMUMS
;	ARE NOT EXCEEDED
;
CARCK2	EQU	$+OFFSET
	LDA	4		;CHECK DISK/USER #
	ANI	0FH		;ISOLATE DRIVE
	CPI	MAX$DRIVE	;VALID DRIVE?
	JC	CARCK3		;YES, SKIP THIS JUNK
	LDA	4		;RESTORE WHOLE LOGIN BYTE
	ANI	0F0H		;RETAIN USER #
	STA	4		;FORCE DRIVE TO A
	CALL	ILPRT		;TELL USER WHAT HE DID
;
	DB	'INVALID DRIVE - RETURNING TO A:',0
;
	JMP	0		;FORCE WARM BOOT

CARCK3	EQU	$+OFFSET
;
	LDA	4		;REFRESH LOGIN BYTE AGAIN
	ANI	0F0H		;ISOLATE USER #
	CPI	MAX$USER*16+1	;VALID USER #?
	JC	CARCK4		;YES, DON'T CHANGE
	LDA	4		;GET BACK LOGIN BYTE
	ANI	0FH		;KEEP DRIVE, ZERO USER
	STA	4
	CALL	ILPRT		;TELL HIM WHAT HAPPENED
;
	DB	'INVALID USER NUMBER - RETURNING TO 0',0
;
	JMP	0		;FORCE WARM BOOT
;
CARCK4	EQU	$+OFFSET
	ORA	A
	RET
;
;	.1 SEC DELAY ROUTINE
;
DELAY	EQU	$+OFFSET
	PUSH	B
	LXI	B,SPEED*4167 	;TIMING CONSTANT
;
DELAY1	EQU	$+OFFSET
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	DELAY1
	POP	B
	RET
;
;	50 MS DELAY ROUTINE
;
KDELAY	EQU	$+OFFSET
	PUSH	B
	LXI	B,SPEED*2084
	JMP	DELAY1
;
;PATCH IN THE NEW JMP TABLE (SAVING THE OLD)
;
PATCH	EQU	$+OFFSET
	CALL	TBLADDR		;CALC HL= CP/M JMP TABLE
	LXI	D,VCOLDBT	;POINT TO SAVE LOCATION
	MVI	B,18		;ALWAYS SAVE PRINTER VECTOR
	CALL	MOVE		;MOVE IT
;NOW MOVE NEW JMP TABLE TO CP/M
	CALL	TBLADDR		;CALC HL=CP/M'S JMP TABLE
	XCHG			;MOVE TO DE
	LXI	H,NEWJTBL 	;POINT TO NEW
	CALL	MOVE		;MOVE IT
	RET
;
UNPATCH EQU	$+OFFSET
	CALL	TBLADDR 	;HL=CP/M'S JMP TABLE
	XCHG			;MOVE TO DE
	LXI	H,VCOLDBT 	;GET SAVED TABLE
	CALL	MOVE		;MOVE ORIG BACK
	RET			
;
;CALCULATE HL=CP/M'S JUMP TABLE, B=LENGTH
;
TBLADDR EQU	$+OFFSET
	LHLD	1		;GET BIOS POINTER
	DCX	H		;..SKIP
	DCX	H		;..TO
	DCX	H		;..COLD BOOT

	if	printer 	;RETAIN LIST DEVICE?
	MVI	B,15		;DON'T MOVE LISTER JUMP
	else
	MVI	B,18		;BYTES TO MOVE
	endif	;printer

	RET
;
;MOVE (HL) TO (DE), LENGTH IN (B)
;
MOVE	EQU	$+OFFSET
	MOV	A,M		;GET A BYTE
	STAX	D		;PUT AT NEW HOME
	INX	D		;BUMP POINTERS
	INX	H
	DCR	B		;DEC BYTE COUNT
	JNZ	MOVE		;IF MORE, DO IT
	RET			;IF NOT,RETURN
;
;COMMON ROUTINE TO CHECK FOR CARRIER LOST,
;CALLED FROM  CONSOLE OUT
;
CHECK	EQU	$+OFFSET
	CALL	CARCK		;SEE IF CARRIER STILL ON
	RNC			;ALL OK
;CARRIER IS LOST.  TYPE MESSAGE SO LOCAL CONSOLE
;	SHOWS THE REASON
BADPASS EQU	$+OFFSET	;COME HERE ON BAD PASSWORD
	MVI	A,1		;SHOW CARRIER LOST SO
	STA	LOSTFLG		;..WE WON'T CK AGAIN
	LXI	SP,STACK	;ENSURE VALID STACK
	CALL	ILPRT
;
	DB	CR,LF,'++CARRIER LOST++',CR,LF,'   ',0
;
	CALL	UNPATCH		;RESTORE ORIG BIOS JMP TBL
	XRA	A		;CLEAR OUT CARRIER..
	STA	LOSTFLG 	;..LOST FLAG
	JMP	HANGUP
;
;READBYTE ROUTINE - USED TO READ THE
;	WELCOME FILE
;
RDBYTE	EQU	$+OFFSET
	MOV	A,H		;TIME TO READ?
	ORA	A		;..IF AT 100H
	JZ	NORD		;NO READ REQ'D
;HAVE TO READ A SECTOR
	LXI	D,FCB
	MVI	C,READ
	CALL	BDOS
	ORA	A		;OK?
	MVI	A,1AH		;FAKE UP EOF
	RNZ			;RET EOF IF BAD
	LXI	H,80H
NORD	EQU	$+OFFSET
	MOV	A,M		;GET CHAR
	INX	H		;TO NEXT
	RET
;
;KEYBOARD/MODEM STATUS TEST ROUTINE
;
MSTAT	EQU	$+OFFSET
	call	check

	if	dual$io		;WANT LOCAL CONSOLE?
	CALL	CONSTAT 	;GET LOCAL STATUS
	ORA	A
	RNZ			;RET IF LOCAL CHAR
	endif	;dual$io
;

	if	inter3
	mvi	a,modem
	out	user		;Select modem UART
	endif	;inter3

	IN	STATUS		;GET MODEM STATUS
	ANI	GBDAV		;GOT A CHARACTER?
	RZ			;RETURN IF NOT
	IN	STATUS		;GET MODEM STATUS
	ANI	GBFE+GBOE	;CHECK FOR FRAMING AND OVERRUN ERROR
	JZ	MSTAT1		;NO ERROR, CHARACTER IS VALID
	CALL	MRESET		;Reset modem UART errors
	XRA	A		;RETURN FALSE
	RET
;
MSTAT1	EQU	$+OFFSET
	MVI	A,0FFH		;SHOW READY
	ORA	A
	RET
;
MRESET	EQU	$+OFFSET
	IN	DATA		;Swallow questionable character
	IN	CMMD		;Get command byte
	ADI	ERESET		;Clear Overrun & Framing errors
	OUT	CMMD		;Reset UART ERROR
	SUI	ERESET
	OUT	CMMD		;Clear UART reset
	RET
;
;MODEM INPUT FUNCTION, CHECKS LOCAL CONSOLE FIRST
;
MINPUT	EQU	$+OFFSET
;
	if	timeout
	PUSH	H
	LXI	H,TOVALUE*MINUTES ;INITIALIZE TIMEOUT COUNTER
	SHLD	TOCNT
	POP	H
	endif	;timeout
;
MINPUT1 EQU	$+OFFSET
	LDA	LOSTFLG		;KNOWN LOSS..
	ORA	A		;..OF CARRIER?
	CZ	CHECK		;CARRIER STILL ON?
	CALL	MSTAT		;ANYTHING?
	ORA	A

	if	timeout
	JNZ	MINPUT2
	CALL	KDELAY		;KILL 50 MS
	PUSH	H
	LHLD	TOCNT		;KNOCK DOWN TIMEOUT COUNTER
	DCX	H
	SHLD	TOCNT
	MOV	A,H
	ORA	L
	POP	H
	JNZ	MINPUT1 	;STILL TIME LEFT..KEEP TRYING
	CALL	ILPRT
;
	DB	'+++INPUT TIMED OUT+++',7,7,0
;
	JMP	NOSLASH
	else
	JZ	MINPUT		;LOOP TILL CHAR RCD
	endif	;timeout
;
MINPUT2	EQU	$+OFFSET

	if	dual$io		;BOTH LOCAL AND REMOTE
	CALL	CONSTAT 	;CHECK LOCAL CONSOLE
	ORA	A		;CHAR?
	JNZ	CONIN		;..YES, READ IT, RET.
	endif	;dual$io
;
;	LOCAL CONSOLE WASN'T READY, SO READ MODEM
;
	if	inter3
	mvi	a,modem
	out	user		;Select modem UART
	endif	;inter3

	IN	DATA		;GET DATA BYTE
	ANI	7FH		;DELETE PARITY
	JZ	MINPUT		;IGNORE NULLS

	if	imsai and hardlog
	PUSH	B
	MOV	B,A
	IN	SENSE
	ANI	LOGSW
	MOV	A,B
	POP	B
	JZ	NOLOG
	endif	;imsai and hardlog

	if	hardlog
	CPI	20H
	JNC	MINPUT3
	CPI	CR
	JNZ	NOLOG

MINPUT3	EQU	$+OFFSET
	CALL	LISTOUT		;ECHO ON PRINTER
	CPI	CR
	JNZ	NOLOG		;CR NEEDS LINEFEED
	MVI	A,LF
	CALL	LISTOUT		;SO SEND IT
	MVI	A,CR		;GET BACK CR
	endif	;hardlog
;
NOLOG	EQU	$+OFFSET
;
	CPI	3		;IS IT CONTROL-C?
	RNZ			;NO, PASS IT THRU
	LDA	0		;SEE IF WARM BOOT DISABLED
	CPI	0C3H		;JMP MEANS WARM BOOT OK
	MVI	A,3		;SO RETURN CONTROL-C
	RZ
	XRA	A		;ELSE CONVERT TO NULL
	RET
;
MOUTPUT EQU	$+OFFSET
;IF WE ALREADY KNOW CARRIER IS LOST,
;DON'T CHECK FOR IT AGAIN
	LDA	LOSTFLG		;KNOWN LOSS OF CARRIER?
	ORA	A
	jnz	silent		;avoid loop in case carrier lost
	call	CHECK		;CARRIER STILL ON?

	if	inter3
	mvi	a,modem
	out	user		;Select modem UART
	endif	;inter3

	IN	STATUS		;GET MODEM STATUS
	ANI	GBTBMT		;TRANSMIT REGISTER EMPTY?
	JZ	MOUTPUT		;LOOP IF NOT READY

	if	imsai and blackout and dual$io
	IN	SENSE		;FLIP SWITCH UP...
	ANI	BLACKSW 	;..TO BLIND REMOTE USER
	JNZ	SILENT
	endif	;imsai and blckout and dual$io

	MOV	A,C		;GET CHAR
	ANI	7FH
;
	if	ck$lwc
	CPI	60H		;CHECK FOR LOWER CASE
	JC	MOUTP2		;SKIP IF NOT LC
	CPI	7FH		;CHECK FOR RUBOUT
	JZ	MOUTP2
	PUSH	H
	LXI	H,ULCSW		;SUBTRACT EITHER 20H OR 0
	SUB	M
	POP	H
	MOV	C,A		;FORCE ON LOCAL AS WELL AS REMOTE
MOUTP2	EQU	$+OFFSET
	endif	;ck$lwc
;
	OUT	DATA		;OUTPUT TO MODEM

SILENT	EQU	$+OFFSET
;
	if	dual$io		;TO LOCAL ALSO?
	push	psw
	CALL	CONOUT		;SEND TO REGULAR BIOS
	pop	psw
	endif	;dual$io
;
;CHECK FOR NULLS
;
	CPI	LF		;TIME FOR NULLS?
	RNZ			;NO, RETURN
;SEND NULLS IF REQUIRED
	LDA	NULLS		;GET COUNT
	ORA	A		;ANY?
	RZ			;..NO
	PUSH	B
	MOV	B,A		;SAVE COUNT
	MVI	C,0		;0 IS A NULL
NULLP	EQU	$+OFFSET
	CALL	MOUTPUT 	;TYPE A NULL
	DCR	B		;MORE?
	JNZ	NULLP		;..YES, LOOP
	POP	B
	RET
;
;	BOOT TRAP-BECOMES DISCONNECT IF
;	JMP AT 0 HAS BEEN ALTERED
;
MBOOT	EQU	$+OFFSET
	LDA	0		;LOOK AT OPCODE
	CPI	0C3H		;IS IT STILL JMP?
	JZ	VWARMBT		;YES, ALLOW IT
	JMP	NOSLASH		;NO, DISCONNECT
;
;	INLINE PRINT ROUTINE
;	CALL ILPRT
;	DB	'MSG',0
;
ILPRT	EQU	$+OFFSET
	XTHL			;SAVE HL, GET MSG
	PUSH	B		;SAVE

ILPLP	EQU	$+OFFSET
	MOV	C,M		;GET CHAR
	CALL	MOUTPUT		;OUTPUT IT
	INX	H		;POINT TO NEXT
	MOV	A,M		;TEST
	ORA	A		;..FOR END
	JNZ	ILPLP
	POP	B		;RESTORE
	XTHL			;RESTORE HL, RET ADDR
	RET			;RET PAST MSG
;
	IF	pwrqd		;KEEP PASSWORD HERE
;ACCESS PASSWORD (ENDS IN C/R)
;
PASSWD	EQU	$+OFFSET
	DB	'PLAUGER'	;THE PASSWORD ITSELF
	DB	CR		;END OF PASSWORD
;ALLOW ROOM FOR BIGGER PASSWORD TO BE
;	PATCHED IN
	DB	0,0,0,0,0,0,0,0,0,0,0
	endif	;pwrqd
;
;	ROUTINE TO LOAD THE COM FILE
;
	if	comfile
LODCOM	EQU	$+OFFSET
	XRA	A		;INITIALIZE FCB
	STA	COMFCB
	LXI	H,COMFCB+12
	MVI	B,21
ZLOOP	EQU	$+OFFSET
	MVI	M,0
	INX	H
	DCR	B
	JNZ	ZLOOP

	MVI	C,OPEN		;NOW OPEN THE FILE
	LXI	D,COMFCB
	CALL	BDOS
	INR	A		;SHOULD BE NON-ZERO
	JZ	ABORT		;NO FILE, ABORT
;
;	NOW LOAD THE FILE
;
	LHLD	6		;GET TOP OF MEMORY
	LXI	D,-80H		;RECORD LOADS CAN'T START..
	DAD	D		;..ABOVE (BDOS) - 80H
	PUSH	H		;SAVE ON STACK
;
	LXI	D,80H		;TPA-80H
	LXI	B,0		;KEEP A RECORD COUNTER
	PUSH	B		;SAVE COUNTER
	PUSH	D		;AND LOAD ADDRESS
GLOOP	EQU	$+OFFSET
	POP	D		;GET TPA ADRS
	LXI	H,80H		;POINT TO NXT ADRS TO READ TO
	DAD	D		;HL HAS THE ADDRESS
	POP	B		;INCREMENT THE COUNTER
;
;	CHECK FOR LOAD PAST TOP-OF-MEMORY
;
	POP	D		;GET -(TOP-OF-MEMORY)
	PUSH	D		;RE-SAVE FOR NEXT TIME
;
	MOV	A,E		;SUBTRACT: (TOP) - (ADRS)
	SUB	L
	MOV	A,D		;ONLY THE CARRY NEEDED
	SBB	H
;
	JNC	SIZEOK		;CY= BETTER MOVCPM
	CALL	ERRXIT		;SO TELL THE STORY
;
	DB	'++ PROGRAM AREA TOO SMALL ++','$'
;;
SIZEOK	EQU	$+OFFSET
	INX	B
	PUSH	B
	PUSH	H		;SAVE TPA ADRS
	XCHG			;ALIGN REGISTERS
	MVI	C,STDMA		;TELL BDOS WHERE TO PUT RECORD
	CALL	BDOS
	LXI	D,COMFCB	;NOW READ THE RECORD
	MVI	C,READ
	CALL	BDOS
	ORA	A
	JZ	GLOOP		;A=0 IF MORE TO READ
	POP	B		;UNJUNK STACK
	POP	B		;THIS IS OUR COUNTER
	POP	H		;MORE JUNK ON STACK
	MOV	A,B		;CHECK FOR ZERO
	ORA	C
	JZ	ABORT		;WE SHOULD HAVE READ SOMETHING
	LXI	D,80H		;WE DID, RESET DMA TO 80H
	MVI	C,STDMA
	CALL	BDOS
	CALL	LOADOK		;PRINT THIS MSG TO CONSOLE:
;
	DB	'++ COM FILE LOADED ++',CR,LF,'$'
;
LOADOK	EQU	$+OFFSET
	POP	D
	LDA	OPTION		;SEE IF THIS WAS "BYE /C"
	CPI	'C'		;IF IT WAS THEN..
	RZ			;..DON'T PRINT MESSAGE
	MVI	C,PRINTF
	CALL	BDOS
	RET
;
ABORT	EQU	$+OFFSET
	CALL	ERRXIT
;
	DB	CR,LF,'+++CANNOT FIND COM FILE.+++','$'
;
ERRXIT	EQU	$+OFFSET
	POP	D
	MVI	C,PRINTF
	CALL	BDOS		;PRINT THE ABORT MSG
	JMP	0		;GIVE UP
	endif	;comfile

;
;THIS AREA IS USED FOR VECTORING CALLS TO THE
;USER'S CBIOS, BUT SAVING THE REGISTERS FIRST
;IN CASE THEY ARE DESTROYED.
;
CONSTAT EQU	$+OFFSET
	PUSH	B
	PUSH	D
	PUSH	H
	CALL	VCONSTAT
	POP	H
	POP	D
	POP	B
	RET
;
CONIN	EQU	$+OFFSET
	PUSH	B
	PUSH	D
	PUSH	H
	CALL	VCONIN

	if	fkeys
	CALL	CKFUNC
	endif	;fkeys

	POP	H
	POP	D
	POP	B
	RET
;
CKFUNC	EQU	$+OFFSET
;
	if	fkeys and imsai
	PUSH	B
	MOV	B,A		;SAVE CHAR
	IN	SENSE		;READ THE SWITCHES
	ANI	ENABLF		;CHECK FKEY ENAB SW
	MOV	A,B
	POP	B
	RZ			;NO FUNCT IF SW OFF
	endif	;fkeys and imsai
;
	if	fkeys
	CPI	SYSDKEY
	JZ	SYSDOWN 	;TELL CALLER TO LEAVE
	CPI	TWITKEY
	JZ	GOODBY		;MAKE CALLER LEAVE
	CPI	MSGKEY
	RNZ
	CALL	ILPRT		;SEND CALLER A MESSAGE
;
	DB	'MESSAGE FROM OPERATOR:',0
;
	MVI	A,' '		;SOMETHING TO RETURN WITH
	RET
;
SYSDOWN EQU	$+OFFSET
	CALL	ILPRT
;
	DB	'SYSTEM DOWN IN'
	DB	' 5 MINUTES....',0
;
	MVI	A,' '
	RET
	endif	;fkeys
;
CONOUT	EQU	$+OFFSET
	PUSH	B
	PUSH	D
	PUSH	H
	CALL	VCONOUT
	POP	H
	POP	D
	POP	B
	RET
;
LISTOUT	EQU	$+OFFSET
	PUSH	B
	PUSH	D
	PUSH	H
	PUSH	PSW
	MOV	C,A
	CALL	VLISTOUT
	POP	PSW
	POP	H
	POP	D
	POP	B
	RET
;
;
;
;	THIS IS THE JMP TABLE WHICH IS COPIED
;	ON TOP OF THE ONE POINTED TO BY
;	LOCATION 1 IN CP/M
;
NEWJTBL EQU	$+OFFSET
	JMP	MCBOOT		;COLD BOOT
	JMP	MBOOT		;WARM BOOT
	JMP	MSTAT		;MODEM STATUS TEST
	JMP	MINPUT		;MODEM INPUT ROUTINE
	JMP	MOUTPUT 	;MODEM OUTPUT ROUTINE
	RET			;DUMMY LIST DEVICE
	NOP
	NOP
;
	if	motor
;
DSKON	EQU	$+OFFSET
	PUSH	PSW		;SAVE THE A AND FLAGS
	MVI	A,DISKON	;VALUE TO TURN ON MOTORS
	OUT	DISK		;TO THE DISK CONTROLLER
	PUSH	H		;THIS IS TIMER
	LXI	H,0		;THIS LONG
DSKLP	EQU	$+OFFSET
	XTHL
	XTHL
	DCX	H		;COUNT LOOP
	MOV	A,H		;CHECK FOR DONE
	ORA	L
	JNZ	DSKLP
	POP	H		;RESTORE HL
	POP	PSW		;AND A & FLAGS
	RET
;
DSKOFF	EQU	$+OFFSET
	PUSH	PSW		;SAVE A & FLAG
	MVI	A,DISKOFF	;VALUE TO TURN MOTORS OFF
	OUT	DISK
	POP	PSW
	RET
;
	endif	;motor
;
	if	rtc
CLKBASE	EQU	50H		;BASE OF SYSTEM SUPPORT 1 CARD
CLKCTL	EQU	CLKBASE+10	;CLOCK CONTROL PORT
CLKDATA	EQU	CLKBASE+11	;CLOCK DATA PORT
CREAD	EQU	10H+40H		;READ COMMAND + HOLD COUNT COMMAND
;
TIME	EQU	$+OFFSET
	PUSH	H
	PUSH	D
	PUSH	B
	PUSH	PSW
	MVI	D,CREAD+5	;POINT TO 10s OF HOURS
	MVI	B,3		;3 LOOPS
	JMP	TX		;START W/ NO SEPARATOR
;
T1	EQU	$+OFFSET
	MVI	C,':'		;SEPARATOR
	CALL	MOUTPUT		;TO THE PRINTER
TX	EQU	$+OFFSET
	MOV	A,D		;GET THE DIGIT ADDRESS
	CALL	CLOCK		;GET THE VALUE
	MOV	C,A		;SAVE IT
	MVI	A,CREAD+5	;TEST FOR FIRST LOOP
	CMP	D		;1ST LOOP?
	MOV	A,C		;RECOVER THE VALUE
	JNZ	T2		;JUMP IF NOT 1ST LOOP
	ANI	3		;DROP PM INDICATOR
T2	EQU	$+OFFSET
	ADI	'0'		;ADD ASCII BIAS
	MOV	C,A
	CALL	MOUTPUT		;AND PRINT IT
	DCR	D		;POINT TO NEXT DIGIT
	MOV	A,D		;GET THE DIGIT ADDRESS TO A
	CALL	PCLOCK		;GET & PRINT ASCII
	DCR	D		;BUMP DIGIT COUNTER
	DCR	B
	JNZ	T1		;LOOP TILL ALL PRINTED
;
;
	CALL	ILPRT		;PRINT THE TIME ZONE
;
	DB	' EST ',0 	;Australian EST
;
; WE WILL NOW PRINT THE DAY OF THE WEEK, FOLLOWED
; BY THE MONTH, DATE AND YEAR
;
;
	MVI	A,CREAD+6		;THIS IS DAY OF WEEK 
	CALL CLOCK		;GET THE DAY NUMBER
;
DAYDONE	EQU	$+OFFSET
	ADD	A		;DOUBLE DAY COUNT
	LXI	H,DAYS		;POINT TO TABLE
	MOV	E,A		;ADD OFFSET TO DE
	MVI	D,0
	DAD	D		;NEW POINTER IN HL
	MOV	A,M		;GET LO BYTE OF WORD
	INX	H		;POINT TO HI BYTE
	MOV	H,M		;TO H
	MOV	L,A		;PLUS LO BYTE POINTS TO STRING
	CALL	LINOUT		;PRINT THE DAY
;
	MVI	A,CREAD+10	;10s OF MONTHS
	CALL	CLOCK
	ORA	A		;WE GOT 10's OF MONTHS?
	JZ	NOTENS		;JUMP IF NOT
	MVI	A,10		;ADD 10s IF WE GOT EM
NOTENS	EQU	$+OFFSET
	MOV	B,A		;SAVE 10s IN B
	MVI	A,CREAD+9	;GET THE ONES
	CALL	CLOCK
	ADD	B		;ADD TO THE 10s PLACE TO GET MONTH
	DCR	A		;CORRECT FOR JAN=1
	ADD	A		;DOUBLE MONTH NUMBER
	LXI	H,MONTHS	;POINT TO DISPATCH TABLE
	MOV	E,A		;OFF SET TO DE
	MVI	D,0
	DAD	D		;POINTER TO STRING AT (HL)
	MOV	A,M		;GET LO BYTE TO A
	INX	H		;POINT TO NEXT
	MOV	H,M		;HI BYTE TO H
	MOV	L,A		;LO BYTE TO L POINTS TO STRING
	CALL	LINOUT		;PRINT THE MONTH
;
	MVI	A,CREAD+8	;10s OF DAYS
	CALL	CLOCK
	ANI	3		;DROP LEAP YEAR INDICATOR
	JZ	NTENS		;JUMP IF NO TENS PLACE
	CALL	PASC		;PRINT IT
NTENS	EQU	$+OFFSET
	MVI	A,CREAD+7	;ONES OF DAYS
	CALL	PCLOCK		;PRINT THEM
	LXI	H,YEAR		;PLUS YEAR MESSAGE
	CALL	LINOUT		;TO LISTER
	MVI	A,CREAD+12	;TENS OF YEAR
	CALL	PCLOCK		;PRINT THEM
	MVI	A,CREAD+11	;ONES OF YEAR
	CALL	PCLOCK
	CALL	ILPRT		;FINISH THE LINE
;
	DB	CR,LF,0
;
	POP	PSW
	POP	B
	POP	D
	POP	H
	RET
;
PCLOCK	EQU	$+OFFSET
	CALL	CLOCK		;GET THE DIGIT
PASC	EQU	$+OFFSET
	ADI	'0'		;ADD ASCII BIAS
	MOV	C,A
	JMP	MOUTPUT		;AND PRINT
;
CLOCK	EQU	$+OFFSET
	OUT	CLKCTL		;TELL IT ADDRESS
	IN	CLKDATA		;GET THE DATA NYBBLE
	PUSH	PSW		;SAVE THE DATA
	XRA	A		;GET 0
	OUT	CLKCTL		;RESET HOLD BIT
	POP	PSW		;RESTORE DATA
	RET
;
LINOUT	EQU	$+OFFSET
	MOV	A,M		;GET THE CHARACTER
	CPI	'$'		;DONE?
	RZ			;RETURN IF DONE
	MOV	C,A		;ELSE PRINT IT
	CALL	MOUTPUT
	INX	H		;POINT TO NEXT CHARACTER
	JMP	LINOUT		;THEN LOOP TILL DONE
;
;
SUN	EQU	$+OFFSET
	DB	'Sunday, $'
MON	EQU	$+OFFSET
	DB	'Monday, $'
TUE	EQU	$+OFFSET
	DB	'Tuesday, $'
WED	EQU	$+OFFSET
	DB	'Wednesday, $'
THU	EQU	$+OFFSET
	DB	'Thursday, $'
FRI	EQU	$+OFFSET
	DB	'Friday, $'
SAT	EQU	$+OFFSET
	DB	'Saturday, $'
;
JAN	EQU	$+OFFSET
	DB	'January $'
FEB	EQU	$+OFFSET
	DB	'February $'
MAR	EQU	$+OFFSET
	DB	'March $'
APR	EQU	$+OFFSET
	DB	'April $'
MAY	EQU	$+OFFSET
	DB	'May $'
JUN	EQU	$+OFFSET
	DB	'June $'
JUL	EQU	$+OFFSET
	DB	'July $'
AUG	EQU	$+OFFSET
	DB	'August $'
SEP	EQU	$+OFFSET
	DB	'September $'
OCT	EQU	$+OFFSET
	DB	'October $'
NOV	EQU	$+OFFSET
	DB	'November $'
DEC	EQU	$+OFFSET
	DB	'December $'
;
YEAR	EQU	$+OFFSET
	DB	', 19$'
;
;#################################################
DAYS	EQU	$+OFFSET
	DW	SUN
	DW	MON
	DW	TUE
	DW	WED
	DW	THU
	DW	FRI
	DW	SAT
	DW	SUN
;
MONTHS	EQU	$+OFFSET
	DW	JAN
	DW	FEB
	DW	MAR
	DW	APR
	DW	MAY
	DW	JUN
	DW	JUL
	DW	AUG
	DW	SEP
	DW	OCT
	DW	NOV
	DW	DEC
;
;
	endif	;RTC
;
WELFILN EQU	$+OFFSET
	DB	0,'STARTUP    ',0
;WELCOME FILE NAME ^^^^^^^^^^^
;
NULLS	EQU	$+OFFSET
	DB	5
;
COMFCB	EQU	$+OFFSET
	DB	0,'ENTRBBS COM'
;COM FILE NAME     ^^^^^^^^^^^
PEND	EQU	$+OFFSET	 ;END OF RELOCATED CODE
;
;	THESE AREAS ARE NOT INITIALIZED
;
	DS	21		;REST OF COM FCB
ULCSW	EQU	$+OFFSET
	DS	1
OPTION	EQU	$+OFFSET
	DS	1
TOCNT	EQU	$+OFFSET
	DS	2
;
;
;KEEP TRACK OF LOST CARRIER WHEN TYPING
;"++CARRIER LOST++" SO WE DON'T LOOP
;
LOSTFLG EQU	$+OFFSET
	DS	1
DROPOUT	EQU	$+OFFSET
	DS	1
;
;SAVE THE CP/M JUMP TABLE HERE
;
VCOLDBT EQU	$+OFFSET
	DS	3
VWARMBT EQU	$+OFFSET
	DS	3
VCONSTAT EQU	$+OFFSET
	 DS	3
VCONIN	 EQU	$+OFFSET
	 DS	3
VCONOUT  EQU	$+OFFSET
	 DS	3
VLISTOUT EQU	$+OFFSET
	 DS	3
;
;	SINCE THESE AREAS ARE NOT INITIALIZED,
;	THE FOLLOWING COUNTERS WILL NOT BE CHANGED
;	BY SUBSEQUENT LOADS OF THIS PROGRAM
;
	if	usrlog
OLDUSR	EQU	$+OFFSET
	DS	2
NEWUSR	EQU	$+OFFSET
	DS	2
NONUSR	EQU	$+OFFSET
	DS	2
	endif
;
;
	DS	60
STACK	EQU	$+OFFSET	;LOCAL STACK
;
CI	EQU	1
WRCON	EQU	2
OPEN	EQU	15
READ	EQU	20
STDMA	EQU	26
PRINTF	EQU	9
DIRECTIO EQU	6
CSTS	EQU	11
CI	EQU	1
FCB	EQU	5CH 
FCBRNO	EQU	FCB+32
;
	END
