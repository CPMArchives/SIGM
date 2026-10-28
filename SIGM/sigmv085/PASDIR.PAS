Program PascalDirectory;
{	Driver program to demonstrate procedure directory()

	All externals in Pascal/Z Users Group Library "ASL.REL"

	translated to Pascal/Z - 07/10/82 (rep)
	added peek(), poke(), call(), and additional comments.

	original program by Daniel S. Hunt
			    822 Green Valley
			    Newbury Park, CA.  91320
	as published in BYTE, June 1982, page 497
}

type	byte = 0..255;
	strng12 = packed array [1..12] of char;


{   peek() returns the contents of the memory location given   }
{   by address. the value returned is a single byte integer.   }
function peek ( address: integer ): byte;
	external;

{   poke() stores the low-order eight bits of abyte   }
{   at the memory location pointed to by address.     }
procedure poke ( address: integer; abyte: byte );
	external;

{$iDIRCTRY.P }

{ Simple driver for procedure directory.  Constructs a string of }
{ 11 chars = '?'.  First char is the binary value of the requested }
{ drive unit.  }
procedure list;
var
  title : strng12;
  ch    : char;
  i	: byte;

	function toupper ( ch: char ): char; external;

begin
  title := '0???????????'; { 12 chars. 1st char = drive unit }
{
  Example string to search for all *.COM files on logged in dr unit...
	  title := '0????????COM';
  NOTE: MUST be in uppercase!
}
  write ( 'LIST DISK DIRECTORY: UNIT "A" OR "B"? ' );
  readln ( ch );
  ch := toupper(ch);

  { construct the proper binary unit identifier:
	0 = logged in drive unit
	1 = drive unit 'A'
	2 = drive unit 'B'
  }
  title[1] := chr( ord(ch) - ord('A') + 1 );
  writeln;
  directory ( title );
  writeln
end{ list };

{$C+}{ enable control-c keypress checking in main program }

BEGIN {MAIN }
  repeat
    list
  until false
END.
