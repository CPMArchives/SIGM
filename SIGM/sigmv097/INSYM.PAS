External Cross::Insym(1);{$L-}{$C-}{$E-}

Procedure InSymbol(Var Dbl_DecF,Dbl_DecL:Dbl_Ptr;Var CurProc:List_Ptr_Ty);
    Label 1;
    Var
      Base:Integer;Base_Set:Set Of Char;
      OLD_SPACES_MARK,
      (*ALTER ZEICHENVORSCHUB BEI FORMATIERUNG VON KOMMENTAREN*)
      I       : INTEGER;
      OLDSYTY: SYMBOL;
      PROCEDURE READBUFFER;
        PROCEDURE READLINE;
        VAR
          Exit:Boolean;
          CH      : CHAR;
        BEGIN (*READLINE*)
          REPEAT
            Exit:=False;
            WHILE HACK_EOLN (OLDSOURCE) AND NOT (EOF (OLDSOURCE)) DO
            BEGIN
              READLN (OLDSOURCE);
              BEGIN
                IF REALLINCNT = MAXLINE
                  THEN HEADER;
                LINECNT := LINECNT + 1;
                REALLINCNT := REALLINCNT + 1;
                WRITELN (CROSSLIST,' ' : 12,LINECNT * INCREMENT : 5);
                WRITE_LINE_NUMBER;WriteLin;
                IF MAXINC = LINECNT
                  THEN NEWPAGE;
              END;
            END;
            IF NOT EOF(OLDSOURCE)
              THEN READ (OLDSOURCE,CH);
          UNTIL (CH <> ' ') OR (EOF (OLDSOURCE));
            {%E}
          BUFFLEN := 0;
          REPEAT
Exit:=False;
            BUFFLEN := BUFFLEN + 1;
            BUFFER [BUFFLEN] := CH;
            IF (HACK_EOLN (OLDSOURCE) OR (BUFFLEN = 147))
              OR (EOF(OLDSOURCE))
              THEN Exit:=True;
            If Not Exit Then Read (OLDSOURCE,CH);
          UNTIL Exit;
          IF NOT (HACK_EOLN (OLDSOURCE))
            THEN
              BEGIN
                WRITELN (OUTPUT);
             WRITELN (OUTPUT,'Line ',(LINECNT+1)*INCREMENT : 5,'Too long');
              WRITELN (CROSSLIST,' ' : 17,' **** Next line too long ****');
              END
            ELSE
              IF NOT (EOF (OLDSOURCE))
                THEN
                  BEGIN
                    READLN (OLDSOURCE);
                  END;
          BUFFERPTR := 1;
          BUFFMARK := 0;
        END (*READLINE*) ;
        {%E}
      BEGIN (*READBUFFER*)
        IF BUFFERPTR = BUFFLEN + 2
          THEN
            BEGIN
              WR_LINE (BUFFERPTR);
              CH := ' ';
              IF EOF (OLDSOURCE)
                THEN EOB := TRUE
                ELSE READLINE;
            END
          ELSE
            BEGIN
              CH := BUFFER [BUFFERPTR];
              BUFFERPTR := BUFFERPTR + 1;
            END;
      END (*READBUFFER*) ;
      PROCEDURE PARENTHESE;
      VAR
        OLD_SPACES_MARK : INTEGER;
        (*ALTER ZEICHENVORSCHUB BEI FORMATIERUNG VON KLAMMERN*)
      BEGIN (*PARENTHESE*)
        OLD_SPACES_MARK := SPACES;
        IF OLDSPACES
          THEN SPACES := LASTSPACES + BUFFERPTR - 2
          ELSE
            BEGIN
              LASTSPACES := SPACES;
              SPACES := SPACES + BUFFERPTR - 2;
              OLDSPACES := TRUE;
            END;
        REPEAT
          INSYMBOL(Dbl_DecF,Dbl_DecL,CurProc)
        UNTIL SYTY IN [RPARENT,EOBSY];
        SPACES := OLD_SPACES_MARK;
        OLDSPACES := TRUE;
        INSYMBOL(Dbl_DecF,Dbl_DecL,CurProc);
      END (*PARENTHESE*) ;
      {%E}
      FUNCTION RESWORD: BOOLEAN ;
      LABEL
        1;
      VAR
        I       : INTEGER;
      BEGIN (*RESWORD*)
        RESWORD:= FALSE;
        FOR I:=RESNUM[CHCNT] TO RESNUM [CHCNT + 1] -1 DO
        IF RESLIST[ I ] = SY
          THEN
            BEGIN
              RESWORD := TRUE;
              SYTY := RESSY [I];
              If Syty=Sub_Program
                Then
                  Begin
                    SyTy:=OtherSy;
                    No_Main:=True;
                  End;
              GOTO 1;
            END;
