
(***************************************************************
*
*		STARS---game
*
*  Donated by Ray Penley, June 1980
*
****************************************************************)


PROGRAM SHOOTINGSTARS;
(*
**  PROGRAM TITLE:	SHOOTING STARS
**
**  WRITTEN BY:		MARK J. BORGERSON
**  DATE WRITTEN:	JUL 1976
**
**  WRITTEN FOR:	PERSONAL ENJOYMENT
**
**  TRANSLATED:		Translated from BASIC
**			 by Ray Penley, SEPT 1979
**			16 April 80 - added KEYIN.
**
*)

TYPE
  VECTOR = ARRAY[1..9] OF INTEGER;
Var
  seed1, seed2:	INTEGER;
  stars, F5:	VECTOR;
  C:		INTEGER;

Procedure KEYIN(VAR CIX : char); EXTERNAL;

Procedure INSTRUCTIONS;
Var
  I : INTEGER;
BEGIN
Writeln;
Writeln('If you like brain teasers then you''re in for some fun.');
Writeln('The object of this puzzle is to solve a 3 X 3 matrix such that');
Writeln('*''s appeas in all positions except in the center which will be');
Writeln('''. The positions on the matrix board are referred to by ROWS');
Writeln('then COLUMNS. The upper right hand position would be referred');
Writeln('to as; 1,3.');
Writeln('When a * is made a '', its immediate neighbors change state,');
Writeln('then is: *''s become '' and vice versa.');
Writeln('In addition, changing corner positions also changes the center');
Writeln('position; changing center position also changes outside');
Writeln('middle positions. Have FUN!');
Writeln;
	(* TIMING LOOP *)
  For I:=1 to 5000 do ;
END(*---of INSTRUCTIONS---*);

Procedure SKIP(LINES:INTEGER);
Var
  I : INTEGER;
BEGIN
  FOR I := 1 TO LINES DO Writeln
END(*---of SKIP---*);

Procedure HEADING;
Var
  A : INTEGER;
BEGIN
  Writeln(' ':20, '***  SHOOTING STARS  ***');
  SKIP(2);
  Writeln('DO YOU WANT INSTRUCTIONS (YES=1 NO=0)');
  READ(A);
  IF A=1 THEN INSTRUCTIONS
END(*---of HEADING---*);

Procedure CLEAR;
(*	!!!  DEVICE DEPENDENT ROUTINE !!!	*)
BEGIN
  Write( CHR(26) )
END(*---of CLEAR---*);

Procedure HOMEUP;
(*	!!!  DEVICE DEPENDENT ROUTINE !!!	*)
BEGIN
  Write( CHR(30) )
END(*---of HOMEUP---*);

(*=================================================*
   Implement a Fibonacci series Random number generator.
   Written for PASCAL/Z By Raymond E. Penley, September 1979
   Add these lines to your program

Var  seed1, seed2 : INTEGER;

	Within the body of the main program but
	BEFORE calling RANDOM:
   SEEDRAND;
*=================================================*)

Procedure SEEDRAND;
(* INITIAL VALUES FOR seed1 AND seed2 MAY BE
   INPUT HERE  *)
BEGIN
   seed1 := 10946;
   seed2 := 17711
END;

FUNCTION RANDOM : INTEGER;
(**
   RANDOM will return numbers from 0 to 32767.
   Call RANDOM using the following convention:
	 Range		 Use
	  0 - 32	RANDOM DIV 1000
	  0 - 327	RANDOM DIV 100
          0 - 32767	RANDOM

GLOBAL
   seed1, seed2 : INTEGER
**)
CONST
  HALFINT = 16383; (* 1/2 OF MAXINT *)
Var
  HALF1, HALF2, HALFADD : INTEGER;

BEGIN
  HALF1 := seed1 DIV 2;
  HALF2 := seed2 DIV 2;
  IF (HALF1+HALF2) >= HALFINT THEN
    HALFADD := HALF1 + HALF2 - HALFINT
  ELSE
    HALFADD := HALF1 + HALF2;
  seed1 := seed2;
  seed2 := HALFADD * 2;(* Restore from previous DIVision *)
  RANDOM := seed2
END(*---of RANDOM---*);

Procedure INITIALIZE;
BEGIN
  CLEAR;
  C := 0;  (* SHOT COUNTER *)
  stars[1] := (-23);	F5[1] := 1518;
  stars[2] := (-3);	F5[2] := 1311;
  stars[3] := (-19);	F5[3] := 570;
  stars[4] := (-11);	F5[4] := 3289;
  stars[5] :=    2;	F5[5] := 2310;
  stars[6] := (-5);	F5[6] := 1615;
  stars[7] := (-13);	F5[7] := 2002;
  stars[8] := (-7);	F5[8] := 1547;
  stars[9] := (-17);	F5[9] := 1190;
END(*---of INITIALIZE---*);

Procedure LOAD;
Var
  I, X7 : INTEGER;
BEGIN
  FOR I := 1  TO 9 DO
    BEGIN
    X7 := ( RANDOM DIV 100 );
    IF X7 > 200 THEN stars[I] := (-stars[I]);
    END  (*FOR*)
END(*---of LOAD---*);

Procedure BOARD;
Var
  J : INTEGER;
BEGIN
  HOMEUP;
  WRITE(' ':20);
  FOR J := 1 TO 9 DO
    BEGIN
      IF stars[ J ] < 0 THEN WRITE( '''        ');
      IF stars[ J ] > 0 THEN WRITE( '*        ');
      IF J MOD 3 = 0 THEN
  	BEGIN
	  SKIP(3);
	  WRITE(' ':20)
	END(*IF*)
    END(*FOR*);
  Writeln
END(*---of BOARD---*);

Procedure PLAYTHEGAME;
Var
  D, X	    : INTEGER;
  ENDOFGAME : BOOLEAN;

	FUNCTION CHECK : INTEGER;
	(*
	 Check to if the F value for the shot can be evenly
	 divided by the stars value for each position. If the
	 stars value divides into F without a remainder, the
	 STAR or black hole is inverted (its sign is changed).
	GLOBAL
	  X	:INTEGER;
	  stars, F5 :VECTOR   *)
	Var
	  B1, K, Z5 :INTEGER;
	BEGIN
	  B1 := 0;
	  FOR K := 1 TO 9 DO
	    BEGIN
	      Z5 := ( F5[ X ] DIV stars[ K ] ) * stars[ K ];
	      IF Z5 = F5[ X ] THEN stars[ K ] := (-stars[ K ])
	    END; (*FOR*)
	  FOR K := 1 TO 9 DO
		B1 := B1 +stars[ K ];
	  CHECK := B1
	END(*---of CHECK---*);

	Procedure INPUT;
	(*
	GLOBAL
	  C, X :INTEGER
	  stars   :VECTOR	*)
	Var
	  CIX : Char;
	  ERROR : BOOLEAN;
	BEGIN
	  REPEAT
	    ERROR := FALSE;(*Turn ERROR flag off for REPEAT *)
	    WRITE('Your Shot ');
	    KEYIN(CIX);
	    X := (ORD(CIX) -ORD('0'));
	    Writeln;
	    C := C +1;
	    IF (X<1) OR (X>9) THEN
	      ERROR := TRUE
	    ELSE
	      IF stars[ X ] <= 0 THEN
	        BEGIN
		  Writeln('You can only Shoot Stars');
		  ERROR := TRUE
		END(* else *)
	  UNTIL NOT ERROR;
	  Writeln
	END(*---of INPUT---*);

BEGIN  (* PLAYTHEGAME *)
  ENDOFGAME := FALSE;
  REPEAT
    INPUT;
    D := CHECK;
    BOARD;
    IF D = (-100) THEN
      BEGIN
	Writeln('You lost!!!');
	ENDOFGAME := TRUE
      END
    ELSE
      IF D=96 THEN
	BEGIN
	  Writeln('You WIN!!!');
	  Writeln('You fired', C:3, ' shots');
	  ENDOFGAME := TRUE
	END
  UNTIL ENDOFGAME
END(*---of PLAYTHEGAME---*);

BEGIN (* MAIN PROGRAM *)
  HEADING;
  CLEAR;
  INITIALIZE;
  SEEDRAND; (* seed the Random Number Generator *)
  LOAD;
  BOARD;
  PLAYTHEGAME
END(*---of SHOOTING STARS---*).
