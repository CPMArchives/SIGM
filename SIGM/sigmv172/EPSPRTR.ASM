
TITLE 'EPSPRTR.ASM'

************************************************************
*                                                          *
*  EPSPRTR is a menu-driven utility to set printer op-     *
*  tions for MX printers with Graftrax +.  This program    *
*  is derived from the October 1983 Microsystems article   *
*  "Write a Menu-Driven Utility to Set Printer Options"    *
*  written by Robert L. LaFara of Castle Oaks Computer     *
*  Services, Indianapolis, IN.  Assemble with MAC or ASM.  *                  
*                                                          *
*  ------------------------------------------------------  *
*                                                          *
*  Version 1.1 by David J. Raibert, December 3, 1983       *
*							   *
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
SI      EQU  8FH        ;COMPRESSED PRINT
DC2	EQU  92H	;TURN OFF COMPRESSED PRINT
ESC     EQU  1BH        ;ESCAPE CHARACTER                  

		;INITIALIZE PROGRAM & SET STACK COUNTER

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

        CPI  '3'        ;3 LINES PER INCH
        JZ   V3
        CPI  '4'        ;4 LINES PER INCH
        JZ   V4
        CPI  '6'        ;6 LINES PER INCH
        JZ   V6
        CPI  '8'        ;8 LINES PER INCH
        JZ   V8

        CPI  '>'        ;CANCEL COMPRESSED
        JZ   CANCEL
        CPI  '<'        ;CANCEL DOUBLE WIDTH
        JZ   VV
	CPI  '^'	;CANCEL UNDERLINE
	JZ   VM
	CPI  '@'	;RESET TO POWER UP INCL TOF
	JZ   V@
	CPI  '+'	;CANCEL UNIDIRECTIONAL
	JZ   VB

        ANI  5FH        ;DISCARD LOWER CASE BIT
        CPI  'F'        ;FORM FEED
        JZ   FMFD
        CPI  'K'        ;SKIP OVER PERF
        JZ   VK
        CPI  'L'        ;LINE FEED
        JZ   LINEF
        
        CPI  'C'        ;COMPRESSED PRINT 
        JZ   CPRD
        CPI  'W'        ;DOUBLE WIDTH
        JZ   VW
		
		;DO NOT IMPLEMENT ITALICS OR SUBSCRIPT IF
                ; GRAFTRAX+ IS NOT INSTALLED IN THE PRINTER

        CPI  'I'        ;ITALICS
        JZ   VI
        CPI  'J'        ;CANCEL ITALICS
        JZ   VJ
        CPI  'S'        ;SUBSCRIPT 
        JZ   VS
        CPI  'R'        ;CANCEL SUBSCRIPT
        JZ   VR
        CPI  'D'        ;DOUBLESTRIKE
        JZ   VD
        CPI  'H'        ;CANCEL DOUBLESTRIKE & SUBSCRIPT
        JZ   VH
        CPI  'E'        ;EMPHASIZED
        JZ   VE
        CPI  'Z'        ;CANCEL EMPHASIZED
        JZ   VZ
	CPI  'U'	;UNDERLINE
	JZ   VU                                         
	CPI  'V'	;UNIDIRECTIONAL
	JZ   VA

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

V3:     MVI  A,'A'      ;ESC 'A' 24 (/72nds)
        MVI  B,24	;3 LINES PER INCH
        JMP  VERT
V4:     MVI  A,'A'      ;ESC 'A' 18 (/72nds)
        MVI  B,18	;4 LINES PER INCH
        JMP  VERT
V6:     MVI  A,'2'	;ESC '2' 
        MVI  B,'$'	;RESET TO 6 LINES PER INCH
        JMP  VERT
V8:     MVI  A,'0'	;ESC 'A' 0
        MVI  B,'$'	;SET FOR 8 LINES PER INCH
        JMP  VERT

VK:     MVI  A,'N'	;ESC 'N' 6
        MVI  B,06	;SET SKIP OVER PERF - 6 LINES
        JMP  VERT

VI:     MVI  A,'4'	;ESC '4'
        MVI  B,'$'	;ITALICS
        JMP  VERT
VJ:     MVI  A,'5'	;ESC '5'
        MVI  B,'$'	;CANCEL ITALICS
        JMP  VERT
VS:     MVI  A,'S'	;ESC 'S' 1
        MVI  B,01	;SUBSCRIPT
        JMP  VERT
