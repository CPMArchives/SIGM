      LETTER      : GETIDENTIFIER(
                                   (* UPDATING *)  CURRCHAR,
                                                   NEXTCHAR,
                                   (* RETURNING *) NAME,
                                                   VALUE,
                                                   LENGTH    );
      DIGIT       : GETNUMBER(
                               (* UPDATING *)  CURRCHAR,
                                               NEXTCHAR,
                               (* RETURNING *) NAME,
                                               VALUE,
                                               LENGTH    );
      QUOTE       : GETCHARLITERAL(
                                    (* UPDATING *)  CURRCHAR,
                                                    NEXTCHAR,
                                    (* RETURNING *) NAME,
                                                    VALUE,
                                                    LENGTH    );
      OTHERCHAR   : BEGIN
                               GETSPECIALCHAR(
                                       (* UPDATING *)  CURRCHAR,
                                                       NEXTCHAR,
                                       (* RETURNING *) NAME,
                                                       VALUE,
                                                       LENGTH    );
                       IF NAME = OPENCOMMENT
                          THEN
                             GETCOMMENT(
                                         (* UPDATING *) CURRCHAR,
                                                        NEXTCHAR,
                                                        NAME,
                                                        VALUE,
                                                        LENGTH    )
                    END;
      FILEMARK    : NAME := ENDOFFILE
   END (* CASE *)
END; (* GETNEXTSYMBOL *)
PROCEDURE GETSYMBOL(
                     (* UPDATING *)  VAR NEXTSYM   : SYMBOLINFO;
                     (* RETURNING *) VAR CURRSYM   : SYMBOLINFO );
VAR
    DUMMY: SYMBOLINFO;
BEGIN (* GETSYMBOL *)
   DUMMY   := CURRSYM;
   CURRSYM := NEXTSYM;
   NEXTSYM := DUMMY  ;
   WITH NEXTSYM^ DO
      BEGIN
         SKIPSPACES(
                     (* UPDATING *)  CURRCHAR,
                                     NEXTCHAR,
                     (* RETURNING *) SPACESBEFORE,
                                     CRSBEFORE     );
         LENGTH := 0;
         IF CURRSYM^.NAME = OPENCOMMENT
            THEN
               GETCOMMENT(
                           (* UPDATING *)  CURRCHAR,
                                           NEXTCHAR,
                           (* RETURNING *) NAME,
                                           VALUE,
                                           LENGTH    )
            ELSE
               GETNEXTSYMBOL(
                              (* UPDATING *)  CURRCHAR,
                                              NEXTCHAR,
                              (* RETURNING *) NAME,
                                                        VALUE,
                                              LENGTH    )
      END (* WITH *)
END; (* GETSYMBOL *)
 PROCEDURE INT2 ( VAR TOPOFSTACK : INTEGER;
 VAR CURRLINEPOS,
     CURRMARGIN : INTEGER;
 VAR KEYWORD    : KEYWORDTABLE;
 VAR DBLCHARS   : DBLCHRSET;
 VAR DBLCHAR    : DBLCHARTABLE;
 VAR SGLCHAR    : SGLCHARTABLE;
 VAR RECORDSEEN : BOOLEAN;
 VAR CURRCHAR,
     NEXTCHAR   : CHARINFO;
 VAR CURRSYM,
     NEXTSYM    : SYMBOLINFO;
 VAR PPOPTION   : OPTIONTABLE );
 
