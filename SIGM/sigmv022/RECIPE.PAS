PROGRAM RECIPE;
(*
**  PROGRAM TITLE	THE RECIPE SYSTEM
**			Version PAS-1.2 translated from
**			the BASIC version into Pascal.
**
**  WRITTEN BY:		Ray Penley
**  DATE WRITTEN:	23 FEB 1980 / last modified: 28 FEB 80
**  WRITTEN FOR:	Computer hobbyists
**
**  PROGRAM SUMMARY:
**
**  The recipe system stores recipes and retrives them
**  by means of a numeric key that represents the foods
**  used in the meal.  Foods are divided into four
**  categories according to their nutritional value.
**
**  INPUT AND OUTPUT FILES:
**	RCPDAT.XXX and RCPDAT.YYY
**		   - the DATA and the backup files
**	RECIPE.MST - the statistics file
**	DUMMY.$$$  - see Procedure InputRecipe for use.
**
**  ORIGINAL PROGRAM:
**	T.G.LEWIS, 'THE MIND APPLIANCE'
**	HAYDEN BOOK COMPANY
**)
CONST
  str_len = 73;		(* max length of all strings + one *)
  EOS	  = '|';	(* End of String marker *)
  Master  = 'RECIPE.MST';
  Tab20	  = 20 ;
  Tab15	  = 15 ;
  on 	  = true;
  off	  = false;

(* !!!!! IMPLEMENTATION DEPENDENCY !!!!! *)
   (*****   PASCAL/Z ver 2.0   *****)
	  INPUT   = 0;

TYPE
  string   = packed array[1..str_len] of char;
  string2  = packed array[1..2] of char;
  string14 = packed array[1..14] of char;
  datatype = record
		 MR,		(* MaxRecords	*)
		 CR : integer;	(* Curr_Rcds	*)
		 F1,		(* current_ID	*)
		 F2,		(* backup_ID	*)
		 date : string14(* last_update	*)
	     end;
VAR
  a_RAY		: packed array[1..5] of string;
  data		:datatype;
  Bell,
  command	:char;
  Last_update	:string14;
  Curr_Rcds,	(* No. of current active records *)
  Hash,		(* Computed Index value of Recipe *)
  Last,
  MaxRecords,	(* Maximum records allowed *)
  TTY		(* width of terminal/CRT *)
		:integer;
  End_of_File,		(* End of File flag *)
  End_of_Text,		(* End of Text flag *)
  adding_recipies,	(* flag = true when adding recipies *)
  switch, error,
  done, yflag	: boolean;

	(* FID. File Identifier *)
  current_ID,			(* Current file ID *)
  backup_ID	:string14;	(* Back up file ID *)

	(* FCB. File descriptors *)
  fa, fb	:TEXT;
  stats		:FILE of datatype;


(*----------------------------------------------*
 *	      INPUT/OUTPUT ROUTINES		*
 *----------------------------------------------*)


(*----------------------------------------------*)
(*		  DISK I/O			*)
(*----------------------------------------------*)


Procedure OPEN_MASTER;
begin
  (* OPEN file RECIPE.MST for READ assign stats *)
	  RESET(master, stats);
  READ(stats, data );
  with data do begin
    MaxRecords := MR;
    Curr_Rcds  := CR;
    current_ID	:= F1;
    backup_ID	:= F2;
    last_update := date
    end(* with *)
end;

Procedure UPDATE_MASTER;
begin
  (* OPEN file RECIPE.MST for WRITE assign stats *)
	  REWRITE(master, stats);
  with data do begin
    MR := MaxRecords;
    CR := Curr_Rcds;
    F1 := current_ID ;
    F2 := backup_ID ;
    date := last_update
    end(* with *);
  WRITE(stats, data )
end;

Procedure GETLINE((* VAR fx : TEXT; *)
		     VAR INBUFF : string );
(**
Returns:
	End_of_Text = true if attempt is made to exceed
		    the input buffer length.
	End_of_File = true if EOF
	INBUFF    = input string
***)
VAR
 CH   : CHAR;
 ix, length : integer;
