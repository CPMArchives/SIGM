PROGRAM PRETTYPRINT (* FROM PROGIN TO PROGOUT *); 
CONST
      MAXSYMBOLSIZE = 200; (* THE MAXIMUM SIZE (IN CHARACTERS) OF A   *)
                           (* SYMBOL SCANNED BY THE LEXICAL SCANNER.  *)
      MAXSTACKSIZE  = 100; (* THE MAXIMUM NUMBER OF SYMBOLS CAUSING   *)
                           (* INDENTATION THAT MAY BE STACKED.        *)
      MAXKEYLENGTH  =  10; (* THE MAXIMUM LENGTH (IN CHARACTERS) OF A *)
                           (* PASCAL RESERVED KEYWORD.                *)
      MAXLINESIZE   =  79; (* THE MAXIMUM SIZE (IN CHARACTERS) OF A   *)
                           (* LINE OUTPUT BY THE PRETTYPRINTER.       *)
      SLOFAIL1      =  77; (* UP TO THIS COLUMN POSITION, EACH TIME   *)
                           (* "INDENTBYTAB" IS INVOKED, THE MARGIN    *)
                           (* WILL BE INDENTED BY "INDENT1".          *)
      SLOFAIL2      =  79; (* UP TO THIS COLUMN POSITION, EACH TIME   *)
                           (* "INDENTBYTAB" IS INVOKED, THE MARGIN    *)
                           (* WILL BE INDENTED BY "INDENT2".  BEYOND  *)
                           (* THIS, NO INDENTATION OCCURS.            *)
      INDENT1       =   2;
      INDENT2       =   1;
      SPACE = ' ';
TYPE
     KEYSYMBOL = ( PROGSYM,    FUNCSYM,     PROCSYM,
                   LABELSYM,   CONSTSYM,    TYPESYM,   VARSYM,
                   BEGINSYM,   REPEATSYM,   RECORDSYM,
                   CASESYM,    CASEVARSYM,  OFSYM,
                   FORSYM,     WHILESYM,    WITHSYM,   DOSYM,
                   IFSYM,      THENSYM,     ELSESYM,
                   ENDSYM,     UNTILSYM,
                   BECOMES,    OPENCOMMENT, CLOSECOMMENT,
                   SEMICOLON,  COLON,       EQUALS,
                   OPENPAREN,  CLOSEPAREN,  PERIOD,
                   ENDOFFILE,
                   OTHERSYM );
     OPTION = ( CRSUPPRESS,
                CRBEFORE,
                BLANKLINEBEFORE,
                DINDENTONKEYS,
                DINDENT,
                SPACEBEFORE,
                SPACEAFTER,
                GOBBLESYMBOLS,
                INDENTBYTAB,
                INDENTTOCLP,
                CRAFTER );
     OPTIONSET = SET OF OPTION;
     KEYSYMSET = SET OF KEYSYMBOL;
     TABLEENTRY = RECORD
                     OPTIONSSELECTED  : OPTIONSET;
                     DINDENTSYMBOLS   : KEYSYMSET;
                     GOBBLETERMINATORS: KEYSYMSET
                  END;
     OPTIONTABLE = ARRAY [ KEYSYMBOL ] OF TABLEENTRY;
     KEY = PACKED ARRAY [ 1..MAXKEYLENGTH ] OF CHAR;
     KEYWORDTABLE = ARRAY [ PROGSYM..UNTILSYM ] OF KEY;
     SPECIALCHAR = PACKED ARRAY [ 1..2 ] OF CHAR;
     DBLCHRSET = SET OF BECOMES..OPENCOMMENT;
     DBLCHARTABLE = ARRAY [ BECOMES..OPENCOMMENT ] OF SPECIALCHAR;
     SGLCHARTABLE = ARRAY [ SEMICOLON..PERIOD ] OF CHAR;
     STRINGY = ARRAY [ 1..MAXSYMBOLSIZE ] OF CHAR;
     SYMBOL = RECORD
                 NAME        : KEYSYMBOL;
                 VALUE       : STRINGY;
                 LENGTH      : INTEGER;
                 SPACESBEFORE: INTEGER;
                 CRSBEFORE   : INTEGER
              END;
     SYMBOLINFO = ^SYMBOL;
     CHARNAME = ( LETTER,    DIGIT,    BLANK,    QUOTE,
                  ENDOFLINE, FILEMARK, OTHERCHAR       );
     CHARINFO = RECORD
                   NAME : CHARNAME;
                   VALUE: CHAR
                END;
     STACKENTRY = RECORD
                     INDENTSYMBOL: KEYSYMBOL;
                     PREVMARGIN  : INTEGER
                  END;
     SYMBOLSTACK = ARRAY [ 1..MAXSTACKSIZE ] OF STACKENTRY;
