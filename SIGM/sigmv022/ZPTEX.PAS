(****************************************************************)
(*								*
 *  PROGRAM TITLE:	Z - P R I N T   T E X T			*
 *								*
 *  WRITTEN BY:		Raymond E. Penley			*
 *  DATE WRITTEN:	17 NOV 1979				*
 *								*
 *  PROGRAM SUMMARY:						*
 *								*
 * A very simple text formatter program.			*
 *								*
 * Command Directives:						*
 *	^P	New Paragraph.					*
 *	^$	End of Text.					*
 *	^I	Indent/space.					*
 *	^N	New Line but not New Paragraph.			*
 *	^B	Break/Pause. Continue on any console input.	*
 *								*
 * NOTE - Command directives may be in either upper or		*
 *	  lower case.						*
 *								*
 * MODIFICATION RECORD:						*
 *	  1.0	19 Nov 79 Original Program 'PWORD.PAS'		*
 *		An attempt to extract "WORDS" from text		*
 *		and print them.					*
 *	  1.1  25 Nov 79 -Analyze, Bump, ProcessCommand		*
 *		 Newline, Page					*
 *	  1.2  26 Nov 79 -From the the Program Text Formatter(1)*
 *		Adjustline, Appendblank, Appendword,		*
 *		Printline, Roomfor, StartParagraph		*
 *	  1.3  28 Nov 79					*
 *		-Added File selection from the console		*
 *	  1.4  19 Aug 80 -Slight mods to program.		*
 *		-Rewrote READWORD.				*
 *								*
 *	(1)PASCAL, An Introduction to				*
 *	   Methodical Programming				*
 *	   Authors: W.Findlay & D.A. Watt			*)
