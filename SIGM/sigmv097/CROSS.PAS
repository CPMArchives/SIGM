PROGRAM CROSS;{$l-}{$E-}{$T-}{$C-}
  (*******************************************************************
   *
   *
   *   PROGRAM ZUR ERSTELLUNG EINER CROSS-REFERENCE LISTE
   *   UND EINER NEU FORMATTIERTEN VERSION EINES PASCAL
   *   PROGRAMS.
   *
   *   EINGABE: PASCAL QUELL-FILE
   *   AUSGABE: NEU FORMATTIERTER QUELL-FILE UND
   *            CROSS-REFERENCE LISTE
   *
   *   AUTHOR:  MANUEL MALL (1974)
   *
   *
   *******************************************************************)
{  PROGRAM CROSS( OLDSOURCE, NEWSOURCE, CROSSLIST,OUTPUT);}
CONST
  VERSION='Version  11-Jun-81';
  Big_Line=MaxInt;
  First_Char='$';Last_Char='_';
  CASEFEED = 6;    (*ZEICHENVORSCHUB BEI CASE*)
  ID_LENGTH=10;
  Num_Reserved_Words=47;
  {%E}
TYPE
  CHAR2=PACKED ARRAY[1..2]OF CHAR;
  LINE_PTR_TY = ^LINE;
  LIST_PTR_TY = ^LIST;
  PROC_CALL_TYPE = ^PROCCALL;
  PROC_STRUC_TYPE = ^PROCSTRUC;
  LINENRTY = 0..32000;          (* ALLOW ALL THE LINE NUMBERS *)
  PAGENRTY = 0..255;            (* ALLOW LARGE NUMBER OF PAGES *)
  WORD    = PACKED ARRAY [1..10] OF CHAR;
  SYMBOL = (LABELSY,CONSTSY,TYPESY,VARSY,
            { 0        1       2      3 }
            (*DECSYM*)
            FUNCT_SY,PROC_SY,INITPROCSY,Sub_Program,  (*PROSYM*)
            { 4        5       6            7 }
         ENDSY,UNTILSY,ELSESY,THENSY,EXITSY,OFSY,DOSY,EOBSY, (*ENDSYMBOLS*)
            { 8   9         10     11    12    13   14   15 }
            BEGINSY,CASESY,LOOPSY,REPEATSY,IFSY,           (*BEGSYM*)
            { 16     17    18      19       20 }
    RECORDSY,FORWARDSY,OTHERSY,INTCONST,IDENT,STRGCONST,EXTERNSY,FORTRANSY,
            RPARENT,SEMICOLON,POINT,LPARENT,COLON,LBRACK,OTHERSSY,
            Other_Wise
            (*DELIMITER*));
  LINE = PACKED RECORD
                  (*BESCHREIBUNG DER ZEILENNUMMERN*)
                  LINENR : LINENRTY;            (*ZEILENNUMMER*)
                  PAGENR : PAGENRTY;            (*SEITENNUMMER*)
          CONTLINK : LINE_PTR_TY          (*NAECHSTER ZEILENNUMMERNRECORD*)
                END;
  LIST = PACKED RECORD
                  (*BESCHREIBUNG VON IDENTIFIERN*)
                  NAME : WORD;                  (*NAME DES IDENTIFIERS*)
                LLINK ,                       (*LINKER NACHFOLGER IN BAUM*)
             RLINK : LIST_PTR_TY;            (*RECHTER NACHFOLGER IM BAUM*)
    FIRST ,                       (*ZEIGER AUF ERSTEN ZEILENNUMMERNRECORD*)
 LAST  : LINE_PTR_TY;            (*ZEIGER AUF LETZTEN ZEILENNUMMERNRECORD*)
 PROCVAR : 0..2;               (*0=KEINE PROZEDUR/ 1=PROZEDUR/ 2=FUNKTION*)
                  CALLED,
              (*ZEIGER AUF DIE ERSTE PROZEDUR DIE VON DIESER GERUFEN WIRD*)
    CALLEDBY : PROC_CALL_TYPE         (*ZEIGER AUF ERSTE RUFENDE PROZEDUR*)
                END;
  {%E}
  PROCCALL = PACKED RECORD
                      (*BESCHREIBUNG VON PROZEDURAUFRUFEN*)
                      PROCNAME : LIST_PTR_TY;
                      (*ZEIGER AUF DEN ZUGEHOERIGEN IDENTIFIERRECORD*)
         NEXTPROC : PROC_CALL_TYPE;    (*ZEIGER AUF DIE NAECHSTE PROZEDUR*)
                      FIRST,
                      (*ZEILENNUMMERNRECORD FUER DEN ERSTEN AUFRUF*)
                      LAST : LINE_PTR_TY
                      (*ZEILENNUMMERNRECORD FUER DEN LETZTEN AUFRUF*)
                    END;
  DBL_DEC = PACKED RECORD
                   (*PROZEDUREN DIE AUCH ALS NORMALE ID. DEFINIERT WURDEN*)
                     PROCORT : LIST_PTR_TY;     (*ZEIGER AUF DIE PROZEDUR*)
         NEXTPROC: ^DBL_DEC     (*NAECHSTE DOPPELT DEKLARIERTE PROZEDUR*)
                     END;