begin
  length := 0;
  End_of_Text := FALSE;
  WHILE NOT EOF(fa) AND (CH <> EOS) DO
    begin
    If length < str_len then
      begin
      READ(fa, CH );
      length := length +1;
      INBUFF [length] := CH
      end(* If *)
    ELSE	(***   error   ***)
      begin
      error := true;
      End_of_Text := TRUE
      end(* else *)
    end(* WHILE *);
    If length >= last then
      last:=length
    Else
      REPEAT
	INBUFF[ last ] := EOS;
	last := last -1
      UNTIL last=length;
	(*** !!! SET FLAG !!! ***)
  End_of_File := EOF(fa);
end(*---of GetLine---*);

Procedure PUTLINE((* VAR fx : TEXT; *)
		     VAR this :string );
VAR
  CH  : char;
  pos : integer;
begin
  pos := 0;
  REPEAT
    pos := pos +1;
    CH := this[ pos ];
    If CH <> EOS then Write(fb, CH)
  UNTIL (CH = EOS) OR (pos = str_len);
  Write(fb, EOS ) (* Mark the End of String *)
end(*---of PUTLINE---*);

Procedure PUT_RECORD((* VAR fx : TEXT; *)
			VAR Index : integer );
VAR
  jx : integer;
begin
  Writeln(fb, Index:5);
  For jx:=1 to 5 do
    PUTLINE((* fb, *) a_RAY[jx] );
end(*---of PUT_RECORD---*);

Procedure GET_RECORD((* VAR fx : TEXT; *)
			VAR Index : integer );
VAR
  JJ : integer;
begin
  READLN (fa, Index);
  FOR JJ := 1 to 5 DO
    GETLINE((* fa, *) a_RAY[JJ] );
end(*---of GET_RECORD---*);

(*----------------------------------------------*)
(*		CONSOLE I/O			*)
(*----------------------------------------------*)

Procedure PRINT((* VAR fx : TEXT; *)
		   VAR this : string );
(*	Print the string 'this' until EOS 	*)
VAR
  CH : CHAR;
  pos : integer;
begin
  pos := 0;
  REPEAT
    pos := pos +1;
    CH := this[ pos ];
    If CH <> EOS then Write(CH)
  UNTIL (CH = EOS) OR (pos = str_len);
  Writeln
end(*---of PRINT---*);

Procedure SCAN((* VAR fx : TEXT; *)
		 VAR INBUFF : String ;
		      count : integer );
(*	SCAN Version 1.1		*
Enter with:
	count = maximum # chars allowed.
Returns:
	INBUFF = input string
	EOS    = End of string marker
Flags:
	error  = false - good input
	       = true if buffer length exceeded
		      If invalid ASCII char detected.

	Valid Alphanumeric chars are:
	between the space - CHR(32) to the tilde - CHR(126)
GLOBAL
   str_len = << default for string length >>
   EOS   = '|';
   error  : boolean
   string  : packed array[1..str_len] of char
 *)
VAR
  InChar : char;
  length : integer;
begin
  error := false;
  For length:=1 to str_len do INBUFF[ length ]:= EOS;
  length := 0;
  REPEAT
    If length < count then(* get valid inputs *)
      begin
      READ( InChar );
      If InChar IN [' ' .. '~'] then
	begin (* Increment length and store InChar *)
	length := length +1;
	INBUFF[length] := InChar
        end(* if *)
      ELSE
	begin
	Writeln(' Alphanumerics only -');
	error:=TRUE
	end(* else *)
      end(* If *)
    ELSE	(*   ERROR   *)
      begin (* RESET EndOfLine (EOLN) *)
      READLN(INBUFF[count]);
      Writeln('Maximum of', count:4, ' characters please!');
      error:=TRUE
      end(* ELSE *)
  UNTIL EOLN(INPUT) OR error;
end(*---of SCAN11---*);

(*----------------------------------------------*
 *		UTILITY ROUTINES		*
 *----------------------------------------------*)


Procedure QUIRY;
(*	YES/NO INPUT MODULE
Returns:
	yflag	=TRUE FOR ''Y' or 'y' INPUT
		=FALSE FOR 'N' or 'n' INPUT
GLOBAL
	yflag : boolean;
*)
VAR
  Ans : char;
  error : boolean;
