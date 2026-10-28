{*
 *  Program Title:	Wumpus
 *  Written by:		Gregory Yob
 *			More BASIC Computer Games
 *			Edited by David H. Ahl
 *
 * Translated into Pascal by Paul H. Gilliam from the
 * BASIC programs 'WUMPUS 1' and 'WUMPUS 2'
 *
 * This game will teach you how to play it.
 * Happy wumpus hunting!
 *
 *   29 June 1980	-corrected minor logic bugs.
 *   29 June 1980	-Modified for Pascal/Z v3.0
 *			 Pascal/Z does not allow jumps out
 *			 of Procedures/Functions [A practice
 *			 I fully agree with!]
 *  Donated July, 1980
 *}
Program  Wumpus;
LABEL	99;		{ Fatal error }
CONST
  default = 80;
  {---   define your screen parameters   ---}
  s_beglin =  1;	{ first line }      (* ADM-3A Screen parameters *)
  s_endlin = 23;	{ last  line }
  s_begcol =  1;	{ first column }
  s_endcol = 80;	{ last column  }

TYPE    
  alfa    = STRING 10;		{ just the right size }
  Dstring = STRING default;
  str0    = STRING 0;
  str255  = STRING 255;
  room     = 1 .. 20;
  tunnel   = 1 .. 3;

VAR
 arrowcount	: integer;
 bell		: char;
 cave		: array[room, tunnel] of room;
 cursorhome,		{ cursor controls }
 cursorup,
 cursordown,
 cursorleft,
 cursorright,  
 clearscreen,
 escape		: char;
 fatal_error	: boolean;
 i, j		: integer;	{ global indexers }
 initlocate	: array[1..6] of room;

Procedure KEYIN(VAR cix: char); external;
(*---Direct Keyboard input of a single char---*)

Function RANDOM(limit: integer): real; external;
(*---returns a real number from 0.0 to limit---*)

Function length(x: str255): integer; external;

Procedure gotoxy( col, row : integer );
(*		 X-coord, Y-coord	*)
begin
  WRITE( chr(27), '=', chr(row+32), chr(col+32))
end;

Procedure terminit;
begin 
 bell := chr(7);
 escape	    := chr(27);
 cursorhome := chr(30);
 cursorup   := chr(11);;   
 cursordown := chr(10);
 cursorleft := chr(8);
 cursorright := chr(12);  
 clearscreen := chr(26);	{ ASCII control-Z }
end{of terminit};

Procedure CLEAR;
begin
  Write(clearscreen);
end;

Procedure clearline( row: integer );
begin
  gotoxy( s_begcol, row);
  WRITE( ' ':(s_endcol-s_begcol+1) );
  gotoxy( s_begcol, row);
end;

Function  randroom : room; { 1..20 }
begin
  randroom := trunc(random(20)) + 1
end  { randroom };

Function  randtunnel : tunnel; { 1..3 }
begin
 randtunnel := trunc(random(3)) + 1
end  { randtunnel };

Function  wumpmove : integer; 
var	i : integer;
begin
  i := trunc(random(4)) + 1;
  If i > 3 then
    wumpmove := -1
  Else
    wumpmove := i;
end  { wumpmove };

Function QUIRY(sign: Dstring): boolean;
var	ch: char;
begin
  writeln;
  Repeat
    write(sign);
    KEYIN(ch);writeln(ch);
    writeln;
  Until ch IN ['Y', 'y', 'N', 'n'];
  QUIRY := ch in ['n', 'N'];
end;

Procedure Instruct;
{*
 *   Attempts to read in an external file to instruct the player
 *   as to how to play the game.
 *   Instruct will pause for console input whenever it finds the
 *   string "$pause" in the first position of a line in the line.
 *}
var	line : Dstring;  
	Ifile : text;
	ch : char;

	Procedure ShowInstructions;
	begin
	  CLEAR;
	  Readln(Ifile,line);
	  while  not eof(Ifile) do
	    begin
	      If (line = '$pause') or (line = '$PAUSE') then
		begin
		Clearline(s_endlin);
		write('Press <sp> to continue.');KEYIN(ch);
		CLEAR;
		end
	      Else
		writeln(line);
	      readln(Ifile,line);
	   end;{ While }
	End{ShowInstructions};

begin  { instruct }  
  CLEAR;
  write('Do you want instructions on how to play? ');
  KEYIN(ch);Writeln(ch);
  writeln;
  If (ch='y') or (ch='Y') then
    begin
      RESET('WUMPUS.DOC',Ifile);
      If not EOF(Ifile) then
	ShowInstructions
      Else
	begin
	writeln;
	writeln('Sorry,  instructions not availiable yet.');
	end;
    end
