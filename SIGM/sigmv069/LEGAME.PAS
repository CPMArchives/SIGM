PROGRAM LeGame;
{+
++ PROGRAM TITLE:	THE GAME
++ WRITTEN BY:		RAYMOND E. PENLEY
++
++ DATE WRITTEN:	AUGUST 7, 1981
++
++  COPYRIGHT (c) AUGUST 1981 by Raymond E. Penley
++  Permission to copy, modify and distribute, except for profit,
++  is hereby granted.
++
++ SUMMARY:
++	LeGame is a real time simulation game with a very simple
++   objective: to move into the other player thus giving the
++   mover an increased score.
++	LeGame is a simple game that moves two players around on a
++   game board.  The game is enhanced by the presence of a third
++   player, the Ghost, on the board.	The ghost player always moves
++   into a player and thereby causes that player to lose all his score.
++	The game is over in 1000 rounds or may be terminated by a
++   control-a key press.
++	The keys that control players movements are:
++
++	     PLAYER "+"  PLAYER "*"
++	     ----------  ----------
++	       Q W E	   I O P
++		\!/	    \!/
++	      A--S--D	  J--K--L
++		/!\	    /!\
++	       Z X C	   N M ,
++
++ NOTES:
++    The file 'TERMIO.PAS' contains terminal IO routines.  To use
++  TERMIO.PAS in your program, study the file TERMIO.PAS and
++  include those routines necessary into your source program.	There
++  are a couple of routines in TERMIO.PAS that may be included in
++  your Pascal source program at compile time: writes() and INITTERM.
++  Edit TERMIO.PAS and create a new file called TERMIO.LIB, then include
++  TERMIO.LIB in your Pascal program.	The Pascal/Z compiler will include
++  the source text as it compiles the main program.
++	All external modules may be found in the Pascal/Z Users' Group's
++  very useful library: ASL.REL [A Small Library].
++	The module 'gotoxy(x,y)' is included as source text in 'TERMIO.PAS'.
++
+}
CONST
  { DEFINE THE OUTER EDGE MARGINS }
  LM = 10;		{ left margin }
  RM = 70;		{ right margin }
  TM =	1;		{ top margin - remember: the top row is row 0 }
  BM = 17;		{ bottom margin }

  { DEFINE THE LIMITS OF THE PLAYING FIELD <THE GAME BOARD> }
  BLM = LM+2;		 { board left margin }
  BRM = RM-2;		 { board right margin }
  BTM = TM+2;		 { board top margin }
  BBM = BM-2;		 { board bottom margin }

  { DEFINE THE PLACEMENT FOR THE SCORE CARD }
  CardRow = BM+2;
  CardColumn = LM;
  alphalen = 10;		{<<< terminal IO routines >>>}

TYPE
  ACTION = ( NULL, EA, NE, NO, NW, WE, SW, SO, SE );
  BYTE = 0..255;
  alpha = array [0..alphalen] of byte;	{<<< terminal IO routines >>>}
  PLAYERTYPE = RECORD
		 X,		     { X-coordinates }
		 Y	  : BYTE;    { Y-coordinates }
		 CH	  : CHAR;    { Players identification }
		 STATE	  : ACTION;  { STATED ACTION }
		 SCORE	  : INTEGER;
	       END;
  STRING3 = PACKED ARRAY [1..3] OF CHAR;   { FOR TERMINAL STRINGS }
  STRING34 = PACKED ARRAY [1..34] OF CHAR;

VAR
  ASET, 		{ first set of keyboard control keys }
  BSET : SET OF CHAR;	{ second set of keyboard control keys }
  COUNT : INTEGER;	{ count number of rounds played }
  EXT : BYTE;		{ direct console character }
  FACTOR : INTEGER;	{ DELAY FACTOR }
  GAMEOVER : BOOLEAN;
  INCHAR : CHAR;	{ global input character }
  LASTMOVE : INTEGER;
  mover : byte; 	{ players turn to move }
  PLAYER_ONE,
  PLAYER_TWO,
  GHOST       : PLAYERTYPE;
  SEED : REAL;		{ for random numbers }

{$iTERMIO.VAR <<<terminal specific variables>>>}



FUNCTION CONCHAR: BYTE; EXTERNAL;
{ RETURNS A CONSOLE CHARACTER DIRECTLY WITH NO ECHO }


