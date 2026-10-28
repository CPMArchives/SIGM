     .XLIST
; KERMIT - KL10 Error-free Reciprocal Micro Interconnect over TTY-lines
; 
;       Program Version 1.0, Kermit Protocol Version 1
;	February 1, 1983
; 
;       Based on the KERMIT Protocol.
; 
;       Copyright (C) 1982,1983 Trustees of Columbia University
;
;       Daphne Tzoar
;       Columbia University Computer Center
;       612 W. 115th St.
;       New York City, NY  10025
; 
;  Special thanks to Frank da Cruz, Bill Catchings, Steve Jensen,
;  Vace Kundakci, and Bernie Eiben for their help and contributions.
 

;  This file is the global data area for all the Kermit modules.
 
 
IBMPC   EQU     1               ; For IBM PC conditional assembly.
STEVE   EQU     0               ; For Steve's homebrew assembly.
 
BELL    EQU     07Q
TAB     EQU     11Q
LF      EQU     12Q
FF      EQU     14Q
CR      EQU     15Q
XON     EQU     21Q
XOFF    EQU     23Q
ESC     EQU     33Q
DEL     EQU     177Q
BS	EQU	08H
 
BIOS    EQU     10H
DOS     EQU     21H
COMM	EQU	14H
KEYB	EQU	16H

CONIN   EQU     01H
CONOUT  EQU     02H
RDRIN   EQU     03H
PUNOUT  EQU     04H
LSTOUT  EQU     05H
DCONIO  EQU     06H
GTIOB   EQU     07H
PRSTR   EQU     09H
CONSTAT EQU     0BH
OPENF   EQU     0FH
CLOSF   EQU     10H
SFIRST  EQU     11H
SNEXT   EQU     12H
DELF    EQU     13H
READF   EQU     14H             ; Read from the file.
WRITEF  EQU     15H
MAKEF   EQU     16H
CFLSZ   EQU     23H
 
DEFESC  EQU     ']'-100Q        ; The default escape character.
 
MAXPKT  EQU     '~'-' '+2Q      ; Maximum size of a packet.
MAXTRY  EQU     05Q             ; Default number of retries on a packet.
IMXTRY  EQU     20Q             ; Default number of retries send initiate.
DRPSIZ  EQU     5EH             ; Default receive packet size.
DSPSIZ  EQU     20H             ; Default send packet size.
DSTIME  EQU     08H             ; Default send time out interval.
DRTIME  EQU     05H             ; Default receive time out interval.
DSPAD   EQU     00H             ; Default send padding.
DRPAD   EQU     00H             ; Default receive padding.
DSPADC  EQU     00H             ; Default send padding char.
DRPADC  EQU     00H             ; Default receive padding char.
DSEOL   EQU     CR              ; Default send EOL char.
DREOL   EQU     CR              ; Default receive EOL char.
DSQUOT  EQU     '#'             ; Default send quote char.
DRQUOT  EQU     '#'             ; Default receive quote char.
 
SOH     EQU     01H             ; Start of header char.
 
BUFSIZ  EQU     80H             ; Size of DMA.
MAXFIL  EQU     50H             ; Maximum number of files allowed.
 
DIASW   EQU     01H             ; Default is diagnostics on.
 
CMKEY   EQU     01H             ; Parse a keyword.
CMIFI   EQU     02H             ; Parse an input file spec (can be wild).
CMOFI   EQU     03H             ; Parse an output file spec.
CMCFM   EQU     04H             ; Parse a confirm.

TIMER	EQU	40H		; Use to issue short beep.
PORT_B	EQU	61H		; Port B address.
B0300	EQU    180H		; Variables for 300 baud, 1200, etc.
B1200	EQU	60H
B1800	EQU	40H
B2400	EQU	30H
B4800	EQU	18H
B9600	EQU	0CH

STACK   SEGMENT PARA STACK 'STACK'
        DW      100 DUP(0)      ; Initialize stack to all zeros.
STK	EQU	THIS WORD
STACK   ENDS
 
DATAS   SEGMENT PARA PUBLIC 'DATAS'
 
        ; Pure storage.
 
versio  db      'CUCCA IBM-PC Kermit-86 - ver 1.0',cr,lf,
	db	'Field Test Version',cr,lf,'$'
kerm    db      'Kermit-86>$'
spmes   db	'Spack:  $'
rpmes 	db	'Rpack:  $'
hibit	db	'Warning - Non Ascii char$'
tmp	db	?
foo	db	'$'
crlf    db      cr,lf,'$'
tmsg1	db	cr,lf,'[Connecting to host,' 
	db	'type Ctrl-]-C to return to PC]',cr,lf,'$'
tmsg2	db	cr,lf,'[Back at micro]',cr,lf,'$'
ermes1  db      cr,lf,'?Unregonized command$'
ermes2  db      cr,lf,'?Illegal character$'
ermes3  db      cr,lf,'?Not confirmed$'
ermes4  db      'Unable to rename file$'
ermes5  db      cr,lf,'?Disk full$'
ermes7  db      '?Unable to receive initiate$'
ermes8  db      '?Unable to receive file name$'
ermes9  db      '?Unable to receive end of file$'
erms10  db      '?Unable to receive data$'
erms11  db      '?Disk full$'
erms14  db      '?Unable to receive an acknowledgement from the host$'
erms15  db      '?Unable to find file$'
erms19  db	'Record length exceeds size of buffer$'
dimsg1  db      '%Bad checksum$'
infms0  db      'Waiting .....$'
infms1  db      'Receiving ...$'
infms2  db      'Sending .....$'
infms3  db      'Completed    $'
infms4  db      'Failed       $'
infms5  db      'Renaming file to $'
 
cfrmes  db      ' Confirm with carriage return $'
; filhlp  db      ' Input file spec (possibly wild) $'
filhlp  db      ' Input file spec $'
;spchar	db	$,&,#,@,!,%,',(,),-,<,>,{,},_,\,^,~,|,`
spchar	db	24H,26H,23H,40H,21H,25H,27H,28H,29H,2DH
	db	3CH,3EH,7BH,7DH,5FH,5CH,5EH,7EH,7CH,60H
escmes  db      cr,lf,'Type the new escape character:  $'
eschlp  db      cr,lf,'Enter literal value (ex: Cntrl ])  $'
tophlp  db      cr,lf,'CONNECT to host on selected port'
        db      cr,lf,'EXIT to DOS'
        db      cr,lf,'HELP by giving this message'
        db      cr,lf,'RECEIVE file from host'
        db      cr,lf,'SEND file to host'
        db      cr,lf,'SET a parameter'
;        db      cr,lf,'SHOW the parameters'
        db      cr,lf,'STATUS of Kermit$'
sethlp  db	cr,lf,'BAUD rate'
	db	cr,lf,'DEBUG'
	db      cr,lf,'ESCAPE character change'
        db      cr,lf,'FILE-WARNING'
	db	cr,lf,'IBM'
        db      cr,lf,'LOCAL-ECHO echoing (half-duplex)'
;        db      cr,lf,'RECEIVE parameter'
;        db      cr,lf,'SEND parameter'
        db      cr,lf,'VT52-EMULATION$'
stshlp  db      cr,lf,'PAD-CHAR'
        db      cr,lf,'PADDING$'
onhlp   db      cr,lf,'OFF      ON$'
yeshlp  db      cr,lf,'NO       YES$'
bdhlp	db	cr,lf,'300   1200   1800   2400   4800   9600$'
inthlp  db      cr,lf,'?  This message'
        db      cr,lf,'C  Close the connection'
        db      cr,lf,'S  Status of the connection'
        db      cr,lf,'Typing the escape character will send it to the host'
        db      cr,lf,cr,lf,'Command>$'
locst   db      cr,lf,'Local echo on$'
remst   db      cr,lf,'Local echo off$'
vtemst  db      cr,lf,'VT52 emulation on$'
novtst  db      cr,lf,'VT52 emulation off$'
ibmst   db      cr,lf,'IBM on$'
noibm   db      cr,lf,'IBM off$'
b03st	db	cr,lf,'Baud rate is 300$'
b12st	db	cr,lf,'Baud rate is 1200$'
b18st	db	cr,lf,'Baud rate is 1800$'
b24st	db	cr,lf,'Baud rate is 2400$'
b48st	db	cr,lf,'Baud rate is 4800$'
b96st	db	cr,lf,'Baud rate is 9600$'
debon	db	cr,lf,'Debug mode on$'
deboff	db	cr,lf,'Debug mode off$'	
flwon	db	cr,lf,'File Warning on$'
flwoff	db	cr,lf,'File Warning off$'
 
 
outlin  db      cr,lf,'                CUCCA IBM-PC Kermit-86 V1.0',
	db	'  Field Test Version',cr,lf
        db      cr,lf,'Number of packets        (hex)'
        db      cr,lf,'Number of retries        (hex)'
        db      cr,lf,'File name $'
delstr  db      10O,' ',10O,10O,'$'     ; Delete string.
clrspc  db      ' ',10O,'$'             ; Clear space.
escspc	db	10O,' ',10O,'$'		; Clear escape.
clrlin  db      cr,'$'			; Clear line (just the cr part).
prsp	db	' $'			; Print a space.
scrhi	dw	0434H			; Err when 8th bit is on.
scrrpr	dw	0700H			; Prompt when Kermit ends.
screrr  dw      0600H		        ; Place for error msgs. 
scrfln  dw      050CH			; Place for file name.
scrnrt  dw      0415H		        ; Place for number of retries.
scrnp   dw      0315H 		        ; Place for number of packets.
scrfr	dw	0600H			; Rename file.
scrst	dw	0334H			; Place for status.
scrsp	dw	0800H			; Place for send packet.
scrrp	dw	0A00H			; Place for receive packet.
ttab	label	word			; Table for cursor movement.
ta	dw	curup			; Cursor up.
tb	dw	curdwn			; Cursor down.
tc	dw	currt  			; Cursor right.
td	dw	curlft			; Cursor left.
te	dw	curskp			; Clear display.
tf	dw	curskp			; Enter graphics mode.
tg	dw	curskp			; Exit graphics mode.
th	dw	curhm			; Cursor home.
ti	dw	curup			; Reverse line feed.
tj	dw	curscr			; Clear to end of screen.
tk	dw	curln			; Clear to end of line.
tl	dw	inslin			; Insert line.
tm	dw	dellin			; Delete line.	
 
        ; COMND tables

comtab  db      07H             ; seven entries.
        db      07H,'CONNECT$'
        dw      telnet
        db      04H,'EXIT$'
        dw      exit
        db      04H,'HELP$'
        dw      help
        db      07H,'RECEIVE$'
        dw      read
        db      04H,'SEND$'
        dw      send
        db      03H,'SET$'
        dw      setcom
        db      06H,'STATUS$'
        dw      status

 
settab  db      07H             ; seven entries.
	db	04H,'BAUD$'
	dw	baudst
	db	05H,'DEBUG$'
	dw	debst
        db      06H,'ESCAPE$'
        dw      escape
	db	0CH,'FILE-WARNING$'
	dw	filwar
        db      03H,'IBM$'
        dw      ibmset
        db      0AH,'LOCAL-ECHO$'
        dw      lcal
        db      0EH,'VT52-EMULATION$'
        dw      vt52em
 
ontab   db      02H             ; Two entries.
        db      02H,'ON$'
        dw      01H
        db      03H,'OFF$'
        dw      00H
 
yestab  db      02H             ; Two entries.
        db      02H,'NO$'
        dw      00H
        db      03H,'YES$'
        dw      01H

bdtab	db	06H		; Six entries.
	db	04H,'1200$'
	dw	B1200
	db	04H,'1800$'
	dw	B1800
	db	04H,'2400$'
	dw	B2400
	db	03H,'300$'
	dw	B0300
	db	04H,'4800$'
	dw	B4800
	db	04H,'9600$'
	dw	B9600
 
; COMND storage
 
cmer00  db      cr,lf,'?Program error   Invalid COMND call$'
cmer01  db      cr,lf,'?Ambiguous$'
cmer02  db      cr,lf,'?Illegal input file spec$'
cmer03	db	cr,lf,'?Unrecognized instruction$'
cmin00  db      ' Confirm with carriage return$'
cmcrlf  db      cr,lf,'$'
 
cmstat  db      ?               ; What is presently being parsed.
cmaflg  db      ?               ; Non-zero when an action char has been found.
cmccnt  db      ?               ; Non-zero if a significant char is found.
cmsflg  db      ?               ; Non-zero when the last char was a space.
cmostp  dw      ?               ; Old stack pointer for reparse.
cmrprs  dw      ?               ; Address to go to on reparse.
cmprmp  dw      ?               ; Address of prompt.
cmptab  dw      ?               ; Address of present keyword table.
cmhlp   dw      ?               ; Address of present help.
cmdbuf  db      80H DUP(?)      ; Buffer for command parsing.
cmfcb   dw      ?               ; Pointer to FCB.
cmfcb2  dw      ?               ; Pointer to position in FCB.
cmcptr  dw      ?               ; Pointer for next char input.
cmdptr  dw      ?               ; Pointer into the command buffer.
cmsiz	dw	?		; Size info of user input.
cmkptr  dw      ?               ; Pointer to keyword.
cmsptr  dw      ?               ; Place to save a pointer.
cmchr	db	?		; Save char when checking ambiguity.
 
; Program storage.
 
oldstk  dw      ?               ; Storage for system stack.
oldsts  dw      ?               ; System stack segment.
ssp	dw	0		; Save SP in Telnet.
bufhex	dw	80H
filsiz	dd	0		; Double word for filesize (in bytes.)
eoflag  db      ?               ; EOF flag; non-zero on EOF.
debug	db	0		; Debugging mode (default off).
hierr	db	0		; Non-ascii char (non-zero if yes).
filflg  db      ?               ; Non-zero when nothing in DMA buffer.
ecoflg  db      0               ; Local echo flag (default off).
escflg  db      0               ; Escape flag (start off).
vtflg   db      1               ; VT52 emulation flag (default on).
flwflg  db      0               ; File warning flag (default off).
ibmflg  db      0               ; IBM flag (default off).
extflg  db      0               ; Exit flag (default off).
escchr  db      defesc          ; Storage for the escape character.
incnt	dw	?		; Number of chars read in from port.
chrcnt  dw      ?               ; Number of chars in the file buffer.
filcnt  dw      ?               ; Number of chars left to fill.
outpnt  dw      ?               ; Position in packet.
bufpnt  dw      ?               ; Position in file buffer.
fcbptr  dw      ?               ; Position in FCB.
datptr  dw      ?               ; Position in packet data buffer.
cbfptr  dw      ?               ; Position in character buffer.
pktptr  dw      ?               ; Poistion in receive packet.
siz     dw      ?               ; Size of data from gtchr.
baud	dw	B4800		; Use default of 4800.
spsiz   db      dspsiz          ; Send packet size.
rpsiz   db      drpsiz          ; Receive packet size.
stime   db      dstime          ; Send time out.
rtime   db      drtime          ; Receive time out.
spad    db      dspad           ; Send padding.
rpad    db      drpad           ; Receive padding.
spadch  db      dspadc          ; Send padding char.
rpadch  db      drpadc          ; Receive padding char.
seol    db      dseol           ; Send EOL char.
reol    db      dreol           ; Receive EOL char.
squote  db      dsquot          ; Send quote char.
rquote  db      drquot          ; Receive quote char.
pktnum  dw      ?               ; Packet number.
numpkt  dw      ?               ; Total number of packets sent.
numrtr  dw      ?               ; Total number of retries.
numtry  db      ?               ; Number of tries on this packet.
oldtry  db      ?               ; Number of tries on previous packet.
state   db      ?               ; Present state of the automaton.
packet  db      ?,?,?,?         ; Packet (data is part of it).
data    db      5AH DUP(?)      ; Data and checksum field of packet.
recpkt  db      60H DUP(?)      ; Receive packet storage (use the following).
filbuf  db      60H DUP(?)      ; Character buffer.
fcb	db	25H DUP(?)	; Use as our FCB.
buff	db	80H DUP(?)	; Use as our DAT.
rdbuf	db	80H DUP(?)
cnt	dw	0
temp	dw	0
temp1   dw      ?               ; Temporary storage.
temp2   dw      ?
temp3   dw      ?
temp4   dw      ?
argblk  dw      ?               ; For subroutine arguments.
argbk1  dw      ?
argbk2  dw      ?
argbk3  dw      ?
fcbnum  dw      ?               ; Number of FCB's left in the list.
 
