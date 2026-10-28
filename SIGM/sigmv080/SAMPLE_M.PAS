PROGRAM Sample_M ;  { Program in Pascal/M to count to 10,000 }

{$D-  (Disable "Debug" option for speed) }

  CONST
    Start_number  = 1 ;
    End_number	  = 10000 ;
    Interval	  = 1000 ;
    Bell	  = 7 ;

  VAR
    Number  : Integer ;
    Go	    : Char ;

BEGIN

  Writeln ('Counting program in Pascal/M') ;
  Writeln ;
  Write ('Press <RETURN> to start: ') ;
  Readln (Go) ;
  Writeln ;
  Writeln ('Counting ...') ;
  Writeln ;

  FOR Number := Start_number TO End_number DO
{ (Remove comment brackets from next two lines for version 2 of program) }
  { IF (Number MOD Interval) = 0 THEN
      Writeln (Number) } ;
  Writeln ;

  Writeln (Chr (7), 'Finished -- Good-bye') ;
  Writeln ;

END .
val) = 0 THEN
      Writeln (Numbe