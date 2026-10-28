


FUNCTION INPUT_DATA(X,Y,LEN:BYTE; ALPHANUMERIC:BOOLEAN;
		    MAXIMUM_VALUE,MINIMUM_VALUE:REAL):$STRING255;

{function to position cursor on terminal screen, enter data, and then 
check the data to insure it is within acceptable limits...if it is not
then the function erases the entry and prompts the user for re-entry..
returns a string up to 80 char}

VAR
DATA:$STRING255;
I:BYTE;

BEGIN

MOVE_CURSOR(X,Y);
READ(DATA);
ŠWHILE (ALPHANUMERIC = TRUE) AND (LENGTH(DATA) > LEN) DO CORRECT(X,Y);

IF   LENGTH(DATA) = 0 THEN
BEGIN
	DATA:=' ';	
	FOR I:=  1 TO (LEN-1) DO  APPEND (DATA,' ');
END;

IF LENGTH(DATA) < LEN THEN
	FOR I:= LENGTH(DATA) TO LEN DO     APPEND(DATA,' ');

INPUT_DATA:=DATA;

END;