DATAS   ENDS                    ; End data segment
 
 
MAIN    SEGMENT PARA PUBLIC 'MAIN'
START   PROC  FAR
        ASSUME  CS:MAIN,DS:DATAS,SS:STACK,ES:NOTHING
 
        push ds                 ; Save system data area.
        sub ax,ax               ; Get a zero.
        push ax                 ; Put zero return addr on stack.
 
        call cmblnk             ; Clear the screen.
	call locate

        mov ax,datas            ; Initialize DS.
        mov ds,ax
	sub ax,ax

        mov oldstk,sp           ; Save old stack pointer.
;        mov ax,ss
;        mov oldsts,ax


;        mov ax,stack            ; Initialize SS.
;        mov ss,ax
;        mov sp,offset ss:stk
;        sub ax,ax

        mov ah,prstr            ; Print the version header.
        mov dx,offset versio
        int dos

	mov ah,1AH		; Set disk transfer address.
	mov dx,offset buff
	int dos

	mov dx,03FBH		; LCR -- Initialize baud rate.
	in al,dx
	mov bl,al
	or ax,80H
	out dx,al
	mov dx,03F8H
	mov ax,baud
	out dx,al
	inc dx
	mov al,ah
	out dx,al
	mov dx,03FBH
	mov al,bl
	out dx,al



; This is the main KERMIT loop.  It prompts for and gets the users commands.

kermit: mov dx,offset kerm
        call prompt             ; Prompt the user.
        mov dx,offset comtab
        mov bx,offset tophlp
        mov ah,cmkey
        call comnd
         jmp kermt2
        call bx                 ; Call the routine returned.
         jmp kermt3
        cmp extflg,0            ;  Check if the exit flag is set.
        jne finish              ;  If so jump to FINISH.
        jmp kermit              ; Do it again.
 
kermt2: mov ah,prstr
        mov dx,offset ermes1    ;  Give an error.
        int dos
        jmp kermit

kermt3: mov ah,prstr
        mov dx,offset ermes3    ;  Give an error.
        int dos
        jmp kermit
 
finish: 
; 	 mov ax,oldsts           ; Restore the old stack.
;        mov ss,ax
        mov sp,oldstk
        ret
 
START   ENDP
 
 
; These are some utility routines.
 
;       Abort
 
ABORT   PROC    NEAR
        mov state,'A'           ; Otherwise abort.
        ret
ABORT   ENDP
 
;       NAK
 
NAK     PROC    NEAR
        mov ax,pktnum           ; Get the packet number we're waiting for.
        mov argblk,ax
        mov argbk1,0
        mov ah,'N'              ; NAK that packet.
        call spack
        ret                     ; Go around again.
NAK     ENDP

; Position cursor for an error message.

ERPOS	PROC 	NEAR
	mov ah,2
	mov bh,0
	mov dx,screrr
	int bios
	ret
ERPOS	ENDP

; Position cursor for number of retries message.

RTPOS	PROC 	NEAR
	mov ah,2
	mov bh,0
	mov dx,scrnrt
	int bios
	ret
RTPOS	ENDP

; Print err message that found a non-standard-Ascii char in the file.

BITERR	PROC	NEAR
	push bx
	mov ah,2
	mov bh,0
	mov dx,scrhi
	int bios
	mov ah,prstr
	mov dx,offset hibit
	int dos
	pop bx
	ret
BITERR	ENDP		
 
;       This routine sets up the data for init packet (either the
;       Send_init or ACK packet).
 
RPAR    PROC    NEAR
        mov ah,rpsiz            ; Get the receive packet size.
        add ah,' '              ; Add a space to make it printable.
        mov [bx],ah             ; Put it in the packet.
        mov ah,rtime            ; Get the receive packet time out.
        add ah,' '              ; Add a space.
        mov 1[bx],ah            ; Put it in the packet.
        mov ah,rpad             ; Get the number of padding chars.
        add ah,' '
        mov 2[bx],ah            ; Put it in the packet.
        mov ah,rpadch           ; Get the padding char.
        add ah,100O             ; Uncontrol it.
        and ah,7FH
        mov 3[bx],ah            ; Put it in the packet.
        mov ah,reol             ; Get the EOL char.
        add ah,' '
        mov 4[bx],ah            ; Put it in the packet.
        mov ah,rquote           ; Get the quote char.
        mov 5[bx],ah            ; Put it in the packet.
        mov ah,06H              ; Six pieces of data.
        ret
RPAR    ENDP
 
;       This routine reads in all the send_init packet information.
 
SPAR    PROC    NEAR
        mov temp4,ax            ; Save the number of arguments.
        mov ah,[bx]             ; Get the max packet size.
        sub ah,' '              ; Subtract a space.
        mov spsiz,ah            ; Save it.
        mov ax,temp4
        cmp al,3                ; Fewer than three pieces?
        jge spar1
        ret                     ; If so we are done.
spar1:  mov ah,2[bx]            ; Get the number of padding chars.
        sub ah,' '
        mov spad,ah
        mov ax,temp4
        cmp al,4                ; Fewer than four pieces?
        jge spar2
        ret                     ; If so we are done.
spar2:  mov ah,3[bx]            ; Get the padding char.
        add ah,100O             ; Re-controlify it.
        and ah,7FH
        mov spadch,ah
        mov ax,temp4
        cmp al,5                ; Fewer than five pieces?
        jge spar3
        ret                     ; If so we are done.
spar3:  mov ah,4[bx]            ; Get the EOL char.
        sub ah,' '
        mov seol,ah
        mov ax,temp4
        cmp al,6                ; Fewer than six pieces?
        jge spar4
        ret                     ; If so we are done.
spar4:  mov ah,5[bx]            ; Get the quote char.
        mov squote,ah
        ret
SPAR    ENDP
 
 
;       Initialize buffers and clear line.
 
INIT    PROC    NEAR
	call cmblnk
	call locate
        mov ah,prstr            ; Put statistics headers on the screen.
        mov dx,offset outlin
        int dos
        call init1
        ret
INIT    ENDP
 
INIT1   PROC    NEAR
        mov chrcnt,bufsiz       ;* Number of chars left.
        mov bufpnt,offset buff         ; Addr for beginning.
        ret
INIT1   ENDP

;  Clear out the old filename on the screen. 

CLRFLN	PROC	NEAR
	mov ah,2
	mov bh,0
	mov dx,scrfln
	int bios
	mov ax,0920H			; Clear out the old filename.
	mov bx,7
	mov cx,12
	int bios
	ret
CLRFLN	ENDP

;       RECEIVE command
 
READ    PROC    NEAR
        mov ah,cmcfm
        call comnd              ; Get a confirm.
         jmp r
        call init               ; Clear the line and initialize the buffers.
        mov numpkt,0            ; Set the number of packets to zero.
        mov numrtr,0            ; Set the number of retries to zero.
        mov pktnum,0            ; Set the packet number to zero.
        mov numtry,0            ; Set the number of tries to zero.
        call rtpos		; Position cursor.
        mov ax,numrtr
        call nout               ; Write the number of retries.
        mov state,'R'           ; Set the state to receive initiate.
read2:  mov ah,2		; Position cursor.
	mov dx,scrst
	mov bh,0
	int bios
	mov ah,prstr            ; Be informative.
        mov dx,offset infms1
        int dos
	mov ah,2
	mov dx,scrnp
	mov bh,0
	int bios
        mov ax,numpkt
        call nout               ; Write the number of packets.
        mov ah,state            ; Get the state.
        cmp ah,'D'              ; Are we in the data send state?
        jne read3
        call rdata
        jmp read2
read3:  cmp ah,'F'              ; Are we in the file receive state?
        jne read4
        call rfile              ; Call receive file.
        jmp read2
read4:  cmp ah,'R'              ; Are we in the receive initiate state?
        jne read5
        call rinit
        jmp read2
read5:  cmp ah,'C'              ; Are we in the receive complete state?
        jne read6
	mov ah,2		; Position cursor.
	mov dx,scrst
	mov bh,0
	int bios
        mov dx,offset infms3    ; Plus a little cuteness.
        mov ah,prstr
        int dos
	mov ah,2
	mov dx,scrrpr		; Put prompt here.
	mov bh,0
	int bios
        jmp rskp
read6:  mov ah,2		; Position cursor.
	mov dx,scrst
	mov bh,0
	int bios
	mov dx,offset infms4    ; Plus a little cuteness.
        mov ah,prstr
        int dos
	mov ah,2
	mov dx,scrrpr
	mov bh,0
	int bios
        jmp rskp
READ    ENDP
 
 
;       Receive routines
 
;       Receive init
 
RINIT   PROC    NEAR
        mov ah,numtry           ; Get the number of tries.
        cmp ah,imxtry           ; Have we reached the maximum number of tries?
        jl rinit2
	call erpos		; Position cursor.
        mov dx,offset ermes7
        mov ah,prstr
        int dos                 ; Print an error message.
        jmp abort               ; Change the state to abort.
rinit2: inc ah                  ; Increment it.
        mov numtry,ah           ; Save the updated number of tries.
        call rpack              ; Get a packet.
         jmp nak                ;  Trashed packet: nak, retry.
        cmp ah,'S'              ; Is it a send initiate packet?
        jne rinit3              ; If not see if its an error.
        mov ah,numtry           ; Get the number of tries.
        mov oldtry,ah           ; Save it.
        mov numtry,0            ; Reset the number of tries.
        mov ax,argblk           ; Returned packet number.  (Synchronize them.)
        inc ax                  ; Increment it.
        and ax,3FH              ; Turn off the two high order bits.
        mov pktnum,ax           ; Save modulo 64 of the number.
        mov bx,numpkt
        inc bx                  ; Increment the number of packets.
        mov numpkt,bx
        mov ax,argbk1           ; Get the number of arguments received.
        mov bx,offset data      ; Get a pointer to the data.
        call spar               ; Get the data into the proper variables.
        mov bx,offset data      ; Get a pointer to our data block.
        call rpar               ; Set up the receive parameters.
	xchg ah,al
	mov ah,0
        mov argbk1,ax           ; Store the returned number of arguments.
        mov ah,'Y'              ; Acknowledge packet.
        call spack              ; Send the packet.
        mov ah,'F'              ; Set the state to file send.
        mov state,ah
        ret
rinit3: cmp ah,'E'              ; Is it an error packet?
        jne rinit4
        call error
rinit4: jmp abort
RINIT   ENDP
 

;       Receive file
 
RFILE   PROC    NEAR
        cmp numtry,maxtry       ; Have we reached the maximum number of tries?
        jl rfile1
	call erpos		; Position cursor.
        mov dx,offset ermes8
        mov ah,prstr
        int dos                 ; Print an error message.
        jmp abort               ; Change the state to abort.
rfile1: inc numtry              ; Save the updated number of tries.
        call rpack              ; Get a packet.
         jmp nak                ;  Trashed packet: nak, retry.
        cmp ah,'S'              ; Is it a send initiate packet?
        jne rfile2              ;  No, try next type.
        cmp oldtry,imxtry       ; Have we reached the maximum number of tries?
        jl rfil12               ; If not proceed.
	call erpos		; Position cursor.
        mov dx,offset ermes7
        mov ah,prstr
        int dos                 ; Print an error message.
        jmp abort               ; Change the state to abort.
rfil12: inc oldtry              ; Save the updated number of tries.
        mov ax,pktnum           ; Get the present packet number.
        dec ax                  ; Decrement.
        cmp ax,argblk           ; Is the packet's number one less than now?
        je rfil13
        jmp nak                 ; No, NAK and try again.
rfil13: call rtpos              ; Position cursor.
        inc numrtr              ; Increment the number of retries.
        mov ax,numrtr
        call nout               ; Write the number of retries.
        mov numtry,0            ; Reset the number of tries.
        mov bx,offset data      ; Get a pointer to our data block.
        call rpar               ; Set up the parameter information.
	xchg ah,al
	mov ah,0
        mov argbk1,ax           ; Save the number of arguments.
        mov ah,'Y'              ; Acknowledge packet.
        call spack              ; Send the packet.
        ret
rfile2: cmp ah,'Z'              ; Is it an EOF packet?
        jne rfile3              ;  No, try next type.
        cmp oldtry,maxtry       ; Have we reached the maximum number of tries?
        jl rfil21               ; If not proceed.
        call erpos              ; Position cursor.
        mov dx,offset ermes9
        mov ah,prstr
        int dos                 ; Print an error message.
        jmp abort               ; Change the state to abort.
rfil21: inc oldtry              ; Increment it.
        mov ax,pktnum           ; Get the present packet number.
        dec ax                  ; Decrement.
        cmp ax,argblk           ; Is the packet's number one less than now?
        je rfil24
        jmp nak                 ; No, NAK and try again.
rfil24: call rtpos              ; Position cursor.
        inc numrtr              ; Increment the number of retries
        mov ax,numrtr
        call nout               ; Write the number of retries.
        mov numtry,0
        mov argbk1,0            ; No data.  (The packet number is in argblk.)
        mov ah,'Y'              ; Acknowledge packet.
        call spack              ; Send the packet.
        ret
rfile3: cmp ah,'F'              ; Start of file?
        jne rfile4
        mov ax,argblk           ; Get the packet number.
        cmp ax,pktnum           ; Is it the right packet number?
        je rfil32
        jmp nak                 ; No, NAK it and try again.
rfil32: inc ax                  ; Increment the packet number.
        and ax,3FH              ; Turn off the two high order bits.
        mov pktnum,ax           ; Save modulo 64 of the number.
        inc numpkt              ; Increment the number of packets.
        call gofil              ; Get a file to write to.
         jmp abort
        call init1              ; Initialize all the buffers.
        mov ah,numtry           ; Get the number of tries.
        mov oldtry,ah           ; Save it.
        mov numtry,0            ; Reset the number of tries.
        mov argbk1,0            ; No data.  (The packet number is in argblk.)
        mov ah,'Y'              ; Acknowledge packet.
        call spack              ; Send the packet.
        mov state,'D'           ; Set the state to data receive.
        ret
rfile4: cmp ah,'B'              ; End of transmission.
        jne rfile5
        mov ax,pktnum
        cmp ax,argblk           ; Do we match?
        je rfil41
        jmp nak                 ; No, NAK it and try again.
rfil41: mov argbk1,0            ; No data.  (Packet number already in argblk).
        mov ah,'Y'              ; Acknowledge packet.
        call spack              ; Send the packet.
        mov state,'C'           ; Set the state to complete.
        ret
rfile5: cmp ah,'E'              ; Is it an error packet.
        jne rfile6
        call error
rfile6: jmp abort
RFILE   ENDP
 
 
;       Receive data
 
