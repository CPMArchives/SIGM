(*************************************************
:
:		HANOI PROGRAM
:
:	This one came in and got mixed up with a bunch
:  of other programs and since it did not have a comment
:  section I don't know who to give credit to.  So if
:  anyone recognizes his own style, drop me a line and
:  I will update this spot to give you proper credit.
:	 I included it because it is a excellent example
:  of recursive procedures.  It nests deeply and demon-
:  strates how local versus global variable are keep
:  separate.  
****************************************************)

PROGRAM HANOI;
VAR	TOTAL : INTEGER;

PROCEDURE MOVETOWER(HEIGHT,
		    FROMNEEDLE,
		    TONEEDLE,
		    USINGNEEDLE : INTEGER);

	PROCEDURE MOVEDISK(TAKEOFF, PUTON : INTEGER);
	BEGIN
	  WRITELN(TAKEOFF, '->', PUTON)
	END; (* MOVEDISK *)

BEGIN (* MOVETOWER *)
  IF HEIGHT > 0
    THEN BEGIN
	   MOVETOWER(HEIGHT-1, FROMNEEDLE, USINGNEEDLE, TONEEDLE);
	   MOVEDISK(FROMNEEDLE, TONEEDLE);
	   MOVETOWER(HEIGHT-1, USINGNEEDLE, TONEEDLE, FROMNEEDLE);
	 END
END; (* MOVETOWER *)

BEGIN (*  MAIN PROGRAM  *)
  WRITE('ENTER NUMBER OF DISKS?');
  READ(TOTAL);
  WRITELN;
  MOVETOWER( TOTAL, 1, 3, 2)
END.  (*  HANOI  *)
