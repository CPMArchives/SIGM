{++++++++++++++++++++++++++++++++++++++++++++++++}
{+  PROGRAM TITLE:	Line Number		+}
{+						+}
{+  WRITTEN BY:		Raymond E. Penley	+}
{+  DATE WRITTEN:	23 July 1980		+}
{+						+}
{+  WRITTEN FOR:	Pascal/Z Users Group	+}
{+						+}
{+  SUMMARY:					+}
{+	Simple program to read in a text file	+}
{+	(such as a program), and WRITE out to	+}
{+	another file adding line numbers to	+}
{+	each line processed.			+}
{+						+}
{++++++++++++++++++++++++++++++++++++++++++++++++}
PROGRAM LINENOS;
(*$P-,F-,M- *)
CONST
	default	= 255;
	left_margin = 5;
	MaxLineLength = default;
	space = ' ';
TYPE
	S$0	= string 0;
	S$255	= string 255;
VAR
	blankcount	: INTEGER;
	charcount	: INTEGER;
	con_wanted	: BOOLEAN;
	ch		: char;
	fatal_error	: BOOLEAN;
	FOUT,
	FIN		: TEXT;
	linecount	: INTEGER;
	other		: INTEGER;
	tab		: CHAR;
	wordcount	: INTEGER;

(*$C- *)
FUNCTION length(x: S$255):INTEGER;EXTERNAL;
FUNCTION index(x,y: S$255): INTEGER; EXTERNAL;
PROCEDURE setlength(VAR x:S$0; y:INTEGER);EXTERNAL;

PROCEDURE Summary;
BEGIN
  WRITELN('Line count .......... ', linecount-1:3);
  WRITELN('No. of spaces ....... ', blankcount:3);
  WRITELN('No. of characters ... ', charcount:3);
  WRITELN;
END;

PROCEDURE GetC(VAR ch: char);
BEGIN
  IF NOT EOF(FIN) THEN
    READ(FIN,ch);
  IF EOF(FIN) THEN ch := ' ';
END;

PROCEDURE Classify(VAR ch: CHAR);
BEGIN
  IF ch IN ['A'..'Z','a'..'z'] THEN
     charcount := SUCC(charcount)
  ELSE IF (ch=space) THEN
     blankcount := SUCC(blankcount)
  ELSE
     other := SUCC(other);
END;

PROCEDURE ConnectFiles;
const
	fid_len	= 14;	{ Max length CP/M file names }
type	FID	= string fid_len;
	byte	= 0..255;
var	firstname,
	fname  : FID;
	ix,jx	: byte;

	Procedure PAD(var ID: fid; required: byte);
	const	space = ' ';
	BEGIN
	  while (length(ID)<required) Do append(ID,space);
	end;

BEGIN{-GETID-}
  fatal_error := FALSE;
  setlength(firstname,0);
  WRITELN;
  WRITE('Enter <Drive:><File name>  ');
  readln(firstname);
  IF (length(firstname)>fid_len) then
    setlength(firstname,fid_len)
  ELSE
    PAD(firstname, fid_len);
  RESET(firstname, FIN);

  IF EOF(FIN) THEN {ABORT}
    BEGIN
    WRITELN('FILE NOT FOUND');
    fatal_error := TRUE;
    END
  ELSE
    BEGIN
    ix := index(firstname,'.'); { search for an extension }
    jx := index(firstname,' '); { search for the first space }
    IF (ix=0) then{ no extension was specified }
      setlength(firstname,jx-1)
    ELSE
      setlength(firstname,ix-1);

    { fname := CONCAT( firstname, '.LST' ); }
    setlength(fname,0);
    append(fname, firstname);
    append(fname, '.LST');
    PAD(fname, fid_len);
    REWRITE(fname, FOUT);
    end;
END{ of ConnectFiles };

PROCEDURE Initialize;
VAR	IX: 1..25;
	ch: char;
BEGIN
  FOR IX:=1 TO 25 DO WRITELN;
  linecount := 0;
  charcount := 0;
  blankcount := 0;
  other := 0;
  wordcount := 0;
  tab := CHR(9);
  ConnectFiles;
  IF NOT fatal_error THEN
    BEGIN
      WRITE('Output to Console?');
      READLN(ch);
      con_wanted := ( (ch='Y') or (ch='y') );
    END;
  WRITELN;
END;

(*$C+*)
BEGIN{ main program LINENOS }
  Initialize;
  WHILE (NOT EOF(FIN)) AND (NOT fatal_error) DO
    BEGIN
      linecount := succ(linecount);
      WRITE(FOUT, linecount:(left_margin),': ');
      IF con_wanted THEN
	WRITE( linecount:(left_margin),': ');
	  WHILE NOT EOLN(FIN) Do
	    BEGIN
	      GetC(ch);
	      Classify(ch);
	      WRITE(FOUT, ch);
	      IF con_wanted THEN WRITE(ch);
	    END{ while NOT eoln };
	  READLN(FIN); {+++ ignore the line boundary +++}
	  WRITELN(FOUT);
	  IF con_wanted THEN WRITELN;
    END;
  Summary;
END{ of LINENOS }.
