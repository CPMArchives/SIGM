External Cross::Init(3);{$L-}{$E-}{$T-}{$C-}
  PROCEDURE INIT_P3;
  BEGIN
    RESNUM[1] := 1;
    RESNUM[2] := 1;
    RESNUM[3] := 7;
    RESNUM[4] :=15;
    RESNUM[5] :=26;
    RESNUM[6] :=32;
    RESNUM[7] :=38;
    RESNUM[8] :=42;
    RESNUM[9] :=44;
    RESNUM[10]:=47;
    RESNUM[11]:=Num_Reserved_Words;
    {%E}
{ NOTE THAT SYMBOLS THAT ARE NOT USED BY THIS PASCAL ARE MADE IMPOSSIBLE TO
     MATCH BY THE ADDITION OF .....'S}
    RESLIST[ 1] :='IF        '; RESSY [ 1] := IFSY;
    RESLIST[ 2] :='TO        '; RESSY [ 2] := OTHERSY;
    RESLIST[ 3] :='OF        '; RESSY [ 3] := OFSY;
    RESLIST[ 4] :='IN        '; RESSY [ 4] := OTHERSY;
    RESLIST[ 5] :='DO        '; RESSY [ 5] := DOSY;
    RESLIST[ 6] :='OR        '; RESSY [ 6] := OTHERSY;
    RESLIST[ 7] :='END       '; RESSY [ 7] := ENDSY;
    RESLIST[ 8] :='FOR       '; RESSY [ 8] := OTHERSY;
    RESLIST[ 9] :='SET       '; RESSY [ 9] := OTHERSY;
    RESLIST[10] :='AND       '; RESSY [10] := OTHERSY;
    RESLIST[11] :='NOT       '; RESSY [11] := OTHERSY;
    RESLIST[12] :='VAR       '; RESSY [12] := VARSY;
    RESLIST[13] :='NIL       '; RESSY [13] := OTHERSY;
    RESLIST[14] :='DIV       '; RESSY [14] := OTHERSY;
    RESLIST[15] :='LOOP......'; RESSY [15] := LOOPSY;
    RESLIST[16] :='CHAR      '; RESSY [16] := OTHERSY;
    RESLIST[17] :='GOTO      '; RESSY [17] := OTHERSY;
    RESLIST[18] :='THEN      '; RESSY [18] := THENSY;
    RESLIST[19] :='ELSE      '; RESSY [19] := ELSESY;
    RESLIST[20] :='WITH      '; RESSY [20] := OTHERSY;
    RESLIST[21] :='CASE      '; RESSY [21] := CASESY;
    RESLIST[22] :='REAL      '; RESSY [22] := OTHERSY;
    RESLIST[23] :='FILE      '; RESSY [23] := OTHERSY;
    RESLIST[24] :='TYPE      '; RESSY [24] := TYPESY;
    RESLIST[25] :='EXIT......'; RESSY [25] := EXITSY;
    RESLIST[26] :='BEGIN     '; RESSY [26] := BEGINSY;
    RESLIST[27] :='ARRAY     '; RESSY [27] := OTHERSY;
    RESLIST[28] :='WHILE     '; RESSY [28] := OTHERSY;
    RESLIST[29] :='CONST     '; RESSY [29] := CONSTSY;
    RESLIST[30] :='LABEL     '; RESSY [30] := LABELSY;
    RESLIST[31] :='UNTIL     '; RESSY [31] := UNTILSY;
    RESLIST[32] :='RECORD    '; RESSY [32] := RECORDSY;
    RESLIST[33] :='REPEAT    '; RESSY [33] := REPEATSY;
    RESLIST[34] :='DOWNTO    '; RESSY [34] := OTHERSY;
    RESLIST[35] :='PACKED    '; RESSY [35] := OTHERSY;
    RESLIST[36] :='OTHERS....'; RESSY [36] := OTHERSSY;
    RESLIST[37] :='EXTERN....'; RESSY [37] := EXTERNSY;
    RESLIST[38] :='INTEGER   '; RESSY [38] := OTHERSY;
    RESLIST[39] :='BOOLEAN   '; RESSY [39] := OTHERSY;
    RESLIST[40] :='FORWARD   '; RESSY [40] := FORWARDSY;
    RESLIST[41] :='FORTRAN...'; RESSY [41] := FORTRANSY;
    RESLIST[42] :='FUNCTION  '; RESSY [42] := FUNCT_SY;
    RESLIST[43] :='EXTERNAL  '; RESSY [43] := EXTERNSY;
    RESLIST[44] :='PROCEDURE '; RESSY [44] := PROC_SY;
    RESLIST[45] :='INITPROCE.'; RESSY [45] := INITPROCSY;
    ResList[46] :='OTHERWISE.'; RESSY [46] := Other_Wise;
    ResList[47] :='SUBPROGRA.'; RESSY [47] := Sub_Program;
  END;
  {%E}
  PROCEDURE INIT_PROC;
  BEGIN
    PROCDEC:=0;
    No_Main:=False;
    Bump:=False;
    Nasty:=False;
    RightMargin:=75;
    I := 0;
    BUFFLEN := 0;
    BUFFMARK := 0;
    BUFFERPTR := 2;
    BUFFINDEX := 0;
    REALLINCNT:= 0;
    LINECNT :=0;
    BLOCKNR := 0;
    LEVEL := 0;
    PAGECNT := 1;
    PAGECNT2 := 0;
    INCREMENT := 1;
    EOB  := FALSE;
    ERRFLAG := FALSE;
    OLDSPACES := FALSE;
    CH := ' ';
    BMARKTEXT := ' ';
    EMARKTEXT := ' ';
    SY := '          ';
    MESSAGE := 'Error in blockstructure';
    DIGITS := ['0'..'9'];
    LETTERS := ['A'..'Z','a'..'z','$','_'];
  ALPHANUM:=['0'..'9','A'..'Z','a'..'z','$','_'](*LETTERS OR DIGITS*);
    DECSYM := [LABELSY..VARSY];
    PROSYM := [FUNCT_SY..INITPROCSY];
    ENDSYM := [FUNCT_SY..EOBSY];      (*PROSYM OR ENDSYMBOLS*)
    BEGSYM := [BEGINSY..IFSY];
    RELEVANTSYM := [LABELSY..INITPROCSY (*DECSYM OR PROSYM*)
                    ,BEGINSY,FORWARDSY,FORTRANSY,EXTERNSY,EOBSY];
  END;
  {%E}
  PROCEDURE INIT;
  BEGIN (*INIT*)
    FOR CH := First_Char TO Last_Char DO FIRSTNAME [CH] := NIL;
    FOR CH := ' ' TO '_' DO DELSY [CH] := OTHERSY;
    DELSY ['('] := LPARENT;
    DELSY [')'] := RPARENT;
    DELSY ['['] := LPARENT;
    DELSY [']'] := RPARENT;
    DELSY [';'] := SEMICOLON;
    DELSY ['.'] := POINT;
    DELSY [':'] := COLON;
    FOR I := 1 TO 147 DO BUFFER [I] := ' ';
    I := 0;
    NEW (FIRSTNAME['M']);
    LISTPTR := FIRSTNAME ['M'];
    WITH FIRSTNAME ['M']^ DO
    BEGIN
      NAME := 'MAIN.     ';
      LLINK := NIL;
      RLINK := NIL;
      NEW (FIRST);
      LAST := FIRST;
      PROCVAR := 1;
      WITH LAST^ DO
      BEGIN
        LINENR := LINECNT;
        CONTLINK := NIL;
      END;
      NEW (CALLED);
      WITH CALLED^ DO
      BEGIN
        PROCNAME := FIRSTNAME ['M'];
        NEXTPROC := NIL;
        NEW (FIRST);
        FIRST^.LINENR := 0;
        FIRST^.CONTLINK := NIL;
        LAST := FIRST;
      END;
      {%E}
      NEW (CALLEDBY);
      WITH CALLEDBY^ DO
      BEGIN
        PROCNAME := FIRSTNAME ['M'];
        NEXTPROC := NIL;
        NEW (FIRST);
        FIRST^.LINENR := 0;
        FIRST^.CONTLINK := NIL;
        LAST := FIRST;
      END;
    END;
    NEW (PROC_CF);
    WITH PROC_CF^ DO
    BEGIN
      PROCNAME := FIRSTNAME ['M'];
      NEXTPROC := NIL;
      LINENR   := 0;
      PROCLEVEL:= 0;
    END;
    PROC_CL := PROC_CF;
  END (*INIT*) ;
.
];
    LETTERS := ['A'..'Z','a'..'z','$','_'];