1:
      END (*RESWORD*) ;
      {%E}
      PROCEDURE FINDNAME;
      LABEL
        1;
      VAR
        PROCPTR : PROC_CALL_TYPE;
        (*ZEIGER AUF RUFENDE BZW. GERUFENE PROZEDUR BEI DEREN VERKETTUNG*)
        LPTR: LIST_PTR_TY;        (*ZEIGER AUF DEN VORGAENGER IM BAUM*)
        ZPTR : LINE_PTR_TY;
        (*ZEIGER AUF DIE VORLETZTE ZEILENNUMMER IN EINER KETTE*)
      RIGHT: BOOLEAN;         (*MERKVARIABLE FUER DIE VERZWEIGUNG IM BAUM*)
        INDEXCH : CHAR;
        (*INDEXVARIABLE FUER DAS FELD DER STARTZEIGER (FIRSTNAME)*)
        PROCEDURE FINDPROC (COMP : LIST_PTR_TY);
        VAR
          PROCCALLPTR : PROC_CALL_TYPE;
          (*MERK SICH LETZTE PROZEDUR FALLS EINE NEUE ERZEUGT WERDEN MUSS*)
        BEGIN (*FINDPROC*)
        WHILE (PROCPTR^.PROCNAME <> COMP) AND (PROCPTR^.NEXTPROC <> NIL) DO
          PROCPTR := PROCPTR^.NEXTPROC;
          IF PROCPTR^.PROCNAME = COMP
            THEN
              BEGIN
                ZPTR := PROCPTR^.LAST;
                NEW (PROCPTR^.LAST);
                WITH PROCPTR^.LAST^ DO
                BEGIN
                  LINENR := LINECNT + 1;
                  PAGENR := PAGECNT;
                  CONTLINK := NIL;
                END;
                ZPTR^.CONTLINK := PROCPTR^.LAST;
              END
            ELSE
              BEGIN
                PROCCALLPTR := PROCPTR;
                NEW (PROCPTR);
                WITH PROCPTR^ DO
                BEGIN
                  PROCNAME := COMP;
                  NEXTPROC := NIL;
                  NEW (FIRST);
                  WITH FIRST^ DO
                  BEGIN
                    LINENR := LINECNT + 1;
                    PAGENR := PAGECNT;
                    CONTLINK := NIL;
                  END;
                  LAST := FIRST;
                END;
                PROCCALLPTR^.NEXTPROC := PROCPTR;
              END;
        END (*FINDPROC*) ;
        {%E}
        PROCEDURE NEWPROCEDURE;
        BEGIN (*NEWPROCEDURE*)
          WITH LISTPTR^ DO
          BEGIN
            PROCVAR := PROCDEC;
            NEW (CALLEDBY);
            WITH CALLEDBY^ DO
            BEGIN
              PROCNAME := CURPROC;
              NEXTPROC := NIL;
              NEW (FIRST);
              WITH FIRST^ DO
              BEGIN
                LINENR := LINECNT + 1;
                PAGENR := PAGECNT;
                CONTLINK := NIL;
              END;
              LAST := FIRST;
            END;
            NEW (CALLED);
            WITH CALLED^ DO
            BEGIN
              PROCNAME := FIRSTNAME ['M'];
              NEXTPROC := NIL;
              NEW (FIRST);
              WITH FIRST^ DO
              BEGIN
                LINENR := LINECNT + 1;
                PAGENR := PAGECNT;
                CONTLINK := NIL;
              END;
              LAST := FIRST;
            END;
          END;
          NEW (PROC_CL^.NEXTPROC);
          PROC_CL := PROC_CL^.NEXTPROC;
          WITH PROC_CL^ DO
          BEGIN
            PROCNAME := LISTPTR;
            NEXTPROC := NIL;
            LINENR := LINECNT + 1;
            PAGENR := PAGECNT;
            PROCLEVEL := LEVEL;
          END;
        END (*NEWPROCEDURE*) ;
        {%E}
      BEGIN (*FINDNAME*)
        INDEXCH := SY [1];
        LISTPTR := FIRSTNAME [INDEXCH];
        WHILE LISTPTR <> NIL DO
        BEGIN
          LPTR:= LISTPTR;
          IF SY = LISTPTR^.NAME
            THEN
              BEGIN
                ZPTR := LISTPTR^.LAST;
                NEW (LISTPTR^.LAST);
                WITH LISTPTR^.LAST^ DO
                BEGIN
                  LINENR := LINECNT + 1;
                  PAGENR := PAGECNT;
                  CONTLINK := NIL;
                END;
                ZPTR^.CONTLINK := LISTPTR^.LAST;
                IF LISTPTR^.PROCVAR <> 0
                  THEN
                    BEGIN
                      IF LISTPTR^.PROCVAR = 2
                        THEN WHILE CH = ' ' DO
                          BEGIN
                            SYLENG := SYLENG + 1;
                            READBUFFER;
                          END;
                      IF (CH <> ':') OR (LISTPTR^.PROCVAR = 1)
                        THEN
                          BEGIN
                            PROCPTR := LISTPTR^.CALLEDBY;
                            FINDPROC (CURPROC);
                            PROCPTR := CURPROC^.CALLED;
                            FINDPROC (LISTPTR);
                          END
                    END
                      {%E}
                  ELSE
                    IF PROCDEC <> 0
                      THEN
                        BEGIN
                          IF DBL_DECF = NIL
                            THEN
                              BEGIN
                                NEW (DBL_DECF);
                                DBL_DECL := DBL_DECF;
                              END
                            ELSE
                              BEGIN
                                NEW (DBL_DECL^.NEXTPROC);
                                DBL_DECL := DBL_DECL^.NEXTPROC;
                              END;
                          DBL_DECL^.NEXTPROC := NIL;
                          DBL_DECL^.PROCORT := LISTPTR;
                          NEWPROCEDURE;
                        END;
                GOTO 1;
              END
            ELSE
              IF SY > LISTPTR^.NAME
                THEN
                  BEGIN
                    LISTPTR:= LISTPTR^.RLINK;
                    RIGHT:= TRUE;
                  END
                ELSE
                  BEGIN
                    LISTPTR:= LISTPTR^.LLINK;
                    RIGHT:= FALSE;
                  END;
        END;
        {%E}
        NEW (LISTPTR);
        WITH LISTPTR^ DO
        BEGIN
          NAME := SY;
          LLINK := NIL;
          RLINK := NIL;
        END;
        IF FIRSTNAME [INDEXCH] = NIL
          THEN FIRSTNAME [INDEXCH] := LISTPTR
          ELSE
            IF RIGHT
              THEN LPTR^.RLINK := LISTPTR
              ELSE LPTR^.LLINK := LISTPTR;
        WITH LISTPTR^ DO
        BEGIN
          NEW (FIRST);
          WITH FIRST^ DO
          BEGIN
            LINENR := LINECNT + 1;
            PAGENR := PAGECNT;
            CONTLINK := NIL;
          END;
          LAST := FIRST ;
          IF PROCDEC = 0
            THEN
              BEGIN
                PROCVAR := 0;
                CALLED := NIL;
                CALLEDBY := NIL;
              END
            ELSE NEWPROCEDURE;
        END;