End{of instruct};
   
Procedure  getacave;
LABEL	9;{ABORT}
var
  i : room;	{ 1..20 }
  j : tunnel;	{ 1..3 }
  k : integer;
  CAVENAME : STRING 5;
  LINE : Dstring;
  cavein : text;
  ch : char;
begin 
 cavename := 'CAVE ';
 Repeat
   Writeln;
   write(bell, 'Enter cave #(0-5) ');
   KEYIN(ch);Writeln(ch);
 Until  ch in ['0'..'5'];
 cavename[5] := ch;
 (* OPEN file "cavename" for Read assign cavein *)
 RESET(cavename,cavein);
 fatal_error := EOF(cavein);
 If fatal_error then {ABORT}
   begin
     writeln;
     writeln('Fatal error - file not found');
     {ABORT}goto 9;
   end;
 writeln('reading ',cavename); 
 readln(cavein, line);
 for  i := 1 to 20 do
   for j := 1 to 3 do read(cavein,cave[i,j]);
  writeln;
  writeln('You are in ',line);
  writeln;
9:{ABORT}
End{ of getacave }{ CLOSE(cavein) };
 
Procedure  initsetup; 
var	locatesunique : boolean;
	i, j : integer;  
begin
 Repeat
   for  i := 1 to 6 do initlocate[i] := randroom;  
   locatesunique := true;
   i := 1;
   while  locatesunique and (i <= 6) do
     begin
     j := 1;
     while  locatesunique and (j <= 6) do
       begin
       If (initlocate[i] = initlocate[j]) and (j <> i) then
	 locatesunique := false
       Else
	 j := j + 1;
       end;
     i := i + 1
     end
 Until  locatesunique
End  { initsetup };
 
Procedure  HuntTheWumpus;
CONST	Title = 'Hunt the Wumpus'; 
TYPE	long = real;
VAR	i	: integer;
	game	: (inprogress, youlost, youwon);
	locate	: array[1..6] of room;
 
	Procedure  warnings;  
	var	location, i, j: integer;
	begin
	  writeln;
	  location := locate[1];   
	  for  i := 2 to 6 do
	    begin
	    for  j := 1 to 3 do
	      begin
	      If cave[location,j] = locate[i] then
		 case  i  of
		      2:  writeln('I smell a Wumpus!');
		   3, 4:  writeln('I feel a draft!');
		   5, 6:  writeln('Bats nearby!');
		 End{case};
	      end{ for j };
	    end{ for i };
	  writeln('You are in Room ',location:2);
	  write('Tunnels lead to ');
	  for  i := 1 to 3 do write(cave[location,i]:3); 
	  writeln;
	End  { warnings };
 
	Function  WantToShoot : boolean;   
	LABEL 4;{EXIT}
	var	ch : char;      
	begin
	  Repeat
	    writeln;
	    write('Shoot or move (s-m) <esc>');     
	    KEYIN(ch);writeln;
	    If ch = escape then
	      begin   
	      game := youlost;
	      { EXIT(HuntTheWumpus) } goto 4;
	      end;
	    If ch = 'l' then
	      begin  
	      write('you = ',locate[1]:3, ' ':8);
	      write(' wumpus = ',locate[2]:3);
	      writeln(' pits = ',locate[3]:3,',',locate[4]:3);
	      writeln(' bats = ',locate[5]:3,',',locate[6]:3);
	      writeln
	      end;
	  Until  ch in ['m', 'M', 's', 'S'];   
	  WantToShoot := ch in ['S', 's'];
	4:{EXIT}
	End  { WantToShoot }; 
                    
	Procedure  movewumpus; 
	var	i : integer;
	begin
	  i := wumpmove;
	  If i > 0 then  locate[2] := cave[locate[2],i];
	  If locate[1] = locate[2] then
	    begin      
	    writeln('Tsk Tsk Tsk - Wumpus got you!');
	    game := youlost
	    end;
	End  { movewumpus };
 
	Function  lint(    s : alfa;
		       var l : long) : integer;  
	LABEL 3;{EXIT}
	var
	  i, j : integer;
	  negitive : boolean;
	  ch : char;
	begin 
	  j := 0;
	  l := 0;
	  lint := -1;
	  negitive := false;
	  for  i := 1 to length(s) do
	    begin 
	    ch := s[i];
	    If ch in ['0'..'9'] then
	      begin
	      j := j + 1;
	      If j > 36 then
	        begin lint := -2; {EXIT(lint)}goto 3 end;
	      l := l * 10 + (ord(ch) - ord('0'))
	      end 
	    Else
	      If ch = '-' then
		begin If negitive then {EXIT(lint)}goto 3 end
	      Else  {EXIT(lint)}goto 3;
	    end;{ FOR }
	  If l > maxint then
	    lint := j
	  Else
	    lint := 0;
	  If negitive then  l := -l;
	  3:{EXIT}
	end{lint};
 
