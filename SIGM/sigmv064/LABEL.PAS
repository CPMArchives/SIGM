PROGRAM STICKERS;{$P}
{$C-,M-,F-}

CONST
SPACE = '           ';   {11 spaces-- horizontal distance between end of}
                         {line and next label on form-feed label sheet}
TYPE
BYTE = 0..255;
$STRING255 = STRING 255;
$STRING80 = STRING 80;
$STRING0 = STRING 0;
$STRING35 = STRING 35; 


VAR
ACROSS,TOP_MARGIN,BOTTOM_MARGIN,GAP,WIDTH,HEIGHT,SPACING,COUNTER,NUMBER,I:BYTE;
NUM:REAL;
LINE:ARRAY[1..4] OF $STRING35;
FOUT:TEXT;
CONTINUE:CHAR;
ERROR:BOOLEAN;

FUNCTION LENGTH(X:$STRING255):INTEGER;EXTERNAL;
PROCEDURE SETLENGTH(VAR X:$STRING0; Y:INTEGER);EXTERNAL;


BEGIN
FOR I:= 1 TO 4 DO SETLENGTH(LINE[I],0);

REWRITE ('LST:',FOUT);
WRITELN(CHR(27),'*',CHR(0),CHR(0),CHR(0),CHR(0)); {clear screen}

writeln('enter a "1" if there is a single label per "line", and a ');
write('         "3" if there are 3 labels per "line":  ');
repeat
read(SPACING);
until SPACING  in [1,3]; {allow either 1 or 3 labels across only, since}
                       {these are the most commonly found form-feed labels}
ERROR:=FALSE;
REPEAT
writeln;
writeln;
write('enter the width of the label in number of characters: ');
readln(WIDTH);
writeln;
writeln;
writeln('enter the total number of vertical lines per label measured from ');
write(' the top to the bottom of the label: ');
READLN(HEIGHT);  {SOME LABELS HAVE A GREATER HEIGHT THAN OTHERS}
WRITELN;
writeln;
writeln('the total: top margin + bottom margin + 4 must be < or = the ');  
writeln('total number of vertical lines per label... remebering this, ');
writeln;
write('enter the number of lines you wish left at top of label as margin:  ');
readln(TOP_MARGIN);
writeln;
writeln;
write('enter the # of lines you wish left at bottom of label as margin:  ');
readln(BOTTOM_MARGIN);
if HEIGHT < (top_margin + bottom_margin + 4) then error := true;
if error = true then writeln('ERROR IN MEASUREMENT.  PLEASE RE-ENTER.  ');
UNTIL ERROR = FALSE;

write('enter the number of lines between labels, i.e. the gap: ');
readln(gap);
writeln;
writeln; 

WRITE('ENTER THE NUMBER OF LABELS YOU NEED:  ');
READLN(NUM);
CASE SPACING OF 
1: NUMBER:=ROUND(NUM);
3:BEGIN
NUMBER:=ROUND(NUM/3.0); {there are three labels across "line" of the sheet}
If (Num/3.0  - number) > 0 then number:=number + 1;
END;	{i.e err on side of printing too many lines of labels}
END; {OF CASE}

WRITELN(CHR(27),'*',CHR(0),CHR(0),CHR(0),CHR(0));

writeln('NOTE: MAXIMUM LENGTH OF ANY LINE IS ',WIDTH-5:3,' CHARACTERS! ');
WRITELN;
WRITELN;

FOR I:= 1 TO 4 DO 
	BEGIN
	WRITELN('ENTER LINE NUMBER:  ',I:2,'  ');
	READLN(LINE[I]);
	END;

FOR I:= 1 TO 4 DO 
	IF (LENGTH(LINE[I]) > (WIDTH-5)) THEN SETLENGTH(LINE[I],(WIDTH-5)) ELSE
	FOR COUNTER:= LENGTH(LINE[I]) TO (WIDTH-5) DO APPEND(LINE[I],' ');
	
{don't allow lines wider than WIDTH-5 since these wouldn't fit neatly on label}
{and, if the line is < WIDTH-5 characters, pad it so it will appear centered}

writeln('Prepare printer, by positioning printer head  approximately ');
writeln('five spaces from left edge and at very top of the 1st label');
writeln('and then enter a carriage return. ');
READLN(CONTINUE);


FOR I:= 1 TO NUMBER DO  
	BEGIN
		FOR COUNTER:= 1 TO TOP_MARGIN DO WRITELN(FOUT);

		FOR COUNTER:= 1 TO 4 DO
	IF SPACING = 1 THEN WRITELN(FOUT,LINE[COUNTER]) 
				ELSE
	WRITELN(FOUT,LINE[COUNTER],SPACE,LINE[COUNTER],SPACE,LINE[COUNTER]);

	FOR COUNTER:= 1 TO (BOTTOM_MARGIN + GAP) DO WRITELN(FOUT);
	{allow for vertical distance between labels on form feed sheet...}
		
	END;

END.