RDATA   PROC    NEAR
        cmp numtry,maxtry       ; Get the number of tries.
        jl rdata1
        call erpos              ; Position cursor.
        mov dx,offset erms10
        mov ah,prstr
        int dos                 ; Print an error message.
        jmp abort               ; Change the state to abort.
rdata1: inc numtry              ; Save the updated number of tries.
        call rpack              ; Get a packet.
         jmp nak                ;  Trashed packet: nak, retry.
        cmp ah,'D'              ; Is it a data packet?
        jne rdata2              ;  No, try next type.
rdat11: mov ax,pktnum           ; Get the present packet number.
        cmp ax,argblk           ; Is the packet's number correct?
        jz rdat14
        cmp oldtry,maxtry       ; Have we reached the maximum number of tries?
        jl rdat12               ; If not proceed.
	call erpos              ; Position cursor.
        mov dx,offset erms10
        mov ah,prstr
        int dos                 ; Print an error message.
        jmp abort               ; Change the state to abort.
rdat12: inc oldtry              ; Save the updated number of tries.
        dec pktnum              ; Decrement present packet number.
        mov ax,pktnum
        cmp ax,argblk           ; Is the packet's number one less than now?
        je rdat13
        jmp nak                 ; No, NAK it and try again.
rdat13: call rtpos              ; Position cursor.
        inc numrtr              ; Increment the number of retries
        mov ax,numrtr
        call nout               ; Write the number of retries.
        mov numtry,0            ; Reset number of tries.
        mov argbk1,0            ; No data.  (The packet number is in argblk.)
        mov ah,'Y'              ; Acknowledge packet.
        call spack              ; Send the packet.
        ret
rdat14: inc ax                  ; Increment the packet number.
        and ax,3FH              ; Turn off the two high order bits.
        mov pktnum,ax           ; Save modulo 64 of the number.
        inc numpkt              ; Increment the number of packets.
        mov ah,numtry           ; Get the number of tries.
        mov oldtry,ah           ; Save it.
        mov ax,argbk1           ; Get the length of the data.
        call ptchr
         jmp abort              ;  Unable to write out chars; abort.
        mov numtry,0            ; Reset the number of tries.
        mov argbk1,0            ; No data.  (Packet number still in argblk.)
        mov ah,'Y'              ; Acknowledge packet.
        call spack              ; Send the packet.
        ret
rdata2: cmp ah,'F'              ; Start of file?
        jne rdata3              ;  No, try next type.
        cmp oldtry,maxtry       ; Have we reached the maximum number of tries?
        jl rdat21               ; If not proceed.
	call erpos		; Position cursor.
        mov dx,offset ermes8
        mov ah,prstr
        int dos                 ; Print an error message.
        jmp abort               ; Change the state to abort.
rdat21: inc oldtry              ; Save the updated number of tries.
        mov ax,pktnum
        cmp ax,argblk           ; Is the packet's number one less than now?
        je rdat22
        jmp nak                 ; No, NAK it and try again.
rdat22: call rtpos              ; Position cursor.
        inc numrtr              ; Increment the number of retries
        mov ax,numrtr
        call nout               ; Write the number of retries.
        mov numtry,0            ; Reset number of tries.
        mov argbk1,0            ; No data.  (The packet number is in argblk.)
        mov ah,'Y'              ; Acknowledge packet.
        call spack              ; Send the packet.
        ret
rdata3: cmp ah,'Z'              ; Is it a EOF packet?
        jne rdata4              ; Try and see if its an error.
        mov ax,pktnum           ; Get the present packet number.
        cmp ax,argblk           ; Is the packet's number correct?
        je rdat32
        jmp nak                 ; No, NAK it and try again.
rdat32: inc ax                  ; Increment the packet number.
        and ax,3FH              ; Turn off the two high order bits.
        mov pktnum,ax           ; Save modulo 64 of the number.
        inc numpkt
rdat33: mov bx,bufpnt           ; Get the dma pointer.
	mov ax,80H
        sub ax,chrcnt           ; Get the number of chars left in the DMA.
        mov cl,'Z'-100O         ; Put in a ^Z for EOF.
        mov [bx],cl
	inc ax
	dec chrcnt
	mov cx,chrcnt
	mov temp,cx
	inc bx
rdt3:	inc ax
	cmp ax,80H
	jg rdat35		; Pad till full.
	mov cl,0		; Use nulls.
	mov [bx],cl
	inc bx
        jmp rdt3
rdat35: call outbuf             ; Output the last buffer.
         jmp abort              ;  Give up if the disk is full.
	call fixfcb
        mov ah,closf            ; Close up the file.
        mov dx,offset fcb
        int dos
        mov ah,numtry           ; Get the number of tries.
        mov oldtry,ah           ; Save it.
        mov numtry,0            ; Reset the number of tries.
        mov argbk1,0            ; No data.  (The packet number is in argblk.)
        mov ah,'Y'              ; Acknowledge packet.
        call spack              ; Send the packet.
        mov state,'F'
        ret
rdata4: cmp ah,'E'                      ; Is it an error packet.
        je rdata5
        call error
rdata5: jmp abort
RDATA   ENDP

FIXFCB  PROC	NEAR	
	mov bx,offset fcb+18
	mov di,offset filsiz
	mov ax,[bx]
	mov [di],ax
	mov bx,offset fcb+16
	mov ax,[bx]
	mov 2[di],ax
	mov ax,temp		; Get number of chars in last buffer full.
	sub filsiz+2,ax		; Get real file size.
	sbb filsiz,0
	mov bx,offset fcb+18
	mov di,offset filsiz
	mov ax,[di]
	mov [bx],ax
	mov bx,offset fcb+16
	mov ax,2[di]
	mov [bx],ax
	ret
FIXFCB	ENDP
 

;       Send command
 
SEND    PROC    NEAR
        mov ah,cmifi            ; Parse an input file spec.
        mov dx,offset fcb       ; Give the address for the FCB.
        call comnd
         jmp r                  ;  Give up on bad parse.
send1:  mov ah,cmcfm
        call comnd              ; Get a confirm.
         jmp r                  ;  Didn't get a confirm.
send11: mov fcbnum,0            ; Zero the fcb list number.
        mov ah,sfirst           ; Get the first file.
        mov dx,offset fcb
        int dos
        cmp al,0FFH             ; Any found?
        jne send12
	mov ah,prstr
	mov dx,offset crlf
	int dos
        mov ah,prstr
        mov dx,offset erms15
        int dos
        ret
;* This must all be redone for MS-DOS.  Hopefully wild card file stepping
;* in MS-DOS works.  If so most of the following is unnecessary.
send12: 
;*
        call init               ; Clear the line and initialize the buffers.
        mov pktnum,0            ; Set the packet number to zero.
        mov numtry,0            ; Set the number of tries to zero.
        mov numpkt,0            ; Set the number of packets to zero.
        mov numrtr,0            ; Set the number of retries to zero.
        call rtpos              ; Position cursor.
        mov ax,0
        call nout               ; Write the number of retries.
        mov state,'S'           ; Set the state to receive initiate.
send2:  mov ah,2                ; Position cursor.
	mov bh,0
	mov dx,scrst
	int bios
        mov ah,prstr            ; Be informative.
        mov dx,offset infms2
        int dos
	mov ah,2
	mov dx,scrnp
	mov bh,0
	int bios
        mov ax,numpkt
        call nout               ; Write the packet number.
        cmp state,'D'           ; Are we in the data send state?
        jne send3
        call sdata
        jmp send2
send3:  cmp state,'F'           ; Are we in the file send state?
        jne send4
        call sfile              ; Call send file.
        jmp send2
send4:  cmp state,'Z'           ; Are we in the EOF state?
        jne send5
        call seof
        jmp send2
send5:  cmp state,'S'           ; Are we in the send initiate state?
        jne send6
        call sinit
        jmp send2
send6:  cmp state,'B'           ; Are we in the eot state?
        jne send7
        call seot
        jmp send2
send7:  cmp state,'C'           ; Are we in the send complete state?
        jne send8
	mov ah,2                ; Position cursor.
	mov dx,scrst
	mov bh,0
	int bios
        mov dx,offset infms3    ; Plus a little cuteness.
        mov ah,prstr
        int dos
	mov ah,2
	mov dx,scrrpr
	mov bh,0
	int bios
        jmp rskp
send8:  mov ah,2                ; Position cursor.
	mov dx,scrst
	mov bh,0
	int bios
        mov dx,offset infms4    ; Plus a little cuteness.
        mov ah,prstr
        int dos
	mov ah,2
	mov dx,scrrpr
	mov bh,0
	int bios
        jmp rskp
SEND    ENDP
 
 
;       Send routines
 
;       Send initiate
 

SINIT   PROC    NEAR
        cmp numtry,imxtry       ; Have we reached the maximum number of tries?
        jl sinit2
	call erpos
        mov dx,offset erms14
        mov ah,prstr
        int dos                 ; Print an error message.
        jmp abort               ; Change the state to abort.
sinit2: inc numtry              ; Save the updated number of tries.
        mov bx,offset data      ; Get a pointer to our data block.
        call rpar               ; Set up the parameter information.
	xchg ah,al
	mov ah,0
        mov argbk1,ax           ; Save the number of arguments.
        mov ax,numpkt           ; Get the packet number.
        mov argblk,ax
        mov ah,'S'              ; Send initiate packet.
        call spack              ; Send the packet.
        call rpack              ; Get a packet.
         jmp r                  ;  Trashed packet don't change state, retry.
        cmp ah,'Y'              ; ACK?
        jne sinit3              ; If not try next.
        mov ax,pktnum           ; Get the packet number.
        cmp ax,argblk           ; Is it the right packet number?
        je sini22
        ret                     ; If not try again.
sini22: inc ax                  ; Increment the packet number.
        and ax,3FH              ; Turn off the two high order bits.
        mov pktnum,ax           ; Save modulo 64 of the number.
        inc numpkt              ; Increment the number of packets.
        mov ax,argbk1           ; Get the number of pieces of data.
        mov bx,offset data      ; Pointer to the data.
        call spar               ; Read in the data.
        mov ah,numtry           ; Get the number of tries.
        mov oldtry,ah           ; Save it.
        mov numtry,0            ; Reset the number of tries.
        mov state,'F'           ; Set the state to file send.
        call getfil             ; Open the file.
         jmp abort              ;  Something is wrong, die.
        ret
sinit3: cmp ah,'N'              ; NAK?
        jne sinit4              ; If not see if its an error.
        call rtpos              ; Position cursor.
        inc numrtr              ; Increment the number of retries
        mov ax,numrtr
        call nout               ; Write the number of retries.
        mov ax,pktnum           ; Get the present packet number.
        inc ax                  ; Increment.
        cmp ax,argblk           ; Get the packet's number.
        je sini32
        ret                     ; If not assume its for this packet, go again.
sini32: mov numtry,0            ; Reset number of tries.
        mov state,'F'           ; Set the state to file send.
        ret
sinit4: cmp ah,'E'              ; Is it an error packet.
        jne sinit5
        call error
sinit5: jmp abort
SINIT   ENDP
 


;       Send file header
 
SFILE   PROC    NEAR
        cmp numtry,maxtry       ; Have we reached the maximum number of tries?
        jl sfile1
	call erpos
        mov dx,offset erms14
        mov ah,prstr
        int dos                 ; Print an error message.
        jmp abort               ; Change the state to abort.
sfile1: inc numtry              ; Increment it.
        mov datptr,offset data  ; Get a pointer to our data block.
	mov bx,offset fcb+1		; Pointer to file name in FCB.
	mov fcbptr,bx		; Save position in FCB.
	mov cl,0		; Counter for chars in file name.
	mov ch,0		; Counter for number of chars in FCB.
sfil11:	cmp ch,8H		; Ninth char?
	jne sfil12
	mov ah,'.'
	mov bx,datptr
	mov [bx],ah		; Put dot in data packet.	
	inc bx
	mov datptr,bx		; Save new position in data packet.
	inc cl
sfil12:	inc ch
	cmp ch,0CH		; Twelve?
	jns sfil13
	mov bx,fcbptr
	mov ah,[bx]		; Get char of filename.
	inc bx
	mov fcbptr,bx		; Save position in FCB.
	cmp ah,'!'		; Is it a good char?
	jl sfil11		; If not, get the next.
	mov bx,datptr
	mov [bx],ah		; Put char in data buffer.
	inc cl			; Increment counter.
	inc bx
	mov datptr,bx		; Save new position. 
	jmp sfil11		; Get another char.
sfil13: mov ch,0
	mov argbk1,cx		; Save number of char in filename.
	mov bx,datptr
	mov ah,'$'
	mov [bx],ah		; Put dollar sign for printing.
	mov ah,2
	mov dx,scrfln	; Put cursor in proper place.
	mov bh,0
	int bios
	call clrfln
	mov ah,prstr
	mov dx,offset data	; Print file name.
	int dos

        mov ax,pktnum           ; Get the packet number.
        mov argblk,ax
        mov ah,'F'              ; File header packet.
        call spack              ; Send the packet.
        call rpack              ; Get a packet.
         jmp r                  ;  Trashed packet don't change state, retry.
        cmp ah,'Y'              ; ACK?
        jne sfile2              ; If not try next.
        mov ax,pktnum           ; Get the packet number.
        cmp ax,argblk
        je sfil14
        ret                     ; If not hold out for the right one.
sfil14: inc ax                  ; Increment the packet number.
        and ax,3FH              ; Turn off the two high order bits.
        mov pktnum,ax           ; Save modulo 64 of the number.
        inc numpkt              ; Increment the number of packets.
        mov ah,numtry           ; Get the number of tries.
        mov oldtry,ah           ; Save it.
        mov numtry,0            ; Reset the number of tries.
;* More file I/O.  Anything to do with the CP/M FCB must be checked for MS-DOS.
sfil15: mov ah,0                ; Get a zero.
        mov bx,offset fcb
        add bx,20H
        mov [bx],ah             ; Set the record number to zero.
        mov eoflag,ah           ; Indicate not EOF.
        mov ah,0FFH
        mov filflg,ah           ; Indicate file buffer empty.
        call gtchr
         jmp sfil16             ; Error go see if its EOF.
        jmp sfil17              ; Got the chars, proceed.
sfil16: cmp ah,0FFH             ; Is it EOF?
        je sfl161
        jmp abort               ; If not give up.
sfl161: mov ah,'Z'              ; Set the state to EOF.
        mov state,ah
        ret
sfil17: mov siz,ax
;*
        mov state,'D'           ; Set the state to data send.
        ret
sfile2: cmp ah,'N'              ; NAK?
        jne sfile3              ; Try if error packet.
        call rtpos              ; Position cursor.
        inc numrtr              ; Increment the number of retries
        mov ax,numrtr
        call nout               ; Write the number of retries.
        mov ax,pktnum           ; Get the present packet number.
        inc ax                  ; Increment.
        cmp ax,argblk           ; Is the packet's number one more than now?
        jz sfil14               ; Just as good as a ACK; go to the ACK code.
        ret                     ; If not go try again.
sfile3: cmp ah,'E'              ; Is it an error packet.
        jne sfile4
        call error
sfile4: jmp abort
SFILE   ENDP
 
 
;       Send data
 
SDATA   PROC    NEAR
        cmp numtry,maxtry       ; Have we reached the maximum number of tries?
        jl sdata1
	call erpos
        mov dx,offset erms14
        mov ah,prstr
        int dos                 ; Print an error message.
        jmp abort               ; Change the state to abort.
sdata1: inc numtry              ; Increment it.
        mov datptr,offset data  ; Get a pointer to our data block.
        mov cbfptr,offset filbuf ; Pointer to chars to be sent.
        mov cx,1                ; First char.
