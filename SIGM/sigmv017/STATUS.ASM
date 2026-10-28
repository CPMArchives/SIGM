;Lauren Guimont		1-25-80		Ver. 1.0
;			1-28-80		Ver. 1.1
;			3-20-80		Ver. 1.2
;			6-26-80		Ver. 1.3
;
;This is an assembly language adaption of a program
;written in NorthStar BASIC called `STATUS'.
;
;This program will determine the location of numerous
;addresses, depending on the system size being run.
;It will also present various pieces of information
;concerning the status of many of the options available
;under CP/M 2.20, besides presenting a map of the memory
;of the host system.
;
;
;Set up the equates to use
;
BDOS	EQU	5		;I/O PATCHING
CONOUT	EQU	2		;CONSOLE CHAR OUT
GIOBYTE	EQU	7		;RETURNS I/O BYTE IN A
STROUT	EQU	9		;PRINT STRING OUTPUT
LOGIN	EQU	24		;RETURNS ON-LINE DRIVES
CURDRV	EQU	25		;RETURNS DEFAULT DRIVE#
ALLOC	EQU	27		;RETURNS ALLOCATION ADDRESS
RONLY	EQU	29		;RETURNS READ ONLY VECTOR
DPARA	EQU	31		;RETURNS DISK PARAMETER BLK
PRUSER	EQU	32		;RETURNS PRESENT USER
;
;
BEGIN	ORG	100H		;Start of TPA
	JMP	START		;Actual program start
	DS	64		;Set up a stack area
STACK	EQU	$
;
BEDOS	DS	2
TPA	DS	2
CCP	DS	2
CONTLR	DS	1
OLDSP	DS	2
BYTE	DB	0
IOBYT	DS	1
VECTOR	DS	2
CDRV	DS	1
ALLOCAD	DS	2
;
;
COUT:				;Character output
	PUSH	B
	PUSH	D
	PUSH	H
	MOV	E,A
	MVI	C,CONOUT
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	RET
;
;The following routine will print the value of
;HL to the console. If entered at HEOUT, it will
;only print the value of the A register
;
ADOUT:				;Output HL to console
	MOV	A,H		;H is first
	CALL	HEOUT
	MOV	A,L		;L is next
HEOUT	MOV	C,A		;Save it
	RRC
	RRC
	RRC
	RRC
	CALL	HEOUT1		;Put it out
	MOV	A,C		;Get it back
HEOUT1	ANI	0FH
	ADI	48
	CPI	58		;0-9?
	JC	OUTCH
	ADI	7		;Make it a letter
OUTCH	CALL	COUT
	RET
;
CLEAR:				;Clear console
	MVI	C,25
	MVI	A,0DH		;C/R
	CALL	COUT
CLEAR1	MVI	A,0AH		;Linefeed
	CALL	COUT
	DCR	C
	JNZ	CLEAR1		;Loop for 25 LF
	RET
;
;
CRLF:				;Send C/R, LF
	MVI	A,0DH
	CALL	COUT
	MVI	A,0AH
	CALL	COUT
	RET
;
SPACE	MVI	A,20H
	CALL	COUT
	RET
;
;PROGRAM MESSAGES
;
MSG0	DB	'STATUS report for CP/M 2.2      '
	DB	'           Version 1.4 (6-27-80)'
	DB	0DH,0AH,0AH,0AH,'$'
MSG1	DB	'    M=RAM memory           R=ROM memory'
	DB	'          .=no memory',0DH,0AH
	DB	'0   1   2   3   4   5   6   7   8   9'
	DB	'   A   B   C   D   E   F'
	DB	0DH,0AH,'$'
MSG2	DB	'CCP starts at $'
MSG3	DB	'BDOS starts at $'
MSG4	DB	'Current logged in drives;  $'
MSG5	DB	'The Allocation address of drive $'
MSG6	DB	': is $'
MSG7	DB	'A$'
MSG8	DB	', B$'
MSG9	DB	', C$'
MSG10	DB	', D$'
MSG11	DB	' bytes$'
MSG12	DB	'The address of the disk '
	DB	'parameter block is $'
MSG13	DB	'Available TPA without '
	DB	'killing the CCP is $'
MSG14	DB	'These drives are vectored'
	DB	' as read only;  $'
MSG15	DB	'BIOS starts at $'
MSG16	DB	'Active I/O ports: $'
MSG17	DB	'None$'
MSG18	DB	'Current drive in use is $'
MSG19	DB	'The present USER number is $'
;
;
START:				;Actual program start
	LXI	H,0		;Clear HL
	DAD	SP		;Get SP from CCP
	SHLD	OLDSP		;Save it
	LXI	SP,STACK	;Point to our stack
	CALL	CLEAR
	LXI	D,MSG0
	MVI	C,STROUT
	CALL	BDOS
	LXI	D,MSG1
	MVI	C,STROUT
	CALL	BDOS
;
;This is the start of the memory map
;
	LXI	H,0000H		;Start memory map
MEMORY:
	MVI	A,0FFH
	CMP	M		;Memory?
	JZ	EMPTY
	MOV	B,M		;Save memory value
	MOV	M,A
	MOV	A,M
	CMP	B		;Same as original?
	JZ	ROM
RAM	MOV	M,B		;Replace original byte
	MVI	B,4DH
	JMP	SHWBY
ROM	MVI	B,52H
	JMP	SHWBY
EMPTY	MVI	A,80H		;Double check W/new value
	MOV	B,M
	MOV	M,A
	MOV	A,M
	CMP	B		;Is it ram?
	JNZ	RAM
	MVI	B,2EH
SHWBY	MOV	A,B
	CALL	COUT		;Output ROM, RAM, or empty
	INR	H
	INR	H
	INR	H
	INR	H
	JNZ	MEMORY		;Loop till done
	CALL	CRLF
	CALL	CRLF
;
;Now we fill in the storage bytes with the proper
;values which are dependent on each particular system.
;
	LHLD	BDOS+1		;Get start of BDOS
	MOV	A,L
	SUI	6
	MOV	L,A
	SHLD	BEDOS		;Store it
	LXI	D,0F700H
	LHLD	BEDOS
	DAD	D		;Add wrap around offset
	SHLD	TPA
	LXI	D,100H
	LHLD	TPA
	DAD	D
	SHLD	CCP		;Store CCP=-100H of TPA
	MVI	C,GIOBYTE
	CALL	BDOS
	STA	IOBYT		;Store the I/O byte
	MVI	C,ALLOC
	CALL	BDOS
	SHLD	ALLOCAD
;
;Now we must output the gathered information
;to the console
;
;Get the CCP address and print it
;
	LXI	D,MSG2
	MVI	C,STROUT
	CALL	BDOS
	LHLD	CCP
	CALL	ADOUT
	CALL	CRLF
;
;Next get the BDOS address and print it
;
	LXI	D,MSG3
	MVI	C,STROUT
	CALL	BDOS
	LHLD	BEDOS
	CALL	ADOUT
	CALL	CRLF
;
;Next get address of BIOS and print it
;
	LXI	D,MSG15
	MVI	C,STROUT
	CALL	BDOS
	LXI	D,0E00H
	LHLD	BEDOS
	DAD	D
	CALL	ADOUT
	CALL	CRLF
;
;Compute TPA without killing CCP and print it
;
	LXI	D,MSG13
	MVI	C,STROUT
	CALL	BDOS
	LHLD	TPA
	CALL	ADOUT
	LXI	D,MSG11
	MVI	C,STROUT
	CALL	BDOS
	CALL	CRLF
;
;Determine which drive is the current drive in
;use, and print the result
;
	LXI	D,MSG18
	MVI	C,STROUT
	CALL	BDOS
	MVI	C,CURDRV
	CALL	BDOS
	ADI	41H
	STA	CDRV
	CALL	COUT
	MVI	A,':'
	CALL	COUT
	CALL	CRLF
;
;Determine Allocation address of current drive, and print it
;
	LXI	D,MSG5
	MVI	C,STROUT
	CALL	BDOS
	LDA	CDRV
	CALL	COUT
	LXI	D,MSG6
	MVI	C,STROUT
	CALL	BDOS
	LHLD	ALLOCAD
	CALL	ADOUT
	MVI	A,48H
	CALL	COUT
	CALL	CRLF
;
;Find out which drives are logged in and print them
;
	MVI	C,LOGIN
	CALL	BDOS
	ANI	0FH
	STA	VECTOR
	LXI	D,MSG4
	MVI	C,STROUT
	CALL	BDOS
	LDA	VECTOR
	RRC
	STA	VECTOR
	LXI	D,MSG7
	MVI	C,STROUT
	CC	BDOS
	LDA	VECTOR
	RRC
	STA	VECTOR
	LXI	D,MSG8
	MVI	C,STROUT
	CC	BDOS
	LDA	VECTOR
	RRC
	STA	VECTOR
	LXI	D,MSG9
	MVI	C,STROUT
	CC	BDOS
	LDA	VECTOR
	RRC
	LXI	D,MSG10
	MVI	C,STROUT
	CC	BDOS
	CALL	CRLF
;
;Find and show the read only vectors
;
	MVI	C,RONLY
	CALL	BDOS
	ANI	0FH
	STA	VECTOR
	LXI	D,MSG14
	MVI	C,STROUT
	CALL	BDOS
	LDA	VECTOR
	ORA	A
	LXI	D,MSG17
	MVI	C,STROUT
	CZ	BDOS
	LDA	VECTOR
	RRC
	STA	VECTOR
	LXI	D,MSG7
	MVI	C,STROUT
	CC	BDOS
	LDA	VECTOR
	RRC
	STA	VECTOR
	LXI	D,MSG8
	MVI	C,STROUT
	CC	BDOS
	LDA	VECTOR
	RRC
	STA	VECTOR
	LXI	D,MSG9
	MVI	C,STROUT
	CC	BDOS
	LDA	VECTOR
	RRC
	LXI	D,MSG10
	MVI	C,STROUT
	CC	BDOS
	CALL	CRLF
;
;Get the disk parameter block and display it
;
	LXI	D,MSG12
	MVI	C,STROUT
	CALL	BDOS
	MVI	C,DPARA
	CALL	BDOS
	CALL	ADOUT
	MVI	A,48H
	CALL	COUT
	CALL	CRLF
;
;Determine the present USER, and print the result
;
	LXI	D,MSG19
	MVI	C,STROUT
	CALL	BDOS
	MVI	E,0FFH
	MVI	C,PRUSER
	CALL	BDOS
	CALL	HEOUT
	MVI	A,48H
	CALL	COUT
	CALL	CRLF
;
;Check all ports (0-255), and determine if they
;are active. If they are, print the port number
;and then do a warm boot (control C)
;
;BE ADVISED!!
;The lable PORT1 gets a byte from storage from a
;lable called BYTE. This value is incremented from
;0-255 and then is written to the second byte from
;the lable PORT2. What I'm saying is that this
;portion of code is SELF MODIFYING!!
;
	LXI	D,MSG16
	MVI	C,STROUT
	CALL	BDOS
PORT1	LDA	BYTE
	STA	PORT2+1
PORT2	IN	0
	CPI	0FFH
	CNZ	PORTOUT
	LDA	BYTE
	CPI	0E0H
	JZ	FINISH
	LDA	BYTE
	INR	A
	STA	BYTE
	JMP	PORT1
FINISH	CALL	CRLF
	CALL	CRLF
	CALL	CRLF
	LHLD	OLDSP
	SPHL
	RET
PORTOUT	LDA	BYTE
	CALL	HEOUT
	CALL	SPACE
	RET



