; Program to convert KERMIT.EXE to all printable characters.  For each
; byte of the file, convert to two characters in the range 20 to 2F. 
; This is done by adding a space to each nibble.  The file KERMIT.FIX
; is created with 64 characters per line.
;
; Daphne Tzoar
; 1/83
; Columbia University Center for Computing Activities

DOS	EQU	21H

STACK	SEGMENT	PARA STACK 'STACK'
	DW 	100 DUP (0)
STK	EQU	THIS WORD
STACK 	ENDS	

DATAS	SEGMENT	PARA PUBLIC 'DATAS'
buff	db	80H DUP(0)
bufone	db	80H DUP(0)
buftwo	db	80H DUP(0)
fcbold	db	25H DUP(0)
fcbnew	db	25H DUP(0)
oldstk	dw	?
kold	db	'KERMIT  EXE$'
knew	db	'KERMIT  FIX$'
chrcnt	db	0
datcnt	db	0
eoflag	db	0
crflg	db	0
cnt	db	0
DATAS	ENDS

MAIN	SEGMENT	PARA PUBLIC 'MAIN'
START	PROC	FAR
	ASSUME CS:MAIN,DS:DATAS,SS:STACK,ES:NOTHING

	push ds				; Initialization
	sub ax,ax
	push ax

	mov ax,datas
	mov ds,ax
	sub ax,ax

	mov oldstk,sp

	mov ah,1AH			; Use my own DTA
	mov dx,offset buff
	int dos
	call one
	mov sp,oldstk
	ret
START 	ENDP
	
ONE	PROC	NEAR
	mov bx,offset fcbold
	mov ah,0
	mov [bx],ah			; Use default drive.
	inc bx
	mov di,offset kold		; Get name of original file.
kerm3:	mov ah,[di]
	cmp ah,'$'			; Got all the data?
	je kerm4
	mov [bx],ah
	inc di
	inc bx
	jmp kerm3
kerm4:  mov bx,offset fcbnew
	mov ah,0
	mov [bx],ah
	inc bx
	mov di,offset knew
kerm5:	mov ah,[di]
	cmp ah,'$'
	je kerm6
	mov [bx],ah
	inc di
	inc bx
	jmp kerm5

kerm6:	mov ax,0
	mov bx,offset fcbold+0CH
	mov [bx],ax			; Zero current block number.
	mov bx,offset fcbold+0EH
	mov [bx],ax			; Lrecl.
	mov bx,offset fcbold+20H
	mov [bx],ah			; Current record (of block).
	inc bx
	mov [bx],ax			; Current record (of file).
	mov bx,offset fcbold+23H
	mov [bx],ax
	mov ah,0FH			; Open file.
	mov dx,offset fcbold
	int dos

	mov ax,0
	mov bx,offset fcbnew+0CH
	mov [bx],ax			; Zero current block number.
	mov bx,offset fcbnew+0EH
	mov [bx],ax			; Lrecl.
	mov bx,offset fcbnew+20H
	mov [bx],ah			; Current record (of block).
	inc bx
	mov [bx],ax			; Current record (of file).
	mov bx,offset fcbnew+23H
	mov [bx],ax
	mov ah,16H			; Create file.
	mov dx,offset fcbnew
	int dos
	mov eoflag,0			; Not end-of-file yet.
	mov datcnt,0			; Chars in write-out buffer.
	mov chrcnt,0			; Chars in read-to buffer.
	mov crflg,0
	mov cnt,0
	mov bx,offset bufone
	mov di,offset buftwo

kerm1:	cmp chrcnt,0H
	jne kerm0
	call inbuf			; Get a buffer-full.
	  jmp kerm9
	mov ax,ds
	mov es,ax			; Move for Dest uses ES register.
	mov si,offset buff
	push di
	mov di,offset bufone		; Move read-in data to bufone.
	mov cx,80H
	rep movs es:bufone,buff
	pop di

	mov bx,offset bufone		; Where the chars are.
	mov chrcnt,80H			; Number of chars.
kerm0:	cmp datcnt,80H
	je kerm2
	dec chrcnt
	mov ah,[bx]			; Get a char.
	mov ch,ah			; Save here.
	and ah,0F0H			; Get high nibble.
	and ch,0FH			; Lower nibble.
	mov cl,4
	shr ax,cl
	add ah,' '			; Make printable.
	mov [di],ah
	inc datcnt
	inc di
	add ch,' '
	mov [di],ch
	inc datcnt
	inc di
	inc bx
	add cnt,2
	cmp cnt,40H			; Time to add CRLF?
	jne kerm1
	mov cnt,0			; Reset counter.
	cmp datcnt,80H			; Have room for it?
	jne kerm8			; Yup, we do.
	mov crflg,0FFH
	jmp kerm2

kerm8:	mov crflg,0
	mov ax,0A0DH
	mov [di],ax
	inc di
	inc di
	add datcnt,2
	jmp kerm1

kerm2: 	mov ax,ds
	mov es,ax			; Move for Dest uses ES register.
	mov si,offset buftwo
	mov di,offset buff
	mov cx,80H
	rep movs es:buff,buftwo		; Must use BUFF for r/w to file.

	mov ah,15H			; Write out to file two.
	mov dx,offset fcbnew
	int dos
	mov datcnt,0
	mov di,offset buftwo		; Start at beginning of buffer.
	cmp crflg,0FFH			; Had our buffer filled prior to CRLF?
	je kerm8			; Yup.
	jmp kerm1			; Get new buffer-full.

kerm9:	mov ah,10H			; Close files.	
	mov dx,offset fcbold
	int dos
	mov dx,offset fcbnew
	int dos
	ret

inbuf:  cmp eoflag,0			; End of file?
	je inbuf0			; Nope.
	ret
inbuf0:	mov dx,offset fcbold
	mov ah,14H			; Read from file.
	int dos
	cmp al,0
	je inbuf2
	mov eoflag,0FFH
inbuf2: jmp rskp
ONE 	ENDP

RSKP	PROC  NEAR
	pop bp
	add bp,3
	push bp
	ret
RSKP	ENDP

MAIN	ENDS
	END 	START