sdat11: mov bx,cbfptr
        mov ah,[bx]
        inc cbfptr
        mov bx,datptr
        mov [bx],ah             ; Put the char in the data packet.
        inc datptr              ; Save position in data packet.
        inc cx                  ; Increment the count.
        cmp cx,siz              ; Have we transfered that many?
        jle sdat11              ; If not get another.
        mov ax,siz              ; Number of char in char buffer.
        mov argbk1,ax
        mov ax,pktnum           ; Get the packet number.
        mov argblk,ax
        mov ah,'D'              ; Data packet.
        call spack              ; Send the packet.
        call rpack              ; Get a packet.
         jmp r                  ;  Trashed packet don't change state, retry.
        cmp ah,'Y'              ; ACK?
        jne sdata2              ; If not try next.
        mov ax,pktnum           ; Get the packet number.
        cmp ax,argblk           ; Is it the right packet number?
        jz sdat12
        ret                     ; If not hold out for the right one.
sdat12: inc ax                  ; Increment the packet number.
        and ax,3FH              ; Turn off the two high order bits.
        mov pktnum,ax           ; Save modulo 64 of the number.
        inc numpkt              ; Increment the number of packets.
        mov ah,numtry           ; Get the number of tries.
        mov oldtry,ah           ; Save it.
        mov numtry,0            ; Reset the number of tries.
        call gtchr
         jmp sdat13             ; Error go see if its EOF.
        mov siz,ax              ; Save the size of the data gotten.
        ret
;* File I/O.
sdat13: cmp ah,0FFH             ; Is it EOF?
        je sdt131
        jmp abort               ; If not give up.
;*
sdt131: mov state,'Z'           ; Set the state to EOF.
        ret
sdata2: cmp ah,'N'              ; NAK?
        jne sdata3              ; See if is an error packet.
        call rtpos	        ; Position cursor.
        inc numrtr              ; Increment the number of retries
        mov ax,numrtr
        call nout               ; Write the number of retries.
        mov ax,pktnum           ; Get the present packet number.
        inc ax                  ; Increment.
        cmp ax,argblk           ; Is the packet's number one more than now?
        jz sdat12               ; Just as good as ACK; goto ACK code.
        ret                     ; If not go try again.
sdata3: cmp ah,'E'              ; Is it an error packet.
        jne sdata4
        call error
sdata4: jmp abort
SDATA   ENDP
 
 
;       Send EOF
 
SEOF    PROC    NEAR
        cmp numtry,maxtry       ; Have we reached the maximum number of tries?
        jl seof1
        call erpos              ; Position cursor.
        mov dx,offset erms14
        mov ah,prstr
        int dos                 ; Print an error message.
        jmp abort               ; Change the state to abort.
seof1:  inc numtry              ; Increment it.
        mov ax,pktnum           ; Get the packet number.
        mov argblk,ax
        mov argbk1,0            ; No data.
        mov ah,'Z'              ; EOF packet.
        call spack              ; Send the packet.
        call rpack              ; Get a packet.
         jmp r                  ;  Trashed packet don't change state, retry.
        cmp ah,'Y'              ; ACK?
        jne seof2               ; If not try next.
        mov ax,pktnum           ; Get the packet number.
        cmp ax,argblk           ; Is it the right packet number?
        jz seof12
        ret                     ; If not hold out for the right one.
seof12: inc ax                  ; Increment the packet number.
        and ax,3FH              ; Turn off the two high order bits.
        mov pktnum,ax           ; Save modulo 64 of the number.
        inc numpkt              ; Increment the number of packets.
        mov ah,numtry           ; Get the number of tries.
        mov oldtry,ah           ; Save it.
        mov numtry,0            ; Reset the number of tries.
        mov ah,closf            ; Close the file.
        mov dx,offset fcb
        int dos
;* Check if successful
        call gtnfil             ; Get the next file.
         jmp seof13             ;  No more.
        mov state,'F'           ; Set the state to file send.
        ret
seof13: mov state,'B'           ; Set the state to EOT.
        ret
seof2:  cmp ah,'N'              ; NAK?
        jne seof3               ; Try and see if its an error packet.
        call rtpos              ; Position cursor.
        inc numrtr              ; Increment the number of retries
        mov ax,numrtr
        call nout               ; Write the number of retries.
        mov ax,pktnum           ; Get the present packet number.
        inc ax                  ; Increment.
        cmp ax,argblk           ; Is the packet's number one more than now?
        jz seof12               ; Just as good as a ACK; go to the ACK code.
        ret                     ; If not go try again.
seof3:  cmp ah,'E'              ; Is it an error packet?
        jne seof4
        call error
seof4:  jmp abort
SEOF    ENDP
 
 
;       Send EOT
 
SEOT    PROC    NEAR
        cmp numtry,maxtry       ; Have we reached the maximum number of tries?
        jl seot1
        call erpos             ; Position cursor.
        mov dx,offset erms14
        mov ah,prstr
        int dos                 ; Print an error message.
        jmp abort               ; Change the state to abort.
seot1:  inc numtry              ; Increment it.
        mov ax,pktnum           ; Get the packet number.
        mov argblk,ax
        mov argbk1,0            ; No data.
        mov ah,'B'              ; EOF packet.
        call spack              ; Send the packet.
        call rpack              ; Get a packet.
         jmp r                  ; Trashed packet don't change state, retry.
        cmp ah,'Y'              ; ACK?
        jne seot2               ; If not try next.
        mov ax,pktnum           ; Get the packet number.
        cmp ax,argblk           ; Is it the right packet number?
        jz seot12
        ret                     ; If not hold out for the right one.
seot12: inc ax                  ; Increment the packet number.
        and ax,3FH              ; Turn off the two high order bits.
        mov pktnum,ax           ; Save modulo 64 of the number.
        inc numpkt              ; Increment the number of packets.
        mov ah,numtry           ; Get the number of tries.
        mov oldtry,ah           ; Save it.
        mov numtry,0            ; Reset the number of tries.
        mov state,'C'           ; Set the state to file send.
        ret
seot2:  cmp ah,'N'              ; NAK?
        jne seot3               ; Is it error.
        call rtpos              ; Position cursor.
        inc numrtr              ; Increment the number of retries
        mov ax,numrtr
        call nout               ; Write the number of retries.
        mov ax,pktnum           ; Get the present packet number.
        inc ax                  ; Increment.
        cmp ax,argblk           ; Is the packet's number one more than now?
        jz seot12               ; Just as good as a ACK; go to the ACK code.
        ret                     ; If not go try again.
seot3:  cmp ah,'E'              ; Is it an error packet.
        jne seot4
        call error
seot4:  jmp abort
SEOT    ENDP
 

;* Here is the bulk of the file I/O.  Good luck.
 
;       File routines
 
;       Output the chars in a packet.

FILEIO	PROC	NEAR 	

ptchr:  mov temp1,ax            ; Save the size.
        mov bx,offset data      ; Beginning of received packet data.
        mov outpnt,bx           ; Remember where we are.
        mov ch,rquote		; Quote char.
ptchr1: dec temp1               ; Decrement # of chars in packet.
	jnl pt1
        jmp rskp                ; Return successfully if done.
pt1:    dec chrcnt              ; Decrement number of chars in dta.
        jns ptchr2              ; Continue if space left.
        call outbuf             ; Output it if full.
         jmp r                  ;  Error return if disk is full.
ptchr2: mov bx,outpnt           ; Get position in output buffer.
        mov ah,[bx]                     ; Grab a char.
        inc bx
        mov outpnt,bx           ; and bump pointer.
        cmp ah,ch               ; Is it the quote char?
        jne ptchr4              ; If not proceed.
        mov ah,[bx]                     ; Get the quoted character
        inc bx
        mov outpnt,bx           ; and bump pointer.
        dec temp1               ; Decrement # of chars in packet.
        mov dh,ah               ; Save the char.
        and ah,80H                      ; Turn off all but the parity bit.
        mov dl,ah               ; Save the parity bit.
        mov ah,dh                       ; Get the char.
        and ah,7FH                      ; Turn off the parity bit.
        cmp ah,ch               ; Is it the quote char?
        jz ptchr3               ; If so just go write it out.
        mov ah,dh                       ; Get the char.
        add ah,40H                      ; Make it a control char again.
        and ah,7FH                      ; Modulo 128.
ptchr3: or ah,dl                ; Or in the parity bit.
ptchr4: mov bx,bufpnt           ; Destination buffer.
        mov [bx],ah                     ; Store it.
        inc bx
        mov bufpnt,bx           ; Update the pointer
        jmp ptchr1              ; and loop to next char.


        ; output the buffer, reset bufpnt and chrcnt
 
outbuf: push bx
        mov ah,writef           ; The write code.
        mov dx,offset fcb
        int dos		         ; Write the record.
        pop bx
        cmp al,0                        ; Successful.
        jz outbf1
	cmp al,01
	jz outbf0
	call erpos
	mov ah,prstr
	mov dx,offset erms19	; Record length exceeds dta.
	int dos
	ret
outbf0: call erpos
	mov ah,prstr            ; Tell about it.
        mov dx,offset erms11    ; Disk full error.
        int dos
        ret
outbf1: mov bx,offset buff      ; Addr for beginning.
        mov bufpnt,bx           ; Store addr for beginning.
        mov ax,bufsiz-1         ; Buffer size.
        mov chrcnt,ax           ; Number of chars left.
        jmp rskp


;       Get the chars from the file.
 
gtchr:  mov ch,squote           ; Keep quote char in c.
        mov ah,filflg           ; Get the file flag.
        cmp ah,0                        ; Is there anything in the DMA?
        jz gtchr0               ; Yup, proceed.
        mov cl,0                ; No chars yet.
        call inbuf
         jmp gtceof             ; No more chars, go return EOF.
gtchr0: mov al,spsiz            ; Get the maximum packet size.
        sub al,5                ; Subtract the overhead.
        mov ah,0
        mov temp1,ax            ; Number of chars we're to get.
        mov bx,offset filbuf            ; Where to put the data.
        mov cbfptr,bx           ; Remember where we are.
        mov cl,0                ; No chars.
gtchr1: dec temp1               ; Decrement the number of chars left.
        jns gtchr2              ; Go on if there is more than one left.
        mov al,cl                       ; Return the count in A.
	mov ah,0
        jmp rskp
gtchr2: mov ax,chrcnt
        dec ax
        jl gtchr3
        mov chrcnt,ax
        jmp gtchr4
gtchr3: call inbuf              ; Get another buffer full.
         jmp gtceof
	cmp chrcnt,0
	jne gtchr4
	sub cl,2		; Don't count controllified Z.
	mov al,cl
	mov ah,0
	jmp rskp
gtchr4: mov bx,bufpnt           ; Position in DMA.
        mov ah,[bx]                     ; Get a char from the file.
        inc bx
        mov bufpnt,bx
        mov dh,ah               ; Save the char.
        and ah,80H                      ; Turn off all but parity.
        mov dl,ah               ; Save the parity bit.
        mov ah,dh                       ; Restore the char.
        and ah,7FH                      ; Turn off the parity.
        cmp ah,' '                      ; Compare to a space.
        jl gtchr5               ; If less then its a control char, handle it.
        cmp ah,del                      ; Is the char a delete?
        jz gtchr5               ; Go quote it.
        cmp ah,ch               ; Is it the quote char?
        jne gtchr8              ; If not proceed.
        dec temp1               ; Decrement the char total remaining.
        mov bx,cbfptr           ; Position in character buffer.
        mov [bx],ah                     ; Put the char in the buffer.
        inc bx
        mov cbfptr,bx
        inc cl                  ; Increment the char count.
        jmp gtchr8
gtchr5: or ah,dl                ; Turn on the parity bit.
        cmp ah,('Z'-100O)               ; Is it a ^Z?
        jne gtchr7              ; If not just proceed.
        mov ah,eoflag           ; EOF flag set?
        cmp ah,0
        jz gtchr6               ; If not just go on.
        mov bx,bufpnt
        mov ax,chrcnt
        mov dh,al               ; Get number of chars left in DMA.
gtch51: dec dh
        mov ah,dh
        jns gtch52              ; Any chars left?
        mov chrcnt,0            ; If not, say so.
        mov al,cl                       ; Return the count in A.
	mov ah,0
        jmp rskp
gtch52: mov ah,[bx]                     ; Get the next char.
        inc bx                  ; Move the pointer.
        cmp ah,('Z'-100O)               ; Is it a ^Z?
        jz gtch51               ; If so see if they rest are.
 
gtchr6: mov ah,('Z'-100O)       ; Restore the ^Z.
gtchr7: xchg ah,al
        mov ah,0
        mov temp2,ax            ; Save the char.
        dec temp1               ; Decrement char counter.
        mov bx,cbfptr           ; Position in character buffer.
        mov [bx],ch                     ; Put the quote in the buffer.
        inc bx
        mov cbfptr,bx
        inc cl                  ; Increment the char count.
        mov ax,temp2            ; Get the control char back.
        xchg al,ah
        add ah,40H                      ; Make the non-control.
        and ah,7fH                      ; Modulo 200 octal.
gtchr8: mov bx,cbfptr           ; Position in character buffer.
        or ah,dl                ; Or in the parity bit.
        mov [bx],ah                     ; Put the char in the buffer.
        inc bx
        mov cbfptr,bx
        inc cl                  ; Increment the char count.
        jmp gtchr1              ; Go around again.
 
gtceof: cmp cl,0		; Had we gotten any data?
	je gteof0		; Nope.
	mov al,cl
	mov ah,0
	jmp rskp
gteof0: mov ah,0FFH             ; Get a minus one.
        ret


inbuf:  mov ah,eoflag           ; Have we reached the end?
        cmp ah,0
        jz inbuf0
        ret                     ; Return if set.
inbuf0: push bx                 
	push cx
	mov bx,offset buff      ; Set the r/w buffer pointer.
        mov bufpnt,bx
        mov ah,readf            ; Read a record.
        mov dx,offset fcb
        int dos
	mov cx,filsiz
	cmp cx,0		; Check for 128 chars or less left.
	jne inbuf1		; Still have data left.
	mov ax,ds
	mov es,ax
	mov si,offset filsiz+2
	mov di,offset bufhex
	cmps filsiz+2,es:bufhex
	ja inbuf1		; More than 128 chars.
	mov eoflag,0FFH		; Set End-of-file.
	mov cx,filsiz+2
	mov chrcnt,cx		; Return proper number of chars.
        mov filflg,0		; Buffer not empty.
	pop cx
	pop bx
	jmp rskp
inbuf1:	sub filsiz+2,80H	; Sent another 128 chars.
	sbb filsiz,0		; Account for the doubleword.
	mov al,80H		; Use as counter for number of chars read.
	pop cx
	pop bx
	cmp filflg,0		; Ever used DMS?
	jnz inbf21		; Nope, then don't change count.
	dec al			; Fix boundary error.
inbf21: mov ah,0                ; Zero the flag (buffer not empty).
	mov chrcnt,ax		; Number of chars read from file.
        mov filflg,0		; Buffer not empty.
	jmp rskp

