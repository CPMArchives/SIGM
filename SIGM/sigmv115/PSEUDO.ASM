;THE FIRST(?) PUBLIC DOMAIN HARDWARE-SOFTWARE
;COMBINATION!
;	
;name of file PSEUDO.ZSM
;
;this program expects the circuit as described
;in the file PSEUDO.DOC
;
;this is Z80 code, but could be easily adapted
;to run on an 8080, 8085.
;
;the pseudo-ops are for my particular assembler
;(ie EJECT = PAGE or SKIP etc.,
;    DEFB = DB, DEFS = DS)
;
;This firmware is released into the public domain
;as of 3/17/83, for personal use only. Hardware
;&/or software changes are at the discretion of
;the user.
;
;any relation to firmware living or dead is 
;purely accidental.
;
;author:
;	Ron Winter
;	PO Box 3061
;	North Brunswick, NJ 08902
;	(201) 249 4228
;
;
;credits:
;
;I wish to thank all the authors of previous SIG/M
;releases for many of the ideas used in creating
;this monster, especially those of BYE for the
;static byte relocation trickery.
;
;
;note: 
;no real mention of OS is given in this code
;and I have run it under (over, thru?) North Star
;HDOS & CP/M equally. It should run on TRS model?,
;Softcards, etc. with very little work(?).
;
;
 EJECT
	TITLE emulator code 
 PSECT ABS

;I initialize VI6 vector for main monitor,
;VI5 for breakpoints, leave Z80 in powered on
;IM0. one could run IM2 without too much sweat.

Jump	EQU 0C3H	;opcode 	
RST40	EQU 0C7H+5*8	;opcode

RST_5	EQU 8*5		;trap $
RST_6   EQU 8*6		;  "

;assumes 24x80 display, but could be used in
;other formats, again a little recoding around
;the display section only.
 
;I use the following commands in the emulator
;(to start with, can be extended)
;
;<esc> means step from address to be entered
;<sp>  means single step- initial setup
;<b> enter breakpoint- and go
;<r or c or s> means run until RET family
;<ret> means full speed- pseudo run

Base	EQU 0	;adjust for your roms in cpm land

Bell	EQU 07
Space	EQU ' '
Esc	EQU 1BH
Ret	EQU 0DH

False	EQU 0
True	EQU .NOT.False

Primes	EQU True	;save AF',HL',DE',BC'

Arming_port	EQU 08	;starts divide/2 on M1

Software_enable EQU True
 IF Software_enable
Enable_port 	EQU 0AH	;set to your values
On_value	EQU 0EH
Off_value	EQU 0EH+01
 ENDIF

Nstar		EQU True
Nstar_parallel	EQU True	;my keyboard input
Other_keyboards EQU False