1:
        PROCDEC := 0;
      END (*FINDNAME*) ;
      {%E}
      PROCEDURE CHECK_E(Pos:Integer);
        {CHECK FOR THE E OPTION AND PAGE IF SO}
      BEGIN
        If (Buffer[Pos+1]='%')And
          ((Buffer[Pos+2]='E')Or(Buffer[Pos+2]='e'))
          Then NewPage;
      End;
      Procedure SkipComment(C:Char;Pos:Integer);
      Begin {Skip over comments checking for eject option}
        IF  C='{'
          Then
            Begin
              Check_E(Pos-1);
              While (CH<>'}')And (Not Eob) Do
              Begin
                ReadBuffer;
              End;
            End
          Else
            Begin
              ReadBuffer;
              Check_E(Pos);
              Repeat
                ReadBuffer
              Until(Ch=')')And(Buffer[BufferPtr-2]='*')Or Eob;
            End;
      End;
      {%E}
      PROCEDURE FINDCOMMENT;
      LABEL
        1;
      VAR
        C: CHAR;
        I: INTEGER;
        FOUND: BOOLEAN;
      BEGIN
        I:= BUFFERPTR - 1;
        C:= ' ';
        FOUND := FALSE;
        WHILE (C=' ') AND (I<BUFFLEN) DO
        BEGIN
          C:= BUFFER[I];
          IF (C='{') OR (C='(') AND (BUFFER[I+1]='*')
            THEN
              BEGIN
                FOUND := TRUE;
                GOTO 1;
              END;
          I:= I + 1;
        END;
