PROGRAM SUBMIT_DEMO;
{
  * PROGRAM TITLE:		Submittable Demo

  * WRITTEN BY:			Raymond E. Penley

  * DATE WRITTEN:		May 14, 1982

  * SUMMARY:
	Execution of external command programs e.g. PIP,
	STAT, DIR via a submit program entirely generated
	within the users program.
}

type
  string0   = string 0;
  string128 = string 128;
  string255 = string 255;
  xsub	    = array [1..10] of string128;{ for submit processing }

var
  asub	     : xsub;
  cmdchar    : char;
  terminated : boolean;

procedure setlength ( var source: string0; leng: integer ); external;

function length ( source: string255 ): integer;	external;

procedure submit ( asub : xsub );
{
  * processes the strings in the array asub into a file of commands
    that will be processed by the CP/M console command processor (CCP).
  * constructs the file in reverse order.
  * all records are exactly 1 sector/128 bytes long.
  * requires:
	- last command string in asub[] must be a null string.
	- asub : array [1..xx] of string128
	- external procedure length()
}
const	max	= 128;		{ one record length / one sector }
type	string128 = string 128;
	line	= string128;
var	count	: integer;
	fsub  	: file of line;
	idx	: integer;

	procedure put_sub ( inbuffer : line );
	{ write records <strings> to our own submit file	    }
	{ record format:					    }
	{ |length byte|command line|null byte|padding to 128 bytes| }
	var	tbuffer : line;
	begin
	  tbuffer := ' ';				{ set up.     }
	  tbuffer[1] := chr ( length(inbuffer) );	{ length byte }
	  append(tbuffer,inbuffer);			{ command line }
	  repeat append(tbuffer,chr(0))			{ pad to length }
	  until length(tbuffer)=max;
	  write ( fsub, tbuffer )
	end{put_sub};

begin { submit }
  { OPEN file '$$$.SUB' for WRITE assign fsub }
    rewrite ( '$$$.SUB', fsub );
  { see how many commands to process }
  count := 0;
  repeat count := count + 1
  until length(asub[count])=0;
  count := count - 1;
  { must force Pascal/Z to dump an even # of 128 byte buffers. ugh! }
  if odd(count) then count := count + 1;
  { write commands to file in reverse order }
  for idx:=count downto 1 do
    put_sub ( asub[idx] )
end{submit};


procedure build_sub ( cmdchar: char );
{
  * builds the submit commands in the array asub
	asub : array [1..xx] of string128;
  * requires:
	external procedure setlength()
}
const	drives	= 'WHICH DRIVE ( A-P ) ? ';
type	string128 = string 128;
	line	= string128;
var	ch	: char;
	Cmd	: line;
	dest	: char;
	filename: string 14;
	idx	: integer;
	source	: char;

begin { build_sub }
  for idx:=1 to 10 do		{ set asub[] to all nulls }
    setlength ( asub[idx],0 );

  case cmdchar of
    '3':{files/directory}{ command = DIR A: }
	begin
	  write ( drives );
	  readln ( ch );
	  Cmd := 'DIR A:';
	  Cmd[5] := ch
	end;
    '4':{status/stat}{ command = STAT A:*.* }
	begin
	  write ( drives );
	  readln ( ch );
	  Cmd := 'STAT A:*.*';
	  Cmd[6] := ch
	end;
    '5':{Move/Copy/PIP}{ command = PIP B:=A:filename[v]		}
		       { command = PIP A:filename=filename[v]	}
	{ simplistic copy operation:		}
	{ additional valid PIP commands	can be added }
	{	PIP PRN:=myletter[NT8]		}
	{	PIP CON:=b:sample.pas		}
	{	PIP a:newname=b:oldname		}
	begin
	  write ( 'ENTER FILE NAME TO BE COPIED - ' );
	  readln ( filename );
	  write ( 'WHERE WILL I FIND THIS FILE? - ' );
	  readln ( source );
	  write ( 'WHERE AM I TO PUT THE  FILE? - ' );
	  readln ( dest );
	  if dest=source then begin
		Cmd := 'PIP A:';
		Cmd[5] := dest;
		append(Cmd,filename);
		append(Cmd,'=');
		append(Cmd,filename)
	  end
	  else begin
		Cmd := 'PIP B:=A:';
		Cmd[5] := dest;
		Cmd[8] := source;
		append(Cmd,filename)
	  end;
	  append(Cmd,'[v]' );	{ verify option }
	end
  end{case};

  { construct the array of submit commands }
  idx := 0;
  idx := idx + 1;
  asub[idx] := Cmd;		{ command string }
  if cmdchar<>'5' then begin
     idx := idx + 1;
     asub[idx] := 'PAUSE';	{ pauses for any console input }
  end;
  idx := idx + 1;
  asub[idx] := 'XSUB';		{ file we want to chain back to }

  { write the submitable file }
  submit ( asub )
end{ build_sub };


procedure do_menu;
var	valid : boolean;
begin		{$C+}{ allow console termination via ctrl-C here }
  repeat
	valid := true;
	writeln;
	writeln ( ' ':12, '(1)  ADD NEW RECORDS' );
	writeln ( ' ':12, '(2)  CHANGE A RECORD' );
	writeln ( ' ':12, '(3)  DIRECTORY' );
	writeln ( ' ':12, '(4)  DISK STATUS' );
	writeln ( ' ':12, '(5)  COPY FILES' );
	writeln ( ' ':12, '(6)  TERMINATE PROGRAM' );
	writeln;
	write ( 'ENTER SELECTION: ' );
	readln ( cmdchar );
	if not ( cmdchar in ['1'..'6'] ) then begin
	   writeln ( 'SORRY INVALID SELECTION. TRY AGAIN' );
	   valid := false
	end
  until valid
end{do_menu};	{$C-}{ disable ctrl-C keypress checking again }


procedure do_add;
begin
end;

procedure do_change;
begin
end;


begin { main program }
  terminated := false;
  while not terminated do begin
     do_menu;
     case cmdchar of
	'1':	do_add;
	'2':	do_change;
	'3','4','5':
		begin
		  build_sub ( cmdchar );
		  terminated := true
		end;
	'6':	terminated := true
     end{case}
  end{while}
end{SUBMIT_DEMO}.
