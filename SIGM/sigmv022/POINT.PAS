
(******************************************************
*
*		POINTERS
*
*	This program will input a list of names, store
*	them in a linked list, output the list, release
*	the storage and end.  It is a demo program but
*	can be expanded to just about anything.
*
*	Extracted from the Pascal/Z manual, page 49.
*
*	Editor for this program was Charlie Foster
*	June 1980
*******************************************************)

PROGRAM pointers;

TYPE    link    = ^namerec;
	namerec = RECORD
			name : string 20;
			next : link
			END;

VAR	m1    : link;	{ FOR STORING THE MARK }
	first : link;	{ FOR FINDING THE FIRST NAME }
	last  : link;	{ FOR FINDING THE LAST NAME }
	x     : link;	{ FOR CHASING THROUGH THE LIST }

BEGIN
	MARK(m1);	{ MARK SETS POINTER TO TOP/HEAP }
	first := nil;	{ 1st NAME POINTER=0 }
	REPEAT
		IF first = nil THEN
		   BEGIN
			NEW(last);	{ ALLOCATE A NEW REC }
			first := last
		   END
		ELSE
		   BEGIN
			NEW(last^.next);
			last := last^.next
		   END;
		WRITE('Name (* = Done )');
		READLN(last^.name);	{ GET PERSONS NAME }
		last^.next := nil
	UNTIL last^.name ='*';
{ PRINT OUT THE NAMES }
	x := first;
	WHILE x^.next <> nil DO
	   BEGIN
		WRITELN(x^.name);
		x := x^.next
	   END;
{ RESTORE THE STORAGE }
	RELEASE(m1);
END.
