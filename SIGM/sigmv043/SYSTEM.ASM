	ENTRY	?BDOS,?BOOT,?FCB,?BUFF
	ENTRY	LDEM
?BDOS	EQU	5
?BOOT	EQU	0
?FCB	EQU	5CH
?BUFF	EQU	80H
LDEM:	MOV	E,M
	INX	H
	MOV	D,M
	INX	H
	RET
	END
