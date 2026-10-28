(*$I+***********************************************************
*		PROGRAM ADDN
*	You type in N integers, and this program will print
*   them and their sum.
*
*	Written by Charlie Foster(The Brain-Drain) as practise
*	in programing in Pascal.
*
*	Nov 1979
****************************************************************
*)

PROGRAM ADDN;

VAR
   QTY : INTEGER;                    (* Quantity of values *)
   NUM : INTEGER;                    (* Individual datum *)
   SUM : INTEGER;                    (* Sum of values *)

BEGIN		                     (* Main program *)
	SUM := 0;
	WRITE('--How many numbers do you intend to sum togeather?-->  ');
	READ(QTY);
	WHILE QTY > 0 DO

	  BEGIN
		NUM := 0;
		WRITELN;
		WRITE('--- ENTER a number--> ');
		READ(NUM);
		SUM := SUM+NUM;
		QTY := QTY-1;
	  END;

	WRITELN;
	WRITELN('THE SUM IS: ', SUM);
	WRITELN
END.
 