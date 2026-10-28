{ This file includes declarations of useful external
  procedures and functions.  It should be included
  before the first procedure of the program.  }

{ Return length of string S }

function length (S : string255) : integer;
  external;

{ Return position of S2 in S1 }

function index (S1, S2 : string255) : integer;
  external;

{ Set length of string S to L }

procedure setlength (var S : string0; L : integer);
  external;

{ Append blanks to a string until specified length
  is achieved. }

procedure pad (var str : string0; len : byte);

begin
while length(str) < len do append(str,blank)
end; { pad }

{ Return amount of spare memory available.  If this function is called,
  SPACE.REL must be linked with the Pascal program.  The number returned
  is the address of the top of the stack minus the address of the top of
  the heap.  This is a 16-bit unsigned integer, and if it is greater than
  32767 it cannot be printed correctly by Pascal.  Note also that calling
  this function reduces the amount of spare memory slightly. }

function space : integer; external;