{PROGRAM AUTHOR: Mark Aldon Weiss  PROGRAM DONATED TO PUBLIC DOMAIN}

CONST

MaxNumRows = 105;   MaxNumCols = 92;   MaxLengthRowString = 125;

{ MaxLengthRowString is greater than MaxNumCols to allow for spillover on  }
{ input so that user may use repeat key to, say, type alot of noncreatures }
{ without worrying about typing exactly enough to fill the row.            }



TYPE

Colony = Array[1..MaxNumRows,1..MaxNumCols] of Char;



VAR

again: Boolean;

GenCount,NumOcc1st,CreatureCount,HowManyMore,i: Integer;

creature,noncreature,how1st,HowRand,option,ch : Char;

NumRows: 0..MaxNumRows;    NumCols: 0..MaxNumCols;    SpaceRequired: Integer;

frac1st: Real;    field: 1..2;    GRID: Colony;    PrintFormat: 1..3;

RowString: String[MaxLengthRowString];



PROCEDURE  HELP;

Begin  {HELP}
Writeln;
Writeln(' N#--type an N and then any positive integer; the next');
Writeln('     # generations are computed and displayed.');
Writeln(' S#--type an S and then any positive integer; the next');
Writeln('     # generations are computed and the last displayed.');
Writeln(' Q#--type a Q and any integer in order to QUIT the current');
Writeln('     grid.  You will then be able to start a new one.')
End;   {HELP}



PROCEDURE  GetOptions;

