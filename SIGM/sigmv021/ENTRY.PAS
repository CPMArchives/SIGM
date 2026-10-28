PROGRAM CREATE_ENTRY_FOR_EXTERNALDECLARATIONS;
{                            by
                      Robert H. Harsch
                     ph: (916) 487-2216
             2362 American River Dr, Suite 311
                   Sacramento, Ca. 95825.
                    All rights reserved.		}

{ only the first 6 characters are significant }

CONST	$ENTRY_KEY='{@';  { string we look for to pick up entry
			name and insert into file name.ZZZ }

	$MAIN_PROGRAM_BEGIN='L99'; { string to look for to stop
			program.  Nothing is copied beyond
			this point to file name.ZZZ }

TYPE
	$STRING0= STRING 0;
	$STRING32= STRING 80;
	$STRING255= STRING 255;
	BYTE= 0..255;

	SYM_LINK= ^SYM_TYPE; { symbol (entry points) linked }
	SYM_TYPE= RECORD
			$SYM: $STRING32;
			PTR: SYM_LINK
		END;

VAR
	INFILE,OUTFILE: TEXT;
	$SYMBOL, $LINE: $STRING255;
	$CH, $TAB: CHAR;
	K,I: INTEGER;
	LOWERCASE, IDSTART, IDENTIFIER: SET OF CHAR;
	PROGRAM_DONE, BADCHAR, PREV_DEFN, FOUND_ENTRY: BOOLEAN;
	SYM_DEFN_ROOT: SYM_LINK;
	UPPERCASE: ARRAY['a'..'z'] OF 'A'..'Z';


FUNCTION LENGTH(X: $STRING255): INTEGER; EXTERNAL;
FUNCTION INDEX(X,Y: $STRING255): INTEGER; EXTERNAL;
PROCEDURE SETLENGTH(VAR X: $STRING0; Y: INTEGER); EXTERNAL;



PROCEDURE GET_FILE_NAME_FROM_COMMAND_LINE(VAR $INF: $STRING32);
VAR	I: INTEGER;

FUNCTION PEEK(ADDR: INTEGER): BYTE;
	TYPE	CONTENTS= PACKED RECORD
				BYT: BYTE { byte in memory }
			END; { of record }
		FORM=(INTEGR,ADDRESS);
		REFERENCE= RECORD
			CASE FORM OF
				INTEGR:  (I: INTEGER);
				ADDRESS: (P: ^CONTENTS)
			END;

	VAR	TEMP: REFERENCE;

	BEGIN { of function peek }
		TEMP.I:= ADDR;
		PEEK:= TEMP.P^.BYT
	END; { of function peek }

	BEGIN { of procedure GET_FILE_NAME_FROM_COMMAND_LINE }
	SETLENGTH($INF,0);
	FOR I:= 129 TO 128 + PEEK(128) DO
			APPEND( $INF, CHR(PEEK(I)) )
	END; { of procedure GET_FILE_NAME_FROM_COMMAND_LINE }



PROCEDURE OPENFILES;
CONST	$M1= 'Input file (without entry points): ';
	$M2= 'Output file (with entry points): ';
VAR	$FILENAME, $NAME_EXT: $STRING32;
	$CR : CHAR; { carriage return }
	BEGIN
		$CR:= CHR(13); { carriage return }
		GET_FILE_NAME_FROM_COMMAND_LINE($FILENAME);
		$NAME_EXT:= $FILENAME;
		APPEND($NAME_EXT, '.SRC');
		APPEND($NAME_EXT,$CR);	{ see note #3 of
				hot news, filenames passed to
				rewrite or reset must be
				deleted with a carriage return}
		RESET($NAME_EXT, INFILE);
		WRITELN($M1, $NAME_EXT);
		$NAME_EXT:= $FILENAME;
		APPEND($NAME_EXT, '.ZZZ');
		APPEND($NAME_EXT,$CR);	{ see note #3 of
				hot news, filenames passed to
				rewrite or reset must be
				deleted with a carriage return}
		REWRITE($NAME_EXT, OUTFILE);
		WRITELN($M2, $NAME_EXT);
	END; { of procedure openfiles }



PROCEDURE WRITEOUT(VAR $SYMBOL: $STRING32;
			PREV_DEFN, BADCHAR: BOOLEAN);
