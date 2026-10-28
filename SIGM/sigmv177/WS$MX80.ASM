;	USER4 04/10/81 USER PATCH AREA
;	being an Epson MX-80 patch file for 
;		Wordstar RELEASE 3.0 May, 1981
;	see USER4 listing, Installation manual, p. F-3
;
TBASE	EQU 0100H
;
	ORG TBASE + 0B4H	; location for printer description
	DB 'Epson MX-80 printer -- GRAFTRAX+ '
;
 	ORG TBASE + 590H	; begins after user 3 area
IOBYTE	EQU TBASE - 100H+3	; location of system I/O assignments
BDOS	EQU TBASE - 100H+5	; BDOS entry point
LISTF	EQU 5			; CP/M list output system call func#
;
BS	EQU 08H
LF	EQU 0AH
FF	EQU 0CH
CR	EQU 0DH
DEL	EQU 07FH
ESC	EQU 01BH
;
;	printer characteristics and printing method
;
;	printer type / overstrike method
;	POSMTH=FF: printer can overstrike only by CR w/o LF
;	POSMTH=0:  printer can overprint by backspacing as well as
;		by CR w/o LF
;	POSMTH=1: printer is a daisy-wheel or similar incremental printer.
;		Can print w/o spacing; can space and roll in small incr.
;
POSMTH:	DB 0FFH	; do not use backspacing -- it takes up too much time
BLDSTR:	DB 3	; 3 strikes for boldspace -- may not be needed with MX80
DBLSTR:	DB 2	; number of strikes for "double-strike'
	DB 0,0,0
;
;	CR/LF string
PSCRLF:	DB 2
	DB CR
	DB LF
	DB 0,0,0,0
	DB 0,0,0,0
;
;	string to return char to beginning of same line
PSCR:	DB 2
	DB CR
	DB 0	; null, for delay
	DB 0,0,0,0
;
;	string to do CR and half-line feed
;	used if rollup (below) is not installed
PSHALF:	DB 0	; not needed
	DB 0,0,0,0,0,0
;
;	string to backspace, i.e., for overprinting
PBACKS:	DB 1
	DB BS
	DB 0,0,0,0
;
;	string to set to compressed mode (see May 83 BYTE, p. 203)
PALT:	DB 1
	DB 8FH	; shift-in. Does not work with emphasized mode
	DB 0,0,0
;
;	string to reset to to uncompressed characters
PSTD:	DB 1
	DB 92H	; DC2                           
	DB 0,0,0
;
;	string to roll carriage up for before superscripts
;		and after subscripts
ROLUP:	DB 3	; use ^PQ (user 1 below) to turn off the mode
	DB ESC
	DB 'S'
	DB 1
	DB 0
;
;	string to roll carriage down, as after superscripts
ROLDOW:	DB 3	; use ^PQ (user 1 below) to turn off the mode 
	DB ESC
	DB 'S'
	DB 0
	DB 0
;
;	user-defined functions  -- see May 83 BYTE, p. 203, for source
;
USR1:	DB 2	; ^PQ  -- used to reset superscript and supscript modes
	DB ESC,'T'
	DB 0,0     
;
USR2:	DB 1	; ^PW -- used to turn on double width. Automatically
;		turns off at line end, or use USR3 below
	DB 08EH
	DB 0,0,0
;
USR3:	DB 1	; ^PE -- used to turn off double width
	DB 94H
	DB 0,0,0
;
USR4:	DB 0	; so far undefined
	DB 0,0,0,0
;
;	change ribbon color - used to control italics mode
RIBBON:	DB 2	; italics character set on
	DB ESC,34H
	DB 0,0
;
RIBOFF:	DB 2	; italics character set off
	DB ESC,35H
	DB 0,0
;
;	string to initialize printer -- may want to
;	initialize to various optional modes, skip perfs, etc.
;	Modify later after basic functions work
PSINIT:	DB 1
	DB CR	; to position head at left margin of paper
	DB 0,0,0
	DB 0,0,0,0
	DB 0,0,0,0
	DB 0,0,0,0	; up to 16 char can be sent
;
;	string to be sent at end of session, for resetting modes etc.
PSFINI:	DB 6		; for now
	DB ESC,46H	; turn off emphasized mode
	DB ESC,48H	; turn off double-strike, superscript and subscript
	DB 92H		; turn off compressed characters
	DB 94H		; turn off double-width characters
	DB 0,0
	DB 0,0,0,0
	DB 0,0,0,0	; again, up to 16 char
;
 	DB 0,0		; reserved
;
;	character used for 'strikeout' effect -- called via ^X
SOCHR:	DB '-'		; change to other if desired
;
;	character used for underscore (except underlining is available)
ULCHR:	DB '_'
;
;	for now, other mods seem unnecessary
;
	end
