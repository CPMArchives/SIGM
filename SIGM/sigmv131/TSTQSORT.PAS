PROGRAM tstqsort;
CONST
  Max_N 	= 5000;
  control_c	= false;
TYPE
  index 	= 0..Max_N;
  Scalar 	= REAL;
  real_array	= ARRAY[index] OF scalar;
  str8		= STRING 8;
VAR
  timestring	: str8;
  answer	: char;
  N,
  i, ix		: INTEGER;
  A		: real_array;
Procedure readq(VAR a:char);external;
Procedure time(VAR t:str8 );external;
Procedure Show;
var
  i: index;
begin
  for i:=1 to N do
    begin
      write(A[i]:8:0);
      if i mod 8 = 0 then writeln;
    end;
  writeln;
end;

{$IB:QQSORTR.PAS }

BEGIN (* MAIN *)
timestring := '  :  :  ';
 REPEAT { until control_c }
  repeat
    writeln;
    writeln('Enter number of items to sort');
    writeln(' 10 <= n <= 10,000');
    write('?');
    readln(N);
  until (N >= 10) and (N <= Max_N);

  writeln;
  writeln('Please stand by while I set up.');
  {$C-,M-,F- [ctrl-c OFF]}
  ix := 113;
  FOR i := 1 TO N DO
    BEGIN
      ix := (131*ix+1) mod 221;
      A[i] := 1.0 * ix;
      if (i mod 1000 = 0) then write(i);
    END;
  writeln;
  A[0] := 1.0 *( -maxint);			{$C+,M+,F+ [ctrl-c ON]}
  write('random array filled : do you want to see the unsorted version?');
  readq(answer);
  writeln;
  IF answer IN ['y','Y'] then show;
  writeln;
  WRITE('Press return when ready to start');
  readq(answer);
  writeln;
  write( CHR(7), 'START @ ');
  time(timestring);
  write(timestring,' ');
  IF qqsort_real(A,1,N) THEN 
   BEGIN
    time(timestring);
    writeln( CHR(7), 'DONE @ ' ,timestring);
    writeln
   END;
  write('Print the array (Y/N)?');
  readq(answer);
  writeln;
  If (answer='Y') or (answer='y') then Show;
  readq(answer);
 UNTIL control_c;
END.
