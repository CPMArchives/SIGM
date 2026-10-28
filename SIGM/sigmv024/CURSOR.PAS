(*****************************************************
*
*	SD SALES 8024 XY CURSOR CONTROL PROGRAM
*
*	This is a demo of the SD Sales video board
*  8024 XY cursor control.  The main procedure will
*  be extracted and put in my library for use in future
*  programs that I write. But this prgram demonstrates
*  just how it works. This type of XY cusor positioning
*  is only good for inserting ASCII characters but the
*  8024 has the ability to be programed with graphic
*  characters so this is a good first step.
*
*  Written by Charlie Foster, Dec 80
*  Donated to the Pascal/Z Users Group
*****************************************************)


PROGRAM XYDEMO;

VAR
             X,Y : INTEGER;
  	    CR,Z : CHAR;

PROCEDURE CURSOR (X,Y : INTEGER; Z : CHAR );
(*This subroutine is designed to input the proper series
of characters to the SD SALES Video Board 8024 to give
XY Cursor. It needs ESC=XYZ where Z=character to print.
It has a offset to worry about so this subroutine needs
to take care everything. X=row, Y=column, Z=character  *)

VAR
            CODE : STRING 5;	(*gets output to video*)
  C1,C2,C3,C4,C5 : CHAR;	(*elements of CODE*)

BEGIN
	Y := Y + 31;		(*add offset*)
	X := X + 31;		(*add offset*)
	C1 := CHR(27);		(*ESC character*)
	C2 := CHR(61);		(* = character*)
	C3 := CHR(X);		(*integer*)
	C4 := CHR(Y);		(*integer*)
	C5 := Z;		(*any ASCII character*)
	CODE := C1;		(*string it all togeather*)
	APPEND(CODE,C2);
	APPEND(CODE,C3);
	APPEND(CODE,C4);
	WRITE(CODE);		(*write position to Video*)
	WRITE(C5);		(*can call anything here*)
END;

BEGIN	(* MAIN --This is for demo purposes only *)

  REPEAT
	WRITE(CHR(26));		(* clears screen *)
	WRITELN(' ':20, 'CHARLIES CURSOR TEST');
	WRITELN(' ':20, '(to repeat test,hit CR)');
	WRITELN(' ':20, '(to quit, hit control C)');
	WRITELN;
	WRITE ('ENTER row number(1 thru 80)-->  ');
	READLN(X);
	WRITE ('ENTER column number(1 thru 24)-->  ');
	READLN(Y);
	WRITE ('ENTER any ASCII character-->  ');
	READLN(Z);
	CURSOR(X,Y,Z);
	READLN(CR);
	UNTIL Z = '&';
END.

