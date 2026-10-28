FUNCTION STACKEMPTY (* RETURNING *) : BOOLEAN;
BEGIN (* STACKEMPTY *)
   IF TOP = 0
      THEN
         STACKEMPTY := TRUE
      ELSE
         STACKEMPTY := FALSE
END; (* STACKEMPTY *)
FUNCTION STACKFULL (* RETURNING *) : BOOLEAN;
BEGIN (* STACKFULL *)
   IF TOP = MAXSTACKSIZE
      THEN
         STACKFULL := TRUE
      ELSE
         STACKFULL := FALSE
END; (* STACKFULL *)
PROCEDURE POPSTACK( (* RETURNING *) VAR INDENTSYMBOL : KEYSYMBOL;
                                    VAR PREVMARGIN   : INTEGER   );
BEGIN (* POPSTACK *)
   IF NOT STACKEMPTY
      THEN
         BEGIN
            INDENTSYMBOL := STACK[TOP].INDENTSYMBOL;
            PREVMARGIN   := STACK[TOP].PREVMARGIN;
            TOP := TOP - 1
         END
      ELSE
         BEGIN
            INDENTSYMBOL := OTHERSYM;
            PREVMARGIN   := 0
         END
END; (* POPSTACK *)
PROCEDURE PUSHSTACK( (* USING *) INDENTSYMBOL : KEYSYMBOL;
                                 PREVMARGIN   : INTEGER   );
BEGIN (* PUSHSTACK *)
   TOP := TOP + 1;
   STACK[TOP].INDENTSYMBOL := INDENTSYMBOL;
   STACK[TOP].PREVMARGIN   := PREVMARGIN
END; (* PUSHSTACK *)
PROCEDURE WRITECRS( (* USING *)          NUMBEROFCRS : INTEGER;
                    (* UPDATING *)   VAR CURRLINEPOS : INTEGER );
VAR
    I: INTEGER;
BEGIN (* WRITECRS *)
   IF NUMBEROFCRS > 0
      THEN
         BEGIN
            FOR I := 1 TO NUMBEROFCRS DO BEGIN
 WRITELN;
               WRITELN(FOUT) END;
            CURRLINEPOS := 0
         END
END; (* WRITECRS *)
PROCEDURE INSERTCR( (* UPDATING *)   VAR CURRSYM    : SYMBOLINFO );
CONST
      ONCE = 1;
BEGIN (* INSERTCR *)
   IF CURRSYM^.CRSBEFORE = 0
      THEN
         BEGIN
            WRITECRS( ONCE, (* UPDATING *)   CURRLINEPOS );
            CURRSYM^.SPACESBEFORE := 0
         END
END; (* INSERTCR *)
PROCEDURE INSERTBLANKLINE( (* UPDATING *)   VAR CURRSYM : SYMBOLINFO );
CONST
      ONCE  = 1;
      TWICE = 2;
BEGIN (* INSERTBLANKLINE *)
   IF CURRSYM^.CRSBEFORE = 0
      THEN
         BEGIN
            IF CURRLINEPOS = 0
               THEN
                   WRITECRS( ONCE, (* UPDATING *)   CURRLINEPOS )
               ELSE
                  WRITECRS( TWICE, (* UPDATING *)   CURRLINEPOS );
            CURRSYM^.SPACESBEFORE := 0
         END
      ELSE
         IF CURRSYM^.CRSBEFORE = 1
            THEN
               IF CURRLINEPOS > 0
                  THEN
                     WRITECRS( ONCE, (* UPDATING *)   CURRLINEPOS )
END; (* INSERTBLANKLINE *)
PROCEDURE LSHIFTON( (* USING *) DINDENTSYMBOLS : KEYSYMSET );
VAR
    INDENTSYMBOL : KEYSYMBOL;
    PREVMARGIN   : INTEGER;
BEGIN (* LSHIFTON *)
   IF NOT STACKEMPTY
      THEN
         BEGIN
            REPEAT
               POPSTACK( (* RETURNING *) INDENTSYMBOL,
                                         PREVMARGIN   );
               IF INDENTSYMBOL IN DINDENTSYMBOLS
                  THEN
                     CURRMARGIN := PREVMARGIN
            UNTIL NOT(INDENTSYMBOL IN DINDENTSYMBOLS)
                   OR (STACKEMPTY);
            IF NOT(INDENTSYMBOL IN DINDENTSYMBOLS)
               THEN
                     PUSHSTACK( (* USING *) INDENTSYMBOL,
                                         PREVMARGIN   )
         END
END; (* LSHIFTON *)
PROCEDURE LSHIFT;
VAR
    INDENTSYMBOL: KEYSYMBOL;
    PREVMARGIN  : INTEGER;
