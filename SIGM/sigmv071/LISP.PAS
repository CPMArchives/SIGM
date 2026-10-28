{++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{+		PASCAL/Z COMPILER OPTIONS		+}
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
{$C- <<< CONTROL-C KEYPRESS CHECKING OFF >>>		 }	
{$F- <<< FLOATING POINT ERROR CHECKING OFF >>>		 }
{$M- <<< INTEGER MULT & DIVD ERROR CHECKING OFF		 }
{++++++++++++++++++++++++++++++++++++++++++++++++++++++++}


(* LAST EDITED: 11/29/81 rep *)

PROGRAM LISP {INPUT,OUTPUT};
{
+  PROGRAM TITLE:	THE ESSENCE OF A LISP INTERPRETER.
+  WRITTEN BY:		W. TAYLOR AND L. COX
+
+  WRITTEN FOR:		US DEPT OF ENERGY
+			CONTRACT # W-7405-ENG-48
+
+	FIRST DATA STARTED : 10/29/76
+	LAST DATE MODIFIED : 12/10/76
+
+ ENTERED BY RAY PENLEY 8 DEC 80.
+ -SOME IDENTIFIERS HAVE BEEN SLIGHTLY MODIFIED BECAUSE OF THE
+  LIMITATION ON IDENTIFIER LENGTH OF 8 CHARACTERS.
}
	{++++++++++++++++++++++++++++++++++++++++++++++++}
	{+	RESERVED WORDS TABLE LISP		+}
	{++++++++++++++++++++++++++++++++++++++++++++++++}
{
	'APPEND    '	<
	'ATOM      '	<  A VARIABLE OR LITERAL USED IN A LIST.
	'REPLACEH  '	<
	'REPLACET  '	<
	'CAR       '	<  THE FIRST ELEMENT OF A LIST.
	'COND      '	<
	'COPY      '	<
	'CONC      '	<
	'CONS      '	<
	'EQ        '	<
	'QUOTE     '	<
	'LABEL     '	<
	'LAMBDA    '	<  FIRST ELEMENT OF A USER DEFINED FUNCTION.
	'CDR       '	<  ALL ELEMENTS OF A LIST EXCEPT THE FIRST ELEMENT.
	'FIN       '	<  FINISHED.

}

LABEL
  1,	{ USED TO RECOVER AFTER AN ERROR BY THE USER }
  2;	{ IN CASE THE END OF FILE IS REACHED BEFORE A FIN CARD }

CONST
  MAXNODE = 600;
{}INPUT = 0;	{ Pascal/Z = console as input }
{}IDLENGTH = 10;

TYPE
{}ALFA = ARRAY [1..10] OF CHAR;
  INPUTSYMBOL = (ATOM, PERIOD, LPAREN, RPAREN);
  RESERVEWORDS = (RELACEHSYM, RELACETSYM, HEADSYM, TAILSYM, EQSYM, QUOTESYM,
		  ATOMSYM, CONDSYM, LABELSYM, LAMBDASYM, COPYSYM, APPENDSYM,
		  CONCSYM, CONSSYM);
  STATUSTYPE = (UNMARKED, LEFT, RIGHT, MARKED);
  SYMBEXPPTR = ^SYMBOLICEXPRESSION;
  SYMBOLICEXPRESSION = RECORD
			 STATUS : STATUSTYPE;
			 NEXT   : SYMBEXPPTR;
			 CASE ANATOM: BOOLEAN OF
			   TRUE: (NAME: ALFA;
				  CASE ISARESERVEDWORD: BOOLEAN OF
				    TRUE: (RESSYM: RESERVEWORDS));
			   FALSE: (HEAD, TAIL: SYMBEXPPTR)
			END;

{
	Symbolicexpression is the record structure used	to implement
	a LISP list.  This record has a tag field 'ANATOM' which tells
	which kind of node a particular node represents (i.e. an atom
	or a pair of pointers 'HEAD' and 'TAIL'), 'ANATOM' is always
	checked before accessing either the name field or the head and
	tail fields of a node.  Two pages ahead there are three diagrams
	which should clarify the data structure.
}

{	THE GLOBAL VARIABLES	}

VAR
{}DUMMY		: CHAR;		{ required in the Pascal/Z version }

{ VARIABLES WHICH PASS INFORMATION FROM THE SCANNER TO THE READ ROUTINE }

  LOOKAHEADSYM,			{ USED TO SAVE A SYMBOL WHEN WE BACK UP }
  SYM		: INPUTSYMBOL;	{ THE SYMBOL THAT WAS LAST SCANNED }
  ID		: ALFA;		{ NAME OF THE ATOM THAT WAS LAST READ }
  ALREADYPEEKED	: BOOLEAN;	{ TELLS 'NEXTSYM' WHETHER WE HAVE PEEKED }
  CH		: CHAR;		{ THE LAST CHAR READ FROM INPUT }
  PTR		: SYMBEXPPTR;	{ POINTER TO THE EXPRESSION BEING EVALUATED }

	{ THE GLOBAL LISTS OF LISP NODES }

  FREELIST,	{ POINTER TO THE LINEAR LIST OF FREE NODES }
  NODELIST,	{ POINTER USED TO MAKE A LINEAS SCAN OF ALL}
		{ THE NODES DURING GARBAGE COLLECTION.	   }
  ALIST	: SYMBEXPPTR;{ POINTER TO THE ASSOCIATION LIST }

	{ TWO NODES WHICH HAVE CONSTANT VALUES }

  NILNODE,
  TNODE	: SYMBOLICEXPRESSION;

	{ VARIABLES USED TO IDENTIFY ATOMS WITH PRE-DEFINED MEANINGS }

  RESWORD	: RESERVEWORDS;
  RESERVED	: BOOLEAN;
  RESWORDS	: ARRAY [RESERVEWORDS] OF ALFA;
  FREENODES	: INTEGER; { NUMBER OF CURRENTLY FREE NODES KNOWN }
  NUMBEROFGCS	: INTEGER; { # OF GARBAGE COLLECTIONS MADE }
{

					 \
					  \
	THE ATOM 'A' IS			---\---
	REPRESENTED BY --->             I     I
					I  A  I
					I     I
					-------


				   \
				    \
				-----\-----
	THE DOTTED PAIR		I    I    I
	'(A.B)' IS		I  / I \  I
	REPESENTED BY --->	I /  I  \ I
				-/-------\-
				/         \
			   ----/----   ----\----
			   I       I   I       I
			   I   A   I   I   B   I
			   I       I   I       I
			   ---------   ---------


				   \
				    \
				-----\-----
	THE LIST '(AB)'		I    I    I
	IS REPRESENTED 		I  / I \  I
	BY --->			I /  I  \ I
				-/-------\-
				/         \
			   ----/----       \
			   I       I        \
			   I   A   I    -----\-----
			   I       I    I    I    I
			   ---------    I   /I\   I
					I  / I \  I
					--/-----\--
					 /       \
				    ----/---- ----\----
				    I       I I       I
				    I   B   I I  NIL  I
				    I       I I       I
				    --------- ---------
}
(*	*	THE GARBAGE COLLECTOR        *          *)
{
 In  general  there are two approaches to maintaining lists of available space
in list processing systems... The  reference counter technique and the garbage
collector technique.

 The reference counter technique requires that for  each  node  or  record  we
maintain  a  count  of  the number of nodes which reference or point to it and
update this count continuously. ie.  with  every  manipulation  In general, if
circular or ring structures are permitted to develope this technique will  not
be  able  to  reclaim  rings which are no longer in use and have been isolared
from the active structure.

 The alternative method, garbage  collection,  does not function continuously,
but is activated only when further storage is required and none is  available.
The complete process consists of two stages.  A marking stage which identifies
nodes  still  reachable (in use) and a collection stage where all nodes in the
system are examined and those not in  use  are merged into a list of available
space.  This is the technique we have chosen to implement here for reasons  of
simplicity and to enhance the interactive nature of out system.

 The  marking  stage  is  theoretically simple, especially in LISP programming
systems where all records are essentially the same size.  All that is required
is a traversal of the active  list  structure, each time marking nodes 1 level
deeper into the tree on each pass.  This is both crude and inefficient.

 Another alternative procedure which could be used would use a recursive  walk
of  the  tree  structure to mark the nodes in use.  This requires the use of a
stack to store  back  pointers  to  branches  not  taken.    This algorithm is
efficient, but tend to  be  self  defeating  in  the  folowing  manner.    The
requisite  stack  could  become  quite large (requiring significant amounts of
storage).  However, the  reason  we  are  performing garbage collection in the
first place is due to  an  insufficiency  of  storage  space.    Therefore  an
usdesirable  situation  is likely to arise where the garbage collector's stack
cannot expand to perform the marking  pass.  Even though there are significant
amounts of free space waiting to be reclaimed.

 A solution to this dilema came when it was realized that space in  the  nodes
themselves  (i.e.  the  left  and right pointers) could be used in lieu of the
explicit stack.  In this way  the  stack  information can be embedded into the
list itself as it is traversed.  This algorithm has been  discussed  in  Knuth
and  in  Berztiss:  Data  Structures,  Theory  and  Practice (2nd ed.), and is
implemented below.

 Since Pascal does not allow structures to be addressed both with pointers and
as indexed arrays, an additional field has been added to sequentially link the
nodes.  This pointer field is  set  on initial creation, and remains invarient
throughout the run.  Using this field, we can simulate a linear  pass  through
the  nodes  for  the  collection  stage.    Of  course, a marker field is also
required.
}
(*	*	*	*	*	*	*	*)

PROCEDURE GARBAGEMAN;

  PROCEDURE MARK(LIST: SYMBEXPPTR);
  VAR
    FATHER, SON, CURRENT: SYMBEXPPTR;
  BEGIN
    FATHER := NIL;
    CURRENT := LIST;
    SON := CURRENT;
    WHILE ( CURRENT<>NIL ) DO
      WITH CURRENT^ DO
	CASE STATUS OF
	  UNMARKED:
	    IF ( ANATOM ) THEN
	      STATUS := MARKED
	    ELSE
	      IF (HEAD^.STATUS <> UNMARKED) OR (HEAD = CURRENT) THEN
		IF (TAIL^.STATUS <> UNMARKED) OR (TAIL = CURRENT) THEN
		   STATUS := MARKED
		ELSE BEGIN
		  STATUS := RIGHT; SON := TAIL; TAIL := FATHER;
		  FATHER := CURRENT; CURRENT := SON
		END
	      ELSE BEGIN
		STATUS := LEFT; SON := HEAD; HEAD := FATHER;
		FATHER := CURRENT; CURRENT := SON
	      END;
	  LEFT:
	    IF ( TAIL^.STATUS <> UNMARKED ) THEN BEGIN
	      STATUS := MARKED; FATHER := HEAD; HEAD := SON;
	      SON := CURRENT
	    END
	    ELSE BEGIN
	      STATUS := RIGHT; CURRENT := TAIL; TAIL := HEAD;
	      HEAD := SON; SON := CURRENT
	    END;
	  RIGHT:
	    BEGIN
		STATUS := MARKED; FATHER := TAIL; TAIL := SON;
		SON := CURRENT
	    END;
	  MARKED: CURRENT := FATHER
	END { OF CASE }
  END { OF MARK };

  PROCEDURE COLLECTFREENODES;
  VAR
    TEMP: SYMBEXPPTR;
  BEGIN
    WRITELN(' NUMBER OF FREE NODES BEFORE COLLECTION = ', FREENODES:1, '.');
    FREELIST := NIL; FREENODES := 0; TEMP := NODELIST;
    WHILE ( TEMP <> NIL ) DO BEGIN
	IF ( TEMP^.STATUS <> UNMARKED ) THEN
	  TEMP^.STATUS := UNMARKED
	ELSE BEGIN
	  FREENODES := FREENODES + 1; TEMP^.HEAD := FREELIST;
	  FREELIST := TEMP
	END;
	TEMP := TEMP^.NEXT;
    END {WHILE};
    WRITELN(' NUMBER OF FREE NODES AFTER COLLECTION = ', FREENODES:1,'.');
  END { OF COLLECTFREENODES };

BEGIN{ GARBAGEMAN }
  NUMBEROFGCS := NUMBEROFGCS + 1; WRITELN;
  WRITELN(' GARBAGE COLLECTION. '); WRITELN; MARK(ALIST);
  IF ( PTR <> NIL ) THEN MARK(PTR);
  COLLECTFREENODES
END{ OF GARBAGEMAN };

PROCEDURE POP(VAR SPTR: SYMBEXPPTR);
BEGIN
  IF ( FREELIST = NIL ) THEN BEGIN
    WRITELN(' NOT ENOUGH SPACE TO EVALUATE THE EXPRESSION.');
{}  GOTO 2;
  END;
  FREENODES := FREENODES - 1;
  SPTR := FREELIST;
  FREELIST := FREELIST^.HEAD;
END{ OF POP };


{	INPUT / OUTPUT UTILITY ROUTINES		 }

PROCEDURE ERROR(NUMBER: INTEGER);
BEGIN
  WRITELN; WRITE('  ERROR   ', NUMBER:1, ', ');
  CASE NUMBER OF
    1: WRITELN('ATOM OR LPAREN EXPECTED IN THE S-EXPR.');
    2: WRITELN('ATOM, LPAREN, OR RPAREN EXPECTED IN THE S-EXPR.');
    3: WRITELN('LABEL AND LAMBDA ARE NOT NAMES OF FUNCTIONS.');
    4: WRITELN('RPAREN EXPECTED IN THE S-EXPR.');
    5: WRITELN('1ST ARGUMENT OF REPLACEH IS AN ATOM.');
    6: WRITELN('1ST ARGUMENT OF REPLACET IS AN ATOM.');
    7: WRITELN('ARGUMENT HEAD IS AN ATOM.');
    8: WRITELN('ARGUMENT TAIL IS AN ATOM.');
    9: WRITELN('1ST ARGUMENT OF APPEND IS NOT A LIST.');
   10: WRITELN('COMMA OR RPAREN EXPECTED IN CONCATENATE.');
   11: WRITELN('END OF FILE ENCOUNTERED BEFORE A "FIN" CARD.');
   12: WRITELN('LAMBDA OR LABEL EXPECTED.');
  END{CASE};
{}IF NUMBER IN [11] THEN
    GOTO 2
  ELSE
    GOTO 1
END { OF ERROR };

PROCEDURE BACKUPINPUT;
{	PUTS A LEFT PARENTHESIS INTO THE STREAM OF INPUT
	SYMBOLS.  THIS MAKES PROCEDURE READEXPR EASIER
	THAN IT OTHERWISE WOULD BE.
}
BEGIN
  ALREADYPEEKED := TRUE; LOOKAHEADSYM := SYM; SYM := LPAREN
END{ OF BACKUPINPUT };

PROCEDURE NEXTSYM;
{	READS THE NEXT SYMBOL FROM THE INPUT FILE.  A SYMBOL IS	DEFINED
	BY THE GOLBAL TYPE "INPUTSYMBOL".  THE GLOBAL VARIABLE 'SYM'
	RETURNS THE TYPE OF THE NEXT SYMBOL READ.  THE GLOBAL VARIABLE
	'ID' RETURNS THE NAME OF AN ATOM IF THE SYMBOL IS AN ATOM.  IF
	THE SYMBOL IS A RESERVED WORD THE GLOBAL VARIABLE 'RESERVED' IS
	SET TO TRUE AND THE GLOBAL VARIABLE 'RESWORD' TELLS WHICH RESERVED
	WORD WAS READ.
}
VAR	I: INTEGER;
BEGIN
  IF ( ALREADYPEEKED ) THEN BEGIN
      SYM := LOOKAHEADSYM; ALREADYPEEKED := FALSE
  END
  ELSE
    BEGIN
      WHILE ( CH=' ' ) DO BEGIN
	IF ( EOLN(INPUT) ) THEN WRITELN;
	READ(CH);
      END{WHILE};
      IF ( CH IN ['(','.',')'] ) THEN BEGIN
	CASE CH OF
	  '(': SYM := LPAREN;
	  '.': SYM := PERIOD;
	  ')': SYM := RPAREN
	END{CASE};
	IF ( EOLN(INPUT) ) THEN WRITELN;
	READ(CH);
      END
      ELSE BEGIN
	SYM := ATOM; ID := '          ';
	I := 0;
	REPEAT
	  I := I + 1;
	  IF ( I < (IDLENGTH+1) ) THEN ID[I] := CH;
	  IF ( EOLN(INPUT) ) THEN WRITELN;
	  READ(CH);
	UNTIL ( CH IN [' ','(','.',')'] );
	RESWORD := RELACEHSYM;
	WHILE (ID <> RESWORDS[RESWORD]) AND (RESWORD <> CONSSYM) DO
	  RESWORD := SUCC(RESWORD);
	RESERVED := ( ID=RESWORDS[RESWORD] )
      END
    END  
END{ OF NEXTSYM };

PROCEDURE READEXPR(VAR SPTR: SYMBEXPPTR);
{
	THIS PROCEDURE RECURSIVELY READS IN THE NEXT SYMBOLIC EXPRESSION
	FROM THE INPUT FILE.  WHEN CALLED THE GLOBAL VARIABLE 'SYM' MUST
	BE THE FIRST SYMBOL IN THE SYMBOLIC EXPRESSION TO BE READ.  A
	POINTER TO THE SYMBOLIC EXPRESSION READ IS RETURNED VIA THE
	VARIABLE PARAMETER SPTR.
	EXPRESSIONS ARE READ AND STORED IN THE APPROPRIATE STRUCTURE
	USING THE FOLLOWING GRAMMAR FOR SYMBOLIC EXPRESSIONS:

	<s-expr> ::= <atom>
		 or ( <s-expr> . <s-expr> )
		 or ( <s-expr> <s-expr> ... <s-expr> )

	WHERE ... MEANS AN ARBITRARY NUMBER OF. (I.E. ZERO OR MORE.)
	TO PARSE USING THE THIRD RULE, THE IDENTITY
		(ABC ... Z) = (A . (BC ... Z))
	IS UTILIZED.  AN EXTRA LEFT PARENTHESIS IS INSERTED INTO THE
	INPUT STREAM AS IF IT OCCURED AFTER THE IMAGINARY DOT.  WHEN
	IT COMES TIME TO READ THE IMAGINARY MATCHING RIGHT PARENTHESIS 
	IT IS JUST NOT READ (BECAUSE IT IS NOT THERE).
}
VAR	NXT: SYMBEXPPTR;
BEGIN
  POP(SPTR);
  NXT := SPTR^.NEXT;
  CASE SYM OF
    RPAREN, PERIOD: ERROR(1);
    ATOM:
	WITH SPTR^ DO BEGIN {  <ATOM>  }
	  ANATOM := TRUE; NAME := ID; ISARESERVEDWORD := RESERVED;
	  IF ( RESERVED ) THEN RESSYM := RESWORD
	END;
    LPAREN:
	WITH SPTR^ DO BEGIN
	  NEXTSYM;
	  IF ( SYM=PERIOD ) THEN ERROR(2)
	  ELSE
	    IF ( SYM=RPAREN ) THEN SPTR^ := NILNODE {   () = NIL   }
	    ELSE BEGIN
		ANATOM := FALSE; READEXPR(HEAD); NEXTSYM;
		IF ( SYM=PERIOD ) THEN BEGIN {   ( <S-EXPR> . <S-EXPR> )   }
		   NEXTSYM;  READEXPR(TAIL); NEXTSYM;
		   IF ( SYM<>RPAREN ) THEN ERROR(4)
		END
		ELSE BEGIN {   ( <S-EXPR> <S-EXPR> ... <S-EXPR> )   }
		  BACKUPINPUT; READEXPR(TAIL)
		END
	    END
	END{WITH}
  END{CASE};
  SPTR^.NEXT := NXT;
END{ OF READEXPR };

PROCEDURE PRINTNAME(NAME: ALFA);
{
	PRINTS THE NAME OF AN ATOM WITH ONE TRAILING BLANK.
}
VAR	I: INTEGER;
BEGIN
  I := 1;
  REPEAT
    WRITE(NAME[I]);
    I := I + 1
  UNTIL (NAME[I]=' ') OR ( I=11 );
  WRITE(' ');
END{ OF PRINTNAME };

PROCEDURE PRINTEXPR(SPTR: SYMBEXPPTR);
{
	THE ALGORITHM FOR THIS PROCEDURE WAS PROVIDED BY WEISSMAN'S LISP
	1.5 PRIMER, PG 125.  THIS PROCEDURE PRINTS THE SYMBOLIC
	EXPRESSION POINTED TO BY THE ARGUMENT 'SPTR' IN THE LIST LIST
	NOTATION. (THE SAME NOTATION IN WHICH EXPRESSIONS ARE READ.)
}
LABEL 1;
BEGIN
  IF ( SPTR^.ANATOM ) THEN
    PRINTNAME(SPTR^.NAME)
  ELSE BEGIN
    WRITE('(');
 1: WITH SPTR^ DO BEGIN
	PRINTEXPR(HEAD);
	IF ( TAIL^.ANATOM ) AND (TAIL^.NAME='NIL       ') THEN
	  WRITE(')')
	ELSE IF ( TAIL^.ANATOM ) THEN BEGIN
	  WRITE('.'); PRINTEXPR(TAIL); WRITE(')')
	END
	ELSE BEGIN
	  SPTR := TAIL;
	  GOTO 1
	END
    END{WITH}
  END
END{ OF PRINTEXPR };

{	END OF I/O UTILITY ROUTINES	}


{	THE EXPRESSION EVALUATOR EVAL	   }

FUNCTION EVAL( E, ALIST: SYMBEXPPTR ): SYMBEXPPTR;
{
 Function eval evaluates the LISP expression 'e' using the association
 list 'alist'. This function uses the following several local functions
 to do so. The algorithm is a Pascal version of the classical LISP
 problem of writing the LISP eval routine in pure LISP. The LISP version
 of the code is as follows:

 (lambda (e alist)
   cond
     ((atom a) (lookup e alist))
     ((atom (car e))
       (cond ((eq (car e) (quote quote))
           (cadr e))
         ((eq (car e) (quote atom))
           (atom (eval (card e) alist)
         ((eq (car e) (quote eq))
           (eq (eval (cadr e) alist)))
         ((eq (car e) (quote car))
           (car (eval (cadr e) alist)))
         ((eq (car e) (quote cdr))
           (cdr (eval (cadr e) alist)))
         ((eq (car e) (quote cons)
           (cons (eval (cadr e) alist)
             (eval (caddr e) alist)
         ((eq (car e) (quote cond)
           (evcon (cdr e))
         (t (eval (cons (lookup (car e) alist)
           (cdr e)) alist )))
     ((eq (caar e) (quote label))
       (eval (cons (caddr e)
         (cdr e)
       (cons (cons (cadar e) (car e))
         alist) ))
   ((eq (caar e) (quote lambda))
     (eval (caddar e)
       (bindargs (cadar e) (cdr e) )))))


	The resulting Pascal code follows:
}
VAR	TEMP, CAROFE, CAAROFE: SYMBEXPPTR;
{
	The first ten of the following local functions implement
	ten of the primitives which operate on the LISP data
	structure. The last three ; 'lookup', 'bindargs', and 'evcon'
	are used by 'eval' to interpret a LISP expresson.
}
  FUNCTION REPLACEH(SPTR1, SPTR2: SYMBEXPPTR): SYMBEXPPTR;
  BEGIN
    IF ( SPTR1^.ANATOM ) THEN ERROR(5)
    ELSE SPTR1^.HEAD := SPTR2;
    REPLACEH := SPTR1;
  END{ OF REPLACEH };

  FUNCTION REPLACET(SPTR1, SPTR2: SYMBEXPPTR): SYMBEXPPTR;
  BEGIN
    IF ( SPTR1^.ANATOM ) THEN ERROR(6)
    ELSE SPTR1^.TAIL := SPTR2;
    REPLACET := SPTR1;
  END{ OF REPLACET };

  FUNCTION HEAD(SPTR: SYMBEXPPTR): SYMBEXPPTR;
  BEGIN
    IF ( SPTR^.ANATOM ) THEN ERROR(7)
    ELSE HEAD := SPTR^.HEAD;
  END{ OF HEAD };

  FUNCTION TAIL(SPTR: SYMBEXPPTR): SYMBEXPPTR;
  BEGIN
    IF ( SPTR^.ANATOM ) THEN ERROR(8)
    ELSE TAIL := SPTR^.TAIL;
  END{ OF TAIL };

  FUNCTION CONS(SPTR1, SPTR2: SYMBEXPPTR): SYMBEXPPTR;
  VAR	TEMP: SYMBEXPPTR;
  BEGIN
    POP(TEMP);
    TEMP^.ANATOM := FALSE; TEMP^.HEAD := SPTR1;
    TEMP^.TAIL := SPTR2; CONS := TEMP;
  END{ OF CONS };

  FUNCTION COPY(SPTR: SYMBEXPPTR): SYMBEXPPTR;
  {
	THIS FUNCTION CREATES A COPY OF THE STRUCTURE
	POINTED TO BY THE PARAMETER 'SPTR'
  }
  VAR	TEMP, NXT: SYMBEXPPTR;
  BEGIN
    IF ( SPTR^.ANATOM ) THEN BEGIN
	POP(TEMP);
	NXT := TEMP^.NEXT; TEMP^ := SPTR^;
 	TEMP^.NEXT := NXT; COPY := TEMP
    END
    ELSE
	COPY := CONS(COPY(SPTR^.HEAD), COPY(SPTR^.TAIL));
  END{ OF COPY };

  FUNCTION APPEND(SPTR1, SPTR2: SYMBEXPPTR): SYMBEXPPTR;
  {
	THE RECURSIVE ALGORITHM IS FROM WEISSMAN, PG 97.
  }
  BEGIN
    IF ( SPTR1^.ANATOM ) THEN
      IF ( SPTR1^.NAME<>'NIL       ' ) THEN ERROR(9)
      ELSE APPEND := SPTR2
    ELSE
      APPEND := CONS(COPY(SPTR1^.HEAD), APPEND(SPTR1^.TAIL,SPTR2));
  END{ OF APPEND };

  FUNCTION CONC(SPTR1: SYMBEXPPTR): SYMBEXPPTR;
  {
	This function serves as the basic concatenation mechanism
	for variable numbers of list expressions in the input stream.
	The concatenation is handled recursively, using the identity:
	   conc(a,b,c,d) = conc(a,cons(b,cons(c,(cons(d,nil))))

	The routine is called when a conc(..... command has been
	recognized on input, and its single argument is the first
	expression in the chain.  It has the side effect of reading
	all following input up to the parenthesis closing the
	conc command.

	The procedure consists of the following steps-
	  1. call with 1st expression as argument.
	  2. read the next expression.
	  3. if the expression just read was not the last, recurse.
	  4. otherwise... unwind.
}
  VAR
    SPTR2, NILPTR: SYMBEXPPTR;
  BEGIN
    IF ( SYM<>RPAREN ) THEN BEGIN
	NEXTSYM; READEXPR(SPTR2); NEXTSYM;
	CONC := CONS(SPTR1, CONC(SPTR2));
    END
    ELSE
      IF ( SYM=RPAREN ) THEN BEGIN
	NEW(NILPTR);
	WITH NILPTR^ DO BEGIN
	  ANATOM := TRUE; NAME := 'NIL       ';
	END{WITH};
	CONC := CONS(SPTR1, NILPTR);
      END
      ELSE
	ERROR(10);
  END{ OF CONC };

  FUNCTION EQQ(SPTR1, SPTR2: SYMBEXPPTR): SYMBEXPPTR;
  VAR	TEMP, NXT: SYMBEXPPTR;
  BEGIN
    POP(TEMP);
    NXT := TEMP^.NEXT;
    IF ( SPTR1^.ANATOM ) AND ( SPTR2^.ANATOM ) THEN
      IF ( SPTR1^.NAME=SPTR2^.NAME ) THEN
	TEMP^ := TNODE
      ELSE if ( sptr1=sptr2 ) then
	temp^ := tnode
      else
	temp^ := nilnode;
    TEMP^.NEXT := NXT; EQQ := TEMP;
  END{ OF EQQ };

  FUNCTION ATOM(SPTR: SYMBEXPPTR): SYMBEXPPTR;
  VAR	TEMP, NXT: SYMBEXPPTR;
  BEGIN
    POP(TEMP);
    NXT := TEMP^.NEXT;
    IF ( SPTR^.ANATOM ) THEN
      TEMP^ := TNODE
    ELSE
      TEMP^ := NILNODE;
    TEMP^.NEXT := NXT; ATOM := TEMP;
  END{ OF ATOM };

  FUNCTION LOOKUP(KEY, ALIST: SYMBEXPPTR): SYMBEXPPTR;
  VAR
    TEMP: SYMBEXPPTR;
  BEGIN
    TEMP := EQQ( HEAD( HEAD(ALIST)), KEY);
    IF ( TEMP^.NAME='T         ' ) THEN
      LOOKUP := TAIL(HEAD(ALIST))
    ELSE
      LOOKUP := LOOKUP(KEY, TAIL(ALIST))
  END{ OF LOOKUP };

  FUNCTION BINDARGS(NAMES, VALUES: SYMBEXPPTR): SYMBEXPPTR;
  VAR
    TEMP, TEMP2: SYMBEXPPTR;
  BEGIN
    IF ( NAMES^.ANATOM ) AND (NAMES^.NAME='NIL       ') THEN
      BINDARGS := ALIST
    ELSE BEGIN
	TEMP := CONS( HEAD(NAMES), EVAL(HEAD(VALUES), ALIST) );
	TEMP2 := BINDARGS(TAIL(NAMES), TAIL(VALUES));
	BINDARGS := CONS(TEMP, TEMP2)
    END
  END{ OF BINDARGS };

  FUNCTION EVCON(CONDPAIRS: SYMBEXPPTR): SYMBEXPPTR;
  VAR
    TEMP: SYMBEXPPTR;
  BEGIN
    TEMP := EVAL( HEAD(HEAD(CONDPAIRS)),ALIST );
    IF ( TEMP^.ANATOM ) AND (TEMP^.NAME='NIL       ') THEN
      EVCON := EVCON( TAIL(CONDPAIRS) )
    ELSE
      EVCON := EVAL( HEAD(TAIL(HEAD(CONDPAIRS))),ALIST )
  END{ OF EVCON };


  BEGIN	{   * E V A L *   }
    IF ( E^.ANATOM ) THEN EVAL := LOOKUP(E, ALIST)
    ELSE
      BEGIN
	CAROFE := HEAD(E);
	IF ( CAROFE^.ANATOM ) THEN
	   IF NOT ( CAROFE^.ISARESERVEDWORD ) THEN
	     EVAL := EVAL( CONS(LOOKUP(CAROFE,ALIST),TAIL(E)), ALIST )
	   ELSE
	     CASE CAROFE^.RESSYM OF

	       LABELSYM, LAMBDASYM: ERROR(3);

	       QUOTESYM	: EVAL := HEAD(TAIL(E));

	       ATOMSYM	: EVAL := ATOM(EVAL(HEAD(TAIL(E)),ALIST));

	       EQSYM	: EVAL := EQQ(EVAL(HEAD(TAIL(E)),ALIST),
				      EVAL(HEAD(TAIL(TAIL(E))), ALIST));

	       HEADSYM	: EVAL := HEAD(EVAL(HEAD(TAIL(E)),ALIST));

	       TAILSYM	: EVAL := TAIL(EVAL(HEAD(TAIL(E)),ALIST));

	       CONSSYM	: EVAL := CONS(EVAL(HEAD(TAIL(E)),ALIST),
				       EVAL(HEAD(TAIL(TAIL(E))), ALIST));

	       CONDSYM	: EVAL := EVCON(TAIL(E));

	       CONCSYM	: {};

	       APPENDSYM : EVAL := APPEND(EVAL(HEAD(TAIL(E)),ALIST),
					  EVAL(HEAD(TAIL(TAIL(E))), ALIST));

	       RELACEHSYM : EVAL := REPLACEH(EVAL(HEAD(TAIL(E)),ALIST),
					   EVAL(HEAD(TAIL(TAIL(E))), ALIST));

	       RELACETSYM : EVAL := REPLACET(EVAL(HEAD(TAIL(E)),ALIST),
					   EVAL(HEAD(TAIL(TAIL(E))), ALIST));
	     END{CASE}
         ELSE
	   BEGIN
	     CAAROFE := HEAD(CAROFE);
	     IF ( CAAROFE^.ANATOM ) AND ( CAAROFE^.ISARESERVEDWORD ) THEN
	       IF NOT ( CAAROFE^.RESSYM IN [LABELSYM, LAMBDASYM] ) THEN
		 ERROR(12)
	       ELSE
		 CASE CAAROFE^.RESSYM OF
		   LABELSYM:
		      BEGIN
			TEMP := CONS( CONS(HEAD(TAIL(CAROFE)),
			   	      HEAD(TAIL(TAIL(CAROFE)))), ALIST);
			EVAL := EVAL(CONS(HEAD(TAIL(TAIL(CAROFE))),
			   		TAIL(E)),TEMP)
		      END;
		   LAMBDASYM:
		      BEGIN
			TEMP := BINDARGS(HEAD(TAIL(CAROFE)), TAIL(E));
			EVAL := EVAL( HEAD( TAIL( TAIL(CAROFE))), TEMP)
		      END
		 END{ CASE }
	     ELSE
	       EVAL := EVAL(CONS(EVAL(CAROFE, ALIST), TAIL(E)), ALIST)
          END   
      END
END{ OF EVAL };

PROCEDURE INITIALIZE;
VAR	I: INTEGER;
	TEMP, NXT: SYMBEXPPTR;
BEGIN
  ALREADYPEEKED := FALSE;
  READ(CH);
  NUMBEROFGCS := 0;
  FREENODES := MAXNODE;
  WITH NILNODE DO BEGIN
    ANATOM := TRUE; NEXT := NIL; NAME := 'NIL       ';
    STATUS := UNMARKED; ISARESERVEDWORD := FALSE
  END;

  WITH TNODE DO BEGIN
    ANATOM := TRUE; NEXT := NIL; NAME := 'T         ';
    STATUS := UNMARKED; ISARESERVEDWORD := FALSE
  END;
{
	ALLOCATE STORAGE AND MARK IT FREE
}
  FREELIST := NIL;
  FOR I:=1 TO MAXNODE DO BEGIN
    NEW(NODELIST); NODELIST^.NEXT := FREELIST;
    NODELIST^.HEAD := FREELIST; NODELIST^.STATUS := UNMARKED;
    FREELIST := NODELIST
  END;
{
	INITIALIZE RESERVED WORD TABLE
}
  RESWORDS[ APPENDSYM   ] := 'APPEND    ';
  RESWORDS[ ATOMSYM     ] := 'ATOM      ';
  RESWORDS[ HEADSYM     ] := 'CAR       ';
  RESWORDS[ TAILSYM     ] := 'CDR       ';
  RESWORDS[ CONDSYM     ] := 'COND      ';
  RESWORDS[ COPYSYM     ] := 'COPY      ';
  RESWORDS[ CONCSYM     ] := 'CONC      ';
  RESWORDS[ CONSSYM     ] := 'CONS      ';
  RESWORDS[ EQSYM       ] := 'EQ        ';
  RESWORDS[ LABELSYM    ] := 'LABEL     ';
  RESWORDS[ LAMBDASYM   ] := 'LAMBDA    ';
  RESWORDS[ QUOTESYM    ] := 'QUOTE     ';
  RESWORDS[ RELACEHSYM  ] := 'REPLACEH  ';
  RESWORDS[ RELACETSYM  ] := 'REPLACET  ';
{
	INITIALIZE THE A-LIST WITH  T  AND  NIL
}
  POP(ALIST);
  ALIST^.ANATOM := FALSE;
  ALIST^.STATUS := UNMARKED;
  POP(ALIST^.TAIL);
  NXT := ALIST^.TAIL^.NEXT;
  ALIST^.TAIL^ := NILNODE;
  ALIST^.TAIL^.NEXT := NXT;
  POP(ALIST^.HEAD);
{
	BIND NIL TO THE ATOM NIL
}
  WITH ALIST^.HEAD^ DO BEGIN
    ANATOM := FALSE; STATUS := UNMARKED; POP(HEAD);
    NXT := HEAD^.NEXT; HEAD^ := NILNODE; HEAD^.NEXT := NXT;
    POP(TAIL); NXT := TAIL^.NEXT; TAIL^ := NILNODE;
    TAIL^.NEXT := NXT
  END;
  POP(TEMP);
  TEMP^.ANATOM := FALSE;
  TEMP^.STATUS := UNMARKED;
  TEMP^.TAIL := ALIST;
  ALIST := TEMP;
  POP(ALIST^.HEAD);
{
	BIND  T  TO THE ATOM  T
}
  WITH ALIST^.HEAD^ DO BEGIN
    ANATOM := FALSE;  STATUS := UNMARKED; POP(HEAD);
    NXT := HEAD^.NEXT; HEAD^ := TNODE; HEAD^.NEXT := NXT;
    POP(TAIL); NXT := TAIL^.NEXT; TAIL^ := TNODE;
    TAIL^.NEXT := NXT
  END
END{ OF INITIALIZE };



BEGIN{+		LISP MAIN PROGRAM		+}
  WRITELN(' * EVAL *');
  INITIALIZE;
  NEXTSYM;
  READEXPR(PTR);
{}READLN(DUMMY);
  WRITELN;
  WHILE NOT ( PTR^.ANATOM ) OR ( PTR^.NAME<>'FIN       ' ) DO BEGIN
    WRITELN;
    WRITELN(' * VALUE *');
    PRINTEXPR( EVAL(PTR, ALIST) );
1:  WRITELN;
    WRITELN;
    IF ( EOF(INPUT) ) THEN ERROR(11);
    PTR := NIL;
    { CALL THE } GARBAGEMAN;
    WRITELN; WRITELN;
    WRITELN(' * EVAL *');
    NEXTSYM;
    READEXPR(PTR);
{}  READLN(DUMMY);
    WRITELN;
  END;
2:WRITELN; WRITELN;
  WRITELN(' TOTAL NUMBER OF GARBAGE COLLECTIONS = ', NUMBEROFGCS:1,'.');
  WRITELN;
  WRITELN(' FREE NODES LEFT UPON EXIT = ', FREENODES:1, '.');
  WRITELN
END { OF LISP }.