(****************************************************************)
PROGRAM ZPTEX;
CONST
 MAXLENGTH 	= 255;	(* GROSS MAXIMUM LINE LENGTH *)
 MAXWORDLENGTH	= 30;	(* GET THOSE REALLY BIG WORDS *)
 MAXLINEWIDTH	= 80;	(* SET TO VIDEO TERMINAL WIDTH  *)
 MINLINEWIDTH	= 30;	(* It isn't a co-incidence that Max Word Length *)
			(* and Min Line Width are equal.		*)
 SPACE 		= ' ';
TYPE
  BYTE = 0..255;	(* POSITIVE SINGLE BYTE INTEGER *)
  STRING14   = PACKED ARRAY [ 1..14 ] OF CHAR;
  STRINGTYPE = RECORD
		 LENGTH : 0..MAXLENGTH;
		 IMAGE  : PACKED ARRAY [ 1..MAXLENGTH ] OF CHAR
	       END;
VAR
  BLANKINDEX	: 0..MAXWORDLENGTH;
  DIRCH		: CHAR;	(* Char to mark a Command *)
  FATALERROR	: BOOLEAN;
  TEXTFILE	: TEXT;
  FILEID	: STRING14;	(* FILE NAME *)
  INDENT	: BYTE;
  LINE		: PACKED ARRAY [ 1..MAXLINEWIDTH ] OF CHAR;
  LINEWIDTH	: BYTE;
  POS		: BYTE; (* GLOBAL INDEXER *)
  POSITION	: 0..MAXLINEWIDTH;
  TAB		: CHAR;	(* ASCII TAB character *)
  WORD		: STRINGTYPE;

	(**************************)

PROCEDURE CLEAR(* OUTPUT *);
VAR
  I: BYTE;
BEGIN
  FOR I:=1 TO 24 DO WRITELN;
END; (* CLEAR *)

PROCEDURE SKIP( LINES : BYTE );
VAR
  I: BYTE;
BEGIN
  FOR I := 1 TO LINES DO WRITELN
END;

PROCEDURE PRINTLINE;
BEGIN
  FOR POS:=1 TO POSITION DO WRITE( LINE[ POS ]);
  WRITELN
END;

PROCEDURE STARTLINE;
BEGIN
  POSITION := 0
END;

PROCEDURE READWORD;
VAR	CH: CHAR;

	PROCEDURE GETC(VAR CH: CHAR);
	BEGIN
	  IF NOT EOF(TEXTFILE) THEN
	     READ(TEXTFILE, CH);
	  (* Classify the character just read *)
	  IF CH=TAB THEN CH := SPACE;
	  IF EOF(TEXTFILE) THEN
	     CH := SPACE;
	END;

(*$C- [Control-C OFF]**********************************)

BEGIN
  CH := SPACE;
  WHILE (NOT EOF(TEXTFILE)) AND (CH=SPACE) DO (* skipblanks *)
    GETC(CH);
  WITH WORD DO BEGIN
    LENGTH := 0;
    WHILE (NOT EOF(TEXTFILE)) AND (CH<>SPACE) DO
      BEGIN (* accept only non space *)
	IF LENGTH < MAXWORDLENGTH THEN
	  BEGIN (* store the char *)
	    LENGTH := LENGTH + 1;
	    IMAGE[ LENGTH ] := CH;
	  END;
	GETC(CH);
      END; (* WHILE *)
(**
	WE NOW HAVE ONE "WORD" IN WORD.IMAGE
	WORD.LENGTH IS THE LENGTH OF THIS WORD
**)
   IF LENGTH >= BLANKINDEX THEN
     BLANKINDEX := LENGTH
   ELSE
     REPEAT
       IMAGE[ BLANKINDEX ] := SPACE;
       BLANKINDEX := PRED(BLANKINDEX);
     UNTIL BLANKINDEX=LENGTH;
  END; (* WITH *)
END; (* READWORD *)

PROCEDURE ANALYZE;
VAR
  PAUSE: CHAR;

	PROCEDURE APPENDWORD;
	BEGIN
	  FOR POS:=1 TO WORD.LENGTH DO
	    BEGIN
	      POSITION := POSITION +1;
	      LINE[ POSITION ] := WORD.IMAGE[ POS ]
	    END
	END;

	PROCEDURE APPENDBLANK;
	BEGIN
	  POSITION := POSITION +1;
	  LINE[ POSITION ] := SPACE
	END;

	FUNCTION ROOMFOR( NMROFCHARS: INTEGER ): BOOLEAN;
	BEGIN
	  ROOMFOR := (POSITION + NMROFCHARS) <= LINEWIDTH
	END;

	PROCEDURE ADJUSTLINE;
	VAR
	  EXTRABLANKS,
	  NMROFGAPS,
	  WIDENING,
	  LEFTMOST,
	  RIGHTMOST: 0..MAXLINEWIDTH;
	BEGIN
	  (*	Make LeftMost the POSition of	*
	   *	the LeftMost non:blank		*)
	  LEFTMOST := 1;
	  WHILE LINE[ LEFTMOST ] = SPACE DO
	    LEFTMOST := SUCC(LEFTMOST);
	  (*	Make RightMost the POSition of	*
	   *	the RightMost non-blank		*)
	  RIGHTMOST := POSITION;
	  WHILE LINE[ RIGHTMOST ] = SPACE DO
	    RIGHTMOST := PRED(RIGHTMOST);
	  (*	Make NMROFGAPS the number of inter-word gaps *)
	  NMROFGAPS := 0;
	  FOR POS := LEFTMOST TO RIGHTMOST DO
	    IF (LINE[ POS ] = SPACE) THEN NMROFGAPS := NMROFGAPS +1;
	  EXTRABLANKS := LINEWIDTH - RIGHTMOST;
	  FOR POS := 1 TO RIGHTMOST DO
	    IF (POS > LEFTMOST) AND (LINE[ POS ] = SPACE) THEN
	      BEGIN (* this Char is an inter-WORD gap *)
	        WIDENING := EXTRABLANKS DIV NMROFGAPS;
	        WRITE( SPACE:(WIDENING+1) );
	        EXTRABLANKS := EXTRABLANKS - WIDENING;
	        NMROFGAPS := NMROFGAPS -1
	      END(* If *)
	    ELSE
	      WRITE( LINE[ POS ] );
	  WRITELN
	END; (* ADJUSTLINE *)

	PROCEDURE NEWLINE;
	(*
	    Print the current LINE without adjustment and
	    move to the next line.
	*)
	BEGIN
	  PRINTLINE;
	  STARTLINE
	END;

	PROCEDURE STARTPARAGRAPH;
	(*
	   Write the current LINE without adjustment
	 *)
	BEGIN
	  PRINTLINE;
	  WRITELN;
	  FOR POSITION := 1 TO INDENT DO
	    LINE[ POSITION ] := SPACE;
	  POSITION := INDENT
	END;

	FUNCTION VALIDCOMMAND( THISCHAR : CHAR ) : BOOLEAN;
	BEGIN
	  VALIDCOMMAND :=
		 (THISCHAR IN [ '$','p','P','i','I','n','N','b','B' ] )
	END;

	PROCEDURE BUMP;
	BEGIN
	  IF (POSITION < LINEWIDTH) THEN
	    BEGIN
	    POS := 0;
	    REPEAT
	      POS := POS + 1;
	      APPENDBLANK
	    UNTIL (POS = INDENT) OR (POSITION = LINEWIDTH);
	    END(* IF *)
	END; (* BUMP *)

BEGIN (*** ANALYZE ***)
  (* All Command Directives must start a Word *)
  IF WORD.IMAGE[ 1 ] = DIRCH THEN
    BEGIN
      IF VALIDCOMMAND( WORD.IMAGE[ 2 ] ) THEN
	BEGIN
	  CASE WORD.IMAGE[ 2 ] OF
	      '$':	FATALERROR := TRUE;(* Force termination *)
	      'P','p':	STARTPARAGRAPH;
	      'I','i':	BUMP;
	      'N','n':	NEWLINE;
	      'B','b':	BEGIN
			NEWLINE;
			READLN( PAUSE )
			END
	  END (* CASE WORD.IMAGE *)
	END(* IF VALIDCOMMAND *)
    END(* IF *)
  ELSE
    (* Output the WORD followed by a blank, right-adjusting
       the old Line and starting a new line if necessary  *)
    BEGIN
      IF NOT ROOMFOR(WORD.LENGTH) THEN
	BEGIN
	  ADJUSTLINE;	  (* Right-justify the Current Line *)
	  STARTLINE
	END;
     APPENDWORD;
     IF ROOMFOR(1) THEN APPENDBLANK
   END (* ELSE *)
END; (* ANALYZE *)

(*$C+ [Control-C ON]*********************************)

PROCEDURE INITIALIZE;
BEGIN
  BLANKINDEX	:= MAXWORDLENGTH;(* start at the extreme right *)
  DIRCH		:= '^'; 	(* Default for Command Character *)
  INDENT	:= 6;		(* Default for all indents *)
  TAB		:= CHR(9);	(* ASCII TAB CHARACTER *)
  FATALERROR	:= FALSE;
  REPEAT
    WRITELN;
    WRITE('Line width?');
    READLN( LINEWIDTH );
    IF LINEWIDTH < MINLINEWIDTH THEN
      WRITELN('Minimum line width is', MINLINEWIDTH:3, '. Please reenter');
  UNTIL (LINEWIDTH>=MINLINEWIDTH) AND (LINEWIDTH<=MAXLINEWIDTH);
  WRITE('Enter text file name ');
  READLN( FILEID );
  (* OPEN file "FILEID" for READ assign TEXTFILE *)
	  RESET( FILEID, TEXTFILE );
  CLEAR(* OUTPUT *);
END;

BEGIN (*** Z-PRINT TEXT ***)
  INITIALIZE;
  IF EOF(TEXTFILE) THEN
    WRITELN('File ', FILEID, 'not found')
  ELSE
    BEGIN
      STARTLINE;
      READWORD; (*** Attempt to read a word ***)
      WHILE NOT ( EOF(TEXTFILE) OR FATALERROR ) DO
	BEGIN
	  ANALYZE;
	  READWORD;	(*** Attempt to read another word ***)
	END; (* WHILE *)
      PRINTLINE; (*** Write the current line without adjustment ***)
    END; (* else *)
  SKIP(4);
END. (*** Z-PRINT TEXT ***)
