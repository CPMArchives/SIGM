	ENTRY	?WRNXT
	EXTRN	?BDOS
	EXTRN	?BOOT
?WRNXT:	MOV	E,A
	MVI	C,2
	CALL	?BDOS
	RET		;RETURN TO USER CODE
	ENTRY	?RNX
?RNX:	MVI	C,1
	CALL	?BDOS
	RET		;RETURN TO USER CODE
	ENTRY	?ISTOP
?ISTOP:	MVI	C,9
	ORI	'0'
	STA	STNO
	LXI	D,STOPMG
	CALL	?BDOS
	JMP	?BOOT
	entry	?msg
?msg:	xthl
	mvi	b,9
ms1:	mov	e,m
	push	b
	push	h
	mvi	c,2
	call	?bdos
	pop	h
	pop	b
	inx	h
	dcr	b
	jnz	ms1
	xthl
	ret
STOPMG:	DB	0DH,0AH,'STOP STATEMENT '
STNO:	DB	'0'
	DB	' IN SOURCE CODE$'
	end