VAR 
     SAWCOMOPEN, SAWCOMCLOSE, SAWQUOTEDSTRING, INACOMMENT    : BOOLEAN; 
     PROGIN, PROGOUT : STRING;
    RECORDSEEN: BOOLEAN;
    CURRCHAR,
    NEXTCHAR: CHARINFO;
    CURRSYM,
    NEXTSYM: SYMBOLINFO;
    CRPENDING: BOOLEAN;
    PPOPTION: OPTIONTABLE;
    KEYWORD: KEYWORDTABLE;
    DBLCHARS: DBLCHRSET;
    DBLCHAR: DBLCHARTABLE;
    SGLCHAR: SGLCHARTABLE;
    STACK: SYMBOLSTACK;
    TOP  : INTEGER;
    STARTPOS,           (* STARTING POSITION OF LAST SYMBOL WRITTEN *)
    CURRLINEPOS,
    CURRMARGIN :  INTEGER;
 FIN, FOUT  : TEXT;
PROCEDURE GETCHAR(
                   (* UPDATING *)  VAR NEXTCHAR  : CHARINFO;
                   (* RETURNING *) VAR CURRCHAR  : CHARINFO );
BEGIN (* GETCHAR *)
   CURRCHAR := NEXTCHAR;
   WITH NEXTCHAR DO
      BEGIN
         IF EOF(FIN)
            THEN
               NAME  := FILEMARK
    ELSE IF EOLN(FIN)
            THEN
               NAME  := ENDOFLINE
 ELSE IF ( ( FIN^ IN [ 'a' .. 'z'] ) AND  (NOT SAWQUOTEDSTRING) )
 THEN BEGIN
   FIN^ := CHR ( ORD ( FIN^ ) - 32 );
   NAME := LETTER
 END
 ELSE IF SAWCOMOPEN THEN
 BEGIN
   SAWCOMOPEN := FALSE;
   FIN^ := '*';
   NAME := OTHERCHAR
 END
 ELSE IF SAWCOMCLOSE THEN
   BEGIN
   SAWCOMCLOSE := FALSE;
   FIN^ := ')';
   NAME := OTHERCHAR
   END
 ELSE IF FIN^ = '{' THEN
   BEGIN
   SAWCOMOPEN := TRUE;
   INACOMMENT := TRUE;
   FIN^ := '(';
   NAME := OTHERCHAR
   END 
 ELSE IF FIN^ = '}' THEN
   BEGIN
     SAWCOMCLOSE := TRUE;
     INACOMMENT := FALSE;
     FIN^ := '*';
     NAME := OTHERCHAR
   END
    ELSE IF FIN^ IN ['A' .. 'Z'] THEN
               NAME  := LETTER
    ELSE IF FIN^ IN ['0'..'9'] THEN
               NAME  := DIGIT
 ELSE IF ( FIN^ = '''') AND ( NOT INACOMMENT ) THEN
 IF SAWQUOTEDSTRING THEN
   BEGIN
     NAME := QUOTE;
     SAWQUOTEDSTRING := FALSE
   END
 ELSE
   BEGIN
     NAME := QUOTE;
     SAWQUOTEDSTRING := TRUE
   END
     ELSE IF FIN^ = SPACE THEN
               NAME  := BLANK
    ELSE NAME := OTHERCHAR;
         IF NAME IN [ FILEMARK, ENDOFLINE ] THEN
               VALUE := SPACE
         ELSE
               VALUE := FIN^;
         IF (NAME <> FILEMARK) AND (NOT SAWCOMOPEN) AND (NOT SAWCOMCLOSE)
            THEN GET(FIN)
      END (* WITH *)
END; (* GETCHAR *)
PROCEDURE STORENEXTCHAR(
                         (* UPDATING *)    VAR LENGTH    : INTEGER;
                                           VAR CURRCHAR,
                                               NEXTCHAR  : CHARINFO;
                         (* PLACING IN *)  VAR VALUE     : STRINGY   );
BEGIN (* STORENEXTCHAR *)
   GETCHAR(
            (* UPDATING *)  NEXTCHAR,
            (* RETURNING *) CURRCHAR  );
   IF LENGTH < MAXSYMBOLSIZE THEN
         BEGIN
            LENGTH := LENGTH + 1;
            VALUE [LENGTH] := CURRCHAR.VALUE
         END
END; (* STORENEXTCHAR *)
PROCEDURE SKIPSPACES(
                      (* UPDATING *)  VAR CURRCHAR,
                                          NEXTCHAR     : CHARINFO;
                      (* RETURNING *) VAR SPACESBEFORE,
                                          CRSBEFORE    : INTEGER  );
BEGIN (* SKIPSPACES *)
   SPACESBEFORE := 0;
   CRSBEFORE    := 0;
   WHILE NEXTCHAR.NAME IN [ BLANK, ENDOFLINE ] DO
      BEGIN
         GETCHAR(
                  (* UPDATING *)  NEXTCHAR,
                  (* RETURNING *) CURRCHAR  );
         CASE CURRCHAR.NAME OF
            BLANK     : SPACESBEFORE := SPACESBEFORE + 1;
             ENDOFLINE : BEGIN
                           CRSBEFORE    := CRSBEFORE + 1;
                           SPACESBEFORE := 0
                        END
         END (* CASE *)
      END (* WHILE *)
END; (* SKIPSPACES *)
PROCEDURE GETCOMMENT(
                      (* UPDATING *) VAR CURRCHAR,
                                         NEXTCHAR  : CHARINFO;
                                     VAR NAME      : KEYSYMBOL;
                                     VAR VALUE     : STRINGY;
                                     VAR LENGTH    : INTEGER   );
BEGIN (* GETCOMMENT *)
 INACOMMENT := TRUE;
   NAME := OPENCOMMENT;
   WHILE NOT(    ((CURRCHAR.VALUE = '*') AND (NEXTCHAR.VALUE = ')'))
              OR (NEXTCHAR.NAME = ENDOFLINE)
              OR (NEXTCHAR.NAME = FILEMARK)) DO
      STORENEXTCHAR(
                     (* UPDATING *) LENGTH,
                                    CURRCHAR,
                                    NEXTCHAR,
                     (* IN *)       VALUE     );
   IF (CURRCHAR.VALUE = '*') AND (NEXTCHAR.VALUE = ')') THEN
         BEGIN
            STORENEXTCHAR(
                           (* UPDATING *) LENGTH,
                                          CURRCHAR,
                                          NEXTCHAR,
                           (* IN *)       VALUE     );
            NAME := CLOSECOMMENT;
            INACOMMENT := FALSE
         END
END; (* GETCOMMENT *)
FUNCTION IDTYPE( (* OF *)        VALUE  : STRINGY;
                 (* USING *)     LENGTH : INTEGER )
                 (* RETURNING *)                   : KEYSYMBOL;
VAR
    I: INTEGER;
    KEYVALUE: KEY;
    HIT: BOOLEAN;
    THISKEY: KEYSYMBOL;
BEGIN (* IDTYPE *)
   IDTYPE := OTHERSYM;
   IF LENGTH <= MAXKEYLENGTH THEN
         BEGIN
            FOR I := 1 TO LENGTH DO
               KEYVALUE [I] := VALUE [I];
            FOR I := LENGTH+1 TO MAXKEYLENGTH DO
               KEYVALUE [I] := SPACE;
            THISKEY := PROGSYM;
            HIT     := FALSE;
            WHILE NOT(HIT OR (THISKEY = SUCC(UNTILSYM))) DO
               IF KEYVALUE = KEYWORD [THISKEY] THEN
                 HIT := TRUE
               ELSE
                 THISKEY := SUCC(THISKEY);
            IF HIT THEN IDTYPE := THISKEY
         END;
END; (* IDTYPE *)
PROCEDURE GETIDENTIFIER(
                         (* UPDATING *)  VAR CURRCHAR,
                                             NEXTCHAR  : CHARINFO;
                         (* RETURNING *) VAR NAME      : KEYSYMBOL;
                                         VAR VALUE     : STRINGY;
                                         VAR LENGTH    : INTEGER   );
BEGIN (* GETIDENTIFIER *)
   WHILE NEXTCHAR.NAME IN [ LETTER, DIGIT ] DO
      STORENEXTCHAR( (* UPDATING *) LENGTH,
                                    CURRCHAR,
                                    NEXTCHAR,
                     (* IN *)       VALUE     );
   NAME := IDTYPE( (* OF *) VALUE, (* USING *) LENGTH );
   IF NAME IN [ RECORDSYM, CASESYM, ENDSYM ] THEN
         CASE NAME OF
            RECORDSYM : RECORDSEEN := TRUE;
            CASESYM   : IF RECORDSEEN THEN
                              NAME := CASEVARSYM;
            ENDSYM    : RECORDSEEN := FALSE
         END (* CASE *)
END; (* GETIDENTIFIER *)
PROCEDURE GETNUMBER(
                     (* UPDATING *)  VAR CURRCHAR,
                                         NEXTCHAR  : CHARINFO;
                     (* RETURNING *) VAR NAME      : KEYSYMBOL;
                                     VAR VALUE     : STRINGY;
                                     VAR LENGTH    : INTEGER   );
BEGIN (* GETNUMBER *)
   WHILE NEXTCHAR.NAME = DIGIT DO
      STORENEXTCHAR(
                     (* UPDATING *) LENGTH,
                                    CURRCHAR,
                                    NEXTCHAR,
                     (* IN *)       VALUE     );
   NAME := OTHERSYM
END; (* GETNUMBER *)
                  PROCEDURE GETCHARLITERAL(
                          (* UPDATING *)  VAR CURRCHAR,
                                              NEXTCHAR  : CHARINFO;
                          (* RETURNING *) VAR NAME      : KEYSYMBOL;
                                          VAR VALUE     : STRINGY;
                                          VAR LENGTH    : INTEGER   );
BEGIN (* GETCHARLITERAL *)
   WHILE NEXTCHAR.NAME = QUOTE DO
      BEGIN
         STORENEXTCHAR(
                        (* UPDATING *) LENGTH,
                                       CURRCHAR,
                                       NEXTCHAR,
                        (* IN *)       VALUE     );
         WHILE NOT(NEXTCHAR.NAME IN [ QUOTE, ENDOFLINE, FILEMARK ]) DO
            STORENEXTCHAR(
                           (* UPDATING *) LENGTH,
                                          CURRCHAR,
                                          NEXTCHAR,
                           (* IN *)       VALUE     );
         IF NEXTCHAR.NAME = QUOTE
            THEN
                              STORENEXTCHAR(
                              (* UPDATING *) LENGTH,
                                             CURRCHAR,
                                             NEXTCHAR,
                              (* IN *)       VALUE     )
      END;
   NAME := OTHERSYM
END; (* GETCHARLITERAL *)
FUNCTION CHARTYPE( (* OF *)        CURRCHAR,
                                   NEXTCHAR : CHARINFO )
                   (* RETURNING *) : KEYSYMBOL;
VAR
    NEXTTWOCHARS: SPECIALCHAR;
    HIT: BOOLEAN;
    THISCHAR: KEYSYMBOL;
BEGIN (* CHARTYPE *)
   NEXTTWOCHARS[1] := CURRCHAR.VALUE;
   NEXTTWOCHARS[2] := NEXTCHAR.VALUE;
   THISCHAR := BECOMES;
   HIT      := FALSE;
   WHILE NOT(HIT OR (THISCHAR = CLOSECOMMENT)) DO
      IF NEXTTWOCHARS = DBLCHAR [THISCHAR] THEN
        HIT := TRUE
      ELSE
        THISCHAR := SUCC(THISCHAR);
   IF NOT HIT THEN
         BEGIN
            THISCHAR := SEMICOLON;
            WHILE NOT(HIT OR (PRED(THISCHAR) = PERIOD)) DO
              IF CURRCHAR.VALUE = SGLCHAR [THISCHAR] THEN
                HIT := TRUE
              ELSE
                THISCHAR := SUCC(THISCHAR)
         END;
   IF HIT THEN
     CHARTYPE := THISCHAR
   ELSE
     CHARTYPE := OTHERSYM
END; (* CHARTYPE *)
PROCEDURE GETSPECIALCHAR(
                          (* UPDATING *)  VAR CURRCHAR,
                                              NEXTCHAR  : CHARINFO;
                          (* RETURNING *) VAR NAME      : KEYSYMBOL;
                                          VAR VALUE     : STRINGY;
                                          VAR LENGTH    : INTEGER   );
BEGIN (* GETSPECIALCHAR *)
   STORENEXTCHAR(
                  (* UPDATING *) LENGTH,
                                 CURRCHAR,
                                 NEXTCHAR,
                  (* IN *)       VALUE     );
   NAME := CHARTYPE( (* OF *) CURRCHAR,
                              NEXTCHAR );
   IF NAME IN DBLCHARS
      THEN
         STORENEXTCHAR(
                          (* UPDATING *) LENGTH,
                                       CURRCHAR,
                                       NEXTCHAR,
                        (* IN *)       VALUE     )
END; (* GETSPECIALCHAR *)
PROCEDURE GETNEXTSYMBOL(
                         (* UPDATING *)  VAR CURRCHAR,
                                             NEXTCHAR  : CHARINFO;
                         (* RETURNING *) VAR NAME      : KEYSYMBOL;
                                         VAR VALUE     : STRINGY;
                                         VAR LENGTH    : INTEGER   );
BEGIN (* GETNEXTSYMBOL *)
   CASE NEXTCHAR.NAME OF
