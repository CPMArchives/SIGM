Program GameOfLife;{INPUT,OUTPUT}
{
  Program to play the game of Life as developed by H.L. Conway
  at the University of Cambridge and introduced in the
  "Mathematical Games" section of the October 1970 "Scientific
  American" magazine.

SUMMARY:
  Life is played on a grid of squares.	A given square is either
  occupied or empty.  The program user specifies which squares are
  occupied initially.  The game of Life program produces new generations
  of the matrix by applying life's laws for birth, survival, and death
  to the present generation.  These laws are:

BIRTH:
  An unoccupied square becomes occupied if in the preceding generation
  exactly three of the eight neighboring squares were occupied
  (squares that touch horizontally, vertically or diagonally are said
  to be neighboring squares).

SURVIVAL:
  An occupied square remains occupied if in the preceding generation
  two or three neighboring squares were occupied.

DEATH:
  An occupied square becomes unoccupied if in the preceding generation
  fewer than two or more than three neighboring squares were occupied.


MODIFICATION RECORD:
     FEB 18, 1981 - Modified for Paascal/Z by Raymond E. Penley.
		  - Any external routines may be obtained from the
		    Pascal/Z Users' Group.
     FEB 21, 1981 - Added escape from data entry portion.
}

CONST

  {The following cursor controls work with a terminal
  such as the Lear Siegler ADM3A, SOROC 120, Televideo.}
       lf=10;		(* cursor down = ctrl/J *)
       uparrow=11;	(* cursor up   = ctrl/K *)
       bkspce=8;	(* cursor back = ctrl/H *)
       ff=12;		(* cursor fwd  = ctrl/L *)
       space=32;	(* ASCII space *)
       sub=26;		(* ASCII clear screen code *)
       esc = 27;	(* ASCII escape code *)
       maxboardsize = 22;
       widthmaxboard=77; 

TYPE   state = (dead, stable, growing);
       neighbor = set of 0..8;
       boards = packed array [1..widthmaxboard,1..maxboardsize] of char;

VAR    survivepopulation:neighbor;
       boardstate	:state;
       newboard,
       oldboard 	:boards;
       j		:1..maxboardsize;
       i		:1..widthmaxboard;
       firsttime       :boolean;
       numberofneighbors:0..8;
       alivecount,
       boardsize,
       changecount,
       generation,
       maxgeneration,
       boardwidth	:integer;
       left,right,
       up,down,
       horizoffset,
       vertoffset	:-1..+1;

{$M-}{ integer mult & divd error checking OFF }
{$F-}{ floating point error checking OFF }
{$R-}{ range checking OFF }
{$S-}{ stack checking OFF }

PROCEDURE GOTOXY(X,Y:INTEGER);
BEGIN
  IF X<0 THEN X :=  0;
  IF X>79 THEN X := 79;
  IF Y<0 THEN Y := 0;
  IF Y>23 THEN Y := 23;
  WRITE( CHR(27),'=',CHR(Y+32),CHR(X+32));
END;

PROCEDURE KEYIN(VAR C:CHAR); EXTERNAL;

procedure clearscreen;
begin
  write(chr(sub));
end;


procedure getanimals(VAR hit: boolean);
var	ch,
	escape,
	up,
	right,
	rght,
	left,
	down   :char;
begin
  escape := chr(esc);
  up := chr(uparrow);
  right := chr(space);
  rght := chr(ff);
  down := chr(lf);
  left := chr(bkspce);
  hit := false;
  repeat
	KEYIN(ch);
	(* read(keyboard,ch); *)
	if ( ch=escape ) then
	  begin
	    ch := 'D';
	    hit := true;
	  end
	else if ( ch=down ) then 
	  begin
	    if ( (j+1)>boardsize ) then j := boardsize else j := j+1;
	    gotoxy(i,j);
	  end
	else if ( ch=up ) then 
	  begin
	    if ( (j-1)<1 ) then j := 1 else j := j-1;
	    gotoxy(i,j);
	  end
	else if (ch=right) or (ch=rght) then 
	  begin
	    if ( (i+1)>boardwidth ) then 
	      begin
		i := 1;
		if ( (j+1)>boardsize ) then j := boardsize else j := j+1;
	      end
	    else i := i+1;
	    gotoxy(i,j);
	  end
	else if ( ch=left ) then 
	  begin
	    if ( (i-1)<1 ) then 
	      begin
		i := boardwidth;
		if ( (j-1)<1 ) then j := 1 else j := j-1;
	      end
	    else i := i-1;
	    gotoxy(i,j);
	  end
	else if ( ch='*' ) then 
	  begin
	    write(ch);
	    oldboard[i,j] := '*';
	    alivecount := alivecount+1;
	    if ( (i+1)>widthmaxboard ) then 
	      begin
		i := 1;
		if ( (j+1)>maxboardsize ) then
		  j := maxboardsize
		else
		  j := j+1;
		gotoxy(i,j);
	      end
	    else i := i+1;
	  end;
  until (ch='d') or (ch='D');