Dpcrt		EQU True	;my `terminal'
Split_screen    EQU True

Destination: EQU 0BD00H	;where I hide it
			;in my system, change to
			;suit
 EJECT
	ORG	Base+0100H	;normal transient

	JP	Initialize
;
;for debugging, <esc> to really frigid start up!
;	DI
;IF Software_enable
;	LD A,Off_value	;disables circuit
;	OUT (Enable_port),A
;ENDIF
;IF Nstar
;	JP 0E800H
;ENDIF
;IF .NOT.Nstar
;	JP 0	;? or wherever is proper
;ENDIF
 EJECT
Initialize: DI
 IF Software_enable
	LD	A,On_value
	OUT	(Enable_port),A
 ENDIF
	LD	(SP_save),SP
	LD	SP,SP_save

	LD	A,Jump
	LD	HL,Breakpoint
	LD	DE,Monitor
	LD	(RST_5),A
	LD	(RST_6),A
	LD	(RST_5+1),HL
	LD	(RST_6+1),DE
 EJECT
;byte relocate our assembly to anywhere
	LD	HL,Source
	LD	DE,Destination
	LD	BC,Size_of_code
	 LDIR
;vectors are set, code is in place
;so now we signal ourself that we are ready
 IF Split_screen
	 CALL	Get_cursor	;split screen use
	 CALL	Change_to_29_lines
	LD	DE,' '+24.SHL.8+' '+0
;D=row, E=column on my screen where I will set
;the cursor (25th row, 1st col)
	 CALL	Set_cursor
 ENDIF
 IF .NOT.Split_screen
;
 ENDIF
	LD	HL,Pretty_display
	LD	DE,80*5-1	;# of char's to
Refresh: LD	C,(HL)		;put on display
	 CALL	Out_locally	;avoiding last
	INC	HL		;screen position
	DEC	DE		;so as to keep
	LD	A,E		;from scrolling
	OR	D
	 JR	NZ,Refresh	;ie, a mini
				;screen editor
 IF Split_screen
	 CALL	Restore_cursor
	 CALL	Back_to_24_lines
 ENDIF
 IF .NOT.Split_screen
;
 ENDIF
	JP	Exit_initialization
Pretty_display:
;layout template
;      1234567890123456789012345678901234567890
;      	        1	  2	    3	      4
;
 DEFM '<sp> single step, <ret> pseudo run, <esc'
 DEFM '> quit, <s> subs                        '
 DEFM '(pc)           AF sz.h.vnc   HL    DE   '
 DEFM ' BC    IX    IY                         '
 DEFM '........       .. ........  ....  ....  '
 DEFM '....  ....  ....                        '
 DEFM ' pc      SP    AF''sz.h.pnc   HL''   DE''  '
 DEFM ' BC''   I     R                          '
 DEFM '....    ....   .. ........  ....  ....  '
 DEFM '....   ..    ..                         '
 EJECT
Offset	EQU Destination-$	;sets lc
;			
Breakpoint: EQU $+Offset
;will hit here on any rst 40 code executed by
;processor, hope it was ours!

Source:	;for relaocator
	DI
	LD	(Save_HL),HL ;save hl 1st
	LD	(SP_save),SP ;save stackpointer

	PUSH	AF	;tease AF into view
	POP	HL
	LD	(Save_AF),HL ;save AF

	POP	HL	;the $ after the break
	DEC	HL	;restored to $ at the
	PUSH	HL	;breakpoint
	LD	(The_next_pc),HL

	LD	SP,SP_save	;private stack
	LD	(Save_DE),DE	;de done
;pointers used here so can be extended to any #
;of bkpts. One must then keep count of them &
;their addresses.
	LD	DE,Bpt_storage
	LD	A,(DE)	;original opcode
	LD	(HL),A	;restored
;
;enable now since it was off for 
;`run until breakpoint'
 IF Software_enable
	LD	A,On_value
	OUT	(Enable_port),A
 ENDIF
;preset single step to pause display
	LD	A,Space
	LD	(Last_key),A
	 JR	Common_code
 EJECT
Monitor: EQU $+Offset
;hit here on vi6, and again it better be ours
;maybe we should
	DI
;just in case it wasn't!
	LD	(Save_HL),HL
	LD	(SP_save),SP
	POP	HL
	LD	(The_next_pc),HL
	PUSH	HL

	LD	SP,SP_save

	PUSH	AF
	POP	HL
	LD	(Save_AF),HL

	LD	(Save_DE),DE
;
Common_code: 	
	LD	(Save_BC),BC	
				;if you want to
	LD	A,I		;pick up the iff2
	LD	(Save_I),A	;flip flop, here
				;it is in the p/v
				;flag now

	LD	A,R		;for those who 
	LD	(Save_R),A	;like to see action

	LD	(SaveIX),IX
	LD	(SaveIY),IY
 IF Primes	
