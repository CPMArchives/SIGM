
(*************************************************************
*
*		DEMO PROGRAM FOR VARIANT RECORDS
*
*  Donated by Ray Penley, June 1980
*
*************************************************************)


PROGRAM VARIANT;

TYPE
  NUM = RECORD
	  CASE INTEGER OF
	  1:  (C1,C2,C3,C4 : CHAR);
	  2:  (I1,I2       : INTEGER);
	  3:  (R	   : REAL)
	END;
VAR
  Q : NUM;

BEGIN
  Q.C1 := 'A';
  Q.C2 := 'F';
  Q.C3 := 'M';
  Q.C4 := '6';
  WRITELN('!----!----!----!----!----!----!');
  WRITELN('CHARACTER');
  WRITELN(Q.C1, Q.C2, Q.C3, Q.C4);
  WRITELN('INTEGER');
  WRITELN(Q.I1, Q.I2);
  WRITELN('REAL');
  WRITELN(Q.R);
END.
