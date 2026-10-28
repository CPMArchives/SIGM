(*$I+ *)
program dly;

Procedure DELAY(timer:integer);
{ call delay with timer = number seconds * 10 }
{  DELAY(10);	will give about 1 second delay }
{  DELAY(5);	will give about 1/2 second delay }
CONST	factor = 172;
var	ix,jx : integer;
begin
  for ix:=1 to factor do
    for jx:=1 to timer do {dummy};
end{of delay};

{dummy program}
begin end.