BEGIN (* LSHIFT *)
   IF NOT STACKEMPTY
      THEN
         BEGIN
            POPSTACK( (* RETURNING *) INDENTSYMBOL,
                                      PREVMARGIN   );
            CURRMARGIN := PREVMARGIN
         END
END; (* LSHIFT *)
PROCEDURE INSERTSPACE( (* USING *)      VAR SYMBOL     : SYMBOLINFO );
BEGIN (* INSERTSPACE *)
   IF CURRLINEPOS < MAXLINESIZE
      THEN
         BEGIN
            WRITE(FOUT, SPACE); WRITE ( SPACE );
            CURRLINEPOS := CURRLINEPOS + 1;
            WITH SYMBOL^ DO
               IF (CRSBEFORE = 0) AND (SPACESBEFORE > 0)
                  THEN
                     SPACESBEFORE := SPACESBEFORE - 1
         END
END; (* INSERTSPACE *)
PROCEDURE MOVELINEPOS( (* TO *)       NEWLINEPOS  : INTEGER;
                       (* FROM *) VAR CURRLINEPOS : INTEGER );
VAR
   I: INTEGER;
BEGIN (* MOVELINEPOS *)
   FOR I := CURRLINEPOS+1 TO NEWLINEPOS DO BEGIN WRITE ( SPACE );
      WRITE(FOUT, SPACE) END;
   CURRLINEPOS := NEWLINEPOS
END; (* MOVELINEPOS *)
PROCEDURE PRINTSYMBOL( (* IN *)             CURRSYM     : SYMBOLINFO;
                       (* UPDATING *)   VAR CURRLINEPOS : INTEGER     );
VAR
   I : INTEGER;
BEGIN (* PRINTSYMBOL *)
   WITH CURRSYM^ DO
      BEGIN
         FOR I := 1 TO LENGTH DO BEGIN WRITE ( VALUE[I] );
            WRITE(FOUT, VALUE[I]) END;
         STARTPOS := CURRLINEPOS (* SAVE START POSITION FOR TABBING *);
         CURRLINEPOS := CURRLINEPOS + LENGTH
      END (* WITH *)
END; (* PRINTSYMBOL *)
PROCEDURE PPSYMBOL( (* IN *) CURRSYM : SYMBOLINFO );
CONST
      ONCE  = 1;
VAR
    NEWLINEPOS: INTEGER;
BEGIN (* PPSYMBOL *)
   WITH CURRSYM^ DO
      BEGIN
         WRITECRS( (* USING *)      CRSBEFORE,
                   (* UPDATING *)   CURRLINEPOS );
         IF (CURRLINEPOS + SPACESBEFORE > CURRMARGIN)
            OR (NAME IN [ OPENCOMMENT, CLOSECOMMENT ])
            THEN
               NEWLINEPOS := CURRLINEPOS + SPACESBEFORE
            ELSE
               NEWLINEPOS := CURRMARGIN;
         IF NEWLINEPOS + LENGTH > MAXLINESIZE
            THEN
               BEGIN
                  WRITECRS( ONCE, (* UPDATING *)   CURRLINEPOS );
                  IF CURRMARGIN + LENGTH <= MAXLINESIZE
                     THEN
                        NEWLINEPOS := CURRMARGIN
                     ELSE
                        IF LENGTH < MAXLINESIZE
                           THEN
                              NEWLINEPOS := MAXLINESIZE - LENGTH
                           ELSE
                              NEWLINEPOS := 0
               END;
         MOVELINEPOS( (* TO *)    NEWLINEPOS,
                      (* FROM *)  CURRLINEPOS );
         PRINTSYMBOL( (* IN *)         CURRSYM,
                      (* UPDATING *)   CURRLINEPOS )
      END (* WITH *)
END; (* PPSYMBOL *)

PROCEDURE RSHIFTTOCLP( (* USING *) CURRSYM : KEYSYMBOL );
   FORWARD;

PROCEDURE GOBBLE(
                  (* UP TO *)            TERMINATORS : KEYSYMSET;
                  (* UPDATING *)     VAR CURRSYM,
                                         NEXTSYM     : SYMBOLINFO );
BEGIN (* GOBBLE *)
   RSHIFTTOCLP( (* USING *) CURRSYM^.NAME );
   WHILE NOT(NEXTSYM^.NAME IN (TERMINATORS + [ENDOFFILE])) DO
      BEGIN
         GETSYMBOL(
                    (* UPDATING *)  NEXTSYM,
                    (* RETURNING *) CURRSYM   );
         PPSYMBOL( (* IN *)         CURRSYM )
      END; (* WHILE *)
   LSHIFT
