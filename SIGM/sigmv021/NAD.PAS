(************************************************
**  PROGRAM TITLE:	Name and Address
**			Version 3.0
**
**  WRITTEN BY:		Raymond E. Penley
**  DATE WRITTEN:	26 June 1980
**
**  ORIGINAL PROGRAM:
**	A General Purpose Permuted Keyword Index Program
**	Written by:	Randy Reitz
**			26 Maple St
**			Chatham Township, N.J. 07928
**
**	Date written:	June 1980
**
**  WRITTEN FOR-S100 Microsystems Magazine
**
**  Donated to PASCAL/Z USERS GROUP, july 1980
** 
***********************************************)
Program NameAndAddress;
label	9999; { abort }
const
  Program_title = 'NAME AND ADDRESS';
  Sort_message  = 'Sort by 1) Name, 2) Address, or 3) Zip Code? ';
  default	= 80 ;
  dflt_str_len	= default;	{ default length for a string }
  dflt_margin	= 1;		{ Left margin default }
  fid_length	= 14;		{max file name length}
  line_len	= default;
  n		= 10;		{Maximun # of delimeters}
  name$field$width	= 20;	{ Name line width }
  address$field$width	= 40;	{ Address line width }
  Zip$field$width	=  5;	{ ZIP Code line width}
  Pdelim	= '^';		{ the "P" delimeter }
  Sdelim	= '/';		{ the "S" delimeter }
  space		= ' ';
  screen_lines	= 24; {# of viewing lines on consle device }
  StrMax	= 255;

type
  dfltstr = STRING dflt_str_len;
  fid	  = STRING fid_length;
  Indexes = array[1..n] of integer;
  str0	  = STRING 0 ;
  str1	  = STRING 1;
  str255  = STRING Strmax ;
  Mstring = STRING Strmax;

  links   = ^entry;

{}stuffing = record
		name,		{ Name line }
		address,	{ Address line    }
		Zip  : dfltstr	{ ZIP Code line   }
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
  in_file	: fid;		{ CP/M File Identifier <FID> }
  margin,			{ left margin }
  num		: integer;	{ occurrences of "P"/"S" delimeters }
  root		: links;
  Ploc,				{ location of "P" delimeters }
  Sloc		: INDEXES;	{ location of "S" delimeters }
  sort		: 0..255;
  size,				{ size of current file }
  this_line	: integer;	{ current line counter }
  termination	: boolean;	{ Program termination flag }
  wrk1		: text;		{ the input file <FCB> }

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
	1: begin	{ NAME Key }
	   Newkey := newx^.stuff.name;
	   Thiskey := this^.stuff.name;
	   end;
	2: begin	{ ADDRESS Key }
	   Newkey := newx^.stuff.address;
	   Thiskey := this^.stuff.address;
	   end;
	3: begin	{ ZIP Code Key }
	   Newkey := newx^.stuff.Zip;
	   Thiskey := this^.stuff.Zip;
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
{
	---Address format---

	Name			line 1
	Address			line 2
	Zip Code		line 3
	<blank line>		line 4
}
var	thiskey: dfltstr;
begin
  CASE sort of
    1: Thiskey := ptr^.stuff.name;	{ Name }
    2: Thiskey := ptr^.stuff.address;	{ Address }
    3: Thiskey := ptr^.stuff.Zip	{ Zip Code }
  End{case};
  If (ptr^.Llink<>nil) AND (Thiskey>=low) then
    TRAVERSE(ptr^.Llink);
  If (thiskey >= low) AND (thiskey <= high) then
    begin{ Write an address }
      With ptr^.stuff do begin
	writeln(' ':margin, name : name$field$width );
	writeln(' ':margin, address : address$field$width );
	writeln(' ':margin, Zip : Zip$field$width );
	writeln;
	end{with};
      this_line := this_line + 1;
      If (this_line*6)+1 > screen_lines then PAUSE;
    end{ Write an address };
  If (ptr^.Rlink<>nil) AND (Thiskey <= high) then
    TRAVERSE(ptr^.Rlink);
End{of TRAVERSE};

Procedure CREATIT;
{
GLOBAL	I : integer;	<passed from main program>
}
var	p: links;
	temp1,
	newname,
	newaddress,
	newZip  : dfltstr;
begin
  NEW(p);
  CASE sort of
    1:	begin
	COPY(newname, LINE, ploc[I]+1, sloc[ 1 ]-ploc[I] );
	COPY(temp1, LINE, 1, ploc[I] );
	APPEND(newname,temp1);
        end;
   2,3: If (LINE[1]=space) then
	  COPY(newname, LINE, 2, sloc[1]-1)
	Else
	  COPY(newname, LINE, 1, sloc[1])
   End{case};
  COPY(newaddress, LINE, sloc[1]+1, (sloc[2]-sloc[1])-1);
  If (length(newaddress) > address$field$width) then
       setlength(newaddress,address$field$width);
  COPY(newZip, LINE, sloc[2]+1, length(LINE)-sloc[2] );
  newname[1]	:= Ucase(newname[1]);
  newaddress[1] := Ucase(newaddress[1]);
  newZip[1]	:= Ucase(newZip[1]);
  With p^.stuff do begin
     name := newname;		{ Name line }
     address := newaddress;	{ Address line }
     Zip := newZip		{ ZIP Code }
     end{with};
  p^.Llink := nil;
  p^.Rlink := nil;
  ENTER(p);
end{of CREATIT};

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
  writeln(' ':12,Program_title);
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
  {---Read In the Data File---}
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
  {---     Read is complete	  ---}
  {---Announce no of records found---}
  writeln('Sort complete with ', size:3, ' records entered.');
  If bad_lines > 0 then
    writeln('There are ', bad_lines:3, ' bad lines in the data file.');
  writeln;
  write('Enter left margin? ');
  READLN(margin);
  writeln;
  writeln('Enter range for output.');
  Termination := false;
  REPEAT
    setlength(low,0);
    setlength(high,0);
    writeln;
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
End{ of Program Name and Address }.
