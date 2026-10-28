PROGRAM LEFTX;{$P,C-,M-,F-}
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

{function to return the "y" left most characters of a string "x"
where y is an integer value up to 255, and x is a string of maximum
length 255 characters.  Corresponds to BASIC command LEFT$(A$,x)..
requires pascal/z's external functions setlength and length.. }

FUNCTION LEFT(X:$STRING255; Y:BYTE):$STRING255;

{returns the first or left-most y characters in a string x}

LABEL 1;
VAR
LEN,I:INTEGER;
L:$STRING255;

BEGIN
SETLENGTH(L,0);
LEN:=LENGTH(X);

IF (LEN = 0) OR (Y < 1) THEN GOTO 1;
IF Y >= LEN THEN 
	BEGIN
	L:=X;
	GOTO 1;
	END;

{IF Y = 1 THEN 
	BEGIN
	L:=X[1];
	GOTO 1;
	END;}

FOR I:= 1 TO Y DO APPEND(L,X[I]);

1:
LEFT:=L;
END;

BEGIN
END.