Dbl_Ptr=^Dbl_Dec;
  PROCSTRUC = PACKED RECORD
                       (*BESCHREIBUNG DER PROZEDURVERSCHACHTELUNG*)
     PROCNAME : LIST_PTR_TY;    (*ZEIGER AUF DEN ZUGERHOERIGEN IDENTIFIER*)
                       NEXTPROC : PROC_STRUC_TYPE;
                       (*ZEIGER AUF DIE NAECHSTD DEKLARIERTE PROZEDUR*)
           LINENR : LINENRTY;       (*ZEILENNUMMER DER PROZEDURDEFINITION*)
           PAGENR ,                 (*SEITENNUMMER DER PROZEDURDEFINITION*)
            PROCLEVEL: PAGENRTY      (*VERSCHACHTELUNGSTIEFE DER PROZEDUR*)
                     END;
  ALFA=PACKED ARRAY[1..ID_LENGTH]OF CHAR;
  Char8=Packed Array[1..8]Of Char;
  {%E}
VAR
  INPUT,OUTPUT:TEXT;
  MaxCh:Integer;MaxLine:Integer;
  RightMargin:Integer;{Do not put text past this margin}
  Bump,Nasty:Boolean;{Bump=True if we bumped into the right margin}
  {Nasty=True if we had to go past the margin}
  FEED,BACKFEED:INTEGER;                         (* INDENT SIZES *)
  I,                                    (*SCHLEIFENVARIABLE*)
  BUFFLEN,
  (*LAENGE DES BESCHRIEBENEN TEILS DES EINGABEPUFFERS*)
  BUFFMARK,
  (*LAENGE DES SCHON GEDRUCKTEN TEIL DES PUFFERS*)
  BUFFERPTR,
  (*ZEIGER AUF DAS NAECHSTE ZU LESENDE ZEICHEN IM PUFFER*)
  BUFFINDEX,                            (*ZEIGER IM ARRAY VON BUFF*)
  BMARKNR,
  (*ZU DRUCKENDE NUMMER FUER MARKIERUNG VON 'BEGIN', 'LOOP' ETC.*)
  EMARKNR,
  (*ZU DRUCKENDE NUMMER FUER MARKIERUNG VON 'END', 'UNTIL' ETC.*)
  SPACES,
  (*ZEICHENVORSCHUB FUER DIE FORMATIERUNG*)
