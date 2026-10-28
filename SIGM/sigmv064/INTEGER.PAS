PROGRAM xint;{$P}
{$C-}
{$M-}
{$F-}
{$I+}
TYPE
$STRING0 = STRING 0;
$STRING80= STRING 80;
$STRING255 = STRING 255;
 
VAR
NUMBER:INTEGER;
DATA:$STRING80;

PROCEDURE SETLENGTH(VARX:$STRING0;Y:INTEGER);EXTERNAL;
FUNCTION LENGTH(X:$STRING255):INTEGER;EXTERNAL;

{the following function converts a string to an integer.
as written, the string has a maximum size of 80 char.  
requires pascal/z's external function: length}

FUNCTION STRTOINT (STR:$STRING80):INTEGER;
LABEL 1;

VAR
I,LEN,SIGN,VAL:INTEGER;

BEGIN
VAL:=0;
LEN:=LENGTH(STR);
I:=1;
SIGN:=1;

IF LEN = 0 THEN	GOTO 1;

REPEAT

	CASE STR[I] OF

	 '-' : SIGN:=-1; 
	 '.' : GOTO 1;

	'0','1','2','3','4','5','6','7','8','9':
		VAL:=(VAL * 10) + (ORD(STR[I]) - 48); {48 = ORD OF 0}

       END; {OF CASE}

I:=I+1;

UNTIL I > LEN;


1: { Exit immediately upon detection of a fatal error.}

STRTOINT:=SIGN * VAL;
END; {OF PROCEDURE}


BEGIN         
END.