begin
  error := true;
  yflag := false;
  REPEAT
    error := false;
    READ(Ans);
    If (Ans = 'Y') OR (Ans = 'y') then
      yflag := true
    Else
      If (Ans <> 'N') AND (Ans <> 'n') then
        begin
	Writeln(BELL, 'Please answer ''Y'' or ''N'' ');
	error := true
	end
  Until NOT error
end(*---of QUIRY---*);

Procedure CLEAR;
(* Device dependent procedure	*)
begin
  Write( CHR(26) );
end;

Procedure SKIP(L1 : integer);
VAR ix : integer;
begin
  FOR ix:=1 to L1 do Writeln;
end;

Procedure PAUSE;
VAR dummy : char;
begin
  skip(4);
  Write('Type return to continue:');
  READ(dummy);
end;

Procedure BREAK;
begin
  CLEAR;
  SKIP(5);
end;

Procedure Pstring(picture : string2; count : integer );
VAR ix : integer;
begin
  FOR ix:=1 to count DO Write( picture );
  Writeln;
end(*---of Pstring---*);

Procedure ShowRecipe;
VAR JJ : integer;
begin
  FOR JJ := 1 to 5 DO
    PRINT(a_RAY[JJ]) ;
  Writeln
end(*--of ShowRecipe--*);

Procedure Display_One(VAR Index : integer);
begin
  Writeln;
  Writeln( 'Recipe #', Index:5 );
  Writeln;
  Pstring( '- ', 20);
  Writeln;
  ShowRecipe;
  skip(4)
end;

(*----------------------------------------------*
 *		   ADD MODULE			*
 *----------------------------------------------*)

Procedure InputFeatures(VAR I : integer);
(******************************************
*	Input Features of Recipe	  *
*******************************************)
(*
RETURNS:
  Hash value computed for various choices
**)
CONST
  Msg1	  = 'None of these' ;
VAR
   F, D, V, P :integer;

	Function QUIRY(X2 : integer) : integer;
	VAR ix : integer;
	begin
	  REPEAT
	    Writeln;
	    Write('Enter Choice (1 to', X2:2, ') ');
	    READ(ix);
	  UNTIL (ix>=1) AND (ix<=X2) ;
	  QUIRY := ix;
	end;
begin
  Writeln;
  Writeln( ' Enter number of choice :');
  Writeln;
  Writeln( ' ':Tab15, 'Fibre Foods' );
  Writeln;
  Writeln( ' ':Tab15, '1.  Bread (flour)     2.  Oats' );
  Writeln( ' ':Tab15, '3.  Rice              4.  Corn' );
  Writeln( ' ':Tab15, '5.  Macaroni          6.  Noodles' );
  Writeln( ' ':Tab15, '7.  Spaghetti         8.  ', Msg1 );
  F := quiry(8);
  Writeln;
  Writeln( ' ':Tab15, 'Protein' );
  Writeln;
  Writeln( ' ':Tab15, '1.  Beef              2.  Poultry' );
  Writeln( ' ':Tab15, '3.  Fish              4.  Eggs' );
  Writeln( ' ':Tab15, '5.  Beans             6.  Nuts' );
  Writeln( ' ':Tab15, '7.  ', Msg1 );
  P := quiry(7);
  BREAK;
  Writeln;
  Writeln( ' ':Tab15, 'Dairy' );
  Writeln;
  Writeln( ' ':Tab15, '1.  Milk                2.  Cheese' );
  Writeln( ' ':Tab15, '3.  Cottage Cheese      4.  Cream' );
  Writeln( ' ':Tab15, '5.  Sour Cream          6.  ', Msg1 );
  D := quiry(6);
  Writeln;
  Writeln( ' ':Tab15, 'Fruits and Vegetables' );
  Writeln;
  Writeln( ' ':Tab15, '1.  Citrus              2.  Melon' );
  Writeln( ' ':Tab15, '3.  Juices              4.  Greens' );
  Writeln( ' ':Tab15, '5.  Yellows & Reds' );
  Writeln( ' ':Tab15, '6.  ', Msg1 );
  V := quiry(6);

   (******************************************
   *  Compute the index value by assigning   *
   *  a weight to each digit in the set.     *
   *******************************************)

	I := 252*F + 36*P + 6*D + V -295
