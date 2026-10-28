FUNCTION median( VAR list   : real_array;
		 left,right : INTEGER;
		 VAR midval : REAL   ) : BOOLEAN;

{$c-,m-,f-,r-  [turn off compiler options for speed : median is debugged] }

{
Author  : G.M.Acland.; University of Pennsylvsania ;1982.
Comment : Determines the median value of the array segment "list",returning
it in the variable midval.If (right - left + 1) < 1 returns FALSE.
	  Uses the PROCEDURE select.
}
VAR
	ok	: BOOLEAN;
	n,k	: INTEGER;
	low	: REAL;
BEGIN
 n := right - left + 1;
 IF n < 1 THEN median := FALSE
 ELSE BEGIN
  IF n = 1 THEN midval := list[left]
  ELSE BEGIN
   IF ODD(n) THEN
    BEGIN
     k      := (n + 1) DIV 2;
     median := select(list,left,right,k);
     midval := list[k];
    END 
    ELSE BEGIN
     k      := n DIV 2;
     ok     := select(list,left,right,k);
     low    := list[k];
     k      := k + 1;
     median := ok AND select(list,left,right,k);
     midval := (low + list[k])/2.0;
    END;
   END; { of : if n = 1 }
  END;  { of : if n < 1 }
END;    { of : function median }