END; (* GOBBLE *)

PROCEDURE RSHIFT( (* USING *) CURRSYM : KEYSYMBOL );
BEGIN (* RSHIFT *)
   IF NOT STACKFULL
      THEN
         PUSHSTACK( (* USING *) CURRSYM,
                                CURRMARGIN);
   IF STARTPOS > CURRMARGIN
      THEN
         CURRMARGIN := STARTPOS;
   IF CURRMARGIN < SLOFAIL1
      THEN
         CURRMARGIN := CURRMARGIN + INDENT1
      ELSE
                                    IF CURRMARGIN < SLOFAIL2
            THEN
               CURRMARGIN := CURRMARGIN + INDENT2
END; (* RSHIFT *)

PROCEDURE RSHIFTTOCLP;
BEGIN (* RSHIFTTOCLP *)
   IF NOT STACKFULL
      THEN
         PUSHSTACK( (* USING *) CURRSYM,
                                CURRMARGIN);
   CURRMARGIN := CURRLINEPOS
END; (* RSHIFTTOCLP *)

BEGIN (* PRETTYPRINT *)
 WRITE ( ' ENTER TEXT FILE TO BE PRETTYPRINTED - - > ');
 READLN ( PROGIN );
 PROGIN := CONCAT ( '#5:',PROGIN,'.TEXT');
 WRITELN;
 WRITE ( 'ENTER NEW FILE NAME OF PRETTYPRINTED PROGRAM - - > ');
 READLN ( PROGOUT );
 PROGOUT := CONCAT ( '#5:',PROGOUT,'.TEXT');
 WRITELN;
 WRITELN (' NOW PRETTYPRINTING.....');
 
 RESET ( FIN,PROGIN);
 REWRITE ( FOUT, PROGOUT);
 
   INITIALIZE( TOP,        CURRLINEPOS,
               CURRMARGIN, KEYWORD,    DBLCHARS,    DBLCHAR,
               SGLCHAR,    RECORDSEEN, CURRCHAR,    NEXTCHAR,
               CURRSYM,    NEXTSYM,    PPOPTION );
   CRPENDING := FALSE;
   WHILE (NEXTSYM^.NAME <> ENDOFFILE) DO
     BEGIN
         GETSYMBOL(
                    (* UPDATING *)  NEXTSYM,
                    (* RETURNING *) CURRSYM   );
         WITH PPOPTION [CURRSYM^.NAME] DO
            BEGIN
               IF (CRPENDING AND NOT(CRSUPPRESS IN OPTIONSSELECTED))
                 OR (CRBEFORE IN OPTIONSSELECTED)
                  THEN
                     BEGIN
                        INSERTCR( (* USING *) CURRSYM);
                        CRPENDING := FALSE
                     END;
               IF BLANKLINEBEFORE IN OPTIONSSELECTED
                  THEN
                     BEGIN
                        INSERTBLANKLINE( (* USING *) CURRSYM);
                        CRPENDING := FALSE
                     END;
               IF DINDENTONKEYS IN OPTIONSSELECTED
                  THEN
                     LSHIFTON(DINDENTSYMBOLS);
               IF DINDENT IN OPTIONSSELECTED
                  THEN
                     LSHIFT;
               IF SPACEBEFORE IN OPTIONSSELECTED
                  THEN
                     INSERTSPACE( (* USING *) CURRSYM );
               PPSYMBOL( (* IN *) CURRSYM );
               IF SPACEAFTER IN OPTIONSSELECTED
                  THEN
                     INSERTSPACE( (* USING *) NEXTSYM );
               IF INDENTBYTAB IN OPTIONSSELECTED
                  THEN
                     RSHIFT( (* USING *) CURRSYM^.NAME );
               IF INDENTTOCLP IN OPTIONSSELECTED
                  THEN
                     RSHIFTTOCLP( (* USING *) CURRSYM^.NAME );
               IF GOBBLESYMBOLS IN OPTIONSSELECTED
                  THEN
                     GOBBLE(
                             (* UP TO *)        GOBBLETERMINATORS,
                             (* UPDATING *)     CURRSYM,
                                                NEXTSYM            );
               IF CRAFTER IN OPTIONSSELECTED
                  THEN
                     CRPENDING := TRUE
            END (* WITH *)
      END; (* WHILE *)
   IF CRPENDING
      THEN
         WRITELN(FOUT);
   CLOSE ( FOUT, LOCK );
 WRITELN;
 WRITELN;
 WRITELN ( ' YOUR PRETTY PRINTED PGM IS NOW IN ',
 PROGOUT );
 END.
