PROGRAM CONFERENCE;
(*********************************************************
 *							 *
 *  		   CHAIRING A CONFERENCE		 *
 *							 *
 *	VERSION						 *
 *	 1.0 	8 Nov 78				 *
 *		 ELECTRONIC DESIGN # 23			 *
 *	 1.1	October 1979				 *
 *		 Entered by R.E. Penley			 *
 *		 PASCAL/Z by ITHACA INTERSYSTEMS	 *
 *		 Modifications were made to the		 *
 *		 following procedures:			 *
 *		  INPUT, CHECK, CONVERT, & CORRECT	 *
 *	 1.2	9 Oct 79				 *
 *		 Added Instructions			 *
 *	 1.3	13 Oct 79				 *
 *		 Modified CHECK to invalidate illegal	 *
 *		 entries by Negating the current entry	 *
 *							 *
 *********************************************************)
CONST
  TTYWIDTH = 80;
  PAPERLINES = 24;

TYPE
  DAYTYPE = (MONDAY, TUESDAY, WEDNESDAY);
  WORD    = ARRAY [1..10]  OF CHAR;

VAR
  TOPIC : ARRAY [MONDAY..WEDNESDAY, 1..4]  OF INTEGER;
  SUBJ	: ARRAY [MONDAY..WEDNESDAY, 1..4]  OF WORD;
  DAY		: DAYTYPE;
  CH		: CHAR;
  J		: INTEGER;
  ERROR, DONE	: BOOLEAN;
(*********************************************************)
PROCEDURE INIT;
BEGIN
  FOR DAY:=MONDAY TO WEDNESDAY DO
    FOR J:=1 TO 4 DO TOPIC [DAY, J] := 0
END;

PROCEDURE INPUT;
VAR
   A1,B1,C1,D1 : INTEGER;

	PROCEDURE PUT( DAY0 : DAYTYPE);
	(* Read Values into A1,B1,C1 & D1.
	   Data must be in the range 1..6  *)
	BEGIN
	  READLN(A1, B1, C1, D1);
	  WRITELN;
	  IF (A1<1) OR (A1>6) OR (B1<1) OR (B1>6) OR
	     (C1<1) OR (C1>6) OR (D1<1) OR (D1>6)
	     THEN    DONE := FALSE
	     ELSE    BEGIN
			DONE := TRUE;
			TOPIC [DAY0, 1] := A1;
			TOPIC [DAY0, 2] := B1;
			TOPIC [DAY0, 3] := C1;
			TOPIC [DAY0, 4] := D1
		       END(* IF *)
	END(* PUT *);

BEGIN (*** Input ***)
  WRITELN;
  REPEAT
    WRITE('Enter Topics for Monday    >');
    PUT(MONDAY)
  UNTIL DONE;
   REPEAT
     WRITE('Enter Topics for Tuesday   >');
     PUT(TUESDAY)
   UNTIL DONE;
     REPEAT
       WRITE('Enter Topics for Wednesday >');
       PUT(WEDNESDAY)
     UNTIL DONE
END(* INPUT *);

PROCEDURE CLEAR;
BEGIN WRITE( CHR(26) ) END;

PROCEDURE SPACE(WIDTH : INTEGER);
BEGIN WRITE(' ':WIDTH) END;

PROCEDURE INSTRUCT;
BEGIN
CLEAR;
WRITELN;WRITELN;
SPACE(15);WRITELN('Conference Scheduling Program');
WRITELN;WRITELN;
WRITELN('   This program will prepare a schedule for a three');
WRITELN('day conference. You may list four topics for each');
WRITELN('day of the conference. There will be a total of six');
WRITELN('topics. Each topic should be scheduled twice.');
WRITELN('   Any entry scheduled more than twice will be rejected.');
WRITELN('A program will be printed out leaving blanks where');
WRITELN('entries were rejected. You may then input your corrections.');
WRITELN('   Once you''ve made all corrections, the final schedule');
WRITELN('will be printed out and your conference is ready.');
WRITELN;
WRITELN('   When prompted enter four numbers for the day''s topics');
SPACE(12);WRITELN( '1..Software');
SPACE(12);WRITELN( '2..Hardware');
SPACE(12);WRITELN( '3..Systems');
SPACE(12);WRITELN( '4..Production');
SPACE(12);WRITELN( '5..Sales');
SPACE(12);WRITELN( '6..Repairs');
WRITELN;WRITELN
END;

