PROGRAM MIDX; {$P,C-,M-,F-}
{$I+}

TYPE
$STRING80=STRING 80;
$STRING0 = STRING 0;
$STRING255 = STRING 255;
BYTE = 0..255;
VAR
DATA:$STRING255;
START,STOP:INTEGER;


FUNCTION LENGTH(X:$STRING255):INTEGER;EXTERNAL;
PROCEDURE SETLENGTH(VAR X:$STRING0;Y:INTEGER);EXTERNAL;

{function to extract characters from within a string, starting at
position "y" and ending at position "z"..
corresponds to BASIC command  MID$(A$,X,Y) } 

FUNCTION MID(X:$STRING255; Y,Z:BYTE):$STRING255; 

{y = starting position and z = the ending position in string x}

LABEL 1;
VAR
LEN,I:INTEGER;
MIDDLE:$STRING255;

BEGIN
SETLENGTH(MIDDLE,0);
LEN:=LENGTH(X);

IF (Y < 1) OR (Y > Z) OR ( Y > LEN) OR (LEN = 0) OR (Z > 255) THEN GOTO 1; 
IF Z > LEN THEN Z:=LEN;

FOR I:= Y TO Z DO APPEND(MIDDLE,X[I]);

1:
MID:=MIDDLE;
END;

BEGIN
END.
