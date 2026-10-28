PROGRAM Student;

{---------------------------------------------------------------}
{ PROGRAM TITLE:	STUDENT	version 2.0			}
{ WRITTEN BY:		Raymond E. Penley			}
{ DATE WRITTEN:		Dec 18, 1982				}
{								}
{ INPUT/OUTPUT FILES:		   *** ACCESS METHOD ***	}
{   STUDENT.NDX - Misc data		<sequential>		}
{   STUDENT.DAT - Name & Address	<direct (random)>	}
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
{ 04/02/83 -- added vlength() by D. Cortesi			}
{								}
{ NOTES:							}
{  utility procedures from the Pascal/Z User's Group		}
{  Library diskette.						}
{---------------------------------------------------------------}


CONST
  MaxStudents = 200; { determines maximum # of data records in file }
  enter = 'ENTER NEW DATA OR PRESS RETURN TO KEEP PRESENT DATA';
  escape = 27;		{ ASCII escape character }

TYPE

   {-------------------------------------------------------------}
   { create a binary search tree in memory to hold our index	 }
   {-------------------------------------------------------------}

   link = ^ip;			{ pointer to the binary tree }
   ip = RECORD			{ the binary tree record }
	  item : integer;	{ KEY FIELD. student's id number	  }
	  rcd  : integer;	{            data file record pointer	  }
	  left,right: link	{            pointers to left/right nodes }
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

  sturec  = RECORD              { field, type, length		}
	       id    : integer;	{ id,     n,  5     <KEY FIELD>	}
	       name,		{ name,   c, 20			}
	       street,		{ street, c, 20			}
	       city   : strng20;{ city,   c, 20			}
	       state  : strng2;	{ state,  c,  2			}
	       zipcode: strng5	{ zipcode,c,  5			}
	    END;
  { total number of bytes = 77 per record.
    72 bytes + 1 for each string }


  {-------------------------------------------------------------}
  { Allow for ten grades and the student ID. Please note that	}
  { this may be changed to suit your particular requirements.	}
  { NOTE: the enumerated type has been setup such that		}
  {       ORD(exam1) = 1.					}
  {-------------------------------------------------------------}

  gradetype = ( id,	{ id field is link between all data files }
		exam1,	{ 1st exam grade			  }
		exam2,	{ 2nd exam grade			  }
		exam3,	{ 3rd exam grade			  }
		exam4,	{ 4th exam grade			  }
		exam5,	{ 5th exam grade			  }
		exam6,	{ 6th exam grade			  }
		exam7,	{ 7th exam grade			  }
		quiz1,	{ quiz 1		 		  }
		quiz2,	{ quiz 2		 		  }
		final);	{ final grade		 		  }

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
  R		: integer;	{ record pointer }
  rof		: integer;	{ total Records On File }
  stucount	: integer;	{ # of students in class }
  Student	: StuRec;	{ A single student }
  StuFile	: FTYPE;	{ name & address file }
  taken		: integer;	{ # of tests taken thus far }
  updated	: boolean;	{ flag for updated items }

{$R-}{ range checking OFF }

{-----------------------------------------------}
{         GENERAL PURPOSE UTILITIES             }
{-----------------------------------------------}

{$iPRIMS.PZ }


{ pause - allows prgm to stop until ready to continue }

PROCEDURE pause;
VAR	ch : char;
BEGIN
   writeln;
   write ('Press any key to continue ');
   keyin(ch); writeln
END{ pause };


{ ClearScreen - simple routine to clear the console device }

PROCEDURE ClearScreen;
VAR	i: 1..25;
BEGIN
   FOR i:=1 TO 25 DO writeln
END{ ClearScreen };


{ Q - prints a text message and accepts only the characters	}
{ passed via goodchars. Returns the result in uppercase.	}
{								}
{ Q ( 'Enter "A", "B", or "C" -> ', ['A','B','C'], command );	}
{								}
{ REQUIRES:							}
{	procedure keyin();external;				}
{	function toupper():char;external;			}

PROCEDURE Q ( message: string255; goodchars: charset; VAR ch: char );
CONST	bell = 7;		{ ASCII bell char }
VAR	tch: char;		{ temp char       }
BEGIN
   write( message );
   REPEAT
     keyin(tch);
     ch := toupper(tch);
     IF ch IN goodchars
	THEN
	   writeln (tch)
	ELSE
	   write (chr(bell))
   UNTIL ch in goodchars
END{ Q };


{ readint - input of an integer value between lower..upper.	}
{	returns integer value and true if valid integer		}
{	else returns a zero value and false.			}
{ REQUIRES:							}
{	function ivalue():integer;				}
{	function vlength():integer;external;			}
	
FUNCTION readint ( VAR i: integer; lower,upper: integer ): boolean;
VAR	answer: strng20;
BEGIN
      readint := true;
      readln(answer);
      IF vlength(answer) > 0 THEN BEGIN
	 i := ivalue(answer,1);
	 IF (i < lower) OR (upper < i ) THEN {do it again}
	    readint := false;
      END
END{ readint };


{-----------------------------------------------}
{        PROGRAM SPECIFIC UTILITIES             }
{-----------------------------------------------}

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

{$R+}{ RANGE CHECKING ON }


{ insert - adds a node to the binary search tree, preserving the ordering }

PROCEDURE insert( VAR node: link; ident, R: integer );
BEGIN
  IF node=nil THEN BEGIN
     new(node);		{ create a new storage location }
     WITH node^ DO BEGIN
        left := nil;
        right := nil;
        item := ident;	{ store the student's id }
        rcd := R	{ store the location record pointer }
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


{ search - returns a pointer to a node in the tree containing }
{  the given data, or nil if there is no such node.	      }

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



PROCEDURE ListRange ( VAR first, last: integer );
{ RETURNS:							   }
{   one value		-first = last				   }
{   all values		-first = lower bound, last = highest bound }
{   a range of values	-first/last = entered values		   }
{ ENTER with first = lower bound; last = uppermost bound.	   }
VAR
	tch: char;
	t1,t2: integer;
BEGIN
  t1 := first;
  t2 := last;
  writeln;
  Q( 'ENTER LIST RANGE: A(ll, O(ne, R(ange ->', ['A','O','R'], tch );
  CASE tch of
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
   R := node^.rcd;		{ returns the record pointer. }
   read ( StuFile:R, student )	{ read student record R. }
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
	   IF vlength(value) > 0 THEN BEGIN
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
	   THEN
	      setlength ( answer,0 )
	   ELSE
	      STR ( id,answer );

        { NOTE:
		do not allow ID to be changed after initial input }
	IF command = 'N' THEN BEGIN { adding New records }
	   REPEAT
	      disp ( 'ID Number      ... ', answer )
	   UNTIL readint ( id,1,9999 );

	   node := search ( listhead,id );	{ id already on file? }
	   IF node<>nil THEN BEGIN { already on file }
	      fread ( StuFile, node );	{ read record for display }
	      ClearScreen;
	      writeln ( bell, id, ' already on file!');
	      goodstatus := not ok;
	      {EXIT}goto 1
	   END
	END{IF command='N'...}
	ELSE
	   writeln ( 'ID Number      ... ', answer );

	disp ( 'Name           ... ', name ); readln(answer);
	IF vlength(answer)>0 THEN
	   name := answer;

	disp ( 'Street Address ... ', street ); readln(answer);
	IF vlength(answer)>0 THEN
	   street := answer;

	disp ( 'City           ... ', city ); readln(answer);
	IF vlength(answer)>0 THEN
	   city := answer;

	disp ( 'State          ... ', state ); readln(answer);
	IF vlength(answer)>0 THEN BEGIN
	   state[1] := toupper ( answer[1] );
	   state[2] := toupper ( answer[2] );
	   setlength ( state,2 )
	END;

	REPEAT
	   valid := true;
	   disp ( 'Zip code       ... ', zipcode ); readln(answer);
	   IF vlength(answer)>0 THEN BEGIN
	      zipcode := '     ';        { insure no garbage in answer }
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
{NOTE:
	record pointer must be set before entry to ChangeGrades() }
CONST
   low = 0;	{ lowest grade acceptable }
   high = 110;	{ highest grade acceptable <wow!>}
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
   END{FOR g}
END{ ChangeGrades };



PROCEDURE display ( VAR output: TEXT; VAR student: sturec );
{NOTE:
	record pointer must be set before entry to display() }
CONST
   width = 35;
BEGIN
   writeln ( output );
   writeln ( output );
   WITH student DO BEGIN
	writeln ( output, 'STUDENT ID: ', id:1 );
	writeln ( output, name, ' ':width-vlength(name), street );
	writeln ( output, ' ':width, city, ', ', state, ' ', zipcode );
	writeln ( output, 'GRADES');
	writeln ( output, ' < first half year >< second half year >');
	FOR g:=exam1 TO gde(taken) DO
	   write ( output, grades[R,g]:4 );
	writeln ( output );
	writeln ( output );
	writeln ( output )
   END
END{ display };



PROCEDURE MODIFY;
VAR
	node	   : link;
	ch	   : char;
	goodstatus : boolean;
BEGIN
   IF command='N' THEN { arrived here from ADD }
      command := 'C'   { ... switch to CHANGE. }
   ELSE BEGIN
      writeln;
      REPEAT
	 write ('Enter student id number ... ')
      UNTIL readint ( student.id,1,9999 )
   END;

   node := search ( listhead,student.id );
   IF node<>nil THEN BEGIN
      fread ( StuFile, node );
      CASE command of
	'C':
	   BEGIN {CHANGE}
	      writeln;
	      Q( 'Do you wish to change A(ddress, or G(rades? <escape=quit> ',
			[chr(escape),'A','G'], ch );
	      if ord(ch)<>escape then begin
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
	   BEGIN {FIND}
	      display ( console,student )
	   END{ FIND }
      END{CASE}
   END
   ELSE
      writeln ( bell, student.id:1,' not on file!')
END{ MODIFY };



PROCEDURE ADD;
VAR
	goodstatus: boolean;
BEGIN
   IF rof >= MaxStudents THEN
      writeln ( 'Sorry can''t add file is full.' )
   ELSE BEGIN { OK to add more records }
      R := rof + 1;		{ temp set record pointer }
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
VAR
	output : TEXT;

	{ printlist - writes the entire tree recursively }
	PROCEDURE PrintList ( node: link );
	LABEL	1;
	BEGIN
	   IF node<>nil THEN
	      WITH node^ DO BEGIN
	         PrintList (left);
		 fread ( StuFile, node ); { read address file }
		 display ( output, student );
		 { test the keyboard and abort on any keypress }
		 IF conchar<>0 THEN BEGIN {ABORT}
		    writeln;writeln(chr(7);'ABORTED');goto 1
		 END;
		 IF command<>'P' THEN pause;
	         PrintList ( right )
	      END{with};
	1:{abort}
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



{ report - generates totals and prints a formatted report on each student }

PROCEDURE report;
LABEL
	1; {abort}
CONST
	fw = 6;
TYPE
	atype = (avg,total);
VAR
	a,rr	 : integer;
	aborted	 : boolean;
	accum	 : array [avg..total,gradetype] of integer;
	first,g,
	last	 : gradetype;
	output	 : TEXT;


   PROCEDURE PrintClass ( node: link );
   LABEL
	 2; {abort}
   BEGIN
      IF node<>nil THEN
         WITH node^ DO BEGIN
            PrintClass (left);
	    R := rcd;
	    rr := rr + 1;
	    { output line consists of: line #, student id #, grades }
	    write ( output, rr:3, grades[R,id]:5, '  ' );
	    a := 0;	   			{ "a" = grade accumulator }
	    FOR g:=first TO last DO BEGIN
	       write ( output,grades[R,g]:fw );
               a := a + grades[R,g];
	       accum[total,g] := accum[total,g] + grades[R,g]
	    END{FOR g};
	    { print the rounded average of this student's grades }
	    writeln (output, '  ', round(a/taken):fw );

	    { test the keyboard and abort on any keypress }
	    IF conchar<>0 THEN BEGIN {ABORT}
	       aborted := true;
	       writeln;writeln(chr(7);'ABORTED');goto 2
	    END;
            PrintClass ( right )
         END{with};
   2:{abort}
   END{ PrintClass };

BEGIN{ report }
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

{REPORT LINE 1}
   writeln ( output );
   write(output,' STUDENT  ');
   FOR g:=first TO last DO
      IF ord(g)=1
	 then write(output,' EXAMS')
	 else write(output,'      ');
   writeln(output,'  AVERAGE');

{REPORT LINE 2}
   write ( output,'========  ' );
   FOR g:=first TO last DO BEGIN
      write( output,ord(g):fw );
      accum[total,g] := 0	{ zero total accumulator }
   END;
   writeln ( output,'  =======' );

{REPORT LINE 3...n}
   rr := 0;
   aborted := false;
   PrintClass(listhead);
   if aborted then goto 1;
   write ( output,'          ' );{ 10 spaces }
   FOR g:=first TO last DO BEGIN
	{ compute the average for all the student's grades }
	accum[avg,g] := accum[total,g] DIV stucount;
	{ underline each column }
	write(output,'   ---');
   END;
   writeln (output);

{REPORT SUMMATION LINE...}
   writeln ( ' CLASS' );
   write   ( ' AVERAGE: ');
   FOR g:=first TO last DO
      write ( output,accum[avg,g]:fw );
   writeln ( output );
   writeln ( output );
1:{abort}
END{ report }{ CLOSE(output); };



PROCEDURE STATS;
VAR
	answer	: strng20;
	valid	: boolean;
BEGIN
   writeln;
   writeln ( 'MAX STUDENTS ALLOWED ... ', MaxStudents:3 );
   writeln ( 'NUMBER OF STUDENTS ..... ', stucount:3 );
   REPEAT
	write  ('NUMBER OF TESTS ........ ', taken:3,' ?' );
	readln ( answer );
	IF vlength(answer)>0 THEN
	   taken := ivalue( answer,1 );
	valid := (taken>=0)
   UNTIL valid
END{ STATS };



PROCEDURE fclose;
VAR
	StuGrades: FILE OF gradestore;	{ grade data on each student }
	StuNdx   : TEXT;		{ index file }
BEGIN
   { OPEN 'STUDENT.NDX' for WRITE assign StuNdx }
   rewrite('STUDENT.NDX',StuNdx);
   writeln ( StuNdx, rof );
   writeln ( StuNdx, date );
   writeln ( StuNdx, stucount ); { # of students in class }
   writeln ( StuNdx, taken );	{ # of tests taken thus far }

   { OPEN 'STUDENT.GDS' for WRITE assign StuGrades }
   rewrite('STUDENT.GDS',StuGrades);
   FOR R:=1 TO rof DO
      write ( StuGrades, grades[R] )
END{ fclose }{ CLOSE(StuNdx); CLOSE(StuGrades); };



PROCEDURE Initialize;
VAR
	i,rr	: integer;
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
   FOR rr:=2 TO MaxStudents DO
      grades[rr] := grades[1];

   { OPEN 'CON:' for WRITE assign console }		{open files=1}
   rewrite('CON:',console);

   { OPEN 'STUDENT.NDX' for READ assign StuNdx }	{open files=2}
   reset('STUDENT.NDX',StuNdx);

   IF eof(StuNdx) THEN BEGIN {create all files}
	writeln ( 'Please standby while I create data files ...' );
	   { OPEN 'STUDENT.NDX' for WRITE assign StuNdx }	{open files=2}
	rewrite('STUDENT.NDX',StuNdx);
	   { OPEN 'STUDENT.DAT' for WRITE assign StuFile }	{open files=3}
   	rewrite('STUDENT.DAT',StuFile);
	   { OPEN 'STUDENT.GDS' for WRITE assign StuGrades }	{open files=4}
   	rewrite('STUDENT.GDS',StuGrades);

	rof := 0;
	stucount := 0;
	taken := 10;	{ setup to 10 then can lower at any time }
	date := 'MM/DD/YY'
   END
   ELSE BEGIN { finish opening files and read record count }
	   { OPEN 'STUDENT.DAT' for READ assign StuFile }	{open files=3}
	reset('STUDENT.DAT',StuFile);
	   { OPEN 'STUDENT.GDS' for READ assign StuGrades }	{open files=4}
	reset('STUDENT.GDS',StuGrades);

	readln ( StuNdx, rof );
	readln ( StuNdx, date );
	readln ( StuNdx, stucount );	{ # of students in class }
	readln ( StuNdx, taken );	{ # of tests taken thus far }
	writeln;
	FOR rr:=1 TO rof DO BEGIN
	   write( chr(13), 'RECORD #', rr:1 );
	   read ( StuGrades, grades[rr] );
	   read ( StuFile:rr,student );    { create the B-tree in memory }
	   insert ( listhead,student.id,rr ){ INDEX ON student.id         }
	END;
	writeln
   END;

   IF rof>0 THEN BEGIN
      writeln;
      writeln ( 'There are ',rof:1,' records on file as of ', date )
   END;
   writeln;
   write ( 'ENTER TODAY''S DATE <MM/DD/YY>  ->');
   keyin(ch);
   if ord(ch)=13 then
      {accept date given}
   else begin
      date[1] := ch;
      write(ch);
      FOR i:=2 TO 8 DO BEGIN
         IF (i=3) or (i=6)
	    THEN ch := '/'
	    ELSE keyin(ch);
          write(ch);
          date[i] := ch
      END;
   end;
   writeln
END{ Initialize }{ CLOSE(StuNdx); CLOSE(StuGrades); };		{open files=2}



BEGIN	(*** MAIN PROGRAM ***)
   Initialize;
   more := true;
   WHILE more DO BEGIN
	writeln;
	Q('N(ew student, F(ind, C(hange, R(eport, L(ist, S(tats, Q(uit ...?',
		['N','C','F','R','L','S','Q'], command );
	CASE command of
	   'N':
	      ADD;
	   'C','F':
	      MODIFY;
	   'R':
	      report;
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

