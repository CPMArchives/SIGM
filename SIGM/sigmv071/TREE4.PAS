{       Pascal/Z compiler options               }
{$C- <<<control-c keypress checking OFF>>>}
{$M- <<<int mult & divd error checking OFF>>>}
{$F- <<<floating point error checking OFF>>>}

PROGRAM BTREE;
{
Program title:	Binary Trees Demo
Written by:
Date written:	November 1981

Last edited:	11/20/81 rep

Pascal compiler: Pascal/Z vers 4.0, Ithaca Intersystems, Inc.

Summary:	Maintain a sorted list in a binary tree

Bibliography:
  GROGONO, P.: Programming in PASCAL, Addison-Wesley Publishing Co.,
	Reading, MA.
  TENENBAUM, A. and AUGENSTEIN, M.: Data Structures Using Pascal,
	Prentice-Hall, Englewood Cliffs, N.J. 07632
  WIRTH, N.: Algorithms + Data Structures = Programs, Prentice-Hall,
	Englewood Cliffs, N.J. 07632
}
CONST
  default = 80;
  vers    =  4; { PROGRAM VERSION NUMBER }

TYPE
  alpha    = packed array [1..10] of char;
  int      = integer;
  str0     = string 0;
  shorty   = string 40;
  dstring  = string default;
  str255   = string 255;

  PersonDetails = RECORD
		    Name,		{ KEY FIELD }
		    Company,
		    address,
		    city,
		    state,
		    zip,
		    salary : shorty;
   	          END;

  apointer  = ^PERSON;

  PERSON = RECORD
	        details : PersonDetails;
		Left,
		Right  : apointer
	     END;


VAR
  bell		: char;
  Command	: CHAR;
  con_wanted,
  tty_wanted    : boolean;
  answer        : shorty;	{ Console inputs here }

  KEY,				{ Name field is the "KEY" field }
  New_Salary,
  New_Company,
  New_address,
  New_City,
  New_State,
  New_Zip        : shorty;

  STDOUT        : FILE OF PersonDetails;

  Employee	: apointer;



function length( x: str255 ): int; external;

function index( x,y: str255 ): int; external;

procedure setlength( var x:str0; y: int ); external;


PROCEDURE InitTree( VAR Employee : apointer );
{  initialize the tree to empty  }
BEGIN
  Employee := NIL
END{of InitTree};


PROCEDURE INSERT( VAR Employee : apointer;
		      key : shorty );
{ insert key into the tree. If it }
{ is there already then do nothing }
BEGIN
  IF Employee = NIL THEN BEGIN
    NEW(Employee);
    WITH Employee^, details DO BEGIN
	Name    := key;
	Salary  := New_Salary;
	Company := New_Company;
	address := New_address;
	City    := New_City;
	State   := New_State;
	zip     := New_Zip;
	left    := NIL;
	right   := NIL
    END{WITH}
  END
  ELSE IF key = Employee^.details.Name THEN
    WRITELN( bell, key,' already in data file' )
  ELSE IF key < Employee^.details.Name THEN
    Insert( Employee^.left, key )
  ELSE IF key > Employee^.details.Name THEN
    Insert( Employee^.right, key )
END{of INSERT};


PROCEDURE DeleteLeftMost( VAR Employee : apointer;
			  VAR DeleteName : shorty );
{ delete the leftmost node in the tree and }
{  returns its value in DeleteName	   }
BEGIN
  IF Employee^.Left <> NIL THEN
    DeleteLeftMost( Employee^.Left, DeleteName )
  ELSE BEGIN
    DeleteName := Employee^.details.Name;
    Employee := Employee^.right
  END
END{of DeleteLeftMost};


PROCEDURE DeleteRoot( VAR Employee : apointer );
{ deletes the root of the nonempty tree by replacing it  }
{ by its successor (or child) if it has only one, or     }
{ replacing its value by that of the leftmost descendant }
{ of the rightmost subtree.				 }
VAR
  DeletedName : shorty;
BEGIN
  IF Employee^.Left = NIL THEN
    Employee := Employee^.right
  ELSE IF Employee^.right = NIL THEN
    Employee := Employee^.Left
  ELSE BEGIN
    DeleteLeftMost( Employee^.right, DeletedName );
    Employee^.details.Name := DeletedName
  END
END{of DeleteRoot};


PROCEDURE Delete( VAR Employee : apointer;
		      key : shorty );
{ delete key from the tree--if it is not }
{ in the tree, do nothing		  }
BEGIN
  IF Employee = NIL THEN
    WRITELN ( bell, key, ' not in data file' )
  ELSE IF key = Employee^.details.Name THEN
    DeleteRoot( Employee )
  ELSE IF key < Employee^.details.Name THEN
    Delete(Employee^.Left, key )
  ELSE IF key > Employee^.details.Name THEN
    Delete( Employee^.right, key )
END;


PROCEDURE DISPLAY( Employee: apointer );
BEGIN
  WITH Employee^.details do begin
    writeln( Name );
    if length( Company ) > 0 then writeln( Company );
    if length( address ) > 0 then writeln( address );
    writeln( City, ', ', State, ' ', Zip );
    writeln
  end
END{of DISPLAY};


