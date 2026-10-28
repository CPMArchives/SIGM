(*******************************************************
*
*		CHARPLOT PROGRAM
*
*	I understand this came from a text book.  It
*  isn't all that great but it will give you some ideas
*  on banners for your programs. So look it over and
*  come up with something better and send it in.
*
*  Donated July, 1980
*
******************************************************)

PROGRAM CHARPLOT;
CONST
  WIDTH = 25;
  HEIGHT = 11;
TYPE
  DX = -WIDTH..+WIDTH;
  DY = -HEIGHT..+HEIGHT;
VAR
  PAGE : ARRAY[DY] OF PACKED ARRAY[DX] OF CHAR;
  X : DX;
  Y : DY;

PROCEDURE RECT(H,W : INTEGER; CH : CHAR);
VAR
  I,XMIN,XMAX : DX;
  J,YMIN,YMAX : DY;
BEGIN
  XMAX:=W;	YMAX:=H;
  XMIN:=-W;	YMIN:=-H;
  (* MARK TOP & BOTTOM OF RECTANGLE *)
  FOR I:=XMIN TO XMAX DO
  BEGIN
	PAGE[YMAX,I]:=CH;
	PAGE[YMIN,I]:=CH;
  END;
  (* MARK SIDES *)
  FOR J:=YMIN TO YMAX DO
  BEGIN
	PAGE[J,XMAX]:=CH;
	PAGE[J,XMIN]:=CH;
  END;
END;  (* RECT *)

PROCEDURE BLANKPAGE;
VAR
  I : DX;
  J : DY;
BEGIN
  FOR J:=-HEIGHT TO HEIGHT DO
    FOR I:=-WIDTH TO WIDTH DO PAGE[J,I]:=' ';
END;

BEGIN	(* MAIN PROGRAM *)
  BLANKPAGE;
  RECT(11,10,'*');
  RECT(5,25,'#');
  RECT(8,15,'&');
  FOR Y:=HEIGHT DOWNTO -HEIGHT DO
    BEGIN
	FOR X:=-WIDTH TO WIDTH DO WRITE(PAGE[Y,X]);
	IF Y > -HEIGHT THEN WRITELN;
    END;
END.
