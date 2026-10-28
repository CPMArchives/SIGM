;********************************************************
;*							*
;*	Minimal effective BIOS driver for Diablo	*
;*	1610/1620 Daisywheel printer using EXT/ACK	*
;*	software handshaking. This driver relies	*
;*	on the fact that the printer is always taking	*
;*	characters out of its buffer so 99.99% of 	*
;*	the time there is room to fit in an escape	*
;*	sequence into the buffer even if it has		*
;*	"counted" to nearly full. It certainly		*
;*	works 100% OK in practice.			*
;*							*
;********************************************************
;
;	By	Bill Bolton
;		Software Tools
;		P.O. Box 80,
;		Newport Beach
;		NSW, 2106
;		Australia
;
;	First coded sometime in 1979
;	Tidied up for publication 26/Jun/1982
;
;INPORT	----> Your port driver routine for inputing from printer
;OUTPORT ---> Your port driver routine for sending to printer
;
AESC	EQU	01BH		;Ascii escape
AETX	EQU	3		;Ascii end of text
AACK	EQU	6		;Ascii acknowlege
MAXESC	EQU	3		;Maximum length of ESC sequence
COUNT	EQU	154		;No. characters for Diablo buffer

DIABLO:
	CALL	OUTPORT		;SEND THE CHARACTER
	CPI	AESC		;WAS IT AN ESCAPE?
	LDA	OUTCNT		; (CHARS SENT SINCE O/P COUNT RESET)
	JNZ	DIAB2		;NO
	ADI	MAXESC		;ENSURE ESC SEQUENCE SENT BEFORE ETX
DIAB2:
	DCR	A
	STA	OUTCNT		;SAVE UPDATED COUNT
	MOV	A,C		;A <---- CHAR SENT TO KEEPP CP/M HAPPY 
	RNZ			;NO, RETURN
	MVI	A,COUNT		;SET COUNT
	STA	OUTCNT
	MVI	C,AETX		;YES, GET ETX
	CALL	OUTPORT		;SEND IT
ACKLOOP:
	CALL	INPORT		;GET CHARACTER FROM PRINTER
	CPI	AACK		;DIABLO SENDS ACK WHEN IT GETS ETX
				;FROM ITS CHARACTER BUFFER
	JNZ	ACKLOOP		;NOT FOUND, KEEP LOOKING
	RET
;
OUTCNT:	DB	154		;COUNT OF CHARACTERS SENT
;
