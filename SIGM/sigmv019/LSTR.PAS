(*$I+	[Show me the source code]  *)
PROGRAM LONGLINE;

CONST
  LINESIZE = 80 ;

TYPE
(*---Pascal/Z needs these TYPE definitions---*)
  $STRING0   = STRING 0 ;
  $STRING255 = STRING 255 ;

VAR
  DONE : BOOLEAN ;
  LINE : STRING LINESIZE ;
  WORD : STRING 80 ;

(*---PASCAL/Z NEEDS THESE STRING FUNCTIONS---*)
FUNCTION LENGTH(X: $STRING255): INTEGER; EXTERNAL;
FUNCTION INDEX(X,Y :$STRING255): INTEGER; EXTERNAL;
PROCEDURE SETLENGTH(VAR X :$STRING0; Y :INTEGER); EXTERNAL;
(*-------------------------------------------*)

PROCEDURE HEADING;
BEGIN
  WRITELN('TYPE ONE WORD AT A TIME AND THIS PROGRAM WILL');
  WRITELN('ASSEMBLE THE WORDS INTO LINES OF ',LINESIZE:1, ' WORDS EACH');
  WRITELN('TYPE ## TO STOP');
  WRITELN;
END;

BEGIN(* MAIN PROGRAM *)
  HEADING;
  SETLENGTH(WORD,0);
  DONE := FALSE;
  {---ATTEMPT TO READ THE FIRST WORD---}
  WRITE('Enter the first word: ');
  READLN(WORD);
  WHILE NOT DONE DO
    BEGIN
      SETLENGTH(LINE,0);
      WHILE ( (LENGTH(LINE) + LENGTH(WORD)) < LINESIZE )
	   AND ( INDEX(WORD, '##')=0 ) DO
        BEGIN(* Our Line will be composed of -
		 WORDS/SPACES/WORDS			*)
	  IF LENGTH(WORD) < LINESIZE THEN APPEND(WORD, ' ');
	  (*---LINE := LINE + WORD---*)
	  APPEND( LINE, WORD );
	  WRITE('Enter the next word: ');
	  READLN(WORD);
          IF WORD = '##' THEN DONE := TRUE;
        END(*WHILE*);
      WRITELN('Here is your Line:');
      WRITELN(LINE)
    END(* WHILE NOT DONE *)
END.