LASTSPACES,                           (*LETZTER BENUTZTER ZEICHENVORSCHUB*)
  SYLENG,
  (*LAENGE DES LETZTEN GELESENEN BEZEICHNERS*)
  CHCNT,
  (*ANZAHL DER RELEVANTEN ZEICHEN IM LETZTEN BEZEICHNER*)
  LEVEL,
  (*VERSCHACHTELUNGSTIEFE DER AKTUELLEN PROZEDUR*)
  BLOCKNR,
  (*ZAEHLT DIE GEKENNZEICHNETEN STATEMENTS*)
  PROCDEC,
  (*GESETZT BEI PROZEDUR DEKLARATION 1=PROCEDURE 2=FUNCTION*)
  PAGECNT,                              (*ZAEHLT DIE SOS-SEITEN*)
  PAGECNT2,
  (*ZAEHLT DIE DRUCKSEITEN PRO SOS-SEITE*)
  INCREMENT,
  (*PARAMETER FUER DIE ERHOEHUNG DER ZEILENNUMMERN*)
  MAXINC,                               (*GROESSTE ERLAUBTE ZEILENNUMMER*)
  REALLINCNT,                         (*ZAEHLT DIE ZEILEN PRO DRUCKSEITE*)
  LINECNT : INTEGER;                    (*ZAEHLT DIE ZEILEN PRO SOS-SEITE*)
  BUFFER  : ARRAY [1..147] OF CHAR;
  (*EINGABEPUFFER (147 ZEICHEN = MAX. LAENGE SOS-ZEILE)*)
  DATUM, DAYTIME: Char8;
  {%E}
  SY      : WORD;                       (*LETZTER GELESENER BEZEICHNER*)
  SYTY    : SYMBOL;                (*TYP DES LETZTEN GELESENEN ZEICHENS*)
  ERRFLAG,                              (*FEHLERMARKE*)
  OLDSPACES,
  (*GESETZT WENN LASTSPACES BENUTZT WERDEN SOLL*)
  EOB     : BOOLEAN;                    (*EOF-MARKE*)
  CH,                                   (*LETZTES GELESENES ZEICHEN*)
  BMARKTEXT,
  (*TEXT ZUR MARKIERUNG VON 'BEGIN' ETC.*)
  EMARKTEXT: CHAR;                  (*TEXT ZUR MARKIERUNG VON 'END' ETC.*)
  DELSY : ARRAY [' '..'_'] OF SYMBOL;(*TYPENARRAY FUER DELIMITERZEICHEN*)
  RESNUM  : ARRAY [1..11] OF INTEGER;
  (*STARTADRESSEN FUER DIE RESERVIERTEN WORTE BESTIMMTER LAENGE*)
  RESLIST : ARRAY [1..Num_Reserved_Words] OF WORD;
  RESSY   : ARRAY [1..Num_Reserved_Words] OF SYMBOL;
  ALPHANUM,                             (*ZEICHEN VON 0..9 UND A..Z*)
  DIGITS,                               (*ZEICHEN VON 0..9*)
  LETTERS : SET OF CHAR;                (*ZEICHEN VON A..Z*)
  RELEVANTSYM,
  (*STARTSYMBOLE FUER STATEMENTS UND PROCEDURES*)
  PROSYM,
  (*ALLE SYMBOLE DIE DEN BEGINN EINER PROZEDUR KENNZEICHNEN*)
  DECSYM,
  (*ALLE SYMBOLE DIE DEN BEGINN VON DEKLARATIONEN KENNZEICHNEN*)
  BEGSYM,
  (*ALLE SYMBOLE DIE DEN BEGINN EINES STATEMENTS KENNZEICHNEN*)
  ENDSYM  : SET OF SYMBOL;
  (*ALLE SYMBOLE DIE STATEMENTS ODER PROZEDUREN TERMINIEREN*)
  LISTPTR : LIST_PTR_TY;
  (*ZEIGER IM BINAERBAUM DER DEKLARIETEN BEZEICHNER*)
  FIRSTNAME : ARRAY [First_Char..Last_Char] OF LIST_PTR_TY;
  (*ZEIGER AUF DIE WURZELN DES BAUMES*)
  PROC_CF,
  (*ZEIGER AUF DAS ERSTE ELEMENT DER PROZEDURENLISTE*)
  PROC_CL : PROC_STRUC_TYPE;
  (*ZEIGER AUF DAS LETZTE ELEMENT DER PROZEDURENLISTE*)
  NEWSOURCE : TEXT;
  (*AUSGABEFILE AUF DEM DAS NEUFORMATIERTE PROGRAMM STEHT*)
  OLDSOURCE, CROSSLIST : TEXT;
  MESSAGE : PACKED ARRAY [1..23] OF CHAR;
  (*ARRAY ZUR AUSGABE DER SCHLUSSMELDUNG*)
  No_Main:Boolean;{True if no main program }
  {%E}