; if you want to see all the 'ed registers
	EXX
	LD	(HL_prime),HL
	LD	(DE_prime),DE
	LD	(BC_prime),BC
	EX	AF,AF'
	PUSH	AF
	POP	HL
	LD	(AF_prime),HL
	EX	AF,AF'
	EXX
 ENDIF
 EJECT
 IF Split_screen
	 CALL	Change_to_29_lines
	 CALL	Get_cursor
 ENDIF
 IF .NOT.Split_screen
;send output to your other terminal
 ENDIF
;main monitor flavor given by this code
	 CALL	Display
Stop:	 CALL Poller
	 JR	NZ,Key_was_struck	;else use
					;last key
	LD	A,(Last_key)
	CP	Ret
	 JR	Z,Pseudo_run
	CP	Space
	 JR	Z,Single_step
	CP	'R'
	 JR	Z,Run_til_rets
;more options here
	 JR	Error
;
Single_step:
	LD	DE,' '+24.SHL.8+' '+57
	 CALL	Set_cursor
	 JR	Stop
;
Run_til_rets: 
	LD	HL,(The_next_pc)
	LD	A,(HL)
	CP	0C9H		;is RET
	 JR	Z,Stop
	CP	0C0H
	 JR	C,Pseudo_run 	;not a RET
	AND	00000111B
	 JR	Z,Stop		;else it aint

Pseudo_run:
	 CALL Recover_all
Exit_initialization: EQU $+Offset
	LD	SP,(SP_save)
	EI
	OUT	(Arming_port),A
	 RET
 EJECT
Key_was_struck:	
	LD (Last_key),A
	CP	Space
	 JR	Z,Pseudo_run

	AND	01011111B 	;case filter
	LD	(Last_key),A

	CP	Ret
	 JR	Z,Pseudo_run

	PUSH 	AF
;set cursor to prompt point of display
	LD	DE,' '+24.SHL.8+' '+57
	 CALL	Set_cursor
	POP	AF

	CP	'S'		;s - subroutine
	 JR	Z,Run_until
	CP	'R'		;r - return
	 JR	Z,Run_until
	CP	'C'		;c - calls
	 JR	Z,Run_until

	CP	Esc
	 JR	Z,Enter_go$

	CP	'B'
	 JR	Z,Set_breakpoint
;more options, then fall thru to
Error:	
	LD	C,Bell
	 CALL	Out_locally

	LD	A,' '		;force a pause
	LD	(Last_key),A
	 JR	Stop
;
Run_until:
	LD	C,A

	LD	A,'R'
	LD	(Last_key),A

	 CALL	Out_locally
	 JR	Pseudo_run
 EJECT
Enter_go$:
	 CALL	Get_address

 IF Split_screen
	 CALL	Restore_cursor
	 CALL	Back_to_24_lines
 ENDIF
 IF .NOT.Split_screen
;
 ENDIF
	LD	A,Space		;force pause
	LD	(Last_key),A	;at breakpoint

	LD	HL,(Go_or_bkpt) ;from chosen
	LD	SP,(SP_save)	;address

 IF Software_enable
	LD	A,On_value
	OUT	(Enable_port),A
 ENDIF
	EI
;this arms it (for any value of A)
	OUT	(Arming_port),A
	 JP	(HL)
;
Set_breakpoint:	
	LD	C,'B'
	 CALL	Out_locally

	 CALL	Get_address

	LD	DE,Bpt_storage
	LD	HL,(Go_or_bkpt)
	LD	A,(HL)		;save byte @ $
	LD	(DE),A
	LD	A,RST40		;set trap
	LD	(HL),A
;for normal run must disable hardware
 IF Software_enable
	LD	A,Off_value	;just in case it
	OUT	(Enable_port),A	;was on
 ENDIF
	 CALL	Recover_all
	LD	SP,(SP_save)
	 RET
;
 EJECT
Recover_all: EQU $+Offset
 IF Split_screen
	 CALL	Restore_cursor
	 CALL	Back_to_24_lines
 ENDIF
 IF .NOT.Split_screen
