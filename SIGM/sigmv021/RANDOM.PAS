(*$I+	[include Pascal prgm stmts]	*)
Program RandomDummy;
var	SEED1, SEED2 : INTEGER;
(*
==============================================
 PROGRAM TITLE:	Random Number Generator

 WRITTEN BY:	Raymond E. Penley
 DATE WRITTEN:	27 June 1980

 WRITTEN FOR:	Pascal/Z Users Group

 SUMMARY:
	Implements a Fibonacci series Random number generator.
	RANDOM will return numbers from 0 to x

		Call as			  Returns
		-------			------------
	    real := RANDOM(10);		0.0 to 10.0
	    real := RANDOM(112);	0.0 to 112.0
	     I := TRUNC(RANDOM(10));      0 to 10

**
  Add these lines to your PASCAL source program:

    Procedure SEEDRAND; EXTERNAL;
    Functin RANDOM(X: Integer): REAL; external;

  Also within the body of the main program
  but BEFORE calling RANDOM(X);

	  SEEDRAND;

==============================================
*)

PROCEDURE SEEDRAND;
(* INITIAL VALUES FOR SEED1 AND SEED2 ARE HERE  *)
(*
	NAME RANDOM
	ENTRY SEEDRAND,RANDOM

SEEDRAND:
*)
Begin
   SEED1 := 10946;
   SEED2 := 17711
END;



Function Random(x: integer): real;
(*
GLOBAL
  SEED1, SEED2 : INTEGER		*)
CONST
  factor = Maxint;
  HALFINT = 16383; (* 1/2 OF MAXINT *)
VAR
  x1 : real;
  temp1, temp2, HALF_ADDER : INTEGER;
(*
RANDOM:
*)
Begin
(* Take 1/2 of the seeds for the comparison test *)
  temp1 := SEED1 DIV 2;
  temp2 := SEED2 DIV 2;
  IF (temp1+temp2) >= HALFINT then{the number is too big -}
    { scale it down }
    HALF_ADDER := temp1 + temp2 - HALFINT
  ELSE
    HALF_ADDER := temp1 + temp2;
  SEED1 := SEED2;
  (* Restore from previous DIVision *)
  SEED2 := HALF_ADDER * 2;
  (*---Convert X to real and divide by factor---*)
  x1 := ((X*1.0)/factor);
  (*---Return random number scaled by factor---*)
  RANDOM := ( SEED2 * x1 );
End{ of RANDOM(X) };
(*$I-	[turn off now]	*)

(*---dummy program---*)
begin end.
