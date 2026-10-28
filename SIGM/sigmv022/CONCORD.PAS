{********************************************************
**
**  EDIT #5 - 12 July 1980
**
**  PROGRAM TITLE:	Concordance
**
**  WRITTEN BY:		Raymond E. Penley
**  DATE WRITTEN:	26 January 1980
**
**  WRITTEN FOR:	Personal pleasure
**			Donated to Pascal/Z users Gp
**
**  PROGRAM SUMMARY:
**
**	Examine a piece of text and produce a list,
**	in alphabetical order, of all the distinct
**	words which appear in the text.
**
**  INPUT AND OUTPUT FILES:
**
**	INPUT FILE: DRIVE: BASIC FILE NAME . EXTENSION
**	OUT FILE:   DRIVE: BASIC FILE NAME . CCD
**
		*************			}
PROGRAM CONCORDANCE;

label	9;{abort}
const
  alfa_len 	= 16;	 { length of words }
  c4 		= MAXINT;{ max line number }
  Clearcode	= 26;	 { clear screen    }
  default	= 255;
  dflt_str_len	= default;
  LLmax 	= default;{ max line length }
  LLmin 	= 72;	{ Min line length }
  space 	= ' ';
  StrMax 	= 255;

type
  alfa		= STRING alfa_len;
  byte		= 0..255;
  charname = (lletter, uletter, digit, blank, quote, atab,
	      EndOfLine, FileMark, otherchar );
  charinfo = RECORD
		name : charname;
		valu : char
	     END;
  dfltstr	= STRING default;{ default length for all strings }
  ItemRecords  = record
		   item  :alfa;
		   Next  :^ItemRecords
		 end;
  ItemPointers = ^ItemRecords;
  str0		= string 0;
  str255	= string StrMax;

