
PROCEDURE CORRECT(X,Y:BYTE);
{procedure called by function input data...} 

VAR
I,A,B:INTEGER;
ALPHANUMERIC:BOOLEAN;
LEN:BYTE;
DATA:$STRING255;
ŠBEGIN

	ERASE_LINES (20,2);
	WRITE (CHR(7));
	MOVE_CURSOR (1,20);

	IF (ALPHANUMERIC = TRUE) AND (LENGTH(DATA) > LEN) THEN
	   WRITE('TERM TOO LONG ');

	
	MOVE_CURSOR(X,Y);
	WRITE (' ');
	A:=X;
	B:=Y;

	FOR  I:=1 TO  LENGTH(DATA) DO
	BEGIN
		MOVE_CURSOR(A,B);
		WRITE(' ');
		A:=A+1;
	END;

	MOVE_CURSOR(X,Y);
	WRITE('_');
	A:=X;
	B:=Y;
	FOR I:= 1 TO (LEN-1)  DO
	BEGIN
		MOVE_CURSOR(A,B);
		WRITE('_');
		A:=A+1;
	END;

	MOVE_CURSOR(X,Y);
	READ(DATA);
	ERASE_LINES(20,1);

END;