Function GetSize:Integer;External;
Procedure Init_P3;External;
Procedure Init;External;
Procedure Init_Proc;External;
  {%E}
  Function Hack_EolN(Var F:Text):Boolean;
  Begin
    If Eof(F)
      Then Hack_Eol:=True
      Else Hack_Eol:=Eoln(F);
  End;
  PROCEDURE WRITECH (FCH : CHAR);
  BEGIN (*WRITECH*)
    WRITE(NEWSOURCE,FCH);
  END (*WRITECH*);
  PROCEDURE WRITELIN;
  BEGIN (*WRITELIN*)
    WRITELN(NEWSOURCE);
  END (*WRITELIN*);
  PROCEDURE WRITEPAGE;
  BEGIN (*WRITEPAGE*)
    {TAKEN CARE OF IN THE OPTIONS ALREADY}
  END (*WRITEPAGE*);
  PROCEDURE WRITE_LINE_NUMBER;
  VAR
    I, LLINECNT : INTEGER;
  BEGIN (*WRITE_LINE_NUMBER*)
    LLINECNT := LINECNT * INCREMENT;
  END (*WRITE_LINE_NUMBER*);
Procedure Page(Var Where:Text);
Begin
  Write(Where,Chr(12));
End;

  PROCEDURE HEADER;
  BEGIN (*HEADER*)
    PAGECNT2 := PAGECNT2 + 1;
    REALLINCNT := 0;
    PAGE (CROSSLIST);
    WRITELN (CROSSLIST,'Page ':20,PAGECNT:3,'-',PAGECNT2:3
             ,' ':15,' ':5,DATUM,' ':4,DAYTIME);
    WRITELN (CROSSLIST);
  END (*HEADER*) ;
  PROCEDURE NEWPAGE;
  BEGIN (*NEWPAGE*)
    PAGECNT2 := 0;
    PAGECNT := PAGECNT + 1;
    WRITEPAGE;
    HEADER;
    IF (HACK_EOLN (OLDSOURCE))AND(NOT EOF(OLDSOURCE))
      THEN READLN (OLDSOURCE);
  END (*NEWPAGE*) ;
  {%E}
  PROCEDURE WR_LINE (POSITION
                    (*LETZTES ZU DRUCKENDES ZEICHEN IM PUFFER*) : INTEGER);
  VAR
    I, COL, LSPACES : INTEGER;    (*MARKIERT ERSTES ZU DRUCKENDES ZEICHEN*)
  BEGIN (*WR_LINE*)
    POSITION := POSITION - 2;
    IF POSITION > 0
      THEN
        BEGIN
          I := BUFFMARK + 1;
          WHILE (BUFFER [I] = ' ') AND (I <= POSITION) DO I := I + 1;
          BUFFMARK := POSITION;
          WHILE (BUFFER [POSITION] = ' ') AND
          (I < POSITION) DO POSITION := POSITION - 1;
          IF I <= POSITION
            THEN
              BEGIN
                IF REALLINCNT = MAXLINE
                  THEN HEADER;
                LINECNT := LINECNT + 1;
                REALLINCNT := REALLINCNT + 1;
                IF BMARKTEXT <> ' '
                  THEN
                    BEGIN
                      WRITE (CROSSLIST,BMARKTEXT, BMARKNR : 4, '       ');
                      BMARKTEXT := ' ';
                    END
                  ELSE
                    IF EMARKTEXT <> ' '
                      THEN
                        BEGIN
                      WRITE (CROSSLIST,'      ',EMARKTEXT,EMARKNR : 4,' ');
                          EMARKTEXT := ' ';
                        END
                      ELSE WRITE (CROSSLIST,'            ');
                WRITE (CROSSLIST,LINECNT * INCREMENT : 5,' ');
                COL:=18;{18 FOR STUFF AT THE BEGINNING OF THE LINE }
                WRITE_LINE_NUMBER;
                IF NOT OLDSPACES
                  THEN LASTSPACES := SPACES;
                LSPACES := LASTSPACES;
                If(Position-I+Lspaces+1)>=RightMargin
                  Then
                    Begin
                      Lspaces:=RightMargin-(Position-I+1);
                      Bump:=True;
                      If Lspaces<0
                        Then Nasty:=True;
                    End;
                    {%E}
                FOR LSPACES := LSPACES DOWNTO 1 DO
                WriteCh(' ');
                For LSpaces:=1 To LastSpaces Do
                Begin
                  Write(CrossList,' ');
                  Col:=Col+1;
                  If Col=MaxCh
                    Then
                      Begin
                        Col:=18;
                        Writeln(CrossList);
                        Write(CrossList,' ':18);
                        RealLinCnt:=RealLinCnt+1;
                      End;
                End;
                FOR I := I TO POSITION DO
                BEGIN
                  WRITE (CROSSLIST,BUFFER [I]);
                  Col:=Col+1;
                  If Col=MaxCh
                    Then
                      Begin
                        Col:=18;
                        Writeln(CrossList);
                        Write(CrossList,' ':18);
                        RealLinCnt:=RealLinCnt+1;
                      End;
 
                  WRITECH (BUFFER[I]);
                  BUFFER [I] := ' ';
                END;
                WRITELIN;
                WRITELN (CROSSLIST);
                IF  (MAXINC = LINECNT)
                  THEN NEWPAGE;
              END;
        END;
    LASTSPACES := SPACES;
    OLDSPACES := FALSE;
  END (*WR_LINE*) ;
  {%E}