CONST	$MSG1= 'Error, symbol previously defined';
	$MSG2= 'Error, "#" or "_" character in symbol defined';
VAR	$TAB: CHAR;
	SYM_NODE: SYM_LINK;
	BEGIN
		$TAB:= CHR(9);
		WRITELN(OUTFILE,$TAB,'ENTRY',$TAB, $SYMBOL);
		WRITELN(OUTFILE,$SYMBOL,':');

		{ write info to screen }
		WRITELN;
		WRITELN('Entry symbol found:');
		WRITELN($TAB,'ENTRY',$TAB, $SYMBOL);
		WRITELN($SYMBOL,':');
		IF PREV_DEFN THEN
			WRITELN($MSG1);
		IF BADCHAR THEN
			WRITELN($MSG2);

		{ insert new symbol into link list }
		NEW(SYM_NODE);
		SYM_NODE^.$SYM:= $SYMBOL;
		SYM_NODE^.PTR:= SYM_DEFN_ROOT;
		SYM_DEFN_ROOT:= SYM_NODE;
	END; { of procedure writeout }



PROCEDURE WAS_$SYMBOL_PREVIOUSLY_DEFN(
		VAR $SYMBOL: $STRING32;
		VAR PREV_DEFN: BOOLEAN);
VAR	SYM_NODE: SYM_LINK;
	BEGIN
		SYM_NODE:= SYM_DEFN_ROOT;
		PREV_DEFN:= FALSE;
		WHILE (SYM_NODE <> NIL) AND NOT PREV_DEFN DO
			WITH SYM_NODE^ DO
				IF $SYM = $SYMBOL
					THEN PREV_DEFN:= TRUE
					ELSE SYM_NODE:= PTR;
	END; { of procedure WAS_$SYMBOL_PREVIOUSLY_DEFN }


BEGIN { of main program }
WRITELN;
WRITELN('Program for automatic insertion of entry points.');
WRITELN('By Robert Harsch.');
WRITELN;
WRITELN('WORKING.');

{ initialize global variables }
SYM_DEFN_ROOT:= NIL;
FOR $CH:='a' TO 'z' DO
	UPPERCASE[$CH]:= CHR(ORD('A') + (ORD($CH) - ORD('a')));
LOWERCASE:= ['a'..'z'];  { We will convert lower case
		characters to upper case like the assembler. }
{ set of "IDentifier START" and "IDentifier" characters }
IDSTART:= ['A'..'Z'] + LOWERCASE + ['$', '%', '.'] + ['#','_'];
IDENTIFIER:= IDSTART + ['0'..'9'];

OPENFILES;
REPEAT
	SETLENGTH($LINE,0);
	READLN(INFILE,$LINE);
	WRITELN(OUTFILE,$LINE);
	APPEND($LINE, ' '); 	{ sentinel }
	I:= INDEX ($LINE, $ENTRY_KEY);
	K:= I + LENGTH ( $ENTRY_KEY );
	FOUND_ENTRY:= (I > 0) AND ( $LINE[K] IN IDSTART );
	IF FOUND_ENTRY THEN
		BEGIN
		SETLENGTH($SYMBOL,0);

		{ pick up first 6 significant chars, and
		convert lower to upper case, store in $SYMBOL }
		I:= K; BADCHAR:= FALSE;
		REPEAT
			IF $LINE[I] IN LOWERCASE THEN
				$LINE[I]:= UPPERCASE[$LINE[I]];
			IF $LINE[I] IN ['#','_'] THEN
				BADCHAR:= TRUE;
			APPEND($SYMBOL,$LINE[I]);
			I:= I + 1
		UNTIL NOT ($LINE[I] IN IDENTIFIER) OR (I-K =6);

		WAS_$SYMBOL_PREVIOUSLY_DEFN($SYMBOL,PREV_DEFN);
		WRITEOUT($SYMBOL,PREV_DEFN,BADCHAR);
		END;
	PROGRAM_DONE:= (INDEX($LINE, $MAIN_PROGRAM_BEGIN) = 1)
				AND
		 	NOT ($LINE[4] IN IDENTIFIER);
UNTIL PROGRAM_DONE;
WRITELN('PROGRAM IS DONE.');

END.