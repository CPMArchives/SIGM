{********************************************************}
{*							*}
{*  PROGRAM TITLE:	STRING Functions Demonstration	*}
{*							*}
{*  WRITTEN BY:		Raymond E. Penley		*}
{*  DATE WRITTEN:	27 MAY 80			*}
{*							*}
{*  WRITTEN FOR:	Pascal/Z Users Group		*}
{*							*}
{*  NOTE:						*}
{*     All comments about the string library are	*}
{*     found in the file 'STRLIB.DOC'			*}
{*							*}
{********************************************************}

PROGRAM StringDemo;

CONST
  master = 'THE QUICK BROWN FOX JUMPED OVER THE LAZY BLACK DOG';
  sign5 = 'This is the master string we will be using:';
  space = ' ';
  StrMax = 255; {maximum length of a string}
(* !!!! IMPLEMENTATION DEPENDENT !!!! *)
	INPUT = 0;

TYPE
  alfa	     = STRING 10 ;{just the right size}
  string40   = STRING 40 ;{ 1/2 of default length  }
  string79   = STRING 79 ;{ ONE less than default length }
  string80   = STRING 80 ;{ DEFAULT length for strings }
  MString    = STRING StrMax ;{ The BIG GUN }
(*---Use these for the Pascal/Z supplied functins---*)
  $STRING0   = STRING 0 ;
  $STRING255 = STRING Strmax ;

VAR
  error  : Boolean; {---required for the STRING Library---}

(*---Required for Pascal/Z supplied string functins---*)
FUNCTION LENGTH(X: $STRING255): INTEGER; EXTERNAL;
FUNCTION INDEX(X,Y :$STRING255): INTEGER; EXTERNAL;
PROCEDURE SETLENGTH(VAR X :$STRING0; Y :INTEGER); EXTERNAL;
(*----------------------------------------------------*)


(************************************************)


Function UCase(ch : char) : char;
(*---Returns an uppercase ASCII character---*)
begin
  If ch IN ['a'..'z'] then
    UCase := CHR(ORD(ch) -32)
  Else
    UCase := ch
end;

(************************************************)


	{---------------------------------------}
	{	    STRLIB LIBRARY		}
	{---------------------------------------}

PROCEDURE PRINT( A : MString);
VAR
  I : 1..StrMax;
begin
  If (LENGTH(A) > 0) and (LENGTH(A) <= StrMax) then
    For I:= 1 to LENGTH(A) do
	write(A[ I ])
  Else
    Write(space)
end;

  (*********************************************)


