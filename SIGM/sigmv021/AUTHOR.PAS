(*
**  PROGRAM TITLE:	AUTHOR
**
**  WRITTEN BY:		Raymond E. Penley
**  DATE WRITTEN:	24 June 1980
**
**  WRITTEN FOR:	Pascal/Z Users Group
**
**  Original program
**	A General Purpose Keyword In Context Program
**		 by:	Randy Reitz
**			26 Maple St
**			Chatham Township, N.J. 07928
**			June 1980
**
**  DONATED TO PASCAL/Z USERS GROUP, July 1980
*)
Program AUTHOR;
label	9999; { abort }
const
  Program_title = 'AUTHOR';
  Sort_message  = 'Sort by 1) TITLE, 2) AUTHOR, or 3) DATE? ';
  default	= 80 ;
  dflt_str_len	= default;	{ default length for a string }
  fid_length	= 14;		{max file name length}
  line_len	= default;
  n		= 10;
  title$field$width  = 56;
  author$field$width = 14;
  date$field$width   =  8;
  Pdelim	= '^';		{ the "P" delimeter }
  Sdelim	= '/';		{ the "S" delimeter }
  space		= ' ';
  screen_lines	= 24; {# of viewing lines on consle device }
  StrMax	= 255;

type
  dfltstr = STRING dflt_str_len;
  fid	  = STRING FID_LENGTH;
  INDEXES = array[1..n] of integer;
  str0	  = STRING 0 ;
  str1	  = STRING 1;
  str255  = STRING Strmax ;
  Mstring = STRING Strmax;

  links   = ^entry;

{}stuffing = record
		title,
		author,
		date  : dfltstr
	     end;

  entry	  = record
{}		stuff: stuffing;
		Rlink,
		Llink: links
	    end;
var
  bad_lines	: integer;	{ count of # of bad lines }
  bell		: char;
  cix		: char;
  error		: boolean;
  High,
  LINE,
  Low		: dfltstr;
  i		: integer;	{ global index }
  in_file	: fid;
  num		: integer;	{ occurrences of "P"/"S" delimeters }
  root		: links;
  Ploc,				{ location of "P" delimeters }
  Sloc		: INDEXES;	{ location of "S" delimeters }
  sort		: 0..n;
  size,				{ size of current file }
  this_line	: integer;	{ current line counter }
  termination	: boolean;	{ Program termination flag }
  wrk1		: text;		{ the input file }

  (*********************************************)

(*---This is how we get string functions in Pascal/Z---*)
Function length(x: str255): integer; external;
Function index(x,y: str255): integer; external;
Procedure setlength(var x: str0; y: integer); external;

Procedure KEYIN(VAR cix: char); external;
(*---Direct Keyboard onput of a single char---*)

Procedure COPY( {    TO     } VAR dest : dfltstr;
		{   FROM    } THIS : MSTRING ;
		{STARTING AT} POSN : INTEGER ;
		{# OF CHARS } LEN  : INTEGER ) ;
{  COPY(NEW_NAME, NBUF, NAME_ADDR, NAME_LEN);	}
{  COPY(A_STRING, A_STRING, 5, 5);		}
{
GLOBAL	  default = default line length;
	  dfltstr = STRING default;
	  StrMax = 255;
	  MSTRING = STRING StrMax;		}
LABEL	9;
VAR	ix   : 1..StrMax;
begin
  SETLENGTH(dest,0);  {length returned string=0}
  If (len + posn) > default then{EXIT}goto 9;
  IF ((len+posn-1) <= LENGTH(this))
     and (len > 0) and (posn > 0) then
     FOR ix:=1 to len do
         APPEND(dest, this[posn+ix-1]);
9: {Any error returns dest with a length of ZERO.}
End{of COPY};

PROCEDURE CONCAT({New_String} VAR C : dfltstr ;
		 {Arg1_str  }     A : Mstring ;
		 {Arg2_str  }     B : Mstring );
{  CONCAT(New_string, Arg1, Arg2);   }
{ An error returns length of new_string=0 }
{
GLOBAL	  default = default line length;
	  dfltstr = STRING default;
	  StrMax = 255;
	  Mstring = STRING StrMax;		}
var	ix : 1..StrMax;
begin
  SETLENGTH(C,0);
  If (LENGTH(A) + LENGTH(B)) <= default then
    begin
	APPEND(C,A);
        APPEND(C,B);
    end;
End{of CONCAT};

Function UCASE(ch: char): char;
begin
  If ch IN ['a'..'z'] then
    UCASE := chr(ord(ch) - 32)
  Else
    UCASE := ch
end;

Procedure FINDR( PAT	   : str1;
		 VAR S     : dfltstr;
		 VAR where : INDEXES;
		 VAR cnt   : integer );
var	ix, cum : integer;
	temp   : dfltstr;
begin
  cum := 0;
  cnt := 0;
  where[1] := 0;
  Repeat
    COPY(temp, S, cum+1, length(S)-cum);
    ix := INDEX(temp, pat);
    cum := cum + ix;
    If (ix>0) then
      begin
	S[cum] := space;
	cnt := cnt + 1;
	where[cnt] := cum;
	where[cnt+1] := 0;
      end;
  Until (ix=0) OR (cum=length(S));
end{of FINDR};

Procedure ENTER(newx: links);
var	this, next: links;
	Newkey, Thiskey: dfltstr;
begin
  If (root=nil) then
    root := newx
  Else
    begin
      next := root;
      Repeat
	this := next;
	CASE sort of
	1: begin
	   Newkey := newx^.stuff.title;
	   Thiskey := this^.stuff.title;
	   end;
	2: begin
	   Newkey := newx^.stuff.author;
	   Thiskey := this^.stuff.author;
	   end;
	3: begin
	   Newkey := newx^.stuff.date;
	   Thiskey := this^.stuff.date;
	   end
	End{case};
	If Newkey <= Thiskey then
	  next := this^.Llink
	Else
	  next := this^.Rlink;
      Until next=nil;
      If Newkey <= Thiskey then
	this^.Llink := newx
      Else
	this^.Rlink := newx;
    end
End{of Enter};

Procedure PAUSE;
var	dummy: char;
begin
  this_line := 0;
  write('Press return <cr> to continue');
  readln(dummy);
End{of Pause};

Procedure TRAVERSE(ptr: links);
var	thiskey: dfltstr;
begin
  CASE sort of
    1: Thiskey := ptr^.stuff.title;
    2: Thiskey := ptr^.stuff.author;
    3: Thiskey := ptr^.stuff.date
  End{case};
  If (ptr^.Llink<>nil) AND (Thiskey>=low) then
    TRAVERSE(ptr^.Llink);
{}If (thiskey >= low) AND (thiskey <= high) then
    begin{ Write a line }
      With ptr^.stuff do begin
	CASE sort of
	  1:	begin  { TITLE || AUTHOR || DATE }
		write( title : title$field$width );
		write( author : author$field$width );
		writeln( date : date$field$width );
		end;
	  2:	begin  { AUTHOR || TITLE || DATE }
		write( author : author$field$width );
		write( title : title$field$width );
		writeln( date : date$field$width );
		end;
	  3:	begin  { DATE || TITLE || AUTHOR }
		write( date : date$field$width );
		write( title : title$field$width );
		writeln( author : author$field$width );
		end
	End{case};
	end{with};
      this_line := this_line + 1;
      If (this_line*6+1 > screen_lines) then PAUSE;
    end{ Write a line };
{}If (ptr^.Rlink<>nil) AND (Thiskey <= high) then
    TRAVERSE(ptr^.Rlink);
End{of TRAVERSE};

Procedure CREATIT;
{
GLOBAL	I : integer;	<passed from main program>
}
var	p: links;
	temp1,
	newtitle,
	newauthor,
	newdate  : dfltstr;
begin
  NEW(p);
  CASE sort of
    1:	begin
{}	COPY(newtitle, LINE, ploc[I]+1, sloc[ 1 ]-ploc[I] );
	COPY(temp1, LINE, 1, ploc[I] );
	APPEND(newtitle,temp1);
        end;
    2,3:If (LINE[1]=space) then
{}	  COPY(newtitle, LINE, 2, sloc[1]-1)
	Else
{}	  COPY(newtitle, LINE, 1, sloc[1])
   End{case};
{} COPY(newauthor, LINE, sloc[1]+1, (sloc[2]-sloc[1])-1);
   If (length(newauthor) > author$field$width) then
       setlength(newauthor,author$field$width);
   newdate := '19';
   COPY(temp1, LINE, sloc[2]+1, length(LINE)-sloc[2] );
   APPEND(newdate, temp1);
{} newtitle[1]	:= Ucase(newtitle[1]);
{} newauthor[1] := Ucase(newauthor[1]);
{} newdate[1]	:= Ucase(newdate[1]);
   With p^.stuff do begin
     title := newtitle;
     author := newauthor;
     date := newdate
     end{with};
   p^.Llink := nil;
   p^.Rlink := nil;
   ENTER(p);
end{of CREATIT};

Procedure Read_Data_File;
begin
  Readln(wrk1,LINE);
  while not EOF(wrk1) do
    begin
      FINDR(Sdelim, LINE, sloc, num);
      error := (num<>2);
      FINDR(Pdelim, LINE, ploc, num);
      error := (error OR (num=0));
      If sort IN [2,3] then num := 1;
      If not error then
	For i:=1 to num do
	  begin CREATIT; size := SUCC(size) end
      Else
	begin
	  writeln(bell,'***BAD LINE***',bell);
	  bad_lines := bad_lines + 1;
	  writeln(LINE)
	end;
      READLN(wrk1,LINE)
    end{while};
End{of Read_Data_File};

Procedure GETID( MESSAGE : dfltstr; VAR ID: FID );
{
GLOBAL	FID_LENGTH = 14;
	dfltstr    = STRING dflt_str_len;
	fid      = STRING FID_LENGTH;		}
const	space = ' ';
begin
  setlength(ID,0);
  writeln;
  write(message);
  READLN(ID);
  while length(ID)<FID_LENGTH do APPEND(ID,space);
End{---of GETID---};

Procedure CLEAR;
var	ix :1..25;
begin
  for ix:=1 to 25 do writeln
end;

Procedure Initialize;
begin
  CLEAR;
  writeln(' ':22,Program_title);
  writeln;writeln;writeln;writeln;
  root := nil;
  bell := chr(7);
  size := 0;
  bad_lines := 0;
  GETID('Enter data file name ->', in_file);
  RESET(in_file,wrk1);
end{of initialize};

Begin{ of Program KeyWordInContext }
  Initialize;
  If EOF(wrk1) then
    begin
      writeln('File ', in_file, 'not found');
      {EXIT}goto 9999;
    end;
  REPEAT
    writeln;
    write(Sort_messge);
    KEYIN(cix);Writeln(cix);
    sort := ORD(cix) - ORD('0');
  UNTIL sort IN [1,2,3];
  Read_Data_File;
  writeln('Sort complete with ', size:3, ' records entered.');
  If bad_lines > 0 then
    writeln('There are ', bad_lines:3, ' bad lines in the data file.');
  writeln;
  writeln('Enter range for output.');
  Termination := false;
  REPEAT
    setlength(low,0);
    setlength(high,0);
{}  writeln;
    write('Low string (<ctrl-C> to quit) ->');
    readln(low);
    If not termination then
      begin{ low string }
	low[1] := UCASE(low[1]);
	write('High string ->');
	readln(high);
	If not termination then
	  begin{ high string }
	    high[1] := UCASE(high[1]);
	    this_line := 0;
	    CLEAR;
	    TRAVERSE(root)
	  end{ high string }
      end{ low string }
  UNTIL Termination;
9999:{ file not found }
End{ of Program AUTHOR }.
