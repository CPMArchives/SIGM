program prime(0);
{An adaptation of the program in Byte, Jan 83, p 214.
The program uses the long integer routines from the library
disc (UNIT1) and the Knuth algorithm to test a series of
numbers for prime-ness.}

label
  1;
const
  bufmax = 16;
  bytemax = 5;
type
  byte = 0..255;
  longint = record
	byt: array [0..bytemax] of integer;
	pos: boolean
	    end;
  realarray = array [0..bytemax] of integer;
  writebuf = array [0..bufmax] of integer;
  digarray = array [0..2] of 0..9;
  string19 = packed array [1..19] of char;
var
  seed1, seed2: integer;
  prm,
  xeof: boolean;
  stdin,
  stdout: text;
  instr: char;
  three,		{3 in longint}
  n: longint;		{candidate prime}

procedure getc ( VAR ch: char );
	external;

procedure errortrap ( str: string19 );
	external;

procedure Negate ( var a: longint );
	external;

function iszero ( num: longint ): boolean;
	external;

function equal ( a,b: longint ): boolean;
	external;

procedure CVI ( a: integer; var u: longint );
	external;

function CVL ( u: longint; var a: integer ): boolean;
	external;

function greater ( a,b: longint ): boolean;
	external;

procedure getlong ( var f: text; var num: longint );
	external;

procedure putlong ( var f: text; num: longint; fieldwidth: integer );
	external;

procedure sub ( a,b: longint; var c: longint );
	external;

procedure add ( a,b: longint; var c: longint );
	external;

procedure multlong ( a,b: longint; var c: longint );
	external;

procedure divlong ( a,b: longint; var q,rem: longint );
	external;

procedure seedrand; external;
function random(x: integer): real; external;

procedure instructions; external;

procedure get_n(var n:longint); external;

procedure if_even(var n:longint); external;

procedure n_prime(n:longint; var prm:boolean); external;

begin		{main program}
write('  Instructions? (Y/N) '); readln(instr);
if instr in ['Y','y'] then instructions;
rewrite('con:',stdout);
reset('con:',stdin);
prm := false;
cvi(3,three);
get_n(n);
if greater(three,n) then goto 1;	{operator exit}
  if_even(n);			{determine if n is even, if so subract 1}
repeat
  n_prime(n,prm);			{the guts; is n prime?}
until prm;			{program termination when prime found}

1:
end.
