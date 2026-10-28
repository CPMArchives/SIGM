PROCEDURE RANDOMIZE;
{ SEED THE RANDOM NUMBER GENERATOR BASED ON A RANDOM TIME DELAY }
var	dummy: real;

  function constat: boolean; external;

begin
  seed := 4.0;{ sorry but we must start at a known point }
  { generate random numbers until a key press is detected }
  while not constat do
    dummy := random( seed );
end{of randomize};