;if other terminal, then really nothing to do
 ENDIF
	LD	A,(Save_I)
	LD	I,A

	LD	BC,(Save_BC)
	LD	DE,(Save_DE)
	LD	IX,(SaveIX)
	LD	IY,(SaveIY)

	LD	HL,(Save_AF)
	PUSH	HL
	POP	AF

	LD	HL,(Save_HL)
 IF Primes
	EXX
	EX	AF,AF'
	LD	HL,(AF_prime)
	PUSH	HL
	POP	AF
	EX	AF,AF'
	LD	HL,(HL_prime)
	LD	DE,(DE_prime)
	LD	BC,(BC_prime)
	EXX
 ENDIF
	 RET
;
Restore_cursor:	EQU $+Offset
	LD	DE,(Col_of_cursor)

Set_cursor: EQU $+Offset
 IF Dpcrt			;& televideo,etc.
	LD	C,Esc
	 CALL	Out_locally
	LD	C,'='
	 CALL	Out_locally
	LD	C,D
	 CALL	Out_locally
	LD	C,E
 ENDIF
 IF .NOT.Dpcrt
;
 ENDIF
Out_locally: EQU $+Offset
 IF Dpcrt
Out_wait: IN	A,(40H)
	BIT	7,A
	 JR	NZ,Out_wait
	LD	A,C
	OUT	(41H),A
 ENDIF
 IF .NOT.Dpcrt
;alternate code to do console out
;char in C, preserve all but AF
 ENDIF	
	 RET
;
In_locally: EQU $+Offset
 IF Dpcrt
In_wait: IN	A,(40H)
	BIT	0,A
	 JR	NZ,In_wait
	IN	A,(41H)
 ENDIF
 IF .NOT.Dpcrt
;code for getting bytes (cursor position) f/ your
;terminal, return char in A
 ENDIF
	 RET
;
Get_cursor: EQU $+Offset
 IF Dpcrt			;& televideo,etc.
	LD	C,Esc
	 CALL	Out_locally
	LD	C,'?'
	 CALL	Out_locally
	 CALL	In_locally
	LD	(Row_of_cursor),A
	 CALL	In_locally
	LD	(Col_of_cursor),A
 ENDIF
 IF .NOT.Dpcrt
;
 ENDIF
	 RET
;
Change_to_29_lines: EQU $+Offset
 IF Dpcrt
	LD	D,29	;lines
 ENDIF
 IF .NOT.Dpcrt
;if other terminal, these routines are
;not needed
 ENDIF
	 JR	S_screen
;
Back_to_24_lines: EQU $+Offset
 IF Dpcrt
	LD	D,24
 ENDIF
 IF .NOT.Dpcrt
;
 ENDIF 
S_screen: LD	HL,Terminal_split_screen_command
	LD	B,C_length
	 CALL	String_it
 IF Dpcrt
	LD	C,D
	 JP	Out_locally
 ENDIF
 IF .NOT.Dpcrt
;
	 RET
 ENDIF
;
String_it: EQU $+Offset
S_print: LD	C,(HL)
	INC	HL
	 CALL	Out_locally
	DJNZ	S_print
	 RET
 EJECT
Poller:	EQU $+Offset
;for get address routine, poller should preserve
;HL at least
;this is the char input routine

 IF Nstar_parallel
;local console input code
	IN	A,(06)
	BIT	1,A
 ENDIF
 IF .NOT.Nstar_parallel
;
;
 ENDIF
	 RET	Z
;return if no key struck, else return with char
;in A, & z flag false.
 IF Nstar_parallel 	;and no repeat, no case!
	BIT	6,A	;on my adm-? keyboard!
	LD	(Repeat?),A

	LD	A,(Toggle)
	 JR	Z,No_case_switch
	XOR	01
	LD	(Toggle),A
No_case_switch: OR A

	IN	A,(00H)	;finally the key
	 JR	Z,Keep_extra_punctuation
	CP	'@'
	 JR	C,Keep_extra_punctuation
	CP	'`'
	 JR	NC,Keep_extra_punctuation
	ADD	A,'a'-'A'
