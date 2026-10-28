PROGRAM REPCHAR;{$P,C-,M-,F-}
{$I+}
TYPE
$STRING255= STRING 255;
$STRING80 = STRING 80;
$STRING0 = STRING 0;
BYTE = 0..255;

 VAR
C:CHAR;
NUMBER:INTEGER;

FUNCTION LENGTH(X:$STRING255):INTEGER;EXTERNAL;
PROCEDURE SETLENGTH(VAR X:$STRING0; Y:INTEGER);EXTERNAL;

{function to repeat "x" number of times a character"y";  especially
useful in write commands...
requires pascal/z's external functions length and setlength..}

FUNCTION REPEAT_CHAR (X:BYTE; Y:CHAR):$STRING255;
LABEL 1;
VAR
RC:$STRING255;
I:INTEGER;

BEGIN
SETLENGTH(RC,0);
IF (I < 1) OR (I > 255) THEN GOTO 1;

{note well:  this will permit writing any character, printable or
 otherwise....e.g. a series of x's or a series of bells ringing!}

FOR I:= 1 TO X DO APPEND(RC,Y);

1:
REPEAT_CHAR:=RC;
END;


BEGIN
END.