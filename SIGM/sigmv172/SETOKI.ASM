
TITLE 'SETOKI.ASM'

************************************************************
*                                                          *
*  SETOKI is a menu-driven utility to set printer options  *
*  for the Okidata Microline 92 printer.   This program    *
*  is derived from the October 1983 Microsystems article   *
*  "Write a Menu-Driven Utility to Set Printer Options"    *
*  written by Robert L. LaFara of Castle Oaks Computer     *
*  Services, Indianapolis, IN.  Assemble with MAC or ASM.  *                  
*                                                          *
*  ------------------------------------------------------  *
*                                                          *
*  Version 1.1 by David J. Raibert, December 3, 1983       *
*  Version 1.2 by Steve Leon, 02/12/84 for Okidata         *
************************************************************

		;SET EQUATES FOR CP/M BDOS FUNCTION & CALLS

CONOUT  EQU  2		;OUTPUT TO CONSOLE
BDOS    EQU  5          
LSTOUT  EQU  5          ;OUTPUT TO THE LST: DEVICE
CONDIR  EQU  6          ;DIRECT INPUT FROM THE CONSOLE
PRTSTR  EQU  9          ;OUTPUT A STRING TO THE CONSOLE

		;SET EQUATES FOR CONTROL CODE   
                ;(NON ESCAPE SEQUENCE) OUTPUTS

LF      EQU  8AH        ;LINE FEED
TOF     EQU  0CH        ;FORM FEED       
CR	EQU  0DH        ;CARRIAGE RETURN
ESC     EQU  1BH        ;ESCAPE CHARACTER                  
RS      EQU  1EH        ;10 CPI
FS      EQU  1CH        ;12 CPI
GS      EQU  1DH        ;17 CPI
US      EQU  1FH        ;DOUBLE WIDTH

        ORG  100H
        LXI  SP,STACK   ;SET STACK COUNTER

		;PRINT THE MENU

MENU:   MVI  C,PRTSTR   ;PREPARE BDOS TO OUTPUT MENU STRING
        LXI  D,MENDAT   ;POINT TO BEGINNING OF MENU STRING
        CALL BDOS       ;PRINT THE MENU STRING

		;INPUT THE CHARACTER FROM THE MENU
		;STORE IT, ECHO IT TO CONSOLE

CHARIN: MVI  C,CONDIR   ;PREPARE BDOS
        MVI  E,0FFH     ; FOR DIRECT CON-
        CALL BDOS       ;  SOLE INPUT
        CPI  0          ;CHARACTER RECEIVED?
        JZ   CHARIN     ;IF NOT, LOOP BACK AND TRY AGAIN
	STA  CHAR	;SAVE IT FOR LATER    
        MVI  C,CONOUT   ;ECHO 
        MOV  E,A        ; IT TO
        CALL BDOS       ;  CONSOLE
		
		;TEST FOR MENU OPTION SELECTED & JUMP TO ES-
		;CAPE OR CONTROL CODE. OTHER CHARACTERS CAN
                ;BE USED IF < + ^ > OR @ ARE NOT AVAILABLE

        LDA  CHAR       ;GET OPTION CHARACTER STORED AT CHAR:

        CPI  '6'        ;6 LINES PER INCH
        JZ   V6
        CPI  '8'        ;8 LINES PER INCH
        JZ   V8
        CPI  '1'        ;10 CPI              
        JZ   LARGE   
        CPI  '2'        ;12 CPI             
        JZ   MED
        CPI  '7'        ;17 CPI
        JZ   SMALL
	CPI  '^'	;CANCEL UNDERLINE
	JZ   VM
        CPI  'F'        ;FORM FEED
        JZ   FMFD
        CPI  'L'        ;LINE FEED
        JZ   LINEF
        CPI  'W'        ;DOUBLE WIDTH
        JZ   DBLE
        CPI  '-'        ;SUBSCRIPT
        JZ   V9
        CPI  '+'        ;SUPERSCRIPT
        JZ   V0
        CPI  'C'        ;CORRESPONDENCE QUALITY
        JZ   VS
        CPI  'R'        ;CANCEL CORRESPONDENCE QUALITY
        JZ   VR
        CPI  'E'        ;EMPHASIZED
        JZ   V9
        CPI  'N'        ;ENHANCED
        JZ   V0
        CPI  'Z'        ;CANCEL EMPHASIZED & ENHANCED
        JZ   VZ
	CPI  'U'	;UNDERLINE
	JZ   VU                                         
        CPI  'Q'        ;QUIT
        JZ   QUIT
        CPI  'T'        ;TEST
        JZ   TEST

		;PRINT ERROR MESSAGE

        MVI  C,PRTSTR   ;PREPARE BDOS TO OUTPUT THE ERROR
			;MESSAGE STRING
        LXI  D,ERRMSG   ;POINT TO ERROR MESSAGE
        CALL BDOS       ;PRINT IT AND
        JMP  MENU       ; GO BACK TO MENU

		;STORE ESCAPE CODES FOR PROCESSING AT 
		;LABEL VERT:, JUMP TO SET UP ESCAPE STRING.
		;NOTE THAT SINCE ESCAPE CODES ARE VARIABLE
		;IN LENGTH, E. G. [ESC 'T'][ESC 'A'18],
		;SINGLE ESCAPE CODES ARE PADDED WITH A '$'.

