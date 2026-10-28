(**************************************************
*
*	Add this to your library. Ray Penley wrote
*  this when the furnished program had a bug but it
*  is still nice to have.
*
*  donated Sept,1980
***************************************************)

PROGRAM COSINE_DUMMY;
(*$I+*)
FUNCTION COSINE(X:REAL):REAL;
{+++   COSINE ROUTINE, ANGLE "X" MUST BE IN RADIANS   +++}
CONST	PI = 3.1415926536;
	J = 2;
VAR	M,N : INTEGER;
	R,S,T,U,V : REAL;
(*
	NAME COSINE
	ENTRY COSINE
*)
	FUNCTION FIX(Y,P: REAL): REAL;
	VAR	SGN : -1..1;
	BEGIN
	  IF Y>0.0 THEN
	    SGN := 1
	  ELSE IF Y=0.0 THEN
	    SGN := 0
	  ELSE
	    SGN := -1;
	  FIX := SGN * TRUNC(ABS(Y)/P);
	END;
(*
COSINE:
*)
BEGIN
  R := 0.0;
  IF ABS(X)>PI THEN R := FIX(X,PI);
  X := X - R * PI;
  M := -1;
  N := 0;
  S := 1.0;
  T := 1.0;
  U := -X * X;
  REPEAT
    V := S;
    M := M + J; N := N + J;
    T := T*U/(M*N) ;
    S := S + T;
  UNTIL (S = V);
  IF (TRUNC(R) MOD J<>0) THEN S := -S;
  COSINE := S;
END;
(*$I-*)
begin end.
