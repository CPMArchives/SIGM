PROGRAM INSTALL;
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+ WRITTEN BY:		 Raymond E. Penley		+}
{+ DATE WRITTEN:	 September 19, 1981		+}
{+							+}
{+ SUMMARY:						+}
{+    Writes a data file 'TERMIO.FIL' that may be used	+}
{+  by a User Prgm for different terminal types without +}
{+  having to rewrite the source prgm.			+}
{+							+}
{+ NOTES:						+}
{+   The variable definitions for all the terminals	+}
{+  are not complete.  Please modify for your terminal	+}
{+  and send a copy of the changes to the Pascal/Z	+}
{+  Users' Group.  Thank you.                           +}
{+							+}
{+    writes()	       - write a sequence to console	+}
{+    puts()	       - write a sequence to disk file	+}
{+    gets()	       - read a sequence from disk file +}
{+    closes()	       - writes nulls to data file	+}
{+    concats()        - concatenates 2 short sequences +}
{+    clear_screen     -				+}
{+    gotoxy(xy)       - position to XY coordinates	+}
{+							+}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

CONST
  alphalen = 10;
  default = 80;

TYPE
  BYTE = 0..255;
  alpha = array [0..alphalen] of byte;
  BFILE = FILE OF BYTE;
  DSTRING = STRING DEFAULT;
  STRING34 = PACKED ARRAY [1..34] OF CHAR;
  STRING0 = STRING 0;
  STRING10 = STRING 10;
  STRING255 = STRING 255;

VAR
  bell	 : char;	{ ASCII value for terminal bell character }
  bx	 : byte;	{ global byte indexer }
  ESC	 : BYTE;	{ ASCII escape character }
  ix	 : integer;	{ global integer indexer }
  NULL	 : BYTE;	{ ASCII null character }
  selected : BOOLEAN;	{ a terminal has been selected flag }
  termio : BFILE;	{ terminal data file   }
  termtype : byte;
  VALID  : BOOLEAN;

	 { first 5 bytes for some misc terminal values }
   DELMIS,		{ delay after other functions. e.g. home up }
   DELCUS,		{ delay after direct addressing of cursor }
   X_OFF,		{ offset to add to column }
   Y_OFF,		{ offset to add to row }
   XY	     : BYTE;	{ flag for column/row or row/column addressing scheme }
	 { string sequences }
   CLRSCR,		{ CLEAR SCREEN }
   CUR, 		{ CURSOR ADDRESSING LEADIN STRING }
   eraeos,		{ CLEAR TO END OF SCREEN }
   eraeol,		{ CLEAR TO END OF LINE }
   HOME,		{ HOME UP CURSOR }
   LockKbd,		{ Lock KEYBOARD }
   UnlockKbd,		{ Unlock KEYBOARD }
   LINDEL,		{ delete screen line containing cursor }
   LININS,		{ insert a blank line on screen }
   INVON,		{ turn on highlighting - inverse video }
   INVOFF,		{ turn off highlighting }
   CRSON,		{ SET CURSOR ON AND BLINKING }
   CRSOFF : ALPHA;	{ SET CURSOR DISPLAY OFF }


function length(x:string255): integer;external;

procedure setlength(var x: string0; y: integer); external;

procedure keyin(var c: char); external;

function toupper(ch: char): char;
begin
  if  (('a'<=ch) and (ch<='z')) then
    toupper := chr(ord(ch)-32)
  else
    toupper := ch
end{ of toupper };


procedure writes( strng: alpha );
{ writes writes a string of type alpha to the console
  device. }
var	ix: byte;
begin
  for ix:=1 to strng[0] do
    write( chr(strng[ix]) )
end{ of writes };


procedure puts( var fb: BFILE; var strng: alpha );
{ procedure puts writes a string of type alpha
  to the specified file of type BFILE. }
var	ix: byte;
begin
  write( fb, strng[0]:1 );	  { length byte }
  for ix:=1 to strng[0] do
    write( fb, strng[ix]:1 )
end{ of puts };


procedure gets( var fb: BFILE; var strng: alpha );
{ procedure gets reads a string of type alpha from the
  specified file of type BFILE. }
var	ix: byte;
begin
  read( fb, strng[0] ); 	{ first byte is always length }
  for ix:=1 to strng[0] do
    read( fb, strng[ix] )
end{ of gets };


procedure closes( var fb: BFILE );
{ closes marks the end of file with 8 nulls }
var	ix: 1..8;
	null : byte;
begin
  null := 0;
  for ix:=1 to 8 do
     write( fb, null:1 )
end;


procedure concats( var first, second, new: alpha );
{ concatenates two short strings of type alpha into
  a third string "new".
  e.g.	   concats( INVON, REVERSE, RVON );
}
var	ix,k,k1: byte;
begin
  if ( first[0] + second[0] ) <= alphalen then begin
     k := first[0];	{ length(first) }
     k1 := second[0];	{ length(second) }
     for ix:=1 to k do new[ix] := first[ix];
     for ix:=1 to k1 do new[k+ix] := second[ix];
     new[0] := k + k1
  end
  else
     new[0] := 0
end{ of concats };



    {++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
    {+ THE FOLLOWING PROCEDURES ARE TO BE USED IN YOUR PROGRAMS +}
    {++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure Clear_Screen;
var	ix: byte;
begin
  writes( CLRSCR );
  for ix:=0 to DELMIS do {}
end;


Procedure gotoxy(x_coord, y_coord: integer);
var	ix, x_pos, y_pos: integer;
begin
  X_POS := x_coord + X_OFF;
  Y_POS := y_coord + Y_OFF;
  IF ( XY=2 ) AND ( X_POS<31 ) THEN X_POS := X_POS + 96;
  writes( CUR );
  IF ( XY=1 ) OR ( XY=2 ) THEN
    write( CHR(X_POS), CHR(Y_POS) )
  ELSE
    write( CHR(Y_POS), CHR(X_POS) );
  for ix:=0 TO DELCUS do {}
end;


PROCEDURE CVRT( alphanum   : dstring;  { input string to be parsed }
		var vector : alpha;    { returned values }
		var len    : integer;  { count of # of values returned }
		low_check,	       { low range }
		high_check : integer); { high range }
{ RETURNS len = -1 for any errors }
label 2;{quick exit}
var	error  : boolean;
	int    : integer; { integer number returned by IVAL }
	rng    : integer; { Range of alphanumeric string.   }
			  { required by IVAL		    }

{$iDELETE.LIB }

{$iIVAL.LIB }

BEGIN { parse alphanum, check for errors }
  error := false;
  len := 0;
  if length(alphanum)=0 then {EXIT} goto 2;
  Repeat
    rng := IVAL( alphanum, int );
    if ( rng>0 ) then begin { valid digit entered }
       if int<low_check then begin { valid integer but < low range }
	 writeln( bell, int, ' less than ', low_check:1, '. Reenter');
	 error := true
       end{if int<low_check}
       else if int>high_check then begin { valid integer but > high range }
	 writeln( bell, int, ' exceeds ', high_check:1, '. Reenter');
	 error := true
       end{if int>high_check}
       else begin { digits in range low_check..high_check }
	 len := len + 1;
	 vector[len] := int
       end{else};
       { compress input string until all gone }
       delete( alphanum, 1, rng-1 )
    end{ if rng > 0 };
    if ( rng<0 ) then begin { integer exceeds maxint }
      writeln( bell, ' overflow');
      error := true
    end
  Until ( rng<=0 ) or ( error );
  if error then len := -1;
2:{quick exit}
End{ of CVRT };


PROCEDURE CREATE;
VAR  ix       : byte;
     done     : boolean;
     len      : integer;
     t	      : alpha;
     answer   : dstring;

   PROCEDURE DO_strng( S: DSTRING; VAR strng: alpha );
   begin
     Repeat
       done := false;
       writeln; writeln;
       writeln('*** ', S, ' ***               Normally 2 or more bytes.');
       writeln;
       write(' ':12, 'Present Values               --->');
       if strng[0]>0 then
	 for ix:=1 to strng[0] do write( strng[ix]:4 );
       writeln;
       write(' ':12, 'Enter New Values or Return   ---> ');
       readln(answer);
       CVRT( answer, t, len, 0, 255 );
       if len=0 then done := true
       else if len>0 then begin
	  strng[0] := len;
	  for ix:=1 to len do strng[ix] := t[ix]
       end
       { else len<0 so error }
     Until ( done )
   END{ of Q };

   PROCEDURE DO_abyte( S: DSTRING; VAR abyte: byte );
   BEGIN
     Repeat
       done := false;
       writeln; writeln;
       writeln('*** ', S, ' ***               Normally 1 Byte.');
       writeln;
       writeln(' ':12, 'Present Value                --->', abyte:4 );
       write(  ' ':12, 'Enter New Value or Return    ---> ');
       readln(answer);
       CVRT( answer, t, len, 0, 255 );
       if len=0 then
	 done := true
       else if len>0 then
	 abyte := t[1]
       { else len<0 so error }
     Until ( done )
   END{ of P };


BEGIN{ CREATE }
  WRITELN; ; WRITELN;
  WRITELN('Enter Decimal Equiv. of Esc Sequence separated by CR');
  WRITELN;

  DO_strng('Clear Screen Code', CLRSCR);

  DO_abyte('Delay for Clear Screen', DELMIS );

  DO_abyte('Delay for Cursor Addr', DELCUS );

  DO_abyte('Column Offset', X_OFF );

  DO_abyte('Row Offset', Y_OFF );

  WRITELN(' ':18, 'Cursor Addressing Scheme');
  writeln; writeln;
  writeln('Direct cursor positioning e.g. Escape + "=" + Column + Row');

  DO_strng('Cursor Leadin String', CUR);
  writeln;writeln;
  writeln('Column/Row or Row/Column flag');
  writeln('ENTER:');
  writeln('   0 = ROW/COLUMN = Row first <most terminals>');
  writeln('   1 = COLUMN/ROW = Column first');
  writeln('   2 = Hazeltine terminal');
  Repeat
    done := false;
    writeln;
    writeln(' ':12, 'Present Value                --->', XY:3 );
    write(  ' ':12, 'Enter New Value or Return    ---> ');
    readln(answer);
    CVRT( answer, t, len, 0, 2 );
    if len=0 then done := true
    else if len>0 then XY := t[1]
  Until ( done );

  DO_strng('Clear to End of Screen', eraeos);

  DO_strng('Clear to End of Line', eraeol);

  DO_strng('Home Command Code', HOME);

  DO_strng('Keyboard Lock Code', LockKbd);

  DO_strng('Keyboard Unlock Code', UnlockKbd);

  DO_strng('Delete Screen line Code', LINDEL);

  DO_strng('Insert blank line Code', LININS);

  DO_strng('Inverse Video On', INVON);

  DO_strng('Inverse Video Off', INVOFF);

  DO_strng('Cursor Display On', CRSON);

  DO_strng('Cursor Display Off', CRSOFF);

  { additional strings may be entered here }

END{ of CREATE };


Procedure InitDefault;
begin
   { INIT SOME TERMINAL VARIABLES TO STANDARD DEFINITIONS }
    DELMIS := 20;  { NOTE - YOU MIGHT HAVE TO TRY DIFFERENT VALUES }
    DELCUS := 20;  { DEPENDING ON THE REACTIONS OF YOUR TERMINAL.  }
    XY := 0;
    X_OFF := 32;
    Y_OFF := 32;
   { INITIALIZE LENGTHS OF STRINGS TO 2 CHARS }
    CLRSCR[0] := 2;
    CUR[0] := 2;
    eraeos[0] := 2;
    eraeol[0] := 2;
    HOME[0] := 2;
    LockKbd[0] := 2;
    UnlockKbd[0] := 2;
    LINDEL[0] := 2;
    LININS[0] := 2;
    INVON[0] := 2;
    INVOFF[0] := 2;
    CRSON[0] := 2;
    CRSOFF[0] := 2;

    {++++++++++++++++++++++++++++++++++++++++++++++++++++}
    { DEFAULT PARAMETERS FOR TELEVIDEO 912/920 TERMINALS }
    {++++++++++++++++++++++++++++++++++++++++++++++++++++}

	{ CLEAR SCREEN }
    CLRSCR[1] := ESC;		CLRSCR[2] := 43;
	{ CURSOR POSITIONING LEAD IN STRING }
    CUR[1] := ESC;		CUR[2] := 61;
	{ ERASE TO END OF SCREEN }
    eraeos[1]:= ESC;		eraeos[2] := 89;
	{ ERASE TO END OF LINE }
    eraeol[1] := ESC;		eraeol[2] := 59;
    HOME[1] := ESC;		HOME[2] := 30;
    LockKbd[1] := ESC;		LockKbd[2] := 35;
    UnlockKbd[1] := ESC;	UnlockKbd[2] := NULL;
    LINDEL[1] := esc;		LINDEL[2] := ord('R');
    LININS[1] := esc;		LININS[2] := ord('E');
	{ INVERSE VIDEO ON }
    INVON[1] := ESC;		INVON[2] := ORD('j');
	{ INVERSE VIDEO OFF }
    INVOFF[1] := ESC;		INVOFF[2] := ord('k');
    CRSON[1] := NULL;		CRSON[2] := NULL;
    CRSOFF := CRSON;
end{ of InitDefault };


PROCEDURE INITIALIZE;
{ terminal type is not one of those listed or user desires to }
{ make changes to terminal data file. }
VAR	ch    : char;
	bx    : byte;
	valid : boolean;

   PROCEDURE INIT1;
   BEGIN
   {   INITIALIZE STRING SEQUENCES TO ZERO LENGTH   }
     XY := 0;
     CLRSCR[0] := 0;
     CUR[0] := 0;
     DELMIS := 0;
     CLRSCR[0] := 0;
     DELCUS := 0;
     X_OFF := 0;
     Y_OFF := 0;
     eraeos[0] := 0;
     eraeol[0] := 0;
     HOME[0] := 0;
     LockKbd[0] := 0;
     UnlockKbd[0] := 0;
     INVON[0] := 0;
     INVOFF[0] := 0;
     LINDEL[0] := 0;
     LININS[0] := 0;
     CRSON[0] := 0;
     CRSOFF[0] := 0;
   END{ of INIT1 };

BEGIN{ INITIALIZE }
  { First try to open data file. }
  { OPEN file TERMIO.FIL for READ assign termio }
  RESET('TERMIO.FIL',termio);

  INIT1; { init string sequences to zero }

  { if end of file then file does not exist, so continue to process. }
  if not eof(termio) then begin
    read( termio, bx, DELMIS, DELCUS, X_OFF, Y_OFF, XY );
    gets( termio, CLRSCR );
    gets( termio, CUR );
    gets( termio, eraeos );
    gets( termio, eraeol );
    gets( termio, HOME );
    gets( termio, LockKbd );
    gets( termio, UnlockKbd );
    gets( termio, LINDEL );
    gets( termio, LININS );
    gets( termio, INVON );
    gets( termio, INVOFF );
    gets( termio, CRSON );
    gets( termio, CRSOFF );
  end{if};

  { Create new/revised data file }
  CREATE
END{ of INITIALIZE };


PROCEDURE Menu;
BEGIN
  WRITELN(' 1 - HAZELTINE 1500');
  WRITELN(' 2 - SOROC IQ-120 or IQ-140');
  WRITELN(' 3 - INFOTON I-100');
  WRITELN(' 4 - TELEVIDEO 912 or 920');
  WRITELN(' 5 - BEEHIVE');
  WRITELN(' 6 - HEATH H-19');
  WRITELN(' 7 - ADDS REGENT');
  WRITELN(' 8 - ZENTEC (DYNABYTE 5022)');
  WRITELN(' 9 - DIRECT VP800');
  WRITELN('10 - TRS-80 (Pickles & Trout CP/M)');
  WRITELN('11 - VECTOR GRAPHIC ( w/ 4.0 or newer Monitor ROM)');
  WRITELN('12 - TELEVIDEO 950');
  WRITELN('13 - NONE OF THE ABOVE');
  WRITELN;  WRITELN
END{ of Menu };


Procedure Write_File;
var	bx : byte;
begin
{ OPEN file TERMIO_FIL for WRITE assign termio }
  REWRITE( 'TERMIO.FIL', termio );
  WRITELN; 

  bx := 5;	 { set length for this string sequence }
  write( termio,		{ first 5 bytes in this sequence }
	     bx:1,		{ length byte }
	     DELMIS:1,		{ delay - misc }
	     DELCUS:1,		{ delay - cursor addressing }
	     X_OFF:1,		{ x-coord offset }
	     Y_OFF:1,		{ y-coord offset }
	     XY:1 );		{ col/row or row/col flag }
  puts(termio, CLRSCR);      { CLEAR SCREEN }
  puts(termio, CUR);	     { CURSOR LEADIN STRING }
  puts(termio, eraeos);      { CLEAR TO END OF SCREEN }
  puts(termio, eraeol);      { CLEAR TO END OF LINE }
  puts(termio, HOME);	     { HOME UP CURSOR }
  puts(termio, LockKbd);     { Lock KEYBOARD }
  puts(termio, UnlockKbd);   { UNLOCK KEYBOARD }
  puts(termio, LINDEL);      { delete screen line containing cursor }
  puts(termio, LININS);      { insert a blank line on screen }
  puts(termio, INVON);	     { turn on highlighting - inverse video }
  puts(termio, INVOFF);      { turn off highlighting }
  puts(termio, CRSON);	     { cursor display on }
  puts(termio, CRSOFF);      { cursor display off }
  closes( termio );
end{ of Write File };



BEGIN { MAIN PROGRAM }
  FOR bx:=1 TO 24 DO WRITELN;
  bell := chr(7);	{ ASCII value bell character }
  ESC := 27;		{ ASCII Escape char }
  NULL := 0;		{ ASCII Null char   }
  REPEAT
    VALID := TRUE;
    Menu;
    WRITE('Enter Terminal Type to be Used ( 1 - 13 ) : ');
    READLN( termtype );
    IF ( termtype<1 ) OR ( termtype>13 ) THEN BEGIN
      VALID := FALSE;
      WRITELN;
      WRITELN;
      WRITELN(bell, 'Invalid terminal type. Reenter.');
      WRITELN; WRITELN; WRITELN
    END
  UNTIL VALID;

  InitDefault;	  { INIT SOME TERMINAL VARIABLES TO STANDARD DEFINITIONS }

  CASE termtype OF
     1: BEGIN { ******	HAZELTINE TERMINAL ****** }
	  CLRSCR[1] := 126;	CLRSCR[2] := 28;
	  CUR[1] := 126;	CUR[2] := 17;
	  XY := 2;
	  X_OFF := 0;
	  Y_OFF := 32;
	  eraeos[1] := 126;	eraeos[2] := 24;
	  eraeol[1] := 126;	eraeol[2] := 15;
	  HOME[1] := 126;	HOME[2] := 18;
	  LockKbd[1] := 126;	LockKbd[2] := 21;
	  UnlockKbd[1] := 126;	UnlockKbd[2] := 6;
	END;

     2: BEGIN { ****** SOROC TERMINAL ****** }
	  CLRSCR[0] := 4;
	  CLRSCR[1] := ESC;
	  CLRSCR[2] := 43;
	  CLRSCR[3] := NULL;
	  CLRSCR[4] := NULL;
	  CUR[2] := 61;
	  eraeos[2] := 89;
	  eraeol[2] := 59;
	  HOME[0] := 1;
	  HOME[1] := 30;
	  LockKbd[2] := 35;
	  UnlockKbd[2] := NULL;
	END;

     3: BEGIN { ****** INFOTON TERMINAL ****** }
	  CLRSCR[0] := 1;
	  CLRSCR[1] := 12;
	  CUR[2] := 102;
	  eraeos[2] := 74;
	  eraeol[2] := 75;
	  HOME[2] := 72;
	  LockKbd[2] := 104;
	  UnlockKbd[2] := 108;
	END;

     4: { ****** TELEVIDEO TERMINAL ****** };
	{ DEFAULT PARAMETERS ARE SET UP FOR TVI 912/920 TERM }

     5: BEGIN { ******* BEEHIVE TERMINAL  ****** }
		CLRSCR[2] := 69;
		CUR[2] := 70;
		eraeos[2] := 74;
		eraeol[2] := 75;
		HOME[2] := 72;
		LockKbd[2] := 35;
		UnlockKbd[2] := NULL;
	END;

     6: BEGIN { ****** HEATH TERMINAL ****** }
		CLRSCR[2] := 69;
		CUR[2] := 89;
		eraeos[2] := 74;
		eraeol[2] := 75;
		HOME[2] := 72;
		LockKbd[2] := 125;
		UnlockKbd[2] := 123;
	END;

     7: BEGIN { ****** ADDS 60 ****** }
	  CLRSCR[0] := 0;
	  CLRSCR[1] := 12;
	  CUR[2] := 89;
	  eraeos[2] := 107;
	  eraeol[2] := 75;
	  HOME[0] := 1;
	  HOME[1] := 8;
	  LockKbd[2] := 53;
	  UnlockKbd[2] := 54;
	END;

     8: BEGIN { ****** ZENTEC (DYNABYTE 5022) ****** }
	  eraeos[2] := 121;
	  eraeol[2] := 84;
	  HOME[0] := 1;
	  HOME[1] := 30;
	END;

     9: BEGIN { ****** DIRECT VP800 ****** }
	  CLRSCR[0] := 5;
	  CLRSCR[1] := ESC;		  CLRSCR[2] := 72;
	  CLRSCR[3] := NULL;		  CLRSCR[4] := ESC;
	  CLRSCR[5] := 74;
	  CUR[2] := 89;
	  eraeos[2] := 74;
	  eraeol[2] := 75;
	  HOME[2] := 72;
	  LockKbd[0] := 1;
	  LockKbd[1] := NULL;
	  UnlockKbd[0] := 1;
	  UnlockKbd[1] := NULL;

	  FOR IX:=1 TO 24 DO WRITELN;
	  WRITELN('NOTE:');
	  WRITELN;
	  WRITE('PRIOR TO RUNNING THE SOFTWARE THE TERMINAL ');
	  WRITELN('MUST BE CONFIGURED TO EMULATE');
	  WRITE('A VT-52 TERMINAL_ ');
	  WRITELN('PLEASE CONSULT THE VP800 USER MANUAL FOR PROCEDURE ON');
	  WRITELN('HOW TO ALTER AND SAVE SETUP FEATURES'); WRITELN;
	  WRITELN;
	END;

    10: BEGIN { ****** TRS-80 (PICKLES & TROUT) ****** }
	  CLRSCR[0] := 1;
	  CLRSCR[1] := 12;
	  CUR[1] := ESC;	CUR[2] := 89;
	  eraeos[0] := 1;
	  eraeos[1]:= 2;
	  eraeol[0] := 1;
	  eraeol[1] :=	1;
	  HOME[0] := 1;
	  HOME[1] := 6;
	  LockKbd[0] := 1;
	  LockKbd[1] := NULL;
	  UnlockKbd[0] := 1;
	  UnlockKbd[1] := NULL;
	END;

    11: BEGIN { ****** VECTOR GRAPHIC W/ 4.0 OR NEWER MONITOR ****** }
	  CLRSCR[0] := 1;
	  CLRSCR[1] := 4;
	  CUR[0] := 1;
	  CUR[1] := ESC;
	  XY := 1;
	  X_OFF := 128;
	  Y_OFF := 128;
	  eraeos[0] := 1;
	  eraeos[1]:= 16;
	  eraeol[0] := 1;
	  eraeol[1] := 17;
	  HOME[0] := 1;
	  HOME[1] := 2;
	  LockKbd[0] := 1;
	  LockKbd[1] := NULL;
	  UnlockKbd[0] := 1;
	  UnlockKbd[1] := NULL;
	END;

     12: BEGIN { ***** TELEVIDEO 950 ***** }
	   DELMIS := 10;
	   DELCUS := 10;
	   LINDEL[0] := 2;
	   LINDEL[1] := ESC;
	   LINDEL[2] := ORD('R');
	   LININS[0] := 2;
	   LININS[1] := ESC;
	   LININS[2] := ORD('E');
	   LockKbd[0] := 2;
	   LockKbd[1] := ESC;
	   LockKbd[2] := ORD('#');
	   UnlockKbd[0] := 2;
	   UnlockKbd[1] := ESC;
	   UnlockKbd[2] := ORD('"');
	   INVON[0] := 3;	{ INVERSE VIDEO ON }
	   INVON[1] := ESC;
	   INVON[2] := ORD('G');
	   INVON[3] := ORD('4');
	   INVOFF[0] := 3;	{ INVERSE VIDEO OFF }
	   INVOFF[1] := ESC;
	   INVOFF[2] := ORD('G');
	   INVOFF[3] := ORD('0');
	   CRSON[0] := 3;	{ SET CURSOR ON AND BLINKING }
	   CRSOFF[0] := 3;	{ SET CURSOR DISPLAY OFF }
	   CRSON[1] := ESC;
	   CRSON[2] := ORD('.');
	   CRSON[3] := ORD('1');
	   CRSOFF[0] := 3;	{ SET CURSOR DISPLAY OFF }
	   CRSOFF[1] := ESC;
	   CRSOFF[2] := ORD('.');
	   CRSOFF[3] := ORD('0');
	 END;

     13: BEGIN { ****** TERMINAL NOT ONE OF THE ABOVE TYPES ****** }
	   INITIALIZE;
	 END
  END{CASE};

  Write_File;

  for bx:=1 to 5 do writeln;
END{ of INSTALL }.
OVE TYPES ****** }
	   INITIALIZE;
	 END
  END{CASE};

  Write_File;

  f