PROCEDURE CONVERT;
(*	CONVERTS TOPIC # TO ASCII SUBJECT
	INVALID ENTRIES ARE BLANKED OUT
*)
VAR	DAYSTOPICS : INTEGER;
BEGIN
  FOR DAY:=MONDAY TO WEDNESDAY DO
    FOR J:=1 TO 4 DO
     BEGIN
	DAYSTOPICS := TOPIC [DAY,J] ;
  	CASE DAYSTOPICS OF
	   1:	SUBJ [ DAY,J ] :='SOFTWARE  ';
	   2:	SUBJ [ DAY,J ] :='HARDWARE  ';
	   3:	SUBJ [ DAY,J ] :='SYSTEMS   ';
	   4:	SUBJ [ DAY,J ] :='PRODUCTION';
	   5:	SUBJ [ DAY,J ] :='SALES     ';
	   6:	SUBJ [ DAY,J ] :='REPAIRS   ';
	ELSE:	(* All other cases are invalid *)
		SUBJ [ DAY,J ] :='          '
	END(* CASE *)
     END(* FOR DAY,J *)
END(* CONVERT *);

PROCEDURE CORRECT;
VAR	LINE	: WORD;

	PROCEDURE CORRECTONE( DAY1 : DAYTYPE);
	(* Read Values into B & C.
	   Data must be in the range 1..6  *)
	VAR	B, C : INTEGER;
	BEGIN
	  WRITE('       Session #   >');
	  READLN(B);
	  WRITE('       Topic       >');
	  READLN(C);
	  TOPIC [DAY1, B] := C
	END;

BEGIN
  WRITELN;
  WRITELN('Blanks indicate illegal entries.');
  WRITELN('Enter Carriage return when done.');
  DONE := FALSE;
  REPEAT
    LINE := '          ';
    WRITELN;
    WRITE('Enter:  Day        >');
    READLN(LINE);
     IF LINE[1] = ' '  (* CARRIAGE RETURN WILL RETURN A NULL *)
	THEN DONE := TRUE
	ELSE CASE LINE[1] OF
	      'M':	CORRECTONE(MONDAY);
	      'T':	CORRECTONE(TUESDAY);
	      'W':	CORRECTONE(WEDNESDAY);
	      ELSE:	(* CHECK THAT THE TURKEY
			   DIDN'T ENTER SOMETHING ELSE *)
			DONE := TRUE
      	     END(* CASE CH *)
  UNTIL DONE;
WRITELN
END(* CORRECT *);

PROCEDURE CHECK;
CONST
	VALID = 2; (* MAX NUMBER OF VALID TOPICS ALLOWED *)
VAR
	NUM : ARRAY [1..6]  OF INTEGER;
	INDEX : INTEGER;
BEGIN
  ERROR:=FALSE;
  FOR J:=1 TO 6 DO   (* INITIALIZE TOPIC COUNTER *)
	 NUM [J] :=0;
  FOR DAY:=MONDAY TO WEDNESDAY DO
    FOR J:=1 TO 4 DO
      BEGIN
	INDEX := ABS( TOPIC[DAY,J] );
	NUM [ INDEX ] := NUM [ INDEX ] +1;
	IF NUM [ INDEX ] > VALID
	  THEN  BEGIN
		  ERROR:=TRUE;
		  (* INVALIDATE ILLEGAL ENTRIES BY NEGATION *)
		  TOPIC [DAY, J] := -TOPIC [DAY, J];
		END(*IF*)
      END(*FOR DAY,J*);
  IF ERROR THEN  CONVERT
END(* CHECK *);

PROCEDURE LIST;
BEGIN
  WRITELN;WRITELN;
  SPACE(8);WRITELN('Monday':15, 'Tuesday':14, 'Wednesday' );
  WRITELN;WRITELN;
  FOR J:=1 TO 4 DO
    BEGIN
      WRITE(J:2, '     ');
      FOR DAY:=MONDAY TO WEDNESDAY DO
	   WRITE(SUBJ [DAY, J] :15);
      WRITELN
      END(* FOR J *);
	(* SCROLL UP THE PROGRAM PRINTOUT *)
  IF NOT ERROR THEN
	FOR J:=(PAPERLINES-10) DOWNTO 0 DO WRITELN
END(* LIST *);
(*********************************************************)
BEGIN	(*** Main program ***)
  INIT;
  INSTRUCT;
  INPUT;
  CONVERT;
  CHECK;
  IF ERROR THEN
	REPEAT
	  LIST;
	  CORRECT;
	  CONVERT;
	  CHECK
	UNTIL NOT ERROR;
  WRITELN(' Schedule is good');
  FOR J:=1 TO 2500 DO; (* SHORT DELAY *)
  LIST
END(*** CONFERENCE ***).
