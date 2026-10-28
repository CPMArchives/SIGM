Program rantest;
{ last edited: 7/15/81 }
var
  i: integer;
  r: real;
  seed: real;


FUNCTION RANDOM(VAR SEED: REAL):REAL;EXTERNAL;

begin
  seed := 4.0;
  While true do begin
    writeln;
    write('enter number of numbers to generate: ');
    readln(n);
    writeln;
    for i:=1 to n do begin
      r := random(seed);
      writeln( i:4,   r,  trunc(r*10), trunc(r*5) );
    end;
  end{while};
end.
 to n do begin
      r := random(seed);
      writeln( i:4,   r,  trunc(r*10), tru