PROCEDURE DREAD( VAR CH: CHAR );
{ BY USING CONCHAR WE CREATE A READ ROUTINE THAT WAITS
  FOR A SINGLE KEYBOARD INPUT }
 VAR	 EXT: BYTE;
BEGIN
  REPEAT
    EXT := CONCHAR;
  UNTIL EXT<>0;
  CH := CHR( EXT );
END{ of DREAD };


FUNCTION TOUPPER(CH: CHAR): CHAR; EXTERNAL;
{ RETURNS THE CHARACTER IN UPPERCASE }


{$iTERMIO.LIB <<<procedures writes() and initterm>>>}


FUNCTION RANDOM( VAR SEED: REAL ): REAL;
{ RETURNS RANDOM NUMBERS IN RANGE 0 - 1 }
{ GLOBAL:
   SEED: REAL;
}
CONST PI = 3.14159;
VAR	X: REAL;
BEGIN
  X := SEED + PI;
  X := EXP(5.0 * LN(X));
  SEED := X - TRUNC(X);
  RANDOM := SEED
END{ of RANDOM };


PROCEDURE ERASE( VAR PLAYER: PLAYERTYPE );
BEGIN
  GOTOXY( PLAYER.X, PLAYER.Y );
  WRITE(' ')
END{ of ERASE };


FUNCTION DIRECTION( A: INTEGER ): ACTION;
{  RETURNS AN ACTION FROM A NUMERIC DIRECTION
   ACCORDING TO THE FOLLOWING CONVENTION:
	  NO=3
     NW=4 \ ! /NE=2
	   \!/
   WEST=5<--+-->EAST=1
	   /!\
    SW=6  / ! \ SE=8
	 SOUTH=7
}
BEGIN
  CASE A OF
    1: DIRECTION := EA;
    2: DIRECTION := NE;
    3: DIRECTION := NO;
    4: DIRECTION := NW;
    5: DIRECTION := WE;
    6: DIRECTION := SW;
    7: DIRECTION := SO;
    8: DIRECTION := SE
  END
END{ of Direction };


PROCEDURE Wappo( VAR PLAYER: PLAYERTYPE );
{ CHANGES PLAYERS DIRECTION AND COORDINATES }
BEGIN
  WITH PLAYER DO BEGIN
    ERASE( PLAYER );
    STATE := DIRECTION( TRUNC(8.0*RANDOM(SEED))+1 );
    { ESTABLISH NEW COORDINATES }
    X := TRUNC(BM*RANDOM(SEED)) + TM;
    Y := TRUNC(RM*RANDOM(SEED)) + LM
  END
END{ of Wappo };


Procedure ScoreCard;
const	sp = '    ';

   procedure sc_a;
   begin
     writes(INVON);write(sp);writes(INVOFF);
   end{ of sc_a };

