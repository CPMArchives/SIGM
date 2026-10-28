Title 'CRCC GENERATOR for ATS GCP ROM'
;    File CRCGEN.ASM
;         
;         Written Feb. '81 by:
;         d.a. steele
;         Information Development and Applications Inc.
;         10759 Tucker St.
;         Beltsville, MD. 20705
;
;This program is to be loaded and execuited in the GCP by useing
;ILOAD and will generate and print out to the console the CRC 
;value to be used in the GCP ROM test of the ATS Diagnostics.
;After this program is ran the operator will need to run SID.
;Using SID create load the first two bytes at 100h with these two
;values.  The low byte first.  Now exit SID by useing a ^C and
;save one page into a file called CRCC.DAT.  This file will be needed
;on the diagnositcs disc before running the GCP ROM test.
maclib    z80
;aseg
GBASE      EQU       0F800H
WBOOT      EQU       GBASE + 3    ;Warm reset of the GCP boot code
CONST      EQU       GBASE + 6    ;Console status
                                  ;Tests status of keyboard input
                                  ;<A> = 0FFH  --> keystroke is available
                                  ;<A> = 0     --> keystroke not available
CONIN      EQU       GBASE + 9    ;Console input
                                  ;Waits for input. 
                                  ;Returns with keystroke in <A>
CONOUT     EQU       GBASE + 12   ;Console output
                                  ;Prints contents of <C> to Plasma
STRING     EQU       GBASE + 15   ;String output
                                  ;Prints string pointed to by <HL> to Plasma
                                  ;Terminates on string containing 00H
MCPSTAT    EQU       GBASE + 18   ;MCP status
                                  ;Tests status of MCP input port
                                  ;<A> = 0FFH --> Char. ready for parallel inpt
                                  ;<A> = 00   --> Char. not ready
MCPIN      EQU       GBASE + 21   ;MCP input
                                  ;Wait for MCP input
                                  ;Input returned in <A>
MCPOUT     EQU       GBASE + 24   ;MCP output
                                  ;Output char in <C> to the MCP

           ORG       6000H        ;Set the stack pointer
START:     LXI       SP,7000H     
           LXI       B,0F800H     ;starting address of ROM
           LXI       D,3FFFH      ;ending address
           CALL      CRC
                                  ;Now we have the CRCC of the EPROMS
                                  ;So print them pot to the console
           PUSH      H            ;Save the CRCC
           LXI       H,LOWB       ;Print low byte msg.
           CALL      STRING
           POP       H            ;Get the CRCC in HL 
           PUSH      H            ;Then put it awayŠ           MOV       A,L          ;Put low byte in a to be printed
           RRC                    ;Convert to hex format
           RRC
           RRC
           RRC
           CALL      OUTCHR       ;Print pot the first hex digit
           POP       H
           PUSH      H
           MOV       A,L
           CALL      OUTCHR       ;Print the second hex digit of the low byte
           LXI       H,HIB        ;Print the high message
           CALL      STRING       
           POP       H            ;Get the CRC back again
           PUSH      H
           MOV       A,H          ;Put high hex digit into a
           RRC                    ;Convert to hex
           RRC
           RRC
           RRC
           CALL      OUTCHR       ;Print out high hex digit
           POP       H
           MOV       A,H
           CALL      OUTCHR       ;print out the low hex digit
           LXI       H,CRLF       ;and do a CR LF
           CALL      STRING
           JMP       WBOOT        ;End with a jump to WBOOT

OUTCHR:    ANI       0FH          ;Print out the hex char. in A
           ADI       90H
           DAA
           ACI       40H
           DAA
           MOV       C,A
           CALL      CONOUT
           RET
          



LOWB:      DB        'Low Byte = ',0
HIB:       DB        '  High Byte = ',0 
CRLF:      DB        0AH,0DH,0
POINT:     DW        0

CRC:                              ;This is the CRCC generator routine
                                  ;This routine computes the CRCC char
                                  ;(16 bits) on the area of memory
                                  ;specified by the call parameters
           PUSH      B            ;Save the first
           MOV       A,C
           CMA
           MOV       C,A
           MOV       A,B
           CMA
           MOV       B,AŠ           INX       B
           XCHG
           DAD       B
           PUSH      H
           POP       B
           POP       H
           INX       B            ;Adjust the length
           CALL      CRCGEN
           RET

CRCGEN:                         ;CRCC Gennerator
                                ;HL Beginning of file
                                ;BC Length of file
                                ;<POINT> save location of the result
                                ;HL result saved
                                ;Generator polynominal G(X)=X(16)+X(12)+X(5)+1
           
GX1        EQU       00100001B    ;Generator polynominal
GX2        EQU       00010000B    ;same

                                  ;Beginning of routine
           SHLD      POINT        ;Save location of P(X)
           PUSH      B            ;save length
           POP       H
           LXI       D,-1         ;Initialize CRC generator
           MVI       C,8          ;Bit count
CRC2:                             ;Do the generation
           PUSH      H            ;Load (BC) @ POINT
           LHLD      POINT        ;Load next P(X)
           MOV       B,M
           INX       H
           SHLD      POINT
           POP       H
CRC4:      
           MOV       A,E
           ADD       E
           MOV       E,A
           MOV       A,D
           ADC       D
           MOV       D,A
           JC        CRC3         ;JMP if MSB = 1

           MOV       A,B          ;shift P(X) left (B)
           ADD       B
           MOV       B,A
           JNC       CRCOUT       ;JMP if MSB = 0

CRCXOR:    MOV       A,E          ;XOR CRC and G(X)
           XRI       GX1
           MOV       E,A
           MOV       A,D
           XRI       GX2
           MOV       D,A
CRCOUT:    DCR       C            ;CK bit count
           JNZ       CRC4Š           MVI       C,8
           DCX       H            ;Ck word count
           MOV       A,L
           ORA       H
           JNZ       CRC2
           XCHG                   ;save the CRC result
           SHLD      POINT
           RET

CRC3:      MOV       A,B          ;Shift P(X)
           ADD       B
           MOV       B,A
           JC        CRCOUT       ;JMP if MSB = 1           
           JMP       CRCXOR       ;JMP if XOR MSB = 0

