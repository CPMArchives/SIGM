;****************************************************************
;*                                                              *
;*  TEST FILE BUILDING PROGRAM - BUILDS MARKED 1024 BYTE BLOCKS *
;*                                                              *
;****************************************************************

; CP/M function call definitions
;
PRINT	EQU	9	;Print string @ DE, terminate with "$"
OPEN	EQU	15	;Open file, FCB @ DE
CLOSE	EQU	16	;Close file, FCB @ DE
SRCHF	EQU	17	;Search for first match, FCB @ DE
SRCHN	EQU	18	;Search for next match, FCB @ DE
ERASE	EQU	19	;Erase specified file(s), FCB @ DE
READ	EQU	20	;Read from file, FCB @ DE
WRITE	EQU	21	;Write to file, FCB @ DE
MAKE	EQU	22	;Make a new file name in dir, FCB @ DE
SETDMA	EQU	26	;Set DMA address for disk I/O @ DE

; CP/M Entry and FCB definitions
;
BDOS	EQU	0005H	;BDOS call address, or entry point
FCB	EQU	005CH	;Default FCB, set up by CP/M CCP.

; ASCII Character definitions
;
CR	EQU	0DH	;Carriage Return
LF	EQU	0AH	;Line Feed

ORG	100H			;CPM TPA convention, program starts

START:	LXI	H,0000		;Save the system
	DAD	SP		;stack pointer for
	SHLD	OLDSP		;use at program exit.
	LXI	SP,STACK	;Allocate local stack.

	LDA	FCB+1		;Consider the requested
	CPI	' '		;file name. (all sp=none specified)
	JZ	NONAM		;If name was specified, then

	LXI	D,FCB		;Use the default FCB (file name)
	MVI	C,ERASE		;Erase the specified file
	CALL	BDOS		;if it already exists.

	LXI	D,FCB		;Use the default FCB (file name)
	MVI	C,MAKE		;Create an empty file name
	CALL	BDOS		;as requested, ready to use.

	CALL	WFILE		;Fill the new file with data

	LXI	D,FCB		;Use the default FCB (file name)
	MVI	C,CLOSE		;Close the now-written file
	CALL	BDOS		;completing the file operation.

NONAM:	LHLD	OLDSP		;Use the system stack pointer
	SPHL			;restoring SP to entry value.
	RET			;Return to operating system.

; BUILD A DATA FILE IN 1024 BYTE BLOCKS, LABELED WITH BLOCK I/D
;
WFILE:	MVI	A,8		;Eight sectors in each block.
	LXI	H,DBLOCK	;Start at the beginning of
WSECL:	SHLD	BLKPT		;the data block for each set.
	STA	SECNT		;Record current sector count.
	XCHG			;DE <- Address of next sector
	MVI	C,SETDMA	;Set data transfer address for
	CALL	BDOS		;this sector write (128 bytes)

	LXI	D,FCB		;Use the default FCB (file name)
	MVI	C,WRITE		;Write the selected sector data
	CALL	BDOS		;to the open disk file.

	LHLD	BLKPT		;The block pointer must
	LXI	D,128		;step over one sector
	DAD	D		;(128 bytes of data).

	LDA	SECNT		;If the sector count has run out
	DCR	A		;its quota of 128 byte sectors,
	JNZ	WSECL		;(this block is done), then:

; COUNT UP THE LABEL IN THE DATA BLOCK, TO NEXT VALUE (IN ASCII)
; (NUMBER MUST HAVE BEEN PRE-INITIALIZED TO ASCII 000001)

	LXI	H,LABEL+5	;Point to lowest digit of label
	MVI	B,6		;Consider up to the full 6 digits
LCNTL:	MOV	A,M		;Examine the current digit
	INR	A		;plus 1, whether still numeric.
	MOV	M,A		;Assume no overflow, number is done.
	CPI	'9'+1		;If numeric overflow did occur
	JNZ	LTCMP		;then (else compare termination)
	MVI	M,'0'		;reset this digit to "0"
	DCX	H		;step to the next higher digit.
	DCR	B		;If there was a next higher digit,
	JNZ	LCNTL		;propagate the carry. (else truncate)


; COMPARE THE DATA BLOCK LABEL WITH THE TERMINATION VALUE (IN ASCII)
; (TERMINATION VALUE MUST HAVE BEEN PRESET TO AN ASCII NUMBER)
;
LTCMP:	LXI	H,LABEL		;Point to highest digit of label
	LXI	D,TERMV		;Point to highest digit of terminator
	MVI	B,6		;Compare up to 6 equal digits.
LTCML:	LDAX	D		;If the current terminator digit
	CMP	M		;is the same as the current label digit
	JNZ	PLNUM		;then: (else print out this label number)
	INX	H		;Step over label digit
	INX	D		;Step over terminator digit
	DCR	B		;If there is another digit to compare
	RZ			;then: (else all digits are equal - end)
	JMP	LTCML		;compare next digit of label (block number).

; PRINT OUT THE CURRENT BLOCK NUMBER BEING WRITTEN TO DISK
;
PLNUM:	LXI	D,PLABL		;Point to label numeric string
	MVI	C,PRINT		;print it out on the console
	CALL	BDOS		;for operator observation.
	JMP	WFILE		;write this block to disk


	DS	64		;Local stack allocation
STACK:				;Stack pointer initialization address
OLDSP:	DW	0080H		;System stack pointer	
BLKPT:	DW	DBLOCK		;Sector data pointer (in block)
SECNT:	DB	8		;Sectors done in block - counter
TERMV:	DB	'001024'	;Required block count, in ASCII
PLABL:	DB	CR		;Cursor position for label display
LABEL:				;Label occupies first 6 Chars of data block
DBLOCK:				;Data block to be written to disk
 DB '000001 $$ Is the current block number in this test data file..',CR,LF
 DB 'Sector 1 in this block of a test file of 1024 byte data blocks',CR,LF
 DB 'ABCDEFGHI This is a test file containing 1024 byte data blocks',CR,LF
 DB 'Sector 2 in this block of a test file of 1024 byte data blocks',CR,LF
 DB 'JKLMNOPQR This is a test file containing 1024 byte data blocks',CR,LF
 DB 'Sector 3 in this block of a test file of 1024 byte data blocks',CR,LF
 DB 'STUVWXYZ. This is a test file containing 1024 byte data blocks',CR,LF
 DB 'Sector 4 in this block of a test file of 1024 byte data blocks',CR,LF
 DB 'abcdefghi This is a test file containing 1024 byte data blocks',CR,LF
 DB 'Sector 5 in this block of a test file of 1024 byte data blocks',CR,LF
 DB 'jklmnopqr This is a test file containing 1024 byte data blocks',CR,LF
 DB 'Sector 6 in this block of a test file of 1024 byte data blocks',CR,LF
 DB 'stuvwxyz. This is a test file containing 1024 byte data blocks',CR,LF
 DB 'Sector 7 in this block of a test file of 1024 byte data blocks',CR,LF
 DB '123456789 This is a test file containing 1024 byte data blocks',CR,LF
 DB 'Sector 8 in this block of a test file of 1024 byte data blocks',CR,LF

	END

