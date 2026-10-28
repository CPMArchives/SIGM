{++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+							+}
{+  PROGRAM TITLE:	Cross Reference Generator	+}
{+							+}
{+  WRITTEN BY:		Peter Grogono			+}
{+  DATE WRITTEN:	?				+}
{+							+}
{+  SUMMARY:						+}
{+							+}
{+	1. Output Files:				+}
{+	   default is to disk files:			+}
{+	   a. output file = file name + '.XRF'		+}
{+	      all identifiers and their line #		+}
{+	   b. output file = file name + '.PRN'		+}
{+	      the file with all lines numbered		+}
{+	2. LISTING Device:				+}
{+	   Output may be to either the console or	+}
{+	   the printer but NOT both.			+}
{+							+}
{+  MODIFICATION RECORD:				+}
{+	12-AUG-80	-modified for Pascal/Z v3.0	+}
{+			-by Raymond E. Penley		+}
{+	16-AUG-80	-added function ConnectFiles	+}
{+	17-AUG-80	-added GetL, ReadC, ReadWord	+}
{+      22-AUG-80	-selective use of control-c	+}
{+							+}
{+							+}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
PROGRAM XREFG2;
{ Cross Reference Generator }
(*$P-,F-,M- [symbolic I/O OFF,
	     floating point checking OFF,
	     integer mult & div checking OFF]		*)
CONST
	alfa_length	=    8;
	BLANKS		= '        ';
	dflt_str_len	= 255;
	entrygap	=    0;   { # of blank lines between line numbers}
	fid_len		=   14;   { Max length CP/M file names }
	heading		= 'Cross-Reference Listing';
	headingsize	=    3;   {number of lines for heading}
	LLmax		= dflt_str_len;
{}	MaxOnLine	=   10;
	Maxlines	= MAXINT; {longest document permitted}
	MaxWordlen	= alfa_length;{longest word read without truncation}
	Maxlinelen	=   80;   {length of output line}
	MaxOnPage	=   60;   {size of output page}
	numbergap	=    2;   {number of gaps between line numbers}
{}	NumKeys		=   46;   {number of Pascal reseve words}
				  {Read your Pascal manuals on this one!}
{}	NumKeysP1	= NumKeys + 1;
{}	NumberWidth	=    6;
	space		=  ' ';

TYPE
{}	ALFA	= PACKED ARRAY[1..alfa_length] OF CHAR;
{}	BYTE	= 0..255;
{}	CHARNAME = (lletter, uletter, digit, blank, quote, atab,
		      EndOfLine, FileMark, otherchar );
{}	CHARINFO = RECORD
		     name : charname;
		     valu : CHAR
		   END;
	COUNTER	= 1..Maxlines;
{}	dfltstr	= string dflt_str_len;
	FID	= string fid_len;
	lineindex = 1..Maxlinelen;
{}	pageindex = BYTE;
	Wordindex = 1..MaxWordlen;
	Queuepointer = ^Queueitem;
	Queueitem = RECORD
			linenumber : counter;
			NextInQueue: Queuepointer
		    END;
	EntryType = RECORD
			Wordvalue : alfa;
			FirstInQueue,
			lastinQueue: Queuepointer
		     END;
	treepointer = ^node;
	node = RECORD
		 entry : EntryType;
		 left,
		 right : treepointer
	       END;

	S$0	= string 0;
	S$255	= string 255;

VAR
  bell		: CHAR;
  blankindex	: BYTE;
  currchar,			{ Current operative character }
  nextchar 	: charinfo;	{ Look-ahead character }
  fatal_error	: BOOLEAN;
  FILE_ID,			{ CP/M file name }
  PRN_ID,			{ basic file name + '.PRN' }
  New_ID  	: FID;		{ basic file name + '.XRF' }
  fbuffer  	: dfltstr;	{ Format buffer - before final Print }
  FIN		: TEXT;
  flushing 	: (KNOT, DBL, STD, LIT);
  form_feed	: CHAR;
  Key		: ARRAY[1..NumKeysP1] OF alfa;
  letters 	: SET OF CHAR;
  LISTING	: BOOLEAN;
  Look	   	: char;	{ Character read in from File }
{}{OUTPUT	: TEXT;  }	{ Listing device -console or printer }
  tab	   	: CHAR;
  wordcount	: INTEGER;	{ total # of words in file }
  WordTree 	: treepointer;
  xeof,			{ EOF status AFTER a read }
  xeoln    	: BOOLEAN;	{ EOLN status after a read }

(*$C- [Control-C OFF]***********************************************)

FUNCTION length(x: S$255): INTEGER; EXTERNAL;
PROCEDURE setlength(VAR x: S$0; y: INTEGER); EXTERNAL;
FUNCTION index(x,y: S$255): INTEGER; EXTERNAL;

PROCEDURE PAGE(VAR fx: TEXT);
BEGIN
  WRITE(fx, form_feed);
END;

PROCEDURE CLEAR{output};
VAR
  ix : 1..24;
BEGIN
  FOR ix:=1 TO 24 DO WRITELN;
END;



PROCEDURE BuildTree(VAR tree: treepointer);
VAR
  CurrentWord : alfa;
  Currentline: INTEGER;
  FOUT: TEXT; { local output file }


   PROCEDURE Entertree(VAR subtree: treepointer;
			   Word   : alfa;
			   line   :counter);
   VAR
     nextitem : Queuepointer;
   BEGIN
     IF subtree=nil THEN
       BEGIN {create a new entry}
	 NEW(subtree);
	 WITH subtree^ DO BEGIN
	   left := nil;
	   right := nil;
	   WITH entry DO BEGIN
	     Wordvalue := Word;
	     NEW(FirstInQueue);
	     LastinQueue := FirstInQueue;
	     WITH FirstInQueue^ DO BEGIN
		linenumber := line;
		NextInQueue := nil;
	     END;{WITH FirstInQueue}
	   END;{WITH entry}
	 END;{WITH subtree}
       END {create a new entry}
     ELSE {append a list item}
       WITH subtree^, entry DO
	 IF Word=Wordvalue THEN
	   BEGIN
	     IF lastinQueue^.linenumber <> line THEN
		BEGIN
		  NEW(nextitem);
		  WITH Nextitem^ DO BEGIN
		    linenumber := line;
		    NextInQueue := nil;
		  END;{WITH}
		  lastinQueue^.NextInQueue := Nextitem;
		  lastinQueue := nextitem;
		END;
	   END
	 ELSE
	   IF Word < Wordvalue THEN
	     Entertree(left,Word,line)
	   ELSE
	     Entertree(right,Word,line);
   END;{Entertree}

Procedure ReadC({updating} VAR nextchar : charinfo;
		{returning}VAR currchar : charinfo );
{ revised 4 Jan 80, rep }
{ Defined the chars "^", "$", and "_" as lowercase letters }
BEGIN	{+++ File status module. +++
   Stores file status "AFTER" a read.
   NOTE this play on words - after one char is
   actually "PRIOR TO" the next character		}
  xeoln := EOLN(FIN);
  xeof  := EOF(FIN);
	{+++ read BYTE module +++}
  IF NOT xeof THEN
        READ(FIN, Look);
	{+++ current operative character module +++}
  currchar := nextchar;
	{+++ Classify the character just read +++}
  WITH nextchar DO BEGIN{ Look-ahead character name module }
    IF xeof THEN
	name := FileMark
    ELSE IF xeoln THEN
	name := EndOfLine
    ELSE IF Look IN ['^', '$', '_', 'a'..'z'] THEN {lower case plus}
	name := lletter
    ELSE IF Look IN ['A'..'Z'] THEN {upper case}
	name := uletter
    ELSE IF Look IN ['0'..'9'] THEN {digit}
	name := digit
    ELSE IF Look = '''' THEN
	name := quote
    ELSE IF Look = TAB THEN
	name := atab
    ELSE IF Look = space THEN
	name := blank
    ELSE
	name := otherchar;
    CASE name of{ store character value module }
	EndOfLine,
	FileMark:	Valu := space;
	ELSE:		Valu := Look
    END{ case name of };
  End{ Look-ahead character name module };
END; {of ReadC}

PROCEDURE GetL( VAR fbuffer : dfltstr );
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+	Get a line of text into users buffer.		+}
{+	Flushes comment lines:				+}
{+	Flushes lines of Literals:  'this is it'	+}
{+	Ignores special characters & tabs:		+}
{+	Recognizes End of File and End of Line.		+}
{+							+}
{+GLOBAL						+}
{+	flushing : (KNOT, DBL, STD, LIT);		+}
{+	fbuffer = dfltstr				+}
{+	LLmax   = 0..Max Line length;			+}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
VAR
  state : (scanning, terminal, overflow);
BEGIN { GetL }
   setlength(fbuffer,0);
   fatal_error := FALSE;
   state := scanning;
  REPEAT
    ReadC(nextchar, currchar);
{}  WRITE(FOUT, currchar.valu);
{}  IF listing THEN
       WRITE( {OUTPUT,} currchar.valu);
    IF (length(fbuffer) >= LLmax) THEN{ exceeded length of buffer }
      BEGIN{ reset EOLN }
	fatal_error := TRUE;
	state := overflow;
	setlength(fbuffer,0);
	WRITE(bell);
	WRITELN('EXCEEDED LENGTH OF INPUT BUFFER');
      END
    ELSE
      BEGIN
	IF (currchar.name IN [FileMark,EndOfLine]) THEN
          state:=terminal{ END of line or END of file };
	CASE flushing of
	    KNOT:
		CASE currchar.name of
		lletter, uletter, digit, blank:
			BEGIN{ store }
			append(fbuffer,currchar.valu);
			END;
		atab, quote, otherchar:
			BEGIN{	 Flush comments	-convert
			         tabs & other chars to spaces }
			IF (currchar.valu='(') and (nextchar.valu='*')
			  THEN flushing := DBL
			ELSE IF (currchar.valu='{') THEN 
			   flushing := STD
			ELSE IF currchar.name=quote THEN
			   flushing := LIT;
			{ convert to a space }
			append(fbuffer,space);
			END;
		else:	{ END of line -or- file mark }
			append(fbuffer,currchar.valu)
		END{ case currchar name of };
	    DBL:  { scanning for a closing  - double comment }
		IF (currchar.valu ='*') and (nextchar.valu =')')
		  THEN flushing := KNOT;
	    STD:  { scanning for a closing curley  }
		  IF currchar.valu = '}' THEN
		      flushing := KNOT;
	    LIT:  { scanning for a closing quote }
		  IF currchar.name = quote THEN
		    flushing := KNOT
        END{ flushing case }
      END{ ELSE }
  UNTIL (state<>scanning);
END; {of GetL}

PROCEDURE ReadWord;
{++++++++++++++++++++++++++++++++++++++++++++++++}
{+						+}
{+	 Analyze the Line into "words"		+}
{+						+}
{++++++++++++++++++++++++++++++++++++++++++++++++}
LABEL	1;
CONST
  TOP = NumKeys	+ 1;
VAR
  ix,		{temp indexer}
  idlen,	{length of the word}
  Cpos : BYTE; { Current Position pointer }

BEGIN{ ReadWord }
  Cpos := 1; { start at the beginning of a line }
  WHILE Cpos < length(fbuffer) DO
    BEGIN {Cpos<length(fbuffer)}
      WHILE (Cpos < length(fbuffer)) AND (fbuffer[Cpos]=space) DO
	Cpos:=Cpos + 1;	   {--- skip spaces ---}

      idlen := 0;
      WHILE (Cpos < length(fbuffer)) AND (fbuffer[Cpos ] <> space) DO
	BEGIN{ accept only non-spaces }
	  IF idlen < MaxWordlen THEN
	    BEGIN
	      idlen := idlen + 1;
	      CurrentWord[idlen] := fbuffer[Cpos];
	    END;
	  Cpos := Cpos +1;
	END{ WHILE };
{}    IF idlen=0 THEN {no word was found} GOTO 1;

      IF idlen >= blankindex THEN
	blankindex := idlen
      ELSE
	REPEAT
	  CurrentWord[blankindex] := space;
	  blankindex := blankindex - 1;
	UNTIL blankindex=idlen;
      WordCount := WordCount + 1;
      {++++++++++++++++++++++++++++++++++}
      {+   linear search with sentinel	+}
      {++++++++++++++++++++++++++++++++++}
	  Key[TOP] := CurrentWord;
	  ix := 0;
	  REPEAT
	    ix := ix + 1;
	  UNTIL Key[ix] = CurrentWord;
      {++++++++++++++++++++++++++++++++++}
{}    IF ix=TOP THEN {CurrentWord is not a reserve word, so}
	 EnterTree(tree,CurrentWord,Currentline);
      1:{Here is no word <length of word=0>};
    END; {WHILE Cpos<length(fbuffer)}
END; {of Readword}

BEGIN{BuildTree}
{}REWRITE(PRN_ID, FOUT);
  PAGE(FOUT);
  Currentline := 0;
  nextchar.name := blank;	{ Initialize next char to a space }
  nextchar.valu := space;
  ReadC({update}    nextchar,	{ Initialize current char to space }
	{returning} currchar);	{ First char from file in nextchar }
  WHILE ((currchar.name<>filemark) AND (NOT fatal_error)) DO
    BEGIN
      Currentline := Currentline + 1;
      WRITE(FOUT, Currentline:6,': ');
      IF listing THEN WRITE({OUTPUT,} Currentline:6,': ');
      GetL(fbuffer) { attempt to read the first line };
      WRITELN(FOUT);
      IF listing THEN WRITELN{output};
      ReadWord; {Analyze the Text into single 'words' }
    END; {While}
  PAGE(FOUT);
END; {of BuildTree}{CLOSE(PRN_ID);}


PROCEDURE PrintTree(tree: treepointer);
{
GLOBAL
	MaxOnLine   = max line references per line
	NumberWidth = field for each number
}
VAR
  FOUT: TEXT; { local output file }
  pageposition: pageindex;

   PROCEDURE PrintEntry(subtree: treepointer;
			VAR position: pageindex);
   VAR	ix: Wordindex;
	itemcount : 0..Maxlinelen;
	itemptr : Queuepointer;

	PROCEDURE PrintLine(VAR Currentposition: pageindex;
			        newlines: pageindex);
	VAR
	  linecounter: pageindex;
	BEGIN
{}	  IF (Currentposition + newlines) < MaxOnPage THEN
	    BEGIN
{}		FOR linecounter:=1 TO newlines DO WRITELN(FOUT);
{}		IF listing THEN
		  FOR linecounter:=1 TO newlines DO WRITELN{OUTPUT};
		Currentposition := Currentposition + newlines;
	    END
	  ELSE
	    BEGIN
{}	      PAGE(FOUT);
{}	      WRITELN(FOUT,heading);
{}	      FOR linecounter := 1 TO headingsize - 1 DO
		 WRITELN(FOUT);
{}	      IF listing THEN
		BEGIN
		  CLEAR{OUTPUT}; {PAGE(OUTPUT);}
		  WRITELN({OUTPUT,} heading);
		  FOR linecounter := 1 TO headingsize - 1 DO
		     WRITELN{OUTPUT};
		END;
	      Currentposition := headingsize + 1;
	    END
	END;{PrintLine}

   BEGIN{PrintEntry}
     IF subtree<>nil THEN
	WITH subtree^ DO BEGIN
	  PrintEntry(left,position);
	  PrintLine(position,entrygap + 1);
	  WITH entry DO BEGIN
{}	    FOR ix:=1 TO MaxWordlen DO
	      WRITE(FOUT, WordValue[ix]);
{}	    IF listing THEN
	       FOR ix:=1 TO MaxWordlen DO
		  WRITE({OUTPUT,} WordValue[ix]);
	    itemcount := 0;
	    itemptr := FirstInQueue;
	    WHILE itemptr <> nil DO
	      BEGIN
		itemcount := itemcount + 1;
		IF itemcount > MaxOnLine THEN
		  BEGIN
		    PrintLine(position,1);
{}		    WRITE(FOUT, space:MaxWordlen);
{}		    IF listing THEN 
		       WRITE({OUTPUT,} space:MaxWordlen);
		    itemcount := 1;
		  END;
{}		WRITE(FOUT, itemptr^.linenumber: numberwidth);
{}		IF listing THEN
		   WRITE({OUTPUT,}itemptr^.linenumber: numberwidth);
		itemptr := itemptr^.NextInQueue;
	      END;{WHILE}
	  END; {WITH entry}
	  PrintEntry(right,position);
	END; {WITH subtree^}
   END; {PrintEntry}

BEGIN{PrintTree}
{}REWRITE(New_ID, FOUT);
  PAGE(FOUT);
  PagePosition := MaxOnPage;
  PrintEntry(tree,PagePosition);
  PAGE(FOUT);
END; {of PrintTree}{CLOSE(New_ID);}

(*$C+ [Control-C ON]*******************************)

FUNCTION ConnectFiles: boolean;
TYPE
  Linebuffer = string 80;
VAR
  ix,jx,
  Cmllen  : BYTE;
  Cmlline : Linebuffer;

	PROCEDURE GCML( VAR line : linebuffer;
			VAR len  : BYTE  );
	{++++++++++++++++++++++++++++++++++++++++++++++++}
	{+ READ the system command line.		+}
	{+ THIS MUST be the very first read in the	+}
	{+ entire program!				+}
	{++++++++++++++++++++++++++++++++++++++++++++++++}
	CONST	input = 0;	{ !!!!  PASCAL/Z   !!! }
	BEGIN
	  setlength(line,0);
	  len := 0;
	  IF NOT EOLN(input) THEN
	    BEGIN
	      READLN(line);
	      len := length(line);
	    END;
	END; {of GCML}

	PROCEDURE PAD(VAR this_ID: fid; required: BYTE);
	BEGIN
	  WHILE (length(this_ID)<required) DO
	    append(this_ID,space);
	END;

BEGIN{ ConnectFiles }
  fatal_error := FALSE;
  ConnectFiles := TRUE;
  GCML(Cmlline, Cmllen);
  IF (Cmllen=0) THEN { no file name from the console }
    BEGIN
      setlength(FILE_ID,0);
      WRITELN;
      WRITE('Enter <Drive:> FILE name - ');
      READLN(FILE_ID);
    END
  ELSE
      FILE_ID := Cmlline;
  IF (length(FILE_ID)>fid_len) THEN
        setlength(FILE_ID,fid_len);
  PAD(FILE_ID, fid_len);
  RESET(FILE_ID, FIN);
  IF EOF(FIN) THEN{ ABORT }
    BEGIN
      WRITE(bell);
      WRITELN('FILE NOT FOUND');
      fatal_error := TRUE;
      ConnectFiles := FALSE;
    END
  ELSE
    BEGIN
      ix := index(FILE_ID,'.'); { search for an extension }
      jx := index(FILE_ID,' '); { search for the first space }
      IF (ix=0) THEN{ no extension was specified }
        setlength(FILE_ID,jx-1)
      ELSE
        setlength(FILE_ID,ix-1);

    setlength(New_ID,0);	{ New_ID := CONCAT(FILE_ID, '.XRF'); }
    append(New_ID, FILE_ID);
    append(New_ID, '.XRF');
    PAD(New_ID, fid_len);

    setlength(PRN_ID,0);	{ PRN_ID := CONCAT(FILE_ID, '.PRN'); }
    append(PRN_ID, FILE_ID);
    append(PRN_ID, '.PRN');
    PAD(PRN_ID, fid_len);

    END;
END{ of ConnectFiles };

(*$C- [control-c OFF]***********************************)

PROCEDURE Initialize;
VAR
  Ch: CHAR;
  con_wanted,
  tty_wanted : BOOLEAN;
BEGIN
  bell := CHR(7);
  IF ConnectFiles THEN
    BEGIN
      letters := ['A'..'Z','a'..'z'];
	Key[ 1] := 'AND     ';
	Key[ 2] := 'ARRAY   ';
	Key[ 3] := 'BEGIN   ';
	Key[ 4] := 'BOOLEAN '; {+++ NOT A RESERVE WORD +++}
	Key[ 5] := 'CASE    ';
	Key[ 6] := 'CHAR    '; {+++ NOT A RESERVE WORD +++}
	Key[ 7] := 'CONST   ';
	Key[ 8] := 'DIV     ';
	Key[ 9] := 'DOWNTO  ';
	Key[10] := 'DO      ';
	Key[11] := 'ELSE    ';
	Key[12] := 'END     ';
	Key[13] := 'EXIT    ';	{+++ NOT a Pascal reserve word +++}
	Key[14] := 'FILE    ';
	Key[15] := 'FOR     ';
	Key[16] := 'FUNCTION';
	Key[17] := 'GOTO    ';
	Key[18] := 'IF      ';
	Key[19] := 'IN      ';
	Key[20] := 'INPUT   '; {+++ NOT A RESERVE WORD +++}
	Key[21] := 'INTEGER '; {+++ NOT A RESERVE WORD +++}
	Key[22] := 'LABEL   ';
	Key[23] := 'MOD     ';
	Key[24] := 'NIL     ';
	Key[25] := 'NOT     ';
	Key[26] := 'OF      ';
	Key[27] := 'OR      ';
	Key[28] := 'OUTPUT  '; {+++ NOT A RESERVE WORD +++}
	Key[29] := 'PACKED  ';
	Key[30] := 'PROCEDUR';
	Key[31] := 'PROGRAM ';
	Key[32] := 'REAL    '; {+++ NOT A RESERVE WORD +++}
	Key[33] := 'RECORD  ';
	Key[34] := 'REPEAT  ';
	Key[35] := 'SET     ';
	Key[36] := 'STRING  ';	{+++ NOT a Pascal reserve word +++}
	Key[37] := 'TEXT    '; {+++ NOT A RESERVE WORD +++}
	Key[38] := 'THEN    ';
	Key[39] := 'TO      ';
	Key[40] := 'TYPE    ';
	Key[41] := 'UNTIL   ';
	Key[42] := 'VAR     ';
	Key[43] := 'WHILE   ';
	Key[44] := 'WITH    ';
	Key[45] := 'WRITE   '; {+++ NOT A RESERVE WORD +++}
	Key[46] := 'WRITELN '; {+++ NOT A RESERVE WORD +++}

	blankindex := alfa_length;
	tab	:= CHR(9);  { ASCII Tab character }
	form_feed := CHR(12);
	flushing := KNOT{ flushing };
	WRITELN;
	WRITELN('Output Device:');
	WRITE(  '  CONSOLE ->');
	READLN(Ch);
	con_wanted := ( (Ch='Y') OR (Ch='y') );
	WRITE(  '  PRINTER ->');
	READLN(Ch);
	tty_wanted := ( (Ch='Y') OR (Ch='y') );
	If tty_wanted THEN
	   con_wanted := FALSE;
	IF NOT (con_wanted OR tty_wanted) THEN
	  LISTING := FALSE
	ELSE
	  BEGIN
	    LISTING := TRUE;
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	    IF con_wanted THEN REWRITE('CON:', OUTPUT);
	    IF tty_wanted THEN REWRITE('LST:', OUTPUT);
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
	  END;
	WRITELN;
    END; {IF ConnectFiles}
END; {of Initialize}

BEGIN { Cross Reference }
  CLEAR{output};
  WRITELN(' ':22, 'CROSS REFERENCE GENERATOR');
  WRITELN;WRITELN;WRITELN;WRITELN;
  Initialize;
  IF NOT fatal_error THEN
    BEGIN
      WordTree := NIL;		{Make the Tree empty}
      BuildTree(WordTree);
      PrintTree(WordTree);
    END;
{}WRITELN;
END. { Cross Reference }
