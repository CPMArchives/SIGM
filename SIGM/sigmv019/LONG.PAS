
(************************************************************
*
*	Donated by Ray Penley, June 1980
*
************************************************************)



(*$I+	[Show me the source code]  *)
PROGRAM LONGLINE;

CONST
  default  = 80 ; {Default length for strings}
  LINESIZE = 80 ;

TYPE
  alfa	     = STRING 10 ;{just the right size}
  shorty     = STRING 40 ;{ 1/2 of default length }
  string40   = STRING 40 ;{ just say it another way }
  string79   = STRING 79 ;{ ONE less than default length }
  string80   = STRING 80 ;{ DEFAULT length }
  Max_String = STRING 255;{ The BIG GUN }
(*---Use these for the Pascal/Z supplied functins---*)
  $STRING0   = STRING 0 ;
  $STRING255 = STRING 255 ;

VAR
  DONE : BOOLEAN ;
  LINE : STRING LINESIZE ;
  WORD : string80 ;

(*---Required for Pascal/Z supplied string functins---*)
FUNCTION LENGTH(X: $STRING255): INTEGER; EXTERNAL;
FUNCTION INDEX(X,Y :$STRING255): INTEGER; EXTERNAL;
PROCEDURE SETLENGTH(VAR X :$STRING0; Y :INTEGER); EXTERNAL;
(*----------------------------------------------------*)

PROCEDURE HEADING;
BEGIN
  WRITELN('TYPE ONE WORD AT A TIME AND THIS PROGRAM WILL');
  WRITELN('ASSEMBLE THE WORDS INTO LINES OF ',LINESIZE:1, ' WORDS EACH');
  WRITELN('TYPE ## TO STOP');
  WRITELN;
END;


Procedure GetWord( var	xword	   : string40 ;
			req_length : integer  );
var
  temp : string 255;
begin
  SETLENGTH(xword,0);{start with a null string}
  READLN(temp);
  If length(temp)<=req_length then
    APPEND(xword,temp)
end;

BEGIN(* MAIN PROGRAM *)
  HEADING;
  SETLENGTH(WORD,0);
  DONE := FALSE;
  {---ATTEMPT TO READ THE FIRST WORD---}
  WRITE('Enter the first word: ');
  GetWord(WORD,20);
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
	  GetWord(WORD,20);
          IF WORD = '##' THEN DONE := TRUE;
        END(*WHILE*);
      WRITELN('Here is your Line:');
      WRITELN(LINE)
    END(* WHILE NOT DONE *)
END.
