 External Cross::Block(2);{$L-}{$E-}{$C-}{$T-}
  PROCEDURE BLOCK;
  VAR
    DBL_DECF,
    (*ZEIGER AUF ERSTE UND LETZTE VARIABLE DIE ALS PROCEDURE*)
    DBL_DECL : ^DBL_DEC;    (*IN DIESEM BLOCK DOPPELT DEKLARIERT WURDEN*)
    CURPROC : LIST_PTR_TY;
    Exit_Set:Set Of Symbol;
    Exit:Boolean;
    (*ZEIGER AUF DIE PROZEDUR IN DEREN
     ANWEISUNGSTEIL DAS PROGRAMM SICH BEFINDET*)
    {%E}
    PROCEDURE RECDEF;
    VAR
      OLD_SPACES_MARK  : INTEGER;
      (*ALTER ZEICHENVORSCHUB BEI FORMATIERUNG VON RECORDS*)
      PROCEDURE CASEDEF;
      VAR
        OLD_SPACES_MARK  : INTEGER;
        (*ALTER ZEICHENVORSCHUB BEI FORMATIERUNG VON VARIANT PARTS*)
        PROCEDURE PARENTHESE;
        VAR
          OLD_SPACES_MARK : INTEGER;
          (*ALTER ZEICHENVORSCHUB BEI FORMATIERUNG
           VON KLAMMERN INNERHALB VON VARIANT PARTS*)
        BEGIN (*PARENTHESE*)
          OLD_SPACES_MARK := SPACES;
          IF OLDSPACES
            THEN SPACES := LASTSPACES
            ELSE LASTSPACES := SPACES;
          SPACES := SPACES + BUFFERPTR - 2;
          OLDSPACES := TRUE;
          REPEAT
            INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
            CASE SYTY OF
              LBRACK :
                     PARENTHESE;
              CASESY :
                     CASEDEF;
              RECORDSY :
                     RECDEF;
              Else:{}
            END;
          UNTIL SYTY IN [RPARENT,EOBSY];
          SPACES := OLD_SPACES_MARK;
          OLDSPACES := TRUE;
          INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
        END (*PARENTHESE*) ;
        {%E}
      BEGIN (*CASEDEF*)
        DELSY ['('] := LBRACK;
        OLD_SPACES_MARK := SPACES;
        IF OLDSPACES
          THEN SPACES := LASTSPACES
          ELSE LASTSPACES := SPACES;
        SPACES := BUFFERPTR - BUFFMARK + SPACES - SYLENG + 3;
        OLDSPACES := TRUE;
        REPEAT
          INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC) ;
          CASE SYTY OF
            LBRACK :
                   PARENTHESE;
            CASESY :
                   CASEDEF;
            RECORDSY:
                   RECDEF;
            Else: {}
          END;
        UNTIL SYTY IN [ENDSY,RPARENT,EOBSY];
        SPACES := OLD_SPACES_MARK;
        DELSY ['('] := LPARENT;
      END (*CASEDEF*) ;
    BEGIN (*RECDEF*)
      OLD_SPACES_MARK := SPACES;
      SPACES := BUFFERPTR - BUFFMARK + SPACES - SYLENG - 2 + FEED;
      OLDSPACES := TRUE;
      INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
      WR_LINE ( BUFFERPTR-SYLENG);
      REPEAT
        CASE SYTY OF
          CASESY :
                 CASEDEF;
          RECORDSY :
                 RECDEF;
          Else:
                 INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC)
        END;
      UNTIL SYTY IN [ENDSY,EOBSY];
      WR_LINE (BUFFERPTR-SYLENG);
      OLDSPACES := TRUE;
      LASTSPACES := SPACES - FEED;
      SPACES := OLD_SPACES_MARK;
      INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
    END (*RECDEF*) ;
    {%E}
    PROCEDURE ERROR (ERRNR : INTEGER);
    BEGIN (*ERROR*)
      ERRFLAG := TRUE;
      WR_LINE (BUFFERPTR);
      WRITE (CROSSLIST,' ':17,' **** ');
      CASE ERRNR OF
        1 :
               WRITELN (CROSSLIST,SY,' ? ? ? ',MESSAGE);
        2 :
    WRITELN (CROSSLIST,'Missing ''End'' OR ''Until'' Number ',EMARKNR : 4);
        3 :
               WRITELN (CROSSLIST,'Missing ''Then'' Number ',EMARKNR : 4);
        4 :
      WRITELN (CROSSLIST,'Missing ''Of'' To ''Case'' Number ',BMARKNR : 4);
        5 :
               WRITELN (CROSSLIST,' Only one ''Exit'' allowed');
        6 :
            WRITELN (CROSSLIST,'Missing ''Exit'' in ''Loop'' ',EMARKNR : 4)
      END;
    END (*ERROR*) ;
    {%E}
    PROCEDURE STATEMENT ;
    VAR
      CURBLOCKNR : INTEGER;     (*AKTUELLE BLOCKNUMMER*)
      PROCEDURE COMPSTAT;
