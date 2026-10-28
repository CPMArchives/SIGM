
(***********************************************************
*
*	Donated by Ray Penley, June 1980
*
***********************************************************)


PROGRAM REVERSE;
{----------------------------------------------}
{  Modified for Pascal/Z by Raymond E. Penley  }
{----------------------------------------------}

TYPE
  Links = ^Nodes;

  Nodes = record
	    Character  :CHAR;
	    Next       :Links
	  end;

VAR
  First, This   :Links;
  ix		:Integer;
  Ch		:CHAR;

Procedure READ_LIST;
CONST	prompt = '>>';
begin
  First := NIL;			{ Make the list of characters empty }
  Writeln;
  Write(prompt);
  READ(Ch);
  While Ch <> '.' Do
    begin
    NEW(This);			{ Allocate a new space }
    This^.Character := Ch;	{ Insert Ch at the front of the list }
    This^.Next := First;	{ link into the list }
    First := This;
    READ(Ch);
    end{while}
end{of Read_List};

Procedure SHOW_LIST;
  (* Write all characters in the list *)
VAR	count : integer;
begin
  Writeln;
  count := 0;
  This := First;
  While This <> NIL DO
    With This^ do begin
      Write(Character);
      count := count + 1;
      This := Next		{ Advance down the chain }
    end;
  Writeln;
  Writeln('You entered ',count:3,' characters.');
end{of Show_list};

begin
  for ix:=1 to 24 do writeln;
  Writeln('Enter a line of characters after the prompt.');
  Writeln('Enter a "." at the end.');
  While true do {infinite loop}
    begin
	READ_LIST;
	SHOW_LIST;
    end{while}
end.