PROCEDURE Preorder( Employee : apointer );
{  prints data from left side of tree to right  } 
BEGIN
  IF Employee <> NIL THEN BEGIN
    DISPLAY( Employee );	{visit the root}
    Preorder( Employee^.Left );	{traverse the left subtree}
    Preorder( Employee^.Right )	{traverse the right subtree}
  END
END{of preorder};


PROCEDURE Inorder( Employee : apointer );
{  prints data outer to inner of tree  }
BEGIN
  IF Employee <> NIL THEN BEGIN
    Inorder( Employee^.Left );	{traverse the left subtree}
    DISPLAY( Employee );	{visit the root}
    Inorder( Employee^.Right )	{traverse the right subtree}
  END
END{of inorder};


PROCEDURE Postorder( Employee : apointer );
{  prints data from leaves first then branchs  }
BEGIN
  IF Employee <> NIL THEN BEGIN
    Postorder( Employee^.Left );	{traverse the left subtree}
    Postorder( Employee^.Right );	{traverse the right subtree}
    DISPLAY( Employee );		{visit the root}
  END
END{of postorder};


{****************************}
{***   UTILITY ROUTINES   ***}
{****************************}


PROCEDURE SIGNON;
VAR	IX : 1..24;
BEGIN
  FOR IX:=1 TO 24 DO WRITELN;
  WRITELN( ' ':15, 'NAME AND ADDRESS ENTRY PROGRAM Version #', vers );
  FOR IX:=1 TO 4 DO WRITELN;
{    SIGNON TEXT GOES HERE    }
END{of SIGNON};


PROCEDURE MENU;
BEGIN
  WRITELN;
  WRITELN;
  WRITELN( ' ':12, '1  -  INSERT MODE' );
  WRITELN( ' ':12, '2  -  DELETE MODE' );
  WRITELN( ' ':12, '3  -  DISPLAY MODE' );
  WRITELN( ' ':12, '9  -  TERMINATE' );
  WRITELN;
  CASE Command OF
   '1': WRITELN( 'MODE=INSERT' );
   '2': WRITELN( 'MODE=DELETE' );
   '3': WRITELN( 'MODE=DISPLAY' );
  ELSE: WRITELN
  END{CASE}
END{of MENU};


FUNCTION toupper( ch: CHAR ): CHAR;
BEGIN
  IF ( 'a'<=ch ) AND ( ch<='z' ) THEN ch := CHR(ORD(ch) - 32);
  toupper := ch
END{of toupper};


PROCEDURE INPUT( txt: dstring; VAR answer: shorty );
BEGIN
  WRITE( txt );
  READLN( answer );
END{of INPUT};


PROCEDURE LIST;
VAR	ch : CHAR;
	OUTPUT : TEXT;
BEGIN
  WRITELN( 'Output to C(onsole or P(rinter? ' );
  readln( ch );
  con_wanted := ( toupper(ch)='C' );
  tty_wanted := ( toupper(ch)='P' );
  { one or the other but not both }
  if tty_wanted then con_wanted := false;
  if NOT (con_wanted OR tty_wanted) then
    { listing := false }
  else begin
    { listing := true; }
    if con_wanted then REWRITE( 'CON:', OUTPUT );
    if tty_wanted then REWRITE( 'LST:', OUTPUT );
  end;
  WRITELN; WRITELN;
  Inorder( Employee );
  if con_wanted then begin
    writeln;
    WRITE( bell, 'PRESS RETURN TO CONTINUE ' );
    READLN( ch );
  end
END{of LIST}{ CLOSE( OUTPUT ); };
  
  


BEGIN{ MAIN PROGRAM BLOCK }
  InitTree( Employee );
  bell := chr(7);
  Command := ' ';
  SIGNON;
  MENU;
  INPUT( 'COMMAND: ', answer );
  Command := toupper( answer[1] );
  WHILE Command <> '9' DO BEGIN
    IF Command IN ['1','2','3'] THEN BEGIN
      WRITELN;
      CASE Command  OF
        '1': begin { INSERT MODE }
	     REPEAT
		writeln( 'ENTER:' );
		INPUT('1 - NAME <Key field>               !', key );
		INPUT('2 - Salary amount <12000>          !', New_Salary );
		input('3 - Company Name <address line 1>  !', New_Company );
		input('4 - Address line 2                 !', New_address );
		input('5 - City                           !', New_City );
		input('6 - State <e.g. MD>                !', New_State );
		input('7 - Zip Code                       !', New_Zip );
		writeln;
		write( 'DATA OK? ' );
		readln( answer );
	      UNTIL toupper(answer[1])<>'N';
	      INSERT( Employee,key );
	     end;

        '2': begin { DELETE MODE }
	     REPEAT
	       INPUT( 'Enter NAME <Key field>      --> ',key );
	       writeln;
	       writeln( 'Deleting > ', key );
	       write( 'OK? ' );
	       readln( answer );
	     UNTIL toupper(answer[1])<>'N';
	     Delete( Employee,key );
	     end;

	'3': begin { LIST MODE }
	       LIST;
	     end
      END{CASE}
    END{IF};
    MENU;
    INPUT( 'COMMAND: ', answer );
    Command := toupper( answer[1] );
  END{WHILE Command <> '9'}
END{of PROGRAM BTREE}.
