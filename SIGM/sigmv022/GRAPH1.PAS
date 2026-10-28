
(*$I+****************************************************************

			GRAPHIC DEMO PROGRAM

     This program gives a graphic representation of a function
f(x) = exp(-x) * sin(2*pi*x).  I adapted it from Jensen, page 30.

written by CHARLIE FOSTER
Feb 1980

****************************************************************
*)

PROGRAM GRAPH1;

CONST
	D = 0.0625;	(* 1/16,16 LINES FOR INTERVAL [X,X+1] *)
	S = 32;		(* 32 CCHARACTER WIDTHS FOR INTERVAL [Y,Y+1] *)
	H = 34;		(* CHARACTER POSITION OF X-AXIS *)
	C = 6.28318;	(* 2*PI *)
      LIM = 32;
VAR
	X,Y : REAL;
	I,N : INTEGER;
BEGIN
	FOR I := 0 TO LIM DO
		BEGIN
		  X := D*I;
		  Y := EXP(-X)*SIN(C*X);
		  N := ROUND(S*Y)+H;
		REPEAT
		  WRITE(' ');
		  N := N-1;
		UNTIL
		  N = 0;
		  WRITELN('*')
		END
END.
