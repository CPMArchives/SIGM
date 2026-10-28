PROGRAM POWERX; {$P,C-,M-,F-}
{$I+}
TYPE
BYTE = 0..255;
VAR
RAISE:BYTE;
NUMBER:REAL;

{function to raise a number "x" to a power "y"...x must be real and y must be
an integer...greater than zero.  This corresponds to the BASIC arithematic
command ** as in A = x**2 .}


FUNCTION POWER (X:REAL; Y:BYTE):REAL;
LABEL 1;
VAR
I:INTEGER;
CALC:REAL;

BEGIN
	CALC:=1.0;

	IF Y < 0 THEN GOTO 1;
	
	CASE Y OF
	1: BEGIN
		CALC:=X;
		GOTO 1;
	   END;
	
	0: GOTO 1;
 
        end; {of case}

IF X = 1.0 THEN
		BEGIN
		CALC:=X*Y;
		GOTO 1;
		END;

IF X = 0.0 THEN
		BEGIN
		CALC:=0.0;
		GOTO 1;
		END;



IF (Y > 1) AND ( X <> 1.0) THEN 
		for  I:= 1 TO Y DO  CALC:=CALC*X;  
1:
POWER:=CALC;
END;

BEGIN
END.