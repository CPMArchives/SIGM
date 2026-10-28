PROGRAM Student;

{---------------------------------------------------------------}
{ PROGRAM TITLE:	STUDENT	version 2.0			}
{ WRITTEN BY:		Raymond E. Penley			}
{ DATE WRITTEN:		Dec 18, 1982				}
{								}
{ INPUT/OUTPUT FILES:		   *** ACCESS METHOD ***	}
{   STUDENT.NDX - Misc data		<sequential>		}
{   STUDENT.DAT - Name & Address	<random>		}
{   STUDENT.GDS	- Grade data		<sequential>		}
{								}
{ COMMANDS:							}
{  New student	- Adds a new entry if file not filled.		}
{  Find		- Searches & displays a student			}
{  Change	- Allows changes on address/grades		}
{  List		- Displays data for all students		}
{  Quit		- Terminate program/close all files		}
{								}
{ SUMMARY:							}
{ Writes a name & address file and a grade file on all students.}
{ Also a file of misc. data; # of rcds on file and date file	}
{ was last updated.						}
{								}
{ 01/29/83 -- EXTENSIVE ERROR CORRECTING ADDED:			}
{								}
{ NOTES:							}
{  utility procedures from the Pascal/Z User's Group		}
{  Library diskette.						}
{---------------------------------------------------------------}


CONST
  MaxStudents = 50; { determines maximum # of data records in file }
  enter = 'ENTER NEW DATA OR PRESS RETURN TO KEEP PRESENT DATA';
  escape = 27;		{ ASCII escape character }

TYPE

   {-------------------------------------------------------------}
   { create a binary search tree in memory to hold our index	 }
   {-------------------------------------------------------------}

   link = ^ip;			{ pointer to the B-tree }
   ip = RECORD			{ the B-tree record }
	  item : integer;	{ KEY FIELD. student's id number }
	  rcd  : integer;	{ data file record pointer }
	  left,right: link	{ pointers to left/right nodes }
	END;

  byte		= 0..255;
  charset	= SET OF CHAR;
  strng2	= string 2;
  strng5	= string 5;
  strng20	= string 20;
  strng		= string 20;


  {-------------------------------------------------------------}
  { sturec - identifies the data to be stored for each student	}
  {-------------------------------------------------------------}

  sturec  = RECORD        { field name, type, length		}
	       id    : integer;	{ id,     n,  5     <KEY FIELD>	}
	       name,		{ name,   c, 20			}
	       street,		{ street, c, 20			}
	       city   : strng20;{ city,   c, 20			}
	       state  : strng2;	{ state,  c,  2			}
	       zipcode: strng5	{ zipcode,c,  5			}
	    END;
  { total number of bytes = 77 per record.
    72 bytes + 1 FOR each string }


  {-------------------------------------------------------------}
  { Allow for ten grades and the student ID. Please note that	}
  { this may be changed to suit your particular requirements.	}
  { NOTE: the enumerated type has been setup such that		}
  { ORD(exam1) = 1.						}
  {-------------------------------------------------------------}

  gradetype = ( id,	{ id field is link between all data files }
		exam1,	{ 1st exam grade }
		exam2,	{ 2nd exam grade }
		exam3,	{ 3rd exam grade }
		exam4,	{ 4th exam grade }
		exam5,	{ 5th exam grade }
		exam6,	{ 6th exam grade }
		exam7,	{ 7th exam grade }
		quiz1,	{ quiz 1 }
		quiz2,	{ quiz 2 }
		final);	{ FINAL grade }

  {-------------------------------------------------------------}
  gradestore	= array [gradetype] of integer;

  {-------------------------------------------------------------}
  StuGds	= array [1..MaxStudents] of gradestore;

  {-------------------------------------------------------------}
  FTYPE		= FILE OF StuRec;

  string0	= string 0;
  string255	= string 255;

VAR
  bell		: char;		{ console bell }
  command	: char;		{ command character }
  console	: TEXT;		{ direct output to console }
  date		: packed array [1..8] of char; { date of last update }
  g		: gradetype;
  Grades	: StuGds;
  ioresult	: boolean;
  listhead	: link;
  more		: boolean;	{ done processing flag }
  R		: integer;	{ global var for record number }
  rof		: integer;	{ total Records On File }
  stucount	: integer;	{ # of students in class }
  Student	: StuRec;	{ A single student }
  StuFile	: FTYPE;	{ name & address file }
  taken		: integer;	{ # of tests taken thus far }
  updated	: boolean;	{ flag for updated items }

{$R-}

{$iPRIMS.PZ }


{ pause - allows one to stop until ready to continue }
PROCEDURE pause;
VAR	ch : char;
BEGIN
   writeln;
   write ('Press any key to continue ');
   keyin(ch); writeln
END{ pause };


{ ClearScreen - routine to clear the console device }
PROCEDURE ClearScreen;
VAR	i: 1..25;
BEGIN
   FOR i:=1 TO 25 DO writeln
END{ ClearScreen };


{ Q - prints a text message and accepts only the characters }
{ passed via goodchars. returns the char input in ch	    }

PROCEDURE Q( message: string255; goodchars: charset; VAR ch: char );
VAR	ctemp: char;
BEGIN
   write( message );
   REPEAT
     keyin(ctemp); ch := toupper(ctemp);
     IF ch IN goodchars
	THEN writeln(ctemp)
	ELSE write (bell)
   UNTIL ch in goodchars
END{ Q };


{ readint - 						}

FUNCTION readint ( VAR i: integer; lower,upper: integer ): boolean;
VAR	answer: strng20;
BEGIN
      readint := true;
      readln(answer);
      IF length(answer) > 0 THEN BEGIN
	 i := ival ( answer,1 );
	 if (i < lower) OR (upper < i ) THEN {do it again}
	    readint := false;
      END
END{ readint };


{ gde - converts an integer to the enumerated type gradetype }

FUNCTION gde ( exam: integer ): gradetype;
BEGIN
     CASE exam OF
	0: gde := id;
	1: gde := exam1;
	2: gde := exam2;
	3: gde := exam3;
	4: gde := exam4;
	5: gde := exam5;
	6: gde := exam6;
	7: gde := exam7;
	8: gde := quiz1;
	9: gde := quiz2;
       10: gde := final
     END
END{ gde };

{$R+}

{ insert - adds a node TO the binary search tree, preserving the ordering }

PROCEDURE insert( VAR node: link; ident, R: integer );
BEGIN
  IF node=nil THEN BEGIN
     new(node);		{ create a new storage location }
     WITH node^ DO BEGIN
        left := nil;
        right := nil;
        item := ident;	{ store the student's ID }
        rcd := R	{ store the location record # }
     END{with}
  END
  ELSE
     WITH node^ DO
        IF ident<item THEN
           insert ( left,ident,R )
        ELSE IF ident>item THEN
           insert ( right,ident,R )
        ELSE
	   { DUPLICATE ENTRY }{ not handled }
END{ insert };


{ search - returns a pointer TO a node in the tree containing
  the given data, or nil if there is no such node. }

FUNCTION search ( node: link; ident: integer ): link;
BEGIN
  IF node=nil THEN
     search := nil
  ELSE
     WITH node^ DO
        IF ident<item THEN
           search := search(left,ident)
        ELSE IF ident>item THEN
           search := search(right,ident)
        ELSE
           search := node
END{ search };


  {-------------------------------------------------------------}
  { ListRange -							}
  {	enter with first = lower bound; last = uppermost bound.	}
  {	returns first/last per operator specifications		}
  {-------------------------------------------------------------}

PROCEDURE ListRange ( VAR first, last: integer );
VAR
	ch: char;
	t1,t2: integer;
BEGIN
  t1 := first;
  t2 := last;
  writeln;
  Q( 'ENTER LIST RANGE: A(ll, O(ne, R(ange ->', ['A','O','R'], ch );
  CASE ch of
     'A':
	BEGIN
	  first := t1;
	  last := t2
	END
     'O':
	REPEAT
	  write ( 'WHICH ONE? '); readln(first);
	  last := first;
	UNTIL (first<=t2) or (first>=t1);
     'R':
	REPEAT
	   write ( 'Enter lower bound ->'); readln(first);
	   write ( 'Enter upper bound ->'); readln(last)
	UNTIL first <= last
  end{CASE}
END{ ListRange };


{ fread - reads the address file and sets the global record pointer }

PROCEDURE fread ( VAR StuFile: FTYPE; VAR node: link );
BEGIN
   R := node^.rcd;		{ returns the record # in "R" }
   read ( StuFile:R, student )	{ read student record "R" }
END{ fread };


PROCEDURE ChangeAddress ( VAR student: sturec; VAR goodstatus: boolean );
LABEL
   1;	{ early exit }
CONST
   ok = true;
VAR
   answer: strng20;
   i	 : integer;
   node  : link;
   valid : boolean;

	PROCEDURE disp ( message, value: string255 );
	BEGIN
	   writeln;
	   IF length(value) > 0 THEN BEGIN
	      writeln ( message, value );
	      write ( ' ':19 )
	   END
	   ELSE
	      write ( message );
	END{ disp };

BEGIN {ChangeAddress}
   goodstatus := ok;
   IF command = 'C' THEN BEGIN
      writeln;
      writeln ( enter )
   END;	
   writeln;writeln;
   WITH student DO BEGIN
	IF id=0
	   THEN setlength ( answer,0 )
	   ELSE STR ( id,answer );

        { NOTE: do not allow ID TO be changed after initial input }
	IF command = 'N' THEN BEGIN { adding New records }
	   REPEAT
	      disp ( 'ID Number      ... ', answer )
	   UNTIL readint ( id,1,9999 );

	   node := search ( listhead,id );	{ id already on file? }
	   IF node<>nil THEN BEGIN { already on file }
	      fread ( StuFile, node );	{ read record FOR show & tell }
	      ClearScreen;
	      writeln ( bell, id, ' already on file!');
	      goodstatus := not ok;
	      {EXIT}goto 1;
	   END
	END{IF command='N'...}
	ELSE
	   writeln ( 'ID Number      ... ', answer );

	disp ( 'Name           ... ', name ); readln(answer);
	IF length(answer)>0 THEN
	   name := answer;
	disp ( 'Street Address ... ', street ); readln(answer);
	IF length(answer)>0 THEN
	   street := answer;
	disp ( 'City           ... ', city ); readln(answer);
	IF length(answer)>0 THEN
	   city := answer;
	disp ( 'State          ... ', state ); readln(answer);
	IF length(answer)>0 THEN BEGIN
	   state[1] := toupper ( answer[1] );
	   state[2] := toupper ( answer[2] );
	   setlength ( state,2 )
	END;
	REPEAT
	   valid := true;
	   disp ( 'Zip code       ... ', zipcode ); readln(answer);
	   IF length(answer)>0 THEN BEGIN
	      zipcode := '     ';{ insure no garbage in answer }
	      IF isdigit(answer[1]) THEN { good chance is digit }
	         FOR i:=1 TO 5 DO
		    zipcode[i] := answer[i]
	      ELSE BEGIN
		 write(bell); valid := false
	      END
	   END
	UNTIL valid;
   END;
   updated := true;
1:{early exit}
END{ ChangeAddress };


PROCEDURE ChangeGrades ( VAR student: sturec );
CONST
   low = 0;	{ lowest grade acceptable }
   high = 110;	{ highest grade acceptable }
VAR
   answer	: strng20;
   first,last	: gradetype;
   lower,upper	: integer;
BEGIN
   lower := 1;
   upper := taken;
   ListRange ( lower,upper );
   first := gde(lower);
   last := gde(upper);
   writeln;
   writeln ( enter );
   writeln;writeln;
   writeln ( 'STUDENT: ', student.name );
   writeln;
   FOR g:=first TO last DO BEGIN
      REPEAT
	 write ( ord(g):3, grades[R,g]:6, ' ?' )
      UNTIL readint ( grades[R,g],low,high )
   END
END{ ChangeGrades };


PROCEDURE display ( VAR output: TEXT; VAR student: sturec );
{ GLOBAL	R : integer; <record #>   }
CONST
   width = 35;
BEGIN
   writeln ( output);
   writeln ( output);
   WITH student DO BEGIN
	writeln (output, 'STUDENT ID: ', id:1 );
	writeln (output, name, ' ':width-length(name), street );
	writeln (output, ' ':width, city, ', ', state, ' ', zipcode );
	writeln ( output, 'GRADES');
	writeln ( output, ' < first half year >< second half year >');
	FOR g:=exam1 TO final DO BEGIN
	   write(output, grades[R,g]:4 )
	END;
	writeln ( output);
	writeln ( output);
	writeln ( output)
   END
END{ display };


PROCEDURE MODIFY;
VAR
	node : link;
	ident: integer;
	ch	: char;
	goodstatus	: boolean;
BEGIN
   IF command='N' THEN BEGIN { arrived here from ADD }
      command := 'C';	     { so, switch to CHANGE  }
      ident := student.id { already in memory }
   END
   ELSE BEGIN
      writeln;
      REPEAT
	 write ('Enter student id number ... ')
      UNTIL readint ( ident,1,9999 )
   END;

   node := search ( listhead,ident );
   IF node<>nil THEN BEGIN
      fread ( StuFile, node );
      CASE command of
	'C':
	   BEGIN {CHANGE}
	   writeln;
	   Q( 'Do you wish to change A(ddress, or G(rades? <escape=quit> ',
			[chr(escape),'A','G'], ch );
	   if ord(ch)=escape then
	      {all done}
	   else begin
	      CASE ch of
		 'A':
		    ChangeAddress ( student,goodstatus );
		'G':
		   ChangeGrades ( student )
	      END{CASE};
	      display ( console,student );
	      if ch='A' THEN { update address file }
		 write ( StuFile:R, student )
	   end
	   END{ CHANGE };
	'F':
	    display ( console,student );{ send the picture to the console }
      END{CASE}
   END
   ELSE
      writeln ( bell, ident:1,' not on file!')
END{ MODIFY };


PROCEDURE ADD;
VAR	goodstatus: boolean;
BEGIN
   IF rof >= MaxStudents THEN
      writeln ( 'Sorry can''t add file is full.' )
   ELSE BEGIN { OK to add more records }
      IF rof=0
	 THEN R := 1
	 ELSE R := rof + 1;
      WITH student DO BEGIN { initialize all fields to zero }
	 id := 0;
	 setlength ( name,0 );
	 setlength ( street,0 );
	 setlength ( city,0 );
	 setlength ( state,0 );
	 setlength ( zipcode,0 )
      END;
      writeln;
      writeln ( 'RECORD #', R:1 );
      ChangeAddress ( student,goodstatus );
      display ( console, student );

      IF goodstatus THEN BEGIN
	 grades[R,id] := student.id;	{ update grades matrix }
	 insert ( listhead,student.id,R );
	 write ( StuFile:R, student );	{ update address file }
	 updated := true;		{ flag we updated the file }
	 rof := R;			{ increment records on file }
	 stucount := rof;		{ and student count         }
	 { move right into edit mode...change address/grades }
	 MODIFY
      END{IF goodstatus then...};
      pause
   END{ELSE}
END{ ADD };


{ list - lists ALL records on file }

PROCEDURE LIST;
VAR	output : TEXT;

	{ printlist - writes the entire tree recursively }
	PROCEDURE PrintList ( node: link );
	BEGIN
	   IF node<>nil THEN
	      WITH node^ DO BEGIN
	         PrintList (left);
		 fread ( StuFile, node ); { read address file }
		 display ( output, student );
		 IF command<>'P' THEN pause;
	         PrintList ( right )
	      END{with}
	END{ PrintList };

BEGIN
   writeln;
   Q('Output to C(onsole or P(rinter? <escape=quit> ',
		[chr(escape),'C','P'], command );
   IF ord(command)=escape THEN
      {all done}
   ELSE BEGIN 
      CASE command OF
	 'P': { direct output to the list device }
	    REWRITE( 'LST:',output );
	 'C': { direct output to the console device }
  	    REWRITE( 'CON:',output )
      end{CASE};
      PrintList(listhead)
   END
END{ LIST }{ CLOSE(output); };


PROCEDURE mathmult;
LABEL
	1; {quick exit}
CONST
	fw = 6;
TYPE
	etype = (total,avg);
VAR
	g,first,last: gradetype;
	a : integer;
	accum : array [total..avg,gradetype] of integer;
	output : TEXT;

	PROCEDURE print ( message: string255; i: etype );
	BEGIN
	   write( output,message );
	   FOR g:=first TO last DO
	      write( output,accum[i,g]:fw );
	   writeln ( output)
	END;

BEGIN{ mathmult }
   writeln;
   Q('Output to C(onsole or P(rinter? <escape=quit> ',
		[chr(escape),'C','P'], command );
   IF ord(command)=escape THEN
      goto 1; {all done}
   CASE command OF
      'P': { direct output to the list device }
         REWRITE( 'LST:',output );
      'C': { direct output to the console device }
         REWRITE( 'CON:',output )
   END{CASE};

   first := exam1;	{ first = 1st exam grade, last = last exam taken }
   last := gde(taken);

   writeln ( output);
   write(output,' STUDENT');
   FOR g:=first TO last DO BEGIN
      write( output,ord(g):fw );
      accum[total,g] := 0;	{ zero accumulators }
      accum[avg,g] := 0
   END;
   writeln ( output,'  AVERAGE');

   FOR r:=1 TO stucount DO BEGIN
      write(output,grades[r,id]:fw,' :'); { print the student's id number }
      a := 0;	   			{ "a" = grade accumulator }
      FOR g:=first TO last DO BEGIN
         write(output,grades[r,g]:fw);
         a := a + grades[r,g];
         accum[total,g] := accum[total,g] + grades[r,g]
      END{FOR g};
      { print the rounded average of this student's grades }
      writeln (output, round(a/taken):fw )
   END{FOR r};

   { compute the average FOR all the student's grades & underline }
   write(output,'        ');
   FOR g:=first TO last DO BEGIN
	accum[avg,g] := accum[total,g] DIV stucount;
	write(output,'   ---');
   end;
   write(output,'   ---');
   writeln ( output);

   print ( '  TOTAL:', total );{ for each graded exam }
   print ( '    AVG:', avg );{ for each graded exam }
   writeln ( output);
1:{quick exit}
END{ mathmult }{ CLOSE(output); };


PROCEDURE STATS;
VAR
	answer	: strng20;
	valid	: boolean;
BEGIN
   writeln;
   writeln ( 'NUMBER OF STUDENTS ... ', stucount:3 );
   REPEAT
	write  ('NUMBER OF TESTS ...... ', taken:3,' ?' );
	readln ( answer );
	IF length(answer)>0 THEN
	   taken := ival ( answer,1 );
	valid := (taken>=0)
   UNTIL valid
END{ STATS };


PROCEDURE fclose;
VAR
	StuGrades: FILE OF gradestore;	{ grade data on each student }
	StuNdx   : TEXT;		{ index file }
BEGIN
   rewrite('STUDENT.NDX',StuNdx);
   writeln ( StuNdx, rof );
   writeln ( StuNdx, date );
   writeln ( StuNdx, stucount ); { # of students in class }
   writeln ( StuNdx, taken );	{ # of tests taken thus far }

   rewrite('STUDENT.GDS',StuGrades);
   FOR R:=1 TO rof DO
      write ( StuGrades, grades[R] )
END{ fclose }{ CLOSE(StuNdx); CLOSE(StuGrades); };


PROCEDURE Initialize;
VAR
	i	: integer;
	ch	: char;
	StuGrades: FILE OF gradestore;	{ grade data on each student }
	StuNdx   : TEXT;		{ index file }
BEGIN
   ClearScreen;
   writeln ( ' ':32, 'STUDENT SYSTEM');
   writeln;
   writeln;
   bell := chr(7);
   listhead := nil;	{ make the list empty }
   updated := false;	{ say file has not been updated }
   
   { insure that all cells in grades matrix are 0 }
   FOR g:=id TO final DO
      grades[1,g] := 0;
   FOR R:=2 TO MaxStudents DO
      grades[R] := grades[1];
   rewrite('CON:',console);
   reset('STUDENT.NDX',StuNdx);

   IF eof(StuNdx) THEN BEGIN {create all files}
	writeln ( 'Please standby while I create data files ...' );
   	rewrite('STUDENT.NDX',StuNdx);
   	rewrite('STUDENT.DAT',StuFile);
   	rewrite('STUDENT.GDS',StuGrades);

	rof := 0;
	stucount := 0;
	taken := 10;	{ setup to 10 then can lower at any time }
	date := 'MM/DD/YY'
   END
   ELSE BEGIN { finish opening files and read record count }
	reset('STUDENT.DAT',StuFile);
	reset('STUDENT.GDS',StuGrades);
	readln ( StuNdx, rof );
	readln ( StuNdx, date );
	readln ( StuNdx, stucount );	{ # of students in class }
	readln ( StuNdx, taken );	{ # of tests taken thus far }
	writeln;
	FOR R:=1 TO rof DO BEGIN
	   write( chr(13), 'RECORD #', R:1 );
	   read ( StuGrades, grades[R] );
	   read ( StuFile:R,student ); 	   { create the B-tree in memory }
	   insert ( listhead,student.id,R )
	END;
	writeln
   END;

   IF rof>0 THEN BEGIN
      writeln;
      writeln ( 'There are ',rof:1,' records on file as of ', date )
   END;
   writeln;
   write ( 'ENTER TODAY''S DATE <MM/DD/YY>  ->');
   FOR i:=1 TO 8 DO BEGIN
      IF (i=3) or (i=6)
	 THEN ch := '/'
	 ELSE keyin(ch);
       write(ch);
       date[i] := ch
   END;
   writeln
END{ Initialize }{ CLOSE(StuNdx); CLOSE(StuGrades); };


BEGIN	(*** MAIN PROGRAM ***)
   Initialize;
   more := true;
   WHILE more DO BEGIN
	writeln;
	Q('N(ew student, F(ind, C(hange, G(rades, L(ist, S(tats, Q(uit ...?',
		['N','C','F','G','L','S','Q'], command );
	CASE command of
	   'N':
	      ADD;
	   'C','F':
	      MODIFY;
	   'G':
	      mathmult;
	   'L':
	      LIST;
	   'S':
	      STATS;
	   'Q':
	      more := false
	end{CASE}
   END{while};
   IF updated THEN fclose
END.