Var Exit:Boolean;
      BEGIN (*COMPSTAT*)
        BMARKTEXT := 'B';
        OLDSPACES := TRUE;
        LASTSPACES := SPACES - BACKFEED;
        INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
        WR_LINE (BUFFERPTR-SYLENG);
        REPEAT
Exit:=False;
          REPEAT
            STATEMENT ;
          UNTIL SYTY IN ENDSYM;
          IF SYTY IN [ENDSY,EOBSY,PROC_SY,FUNCT_SY]
            THEN Exit:=True;
If Not Exit Then
Begin
          ERROR (1);
          INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC) ;
End;
        UNTIL Exit;
        WR_LINE (BUFFERPTR-SYLENG);
        EMARKTEXT := 'E';
        EMARKNR := CURBLOCKNR;
        LASTSPACES := SPACES-BACKFEED;
        OLDSPACES := TRUE;
        IF SYTY = ENDSY
          THEN
            BEGIN
              INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC) ;
              WR_LINE (BUFFERPTR-SYLENG);
            END
          ELSE ERROR (2);
      END (*COMPSTAT*) ;
      {%E}
      PROCEDURE CASESTAT;
      VAR
        OLD_SPACES_MARK : INTEGER;
        (*ALTER ZEICHENVORSCHUB BEI FORMATIERUNG VON CASE-STATEMENTS*)
Exit:Boolean;
Exit_Set,Exit_S2:Set Of Symbol;
      BEGIN (*CASESTAT*)
        BMARKTEXT := 'C';
        OLDSPACES := TRUE;
        LASTSPACES := SPACES-BACKFEED;
        INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
        STATEMENT ;
        IF SYTY = OFSY
          THEN WR_LINE (BUFFERPTR)
          ELSE ERROR (3);
        REPEAT
Exit:=False;
          REPEAT
            REPEAT
              If SyTy<>Other_Wise
                Then
                  INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC) ;
Exit_Set:=(EndSym-[ElseSy]+[Colon,Other_Wise]);
            UNTIL SYTY IN Exit_Set;
            IF (SYTY = COLON)Or(SyTy=Other_Wise)
              THEN
                BEGIN
                  OLD_SPACES_MARK := SPACES;
                  LASTSPACES := SPACES;
                  SPACES := OLD_SPACES_MARK + CASEFEED;
                  OLDSPACES := TRUE;
                  INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
                  IF NOT ( SYTY IN BEGSYM )
                    THEN
                      BEGIN
                        WR_LINE ( BUFFERPTR - SYLENG );
                        SPACES := SPACES +1;
                      END;
                  STATEMENT ;
                  SPACES := OLD_SPACES_MARK;
                END;
Exit_S2:=EndSym-[ElseSy];
          UNTIL SYTY IN Exit_S2;
          IF SYTY IN [ENDSY,EOBSY,PROC_SY,FUNCT_SY]
            THEN Exit:=True;