end;  (* get animals *)


Procedure PrintHeader;
begin
  writeln('Generation #',generation:3, '     Population =',alivecount:3);
end;{ of PrintHeader }


procedure initialize;
{ Here is the input section.  It initializes all necessary parameters
  and creates the initial board}
label	1;
const	s1 = 'Please enter the ';
var	hit : boolean;
begin
1:{ here if hit }
  generation := 0;
  If firsttime then
    clearscreen
  else
    gotoxy(0,0);
  writeln(s1, 'maximum number of generations'); 
  write  ('     you would like for this game: ->');
  readln(maxgeneration);
  write  (s1, 'board width for this game: ->');
  readln(boardwidth);
  write  (s1, 'board heighth for this game: ->');
  readln(boardsize);
  if ( boardsize>maxboardsize ) then
     boardsize := maxboardsize;
  if ( boardwidth>widthmaxboard ) then
     boardwidth := widthmaxboard;
  clearscreen;
  writeln;
  for j := 1 to boardsize do
    begin
      write(' ');
      for i := 1 to boardwidth do
	begin
	  oldboard[i,j] := ' ';
	  write('-');
	end;
      if ( j<boardsize ) then writeln;
    end;
  gotoxy(0,0);
  writeln('"*"=organism, cursor control keys move cursor,',
	  ' D for done, ESC start over');
  alivecount := 0;
  i := 1;
  j := 1;
  gotoxy(i,j);
  getanimals(hit);
  clearscreen;
  If hit then goto 1;
  printheader;
  for j := 1 to boardsize do
    begin
      for i := 1 to boardwidth do
	write (oldboard[i,j]);
      if ( j<boardsize ) then writeln;
    end;
end {initialize};
       

procedure processboard;
{ The actual board processing begins here}
begin
{$C-}{ control-c cheking OFF }
  alivecount := 0;
  changecount := 0;
  for i := 1 to boardwidth do
    begin
      for j := 1 to boardsize do
	begin
	{first we must compute the number of neighbors for
	 a cell at coordinate i,j  We must make sure that the
	 cell is not on an edge}
	  if ( i>1 )
		then left := -1
		else left := 0;
	  if ( i<boardwidth )
		then right := +1
		else right := 0;
	  if ( j>1 )
		then up := -1
		else up := 0;
	  if ( j<boardsize )
		then down := +1
		else down := 0;
	  numberofneighbors := 0;
	  for horizoffset :=  left to right do
	    begin
	      for vertoffset := up to down do
		if (oldboard[i+horizoffset,j+vertoffset] ='*') and
		   ((horizoffset<>0) or (vertoffset<>0))
		   then numberofneighbors := numberofneighbors+1;
	    end;
	   {The last test prevents counting a cell as a
	    neighbor of itself.
	    Now see which cells should be alive in the 
	    next generation.}
	   newboard[i,j] := ' ';
	   if ((oldboard[i,j]=' ') and (numberofneighbors = 3)) 
	     or ((oldboard[i,j] = '*')
		 and (numberofneighbors in survivepopulation))
		   then begin
		      newboard[i,j] := '*';
		      alivecount := alivecount +1
		      end;
	end {j loop};
      end{i loop};  {of the processing of each individual cell}
end; {of processboard}

{$C+}{ Control-C checking ON }

procedure printgeneration;
{ We have now completed a new generation. Print it out
  and copy it back into the oldboard to get ready for the
  next cycle}
begin
  generation := generation +1;
  clearscreen;
  PrintHeader;
  for j := 1 to boardsize do
    begin
      for i := 1 to boardwidth do
	begin
	  write (newboard[i,j]);
	  {see if anything has changed during this generation}
	  if ( newboard[i,j]<>oldboard[i,j] ) then
	    begin
	      changecount := changecount+1;
	      oldboard[i,j] := newboard[i,j]
	    end
	end;
      if ( j<boardsize ) then writeln;
    end;
  {set a flag indicating the state of the board at the end of this
   generation}
 if ( alivecount=0 ) then
   boardstate := dead
 else 
   if ( changecount=0 ) then
     boardstate := stable
   else boardstate := growing
end {processboard};
      
procedure printresults;
{ print why we stopped }
begin
  case boardstate of
    dead      :writeln('Colony died');
    stable    :writeln('Colony is stable');
    growing   :writeln('Maximum generation number has been exceeded')
  end {of case statement}
end {printresults};


begin{ MAIN PROGRAM }
  firsttime := true;
  While true do
    begin
      survivepopulation := [2,3];
      initialize;
      firsttime := false;
      repeat
	processboard;
	printgeneration;
      until (boardstate = dead)
	   or (boardstate = stable)
	     or (generation >= maxgeneration);
      printresults;
    end;
end.{Game of Life}
ad)
	   or (boardstate = stable)
	     or (