begin
  { write player two's score first }
  gotoxy( (CardColumn+35),(CardRow+2) );
  sc_a; write( PLAYER_TWO.SCORE:5, '000' ); sc_a;

  { now write score for player one leaving cursor in center of screen }
  gotoxy( (CardColumn+5),(CardRow+2) );
  sc_a; write( PLAYER_ONE.SCORE:5, '000' ); sc_a;

  gotoxy(40,(TM+5)); { pull cursor up out of the way }
end{ of ScoreCard };


PROCEDURE InitScoreBoard;
const	blanks = '                  ';
var	CC1, CC2 : byte;

   procedure init_b( x,y: byte );
   begin
     gotoxy( x,y );
     writes(invon);write(blanks);writes(invoff);
   end{ of init_b };

BEGIN
  CC1 := CardColumn + 5;
  CC2 := CardColumn + 35;
  init_b( CC1, CardRow );
  init_b( CC2, CardRow );

  gotoxy( CC1,(CardRow+1) );
  writes(invon);write('    PLAYER (+)    ');writes(invoff);

  gotoxy( CC2,(CardRow+1) );
  writes(invon);write('    PLAYER (*)    ');writes(invoff);

  ScoreCard;
  init_b( CC1,(CardRow+3) );
  init_b( CC2,(CardRow+3) );
END{ of InitScoreBoard };


PROCEDURE GENSCORE( VAR PLAYER: PLAYERTYPE );

   function hit( var a,b: playertype ): boolean;
   { RETURNS TRUE IF BOTH PLAYERS HAVE THE SAME COORDINATES }
   begin
     hit := ((a.x=b.x) and (a.y=b.y))
   end;

BEGIN
  {  ARE ANY SQUARES OCCUPIED BY TWO PLAYERS	}
  IF HIT( PLAYER_ONE, PLAYER_TWO ) THEN BEGIN
     { GIVE PLAYER ON THE MOVE A BONUS SCORE }
     PLAYER.SCORE := PLAYER.SCORE + 500;
     Wappo( PLAYER_ONE );
     Wappo( PLAYER_TWO );
     ScoreCard;
  END
  ELSE BEGIN  { ARE ANY SQUARES OCCUPIED BY THE GHOST AND PLAYER 1 OR }
    { THE GHOST AND PLAYER 2 }
    IF HIT( GHOST, PLAYER_ONE ) THEN BEGIN
      PLAYER_ONE.SCORE := 0;
      Wappo( PLAYER_ONE );
      wappo( ghost );
      ScoreCard
    END
    ELSE IF HIT( GHOST, PLAYER_TWO ) THEN BEGIN
      PLAYER_TWO.SCORE := 0;
      Wappo( PLAYER_TWO );
      wappo( ghost );
      ScoreCard
    END
    ELSE
      PLAYER.SCORE := PLAYER.SCORE + 1
  END{ELSE}
END{ of GenScore };


FUNCTION GENSTATE( CH: CHAR ): ACTION;
{ GENERATES A NEW STATE DEPENDING UPON THE CHARACTER PASSED }
{ USING THE FOLLOWING CONVENTION:
    PLAYER 1	PLAYER 2
     Q W E	 I O P
      \!/	  \!/
    A--S--D	J--K--L
      /!\	  /!\
     Z X C	 N M ,
}
BEGIN
  CASE TOUPPER(CH) OF
   'S','K':	GENSTATE := NULL;
   'D','L':	GENSTATE := EA;
   'E','P':	GENSTATE := NE;
   'W','O':	GENSTATE := NO;
   'Q','I':	GENSTATE := NW;
   'A','J':	GENSTATE := WE;
   'Z','N':	GENSTATE := SW;
   'X','M':	GENSTATE := SO;
   'C',',','<': GENSTATE := SE
  END
END{ of GENSTATE };


PROCEDURE GenMove( VAR PLAYER: PLAYERTYPE; ext: byte );
var	ch: char;

   PROCEDURE DELAY( FACTOR: INTEGER);
   VAR IX : INTEGER;
   BEGIN
     FOR IX:=1 TO FACTOR DO {DELAY}
   END;

BEGIN
  { if new character entered from keyboard then generate }
  { a new direction for the player concerned }
  if ( ext<>0 ) then begin
     ch := chr(ext);
     IF ( CH IN ASET ) THEN
	PLAYER_ONE.STATE := GENSTATE(CH)
     ELSE IF ( CH IN BSET ) THEN
	PLAYER_TWO.STATE := GENSTATE(CH)
  end;

  WITH PLAYER DO BEGIN
    ERASE( PLAYER );

    CASE STATE OF
      NULL: {HOLD PRESENT POSITION};
	EA:  X := X + 1;
	NE:  BEGIN X := X + 1; Y := Y - 1 END;
	NO:  Y := Y - 1;
	NW:  BEGIN X := X - 1; Y := Y - 1 END;
	WE:  X := X - 1;
	SW:  BEGIN X := X - 1; Y := Y + 1 END;
	SO:  Y := Y + 1;
	SE:  BEGIN X := X + 1; Y := Y + 1 END
    END{CASE};

    { CHECK IF WE ARE MOVING OFF THE SCREEN }
    IF ( Y>BBM ) THEN
       Y := BTM
    ELSE IF ( Y<BTM ) THEN
       Y := BBM;
    IF X>BRM THEN
       X := BLM
    ELSE IF X<BLM THEN
       X := BRM;

    GOTOXY(X,Y); WRITE( CH )
  END{WITH};

  GENSCORE( PLAYER );
  DELAY(FACTOR)
END{ of GenMove };


PROCEDURE SIGN( TXT: STRING34 );
CONST
  border = '**********************************';
begin
  GOTOXY(25,7); { row=7 }
  writes(invon);write(border);writes(invoff);
  GOTOXY(25,8);
  writes(invon);write(txt);writes(invoff);
  GOTOXY(25,9);
  writes(invon);write(border);writes(invoff);
end{ of SIGN };


PROCEDURE INITIALIZE;
TYPE	MSTRING = STRING 255;
VAR	IX: BYTE;

   PROCEDURE HALT( TXT: MSTRING ); EXTERNAL;

BEGIN
  { INITIALIZE TERMINAL SPECIFIC VARIABLES }
  IF NOT INITTERM THEN
     HALT('File "TERMIO.FIL not found. Run INSTALL.');
  COUNT := 0;		{ ROUNDS COUNTER }
  SEED := 4.0;		{ THIS ISN'T TRULY RANDOM! }

  { init the first set of keyboard control keys }
  ASET := ['q','Q','w','W','e','E',
	   'a','A','s','S','d','D',
	   'z','Z','x','X','c','C'];

  { init the second set of keyboard control keys }
  BSET :=  ['i','I','o','O','p','P',
	    'j','J','k','K','l','L',
	    'n','N','m','M',',','<'];

  { clear the terminal screen and signon }
  writes( CLRSCR );
  SIGN( '***      T H E  G A M E        ***' );
  WRITELN;WRITELN;WRITELN;

  { SET UP DELAY FACTOR }
  WRITELN(' ':12, '1 - BEGINNING GAME');
  WRITELN(' ':12, '2 - ADVANCED GAME');
  WRITELN(' ':12, '3 - MASTER CRAFTSMAN');
  WRITELN;
  WRITE(' ':12, 'SELECT ->');
  DREAD(inchar);
  LASTMOVE := 5000;
  case inchar of
    '1': begin FACTOR := 500; lastmove := 1000 end;
    '2': FACTOR := 250;
    '3': FACTOR := 1;
   ELSE: FACTOR := 50
  end;

  writes( CLRSCR );
  writes( CRSOFF ); { TURN CURSOR DISPLAY OFF ON TERMINALS THAT CAN DO SO. }

  { PLACE A BOARDER AROUND THE PLAYING FIELD }
  for ix:=LM to RM do begin { top and bottom borders }
      gotoxy(ix,TM); write('=');
      gotoxy(ix,BM); write('=')
    end;
  for ix:=TM to BM do begin { left and right borders }
    gotoxy(LM,ix); write('=');
    gotoxy(RM,ix);write ('=')
  end;


  { INITIALIZE PLAYERS AND GHOST }
  WITH GHOST DO BEGIN
    CH := 'C';
    SCORE := 0
  END;
  WITH PLAYER_ONE DO BEGIN
    CH := '+';
    SCORE := 0
  END;
  WITH PLAYER_TWO DO BEGIN
    CH := '*';
    SCORE := 0
  END;

  InitScoreBoard;

  { PLACE THE BEGINNING MOVES }
  Wappo( GHOST );	{ FIRST - PICK RANDOM POINTS FOR PLACEMENT }
  Wappo( PLAYER_ONE );
  Wappo( PLAYER_TWO );

  GenMove( PLAYER_ONE, 0 );
  GenMove( PLAYER_TWO, 0 );
  GenMove( GHOST, 0 )
END{ of Initialize };



BEGIN{ MAIN PROGRAM }
  INITIALIZE;
  GAMEOVER := FALSE;
  mover := 1;
  ext := 0; { preload ext to no character input }
  WHILE not gameover do begin
    if ext=1 then begin
       gameover := true
    end
    else begin
      case mover of
	  1: GenMove( player_one, ext );
	2,4: GenMove( ghost, ext );
	  3: GenMove( player_two, ext )
      end;
      mover := mover + 1;
      if mover>4 then mover := 1;
      COUNT := COUNT + 1;
      gameover := ( count>lastmove );
      if ( count mod 6=0 ) then { TRY A NEW DIRECTION FOR THE GHOST }
	 GHOST.STATE := DIRECTION( TRUNC(8.0*RANDOM(SEED))+1 );
      { keep reading the console }
      ext := conchar
    end {else}
  END{WHILE};

  SIGN( '***      G A M E  O V E R      ***' );

  GOTOXY(0,0);
  writes( CRSON )    { TURN CURSOR BACK ON }
END{ of Program LeGame }.
     G A