If Not Exit Then
          ERROR (1);
        UNTIL Exit;
        WR_LINE (BUFFERPTR-SYLENG);
        EMARKTEXT := 'E';
        EMARKNR := CURBLOCKNR;
        LASTSPACES := SPACES-BACKFEED;
        OLDSPACES := TRUE;
        IF SYTY = ENDSY
          THEN
            BEGIN
              INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC) ;
              WR_LINE (BUFFERPTR-SYLENG);
            END
          ELSE ERROR (2);
      END (*CASESTAT*) ;
      {%E
       PROCEDURE LOOPSTAT;
       VAR
       LOOPFLAG : BOOLEAN;     (*GESETZT BEIM AUFTRETEN VON EXIT-STATEMENTS
       BEGIN (*LOOPSTAT
       BMARKTEXT := 'L';
       OLDSPACES := TRUE;
       LASTSPACES := SPACES - BACKFEED;
       INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
       WR_LINE (BUFFERPTR-SYLENG);
       LOOPFLAG := FALSE;
       REPEAT
       REPEAT
       STATEMENT ;
       IF SYTY = EXITSY
       THEN
       BEGIN
       WR_LINE (BUFFERPTR-SYLENG);
       IF LOOPFLAG
       THEN ERROR (5);
       OLDSPACES := TRUE;
       LASTSPACES := SPACES-BACKFEED;
       LOOPFLAG := TRUE;
       EMARKTEXT := 'X';
       EMARKNR := CURBLOCKNR;
       INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC); INSYMBOL(Dbl_DecL,CurProc);
       END;
       UNTIL SYTY IN ENDSYM;
       IF SYTY IN [ENDSY,EOBSY,PROC_SY,FUNCT_SY]
       THEN Exit:=True;
If Not Exit Then
Begin
       ERROR (1);
       INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC) ;
End;
       UNTIL Exit;
       WR_LINE (BUFFERPTR-SYLENG);
       EMARKTEXT := 'E';
       EMARKNR := CURBLOCKNR;
       LASTSPACES := SPACES-BACKFEED;
       OLDSPACES := TRUE;
       IF SYTY = ENDSY
       THEN
       BEGIN
       INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC) ;
       WR_LINE (BUFFERPTR-SYLENG);
       END
       ELSE ERROR (2);
       IF NOT LOOPFLAG
       THEN ERROR (6);
       END (*LOOPSTAT ;
       }
      {%E}
      PROCEDURE IFSTAT ;
      BEGIN (*IFSTAT*)
        BMARKTEXT := 'I';
        LASTSPACES := SPACES - BACKFEED;
        OLDSPACES := TRUE;
        INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
        STATEMENT ;
        SPACES:=SPACES+FEED;
        IF SYTY = THENSY
          THEN
            BEGIN
              WR_LINE (BUFFERPTR-SYLENG);
              LASTSPACES := SPACES - BACKFEED;
              OLDSPACES := TRUE;
              EMARKTEXT := 'T';
              EMARKNR := CURBLOCKNR;
              INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
              STATEMENT ;
            END
          ELSE ERROR (4);
        IF SYTY = ELSESY
          THEN
            BEGIN
              OLDSPACES := TRUE;
              LASTSPACES := SPACES - BACKFEED;
              WR_LINE (BUFFERPTR-SYLENG);
              EMARKTEXT := 'S';
              EMARKNR := CURBLOCKNR;
              LASTSPACES := SPACES - BACKFEED;
              OLDSPACES := TRUE;
              INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
              STATEMENT ;
            END;
        SPACES:=SPACES-FEED;
      END (*IFSTAT*) ;
      {%E}
      PROCEDURE LABELSTAT;
      BEGIN (*LABELSTAT*)
        LASTSPACES := 0;
        OLDSPACES := TRUE;
        INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
        WR_LINE (BUFFERPTR-SYLENG);
      END (*LABELSTAT*) ;
      PROCEDURE REPEATSTAT;
Var Exit:Boolean;
      BEGIN (*REPEATSTAT*)
        BMARKTEXT := 'R';
        OLDSPACES := TRUE;
        LASTSPACES := SPACES - BACKFEED;
        INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC) ;
        WR_LINE (BUFFERPTR-SYLENG);
        REPEAT
Exit:=False;
          REPEAT
            STATEMENT ;
          UNTIL SYTY IN ENDSYM;
          IF SYTY IN [UNTILSY,EOBSY,PROC_SY,FUNCT_SY]
            THEN Exit:=True;
If Not Exit Then
Begin
          ERROR (1);
          INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC) ;
