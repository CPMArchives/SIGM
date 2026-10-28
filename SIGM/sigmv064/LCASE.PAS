PROGRAM LCASE;{$P,C-,M-,F-}
{$I+}
TYPE
$STRING0 = STRING 0;
$STRING80 =STRING 80;
$STRING255 = STRING 255;

VAR
DATA:$STRING80;
FUNCTION LENGTH(x:$STRING255):INTEGER;EXTERNAL;
PROCEDURE SETLENGTH(VAR X:$STRING0; Y:INTEGER);EXTERNAL;

{function to convert a string "x" to all lower case characters and then
return this converted string..
corresponds to the BASIC command LCASE$(A$)..}


FUNCTION LCASE(X:$STRING255):$STRING255;
LABEL 1;
VAR
I,LEN,ASCII:INTEGER;
LCASEX:$STRING80;

BEGIN
SETLENGTH(LCASEX,0);
LEN:=LENGTH(X);
IF (LEN = 0) OR (LEN > 255)  THEN GOTO 1;

FOR I:=1 TO LEN DO
	
	IF (ORD(X[I]) > 64) AND (ORD(X[I]) < 91) THEN 
	APPEND(LCASEX,CHR(ORD(X[I])+32)) ELSE
	APPEND(LCASEX,X[I]);

{97 represents a little 'a' and 122 a little 'z'..32 is the offset between
  a capital and a little letter in ascii code}

LCASE:=LCASEX;
1: {immediate exit upon fatal error}

END;

Begin
end.