PROCEDURE COPY( {    TO     } VAR dest : string80 ;
		{   FROM    } THIS : MSTRING ;
		{STARTING AT} POSN : INTEGER ;
		{# OF CHARS } LEN  : INTEGER ) ;
{  COPY(NEW_NAME, NBUF, NAME_ADDR, NAME_LEN);	}
{  COPY(A_STRING, A_STRING, 5, 5);		}
{GLOBAL
  StrMax = 255;
  MSTRING = STRING StrMax;			}
LABEL	99;
CONST	line_length = 80 ;
VAR	ix   : 1..StrMax;
begin
  SETLENGTH(dest,0);  {length returned string=0}
  If (len + posn) > line_length then{exit}goto 99;
  IF ((len+posn-1) <= LENGTH(this)) and
     (len > 0) and (posn > 0) then
     FOR ix:=1 to len do
         APPEND(dest, this[posn+ix-1]);
99: {Any error returns dest with a length of ZERO.}
End{of COPY};

  (*********************************************)


PROCEDURE CONCAT({New_String} VAR C : string80 ;
		 {Arg1_str  }     A : Mstring ;
		 {Arg2_str  }     B : Mstring );
{  CONCAT(New_string, Arg1, Arg2);   }
CONST
  line_length = 80;
VAR
  ix : 1..StrMax;
begin
  SETLENGTH(C,0);
  If (LENGTH(A) + LENGTH(B)) <= line_length then
    begin
	APPEND(C,A);
        APPEND(C,B);
    end;
  {If error then returns length of new_string=0}
End{of CONCAT};

  (*********************************************)


PROCEDURE REPLACE(VAR source	: string80;
		  VAR dest	: string80;
		      K1	: Integer);
(*
 *	REPLACE(Source, Destination, Index);
 *	REPLACE(Sub,Next,N);
 *)
CONST	line_length = 80;
VAR	temp1,temp2 : Mstring;
	pos, k      : 1..StrMax;
begin
  If (K1 > 0) and (K1 <= LENGTH(dest)) and (K1 <= line_length) then
    begin (* Position 'K1' is within STRING 'dest'	*)
	  (* but not longer than line_length		*)
      SETLENGTH(temp1,0);
      SETLENGTH(temp2,0);
      COPY(temp1,dest,1,K1-1);
      APPEND(temp1,source);(* concatenate temp1 and A *)
      k := K1 + LENGTH(source);(* extract remaining chars from dest *)
      COPY(temp2,dest,k,(LENGTH(dest)-k+1));
      CONCAT(dest,temp1,temp2)
    end(*If*)
  Else(* Issue error message and do nothing *)
    Writeln('Index out of range')
end(* of REPLACE *);

  (*********************************************)



Procedure GetLine( VAR Agr_string : string80 ;
			    count : integer );
(*----------------------------------------------*)
(* version: 31 MAY 80 by R.E.Penley		*)
(* Valid Alphanumeric chars are:		*)
(* from the ASCII space - CHR(32) to the	*)
(*	    ASCII tilde - CHR(126)		*)
(* In order to get this to work with		*)
(* Pascal/Z v 3.0 I have defined a line		*)
(* as a string[80]				*)
(*----------------------------------------------*)
(*
GLOBAL	StrMax = 255;
	Mstring = STRING 255;
	error  : boolean; <<to be returned to caller>>
*)
CONST	SPACE = ' ';
	a_error = 'Alphanumerics only - ';
	line_length = 80;
VAR	InChar : char;
	CHAR_COUNT : INTEGER;
	ix : 1..StrMax;
begin
  error := false;
  SETLENGTH( Agr_string, 0 );
  CHAR_COUNT := 0;
  REPEAT
  If (count <= line_length) AND (CHAR_COUNT < count) then
    begin{start accepting chars}
    READ( InChar );
    If InChar IN [' ' .. '~'] then{valid char}
      begin{increment CHAR_COUNT and store InChar}
	CHAR_COUNT := char_count + 1 ;
	APPEND( Agr_string, InChar );
      end(* If *)
    Else (* we have a non-acceptable character *)
      begin
	WRITELN(a_error);
	error:=TRUE
      end(* else *)
    end(* If *)
  Else	(*   ERROR   *)
    begin (* RESET EndOfLine <EOLN> *)
{}    READLN( Agr_string[ CHAR_COUNT ] );
      WRITELN('Maximum of', count:4, ' characters please!');
      error:=TRUE
    end(* else *)
  UNTIL EOLN(INPUT) or error;
  If error then{return a length of zero}
    SETLENGTH( Agr_string, 0 );
End{of GetLine};


	{---------------------------------------}
	{	    UTILITY ROUTINES		}
	{---------------------------------------}

Procedure DRAW(picture : Mstring ; count : integer);
VAR	ix : integer;
begin
  For ix:=1 to count do
    WRITE(picture);
end;

Procedure DELAY(timer:integer);
{  DELAY(10);	will give about 1 second delay }
{  DELAY(5);	will give about 0.5 second delay }
{  DELAY(30);	will give about 3 second delay }
CONST	factor = 172;
var	ix,jx : integer;
begin
  for ix:=1 to factor do
    for jx:=1 to timer do {dummy};
end;

Function QUIRY(message : string80) : boolean ;
{	Try to write a general purpose		}
{	routine that gets a 'YES' or 'NO'	}
{	response from the user.			}
VAR	ans : string 2;
	valid : boolean;
begin
  Repeat
    valid := false;
    Write(message);
    readln(ans);
    If ans='OK' then
      begin valid := true; QUIRY := true end
    Else
	If ans[1] IN ['Y','y','N','n'] then
	  begin
	    valid := true;
	    QUIRY := ( (ans='Y') or (ans='y') )
	  end
  Until valid{response}
end{of Quiry};

Procedure CLEAR;
var	ix :1..25;
begin
  for ix:=1 to 25 do writeln
end;

Procedure SKIP(n : integer);
var	ix : 0..255;
begin
  for ix:=1 to n do writeln
end;

Procedure PAUSE;
CONST	sign = 'Enter return to continue ';
var	ch : char;
begin
  write(sign);
  readln(CH)
end;

Procedure HEADER( title : string80 );
CONST	left_margin  = 11;
	right_margin = 51;
	center	     = 31;
	dashes	     = '{---------------------------------------}';
VAR	F1,	{filler left side}
	F2,	{filler right side}
	CL,	{center line of title}
	len	{length of title}
		 : integer;
begin
  len := LENGTH(title);
  CL := len DIV 2;
  {If length of title is odd then increase CL by one}
  If ODD(len) then CL := CL +1;
  F1 := (center - CL) - left_margin;
  {If length of title is even then reduce F1 by 1   }
  If not ODD(len) then F1 := F1 - 1;
  F2 := right_margin - (center + CL);
  writeln(' ':left_margin,dashes);
  writeln(' ':left_margin,'{',' ':F1,title,' ':F2,'}');
  writeln(' ':left_margin,dashes);
end;

	{---------------------------------------}
	{	DEMONSTRATION ROUTINES		}
	{---------------------------------------}

Procedure Simple_IO;
VAR	line : string80;
	C   : char;
	again: boolean;
begin
  CLEAR;
  writeln;writeln;
  HEADER('Input/Output DEMONSTRATION');
  SKIP(5);
  REPEAT
    WRITE('Enter one character >');
    Readln(C);
    WRITELN('The Char you entered was ', C);
    writeln;writeln;
    again := QUIRY('Again? ');
  Until not again;
  Repeat
    Repeat
      WRITELN;
      WRITELN('Input a short string');
      WRITELN('            <--- Max 10 char');
      WRITE('>>');
      GetLine(line,10);
      IF NOT error THEN
        begin
	  WRITELN;
	  WRITE('You entered a');
	  write(LENGTH(line):3, ' Character String. >');
	  PRINT(line);Writeln;
        end;
    Until not error;
    writeln;writeln;
    again := QUIRY('Again? ');
  Until not again;
End{of I/O demo};

Procedure Str_Comp;
VAR	S  : string 40;
	T  : string 20;
begin
  S := 'SOMETHING';
  T := 'SOMETHING BIGGER';
  CLEAR;
  HEADER('STRING COMPARISONS');
  SKIP(2);
  writeln('First we will compare these two string variables:');
  writeln('1. ',S);
  writeln('2. ',T);
  DELAY(20);
  IF S=T THEN
    WRITELN('Strings do not work very well')
  ELSE
    IF S > T THEN
      WRITELN(S, ' is greater than ', T)
    ELSE
      IF S < T THEN
        WRITELN(S, ' is less than ', T);
  writeln;
  writeln('Now to compare the variable string S against the');
  writeln('literal strings ''SOMETHING'' and ''SAMETHING''');
  DELAY(20);
  IF S = 'SOMETHING' THEN
    WRITELN(S, ' equals ', S);
  IF S > 'SAMETHING' THEN
    WRITELN(S, ' is greater than SAMETHING');
  writeln;
  PAUSE;
  writeln;
  writeln('The same test but with extra blanks in the literal string');
  DELAY(10);
  IF S = 'SOMETHING               ' THEN
    WRITELN('BLANKS DON''T COUNT')
  ELSE
    WRITELN('BLANKS APPEAR TO MAKE A DIFFERENCE');
  writeln;
  writeln('Now to change the variable strings:');
  writeln('1.  S := ''XXX''');
  writeln('2.  T := ''ABCDEF''');
  S := 'XXX' ;
  T := 'ABCDEF' ;
  DELAY(20);
  IF S > T THEN
    WRITELN(S, ' is greater than ', T)
  ELSE
    WRITELN(S, ' is less than ',T);
  writeln;writeln;
  PAUSE;
End{of Str_Comp};

Procedure Copy_demo;
(* global
	master : string80; *)
CONST	sign1 = 'First - Enter the starting position in the main string';
	sign2 = 'Next - Enter the number of chars to copy';
VAR	sub	 : string 80;
	again	 : boolean;
	start,
	count	 : INTEGER;
begin
  CLEAR;
  HEADER('STRING COPY');
  writeln;writeln;
  WRITELN(sign5);
  Repeat
    WRITELN;
    WRITELN(master);
    writeln;writeln;
    Writeln(sign1);
    WRITE(' >'); Readln(start);
    Writeln(sign2);
    write(' >'); Readln(count);
    WRITELN;
    COPY(SUB,master,start,count);
    write('The substring = ');WRITELN(SUB);
    writeln;writeln;
    again := QUIRY('Again? ');
  Until not again;
End{of Copy_demo};

Procedure C_cat_demo;
VAR	strg1,strg2,
	sub	: string 80;
	again	: boolean;
begin
  CLEAR;
  HEADER('CONCATENATION DEMONSTRATION');
  writeln;writeln;
  Repeat
    writeln;writeln;
    writeln('Now to CONCAT two strings');
    writeln('Enter a short string');
    GetLine(strg1,40);
    writeln('Enter another short string');
    GetLine(strg2,40);
    CONCAT(sub,strg1,strg2);
    writeln(SUB);
    writeln;writeln;
    again := QUIRY('Again? ');
  Until not again;
end{of C_cat_demo};

Procedure Replc_demo;
CONST	sign1 = 'First - give me a short string within the master';
VAR	pattern,
	work	 : string80;
	pos	 : integer;
	again	 : boolean;
begin
  CLEAR;
  HEADER('Position & Replace demo');
  writeln;writeln;
  WRITELN(sign5);
  Repeat
    work := master;
    WRITELN;
    WRITELN(work);
    writeln;writeln;
    Writeln(sign1);
    WRITE(' >');
    Readln(pattern);
    pos := INDEX(work,pattern);
    writeln('The position of ',pattern,' is : ',pos);
    writeln;
    writeln('Now to replace `BROWN` with `APPLE`');
    writeln;
    pattern := 'APPLE';
    pos := INDEX(work,'BROWN');
    REPLACE(pattern,work,pos);
    writeln(work);
    writeln;
    writeln('Finally to replace `LAZY BLACK DOG`');
    writeln;
    pattern := 'SLOW TURTLE';
    pos := INDEX(work,'LAZY');
    REPLACE(pattern,work,pos);
    writeln(work);
    writeln;writeln;
    again := QUIRY('Again? ');
  Until not again;
End{of Replc_demo};

Procedure SIGNON;
var	ix : integer;
begin
  For ix := 1 to 2 do
    begin DRAW('*',72);writeln end;
  DRAW('*',4);DRAW(' ',64);DRAW('*',4);writeln;

  DRAW('*',4);
  WRITE(' ':22, 'STRING DEMONSTRATION',' ':22);
  DRAW('*',4);writeln;

  DRAW('*',4);DRAW(' ',64);DRAW('*',4);writeln;
  For ix := 1 to 2 do
    begin DRAW('*',72);writeln end;
end{of signon};

Procedure Wrap_up;
begin
  CLEAR;
  HEADER('=*= Pascal/Z is good! =*=');
  writeln;writeln;
  writeln('That concludes the demonstration');
  writeln('You are invited to look over this Pascal program.');
  writeln('There are many procedures and functions that should');
  writeln('be included in your library.');
  writeln('If you have any questions or can make any improvements');
  writeln('please send them to the:');
  writeln;
  writeln(' ':12,'===/');
  writeln(' ':12,'  /	USERS GROUP');
  writeln(' ':12,' /========================');
  writeln(' ':12,'7962 Center Parkway');
  writeln(' ':12,'Sacramento, CA.  95823');
  SKIP(5);
end{of wrap_up};

	{---------------------------------------}
	{	MASTER CONTROL PROGRAM		}
	{---------------------------------------}

Begin{main program}
  CLEAR;
  SIGNON;
  SKIP(10);
  DELAY(40);{4 seconds delay};
  Simple_IO;
  Str_Comp;
  Copy_demo;
  C_cat_demo;
  Replc_demo;
  Wrap_up;
End{of Demonstration}.
