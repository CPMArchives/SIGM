	OPT	OBJ-H		Intel HEX format
	ORG	$4000

LOC	EQU	$3210

FRONT	MOVE.L	D1,D0
	MOVE.B	D1,D0
	MOVE.W	D1,D0
	MOVE	D1,D0		data reg direct
	MOVE	A1,D0		address reg direct
	MOVE	(A1),D0		address reg indirect
	MOVE	(A1)+,D0	with post increment
	MOVE	-(A1),D0	with pre decrement
	MOVE	2(A1),D0	with index
	MOVE	2(A1,D1),D0	with index and offset
	MOVE	$3210,D0	absolute short
	MOVE	$3210.L,D0	absolute long forced
	MOVE	(LOC).L,D0	isolate .L from symbol LOC
	MOVE	$43210,D0	absolute long
	MOVE	DATA(PC),D0	pc relative
	MOVE	DATA(PC,D1),D0	pc relative with index
	MOVE	#$3210,D0	immediate

	ADD.L	D1,D0
	ADD.B	D1,D0
	ADD.W	D1,D0
	ADD	D1,D0
	ADD	#2,D0
	ADDQ	#2,D0
	ADD	#9,D0
	ADDI	#9,D0

	DC.B	'Hello'
	DC	'Hello'

DATA	DCB	3,$3210

	END
