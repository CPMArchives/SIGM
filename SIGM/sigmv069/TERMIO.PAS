{+++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+ TERMINAL IO DRIVERS SOURCE PROGRAM - UNMODIFIED   +}
{+ YOU MUST MODIFY THIS PROGRAM FOR YOUR APPLICATION +}
{+ AND RENAME THE MODIFIED PROGRAM "TERMIO.LIB"      +}
{+++++++++++++++++++++++++++++++++++++++++++++++++++++}

	{+ CONSTANT DEFINITIONS +}
CONST
  alphalen = 10;

	{+ TYPE DEFINITIONS +}
TYPE
  byte = 0..255;
  alpha = array [0..alphalen] of byte;

	{+ VARIABLE DEFINITIONS +}
VAR
      { first 5 bytes for some misc terminal values }
   DELMIS,		{ delay after other functions }
   DELCUS,		{ delay after moving cursor }
   X_OFF,		{ offset to add to column }
   Y_OFF,		{ offset to add to row }
   XY	     : BYTE;	{ flag for column/row or row/column }
	 { string sequences }
   CLRSCR,		{ CLEAR SCREEN }
   CUR, 		{ CURSOR ADDRESSING LEADIN STRING }
   eraeos,		{ CLEAR TO END OF SCREEN }
   eraeol,		{ CLEAR TO END OF LINE }
   HOME,		{ HOME UP CURSOR }
   LockKbd,		{ LOCK KEYBOARD }
   UnlockKbd,		{ UNLOCK KEYBOARD }
   LINDEL,	   { delete screen line containing cursor }
   LININS,	   { insert a blank line on screen }
   INVON,	   { turn on highlighting - inverse video }
   INVOFF,	   { turn off highlighting }
   CRSON,	   { SET CURSOR ON AND BLINKING }
   CRSOFF : ALPHA; { SET CURSOR DISPLAY OFF }


procedure writes( strng: alpha );
{ writes writes a string of type alpha to the console
  device. }
var	ix: byte;
begin
  for ix:=1 to strng[0] do
    write( chr(strng[ix]) );
end{ of writes };


Procedure Clear_Screen;
var	ix: byte;
begin
  writes( CLRSCR );
  for ix:=0 to DELMIS do {};
end;


Procedure gotoxy(x_coord, y_coord: byte);
var	ix: byte;
	x_pos, y_pos: byte;
begin
  X_POS := x_coord + X_OFF;
  Y_POS := y_coord + Y_OFF;
  IF ( XY=2 ) AND ( X_POS<31 ) THEN
    X_POS := X_POS + 96;
  writes( CUR );
  IF ( XY=1 ) OR ( XY=2 ) THEN
    write( CHR(X_POS), CHR(Y_POS) )
  ELSE
    write( CHR(Y_POS), CHR(X_POS) );
  for ix:=0 TO DELCUS do {};
end;


FUNCTION INITTERM: BOOLEAN;
{ RETURNS TRUE IF TERMINAL DATA FILE FOUND  }
{	  FALSE IF DATA FILE NOT FOUND!     }
TYPE	BFILE = FILE OF BYTE;
VAR	bx     : byte;
	termio : BFILE;

   procedure gets( var fb: BFILE; var strng: alpha );
   { gets a string of type alpha from the
     specified file of type BFILE. }
   var	   ix: byte;
   begin
     read( fb, strng[0] );	   { first byte is always length }
     for ix:=1 to strng[0] do
       read( fb, strng[ix] )
   end{ of gets };

begin
  { OPEN file TERMIO.FIL for READ assign TERMIO }
  reset('TERMIO.FIL', termio);
  if eof(termio) then { file does not exist }
     INITTERM := FALSE
  else begin
    INITTERM := TRUE;
    { first 5 bytes in this sequence }
    { strings must be read back in same sequence as were written }
    read( termio,
	      BX,	 { length byte }
	      DELMIS, DELCUS, X_OFF, Y_OFF, XY );
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
  end{else}
end{ of INITTERM }{ CLOSE(termio); };



 INVOFF );
    gets( termio, CRSON );
    gets( termio, CRSOFF );
  end{else}
end{ of INITTERM }{ CLOSE(term