getfil: mov ah,0FFH
        mov filflg,ah           ; Nothing in the DMA.
        mov ax,0
        mov eoflag,ah           ; Not the end of file.
        mov bx,offset fcb+0CH
        mov [bx],ax             ; Zero the current block number.
        mov bx,offset fcb+0EH
        mov [bx],ax             ; Ditto for Lrecl.
        mov bx,offset fcb+20H
        mov [bx],ah             ; Zero the current record (of block).
	inc bx
	mov [bx],ax		; Same for record (of file). 
	mov bx,offset fcb+23H
	mov [bx],ax
        mov ah,openf            ; Open the file.
        mov dx,offset fcb
        int dos
	mov bx,offset fcb+18	; File size in bytes (hi order word).
	mov di,offset filsiz	; Where to put the info. 
	mov ax,[bx]
	mov [di],ax
	mov bx,offset fcb+16	; Lo order word.
	mov ax,[bx]
	mov 2[di],ax
	sub filsiz+2,1		; Don't count the ^Z.
	sbb filsiz,0
        jmp rskp


gtnfil: ret                     ; Just need label for now.

;       Get the file name (including host to micro translation)
 
gofil:  mov bx,offset data      ; Get the address of the file name.
        mov datptr,bx           ; Store the address.
        mov bx,offset fcb+1            ; Address of the FCB.
        mov fcbptr,bx           ; Save it.
        mov ax,0
        mov temp1,ax            ; Initialize the char count.
        mov temp2,ax
	mov si,offset fcb
        mov [si],ah             ; Set the drive to default to current.
        mov ch,' '
gofil1: mov [bx],ch                     ; Blank the FCB.
        inc bx
        inc ah
        cmp ah,0BH                      ; Twelve?
        jl gofil1
gofil2: mov bx,datptr           ; Get the NAME field.
        mov ah,[bx]
        inc bx
        mov datptr,bx
        cmp ah,'.'                      ; Seperator?
        jne gofil3
        mov bx,offset fcb+9H
        mov fcbptr,bx
        mov ax,temp1
        mov temp2,ax
        mov temp1,9H
        jmp gofil6
gofil3: cmp ah,0                        ; Trailing null?
        jz gofil7               ; Then we're done.
        mov bx,fcbptr
        mov [bx],ah
        inc bx
        mov fcbptr,bx
        mov ax,temp1            ; Get the char count.
        inc ax
        mov temp1,ax
        cmp ax,8H                       ; Are we finished with this field?
        jl gofil2
gofil4: mov temp2,ax
        mov bx,datptr
        mov ah,[bx]
        inc bx
        mov datptr,bx
        cmp ah,0
        jz gofil7
        cmp ah,'.'                      ; Is this the terminator?
        jne gofil4              ; Go until we find it.
gofil6: mov bx,datptr           ; Get the TYPE field.
        mov ah,[bx]
        inc bx
        mov datptr,bx
        cmp ah,0                        ; Trailing null?
        jz gofil7               ; Then we're done.
        mov bx,fcbptr
        mov [bx],ah
        inc bx
        mov fcbptr,bx
        inc temp1               ; Increment char count.
        cmp temp1,0CH                   ; Are we finished with this field?
        jl gofil6
gofil7: mov bx,datptr
	mov ah,'$'
        mov [bx],ah             ; Put in a dollar sign for printing.
        mov ah,2 	        ; Position cursor.
        mov dx,scrfln
	mov bh,0
        int bios
	call clrfln
        mov ah,prstr            ; Print the file name.
        mov dx,offset data
        int dos
        mov ah,flwflg           ; Is file warning on?
        cmp ah,0
	jnz gf7x
        jmp gofil9              ; If not, just proceed.
gf7x:   mov ah,openf            ; See if the file exists.
        mov dx,offset fcb
        int dos
        cmp al,0FFH             ; Does it exist?
	jnz gf8x
        jmp gofil9               ; If not create it.
gf8x:	mov ah,2		; Position cursor.
	mov dx,scrfr
	mov bh,0
	int bios
        mov ah,prstr            ; Inform the user we are renaming the file.
        mov dx,offset infms5
        int dos
        mov ax,temp2            ; Get the number of chars in the file name.
        cmp ax,0
        jne gofil8
        mov ax,temp1
        mov temp2,ax
gofil8: mov ch,0
        mov cl,al
	mov al,0			; Says if first field is full.
        cmp cl,9H                       ; Is the first field full?
        jne gofl81
        mov al,0FFH             ; Set a flag saying so.
        dec cl
gofl81: mov bx,offset fcb              ; Get the FCB.
        add bx,cx               ; Add in the character number.
	mov ah,'&'
        mov [bx],ah             ; Replace the char with an ampersand.
	push ax
        push bx
        mov ah,openf            ; See if the file exists.
        mov dx,offset fcb
        int dos
        pop bx
        cmp al,0FFH             ; Does it exist?
	pop ax
        jz gofl89               ; If not create it.
        cmp al,0                      ; Get the flag.
        jz gofl83
        dec cl                  ; Decrement the number of chars.
        cmp cl,0
        jz gofl88               ; If no more, die.
        jmp gofl81
gofl83: inc cl                  ; Increment the number of chars.
        cmp cl,9H                       ; Are we to the end?
        jl gofl81               ; If not try again ; else fail. 
 
gofl88: call erpos		; Position cursor.
	mov ah,prstr            ; Tell the user that we can't rename it.
        mov dx,offset ermes4
        int dos
        ret
 
gofl89: mov bx,offset fcb+0CH          ; Point past the end of the file name.
        mov dh,[bx]                     ; Save the present contents.
	mov ah,'$'
        mov [bx],ah             ; Put in a dollar sign.
        push dx
        mov ah,prstr            ; Print the file name.
        mov dx,offset fcb+1
        int dos
        pop dx
        mov bx,offset fcb+0CH          ; Restore over the dollar sign.
        mov [bx],dh
gofil9: mov ah,delf             ; Delete the file if it exists.
        mov dx,offset fcb
        int dos
        mov ax,0
        mov si,offset fcb+0CH
        mov [si],ax             ; Zero current block.
        mov si,offset fcb+0EH
        mov [si],ax             ; Same for Lrecl.
        mov si,offset fcb+20H
        mov [si],ah             ; Zero the current record (within block).
	inc si
	mov [si],ax		; Zero record (within file).
	mov si,offset fcb+23H
	mov [si],ax
        mov ah,makef            ; Now create it.
        mov dx,offset fcb
        int dos
        cmp al,0FFH             ; Is the disk full?
	je gf9x
        jmp rskp
gf9x:   call erpos		; Position cursor.
	mov ah,prstr            ; If so tell the user.
        mov dx,offset erms11
        int dos
        ret

FILEIO	ENDP
;*
 
 
;       Packet routines
 
; Send_Packet
; This routine assembles a packet from the arguments given and sends it
; to the host.
;
; Expects the following:
;       AH     - Type of packet (D,Y,N,S,R,E,F,Z,T)
;       ARGBLK - Packet sequence number
;       ARGBK1 - Number of data characters
; Returns: +1 always
 
SPKT	PROC	NEAR

spack:  push ax                 ; Save the packet type.
        mov bx,offset packet    ; Get address of the send packet.
        mov ah,soh              ; Get the start of header char.
        mov [bx],ah             ; Put in the packet.
        inc bx                  ; Point to next char.
        mov ax,argbk1           ; Get the number of data chars.
	xchg ah,al
        add ah,' '+3            ; Real packet character count made printable.
        mov [bx],ah             ; Put in the packet.
        inc bx                  ; Point to next char.
        mov cl,ah               ; Start the checksum.
        mov ax,argblk           ; Get the packet number.
	xchg ah,al
        add ah,' '              ; Add a space so the number is printable.
        mov [bx],ah             ; Put in the packet.
        inc bx                  ; Point to next char.
        add cl,ah               ; Add the packet number to the checksum.
        pop ax                  ; Get the packet type.
        mov [bx],ah             ; Put in the packet.
        inc bx                  ; Point to next char.
        add cl,ah               ; Add the type to the checksum.
        mov dx,argbk1           ; Get the packet size.
spack2: cmp dx,0                ; Are there any chars of data?
         jz spack3              ;  No, finish up.
        dec dx                  ; Decrement the char count.
        mov ah,[bx]             ; Get the next char.
        inc bx                  ; Point to next char.
        add cl,ah               ; Add the char to the checksum.
	cmp ah,0
	jns spack2
	mov hierr,0FFH		; set err flag. 
        jmp spack2              ; Go try again.
spack3: cmp hierr,0
	je sp3x			; Nothing special to do.
	call biterr
	mov hierr,0		; Reset.
sp3x:	mov ah,cl               ; Get the character total.
	mov ch,cl		; Save here too (need 'cl' for shift).
        and ah,0C0H             ; Turn off all but the two high order bits.
	mov cl,6
        shr ah,cl               ; Shift them into the low order position.
	mov cl,ch
        add ah,cl               ; Add it to the old bits.
        and ah,3FH              ; Turn off the two high order bits.  (MOD 64)
        add ah,' '              ; Add a space so the number is printable.
        mov [bx],ah             ; Put in the packet.
        inc bx                  ; Point to next char.
        mov ah,seol             ; Get the EOL the other host wants.
        mov [bx],ah             ; Put in the packet.
        inc bx                  ; Point to next char.
        mov ah,0                ; Get a null.
        mov [bx],ah             ; Put in the packet.
	cmp debug,0		; debug mode.
	je spack4
	inc bx
	mov ah,'$'
	mov [bx],ah
	mov ah,2
	mov dx,scrsp
	mov bh,0
	int bios
	mov ah,prstr
	mov dx,offset spmes
	int dos
	mov dx,offset packet
	mov ah,prstr
	int dos			; debug end.
spack4: call outpkt             ; Call the system dependent routine.
        ret
 
SPKT	ENDP 
;       Write out a packet.
 
OUTPKT  PROC    NEAR
        mov dh,spad             ; Get the number of padding chars.
outpk2: dec dh
        cmp dh,0
        jl outpk3               ; If none left proceed.
        mov ah,spadch           ; Get the padding char.
        call outchr             ; Output it.
        jmp outpk2
outpk3: mov bx,offset packet    ; Point to the packet.
outlup: mov ah,[bx]             ; Get the next character.
        cmp ah,0                ; Is it a null?
        jnz outlp2
        ret
outlp2: call outchr             ; Output the character.
        inc bx                  ; Increment the char pointer.
        jmp outlup
OUTPKT  ENDP
 
 
;************************System Dependent****************************
;       Put a char in AH to the port.
PORT	PROC  NEAR 
outchr: mov al,ah               ; Char must be in al.
	mov cx,0
	cmp ibmflg,0
	je outch1
	or al,080H
outch1: mov ah,1                ; Output it.
	mov dx,0
        int comm
	cmp ah,00H
	je outch3
	loop outch1
	ret
outch3:	ret
;	cmp ibmflg,0
;	je outch2		; Only wait for the IBM.
;	cmp al,CR
;	je outch2
;	mov cx,0A00H
;clup:	loop clup	
;outch2:	ret
 
 
;************************System Dependent****************************
;
;       Get a char from the port and return in A.
 
inchr:  mov dx,03FDH		; Get port status.
	in al,dx
	test al,1		; Data available?
	jnz inchr3		; Read char ok.
        mov ah,constat          ; Is a char on the console?
        int dos
        cmp al,0
        jz inchr                ; If not go look for another char.
        mov ah,conin            ; Get the char.
        int dos
	mov ah,al 
        cmp ah,cr                       ; Is it a carriage return?
        je inchr4              ; If not go look for another char.
	jmp inchr		; Wait for some kind of input.
inchr4:	ret
inchr3: mov dx,03F8H		; Read in the char.
	in al,dx
	mov ah,al
	cmp ibmflg,0
	je inchr5
	and ah,7FH                      ; Turn off the parity bit.
inchr5: jmp rskp
PORT	ENDP
;*
 
 
; Receive_Packet
; This routine waits for a packet arrive from the host.  It reads
; chars until it finds a SOH.

RPACK	PROC	NEAR
	mov ah,2
	mov dx,scrst		; Position cursor.
	mov bh,0
	int bios
	mov ah,prstr
	mov dx,offset infms0
        int dos
        call inpkt              ; Read up to a carriage return.
         jmp r                  ;  Return bad.
rpack0: call getchr             ; Get a character.
         jmp r                  ;  Hit the carriage return, return bad.
        cmp ah,soh              ; Is the char the start of header char?
         jne rpack0             ;  No, go until it is.
rpack1: call getchr             ; Get a character.
         jmp r                  ;  Hit the carriage return, retuset infms0
        cmp ah,soh              ; Is the char the start of header char?
         jz rpack1              ;  Yes, then go start over.
        mov cl,ah               ; Start the checksum.
        sub ah,' '+3            ; Get the real data count.
        mov dh,ah               ; Save it for later.
        mov al,ah               ; Swap halves.
        mov ah,0
        mov argbk1,ax           ; Save the data count.
        call getchr             ; Get a character.
         jmp r                  ;  Hit the carriage return, return bad.
        cmp ah,soh              ; Is the char the start of header char?
         jz rpack1              ;  Yes, then go start over.
        add cl,ah               ; Add it to the checksum.
        sub ah,' '              ; Get the real packet number.
        mov al,ah               ; Swap halves.
        mov ah,0
        mov argblk,ax           ; Save the packet number.
        call getchr             ; Get a character.
         jmp r                  ;  Hit the carriage return, return bad.
        cmp ah,soh              ; Is the char the start of header char?
         jz rpack1              ;  Yes, then go start over.
        push ax                 ; Save the message type.
        add cl,ah               ; Add it to the checksum.
        mov bx,offset data      ; Point to the data buffer.
rpack2: dec dh                  ; Any data characters?
         js rpack3              ;  If not go get the checksum.
        call getchr             ; Get a character.
         jmp r                  ;  Hit the carriage return, return bad.
        cmp ah,soh              ; Is the char the start of header char?
         jz rpack1              ;  Yes, then go start over.
        mov [bx],ah             ; Put the char into the packet.
        inc bx                  ; Point to the next character.
        add cl,ah               ; Add it to the checksum.
        jmp rpack2              ; Go get another.
rpack3: call getchr             ; Get a character.
         jmp r                  ;  Hit the carriage return, return bad.
        cmp ah,soh              ; Is the char the start of header char?
         jz rpack1              ;  Yes, then go start over.
        sub ah,' '              ; Turn the char back into a number.
        mov dh,cl               ; Get the character total.
        and dh,0C0H             ; Turn off all but the two high order bits.
	mov ch,cl
	mov cl,6
        shr dh,cl               ; Shift them into the low order position.
	mov cl,ch
        add dh,cl               ; Add it to the old bits.
        and dh,3FH              ; Turn off the two high order bits.  (MOD 64)
        cmp dh,ah               ; Are they equal?
         jz rpack4              ;  If so finish up.
        mov dx,offset dimsg1
        mov ah,prstr
        int dos                 ; Print a diagnostic message.
        ret
rpack4: mov ah,0
        mov [bx],ah             ; Put a null at the end of the data.
        pop ax                  ; Get the type.
        jmp rskp
RPACK   ENDP
 
 
INPKT   PROC    NEAR
        mov bx,offset recpkt    ; Point to the beginning of the packet.
	mov incnt,0
inpkt2: call inchr              ; Get a character.
         jmp r                  ;  Return failure.
        mov [bx],ah             ; Put the char in the packet.
        inc bx
	inc incnt
        cmp ah,reol             ; Is it the EOL char?
        jne inpkt2              ; If not loop for another.
	cmp ibmflg,0            ; Is this the (dumb) IBM mainframe?
        jz inpkt4               ; If not then proceed.
	cmp incnt,1		; Ignore bare CR.
	jne inpkt5
	mov incnt,0
	mov bx,offset recpkt
	jmp inpkt2
inpkt5: cmp state,'S'           ; Check if this is the Send-Init packet.
        jz inpkt4               ; If so don't wait for the XON.
