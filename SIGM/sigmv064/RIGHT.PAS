PROGRAM RIGHTX;{$P,C-,M-,F-}
{$I+}

TYPE
$STRING80 = STRING 80;
$STRING0 = STRING 0;
$STRING255 = STRING 255;
BYTE = 0..255;
VAR
DATA:$STRING255;
NUMBER:INTEGER;

function length(x:$string255):INTEGER;external;
PROCEDURE setlength(var x:$string0; y : INTEGER); external;

{function to return the "y" right most characters of a string "x"..
corresponds to the BASIC command RIGHT$(A$,X);..
requires pascal/z external functions length and setlength..}

FUNCTION RIGHT(X:$STRING255; Y:BYTE):$STRING255;

{returns the last or right-most y characters in a string x}

LABEL 1;
VAR
LEN,I:INTEGER;
R:$STRING255;

BEGIN
SETLENGTH(R,0);
LEN:=LENGTH(X);

IF (LEN = 0) OR (Y < 1) THEN GOTO 1;
IF Y >= LEN THEN 
	BEGIN
	R:=X;
	GOTO 1;
	END;

FOR I:= (LEN -Y+1) TO LEN DO APPEND(R,X[I]);

1:
RIGHT:=R;
END;

BEGIN
END.