;MODEM PORT EQUATES
MDATA   EQU     4               ;Modem data port
MSTAT   EQU     5               ;Modem status port
MCNTR   EQU     5               ;Modem control port
MOMASK  EQU     1               ;Mask for input available
MIMASK  EQU     2               ;Mask for output posible
RESET   EQU     01000000B       ;Value for port reset
MINIT1  EQU     01001111B       ;Modem initialise value
MINIT2  EQU     00010101B       ; and second one
PINIT1  EQU     01001110B       ;Printer initialise value
PINIT2  EQU     00010101B       ; and second one

;CP/M EQUATES
BASE    EQU     0               ;Start of CP/M
BDOS    EQU     BASE+5          ;OS calls
CCP	EQU	0C000H		;Console Command Processor address
BIOS	EQU	0D600H		;Basic I/O, first vector.
TPA	EQU	0100H		;Start or programs
CONS    EQU     6               ;Direct console output
PRINT	EQU	9		;Print string
ESC     EQU     27



	ORG	TPA
	LXI	D,ACTIV
	MVI	C,PRINT
	CALL	BDOS		;Print a message

	LHLD	BASE+6		;Get BDOS vector and save it
	SHLD	BDOSTP		; for later if needed
	LXI	H,STARTR	;Protect memory - this will always
	SHLD	BASE+6		; happen after a warm boot

	LHLD	BIOS+09H+1	;Check if already installed
	MOV	A,H
	CPI	CONSIN/256	;Is jump already in?
	RZ			;Return to CP/M, hope that code
				; is still sitting under CCP as
				; no way of knowing where the
				; vector is supposed to go
	LXI	H,ENDP+1
	LXI	D,STARTR
	LXI	B,ENDR-STARTR
MOVLOP: MOV	A,M		;Move routine up there
	STAX	D
	INX	H
	INX	D
	DCX	B
	MOV	A,B
	ORA	C
	JNZ	MOVLOP

	LHLD	BDOSTP		;Get saved BDOS vector
	SHLD	STARTR+1	;Install it

	LHLD	BIOS+09H+1	;Console input vector
	SHLD	CONSIN+1	;Save in my prog
	LXI	H,CONSIN
	SHLD	BIOS+09H+1	;Trap calls to here

	RET			;Return to CP/M
		;THIS MUST NOT BE A WARM BOOT. The reason is
		; because this program does not worry about
		; warm boots, hence should have this as an
		; auto-execute command. If we booted here
		; and have auto command , hey presto endless
		; loop !!
ACTIV:	DT	'(EXTCOM active)$'
BDOSTP:	DW	0		;Temporary storage for BDOS vector

ENDP:	DB	0
	ORG	CCP-100H	;256 bytes of room
STARTR: DB	0C3H
	DW	0
CONSIN: DB	0CDH		;CALL = back here when
	DW	0		;	done
	PUSH	PSW		;Save status from routine
	ORA	A		; ^@ is go to extcom
	JZ	EXTCOM
	POP	PSW
	RET			;Back to wherever...


EXTCOM: 	LXI	H,STARTR-1
		SPHL			;Move to a new stack
		LXI	D,SIGNON
		MVI	C,PRINT
		CALL	BDOS

		CALL	INITIALISE
START:          CALL    GETCHAR
                CNZ     PUTMOD
                CALL    GETMOD
                CNZ     PUTCHAR
                JMP     START


INITIALISE:     MVI     A,RESET         ;Set up the port for modem
                OUT     MCNTR           ;operation. Form : 8 data bits
                MVI     A,MINIT1        ;                  1 stop bit
                OUT     MCNTR           ;                  no parity
                MVI     A,MINIT2        ;                  300 baud
                OUT     MCNTR
                RET

GETCHAR:        MVI     C,CONS          ;Console I/O function
                MVI     E,0FFH          ;Requesting input
                CALL    BDOS
                ORA     A               ;If A=0, no character
                RZ
		CPI	ESC		;Check for ESCape
                RNZ
                MVI     A,RESET         ;Set up port for printer
                OUT     MCNTR           ;operation. Form : 8 data bits
                MVI     A,PINIT1        ;                  1 stop bit
                OUT     MCNTR           ;                  no parity
                MVI     A,PINIT2        ;                  1200 baud
                OUT     MCNTR           ;
                JMP     BASE            ;Back to CP/M

PUTMOD:         STA     TEMP            ;Save character..
                MVI     B,100           ;Initialise counter
NEXTLOOP:       DCR     B               ;Drop counter. Finished ?
                RZ                      ;Go back if we are
                IN      MSTAT           ;Get modem status
                ANI     MOMASK          ;Is it ready ?
                JZ      NEXTLOOP        ;No, try again
                LDA     TEMP            ;Get chararacter back
                OUT     MDATA           ;Send it
                RET                     ;Lets go back
TEMP:           DB      0               ;Temporary storage

GETMOD:         IN      MSTAT           ;Get status
                ANI     MIMASK          ;Is it ready ?
                RZ                      ;Go back if not
                IN      MDATA
                ORA     A               ;Reset Z flag
                RET

PUTCHAR:        ANI     07FH            ;Strip any high bits
                MOV     E,A             ;Move char to output
                MVI     C,CONS          ;Function: direct I/O
                CALL    BDOS            ;Display it.
                RET
SIGNON: 	DT	'EXTernal COMunications...(300 baud)...'
		DW	0A0DH
		DB	'$'
ENDR:		DB	0