VR:     MVI  A,'T'	;ESC 'T'
        MVI  B,'$'	;CANCEL SUBSCRIPT & UNIDIRECTIONAL
        JMP  VERT
VW:     MVI  A,'W'	;ESC 'W' 1
        MVI  B,01	;DOUBLE WIDTH
        JMP  VERT
VV:     MVI  A,'W'	;ESC 'W' 0
        MVI  B,00	;CANCEL DOUBLE WIDTH
        JMP  VERT
VD:     MVI  A,'G'	;ESC 'G'
        MVI  B,'$'	;DOUBLESTRIKE
        JMP  VERT
VH:     MVI  A,'H'	;ESC 'H'
        MVI  B,'$'	;CANCEL DOUBLESTRIKE & SUBSCRIPT
        JMP  VERT
VE:     MVI  A,'E'	;ESC 'E'
        MVI  B,'$'	;EMPHASIZED
        JMP  VERT
VZ:     MVI  A,'F'	;ESC 'F'
        MVI  B,'$'	;CANCEL EMPHASIZED
        JMP  VERT
VU:	MVI  A,'-'	;UNDERLINE
	MVI  B,01
	JMP  VERT
VM:     MVI  A,'-'	;CANCEL UNDERLINE
	MVI  B,00
	JMP  VERT
VA:	MVI  A,'U'	;UNIDIRECTIONAL
	MVI  B,01
	JMP  VERT
VB:	MVI  A,'U'	;CANCEL UNIDIRECTIONAL
	MVI  B,00

V@:	MVI  A,'@'	;ESC '@'
	MVI  B,'$'	;RESET ALL
	JMP  VERT

		;STORE ESCAPE SEQUENCE CODE CHARACTERS AT
		;LABEL VSTR: FOR LATER OUTPUT THRU TEST1

VERTº   STÁ  VSTR+±     ;STORÅ 1sô ESCAPE CHARACTER
			;ESC (1BH) IS PROVIDED AT VSTR + 0
        MOV  A,B        ;STORE 2nd CHARACTER OR THE
        STA  VSTR+2     ; PADDING '$' TERMINATOR     
	MVI  A,'$'	;HERE IS THE OTHER '$' YOU MAY NEED 
	STA  VSTR+3	; TERMINATE THE ESCAPE STRING 
        LXI  H,VSTR     ;SET PC TO ESCAPE SEQUENCE STRING
        JMP  TEST1      ;TEST FOR CHARACTERS & TERMINATOR

		;SET  UP CONTROL CODES FOR OUTPUT

LINEF:  MVI  E,LF       ;LINE FEED
        JMP  OUTPUT
FMFD:   MVI  E,TOF      ;FORM FEED
        JMP  OUTPUT
CPRD:   MVI  E,SI       ;COMPRESSED
        JMP  OUTPUT
CANCEL: MVI  E,DC2      ;CANCEL COMPRESSED
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

MENDAT  DB   CR,LF,'PRINTER OPTIONS MENU',CR,LF,LF
        DB   ' 3 = THREE (3) LINES PER INCH     4 = FOUR (4) LINES',CR,LF
        DB   ' 8 = EIGHT (8) LINES PER INCH     6 = RESET LINES',CR,LF,LF
        DB   ' F = FORM FEED                    L = LINE FEED',CR,LF
        DB   ' K = SKIP (SIX) OVER PERF',CR,LF
        DB   '                                  TO CANCEL OPTION',CR,LF
        DB   ' C = COMPRESSED PRINT-17 CPI ##          >',CR,LF
        DB   ' W = DOUBLE WIDTH-5 CPI (+C=8.5)         <',CR,LF
        DB   ' I = ITALICS                             J',CR,LF       
        DB   ' S = FINE PRINT##                        R & H',CR,LF
        DB   ' D = DOUBLESTRIKE                        H',CR,LF
        DB   ' E = EMPHASIZED**                        Z',CR,LF
	DB   ' U = UNDERLINE                           ^',CR,LF
	DB   ' V = UNIDIRECTIONAL L ->R                +',CR,LF
	DB   ' @ = RESET TO POWER-UP INCL TOF',CR,LF                   
        DB   '** > DO NOT USE WITH "C" OR "S" SEE ## ABOVE',CR,LF,LF
        DB   ' T = TEST PRINTER                 Q = QUIT',CR,LF,LF
        DB   'ENTER OPTION  ','$'

ERRMSG: DB   CR,LF,'NO SUCH OPTION - TRY AGAIN!'
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