Keep_extra_punctuation:	LD (Key_stroke),A
	LD	A,(Repeat?)
	BIT	7,A
	 JR	NZ,Force_repeat	;note false zf
	LD	A,30H	;resets parallel
			;input flag on m'board
	OR	A	;note also false zf
	OUT	(06H),A
Force_repeat: LD A,(Key_stroke)
 ENDIF
 IF .NOT.Nstar_parallel
;probably a lot less code!
 ENDIF
	 RET
 EJECT
Reget:
	POP	HL
Get_address: EQU $+Offset
;must enter 4 hex characters, <esc> to re-enter
;only return to use displayed value
	LD	DE,' '+24.SHL.8+' '+59
	 CALL	Set_cursor

	LD	HL,Address_prompt
	LD	B,P_length
	 CALL	String_it

	LD	HL,Go_or_bkpt+1 ;human entry
	 CALL	Hex_loop	;is left to right	
	 CALL	Hex_loop	;so we do high
	LD	HL,Go_or_bkpt	;first, then low
	 CALL	Hex_loop	;byte of address
	 CALL	Hex_loop	;need for exit
	 RET			;method
;
Hex_nfg:
	LD	A,C
	CP	Esc
	 JR	Z,Reget
	LD	C,Bell
	 CALL	Out_locally
;
Hex_loop: EQU $+Offset
Hex_wait: CALL	Poller
	 JR	Z,Hex_wait
	LD	C,A		;save for echo
	CP	'0'
	 JR	C,Hex_nfg
	SUB	'0'
	CP	'9'-'0'+1
	 JR	C,Hex_ok
	AND	01011111B	;upper-lower
				;case filter
	SUB	'A'-('9'+1)
	CP	16
	 JR	NC,Hex_nfg
Hex_ok:	RLD			;since we have it
	 			;might as well
				;stuff it in
	 JP	Out_locally
 EJECT
;main monitor display update
Display: EQU $+Offset

	LD	DE,' '+26.SHL.8+' '
	 CALL	Set_cursor
;
	LD	HL,(The_next_pc)
	LD	B,04		;contents of next
Show_code: LD	A,(HL)		;address
	 CALL	Hex_to_2_ascii	;disassembler
	INC	HL		;anyone?
	 DJNZ	Show_code
;
	LD	HL,Save_AF
	LD	DE,' '+26.SHL.8+' '+15
	 CALL	Do_a_line

	LD	HL,(SaveIX)
	 CALL	Word_to_4_ascii

	 CALL	Two_blanks

	LD	HL,(SaveIY)
	 CALL	Word_to_4_ascii

;next display line
	LD	DE,' '+28.SHL.8+' '+0
	 CALL	Set_cursor

	LD	HL,(The_next_pc)

	 CALL	Word_to_4_ascii
	 CALL	Four_blanks
	LD	HL,(SP_save)	;with our trap on
	INC	HL		;it, so we show 
	INC	HL		;it as the back-
	 CALL	Word_to_4_ascii ;ground sees it
;
 IF Primes
	LD	HL,AF_prime
	LD	DE,' '+28.SHL.8+' '+15

	 CALL	Do_a_line
	 CALL	One_blank
 ENDIF
 IF .NOT.Primes
	LD	DE,' '+28.SHL.8+' '+47
			        ;that aught to line
				;up under I & R
	 CALL	Set_cursor
 ENDIF
	LD	A,(Save_I)
	 CALL	Hex_to_2_ascii
	 CALL	Four_blanks
	LD	A,(Save_R)
	 JP	Hex_to_2_ascii
 EJECT
