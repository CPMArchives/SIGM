(*
** PROGRAM TITLE:	Alpha Numeric Numbers Conversions
**
** WRITTEN BY:		Raymond E. Penley
** DATE WRITTEN:	5 July 1980
**
** SUMMARY:
**
**	VAL =  Single character to integer value.
**	RDR =  Alphanumeric to real number.
**	STR =  Integer to alphanumeric.
**
**  Donated to PASCAL/Z USERS GROUP, July 1980
**
*)
const	default = 80;		{ Default length }

type	Dstring = STRING default;
	str0    = STRING 0;
	str255  = STRING 255;

var	zx :real;		{ the real numbers go here }
	done: boolean;
	number : integer;	{ the integer number in here }
	answer : Dstring;	{ String buffer		}
 
function length(x: str255): integer; external;
procedure setlength(var x: str0; y: integer); external;

(*------------------------------------------*)
Function VAL(ch: char): integer;
{ Returns the integer value of
  the single char passed }
const	z = 48; {  ORD('0')  }
begin
  VAL := ORD(ch) - z
end;

(*------------------------------------------*)
Function RDR(var f: Dstring  ): real;
{ read real numbers in free format.
  author: Niklaus Wirth
  book:   Pascal User Manual & Report
	  pg 122-123
  ENTER WITH:
	f = a string containing ONLY the alphanumeric number
	    to be converted to a real number.
  RETURNS:
	A real number.
	Any error returns RDR := 0.0
*}
label	9;{ error exit }
const
	t48 = 281474976710656.0 ;
	limit = 56294995342131.0 ;
	lim1 = 322;		{ maximum exponent }
	lim2 = -292;		{ minimum exponent }
	space = ' ';
	emsg1 = '**digit expected';
	emsg2 = '**number too large';
type
	posint = 0..323;
var
  ch	: char;
  y	: real;
  posn,
  a,i,e	: integer;
  fatal,
  s,ss	: boolean; { signs }

procedure Getc(var ch: char);
begin
  posn := posn + 1;
  ch := f[posn];
end;

function TEN(e: posint): real; {  = 10**e,  0<e<322  }
var	i: integer;
	t: real;
begin
  i := 0;
  t := 1.0;
  repeat
    If ODD(e) then
      case i of
	0: t := t * 1.0E1;
	1: t := t * 1.0E2;
	2: t := t * 1.0E4;
	3: t := t * 1.0E8;
	4: t := t * 1.0E16;
	5: t := t * 1.0E32	{ that's all! }
	6,7,8:
	   begin
	   writeln('**Floating point overflow');
	   fatal := true;
	   e := 2;{ sets e to zero on next division }
	   end;
	{*===================*
	--- can not use ---
	 6: t := t * 1.0E64;
	 7: t := t * 1.0E128;
	 8: t := t * 1.0E256
	 *===================*}
      end{ case };
    e := e DIV 2;
    i := i + 1;
  until e=0;
  TEN := t;
end{of TEN};

begin
  fatal := false;
  posn := length(f);
  setlength(f,posn+1);
  f[posn+1] := space;
  posn := 0;
  getc(ch);
  { skip leading blanks }
  While ch=space do getc(ch);
  If ch='-' then
    begin
    s := true;
    getc(ch)
    end
  Else
    begin
    s := false;
    If ch='+' then getc(ch)
    end;
  If not(ch IN ['0'..'9']) then
    begin
    writeln(emsg1);
    {HALT} fatal := true; goto 9;
    end;
  a := 0;
  e := 0;
  repeat
    If a<limit then
      a := 10 * a + VAL(ch)
    Else
      e := e+1;
    getc(ch);
  until not(ch IN ['0'..'9']);
  If ch='.' then
    begin { read fraction }
    getc(ch);
    while ch IN ['0'..'9'] do
      begin
      If a<limit then
	begin
	a := 10 * a + VAL(ch);
	e := e - 1
	end;
      getc(ch);
      end{ while };
    end{ read fraction };
  If (ch='E') or (CH='e') then
    begin { read scale factor }
      getc(ch);
      i := 0;
      If ch='-' then
        begin ss := true; getc(ch) end
      Else
        begin
        ss := false;
        If ch='+' then getc(ch)
        end;
      If ch IN ['0'..'9'] then
        begin
        i := VAL(ch);
        getc(ch);
        while ch IN ['0'..'9'] do
	  begin
	  If i<limit then i := 10 * i + VAL(ch);
	  getc(ch)
	  end{ while}
        end{ If }
      Else
        begin
        writeln(emsg1);
        {HALT} fatal := true; goto 9;
        end;
      If ss
	 then e := e - i
	 Else e := e + i;
    end{ read scale factor };
  If e < lim2 then
    begin
    a := 0;
    e := 0;
    end
  Else
    If e > lim1 then
      begin
      writeln(emsg2);
      {HALT} fatal := true; goto 9;
      end;
  {  0 < a < 2**49  }
  If a >= t48 then
    y := ((a+1) DIV 2) * 2.0
  Else
    y := a;
  If s then y := -y;
  If e < 0 then
    RDR := y/TEN(-e)
  Else
    If e<>0 then
      RDR := y*TEN(e)
    Else
      RDR := y;
9: If fatal then RDR := 0.0;
End{of RDR};

(*------------------------------------------*)
Procedure STR( var S: Dstring;
		tval: integer );
{ ENTER WITH:
	tval = INTEGER to be converted to an alphanumeric
	       string.
  RETURNS:
	An alphanumeric equal of tval in S.
}
const
	size = 15; { number of digits in the number }
var
	cix : char;
	digits : packed array[1..10] of char;
	i,		{ length of number }
	d,t,j: integer;
begin
  digits := '0123456789';
  t := ABS(tval);
  setlength(S,0);	{ null string }
  i := 0;
  repeat { generate digits }
    i := i + 1;
    d := t MOD 10;
    append(S,digits[d+1]);
    t := t DIV 10
  until (t=0) OR (i>=size);
  If (tval<0) AND (i<size) then
    begin { sign }
    i := i + 1;
    append(S,'-')
    end;
  j := 1;
  while j<i do
    begin{ reverse }
    cix := S[i]; S[i] := S[j]; S[j] := cix;
    i := i - 1;
    j := j + 1
    end{ revese }
End{of STR};

begin
  done := false;
  repeat
    writeln;
    write('Enter a number (real or integer) ?');
    readln(answer);
    writeln('literal number is ..... ', answer);
    writeln('with a length of  ..... ', length(answer):4 );
    zx := RDR(answer);
    writeln('the numeric equal of your literal .. ', zx);
    writeln('Formatted as ! Number:10:4 ! ....... ', zx:10:4);
    write('Five times ', zx, ' = ');writeln( zx * 5 );
    write('The integer portion is ............... ');writeln( trunc(zx) );
    writeln;
    write('Enter an integer ?');
    readln(number);
    STR(answer, number);
    writeln('The integer number is .............. ', number);
    writeln('Expressed as an alphanumeric is .... ', answer);
    writeln('the length of the literal is ....... ', length(answer) );
    append(answer,answer);
    writeln('Since we now have a string');
    writeln(' we can concatenate like so ........ ', answer);
  Until done;
End{ of Alpha_Numeric }.