end;


Procedure InputRecipe;

LABEL 2399; (*---EXIT---*)

VAR
  state : (absent, done, adding) ;
  ix, jx : integer;
  temp	 : string14;
  Line	 : string;

	Procedure Correct;
	begin
	REPEAT
	  BREAK;
	  Write(bell);
	  Writeln(' ':(TTY DIV 2) -10, 'HERE IS YOUR RECIPE');
	  Writeln;
	  ShowRecipe;
	  Writeln;
	  Writeln('Are there any corrections to be made ');
	  QUIRY;
	  If yflag then
	    begin
	    BREAK;
	    Writeln('Enter <cr> return if correct or Reenter the line');
	    Writeln;
	    For ix:=1 to 5 do
	      begin
	      PRINT(a_RAY[ix]);
	      SCAN(Line, str_len -1);
	      If Line[1] <> ' ' then a_RAY[ix] := Line
	      end
	    end(* If *)
	Until yflag=false;
	end(*---of Correct---*);

	Procedure QUEST;
	begin
	  Pause;
	  BREAK;
	  Write('Do you want to ADD recipies? ' );
	  QUIRY;
	  CLEAR;
	end;

begin(*---InputRecipe---*)
  QUEST;
  If yflag=false then (* EXIT *) goto 2399;
  adding_recipies := true ;
  state := adding ;
  (* OPEN file backup_ID for WRITE assign fb *)
	REWRITE(backup_ID, fb);

  (* OPEN file current_ID for READ assign fa *)
	RESET(current_ID, fa);

  If NOT EOF(fa) then
    begin(* COPY current to back_up *)
    ix := 0 ;
    While ix < Curr_Rcds do
      begin
      ix := ix +1;
      GET_RECORD((* fa, *) HASH);
      PUT_RECORD((* fb, *) HASH);
      end(* while *)
    end(* IF *);