inpkt3: call inchr              ; Wait for the turn around char.
         jmp inpkt4
        cmp ah,xon              ; Is it the IBM turn around character?
        jne inpkt3              ; If not, go until it is.
inpkt4: mov bx,offset recpkt
        mov pktptr,bx           ; Save the packet pointer.
        jmp rskp                ; If so we are done.
INPKT   ENDP

 
GETCHR  PROC    NEAR
        push bx
        mov bx,pktptr           ; Get the packet pointer.
        mov ah,[bx]             ; Get the char.
        inc bx
        mov pktptr,bx
        pop bx                  ; Restore BX.
        cmp ah,reol             ; Is it the EOL char?
        jne getcr2              ; If not return retskp.
        ret                     ; If so return failure.
getcr2: jmp rskp
GETCHR  ENDP
 
 
; This is where we go if we get an error packet.
 
ERROR   PROC    NEAR
        mov state,'A'           ; Set the state to abort.
        call erpos	        ; Position the cursor.
        mov bx,argbk1           ; Get the length of the data.
        add bx,offset data      ; Get to the end of the string.
        mov ah,'$'              ; Put a dollar sign at the end.
        mov [bx],ah
        mov ah,prstr            ; Print the error message.
        mov dx,offset data
        int dos
        ret
ERROR   ENDP
 
 
; This is the 'exit' command.  It leaves KERMIT and returns to CP/M.
 
EXIT    PROC    NEAR
        mov ah,cmcfm
        call comnd              ; Get a confirm.
         jmp r
        mov extflg,1            ;  Set the exit flag.
        jmp rskp                ; Then return to system.
EXIT    ENDP
 
 
; This is the 'help' command.  It gives a list of the commands.
 
HELP    PROC    NEAR
        mov ah,cmcfm
        call comnd              ; Get a confirm.
         jmp r
        mov ah,prstr            ; Print a string to the console.
        mov dx,offset tophlp    ; The address of the help message.
        int dos
        jmp rskp
HELP    ENDP
 

source	db	2048 DUP(?)	; Buffer for data from port.
srcpnt	dw	0		; Pointer in buffer (DI).
count	dw	0		; Number of chars in int buffer.
savesi	dw	0		; Save SI register here.	


;       This is the CONNECT command.
 
TELNET  PROC    NEAR
        mov ah,cmcfm
        call comnd              ; Get a confirm.
         jmp r                  ;  Didn't get a confirm.
        mov ah,prstr            ; Output
        mov dx,offset crlf      ; a crlf.
        int dos
	mov dx,offset tmsg1
	int dos
	cld			; Do increment in string operations.
	cli			; Disable interrupts.
	xor ax,ax
	mov cx,ds		; Save DS in CX.
	mov ds,ax		; Use low core.
	mov bx,30H
	push [bx]		; Serial Card Interrupt vector.
	mov bx,32H
	push [bx]
	mov bx,6CH		; "break" interrupt vector.
	push [bx]
	mov bx,6EH
	push [bx]
	mov bx,30H
	mov ax,offset serint
	mov es,ax
	mov [bx],es		; Setup int addr.
	mov bx,32H
	mov [bx],cs
	mov bx,6CH
	mov ax,offset intret
	mov es,ax
	mov [bx],es		; ignore break int's (pt to "iret").
	mov bx,6EH
	mov [bx],cs
	mov ds,cx
	mov ssp,sp		; Save SP to make an easy return.
	lea ax,cs:source
	mov cs:srcpnt,ax
	mov cs:savesi,ax	; Source of data starts at buffer head.
	mov cs:count,0	
	mov di,cs:srcpnt   	; Address (for int) to put chars.
	mov ax,cs
	mov es,ax
	mov si,0		; Place to get chars from.
	in al,21H		; Set up 8259 interrupt controller.
	and al,0EFH		; Enable INT4.
	out 21H,al
	mov dx,03FBH		; Set up baud, parity, etc.
	mov al,3		; (baud set independently)
	out dx,al
	mov dx,03F9H		; Interrupt enable register.
	mov al,1
	out dx,al
	mov dl,0FCH		; Enable int's from serial card.
	mov al,0BH
	out dx,al
	sti	 		; Enable interrupts.
	mov dl,0F8H
	in al,dx
telnoe: call plup		; Char at port (type to console) ?
	cmp al,ESC
	jne telx
	jmp telesc
telx:	cmp al,DEL		; Don't bother with deletes.
	je telnoe
	cmp al,XOFF		; Skip all the following too.
	je telnoe
	cmp al,XON	
	je telnoe
	cmp al,00H		; Null.
	je telnoe
	cmp al,BELL
	jne nobell
	call beep
	jmp telnoe
nobell:	mov ah,14	
	mov bx,0
	int bios
	jmp telnoe
TELNET  ENDP


EXTLN	PROC	NEAR
	cli			; Disable interrupts.
;	push ax
	mov dx,03FCH	
	mov al,3		; Disable modem interrupts.
	out dx,al
	in al,21H		; Interrupt control.
	or al,10H		; Inhibit IRQ4.
	out 21H,al
	mov sp,ssp
	xor bx,bx
	mov cx,ds		; Save DS register.
	mov ds,bx		; Address low memory.
;	pop ax
	mov bx,6EH
	pop [bx]
	mov bx,6CH
	pop [bx]
	mov bx,32H		; Restore old interrupt vectors.
	pop [bx]
	mov bx,30H
	pop [bx]
	mov ds,cx		; Restore DS.
	xor bx,bx
	sti
	mov ah,prstr
	mov dx,offset tmsg2
	int dos
	jmp rskp
EXTLN	ENDP

; *********** serial port interrupt routine ********

SERINT  PROC  NEAR
	push dx
	push ax
	push es
	push di
	cld
	mov di,cs:srcpnt	; Registers for storing data.
	mov ax,cs
	mov es,ax
	mov dx,03FDH		; Asynch status port.
	in al,dx
	test al,1		; Data available?
	jz retint		; Nope.
	mov dl,0F8H
	in al,dx
	and al,7FH		; Only want 7 bits.
	jz retint		; Ignore nulls.
	cmp al,7FH		; Ignore rubouts, too.
	jz retint
	stosb			; Store char in buffer.
	lea ax,cs:source
	sub di,ax
	and di,7FFH		; Truncate buffer here.
	add di,ax
	inc cs:count
retint:	mov cs:srcpnt,di
	sti
	mov al,64H
	out 20H,al		;Send End-of-Interrupt to 8259.
	pop di
	pop es
	pop ax
	pop dx
intret:	iret
SERINT	ENDP

PLUP	PROC	NEAR
	call prtchr
	  ret			; Got a char.
	  nop			; Use up three bytes.
	  nop
	call conchr		; See if char at cons (type to port).
	  jmp extln		; Go back to Kermit on micro.
	jmp plup 
PLUP	ENDP

;************************System Dependent****************************
 
;* These I/O routines are similar to those just above.
 
PRTCHR  PROC    NEAR
	cmp cs:count,0
	jnz prtch2
	jmp rskp		; No data - check console.
prtch2: cli			; Disable int's.
	mov cx,ds
	mov ax,cs
	mov ds,ax
	mov si,cs:savesi
	lodsb			; Get char from buffer.
	lea dx,cs:source
	sub si,dx
	and si,7FFH		; Truncate buffer after here.
	add si,dx
	dec cs:count
	mov cs:savesi,si 
	mov ds,cx
	sti			; Renable int's.
	ret
PRTCHR  ENDP


; Generate a short beep.

BEEP	PROC	NEAR
	mov al,10110110B	; Gen a short beep (long one losses data.)
	out timer+3,al		; Code snarfed from Technical Reference.
	mov ax,533H
	out timer+2,al
	mov al,ah
	out timer+2,al
	in al,port_b
	mov ah,al
	or al,03
	out port_b,al
	sub cx,cx
	mov bl,1
beep0:  loop beep0
	dec bl		
	jnz beep0
	mov al,ah
	out port_b,al
	ret
BEEP	ENDP 
 
CONCHR  PROC    NEAR
	mov ah,1		; Get keyboard status.
	int keyb
	jnz cnc0x	
	jmp rskp
cnc0x:	mov ah,0		; Read a char.
	int keyb
	cmp al,0		; Special char (cntrl-break)?
	jnz nobrk		; Nope.
	cmp ah,3		; 3 in ah means nul code.
	jz cnc1y		; Skip nulls.
	cmp ah,0		; Cntrl-Break?
	jne cnc1y
	xor cx,cx
	mov dx,03fbH
	in al,dx
	or al,40H		; Set send-break bit
	out dx,al
pause:	loop pause
	xor al,40H
	out dx,al
cnc1y:	jmp rskp	

nobrk:  mov dl,al		; Store char here.
	mov ah,escchr           ; Get the escape char.
        cmp ah,dl               ; Is it an escape char?
        jz intchr               ; If so go process it.
	cmp ibmflg,0
	je conch0
	or dl,080H		; Turn on eighth bit.
conch0:	push dx
        call prtout             ; Output the char to the port.
	pop dx
        mov ah,ecoflg           ; Get the echo flag.
        cmp ah,0                        ; Is it turned on?
	jnz cnc1x
        jmp rskp                 ; If not we're done here.
cnc1x:  and dl,7FH
	cmp dl,BS		; Backspace?
	je cnc2x
	cmp dl,CR		; Carriage return?
	je cnc2x
	cmp dl,BELL
	jne cnc2y
	call beep
	jmp rskp
cnc2y:	cmp dl,20H		; Is it a control char?
	jge cnc2x	
	jmp rskp
cnc2x:	mov ah,dconio           ; Direct console output.
        int dos                 ; Echo the char.
        jmp rskp
CONCHR  ENDP
 
CONN	PROC	NEAR	 
intchr: mov ah,dconio           ; Direct console I/O.
        mov dl,0FFH             ; Input.
        int dos                 ; Get a char.
	mov ah,al
	cmp ah,0                        ; Is the char a null?
        jz intchr               ; If so, go until we get a char.
        mov bh,ah               ; Save the actual char.
        and ah,137O             ; Convert to upper case.
        cmp ah,'C'                      ; Is it close?
        jne intch0
        ret
intch0: cmp ah,'S'                      ; Is it status?
	jnz inc0x
        jmp stat01               ; If so, jump to stat01 (it will return).
inc0x:  mov ah,bh                       ; Get the char.
        cmp ah,'?'                      ; Is it help?
        jne intch1              ; If not, go to the next check.
        mov dx,offset inthlp    ; If so, get the address of the help message.
        mov ah,prstr            ; Print it.
        int dos
        jmp intchr              ; Get another char.
intch1: mov ch,ah               ; Put the char into another reg.
        mov ah,escchr           ; Get the escape char.
        cmp ah,ch               ; Is it the escape char?
        jne intch2              ; If not, go send a beep to the user.
	cmp ibmflg,0
	je intc11
	or ch,080H		; Turn on high order bit. 
intc11: mov dl,ch
	call prtout             ; Output it.
        jmp rskp                ; Return, we are done here.
intch2: mov dl,'G'-100O         ; Otherwise send a beep.
        mov ah,dconio
        int dos
        jmp rskp

;* Another similar I/O routine.
 
;************************System Dependent****************************
 
prtout: mov al,dl               ; Char must be in al.
	mov dx,03f8H
	out dx,al
        ret
CONN	ENDP
;*

TELESC	PROC	NEAR
	cmp vtflg,0		; Is vt52 flag on?
	jne vt0
	jmp telnoe		; Don't do escape stuff if it's off.
vt0:	call plup
        mov ah,al                       ; Get the char.
	cmp ah,'Y'		; Special char - move cursor.
	jne vt1
	jmp movcur
vt1:    cmp ah,'A'                      ; Less than an 'A'?
        jl vtig                 ; Yes - ignore.
        cmp ah,'M'+1            ; Greater than 'M'?
        jns vtig                ; Yes - ignore.
        mov al,'A'
        sub ah,al               ; Else make into index.
        shl ah,1
        mov bx,offset ttab      ; Load base addr of table.
	mov cl,ah               ; Move a into cx.
        mov ch,00H              ; Zero out high byte.
        add bx,cx               ; Double add index+offset.
	mov bx,[bx]		; Get address of routine to call.
	jmp bx
vtig:                           ; Ignore escape sequence.
        push ax                 ; Push the char to be output.
        mov dl,esc              ; Load an escape.
        mov ah,conout           ; The function code
        int dos                 ; and the syscal.
        pop ax                  ; Restore the character
        mov dl,ah               ; and move to output register.
        mov ah,conout           ; The function
        int dos                 ; and the syscall.
        jmp telnoe              ; Return home.
TELESC	ENDP

TEL	PROC	NEAR
movcur:	call plup
	sub al,32
	mov dh,al
	mov temp,dx		; Save row position here.
	call plup
	mov dx,temp		; Restore
	sub al,32		; Comes with 37Q added on (& starts at 1).
	mov dl,al
	mov bh,0
	mov ah,2
	int bios
	jmp telnoe

curup:	mov ah,3		; Cursor up function.
	mov bh,0
	int bios
	cmp dh,0
	je cup0
	sub dh,1
	mov ah,2
	int bios
cup0:	jmp telnoe

curdwn:	mov ah,3		; Cursor down.
	mov bh,0
	int bios
	cmp dh,24
	je cdn0
	add dh,1
	mov ah,2
	int bios
cdn0:	jmp telnoe

currt:	mov ah,3		; Cursor right.
	mov bh,0
	int bios
	cmp dl,79
	je crt0
	add dl,1
	mov ah,2
	int bios
crt0:	jmp telnoe

curlft:	mov ah,3		; Cursor left.
	mov bh,0
	int bios
	cmp dl,0
	je clt0
	sub dl,1
	mov ah,2
	int bios
clt0:	jmp telnoe

curskp:	jmp vtig		; Ignore for now.

curhm:	call locate
	jmp telnoe

curscr:	mov ah,3		; Clear to end of screen.
	mov bh,0
	int bios
	cmp dx,0
	jne csr0
	call cmblnk
	jmp telnoe
csr0:	cmp dl,0
	je csr1
	push dx
	call curln
	pop dx
	add dh,1
	mov dl,0
csr1:	mov cx,dx
	mov dx,184FH
	mov bh,7
;	mov al,25
;	sub al,ch
	mov al,0
	mov ah,7
	int bios
	jmp telnoe

curln:	mov ah,3		; Clear to end of line.
	mov bh,0
	int bios		; Get current cursor position
	mov cx,dx
	mov dl,79
	mov ah,7
	mov al,0
	mov bh,7
	int bios
	jmp telnoe

inslin:	mov ah,3		; Get cursor position.
	mov bh,0
	int bios
	mov temp,dx		; Save here.
	mov cx,dx
	mov cl,0		; Start at beginning of row.
	mov dx,184FH		; End at lower corner of screen.
	mov ax,0701H
	mov bh,7
	int bios		; Scroll down one line.
	mov dx,temp		; Get back where we were.
	mov dl,0
	mov ah,2
	mov bh,0
	int bios
	jmp telnoe

dellin: mov ah,3
	mov bh,0
	int bios		; Get current cursor position. 
	mov temp,dx		; Remember the place.
	mov ax,0601H		; Scroll up one line.
	mov cx,dx
	mov cl,0		; Start at beginning of row.
	mov dx,184FH
	mov bh,7
	int bios
	mov dx,temp
	mov dl,0
	mov ah,2
	mov bh,0
	int bios
	jmp telnoe
	
TEL	ENDP

;*
 
; This is the SET command.
 
