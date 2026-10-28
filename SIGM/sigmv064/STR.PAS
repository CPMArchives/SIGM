PROGRAM STR;{$P}
{$C-}
{$M-}
{$F-}
{$I+}
TYPE
$STRING0 = STRING 0;
$STRING80= STRING 80;
$STRING255 = STRING 255;
 
VAR
NUMBER:REAL;
DATA:$STRING80;

PROCEDURE SETLENGTH(VARX:$STRING0;Y:INTEGER);EXTERNAL;
FUNCTION LENGTH(X:$STRING255):INTEGER;EXTERNAL;

{function to convert a string "str" to a real number...
corresponds roughly to the VAL$ statement in BASIC}

FUNCTION STRTOREAL (STR:$STRING80):REAL;
LABEL 1;

VAR
DECVAL,SIGN,VAL:REAL;
DECIMAL,ERROR:BOOLEAN;
L,I,LEN:INTEGER;

BEGIN
VAL:=0;
DECVAL:=0;
LEN:=LENGTH(STR);
L:=LEN;
ERROR:=FALSE;
DECIMAL:=FALSE;
I:=1;
SIGN:=1.0;

IF LEN = 0 THEN 
	BEGIN
	ERROR:=TRUE;
	GOTO 1;
	END;

WHILE (DECIMAL = FALSE) AND (I < LEN + 1) DO
BEGIN

	CASE STR[I] OF

	 '-' : SIGN:=-1.0; 
	 '.' : DECIMAL:=TRUE;

	'0','1','2','3','4','5','6','7','8','9':
		VAL:=(VAL * 10) + (ORD(STR[I]) - 48); {48 = ord of zero}
       END; {OF CASE}

I:=I+1;

END; {of while}

WHILE (DECIMAL = TRUE) AND (L > I-1 ) DO  {i-1 because of last while loop}
	BEGIN	
		IF STR[L] IN ['0'..'9'] THEN
			DECVAL:=(DECVAL * 0.1) + ((ORD(STR[L]) - 48) * 0.1);
		L:=L-1;
	END;


1: { Exit immediately upon detection of a fatal error.}

STRTOREAL:=SIGN * (DECVAL + VAL);
END; {OF PROCEDURE}


BEGIN
END.