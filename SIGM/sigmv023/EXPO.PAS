(*$I+,C-,S- ****************************************
:
:		EXPONENT PROGRAM
:
:	Ken Kuller donated this little program to the
:  Pascal/Z Users Group in case someone else needed a
:  benchmark program. 
:
***************************************************)

Program Number_cruncher;

Const
  zero      =        0.0;
  epsilon   = 0.00000001;
  one       =        1.0;

  initial   =      -10.0;       { First value in table }
  increment =        0.5;       { Size of step         }
  last      =       10.0;       { Last value in table  }


Var
  x, term   :       real;
  expo      :       real;
  n         :    integer;


Function Series (last_term, X :    real;
                 var n        : integer ) : real;
  { This function calculates "e to the x" by evaluating the series,  }
  { whose terms are  ( x**n ) / n!, and adding the them in order of  }
  { increasing magnitude to reduce the truncation error.             }

  Var
    term : real;

  Begin    { Series }
    If x = zero
      then
        series := one
      else    { x <> 0 }
        if last_term < epsilon
          then    { solution is close enough }
            series := last_term
          else
            begin
              n := n + 1;
              term := last_term * x / n;
              series := series ( term, x, n ) + last_term
            end    { last_term > epsilon }
  End;    { function series }


Function Reciprocal ( { inverts } parameter : real ) : real;

  Begin
    Reciprocal := one / parameter
  End;    { Reciprocal }


Function Exponent ( x : real ) : real;

  Begin
    If x < zero
      then
        exponent := reciprocal ( exponent ( -x ) )
      else
        begin
          n := 0;
          term := one;
          exponent := series ( term, x, n )
        end    { else }
  End;    { Exponent }


Begin    { main program }

  { write table heading }
  Writeln ( '           X      E to the X' );
  Writeln ( '         =====  ============' );

  x := initial - increment;
  repeat
    x := x + increment;
    expo := exponent(x);
    writeln ( x :4 :1, expo :12 :6 )
  until x = last

end.
