PROGRAM UCASE;{$P,C-,M-,F-}
{$I+}
TYPE
$STRING0 = STRING 0;
$STRING80 =STRING 80;
$STRING255 = STRING 255;

VAR
DATA:$STRING80;
FUNCTION LENGTH(x:$STRING255):INTEGER;EXTERNAL;
PROCEDURE SETLENGTH(VAR X:$STRING0; Y:INTEGER);EXTERNAL;

{function to convert a string of maximum length = 255 to all upper
case letters, and return the converted string..corresponds to the BASIC
command UCASE$.  
requires pascal/z's external functions, length and setlength}

FUNCTION UCASE(X:$STRING255):$STRING255;
LABEL 1;
VAR
I,LEN,ASCII:INTEGER;
UCASEX:$STRING255;

BEGIN
SETLENGTH(UCASEX,0);
LEN:=LENGTH(X);
IF (LEN = 0) OR (LEN > 255)  THEN GOTO 1;

FOR I:=1 TO LEN DO
	
	IF (ORD(X[I]) > 96) AND (ORD(X[I]) < 123) THEN 
	APPEND(UCASEX,CHR(ORD(X[I])-32)) ELSE
	APPEND(UCASEX,X[I]);

{97 represents a little 'a' and 122 a little 'z'..32 is the offset between
  a capital and a little letter in ascii code}

UCASE:=UCASEX;
1: {immediate exit upon fatal error}

END;

Begin
end.