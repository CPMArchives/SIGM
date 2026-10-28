
(***********************************************************
*
*		PASCAL'S TRIANGLE
*
*	When I saw this algorithm I just had to add
*  it to our collection.  It don't do much but it's still
*  nice to hang from the wall.  If anyone has something
*  similar, how about donating it to Z-ug.
*
* Courtesy of Charlie Foster
* June 1980
*
***********************************************************)

PROGRAM PASCAL;

CONST
	N=13;
VAR
	I,J : INTEGER;
          A : ARRAY[1..N] OF INTEGER;
BEGIN
	WRITELN;
	WRITELN('            zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz ');
	WRITELN('              P A S C A L s   T R I A N G L E   ');
	WRITELN('            zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz ');
	WRITELN;
       FOR I := 1 TO N DO
          BEGIN
                A[I] := 1;
               FOR J := I-1 DOWNTO 2 DO
                A[J] := A[J-1] + A[J];
                WRITE(' ':2*(N-I)+1);
               FOR J :=1 TO I DO WRITE(A[J]:4);
                WRITELN
          END
END.