Do_a_line: EQU $+Offset

	 CALL	Set_cursor
	INC	HL
	LD	A,(HL)		;saved A (or A')
	 CALL	Hex_to_2_ascii
	 CALL	One_blank

	DEC	HL
	LD	A,(HL)		;flag register
	INC	HL
	INC	HL
	LD	B,08		;# bits
More_bits: LD	C,'1'
	SLA	A
	PUSH	AF
	 JR	C,A_bit
	DEC	C		;'1' -> '0'
A_bit:	 CALL	Out_locally
	POP	AF
	DJNZ	More_bits

	 CALL	Two_blanks

	EX	DE,HL
	LD	B,03		;for HL DE & BC
HLDEBC:	LD	A,(DE)		;or  primed
	LD	L,A
	INC	DE
	LD	A,(DE)
	LD	H,A
	INC	DE
	 CALL	Word_to_4_ascii
	 CALL	Two_blanks
	DJNZ	HLDEBC
	 RET
 EJECT
;garden variety utilities
;
;print HL as 4 ascii bytes
Word_to_4_ascii: EQU $+Offset

	LD	A,H
	 CALL	Hex_to_2_ascii
	LD	A,L

;print A as 2 ascii bytes 
Hex_to_2_ascii:	EQU $+Offset

	PUSH	AF
	SRL	A
	SRL	A
	SRL	A
	SRL	A
	 CALL	Byte_to_ascii
	POP	AF
	AND	0FH

;nybble to ascii & print
Byte_to_ascii: EQU $+Offset
	ADD	A,90H
	DAA
	ADC	A,40H
	DAA
	LD	C,A
	 JP	Out_locally
;
Four_blanks: EQU $+Offset

	LD	C,' '
	 CALL	Out_locally
	LD	C,' '
	 CALL	Out_locally

Two_blanks: EQU $+Offset

	LD	C,' '
	 CALL	Out_locally

One_blank: EQU $+Offset

	LD	C,' '
	 JP	Out_locally
 EJECT
Terminal_split_screen_command: EQU $+Offset

 IF Dpcrt
	DEFB	Esc,'L',0,1,8AH,0E7H
 ENDIF
 IF .NOT.Dpcrt
;if other terminal then this probably aint here
  ENDIF
C_length: EQU $+Offset-Terminal_split_screen_command
;
The_next_pc: EQU $+Offset
	DEFS 2
Go_or_bkpt: EQU $+Offset
	DEFS 2

Save_AF: EQU $+Offset
	DEFS 2
Save_HL: EQU $+Offset
	DEFS 2
Save_DE: EQU $+Offset
	DEFS 2
Save_BC: EQU $+Offset
	DEFS 2

SaveIX:	EQU $+Offset
	DEFS 2
SaveIY:	EQU $+Offset
	DEFS 2

AF_prime: EQU $+Offset
	DEFS 2
HL_prime: EQU $+Offset
	DEFS 2
DE_prime: EQU $+Offset
	DEFS 2
BC_prime: EQU $+Offset
	DEFS 2

Save_I:	EQU $+Offset
	DEFS 1
Save_R:	EQU $+Offset
	DEFS 1

Bpt_storage: EQU $+Offset
	DEFS 2

Col_of_cursor: EQU $+Offset
	DEFS 1
Row_of_cursor: EQU $+Offset	
	DEFS 1
 IF Nstar_parallel
Toggle:	EQU $+Offset
	DEFS 1
Key_stroke: EQU $+Offset
	DEFS 1
Repeat?: EQU $+Offset
	DEFS 1
 ENDIF
Last_key: EQU $+Offset
	DEFS 1
;
Address_prompt: EQU $+Offset
	DEFM 'addr ='
P_length: EQU $+Offset-Address_prompt
;leave some stack space
	DEFS ($.AND.0FF00H)+100H-$-2
	DEFB 0		;to see if enuf sp space
SP_save	EQU $+Offset
 LIST
Size_of_code: EQU $+Offset-Breakpoint 
;see if total size will fit where you plan to 
;move it (reassemble with alternate origin til
;it just fits)!
	END