V6:     MVI  A,'6'	;ESC '6' 
        MVI  B,'$'	;RESET TO 6 LINES PER INCH
        JMP  VERT
V8:     MVI  A,'8'	;ESC 'A'  
        MVI  B,'$'	;SET FOR 8 LINES PER INCH
        JMP  VERT
V9:     MVI  A,'J'	;ESC 'J'  
        MVI  B,'$'      ;SET SUPERSCRIPT, CANCEL SUBSCRIPT
        JMP  VERT
V0:     MVI  A,'L'	;ESC 'L'  
        MVI  B,'$'      ;SET SUBSCRIPT, CANCEL SUPER 
        JMP  VERT
VU:     MVI  A,'C'	;ESC 'C'
        MVI  B,'$'	;UNDERLINE
        JMP  VERT
VM:     MVI  A,'D'	;ESC 'D'
        MVI  B,'$'	;CANCEL UNDERLINE
        JMP  VERT
VS:     MVI  A,'1'	;ESC '1'  
        MVI  B,'$'      ;CORRESPONDENCE QUALITY
        JMP  VERT
VR:     MVI  A,'0'	;ESC '0'
        MVI  B,'$'	;CANCEL CORRESPONDENCE QUALITY    
        JMP  VERT
VE:     MVI  A,'T'	;ESC 'T'
        MVI  B,'$'	;EMPHASIZED
        JMP  VERT
VF:     MVI  A,'H'	;ESC 'H'
        MVI  B,'$'	;ENHANCED  
        JMP  VERT
VZ:     MVI  A,'I'	;ESC 'I'
        MVI  B,'$'	;CANCEL EMPHASIZED & ENHANCED
        JMP  VERT

		;STORE ESCAPE SEQUENCE CODE CHARACTERS AT
		;LABEL VSTR: FOR LATER OUTPUT THRU TEST1

VERT:   STA  VSTR+1     ;STORE 1st ESCAPE CHARACTER
			;ESC (1BH) IS PROVIDED AT VSTR + 0
        MOV  A,B        ;STORE 2nd CHARACTER OR THE
        STA  VSTR+2     ; PADDING '$' TERMINATOR     
	MVI  A,'$'	;HERE IS THE OTHER '$' YOU MAY NEED 
	STA  VSTR+3	; TERMINATE THE ESCAPE STRING 
        LXI  H,VSTR     ;SET PC TO ESCAPE SEQUENCE STRING
        JMP  TEST1      ;TEST FOR CHARACTERS & TERMINATOR

		;SET  UP CONTROL CODES FOR OUTPUT

LARGE:  MVI  E,RS       ;10 CPI    
        JMP  OUTPUT
MED:    MVI  E,FS       ;12 CPI    
        JMP  OUTPUT
SMALL:  MVI  E,GS       ;17 CPI    
        JMP  OUTPUT
LINEF:  MVI  E,LF       ;LINE FEED
        JMP  OUTPUT
FMFD:   MVI  E,TOF      ;FORM FEED
        JMP  OUTPUT