End;
        UNTIL EXIT;
        WR_LINE (BUFFERPTR-SYLENG);
        EMARKTEXT := 'U';
        EMARKNR := CURBLOCKNR;
        OLDSPACES := TRUE;
        LASTSPACES := SPACES-BACKFEED;
        IF SYTY = UNTILSY
          THEN
            BEGIN
              INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
              STATEMENT ;
            END
          ELSE ERROR (2);
      END (*REPEATSTAT*) ;
      {%E}
    BEGIN (*STATEMENT*)
      IF SYTY = INTCONST
        THEN
          BEGIN
            INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
            IF SYTY = COLON
              THEN LABELSTAT;
          END;
      IF SYTY IN BEGSYM
        Then
          BEGIN
            BLOCKNR := BLOCKNR + 1;
            CURBLOCKNR := BLOCKNR;
            BMARKNR := CURBLOCKNR;
            WR_LINE (BUFFERPTR-SYLENG);
            SPACES := SPACES + FEED;
            CASE SYTY OF
              BEGINSY :
                     COMPSTAT;
                     {             LOOPSY  :
                      LOOPSTAT;         }
              CASESY  :
                     CASESTAT;
              IFSY    :
                     IFSTAT ;
              REPEATSY :
                     REPEATSTAT ;
              Else:{}
            END;
            SPACES := SPACES - FEED;
          END
 ELSE
 WHILE NOT(SYTY IN([SEMICOLON,Colon]+ENDSYM))DO
INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
      IF (SYTY = SEMICOLON)Or(SyTy=Colon)
        THEN INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC)
        ELSE
          IF SYTY = DOSY
            THEN
              BEGIN
                INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
                STATEMENT ;
              END;
    END (*STATEMENT*) ;
    {%E}
  BEGIN (*BLOCK*)
    DBL_DECF := NIL;
    LEVEL := LEVEL + 1;
    CURPROC := LISTPTR;
If Level=1 Then
Begin
  Insymbol(Dbl_DecF,Dbl_DecL,CurProc);
  No_Main:=SyTy=ExternSy;
  While SyTy<>Semicolon Do InSymbol(Dbl_DecF,Dbl_DecL,CurProc);
End;
    SPACES := LEVEL * FEED;
    REPEAT
      INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC)
    UNTIL (SYTY IN RELEVANTSYM);
    Repeat
      WHILE SYTY IN (DECSYM) DO
      BEGIN
        WR_LINE (BUFFERPTR-SYLENG);
        SPACES := SPACES - FEED;
        WR_LINE (BUFFERPTR);
        SPACES := SPACES + FEED;
        REPEAT
          INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC) ;
          IF SYTY = RECORDSY
            THEN RECDEF;
        UNTIL SYTY IN RELEVANTSYM;
      END;
      WHILE SYTY IN PROSYM DO
      BEGIN
        WR_LINE (BUFFERPTR-SYLENG);
        OLDSPACES := TRUE;
        IF SYTY <> INITPROCSY
          THEN
            BEGIN
              IF SYTY = PROC_SY
                THEN PROCDEC := 1
                ELSE PROCDEC := 2;
              INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
            END;
        BLOCK;
        IF SYTY = SEMICOLON
          THEN INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
      END;
Exit_Set:=ProSym+DecSym;
Exit:=Not (SyTy In Exit_Set);
    Until Exit;
    LEVEL := LEVEL - 1;

    SPACES := LEVEL * FEED;
    IF NOT ((SYTY IN [BEGINSY,FORWARDSY,EXTERNSY,FORTRANSY,EobSy])
            Or((No_Main)And (SyTy=Point)))
      THEN
        BEGIN
          ERROR (1);
WHILE NOT
(SYTY IN [BEGINSY,FORWARDSY,EXTERNSY,FORTRANSY,EOBSY])
 DO INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC)
        END;
        {%E}
    IF SYTY = BEGINSY
      THEN STATEMENT
      ELSE
        BEGIN
          INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC) ;
          IF SYTY = FORTRANSY
            THEN INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC) ;
        END ;
    IF DBL_DECF <> NIL
      THEN
        REPEAT
          DBL_DECF^.PROCORT^.PROCVAR := 0;
          DBL_DECF := DBL_DECF^.NEXTPROC;
        UNTIL  DBL_DECF = NIL;
    IF (LEVEL = 0)And (Not No_Main)
      THEN
        BEGIN
          IF SYTY <> POINT
            THEN
              BEGIN
                WRITELN (OUTPUT,'Missing point at program end');
                WRITELN (OUTPUT);
   WRITELN (CROSSLIST,' ' : 17, ' **** Missing point at program end ****');
                INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC);
              END;
          IF SYTY <> EOBSY
            THEN
              REPEAT
                INSYMBOL(DBL_DECF,Dbl_DecL,CURPROC)
              UNTIL SYTY = EOBSY;
        END;
  END (*BLOCK*) ;
.
      IF SYTY = RECORDSY
            THEN RECDEF;
        UNTIL