1:
        IF FOUND
          THEN
            Begin
              While (Ch<>'{')And(Ch<>'(')Do ReadBuffer;
              SkipComment(Ch,BufferPtr);
            END;
        ReadBuffer;
      End;
      FUNCTION UPPER(C:CHAR):CHAR;
      BEGIN
        IF (C>='a')And(C<='z')
          Then Upper:=CHR(ORD(C)-Ord('a')+ord('A'))
          Else Upper:=C;
      End;
      {%E}
    BEGIN (*INSYMBOL*)
      SYLENG := 0;
      WHILE ((CH IN ['(',' ','?','!','@'])OR(CH='{')
             OR(CH='}'))AND NOT EOB DO
      BEGIN
        IF (CH = '{') OR (CH = '(') AND (BUFFER[BUFFERPTR] = '*')
          THEN
            BEGIN
              OLD_SPACES_MARK := SPACES;
              IF OLDSPACES
                THEN SPACES := LASTSPACES
                ELSE  LASTSPACES := SPACES;
              SPACES := SPACES + BUFFERPTR - 1;
              OLDSPACES := TRUE;
              SkipComment(CH,BufferPtr);
              SPACES := OLD_SPACES_MARK;
              OLDSPACES := TRUE;
            END
          ELSE
            IF CH = '('
              THEN GOTO 1;
        READBUFFER;
      END;
      IF CH = ''''
        THEN
          BEGIN
            SYTY := STRGCONST;
            REPEAT
              READBUFFER;
            UNTIL (CH = '''') OR EOB;
            READBUFFER;
          END
        ELSE
          IF CH IN LETTERS
            THEN
              BEGIN
                SYLENG := 0;
                REPEAT
                  SYLENG := SYLENG + 1;
                  IF SYLENG <= 10
                    THEN SY [SYLENG] :=UPPER(CH);
                  READBUFFER;
                UNTIL NOT (CH IN ALPHANUM);
                FOR I := SYLENG + 1 TO 10 DO SY [I] := ' ';
                IF SYLENG > 10
                  THEN CHCNT := 10
                  ELSE CHCNT := SYLENG;
                IF NOT RESWORD
                  THEN
                    BEGIN
                      SYTY := IDENT ;
                      FINDNAME;
                    END
              END
            ELSE
              {%E}
              IF CH IN DIGITS
                THEN
                  BEGIN
                    Base:=0;
                    REPEAT
If Base<36 Then
                      Base:=Base*10+Ord(Ch)-Ord('0');
                      READBUFFER;
                    UNTIL NOT (CH IN DIGITS);
                    SYTY := INTCONST;
                    If (Ch='#')And (Base<36)
                      Then
                        Begin
                          Base_Set:=Digits;
                          For Base:=Base DownTo 11 Do
                          Base_Set:=Base_Set+[Chr(Base-11+Ord('A'))];
                          Repeat
                            ReadBuffer;
                          Until Not(Ch In Base_Set);
                        End;
                    BEGIN
                      IF CH = '.'
                        THEN
                          BEGIN
                            REPEAT
                              READBUFFER
                            UNTIL NOT (CH IN DIGITS);
                            SYTY := OTHERSY;
                          END;
                      IF (CH = 'E')OR(CH='e')
                        THEN
                          BEGIN
                            READBUFFER;
                            IF CH IN ['+','-']
                              THEN READBUFFER;
                            WHILE CH IN DIGITS DO READBUFFER;
                            SYTY := OTHERSY;
                          END;
                    END;
                  END
                ELSE
                  IF CH <> ' '
                    THEN
                      BEGIN
                        1
:
                        OLDSYTY := SYTY;
If (CH<' ')Or(CH>'_')Then SYTY:=OTHERSY
Else
                        SYTY := DELSY [CH];
                        READBUFFER;
                        IF (OLDSYTY=ENDSY) AND (SYTY=SEMICOLON)
                          THEN FINDCOMMENT;
                        IF SYTY = LPARENT
                          THEN PARENTHESE
                          ELSE
                            IF (SYTY = COLON) AND (CH = '=')
                              THEN
                                BEGIN
                                  SYTY := OTHERSY;
                                  READBUFFER;
                                END;
                      END
                    ELSE SYTY := EOBSY;
    END (*INSYMBOL*) ;
.



);
    END (*INSYMBOL*