var
  Look	   : char;	{ Character read in from File }
  cline	   : integer;	{ current line number }
  currchar,		{ Current operative character }
  nextchar : CharInfo;	{ Look-ahead character }
  CON_wanted,
  DEBUG,
  error_flag: BOOLEAN;
  Fbuffer  : dfltstr;	{ Format buffer - before final Print }
  flushing : (KNOT, DBL, STD, LIT);
  ID	   : alfa;	{ Identifier storage }
  idlen	   : byte;	{ Identifier Length }
  ListHead  :ItemPointers;
  tab	   : char;
  TextFile,		{ Input file }
  Work_File: TEXT;	{ Output file }
  wordcount: integer;	{ total # of words in file }
  xeof,			{ EOF status AFTER a read }
  xeoln    : boolean;	{ EOLN status after a read }

Function length(x: str255): integer; external;
Procedure setlength(var x: str0; y: integer); external;
Function index(x,y: str255): integer; external;

PROCEDURE Error( enumb : byte);
begin
  CASE enumb of
    0:	writeln('Fatal error!');
    1:	writeln('Exceeded buffer limits on read');
    2:	{-reserved-};
    3:	writeln('File not found');
    4:	{-reserved-}
   end{ of case };
  error_flag := true
end;

PROCEDURE InsertItem( Newitem  :alfa);
{*
**	From the book - PASCAL An Introduction
**	to Methodical Programming
**	Authors:
**	W. Findlay and D.A. Watt
		******			}
VAR	entry,
	PriorEntry,
	Newentry 	:ItemPointers;
	found		:boolean;

   Procedure INSERTWORD;
   begin{ CREATE the New entry and Insert it in position }
     New(Newentry);
     Newentry^.item := Newitem;
     Newentry^.Next := entry;
     If entry = ListHead then
       ListHead := Newentry
     Else
       PriorEntry^.Next := Newentry;
   end{-of InsertWord-};

begin
  { FIND the position where the New item will be Inserted }
  entry := ListHead;
  found := false;
  While NOT found AND (entry <> NIL) do
    WITH entry^ DO
      If (item < Newitem) then
	begin
	PriorEntry := entry;
	entry := Next
	end
      Else
	found := true;
  If found then{-Crate a new entry in the list If necessary-}
    begin
    If (entry^.item <> Newitem) then InsertWord{ at position `entry` }
    end
  Else
    InsertWord{ at end of list }
end{-of InsertItem-};

PROCEDURE WriteItems;
CONST	  Sail = '***   INDEX   ***';
var	  entry  :ItemPointers;
begin
  Writeln(Work_File, Sail);
  If CON_wanted then writeln(Sail);
  entry := ListHead;
  While entry <> NIL DO
    WITH entry^ DO
      begin
      Writeln(Work_File, item);
      If CON_wanted then writeln(item);
      entry := Next
      end
end{--of WriteItems-};

Procedure ReadC(var nextchar : charinfo;
		var currchar : charinfo );
{ revised 4 Jan 80, rep }
begin{ Terminator status module.
   Stores terminator status "AFTER" a read.
   NOTE this play on words - after one char is
   actually "PRIOR TO" the next character		}
  xeoln := EOLN(textfile);
  xeof  := EOF(textfile);
{ read byte module }
  If NOT xeof then
        READ(Textfile, Look);
{ current operative character module }
  currchar := nextchar;
  With NextChar do begin{ Look-ahead character name module }
    If xeof then
      name := FileMark
    Else If xeoln then
	   name := EndOfLine
    Else If LooK IN ['a'..'z'] then { lower case }
	   name := lletter
    Else If LooK IN ['A'..'Z'] then { upper case }
	   name := uletter
    Else If LooK IN ['0'..'9'] then { digit }
	   name := digit
    Else If LooK = '''' then
	   name := quote
    Else If LooK = TAB then
	   name := atab
    Else If LooK = space then
	   name := blank
    Else name := otherchar;
    CASE name of{ store character value module }
	EndOfLine,
	FileMark:	Valu := space;
	Else:		Valu := LooK
    end{ case name of };
  End{ Look-ahead character name module };
end{ ReadC };

PROCEDURE GetL( var Fbuffer : dfltstr );
{		*****
	Get a line of text into users buffer.
	Flushes comment lines:
	Flushes lines of Literals:  'this is it'
	Ignores special characters & tabs:
	Recognizes End of File and End of Line.
GLOBAL
	flushing : (KNOT, DBL, STD, LIT);
	Fbuffer = dfltstr
	LLmax   = 0..Max Line length;
		*****				}
var	state : (scanning, terminal, overflow);
begin { GetL }
   setlength(fbuffer,0);
   error_flag := false;
   state := scanning;
  REPEAT
    ReadC(Nextchar, Currchar);
    If (length(fbuffer) >= LLmax) then{ exceeded length of buffer }
      begin{ reset EOLN }
	state := overflow;
	READLN(fbuffer);{ reset EOLN }
	error(1)
      end
    Else
      begin
	If (currchar.name IN [FileMark,EndOfLine]) then
          state:=terminal{ end of line or end of file };
	CASE flushing of
	    KNOT:
		CASE currchar.name of
		lletter, uletter, digit, blank:
			begin{ store }
			append(fbuffer,currchar.valu);
			end;
		atab, quote, otherchar:
			begin{	 Flush comments	-convert
			         tabs & other chars to spaces }
			If (currchar.valu='(') and (nextchar.valu='*')
			  then flushing := DBL
			Else If (currchar.valu='{') then 
			   flushing := STD
			Else If currchar.name=quote then
			   flushing := LIT;
			{ convert to a space }
			append(fbuffer,space);
			end;
		else:	{ end of line -or- file mark }
			append(fbuffer,currchar.valu)
		end{ case currchar name of };
	    DBL:  { scanning for a closing  - double comment }
		If (currchar.valu ='*') and (nextchar.valu =')')
		  then flushing := KNOT;
	    STD:  { scanning for a closing curley  }
		  If currchar.valu = '}' then
		      flushing := KNOT;
	    LIT:  { scanning for a closing quote }
		  If currchar.name = quote then
		    flushing := KNOT
        end{ flushing case }
      end{ Else }
  UNTIL (state<>scanning);
end{-of GetL-};

PROCEDURE ReadWord;
{	 Analyze the Line into "words"		}
const	space = ' ';
var	Cpos : byte; { Current Position pointer }
begin{ ReadWord }
 Cpos := 1; { start at the beginning of a line }
 While (Cpos < length(fbuffer)) Do
  begin
   { skip spaces }
   while (Cpos < length(Fbuffer)) AND (fbuffer[Cpos]=space) Do Cpos:=Cpos+1;
   Setlength(ID,0);{ start with a null array }
   while (Cpos < length(fbuffer)) AND (fbuffer[Cpos ] <> space) Do
    begin{ accept only non-spaces }
     If (length(ID)<alfa_len) then append(ID,fbuffer[ Cpos ]);
     Cpos := Cpos +1;
    end{ while };
   while (length(ID)<alfa_len) Do append(ID,space);
{}If DEBUG then writeln('   ',ID);
   InsertItem(ID);
   WordCount := WordCount + 1;
 end;
end{-of ReadWord-};

Procedure SKIP(n : byte);
var	i : byte;
begin	For i:=1 to N do writeln
end;

Function ConnectFiles: boolean;
const	dflt_extension = '.CCD';
	fid_len	= 14;	{ Max length CP/M file names }
type	FID	= string fid_len;
var	File_ID,
	New_ID  : FID;
	ix,jx	: byte;

	Procedure PAD(var ID: fid; required: byte);
	const	space = ' ';
	begin
	  while (length(ID)<required) Do append(ID,space);
	end;

begin{-GETID-}
  ConnectFiles := true;
  Setlength(File_ID,0);
  writeln;
  write('Enter <Drive:><File name>  ');
  readln(File_ID);
  If (length(File_ID)>fid_len) then
    setlength(File_ID,fid_len)
  Else
    PAD(File_ID, fid_len);
  RESET(File_ID, TextFile);
  If EOF(TextFile) then{ ABORT }
    begin
      error(3);
      ConnectFiles := false;
    end
  Else
    begin
    ix := index(File_ID,'.'); { search for an extension }
    jx := index(File_ID,' '); { search for the first space }
    If (ix=0) then{ no extension was specified }
      Setlength(File_ID,jx-1)
    Else
      Setlength(File_ID,ix-1);
    Setlength(New_ID,0);
    append(New_ID, File_ID);
    append(New_ID, dflt_extension);
    PAD(New_ID, fid_len);
    REWRITE(New_ID, Work_File);
    end;
End{ of ConnectFiles };

Procedure Initialize;
var	ch: char;
begin
  ListHead := NIL;  { MAKE the LIST EMPTY }
  cline	:= 0; { current line counter }
  wordcount := 0;
  idlen := 0;
  tab	:= chr(9);  { ASCII Tab character }
  flushing := KNOT{ flushing };
{-INITIALIZE look-ahead char-}
  nextchar.name := blank;
  nextchar.valu := space;

  writeln;
  WRITE('DEBUG?');READ(Ch);
  DEBUG := ((Ch='Y') or (Ch='y'));
  writeln;
  WRITE('Output to Console?');READ(Ch);
  CON_wanted := ((Ch='Y') or (Ch='y'));
end;

PROCEDURE Clear(code : byte);
{	device dependent routine	}
begin   WRITELN( CHR(code) )
end;

Procedure Sign_On;
begin
  Clear(clearcode);
  writeln;
  writeln(' ':20,'***   C O N C O R D A N C E   ***');
  SKIP(4);
end;

Begin{ main body of Concordance }
  Sign_On;
  If NOT ConnectFiles then {ABORT} goto 9;
  Initialize;
  SKIP(4);
  cline:= cline +1;
  GetL(Fbuffer) { attempt to read the first line };
  while ((currchar.name<>filemark) AND (NOT error_flag)) do
    begin
{}    If DEBUG then writeln('line',cline:5,'  ',fbuffer);
      ReadWord{Analyze the Text into single 'words' };
      If cline=c4 then cline:=0;
      cline := cline +1;
      GetL(Fbuffer) { attempt to read another line of text };
    end{ while };
  Clear(clearcode);
  WriteItems;	{ Write all the Items in order }
  writeln;
  writeln(' ':18, '***   SUMMARY   ***');
  writeln('Total # lines =',cline -1);
  writeln('Total # words =', wordcount);
  writeln;
9:{ABORT};
end{ of ConCordance }.