DBLE:   MVI  E,US       ;DOUBLE WIDTH
        JMP  OUTPUT

		;OUTPUT CONTROL CODES TO PRINTER

OUTPUT: MVI  C,LSTOUT   ;PREPARE BDOS TO OUTPUT TO LST:
        CALL BDOS       ; MOVE CHARACTER OUT TO PRINTER
        MVI  E,CR       ;DUMP THE PRINTER
        CALL BDOS       ; BUFFER (EMPTY IT WITH <CR>)
        JMP  MENU       ;GO BACK TO THE MENU FOR ANOTHER

TEST:   LXI  H,TSTR     ;POINT TO THE BEGINNING OF THE   
			;PRINTER TEST STRING

		;THE ESCAPE CODES ARE PROCESSED HERE

TEST1:  SHLD INDEX      ;STORE THE V-STRING ADDRESS INTO STORAGE
        MOV  E,M        ;PUT CHARACTER TO PRINT INTO E FOR OUTPUT
        MOV  A,E        ;MOVE CHAR INTO REG 'A' TO LOOK FOR '$'
        CPI  '$'        ;IS IT STRING TERMINATOR '$'?
        JZ   MENU       ;IF SO, END TEST AND GOTO MENU
        MVI  C,LSTOUT   ;PRINT
        CALL BDOS       ; CHARACTER
        LHLD INDEX      ;GO BACK TO STORAGE FOR STRING ADDRESS
        INX  H          ;INCREMENT PC TO NEXT CHARACTER
        JMP  TEST1      ;PRINT IT

QUIT:   MVI  C,0        ;BACK TO
        CALL BDOS       ; OPERATING SYSTEM

		;SET UP MENU TABLE AND STRING OUTPUT DATA

MENDAT  DB   CR,LF,'                       PRINTER OPTIONS MENU',CR,LF   
        DB   '                FOR OKIDATA MICROLINE 92 PRINTER',CR,LF,LF,LF
        DB   '           1 = 10 CPI         2 = 12 CPI    7 = 17 CPI        ',CR,LF,LF
        DB   '           W = DOUBLE WIDTH                         ',CR,LF
        DB   '           8 = EIGHT LINES PER INCH         6 = SIX PER INCH',CR,LF   
        DB   '           F = FORM FEED                    L = LINE FEED',CR,LF,LF
        DB   '                                            TO CANCEL OPTION',CR,LF
        DB   '           C = CORRESPONDENCE QUALITY              R',CR,LF
        DB   '           E = EMPHASIZED                          Z',CR,LF       
        DB   '           N = ENHANCED                            Z',CR,LF
        DB   '           - = SUBSCRIPT                           +',CR,LF
        DB   '           + = SUPERSCRIPT                         -',CR,LF
	DB   '           U = UNDERLINE                           ^',CR,LF,LF
        DB   '           T = TEST PRINTER                 Q = QUIT',CR,LF,LF    
        DB   '     ENTER OPTION  ','$'

ERRMSG: DB   CR,LF,'         NO SUCH OPTION - TRY AGAIN!'
	DB   CR,LF,'$'

VSTR:   DB   ESC 	;PROVIDE THE 1B HEX CHARACTER HERE
        DS   3          ;RESERVE SPACE FOR THE NEXT 2 OR 3

TSTR:   DB   CR,LF,'ABCDEFGHIJKLMNOPQRSTUVWXYZ',CR,LF
        DB   'abcdefghijklmnopqrstuvwxyz',CR,LF
        DB   '1234567890-=`!@#%^&*()_+~',CR,LF
        DB   '[]\|/;:''"{},.?<>',CR,LF,'$'
			
		;RESERVE MEMORY FOR DATA AND STACK	

CHAR:   DS   1		;RESERVE MEMORY FOR INPUT 
			;OF THE OPTION CHARACTER 
INDEX:  DS   2		;RESERVE MEMORY FOR "VSTR"     
			;ADRESS WHEN STORED AT TEST1
        DS   32         ;DEFINE STACK - 16 LEVEL
STACK:                  ;TOP OF STACK
        END
....................................................................

;David J. Raibert, CPA   D J Raibert & Associates, PA
;10 Wilsey Square, Ridgewood, NJ  07450