PROCEDURE INSYMBOL(Var DBL_DECF,Dbl_DecL:Dbl_Ptr;
VAR CURPROC:LIST_PTR_TY);
EXTERNAL;
Procedure Block;External;
  {%E}
  PROCEDURE PRINTLISTE;
  VAR
    FIRSTPROC,LASTPROC,
    (*ZEIGER ZUM DURCHHANGELN DURCH DIE BAEUME UND LISTEN BEIM AUSDRUCKEN*)
    PRED : LIST_PTR_TY;
    INDEXCH : CHAR;
    Col:Integer;
    (*LAUFVARIABLE FUER DAS FELD 'FIRSTNAME' ZUM AUSDRUCKEN*)
    LineCounter:Integer; {Count of the lines on the page}
    Procedure List_Page;
    Begin
      LineCounter:=0;
      Page(CrossList);
    End;
    Procedure List_Eol;
    Begin
      Writeln(CrossList);
      LineCounter:=LineCounter+1;
      If LineCounter=MaxLine
        Then List_Page;
      Col:=1;
    End;
    Procedure Write_N3(N:Integer);
    Begin
      If N>=100
        Then Write(CrossList,N:3)
        Else
          If N>=10
            Then
              Write(CrossList,N:2,' ')
            Else Write(CrossList,N:1,'  ');
    End;
    PROCEDURE WR_LINENR (SPACES : INTEGER);
    VAR
      LINK : LINE_PTR_TY;
      (*ZEIGER ZUM DURCHHANGELN DURCH DIE VERKETTUNG DER ZEILENNUMMERN*)
    BEGIN (*WR_LINENR*)
      LINK := LISTPTR^.FIRST;
      Col:=Spaces+1;
      REPEAT
        IF (Col+13)>MaxCh
          THEN
            BEGIN
              List_Eol;
              WRITE (CROSSLIST,' ' : SPACES);
              Col:=Spaces+1;
            END;
        WRITE (CROSSLIST,LINK^.LINENR*INCREMENT:6,'/');
        Write_N3(Link^.PageNr);Write(CrossList,' ':3);
        COL:=COL+13;
        LINK := LINK^.CONTLINK;
      UNTIL LINK = NIL;
    END (*WR_LINENR*) ;
    {%E}
  BEGIN (*PRINTLISTE*)
    FIRSTPROC := NIL;
    LASTPROC := NIL;
    WITH FIRSTNAME ['M']^ DO
    IF RLINK = NIL
      THEN FIRSTNAME ['M'] := LLINK
      ELSE
        BEGIN
          LISTPTR := RLINK;
          WHILE LISTPTR^.LLINK <> NIL DO LISTPTR := LISTPTR^.LLINK;
          LISTPTR^.LLINK := LLINK;
          FIRSTNAME ['M'] := RLINK;
        END;
    INDEXCH := First_Char;
    WHILE (INDEXCH < Last_Char) AND (FIRSTNAME [INDEXCH] = NIL)
    DO INDEXCH := SUCC (INDEXCH);
    IF FIRSTNAME [INDEXCH] <> NIL
      THEN
        BEGIN
          List_page;
          WRITE (CROSSLIST,'Cross listing of identifiers');
          List_Eol;
          WRITE (CROSSLIST,'****************************');
          List_Eol;
          FOR INDEXCH := INDEXCH TO Last_Char DO
          WHILE FIRSTNAME [INDEXCH] <> NIL DO
          BEGIN
            LISTPTR := FIRSTNAME [INDEXCH];
            WHILE LISTPTR^.LLINK <> NIL DO
            BEGIN
              PRED := LISTPTR;
              LISTPTR := LISTPTR^.LLINK;
            END;
            IF LISTPTR = FIRSTNAME [INDEXCH]
              THEN FIRSTNAME [INDEXCH] := LISTPTR^.RLINK
              ELSE PRED^.LLINK := LISTPTR^.RLINK;
            IF LISTPTR^.CALLED <> NIL
              THEN
                BEGIN
                  IF FIRSTPROC = NIL
                    THEN
                      BEGIN
                        FIRSTPROC := LISTPTR;
                        LASTPROC := FIRSTPROC;
                        LASTPROC^.CALLED^.PROCNAME := NIL;
                      END
                    ELSE
                      BEGIN
                        LASTPROC^.CALLED^.PROCNAME := LISTPTR;
                        LASTPROC := LISTPTR;
                      END;
                END;
                {%E}
            List_Eol;
            WRITE (CROSSLIST,LISTPTR^.NAME : 11);
            WR_LINENR (11);
          END;
          IF FIRSTPROC <> NIL
            THEN
              BEGIN
                List_Page;
                WRITE(CROSSLIST,'Cross listing of routines');
                List_Eol;
                WRITE(CROSSLIST,'*************************');
                List_Eol;
                LASTPROC^.CALLED^.PROCNAME := NIL;
                LASTPROC := FIRSTPROC;
                WHILE LASTPROC <> NIL DO
                BEGIN
                  LISTPTR :=LASTPROC;
                  List_Eol;List_Eol;
                  WRITE (CROSSLIST,LASTPROC^.NAME:11, ' Is called from:');
                  WITH LASTPROC^ DO
                  REPEAT
                    List_Eol;
                    WRITE (CROSSLIST,' ' : 11,CALLEDBY^.PROCNAME^.NAME:11);
                    LISTPTR^.FIRST := CALLEDBY^.FIRST;
                    WR_LINENR (22);
                    CALLEDBY := CALLEDBY^.NEXTPROC;
                  UNTIL CALLEDBY = NIL;
                  List_Eol;List_Eol;
                  IF LASTPROC^.CALLED^.NEXTPROC <> NIL
                    THEN
                      BEGIN
                        WRITE (CROSSLIST,' ' : 11, ' Calls:');
                        WITH LASTPROC^.CALLED^ DO
                        REPEAT
                          List_Eol;
                    WRITE (CROSSLIST,' ' : 11,NEXTPROC^.PROCNAME^.NAME:11);
                          LISTPTR^.FIRST := NEXTPROC^.FIRST;
                          WR_LINENR (22);
                          NEXTPROC := NEXTPROC^.NEXTPROC;
                        UNTIL NEXTPROC = NIL;
                      END;
                  LASTPROC := LASTPROC^.CALLED^.PROCNAME;
                END;
                List_Page;
                WRITE(CROSSLIST,'Procedure Nesting ');List_Eol;
                WRITE(CROSSLIST,'******************');List_Eol;
                PROC_CL := PROC_CF;
                REPEAT
                  List_Eol;
                  WITH PROC_CL^ DO
                  WRITE (CROSSLIST,' ':PROCLEVEL*3,PROCNAME^.NAME : 11,
                         LINENR * INCREMENT : 6,'/',PAGENR : 3);
                  PROC_CL := PROC_CL^.NEXTPROC;
                UNTIL PROC_CL = NIL;
              END;
        END;
  END (*PRINTLISTE*) ;
  {%E}
