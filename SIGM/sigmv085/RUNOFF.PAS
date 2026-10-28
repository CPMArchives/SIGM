{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+								+}
{+ PROGRAM TITLE: 		RUNOFF ROUTINE			+}
{+								+}
{+								+}
{+ SUMMARY:							+}
{+    Complete instructions are found in file RUNOFF.DOC	+}
{+								+}
{+  VERSION RECORD						+}
{+    04/22/82  - added single sheet, continuous sheet, pause,  +}
{+                and message commands. R.E. Penley    		+}
{+    04/21/82  - added .OUT command. R.E. Penley		+}
{+    04/17/82  - first complete run under Pascal/Z with no	+}
{+		  errors. R.E. Penley				+}
{+    02/19/82	- First attempt at modification for operation   +}
{+		  under CP/M operating system. R.E. Penley	+}
{+    01/01/79  - TRW KERNAL OPERATING SYSTEM VERS 1A		+}
{+		  MULTIPLE MINICOMPUTER ARCHITECTURE		+}
{+		  IR&D PROJECT. Michelle Feraud			+}
{+								+}
{+ PROGRAMMERS NOTES:						+}
{+ -Pascal/Z compiler v 4.0 by Ithaca Intersystems.		+}
{+ -The program tries to use as much in line code as possible.  +}
{+  This makes the program much faster since we cut down on	+}
{+  calls to procedures/functions and the extra code associated +}
{+  with procedure calls.					+}
{+ -Under Pascal/Z the following was observed:			+}
{+  case 1 - conversion of a chr() takes 6 bytes of code.	+}
{+    const							+}
{+	nl = 10;						+}
{+    begin							+}
{+      c := chr(nl);						+}
{+  case 2 - conversion of a variable takes 7 bytes of code.	+}
{+    var newline: char;					+}
{+    begin							+}
{+      newline := chr(10);					+}
{+      c := newline;						+}
{+								+}
{+ -If any changes are made to the source program the		+}
{+  following steps will recompile RUNOFF.PAS (assume dr A:).	+}
{+	pascal runoff						+}
{+	asmbl main,runoff.aa/rel				+}
{+	era runoff.src						+}
{+	link /n:runoff runoff/v asl/s /e			+}
{+	era runoff.rel						+}
{+								+}
{+  required files are:						+}
{+	 asl.rel, runoff.pas, runinit.p,			+}
{+	 runcomm.p, stdopen.p, open.p				+}
{+								+}
{+ NICE TO HAVE:						+}
{+ 1. chaining to other text files				+}
{+ 2. ability to read text/data from another file.		+}
{+ 3. read/get inputs from console/disk files.			+}
{+ 4. top and bottom margin settings.				+}
{+ 5. Indent command.						+}
{+								+}
{+ BUGS:							+}
{+ 1. Program does not seem to like blank lines in text files.	+}
{+								+}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
PROGRAM RUNOFF;