SETCOM  PROC    NEAR
        mov dx,offset settab    ; Parse a keyword from the set table.
        mov bx,offset sethlp
        mov ah,cmkey
        call comnd
         jmp r
        call bx
        jmp rskp
SETCOM  ENDP
 
 
;       This is the ESCAPE character SET subcommand.
 
ESCAPE  PROC    NEAR

	call cmgtch		; Get a char.
	jns es1			; Terminator or no?
	and ah,7FH		; Turn off minus bit.
	cmp ah,'?'
	jne es0
esch:	mov dx,offset eschlp
	mov ah,prstr
	int dos
	mov dx,offset crlf
	int dos
	mov dx,offset kerm
	int dos
	mov bx,cmdptr
	mov al,'$'
	mov [bx],al
	mov dx,offset cmdbuf
	int dos
	jmp repars
es0:	mov dx,offset escmes	; Print a message.
	mov ah,prstr
	int dos
	mov ah,conin
	int dos			; Get new escape char.
	mov ah,al
	cmp ah,'?'
	je esch
	cmp ah,cr
	jne es1
	mov ah,prstr
	mov dx,offset ermes3
	int dos
	ret
es1:  	mov escchr,ah		; Save new value.
	ret
ESCAPE  ENDP
 
 
;       This is the LOCAL echo SET subcommand.
 
LCAL    PROC    NEAR
        mov dx,offset ontab
        mov bx,offset onhlp
        mov ah,cmkey
        call comnd
         jmp r
        push bx                 ; Save the parsed value.
        mov ah,cmcfm
        call comnd              ; Get a confirm.
         jmp r                  ;  Didn't get a confirm.
        pop bx
        mov ecoflg,bl           ; Set the local echo flag.
	ret
LCAL    ENDP
 
;       This is the VT52 emulation SET subcommand.
 
VT52EM  PROC    NEAR
        mov dx,offset ontab
        mov bx,offset onhlp
        mov ah,cmkey
        call comnd
         jmp r
        push bx
        mov ah,cmcfm
        call comnd              ; Get a confirm.
         jmp r                  ;  Didn't get a confirm.
        pop bx
        mov vtflg,bl            ; Set the VT52 emulation flag.
	ret
VT52EM  ENDP
 
;       This is the SET IBM command.
 
IBMSET  PROC    NEAR
        mov dx,offset ontab
        mov bx,offset onhlp
        mov ah,cmkey
        call comnd
         jmp r
        push bx
        mov ah,cmcfm
        call comnd              ; Get a confirm.
         jmp r                  ;  Didn't get a confirm.
        pop bx
        mov ibmflg,bl           ; Set the IBM flag.
	ret
IBMSET  ENDP

;       This is the SET File-Warning command.
 
FILWAR  PROC    NEAR
        mov dx,offset ontab
        mov bx,offset onhlp
        mov ah,cmkey
        call comnd
         jmp r
        push bx
        mov ah,cmcfm
        call comnd              ; Get a confirm.
         jmp r                  ;  Didn't get a confirm.
        pop bx
        mov flwflg,bl           ; Set the IBM flag.
	ret
FILWAR  ENDP

; Sets debugging mode on and off.

DEBST	PROC    NEAR
        mov dx,offset ontab
        mov bx,offset onhlp
        mov ah,cmkey
        call comnd
         jmp r
        push bx
        mov ah,cmcfm
        call comnd              ; Get a confirm.
         jmp r                  ;  Didn't get a confirm.
        pop bx
        mov debug,bl           ; Set the IBM flag.
	ret
DEBST   ENDP

;  This function sets the baud rate.

BAUDST  PROC    NEAR
        mov dx,offset bdtab
        mov bx,offset bdhlp
        mov ah,cmkey
        call comnd
         jmp r
	push bx
	mov ah,cmcfm
	call comnd		; Get a confirm.
	 jmp r			; Didn't get one.
	pop bx
        mov baud,bx           ; Set the IBM flag.
	mov dx,03FBH		; LCR
	in al,dx
	mov bl,al
	or ax,80H
	out dx,al
	mov dx,03F8H
	mov ax,baud
	out dx,al
	inc dx
	mov al,ah
	out dx,al
	mov dx,03FBH
	mov al,bl
	out dx,al
	ret
BAUDST  ENDP
 
;       This is the STATUS command.
 
STATUS  PROC    NEAR
        call stat0
         jmp r
        jmp rskp
STATUS  ENDP
 
STAT0   PROC    NEAR
        mov ah,cmcfm
        call comnd              ; Get a confirm.
         jmp r                  ;  Didn't get a confirm.
stat01: mov dx,offset locst     ; Assume local echo on.
	cmp ecoflg,0            ; Is the local echo flag on?
        jnz stat1               
        mov dx,offset remst     ; If not say so.
stat1:  mov ah,prstr            ; Print it.
        int dos
        mov dx,offset vtemst    ; Get address of the VT52 emulation string.
        cmp vtflg,0             ; Is the VT52 emulation flag on?
        jnz stat2
        mov dx,offset novtst    ; If not say so.
stat2:  mov ah,prstr            ; Print it.
        int dos
	mov dx,offset ibmst	; Is IBM flag on?
	cmp ibmflg,0
	jnz stat3
	mov dx,offset noibm     ; Say it's not.
stat3:  mov ah,prstr
	int dos
	mov dx,offset deboff	; Assume debug mode is off.
	cmp debug,0
	je stat4
	mov dx,offset debon
stat4:	mov ah,prstr
	int dos
	mov dx,offset flwon	; Assume file-warning on.
	cmp flwflg,0
	jne stat5
	mov dx,offset flwoff
stat5:	mov ah,prstr
	int dos
	mov dx,offset b48st	; Assume 4800 baud.
	cmp baud,B4800
	jz stat9
	mov dx,offset b12st
	cmp baud,B1200
	jz stat9
	mov dx,offset b18st
	cmp baud,B1800
	jz stat9
	mov dx,offset b24st
	cmp baud,B2400
	jz stat9
	mov dx,offset b96st
	cmp baud,B9600
	jz stat9
	mov dx,offset b03st
stat9:	mov ah,prstr
	int dos
        mov dx,offset cmcrlf    ; Get the address of a crlf.
        mov ah,prstr            ; Print it.
        int dos
        jmp rskp
STAT0   ENDP
 
 
 
;       Utility routines
 
; Jumping to this location is like retskp.  It assumes the instruction
;   after the call is a jmp addr.
 
RSKP    PROC    NEAR
	pop bp
	add bp,3
	push bp
        ret
RSKP    ENDP
 
; Jumping here is the same as a ret.
 
R       PROC    NEAR
        ret
R       ENDP
 
; This routine prints the number in AX on the screen.
;       (Thanks to Jeff Damens)
 
NOUT    PROC    NEAR
        push bx                 ; Save some stuff.
        push cx
        push dx
        push ax
        mov bh,0                ; Don't print leading zeros.
        and ah,0F0H             ; Only want high order nibble.
        mov cl,4
	shr ah,cl
        call pdig               ; Print the digit.
        pop ax                  ; Restore argument.
        and ah,0FH              ; Just the low order nibble.
        call pdig
        mov ah,al
        and ah,0F0H             ; Only want high order nibble.
	mov cl,4
        shr ah,cl
        call pdig               ; Print the digit.
        mov ah,al
        and ah,0FH              ; Just the low order nibble.
        mov bh,0FFH             ; Make sure at least one zero is printed.
        call pdig
        pop dx                  ; Restore some stuff.
        pop cx
        pop bx
        ret
NOUT    ENDP
 
        ; print the digit in register AH
 
PDIG    PROC    NEAR
        push ax                 ; Save it.
        cmp ah,0
        jne pdig2
        cmp bh,0
        jne pdig2
        pop ax
        ret
pdig2:  mov bh,0FFH             ; Set the print zero flag.
        cmp ah,10               ; Do we use digits or a-f?
        jl usedig               ; Digit.
        add ah,'A'-10           ; Compute digit
        jmp havdig              ; and proceed.
usedig: add ah,'0'              ; Convert to digit
havdig: mov dl,ah
        mov ah,conout
        int dos
        pop ax
        ret
PDIG    ENDP
 

;       This set of routines provides a user oriented way of parsing
;       commands.  It is similar to that of the COMND JSYS in TOPS-20.
 
 
;       This routine prints the prompt in DE and specifies the reparse
;       address.
 
PROMPT	PROC  NEAR
	pop bx                  ; Get the return address.
        push bx                 ; Put it on the stack again.
        mov cmrprs,bx           ; Save as addr to go to on reparse.
        mov bx,0                        ; Clear out register.
        add bx,sp               ; Get the present stack pointer.
        mov cmostp,bx           ; Save for later restoral.
        mov cmprmp,dx           ; Save pointer to the prompt.
        mov bx,offset cmdbuf
        mov cmcptr,bx           ; Initialize the command pointer.
        mov cmdptr,bx
        mov ah,0
        mov cmaflg,ah           ; Zero the flags.
        mov cmccnt,ah
        mov cmsflg,0FFH
        mov ah,prstr
        mov dx,offset cmcrlf
        int dos
        mov ah,prstr            ; Print the prompt.
        mov dx,cmprmp
        int dos
        ret
PROMPT	ENDP
 
;       This address is jumped to on reparse.

PARSE	PROC NEAR 
repars: mov sp,cmostp           ; new sp <-- old sp
        mov bx,offset cmdbuf
        mov cmdptr,bx
        mov ah,0FFH
        mov cmsflg,ah
        mov bx,cmrprs           ; Get the reparse address.
        call bx                 ; Go there.
 
;       This address can be jumped to on a parsing error.
 
prserr: mov sp,cmostp           ; Set new sp to old one.
        mov bx,offset cmdbuf
        mov cmcptr,bx           ; Initialize the command pointer.
        mov cmdptr,bx
        mov ah,0
        mov cmaflg,ah           ; Zero the flags.
        mov cmccnt,ah
        mov cmsflg,0FFH
        mov ah,prstr
        mov dx,offset cmcrlf
        int dos
        mov ah,prstr            ; Print the prompt.
        mov dx,cmprmp           ; Get the prompt.
        int dos
;* Instead return to before the prompt call.
        mov bx,cmrprs
        call bx
PARSE	ENDP
 
;       This routine parses the specified function in AH. Any additional
;       information is in DX and BX.
;       Returns +1 on success
;               +4 on failure (assumes a JMP follows the call)
 
CMND	PROC NEAR
comnd:  mov cmstat,ah           ; Save what we are presently parsing.
        call cminbf             ; Get chars until an action or a erase char.
	mov ah,cmstat		; Restore 'ah' for upcoming checks.
        cmp ah,cmcfm            ; Parse a confirm?
        jz cmcfrm               ; Go get one.
        cmp ah,cmkey            ; Parse a keyword?
	jnz cm1
        jmp cmkeyw               ; Try and get one.
cm1:    cmp ah,cmifi		; Parse an input file spec?
	jnz cm2
	jmp cmifil		; Go get one.
cm2:	cmp ah,cmofi		; Output file spec?
	jnz cm3
	jmp cmofil		; Go get one.
cm3:	mov ah,prstr		; Else give error.
	mov dx,offset cmer00	; "?Unrecognized COMND call"
	int dos
	ret

; This routine gets a confirm.

cmcfrm: call cmgtch		; Get a char.
	cmp ah,0		; Is it negative (a terminator; a space or
				; a tab will not be returned here as they
				; will be seen as leading white space.)
        js cmcfr0
        ret                     ; If not, return failure.
cmcfr0: and ah,7FH                      ; Turn off the minus bit.
        cmp ah,esc                      ; Is it an escape?
        jne cmcfr2
        mov ah,conout
        mov dl,bell             ; Get a bell.
        int dos
        mov ah,0
        mov cmaflg,ah           ; Turn off the action flag.
        mov bx,cmcptr           ; Move the pointer to before thee scape.
        dec bx
        mov cmcptr,bx
        mov cmdptr,bx
        dec cmccnt              ; Decremrnt the char count.
        jmp cmcfrm              ; Try again.
cmcfr2: cmp ah,'?'                      ; Curious?
        jne cmcfr3
        mov ah,prstr            ; Print something useful.
        mov dx,offset cmin00
        int dos
        mov ah,prstr
        mov dx,offset cmcrlf            ; Print a crlf.
        int dos
        mov ah,prstr
        mov dx,cmprmp           ; Reprint the prompt.
        int dos
        mov bx,cmdptr           ; Get the pointer into the buffer.
        mov ah,'$'              ; Put a $ there for printing.
        mov [bx],ah
        mov bx,cmcptr
        dec bx                  ; Decrement & save the buffer pointer.
        mov  cmcptr,bx
        mov ah,prstr
        mov dx,offset cmdbuf
        int dos
        mov ah,0                        ; Turn off the action flag.
        mov cmaflg,ah
        jmp repars              ; Reparse everything.
 
cmcfr3: cmp ah,ff                       ; Is it a form feed?
        jne cmcfr4
        call cmblnk             ; If so blank the screen.
cmcfr4: jmp rskp
 
;       This routine parses a keyword from the table pointed
;       to in DX.  The format of the table is as follows:
;
;       addr:   db      n       ; Where n is the # of entries in the table.
;               db      m       ; M is the size of the keyword.
;               db      'string$' ; Where string is the keyword.
;               dw      ab      ; Where ab is data to be returned.
;
;       The keywords must be in alphabetical order.


cmkeyw: mov cmhlp,bx            ; Save the help.
        mov cmptab,dx           ; Save the beginning of keyword table.
        mov bx,dx
        mov ch,[bx]                     ; Get number of entries in table.
        inc bx
	mov dx,cmdptr		; Save command pointer.
	mov cmsptr,dx		; Save pointer's here.
cmky1:  cmp ch,0                ; Any commands left to check?
        jne cmky2
        ret                     ; Fail if not.
cmky2:  dec ch
	mov cl,0		; Keep track of how many chars read in so far.
        call cmgtch             ; Get a char.
        cmp ah,0                ; Do we have a terminator?
        jns cmky2x 
	jmp cmky4               ; Negative number means we do.
cmky2x: inc bx                  ; Point to first letter of keyword.
	inc cl			; Read in another char.
        mov al,[bx]                   
        cmp ah,'a'              ; Less than a?
        jl cmky21               ; If so, don't capitalize.
        cmp ah,'z'+1            ; More than z?
        jns cmky21
        and ah,137O             ; Capitalize the letter.
cmky21: cmp ah,al
	je cmky3
	jg cmky2y
        jmp cmky41              ; Fail if ah preceeds al alphabetically.
cmky2y: jmp cmky6               ; Not this keyword - try the next.
cmky3:  inc bx                  ; We match here, how 'bout next char?
        mov al,[bx]
        cmp al,'$'               ; End of keyword?
	jne cmky3x
        jmp cmky7                ; Succeed.
cmky3x:	mov dl,al		; Save al's char here.
        call cmgtch
	inc cl			; Read in another char.
	mov al,dl
	cmp ah,'a'
	jl cmky31
	cmp ah,'z'+1
	jns cmky31
	and ah,137O
cmky31: cmp ah,9BH		; Escape Recognition (escape w/minus bit on)?
	je cmky3y
	cmp ah,0A0H		; A space?
	je cmky3y
	cmp ah,8DH		; Carriage return?
	je cmky3y
	jmp cmky38
cmky3y:	mov cmkptr,bx		; Save bx here.
	mov cmsiz,cx		; Save size info.
	mov cmchr,ah		; Save char for latter.
	call cmambg		; See if input is ambiguous or not.
	 jmp cmky32		; Succeeded (not ambiguous).
	mov ah,cmchr
	cmp ah,9BH		; Escape?
	je cmky3z
	jmp cmky41		; Fail.
