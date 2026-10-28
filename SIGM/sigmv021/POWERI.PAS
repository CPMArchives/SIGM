
(*******************************************************
*
*		DEMO for POWERS function
*
*	I think Ray Penley sent me this one just for 
*  practise.  It works so why not.
*
*  July 1980
*
******************************************************

Program PowerI;
label 1;
var	number,zx: real;
	P: integer;

Function power(x: real; y: integer): real; external;

begin
1:writeln;
  writeln('Enter a number ?');readln(number);
  writeln('To what power ?');readln(P);
  zx := POWER(number,P);
  writeln(number,' to the ',P,' power = ',zx);
  goto 1;
end.
