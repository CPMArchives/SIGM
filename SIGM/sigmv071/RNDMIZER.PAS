Program rtest2;
{ 11/27/81 rep }
var
  a1, a2 ,a3: integer;
  seed: real;


function random( var seed: real):real; external;

procedure randomize; external;


BEGIN
  a1 := 0; a2 := 0; a3 := 0;
  Write('Enter your first move -->');
  RANDOMIZE;
  readln( a1 );
  writeln('First twenty numbers generated:' );
  for a3:=1 to 20 do begin
    write( a3:2 );writeln( trunc(random(seed)*10) );
  end;
  writeln;
  writeln( 'NOTE: first move generated to block #', a1:1 );
END.



PROCEDURE RANDOMIZE;
{ SEED THE RANDOM NUMBER GENERATOR BASED ON A RANDOM TIME DELAY }
var	dummy: real;

  function constat: boolean; external;

begin
  seed := 4.0;{ lucky guess }
  { generate random numbers until a key press is detected }
  while not constat do
    dummy := random( seed );
end{of randomize};

