PROGRAM tp;
CONST	maxn		= 512;
	doomsday	= FALSE;
TYPE	intarray	= ARRAY[1..maxn] OF INTEGER;
	byte		= 0..255;
VAR	x,y		: intarray;
	n,i		: INTEGER;
	dc		: byte;
	answer		: CHAR;
	penup		: BOOLEAN;
PROCEDURE profile(VAR x,y : intarray;
		  VAR n   : INTEGER;
		  dc      : byte;
		  m       : INTEGER;
		  VAR p   : BOOLEAN);EXTERNAL;
BEGIN
 REPEAT
 n  := 0;
 WRITE('enter dc ---> ');
 READ(dc);
 WRITELN('put hipad in stream mode : hit return when ready !');
 READ(answer);
 WRITELN('commencing profile : ');
 profile(x,y,n,dc,maxn,penup);
 WRITELN('done : n = ',n:3);
 IF penup 
    THEN WRITELN('PEN CAME UP')
    ELSE WRITELN('PEN NOT  UP');
 WRITELN;
 WRITE('Dump x and Y ?   ');
 READ(answer);
 IF answer IN ['y','Y']
    THEN BEGIN
          FOR i := 1 TO n DO
           BEGIN
            WRITE('x[',i:3,'] := ',x[i]);
            WRITELN('		','y[',i:3,'] := ',y[i]);
           END;
         END;
 READ(answer);
 UNTIL doomsday;
END.
