PROGRAM SPACEX; {$P,C-,M-,F-}
{$I+}
TYPE
$STRING80 = STRING 80;
$STRING0 = STRING 0;
$STRING255 = STRING 255;
BYTE = 0..255;
VAR
DATA:$STRING255;
NUMBER:INTEGER;

FUNCTION LENGTH(X:$STRING255):INTEGER;EXTERNAL;
PROCEDURE SETLENGTH(VAR X:$STRING0; Y:INTEGER);EXTERNAL;

{function to return "x" number of spaces to a write command or statement..
corresponds to BASIC commands such as SPACE$(X) or TAB(x)...
although in structured programming, it is stylistically better to format
output using format commands such as x:9:2 for a real number or 
name:30 for a string, this function is often useful in designing a layout,
and certainly is more "readable" in a program...}


FUNCTION SPACE(X:BYTE):$STRING255; 
VAR
I:INTEGER;
S:$STRING255;

BEGIN
SETLENGTH(S,0);
IF (X > 0) AND (X < 256) THEN FOR I:=1 TO X DO APPEND(S,' ');

SPACE:=S;
END;

BEGIN
END.