CONST
  DfltLeftMrgn     =  0;	{ default left margin  }
  DfltRightMrgn    = 60;	{    "    right margin }
  DfltLineSpacing  =  1;	{    "    line spacing }
  DfltIndent	   =  5;	{    "    indent       }
  DftlTestPage	   =  0;	{    "    test page    }
  DfltPageSize	   = 60;	{    "    page size    }

  ZR		= 0;		{ ASCII NULL }
  NL		= 10;		{ ASCII Line feed CODE / New line }
  FF		= 12;		{ ASCII FORM feed CODE }
  CR		= 13;		{ ASCII carriage return CODE }
  SPACE		= ' ';
  NmbrArgs	= 8;		{ MAX # OF NUMERICAL ARGUMENTS << 04/21/82 >>}

  LineLength	= 132;		{ Max length of a single "line" }
  MaxBuffer	= 128 * 8;	{ use 1K buffers. }	{<<< 04.26.82 >>>}

  IDLENGTH	= 12;
  CmdSize	= 4;
  anull		= -maxint;

TYPE
  ARGARRAY	= ARRAY [0..NmbrArgs] OF INTEGER;
  cstring	= PACKED ARRAY [1..4] OF CHAR;
  IDENTIFIER	= PACKED ARRAY [1..IDLENGTH] OF CHAR;
  Line		= PACKED ARRAY [1..MaxBuffer] OF CHAR;	{<<< 04.26.82 >>>}
  LISTRECORD	= RECORD
		    NUMBER,
		    SPACING,
		    OFFSET : INTEGER
	          END;

  {++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
  {+ NOTE: commands MUST be inserted here in order of most frequent +}
  {+       usage.  Only by trial and error can the correct/most     +}
  {+       correct sequence be found.				    +}
  {++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

  CmdType = (	FIRST,
		CmdJustify,			{ MOST USED COMMAND FIRST }
		CmdNoFill,
		CmdParaGraph,
		CmdFill,
		CmdRem,		{Remarks lines added <<< 04.16.82 >>>}
		CmdLeftMrgn,
		CmdHeadLevel,
		CmdNoJustify,
		CmdBreak,
		CmdSkip,
		CmdBlank,
		CmdPage,
		CmdCenter,
		CmdSpacing,
		CmdTitle,
		CmdNumber,
		CmdHeader,
		CmdNoHeader,
		CmdMessage,	{Show message on console device < 04.22.82 >}
		CmdLeftJustify,	{Left Justify CMD added     <<< 04.18.82 >>>}
		CmdSingle,	{Single sheet paper         <<< 04.22.82 >>>}
		CmdCont,	{Continuous sheet paper     <<< 04.22.82 >>>}
		CmdPause,	{Pause await console input  <<< 04.22.82 >>>}
		CmdPageSize,
		CmdTestPage,
		CmdOut,		{Output direct commands to printer }
		CmdRightMrgn,
		CmdTempIndent,	{ Temporary indent command }
		CmdPeriod,
		CmdNoPeriod,
		CmdNoNumber,
		CmdList,
		CmdListEntry,
		CmdEndList,
		Invalid,	{Sentinal in CommandTable <<< 04.16.82 >>>}
		Cmdp1c,
		Cmdp2c,
		Cmdp3c,
		Cmdpgs1c,
		Cmdpgs2c );

VAR
  Cmdchar	: CHAR;		{ character defining the start of a command }
  CCmd		: CmdType;

  INBUF		: Line;		{ input line buffer }
  ipos		: integer;	{ position of cursor in input line }

  OUTBUF	: Line;		{ output line buffer }
  opos		: integer;	{ position of cursor in output line }

  CommandTable	: ARRAY [FIRST..Invalid] OF cstring;

  Line_count,
  PAGE_count,
  Line_SPACING,
  PARA_SPACING,
  PARA_INDENT,
  PARA_TESTPAGE,
  PAGE_SIZE,
  PAGE_CENTER,
  LEFT_MARGIN,
  RIGHT_MARGIN	: INTEGER;

  { FORMATTING FLAGS }
  Headerflag,
  Numberflag,
  Periodflag,
  Single_sheet,				{<<< 04.22.82 >>>}
  Fillflag,
  Justifyflag	: BOOLEAN;

  { PARAMETER INITIALIZATION PHASE }
  Setup 	: BOOLEAN;
  INITPARAMCommandS : SET OF CmdType;

  { HEAD LEVEL DECLARATONS }
  OLDHeadLevel : integer;
  Level        : ARRAY [1..5] OF INTEGER;

  { LIST AND BULLET DECLARATIONS }
  LISTLevel : integer;
  LISTPARAM : ARRAY [1..5] OF LISTRECORD;

  { FILL AND JUSTIFY DECLARATIONS }
  wrdbuffull,
  STARTOFLine,
  EndOfFile,
  EndOfSENTENCE : BOOLEAN;
  inval,			{ indent value }
  tival,			{ temp indent value }
  ceval,			{ # of lines to center <<< 04.22.82 >>>}
  SPACES,
  WORDLENGTH,
  outwds,
  DIRECTION	: integer;

  CURRENT_TITLE : Line;

  SENTENCE_ENDERS,
  DIGITS	: SET OF CHAR;

  STDIN,			{ standard input file }
  STDOUT	: TEXT;		{ standard output file }


	{++++++++++++++++++++++++++++++++++++++++++}
	{+ COMPILER OPTIONS FOR PASCAL/Z COMPILER +}
	{++++++++++++++++++++++++++++++++++++++++++}

{$C-}{ control-c checking OFF 		}
{$F-}{ floating point error checking OFF }
{$M-}{ integer mult & divd error checking OFF }


	{************************************}
	{*     GENERAL UTILITY ROUTINES     *}
	{************************************}

function toupper ( ch: char ): char;
	external;

function max ( x,y: integer ): integer;
begin
  if x>y then max := x
	 else max := y
end;

function min ( x,y: integer ): integer;
begin
  if x<y then min := x
	 else min := y
end;

	{*****************************************}
	{*   PROGRAM SPECIFIC UTILITY ROUTINES   *}
	{*****************************************}

function EndOfLine ( var buf: line ): boolean;
begin
  EndOfLine := (buf[ipos]=chr(nl));
end;


PROCEDURE print ( var TEXT: Line );
{ Prints the string TEXT to the console device }
{ last modified 04/14/82 rep }
VAR	I: integer;
	ch : char;
BEGIN
  i := 1;
  ch := text[i];
  while not ( (ch=chr(nl)) OR (ch=CHR(ZR)) )
    do begin
         write ( ch );
	 i := i + 1;
	 ch := text[i];
       end;
   writeln;
END{print};


PROCEDURE HELP;
BEGIN
  writeln;
  writeln('TRY AGAIN:');
  writeln('  RUNOFF INPUTFILE OUTPUTFILE <output to disk file>' );
  writeln('  RUNOFF INPUTFILE            <output to list device>');
  writeln('  RUNOFF INPUTFILE LST:' );
  writeln('  RUNOFF INPUTFILE CON:       <output to console>' );
  writeln;
end{help};




	{***************************************}
	{*	  I/O BUFFER ROUTINES	       *}
	{***************************************}

PROCEDURE getc ( VAR ch: char );{$R-}(*** RANGE CHECKING OFF ***)
var	xeoln: boolean;
begin
  xeoln := eoln(stdin);
  EndOfFile := eof(stdin);
  if not EndOfFile then Read(stdin,ch);
  if xeoln or EndOfFile then
     ch := CHR(NL);
end{ getc };			{$R+}(*** RANGE CHECKING ON ***)


PROCEDURE getline;
(************************************************)
(* GET ONE LINE FROM SOURCE FILE INTO INBUF	*)
(* GLOBAL:					*)
(*	NL, EndOfFile, MaxBuffer 		*)
(************************************************)
var	ch: char;
	ix: integer;
BEGIN				{$R-}
  ix := 0;
  repeat
    ix := ix + 1;
    getc(ch);
    if ORD(ch) > 127 then ch := CHR( ORD(ch)-128 );
    INBUF[ix] := ch;
  until (ch=CHR(NL)) or (EndOfFile) or (ix=MaxBuffer);
  { set cursor position to beginning of input buffer less one }
  ipos := 0;
end{ getline };			{$R+}


PROCEDURE putc ( C: CHAR );
{ WRITE ONE CHAR TO OUTPUT FILE }
begin
  if ( c = CHR(NL) ) then
	writeln(stdout)
  else
	write(stdout,c);	{output the character}
end{ putc };


PROCEDURE putline { var outbuf: line };
{
  Put current output line to output file.  Line is
  expected to have appropriate end-of-line character
  when received.  Also, keeps track of line count
  AND StartOfLine flag (for fill routines).
}
VAR	I: integer;
BEGIN
  IF ( opos > LEFT_MARGIN ) THEN BEGIN
    FOR I:=1 TO opos
       DO putc ( OUTBUF[I] );
    opos := LEFT_MARGIN;
    FOR I:=1 TO opos
       DO OUTBUF[I] := SPACE;
    STARTOFLine := TRUE;
    Line_count := Line_count + 1;
  END;
END{putline};


function value { var INBUF: line; var ipos: integer }: INTEGER;
{ RETURNS					}
{	Integer value of source string 'INBUF'  }
{	starting at position "ipos"		}
const	zero = 48; { ordinal value of '0' }
VAR	sign : -1..1;
	NUM  : INTEGER;
BEGIN
  IF INBUF[ipos] = '-' THEN BEGIN
    sign := -1;
    ipos := ipos + 1
  END
  ELSE BEGIN
    sign := 1;
    IF INBUF[ipos] = '+' THEN ipos := ipos + 1
  END;
  NUM := 0;
  REPEAT
    NUM := 10 * NUM + ord(INBUF[ipos]) - zero;
    ipos := ipos + 1
  UNTIL NOT ( INBUF[ipos] IN DIGITS );
  VALUE := NUM * SIGN
END{VALUE};


	{++++++++++++++++++++++++++++++++++++++++++++++++}
	{+	CHECK BOUNDS AND/OR SET PARAMETERS	+}
	{++++++++++++++++++++++++++++++++++++++++++++++++}

PROCEDURE Check_Set ( argtype: CmdType;	{ command argument }
		        var val: INTEGER );	{ value to check/set }
VAR	I: INTEGER;
BEGIN				{$R-}
  CASE argtype OF

    CmdSkip, CmdBlank: { CHECK SKIP & BLANK ARGUMENT }
	val := max ( val,1 ); { always space at least 1 line }

    CmdTempIndent :	 { CHECK INDENT ARGUMENT }
	IF ( (LEFT_MARGIN+val) < 0 ) THEN
	  val := LEFT_MARGIN
	ELSE IF ( (LEFT_MARGIN+val) > (RIGHT_MARGIN-1) ) THEN
	  val := 0;

    Cmdp1c : { IF NOT NULL RESET PARAGRAPH INDENT }
	IF ( val <> anull ) THEN
	  IF ( (LEFT_MARGIN+val) < 0 ) OR
	     ( (LEFT_MARGIN+val) > (RIGHT_MARGIN-1) ) THEN
		PARA_INDENT := DfltIndent
	  ELSE
		PARA_INDENT := val;

    Cmdp2c : { IF NOT NULL RESET PARAGRAPH VERTICAL SPACING }
	IF ( val <> anull ) THEN
	  IF ( val < 0 ) THEN
	    PARA_SPACING := (Line_SPACING+1) DIV 2
	  ELSE
	    PARA_SPACING := val;

    Cmdp3c : { IF NOT NULL RESET PARAGRAPH TEST PAGE ARGUMENT }
	IF ( val <> anull ) THEN
	  IF ( val < 0 ) THEN
	    PARA_TESTPAGE := DftlTestPage
	  ELSE
	    PARA_TESTPAGE := val;

    CmdCenter	: { Compute value for page center }
	begin
	  ceval := max ( val,1 ); { always center 1 line }
	  page_center := ( ( right_margin-left_margin ) DIV 2 ) + left_margin;
	end;

    CmdTestPage : { CHECK TESTPAGE ARGUMENT }
	IF NOT ( (val <> anull) AND (val >= 0) ) THEN val := 0;

    CmdHeadLevel : { CHECK HeadLevel ARGUMENT }
	begin
	  val := max ( val,1 ); { set floor to larger of val or 1 }
	  val := min ( val,5 ); { set ceiling to smaller of val or 5 }
	end;

    CmdList : { CHECK LIST ARGUMENTS }
	IF ( val < 0 ) THEN val := DfltLineSpacing

    CmdLeftMrgn : { RESET LEFT MARGIN & BLANK OUTBUF UP TO LEFT MARGIN }
	BEGIN
	  IF ( val < 0 ) OR ( val >= RIGHT_MARGIN ) THEN
		LEFT_MARGIN := DfltLeftMrgn
	  ELSE
		LEFT_MARGIN := val;
	  FOR I:=1 TO LEFT_MARGIN
	    DO OUTBUF[I] := SPACE;
	  opos := LEFT_MARGIN;
	END;

    CmdRightMrgn : { RESET RIGHT MARGIN. No further than LineLength }
	IF ( val > (LineLength-1) ) OR ( val < LEFT_MARGIN ) THEN
	  RIGHT_MARGIN := DfltRightMrgn
	ELSE
	  RIGHT_MARGIN := val;

   CmdSpacing : { RESET Line SPACING AND PARAGRAPH SPACING }
	begin
	  IF ( val < 1 ) OR ( val > 5 ) THEN
		Line_SPACING := DfltLineSpacing
	  ELSE
		Line_SPACING := val;
	  PARA_SPACING := (Line_SPACING+1) DIV 2;
	end;

    Cmdpgs1c: { RESET PAGE SIZE }
	IF ( val < 11 ) THEN
		PAGE_SIZE := DfltPageSize
	ELSE
		PAGE_SIZE := val;

    Cmdpgs2c : { IF NOT NULL RESET RIGHT MARGIN }
	IF ( val <> anull ) THEN
	  IF ( val > (LineLength-1) ) OR ( val < LEFT_MARGIN ) THEN
		RIGHT_MARGIN := DfltRightMrgn
	  ELSE
		RIGHT_MARGIN := val;

    CmdNumber : { IF NOT NULL RESET PAGE count }
	IF ( val <> anull ) THEN
	  IF ( val > 0 ) THEN
		PAGE_count := val - 1
	  ELSE
		PAGE_count := 0
  END{CASE};
END{Check_Set};		{R+}


PROCEDURE SETTITLE ( argstring : Line );
{ REPLACE CURRENT TITLE WITH Command STRING ARGUMENT }
VAR	CTP, STP: integer;
BEGIN
  FOR CTP:=1 TO RIGHT_MARGIN
     DO CURRENT_TITLE[CTP] := SPACE;
  CTP := LEFT_MARGIN + 1;
  STP := 1;
  WHILE ( argstring[STP] <> CHR(ZR) ) AND ( CTP<=RIGHT_MARGIN )
     DO BEGIN
	  CURRENT_TITLE[CTP] := argstring[STP];
	  CTP := CTP + 1;
	  STP := STP + 1
        END
END{SETTITLE};


FUNCTION ATTOPOFPAGE: BOOLEAN;
{ IS CURRENT OutPutLine THE FIRST Line OF TEXT AFTER THE PAGE Head? }
BEGIN
  ATTOPOFPAGE := ( Line_count=5 )
END;


FUNCTION TEST_PAGE ( argc: INTEGER ): BOOLEAN;
{ ARE THERE argc lines LEFT ON THE CURRENT PAGE? }
BEGIN
  TEST_PAGE := ( (PAGE_SIZE-Line_count) >= argc )
END;


PROCEDURE SKIPLines ( N: INTEGER );
{ INSERT N BLANK Lines INTO OUTPUT FILE }
VAR	I: integer;
BEGIN		{$R-}
  IF ( N>0 ) THEN
    FOR I:=1 TO N DO BEGIN
      putc(CHR(NL));
      Line_count := Line_count + 1
    END
END{SKIPLines};	{$R+}


PROCEDURE PUTPAGEHead;
{ PUT CURRENT TITLE AND PAGE NUMBER INTO OUTPUT Line AND PRINT }
VAR	PAGE_NUMBER: INTEGER;
BEGIN		{$R-}
  OUTBUF := CURRENT_TITLE;
  IF ( NUMBERflag ) THEN BEGIN { TRANSLATE AND OUTPUT PAGE NUMBER }
    opos := RIGHT_MARGIN;
    PAGE_NUMBER := PAGE_count;
    REPEAT
	OUTBUF[opos] := CHR((PAGE_NUMBER MOD 10)+48);
	opos := opos - 1;
	PAGE_NUMBER := PAGE_NUMBER DIV 10
    UNTIL ( PAGE_NUMBER=0 );
  END;

  OUTBUF[opos-4] := 'P';
  OUTBUF[opos-3] := 'A';
  OUTBUF[opos-2] := 'G';
  OUTBUF[opos-1] := 'E';
  OUTBUF[opos  ] := ' ';
  opos := RIGHT_MARGIN + 1;
  OUTBUF[opos] := CHR(NL);
  putline
END{PUTPAGEHead};	{$R+}


PROCEDURE NEWPAGE;
{ GO TO TOP OF NEW PAGE AND PRINT PAGE Head }
var	dummy: char;
BEGIN			{$R-}
  putc ( CHR(FF) );	{*** assumes printer recognizes formfeed char ***}
  PAGE_count := PAGE_count + 1;
  Line_count := 0;

  if single_sheet then begin {pause for operator intervention  << 04.22.82 >>}
	writeln;
	write ( 'Insert new page. Press return to continue. ' );
	readln ( dummy );
  end;

  IF Headerflag THEN BEGIN { PRINTED PAGE Head }
     SKIPLines(1);
     PUTPAGEHead;
     SKIPLines(3)
  END
  ELSE { BLANK PAGE Head }
    SKIPLines(5)
END{NEWPAGE};		{$R+}


PROCEDURE MOVE_opos ( mvarg: INTEGER );
{ MOVE OUTPUT Line Cursor position FORWARD OR BACKWARD. A      }
{ FORWARD MOVE BLANKS THE Line UP TO THE NEW POSITION OF opos. }
VAR	I: integer;
BEGIN
  IF ( mvarg > 0 ) THEN BEGIN
	opos := opos + 1;
	FOR i:=opos TO (opos+mvarg-1)
	  DO OUTBUF[i] := SPACE;
	opos := opos + mvarg - 1
  END
  ELSE IF ( mvarg < 0 ) THEN
	opos := opos + mvarg
END{MOVE_opos};


PROCEDURE PUTHeadLevel ( NEWHeadLevel: INTEGER; HeadSTRING: Line );
{ PUT Head Level NUMBER AND Head Level TITLE INTO OUTPUT Line }
VAR	chars,
	k, I,
	HSP	: integer;
	LevelsOut,
	LevelNUM,
	NUMBER	: INTEGER;
BEGIN			{$R-}
  IF ( NEWHeadLevel<OLDHeadLevel ) THEN { ZERO UNNEEDED Head Level NUMBERS }
     FOR i:=(NEWHeadLevel+1) TO OLDHeadLevel
	DO Level[i] := 0;
  Level[NEWHeadLevel] := Level[NEWHeadLevel] + 1;
  IF ( NEWHeadLevel=1 ) THEN (* WILL PRINT FIRST 2 Head Level NUMBERS *)
     LevelsOut := 2
  ELSE (* WILL PRINT SPECIFIED Head Level NUMBERS *)
     LevelsOut := NEWHeadLevel;
  FOR LevelNUM:=1 TO LevelsOut
    DO BEGIN { PRINT Head Level NUMBERS }
	 IF ( LevelNUM <> 1 ) THEN
	    OUTBUF[opos] := '.';
	 NUMBER := Level[LevelNUM];
	  k := number;
	  CHARS := 1;
	  WHILE ( k>9 )
	    DO BEGIN
		 k := k DIV 10;
		 CHARS := CHARS + 1
	       END;
	 FOR I:=(opos+CHARS) DOWNTO (opos+1)
	   DO BEGIN
		OUTBUF[I] := CHR( (NUMBER MOD 10)+48 );
		NUMBER := NUMBER DIV 10
	      END;
	 opos := opos + CHARS + 1
       END;
  OLDHeadLevel := NEWHeadLevel;
  IF ( HeadSTRING[1] <> CHR(ZR) ) THEN BEGIN { PRINT Head Level TITLE }
    OUTBUF[opos] := SPACE;
    OUTBUF[opos+1] := SPACE;
    opos := opos + 2;
    HSP := 1;
    WHILE ( HeadSTRING[HSP] <> CHR(ZR) ) AND ( opos<=RIGHT_MARGIN )
       DO BEGIN
	     OUTBUF[opos] := HeadSTRING[HSP];
	     opos := opos + 1;
	     HSP := HSP + 1
	  END;
  END;
  OUTBUF[opos] := CHR(NL);
  putline;
END{PUTHeadLevel};	{$R+}


PROCEDURE STARTLIST ( VAR N: INTEGER );
{ INITIALIZE THIS Level OF LIST }
VAR	NEWLEFTMARGIN: INTEGER;
BEGIN
  LISTLevel := LISTLevel + 1;
  WITH LISTPARAM[LISTLevel]
     DO BEGIN
	  NUMBER := 0;
	  SPACING := N;
	  NEWLEFTMARGIN := LEFT_MARGIN + OFFSET;
	  Check_Set ( CmdLeftMrgn, NEWLEFTMARGIN );
	END
END{STARTLIST};


PROCEDURE PUTLISTNUMBER ( LISTTYPE: CmdType );
{ TRANSLATE LIST ELEMENT NUMBER INTO CHARACTERS }
VAR	NUMBER: INTEGER;
BEGIN
  OUTBUF[LEFT_MARGIN-2] := '.';
  OUTBUF[LEFT_MARGIN-1] := ' ';
  OUTBUF[LEFT_MARGIN  ] := ' ';
  NUMBER := LISTPARAM[LISTLevel].NUMBER;
  opos := LEFT_MARGIN - 3;
  REPEAT
    OUTBUF[opos] := CHR( (NUMBER MOD 10)+48 );
    NUMBER := NUMBER DIV 10;
    opos := opos - 1;
  UNTIL NUMBER=0;
  opos := LEFT_MARGIN;
END{PUTLISTNUMBER};


PROCEDURE LISTMEMBER ( LISTTYPE: CMDTYPE );
{ SPACE DOWN AND NUMBER A LIST ENTRY }
BEGIN
  WITH LISTPARAM[LISTLevel]
     DO BEGIN
	  IF TEST_PAGE ( SPACING+1 ) THEN
	    SKIPLINES ( SPACING )
	  ELSE
	    NEWPAGE;
	  NUMBER := NUMBER + 1;
	END;
  PUTLISTNUMBER ( LISTTYPE );
END{LISTMEMBER};


PROCEDURE STOPLIST;
{ TERMINATE THIS Level OF LIST AND RESET TO PRIOR Level }
VAR	NEWLEFTMARGIN: INTEGER;
BEGIN
  WITH LISTPARAM[LISTLevel] DO BEGIN
    IF TEST_PAGE ( SPACING+1 ) THEN
	SKIPLines ( SPACING )
    ELSE
	NEWPAGE;
    NEWLEFTMARGIN := LEFT_MARGIN - OFFSET;
    Check_Set ( CmdLeftMrgn, NEWLEFTMARGIN )
  END;
  LISTLevel := LISTLevel - 1
END{STOPLIST};


PROCEDURE BREAK;
BEGIN
  putline;
  IF TEST_PAGE ( Line_SPACING ) THEN
    SKIPLines ( Line_SPACING-1 )
  ELSE
    NEWPAGE
END{BREAK};


	{************************************}
	{*     TEXT PROCESSING ROUTINES     *}
	{************************************}


PROCEDURE DoText ( var INBUF: Line );
{ FORMAT TEXT }
VAR
  wrdbuffer	: Line;


PROCEDURE PUTCENTERED;
{ CENTER TEXT FROM INPUT LINE }
VAR	i,
	width,			{ width of input text }
	fudge: integer;		{ computed center of input text }
BEGIN
  (*** width := length(INBUF); ***)
  repeat ipos := ipos + 1
  until EndOfLine ( INBUF );
  width := ipos - 1;

  (***	Compute center char of line to be centered ***)
  fudge := width DIV 2;
  if odd(width) then { pretty it up }
    fudge := fudge + 1;

  (*** Now compute how much to indent to get there ***)
  tival := (page_center - fudge) + 1; { have to add 1 to get off of zero base }

  (*** However don't go less than left margin ***)
  tival := max ( tival, (left_margin+1) );

  for i:=(left_margin+1) to (tival-1)
    do outbuf[i] := space;
  opos := tival;
  ipos := 1;
  WHILE ( not EndOfLine(INBUF) ) AND ( opos <= RIGHT_MARGIN )
     DO BEGIN { PUT CENTERED TEXT }
	  OUTBUF[opos] := INBUF[ipos];
	  opos := opos + 1;
	  ipos := ipos + 1
	END;
  OUTBUF[opos] := CHR(NL)
END{PUTCENTERED};


PROCEDURE GETWORD;
{ REMOVE A CONTIGUOUS GROUP OF CHARS FROM INPUT Line }
VAR	WBP: integer;
BEGIN
  REPEAT ipos := ipos + 1
  UNTIL INBUF[ipos] <> SPACE;
  IF NOT EndOfLine(INBUF) THEN BEGIN { GET WORD }
    wrdbuffull := FALSE;
    WBP := 1;
    WHILE NOT wrdbuffull
       DO begin
	    IF ( EndOfLine(INBUF) ) OR ( INBUF[ipos]=SPACE ) THEN BEGIN
		(* WORD HAS BEEN GOTTEN *)
		wrdbuffull := TRUE;
		WORDLENGTH := WBP - 1;
		EndOfSENTENCE := (wrdbuffer[WORDLENGTH] IN SENTENCE_ENDERS);
	    END{IF}
	    ELSE BEGIN
		wrdbuffer[WBP] := INBUF[ipos];
		WBP := WBP + 1;
		ipos := ipos + 1
	    END{ELSE}
	end{while}
  END{IF}
  ELSE BEGIN {AT END OF INPUT LINE AND NO WORD HAS BEEN GOTTEN} 
    wrdbuffull := FALSE;
    WORDLENGTH := 0;
  END;
END{GETWORD};


FUNCTION SpaceRemaining: BOOLEAN;
{ Is there enough room left in output line for current word? }
BEGIN
  SpaceRemaining := ( (SPACES+WORDLENGTH+opos-1) <= RIGHT_MARGIN )
END;


procedure justify ( var outbuf: line );
{ JUSTIFY OUTPUT LINE OUT TO RIGHT MARGIN.
{ ALGORITHM FROM "SOFTWARE TOOLS" BY K & F, PG 241. }
VAR	I, nextra,
	nmbrholes,
	LEFTSIDE,
	RIGHTSIDE,
	BLANKS	: INTEGER;
BEGIN			{$R-}
  { COMPUTE NUMBER OF BLANKS THAT WILL HAVE TO BE INSERTED }
  nextra := (RIGHT_MARGIN+1) - opos;
  IF (nextra>0) AND (outwds>1) THEN BEGIN
    { REVERSE PREVIOUS DIRECTION FOR INSERTING BLANKS }
    DIRECTION := 1 - DIRECTION;
    { COMPUTE # OF HOLES IN WHICH TO ADD BLANKS }
    nmbrholes := outwds - 1;
    LEFTSIDE := opos;
    RIGHTSIDE := RIGHT_MARGIN + 1;
    opos := RIGHTSIDE;
    WHILE ( LEFTSIDE < RIGHTSIDE )
      DO BEGIN { JUSTIFY TEXT }
	   OUTBUF[RIGHTSIDE] := OUTBUF[LEFTSIDE];
	   IF ( OUTBUF[LEFTSIDE]=' ' ) THEN BEGIN {END OF WORD}
	       IF NOT (PERIODflag AND (OUTBUF[LEFTSIDE-1] IN SENTENCE_ENDERS))
		 THEN BEGIN { COMPUTE # OF EXTRA BLANKS TO INSERT }
			IF DIRECTION=0 THEN
			    BLANKS := ((nextra-1) DIV nmbrholes) + 1
			ELSE
			    BLANKS := nextra DIV nmbrholes;
			nextra := nextra - BLANKS;
			nmbrholes := nmbrholes - 1;
			FOR I:=1 TO BLANKS
			  DO BEGIN { INSERT EXTRA BLANKS }
				RIGHTSIDE := RIGHTSIDE - 1;
				OUTBUF[RIGHTSIDE] := ' '
			     END;
		      END{IF}
	   END{IF};
	   LEFTSIDE := LEFTSIDE - 1;
	   RIGHTSIDE := RIGHTSIDE - 1
	 END{WHILE}
  END{IF}
END{justify};			{$R+}


PROCEDURE PUTWORD ( var wrdbuffer : line );
{  PUT CURRENT WORD INTO OUTPUT Line. KEEP  }
{  TRACK OF WORD count FOR JUSTIFY ROUTINE. }
VAR	I, WBP: integer;
BEGIN
  IF NOT STARTOFLine THEN BEGIN { SPACING BETWEEN WORDS }
    FOR I:=1 TO SPACES
       DO BEGIN
	    OUTBUF[opos] := SPACE;
	    opos := opos + 1
	  END{FOR}
  END
  ELSE BEGIN { THIS IS THE FIRST WORD ON THE Line }
    STARTOFLine := FALSE;
    outwds := 0;
    opos := opos + 1
  END;
  FOR WBP:=1 TO WORDLENGTH
     DO BEGIN { COPY WORD INTO OUTPUT Line }
	  OUTBUF[opos] := wrdbuffer[WBP];
	  opos := opos + 1
	END;
  OUTBUF[opos] := CHR(NL);
  outwds := outwds + 1
END{PUTWORD};


PROCEDURE Fill_Lines;
{ Fill AND JUSTIFY ONE OR MORE OUTPUT Lines FROM CURRENT INPUT Line }
VAR	LineFilled: BOOLEAN;


   PROCEDURE Fill_ONE_Line;
   { Fill OUTPUT Line FROM CURRENT INPUT Line }
   VAR	FINISHED: BOOLEAN;
   BEGIN
     IF NOT wrdbuffull THEN GETWORD;
     LineFilled := FALSE;
     FINISHED := FALSE;
     WHILE NOT FINISHED
       DO BEGIN
	    IF ( spaceremaining ) then begin
	      if ( WORDLENGTH <> 0 ) then begin
		{ CONTINUE FillING Line }
		PUTWORD ( wrdbuffer );
		IF EndOfSENTENCE THEN { SET SPACING BEFORE NEXT WORD }
		    SPACES := 2
		ELSE
		    SPACES := 1;
		IF NOT EndOfLine(INBUF) THEN
		    GETWORD
		ELSE BEGIN { NO MORE WORDS IN THIS INPUT Line }
		    FINISHED := TRUE;
		    wrdbuffull := FALSE;
		END{else}
	      end{if wordlength <> 0}
	    END{if spaceremaining}
	    ELSE BEGIN { Stop filling line }
		FINISHED := TRUE;
		LineFilled := Not SpaceRemaining;
	    END{Stop filling line}
	  END
   END{Fill ONE Line};

BEGIN {Fill_Lines}
  Fill_ONE_Line;
  WHILE ( LineFilled )
    DO BEGIN
	  IF JUSTIFYflag THEN justify ( OUTBUF );
	  BREAK;
	  Fill_ONE_Line;
       END
END{Fill_Lines};


PROCEDURE CopyAsIs;
{ COPY INPUT Line LITERALLY AS FOUND IN SOURCE FILE }
VAR	LineCOPIED: BOOLEAN;
BEGIN
  LineCOPIED := FALSE;
  WHILE NOT LineCOPIED DO BEGIN
    REPEAT
	opos := opos + 1;
	ipos := ipos + 1;
	OUTBUF[opos] := INBUF[ipos];
    UNTIL (opos=RIGHT_MARGIN) OR ( EndOfLine(INBUF) );
    IF EndOfLine(INBUF) THEN { INPUT Line HAS BEEN COPIED }
	LineCOPIED := TRUE
    ELSE BEGIN { INPUT Line MAY BE TOO LONG, REMAINDER GOES TO NEXT Line }
	IF INBUF[ipos+1]=CHR(NL) THEN {Line IS EXACTLY THE RIGHT SIZE}
	    LineCOPIED := TRUE;
	opos := opos + 1;
	OUTBUF[opos] := CHR(NL)
    END;
    BREAK;
  END
END{CopyAsIs};


BEGIN {DoText}
  if ceval>0 then begin
     PUTCENTERED;
     ceval := ceval - 1;
     BREAK
  END
  ELSE
     IF Fillflag THEN
	Fill_Lines
     ELSE
	CopyAsIs
END{DoText};


FUNCTION ScanCommand: CmdType;
{ REMOVE Command STRING FROM INPUT Line AND SEARCH
  Command Table FOR MATCHING Command TYPE	   }
VAR	CommandLine  : cstring;
	CmdIndex     : CmdType;
	hash,
	j,
	cpos	     : integer;
BEGIN			{$R-}
  FOR cpos:=1 TO (CmdSize-1)
    DO CommandLine[cpos] := SPACE;
  ipos := 2; { skip CmdChar }
  cpos := 1;
  WHILE ( INBUF[ipos] <> ' ' )
     AND ( not EndOfLine(INBUF) )
        AND ( cpos <= CmdSize )
     DO BEGIN { get Command string }
	  CommandLine[cpos] := toupper ( INBUF[ipos] );
	  ipos := ipos + 1;
	  cpos := cpos + 1
	END{WHILE};
  CommandLine[CmdSize] := CHR(ZR);

  { since the table is so short just do a sequential search. <<<04.15.82>>>}
  CmdIndex := FIRST;
  CommandTable[invalid] := CommandLine; { insert the sentinal }
  repeat CmdIndex := SUCC(CmdIndex);
  until CommandTable[CmdIndex]=CommandLine;
  ScanCommand := CmdIndex
END{ScanCommand};		{$R+}


{$iRUNCOMM.P }


{$iSTDOPEN.P }


{$iRUNINIT.P }


BEGIN	{*     MAIN PROGRAM	*}
  for ipos:=1 to 24 do writeln;
  WRITELN ( ' RUNOFF' );
  writeln ( ' CP/M Version 1.0 Created April 30, 1982' );
  OpenFiles;
  INITIALIZE{ all parameters now };

{$C+}{ allow program termination from this section }
  getline;
  Setup := TRUE;
  { PROCESS THOSE Commands THAT AFFECT THE VARIOUS PARAMETER & flag SETTINGS }
  WHILE NOT EndOfFile AND Setup
    DO BEGIN
	IF INBUF[1]=Cmdchar THEN BEGIN
	   CCmd := ScanCommand;
	   IF CCmd IN INITPARAMCommandS THEN BEGIN
	      DoCommand ( INBUF );
	      getline
	   END
	   ELSE { First non-init Command ends setup phase }
	      Setup := FALSE;
	END
	ELSE { First text line ends setup phase }
	   Setup := FALSE;
       END{WHILE};

  NEWPAGE; { TOP OF FIRST PAGE }
  WHILE NOT EndOfFile
     DO BEGIN { PROCEED WITH NORMAL SOURCE FILE PROCESSING }
	  IF INBUF[1]=Cmdchar THEN
	    DoCommand ( INBUF )
	  ELSE
	    DoText ( INBUF );
	  getline
	  {+++ test for break key press here +++}
	END{WHILE};

  putline;{ terminate }
  putc ( CHR(FF) );
  writeln ( 'End of job.' );
  writeln;writeln;
END{ RUNOFF }.