BEGIN
   WITH PPOPTION [ OFSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ CRSUPPRESS,
                                SPACEBEFORE ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ FORSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ SPACEAFTER,
                                INDENTBYTAB,
                                GOBBLESYMBOLS,
                                CRAFTER ];
         DINDENTSYMBOLS    := [];
                                  GOBBLETERMINATORS := [ DOSYM ]
      END;
   WITH PPOPTION [ WHILESYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ SPACEAFTER,
                                INDENTBYTAB,
                                GOBBLESYMBOLS,
                                CRAFTER ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := [ DOSYM ]
      END;
   WITH PPOPTION [ WITHSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ SPACEAFTER,
                                INDENTBYTAB,
                                GOBBLESYMBOLS,
                                CRAFTER ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := [ DOSYM ]
      END;
   WITH PPOPTION [ DOSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ CRSUPPRESS,
                                SPACEBEFORE ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END;

   WITH PPOPTION [ IFSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ SPACEAFTER,
                                INDENTBYTAB,
                                             GOBBLESYMBOLS,
                                CRAFTER ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := [ THENSYM ]
      END;
   WITH PPOPTION [ THENSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ INDENTBYTAB, CRAFTER ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ ELSESYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ CRBEFORE,
                                DINDENTONKEYS,
                                DINDENT,
                                INDENTBYTAB,
                                CRAFTER ];
         DINDENTSYMBOLS    := [ IFSYM,
                                ELSESYM ];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ ENDSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ CRBEFORE,
                                DINDENTONKEYS,
                                DINDENT,
                                CRAFTER ];
         DINDENTSYMBOLS    := [ IFSYM,
                                THENSYM,
                                ELSESYM,
                                FORSYM,
                                WHILESYM,
                                WITHSYM,
                                CASEVARSYM,
                                COLON,
                                EQUALS ];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ UNTILSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ CRBEFORE,
                                DINDENTONKEYS,
                                DINDENT,
                                SPACEAFTER,
                                GOBBLESYMBOLS,
                                CRAFTER ];
         DINDENTSYMBOLS    := [ IFSYM,
                                THENSYM,
                                ELSESYM,
                                FORSYM,
                                WHILESYM,
                                WITHSYM,
                                COLON,
                                EQUALS ];
         GOBBLETERMINATORS := [ ENDSYM,
                                UNTILSYM,
                                ELSESYM,
                                SEMICOLON ];
      END;
   WITH PPOPTION [ BECOMES ] DO
      BEGIN
         OPTIONSSELECTED   := [ SPACEBEFORE,
                                SPACEAFTER,
                                GOBBLESYMBOLS ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := [ ENDSYM,
                                UNTILSYM,
                                ELSESYM,
                                SEMICOLON ]
      END;
   WITH PPOPTION [ OPENCOMMENT ] DO
      BEGIN
         OPTIONSSELECTED   := [ CRSUPPRESS ];
         DINDENTSYMBOLS    := [];
          GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ CLOSECOMMENT ] DO
      BEGIN
         OPTIONSSELECTED   := [ CRSUPPRESS ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ SEMICOLON ] DO
      BEGIN
         OPTIONSSELECTED   := [ CRSUPPRESS,
                                DINDENTONKEYS,
                                CRAFTER ];
         DINDENTSYMBOLS    := [ IFSYM,
                                THENSYM,
                                ELSESYM,
                                FORSYM,
                                WHILESYM,
                                WITHSYM,
                                COLON,
                                EQUALS ];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ COLON ] DO
      BEGIN
         OPTIONSSELECTED   := [ SPACEAFTER, 
				INDENTTOCLP ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ EQUALS ] DO
      BEGIN
         OPTIONSSELECTED   := [ SPACEBEFORE,
                                SPACEAFTER,
				INDENTTOCLP ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ OPENPAREN ] DO
      BEGIN
         OPTIONSSELECTED   := [ GOBBLESYMBOLS ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := [ CLOSEPAREN ]
      END;
   WITH PPOPTION [ CLOSEPAREN ] DO
      BEGIN
         OPTIONSSELECTED   := [];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ PERIOD ] DO
      BEGIN
         OPTIONSSELECTED   := [ CRSUPPRESS ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ ENDOFFILE ] DO
      BEGIN
         OPTIONSSELECTED   := [];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ OTHERSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END
END; (* INITIALIZE2 *)



PROCEDURE INITIALIZE( (* RETURNING *)
                          VAR TOPOFSTACK  : INTEGER;
                          VAR CURRLINEPOS,
                              CURRMARGIN  : INTEGER;
                          VAR KEYWORD     : KEYWORDTABLE;
                          VAR DBLCHARS    : DBLCHRSET;
                          VAR DBLCHAR     : DBLCHARTABLE;
                          VAR SGLCHAR     : SGLCHARTABLE;
                          VAR RECORDSEEN  : BOOLEAN;
                          VAR CURRCHAR,
                              NEXTCHAR    : CHARINFO;
                          VAR CURRSYM,
                              NEXTSYM     : SYMBOLINFO;
                          VAR PPOPTION    : OPTIONTABLE   );
BEGIN (* INITIALIZE *)
   TOPOFSTACK  := 0;
   CURRLINEPOS := 0;
   CURRMARGIN  := 0;
   KEYWORD [ PROGSYM    ] := 'PROGRAM   ' ;
   KEYWORD [ FUNCSYM    ] := 'FUNCTION  ' ;
   KEYWORD [ PROCSYM    ] := 'PROCEDURE ' ;
   KEYWORD [ LABELSYM   ] := 'LABEL     ' ;
   KEYWORD [ CONSTSYM   ] := 'CONST     ' ;
   KEYWORD [ TYPESYM    ] := 'TYPE      ' ;
   KEYWORD [ VARSYM     ] := 'VAR       ' ;
   KEYWORD [ BEGINSYM   ] := 'BEGIN     ' ;
   KEYWORD [ REPEATSYM  ] := 'REPEAT    ' ;
   KEYWORD [ RECORDSYM  ] := 'RECORD    ' ;
   KEYWORD [ CASESYM    ] := 'CASE      ' ;
   KEYWORD [ CASEVARSYM ] := 'CASE      ' ;
   KEYWORD [ OFSYM      ] := 'OF        ' ;
   KEYWORD [ FORSYM     ] := 'FOR       ' ;
   KEYWORD [ WHILESYM   ] := 'WHILE     ' ;
   KEYWORD [ WITHSYM    ] := 'WITH      ' ;
   KEYWORD [ DOSYM      ] := 'DO        ' ;
   KEYWORD [ IFSYM      ] := 'IF        ' ;
   KEYWORD [ THENSYM    ] := 'THEN      ' ;
   KEYWORD [ ELSESYM    ] := 'ELSE      ' ;
   KEYWORD [ ENDSYM     ] := 'END       ' ;
   KEYWORD [ UNTILSYM   ] := 'UNTIL     ' ;
   DBLCHARS := [ BECOMES, OPENCOMMENT ];
   DBLCHAR [ BECOMES     ]  := ':=' ;
   DBLCHAR [ OPENCOMMENT ]  := '(*' ;
   SGLCHAR [ SEMICOLON  ]   := ';' ;
   SGLCHAR [ COLON      ]   := ':' ;
   SGLCHAR [ EQUALS     ]   := '=' ;
   SGLCHAR [ OPENPAREN  ]   := '(' ;
   SGLCHAR [ CLOSEPAREN ]   := ')' ;
   SGLCHAR [ PERIOD     ]   := '.' ;
   RECORDSEEN := FALSE;
 SAWCOMOPEN := FALSE;
 SAWCOMCLOSE := FALSE;
 INACOMMENT := FALSE;
 SAWQUOTEDSTRING := FALSE;
   GETCHAR(
            (* UPDATING *)  NEXTCHAR,
            (* RETURNING *) CURRCHAR  );
   NEW(CURRSYM);
   NEW(NEXTSYM);
   GETSYMBOL(
              (* UPDATING *)  NEXTSYM,
              (* RETURNING *) CURRSYM  );
   WITH PPOPTION [ PROGSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ BLANKLINEBEFORE,
                                SPACEAFTER ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ FUNCSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ BLANKLINEBEFORE,
                                DINDENTONKEYS,
                                SPACEAFTER ];
         DINDENTSYMBOLS    := [ LABELSYM,
                                CONSTSYM,
                                TYPESYM,
                                VARSYM ];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ PROCSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ BLANKLINEBEFORE,
                                DINDENTONKEYS,
                                SPACEAFTER ];
         DINDENTSYMBOLS    := [ LABELSYM,
                                CONSTSYM,
                                TYPESYM,
                                VARSYM ];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ LABELSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ BLANKLINEBEFORE,
                                SPACEAFTER,
				INDENTTOCLP,
				CRAFTER ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ CONSTSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ BLANKLINEBEFORE,
                                DINDENTONKEYS,
				SPACEAFTER,
				INDENTTOCLP,
				CRAFTER ];
         DINDENTSYMBOLS    := [ LABELSYM ];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ TYPESYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ BLANKLINEBEFORE,
                                DINDENTONKEYS,
				SPACEAFTER,
				INDENTTOCLP,
				CRAFTER ];
         DINDENTSYMBOLS    := [ LABELSYM,
                                CONSTSYM ];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ VARSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ BLANKLINEBEFORE,
                                DINDENTONKEYS,
				SPACEAFTER,
				INDENTTOCLP,
				CRAFTER  ];
         DINDENTSYMBOLS    := [ LABELSYM,
                                CONSTSYM,
                                TYPESYM ];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ BEGINSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ DINDENTONKEYS,
                                INDENTBYTAB,
                                CRAFTER ];
         DINDENTSYMBOLS    := [ LABELSYM,
                                CONSTSYM,
                                TYPESYM,
                                VARSYM ];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ REPEATSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ INDENTBYTAB,
                                CRAFTER ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ RECORDSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ INDENTBYTAB,
                                CRAFTER ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := []
      END;
   WITH PPOPTION [ CASESYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ SPACEAFTER,
                                INDENTBYTAB,
                                GOBBLESYMBOLS,
                                CRAFTER ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := [ OFSYM ]
      END;
   WITH PPOPTION [ CASEVARSYM ] DO
      BEGIN
         OPTIONSSELECTED   := [ SPACEAFTER,
                                INDENTBYTAB,
                                GOBBLESYMBOLS,
                                CRAFTER ];
         DINDENTSYMBOLS    := [];
         GOBBLETERMINATORS := [ OFSYM ]
      END;
 INT2 ( TOPOFSTACK, CURRLINEPOS, CURRMARGIN, KEYWORD, DBLCHARS, DBLCHAR,
 SGLCHAR, RECORDSEEN, CURRCHAR, NEXTCHAR, CURRSYM, NEXTSYM, PPOPTION );
 END;
 
      BLCHAR,
      SGLCHAR,
      RECORDSEEN,
      CURRCHAR,
      NEXTCHAR, CURRSYM, NEXTSYM, PPOPTION );
 END;