cmky3z:	mov ah,conout		; Else, ring a bell.
	mov dl,bell
	int dos
	mov bx,cmcptr		; Move pointer to before the escape.
	dec bx
	mov cmcptr,bx
	mov cmdptr,bx
	dec cmccnt		; Decrement char count.
	mov bx,cmkptr		; Failed - pretend user never typed ....
	mov cx,cmsiz		; ... in a char.
	dec cl			; Don't count the escape.
	dec bx
	mov cmaflg,0		; Reset the action flag.
	jmp cmky3		; Keep checking.
cmky32: mov cx,cmsiz		; Restore info.
	mov bx,cmkptr		; Our place in the keyword table.
	cmp cmchr,0A0H		; Space?
	je cmky35
	cmp cmchr,8DH		; Carriage return?
	je cmky35
	dec cmcptr		; Pointer into buffer of input.
	mov dx,cmcptr
cmky33:	mov ah,[bx]		; Get next char in keyword.
	cmp ah,'$'		; Are we done yet?
	jz cmky34
	mov di,dx
	mov [di],ah
	inc bx
	inc dx
	inc cmccnt
	jmp cmky33
cmky34:	mov ah,' '
	mov di,dx
	mov [di],ah		; Put a blank in the buffer.
	inc dx
	mov cx,cmcptr		; Remember where we were (for printing below).
	mov cmcptr,dx		; Update our pointers.
	mov cmdptr,dx
	mov ah,'$'
	mov di,dx
	mov [di],ah		; Add '$' for printing.
	mov ah,prstr
	mov dx,cx		; Point to beginning of filled in data.
	int dos
	inc bx			; Point to address we'll need.
	mov bx,[bx]
	mov cmaflg,0 		; Turn off action flag.
	jmp rskp

cmky35:	inc bx
	mov ah,[bx]		; Find end of keyword. 
	cmp ah,'$'
	jne cmky35	
	inc bx
	mov bx,[bx]		; Address of next routine to call.
;	mov cmaflg,0		; Zero the action flag.
	jmp rskp

cmky38:	cmp ah,al
        jne cmky6               ; Go to end of keyword and try next.
        jmp cmky3
           
cmky4:  and ah,7FH              ; Turn off minus bit.
        cmp ah,'?'              ; Need help?
        je cmky5
	cmp ah,' '		; Just a space - no error.
	je cmky51
	cmp ah,cr
	je cmky51
	cmp ah,tab
	je cmky51 
	cmp ah,esc		; Ignore escape?
	je cmky43
cmky41: mov ah,prstr
        mov dx,offset cmer03
        int dos
        jmp prserr              ; Parse error - give up.

cmky43:	mov ah,conout		; Ring a bell.
	mov dl,bell
	int dos
	mov bx,cmcptr
	dec bx
	mov cmcptr,bx
	mov cmdptr,bx
	dec cmccnt		; Don't count the escape.
	mov cmaflg,0		; Reset action flag.
	inc ch			; Account for a previous 'dec'.
	jmp cmky1		; Start over.

cmky5:  mov ah,prstr
        mov dx,cmhlp            ; Print the help text.
        int dos
	mov dx,offset crlf
	int dos
	mov dx,offset kerm
	int dos
	mov bx,cmdptr		; Get pointer into buffer.
	mov al,'$'
	mov [bx],al		; Add dollar sign for printing.
	mov dx,offset cmdbuf
	int dos
	dec cmcptr		; Don't keep it in the buffer.
	dec cmccnt		; Don't conut it.
	mov cmaflg,0            ; Turn off the action flag.
        jmp repars

cmky51:	jmp prserr

cmky6:  inc bx                  ; Find end of keyword.
        mov al,[bx]
        cmp al,'$'
        jne cmky6             
        inc bx                  ; Beginning of next command.
        inc bx
        inc bx
	mov dx,cmsptr		; Get old cmdptr.
	mov cmdptr,dx		; Restore.
	mov cmsflg,0FFH
        jmp cmky1               ; Keep trying.

cmky7:  call cmgtch             ; Get char.
	cmp ah,0
	js cmky71		; Ok if a terminator.
        dec bx
        jmp cmky6               ; No match - try next keyword.
cmky71: inc bx                  ; Get necessary data.
        mov bx,[bx]
	cmp ah,9BH		; An escape?
	jne cmky72
	mov ah,prstr
	mov dx,offset prsp      ; Print a space.
	int dos
	mov di,cmcptr
	dec di
	mov ah,20H
	mov [di],ah		; Replace escape char with space.
	mov cmaflg,0
	mov cmsflg,0FFH		; Pretend they typed a space.
cmky72: jmp rskp

; See if keyword is unambiguous or not from what the user has typed in.

cmambg:	cmp ch,0		; Any keywords left to check?
	jne cmamb0
	ret			; If not then not ambiguous.
cmamb0:	inc bx			; Go to end of keyword ...
	mov al,[bx]		; So we can check the next one.
	cmp al,'$'
	jne cmamb0
	add bx,4		; Point to start of next keyword.
	dec cl			; Don't count escape.
	mov dx,cmsptr		; Buffer with input typed by user.
cmamb1:	mov ah,[bx]		; Keyword char.	
	mov di,dx
	mov al,[di]		; Input char.
	cmp al,'a'		; Do capitalizing.
	jl cmam11
	cmp al,'z'+1
	jns cmam11
	and al,137O
cmam11:	cmp ah,al		; Keyword bigger than input (alphabetically)?
	jle cmamb2		; No - keep checking.
	ret			; Yes - not ambiguous.
cmamb2:	inc bx			; Advance one char.
	inc dx
	dec cl
	jnz cmamb1
	jmp rskp		; Fail - it's ambiguous.

cmifil: mov bx,dx               ; Get the fcb address in bx.
        mov cmfcb,bx            ; Save it.
        mov ch,0                ; Initialize char count.
        mov ah,0
        mov [bx],ah                     ; Set the drive to default to current.
	inc bx
        mov cmfcb2,bx
        mov cl,' '
cmifi0: mov [bx],cl                     ; Blank the FCB.
        inc bx
        inc ah
        cmp ah,0BH                      ; Twelve?
        jl cmifi0
cmifi1: call cmgtch             ; Get another char.
        cmp ah,0                        ; Is it an action character.
        jns cmifi2
        and ah,7FH                      ; Turn off the action bit.
        cmp ah,'?'                      ; A question mark?
        jne cmif12
        mov al,0
        mov cmaflg,al           ; Blank the action flag.
        dec cmcptr           ; Decrement the buffer pointer.
	dec cmccnt		; Decrement count.
;        jmp cmifi8              ; Treat like any other character.
	mov ah,prstr
	mov dx,offset filhlp	; Help  message.
	int dos
	mov dx,offset crlf
	int dos
	mov dx,offset kerm
	int dos
	mov bx,cmdptr
	mov al,'$'
	mov [bx],al		; Put in dollar sign for printing.
	mov dx,offset cmdbuf
	int dos
	jmp repars
cmif12: cmp ah,esc                      ; An escape?
        jne cmif13
        mov ah,0
        mov cmaflg,ah           ; Turn off the action flag.
        mov ah,conout
        mov dl,bell
        int dos         ; Ring the bell.
        mov bx,cmcptr           ; Move the pointer to before the escape.
        dec bx
        mov cmcptr,bx
        mov cmdptr,bx
        dec cmccnt              ; Decrement char count.
        jmp repars
cmif13: mov ah,ch                       ; It must be a terminator.
        cmp ah,0                        ; Test the length of the file name.
	jnz cmf3x
        jmp cmifi9               ; If zero complain.
cmf3x:  cmp ah,0DH
        js cmf3y
	jmp cmifi9              ; If too long complain.
cmf3y:  jmp rskp                ; Otherwise we have succeeded.
cmifi2: cmp ah,'.'
        jne cmifi3
        inc ch
        mov ah,ch
        cmp ah,1H                       ; Any chars yet?
      	jnz cmf2x
	jmp cmifi9               ; No, give error.
cmf2x:  cmp ah,0AH                      ; Tenth char?
      	js cmf2y
	jmp cmifi9              ; Past it, give an error.
cmf2y:  mov dl,9H
        mov dh,0
        mov bx,cmfcb
        add bx,dx               ; Point to file type field.
        mov cmfcb2,bx
        mov ch,9H               ; Say we've gotten nine.
        jmp cmifi1              ; Get the next char.
cmifi3: cmp ah,':'
        jne cmifi4
        inc ch
        cmp ch,2H                       ; Is it in right place for a drive?
        jne cmifi9              ; If not, complain.
        mov bx,cmfcb2
	sub bx,1
        mov ah,[bx]                     ; Get the drive name.
        sub ah,'@'              ; Get the drive number.
	mov cmfcb2,bx
 	mov bx,cmfcb
        mov [bx],ah                     ; Put it in the fcb.
        jmp cmifi1
cmifi4: cmp ah,'*'
        jne cmifi7
        mov ah,ch
        cmp ah,8H                       ; Is this in the name or type field?
        jz cmifi9               ; If its where the dot should be give up.
        jns cmifi5              ; Type.
        mov cl,8H               ; Eight chars.
        jmp cmifi6
cmifi5: mov cl,0CH              ; Three chars.
cmifi6: mov bx,cmfcb2           ; Get a pointer into the FCB.
        mov ah,'?'
        mov [bx],ah                     ; Put a question mark in.
        inc bx
        mov cmfcb2,bx
        inc ch
        mov ah,ch
        cmp ah,cl
        jl cmifi6               ; Go fill in another.
        jmp cmifi1              ; Get the next char.
cmifi7: cmp ah,'0'
        jl cmif8x
        cmp ah,'z'+1
        jns cmif8x
        cmp ah,'A'                      ; Don't capitalize non-alphabetics.
        jl cmifi8
        and ah,137O             ; Capitalize.
cmifi8: mov bx,cmfcb2           ; Get the pointer into the FCB.
        mov [bx],ah                     ; Put the char there.
        inc bx
        mov cmfcb2,bx
        inc ch
        jmp cmifi1

cmif8x:	push es
	mov cx,ds
	mov es,cx		; Scan uses ES register.
	mov di,offset spchar    ; Special chars.
	mov cx,20		; Twenty of them.
	mov al,ah		; Char is in al.
	repnz scasb		; Search string for input char.
	cmp cx,0		; Was it there?
	pop es
	jnz cmifi8
 
cmifi9: mov ah,prstr
        mov dx,offset cmer02
        int dos
        ret
 
cmofil: jmp cmifil              ; For now, the same as CMIFI.



cminbf: push dx
        push bx
        mov cx,dx               ; Save value here too.
        mov ah,cmaflg           ; Is the action char flag set?
        cmp ah,0
	je cminb1
        jmp cminb9              ; If so get no more chars.
cminb1: inc cmccnt              ; Increment the char count.
        mov ah,conin            ; Get a char.
        int dos
	mov ah,al		; Keep char in 'ah'.
        mov bx,cmcptr           ; Get the pointer into the buffer.
        mov [bx],ah                     ; Put it in the buffer.
        inc bx
        mov cmcptr,bx
        cmp ah,25O                      ; Is it a ^U?
        jne cminb2
cmnb12: mov ah,prstr
	mov dx,offset clrlin
	int dos
	mov ax,0920H	   		; Write spaces.
        mov bx,7 	           ; Clear the line.
	mov cx,80
        int bios
        mov ah,prstr
        mov dx,cmprmp           ; Print the prompt.
        int dos
        mov bx,offset cmdbuf
        mov cmcptr,bx           ; Reset the point to the start.
	mov cmccnt,0	           ; Zero the count.
        mov dx,cx               ; Preserve original value of dx.
        jmp repars              ; Go start over.
cminb2: cmp ah,10O                      ; Or backspace?
        jz cminb3
        cmp ah,del                      ; Delete?
        jne cminb4
        mov ah,prstr            ; Print the delete string.
        mov dx,offset delstr
        int dos
cminb3: mov ah,cmccnt           ; Decrement the char count by two.
        dec ah
        dec ah
        cmp ah,0                        ; Have we gone too far?
        jns cmnb32              ; If not proceed.
        mov ah,conout           ; Ring the bell.
        mov dl,bell
        int dos
        jmp cmnb12              ; Go reprint prompt and reparse.
cmnb32: mov cmccnt,ah           ; Save the new char count.
        mov ah,prstr            ; Erase the character.
        mov dx,offset clrspc
        int dos
        mov bx,cmcptr           ; Get the pointer into the buffer.
        dec bx                  ; Back up in the buffer.
        dec bx
        mov cmcptr,bx
        jmp repars              ; Go reparse everything.
cminb4: cmp ah,'?'                      ; Is it a question mark.
        jz cminb6
        cmp ah,esc                      ; Is it an escape?
        jz cminb8
        cmp ah,cr                       ; Is it a carriage return?
        jz cminb5
        cmp ah,lf                       ; Is it a line feed?
        jz cminb5
        cmp ah,ff                       ; Is it a formfeed?
        jne cminb7
        call cmblnk
	call locate
cminb5: mov ah,cmccnt           ; Have we parsed any chars yet?
        cmp ah,1
	jnz cminb6
        jmp prserr               ; If not, just start over.
cminb6: mov ah,0FFH             ; Set the action flag.
        mov cmaflg,ah
        jmp cminb9
cminb7: jmp cminb1		; Get another char.

cminb8: mov ah,prstr		; Don't print the escape char.
	mov dx,offset escspc
	int dos
	jmp cminb6
 
cminb9: pop bx
        pop dx
        ret
 
cmgtch: push cx
	push bx
        push dx
cmgtc1: mov ah,cmaflg
        cmp ah,0                        ; Is it set.
        jne cmgt10
        call cminbf             ; If the action char flag is not set get more.
cmgt10: mov bx,cmdptr           ; Get a pointer into the buffer.
        mov ah,[bx]                     ; Get the next char.
        inc bx
        mov cmdptr,bx
        cmp ah,' '                      ; Is it a space?
        jz cmgtc2
        cmp ah,tab                      ; Or a tab?
        jne cmgtc3
cmgtc2: mov ah,cmsflg           ; Get the space flag.
        cmp ah,0                        ; Was the last char a space?
        jne cmgtc1              ; Yes, get another char.
        mov ah,0FFH             ; Set the space flag.
        mov cmsflg,ah
        mov ah,' '
        pop dx
        pop bx
        jmp cmgtc5
cmgtc3: mov al,0
        mov cmsflg,al           ; Zero the space flag.
        pop dx
        pop bx
        cmp ah,esc
        jz cmgtc5
        cmp ah,'?'                      ; Is the user curious?
        jz cmgtc4
        cmp ah,cr
        jz cmgtc4
        cmp ah,lf
        jz cmgtc4
	cmp ah,ff
	je cmgtc4
	pop cx
	ret			; Not an action char, just return.
cmgtc4: dec cmdptr
cmgtc5: or ah,80H		; Make the char negative to indicate
	pop cx
	ret			; it is a terminator.
CMND	ENDP

; This routine blanks the screen.

CMBLNK	PROC	NEAR		; This is stolen from the IBM example.
	mov cx,0
	mov dx,184FH
	mov bh,7
	mov ax,600H
	int bios
	ret
CMBLNK  ENDP

; Cursor control.

LOCATE  PROC	NEAR
	mov dx,0		; Go to top left corner of screen.
	mov bh,0
	mov ah,2
	int bios
	ret
LOCATE  ENDP

 
MAIN 	ENDS			; End of code section.
	END	START
