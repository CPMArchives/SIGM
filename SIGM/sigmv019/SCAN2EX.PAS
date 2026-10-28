PROGRAM Scan2Evaluation;
(*
 * PROGRAM TITLE:	Scan 2 Evaluation
 * WRITTEN BY:		Raymond E. Penley
 * DATE WRITTEN:	4 January 1980
 *			11 June 1980 slightly modified for
 *			Pascal/Z vers 3.0
 *
 * PURPOSE:
 *	This is an evaluation of a File read routine I call:
 *	"SCAN-2". SCAN-2 provides to the calling
 *	program TWO characters;
 *	   A current character (currchar) and
 *	   a look-ahead char (nextchar).
 *
 *)

CONST
  prompt = '?';
  space = ' ';
  fill = '    ';
  DisplayLines = 12;
  FID_LENGTH = 14;	{---Maximum length for a file name---}

TYPE
  charname = (lletter, uletter, digit, blank, quote, atab,
	      EndOfLine, FileMark, otherchar );
  charinfo = RECORD
		name : charname;
		valu : char
	     END;
  STR0	   = STRING 0;
  STR255   = STRING 255;
  STRING80 = STRING 80;
  FID      = STRING FID_LENGTH; {---FILE IDENTIFIER TYPE---}

VAR
  xeof,			(* EOF status AFTER a read *)
  xeoln    : boolean;	(* EOLN status AFTER a read *)
  count    : integer;	(* line counter *)
  LooK,			(* Look-ahead character *)
  Ch	   : CHAR;	(* temp usage char *)
  currchar,		(* Current operative character *)
  nextchar : CharInfo;	(* Next character to be operated on *)
  FileID   : FID;     	(* File IDentifier *)
  tab	   : char;	(* ASCII tab character *)
  ft	   : Text;	(* File Control Block <FCB> *)


FUNCTION LENGTH(X: STR255): INTEGER; EXTERNAL;
PROCEDURE SETLENGTH(VAR X: STR0; Y: INTEGER); EXTERNAL;

PROCEDURE GETID( Message : STRING80; VAR ID: FID );
CONST	SPACE = ' ';
begin
  SETLENGTH(ID,0);
  writeln;
  write(message);
  READLN(ID);
  WHILE LENGTH(ID)<FID_LENGTH DO APPEND(ID,SPACE);
end;

PROCEDURE GetC(	VAR nextchar : charinfo;
		VAR currchar : charinfo );
(* revised 4 Jan 80, rep *)
begin
(*	 Terminator status module
	Stores terminator status "AFTER" a read.
	NOTE this play on words - after one char is
	also "PRIOR TO" the next character
							*)
  xeoln := EOLN(ft);
  xeof  := EOF(ft);
	(* read byte module *)
  If NOT xeof then
    READ(ft, Look);
	(* current operative character module *)
  currchar := nextchar;
	(* Look-ahead character name module *)
  With NextChar do begin
    IF xeof then
      name := FileMark
    Else If xeoln then
	   name := EndOfLine
    Else If LooK IN ['a'..'z'] then (* lower case *)
	   name := lletter
    Else If LooK IN ['A'..'Z'] then (* upper case *)
	   name := uletter
    Else If LooK IN ['0'..'9'] then (* digit *)
	   name := digit
    Else If LooK = '''' then
	   name := quote
    Else If LooK = TAB then
	   name := atab
    Else If LooK = space then
	   name := blank
    Else name := otherchar;
	(* store character value module *)
    CASE name of
	EndOfLine,
	FileMark:	Valu := space;
	Else:		Valu := LooK
	end(* case name of *);
    end(* look-ahead name module *)
end(*---of GetC---*);

Procedure HEADER;
begin
writeln(' ':15,'STATUS      Cchar   Cchar',' ':11,'Nchar    Nchar');
writeln('    LooK     EOLN  EOF     VAL    Name ',
		' ':11,' VAL     Name');
end;

Procedure DISPLAY;
begin
{-----FIRST LINE---}
  write(count:3, fill);
  If ord(LooK)=26 then
     write('^Z', ' ':5)
  Else
    write(LooK, ' ':6);
  If xeoln then write('T') else write('F'); write('   ');
  If Xeof then write('T') else write('F');
  Writeln(' ':30, nextchar.valu, ' ':6, nextchar.name );
{-----SECOND LINE-----}
  Writeln(' ':26, currchar.valu, ' ':5 , currchar.name );
end;

Procedure PAUSE;
VAR
  dummy : char;
begin
  write(prompt);readln(dummy);
end;

Procedure Initialize;
begin
  TAB := chr(9);  (* ASCII Tab character *)
	(*** INITIALIZE look-ahead char ***)
  nextchar.name := blank;
  nextchar.valu := space;
end;

BEGIN(* SCAN-2 main *)
  GETID('Enter File Name: ', FileID);
  RESET(FileID, ft);
  If EOF(ft) then
    begin
    writeln('File not found');
    end
  ELSE
    begin
      Initialize;
      writeln;writeln;
      GetC(nextchar, currchar);(* attempt to read *)
      While (CurrChar.name<>filemark) do
	begin(* processing char *)
 	count := 0;
	Header;
	  REPEAT
	    count := count +1;
	    Display;
	    GetC(nextchar, currchar);
	  UNTIL (count=DisplayLines) or (CurrChar.name=filemark);
	PAUSE;
	writeln;
	end(* of processing *);
      writeln('Normal file termination');
    end(* else *);
    WRITELN('That''S all!');
end(*---of SCAN-2 eval---*).
