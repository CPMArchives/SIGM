PROGRAM PGLST;
{Format words compactly for printing.
  Copyright 1979 by C. E. Duncan.
  Revised 13:35 1980 December 15.}
CONST
    MCL = 80;	{MAXIMUM CHARACTERS PER LINE}
    LPP = 60;	{LINES PER PAGE}
TYPE
    $STRING0 = STRING 0;
    $STRING255 = STRING 255;
VAR
    LL: INTEGER;	{ITEM LENGTH}
    NPL: INTEGER;	{ITEMS PER LINE}
    X: INTEGER;		{COUNT ITEMS PROCESSED}
    WRDFL: TEXT;	{INPUT FILE}
    PRNFL: TEXT;	{OUTPUT PRINT FILE}
    A: ARRAY[1..LPP] OF STRING 218;	{OUTPUT PAGE IMAGE}
FUNCTION LENGTH(X:$STRING255):INTEGER; EXTERNAL;
FUNCTION INDEX(X,Y:$STRING255):INTEGER; EXTERNAL;
PROCEDURE SETLENGTH(VAR X:$STRING0; Y:INTEGER); EXTERNAL;
PROCEDURE INIT;
VAR
    IFLN: STRING 14;	{INPUT FILE CP/M NAME}
    OULN: STRING 14;	{OUTPUT FILE CP/M NAME}
BEGIN
    WRITE('Name of file to be listed: ');
    READLN(IFLN);
    WRITE('Output print file name: ');
    READLN(OULN);
    WRITE('Item length: ');
    READLN(LL);
    LL := LL + 2;
    X := 0;
    RESET(IFLN,WRDFL);
    REWRITE(OULN,PRNFL);
    NPL := (MCL + 2) DIV LL;	{ITEMS PER LINE}
    LL := LL - 2
END;	{INIT}
PROCEDURE FILLPG;
VAR
    I,R,S,U,V,W: INTEGER;
    WRD: STRING 218;
BEGIN
    FOR W := 1 TO LPP	{CLEAR ARRAY}
    DO
	SETLENGTH( A[W], 0 )
    {OD};
    V := 1;
    WHILE (V <= NPL) AND (NOT EOF(WRDFL))
    DO
 	BEGIN
	S := (V-1)*(LL+2);
	U := 1;
	WHILE (U <= LPP) AND (NOT EOF(WRDFL))
	DO
	    BEGIN
	    READLN(WRDFL,WRD);
	    X := X + 1;
	    IF V = 1
	    THEN
		A[U] := WRD
	    ELSE
	      BEGIN
		R := S - LENGTH(A[U]);
		FOR I := 1 TO R
		DO
		    APPEND(A[U],' ')
		{OD};
		APPEND(A[U],WRD)
	      END
	    {FI};
	    U := U + 1
	    END
	{OD};
	V := V + 1
	END
    {OD}
END;	{FILLPG}
PROCEDURE LSTPG;
VAR
    I: INTEGER;
BEGIN
    I := 1;
    WHILE (I <= LPP)
    DO
	BEGIN
	IF ( LENGTH ( A[I] ) <> 0 )
	THEN
	    WRITELN(PRNFL,A[I])
	{FI};
	I := I + 1
	END
    {OD}
END;	{LSTPG}
BEGIN
    INIT;
    WHILE NOT EOF(WRDFL)
    DO
	BEGIN
	FILLPG;
	LSTPG
	END
    {OD};
    WRITELN(PRNFL,X,' items.');
    WRITELN(X,' items processed')
END.