Begin  {GetOptions}
Writeln;
Writeln(' You may have a maximum of ',MaxNumRows,' rows in your grid.');
Writeln(' How many rows do you want for your grid (remember,');
Write(' no creatures are allowed in the first or last row)?    ');
Readln(NumRows);    Writeln;
Writeln(' You may have a maximum of ',MaxNumCols,' columns in your grid.');
Writeln(' How many columns do you want for your grid (remember,');
Write(' no creatures are allowed in the first or last column)?    ');
Readln(NumCols);
Writeln;
Write(' Type the character you want to represent a creature ------->  ');
Readln(creature);
Write(' Type the character you want to represent a NONcreature ---->  ');
Readln(noncreature);
Writeln;
Writeln(' While the terminal display will have no spaces between the grid');
Writeln(' characters, you may have a blank space between the grid characters');
Write(' on the printout.  Do you want a blank separating characters?      ');
Readln(ch);    Writeln;
IF ch IN ['y','Y'] THEN Field := 2 ELSE Field := 1;
SpaceRequired := NumCols * Field + 25;
IF SpaceRequired <= 66 THEN PrintFormat := 1;
IF (SpaceRequired > 66) AND (SpaceRequired <= 80) THEN PrintFormat := 2;
IF (SpaceRequired > 80) AND (SpaceRequired <= 132) THEN PrintFormat := 3;
IF SpaceRequired > 132 THEN
   Begin
   Field := 1;
   PrintFormat := 3;
   SpaceRequired := NumCols + 25;
   If SpaceRequired > 132 Then
      Begin
      Writeln(#7,' WARNING:  Your grid will have too many columns to fit on');
      Writeln('           one line of the printout.  You will therefore get');
      Writeln('           wrap-arounds, but your grid will still print.');
      Writeln
      End
   End;
REPEAT
  Writeln(' Do you want a random first generation (type r) or do you want to');
  Write(' make your own first generation (type s)?     ');
  Readln(how1st)
UNTIL how1st IN ['r','R','s','S'];
IF how1st IN ['r','R'] THEN
   Begin
   REPEAT
     Writeln(' Do you want BOTH the number and the placement of creatures to');
     Writeln(' be random (type b) or only the placement of creatures to be');
     Write(' random (type p)?     ');    Readln(HowRand)
   UNTIL HowRand IN ['b','B','p','P'];
   If HowRand In ['p','P'] Then
      Begin
      Writeln(' What fraction (between 0 & 1) of your first generation grid');
      Write(' do you want to be occupied (i.e., have creatures)?     ');
      Readln(frac1st);
      NumOcc1st := ROUND( frac1st * (NumRows-2) * (NumCols-2) )
      End
   End
End;   {GetOptions}



PROCEDURE  PrintGrid;

Var  r,c,midpt: Integer;

Begin  {PrintGrid}
IF GenCount = 1 THEN CreatureCount := NumOcc1st;
midpt := NumRows DIV 2;
FOR r := 1 to (midpt-1) DO
    Begin
    Write(lst,' ');  For c := 1 to NumCols Do Write(lst,GRID[r,c]:Field);
    Writeln(lst)
    End;
Write(lst,' ');  For c := 1 to NumCols Do Write(lst,GRID[midpt,c]:Field);
Writeln(lst,'   GENERATION ',GenCount);
Write(lst,' ');  For c := 1 to NumCols Do Write(lst,GRID[midpt+1,c]:Field);
Writeln(lst,'   Frac. Occ. = ',CreatureCount/( (NumRows-2)*(NumCols-2) ):8:6);
FOR r := (midpt+2) to NumRows DO
    Begin
    Write(lst,' ');  For c := 1 to NumCols Do Write(lst,GRID[r,c]:Field);
    Writeln(lst)
    End
End;   {PrintGrid}



PROCEDURE  WriteGridToTerminal;

Var  r,c,midpt: Integer;

Begin  {WriteGridToTerminal}
IF GenCount = 1 THEN CreatureCount := NumOcc1st;
midpt := NumRows DIV 2;
FOR r := 1 to (midpt-1) DO
    Begin
    Write(' ');  For c := 1 to NumCols Do Write(GRID[r,c]);
    Writeln
    End;
Write(' ');  For c := 1 to NumCols Do Write(GRID[midpt,c]);
Writeln('   GENERATION ',GenCount);
Write(' ');  For c := 1 to NumCols Do Write(GRID[midpt+1,c]);
Writeln('   Frac. Occ. = ',CreatureCount/( (NumRows-2)*(NumCols-2) ):8:6);
FOR r := (midpt+2) to NumRows DO
    Begin
    Write(' ');  For c := 1 to NumCols Do Write(GRID[r,c]);
    Writeln
    End
End;   {WriteGridToTerminal}



PROCEDURE  FirstGen;

Var   c,r,midpt: Integer;   ch,correction: char;

Begin  {FirstGen}
FOR r := 1 to NumRows DO FOR c := 1 to NumCols DO GRID[r,c] := noncreature;
IF how1st IN ['s','S'] THEN
   Begin
   NumOcc1st := 0;
   Writeln(' ':10,'C O L U M N');
   Write(' ':10);
   FOR c := 2 to (NumCols-1) DO Write( (10+c) MOD 10 );
   Writeln;
   FOR r := 2 to (NumRows-1) DO
       Begin
       Write(' row',r:3,':  ');
       Readln(RowString);
       For c := 2 to (NumCols-1) Do
           Begin
           GRID[r,c] := RowString[c-1];
           IF GRID[r,c] = creature THEN NumOcc1st := NumOcc1st + 1
           End
       End;
   midpt := NumRows DIV 2;
   Writeln;  Writeln;
   Writeln(' This is your first generation grid as it now stands:');
   Writeln;
   Writeln(' ':10,'C O L U M N');
   Write(' ':10);
   FOR c := 2 to (NumCols-1) DO Write( (10+c) MOD 10 );
   Writeln;
   FOR r := 2 to (midpt-1) DO
       Begin
       Writeln;
       Write(' row',r:3,':  ');
       For c := 2 to (NumCols-1) Do Write(GRID[r,c])
       End;
   Writeln;
   Write(' row',midpt:3,':  ');
   FOR c := 2 to (NumCols-1) Do Write(GRID[midpt,c]);
   Writeln('   GENERATION 1');
   Write(' row',(midpt+1):3,':  ');
   FOR c := 2 to (NumCols-1) Do Write(GRID[midpt+1,c]);
   Write('   Fraction Nonborder Occupied = ');
   Write(NumOcc1st/( (NumRows-2)*(NumCols-2) ):8:6);
   FOR r := (midpt+2) to (NumRows-1) DO
       Begin
       Writeln;
       Write(' row',r:3,':  ');
       For c := 2 to (NumCols-1) Do Write(GRID[r,c])
       End;
   Writeln;  Writeln;
   Write(' Do you want to make any corrections?    ');
   Readln(correction);
   IF correction IN ['y','Y'] THEN WHILE correction IN ['y','Y'] DO
      Begin
      Write(' Row of mistake ----->   ');  Readln(r);
      Write(' Column of mistake -->   ');  Readln(c);
      Write(' Desired creature or non-creature character');
      Write(' for this location ---->   ');  Readln(ch);
      GRID[r,c] := ch;
      Write(' Any more corrections?   ');
      Readln(correction)
      End
   End;
IF how1st IN ['r','R'] THEN
   Begin
   IF HowRand IN ['b','B'] THEN
      NumOcc1st := ROUND( RANDOM*(NumRows-2)*(NumCols-2) );
   CreatureCount := 0;
   WHILE CreatureCount < NumOcc1st DO  {Place a creature randomly}
         Begin
         CreatureCount := CreatureCount + 1;
         REPEAT
            r := ROUND( ((NumRows-1)-2) * RANDOM + 2);
            c := ROUND( ((NumCols-1)-2) * RANDOM + 2)
         UNTIL GRID[r,c] <> creature;
         GRID[r,c] := creature;
         { The REPEAT loop is so that you don't put a creature where there   }
         { already was one since this would not increase the number of ran-  }
         { domly placed creatures.  Once a random grid postion is found that }
         { is not already occupied, a creature is placed in that position.   }
         { The assignments to r and c in the REPEAT loop may be confusing.   }
         { Just keep in mind that for, say, an 11-row grid you want a random }
         { number from 2 to 10.  The assignment accomplishes this.           }
         End;
   WriteGridToTerminal
   End;
PrintGrid
End;   {FirstGen}



PROCEDURE  NextGen;

Var  r,c,NumNeighbors,occupations: Integer;   TempMat: Colony;

     MatNeighbors: Array[1..MaxNumRows,1..MaxNumCols] of Integer;

Begin  {NextGen}
FOR r := 1 to NumRows DO FOR c := 1 to NumCols DO TempMat[r,c] := noncreature;
FOR r := 2 to (NumRows-1) DO FOR c := 2 to (NumCols-1) DO
    Begin
    NumNeighbors := 0;
    IF GRID[r+1,c+1] = creature THEN NumNeighbors := NumNeighbors + 1;
    IF GRID[r+1,c  ] = creature THEN NumNeighbors := NumNeighbors + 1;
    IF GRID[r+1,c-1] = creature THEN NumNeighbors := NumNeighbors + 1;
    IF GRID[r  ,c+1] = creature THEN NumNeighbors := NumNeighbors + 1;
    IF GRID[r  ,c-1] = creature THEN NumNeighbors := NumNeighbors + 1;
    IF GRID[r-1,c+1] = creature THEN NumNeighbors := NumNeighbors + 1;
    IF GRID[r-1,c  ] = creature THEN NumNeighbors := NumNeighbors + 1;
    IF GRID[r-1,c-1] = creature THEN NumNeighbors := NumNeighbors + 1;
    MatNeighbors[r,c] := NumNeighbors
    End;
FOR r := 2 to (NumRows-1) DO FOR c := 2 to (NumCols-1) DO
    IF (MatNeighbors[r,c]<>2) AND (MatNeighbors[r,c]<>3) THEN
       TempMat[r,c] := noncreature ELSE TempMat[r,c] := GRID[r,c];
FOR r := 2 to (NumRows-1) DO FOR c := 2 to (NumCols-1) DO
    IF GRID[r,c] = noncreature THEN
       Begin
       occupations := 0;
       IF GRID[r+1,c+1] = creature THEN occupations := occupations + 1;
       IF GRID[r+1,c  ] = creature THEN occupations := occupations + 1;
       IF GRID[r+1,c-1] = creature THEN occupations := occupations + 1;
       IF GRID[r  ,c+1] = creature THEN occupations := occupations + 1;
       IF GRID[r  ,c-1] = creature THEN occupations := occupations + 1;
       IF GRID[r-1,c+1] = creature THEN occupations := occupations + 1;
       IF GRID[r-1,c  ] = creature THEN occupations := occupations + 1;
       IF GRID[r-1,c-1] = creature THEN occupations := occupations + 1;
       IF occupations = 3 THEN TempMat[r,c] := creature
       End;
CreatureCount := 0;
FOR r := 1 to NumRows DO FOR c := 1 to NumCols DO
    Begin
    GRID[r,c] := TempMat[r,c];
    IF GRID[r,c] = creature THEN CreatureCount := CreatureCount + 1
    End
End;   {NextGen}



BEGIN  { M A I N    P R O G R A M }
Writeln;
Writeln;
Writeln(' This program is the game of life.  It has a great many extra ');
Writeln(' features that will become apparent as the program is executed.');
Writeln(' The rules of life are that a creature will survive in the next');
Writeln(' generation only if there are exactly 2 or 3 neighboring creatures.');
Writeln(' A creature is born in the next generation if there are exactly 3');
Writeln(' creatures surrounding the non-creature grid space.  NO CREATURES');
Writeln(' ARE PERMITTED IN THE BORDER OF THE GRID.');
Writeln;
Writeln(' Turn the printer off.  Turn the knob on the printer to set a page');
Writeln(' so it''s at the top of a sheet.  Turn the printer ON.');
Writeln;
REPEAT
Write(#7,' Did you follow the instructions?   '); Readln(ch)
UNTIL ch IN ['y','Y'];
Writeln(lst,#27'C'#0#11#27'N'#3);
{ codes to Epson printer for length of page = 11 in., skip over perf. 3 lines }
again := TRUE;
WHILE again DO
   Begin
   GenCount := 1;
   GetOptions;
   CASE PrintFormat OF
     1: Writeln(lst,#27'W'#1#15#27'2'#27'U'#0);
     2: Writeln(lst,#27'W'#0#18#27'U'#0#27'2');
     3: IF Field = 1 THEN Writeln(lst,#15#27'U'#1#27'0'#27'W'#0)
        ELSE Writeln(lst,#15#27'U'#0#27'2'#27'W'#0)
     End;  {of CASE}
     {These are various codes to the printer to turn on/off double width}
     {or compressed print or unidirectional printing or 8 lines per inch, etc.}
   Writeln;
   FirstGen;
   Writeln;
   REPEAT
      Writeln;
      Write(' Type N# S# Q# or H4(for help) ---->    ');
      Readln(option,HowManyMore);
      IF option IN ['n','N'] THEN FOR i := 1 to HowManyMore DO
         Begin
         Writeln;  Writeln(lst);
         GenCount := GenCount + 1;
         NextGen;
         WriteGridToTerminal;  PrintGrid
         End;
      IF option IN ['s','S'] THEN
         Begin
         FOR  i := 1 to HowManyMore DO
            Begin
            GenCount := GenCount + 1;
            NextGen
            End;
         Writeln;
         Writeln(lst);
         WriteGridToTerminal;  PrintGrid
         End;
      IF option IN ['q','Q'] THEN
         Begin
         Writeln;  Writeln
         End;
      IF option IN ['h','H'] THEN HELP
   UNTIL option IN ['q','Q'];
   Writeln;
   Write(' Do you want to start over with a new first generation?   ');
   Readln(ch);
   IF ch IN ['y','Y'] THEN again := TRUE ELSE again := FAlSE
   End
END.   { M A I N    P R O G R A M }

