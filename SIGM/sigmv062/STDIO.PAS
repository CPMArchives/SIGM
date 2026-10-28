EXTERNAL KFORMAT::STDIO;

{++++++++++++++++++++++++++++++++++++++++}
{+    STANDARD FILE IO MODULE		+}
{++++++++++++++++++++++++++++++++++++++++}
{
WRITTEN BY:    Raymond E. Penley
DATE WRITTEN:  March 13, 1981
}
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	 DECLARE THE FOLLOWING IN YOUR MAIN PROGRAM.
CONST
  DEFAULT	= 80;
  SMAX		= 255;
  space 	= ' ';
  maxargc	= 5;	< maximum # of words you expect to parse >
			< out of the Command line.		 >

TYPE
  byte		= 0..255;
  int		= INTEGER;
  DSTRING	= string default;
  MSTRING	= STRING SMAX;
  S$0		= string 0;
  S$255 	= string 255;

VAR
  argc : byte;
  argv : ARRAY [1..maxargc] OF DSTRING;
  infile,
  outfile,
  params : byte;
  inbuf : MSTRING;
  ioresult,
  con_wanted,
  printer_wanted : boolean;
  stdin,
  stdout	: TEXT;

PROCEDURE HALT(message:MSTRING);EXTERNAL;

++++++++++++++++++++++++++++++++++++++++++++++++++++}

{$C-}{ CONTROL-C CHECKING OFF }
{$M-}{ INTEGER MULT & DIVD ERROR CHECKING OFF }
{$F-}{ FLOATING POINT ERROR CHECKING OFF }


{$iOPEN.LIB }

{$iGCML.LIB }


PROCEDURE PARSE(inbuf: MSTRING);
var	idlen,cpos: int;
begin
  append(inbuf,' ');
  for argc := 1 to maxargc do setlength(argv[argc],0);
  argc := 0;
  cpos := 1;
     WHILE cpos < length(inbuf) DO
       BEGIN
	 WHILE (cpos < length(inbuf)) AND (inbuf[cpos]=space) DO
	   cpos := cpos + 1; { skip over spaces  }
	 idlen := 0;
	 argc := argc + 1;
	 WHILE (cpos < length(inbuf)) AND (inbuf[cpos]<>space) DO
	   BEGIN {accept only non-space}
	     idlen := idlen + 1;
	     append( argv[argc], inbuf[cpos] );
	     cpos := cpos + 1;
	   END;
       END; {WHILE cpos<length(inbuf)}
end;


PROCEDURE STDOPEN;
BEGIN
  xeof := false;
  xeoln := false;
  infile  := 1;  { argv[1] should be the input file. }
  outfile := 2;  { argv[2] should be the output file. }
  params  := 3;  { argv[3] should hold any optional parameters }

  GCML(inbuf);

  if length(inbuf)<>0 then
    begin  PARSE(inbuf);
	   { open input file }
	   OPEN(argv[infile],'I',stdin);
	   if ioresult=false then HALT(' ');
	   { open output file			    }
	   { if no file specified then default=LST: }
	   if length(argv[outfile])=0 then argv[outfile] := 'LST:';
	   OPEN(argv[outfile],'O',stdout);
	   if ioresult=false then HALT(' ');
    end
END { * STD OPEN * };


PROCEDURE getc(VAR ch: char);	{$R-}{ * RANGE CHECKING OFF * }
BEGIN
  xeof := false;
  IF NOT EOF(stdin) THEN
    READ(stdin,ch);
  IF EOF(stdin) THEN
    begin ch := ' ';
	  xeof := true;
    end
  else if ch=chr(5) then	{ * end of file on the console? * }
    xeof := true;		{ * do eof stuff if yes 	* }
end;				{$R+}{ * RANGE CHECKING ON	* }


PROCEDURE putc(c:CHAR);
BEGIN
  if c=newline
    then writeln(stdout)
    else WRITE(stdout,c);	{output the character}
END;


PROCEDURE puts(VAR LINE:MSTRING);
var	i:int;
BEGIN
   for i:=1 to length(LINE) do putc( LINE[i] );
END;


procedure gets(var inbuf:MSTRING);
{ * this version of gets() specially modified for kformat.pas * }
(* GLOBAL:
	   newline, xeof, SMAX, stdin *)
var	ch: char;
BEGIN
  setlength(inbuf,0);			{ * inbuf := ''; * }
  WHILE not eoln(stdin) and not xeof do
    begin
      getc(ch);
      If ORD(ch)>127 then ch := CHR( ORD(ch)-127 );
      If length(inbuf) < SMAX then (* start accepting characters *)
	append(inbuf, ch)
    end;
  READLN(stdin); {+++ ignore the line boundary +++}
  append(inbuf,newline);		{ *** MAR 81 *** }
end;


{END EXTERNAL}.

 READLN(stdin); {+++ 