Function P$Date:Char8;
Begin
  P$Date:='        ';
End;
  Function P$Time:Char8;
Begin
  P$Time:='        ';
End;
  Procedure Option(Var R,I,P,S:Integer);
Begin
  R:=72;I:=2;P:=132;S:=55;
End;
Procedure Init_Files;
Var Name:Array[1..30]Of Char;
Procedure Read_Name;
Var Cur_Char:1..30;
Begin
  Readln(Input,Name);
  For Cur_Char:=1 To 30 Do
    If Name[Cur_Char]>='a' Then
      Name[Cur_Char]:=Chr(Ord(Name[Cur_Char])-Ord('a')+Ord('A'));
End;

Begin
  Reset('CON:',Input);Rewrite('CON:',Output);
  Write(Output,'Input file:');
  Read_Name;
  Reset(Name,OLDSOURCE);
  Write(Output,'Output file:');
  Read_Name;
  Rewrite(Name,NEWSOURCE);
  Write(Output,'Cross file:');
  Read_Name;
  Rewrite(Name,CROSSLIST);
End;
{%E}
BEGIN (*MAIN*)
  Init_Files;
  INIT_PROC;
  INIT_P3;
  INIT;
  WRITELN (OUTPUT);
  WRITELN (OUTPUT,VERSION);
  WRITELN (OUTPUT);
  MAXINC := Big_Line DIV INCREMENT ;
  IF MAXINC > Big_Line
    THEN MAXINC := Big_Line;
  CH := ' ';
  Datum:=P$Date;DayTime:=P$Time;
  Option(RightMargin,Feed,MaxCh,MaxLine);
  If MaxCh<60
    Then MaxCh:=60;
  BackFeed:=Feed;
  BEGIN
    HEADER;
    BLOCK;
    WR_LINE (BUFFLEN+2);
    IF NOT ERRFLAG
      THEN WRITE (OUTPUT,'No ');
    WRITELN (OUTPUT,MESSAGE);
    PRINTLISTE;
    INIT;
  END;
  If Bump
    Then Write(Output,'Some')
    Else Write(Output,'No');
  Writeln(Output,' lines bumped into the right margin');
  If Nasty
    Then Writeln(Output,'Some did not fit even when bumped');
Writeln(Output,'Heap size remaining ',GetSize:1);
END (*MAIN*) .