(*---Input/Enter additional recipies until done---*)
(*---or curr_records > Max_Records allowed     ---*)

  REPEAT
  If Curr_Rcds > MaxRecords then
    state := done
  Else(* we can add more date *)
    begin
      Writeln( 'Identify Recipe with features. First ');
      InputFeatures(HASH);
      BREAK;
      Writeln( 'Now Enter 5 lines of the recipe');
      Writeln;
      For jx := 1 to 5 DO
	begin
	Write('>');
	SCAN( a_RAY[jx], str_len -1 );
	end;(* For *)
      Correct(* if required *);
      Curr_Rcds := Curr_Rcds +1;
      PUT_RECORD((* fb, *) HASH);
      QUEST;
      If yflag=false then state := done;
    end;(* else *)
  UNTIL state<>adding;

  (*---------------------------------------*
   *	     ***   trick   ***		   *
   *  close previous file ID assigned	   *
   *  FCB fb and fix CP/M directory entry  *
   *---------------------------------------*)

	REWRITE('DUMMY.$$$', fb);

  (*	SWAP file ID`s				*)
  (*	Back Up file is now the Current file	*)
  temp := backup_ID;
  backup_ID := current_ID;
  current_ID := temp;

  UPDATE_MASTER;(*--status file--*)

2399: (* EXIT *);
end(*--of InputRecipe--*);


(*--------------------------------------*)
(*	      DUMP/FIND MODULE		*)
(*--------------------------------------*)

Procedure File_Scan ;
(*
GLOBAL
  MaxRecords = maximum allowed records
  Curr_Rcds = # of recipes in file
*)
VAR
  state : (absent, found, searching) ;
  ix, index : integer;

	Procedure DUMP;
	(*********************************
	*  OUTPUT all Recipes from file  *
	**********************************)
	begin
	  REPEAT
	    If ix > Curr_Rcds then
	      state := absent
	    Else
	      begin
		ix := ix +1;
		GET_RECORD((* fa, *) HASH);
		Display_One(HASH);
		Pause
	      end(* else *)
	  UNTIL state<>searching;
	end(*--of DUMP--*);

	Procedure FIND;
	(*************************************
	*	Lookup recipes from file     *
	**************************************)
	VAR
	  Index : integer;
	begin
	  CLEAR;
	  InputFeatures(Index);
	  REPEAT
	    If ix > Curr_Rcds then
	      state := absent
	    Else
	      begin
		GET_RECORD((* fa, *) HASH);
		If HASH=Index then
		  state := found
		Else
		  ix := ix +1
	      end(* else *);
	  Until state<>searching;
	  If state=found then
	    begin
	    CLEAR;
	    Display_One(HASH);
	    end;
	end(*--of Lookup--*);

begin(*---File_Scan---*)
  Pause;
  state := absent;
  If adding_recipies then
    (* read new stats *) OPEN_MASTER;
  (* OPEN file current_ID for READ assign fa *)
	  RESET(current_ID, fa);

  If NOT EOF(fa) then
    begin
    state := searching ;
    ix := 1 ;
    If Curr_rcds=0 then
      state := absent
    Else
      begin
	CASE command of
	  'O', 'o':	DUMP;
	  'F', 'f':	FIND
	end(* case *)
      end(* else *)
    end(* IF *);
  If state=absent then
    begin
    BREAK;
    Writeln('That''s all the Recipes on File');
    end;
  Pause;
end(*---of File_Scan---*);

(*--------------------------------------*)
(*	      INITIALIZATION		*)
(*--------------------------------------*)


Procedure INIT1;
(* byte count/record = (chars/line + overhead/line) times No. of lines *)
begin
  BELL		:= CHR(7) ;
  TTY		:=  72 ;
  last		:= str_len ;
  MaxRecords	:= 50 ;(* 360 times 50 = 18000 bytes *)
  Curr_Rcds	:=  0 ;
  Last_Update	:= 'YY/MM/DD      ';
  current_ID	:= 'RCPDAT.XXX    ';
  backup_ID	:= 'RCPDAT.YYY    ';
  adding_recipies := false
end;

Procedure INIT2;
begin
   (* OPEN file `RECIPE.MST` for READ assign stats *)
	  RESET(master, stats);

  If EOF(stats) then(* not found *)
    (* OPEN file `RECIPE.MST` for WRITE assign stats *)
	  UPDATE_MASTER
  Else begin(* READ in data record *)
    READ(stats, data );
    with data do begin
      MaxRecords := MR;
      Curr_Rcds  := CR;
      current_ID := F1;
      backup_ID	 := F2;
      last_update := date
      end(* with *)
    end;
  SKIP(5);
  Writeln('Last update of Recipe data file was ', last_update);
  Writeln('File currently consists of ', Curr_Rcds:4, ' Recipies');
  Writeln;
  Write('Please enter todays date <YY/MM/DD>  ');
  READLN(last_update)
end;

(*----------------------------------------------*
 *		MAIN PROGRAM			*
 *----------------------------------------------*)

BEGIN
  INIT1;
  CLEAR;
  Pstring( '**', (TTY DIV 2));
  Writeln;
  Writeln( ' ':22, 'The Recipe System');
  Writeln;
  Pstring( '**', (TTY DIV 2));
  INIT2;
  done := false;
  WHILE NOT(done) DO
    begin
    CLEAR;
    Pstring( '**', (TTY DIV 2));
    skip(3);
    Writeln( ' ':Tab15, 'Select One of the following:');
    Writeln;
    Writeln( ' ':Tab20, 'I(nput Recipes');
    Writeln( ' ':Tab20, 'O(utput all Recipes');
    Writeln( ' ':Tab20, 'F(ind a Recipe');
    Writeln( ' ':Tab20, 'S(top');
    switch := on;
    WHILE switch(* is on *) do
      begin
      switch := off;
      Writeln;
      Write(' ':(Tab15), 'Enter choice   ' );
      READ( command );
	CASE command of
	  'I', 'i':	InputRecipe;
	  'O', 'o',
	  'F', 'f':	File_Scan;
	  'S', 's':	done := true;
	 ELSE:		begin
			Write(BELL);
			switch := on
			end
	end(* case *)
      end(* while switch is on *)
    end(* while not done *)
end(*---of Program Recipe---*).