Procedure doshot;
var
  path : array[1..5] of integer;
  rooms, i, j, arrow : integer;
  roomok, targethit : boolean;
  l : long;
  ans : alfa;
begin
 { program the arrow }
  Repeat
    write('No. of rooms (1-5) ');
    readln(ans);   
    i := lint(ans, l);
    rooms := trunc(l);
  Until  (i = 0) and (rooms >= 1) and (rooms <= 5);              
  for  i := 1 to rooms do
    begin
    Repeat
      roomok := true;
      write('Room # ');
      readln(ans);  
      j := lint(ans, l);
      roomok := (j = 0) and (l > 0) and (l < 21);
      path[i] := trunc(l);
      If i > 2 then
	If path[i] = path[i-2] then
	  begin
	  writeln('Arrows aren''t that crooked - try another room');
	  roomok := false;
	  end;
      If not roomok then  write(bell);  
    Until  roomok;
    end;
    { shoot the arrow }
  arrowcount := arrowcount - 1;
  I := 1;
  arrow := locate[1];
  Repeat 
    roomok := false; 
    for  j := 1 to 3 do
      If cave[arrow,j] = path[i] then  roomok := true;
    If roomok then
      arrow := path[i]
    Else
      arrow := randroom;
    If arrow = locate[1] then
	begin    
	writeln('OUCH! Arrow got YOU!');
	game := youlost
	end 
    Else
      If arrow = locate[2] then
	begin
	writeln('Aha! You got the Wumpus!');
	game := youwon
	end;
    i := i + 1;
  Until  (i > rooms) or (game <> inprogress);
  Case game of
    inprogress:	begin
		If arrowcount=0 then
		  begin
		  writeln('Out of arrows!!');
		  game := youlost;
		  end
		Else
		  writeln('missed');
		MoveWumpus;
		end;
   youwon:	{dummy};
   youlost:	MoveWumpus
   end{of Case};
end  { doshot };
 
Procedure domove; 
var
  room, i, location : integer;
  roomok, movefinished : boolean;
  l : long;
  ans : alfa;
begin
  location := locate[1];
  Repeat
    write('Where to? '); 
    readln(ans); 
    roomok := false;
    i := lint(ans, l);
    room := trunc(l);
    If i = 0 then
      begin
      for  i := 1 to 3 do
	If room = cave[location,i] then  roomok := true;
      If room = location then  roomok := true;
      end;{ If i=0 }
    If not roomok then  writeln('Not possible');
  Until  roomok;
  location := room;
  Repeat  
    locate[1] := location;
    movefinished := true; 
    If location = locate[2] then
      begin
      writeln('... OOPS!  Bumped a Wumpus');
      movewumpus
      end;
    If game = inprogress then
      If (location = locate[3]) or (location = locate[4]) then
	begin
	writeln('YYYIIEEEE . . . Fell in a pit!');
	game := youlost
	end
      Else
	If (location = locate[5]) or (location = locate[6]) then
	  begin
	  writeln('ZAP -- Super bat snatch! Elsewhereville for you!'); 
	  movefinished := false;
	  location := randroom
	  end;
  Until  movefinished;
end  { do move }; 
 
begin { HuntTheWumpus } 
  arrowcount := 5; 
  for  i := 1 to 6 do locate[i] := initlocate[i];       
  game := inprogress;
  writeln;
  writeln(Title);
  writeln;
{}  REPEAT
      warnings;
      Case WantToShoot of
	TRUE:	If game<>youlost then Doshot;
	FALSE:	If game<>youlost then DoMove
      End{of case};
{}  Until game<>inprogress;
  If game = youwon then
    writeln('Hee Hee Hee - The Wumpus''ll getcha next time.')
  Else
    writeln('Ha Ha Ha - You lose!');
end{ huntthewumpus };
 
Function newsetup: boolean;
begin
  newsetup := QUIRY('Same setup (y-n) ');
end;

Function newcave: boolean;
begin
  newcave := QUIRY('Same cave (y-n) ');
end;

Function  alldone : boolean; 
begin
  alldone := Quiry('Play again (y-n) ');
end;
 
begin{ Main Program Wumpus }
  terminit; 
  Instruct;
  Repeat
     getacave;
     If fatal_error then{ABORT}goto 99;
     Repeat 
       initsetup;
       Repeat
	 HuntTheWumpus;
       Until  newsetup;
     Until  newcave
  Until  alldone;
99:{ABORT}
End{of Wumpus}.
